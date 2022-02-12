CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE



$f.o:	$f.c
	$(CC) $(CFLAGS) -c $f.c

all:
	$(CC) $(CFLAGS) -c *.c


clean:
	rm -f *.o
