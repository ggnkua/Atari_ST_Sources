################################################################################
#	Makefile for Rodime hard-disk across SCSI bus
################################################################################

CC= cc
CFLAGS= -OPS -c

#	HD handler with N sector buffering (No advantage on Rodime)
#hdhand: hd.o scsi.o rdwrhd.o devbuf.o
#	ld -r -o hdhand hd.o scsi.o rdwrhd.o devbuf.o

hdhand: hd.o scsi.o rdwrhd.o
	ld -r -o hdhand hd.o scsi.o rdwrhd.o

hd.o:	hd.c hd.h scsi.h
	$(CC) $(CFLAGS) hd.c

scsi.o:	scsi.c scsi.h 68230.h
	$(CC) $(CFLAGS) scsi.c

rdwrhd.o: rdwrhd.68k
	as68k -o rdwrhd.o rdwrhd.68k

devbuf.o: devbuf.c devbuf.h
	$(CC) $(CFLAGS) devbuf.c

