INCLUDE=d:\tc\include
LINK   = d:\tc\tlink.ttp
#
#	CFLAGS:
#
#	-A	 = ANSI only
#	-P-	 = Don't allow 16 bits addressing within same file
#	-W+	 = Activate all warnings
#	-DATARI	 = Machine is AtariST
#
CFLAGS = -A -P -W+ -I${INCLUDE} -DATARI

CC     = d:\tc\tcc.ttp ${CFLAGS}

OBJ=	mines.o explode.o rsc.o

mines.prg: ${OBJ}
	${LINK} -S=8000 -C=mines.lnk

mines.o: mines.c shapes.h mines.h
	${CC} mines.c

explode.o: explode.c explode.h
	${CC} explode.c

rsc.o: rsc.c mines.h
	${CC} rsc.c

backup:
	d:\usr\bin\zoo.ttp a mines.zoo *.c *.h makefile *.lnk *.rsc *.rsd
