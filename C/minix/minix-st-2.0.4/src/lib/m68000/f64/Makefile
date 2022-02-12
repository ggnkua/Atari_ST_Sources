# CC = scc
#INTSIZE = # -DNOLONGS
#CFLAGS = -O -V -D_MINIX -D_POSIX_SOURCE $(INTSIZE)
#CPPFLAGS = -P $(INTSIZE) -DSOZOBON

CPP=	/usr/lib/cpp -P
CPPPFLAGS = $(CPPFLAGS) -DSOZOBON
AS =	jas
#AR = 	ar
ARFLAGS = rv

OBJS =	doprintf.o scanf.o xcvt.o atof.o modf.o _ffp.o _cvf.o

all :	libm.a

libm.a : $(OBJS)
	rm -f $@
	$(AR) $(ARFLAGS) $@ $(OBJS)

.s.o:
	$(CPP) $(CPPPFLAGS) $*.s >$*I.s
	$(AS) $*I.s -o $*.o
	rm -f $*I.s

clean :
	rm -f $(OBJS)

clobber :
	rm -f libf64.a
