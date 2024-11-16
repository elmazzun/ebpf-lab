# My eBPF lab

Compile and run a simple eBPF program within a Docker container.

Every `tracepoint/syscalls/sys_enter_execve` match will print the process that invoked `sys_enter_execve` syscall.

- [Compile and run](#compile-and-run)
- [Environment](#environment)
- [Useful stuff](#useful-stuff)

## Compile and run

Your Linux kernel should be version 4.1 or newer; in addition, the kernel should have been compiled with some flags. 

```bash
# Check if required flags have been enabled
$ ./0-check-kernel-config.sh 
CONFIG_BPF=y
CONFIG_HAVE_EBPF_JIT=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_KPROBES=y
CONFIG_UPROBES=y
CONFIG_DEBUG_FS=y
CONFIG_FTRACE=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_KPROBE_EVENTS=y
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y

CONFIG_NET_SCH_SFQ=m
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_DUMMY=m
CONFIG_VXLAN=m
```

If you are good, run this script in order to build the environment where you 
will build the eBPF program.

```bash
$ ./1-build-compiler-image.sh 
[+] Building 1.2s (7/7) FINISHED                                               docker:default
 ...
 => => naming to docker.io/<USER>/ebpf-lab:0.1.0 
```

Run this script in order to compile the eBPF program in a container. 

```bash
$ ./2-build-ebpf-app.sh      
clang \
	-target bpf \
	-D__TARGET_ARCH_x86 \
	-Wall \
	-O2 -g \
	-c my-ebpf.bpf.c -o my-ebpf.bpf.o 
llvm-strip -g my-ebpf.bpf.o
/usr/sbin/bpftool gen skeleton my-ebpf.bpf.o > my-ebpf.skel.h
clang \
	-g -O2 \
	-D__TARGET_ARCH_x86 \
	-I /usr/local/bpf/include \
	-o my-ebpf my-ebpf.c \
	-L /usr/local/bpf/lib64 -lbpf \
	-lbpf -lelf -lz
```

Lastly, run your eBPF program in a container.

```bash
$ ./3-run-ebpf-app.sh  
libbpf: loading object 'my_ebpf_bpf' from buffer
libbpf: elf: section(3) tracepoint/syscalls/sys_enter_execve, size 120, link 0, flags 6, type=1
libbpf: sec 'tracepoint/syscalls/sys_enter_execve': found program 'bpf_prog' at insn offset 0 (0 bytes), code size 15 insns (120 bytes)
...
libbpf: map 'my_ebpf_.rodata': created successfully, fd=5
Successfully started! Please run `sudo cat /sys/kernel/debug/tracing/trace_pipe` to see output of the BPF programs.
.........Reached 10 iterations, cleaning BPF program...
```

As suggested in the output above, you may run `sudo cat /sys/kernel/debug/tracing/trace_pipe` 
in another terminal so that you may see the eBPF program output.

```bash
$ sudo cat /sys/kernel/debug/tracing/trace_pipe
...
             git-25426   [005] ...21  1168.373928: bpf_trace_printk: invoke bpf_prog: Hello, World!

             git-25429   [007] ...21  1168.378629: bpf_trace_printk: invoke bpf_prog: Hello, World!

            tail-25432   [004] ...21  1168.382694: bpf_trace_printk: invoke bpf_prog: Hello, World!

             git-25433   [007] ...21  1168.382749: bpf_trace_printk: invoke bpf_prog: Hello, World!
...
```
## Environment

Tested on `Docker 27.3.1` and Linux Mint 21 with `6.8.0-40-generic` kernel.

These are BPF packages installed in `<USER>/ebpf-lab:0.1.0` Docker image:

```bash
root@73f5b9bbdf5d:/my-ebpf# dpkg -l | grep -i bpf
ii  bpfcc-tools                     0.26.0+ds-1                    all          tools for BPF Compiler Collection (BCC)
ii  bpftool                         7.1.0+6.1.115-1                amd64        Inspection and simple manipulation of BPF programs and maps
ii  libbpf-dev:amd64                1:1.1.0-1                      amd64        eBPF helper library (development files)
ii  libbpf1:amd64                   1:1.1.0-1                      amd64        eBPF helper library (shared library)
ii  libbpfcc:amd64                  0.26.0+ds-1                    amd64        shared library for BPF Compiler Collection (BCC)
ii  libpfm4:amd64                   4.13.0-1                       amd64        Library to program the performance monitoring events
ii  python3-bpfcc                   0.26.0+ds-1                    all          Python 3 wrappers for BPF Compiler Collection (BCC)
```

## Useful stuff

https://ebpf-go.dev/guides/getting-started/#compile-ebpf-c-and-generate-scaffolding-using-bpf2go

- [Why libbpf and CO-RE](https://nakryiko.com/posts/bcc-to-libbpf-howto-guide/#why-libbpf-and-bpf-co-re)

- [libbpf overwiew](https://libbpf.readthedocs.io/en/latest/libbpf_overview.html)

- [Every Boring Problem Found in eBPF](https://tmpout.sh/2/4.html)

- [bcc Reference Guide](https://android.googlesource.com/platform/external/bcc/+/refs/heads/android10-c2f2-s1-release/docs/reference_guide.md#6-bpf_get_current_comm) (API)

- [unknown opcode 8d](https://stackoverflow.com/questions/70392721/unable-to-load-ebpf-program-loading-stops-at-13-func-bpf-prog1-type-id-9-inval)
