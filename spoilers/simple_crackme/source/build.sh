#!/bin/sh
docker run  -v .:/src/ -it z88dk/z88dk zcc +cpm -compiler=sdcc -O3 -create-app simple.c -osimple.bin
srec_cat SIMPLE.COM -binary -offset=0x100 -Execution_Start_Address=0x100 -o simple.hex -intel
