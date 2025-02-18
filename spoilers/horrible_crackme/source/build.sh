#!/bin/sh
docker run  -v .:/src/ -it z88dk/z88dk zcc +cpm -vn -O3 -create-app horrible.c -ohorrible.bin
srec_cat HORRIBLE.COM -binary -offset=0x100 -Execution_Start_Address=0x100 -o horrible.hex -intel
