#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

typedef struct process_info {
    int pid;
    char comm[100];
} proc_info;