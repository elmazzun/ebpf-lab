FROM debian:12

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y \
    vim \
    clang \
    llvm \
    build-essential \
    make \
    libbpf-dev \
    bpftool \
    bpfcc-tools && rm -rf /var/lib/apt/lists/*

WORKDIR /my-ebpf