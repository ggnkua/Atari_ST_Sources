
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

CFLAGS = -Wall
OFLAGS = -O2 -fomit-frame-pointer

SRCS = dgif_lib.c egif_lib.c gifalloc.c gif_err.c gif_font.c gif_hash.c openbsd-reallocarray.c
HDRS = gif_hash.h gif_lib.h gif_lib_private.h
OBJS = $(SRCS:.c=.o)

libgif.a:
	cp -r $(HDRS) $(DESTDIR)/include
	$(CC) $(CFLAGS) -m68000 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libgif.a $(DESTDIR)/lib/libgif.a
	rm -f *.o libgif.a
	$(CC) $(CFLAGS) -m68020-60 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libgif.a $(DESTDIR)/lib/m68020-60/libgif.a
	rm -f *.o libgif.a
	$(CC) $(CFLAGS) -mcpu=5475 $(OFLAGS) -c $(SRCS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libgif.a $(DESTDIR)/lib/m5475/libgif.a
	rm -f *.o libgif.a

clean:
	rm -f *.o libgif.a
