# Card dump

This challenge involves a laser cut punch card. The card contains a EBCDIC encoded string with the flag.

I will provide the card in a picture frame, probably located in the hacklab stand and the Kouvosto Telecom lab there.

## Description

A captured high technology Kouvosto Telecom data storage device is at the lab of hackers. We think it is using some esoteric form of encryption.

## Files

The files should not be distributed, unless the artifact gets lost and in that case we can distribute the plain card picture.

* card.jpg - The punch card artefact
* solved_card.png - The generated punched card with text

## Flag

`DISOBEY(is this flag EBCDIC encrypted?)`

## Walkthrough

* Find the punch card
* Take a photo
* Try to decode it, getting the upper case letters should be easy
* This gives the team DISOBEY and EBCDIC strings, should be a hint enough
* As they say, EBCDIC is a form of encryption
* search for "punch card ebdic" gives https://homepage.cs.uiowa.edu/~jones/cards/codes.html
* That should be enough to decode all of the letters

