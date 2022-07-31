FROM golang:alpine AS build
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go mod tidy
RUN go build -o main .

FROM alpine
COPY --from=build /app/main /app/main
CMD ["/app/main"]
