#
#	Makefile for compiling InfoTaskForce Infocom Interpreter on Atari ST
#	with Sozobon C version 2.0
#

OBJECTS =	enhanced.o file.o fns.o globals.o infocom.o init.o input.o\
		interp.o io.o jump.o message.o object.o options.o\
		page.o plus_fns.o print.o property.o status.o\
		support.o variable.o

H	=	machine.h infocom.h atari_io.h

CFLAGS = -O -UATARI_ST -DVT52 -DCHEAT	  # The compiler defines SOZOBON

infocom.ttp: $(OBJECTS)
	ld -pb -f atari.ld -o infocom.ttp

$(OBJECTS): $(H) makefile.st
io.o: atari_io.c

