package main

import (
	"github.com/tarm/serial"
	"log"
	"os"
	"time"
)

func main() {
	log.Printf("Opening ports: %s and %s", os.Args[1], os.Args[2])
	c := &serial.Config{Name: os.Args[1], Baud: 19200}
	s1, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal(err)
	}

	c.Name = os.Args[2]
	s2, err := serial.OpenPort(c)

	log.Printf("Starting senders...")

	go send1(s1)
	go send2(s2)

	log.Printf("Sleeping...")

	for {
		time.Sleep(time.Second)
	}

}

func send1(s *serial.Port) {
	msg := "DISOBEY[HTTP 303: Your princess is ????????? Hello there hacker, are you having a good CTF? Hope you haven't been triggered by any challenges..."
	for {
		_, err := s.Write([]byte(msg))
		if err != nil {
			panic(err)
		}
		time.Sleep(500 * time.Millisecond)
	}
}

func send2(s *serial.Port) {
	msg := "Hey, it is dangerous to go alone, have this part of the flag: in another data stream]. A hacker should still OBEY all laws and avoid triggering any alarms"
	for {
		_, err := s.Write([]byte(msg))
		if err != nil {
			panic(err)
		}
		time.Sleep(700 * time.Millisecond)
	}
}
