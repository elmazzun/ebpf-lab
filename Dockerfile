FROM debian:12

ENV DEBIAN_FRONTEND="noninteractive"

# Install required software
RUN apt-get update && apt-get install -y \
    clang \
    llvm \
    build-essential \
    make \
    libbpf-dev \
    bpftool \
    bpfcc-tools

# Import eBPF environment
COPY ./my-ebpf /root/my-ebpf
