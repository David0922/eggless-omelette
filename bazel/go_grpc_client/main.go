package main

import (
	"context"
	"fmt"
	"log"

	pb "dummy.mofu.dev/protos"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	ip := "0.0.0.0"
	port := 3000
	serverAddr := fmt.Sprintf("%s:%d", ip, port)

	conn, err := grpc.Dial(serverAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("failed to connect: %v", err)
	}
	defer conn.Close()
	client := pb.NewCalculatorClient(conn)

	ctx := context.Background()

	for {
		var a, b int32

		fmt.Print("a: ")
		fmt.Scanf("%d", &a)
		fmt.Print("b: ")
		fmt.Scanf("%d", &b)

		response, err := client.Add(ctx, &pb.AddRequest{A: a, B: b})
		if err != nil {
			log.Fatalf("failed to call pb.AddRequest: %v", err)
		}
		log.Printf("response: %+v\n", response)
	}
}
