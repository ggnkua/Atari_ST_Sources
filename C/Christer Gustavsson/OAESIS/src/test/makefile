#
# Makefile for OAESIS test programs using GCC
#

CC = gcc
AS = gcc
LD = gcc
MODEL = -mshort
LDLIBS = -lmint16 -liio16 -lgem16

DEFS = -D__MINT__ 

CFLAGS = -Wall -fomit-frame-pointer $(MODEL) $(DEFS) -bm68k-mint
ASFLAGS = $(MODEL)

CFILES = appltrec.c evnttest.c formtest.c fcntltst.c lines.c test.c test2.c \
	test2rsc.c testikbd.c testmenu.c testmen.c trackvdi.c

SFILES = trackvds.s

PRJFILES = appltrec.prj evnttest.prj fcntltst.prj formtest.prj lines.prj \
	test.prj test2.prj testikbd.prj testmenu.prj trackvdi.prj

RCSFILES = $(CFILES) $(SFILES) $(PRJFILES) makefile test2rsc.hrd test2rsc.rsc \
	testmen.hrd \
	testmen.rsc testmen.h test2rsc.h

all: appltrec.prg evnttest.prg formtest.prg lines.prg test.prg test2.prg \
	testikbd.prg testmenu.prg

.SUFFIXES: .c .prg

.c.prg:
	$(LINK.c) -o $@ $< $(LDLIBS)

rcsci:
	ci -l $(RCSFILES)

clean:
	rm -f *.o

realclean: clean
	rm -f *.pdb *.prg
