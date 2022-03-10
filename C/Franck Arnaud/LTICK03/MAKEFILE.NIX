# LazyTick Makefile for Unix
# you need strftime, strlwr

CC=gcc
CFLAGS=-DUNIX -O

# libctext contains strftime and strlwr, which are needed and not in my libc
LDLIBS=-lcext

OBJS=tick.o misc.o config.o announce.o crc32.o

ltick: $(OBJS)
	$(CC) $(OBJS) $(LDLIBS) -o $@

misc.c: misc.h tick.h qbbs.h
config.c: misc.h config.h tick.h
tick.c: config.h misc.h tick.h announce.h crc32.h
announce.c: announce.h tick.h
crc32.c: crc32.h
