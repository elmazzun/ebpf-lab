# ibipief

Some experiments with eBPF

## Build the lab

Create Docker image that compiles source:

```
$ ./build.sh
```

## Compile sources

```
$ ./run.sh
```

## Run binary

```
$ sudo ./ibipief
```

## Useful stuff

- [Every Boring Problem Found in eBPF](https://tmpout.sh/2/4.html)

- [bcc Reference Guide](https://android.googlesource.com/platform/external/bcc/+/refs/heads/android10-c2f2-s1-release/docs/reference_guide.md#6-bpf_get_current_comm) (API)

- [unknown opcode 8d](https://stackoverflow.com/questions/70392721/unable-to-load-ebpf-program-loading-stops-at-13-func-bpf-prog1-type-id-9-inval)

- [Learning eBPF](https://cilium.isovalent.com/hubfs/Learning-eBPF%20-%20Full%20book.pdf) (book)

- [aquasecurity examples](https://github.com/aquasecurity/libbpfgo/tree/main/selftest)

## Thanks to

- https://github.com/lizrice/libbpfgo-beginners/tree/main

- https://github.com/grantseltzer/libbpfgo-example

- https://blog.aquasec.com/libbpf-ebpf-programs