## setup dev env

### install cmake & ninja

```
# linux
sudo apt install ninja-build

CMAKE_VER=v3.31.3
sudo apt install libssl-dev openssl
git clone --branch $CMAKE_VER --depth 1 https://github.com/Kitware/CMake.git
cd CMake
./bootstrap && make && sudo make install

# mac
brew install cmake ninja
```

### install dependencies

```bash
vcpkg --disable-metrics install --recurse
```

### update vcpkg baseline

```bash
vcpkg --disable-metrics x-update-baseline
```

### show package versions

```bash
vcpkg --disable-metrics list
```

### create `CMakeUserPresets.json`

```json
{
  "version": 2,
  "configurePresets": [
    {
      "name": "default",
      "inherits": "vcpkg",
      "environment": {
        "VCPKG_ROOT": "path/to/vcpkg"
      }
    }
  ]
}
```

## format

```bash
find . \( -path ./build -o -path ./vcpkg_installed \) -prune -o \
  -type f \( -name '*.cc' -o -name '*.h' \) -exec clang-format -i {} +
```

## build

```
cmake --preset=default
cmake --build build
```

## run

```
./build/main_http
```

## verify that it works

```
curl localhost:3000
```

## clean

```
rm -rf ./build
```
