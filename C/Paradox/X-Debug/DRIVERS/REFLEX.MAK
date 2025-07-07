
# makefile for Reflex driver

reflex.scr: reflex.c
	lc -L+checkram.o -b0 -v -w reflex
	mv -f reflex.ttp reflex.scr
