FROM ubuntu:24.04 AS build
RUN mkdir /app
WORKDIR /app
RUN apt-get update -qq
RUN apt-get install -qq \
  build-essential \
  cmake \
  git \
  libboost-all-dev
ADD . /app
RUN cmake .
RUN make

FROM ubuntu:24.04
COPY --from=build /app/main /app/main
CMD ["/app/main"]
