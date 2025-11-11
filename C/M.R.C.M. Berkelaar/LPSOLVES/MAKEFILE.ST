MYSOURCES= main.c solve.c read.c write.c tran.c dual.c
YSOURCE= ytab.c
YOBJECT= ${YSOURCE:.c=.o}
LSOURCE= lexyyx.c
OBJECTS= ${MYSOURCES:.c=.o} ${YOBJECT}
INCLUDES= globals.h defines.h proto.h
TARGET= lp_solve
MANPAGE= ${TARGET}.1

# -ll and -lm seems to be enough on most machines.
#LIBS= -ll -lm
LIBS= -lpml

# change this when you like. They are only used with make install.
INSTALLDIR=/usr/local/bin
MANDIR=/usr/local/man/man1

# for performance reasons be sure to add all possible floating point support
# This is ANSI C code following POSIX standards, be sure to tell your compiler
# when necessary.
# default
CFLAGS= -O
#Apollo 68040 based: 425[est], DN5500
#CFLAGS= -O -Acpu,mathlib
#Apollo 680[23]0 based: DN[234]XXX
#CFLAGS= -O -Acpu,mathchip
# debugging
#CFLAGS= -g

# choose a C compiler. On Sun, you probably want to use gcc
CC= gcc

${TARGET} : ${OBJECTS} 
	${CC} -o ${TARGET} ${CFLAGS} ${OBJECTS} ${LIBS}

${OBJECTS} : ${INCLUDES}

main.o : patchlev.h


#${LSOURCE} : lex.l
#	lex lex.l

#${YSOURCE} : lp.y
#	yacc lp.y

#${YOBJECT} : ${LSOURCE}

install:
	cp ${TARGET} ${INSTALLDIR}
	cp ${MANPAGE} ${MANDIR}

clean:
	/bin/rm -f ${OBJECTS} ${TARGET} TAGS ${LSOURCE}  ${YSOURCE}

# the following definitions can be practical if you have the tools

TAGS:
	etags *.[chly]

proto.h:
	mkproto ${MYSOURCES} > proto.h

${TARGET}.man: ${MANPAGE}
	nroff -man ${MANPAGE} > ${TARGET}.man
