load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_grpc_server_lib",
    srcs = ["main.go"],
    importpath = "dummy.mofu.dev/go_grpc_server",
    visibility = ["//visibility:private"],
    deps = [
        "//protos:calc_go",
        "@org_golang_google_grpc//:go_default_library",
    ],
)

go_binary(
    name = "go_grpc_server",
    embed = [":go_grpc_server_lib"],
    visibility = ["//visibility:public"],
)
