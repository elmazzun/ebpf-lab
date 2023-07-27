# ibipief

This is a virtualised and dockerized environment for creating and testing eBPF 
programs.

The following stacks are used:

- Vagrant: since eBPF programs are hot-loaded on a kernel, I thought it was 
better not to use my host kernel but a virtualized one
- Docker: a Docker image containing the required toolchain to compile a eBPF 
program 

## Create the Virtual Machine

In order to build the working environment you will create a Ubuntu-based 
virtual machine by running `vagrant up --provision` command: `docker` and 
`go` will be installed in the VM.

Once the VM has been provisioned, you may enter the VM by running 
`vagrant ssh`: you may now perform two quick checks in the VM by running:

```bash
vagrant@ubuntu2204:~$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

(docker should be installed and you should be able to use it without being 
root)  
and

```bash
vagrant@ubuntu2204:~$ go version
go version go1.16.7 linux/amd64
```

(Go should be successfully installed).

## Create eBPF compiler Docker image

`lab` directory in this repository should have been mounted in VM 
`/vagrant/lab/` path.

After SSH'ing in the VM, run the following commands:

```bash
# Move to the lab
vagrant@ubuntu2204:~$ cd /vagrant/lab
vagrant@ubuntu2204:/vagrant/lab$ 

# Build eBPF compiler Docker image
vagrant@ubuntu2204:/vagrant/lab$ ./build.sh 
...
 => => naming to docker.io/library/ebpf-lab:0.1.0

# Run eBPF compiler and create the eBPF executable
vagrant@ubuntu2204:/vagrant/lab$ ./run.sh 
CC="clang" CGO_CFLAGS="-I /usr/include/bpf" CGO_LDFLAGS="/usr/lib/x86_64-linux-gnu/libbpf.a" go build -o ibipief -buildvcs=false
go: downloading github.com/aquasecurity/libbpfgo v0.1.0
go: downloading golang.org/x/sys v0.0.0-20210514084401-e8d321eab015
clang \
	-I /usr/include/x86_64-linux-gnu \
	-g -O2 -c -target bpf \
	-o ibipief.bpf.o ibipief.bpf.c

# Finally run the eBPF program with root privileges
vagrant@ubuntu2204:/vagrant/lab$ sudo ./ibipief
>>> module done
>>> object loaded
>>> got program ibipief
```

Open another terminal tab, SSH again in this running VM and see eBPF start 
printing the intercepted programs.

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