# makefile for gulam

# 890111 kbad	hacked it out. Note: some of these files may benefit from
#		MWC optimization flagz, but I haven't bothered.
#
# Use these defines for MWC
#CFLAGS	=	-DMWC -VPEEP -NOVSUVAR -NOVSNREG
#LIBS = -lc
#CC = cc
#
#.c.o:
#	cc $(CFLAGS) -c $*.c
#
# Use these defines for GCC
CC = gcc
#CFLAGS = -O -mshort -I. -DMWC -funsigned-char \
#	-fomit-frame-pointer -fcombine-regs -fwritable-strings

#CFLAGS = -O -mshort -DMWC -funsigned-char -G
CFLAGS = -O -mshort -DMWC -funsigned-char
LIBS =

# gasmmwc.o removed, gasmgnu.o added

SRCFILES	= basic.c buffer.c cs.c display.c do.c error.c \
		ex.c file.c fio.c fop.c function.c gasmgnu.c \
		gcoatari.c gfsatari.c gioatari.c gmcatari.c \
		hist.c kb.c lex.c line.c ls.c main.c misc.c \
		pmalloc.c pregrep.c random.c regexp.c region.c \
		rehash.c rsearch.c teb.c tv.c ue.c util.c \
		window.c word.c xmdm.c \
		gu.h  keynames.h  regexp.h  sysdpend.h  ue.h

OFILES =	basic.o buffer.o cs.o display.o do.o error.o \
		ex.o file.o fio.o fop.o function.o gasmgnu.o \
		gcoatari.o gfsatari.o gioatari.o gmcatari.o \
		hist.o kb.o lex.o line.o ls.o main.o misc.o \
		pmalloc.o pregrep.o random.o regexp.o region.o \
		rehash.o rsearch.o teb.o tv.o ue.o util.o \
		window.o word.o xmdm.o

UEFILES	=	basic.o buffer.o cs.o display.o error.o file.o \
		fio.o function.o kb.o line.o misc.o random.o \
		region.o rsearch.o teb.o ue.o window.o word.o

GUFILES	=	cs.o word.o do.o ex.o fop.o gcoatari.o \
		gfsatari.o gioatari.o gmcatari.o hist.o \
		lex.o ls.o main.o pregrep.o rehash.o tv.o \
		util.o xmdm.o

KEYFILES=	gioatari.o kb.o misc.o random.o teb.o ue.o

REFILES	=	ex.o pregrep.o regexp.o rsearch.o

gunew.prg:	$(OFILES)
		$(CC) $(CFLAGS) -s -o $@ $(OFILES) $(LIBS)

link:
		$(CC) $(CFLAGS) -s -o gunew.prg $(OFILES) $(LIBS)

$(UEFILES):	ue.h sysdpend.h

$(GUFILES):	gu.h sysdpend.h

$(KEYFILES):	keynames.h

$(REFILES):	regexp.h

gasmmwc.o:	gasmmwc.s
		as -o $@ $<

# linux runs these ...
splint:
	splint -I ~/projects/st-archive/driveC/programm.ing/c/gcc/include/ \
	-D__GNUC__ -booltype BOOL -ansi-lib $(SRCFILES)

TAGS: $(SRCFILES)
	etags  $(SRCFILES) gu.h  keynames.h  regexp.h  sysdpend.h  ue.h
