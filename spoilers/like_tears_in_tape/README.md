# Like Tears in Tape

This challenge involves a length of 6bit punched tape. The 6bit tape was most commonly used with typesetting machines in printing industry. The physical tape contains the flag punched in the typical 6bit encoding they used.

The encoding is actually just an extension of the 5bit International telegraph alphabet 2.

So this should be solvable with minimal hints.

## Description

All those flags will be lost in time, like tears in tape. Time to decode.

## Flag

`DISOBEY(6bit typesetting punched tape)`

## Walkthrough

1. Find the piece of tape
2. Take a photo
3. Google "6bit tape encoding"
4. Find https://en.wikipedia.org/wiki/Six-bit_character_code
5. Google "6bit tape encoding typesetting"
6. Find the key for the encoding in https://www.smecc.org/teletypes_in_typesetting.htm

## Files

All files are meant to be just backups

* tape.jpg - The tapes
* key.jpg - Decoding key from the internet
* flag.txt - Flag string
* flag.bin - Encoded flag
* convert.go - Ascii to teletypesetting converter written in go

