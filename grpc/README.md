setup go client / server

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# generate / sync `go.sum`
go mod tidy
```

test grpc server with `grpcurl`

```bash
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

grpcurl -plaintext -proto ./schema/calculator.proto -d @ localhost:3000 Calculator.Add <<EOM
{
  "a": 1,
  "b": 2
}
EOM
```
