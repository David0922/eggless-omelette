package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"connectrpc.com/connect"
	"github.com/rs/cors"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	pb "dummy.mofu.dev/protos/gen_go"
	connectPb "dummy.mofu.dev/protos/gen_go/gen_go_connect"
)

type server struct {
	logger zerolog.Logger
}

func (s *server) Add(
	ctx context.Context,
	req *connect.Request[pb.AddRequest],
) (*connect.Response[pb.AddResponse], error) {
	res := connect.NewResponse(&pb.AddResponse{C: req.Msg.GetA() + req.Msg.GetB()})
	s.logger.Info().Interface("request", req).Interface("response", res).Send()
	return res, nil
}

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	logger := zerolog.New(zerolog.ConsoleWriter{Out: os.Stderr}).With().Caller().Timestamp().Logger().Level(zerolog.DebugLevel)

	s := &server{logger}

	mux := http.NewServeMux()
	path, connectHandler := connectPb.NewCalculatorHandler(s)
	c := cors.New(cors.Options{AllowedHeaders: []string{"*"}})
	handler := c.Handler(connectHandler)
	mux.Handle(path, handler)

	// use h2c so we can serve HTTP/2 without TLS
	if err := http.ListenAndServe("0.0.0.0:3000", h2c.NewHandler(mux, &http2.Server{})); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
