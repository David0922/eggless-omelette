package main

import (
	"context"
	"log"
	"net/http"

	"connectrpc.com/connect"
	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/cors"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	pb "dummy.mofu.dev/protos/gen_go"
	pbConn "dummy.mofu.dev/protos/gen_go/gen_go_connect"
)

type server struct{}

func (s *server) Add(
	ctx context.Context,
	req *connect.Request[pb.AddRequest],
) (*connect.Response[pb.AddResponse], error) {
	log.Printf("request: %+v\n", req)
	return connect.NewResponse(&pb.AddResponse{C: req.Msg.GetA() + req.Msg.GetB()}), nil
}

func main() {
	s := &server{}
	path, handler := pbConn.NewCalculatorHandler(s)

	router := chi.NewRouter()
	router.Use(middleware.Logger)
	router.Use(cors.Handler(cors.Options{AllowedHeaders: []string{"*"}}))
	router.Handle(path+"*", handler)

	// use h2c so we can serve HTTP/2 without TLS
	if err := http.ListenAndServe("0.0.0.0:3000", h2c.NewHandler(router, &http2.Server{})); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
