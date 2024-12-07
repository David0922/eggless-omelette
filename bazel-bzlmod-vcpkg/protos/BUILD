load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_proto_grpc_cpp//:defs.bzl", "cpp_grpc_library")

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

cpp_grpc_library(
    name = "calc_cc_grpc",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
    deps = ["//:third_party"],
)
