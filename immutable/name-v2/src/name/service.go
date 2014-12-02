package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func name_v2_handler(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintln(w, "[\"Phil\", \"John\"]")
}

func crash_handler(w http.ResponseWriter, req *http.Request) {
	os.Exit(1)
}

func main() {
	http.HandleFunc("/v2/name", name_v2_handler)
	http.HandleFunc("/crash", crash_handler)
	addr := ":" + os.Getenv("PORT")
	fmt.Printf("Listening on %v\n", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
