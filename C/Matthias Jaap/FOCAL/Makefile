# Makefile for focal
#

#CC = cc
#CFLAGS = -O -DDIR_SUPPORT -DDIRENT
CC = gcc
CFLAGS	= -O -g -Wall -DDIR_SUPPORT -DDIRENT

OBJECTS	= \
	focal0.o \
	focal1.o \
	focal2.o \
	focal3.o

SHAR	= \
	README \
	INSTALL \
	Makefile \
	makefile.dos \
	focal.doc \
	focal.h \
	proto.h \
	focal0.c \
	focal1.c \
	focal2.c \
	focal3.c \
	sieve.foc \
	queens.foc

all:	focal

$(OBJECTS) : focal.h proto.h

focal:	$(OBJECTS)
	$(CC) $(CFLAGS) -o focal $(OBJECTS) -lm

shar:
	shar -s SDI00379@niftyserve.or.jp -c -v -x -w -n Focal -a $(SHAR) > focal.shar

tar:
	tar cvof focal.tar $(SHAR)

targz:	tar
	gzip focal.tar

clean:
	rm -f *~ *.o core a.out

clobber: clean
	rm -f focal
	rm -f focal.shar
	rm -f focal.tar focal.tar.gz
