#!/bin/bash

if [[ ! -f /sys/kernel/btf/vmlinux ]]; then
    echo "/sys/kernel/btf/vmlinux not found"
    echo "It seems your kernel does not ship with BTF."
    echo "Be sure that /boot/config-$(uname -r) has CONFIG_DEBUG_INFO_BTF=y."
    echo "Re-compile your kernel with CONFIG_DEBUG_INFO_BTF=y"
    echo "or upgrade the kernel".
    exit 1
fi

# From https://github.com/iovisor/bcc/blob/master/INSTALL.md#kernel-configuration
# and https://github.com/iovisor/bcc/blob/master/docs/kernel_config.md
# getting only flags for a Kernel >= 4.7

# Mandatories flags
grep \
    -e "CONFIG_BPF=y" \
    -e "CONFIG_BPF_SYSCALL=y" \
    -e "CONFIG_BPF_JIT=y" \
    -e "CONFIG_HAVE_EBPF_JIT=y" \
    -e "CONFIG_BPF_EVENTS=y" \
    -e "CONFIG_KPROBES=y" \
    -e "CONFIG_UPROBES=y" \
    -e "CONFIG_DEBUG_FS=y" \
    -e "CONFIG_DEBUG_INFO_BTF=y" \
    -e "CONFIG_DEBUG_INFO_BTF_MODULES=y" \
    -e "CONFIG_FTRACE=y" \
    -e "CONFIG_FTRACE_SYSCALLS=y" \
    -e "CONFIG_KPROBE_EVENTS=y" \
    -e "CONFIG_UPROBE_EVENTS=y" \
    -e "CONFIG_BPF_EVENTS=y" \
    "/boot/config-$(uname -r)"

echo

# Facultative flags
# There are a few optional kernel flags needed for running bcc networking examples on vanilla kernel
grep \
    -e "CONFIG_NET_SCH_SFQ=m" \
    -e "CONFIG_NET_ACT_POLICE=m" \
    -e "CONFIG_NET_ACT_GACT=m" \
    -e "CONFIG_DUMMY=m" \
    -e "CONFIG_VXLAN=m" \
    "/boot/config-$(uname -r)"
