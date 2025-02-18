# Roped in

A 8051 pwn challenge, involving a simplish ROP chain. This will be played on physical 8051 boards supplied by me via usb serial adapters.

The provided target hardware will require little bit of table space for them + the players laptop, the one table I requested previously should be enough.

## Description

We have stolen some development files and a prototype from Kouvosto Telecom. Apparently they are developing a SUCKS v2 with improved security due to non executable stack and ram. Can you make sense about this?

Physical boards with USB uart (38400 baud, 8N1) are available near the CTF desk.

## Files

* challenge/roped.hex - censored challenge binary
* source/rop.asm - uncencored source
* source/poc.bin - PoC exploit payload

## Flags

* `DISOBEY[are you into bondage?]`

## Walkthrough

1. ghidra
2. see the clear buffer overflow into stack
3. find rop target
  * the simple one is unreachable due to input routine dropping characters < 0x20
4. it has some guards
5. figure out the rop chain
6. get the flag

