######## Stage 1: build
# Debian-12 based image
FROM golang:1.23.3-bookworm AS build-env

COPY my-ebpf/ /my-ebpf

WORKDIR /my-ebpf

RUN ls /my-ebpf

# clang version 14.0.6
# LLVM version 14
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y -q && \
    apt-get upgrade -y -q && \
    apt-get install -y -q \
    vim \
    net-tools \
    clang \
    libbpf-dev \
    bpftool \
    linux-headers-amd64 \
    llvm \
    && rm -rf /var/lib/apt/lists/*

RUN bpftool btf dump file /sys/kernel/btf/vmlinux format c > /usr/include/vmlinux.h

######## Stage 2: compile 
FROM build-env AS builder

RUN chmod +x build-app.sh

RUN bash build-app.sh

######## Stage 3: runtime
FROM alpine:latest

COPY --from=builder /my-ebpf/ebpf-test /usr/local/bin/ebpf-test

CMD ["/usr/local/bin/ebpf-test"]