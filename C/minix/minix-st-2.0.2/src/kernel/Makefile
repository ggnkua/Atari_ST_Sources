# change if you prefer support for another national keyboard version
#KEYMAP	= keymap.uk.h
KEYMAP	= keymap.ge.h

DEFS	= -DACK -I$i -DSPEEDUP16=1 -DVS_FLOPPY=1 -DMULTIBOARD=1
CC	= exec cc
CFLAGS	= $(DEFS) -O # -DVS_DEBUG


AS	= cc $(DEFS) -c
LD	= /usr/lib/em_led
CV	= /usr/lib/cv
#l	= /usr/lib
l	= ../lib
i	= ../include

FLOPPY	= stfloppy.o
#SCREEN  = screen.o
SCREEN  = 
SOBJ	= stmpx.o klib68k.o stdskclks.o fpps.o pmmus.o rs2.o
COBJ	= stmain.o proc.o system.o stshadow.o \
	  tty.o clock.o memory.o stdma.o $(FLOPPY) stacsi.o \
	  stcon.o stkbd.o stvdu.o stfnt.o stprint.o rs232.o \
 	  table.o dmp.o misc.o stdskclk.o $(SCREEN) stscsi.o fpp.o pmmu.o \
 	  pty.o driver.o drvlib.o stnet.o
OBJ	= $(SOBJ) $(COBJ)
MAP	= keymap.ge.h keymap.uk.h keymap.us.h
HDR	= const.h glo.h kernel.h proc.h proto.h \
	  stacia.h staddr.h stdma.h stfdc.h sthdc.h stmfp.h \
	  stram.h stsound.h stvideo.h tty.h type.h stscsi.h
DEP	= $i/errno.h $i/limits.h $i/sgtty.h $i/signal.h \
	  $i/minix/boot.h $i/minix/callnr.h $i/minix/com.h \
	  $i/minix/config.h $i/minix/const.h $i/minix/type.h \
	  $i/sys/types.h keymap.h $(HDR)
ALL	= kernel

all:	$(ALL)

cp cmp:	all

clean:
	rm -f $(OBJ)

clobber: clean
	rm -f $(ALL) tmp

kernel:	$(OBJ) $l/libc.a $l/libe.a $l/end.a
	$(LD) -c -o tmp $(OBJ) $l/libc.a $l/libe.a $l/end.a
	$(CV) -R tmp $@
	rm tmp

stmpx.o:	stmpx.s
	$(CC) $(DEFS) -c stmpx.s
klib68k.o:	klib68k.s
	$(CC) $(DEFS) -c klib68k.s
stdskclks.o:	stdskclks.s
	$(CC) $(DEFS) -c stdskclks.s
rs2.o:		rs2.s
	$(CC) $(DEFS) -c rs2.s
fpps.o:		fpps.s
	$(CC) $(DEFS) -c fpps.s
pmmus.o:	pmmus.s
	$(CC) $(DEFS) -c pmmus.s

# too crude
$(OBJ):	$(DEP)

keymap.h:	$(KEYMAP)
	rm -f $@; cp $? $@
