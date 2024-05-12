load("@rules_python//python:defs.bzl", "py_binary", "py_library")

py_binary(
    name = "main",
    srcs = ["main.py"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//py_lib",
        "@pip//flask",
    ],
)

py_library(
    name = "py_server",
    srcs = ["main.py"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//py_lib",
        "@pip//flask",
    ],
)
