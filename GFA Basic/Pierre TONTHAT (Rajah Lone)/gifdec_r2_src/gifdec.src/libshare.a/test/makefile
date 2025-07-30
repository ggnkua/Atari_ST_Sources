#  makefile for libshare/test.ldg:
#  by Arnaud BERCEGEAY (Feb 2004)


ifeq ($(CROSS),yes)
CROSSPREFIX = m68k-atari-mint
CC     = $(CROSSPREFIX)-gcc
AR     = $(CROSSPREFIX)-ar
PREFIX = /usr/$(CROSSPREFIX)
else
CC     = gcc
AR     = ar
PREFIX = /usr
endif

WARN = \
        -Wall \
        -Wmissing-prototypes \
        -Winline \
        -Wshadow \
        -Wpointer-arith \
        -Wcast-qual \
        -Waggregate-return
        
CFLAGS= -O2 -fomit-frame-pointer $(WARN) $(M68K_ATARI_MINT_CFLAGS)

LIBOBJ = libtest.o
PRGOBJ = prgtest.o

.SUFFIXES:
.SUFFIXES: .c .S .o

.c.o:
	$(CC) $(CFLAGS) -c $*.c -o $*.o

LIBTARGET = test.ldg 
PRGTARGET = test.tos

all: $(LIBTARGET) $(PRGTARGET)

$(LIBTARGET): $(LIBOBJ)
	$(CC) -o$@ $(LIBOBJ) -lshare -lldg -lgem

$(PRGTARGET): $(PRGOBJ)
	$(CC) -o$@ $(PRGOBJ) -lldg -lgem

clean:
	rm -f *.o
