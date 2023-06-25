#!/bin/bash

# docker run -it --privileged ebpf-lab:0.1.0
#     # -v /lib/modules:/lib/modules:ro \
#     # -v /sys:/sys:ro \
#     # -v /usr/src:/usr/src:ro \

docker run --rm -v $(pwd)/:/app/:z ebpf-lab:0.1.0
