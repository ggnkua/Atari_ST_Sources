################################################################################
#	Makefile for floppy handler
################################################################################

AS=as68k
CC=cc
CFLAGS= -c -OPS
KIT= -E
#TEST= -DEXBUF
TEST=

fdhand: floppy.h ../../include/buf.h fdc.o fdcmnds.o rdwrc.o
	ld -x -r -o fdhand fdc.o fdcmnds.o rdwrc.o

rdwrc.o: rdwrc.68k
	$(AS) -o rdwrc.o rdwrc.68k

fdc.o: floppy.h ../../include/buf.h fdc.c buffer.h
	$(CC) $(CFLAGS) $(TEST) fdc.c

fdcmnds.o: floppy.h fdcmnds.c
	$(CC) $(CFLAGS) $(TEST) fdcmnds.c

# Test software
fdhandt: floppy.h ../../include/buf.h fdc.o fdcmnds.o rdwrc.o ftest.o
	ld -x -r -o fdhandt fdc.o fdcmnds.o rdwrc.o ftest.o

ftest.o: ftest.c
	$(CC) $(CFLAGS) ftest.c

# Test software for a kit (Runs stand alone)
fdtest: floppy.h ../../include/buf.h test.o fdc.o fdcmnds.o rdwrc.o ftest.o\
	testutil.o
	$(CC) $(KIT) -o fdtest test.o fdc.o fdcmnds.o rdwrc.o ftest.o testutil.o

test.o: test.c ../../include/buf.h
	$(CC) $(CFLAGS) test.c

testutil.o: testutil.68k
	$(AS) -o testutil.o testutil.68k
