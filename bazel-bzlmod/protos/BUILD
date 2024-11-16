load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_proto_grpc_cpp//:defs.bzl", "cpp_grpc_library")
load("@rules_proto_grpc_go//:defs.bzl", "go_grpc_library")
load("@rules_proto_grpc_python//:defs.bzl", "python_grpc_library")

proto_library(
    name = "calc_proto",
    srcs = ["calculator.proto"],
    visibility = ["//visibility:public"],
)

cpp_grpc_library(
    name = "calc_cc_grpc",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
)

go_grpc_library(
    name = "calc_go_grpc",
    importpath = "dummy.mofu.dev/protos",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
)

# gazelle:exclude empty.go

python_grpc_library(
    name = "calc_py_grpc",
    protos = [":calc_proto"],
    visibility = ["//visibility:public"],
)
