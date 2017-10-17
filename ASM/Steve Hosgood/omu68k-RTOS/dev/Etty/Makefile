#	TTY Handler
CFLAGS = -c -OPS -DVIWINDOWS

ttyhand:tty.o ttyc.o acia.o 
	ld -x -r -o ttyhand tty.o ttyc.o  acia.o

tty.o: tty.c tty.h ../../include/param.h ../../include/inode.h\
	../../include/procs.h ../../include/excep.h ../../include/signal.h\
	../../include/dev.h ../../include/state.h
	cc $(CFLAGS) tty.c

ttyc.o: ttyc.c tty.h
	cc $(CFLAGS) ttyc.c

acia.o: acia.c tty.h acia.h ../../include/excep.h
	cc $(CFLAGS) acia.c

#Test software
test:	test.o tty.o ttyc.o acia.o  mc.o bytecp.o mcexcep.o excep.o
	ld -X -R 1000 -o test mc.o test.o tty.o ttyc.o acia.o mcexcep.o\
	bytecp.o excep.o /usr/lib/lib_KITS.a -lc

test.o: test.c
	cc -c test.c

