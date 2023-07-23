// +build ignore
#include "ibipief.bpf.h"

// Avoid error "cannot call GPL-restricted function from non-GPL compatible program"
// https://github.com/nyrahul/ebpf-guide/blob/master/docs/gpl_license_ebpf.rst
char __license[] __attribute__((section("license"), used)) = "GPL";

// Example: tracing a message on a kprobe
SEC("kprobe/sys_execve")
int ibipief(void *ctx)
{
    bpf_printk("I'm alive!");
    return 0;
}
