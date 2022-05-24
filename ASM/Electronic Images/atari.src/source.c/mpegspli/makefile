#
# Copyright (c) 1994 Michael Simmons.
# All rights reserved.
# 
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose, without fee, and without written agreement is
# hereby granted, provided that the above copyright notice and the following
# two paragraphs appear in all copies of this software.
# 
# IN NO EVENT SHALL MICHAEL SIMMONS BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF MICHAEL SIMMONS
# HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# THE MICHAEL SIMMONS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND MICHAEL SIMMONS HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#
# I can be contacted via 
# Email: michael@ecel.uwa.edu.au
# Post: P.O. Box 506, NEDLANDS WA 6009, AUSTRALIA
# Linux
#CC=g++
#CFLAGS=-O2 -m486 -funroll-loops -Wall -DLINUX -DINTEL_BYTE_ORDER
#INCLUDES=-I/usr/g++-include/ -I/usr/lib/gcc-lib/i486-linux/2.5.8/include/
#LIBS=-lm

# SunOS
CFLAGS = -O2
CC = gcc
LIBS = -lpml

OBJS = main.o global.o fileio.o util.o split.o parsers.o dialog.o errmsg.o

all:		splitmpeg

splitmpeg:	$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o $@ $(LIBS) 

.c.o:
		$(CC) -c $(CFLAGS) $(INCLUDES) $< -o $@

depend:
		makedepend $(INCLUDES) -w100 *.c

clean:
		-rm splitmpeg
		-rm *.o

tags:
		etags *.c *.h


# DO NOT DELETE THIS LINE -- make depend depends on it.

