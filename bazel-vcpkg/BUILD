cc_library(
    name = "third_party",
    srcs = select({
        "@platforms//os:linux": glob(["vcpkg_installed/x64-linux/lib/**/*.a"]),
        "@platforms//os:macos": glob(["vcpkg_installed/arm64-osx/lib/**/*.a"]),
    }),
    hdrs = select({
        "@platforms//os:linux": glob([
            "vcpkg_installed/x64-linux/include/**/*.h",
            "vcpkg_installed/x64-linux/include/**/*.hpp",
            "vcpkg_installed/x64-linux/include/**/*.ipp",
            "vcpkg_installed/x64-linux/include/**/*.inc",
        ]),
        "@platforms//os:macos": glob([
            "vcpkg_installed/arm64-osx/include/**/*.h",
            "vcpkg_installed/arm64-osx/include/**/*.hpp",
            "vcpkg_installed/arm64-osx/include/**/*.ipp",
            "vcpkg_installed/arm64-osx/include/**/*.inc",
        ]),
    }),
    includes = select({
        "@platforms//os:linux": ["vcpkg_installed/x64-linux/include"],
        "@platforms//os:macos": ["vcpkg_installed/arm64-osx/include"],
    }),
    linkopts = ["-pthread"],
    linkstatic = False,
    visibility = ["//visibility:public"],
)
