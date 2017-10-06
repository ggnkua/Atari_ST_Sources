CC = gcc
CFLAGS = -Wall -fomit-frame-pointer -D__MINT__ -mshort
LD = gcc
LDLIBS = -lmint16 -liio16
TARGETS = cleanret.ttp depcheck.ttp r2c.ttp r2c_raw.ttp

CFILES = cleanret.c depcheck.c r2c.c r2c_raw.c

RCSFILES = $(CFILES) makefile

all: $(TARGETS)

.SUFFIXES: .c .ttp

.c.ttp:
	$(LINK.c) -o $@ $< $(LDLIBS)

rcsci:
	ci -l $(RCSFILES)

clean:
	rm -f *.o

realclean:
	rm -f *.o $(TARGETS)


