# makefile for an acc

CFLAGS    = -v -e -O +O-q
LDFLAGS   = -s accappmi.o
LOADLIBES = xaesfast.a xvdifast.a

ximgsnap.prg: ximgsnap.c

