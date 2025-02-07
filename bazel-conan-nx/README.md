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

# --expunge: removes the entire working tree and stops the bazel server
bazel clean --expunge

# linux
sudo rm -rf ~/.cache/bazel
rm -rf ~/.conan2

# mac
sudo rm -rf  /private/var/tmp/_bazel*
rm -rf ~/.conan2
```
