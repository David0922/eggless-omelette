### install bazel

```
BIN=/work-dir/bin
chmod +x ./bazelisk-linux-amd64
mv ./bazelisk-linux-amd64 $BIN
sudo ln -s $BIN/bazelisk-linux-amd64 $BIN/bazel
```

### build

```
bazel build //main:goodbye-world
```

### clean

```
bazel clean --async
```

### execute

```
./bazel-bin/main/goodbye-world
```
