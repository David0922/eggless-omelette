### install cmake

```
sudo apt install cmake

brew install cmake
```

### install boost c++

```
sudo apt install libboost-all-dev

brew install boost
```

### build locally

```
mkdir build
cd build
cmake ..
make
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
