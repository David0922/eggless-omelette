## install protoc & protobuf plugins

```bash
# grpc
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# connect rpc
go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest
go install github.com/bufbuild/buf/cmd/buf@latest
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
```

## install dependencies

```bash
conan profile detect
conan install . --build=missing
bazel mod tidy
```

## format C++ & protobuf

```bash
find . -type f \( -name '*.cc' -o -name '*.h' -o -iname '*.proto' \) -exec clang-format -i {} +
```

## generate `BUILD` for go projects

```bash
bazel run //:gazelle_go

# specific dir
bazel run //:gazelle_go -- dir1 dir2
```

## sync bazel with go.mod

```bash
# create `deps.bzl` if it doesn't exist
touch deps.bzl

bazel run @io_bazel_rules_go//go -- mod tidy
bazel mod tidy
bazel run //:gazelle_go
```

## build

```bash
# build all
bazel build //...

# build a target (e.g. cc_server)
bazel build //cc_server
```

## run

```bash
# run a target
bazel run //cc_server

# or

# run binary manually
./bazel-bin/cc_server/cc_server
```

## clean

```bash
bazel clean --async

# --expunge: removes the entire working tree and stops the bazel server
bazel clean --expunge

# linux
sudo rm -rf ~/.cache/bazel
rm -rf ~/.conan2

# mac
sudo rm -rf /private/var/tmp/_bazel*
rm -rf ~/.conan2
```
