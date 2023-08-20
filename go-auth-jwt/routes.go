package main

import (
	"bytes"
	"encoding/json"
	"net/http"
)

type Credential struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func register(w http.ResponseWriter, req *http.Request) {
	var credential Credential

	userDB := UserDB()

	if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if _, ok := userDB[credential.Username]; ok {
		http.Error(w, "username already exists", http.StatusBadRequest)
		return
	}

	salt, err := RandStr()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	hash := Argon2id(credential.Password, salt)

	userDB[credential.Username] = User{Username: credential.Username, Salt: salt, Hash: hash}
}

func login(w http.ResponseWriter, req *http.Request) {
	var credential Credential

	userDB := UserDB()

	if err := json.NewDecoder(req.Body).Decode(&credential); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	user, ok := userDB[credential.Username]
	if !ok {
		http.Error(w, "incorrect credential", http.StatusUnauthorized)
		return
	}

	if hash := Argon2id(credential.Password, user.Salt); !bytes.Equal(hash, user.Hash) {
		http.Error(w, "incorrect credential", http.StatusUnauthorized)
		return
	}

	jwt, err := NewJWT(JWTKey(), user.Username)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Write([]byte(jwt))
}
