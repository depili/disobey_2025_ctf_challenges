# Unfiltered Crap

This a USB packet capture containing a serial session containing platform information and xmodem transfer of a challenge binary.

I think this should be decently challenging one, as usb pcaps probably aren't familiar to people and if one doesn't realize the correct load address for the binary its all down the rabbit hole.

My plan is to provide a CP/M 2.2 manual with a bookmark at section 5.1 for decoration for my other physical challenges as a hint.

## Description

Bunch of useless crap. Nothing to see here.

## Walkthrough

* Open the .pcap in wireshark
* Despair on the 2,7 million packets
  * filtering the SOF, IN request and NAKs out gets it down quite fast...
* Try harder and use filter like "(ftdi-ft.if_a_rx_payload != "") || (ftdi-ft.if_a_tx_payload != "")"
  * 92 packets will be displayed.
* The serial session is mostly pure ascii and readable, but it is split into multiple transactions
* Wireshark doesn't merge the flow like with tcp/ip :(
* Read the text and figure out the following details
  * Boot gives the CPU as Z180
  * a CP/M 2.2 OS is booted into
  * a xmodem receiver is started on the target
  * a file SECRET.COM is being transfered
* Figure out the xmodem frames, there are three and copying the bytes by copy-and-paste is quite trivial
  * The xmodem frames are in packets 1861323, 1987886 and 1994043
  * Avoid copying the three bytes of header and one byte of checksum
  * Reconstruct the binary
  * If one really wants to there are suitable xmodem libraries for python and go to parse the frames
* Load the binary into ghidra like a champ
  * Despair that nothing really works
    * The binary is constructed with obfuscating data in a way that it seems to make sense even when loaded at 0x00 but it is just a complete red herring...
  * Read CP/M documentation and reload the binary at 0x100
  * Reverse the simple xor obfuscation for the flag

## Flag

DISOBEY[usb captures are still painful]

## Files

* challenge/unfiltered_crap.pcap - the challenge file
* sources/secret.asm - assembly sources of the cp/m 2.2 binary contained in the pcap


## 'Screenshot' of the serial session

The capture stops before the command `secret` is executed.

```
RomWBW HBIOS v3.5.0-dev.45, 2024-06-27

Helsinki Hacklab Z180 [HHL_Z180] Z80180 @ 9.216MHz IO=0x80
0 MEM W/S, 2 I/O W/S, INT MODE 2, Z180 MMU
512KB ROM, 512KB RAM, HEAP=0x2468
ROM VERIFY: 00 00 00 00 PASS

AY: MODE=RCZ180 IO=0x68 NOT PRESENT
ASCI0: IO=0x80 ASCI MODE=57600,8,N,1
ASCI1: IO=0x81 ASCI MODE=57600,8,N,1
DSRTC: MODE=STD IO=0x0C NOT PRESENT
INTRTC: Wed 2020-01-01 00:00:00
MD: UNITS=2 ROMDISK=384KB RAMDISK=256KB
FD: MODE=RCWDC IO=0x50 NOT PRESENT
IDE: IO=0x10 MODE=RC
IDE0: NO MEDIA
IDE1: NO MEDIA
PPIDE: IO=0x20 PPI NOT PRESENT
SD: MODE=SC OPR=0x0C CNTR=0x8A TRDR=0x8B DEVICES=1
SD0: NO MEDIA
CH0: IO=0x3E NOT PRESENT
CH1: IO=0x3C NOT PRESENT
FP: IO=0x00 NOT PRESENT

Unit        Device      Type              Capacity/Mode
----------  ----------  ----------------  --------------------
Char 0      ASCI0:      RS-232            57600,8,N,1
Char 1      ASCI1:      RS-232            57600,8,N,1
Disk 0      MD0:        RAM Disk          256KB,LBA
Disk 1      MD1:        ROM Disk          384KB,LBA
Disk 2      IDE0:       Hard Disk         --
Disk 3      IDE1:       Hard Disk         --
Disk 4      SD0:        SD Card           --


Helsinki Hacklab Z180 [HHL_Z180] Boot Loader

Boot [H=Help]: c

Loading CP/M 2.2...

CBIOS v3.5.0-dev.45 [WBW]

Formatting RAMDISK...

Configuring Drives...

.A:=MD0:0
.B:=MD1:0

.3701 Disk Buffer Bytes Free

CP/M-80 v2.2, 54.0K TPA

B>

B>xm r a0:secret.com


XMODEM v12.5 - 07/13/86
RomWBW, 30-May-2020 [WBW], HBIOS FastPath on COM0

Receiving: A0:SECRET.COM
248k available for uploads
File open - ready to receive
To cancel: Ctrl-X, pause, Ctrl-X
CK
Thanks for the upload

B>a:

A>

A>secret

DISOBEY[usb captures are still painful]
A>
```
