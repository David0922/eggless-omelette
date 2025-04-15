package main

import (
	"context"
	"net/http"
	"runtime/debug"
	"time"

	"github.com/rs/zerolog"
)

type Middleware func(http.Handler) http.Handler

type UsernameCtxKey struct{}

func MiddlewareStack(ms ...Middleware) Middleware {
	return func(next http.Handler) http.Handler {
		for i := len(ms) - 1; i >= 0; i-- {
			next = ms[i](next)
		}
		return next
	}
}

func NewRecovery(logger zerolog.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if r := recover(); r != nil {
					logger.Error().Interface("recover", r).Bytes("stack trace", debug.Stack()).Send()
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}

func NewRequestLogger(logger zerolog.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			t0 := time.Now()
			next.ServeHTTP(w, r)
			logger.
				Info().
				Str("method", r.Method).
				Str("url", r.URL.RequestURI()).
				Interface("from", r.RemoteAddr).
				Str("user_agent", r.UserAgent()).
				Dur("elapsed_ms", time.Since(t0)).Send()
		})
	}
}

func NewAuthenticator(jwtKey []byte, userDB FakeUserDB, _ zerolog.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			tokenString, err := ExtractBearerToken(req)
			if err != nil {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			username, err := ValidateJWT(jwtKey, tokenString)
			if err != nil {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			if _, ok := userDB[username]; !ok {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(req.Context(), UsernameCtxKey{}, username)

			next.ServeHTTP(w, req.WithContext(ctx))
		})
	}
}
