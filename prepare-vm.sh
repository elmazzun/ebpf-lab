#!/bin/bash

# https://www.sobyte.net/post/2022-07/c-ebpf/

export DEBIAN_FRONTEND=noninteractive
sudo apt update

sudo apt install -y \
    tree \
    coreutils bsdutils findutils \
    binutils-dev libcap-dev \
    build-essential pkgconf \
    clang clang-format \
    llvm \
    linux-headers-generic \
    linux-tools-generic \
    zlib1g-dev libelf-dev libbpf-dev

# download and compile libbpf
git clone https://github.com/libbpf/libbpf.git
cd /home/vagrant/libbpf/src
NO_PKG_CONFIG=1 make -j

# download and compile bpftool
cd /home/vagrant/
git clone https://github.com/libbpf/bpftool.git
cd /home/vagrant/bpftool
# bpftools repository uses libbpf as submodule: since we have already cloned 
# libbpf, just init the submodule by running the following command:
git submodule update --init
cd /home/vagrant/bpftool/src
make -j

# install the compiled libbpf library under /usr/local/bpf for subsequent
# shared dependencies of all libbpf-based programs
cd /home/vagrant/libbpf/src
sudo BUILD_STATIC_ONLY=1 NO_PKG_CONFIG=1 PREFIX=/usr/local/bpf make install
tree /usr/local/bpf

# install bpftool again
cd /home/vagrant/bpftool/src/
sudo NO_PKG_CONFIG=1 make install

# make sure /usr/local/sbin is in your PATH path
which bpftool
