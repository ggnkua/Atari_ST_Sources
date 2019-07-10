# makefile for t100	Wed Sep 11 00:17:06 1991
#
# $Id: makefile.,v 1.0 1991/09/12 21:15:04 rosenkra Exp $
#
# $Log: makefile.,v $
# Revision 1.0  1991/09/12  21:15:04  rosenkra
# Initial revision
#
#
# this was originally set up for MiNT so i left it that way. note the use
# of -nostdlib in the link to get at mint in my setup. this works! LIBS
# must appear at the end of the list, however. works with gmake 3.60. note
# the -z for gcc to have stderr go to file "compile.err".
#
# tested with: gcc v1.40, mintlib10, 32-bit
#
# for -mshort, LIBS will need to be changed to gnu16 and iio16.
#
# configuration:
#
# DEBUG			debugging mode
# EMUL_VT100		set to have it do ANSI/vt100 (much of it, not all)
# SET_RS232_INIT	for TOS 1.2 and up. does Rsconf and uses return val
# SWAP_DEL_AND_BS	interchanges del and backspace keys if defined
# USE_FONTS		does bold, underline, and reverse. also resets sys
#			font. only when EMUL_VT100 is defined. uses line A
#			to get font header ptr. resets sys font on exit.
#

CC		= gcc
DEBUG		= #-DDEBUG
DEFINES		= -DEMUL_VT100 -USET_RS232_INIT -USWAP_DEL_AND_BS -DUSE_FONTS
CFLAGS		= -v -Wall -z -Ig:/mint/include $(DEBUG) $(DEFINES)
LDSPECIAL	= -nostdlib g:/mint/lib/crt0.o
LDFLAGS		= -v -Wall -z -Lg:/mint/lib $(LDSPECIAL)
LIBS32		= -lgnu -liio
LIBS16		= -lgnu16 -liio16
# if -mshort, use LIBS16...
LIBS		= $(LIBS32)

TARGET		= t100.ttp

OBJS		= t100.o cookie.o config.o vt100.o bold.o roman.o uline.o\
		normal.o reverse.o font.o



$(TARGET):	$(OBJS)
		$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS) $(LIBS)



t100.o:		t100.h t100.c
		$(CC) $(CFLAGS) -c -o t100.o t100.c

cookie.o:	t100.h cookie.c
		$(CC) $(CFLAGS) -c -o cookie.o cookie.c

config.o:	t100.h config.c
		$(CC) $(CFLAGS) -c -o config.o config.c

vt100.o:	t100.h vt100.c
		$(CC) $(CFLAGS) -c -o vt100.o vt100.c

font.o:		font.c
roman.o:	roman.c roman.h
bold.o:		bold.c bold.h
uline.o:	uline.c uline.h
reverse.o:	reverse.c reverse.h
normal.o:	normal.c


clean:
		rm $(OBJS)

clobber:	clean
		rm t100.ttp
