## setup dev env

### install cmake & ninja

```
sudo apt install cmake ninja-build

brew install cmake ninja
```

### update vcpkg baseline

```bash
vcpkg --disable-metrics x-update-baseline
```

### show package versions

```bash
vcpkg --disable-metrics list
```

### install dependencies

```bash
vcpkg --disable-metrics install
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

## clean

```
rm -rf ./build
```

## run

```
./build/main_http
```

## verify that it works

```
curl localhost:3000
```
