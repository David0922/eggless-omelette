package main

import (
	"log"
	"sync"
)

type User struct {
	Username string
	Salt     []byte
	Hash     []byte
}

type FakeUserDB map[string]User

var (
	once sync.Once

	jwtKey []byte
	userDB FakeUserDB
)

func JWTKey() []byte {
	once.Do(func() {
		if s, err := RandStr(); err != nil {
			log.Fatal(err)
		} else {
			jwtKey = s
		}
	})
	return jwtKey
}

func UserDB() FakeUserDB {
	once.Do(func() {
		userDB = make(FakeUserDB)
	})
	return userDB
}
