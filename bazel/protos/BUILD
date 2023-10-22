load("@com_github_grpc_grpc//bazel:cc_grpc_library.bzl", "cc_grpc_library")
load("@com_github_grpc_grpc//bazel:python_rules.bzl", "py_grpc_library", "py_proto_library")
load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

cc_proto_library(
    name = "calc_cc_proto",
    visibility = ["//visibility:public"],
    deps = [":calc_proto"],
)

cc_grpc_library(
    name = "calc_cc_grpc",
    srcs = [":calc_proto"],
    grpc_only = True,
    visibility = ["//visibility:public"],
    deps = [":calc_cc_proto"],
)

go_proto_library(
    name = "calc_go_proto",
    compilers = ["@io_bazel_rules_go//proto:go_grpc"],
    importpath = "dummy.mofu.dev/protos",
    proto = ":calc_proto",
    visibility = ["//visibility:public"],
)

go_library(
    name = "calc_go",
    embed = [":calc_go_proto"],
    importpath = "dummy.mofu.dev/protos",
    visibility = ["//visibility:public"],
)

# gazelle:exclude empty.go

py_proto_library(
    name = "calc_py_proto",
    visibility = ["//visibility:public"],
    deps = [":calc_proto"],
)

# can't compile in mamba env
# has to be compiled in virtualenv
py_grpc_library(
    name = "calc_py_grpc",
    srcs = [":calc_proto"],
    visibility = ["//visibility:public"],
    deps = [":calc_py_proto"],
)
