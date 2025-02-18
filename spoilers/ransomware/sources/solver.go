package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("Opening ../challenge/FLAG.ENC\n")

	data, err := os.ReadFile("../challenge/FLAG.ENC")
	target := []byte("DISOBEY[")

	if err != nil {
		panic(err)
	}

	for i := uint16(1); i != 0; i++ {
		cur := i
		hit := true
		key := byte(0)
		for j, b := range target {
			cur, key = lsfr(cur)
			if data[j] != (b ^ key) {
				hit = false
			}
		}
		if hit {
			flag := make([]byte, 128)
			cur := i
			key := byte(0)
			for i := range data {
				cur, key = lsfr(cur)
				flag[i] = data[i] ^ key
			}
			fmt.Printf("Flag: %s\n", flag)
			return
		}
	}

	fmt.Printf("Nope!\n")
}

func lsfr(current uint16) (uint16, byte) {
	val := byte(0)
	for i := 0; i < 8; i++ {
		out := current & 0x0001
		current = current >> 1
		if out != 0 {
			current = current ^ 0xB400
		}
		val = (val >> 1) + (byte(out) << 7)
	}

	return current, val
}
