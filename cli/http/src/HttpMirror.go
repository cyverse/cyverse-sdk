package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
)

var mirrorlogpath = flag.String("log", "httpmirror.log", "Enter location of request log")
var port = flag.String("port", "3000", "Enter port for web server")

func main() {
	// parse the global parameters from the command line
	flag.Parse()
	http.HandleFunc("/", httpmirror)

	fmt.Println("Server started on port: ", *port)
	fmt.Println("Server requests logged to: ", *mirrorlogpath)

	log.Fatal(http.ListenAndServe(":"+*port, nil))
}

func httpmirror(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Agave Webhook Mirror"))
	var dump, _ = httputil.DumpRequest(r, true)

	write(dump)
	w.Write(dump)
}

// func port() string {
// 	// port := flag.String("port", "3000", "Enter port for web server")
// 	flag.Parse()
// 	return *port
// }

func write(s []byte) {

	f, err1 := os.OpenFile(*mirrorlogpath, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0666)
	if err1 != nil {
		fmt.Println(err1.Error())
	}
	defer f.Close()

	fmt.Println(string(s))

	_, err2 := f.Write(s)
	if err2 != nil {
		log.Panic(err2)
	}

	f.Sync()
}
