### install cmake

```
sudo apt install cmake ninja-build

brew install cmake ninja
```

### build locally

```bash
# make
cmake -S . -B build
cmake --build build --parallel

# ninja
cmake -S . -B build -G Ninja
ninja -C build
```

### clean

```
rm -rf ./build
```

### run locally

```
./build/app/main
```
