#!/bin/bash

docker run --rm -it --privileged \
    -v /lib/modules:/lib/modules:ro \
    -v /sys:/sys:ro \
    -v /usr/src:/usr/src:ro \
    ebpf-lab:0.1.0
