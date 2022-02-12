# Makefile for ic

CFLAGS	= -O -D_POSIX_SOURCE -D_MINIX

all:	ic

OBJ   = ic.o ic_input.o ic_output.o 

ic:	$(OBJ)
	cc  $(OBJ) -i -o ic
	install -S 4kw ic

install:	/usr/bin/ic

/usr/bin/ic:	ic
	install -cs -o bin ic $@

$(ICOBJ): ic.h

clean:
	rm -f *.o ic *.bak core
