package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

type GoogleAuthorizationResponse struct {
	code string
	err  error
}

type GoogleExchangeTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	RefreshToken string `json:"refresh_token"`
	Scope        string `json:"scope"`
	TokenType    string `json:"token_type"`
}

type GoogleRefreshTokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
	Scope       string `json:"scope"`
	TokenType   string `json:"token_type"`
}

func googleRefreshTokenRequest(clientID string, clientSecret string, refreshToken string) (*GoogleRefreshTokenResponse, error) {
	refreshTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://oauth2.googleapis.com/token",
		nil,
		map[string]string{
			"client_id":     clientID,
			"client_secret": clientSecret,
			"grant_type":    "refresh_token",
			"refresh_token": refreshToken,
		},
		nil,
	)
	if err != nil {
		return nil, err
	}

	var refreshTokenRes GoogleRefreshTokenResponse
	if err = json.Unmarshal(refreshTokenRaw, &refreshTokenRes); err != nil {
		return nil, err
	}

	return &refreshTokenRes, nil
}

func google() {
	var wg sync.WaitGroup
	defer wg.Wait()

	authResCh := make(chan *GoogleAuthorizationResponse)

	wg.Add(1)
	go func() {
		defer wg.Done()

		mux := http.NewServeMux()
		srv := &http.Server{
			Addr:    ":3000",
			Handler: mux,
		}
		mux.HandleFunc("/auth/google", func(w http.ResponseWriter, req *http.Request) {
			authorizationCode := req.URL.Query().Get("code")
			authorizationError := req.URL.Query().Get("error")

			if authorizationError != "" {
				authResCh <- &GoogleAuthorizationResponse{
					code: "",
					err:  fmt.Errorf(authorizationError),
				}
				w.Write([]byte(authorizationError))
			} else if authorizationCode == "" {
				authResCh <- &GoogleAuthorizationResponse{
					code: "",
					err:  fmt.Errorf("empty authorization code"),
				}
				w.Write([]byte("empty authorization code"))
			} else {
				authResCh <- &GoogleAuthorizationResponse{
					code: authorizationCode,
					err:  nil,
				}
				w.Write([]byte("done"))
			}

			go srv.Shutdown(context.Background())
		})

		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalln(err)
		} else {
			log.Println("shutdown 0.0.0.0:3000/auth/google")
		}
	}()

	clientID := os.Getenv("GOOGLE_CLIENT_ID")
	clientSecret := os.Getenv("GOOGLE_CLIENT_SECRET")
	redirectURI := "http://localhost:3000/auth/google"

	// scope for user info
	scope := "https://www.googleapis.com/auth/userinfo.email"

	authorizeURL, err := HTTPRequestURL("https://accounts.google.com/o/oauth2/v2/auth", map[string]string{
		"client_id":     clientID,
		"redirect_uri":  redirectURI,
		"response_type": "code",
		"scope":         scope,
		"access_type":   "offline",
	})
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("go to the following link in your browser and complete the sign-in prompts:", authorizeURL)

	authRes := <-authResCh
	if authRes.err != nil {
		log.Fatalf("failed to get authorized from google: %v\n", authRes.err)
	}

	authTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://oauth2.googleapis.com/token",
		nil,
		map[string]string{
			"client_id":     clientID,
			"client_secret": clientSecret,
			"code":          authRes.code,
			"grant_type":    "authorization_code",
			"redirect_uri":  redirectURI,
		},
		nil,
	)
	if err != nil {
		log.Fatalf("failed to exchange authorization code for access and refresh tokens: %v\n", err)
	}

	var authTokenRes GoogleExchangeTokenResponse
	if err = json.Unmarshal(authTokenRaw, &authTokenRes); err != nil {
		log.Fatalln(err)
	}
	accessToken := authTokenRes.AccessToken
	refreshToken := authTokenRes.RefreshToken
	tokenExpiration := time.Now().Add(time.Duration(authTokenRes.ExpiresIn) * time.Second)

	if time.Now().After(tokenExpiration) {
		log.Println("access token expired; refreshing access token")

		refreshTokenRes, err := googleRefreshTokenRequest(clientID, clientSecret, refreshToken)
		if err != nil {
			log.Fatalf("failed to refresh access token: %v\n", err)
		}
		accessToken = refreshTokenRes.AccessToken
		// tokenExpiration = time.Now().Add(time.Duration(refreshTokenRes.ExpiresIn) * time.Second)
	}

	// access protected resource
	userInfo, _, err := HTTPRequest(
		http.MethodPost,
		"https://openidconnect.googleapis.com/v1/userinfo",
		map[string]string{"Authorization": "Bearer " + accessToken},
		nil,
		nil,
	)
	if err != nil {
		log.Fatalf("failed to get user info: %v\n", err)
	} else {
		log.Println("user info:", string(userInfo))
	}
}
