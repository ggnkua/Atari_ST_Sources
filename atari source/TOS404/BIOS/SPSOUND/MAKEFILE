# Makefile for Sparrow XBIOS sound calls

.SUFFIXES:
.SUFFIXES: .o .s

.s.o:
	mac -u -y96 $<

spsound.o: soundcmd.o sndlow.o
	aln -u -p -w -l -o $@ $<

soundcmd.o: soundcmd.s spardef.inc
sndlow.o: sndlow.s spardef.inc

