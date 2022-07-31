cc_binary(
    name = "main",
    srcs = ["main.cc"],
    features = ["fully_static_link"],  # compile a standalone static executable
    deps = [
        "//lib:my-str",
        "@crow",
    ],
)
