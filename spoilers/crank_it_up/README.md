# Crank it up

A challenge exploring what a fully static CPU means.

This is a physical challenge, taking 50x20cm of table space. It consists of a 8051 board with a blinkenlights-addon showing the state of all control lines and the data/address bus. The clock crystal has been replaced by a 100 pulses per revolution CNC manual pulse generator wheel.

The challenge doesn't include any sources, the whole small program and the flag can be extracted from the LEDs. The CPU uses 12 clocks per machine cycle, so it executes little over 8 instructions per revolution.

## Description

We got this strange contraption from Kouvosto Telecom, at least it provides a fancy led lightshow, does it do anything else? Challenge is located at the lab of hackers. 8051.

## Files

* crank.asm contains the code running on the challenge platform

## Flag

DISOBEY{can you get to 1Mhz?}

## Hints for solving

* Capture a video
* Look for clock cycles where PSEN is low
* These are reads from the program memory
* After while notice that some reads are in visually pretty address space
* Collect the data from the reads
* Assemble the flag

This should be doable by hand as the flag is quite short and you get a character per read cycle. Having a video helps as one can rewind and check what was missed.
