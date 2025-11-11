# Makefile for gdbm.
#
# for System V, add "-DSYSV" to CFLAGS.  Also, if you need alloca(),
# add "-lPW" to LIBS.
#
# for BSD, nothing is required
#
# for gcc, uncomment the CC = gcc line.

CC = cgcc
CFLAGS = -O # -O -DSYSV
LDFLAGS =
LIBS = # -lPW
DBM = -ldbm
NDBM = -lc
LIBC = -lc
LINTFLAGS =


GDBM_CF = gdbmopen.c gdbmdelete.c gdbmfetch.c  gdbmstore.c gdbmclose.c \
	gdbmreorg.c gdbmseq.c \
	bucket.c falloc.c findkey.c global.c hash.c update.c version.c

HFILES = gdbmdefs.h extern.h gdbmerrno.h systems.h dbm.h ndbm.h gdbmconst.h


MSCFILES = COPYING ChangeLog Makefile README gdbm.proto conv2gdbm.c

TESTFILES = testdbm.c testndbm.c testgdbm.c


GDBM_OF = gdbmopen.o gdbmdelete.o gdbmfetch.o  gdbmstore.o gdbmclose.o \
	gdbmreorg.o gdbmseq.o \
	bucket.o falloc.o findkey.o global.o hash.o update.o version.o


LIBDIR = /usr/lib
INCLUDE = /usr/include

default: gdbm.olb
odefault:	
	@echo "\"make gdbm.olb\" to make the library"
	@echo "\"make testgdbm\" to make the gdbm test program"
	@echo "\"make allgdbm\" to make all of the above"
	@echo "\"make conv2gdbm\" to make the conversion program"
	@echo "\"make all\" to make all of the above"
	@echo "\"make install\" to install the library"
	@echo "\"make dist\" to make gdbm.tar.Z distribution file"

all:	allgdbm conv2gdbm 


allgdbm: gdbm.olb testgdbm 

gdbm.olb:	$(GDBM_OF) gdbm.h
	rm -f gdbm.olb
	car q gdbm.olb $(GDBM_OF)

gdbm.h:	gdbm.proto gdbmerrno.h
	cp gdbm.proto gdbm.h
	chmod +w gdbm.h
	grep _ gdbmerrno.h >> gdbm.h

install: gdbm.olb gdbm.h
	install -c -m 644 gdbm.olb $(LIBDIR)/libgdbm.olb
	if [ -f /usr/bin/ranlib -o -f /bin/ranlib ]; \
		then ranlib $(LIBDIR)/libgdbm.olb; fi
	install -c -m 644 gdbm.h $(INCLUDE)/gdbm.h

testgdbm: testgdbm.o gdbm.olb
	$(CC) $(CFLAGS) $(LDFLAGS) -o testgdbm testgdbm.o gdbm.olb $(LIBS)

conv2gdbm: conv2gdbm.o gdbm.olb
	$(CC) $(CFLAGS) $(LDFLAGS) -o conv2gdbm conv2gdbm.o $(DBM) $(LIBC) \
	gdbm.olb $(LIBS)

lintgdbm: 
	lint $(LFLAGS) $(DBM_CF) $(NDBM_CF) $(GDBM_CF) testgdbm.c

clean:
	rm -f $(GDBM_OF) gdbm.h gdbm.olb \
	testgdbm  testgdbm.o \
	conv2gdbm conv2gdbm.o

dist:
	OF=`sed -n 's/.*\([0-9][0-9]*\.[0-9][0-9]*\).*/gdbm-\1/p' version.c` \
	;mkdir $$OF   		  \
	;ln $(MSCFILES) $(DBM_CF) $(NDBM_CF) $(GDBM_CF) $(HFILES) \
	    $(TESTFILES)  $$OF	  \
	;tar cvohf $$OF.tar $$OF  \
	;compress $$OF.tar        \
	;rm -rf $$OF



# gdbm files
gdbmclose.o:	gdbmdefs.h 
gdbmdelete.o:	gdbmdefs.h gdbmerrno.h 
gdbmfetch.o:	gdbmdefs.h gdbmerrno.h 
gdbmopen.o:	gdbmdefs.h gdbmerrno.h 
gdbmreorg.o:	gdbmdefs.h gdbmerrno.h extern.h
gdbmseq.o:	gdbmdefs.h 
gdbmstore.o:	gdbmdefs.h gdbmerrno.h 

# gdbm support files
bucket.o:	gdbmdefs.h
falloc.o:	gdbmdefs.h
findkey.o:	gdbmdefs.h
global.o:	gdbmdefs.h gdbmerrno.h 
hash.o:		gdbmdefs.h
update.o:	gdbmdefs.h
version.o:
extern.h:
gdbmdefs.h:	gdbmconst.h systems.h
	touch gdbmdefs.h

# other programs
testgdbm.o:	gdbmdefs.h extern.h gdbmerrno.h systems.h
conv2gdbm.o:	gdbm.h
