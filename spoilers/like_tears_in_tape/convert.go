package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("Reading from file: %s\n", os.Args[1])
	fmt.Printf("Writing to file: %s\n", os.Args[2])

	inFile, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}

	data := convert(string(inFile))

	err = os.WriteFile(os.Args[2], data, 0644)

	if err != nil {
		panic(err)
	}
}

func convert(input string) []byte {
	const shift = 0x1B
	const unshift = 0x1F

	upper := map[rune]byte{
		// 0x0 = tape feed
		'T': 0x1,
		// 0x2 = Return
		'O': 0x3,
		' ': 0x4,
		'H': 0x5,
		'N': 0x6,
		'M': 0x7,
		// 0x8 = elevate
		'L': 0x9,
		'R': 0xA,
		'G': 0xB,
		'I': 0xC,
		'P': 0xD,
		'C': 0xE,
		'V': 0xF,
		'E': 0x10,
		'Z': 0x11,
		'D': 0x12,
		'B': 0x13,
		'S': 0x14,
		'Y': 0x15,
		'F': 0x16,
		'X': 0x17,
		'A': 0x18,
		'W': 0x19,
		'J': 0x1A,
		// 0x1B = shift
		'U': 0x1C,
		'Q': 0x1D,
		'K': 0x1E,
		// 0x1F = unshift
		// 0x20 = thin space
		// 0x21 = 5/8
		// 0x22 = some weird symbol
		'&': 0x23,
		// 0x24 = add thin space
		// 0x25 = Em leader
		',': 0x26,
		'.': 0x27,
		// 0x28 = PF of LM
		// 0x29 = V Rule Em Sp
		// 0x2A = 1/2
		':': 0x2B,
		'-': 0x2C,
		'?': 0x2D,
		// 0x2E = En space
		// 0x2F = Quad center
		// 0x30 = 3/8
		'(': 0x31,
		'@': 0x32,
		// 0x33 = upper roll
		// 0x34 = Em space
		// 0x35 = 3/4
		// 0x36 = Quad left
		// 0x37 = 1/8
		'!': 0x38,
		// 0x39 = 1/4
		// 0x3A = bell
		// 0x3B = lower roll
		// 0x3C = 7/8
		// 0x3D = En leader
		// 0x3E = OR or UM
		// 0x3F = Rub out
	}

	lower := map[rune]byte{
		// 0x0 = tape feed
		't': 0x1,
		// 0x2 = Return
		'o': 0x3,
		' ': 0x4,
		'h': 0x5,
		'n': 0x6,
		'm': 0x7,
		// 0x8 = elevate
		'l': 0x9,
		'r': 0xA,
		'g': 0xB,
		'i': 0xC,
		'p': 0xD,
		'c': 0xE,
		'v': 0xF,
		'e': 0x10,
		'z': 0x11,
		'd': 0x12,
		'b': 0x13,
		's': 0x14,
		'y': 0x15,
		'f': 0x16,
		'x': 0x17,
		'a': 0x18,
		'w': 0x19,
		'j': 0x1A,
		// 0x1B = shift
		'u': 0x1C,
		'q': 0x1D,
		'k': 0x1E,
		// 0x1F = unshift
		// 0x20 = thin space
		'5': 0x21,
		// 0x22 = some weird symbol
		'9': 0x23,
		// 0x24 = add thin space
		// 0x25 = Em leader
		',': 0x26,
		'.': 0x27,
		// 0x28 = PF of LM
		// 0x29 = V Rule Em Sp
		'4': 0x2A,
		';': 0x2B,
		'8': 0x2C,
		'0': 0x2D,
		// 0x2E = En space
		// 0x2F = Quad center
		'3': 0x30,
		')': 0x31,
		'_': 0x32,
		// 0x33 = upper roll
		// 0x34 = Em space
		'6': 0x35,
		// 0x36 = Quad left
		'1': 0x37,
		'$': 0x38,
		'2': 0x39,
		// 0x3A = bell
		// 0x3B = lower roll
		'7': 0x3C,
		// 0x3D = En leader
		// 0x3E = OR or UM
		// 0x3F = Rub out
	}

	ret := make([]byte, 1)

	state := -1

	for _, r := range input {
		if val, ok := upper[r]; ok {
			if state != 1 {
				ret = append(ret, shift)
				state = 1
			}
			ret = append(ret, val)
		} else if val, ok := lower[r]; ok {
			if state != 2 {
				ret = append(ret, unshift)
				state = 2
			}
			ret = append(ret, val)
		} else {
			fmt.Printf("Rune not found: %c\n", r)
		}
	}

	return ret
}
