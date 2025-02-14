package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

func main() {
	ip := "0.0.0.0"
	port := 3000
	bindAddr := fmt.Sprintf("%s:%d", ip, port)

	// http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
	// 	log.Printf("req: %+v\n", req)
	// 	fmt.Fprintf(w, "goodbye world\n")
	// })

	router := chi.NewRouter()

	router.Use(cors.Handler(cors.Options{}))
	router.Use(middleware.Logger)

	router.Get("/", func(w http.ResponseWriter, req *http.Request) {
		w.Write([]byte("goodbye world\n"))
	})

	log.Printf("listening at %s\n", bindAddr)

	// if err := http.ListenAndServe(bindAddr, nil); err != nil {
	if err := http.ListenAndServe(bindAddr, router); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
