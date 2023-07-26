#!/bin/bash

# https://pkg.go.dev/net/http/pprof
# https://go.dev/blog/pprof
go tool pprof http://localhost:6060/debug/pprof/heap
