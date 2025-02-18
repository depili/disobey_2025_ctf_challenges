# Analog Dreams

This challenge involves man-in-the-middle inspection of RS232 serial communications. For this a Thurlby DA100 Serial Data Protocol Analyzer and a analog osciloscope acting as its display screen will be provided along with other necesserry hardware.

This challenge will be mainly an introduction on signal aquisition with an osciloscope and UART serial signals.

A timer will be provided giving each team 13 minutes and 37 seconds per go to keep queues reasonable.

A backup LCD display module DA101 exists for the DA100 in case the vintage analog scope breaks during the event.

## Description

Our spies have managed to aquire some important Kouvosto Telecom technology. It is available at the community village near the laboratory of hackers.

## Files

* challenge/DA100.pdf - User manual for the serial data protocol analyzer

## Walkthrough

1. Power on the provided osciloscope and DA100
2. Aquire the text output from the DA100 on the scope, the manual gives hints about the right settings. Failing that tweak the knobs on the scope until something is visible
3. Setup the DA100 to the communication, the auto-detect for the serial link parameters will be fine
4. Observe the traffic, it goes too fast to get the flag, but the end of each burst gives a hint about triggers
5. Setup a trigger in DA100, it supports 3 byte triggers and the manual is helpful.
6. The flag format gives great hints about potential triggers to use
7. Get half of the flag
8. There is a switch for choosing the data direction captured, switch it
9. Get the second half of the flag
10. Scramble the scope knobs so that the next group will have Fun

## Flag

`DISOBEY[HTTP 303: Your princess is in another data stream]`

### The UART messages:

Direction 1:
`DISOBEY[HTTP 303: Your princess is ????????? Hello there hacker, are you having a good CTF? Hope you haven't been triggered by any challenges...`

Direction 2:
`Hey, it is dangerous to go alone, have this part of the flag: in another data stream]. A hacker should still OBEY all laws and avoid triggering any alarms`
