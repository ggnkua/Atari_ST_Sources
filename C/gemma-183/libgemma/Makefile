#

include objects

CC= gcc
CFLAGS= -Wall -O2 -m68020-60 -fomit-frame-pointer -mshort $(DEFS) \
	-I../include
DEFS=
TARGET = ../lib/m68020-60/mshort/libgemma.a
AR= ar rs
RM= rm -f

all: $(TARGET)

startup.o: startup.s
	$(CC) $(CFLAGS) -c startup.s -o $@
	$(RM) startup.s

startup.s: startup.spp
	asmtrans -gas $(DEFS) -o $@ startup.spp

$(TARGET): $(OBJS)
	$(RM) $@
	$(AR) $@ $(OBJS)

install:
	mv $(TARGET) /usr/lib/m68020-60/mshort/

clean:
	$(RM) $(OBJS)

veryclean:
	$(RM) $(OBJS) $(TARGET)
	@make -f Makefile.000 veryclean
