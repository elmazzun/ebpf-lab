# ibipief

Some experiments with eBPF

Thanks to https://github.com/lizrice/libbpfgo-beginners/tree/main

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

## Troubleshooting

```bash
$ llvm-objdump -h ibipief.bpf.o          

$ llvm-objdump -s ibipief.bpf.o

$ llvm-objdump -S ibipief.bpf.o

$ sudo gdb ./ibipief

```

## Thanks to

