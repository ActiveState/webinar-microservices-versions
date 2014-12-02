package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func name_v1_handler(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintln(w, "Phil")
}

func crash_handler(w http.ResponseWriter, req *http.Request) {
	os.Exit(1)
}

func main() {
	http.HandleFunc("/v1/name", name_v1_handler)
	http.HandleFunc("/crash", crash_handler)
	addr := ":" + os.Getenv("PORT")
	fmt.Printf("Listening on %v\n", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
