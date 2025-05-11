# .PRG, .TOS, .TTP ...

.SUFFIXES: $(SUFFIXES) .prg .tos .ttp

%.tos %.ttp %.prg: %.o
	$(LINK.o) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

%.tos %.ttp %.prg: %.cc
	$(LINK.cc) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

%.i: %.c
	$(CC) -E $(CFLAGS) $^ -o $*.i

#The ATARI ST department for GCC
CC = gcc
CCC = gcc
C++ = gcc
LINK = gcc
LINK.o = gcc
AR = gcc-ar
AS = gcc-as

MAKE=make

SHELL = e:/bin/shell.ttp
