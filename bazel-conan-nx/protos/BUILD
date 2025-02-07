# gazelle:ignore

load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_proto_grpc_go//:defs.bzl", "go_grpc_library")

cc_library(
    name = "calc_cc_grpc",
    srcs = glob(["calculator*.cc"]),
    hdrs = glob(["calculator*.h"]),
    visibility = ["//visibility:public"],
    deps = [
        "@grpc",
        "@protobuf",
    ],
)

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

go_grpc_library(
    name = "calc_go_grpc",
    importpath = "dummy.mofu.dev/protos",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
)
