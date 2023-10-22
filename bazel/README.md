## generate `BUILD` for go projects

```bash
bazel run //:gazelle

# specific dir
bazel run //:gazelle -- dir1 dir2
```

## sync bazel with go.mod

```bash
go mod tidy

bazel run //:gazelle-update-repos
bazel run //:gazelle
```

## update `requirements.txt`

```bash
mamba update --all --yes

pip list --format=freeze > requirements.txt
```

## build

```bash
# build all
bazel build //...

# build a target (e.g. cpp_server)
bazel build //cpp_server
```

## run

```bash
# run a target
bazel run //cpp_server

# or

# run binary manually
./bazel-bin/cpp_server/cpp_server
```

## clean

```bash
bazel clean --async

sudo rm -rf ~/.cache/bazel
```

---

#### bazel target pattern syntax

https://grpc.io/blog/bazel-rules-protobuf/#13-target-pattern-syntax

![](./target-pattern-syntax.png)
