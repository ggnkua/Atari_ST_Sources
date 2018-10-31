# A SozobonX C makefile for game PUNSSi (C) 1995, 1997 by Eero Tamminen

CFLAGS = -O -e -v

test.tos: test.o keycodes.o joyisrz.o

punssi.tos: punssi.o keycodes.o joyisrz.o

test.o: test.c device.h
punssi.o: punssi.c punssi.h dosound.h device.h
keycodes.o: keycodes.c device.h
joyisrz.o: joyisrz.s
