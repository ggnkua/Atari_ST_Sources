# A SozobonX makefile for XIMG viewer

CFLAGS   = -e -v -O +O-q
LOADLIBES= xaesfast.a xvdifast.a

ximgview.prg: ximgview.o
