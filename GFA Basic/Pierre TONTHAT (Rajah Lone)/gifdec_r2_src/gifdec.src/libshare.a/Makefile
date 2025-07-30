#  makefile for libshare:
#  libshare is a dirty patch to make LDG compiled against mintlib shareable
#  by Arnaud BERCEGEAY (Feb 2004)

# raj: add 020 and ColdFire targets

CROSSPREFIX=/opt/cross-mint/bin/m68k-atari-mint-
PATH = /opt/cross-mint/m68k-atari-mint/bin:/opt/cross-mint/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
LD_LIBRARY_PATH=/opt/cross-mint/lib:/opt/cross-mint/m68k-atari-mint/lib:$LD_LIBRARY_PATH
DESTDIR=/opt/cross-mint/m68k-atari-mint

CC = $(CROSSPREFIX)gcc
AS = $(CC)
AR = $(CROSSPREFIX)ar
RANLIB = $(CROSSPREFIX)ranlib
STRIP = $(CROSSPREFIX)strip
FLAGS = $(CROSSPREFIX)flags

CFLAGS = -Wall -Wno-unused-result
OFLAGS = -O2 -fomit-frame-pointer

SRCS = libshare.c gl_shm.c calloc.c chdir.c malloc.c realloc.c sbrk.c
HDRS = libshare.h lib.h
OBJS = $(SRCS:.c=.o)

libshare.a:
	cp -r $(HDRS) $(DESTDIR)/include
	$(CC) $(CFLAGS) -m68000 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libshare.a $(DESTDIR)/lib/libshare.a
	rm -f *.o libshare.a
	$(CC) $(CFLAGS) -m68020-60 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libshare.a $(DESTDIR)/lib/m68020-60/libshare.a
	rm -f *.o libshare.a
	$(CC) $(CFLAGS) -mcpu=5475 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libshare.a $(DESTDIR)/lib/m5475/libshare.a
	rm -f *.o libshare.a

clean:
	rm -f *.o libshare.a
