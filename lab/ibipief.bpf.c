// +build ignore
#include "ibipief.bpf.h"

#ifndef SIGTERM
#define SIGTERM 15
#endif

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 1 << 24);
} events SEC(".maps");

long ringbuffer_flags = 0;
int counter = 0;
const int MAX_COUNTER = 100;

SEC("kprobe/sys_execve")
int ibipief(void *ctx)
{
    __u64 id = bpf_get_current_pid_tgid();
    __u32 tgid = id >> 32;
    proc_info *process;

    // Reserve space on the ringbuffer for the sample
    process = bpf_ringbuf_reserve(&events, sizeof(proc_info),
        ringbuffer_flags);
    if (!process) {
        return 0;
    }

    process->pid = tgid;
    bpf_get_current_comm(&process->comm, 100);

    bpf_ringbuf_submit(process, ringbuffer_flags);

    counter++;
    bpf_printk("Yo, found stuff");
    if (counter == MAX_COUNTER) {
        bpf_printk("Raising SIGTERM, got %d syscalls\n", counter);
        bpf_send_signal_thread(SIGTERM);
    }

    return 0;
}

// Avoid "cannot call GPL-restricted function from non-GPL
// compatible program" error
char LICENSE[] SEC("license") = "GPL";
