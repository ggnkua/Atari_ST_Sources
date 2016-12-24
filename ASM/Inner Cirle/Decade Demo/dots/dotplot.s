	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp		* Set supervisor mode.
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ffff8260.w		* Low resolution pleez!

	move.b	$ffff8201.w,scrnpos+1
	move.b	$ffff8203.w,scrnpos+2	* Get screen position.
	
	
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


key:	
	move.l	scrnpos(pc),a0		* Get screen address (tee-hee!).
	move.w	ycord(pc),d0		* Get Y coordinate.
	lea	yoffs(pc),a1
	add.w	d0,d0
	add.w	(a1,d6.w),a0
	move.w	xcord(pc),d0		* Get X coordinate.
	lea	xoff(pc),a1		* Get X address of offsets/data.
	add.w	d0,d0
	add.w	d0,d0			* Long access.
	adda.w	d0,a1			* Add to table address.
	add.w	(a1),a0			* Add to total screen offset.
	move.w	2(a1),d0		* Get point data.
	move.w	d0,d1			* And store it to D1.
	not.w	d1			* Inverse mask it.

	move.w	colour(pc),d2		* Get colour.

docols:	lea	prouts(pc),a1		* Nab point plot routs taddress.
	lsl.w	#4,d2			* 16 bytes per routine.
	jsr	(a1,d2.w)		* Execute point routine.
	
	
space:	cmpi.b	#57,$fffffc02.w
	bne	key			* Repeat if spacebar not pressed.
	
	
flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done					* Flush keyboard.

	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8242.w
	move.w	#$000,$ffff8244.w	
	move.w	#$000,$ffff8246.w	* Set colours to 'normal'.

	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp			* Old stack & mode.
	
	clr.w	-(sp)
	trap	#1			* ... Terminate program.
	
	
oldsp:	ds.l	1			* Space for old stack address.
scrnpos:ds.l	1			* Screen position (crafty place!).

xcord:	dc.w	0
ycord:	dc.w	0
colour:	dc.w	1

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

yoffs:	even
yoff	set	0
	rept	200
	dc.w	yoff
yoff	set	yoff+160
	endr

xoff:	even
	dc.w	0
	dc.w	0