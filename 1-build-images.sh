#!/bin/bash

if ! docker build --target build-env -t "$(whoami)/my-ebpf-env:0.1.0" .; then
    echo "Failed to create eBPF compilation environment"
    exit 1
fi

if ! docker build --target builder -t "$(whoami)/my-ebpf-builder:0.1.0" .; then
    echo "Failed to configure eBPF compilation environment"
    exit 2
fi

if ! docker build -t "$(whoami)/my-ebpf-runtime:0.1.0" .; then
    echo "Failed to create eBPF runtime environment"
    exit 3
fi
