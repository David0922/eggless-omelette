### build locally

```
bazel build --cxxopt='-std=c++17' //main
```

### run locally

```
./bazel-bin/main/main
```

### clean

```
rm -rf ~/.cache/bazel
bazel clean --async
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
