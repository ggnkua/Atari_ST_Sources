* This one masks the dots (so the background doesn't have to be cleared)

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
	
	
	lea	xoff(pc),a0
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



	move.l	#319,x1		* Source X.
	move.l	#318,x2		* Destination X (< so a shrink).
	move.l	#199,y1		* Source X.
	move.l	#198,y2		* Destination X (< so a shrink).
	move.l	y2(pc),d0
	mulu	#160,d0
	move.l	d0,ymult

	move.l	y1(pc),d5	* Get source X.
	move.l	y2(pc),d4	* Get destination X.

	move.l	d5,d0
	divu	d4,d0
	move	d0,d5
	swap	d5
	clr	d0
	divu	d4,d0
	move	d0,d5	* MSW = int ... LSW = frac.
	
	moveq.l	#0,d6
	move.w	d5,d6
	move.w	d6,d7
	swap	d5
	move.w	d5,d4

	move.l	d6,savd6
	move.l	d7,savd7
	move.w	d4,savd4
	
	
	move.l	x1(pc),d5	* Get source X.
	move.l	x2(pc),d4	* Get destination X.

	move.l	d5,d0
	divu	d4,d0
	move	d0,d5
	swap	d5
	clr	d0
	divu	d4,d0
	move	d0,d5	* MSW = int ... LSW = frac.
	
	moveq.l	#0,d6
	move.w	d5,d6
	move.w	d6,d7
	swap	d5
	move.w	d5,d4

	moveq.w	#0,d5		* Xcoord (source)
	clr.w	ycord

	moveq.w	#0,d2		* Xcoord (destination)
	clr.w	yptr

	lea	prouts(pc),a2
	lea	yptr(pc),a5
	lea	ycord(pc),a6

	move.l	scrnpos(pc),a3	* Destination address.
	lea	pic+34(pc),a4	* Source address.
	
	move.w	#$2700,sr

key:	
	move.l	a4,a0			* Get screen address (tee-hee!).
	move.w	(a6),d0			* Get Y coordinate.
	lea	yoffs(pc),a1
	add.w	d0,d0
	add.w	(a1,d0.w),a0
	move.w	d5,d0			* Get X coordinate.
	lea	xoff(pc),a1		* Get X address of offsets/data.
	add.w	d0,d0
	add.w	d0,d0			* Long access.
	adda.w	(a1,d0.w),a0		* Add to total screen offset.
	move.w	2(a1,d0.w),d0		* Get point data.

	moveq.w	#0,d3
	move.w	(a0)+,d1
	and.w	d0,d1
	beq.s	not1
	addq.w	#1,d3
not1:	move.w	(a0)+,d1
	and.w	d0,d1
	beq.s	not2
	addq.w	#2,d3
not2:	move.w	(a0)+,d1
	and.w	d0,d1
	beq.s	not4
	addq.w	#4,d3
not4:	move.w	(a0)+,d1
	and.w	d0,d1
	beq.s	not8
	addq.w	#8,d3
not8:


	move.l	a3,a0			* Get screen address (tee-hee!).
	adda.w	(a5),a0			* Add raw Y offset.
	move.w	d2,d0			* Get X coordinate.
	lea	xoff(pc),a1		* Get X address of offsets/data.
	add.w	d0,d0
	add.w	d0,d0			* Long access.
	add.w	(a1,d0.w),a0		* Add to total screen offset.
	move.w	2(a1,d0.w),d0		* Get point data.
	move.w	d0,d1			* And store it to D1.
	not.w	d1			* Inverse mask it.

	lsl.w	#4,d3			* 16 bytes per routine.
	jsr	(a2,d3.w)		* Execute point routine.


	add.l	d7,d6		* Add fraction long so overflow=1!.
	swap	d6		* Move overflow (if any) to lower LSW.
	add	d6,d5		* Add it to integer part.
	clr	d6		* And clear the overflow.
	swap	d6		* Restore fraction to LSW.

	add	d4,d5		* And increase d5 by its own integer.

	addq.w	#1,d2

	cmp.l	x2(pc),d2
	bgt.s	testy
	
	bra.s	key
	
testy:	moveq.w	#0,d5			* Destination X to 0.
	moveq.w	#0,d2			* Source X to 0.
	move.l	d7,-(sp)
	move.l	d6,-(sp)
	move.w	d4,-(sp)
	move.l	savd6(pc),d6
	move.l	savd7(pc),d7
	move.w	savd4(pc),d4
	add.l	d7,d6
	swap	d6
	add	d6,(a6)
	clr	d6
	swap	d6
	add	d4,(a6)
	move.l	d6,savd6
	move.l	d7,savd7
	move.w	(sp)+,d4
	move.l	(sp)+,d6
	move.l	(sp)+,d7

	move.w	d7,d6

	add.w	#160,(a5)
	
	move.l	ymult(pc),d0
	cmp.w	(a5),d0
	bgt	key
	
	
flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done					* Flush keyboard.

	move.w	#$2300,sr

	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp

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

x1:	dc.l	0			* Source X.
x2:	dc.l	0			* Destination X.
y1:	dc.l	0			* Source Y.
y2:	dc.l	0			* Destination Y.

ymult:	dc.l	0

xcord:	dc.w	0
ycord:	dc.w	0

xptr:	dc.w	0
yptr:	dc.w	0

colour:	dc.w	1

savd6:	dc.l	0
savd7:	dc.l	0
savd4:	dc.w	0

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
	rept	320
	dc.w	0
	dc.w	0
	endr
	
pic:	even
	incbin	fighterp.pi1
