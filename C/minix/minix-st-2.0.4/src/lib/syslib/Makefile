# Makefile for lib/syslib.

CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE
CC1	= $(CC) $(CFLAGS) -c

LIBSYS	= ../libsys.a
all:	$(LIBSYS)

OBJECTS	= \
	$(LIBSYS)(kmalloc.o) \
	$(LIBSYS)(kprintf.o) \
	$(LIBSYS)(putk.o) \
	$(LIBSYS)(sys_abort.o) \
	$(LIBSYS)(sys_copy.o) \
	$(LIBSYS)(sys_endsig.o) \
	$(LIBSYS)(sys_exec.o) \
	$(LIBSYS)(sys_findproc.o) \
	$(LIBSYS)(sys_fork.o) \
	$(LIBSYS)(sys_fresh.o) \
	$(LIBSYS)(sys_getmap.o) \
	$(LIBSYS)(sys_getsp.o) \
	$(LIBSYS)(sys_kill.o) \
	$(LIBSYS)(sys_newmap.o) \
	$(LIBSYS)(sys_oldsig.o) \
	$(LIBSYS)(sys_sendsig.o) \
	$(LIBSYS)(sys_sigret.o) \
	$(LIBSYS)(sys_sysctl.o) \
	$(LIBSYS)(sys_times.o) \
	$(LIBSYS)(sys_trace.o) \
	$(LIBSYS)(sys_xit.o) \
	$(LIBSYS)(taskcall.o) \

$(LIBSYS):	$(OBJECTS)
	aal cr $@ *.o
	rm *.o

$(LIBSYS)(kmalloc.o):	kmalloc.c
	$(CC1) kmalloc.c

$(LIBSYS)(kprintf.o):	kprintf.c
	$(CC1) kprintf.c

$(LIBSYS)(putk.o):	putk.c
	$(CC1) putk.c

$(LIBSYS)(sys_abort.o):	sys_abort.c
	$(CC1) sys_abort.c

$(LIBSYS)(sys_copy.o):	sys_copy.c
	$(CC1) sys_copy.c

$(LIBSYS)(sys_endsig.o):	sys_endsig.c
	$(CC1) sys_endsig.c

$(LIBSYS)(sys_exec.o):	sys_exec.c
	$(CC1) sys_exec.c

$(LIBSYS)(sys_findproc.o):	sys_findproc.c
	$(CC1) sys_findproc.c

$(LIBSYS)(sys_fork.o):	sys_fork.c
	$(CC1) sys_fork.c

$(LIBSYS)(sys_fresh.o):	sys_fresh.c
	$(CC1) sys_fresh.c

$(LIBSYS)(sys_getmap.o):	sys_getmap.c
	$(CC1) sys_getmap.c

$(LIBSYS)(sys_getsp.o):	sys_getsp.c
	$(CC1) sys_getsp.c

$(LIBSYS)(sys_kill.o):	sys_kill.c
	$(CC1) sys_kill.c

$(LIBSYS)(sys_newmap.o):	sys_newmap.c
	$(CC1) sys_newmap.c

$(LIBSYS)(sys_oldsig.o):	sys_oldsig.c
	$(CC1) sys_oldsig.c

$(LIBSYS)(sys_sendsig.o):	sys_sendsig.c
	$(CC1) sys_sendsig.c

$(LIBSYS)(sys_sigret.o):	sys_sigret.c
	$(CC1) sys_sigret.c

$(LIBSYS)(sys_sysctl.o):	sys_sysctl.c
	$(CC1) sys_sysctl.c

$(LIBSYS)(sys_times.o):	sys_times.c
	$(CC1) sys_times.c

$(LIBSYS)(sys_trace.o):	sys_trace.c
	$(CC1) sys_trace.c

$(LIBSYS)(sys_xit.o):	sys_xit.c
	$(CC1) sys_xit.c

$(LIBSYS)(taskcall.o):	taskcall.c
	$(CC1) taskcall.c
