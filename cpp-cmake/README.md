### install cmake

```
sudo apt install cmake ninja-build

brew install cmake ninja
```

### install boost c++

```
sudo apt install libboost-all-dev

brew install boost
```

### build locally

```bash
mkdir build
cd build

# make
cmake ..
make -j $(nproc)

# ninja
cmake -G Ninja ..
ninja -j $(nproc)
```

### clean

```
rm -rf ./build
```

### run locally

```
./build/main
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
