{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// E555 Speaker Engine
//
// Author: Kwabena W. Agyeman
// Updated: 7/27/2010
// Designed For: P8X32A
// Version: 1.1
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 8/26/2009.
// v1.1 - Added support for variable pin assignments - 7/27/2010.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Speaker Circuit:
//
// SpeakerPinNumber --- Speaker Driver (Active High).
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

PUB speakerFrequency(newFrequency, speakerPinNumber) '' 10 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the speaker frequency using the SPIN interpreter's counter modules.
'' //
'' // NewFrequency - The new frequency. Between 0 Hz and 80MHz @ 80MHz. -1 to reset the pin and counter modules.
'' // SpeakerPinNumber - Pin to use to drive the speaker circuit. Between 0 and 31.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  speakerSetup((newFrequency <> -1), speakerPinNumber)

  newFrequency := ((newFrequency <# clkfreq) #> 0)

  result := 1

  repeat 32
    newFrequency <<= 1
    result <-= 1
    if(newFrequency => clkfreq)
      newFrequency -= clkfreq
      result += 1

  frqa := result~

  phsb := 0

PUB speakerVolume(newVolume, speakerPinNumber) '' 10 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Changes the speaker volume using the SPIN interpreter's counter modules.
'' //
'' // NewVolume - The new volume. Between 0% and 100%. -1 to reset the pin and counter modules.
'' // SpeakerPinNumber - Pin to use to drive the speaker circuit. Between 0 and 31.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  speakerSetup((newVolume <> -1), speakerPinNumber)

  frqb := (((100 - ((newVolume <# 100) #> 0)) * constant(posx / 50)) | $7)

PRI speakerSetup(activeOrInactive, speakerPinNumber) ' 5 Stack Longs

  speakerPinNumber := ((speakerPinNumber <# 31) #> 0)

  dira[speakerPinNumber] := activeOrInactive

  outa[speakerPinNumber] := false

  ctra := ((constant(%0_0100 << 26) + speakerPinNumber) & activeOrInactive)

  ctrb := ((constant(%0_0110 << 26) + speakerPinNumber) & activeOrInactive)

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}