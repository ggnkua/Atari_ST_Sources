DUMPFLAGS	= -cusrt -ff -m0 -q5w5e -O -v
LIBSFFP	= lib:lcmffp.lib lib:lcnb.lib lib:amiga.lib

all:	sa2dkb twister dxf2dkb 3d2-dkb chemconv pickshel

sa2dkb:		sa2dkb.o
		blink FROM lib:c.o sa2dkb.o LIB $(LIBSFFP) TO sa2dkb

sa2dkb.o :	sa2dkb.c
		$(CC) $(DUMPFLAGS) $*

twister:	twister.o
		blink FROM lib:c.o twister.o LIB $(LIBSFFP) TO twister
		
twister.o:	twister.c
		$(CC) $(DUMPFLAGS) $*

dxf2dkb:	dxf2dkb.o
		blink FROM lib:c.o dxf2dkb.o LIB $(LIBSFFP) TO dxf2dkb

dxf2dkb.o:	dxf2dkb.c
		$(CC) $(DUMPFLAGS) $*

3d2-dkb:	3d2-dkb.o
		blink FROM lib:c.o 3d2-dkb.o LIB $(LIBSFFP) TO 3d2-dkb

3d2-dkb.o :	3d2-dkb.c
		$(CC) $(DUMPFLAGS) $*

chemconv:	chemconv.o
		blink FROM lib:c.o chemconv.o LIB $(LIBSFFP) TO chemconv

chemconv.o :	chemconv.c
		$(CC) $(DUMPFLAGS) $*

pickshel:	pickshel.o
		blink FROM lib:c.o pickshel.o LIB $(LIBSFFP) TO pickshel

pickshel.o :	pickshel.c
		$(CC) $(DUMPFLAGS) $*
