FROM ubuntu:22.04 AS build
RUN mkdir /app
WORKDIR /app
RUN apt-get update -qq
RUN apt-get install -qq \
  build-essential \
  git \
  libboost-all-dev \
  wget
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.12.0/bazelisk-linux-amd64
RUN chmod +x ./bazelisk-linux-amd64
RUN ./bazelisk-linux-amd64 --version
ADD . /app
RUN ./bazelisk-linux-amd64 build --cxxopt='-std=c++17' //main

FROM scratch
COPY --from=build /app/bazel-bin/main/main /app/main
CMD ["/app/main"]
