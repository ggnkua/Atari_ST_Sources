# Makefile for lib/other.

# The bxxx(), and *index() functions are not used, because they have assembly
# equivalents.

#	_longjerr.o \

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= -I../.. $(XCFLAGS)

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

OBJECTS	= \
	_brk.o \
	_lstat.o \
	_readlink.o \
	_reboot.o \
	_seekdir.o \
	_symlink.o \
	asynchio.o \
	crypt.o \
	ctermid.o \
	cuserid.o \
	environ.o \
	errno.o \
	execlp.o \
	fdopen.o \
	ffs.o \
	fslib.o \
	fsversion.o \
	getgrent.o \
	getlogin.o \
	getopt.o \
	getpass.o \
	getpwent.o \
	getttyent.o \
	getw.o \
	hypot.o \
	itoa.o \
	loadname.o \
	lock.o \
	lrand.o \
	lsearch.o \
	memccpy.o \
	mtab.o \
	nlist.o \
	peekpoke.o \
	popen.o \
	printk.o \
	putenv.o \
	putw.o \
	regexp.o \
	regsub.o \
	stderr.o \
	swab.o \
	syscall.o \
	sysconf.o \
	telldir.o \
	termcap.o \
	ttyname.o \
	ttyslot.o \
	bzero.o \
	bcmp.o \
	bcopy.o \
	index.o \
	rindex.o

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	$(RM) *.o
