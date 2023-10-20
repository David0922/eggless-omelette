load("@pip_deps//:requirements.bzl", "requirement")
load("@rules_python//python:defs.bzl", "py_binary")

py_binary(
    name = "py_server",
    srcs = ["main.py"],
    main = "main.py",
    deps = [
        "//py_lib",
        requirement("Flask"),
    ],
)
