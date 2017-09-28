
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

CFLAGS = -I./lib -I./include
OFLAGS = -Wall -O2 -fomit-frame-pointer

SRCS = tiniconv.c tiniconv_desc.c

OBJS = tiniconv.o tiniconv_desc.o

libtiniconv.a:
	cp -r tiniconv.h $(DESTDIR)/include
	$(CC) $(CFLAGS) -m68000 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libtiniconv.a $(DESTDIR)/lib/libtiniconv.a
	rm -f *.o libtiniconv.a
	$(CC) $(CFLAGS) -m68020-60 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libtiniconv.a $(DESTDIR)/lib/m68020-60/libtiniconv.a
	rm -f *.o libtiniconv.a
	$(CC) $(CFLAGS) -mcpu=5475 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libtiniconv.a $(DESTDIR)/lib/m5475/libtiniconv.a
	rm -f *.o libtiniconv.a

clean:
	rm -f *.o libtiniconv.a
