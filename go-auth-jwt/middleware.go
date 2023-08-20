package main

import (
	"context"
	"net/http"
)

type UsernameCtxKey struct{}

func Authenticator(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		tokenString, err := ExtractBearerToken(req)
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		username, err := ValidateJWT(JWTKey(), tokenString)
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		if _, ok := UserDB()[username]; !ok {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(req.Context(), UsernameCtxKey{}, username)

		next.ServeHTTP(w, req.WithContext(ctx))
	})
}
