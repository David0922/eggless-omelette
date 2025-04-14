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

type TradeStationAuthorizationResponse struct {
	code string
	err  error
}

type TradeStationExchangeTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	IDToken      string `json:"id_token"`
	RefreshToken string `json:"refresh_token"`
	Scope        string `json:"scope"`
	TokenType    string `json:"token_type"`
}

type TradeStationRefreshTokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
	Scope       string `json:"scope"`
	IDToken     string `json:"id_token"`
	TokenType   string `json:"token_type"`
}

func tradestationRefreshTokenRequest(clientID string, clientSecret string, refreshToken string) (*TradeStationRefreshTokenResponse, error) {
	refreshTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://signin.tradestation.com/oauth/token",
		map[string]string{"Content-Type": "application/x-www-form-urlencoded"},
		nil,
		[]byte(url.Values{
			"client_id":     []string{clientID},
			"client_secret": []string{clientSecret},
			"grant_type":    []string{"refresh_token"},
			"refresh_token": []string{refreshToken},
		}.Encode()),
	)
	if err != nil {
		return nil, err
	}

	var refreshTokenRes TradeStationRefreshTokenResponse
	if err = json.Unmarshal(refreshTokenRaw, &refreshTokenRes); err != nil {
		return nil, err
	}

	return &refreshTokenRes, nil
}

func tradestation() {
	var wg sync.WaitGroup
	defer wg.Wait()

	authResCh := make(chan *TradeStationAuthorizationResponse)

	wg.Add(1)
	go func() {
		defer wg.Done()

		mux := http.NewServeMux()
		srv := &http.Server{
			Addr:    ":3000",
			Handler: mux,
		}
		// mux.HandleFunc("/auth/tradestation", func(w http.ResponseWriter, req *http.Request) {
		mux.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
			authorizationCode := req.URL.Query().Get("code")
			authorizationError := req.URL.Query().Get("error")

			if authorizationError != "" {
				authResCh <- &TradeStationAuthorizationResponse{
					code: "",
					err:  fmt.Errorf(authorizationError),
				}
				w.Write([]byte(authorizationError))
			} else if authorizationCode == "" {
				authResCh <- &TradeStationAuthorizationResponse{
					code: "",
					err:  fmt.Errorf("empty authorization code"),
				}
				w.Write([]byte("empty authorization code"))
			} else {
				authResCh <- &TradeStationAuthorizationResponse{
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
			log.Println("shutdown https://0.0.0.0:3000/auth/tradestation")
		}
	}()

	clientID := os.Getenv("TRADESTATION_CLIENT_ID")
	clientSecret := os.Getenv("TRADESTATION_CLIENT_SECRET")
	// redirectURI := "https://127.0.0.1:3000/auth/tradestation"
	redirectURI := "http://localhost:3000"

	// authorizeURL, err := HTTPRequestURL("https://signin.tradestation.com/authorize", map[string]string{
	// 	"audience":      "https://api.tradestation.com",
	// 	"client_id":     clientID,
	// 	"redirect_uri":  redirectURI,
	// 	"response_type": "code",
	// 	"scope":         "email MarketData Matrix offline_access openid OptionSpreads profile ReadAccount Trade",
	// })
	// if err != nil {
	// 	log.Fatalln(err)
	// }
	// log.Println("go to the following link in your browser and complete the sign-in prompts:", authorizeURL)

	// authRes := <-authResCh
	// if authRes.err != nil {
	// 	log.Fatalf("failed to get authorized from tradestation: %v\n", authRes.err)
	// }
	authRes := &TradeStationAuthorizationResponse{
		code: "CPICAha2V_8bEyhCuXHBAAYfO2tg50vbod7TYFdGHHRZ1",
	}

	authTokenRaw, _, err := HTTPRequest(
		http.MethodPost,
		"https://signin.tradestation.com/oauth/token",
		map[string]string{
			"Content-Type": "application/x-www-form-urlencoded",
		},
		nil,
		[]byte(url.Values{
			"client_id":     []string{clientID},
			"client_secret": []string{clientSecret},
			"code":          []string{authRes.code},
			"grant_type":    []string{"authorization_code"},
			"redirect_uri":  []string{redirectURI},
		}.Encode()),
	)
	if err != nil {
		log.Fatalf("failed to exchange authorization code for access and refresh tokens: %v\n", err)
	}

	var authTokenRes TradeStationExchangeTokenResponse
	if err = json.Unmarshal(authTokenRaw, &authTokenRes); err != nil {
		log.Fatalln(err)
	}
	accessToken := authTokenRes.AccessToken
	refreshToken := authTokenRes.RefreshToken
	tokenExpiration := time.Now().Add(time.Duration(authTokenRes.ExpiresIn) * time.Second)

	if time.Now().After(tokenExpiration) {
		log.Println("access token expired; refreshing access token")

		refreshTokenRes, err := tradestationRefreshTokenRequest(clientID, clientSecret, refreshToken)
		if err != nil {
			log.Fatalf("failed to refresh access token: %v\n", err)
		}
		accessToken = refreshTokenRes.AccessToken
		// tokenExpiration = time.Now().Add(time.Duration(refreshTokenRes.ExpiresIn) * time.Second)
	}

	// access protected resource
	accountInfo, _, err := HTTPRequest(
		http.MethodGet,
		"https://api.tradestation.com/v3/brokerage/accounts",
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
