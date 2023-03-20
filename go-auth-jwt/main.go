package main

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/argon2"
)

type Credential struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type User struct {
	Username string
	Salt     []byte
	Hash     []byte
}

type FakeUserDB map[string]User

type JWTClaims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

type UsernameCtxKey struct{}

func RandStr() ([]byte, error) {
	salt := make([]byte, 32)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
		return nil, err
	}
	return salt, nil
}

func Argon2id(password string, salt []byte) []byte {
	return argon2.IDKey([]byte(password), salt, 1, 64*1024, 4, 32)
}

func ExtractBearerToken(req *http.Request) (string, error) {
	authHeader := req.Header.Get("Authorization")

	if !strings.HasPrefix(authHeader, "Bearer ") {
		return "", fmt.Errorf("incorrect format")
	}

	return strings.TrimPrefix(authHeader, "Bearer "), nil
}

func NewJWT(jwtKey []byte, username string) (string, error) {
	claims := JWTClaims{
		username,
		jwt.RegisteredClaims{ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour))},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, &claims)

	return token.SignedString(jwtKey)
}

func ValidateJWT(jwtKey []byte, tokenString string) (string, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %+v", token.Header["alg"])
		}

		return jwtKey, nil
	})
	if err != nil {
		return "", err
	}

	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims.Username, nil
	} else {
		return "", fmt.Errorf("invalid token")
	}
}

func NewAuthenticator(fakeUserDB FakeUserDB, jwtKey []byte) func(http.Handler) http.Handler {
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

			_, ok := fakeUserDB[username]
			if !ok {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(req.Context(), UsernameCtxKey{}, username)

			next.ServeHTTP(w, req.WithContext(ctx))
		})
	}
}

func main() {
	fakeUserDB := make(FakeUserDB)

	jwtKey, err := RandStr()
	if err != nil {
		log.Fatalln(err)
	}

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Post("/api/v1/register", func(w http.ResponseWriter, req *http.Request) {
		var credential Credential

		if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		if _, ok := fakeUserDB[credential.Username]; ok {
			http.Error(w, "username already exists", http.StatusBadRequest)
			return
		}

		salt, err := RandStr()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		hash := Argon2id(credential.Password, salt)

		fakeUserDB[credential.Username] = User{Username: credential.Username, Salt: salt, Hash: hash}
	})

	r.Post("/api/v1/login", func(w http.ResponseWriter, req *http.Request) {
		var credential Credential

		if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		user, ok := fakeUserDB[credential.Username]
		if !ok {
			http.Error(w, "incorrect credential", http.StatusUnauthorized)
			return
		}

		if hash := Argon2id(credential.Password, user.Salt); !bytes.Equal(hash, user.Hash) {
			http.Error(w, "incorrect credential", http.StatusUnauthorized)
			return
		}

		jwt, err := NewJWT(jwtKey, user.Username)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write([]byte(jwt))
	})

	r.Group(func(r chi.Router) {
		r.Use(NewAuthenticator(fakeUserDB, jwtKey))

		r.Get("/api/v1/protected", func(w http.ResponseWriter, req *http.Request) {
			username := req.Context().Value(UsernameCtxKey{}).(string)
			log.Printf("%s accessed /api/v1/protected", username)

			w.Write([]byte("Ϟ(๑⚈ ․̫ ⚈๑)⋆"))
		})
	})

	bindAddr := "0.0.0.0:3000"
	log.Printf("listening at %s\n", bindAddr)

	if err := http.ListenAndServe(bindAddr, r); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
