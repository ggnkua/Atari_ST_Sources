#
# Makefile for oAESis using GCC
#

CC = gcc
AS = gcc
LD = gcc
MODEL = -mshort
LDLIBS = -lmint16 -liio16 -lgem16


DEFS = -D__MINT__ 


CFLAGS = -Wall -fomit-frame-pointer $(MODEL) $(DEFS) -bm68k-mint
ASFLAGS = $(MODEL)

CFILES = appl.c boot.c debug.c docalls.c evnt.c evnthndl.c form.c fsel.c \
         global.c graf.c main.c menu.c misc.c mousedev.c objc.c rdwrs.c \
         resource.c rlist.c rsrc.c scrp.c shel.c vdi.c wind.c

HFILES = appl.h boot.h debug.h evnt.h evnthndl.h form.h fsel.h gemdefs.h \
         global.h \
         graf.h lxgemdos.h mintdefs.h menu.h mesagdef.h misc.h mousedev.h \
         objc.h rdwrs.h resource.h rlist.h rsrc.h scrp.h shel.h types.h \
         version.h vdi.h \
         wind.h
   
SFILES = gcc.s

OBJS = $(CFILES:%.c=%.o) $(SFILES:%.s=%.o)

all: oaesis.prg
	cd test; $(MAKE)

oaesis.prg: $(OBJS)
	$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
	strip $@

gcc.o: lxgemdos.h

appl.o:     appl.h debug.h evnthndl.h mintdefs.h menu.h mesagdef.h misc.h \
            rdwrs.h types.h vdi.h wind.h
boot.o:     debug.h global.h mintdefs.h misc.h types.h
debug.o:    debug.h
docalls.o:  appl.h debug.h evnt.h form.h fsel.h global.h graf.h menu.h objc.h \
            rdwrs.h rsrc.h scrp.h shel.h types.h wind.h
evnt.o:     appl.h debug.h evnt.h evnthndl.h global.h lxgemdos.h \
            mintdefs.h mesagdef.h objc.h resource.h types.h wind.h
evnthndl.o: appl.h debug.h evnthndl.h global.h mintdefs.h mesagdef.h misc.h \
            mousedev.h objc.h resource.h types.h vdi.h wind.h
form.o:     appl.h debug.h evnt.h form.h global.h graf.h mintdefs.h objc.h \
            resource.h types.h wind.h
fsel.o:     appl.h debug.h form.h fsel.h graf.h mintdefs.h misc.h objc.h \
            resource.h rsrc.h types.h
global.o:   boot.h debug.h global.h lxgemdos.h types.h vdi.h
graf.o:     appl.h debug.h evnt.h evnthndl.h global.h graf.h misc.h objc.h \
            resource.h types.h vdi.h wind.h
main.o:     appl.h debug.h evnt.h evnthndl.h form.h graf.h lxgemdos.h menu.h \
            misc.h mousedev.h objc.h rdwrs.h resource.h wind.h
menu.o:     appl.h boot.h debug.h evnt.h global.h lxgemdos.h mintdefs.h menu.h \
            mesagdef.h misc.h objc.h rdwrs.h resource.h types.h version.h wind.h
misc.o:     global.h lxgemdos.h misc.h types.h vdi.h
mousedev.o: appl.h lxgemdos.h mintdefs.h misc.h mousedev.h types.h vdi.h
objc.o:     appl.h debug.h global.h misc.h objc.h types.h vdi.h
rdwrs.o:    debug.h mintdefs.h rdwrs.h types.h
rlist.o:    mintdefs.h misc.h rlist.h types.h
rsrc.o:     appl.h debug.h mintdefs.h rsrc.h shel.h types.h vdi.h
scrp.o:     scrp.h types.h
shel.o:     appl.h debug.h lxgemdos.h misc.h rdwrs.h types.h
vdi.o:      lxgemdos.h types.h vdi.h
wind.o:     appl.h debug.h evnt.h evnthndl.h global.h lxgemdos.h \
            mintdefs.h mesagdef.h misc.h objc.h rdwrs.h \
            resource.h rlist.h types.h vdi.h wind.h


#
# assembler source files
#
.SUFFIXES: .s .o0

.s.o:
	$(AS) $(ASFLAGS) -o $@ -c $<


gcc.o: gcc.s

tosify:
	cleanret -a $(CFILES) $(HFILES)

unixify:
	cleanret -u $(CFILES) $(HFILES)

EXTRAS= oaesis.prg $(ATRANS) $(ATRANSOBJ)

rcsci:
	ci -l $(CFILES) $(HFILES) $(SFILES) purec.s resource.hrd resource.rsc \
           oaesis.prj makefile
	cd test; $(MAKE) rcsci

rcsco:
	co -l $(CFILES) $(HFILES) $(SFILES) purec.s resource.hrd resource.rsc \
           oaesis.prj

clean:
	rm -f $(OBJS) purec.o
	cd test; $(MAKE) clean

realclean:
	rm -f $(OBJS) purec.o $(EXTRAS) *.pdb
	cd test; $(MAKE) realclean

