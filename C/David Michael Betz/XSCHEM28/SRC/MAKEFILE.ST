# makefile for Atari ST with gcc

CC = gcc
CFLAGS= -O -Datarist=1 -I.
LIBS = -lpml

OBJ1=xscheme.o xsdmem.o xsimage.o xsio.o xsobj.o xsprint.o xsread.o xssym.o \
xsfun1.o xsfun2.o xsmath.o ststuff.o

OBJ2=xsinit.o xscom.o xsint.o

xscheme:	$(OBJ1) $(OBJ2) xsftab.o
	$(CC) $(CFLAGS) -o xscheme.ttp $(OBJ1) $(OBJ2) xsftab.o $(LIBS)

$(OBJ1):	xscheme.h xsproto.h
$(OBJ2):	xscheme.h xsproto.h xsbcode.h
xsftab.o:	xscheme.h xsproto.h osdefs.h osptrs.h

clean:
	rm -f *.o xscheme.ttp
