#!/bin/bash

docker build --target build-env -t "$(whoami)/my-ebpf-env:0.1.0" .
docker build --target builder -t "$(whoami)/my-ebpf-builder:0.1.0" .
docker build -t "$(whoami)/my-ebpf-runtime:0.1.0" .