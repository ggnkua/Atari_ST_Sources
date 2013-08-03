#
#
SRC = sparrow.s hflop.s rom.s video.s sysctrl.s excep.s dsp.s scsi.s e_exp.s color.s fonts.s joy.s scroll.s keybd.s sdma.s rtc.s endcart.s #palette.s
OBJ = sparrow.o rtc.o joy.o scroll.o sdma.o video.o keybd.o rom.o dsp.o hflop.o sysctrl.o excep.o color.o scsi.o e_exp.o fonts.o endcart.o #palette.o

LINKER = aln
AS = mac
ASFLAGS = -u 

all : sp.out

sparrow.out : sparrow.abs
	glue -b fa0000 -o sparrow.out sparrow.abs

sparrow.sym : $(OBJ)
	$(LINKER) -s -l -w -a 00FA0000 x 0 -o sparrow.sym $(OBJ)

sparrow.abs : $(OBJ)
	$(LINKER) -w -a 00FA0000 x 0 -o sparrow.abs $(OBJ)
# TEMPORARY BURN IN CARTRIGES

sp.out: spburn1.out sparrow.out
	join sparrow.out spburn1.out sp.out
spburn1.out : spburn1.abs
	glue -b F0000 -o spburn1.out spburn1.abs 
spburn1.abs : $(OBJ)
	$(LINKER) -w -a 000F0000 x 0 -o spburn1.abs $(OBJ)

#sparrow.lnk : $(OBJ)
#	$(LINKER) -p -o sparrow.lnk $(OBJ)

sparrow.o : var.s hardware.s defs.s macros.s init.s init2.s nvram.s menu.s rtc.s midi.s wait.s console.s ram.s audio.s timer.s hires.s blt.s wr.s rwh_at.s scrn16.s system.s scc.s help1.s version.s var.gbl sumenu.s
fonts.o : fonts.s
sysctrl.o : var.s hardware.s defs.s macros.s nvram.s
dsp.o : dsp.s var.s hardware.s defs.s macros.s nvram.s scrn16.gbl 
e_exp.o : hardware.s defs.s nvram.s e_data.s e_var.s 
#palette.o : palette.s
video.o : video.s var.s palette.s hardware.s defs.s macros.s nvram.s
scsi.o: scsi.s var.s hardware.s defs.s nvram.s
excep.o: excep.s var.s hardware.s defs.s nvram.s
rom.o: rom.s var.s hardware.s defs.s nvram.s
color.o: color.s var.s hardware.s defs.s nvram.s
joy.o: joy.s var.s hardware.s defs.s nvram.s gentst.s macros.s
scroll.o: scroll.s var.s hardware.s defs.s nvram.s
keybd.o: keybd.s var.s hardware.s defs.s nvram.s
hflop.o: hflop.s var.s hardware.s defs.s nvram.s
sdma.o: sdma.s var.s hardware.s defs.s nvram.s
rtc.o: rtc.s var.s hardware.s defs.s nvram.s
endcart.o : endcart.s
