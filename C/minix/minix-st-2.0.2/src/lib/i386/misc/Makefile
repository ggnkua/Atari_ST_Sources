# Makefile for lib/i386/misc.

CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE -Was-ack
CC1	= $(CC) $(CFLAGS) -c

LIBRARY	= ../../libc.a
all:	$(LIBRARY)

OBJECTS	= \
	$(LIBRARY)(alloca.o) \
	$(LIBRARY)(get_bp.o) \
	$(LIBRARY)(getprocessor.o) \
	$(LIBRARY)(iolib.o) \
	$(LIBRARY)(oneC_sum.o) \

$(LIBRARY):	$(OBJECTS)
	aal cr $@ *.o
	rm *.o

$(LIBRARY)(alloca.o):	alloca.s
	$(CC1) alloca.s

$(LIBRARY)(get_bp.o):	get_bp.s
	$(CC1) get_bp.s

$(LIBRARY)(getprocessor.o):	getprocessor.s
	$(CC1) getprocessor.s

$(LIBRARY)(iolib.o):	iolib.s
	$(CC1) iolib.s

$(LIBRARY)(oneC_sum.o):	oneC_sum.s
	$(CC1) oneC_sum.s
