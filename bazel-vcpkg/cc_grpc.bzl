"""
https://github.com/rules-proto-grpc/rules_proto_grpc/blob/5.0.1/modules/core/internal/filter_files.bzl
https://github.com/rules-proto-grpc/rules_proto_grpc/blob/5.0.1/modules/cpp/cpp_grpc_library.bzl
"""

load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_proto_grpc_cpp//:defs.bzl", "cpp_grpc_compile")

def _filter_files_impl(ctx):
    return [DefaultInfo(
        files = depset([
            file
            for file in ctx.attr.target.files.to_list()
            if file.extension in ctx.attr.extensions
        ]),
    )]

filter_files = rule(
    implementation = _filter_files_impl,
    attrs = {
        "target": attr.label(
            doc = "source target to filter",
            mandatory = True,
        ),
        "extensions": attr.string_list(
            doc = "extensions of the files to keep e.g. ['h']",
            mandatory = True,
        ),
    },
)

# buildifier: disable=function-docstring
def cc_grpc(name, protos, visibility, deps):
    name_pb = name + "_pb"
    name_srcs = name_pb + "_srcs"
    name_hdrs = name_pb + "_hdrs"

    cpp_grpc_compile(
        name = name_pb,
        protos = protos,
    )

    filter_files(
        name = name_srcs,
        target = name_pb,
        extensions = ["cc"],
    )

    filter_files(
        name = name_hdrs,
        target = name_pb,
        extensions = ["h"],
    )

    cc_library(
        name = name,
        srcs = [name_srcs],
        hdrs = [name_hdrs],
        includes = [name_pb],
        visibility = visibility,
        deps = deps,
    )
