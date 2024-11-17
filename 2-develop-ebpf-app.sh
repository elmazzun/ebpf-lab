#!/bin/bash

docker run -it \
    --rm \
    --privileged \
    --network host \
    "$(whoami)/my-ebpf-builder:0.1.0" bash