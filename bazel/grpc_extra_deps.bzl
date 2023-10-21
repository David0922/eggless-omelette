"""
fork of https://github.com/grpc/grpc/blob/v1.54.3/bazel/grpc_extra_deps.bzl, without:

go_rules_dependencies()
go_register_toolchains(version = "1.18")
gazelle_dependencies()
"""

load("@build_bazel_apple_support//lib:repositories.bzl", "apple_support_dependencies")
load("@build_bazel_rules_apple//apple:repositories.bzl", "apple_rules_dependencies")
load("@com_envoyproxy_protoc_gen_validate//:dependencies.bzl", "go_third_party")
load("@com_google_googleapis//:repository_rules.bzl", "switched_rules_by_language")
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@envoy_api//bazel:repositories.bzl", "api_dependencies")
load("@upb//bazel:workspace_deps.bzl", "upb_deps")

def grpc_extra_deps(ignore_version_differences = False):
    protobuf_deps()

    upb_deps()

    api_dependencies()

    # Pull-in the go 3rd party dependencies for protoc_gen_validate, which is
    # needed for building C++ xDS protos
    go_third_party()

    apple_rules_dependencies(ignore_version_differences = ignore_version_differences)

    apple_support_dependencies()

    # Initialize Google APIs with only C++ and Python targets
    switched_rules_by_language(
        name = "com_google_googleapis_imports",
        cc = True,
        grpc = True,
        python = True,
    )
