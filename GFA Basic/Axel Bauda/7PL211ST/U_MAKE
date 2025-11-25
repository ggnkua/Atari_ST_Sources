#
# Makefile for 7PLUS under UNIX
#

# choose your target for the Makefile.
# for MessDOS you should choose "7plus.exe".
TARGET = 7plus
#TARGET = 7plus.exe

# define the object suffix of your system.
# for MessDOS you should define "obj".
O = o
#O = obj

# choose compiler and linker and their flags
# GNU cc
CC = gcc
LD = gcc
CFLAGS = -O -W -ansi
LDFLAGS = -s -ansi

# ordinary cc (must be ANSI)
#CC = cc
#LD = cc
#CFLAGS = -O
#LDFLAGS = -s

# choose defines and special flags for your system:
# - normally: no defines
# - AT&T System V Release 4, SCO UNIX (no gcc): -D__unix__ -DSYSV
#DEFINES = -D__unix__ -DSYSV
DEFINES =
# - BSD, Ultrix, AT&T System V Release 4, SCO UNIX/XENIX: no special flags
# - Interactive UNIX 386: -posix
#SPECFLAGS = -posix
SPECFLAGS =

SRCS =  7plus.c  encode.c  correct.c rebuild.c  decode.c \
        extract.c join.c  utils.c  unix.c

OBJS =  7plus.$O encode.$O correct.$O rebuild.$O decode.$O \
        extract.$O join.$O utils.$O unix.$O

.c.o:
	$(CC) -c $(CFLAGS) $(SPECFLAGS) $(DEFINES) $*.c

TARGET: $(OBJS)
	$(LD) $(LDFLAGS) $(SPECFLAGS) -o $(TARGET) $(OBJS) $(LIBS)

depend:
	$(CC) -M $(SRCS) >depend.out

clean:
	rm -f $(OBJS)
	rm -f $(TARGET) core a.out depend.out

7plus.o : 7plus.c 7plus.h
encode.o : encode.c 7plus.h globals.h 
rebuild.o : rebuild.c 7plus.h globals.h 
decode.o : decode.c 7plus.h globals.h 
correct.o : correct.c 7plus.h globals.h
extract.o : extract.c 7plus.h globals.h 
join.o : join.c 7plus.h globals.h 
utils.o : utils.c 7plus.h globals.h 
unix.o : unix.c 7plus.h
