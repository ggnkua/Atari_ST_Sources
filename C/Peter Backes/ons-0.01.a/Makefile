# The top level Makefile

DISTRIB = ons

CC = gcc

CFLAGS = -g3 -O2 -Wall
LFLAGS = -L.

# Precious targets
PRECIOUS = version.h
TARGETS = libsky.a gfalist

SKY_ARC = libsky.a(sky.o) libsky.a(tables.o)
SKY_OBJS = sky.o tables.o

GFALIST_OBJS = gfalist.o charset.o

OBJS = $(SKY_OBJS) $(GFALIST_OBJS)

GB36_GEN = default2.out default4.out hell.out default.out default3.out \
	default5.out sky.out

GEN = $(GB36_GEN)

TRASH = core ons.spec.OLD

all: $(PRECIOUS) $(TARGETS)

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

version.h: HISTORY verextr.sh $(SKY_OBJS)
	sh verextr.sh -g $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TRASH) $(GEN)

realclean: clean
	rm -f $(TARGETS)

clobber: realclean
	rm -f $(PRECIOUS)

dist: MANIFEST HISTORY packdist.sh
	sh packdist.sh -t $(DISTRIB) -m $< -v HISTORY,version.h -s ons.spec ck md

rpms: dist
	sh packdist.sh -t $(DISTRIB) -v HISTORY,version.h mr

ons.spec: README HISTORY packdist.sh
	sh packdist.sh -a README -v HISTORY,version.h -t $(DISTRIB) -s ons.spec fs

test: $(GEN)
	@for i in $(GEN); do ls -l $$i; done

%.out: gb36test.a gfalist
	ar xvo $< $*.gfa $*.lst
	gfalist -b -o $*.tmp $*.gfa
	diff $*.lst $*.tmp > $@ || true
	rm $*.gfa $*.lst $*.tmp

#DEPEND
gfalist: libsky.a
sky.o: sky.c sky.h tables.h
gfalist.o: gfalist.c charset.h sky.h tables.h version.h

