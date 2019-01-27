
CFLAGS  =  -Wall -O2 -fomit-frame-pointer
LDFLAGS = -s
LDLIBS  = -lldg -lpolarssl -lgem -lz

TARGET = polarssl.ldg

# list header files here
HEADER =

# list C files here
COBJS = main.c timing_alt.c

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
STACK = $(CROSSPREFIX)stack

OBJS = $(COBJS:.c=.o)

all: $(TARGET)
	$(STRIP) $(TARGET)
	$(STACK) -S 128k $(TARGET)
	rm -f *.o
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
	#$(CC) $(CFLAGS) -m68000 -c $*.c -o $*.o
	#$(CC) $(CFLAGS) -m68020-60 -c $*.c -o $*.o
	$(CC) $(CFLAGS) -mcpu=5475 -c $*.c -o $*.o

$(TARGET): $(OBJS)
	#$(CC) $(OBJS) $(CFLAGS) -m68000 $(LDLIBS) -o $(TARGET)
	#$(CC) $(OBJS) $(CFLAGS) -m68020-60 $(LDLIBS) -o $(TARGET)
	$(CC) $(OBJS) $(CFLAGS) -mcpu=5475 $(LDLIBS) -o $(TARGET)

