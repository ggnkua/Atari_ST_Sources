# define as -DCLOCKS if you have a clock on your hard disk controller
CLOCKS	=

# change if you prefer support for another national keyboard version
KEYMAP	= keymap.us.h

DEFS	= -DACK $(CLOCKS)
CFLAGS	= -O $(DEFS)


AS	= cc $(DEFS) -c
LD	= /usr/lib/ld
CV	= /usr/lib/cv
l	= /usr/lib
i	= /usr/include


SOBJ	= stmpx.o copy68k.o stdskclks.o
COBJ	= stmain.o proc.o system.o stshadow.o \
	  tty.o clock.o memory.o stdma.o stfloppy.o stwini.o \
	  stcon.o stkbd.o stvdu.o stfnt.o stprint.o rs232.o \
 	  table.o stdmp.o misc.o stdskclk.o
OBJ	= $(SOBJ) $(COBJ)
MAP	= keymap.ge.h keymap.uk.h keymap.us.h
HDR	= const.h glo.h kernel.h proc.h proto.h \
	  stacia.h staddr.h stdma.h stfdc.h sthdc.h stmfp.h \
	  stram.h stsound.h stvideo.h tty.h type.h
DEP	= $i/errno.h $i/limits.h $i/sgtty.h $i/signal.h \
	  $i/minix/boot.h $i/minix/callnr.h $i/minix/com.h \
	  $i/minix/config.h $i/minix/const.h $i/minix/type.h \
	  $i/sys/types.h keymap.h $(HDR)
ALL	= kernel.mix

all:	$(ALL)

cp cmp:	all

clean:
	rm -f $(OBJ)

clobber:
	rm -f $(ALL) kernel.out

kernel.mix:	$(OBJ) $l/libc.a $l/end.o
	$(LD) -c -o kernel.out $(OBJ) $l/libc.a $l/end.o
	$(CV) -R kernel.out $@

stmpx.o:	stmpx.s
	$(CC) $(CFLAGS) -c stmpx.s
copy68k.o:	copy68k.s
	$(CC) $(CFLAGS) -c copy68k.s
stdskclks.o:	stdskclks.s
	$(CC) $(CFLAGS) -c stdskclks.s

# too crude
$(OBJ):	$(DEP)

keymap.h:	$(KEYMAP)
	rm -f $@; cp $? $@
