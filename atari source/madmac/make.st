#
#  Makefile for 68000 (ST) version of MADMAC
#
AS = mac
CLIB = lib7.a
CC = c68
CFLAGS = -DST
ST = st_

HFILES = as.h amode.h sect.h token.h

CFILES = amac.c amem.c amode.cdirect.c \
	eagen.c eagen0.c \
	error.c expr.c mach.c macro.c mark.c \
	parmode.c procln.c sect.c symbol.c token.c \
	object.c mwobj.c listing.c fext.c st.c 6502.c \
	kmatch.s stasm.s clear.s qsort.c time.c

MISC = 68ktab 6502.tbl mntab kwtab Makefile

OBJECTS = ${ST}amac.o ${ST}procln.o ${ST}amode.o ${ST}expr.o \
	${ST}sect.o ${ST}direct.o ${ST}mach.o ${ST}macro.o ${ST}eagen.o \
	${ST}token.o ${ST}symbol.o ${ST}mark.o ${ST}amem.o ${ST}error.o \
	${ST}object.o ${ST}mwobj.o ${ST}listing.o ${ST}fext.o \
	${ST}st.o ${ST}kmatch.o ${ST}stasm.o ${ST}6502.o ${ST}clear.o \
	${ST}qsort.o ${ST}time.o

TOOLS = kwgen 68kgen


#
#  mac.prg	vanilla, production MAC
#  smac.prg	MAC with global symbols for profiling
#  dmac.prg	MAC with global and local symbols for debugging
#
mac.prg : ${OBJECTS} c680.o
	aln -w -o mac.prg \
	c680.o ${OBJECTS} ${CLIB}

smac.prg : ${OBJECTS}
	aln -s -w -o smac.prg \
	c680.o ${OBJECTS} ${CLIB}

dmac.prg : ${OBJECTS}
	aln -s -l -w -o dmac.prg \
	c680.o ${OBJECTS} ${CLIB}

c680.o : c680.s
	mac c680.s

${ST}kmatch.o : kmatch.s
	mac -o ${ST}kmatch.o kmatch.s

${ST}stasm.o : stasm.s
	mac -o ${ST}stasm.o stasm.s

${ST}clear.o : clear.s
	mac -o ${ST}clear.o clear.s

${ST}amac.o : amac.c
	${CC} ${CFLAGS} -c amac.c -o ${ST}amac.o

${ST}debug.o : debug.c
	${CC} ${CFLAGS} -c debug.c -o ${ST}debug.o

${ST}amode.o : amode.c parmode.c amode.h kwtab.h mntab.h
	${CC} ${CFLAGS} -c amode.c -o ${ST}amode.o

${ST}token.o : token.c kwtab.h
	${CC} ${CFLAGS} -c token.c -o ${ST}token.o
kwtab.h : kwtab
	kwgen kw <kwtab >kwtab.h

${ST}symbol.o : symbol.c
	${CC} ${CFLAGS} -c symbol.c -o ${ST}symbol.o

${ST}mark.o : mark.c
	${CC} ${CFLAGS} -c mark.c -o ${ST}mark.o

${ST}object.o : object.c
	${CC} ${CFLAGS} -c object.c -o ${ST}object.o

${ST}mwobj.o : mwobj.c
	${CC} ${CFLAGS} -c mwobj.c -o ${ST}mwobj.o

${ST}procln.o : procln.c mntab.h 6502.h
	${CC} ${CFLAGS} -c procln.c -o ${ST}procln.o
mntab.h : mntab 68kmn
	@echo "This may take a minute or so:"
	cat mntab 68kmn | kwgen mn >mntab.h
6502.h : 6502.tbl
	kwgen mp <6502.tbl >6502.h
68ktab.h 68kmn : 68ktab
	68kgen 68kmn <68ktab >68ktab.h

${ST}expr.o : expr.c
	${CC} ${CFLAGS} -c expr.c -o ${ST}expr.o

${ST}sect.o : sect.c
	${CC} ${CFLAGS} -c sect.c -o ${ST}sect.o

${ST}direct.o : direct.c
	${CC} ${CFLAGS} -c direct.c -o ${ST}direct.o

${ST}listing.o : listing.c
	${CC} ${CFLAGS} -c listing.c -o ${ST}listing.o

${ST}mach.o : mach.c 68ktab.h kwtab.h
	${CC} ${CFLAGS} -c mach.c -o ${ST}mach.o

${ST}macro.o : macro.c
	${CC} ${CFLAGS} -c macro.c -o ${ST}macro.o

${ST}eagen.o : eagen.c eagen0.c
	${CC} ${CFLAGS} -c eagen.c -o ${ST}eagen.o

${ST}amem.o : amem.c
	${CC} ${CFLAGS} -c amem.c -o ${ST}amem.o

${ST}error.o : error.c
	${CC} ${CFLAGS} -c error.c -o ${ST}error.o

${ST}fext.o : fext.c
	${CC} ${CFLAGS} -c fext.c -o ${ST}fext.o

${ST}st.o : st.c
	${CC} ${CFLAGS} -c st.c -o ${ST}st.o

${ST}6502.o : 6502.c
	${CC} ${CFLAGS} -c 6502.c -o ${ST}6502.o

${ST}qsort.o : qsort.c
	${CC} ${CFLAGS} -c qsort.c -o ${ST}qsort.o

${ST}time.o : time.c
	${CC} ${CFLAGS} -c time.c -o ${ST}time.o


#
#  Tools
#
kwgen : kwgen.c
	cc -o kwgen kwgen.c

68kgen : 68kgen.c
	cc -o 68kgen 68kgen.c

conv65.prg : st_conv65.o st_fext.o
	aln -w -o conv65.prg c680.o st_conv65.o st_fext.o ${CLIB}
st_conv65.o : conv65.c
	c68 -DST -c conv65.c -o st_conv65.o

#
#  Happenings
#
clean :
	rm ${ST}*.o mac.prg

listing :
	print ${HFILES} ${CFILES} ${MISC}

backup :
	cp Makefile 68ktab kwtab mntab *.h *.c Bak
