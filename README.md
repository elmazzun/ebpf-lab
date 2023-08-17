# My eBPF lab

Creating and testing eBPF programs on a virtualized Ubuntu machine.

Although loading eBPF programs into the kernel is safe, I did not want to 
install the compilation toolchain for eBPF programs on my host and am 
therefore using a virtual machine to host the toolchain and run test eBPF 
programs.

## Creating the Virtual Machine

Before anything, you must install [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation) 
and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

In order to build the working environment, you will create a Ubuntu-based 
VM by running `vagrant up` command in the root folder of this repository.

**The VM comes with no desktop environment**: since you just have to run 
`make` and `sudo ./my-ebpf-program` from the VM, there's no need for a 
desktop environment.

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

Ideally, this is how you would work while developing new eBPF programs:

- create/turn on the VM with `vagrant up`.  
  Once up, you may access the VM by running `vagrant ssh` or by using VirtualBox 
  GUI, getting a shell and getting inside the VM by using default credentials, 
  which are `vagrant` username and `vagrant` password.

- if you begin a new eBPF project create a new folder in `lab` (eg `my-project`) 
  and put your code in `my-project` folder together with its Makefile;

- compile `my-project` by adding the string `my-project` in `lab/Makefile` first 
  row; `lab/Makefile` loops in all the folders in `lab` and runs the Makefile 
  found in each directory.  
  Thus, if you want to compile all the projects in `lab` just run `make` while 
  being in `/home/vagrant/lab`; you can also compile a single project (say 
  `my-project`) by positioning yourself in `lab` and running `make my-project`.  
  **Be sure to run `make` inside the VM**.

- run the binary with `sudo` **always from inside the VM**.

## Useful stuff

- [Why libbpf and CO-RE](https://nakryiko.com/posts/bcc-to-libbpf-howto-guide/#why-libbpf-and-bpf-co-re)

- [libbpf overwiew](https://libbpf.readthedocs.io/en/latest/libbpf_overview.html)

- [Every Boring Problem Found in eBPF](https://tmpout.sh/2/4.html)

- [bcc Reference Guide](https://android.googlesource.com/platform/external/bcc/+/refs/heads/android10-c2f2-s1-release/docs/reference_guide.md#6-bpf_get_current_comm) (API)

- [unknown opcode 8d](https://stackoverflow.com/questions/70392721/unable-to-load-ebpf-program-loading-stops-at-13-func-bpf-prog1-type-id-9-inval)
