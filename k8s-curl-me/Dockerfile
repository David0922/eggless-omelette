FROM golang:alpine AS build
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go mod tidy
RUN CGO_ENABLED=0 go build -o main .

FROM scratch
COPY --from=build /app/main /app/main
CMD ["/app/main"]
