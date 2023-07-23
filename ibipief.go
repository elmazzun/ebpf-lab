package main

import "C"

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"os"
	"os/signal"

	bpf "github.com/aquasecurity/libbpfgo"
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

	prog, err := bpfModule.GetProgram("ibipief")
	must(err)
	fmt.Println(">>> got program ibipief")

	_, err = prog.AttachKprobe("__x64_sys_execve")
	must(err)

	eventsChannel := make(chan []byte)
	rb, err := bpfModule.InitRingBuf("events", eventsChannel)
	if err != nil {
		os.Exit(-1)
	}

	rb.Start()

	for {
		event := <-eventsChannel
		// Treat first 4 bytes as LittleEndian Uint32
		pid := int(binary.LittleEndian.Uint32(event[0:4]))
		// Remove excess 0's from comm, treat as string
		comm := string(bytes.TrimRight(event[4:], "\x00"))
		fmt.Printf("%d %v\n", pid, comm)
	}

	rb.Stop()
	rb.Close()
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
