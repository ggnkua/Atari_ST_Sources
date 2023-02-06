#!/bin/sh
as sys.s -o sys.o
gcc -c *.c
gcc *.o -o bit_rip
rm *.o
./bit_rip
