## install dependencies

```bash
vcpkg --disable-metrics install --recurse
```

## update vcpkg baseline

```bash
vcpkg --disable-metrics x-update-baseline
```

## show package versions

```bash
vcpkg --disable-metrics list
```

## format C++ & protobuf

```bash
find . -path ./vcpkg_installed -prune -o -type f \( -name '*.cc' -o -name '*.h' -o -iname '*.proto' \) -exec clang-format -i {} +
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

# mac
sudo rm -rf  /private/var/tmp/_bazel*
```
