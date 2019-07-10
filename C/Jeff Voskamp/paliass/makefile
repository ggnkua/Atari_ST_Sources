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
GETOPT =
### end of configuration section 

# note: parse.y -> parse.c is commented out below (most don't have YACC)

CC = cc
CFLAGS = -O -DATARI
YFLAGS = -d

OBJ = addlink.o addnode.o local.o main.o mapit.o mapaux.o mem.o parse.o printit.o getopt.o
HDRS = def.h config.h
CSRC = addlink.c addnode.c local.c main.c mapit.c mapaux.c mem.c printit.c getopt.c
LSRC = $(CSRC) parse.c
SRC = $(CSRC) parse.y makedb.c arpatxt.c

pathalia.ttp: $(OBJ)
	$(CC) $(OBJ) -o pathalia.ttp

all: pathalia.ttp makedb arpatxt

$(OBJ):	$(HDRS)

# if you actually have YACC (or compatible) de-comment this
#parse.c: parse.y $(HDRS)
#	$(YACC) $(YFLAGS) parse.y
#	mv y_tab.c parse.c

makedb: makedb.o
	$(CC) makedb.o $(LDFLAGS) $(DBM) -o makedb

makedb.o: config.h

arpatxt: arpatxt.o
	$(CC) arpatxt.o $(LDFLAGS) -o arpatxt

clean:
	rm -f *.o y.tab.? parse.c

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
