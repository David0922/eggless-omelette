load("@rules_proto//proto:defs.bzl", "proto_library")
load("//:cc_grpc.bzl", "cc_grpc")

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

# cpp_grpc_library(
#     name = "calc_cc_grpc",
#     protos = [":calc_proto"],
#     visibility = ["//visibility:public"],
#     deps = ["//:vcpkg"],
# )

cc_grpc(
    name = "calc_cc_grpc",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
    deps = ["//:vcpkg"],
)
