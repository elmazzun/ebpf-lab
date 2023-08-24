# https://github.com/lizrice/learning-ebpf/blob/main/chapter5/Makefile

TARGET = my-ebpf
ARCH := $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')
BPFTOOL ?= /usr/sbin/bpftool

BPF_OBJ = ${TARGET:=.bpf.o}
USER_C = ${TARGET:=.c}
USER_SKEL = ${TARGET:=.skel.h}

LIBBPF_INCLUDES = -I /usr/local/bpf/include
LIBBPF_LIBS = -L /usr/local/bpf/lib64 -lbpf

all: $(TARGET) $(BPF_OBJ)
.PHONY: all

%.bpf.o: %.bpf.c vmlinux.h
	clang \
		-target bpf \
		-D__TARGET_ARCH_$(ARCH) \
		-Wall \
		-O2 -g \
		-c $< -o $@ 
	llvm-strip -g $@

$(USER_SKEL): $(BPF_OBJ)
	$(BPFTOOL) gen skeleton $< > $@

vmlinux.h:
	$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

$(TARGET): $(USER_C) $(USER_SKEL) 
	clang \
		-g -O2 \
		-D__TARGET_ARCH_$(ARCH) \
		$(LIBBPF_INCLUDES) \
		-o my-ebpf my-ebpf.c \
		$(LIBBPF_LIBS) \
		-lbpf -lelf -lz
 
clean:
	rm -f $(TARGET) ${BPF_OBJ} ${USER_SKEL}
