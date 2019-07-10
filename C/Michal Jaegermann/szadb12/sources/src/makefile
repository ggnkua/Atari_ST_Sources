#
# Makefile for the Atari ST - Sozobon C
#

CFLAGS = -c -O -DHELP
#CFLAGS = -c -O
#CFLAGS = -c

#
.c.o:
	cc $(CFLAGS) $<

# DO NOT optimize assembler sources!!
.s.o:
	cc -c $<

HDRS=   adb.h lang.h
SRCS=	start.s adb.c adb1.c pcs.c trace.c dis3.c prt.c assist.s
SRC2=	fkeydefs.c help.c window.c stepping.c
OBJ=	start.o adb.o adb1.o pcs.o trace.o dis3.o prt.o assist.o
OB2=	fkeydefs.o help.o window.o stepping.o

all : adb.ttp

help.o : $(HDRS)

# flag -t leaves symbol table in executables
adb.ttp : $(OBJ) $(OB2) adb.h
	ld -o adb.ttp -t -f adb.lds

clean :
	$(RM) $(OBJ) $(OB2)
