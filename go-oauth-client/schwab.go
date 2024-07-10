package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"
)

type SchwabAuthorizationResponse struct {
	code string
	err  error
}

type SchwabExchangeTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	IDToken      string `json:"id_token"`
	RefreshToken string `json:"refresh_token"`
	Scope        string `json:"scope"`
	TokenType    string `json:"token_type"`
}

type SchwabRefreshTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	IDToken      string `json:"id_token"`
	RefreshToken string `json:"refresh_token"`
	Scope        string `json:"scope"`
	TokenType    string `json:"token_type"`
}

func schwabRefreshTokenRequest(clientID string, clientSecret string, refreshToken string) (*SchwabRefreshTokenResponse, error) {
	refreshTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://api.schwabapi.com/v1/oauth/token",
		map[string]string{
			"Authorization": "Basic " + EncodeBasicAuthenticationCredentials(clientID, clientSecret),
			"Content-Type":  "application/x-www-form-urlencoded",
		},
		nil,
		[]byte(url.Values{
			"grant_type":    []string{"refresh_token"},
			"refresh_token": []string{refreshToken},
		}.Encode()),
	)
	if err != nil {
		return nil, err
	}

	var refreshTokenRes SchwabRefreshTokenResponse
	if err = json.Unmarshal(refreshTokenRaw, &refreshTokenRes); err != nil {
		return nil, err
	}

	return &refreshTokenRes, nil
}

func schwab() {
	var wg sync.WaitGroup
	defer wg.Wait()

	authResCh := make(chan *SchwabAuthorizationResponse)

	wg.Add(1)
	go func() {
		defer wg.Done()

		mux := http.NewServeMux()
		srv := &http.Server{
			Addr:    ":3000",
			Handler: mux,
		}
		mux.HandleFunc("/auth/schwab", func(w http.ResponseWriter, req *http.Request) {
			authorizationCode := req.URL.Query().Get("code")
			authorizationError := req.URL.Query().Get("error")

			if authorizationError != "" {
				authResCh <- &SchwabAuthorizationResponse{
					code: "",
					err:  fmt.Errorf(authorizationError),
				}
				w.Write([]byte(authorizationError))
			} else if authorizationCode == "" {
				authResCh <- &SchwabAuthorizationResponse{
					code: "",
					err:  fmt.Errorf("empty authorization code"),
				}
				w.Write([]byte("empty authorization code"))
			} else {
				authResCh <- &SchwabAuthorizationResponse{
					code: authorizationCode,
					err:  nil,
				}
				w.Write([]byte("done"))
			}

			go srv.Shutdown(context.Background())
		})

		if err := srv.ListenAndServeTLS("localhost.crt", "localhost.key"); err != http.ErrServerClosed {
			log.Fatalln(err)
		} else {
			log.Println("shutdown https://0.0.0.0:3000/auth/schwab")
		}
	}()

	clientID := os.Getenv("SCHWAB_CLIENT_ID")
	clientSecret := os.Getenv("SCHWAB_CLIENT_SECRET")
	redirectURI := "https://127.0.0.1:3000/auth/schwab"

	authorizeURL, err := HTTPRequestURL("https://api.schwabapi.com/v1/oauth/authorize", map[string]string{
		"client_id":     clientID,
		"redirect_uri":  redirectURI,
		"response_type": "code",
		"scope":         "api",
	})
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("go to the following link in your browser and complete the sign-in prompts:", authorizeURL)

	authRes := <-authResCh
	if authRes.err != nil {
		log.Fatalf("failed to get authorized from schwab: %v\n", authRes.err)
	}

	authTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://api.schwabapi.com/v1/oauth/token",
		map[string]string{
			"Authorization": "Basic " + EncodeBasicAuthenticationCredentials(clientID, clientSecret),
			"Content-Type":  "application/x-www-form-urlencoded",
		},
		nil,
		[]byte(url.Values{
			"code":         []string{authRes.code},
			"grant_type":   []string{"authorization_code"},
			"redirect_uri": []string{redirectURI},
		}.Encode()),
	)
	if err != nil {
		log.Fatalf("failed to exchange authorization code for access and refresh tokens: %v\n", err)
	}

	var authTokenRes SchwabExchangeTokenResponse
	if err = json.Unmarshal(authTokenRaw, &authTokenRes); err != nil {
		log.Fatalln(err)
	}
	accessToken := authTokenRes.AccessToken
	refreshToken := authTokenRes.RefreshToken
	tokenExpiration := time.Now().Add(time.Duration(authTokenRes.ExpiresIn) * time.Second)

	if time.Now().After(tokenExpiration) {
		log.Println("access token expired; refreshing access token")

		refreshTokenRes, err := schwabRefreshTokenRequest(clientID, clientSecret, refreshToken)
		if err != nil {
			log.Fatalf("failed to refresh access token: %v\n", err)
		}
		accessToken = refreshTokenRes.AccessToken
		// tokenExpiration = time.Now().Add(time.Duration(refreshTokenRes.ExpiresIn) * time.Second)
	}

	// access protected resource
	accountInfo, _, err := HTTPRequest(
		http.MethodGet,
		"https://api.schwabapi.com/trader/v1/accounts",
		map[string]string{"Authorization": "Bearer " + accessToken},
		nil,
		nil,
	)
	if err != nil {
		log.Fatalf("failed to get user info: %v\n", err)
	} else {
		log.Println("user info:", string(accountInfo))
	}
}
