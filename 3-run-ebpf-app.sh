#!/bin/bash

PWD_ABSOLUTE_PATH=$(pwd)

docker run -it \
    --rm \
    --privileged \
    --cap-add=SYS_ADMIN \
    --cap-add=NET_ADMIN \
    --cap-add=BPF \
    --mount type=bind,source=/sys/fs/bpf,target=/sys/fs/bpf \
    --mount type=bind,source=/sys/kernel/debug,target=/sys/kernel/debug \
    -v "$PWD_ABSOLUTE_PATH/my-ebpf":/my-ebpf \
    "$(whoami)/ebpf-lab:0.1.0" ./my-ebpf