CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE

CMD	= sh
OBJ	= sh1.o sh2.o sh3.o sh4.o sh5.o sh6.o
HDR	= sh.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)
