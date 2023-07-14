### install bazel

```
BIN=/work-dir/bin
chmod +x ./bazelisk-linux-amd64
mv ./bazelisk-linux-amd64 $BIN
sudo ln -s $BIN/bazelisk-linux-amd64 $BIN/bazel
```

### install boost c++

```
sudo apt install libboost-all-dev
```

#### known issue

bazel can't find Boost C++ in macOS

### build locally

```
bazel build --cxxopt='-std=c++17' //main
```

### clean

```
rm -rf ~/.cache/bazel
bazel clean --async
```

### run locally

```
./bazel-bin/main/main
```

### build docker image

```
docker build -t cpp-server .
```

### run docker container

```
docker run --rm -it -p 3000:3000 cpp-server
```

### verify that it works

```
curl localhost:3000
```
