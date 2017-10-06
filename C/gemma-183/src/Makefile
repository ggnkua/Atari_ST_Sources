include ../config

TARGET= ../gemma.slb
CC= gcc
LD= gcc
RM= rm -f
DEFS= 
MODEL= $(TARGETCPU) -mshort -fomit-frame-pointer
CFLAGS=	-Wall -O2 $(MODEL) $(DEFS) -I../include/
LDFLAGS= -s -nostartfiles $(MODEL)
LIBS= -lgcc
OBJ=	header.o \
	alert.o appl.o av.o dialog.o env.o fselect.o gemma.o \
	misc.o proc.o rsrc.o emu.o callout.o dosproto.o \
	gemproto.o sflags.o ctrl_list.o version.o

all:	$(TARGET)

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

header.o: header.s
	$(CC) $(CFLAGS) -c header.s -o $@

clean:
	$(RM) *.o

veryclean:
	$(RM) *.o $(TARGET)

install:
	cp $(TARGET) $(SLBPATH)
	chmod 755 $(SLBPATH)/$(TARGET)
