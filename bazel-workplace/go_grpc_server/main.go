package main

import (
	"context"
	"fmt"
	"log"
	"net"

	pb "dummy.mofu.dev/protos"

	"google.golang.org/grpc"
)

type server struct {
	pb.UnimplementedCalculatorServer
}

func (s *server) Add(ctx context.Context, req *pb.AddRequest) (*pb.AddResponse, error) {
	log.Printf("request: %+v\n", req)
	return &pb.AddResponse{C: req.GetA() + req.GetB()}, nil
}

func main() {
	ip := "0.0.0.0"
	port := 3000
	bindAddr := fmt.Sprintf("%s:%d", ip, port)

	lis, err := net.Listen("tcp", bindAddr)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterCalculatorServer(s, &server{})
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
