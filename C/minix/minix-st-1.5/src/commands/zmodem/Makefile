CFLAGS	= -DV7 -O

CMD	= rz sz
OBJ	= rz.o sz.o
HDR	= rbsb.c zm.c zmodem.h crctab.c

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

rz:	rz.o
	$(CC) -o $@ $@.o

sz:	sz.o
	$(CC) -o $@ $@.o

$(OBJ):	$(HDR)
