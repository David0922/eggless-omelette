package main

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

func HTTPRequestURL(endpoint string, params map[string]string) (string, error) {
	urlVal := url.Values{}
	for k, v := range params {
		urlVal.Add(k, v)
	}

	url, err := url.Parse(endpoint)
	if err != nil {
		return "", err
	}
	url.RawQuery = urlVal.Encode()

	return url.String(), nil
}

func HTTPRequest(method string, endpoint string, headers map[string]string, params map[string]string, body []byte) ([]byte, int, error) {
	url, err := HTTPRequestURL(endpoint, params)
	if err != nil {
		return nil, 0, err
	}

	req, err := http.NewRequest(method, url, bytes.NewBuffer(body))
	if err != nil {
		return nil, 0, err
	}

	for k, v := range headers {
		req.Header.Add(k, v)
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, 0, err
	} else if res.StatusCode != http.StatusOK {
		return nil, res.StatusCode, fmt.Errorf("url: %s; req.Header: %v; res.Status: %v", url, req.Header, res.Status)
	}
	defer res.Body.Close()

	resBody, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, res.StatusCode, err
	}

	return resBody, res.StatusCode, nil
}
