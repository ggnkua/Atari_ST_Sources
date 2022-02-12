# Makefile for the libraries

# This makefile runs make in all the subdirectories of the src/lib tree.
# See ansi/Makefile for a further explanation.

MAKE	= exec make -$(MAKEFLAGS)

usage:
	@echo "Usage: make all" >&2	# Compile all library functions" >&2
	@echo "       make install	# Backup /usr/lib/*.a first!" >&2
	@echo "       make clean	# Delete .o and .a files" >&2
	@false

all:
	cd ansi && $(MAKE)
	cd curses && $(MAKE)
	cd dummy && $(MAKE)
	cd editline && $(MAKE)
	cd end && $(MAKE)
	cd float && $(MAKE)
	cd fphook && $(MAKE)
	cd ip && $(MAKE)
	cd libm2 && $(MAKE)
	cd libp && $(MAKE)
	cd liby && $(MAKE)
	cd math && $(MAKE)
	cd other && $(MAKE)
	cd posix && $(MAKE)
	test `arch` = i86 -o `arch` = m68000 || { cd regex && $(MAKE); }
	test `arch` = m68000 || { cd rts && $(MAKE); }
	cd stdio && $(MAKE)
	cd syscall && $(MAKE)
	cd syslib && $(MAKE)
	cd `arch` && $(MAKE)

install:	all
	$(MAKE) install_`arch`

# Installation rules for PC Minix.
LIB=	/usr/lib

install_i86:	\
	$(LIB)/ncrtso.o \
	$(LIB)/nm2rtso.o \
	$(LIB)/nprtso.o \
	$(LIB)/libc.a \
	$(LIB)/libd.a \
	$(LIB)/libe.a \
	$(LIB)/libfp.a \
	$(LIB)/libm.a \
	$(LIB)/libm2.a \
	$(LIB)/libp.a \
	$(LIB)/end.a \
	$(LIB)/libsys.a \
	$(LIB)/libcurses.a \
	$(LIB)/libedit.a \
	$(LIB)/liby.a \

$(LIB)/ncrtso.o:	ncrtso.o
	install -c -o bin $? $@

$(LIB)/nm2rtso.o:	nm2rtso.o
	install -c -o bin $? $@

$(LIB)/nprtso.o:	nprtso.o
	install -c -o bin $? $@

$(LIB)/libc.a:	libc.a
	install -c -o bin $? $@

$(LIB)/libd.a:	libd.a
	install -c -o bin $? $@

$(LIB)/libe.a:	libe.a
	install -c -o bin $? $@

$(LIB)/libfp.a:	libfp.a
	install -c -o bin $? $@

$(LIB)/libm.a:	libm.a
	install -c -o bin $? $@

$(LIB)/libm2.a:	libm2.a
	install -c -o bin $? $@

$(LIB)/libp.a:	libp.a
	install -c -o bin $? $@

$(LIB)/end.a:	end.a
	install -c -o bin $? $@

$(LIB)/libsys.a:	libsys.a
	install -c -o bin $? $@

$(LIB)/libcurses.a:	libcurses.a
	install -c -o bin $? $@

$(LIB)/libedit.a:	libedit.a
	install -c -o bin $? $@

$(LIB)/liby.a:	liby.a
	install -c -o bin $? $@

# Installation rules for Minix-386.
LIB386=	/usr/lib/i386
LIB86=	/usr/lib/i86

install_i386:	\
	$(LIB386)/crtso.o \
	$(LIB386)/m2rtso.o \
	$(LIB386)/prtso.o \
	$(LIB386)/libc.a \
	$(LIB386)/libd.a \
	$(LIB386)/libe.a \
	$(LIB386)/libfp.a \
	$(LIB386)/libm.a \
	$(LIB386)/libm2.a \
	$(LIB386)/libp.a \
	$(LIB386)/end.a \
	$(LIB386)/libsys.a \
	$(LIB386)/libcurses.a \
	$(LIB386)/libedit.a \
	$(LIB386)/liby.a \
#	$(LIB86)/libc.a \
#	$(LIB86)/end.a \

$(LIB386)/crtso.o:	crtso.o
	install -c -o bin $? $@

$(LIB386)/m2rtso.o:	m2rtso.o
	install -c -o bin $? $@

$(LIB386)/prtso.o:	prtso.o
	install -c -o bin $? $@

$(LIB386)/libc.a:	libc.a
	install -c -o bin $? $@

$(LIB386)/libd.a:	libd.a
	install -c -o bin $? $@

$(LIB386)/libe.a:	libe.a
	install -c -o bin $? $@

$(LIB386)/libfp.a:	libfp.a
	install -c -o bin $? $@

$(LIB386)/libm.a:	libm.a
	install -c -o bin $? $@

$(LIB386)/libm2.a:	libm2.a
	install -c -o bin $? $@

$(LIB386)/libp.a:	libp.a
	install -c -o bin $? $@

$(LIB386)/end.a:	end.a
	install -c -o bin $? $@

$(LIB386)/libsys.a:	libsys.a
	install -c -o bin $? $@

$(LIB386)/libcurses.a:	libcurses.a
	install -c -o bin $? $@

$(LIB386)/libedit.a:	libedit.a
	install -c -o bin $? $@

$(LIB386)/liby.a:	liby.a
	install -c -o bin $? $@

#$(LIB86)/libc.a:	libc86.a
#	install -c -o bin $? $@
#
#$(LIB86)/end.a:	end86.a
#	install -c -o bin $? $@

# Installation rules for Minix-ST.
LIB=	/usr/lib/m68000

install_m68000:	\
	$(LIB)/crtso.o \
	$(LIB)/cfrtso.o \
	$(LIB)/m2rtso.o \
	$(LIB)/m2frtso.o \
	$(LIB)/prtso.o \
	$(LIB)/pfrtso.o \
	$(LIB)/libc.a \
	$(LIB)/libd.a \
	$(LIB)/libe.a \
	$(LIB)/libfp.a \
	$(LIB)/libm.a \
	$(LIB)/libm2.a \
	$(LIB)/libp.a \
	$(LIB)/end.a \
	$(LIB)/libsys.a \
	$(LIB)/libcurses.a \
	$(LIB)/libedit.a \
	$(LIB)/liby.a \

$(LIB)/crtso.o:	crtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/cfrtso.o:	cfrtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/m2rtso.o:	m2rtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/m2frtso.o:	m2frtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/prtso.o:	prtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/pfrtso.o:	pfrtso.o
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libc.a:	libc.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libd.a:	libd.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libe.a:	libe.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libfp.a:	libfp.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libm.a:	libm.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libm2.a:	libm2.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libp.a:	libp.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/end.a:	end.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libsys.a:	libsys.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libcurses.a:	libcurses.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/libedit.a:	libedit.a
	install -c -o bin -g bin -m 644 $? $@

$(LIB)/liby.a:	liby.a
	install -c -o bin -g bin -m 644 $? $@


clean:
	find . -name '*.[oa]' -o -name '*.bak' | xargs rm
