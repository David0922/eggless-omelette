package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"strings"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

func dbURI() (string, error) {
	dbConfig, err := ioutil.ReadFile("./db.config")
	if err != nil {
		return "", err
	}

	splitted := strings.Split(string(dbConfig), "\n")
	if len(splitted) < 3 {
		return "", fmt.Errorf("failed to load ./db.config")
	}

	username := splitted[0]
	password := splitted[1]
	clusterAddr := splitted[2]

	return fmt.Sprintf("mongodb+srv://%s:%s@%s", username, password, clusterAddr), nil
}

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
	uri, err := dbURI()
	if err != nil {
		log.Fatal(err)
	}

	_, disconnect, err := dbClient(uri)
	if err != nil {
		log.Fatal(err)
	}
	defer disconnect()
}
