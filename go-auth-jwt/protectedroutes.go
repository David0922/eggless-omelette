package main

import (
	"log"
	"net/http"
)

func protected(w http.ResponseWriter, req *http.Request) {
	username := req.Context().Value(UsernameCtxKey{}).(string)
	log.Printf("%s accessed /api/v1/protected", username)

	w.Write([]byte("Ϟ(๑⚈ ․̫ ⚈๑)⋆ " + username))
}
