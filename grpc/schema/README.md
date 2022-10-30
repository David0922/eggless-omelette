setup

```bash
# linux
sudo apt install protobuf-compiler

# mac
brew install protobuf
```

format

```bash
clang-format -i --style=Google ./*.proto
```

build

```bash
# go
protoc \
  --go_out=. \
  --go_opt=paths=source_relative \
  --go-grpc_out=. \
  --go-grpc_opt=paths=source_relative \
  ./*.proto

# typescript (grpc-web)
# todo
```
