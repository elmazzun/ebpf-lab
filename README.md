# My eBPF lab

⚠️⚠️⚠️

This repository is under heavy refactoring!  
**Do not clone it!**  
I am currently modifying the environment from a virtualized-based environment 
to a container-based.  
I am planning to adapt this repository so that it can be used as a stand-alone 
container building eBPF pipeline or together with https://github.com/elmazzun/debian-12-vm.

⚠️⚠️⚠️

**You may test this eBPF lab in your local machine or you may use my**
**[virtualized environment](https://github.com/elmazzun/debian-12-vm) where**
**this repository is included as submodule**.

## Creating the Virtual Machine

The provisioning script `prepare-vm.sh` will install the following components:

- `clang`: the compiler used to make eBPF target files from C programs.  
  clang is a compiler front-end for C (and other languages), using LLVM as the 
  back-end.

- `libbpf`: the BPF program loader. It takes compiled BPF ELF object file, 
  post-process it as necessary, sets up various kernel objects (maps, programs, 
  etc) and triggers BPF programs loading and verification.  
  libbpf is downloaded from official repository https://github.com/libbpf/libbpf.git, 
  compiled and installed in the VM.

- `bpftool`: a tool used to inspect and manipulate eBPF programs.  
  bpftool is downloaded from official repository https://github.com/libbpf/bpftool, 
  compiled and installed in the VM.

The structure of this repository is pretty straightforward:

```bash
$ tree -L 1
.
├── lab           # The whole eBPF working environment
├── prepare-vm.sh # VM provisioning script
├── README.md     # This file
└── Vagrantfile   # VM configuration script
```

- `Vagrantfile` will create the VM, configure it, mount `lab` folder inside the 
  VM and provision it by running `prepare-vm.sh`.

- `prepare-vm.sh` is the provisioning script: it downloads and installs the 
  necessary packages (clang, libbpf, bpftool and others).

- `lab`: this folder contains the eBPF projects I will work on.  
  `lab` is a Vagrant *synced folder*: this means that you may edit from your 
  host machine whatever you want in `lab` and all the changes are automatically 
  applied to   `lab` guest machine and viceversa.  
  If you destroy the VM, `lab` files won't be lost.

## Working with the VM

Compile `my-project` by adding the string `my-project` in `lab/Makefile` first 
row; `lab/Makefile` loops in all the folders in `lab` and runs the Makefile 
found in each directory.  
Thus, if you want to compile all the projects in `lab` just run `make` while 
being in `/home/vagrant/lab`; you can also compile a single project (say 
`my-project`) by positioning yourself in `lab` and running `make my-project`.  

## Useful stuff

- [Why libbpf and CO-RE](https://nakryiko.com/posts/bcc-to-libbpf-howto-guide/#why-libbpf-and-bpf-co-re)

- [libbpf overwiew](https://libbpf.readthedocs.io/en/latest/libbpf_overview.html)

- [Every Boring Problem Found in eBPF](https://tmpout.sh/2/4.html)

- [bcc Reference Guide](https://android.googlesource.com/platform/external/bcc/+/refs/heads/android10-c2f2-s1-release/docs/reference_guide.md#6-bpf_get_current_comm) (API)

- [unknown opcode 8d](https://stackoverflow.com/questions/70392721/unable-to-load-ebpf-program-loading-stops-at-13-func-bpf-prog1-type-id-9-inval)
