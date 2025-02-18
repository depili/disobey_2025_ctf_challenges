# Ransomware

A CPM 2.2 Z180 binary and crypto challenge. The binary generates a keystream from 16bit Galois LFSR and uses that to encrypt the flag file. The challenge requires reverse engineering the binary and then brute-forcing the encryption with known partial plaintext "DISOBEY". Since the keyspace is only 16bits this should be computationally easy even on a potato.

The binary isn't really obfuscated, as a good portion of the challenge lies in the implementation of the decryption and getting the key out.


The binary is distributed as intel hex format to offer the correct load address (which also serves as a hint for the unfiltered crap -challenge...)

## Description

Our sensitive files on our state-of-art CP/M 2.2 Z180 mainframe have been encrypted with this new strain of ransomware, can we do anything?

## Files

* challenge/flag.enc - encrypted flag
* challenge/ransomware.hex - intel hex format binary
* sources/ransomware.asm - z180 assembly sources for the encryptor
* sources/FLAG.TXT - plaintext flag
* sources/solver.go - a brute force solver, build with `go build solver.go`

## FLAG

DISOBEY[test flag, please ignore]

## Walkthrough

* Load the binary in ghidra or CP/M DDT
* Figure out the syscalls
* Figure out the keystream generation, a bog standard 16bit galois LFSR with maximal period
* Guess part of the plaintext, either the DISOBEY[ start or the end padding from CP/M
* Build a brute forcer
* Receive the flag
