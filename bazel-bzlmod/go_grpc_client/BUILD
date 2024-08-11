load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "go_grpc_client_lib",
    srcs = ["main.go"],
    importpath = "dummy.mofu.dev/go_grpc_client",
    visibility = ["//visibility:private"],
    deps = [
        "//protos:calc_go",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_google_grpc//credentials/insecure",
    ],
)

go_binary(
    name = "go_grpc_client",
    embed = [":go_grpc_client_lib"],
    visibility = ["//visibility:public"],
)
