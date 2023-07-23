// +build ignore
#include "ibipief.bpf.h"

// Avoid error "cannot call GPL-restricted function from non-GPL compatible program"
// https://github.com/nyrahul/ebpf-guide/blob/master/docs/gpl_license_ebpf.rst
char __license[] __attribute__((section("license"), used)) = "GPL";

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 1 << 24);
} events SEC(".maps");

long ringbuffer_flags = 0;

// Example: tracing a message on a kprobe
SEC("kprobe/sys_execve")
int ibipief(void *ctx)
{
    __u64 id = bpf_get_current_pid_tgid();
    __u32 tgid = id >> 32;
    proc_info *process;

    // Reserve space on the ringbuffer for the sample
    process = bpf_ringbuf_reserve(&events, sizeof(proc_info), ringbuffer_flags);
    if (!process) {
        return 0;
    }

    process->pid = tgid;
    bpf_get_current_comm(&process->comm, 100);

    bpf_ringbuf_submit(process, ringbuffer_flags);
    return 0;
}
