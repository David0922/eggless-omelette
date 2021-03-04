package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		for _, envVar := range []string{"MY_NODE_NAME", "MY_POD_IP", "MY_POD_NAME", "MY_POD_NAMESPACE", "MY_POD_SERVECE_ACCOUNT"} {
			fmt.Fprintf(w, "%s: %s\n", envVar, os.Getenv(envVar))
		}
	})
	http.ListenAndServe(":8080", nil)
}
