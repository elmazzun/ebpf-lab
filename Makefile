ARCH=$(shell uname -m)

TARGET := ibipief
TARGET_BPF := $(TARGET).bpf.o

# https://github.com/lizrice/libbpfgo-beginners/pull/5/commits/ed85ae895e90452530baa96e813ba17c3e8c129b
GO_SRC := *.go Makefile
BPF_SRC := *.bpf.c *.bpf.h Makefile

LIBBPF_HEADERS := /usr/include/bpf
LIBBPF_OBJ := /usr/lib/$(ARCH)-linux-gnu/libbpf.a

.PHONY: all
all: $(TARGET) $(TARGET_BPF)

go_env := CC="clang -v" CGO_CFLAGS="-I $(LIBBPF_HEADERS)" CGO_LDFLAGS="$(LIBBPF_OBJ)"

$(TARGET): $(GO_SRC)
	$(go_env) go build -o $(TARGET) -buildvcs=false

$(TARGET_BPF): $(BPF_SRC)
	clang \
		-I /usr/include/$(ARCH)-linux-gnu \
		-v -g -O0 -c -target bpf \
		-o $@ $<

.PHONY: clean
clean:
	go clean
