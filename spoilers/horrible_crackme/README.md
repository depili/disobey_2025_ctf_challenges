# Horrible crackme

This was born when trying to get z88dk to make the simple crackme binary, this one undoes all of the steps for producing a sane binary. The obfuscation is really similiar to the simple crackme, but this one will make ghidra sad.

In the end this uses the same obfuscation code just with two different values than simple crackme and the alterations to the source are quite minimal, it all still results in huge difference in the binary.

Tested on real hardware.

## Description

Compilers are awesome, right?. Z180, CP/M 2.2

Trust the entry point.

## Walkthrough

1. Load the provided intel hex binary into ghidra
2. Dissassemble from the provided entry point 0x100
  * If one runs the auto analyze it priotizes a string instead of code at init....
3. Despair on the amount of initialization code
4. Look into strings, find some Interesting Ones
5. See where the strings are referenced at
6. Find main() at 0x0461
7. Inline bunch of functions in ghidra to get some sanity back
  * For some reason z88dk splits bunch of stuff into separate functions
  * For example the xor call gets put into a function, just because
8. It isn't much... Resort to text editor for the stack offsets
9. Figure out the password checking loops
10. Figure out the obfuscation parameters from the stack
11. Reimplement the stuff in cyberchef or tool of ones choice
12. Get the flag

## Flag

`DISOBEY[compilers, eh?]`

## Files

* challenge/simple.hex - challenge binary as intel hex
* source/simple.c - c source code, compile with z88dk
* source/build.sh - build script

