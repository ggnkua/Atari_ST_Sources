# Makefile for lib/syslib.

base = ..
include $(base)/makeconfig
include $(base)/$(mk)/$(cfg).mk

CFLAGS	= $(XCFLAGS)
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= $(LIBC)
all:	$(LIBRARY)

OBJECTS	= \
	sys_abort.o \
	sys_copy.o \
	sys_endsig.o \
	sys_exec.o \
	sys_fork.o \
	sys_fresh.o \
	sys_getmap.o \
	sys_getsp.o \
	sys_kill.o \
	sys_newmap.o \
	sys_oldsig.o \
	sys_sendsig.o \
	sys_sigret.o \
	sys_times.o \
	sys_trace.o \
	sys_xit.o \
	taskcall.o \

$(LIBRARY):	$(OBJECTS)
	$(AR) $(ARFLAGS) $@ *.o
	$(RM) *.o

clean:
	$(RM) *.o

sys_abort.o:	sys_abort.c
	$(CC1) sys_abort.c

sys_copy.o:	sys_copy.c
	$(CC1) sys_copy.c

sys_endsig.o:	sys_endsig.c
	$(CC1) sys_endsig.c

sys_exec.o:	sys_exec.c
	$(CC1) sys_exec.c

sys_fork.o:	sys_fork.c
	$(CC1) sys_fork.c

sys_fresh.o:	sys_fresh.c
	$(CC1) sys_fresh.c

sys_getmap.o:	sys_getmap.c
	$(CC1) sys_getmap.c

sys_getsp.o:	sys_getsp.c
	$(CC1) sys_getsp.c

sys_kill.o:	sys_kill.c
	$(CC1) sys_kill.c

sys_newmap.o:	sys_newmap.c
	$(CC1) sys_newmap.c

sys_oldsig.o:	sys_oldsig.c
	$(CC1) sys_oldsig.c

sys_sendsig.o:	sys_sendsig.c
	$(CC1) sys_sendsig.c

sys_sigret.o:	sys_sigret.c
	$(CC1) sys_sigret.c

sys_times.o:	sys_times.c
	$(CC1) sys_times.c

sys_trace.o:	sys_trace.c
	$(CC1) sys_trace.c

sys_xit.o:	sys_xit.c
	$(CC1) sys_xit.c

taskcall.o:	taskcall.c
	$(CC1) taskcall.c
