TARGET = ../lib/m68020-60/mshort/libslb.a
AR= ar rs
RM= rm -f
CC= gcc
CFLAGS= -Wall -Os -m68020-60 -fomit-frame-pointer -mshort $(DEFS) \
	-I../include
DEFS=
OBJS= libslb.o

all: $(TARGET)

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
