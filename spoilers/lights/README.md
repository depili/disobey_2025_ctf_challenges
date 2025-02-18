# Lights

A 8051 reverse engineering challenge that involves writing a solver or finding a suitable ready made one.

This is a machine with a 4x5 keypad and a LCD. The keys have indicator LEDs. The machine will generate a random seed and then a 10 press "lights out" puzzle and prompt the user for a response for the challenge.

The algorithm can be reverse engineered from the provided binary, but it doesn't contain the flag. To obtain the flag the player needs to actually solve a puzzle on the hardware, thus a solver needs to be made.

If one is able to identify the type of the puzzle then there are suitable solvers like https://www.dcode.fr/lights-out-solver that can be used to generate the solution. The code expects exactly 10 presses in the solution, so some times the solvers might find more optimal solutions, but as long as the solution is off by 2, 4, 6 or 8 presses one can just input presses of a single button and still get the flag.

This is meant to be a little on the more challenging side, as it involves hardware, software reverse engineering and coding.


## Description

We have obtained a sample of Kouvosto Telecom secure key storage system and some test version of its software and schematics. The device is at the lab of hackers.


## Files

* challenge/lights_censored.hex - binary in intel hex format
* challenge/keys.pdf - schematic for the keyboard
* challenge/lcd.pdf - schematic for the LCD
* challenge/main.pdf - schematic for the 80c51 board
* source/kb.asm - uncensored main source, compile with asl
* source/challenge.asm - censored source for the challenge binary

## Flag

`DISOBEY[triple check files...]`
