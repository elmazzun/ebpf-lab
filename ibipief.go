package main

import (
	"C"

	bpf "github.com/aquasecurity/libbpfgo"
	"github.com/aquasecurity/libbpfgo/helpers"
)
import (
	"fmt"
	"os"
	"os/signal"
)

func main() {
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt)

	bpfModule, err := bpf.NewModuleFromFile("ibipief.bpf.o")
	must(err)
	fmt.Println(">>> module done")
	defer bpfModule.Close()

	err = bpfModule.BPFLoadObject()
	must(err)
	fmt.Println(">>> object loaded")

	prog, err := bpfModule.GetProgram("./ibipief")
	must(err)
	fmt.Println(">>> got program ibipief")
	_, err = prog.AttachKprobe(sys_execve)
	must(err)

	go helpers.TracePipeListen()
	<-sig

	// prog, err = bpfModule.GetProgram("hello_bpftrace")
	// must(err)
	// _, err = prog.AttachRawTracepoint("sys_enter")
	// must(err)

	// e := make(chan []byte, 300)
	// p, err := bpfModule.InitPerfBuf("events", e, nil, 1024)
	// must(err)

	// p.Start()

	// counter := make(map[string]int, 350)
	// go func() {
	// 	for data := range e {
	// 		comm := string(data)
	// 		counter[comm]++
	// 	}
	// }()

	// <-sig
	// p.Stop()
	// for comm, n := range counter {
	// 	fmt.Printf("%s: %d\n", comm, n)
	// }
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
