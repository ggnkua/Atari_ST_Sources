#!/bin/make -f
# pathalias -- by steve bellovin, as told to peter honeyman

### begin configuration section
###
# if you can't or don't intend to use dbm files,
# don't bother with DBM or makedb
DBM = -ldbm
# or if you roll your own ...
# DBM = dbm.o
###
# where is getopt (if not in the c library)?
# GETOPT = getopt.o
### end of configuration section 


CFLAGS = -DMWC
LDFLAGS = -s $(GETOPT)
YFLAGS = -d

OBJ = addlink.o addnode.o local.o main.o mapit.o mapaux.o mem.o parse.o printit.o
HDRS = def.h config.h
CSRC = addlink.c addnode.c local.c main.c mapit.c mapaux.c mem.c printit.c
LSRC = $(CSRC) parse.c
SRC = $(CSRC) makedb.c arpatxt.c

pathalias: $(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o palias.prg

all: pathalias makedb arpatxt

$(OBJ):	$(HDRS)

makedb: makedb.o
	$(CC) makedb.o $(LDFLAGS) $(DBM) -o makedb

makedb.o: config.h

arpatxt: arpatxt.o
	$(CC) arpatxt.o $(LDFLAGS) -o arpatxt

clobber: clean
	rm -f pathalias makedb arpatxt

tags: $(SRC) $(HDRS)
	ctags -w $(HDRS) $(SRC)

bundle:
	@bundle README CHANGES pathalias.1 Makefile ${HDRS} ${SRC}

lint:	$(LSRC)
	lint $(CFLAGS) $(LSRC)
	lint makedb.c
	lint arpatxt.c

install:
	@echo "install pathalias, makedb, arpatxt, and pathalias.1"
	@echo "according to local conventions"
