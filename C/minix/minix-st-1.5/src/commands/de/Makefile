CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE

CMD	= de
OBJ	= de.o de_stdin.o de_stdout.o de_diskio.o de_recover.o
HDR	= de.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ): $(HDR)
