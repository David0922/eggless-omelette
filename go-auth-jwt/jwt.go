package main

import (
	"crypto/rand"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/argon2"
)

type JWTClaims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

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
