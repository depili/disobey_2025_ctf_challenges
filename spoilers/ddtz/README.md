# Dichlorodiphenyltrichloroethane Zone

This challenge is a CP/M 2.2 system running on a Z180 and a vintage serial terminal. The system contains the challenge binary and the CP/M DDT (dynamic debugging tool) utility, more spesifically the ddtz variant that also dissasembles the z80 opcodes in addition to intel 8080.

A CP/M quickstart guide and a manual will be also provided.

The plan is to locate the challenge next to the hacklab booth in the community village.

The system runs completely on a rom/ramdisk and thus resetting it clears the state completely.

## Description

Our spies have secured one Kouvosto Telecom secure terminal. It is a the lab of hackers. Can you get it to divulge its secrets?

## Possible hints

* DDTZ

## Walkthrough

1. boot the system
2. dir
  * See ddtz.com, flag.com
3. Search for ddtz documentation
4. run flag.com, it asks for a challenge and a response
5. ddtz flag.com
6. use D to examine the memory
7. Notice the "Enjoy your flag" string
8. Use S 0, 400, 38a to search for references
9. Examine the stuff next to 16B, the first hit
10. G 16A to get the flag

## Flag

* DISOBEY[old tools for old jobs]

## Files

* the source/ directory contains the assembly source of the challenge binary.