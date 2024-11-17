#!/bin/bash

go mod init ebpf-test

go mod tidy

go get github.com/cilium/ebpf/cmd/bpf2go

go generate

# CGO_ENABLED=0: statically compile eBPF program
# GOOS=linux:    compile it for Linux
# GOARCH=amd64:  compile it for x86_64
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build