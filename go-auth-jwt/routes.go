package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/rs/zerolog"
)

type Controller struct {
	jwtKey []byte
	userDB FakeUserDB
	logger zerolog.Logger
}

type Credential struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (c *Controller) register(w http.ResponseWriter, req *http.Request) {
	var credential Credential

	if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
		c.logger.Error().Err(err).Send()
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	credential.Username = strings.TrimSpace(credential.Username)
	credential.Password = strings.TrimSpace(credential.Password)
	if len(credential.Username) == 0 || len(credential.Password) == 0 {
		http.Error(w, "username & password can't be empty", http.StatusBadRequest)
		return
	}

	if _, ok := c.userDB[credential.Username]; ok {
		http.Error(w, "username already exists", http.StatusBadRequest)
		return
	}

	salt, err := RandStr()
	if err != nil {
		c.logger.Error().Err(err).Send()
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	hash := Argon2id(credential.Password, salt)

	c.userDB[credential.Username] = User{Username: credential.Username, Salt: salt, Hash: hash}
}

func (c *Controller) login(w http.ResponseWriter, req *http.Request) {
	var credential Credential

	if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
		c.logger.Error().Err(err).Send()
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	user, ok := c.userDB[credential.Username]
	if !ok {
		http.Error(w, "incorrect credential", http.StatusUnauthorized)
		return
	}

	if hash := Argon2id(credential.Password, user.Salt); !bytes.Equal(hash, user.Hash) {
		http.Error(w, "incorrect credential", http.StatusUnauthorized)
		return
	}

	jwt, err := NewJWT(c.jwtKey, user.Username)
	if err != nil {
		c.logger.Error().Err(err).Send()
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write([]byte(jwt))
}

func (c *Controller) protected(w http.ResponseWriter, req *http.Request) {
	username, ok := req.Context().Value(UsernameCtxKey{}).(string)
	if !ok {
		c.logger.Error().Msg("failed to get username")
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	c.logger.Info().Msgf("%s accessed protected resource", username)
	w.Write([]byte("Ϟ(๑⚈ ․̫ ⚈๑)⋆ " + username + "\n"))
}
