load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")

cc_library(
    name = "pet",
    srcs = ["pet.cc"],
    hdrs = ["pet.h"],
)

pybind_extension(
    name = "pet_pybind",
    srcs = ["pet_pybind.cc"],
    deps = [":pet"],
)

py_library(
    name = "pet_pybind_lib",
    data = [":pet_pybind.so"],
)

py_binary(
    name = "main",
    srcs = ["main.py"],
    main = "main.py",
    deps = [":pet_pybind_lib"],
)
