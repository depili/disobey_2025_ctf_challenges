# Shape of things to come

A simple PDP-8 executable that asks for the password from the console teletype and with the right password provides the flag. Has quite light obfuscation.

One part of this challenge is the lack of standard tooling. SIMH and https://www.bernhard-baehr.de/pdp8e/pdp8e.html for macos are good emulators.

For dissassemblers the excel based one at
https://deramp.com/downloads/mfe_archive/005-Documentation%20and%20Code%20by%20Martin/010%20Code%20by%20Martin/DEC%20PDP8%20Code/PDP-8%20Assembler%20Disassembler/ seems to work the best...

Hopefully I will have the PDP-8 physically present next year...

## Description

PDP-8. Read in mode tape binary. Entry at 0200. Tested on real hardware.

## Files

* source/shape.pal - PAL-D assembler source
* source/shape.lst - PAL-D assembler listing
* challenge/shape.rim - Read in format challenge binary

## Flag

`DISOBEY[the pdp-8 lives!]`

## Walkthrough

* Power on your PDP-8
* Enter DEC-08-LRAA RIM loader at standard address 7756 via the switch register
* Set switch register to 7756
* Press load address key
* Load the program tape into the teletype tape reader
* Make sure the ASR33 is online
* Press CONT
* Press start on the tape reader
* Wait until the tape has been read
* Press HALT
* Set switch register to 0200
* Press CONT
* When asked enter the password "kissa2" on the teletype
* Press enter
* Get the flag

Alternatively, load program, set address to 0240 and run from there to just get the flag.