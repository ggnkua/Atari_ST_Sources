CC = m68k-atari-mintelf-gcc
CFLAGS += -Wall -g

PROGS = icecat freeze melt
ICELIB = libice.a
ICELIB_OBJS = ice_info.o ice_crunch.o ice_decrunch.o

all: $(PROGS)

icecat: icecat.o $(ICELIB)
	$(CC) -o icecat icecat.o $(ICELIB)

freeze: freeze.o $(ICELIB)
	$(CC) -o freeze freeze.o $(ICELIB)

melt: melt.o $(ICELIB)
	$(CC) -o melt melt.o $(ICELIB)

$(ICELIB): $(ICELIB_OBJS)
	rm -f $(ICELIB)
	m68k-atari-mintelf-ar cr $(ICELIB) $(ICELIB_OBJS)
	m68k-atari-mintelf-ranlib $(ICELIB)

clean:
	rm -f $(PROGS) $(ICELIB) $(ICELIB_OBJS) icecat.o freeze.o melt.o

check: $(PROGS)
	cd testcases; ./check
