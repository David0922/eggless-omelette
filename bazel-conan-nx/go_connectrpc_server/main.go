package main

import (
	"context"
	"io"
	"log"
	"net/http"
	"os"

	"connectrpc.com/connect"
	"github.com/rs/cors"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/protobuf/proto"

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
	mux.Handle(path, connectHandler)

	mux.HandleFunc("/rest-api/calculator/add", func(w http.ResponseWriter, r *http.Request) {
		resBody, err := io.ReadAll(r.Body)
		defer r.Body.Close()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		req := &pb.AddRequest{}
		if err := proto.Unmarshal(resBody, req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		res := &pb.AddResponse{C: req.GetA() + req.GetB()}
		logger.Info().Interface("request", req).Interface("response", res).Send()

		resBin, err := proto.Marshal(res)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write(resBin)
	})

	handler := cors.New(cors.Options{AllowedHeaders: []string{"*"}}).Handler(mux)

	// use h2c so we can serve HTTP/2 without TLS
	if err := http.ListenAndServe("0.0.0.0:3000", h2c.NewHandler(handler, &http2.Server{})); err != nil {
		log.Fatalf("http.ListenAndServe: %v\n", err)
	}
}
