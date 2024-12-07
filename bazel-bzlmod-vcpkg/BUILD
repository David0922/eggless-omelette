cc_library(
    name = "third_party",
    srcs = glob(["vcpkg_installed/x64-linux/lib/**/*.a"]),
    hdrs = glob([
        "vcpkg_installed/x64-linux/include/**/*.h",
        "vcpkg_installed/x64-linux/include/**/*.hpp",
        "vcpkg_installed/x64-linux/include/**/*.ipp",
    ]),
    includes = ["vcpkg_installed/x64-linux/include"],
    linkopts = ["-pthread"],
    linkstatic = False,
    visibility = ["//visibility:public"],
)
