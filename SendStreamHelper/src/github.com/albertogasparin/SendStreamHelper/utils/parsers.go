package utils

import (
	"log"
	"net/url"
	"os"
)

// check if argument is a youtube url
func IsYoutubeURL(query string) (bool, string) {

	u, err := url.ParseRequestURI(query)
	if err != nil {
		return false, ""
	}
	if u.Host == "youtu.be" {
		return true, u.Path[1:]
	}

	u, _ = url.ParseRequestURI(query)
	if u.Host == "www.youtube.com" || u.Host == "youtube.com" {
		v, _ := url.ParseQuery(u.RawQuery)
		return true, v.Get("v")
	}
	return false, ""

}

// check other stream
// return values are "is other scheme" and "is local"
func IsOtherScheme(query string) (isscheme bool, islocal bool) {
	u, err := url.ParseRequestURI(query)
	if err != nil {
		log.Println("Error: not a valid stream or path")
		os.Exit(2)
	}
	if len(u.Scheme) == 0 {
		return
	}
	isscheme = true // no error so, it's a scheme
	islocal = u.Host == "127.0.0.1" || u.Host == "localhost" || u.Host == "localhost.localdomain"
	return
}
