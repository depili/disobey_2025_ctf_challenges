# Matrix

This is a hybrid challenge, with a binary and a physical hardware implementation. The goal is to reverse engineer the provided 8051 binary, figure out a keycode and then enter it on the hardware to
receive the key.

The keycode uses linear algebra for keycode checking and also
a "feature" of the key matrix scanning algortihm and multi-
key presses for obfuscation.

The hardware will show the flag on a LCD screen upon entry of the correct combination.

The LCD routines use a philips extension to the 8051 architechture adding a second DPTR, but understanding that part shouldn't be
important for solving the challenge.

The challenge takes about 40x40 cm of table space and needs a power outlet.

## Description

Our spies have been able to exfiltrate a prototype kouvosto telecom access control system and some development code for it. Can you figure out their office access code?

8051 (P80C51FA), intel hex.

## Difficulty

Should be on the easier side

## Files

* challenge/matrix.hex - intel hex challenge binary
* sources/matrix.asm - uncensored development sources
* sources/censored.asm - censored challenge binary sources


## Flag

DISOBEY[Welcome]

## Walkthrough

* Load the intel hex into ghidra with 8051 language
* Reverse the input section
* Reverse the multiplication table based code check
* Solve the linear equation system (wolfram alpha or other such tools help)
* Obtain the keycode 0 4 5 1 16 7
* Enter the code
  * 16 can be entered by:
    * Press 9 down
    * Press 5 down
    * Release 9
    * Release 5
* See the flag on the LCD screen
