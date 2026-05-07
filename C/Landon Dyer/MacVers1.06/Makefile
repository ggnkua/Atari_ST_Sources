CRUN = /lib/crt0.o
CLIB = -lc
CC = cc

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
#	-O	production
#	-pg -g  profiling & debugging
#	-O -pg  profiling only
#
CFLAGS = -DBSD -DDO_DEBUG -O

HFILES = as.h amode.h sect.h token.h

CFILES = amac.c amem.c amode.c debug.c direct.c\
	eagen.c eagen0.c\
	error.c expr.c mach.c macro.c mark.c object.c mwobj.c\
	parmode.c procln.c sect.c symbol.c token.c\
	object.c listing.c fext.c 6502.c kwmatch.c time.c

MISC = 68ktab 6502.tbl mntab kwtab Makefile

OBJECTS = amac.o procln.o amode.o expr.o\
	sect.o direct.o mach.o macro.o eagen.o\
	token.o symbol.o mark.o amem.o error.o\
	debug.o object.o mwobj.o listing.o fext.o 6502.o kwmatch.o time.o

TOOLS = kwgen 68kgen


mac : ${OBJECTS}
	${CC} ${CFLAGS} -o mac ${OBJECTS}

amac.o : amac.c
	${CC} ${CFLAGS} -c amac.c

debug.o : debug.c
	${CC} ${CFLAGS} -c debug.c

amode.o : amode.c parmode.c amode.h kwtab.h mntab.h
	${CC} ${CFLAGS} -c amode.c

token.o : token.c kwtab.h token.h
	${CC} ${CFLAGS} -c token.c
kwtab.h : kwtab
	kwgen kw <kwtab >kwtab.h

symbol.o : symbol.c
	${CC} ${CFLAGS} -c symbol.c

listing.o : listing.c
	${CC} ${CFLAGS} -c listing.c

mark.o : mark.c
	${CC} ${CFLAGS} -c mark.c

object.o : object.c
	${CC} ${CFLAGS} -c object.c

mwobj.o : mwobj.c
	${CC} ${CFLAGS} -c mwobj.c

procln.o : procln.c mntab.h 6502.h
	${CC} ${CFLAGS} -c procln.c
6502.h : 6502.tbl
	kwgen mp <6502.tbl >6502.h
mntab.h : mntab 68kmn
	@echo "This may take a minute or so:"
	cat mntab 68kmn | kwgen mn >mntab.h
68ktab.h 68kmn : 68ktab
	68kgen 68kmn <68ktab >68ktab.h

expr.o : expr.c
	${CC} ${CFLAGS} -c expr.c

sect.o : sect.c
	${CC} ${CFLAGS} -c sect.c

direct.o : direct.c
	${CC} ${CFLAGS} -c direct.c

mach.o : mach.c 68ktab.h kwtab.h
	${CC} ${CFLAGS} -c mach.c

macro.o : macro.c token.h
	${CC} ${CFLAGS} -c macro.c

eagen.o : eagen.c eagen0.c
	${CC} ${CFLAGS} -c eagen.c

amem.o : amem.c
	${CC} ${CFLAGS} -c amem.c

error.o : error.c
	${CC} ${CFLAGS} -c error.c

fext.o : fext.c
	${CC} ${CFLAGS} -c fext.c

6502.o : 6502.c
	${CC} ${CFLAGS} -c 6502.c

kwmatch.o : kwmatch.c
	${CC} ${CFLAGS} -c kwmatch.c

time.o : time.c
	${CC} ${CFLAGS} -c time.c

#
#  Tools
#
kwgen : kwgen.c
	cc -o kwgen kwgen.c

68kgen : 68kgen.c
	cc -o 68kgen 68kgen.c

conv65 : conv65.o fext.o
	cc -o conv65 conv65.o fext.o
conv65.o : conv65.c
	cc -c -DBSD conv65.c

#
#  Electric things
#
clean :
	rm ${OBJECTS} mac kwtab.h 6502.h mntab.h 68ktab.h 68kmn

listing :
	print ${HFILES} ${CFILES} ${MISC}

backup :
	cp ${MISC} *.s *.h *.c Bak

install :
	cp mac ${BINDIR}
	cp mac.prg ${68KDIR}

send :
	send *.h ${CFILES} st.c kmatch.s stasm.s clear.s \
		${MISC} Make.ST

shar :
	shar *.h ${CFILES} st.c kmatch.s stasm.s clear.s ${MISC} \
	conv65.c 68kgen.c \
	 >mac.shar

lint :
	lint -vhxc ${CFLAGS} ${HFILES} ${CFILES}
