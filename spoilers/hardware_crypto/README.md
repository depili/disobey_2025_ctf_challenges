# Hardware crypto

A logic analyzer capture of a Futaba GP9002A01A display control signals. The display shows the flag, the challenge is to parse the signals and get to the picture.

The display is nice VFD unit that supports XOR for the two display buffers, so to make things spicy that functionality is used.

This should be decently challenging as the tools needed aren't familiar to most and solving the challenge requires additional work on top of using the tools.

## Description

Our spies have obtained a signal capture of the state-of-art Kouvosto Telecom GP9002A01A hardware encryption module. Can you extract the keys?

Captures made with Sigrok / Pulseview. Channel names correspond to connector pins.

## Files

* disobey.go - source for the controlling application
* solution.jpg - image of the display showing the flag
* challenge/hardware_crypto.sr - Sigrok format capture

## Flag

`DISOBEY[VFD IS THE BEST DISPLAY]`

## Walkthrough

* Google the datasheet for the module, it is easily available
* Get pulseview from sigrok.org (available on all platforms)
* Open the capture
* Use parallel decoder to dump the data, or export as CVS
* Check the issued commands on the capture, get display settings
* Use scripting to reconstruct the XORred image
