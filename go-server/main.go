package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	ip := "0.0.0.0"
	port := 3000
	bindAddr := fmt.Sprintf("%s:%d", ip, port)

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("goodbye world\n"))
	})

	if err := http.ListenAndServe(bindAddr, mux); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
