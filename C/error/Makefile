TARGET= error.slb
CC= gcc
LD= gcc
RM= rm -f
DEFS= -fomit-frame-pointer
MODEL= -m68000 -mshort
CFLAGS=	-Wall -O2 $(MODEL) $(DEFS) -I../include/
LDFLAGS= -s -nostartfiles $(MODEL)
LIBS= -lgcc
OBJ=	header.o error.o

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
