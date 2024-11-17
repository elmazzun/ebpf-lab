# TODO

doc:
- [ ] add table of contents to NOTES.md
- [ ] write about *Library support for data structure relocations* in NOTES.md

eBPF projects:
- [ ] export eBPF in Prometheus metrics
- [ ] make a eBPF program container aware
- [ ] make a IPv6 packet dropper

toolchain:
- [ ] don't hard-code image name in scripts
- [ ] don't hard-code image tag in scripts
- [X] statically compile eBPF program
- [X] build another image where to run eBPF program
- [X] make the build process returns a Docker image containing the 
      compiled eBPF binary
- [X] instead of downloading and compiling `libbpf` and `bpftools`,  
  see if they are available from Ubuntu repositories
- [X] use some higher level library (Cilium?)
