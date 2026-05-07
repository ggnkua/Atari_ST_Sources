CC = gcc

#
#  Adjust these directories to suit your needs
#
#    BINDIR --- native (cross) version
#    68KDIR --- 68000 version
#
68KDIR = /usr/local/68k
BINDIR = /usr/local/bin


#
#  Adjust these definitions to suit MAC development under weigh:
#
#	-DBSD   for 4.2 BSD (always, here)
#	-DSYSV	for System V (ATT 3B1)
#	-O	production
#	-pg -g  profiling & debugging
#	-O -pg  profiling only
#
CFLAGS = -DLINUX86

HFILES = as.h amode.h sect.h token.h

CFILES = amac.c amem.c amode.c debug.c direct.c \
	eagen.c eagen0.c \
	error.c expr.c mach.c macro.c mark.c object.c mwobj.c \
	parmode.c procln.c sect.c symbol.c token.c \
	object.c listing.c fext.c 6502.c kwmatch.c time.c

MISC = 68ktab 6502.tbl mntab kwtab Makefile

OBJECTS = amac.o procln.o amode.o expr.o \
	sect.o direct.o mach.o macro.o eagen.o \
	token.o symbol.o mark.o amem.o error.o \
	debug.o object.o mwobj.o listing.o fext.o \
	6502.o kwmatch.o time.o

TOOLS = kwgen 68kgen


mac : $(OBJECTS)
	gcc -o mac $(OBJECTS)

#
#	generated sources
#

6502.h : 6502.tbl ./kwgen
	./kwgen mp <6502.tbl >6502.h

mntab.h : mntab 68kmn ./kwgen
	cat mntab 68kmn | ./kwgen mn >mntab.h

68ktab.h 68kmn : 68ktab 68ktab ./68kgen
	./68kgen 68kmn <68ktab >68ktab.h

kwtab.h : kwtab ./kwgen
	./kwgen kw <kwtab >kwtab.h

amac.o : amac.c
debug.o : debug.c
amode.o : amode.c parmode.c amode.h kwtab.h mntab.h
token.o : token.c kwtab.h token.h
symbol.o : symbol.c
listing.o : listing.c
mark.o : mark.c
object.o : object.c
mwobj.o : mwobj.c
procln.o : procln.c mntab.h 6502.h
expr.o : expr.c
sect.o : sect.c
direct.o : direct.c
mach.o : mach.c 68ktab.h kwtab.h
macro.o : macro.c token.h
eagen.o : eagen.c eagen0.c
amem.o : amem.c
error.o : error.c
fext.o : fext.c
6502.o : 6502.c
kwmatch.o : kwmatch.c
time.o : time.c

#
#  Tools
#

./kwgen : kwgen.c
	gcc kwgen.c -o kwgen

./68kgen : 68kgen.c
	gcc 68kgen.c -o 68kgen


clean:
	rm *.o kwgen 68kgen mac kwtab.h 68ktab.h mntab.h 6502.h
