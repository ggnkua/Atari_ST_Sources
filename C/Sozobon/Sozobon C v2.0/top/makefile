#
# Makefile for the optimizer
#
CC=cc

OBJ =	main.o io.o util.o sym.o func.o branch.o inst.o opcodes.o \
	health.o data.o peep1.o peep2.o peep3.o reg.o

CFLAGS = -O

xtop.ttp : $(OBJ)
	$(CC) $(OBJ) -o xtop.ttp

clean:
	$(RM) *.o

clobber:
	$(RM) *.o xtop.ttp
