
# makefile for Moniterm driver

moniterm.scr: moniterm.c
	lc -L+checkram.o -b0 -v -w moniterm
	mv -f moniterm.ttp moniterm.scr
