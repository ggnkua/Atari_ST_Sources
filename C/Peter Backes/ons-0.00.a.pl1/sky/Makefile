CFLAGS = -g3 -O2 -Wall
LFLAGS = -L.

CC = gcc

# Precious targets
PRETARGETS = version.h
TARGETS = libsky.a gfalist

SKY_ARC = libsky.a(sky.o) libsky.a(tables.o)
SKY_OBJS = sky.o tables.o

GFALIST_OBJS = gfalist.o charset.o

OBJS = $(SKY_OBJS) $(GFALIST_OBJS)

all: $(PRETARGETS) $(TARGETS)

libsky.a: $(SKY_OBJS)
	$(AR) rcv $@ $?
	ranlib $@

# Updating on a per file basis: 
#libsky.a: $(SKY_ARCH) $(SKY_OBJS)
#	ranlib $@
#(%.o): %.o
#	$(AR) rcv $@ $<

# Updating with intermediate files:
#libsky.a: $(SKY_ARCH)
#	ranlib $@
#(%.o): %.c
#	$(CC) $(CFLAGS) -c $< -o $*.o
#	$(AR) rcv $@ $*.o
#	rm $*.o

gfalist: $(GFALIST_OBJS)
	$(CC) $(LFLAGS) $+ -o $@ -lsky

version.h: HISTORY ../HISTORY ../verextr.sh $(SKY_OBJS)
	sh ../verextr.sh -g -j ../HISTORY $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) core

realclean: clean
	for i in $(PRETARGETS); do mv $$i /tmp/$$i.OLD; done
	rm -f $(TARGETS)

unclean:
	for i in $(PRETARGETS); do mv /tmp/$$i.OLD $$i; done

#DEPEND
gfalist: libsky.a
sky.o: sky.c sky.h tables.h
gfalist.o: gfalist.c charset.h sky.h tables.h version.h

