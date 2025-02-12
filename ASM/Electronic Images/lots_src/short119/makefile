BUGFIX_RELEASE=19

.SUFFIXES: .c .o
BOBJS = mkbshift.o
COBJS = exit.o array.o ulaw.o
SOBJS = main.o shorten.o fixio.o vario.o poly.o lpc.o hsgetopt.o dupfinfo.o
CC    = gcc
DEFS  = -DBUGFIX_RELEASE=\"${BUGFIX_RELEASE}\"
CFLAGS= -O2

prefix = /usr/local
manext = 1

.c:	; $(CC) $(CFLAGS) $(DEFS) -o $* $*.c
.c.o:	; $(CC) $(CFLAGS) $(DEFS) -c $*.c

all: shorten shorten.man

install: shorten
	cp shorten $(prefix)/bin
	cp shorten.1 $(prefix)/man/man$(manext)/shorten.$(manext)

shorten: bitshift.h $(COBJS) $(SOBJS)
	$(CC) $(CFLAGS) $(DEFS) -o shorten $(COBJS) $(SOBJS) -lm
	sh -c "if [ $$TERM = ibmpc ] ; then strip shorten ; coff2exe -s /djgpp/bin/go32.exe shorten; fi"

bitshift.h: mkbshift
	mkbshift

mkbshift: $(COBJS) $(BOBJS)
	$(CC) $(CFLAGS) $(DEFS) -o mkbshift $(COBJS) $(BOBJS) -lm
	sh -c "if [ $$TERM = ibmpc ] ; then coff2exe mkbshift ; fi"

shorten.man: shorten.1
	nroff -man shorten.1 | col -b > shorten.man

test: shorten
	./shorten -x mvs_s16.shn tmp.s16
	if [ `wc -lc tmp.s16 | sed 's/ //g'` != "17032596tmp.s16" ]; then exit 1; fi
	shntest

release: test spotless shorten.man
	mkrelease ${BUGFIX_RELEASE}

clean:
	rm -f $(COBJS) $(BOBJS) $(SOBJS)

spotless: clean
	rm -f shorten mkbshift mkbshift.exe bitshift.h shorten.man tmp.s16 *~
