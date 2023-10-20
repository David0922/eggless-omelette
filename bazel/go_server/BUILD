load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_binary(
    name = "go_server",
    embed = [":go_server_lib"],
    visibility = ["//visibility:public"],
)

go_library(
    name = "go_server_lib",
    srcs = ["main.go"],
    importpath = "dummy.mofu.dev/go_server",
    visibility = ["//visibility:private"],
    deps = [
        "//go_lib",
        "@com_github_go_chi_chi_v5//:chi",
        "@com_github_go_chi_chi_v5//middleware",
        "@com_github_go_chi_cors//:cors",
    ],
)
