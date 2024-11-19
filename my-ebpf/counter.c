//go:build ignore

// Missing definition from vmlinux.h
#define ETH_P_IP	0x0800

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// [0] = total received packets
// [1] = total dropped invalid packets
// [2] = total dropped ICMP packets
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY); 
    __type(key, __u32);
    __type(value, __u64);
    __uint(max_entries, 3);
} pkt_count SEC(".maps"); 

SEC("xdp") 
int count_packets(struct xdp_md *ctx) {
    __u32 total_pkts_key = 0;
    __u32 invalid_drop_pkts_key = 1;
    __u32 icmp_drop_pkts_key = 2;

    __u64 *count = bpf_map_lookup_elem(&pkt_count, &total_pkts_key);
    if (count) {
        __sync_fetch_and_add(count, 1);
    }

    void *data = (void *)(long)ctx->data;         // start of packet data
    void *data_end = (void *)(long)ctx->data_end; // end of packet data

    struct ethhdr *eth = data;
    if (data + sizeof(struct ethhdr) > data_end) {
        bpf_printk("Invalid Ethernet header, drop packet\n");
        __u64 *drop_count = bpf_map_lookup_elem(&pkt_count, &invalid_drop_pkts_key);
        if (drop_count) {
            __sync_fetch_and_add(drop_count, 1);
        }
        return XDP_DROP;
    }

    if (bpf_ntohs(eth->h_proto) != ETH_P_IP) {
        bpf_printk("Ethernet not IPv4, dropping\n");
        __u64 *drop_count = bpf_map_lookup_elem(&pkt_count, &invalid_drop_pkts_key);
        if (drop_count) {
            __sync_fetch_and_add(drop_count, 1);
        }
        return XDP_DROP;
    }

    struct iphdr *iph = data + sizeof(struct ethhdr);
    if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) > data_end) {
        bpf_printk("Invalid IP header, drop packet\n");
        __u64 *drop_count = bpf_map_lookup_elem(&pkt_count, &invalid_drop_pkts_key);
        if (drop_count) {
            __sync_fetch_and_add(drop_count, 1);
        }
        return XDP_DROP;
    }

    if (iph->protocol == IPPROTO_ICMP) {
        bpf_printk("Found ICMP, drop packet\n");
        __u64 *icmp_drop_count = bpf_map_lookup_elem(&pkt_count, &icmp_drop_pkts_key);
        if (icmp_drop_count) {
            __sync_fetch_and_add(icmp_drop_count, 1);
        }
        return XDP_DROP;
    }

    return XDP_PASS; 
}

char __license[] SEC("license") = "Dual MIT/GPL";
