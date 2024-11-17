//go:build ignore

// Missing definition from vmlinux.h
#define ETH_P_IP	0x0800

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY); 
    __type(key, __u32);
    __type(value, __u64);
    __uint(max_entries, 1);
} pkt_count SEC(".maps"); 

SEC("xdp") 
int count_packets(struct xdp_md *ctx) {
    __u32 key    = 0; 
    __u64 *count = bpf_map_lookup_elem(&pkt_count, &key);

   if (count) {
       __sync_fetch_and_add(count, 1);
   }

    void *data = (void *)(long)ctx->data;         // start of packet data
    void *data_end = (void *)(long)ctx->data_end; // end of packet data

    struct ethhdr *eth = data;
    if (data + sizeof(struct ethhdr) > data_end) {
        bpf_printk("Invalid Ethernet header, drop packet\n");
        return XDP_DROP;
    }

    if (bpf_ntohs(eth->h_proto) != ETH_P_IP) {
        //bpf_printk("Ethernet not IPv4, dropping\n");
        return XDP_DROP;
    }

    struct iphdr *iph = data + sizeof(struct ethhdr);
    if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) > data_end) {
        bpf_printk("Invalid IP header, drop packet\n");
        return XDP_DROP;
    }

    if (iph->protocol == IPPROTO_ICMP) {
        bpf_printk("Found ICMP, drop packet\n");
        return XDP_DROP;
    }

    return XDP_PASS; 
}

char __license[] SEC("license") = "Dual MIT/GPL";
