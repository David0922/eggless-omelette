package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		log.Printf("req: %+v\n", req)
		fmt.Fprintf(w, "goodbye world\n")
	})

	if err := http.ListenAndServe(":3000", nil); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
