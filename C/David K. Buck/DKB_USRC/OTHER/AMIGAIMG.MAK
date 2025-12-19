CFLAGS	= -cusrt -ff -m0 -q5w5e -O -v

.o.c:
	lc $(CFLAGS) $*

all:	dump2i24 combdump catdump dump2mtv halftga gluetga dump2raw tga2dump ip2dkb

dump2i24:	dump2i24.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib dump2i24.o TO dump2i24

combdump:	combdump.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib combdump.o TO combdump

catdump:	catdump.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib catdump.o TO catdump

dump2mtv:	dump2mtv.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib dump2mtv.o TO dump2mtv

halftga:	halftga.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib halftga.o TO halftga

gluetga:	gluetga.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib gluetga.o TO gluetga

dump2raw:	dump2raw.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib dump2raw.o TO dump2raw

tga2dump:	tga2dump.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib tga2dump.o TO tga2dump

ip2dkb:		ip2dkb.o
		blink from lib:c.o LIB lib:lcmffp.lib lib:lc.lib ip2dkb.o TO ip2dkb

dump2i24.o:	dump2i24.c
combdump.o:	combdump.c
catdump.o:	catdump.c
dump2mtv.o:	dump2mtv.c
halftga.o:	halftga.c
gluetga.o:	gluetga.c
dump2raw.o:	dump2raw.c
tga2dump.o:	tga2dump.c
ip2dkb.o:	ip2dkb.c
