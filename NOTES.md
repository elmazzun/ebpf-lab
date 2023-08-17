# NOTES

Some notes I found useful:

## CO-RE, BTF, libbpf

CO-RE enables eBPF programs that can run on kernel versions different from the 
versions on which they were built.

Compile Once - Run Everywhere (CO-RE) approach consists of a few elements:

- **BTF (BPF Type Format)**: it is a format for expressing the layout of data 
  structures and function signatures. In CO-RE it's used to determine any 
  differences between the structures used at compilation time and at runtime. 

- **Kernel headers**: `bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h`  
  `vmlinux.h` defines all kernel's data type. When the program is run on a 
  target machine, the user space program that loads it into the kernel will 
  make adjustments to account for differences between this build-time BTF 
  information and the BTF information for the kernel that’s running on that 
  target machine.  
  Instead of picking the right header file of the structures you are interested 
  in, just include `vmlinux.h`.

- **Compiler support**: Clang compiler was enchanced so that when it compiles 
  eBPF programs with `-g` flag, it includes *CO-RE relocations*, derived from 
  the BTF information describing the kernel data structures.  
  `-O2` optimization flag is required for Clang to produce BPF bytecode that 
  will pass the verifier.  
  If you are using certain macros defined by *libbpf*, you'l need to specify 
  *target architecture* at compile time: you can do this by setting 
  `-D __TARGET_ARCH_($ARCH)`: maybe it is better to say *compile once per*
  *architecture, run everywhere*.

- **Library support for data structure relocations**: 

- **BPF skeleton (optional)**: if you are writing user space code in C (as I 
  am currently doing), you may want to generate functions that user space code 
  can call to manage the lifecycle of BPF programs; the alternative is using 
  directly the functions defined in libbpf library but those may be too low-level.  
  `bpftool gen skeleton example.bpf.o > example.skel.h`.  
  Once the skeleton has been generated, you don't really need the object file 
  anymore.

## Get statistics about syscalls for a program

```bash
$ strace -c echo "ebpf"
ebpf
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 84,52    0,003878        3878         1           execve
  3,86    0,000177          22         8           mmap
  3,71    0,000170          56         3           openat
  1,22    0,000056           9         6           pread64
  1,11    0,000051          17         3           mprotect
  1,05    0,000048           9         5           close
  0,98    0,000045          45         1           munmap
  0,83    0,000038           9         4           fstat
  0,83    0,000038          12         3           brk
  0,63    0,000029          29         1           write
  0,52    0,000024          24         1         1 access
  0,39    0,000018           9         2         1 arch_prctl
  0,35    0,000016          16         1           read
------ ----------- ----------- --------- --------- ----------------
100.00    0,004588                    39         2 total
```

# Inspect loaded programs

`bpftool` can list all the programs that are loaded into the kernel.

```bash
$ bpftool prog list
...
540: xdp name hello tag d35b94b4c0c10efb gpl
        loaded_at 2022-08-02T17:39:47+0000 uid 0
        xlated 96B jited 148B memlock 4096B map_ids 165,166
        btf_id 254

$ bpftool prog show id 540 --pretty
{
    "id": 540,
    "type": "xdp",
    "name": "hello",
    ...
}
```

You can view all the network-attached eBPF programs:

```bash
$ bpftool net list
xdp:
eth0(2) driver id 540

tc:

flow_dissector:
```

## Parse network packet

```c
void *data = (void *)(long)ctx->data;
void *data_end = (void *)(long)ctx->data_end;

struct ethhdr *eth = data;
if (data + sizeof(struct ethhdr) > data_end)
    return XDP_ABORTED;

if (bpf_ntohs(eth->h_proto) != ETH_P_IP)
    return XDP_PASS;

struct iphdr *iph = data + sizeof(struct ethhdr);
if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) > data_end)
    return XDP_ABORTED;

/* iph->protocol == IPPROTO_ICMP | IPPROTO_TCP | ... */
```
