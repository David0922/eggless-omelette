load("@rules_python//python:defs.bzl", "py_binary")

py_binary(
    name = "py_grpc_server",
    srcs = ["main.py"],
    main = "main.py",
    deps = ["//protos:calc_py_grpc"],
)
