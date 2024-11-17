#!/bin/bash

# --privileged:   for seting memlock rlimit
# --network host: for using host network
docker run --rm -it \
    --privileged \
    --network host \
    "$(whoami)/my-ebpf-runtime:0.1.0"