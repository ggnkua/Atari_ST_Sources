CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE

CMD	= nroff
OBJ	= main.o command.o text.o io.o macros.o strings.o escape.o low.o
HDR	= config.h nroff.h version.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

$(CMD):	$(OBJ)
	$(CC) -o $@ $(OBJ)

$(OBJ):	$(HDR)
