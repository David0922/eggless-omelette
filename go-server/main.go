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

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		log.Printf("req: %+v\n", req)
		fmt.Fprintf(w, "goodbye world\n")
	})

	log.Printf("listening at %s\n", bindAddr)

	if err := http.ListenAndServe(bindAddr, nil); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
