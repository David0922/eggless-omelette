FROM alpine:3.21.3
RUN apk add gcc git linux-headers make musl-dev
RUN git clone --recursive --branch 1_36_1 --depth 1 https://git.busybox.net/busybox
WORKDIR /busybox
RUN make defconfig
RUN sed -i "s|CONFIG_PREFIX=\"./_install\"|CONFIG_PREFIX=\"/build\"|" ./.config
RUN sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' ./.config
RUN make -j $(nproc)
CMD ["make", "install"]
