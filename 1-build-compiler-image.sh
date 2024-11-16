#!/bin/bash

docker build \
    -f Dockerfile.cilium \
    -t "$(whoami)/ebpf-lab-cilium:0.1.0" .