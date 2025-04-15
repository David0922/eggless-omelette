package main

import (
	"net/http"
	"os"

	"github.com/rs/zerolog"
)

type User struct {
	Username string
	Salt     []byte
	Hash     []byte
}

type FakeUserDB map[string]User

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	logger := zerolog.New(zerolog.ConsoleWriter{Out: os.Stderr}).With().Caller().Timestamp().Logger().Level(zerolog.DebugLevel)

	jwtKey, err := RandStr()
	if err != nil {
		logger.Fatal().Err(err).Send()
	}

	userDB := make(FakeUserDB)

	controller := &Controller{
		jwtKey: jwtKey,
		userDB: userDB,
		logger: logger,
	}

	recovery := NewRecovery(logger)
	requestLogger := NewRequestLogger(logger)
	authenticator := NewAuthenticator(jwtKey, userDB, logger)
	middleware := MiddlewareStack(recovery, requestLogger)

	privileged := http.NewServeMux()
	privileged.HandleFunc("GET /protected", controller.protected)

	v1 := http.NewServeMux()
	v1.HandleFunc("GET /panic", func(w http.ResponseWriter, r *http.Request) {
		panic("oh no ><")
	})
	v1.HandleFunc("POST /register", controller.register)
	v1.HandleFunc("POST /login", controller.login)
	v1.Handle("/", authenticator(privileged))

	mux := http.NewServeMux()
	mux.Handle("/api/v1/", middleware(http.StripPrefix("/api/v1", v1)))

	bindAddr := "0.0.0.0:3000"
	logger.Info().Str("bindAddr", bindAddr).Send()

	if err := http.ListenAndServe(bindAddr, mux); err != nil {
		logger.Fatal().Err(err).Send()
	}
}
