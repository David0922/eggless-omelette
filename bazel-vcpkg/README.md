## install dependencies

```bash
vcpkg --disable-metrics install --recurse
```

## update vcpkg baseline

```bash
vcpkg --disable-metrics x-update-baseline
```

### show package versions

```bash
vcpkg --disable-metrics list
```

## format C++ & protobuf

```bash
find . -iname vcpkg_installed -prune -o -iname '*.cc' -o -iname '*.h' -o -iname '*.proto' | xargs clang-format -i
```

## build

```bash
# build all
bazel build //...

# build a target (e.g. cpp_server)
bazel build //cpp_server

# build on mac
bazel build --config=macos //...
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

---

#### bazel target pattern syntax

https://grpc.io/blog/bazel-rules-protobuf/#13-target-pattern-syntax

![](./target-pattern-syntax.png)
