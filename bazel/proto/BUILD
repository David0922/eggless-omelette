load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

go_proto_library(
    name = "calc_go_proto",
    compilers = ["@io_bazel_rules_go//proto:go_grpc"],
    importpath = "dummy.mofu.dev/proto",
    proto = ":calc_proto",
    visibility = ["//visibility:public"],
)

go_library(
    name = "calc_go",
    embed = [":calc_go_proto"],
    importpath = "dummy.mofu.dev/proto",
    visibility = ["//visibility:public"],
)

# gazelle:exclude empty.go
