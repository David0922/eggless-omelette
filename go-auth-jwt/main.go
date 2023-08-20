package main

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()

	r.Use(middleware.Logger)

	r.Post("/api/v1/register", register)
	r.Post("/api/v1/login", login)

	r.Group(func(r chi.Router) {
		r.Use(Authenticator)

		r.Get("/api/v1/protected", protected)
	})

	bindAddr := "0.0.0.0:3000"
	log.Printf("listening at %s\n", bindAddr)

	if err := http.ListenAndServe(bindAddr, r); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
