### build

```
bazel build --cxxopt='-std=c++17' '...'
```

### test

```
bazel test --test_output=all '...'
```

### clean

```
rm -rf ~/.cache/bazel
bazel clean --async
```
