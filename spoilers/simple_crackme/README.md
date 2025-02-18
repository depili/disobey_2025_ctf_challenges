# Simple crackme

This is a simple Z80 CP/M crackme, it should be a nice and simple challenge to get the ball rolling. The binary just uses printf and reads the flag from console. There is simple bit shift, addition and xor obfuscation for the flag that should be really easy to reverse. No effort was put into obfuscating the execution other than having the statically linked printf there.

This was an excercise of frustration to get z88dk to compile code that wasn't horrible mess when looked at in ghidra. Steps for that included:
- Making all variables global, otherwise the stack manipulation makes ghidras decompiler weep
- Ditching char as a datatype, as that leads to way too many helper function calls

Tested on real hardware.

## Description

Simple one. Z180, CP/M 2.2

Trust the entry point.

## Walkthrough

1. Load the provided intel hex binary into ghidra
2. Dissassemble from the provided entry point 0x100
  * If one runs the auto analyze it priotizes a string instead of code at init....
3. Despair on the amount of initialization code
4. Look into strings, find some Interesting Ones
5. See where the strings are referenced at
6. Find main() at 0x03b8
7. Figure out the password checking loops
  * The decompiler is really helpful in here
  * The biggest issue is that the printf() calls aren't shown correctly
8. Reimplement the stuff in cyberchef or tool of ones choice
9. Get the flag

## Flag

`DISOBEY[CP/M hacking]`

## Files

* challenge/simple.hex - challenge binary as intel hex
* source/simple.c - c source code, compile with z88dk
* source/build.sh - build script, uses containerized z88dk & sdcc
