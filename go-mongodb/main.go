package main

import (
	"context"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

func dbClient(uri string) (*mongo.Client, func(), error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		cancel()
		return nil, nil, err
	}

	// ping the primary
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		cancel()
		return nil, nil, err
	}
	log.Println("successfully connected and pinged")

	return client, func() {
		cancel()

		if err := client.Disconnect(ctx); err != nil {
			log.Fatal(err)
		}
	}, nil
}

func main() {
	_, disconnect, err := dbClient(os.Getenv("MONGODB_URI"))
	if err != nil {
		log.Fatal(err)
	}
	defer disconnect()
}
