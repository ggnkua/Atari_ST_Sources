	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp		* Set supervisor mode.
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ffff8260.w		* Low resolution pleez!

	lea	pal(pc),a0
	lea	$ff8240,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	
	lea	xoff,a0
	moveq.l	#0,d0
	move.w	#$f,d3
	move.w	#320-1,d7		* Set up some variables.
	
cxs:	move.w	d0,d1			* Get X coordinate for offset.
	move.w	d0,d2			* get X coordinate for shift.
	and.b	#%11110000,d1		* Mask out naughty bits.
	lsr.w	#1,d1			* And get chunk address.
	move.w	d1,(a0)+		* Store screen offset.
	
	and.w	d3,d2			* Get shift count.
	add.w	d2,d2			* Word access.
	lea	omasks(pc),a1		* Get mask table address.
	move.w	0(a1,d2.w),d1		* Get point data.
	move.w	d1,(a0)+		* Save it.
	
	addq.w	#1,d0
	dbra	d7,cxs			* Do for 20 chunks.

	move.l	a0,scrnpos
	move.l	a0,d0
	add.w	#256,d0
	move.b	#0,d0
	move.l	d0,scrnpos
	add.l	#32000,d0
	move.l	d0,scrn2

	move.w	#$2700,sr		* Off with all interrupts.
	move.b	$fffa07,sa1
	move.b	$fffa09,sa2
	move.b	$fffa13,sa3
	move.b	$fffa19,sa4
	move.b	$fffa1f,sa5
	move.b	$fffa21,sa6
	move.b	$fffa1b,sa7		* Save necessary MFP regs.
	move.b	$fffa15,sa8
	move.b	$fffa1d,sa9
	move.b	$fffa25,sa10
	move.b	#0,$fffa07
	move.b	#0,$fffa09		* Throw out everything!
	
	bclr.b	#3,$fffa17		* Software End Of Interrupt mode.

	move.l	$70.w,oldvbl		* Save old VBL.
	move.l	#vbl,$70.w		* Install my VBL.
	move.w	#$2300,sr
	
	move.l	scrnpos(pc),a0
	move.w	#3999,d0
clean:	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbra	d0,clean		* Clear screen.
	
	
key:	move.b	lcount(pc),d0
sync:	cmp.b	lcount(pc),d0
	beq.s	sync			* Wait for beam flyback.

*	move.w	#$700,$ffff8240.w	* To see how much time it takes...

	tst.b	flip
	bne.s	poo
	move.b	#1,flip
	bra.s	scour
poo:	move.b	#0,flip
	
scour:	moveq.l	#0,d0
	move.l	d0,d1			* Clear registers.
	move.l	scrnpos(pc),a0		* Initialise screen address.
	tst.b	flip
	bne.s	oh2
	bsr	clrrts			* Execute point clear routines.
	bra.s	goon
oh2:	bsr	clrrts2
	
goon:	
	tst.b	flip
	beq.s	seccy
	lea	clrrts2+4(pc),a2	* To save LEA'ing.
	bra.s	pand
seccy:	lea	clrrts+4(pc),a2		* To save LEA'ing.
pand:	moveq.w	#4,d4
	moveq.w	#6,d3
	
nexp:	move.l	scrnpos(pc),a0		* Get screen address (tee-hee!).
	move.w	ycord(pc),d6		* Get Y coordinate.
	lea	yoffs(pc),a1
	lsl.w	#1,d6
	move.w	(a1,d6.w),d6
	move.w	xcord(pc),d2		* Get X coordinate.
	lea	xoff(pc),a1		* Get X address of offsets/data.
	add.w	d2,d2
	add.w	d2,d2			* Long access.
	adda.w	d2,a1			* Add to table address.
	add.w	(a1),d6			* Add to total screen offset.
	adda.w	d6,a0			* Now add it to screenbase.
	move.w	d6,(a2)			* Self modify clear routines.
	add.w	d3,a2			* Increase pointer to clr routs.
	move.w	2(a1),d0		* Get point data.
	move.w	d0,d1			* And store it to D1.
	not.w	d1			* Inverse mask it.
	move.w	#1,d2			* Get colour.
	
	lea	prouts(pc),a1		* Nab point plot routs taddress.
	lsl.w	d4,d2			* 16 bytes per routine.
	jsr	(a1,d2.w)		* Execute point routine.
	
	
*	move.w	#$000,$ffff8240.w	* End of timing loop (all points).
	
	cmpi.b	#57,$fffffc02.w
	bne	key			* Repeat if spacebar not pressed.
	
	
flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done					* Flush keyboard.

	move.w	#$2700,sr
	move.b	sa1(pc),$fffa07
	move.b	sa2(pc),$fffa09
	move.b	sa3(pc),$fffa13
	move.b	sa4(pc),$fffa19
	move.b	sa5(pc),$fffa1f
	move.b	sa6(pc),$fffa21
	move.b	sa7(pc),$fffa1b
	move.b	sa8(pc),$fffa15
	move.b	sa9(pc),$fffa1d
	move.b	sa10(pc),$fffa25
	move.l	oldvbl(pc),$70.w	* Re-install old VBL.
	move.w	#$2300,sr
	
	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8242.w
	move.w	#$000,$ffff8244.w	
	move.w	#$000,$ffff8246.w	* Set colours to 'normal'.

	MOVE.B #7,$FFFF8800.W
	MOVE.B #-1,$FFFF8802.W

	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp			* Old stack & mode.
	
	clr.w	-(sp)
	trap	#1			* ... Terminate program.
	
	
vbl:	move.b	scrn2+1(pc),$ffff8201.w
	move.b	scrn2+2(pc),$ffff8203.w
	move.l	scrnpos(pc),-(sp)
	move.l	scrn2,scrnpos
	move.l	(sp)+,scrn2
	addq.b	#1,lcount		* Signal flyback has occured.
	rte

	
oldsp:	ds.l	1			* Space for old stack address.
oldvbl:	ds.l	1			* Space for old VBL address.

lcount:	ds.w	1			* Space for beam flyback signal.

scrnpos:ds.l	1			* Screen position (crafty place!).
scrn2:	ds.l	1

cords:	dc.w	10-1
	dc.w	-20,20,1
	dc.w	-10,20,1
	dc.w	20,20,1
	dc.w	-20,20,1
	dc.w	20,-20,1
	dc.w	-10,20,1
	dc.w	-20,10,1
	dc.w	-10,10,1
	dc.w	20,20,1
	dc.w	10,-20,1
	

omasks:	dc.w	%1000000000000000	* Actual point data.
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001

	
******* Routines for plotting the points. D1 contains the inverse mask,
******* and D0 contains the mask proper for the point.
******* Starts from colour 0 to colour 15.

******* Each routine is 10 bytes long. 4 PLANES, remember!
	
prouts:
col0:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 0.
	dc.l	0
	dc.w	0			* Force each routine to 16 bytes.
col1:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 1.
	dc.l	0
	dc.w	0
col2:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 2.
	dc.l	0
	dc.w	0
col3:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts				* Colour 3.
	dc.l	0
	dc.w	0
col4:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 4.
	dc.l	0
	dc.w	0
col5:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 5.
	dc.l	0
	dc.w	0
col6:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 6.
	dc.l	0
	dc.w	0
col7:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)
	rts				* Colour 7.
	dc.l	0
	dc.w	0
col8:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 8.
	dc.l	0
	dc.w	0
col9:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 9.
	dc.l	0
	dc.w	0
col10:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 10.
	dc.l	0
	dc.w	0
col11:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)
	rts				* Colour 11.
	dc.l	0
	dc.w	0
col12:	and.w	d1,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 12.
	dc.l	0
	dc.w	0
col13:	or.w	d0,(a0)+
	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 13.
	dc.l	0
	dc.w	0
col14:	and.w	d1,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 14.
	dc.l	0
	dc.w	0
col15:	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts				* Colour 15.

clrrts:	rept	100
	movem.l	d0-d1,0(a0)
	endr
	rts

clrrts2:rept	100
	movem.l	d0-d1,0(a0)
	endr
	rts

pal:	dc.w	$000,$077,$027,$037,$047,$057,$067,$077
	dc.w	$700,$710,$720,$730,$740,$750,$760,$770

yoffs:	
yoff	set	0
	rept	200
	dc.w	yoff
yoff	set	yoff+160
	endr

flip:	dc.b	0
sa1:	ds.b	1
sa2:	ds.b	1
sa3:	ds.b	1
sa4:	ds.b	1
sa5:	ds.b	1
sa6:	ds.b	1
sa7:	ds.b	1
sa8:	ds.b	1
sa9:	ds.b	1
sa10:	ds.b	1

xoff:	even
	dc.w	0
	dc.w	0