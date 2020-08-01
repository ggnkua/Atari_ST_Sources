#
# Makefile for the Atari ST
#

CFLAGS = -c

#	Sozobon rule
.c.o:
	cc $(CFLAGS) $<

.s.o:
	cc $(CFLAGS) $<

OBJ=	start.o adb.o adb1.o pcs.o trace.o dis3.o prt.o assist.o
OB2=	help.o window.o

all : szadb.ttp

szadb.ttp : $(OBJ) $(OB2)
	ld -o szadb.ttp -f adb.lds

clean :
	$(RM) $(OBJ)
