#
# Makefile
#
CFLAGS  = -Wall -O -fomit-frame-pointer -DATARI -DNO_GZIP -DPKZIP_BUG_WORKAROUND
LDFLAGS = -s
LDLIBS  = -lldg

TARGET = deflate.ldg

# list header files here
HEADER = adler32.c crc32.h deflate.h inffast.h inffixed.h inflate.h inftrees.h trees.h zconf.h zlib.h zutil.h

# list C files here
#
COBJS = adler32.c crc32.c deflate.c infback.c inffast.c inflate.c inftrees.c trees.c zutil.c main.c
#
# list assembler files here
SOBJS =

SRCFILES = $(HEADER) $(COBJS) $(SOBJS)

#############################
CROSSPREFIX=/opt/cross-mint/bin/m68k-atari-mint-
PREFIX=/opt/cross-mint
PATH = $(PREFIX)/m68k-atari-mint/bin:$(PREFIX)/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
LD_LIBRARY_PATH=$(PREFIX)/lib:$(PREFIX)/m68k-atari-mint/lib:$LD_LIBRARY_PATH

CC = $(CROSSPREFIX)gcc
AS = $(CC)
AR = $(CROSSPREFIX)ar
RANLIB = $(CROSSPREFIX)ranlib
STRIP = $(CROSSPREFIX)strip
FLAGS = $(CROSSPREFIX)flags

OBJS = $(COBJS:.c=.o)

all: $(TARGET)
	$(STRIP) $(TARGET)
	-@rm -f $(OBJS)
	@echo All done

clean:
	-@rm -f $(OBJS)
	-@rm -f $(TARGET)
	@echo Cleaned

new: clean
	-@rm -f $(TARGET)
	$(MAKE) all


.SUFFIXES:
.SUFFIXES: .c .S .o

.c.o:
	$(CC) $(CFLAGS) -m68000 -c $*.c -o $*.o
	#$(CC) $(CFLAGS) -m68020-60 -c $*.c -o $*.o
	#$(CC) $(CFLAGS) -mcpu=5475 -c $*.c -o $*.o

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -m68000 $(LDLIBS) -o $(TARGET)
	#$(CC) $(OBJS) -m68020-60 $(LDLIBS) -o $(TARGET)
	#$(CC) $(OBJS) -mcpu=5475 $(LDLIBS) -o $(TARGET)

