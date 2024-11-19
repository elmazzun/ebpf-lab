package main

import (
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	TotalPackets = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "total_packets",
			Help: "Number of received packets.",
		},
	)
	DroppedInvalidPackets = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "invalid_dropped_packets",
			Help: "Number of invalid packets dropped.",
		},
	)
	DroppedIcmpPackets = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "icmp_dropped_packets",
			Help: "Number of ICMP packets dropped.",
		},
	)
)

func init() {
	prometheus.MustRegister(TotalPackets)
	prometheus.MustRegister(DroppedInvalidPackets)
	prometheus.MustRegister(DroppedIcmpPackets)
}

func main() {

	go func() {
		http.Handle("/metrics", promhttp.Handler())
		log.Fatal(http.ListenAndServe(":8080", nil))
	}()

	// Remove resource limits for kernels <5.11.
	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatal("Removing memlock:", err)
	}

	// Load the compiled eBPF ELF and load it into the kernel.
	var objs counterObjects
	if err := loadCounterObjects(&objs, nil); err != nil {
		log.Fatal("Loading eBPF objects:", err)
	}
	defer objs.Close()

	ifname := "enp0s31f6" // Change this to an interface on your machine.
	iface, err := net.InterfaceByName(ifname)
	if err != nil {
		log.Fatalf("Getting interface %s: %s", ifname, err)
	}

	// Attach count_packets to the network interface.
	link, err := link.AttachXDP(link.XDPOptions{
		Program:   objs.CountPackets,
		Interface: iface.Index,
	})
	if err != nil {
		log.Fatal("Attaching XDP:", err)
	}
	defer link.Close()

	log.Printf("Counting incoming packets on %s...", ifname)

	// Periodically fetch the packet counter from PktCount,
	// exit the program when interrupted.
	tick := time.Tick(time.Second)
	stopper := make(chan os.Signal, 5)
	signal.Notify(stopper, os.Interrupt)

	for {
		select {
		case <-tick:
			var count, dropInvalidPackets, dropIcmpPackets uint64

			err := objs.PktCount.Lookup(uint32(0), &count)
			if err != nil {
				log.Fatal("Map lookup:", err)
			}
			log.Printf("Received %d packets", count)
			TotalPackets.Add(float64(count))

			err = objs.PktCount.Lookup(uint32(1), &dropInvalidPackets)
			if err != nil {
				log.Fatal("Map lookup:", err)
			}
			log.Printf("Dropped %d invalid packets", dropInvalidPackets)
			DroppedInvalidPackets.Add(float64(dropInvalidPackets))

			err = objs.PktCount.Lookup(uint32(2), &dropIcmpPackets)
			if err != nil {
				log.Fatal("Map lookup:", err)
			}
			log.Printf("Dropped %d ICMP packets", dropIcmpPackets)
			DroppedIcmpPackets.Add(float64(dropIcmpPackets))
		case <-stopper:
			log.Print("Received signal, exiting..")
			return
		}
	}
}
