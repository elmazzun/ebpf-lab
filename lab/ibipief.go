package main

import "C"

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	bpf "github.com/aquasecurity/libbpfgo"

	"net/http"
	_ "net/http/pprof"
)

func handler(signal os.Signal) {
	if signal == syscall.SIGTERM || signal == syscall.SIGINT {
		fmt.Println(">>> Got kill signal.")
		fmt.Println(">>> Program will terminate now.")
	} else {
		fmt.Println("Ignoring signal: ", signal)
	}
}

func main() {

	var rb *bpf.RingBuffer

	counter := 0
	signal_channel := make(chan os.Signal, 1)
	signal.Notify(signal_channel, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		log.Println(http.ListenAndServe("localhost:6060", nil))
	}()

	go func() {
		what_signal := <-signal_channel
		if what_signal == syscall.SIGTERM || what_signal == syscall.SIGINT {
			fmt.Println(">>> Got kill signal.")
			fmt.Println(">>> Program will terminate now.")
		} else {
			fmt.Println("Ignoring signal: ", what_signal)
		}
		rb.Stop()
		rb.Close()
		os.Exit(0)
	}()

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
	rb, err = bpfModule.InitRingBuf("events", eventsChannel)
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
		fmt.Printf("#%d: %d %v\n", counter, pid, comm)
		counter++
	}

	rb.Stop()
	rb.Close()
	os.Exit(0)
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
