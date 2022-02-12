# Makefile for lib/syslib.

CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= ../libc.a
all:	$(LIBRARY)

OBJECTS	= \
	$(LIBRARY)(sys_abort.o) \
	$(LIBRARY)(sys_copy.o) \
	$(LIBRARY)(sys_endsig.o) \
	$(LIBRARY)(sys_exec.o) \
	$(LIBRARY)(sys_fork.o) \
	$(LIBRARY)(sys_fresh.o) \
	$(LIBRARY)(sys_getmap.o) \
	$(LIBRARY)(sys_getsp.o) \
	$(LIBRARY)(sys_kill.o) \
	$(LIBRARY)(sys_newmap.o) \
	$(LIBRARY)(sys_oldsig.o) \
	$(LIBRARY)(sys_sendsig.o) \
	$(LIBRARY)(sys_sigret.o) \
	$(LIBRARY)(sys_times.o) \
	$(LIBRARY)(sys_trace.o) \
	$(LIBRARY)(sys_xit.o) \
	$(LIBRARY)(taskcall.o) \

$(LIBRARY):	$(OBJECTS)
	aal cr $@ *.o
	rm *.o

$(LIBRARY)(sys_abort.o):	sys_abort.c
	$(CC1) sys_abort.c

$(LIBRARY)(sys_copy.o):	sys_copy.c
	$(CC1) sys_copy.c

$(LIBRARY)(sys_endsig.o):	sys_endsig.c
	$(CC1) sys_endsig.c

$(LIBRARY)(sys_exec.o):	sys_exec.c
	$(CC1) sys_exec.c

$(LIBRARY)(sys_fork.o):	sys_fork.c
	$(CC1) sys_fork.c

$(LIBRARY)(sys_fresh.o):	sys_fresh.c
	$(CC1) sys_fresh.c

$(LIBRARY)(sys_getmap.o):	sys_getmap.c
	$(CC1) sys_getmap.c

$(LIBRARY)(sys_getsp.o):	sys_getsp.c
	$(CC1) sys_getsp.c

$(LIBRARY)(sys_kill.o):	sys_kill.c
	$(CC1) sys_kill.c

$(LIBRARY)(sys_newmap.o):	sys_newmap.c
	$(CC1) sys_newmap.c

$(LIBRARY)(sys_oldsig.o):	sys_oldsig.c
	$(CC1) sys_oldsig.c

$(LIBRARY)(sys_sendsig.o):	sys_sendsig.c
	$(CC1) sys_sendsig.c

$(LIBRARY)(sys_sigret.o):	sys_sigret.c
	$(CC1) sys_sigret.c

$(LIBRARY)(sys_times.o):	sys_times.c
	$(CC1) sys_times.c

$(LIBRARY)(sys_trace.o):	sys_trace.c
	$(CC1) sys_trace.c

$(LIBRARY)(sys_xit.o):	sys_xit.c
	$(CC1) sys_xit.c

$(LIBRARY)(taskcall.o):	taskcall.c
	$(CC1) taskcall.c
