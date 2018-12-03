#/* 
# *   Copyright (c) 1990 Rodney Volz
# *   ALL RIGHTS RESERVED 
# * 
# *   THIS SOFTWARE PRODUCT CONTAINS THE
# *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
# *
# *   The copyright notices above do not evidence
# *   intended publication of such source code.
# *
# */
#
#/*
# * MERCURY UUCP SOURCECODE [MAKEFILE]
# */
#



#
# Megamax-C compiler:
MMCC	= \bin.mm\cc.prg
# Megamax-C linker:
MMLD	= \bin.mm\ld.prg
# Mark-Williams-C compiler:
MWCC	= \bin.mwc\cc.prg

CFLAGS	= -DMWC -DST

.SUFFIXES: .o .c .s .mmc .prg

.mmc.o:
	cp $< tmp.c
	$(MMCC) tmp.c
	rm tmp.c
	mv tmp.o $@

#
## Here we go...
#

all:	batch elm expire login mail pnews rnews rn rmail server \
	statnews showmail uupoll uucp uux uudecode uuencode unshar
	echo


install:
		$(MWCC)	install.c -o install.prg

unshar:
		$(MWCC) -O unshar.c -o unshar.prg

uudecode:
		$(MWCC) -O uudecode.c -o uudec.prg

uuencode:
		$(MWCC) -O uuencode.c -o uuenc.prg

batch:	batch.o
	$(MMLD) -o batch.prg batch.o

elm:	elm.o
	$(MMLD) -o elm.prg elm.o

expire:	expire.o
	$(MMLD) -o expire.prg expire.o

login:	login.o
	$(MMLD) -o login.prg login.o

mail:	mail.o
	$(MMLD) -o mail.prg mail.o

pnews:	pnews.o
	$(MMLD) -o pnews.prg pnews.o

rnews:	rnews.o
	$(MMLD) -o rnews.prg rnews.o

rmail:	rmail.o
	$(MMLD) -o rmail.prg rmail.o

server:	server.o
	$(MMLD) -o server.prg server.o

statnews: statnews.o
	$(MMLD) -o statnews.prg statnews.o

showmail: showmail.o
	$(MMLD) -o showmail.prg showmail.o

uupoll:	uupoll.o
	$(MMLD) -o uupoll.prg uupoll.o

uucp:	uucp.o
	$(MMLD) -o uucp.prg uucp.o

uux:	uux.o
	$(MMLD) -o uux.prg uux.o

rn:	rn.o
	$(MMLD) -o rn.prg rn.o

