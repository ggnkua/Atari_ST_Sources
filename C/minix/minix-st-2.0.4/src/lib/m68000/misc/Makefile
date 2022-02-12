CFLAGS	= -I../../.. -D_MINIX -D_POSIX_SOURCE -D__ACK__
CC1	= $(CC) -c $(CFLAGS)

LIBRARY	= ../../libc.a
all:	$(LIBRARY)

OBJS	= \
	$(LIBRARY)(alloca.o) \
	$(LIBRARY)(get_bp.o) \
	$(LIBRARY)(oneC_sum.o) \
	$(LIBRARY)(u64.o)

$(LIBRARY):	$(OBJS)
	aal cr $@ *.o
	rm -f *.o

$(LIBRARY)(alloca.o):	alloca.s
	$(CC1) $<

$(LIBRARY)(get_bp.o):	get_bp.s
	$(CC1) $<

$(LIBRARY)(oneC_sum.o):	oneC_sum.s
	$(CC1) $<

$(LIBRARY)(u64.o):	u64.c
	$(CC1) $<

clean:	
	@rm -rf *.o *.bak

clobber:
	@rm -rf *.o *.bak
