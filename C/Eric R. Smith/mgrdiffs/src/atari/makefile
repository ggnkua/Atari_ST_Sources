#                        Copyright (c) 1988,1989 Bellcore
#                            All Rights Reserved
#       Permission is granted to copy or use this program, EXCEPT that it
#       may not be sold for profit, the copyright notice must be reproduced
#       on copies, and credit should be given to Bellcore where it is due.
#       BELLCORE MAKES NO WARRANTY AND ACCEPTS NO LIABILITY FOR THIS PROGRAM.

#	$Header: Makefile,v 1.2 89/05/23 08:33:45 sau Exp $
#	$Source: /mnt/sau/bitblt/DEC/RCS/Makefile,v $

#	makefile for the Atari blit library (adapted from S. A. Uhler)

#	Compile flags
#	  INVERT	- invert the sense of black and white
#	  UNROLL - Unroll the inner loops
#	  NOCLIP	- Don't do clipping on bit-blits

START=.
CFLAGS= $(FLAG) -I. -DUNROLL
CC=gcc
AR=gcc-ar

LIBOBJS=bitmap.o blit.o line.o pixel.o bit_on.o

blitlib.a:		$(LIBOBJS)
			$(AR) rs blitlib.a $(LIBOBJS)

rops:		rops.o bitmap.o blit.o
			$(CC) $(CFLAGS) -o rops rops.o blit.o bitmap.o

test_rop:	test_rop.o bitmap.o blit.o
			$(CC) $(CFLAGS) -o test_rop test_rop.o blit.o bitmap.o

bitmap.o blit.o line.o pixel.o bit_on.o:	bitmap.h

clean:
	-rm -f *.o core blit.c
