CFLAGS	= -O

CMD	= stterm read_tty write_tty
OBJ	= do_shell.o err.o read_tty.o term.o write_tty.o
HDR	= const.h

all:	$(CMD)

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

stterm:	term.o err.o
	$(CC) -o stterm term.o err.o

write_tty:	write_tty.o do_shell.o
	$(CC) -o write_tty write_tty.o do_shell.o

read_tty:	read_tty.o
	$(CC) -o read_tty read_tty.o

$(OBJ):	$(HDR)
