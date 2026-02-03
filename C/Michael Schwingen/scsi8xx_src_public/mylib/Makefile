#
# Top level Makefile for MiNT-Gcc library
#

all: mylib

# GCC configuration info...

#PROCOPT := -m68000 -fno-defer-pop -fforce-addr
PROCOPT := -m68040 -fforce-addr
# Processor-specific options and optimizations. 
# Default processor, Motorola 68000 without floating point coproc.
# Some versions of GCC break m68000 code unless -fno-defer-pop
# is set.

# Set up to run native...

AR	:= ar
AS	:= gcc 
CC	:= gcc -pipe
#LIB	:= /usr/lib/m68000 
LIB	:= /usr/local/lib/new/
INCLUDE_DIR := ../include
CP	:= mv

# Flags for extra 'long long' support under newer gcc's
#LONGLONG=-DPRINTF_LONGLONG

# Flags for extra 'long double' support under newer gcc's
#XFLOAT=-DXFLOAT_ENABLE

# Additional options for compiling C code

#XFLAGS := -nostdinc -I../include

# Dynamic selection of options for each target library...

ifneq (,$(findstring debug,$(TARGET)))
OPTIM= -O -g -Wstrict-prototypes
FRAME=
DEBUG=
g=g
else
OPTIM= -O2 
FRAME= -fomit-frame-pointer
DEBUG= -DNDEBUG
g=
endif

ifneq (,$(findstring long-int,$(TARGET)))
SHORT=
DSHORT=
ST=
else
SHORT= -mshort
DSHORT= -DSHORTLIB
ST=16
endif

ifneq (,$(findstring 68020,$(TARGET)))
PROCOPT := -m68020-40 -m68881 -fno-force-mem
LIB := /usr/lib/m68020
CC := $(CC) 
endif

ifneq (,$(findstring baserel,$(TARGET)))
CC := $(CC) -mbaserel
b=b
else
b=
endif

ifneq (,$(findstring sfp004,$(TARGET)))
SFPFLAG = -Dsfp004
SFP=sfp
else
SFPFLAG=
SFP=
endif

# common subset of options; no int size or omit-frame-pointer:
COPTS= $(DEBUG) $(OPTIM) $(XFLAGS) $(SFPFLAG) $(PROCOPT)

# Base options CC; includes int size but not omit-frame-pointer
CFFLAGS = $(SHORT) $(COPTS)

# normal CFLAGS including int size and omit-frame-pointer
CFLAGS= $(CFFLAGS) $(FRAME) $(LONGLONG) -D__NO_FLOAT__

# cflags for stuff that needs to be compiled with 32 bit ints
CLFLAGS= $(COPTS) $(FRAME) $(DSHORT) $(XFLOAT) $(XLFLAGS)

# flags to $(CC) when it runs the assembler only
ASFLAGS= -c

# flags to $(CC) when running preprocessor and assembler
PPFLAGS= $(XPFLAGS) $(SHORT) $(SFPFLAG) -P -c

CLIB= $bgnu$g$(SFP)$(ST).olb
CLIB020=$bgnu$g$(SFP)$(ST)020.olb
IIOLIB= $biio$g$(SFP)$(ST).olb
CRT0=$bcrt0.o
GCRT0=$bgcrt0.o

STARTO= $(CRT0) $(GCRT0)

# the stuff to make
ALL= $(CLIB) $(IIOLIB) $(STARTO)
ALL020 = $(CLIB020) $(STARTO)

#all: lshort llong lgshort lglong
top: lshort llong lbshort lblong
top020: l020short l020long l020bshort l020blong

%.target:
	$(MAKE) clean
	-rm -f *.target
	-touch $@

lshort: lshort.target
	$(MAKE) install

llong: llong.target
	$(MAKE) install TARGET="long-int"

lgshort: lgshort.target
	$(MAKE) install TARGET=debug

lglong: lglong.target
	$(MAKE) install TARGET="long-int debug"

l020short: l020short.target
	$(MAKE) install020 TARGET=68020
#	$(MAKE) install TARGET=68020

l020long: l020long.target
	$(MAKE) install020 TARGET="68020 long-int"
#	$(MAKE) install TARGET="68020 long-int"

lbshort: lbshort.target
	$(MAKE) install TARGET="baserel"

lblong: lblong.target
	$(MAKE) install TARGET="long-int baserel"

l020bshort: l020bshort.target
	$(MAKE) install020 TARGET="68020 baserel"

l020blong: l020blong.target
	$(MAKE) install020 TARGET="68020 long-int baserel"

lsfpshort: lsfpshort.target
	$(MAKE) install TARGET="sfp004"

lsfplong: lsfplong.target
	$(MAKE) install TARGET="long-int sfp004"

lbsfpshort: lbsfpshort.target
	$(MAKE) install TARGET="baserel sfp004"

lbsfplong: lbsfplong.target
	$(MAKE) install TARGET="long-int baserel sfp004"

bakclean:
	rm -f *~ *#
	rm -f */*~ */*#
	rm -f *.orig *.rej
	rm -f */*.orig */*.rej
	rm -f $(INCLUDE_DIR)/*~ $(INCLUDE_DIR)/*#
	rm -f $(INCLUDE_DIR)/*/*~ $(INCLUDE_DIR)/*/*#
	rm -f $(INCLUDE_DIR)/*.orig $(INCLUDE_DIR)/*.rej
	rm -f $(INCLUDE_DIR)/*/*.orig $(INCLUDE_DIR)/*/*.rej

realclean: bakclean
	rm -f *.o *.olb *.tmp
	rm -f core report nohup.out
	rm -f foo bar baz
	rm -f *.target

distclean: realclean
	rm -f diffc diffh

# Get the rules to build everything...

#
# GCC specific stuff
FCOMPD = _eqdf2.o _gtdf2.o _ledf2.o _gedf2.o _ltdf2.o
FCOMPS = _eqsf2.o _gtsf2.o _lesf2.o _gesf2.o _ltsf2.o

GLIB1 = _addsubd.o _addsubs.o _divdf3.o _divmods.o \
	_divsf3.o _extends.o _fixdfsi.o _fxunsd.o _fltsi.o \
	_muldf3.o _mulsf3.o _mulsi3.o _negdf2.o _negsf2.o _normdf.o _normsf.o \
	_truncdf.o _udivmod.o _umulsi3.o _fixsfsi.o _fltsisf.o _isnan.o

GLIB2 = _muldi3.o _divdi3.o _moddi3.o _udivdi3.o _umoddi3.o _negdi2.o \
	_lshrdi3.o _lshldi3.o _ashldi3.o _ashrdi3.o _udivmoddi4.o _cmpdi2.o \
	_ucmpdi2.o _floatdidf.o _floatdisf.o _fixunsdfsi.o _fixunssfsi.o \
	_fixunsdfdi.o _fixdfdi.o _fixunssfdi.o _fixsfdi.o _op_new.o \
	_new_handler.o _op_delete.o _trampoline.o __main.o _ctor_list.o \
	_dtor_list.o _ffsdi2.o _op_vnew.o _op_vdel.o _eh.o _pure.o

GCC= 	crtinit.o stksiz.o inistack.o heapbase.o binmode.o \
	$(GLIB1) $(GLIB2) $(FCOMPD) $(FCOMPS) \
	ldexp.o frexp.o modf.o alloca.o setjmp.o osbind.o\
	linea.o  alglobal.o thread.o sysvar.o gmon.o \
	initsig.o bblink.o defmode.o

#
# ANSI stuff + support
ANSI =  abort.o atexit.o atof.o atoi.o atol.o \
	bsearch.o \
	calloc.o clock.o ctime.o ctype.o \
	difftime.o div.o doprnt.o \
	eprintf.o \
	fclose.o fdopen.o fflush.o fgetc.o fgetpos.o fgets.o filbuf.o \
	fopen.o fopen_i.o fprintf.o fputc.o fputs.o \
	fread.o freopen.o fscanf.o fseek.o ftell.o \
	fsetpos.o fungetc.o fwrite.o getcooki.o\
	getbuf.o getenv.o gets.o getw.o \
	ldiv.o localtim.o ltoa.o \
	main.o malloc.o \
	printf.o puts.o \
	qsort.o \
	raise.o rand.o realloc.o rewind.o \
	scanf.o sscanf.o setbuf.o setvbuf.o \
	setlocal.o sprintf.o strftime.o strtol.o strtoul.o system.o \
	tmpnam.o tmpfile.o toxxx.o \
	vfprintf.o vfscanf.o vprintf.o vscanf.o \
	wcmb.o wcscat.o wcscmp.o wcscpy.o wcslen.o wnull.o

#
# other miscellaneous stuff
PORT =  a64l.o alphasor.o abs.o buffindf.o ctermid.o cuserid.o \
	enoent.o \
	ffs.o findfile.o fopenp.o frwbin.o ftw.o \
	gethostn.o getlogin.o getopt.o getpages.o getpass.o getpw.o grp.o \
	l64a.o labs.o \
	mktemp.o nlist.o obstack.o \
	random.o regexp.o regsup.o \
	scandir.o strlwr.o strupr.o strrev.o sync.o \
	textio.o truncate.o \
	utmp.o wtmp.o \
	ic.o ig.o il.o ip.o iw.o ident.o

#
# the string library

STRING = strcat.o strchr.o strcmp.o strcpy.o strcspn.o strdup.o \
	strlen.o strncat.o strncmp.o strncpy.o strpbrk.o strrchr.o strspn.o \
	strtok.o strstr.o memccpy.o memcmp.o memchr.o memset.o \
	bcopy.o bcmp.o bzero.o strerror.o strcoll.o \
	stricmp.o strnicmp.o

#
# stuff to fake unix system calls 

UNIX=   access.o alarm.o \
	console.o chdir.o chmod.o chown.o close.o closedir.o \
	do_lock.o do_stat.o dup.o dup2.o \
	execl.o execle.o execp.o execv.o execve.o \
	fcntl.o flock.o fork.o fstat.o \
	getcwd.o getdtabl.o getegid.o geteuid.o getgid.o getgroup.o \
	getitimer.o getloadavg.o getpid.o getppid.o \
	getuid.o getrusag.o getwd.o \
	initgroups.o inode.o ioctl.o isatty.o isctty.o \
	kill.o killpg.o link.o lockf.o lseek.o lstat.o \
	mkfifo.o mkdir.o mknod.o \
	nice.o open.o opendir.o \
	pause.o pipe.o perror.o pgrp.o popen.o psignal.o putenv.o \
	read.o readdir.o rewinddi.o rename.o rmdir.o \
	sbrk.o seekdir.o select.o \
	setegid.o seteuid.o setgid.o \
	setitimer.o setregid.o setreuid.o setuid.o \
	sgtty.o sigactio.o \
	sigblock.o siglist.o signal.o sleep.o spawn.o spawnve.o spawnvp.o \
	setrlimi.o stat.o statfs.o stime.o symlink.o sysconf.o \
	telldir.o time.o times.o timeoday.o ttyname.o \
	uidgid.o uname.o unlink.o unx2dos.o utime.o \
	vfork.o \
	wait.o wait3.o wait4.o waitpid.o write.o

#
# termios stuff

TERMIOS=	cfgetisp.o cfgetosp.o cfsetisp.o cfsetosp.o \
		tcattr.o tcbreak.o tcdrain.o \
		tcflow.o tcflush.o tcpgrp.o

#
# stuff for integer only scan/printf

IIOBJ = idoprnt.o iscanf.o fprintf.o sprintf.o fscanf.o sscanf.o

#all: $(ALL)
all020: $(ALL020)

$(CLIB): $(GCC) $(UNIX) $(STRING) $(ANSI) $(PORT) $(TERMIOS)
	$(AR) rs $(CLIB) $(GCC) $(UNIX) $(STRING) $(ANSI) $(PORT) $(TERMIOS)

$(IIOLIB): $(IIOBJ)
	$(AR) rs $(IIOLIB) $(IIOBJ)

$(CLIB020): $(GCC) $(UNIX) $(STRING) $(ANSI) $(PORT) $(TERMIOS)
	$(AR) rs $(CLIB020) $(GCC) $(UNIX) $(STRING) $(ANSI) $(PORT) $(TERMIOS)

#
# gmon.o CANNOT have -fomit-frame-pointer
gmon.o: gmon.c
	$(CC) $(CFFLAGS) -c $<

#
# Assembler stuff that needs to be preprocessed
#
.SUFFIXES: .cpp

$(FCOMPD): %.o: _cmpdf2.cpp
	$(CC) $(PPFLAGS) -DL$* -x assembler-with-cpp -c $< -o $@

$(FCOMPS): %.o: _cmpsf2.cpp
	$(CC) $(PPFLAGS) -DL$* -x assembler-with-cpp -c $< -o $@

.cpp.o:
	$(CC) $(PPFLAGS) -x assembler-with-cpp -c $< -o $@
#	$(CC) $(PPFLAGS) -E -x assembler-with-cpp -c $< -o temp.s   
#	crlf -s temp.s 
#	$(CC) -c temp.s -o $@

setjmp.o : setjmp.cpp
div.o : div.cpp
_addsubd.o: _addsubd.cpp
_addsubs.o: _addsubs.cpp
_divdf3.o: _divdf3.cpp
_divsf3.o: _divsf3.cpp
_extends.o: _extends.cpp
_fixdfsi.o: _fixdfsi.cpp
_fltsi.o: _fltsi.cpp
_fxunsd.o: _fxunsd.cpp
_muldf3.o: _muldf3.cpp
_mulsf3.o: _mulsf3.cpp
_normdf.o: _normdf.cpp
_normsf.o: _normsf.cpp
_truncdf.o: _truncdf.cpp
_fixsfsi.o: _fixsfsi.cpp
_fltsisf.o: _fltsisf.cpp
frexp.o: frexp.cpp
ldexp.o: ldexp.cpp
modf.o: modf.cpp
vfork.o : vfork.cpp
osbind.o : osbind.cpp
alloca.o: alloca.cpp
bcopy.o: bcopy.cpp

bzero.o: %.o: bzero.cpp
	$(CC) $(PPFLAGS) -DL$* -x assembler-with-cpp -c $< -o $@

memset.o: %.o: bzero.cpp
	$(CC) $(PPFLAGS) -DL$* -x assembler-with-cpp -c $< -o $@

#
# integer only io stuff
idoprnt.o: doprnt.c
	$(CC) $(CFLAGS) -D__NO_FLOAT__ -c $< -o idoprnt.o

iscanf.o: scanf.c
	$(CC) $(CFLAGS) -D__NO_FLOAT__ -c $< -o iscanf.o

#
# gcrt0 and crt0
#

$(GCRT0): crt0.cpp
	$(CC) $(PPFLAGS) -DGCRT0 -x assembler-with-cpp -c $< -o $@

$(CRT0): crt0.cpp
	$(CC) $(PPFLAGS) -x assembler-with-cpp -c $< -o $@

# other dependencies
atof.o  : flonum.h

#
# libgcc2 stuff (works for both -mshort and -mnoshort)

$(GLIB2): %.o: libgcc2.c longlong.h
	$(CC) $(CLFLAGS) -DL$* -c $< -o $@

.PHONY:	install install020 clean realclean all all020 top

install: $(ALL)
	$(CP) $(ALL) $(LIB)

install020: $(ALL020)
	$(CP) $(ALL020) $(LIB)

__clean:
	rm -f $(GCC)
	rm -f $(UNIX)
	rm -f $(STRING)
	rm -f $(ANSI)
	rm -f $(PORT)
	rm -f $(TERMIOS)
	rm -f $(IIOBJ)


mylib: crtinit.o sprintf.o bzero.o doprnt.o memchr.o ctype.o toxxx.o bcopy.o $(GLIB2)
	$(AR) rs libmylib16.a $^
	
