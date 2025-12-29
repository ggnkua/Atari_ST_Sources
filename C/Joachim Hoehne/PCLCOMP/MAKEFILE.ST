#
# Makefile for pclcomp using gcc on an atari computer
#
CC = gcc
CFLAGS = -O2 -fomit-frame-pointer -mint
LIBS =

OBJS = getopt.o pclcomp.o

all: pclcomp

pclcomp: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o pclcomp.ttp
	xstrip -k pclcomp.ttp

# -eof-
