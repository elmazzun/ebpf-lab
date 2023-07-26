#!/bin/bash

# no --rm

docker run -v $(pwd)/:/app/:z ebpf-lab:0.1.0
