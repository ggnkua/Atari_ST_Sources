# Makefile for sh

CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE -m -wa
LDFLAGS	= -i

OBJ	= sh1.o sh2.o sh3.o sh4.o sh5.o sh6.o

all:	sh

sh:	$(OBJ)
	cc $(LDFLAGS) -o $@ $(OBJ)
	install -S 11kw sh

install:	/usr/bin/sh /bin/sh

/usr/bin/sh:	sh
	install -cs -o bin sh $@

/bin/sh:	/usr/bin/sh
	install -lcs /usr/bin/sh $@

$(OBJ):	sh.h

clean:
	rm -f sh *.o *.bak core
