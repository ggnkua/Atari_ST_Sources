
stars	equ	40

	opt	o+,d+

	move.l a7,a5
	move.l 4(a5),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.w #0,-(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
		
	bsr initstars
	bsr initscreen
	
	bsr	super
	bsr	setcols
	bsr	user
	
loop
	bsr cls
	bsr handlestars
	bsr swapscreens

terminate
	move.w	#255,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.b	d0
	beq.s	loop

	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	bsr	super
	bsr	restcols
	bsr	user
		
	clr.w -(sp)
	trap #1
	

* Routines to handle the paralax scrolling star field.

initstars

* Get the memory for the star co-ordinates

	move.l	#5120,-(sp)		Request 250 bytes from O/S
	move.w	#$48,-(sp)		Malloc function number
	trap	#1
	addq.l	#6,sp
	move.l	d0,starmem

* Generate the random positions

	move.l	d0,a4		Copy start addr into reg' that wont get corpted
	move.w	#stars*3,d4	No. of co-ords to generate

genx	move.w	#17,-(sp)	Xbios RANDOM function number	 
	trap	#14
	addq.l	#2,sp

	and.w	#$ff,d0		Mask unnecesary bits from returned number
	cmp.w	#199,d0		Is the number still to big ?
	bgt.s	genx		Yes so regenerate number.
	move.w	d0,(a4)+	Store number & set pointer to next free

geny	move.w	#17,-(sp)	Xbios RANDOM function number
	trap	#14
	addq.l	#2,sp

	and.w	#%111111111,d0	Mask unused bits
	cmp.w	#319,d0		Is the number still to big ?
	bgt.s 	geny		Yes so regenerate number
	move.w	d0,(a4)+	No so store number & set pointer to next free
	dbf	d4,genx		Generate next pair of coords

	clr.w	oldstar		Make sure valid coord is in random star store
	rts

handlestars
	move.l	starmem,a0	Move addr of star coords into a pointer 'A0'
	REPT	stars
	bsr	plot2		Plot stars (lowest (darkest) field of stars)
	ENDR
	REPT	stars
	bsr	plot1		Plot stars (Mid field of stars)
	ENDR
	REPT	stars
	bsr	plot15		Plot stars (Top (brightest) field of stars)
	ENDR

* 'Move' the stars by changing their coordinates
* LOWER LEVEL 

	moveq	#stars,d0	No. of stars in lower layer to move	
	move.l	starmem,a0	Addr of star coords array 
m3	tst.w	(a0)		Will the star 'fall' off top of screen if moved ?
	beq.s	loose_lowerstar	Yes so branch & regenerate its coordinates.
	subq.w	#1,(a0)		No so move the star up a level.
llr	addq.l	#4,a0		Move the array pointer to next set of coords
	dbf	d0,m3

* MID LEVEL 
	moveq	#stars,d0	No. of stars in mid layer to move	
m2	cmp.w	#2,(a0)		Will the star 'fall' off top of screen if moved ?
	ble.s	loose_midstar	Yes so branch & regenerate its coordinates.
	subq.w	#2,(a0)		No so move the star up a level.
lmr	addq.l	#4,a0		Move the array pointer to next set of coords
	dbf	d0,m2

* TOP LEVEL 

	moveq	#stars,d0	No. of stars in mid layer to move	
m1	cmp.w	#3,(a0)		Will the star 'fall' off top of screen if moved ?
	ble.s	loose_topstar	Yes so branch & regenerate its coordinates.
	subq.w	#3,(a0)		No so move the star up a level.
ltr	addq.l	#4,a0		Move the array pointer to next set of coords
	dbf	d0,m1
	rts
	
	
loose_lowerstar		* Handles a star falling off the top of the screen

	move.w	#199,(a0)	Reset Y axis to bottom of screen
	move.w	oldstar,d1	X coord of last star to drop (Semi-random no.)
	move.w	2(a0),oldstar	Put old X coord for use as a random number.
	move.w	d1,2(a0)	Use old drop no. (semi-random) as new X coord
	bra.s	llr		And return to the 'move stars' routine 

loose_midstar		* Handles a star falling off the top of the screen

	move.w	#199,(a0)	Reset Y axis to bottom of screen
	move.w	oldstar,d1	X coord of last star to drop (Semi-random no.)
	move.w	2(a0),oldstar	Put old X coord for use as a random number.
	move.w	d1,2(a0)	Use old drop no. (semi-random) as new X coord
	bra.s	lmr		And return to the 'move stars' routine 
	
loose_topstar		* Handles a star falling off the top of the screen

	move.w	#199,(a0)	Reset Y axis to bottom of screen
	move.w	oldstar,d1	X coord of last star to drop (Semi-random no.)
	move.w	2(a0),oldstar	Put old X coord for use as a random number.
	move.w	d1,2(a0)	Use old drop no. (semi-random) as new X coord
	bra.s	ltr		And return to the 'move stars' routine 
	
plot1 	* Plot a pixel in color 1 - much faster than using O/S.

	moveq	#0,d0
	move.w	#160,d2		Width of a screen line in bytes.
	move.l	a6,a1		Copy logical screen address.
	mulu.w	(a0)+,d2	Calculate distance down screen...
	add.l	d2,a1		and add to screen addr.

	move.w	(a0),d0		Copy the X co-ord of the star.
	asr.w	#4,d0		Now calculate it's byte offset;
	asl.l	#3,d0		The byte off set of the X co-ord.
	move.w	(a0)+,d2	as above
	sub.w	d0,d2		final bit offset calculation.
	bset	d2,0(a1,d0)	Set bit #D2, with D0 as byte offset in plane 0
	rts
	
plot2	* Plot a pixel in color 2 - much faster than using O/S.

	moveq	#0,d0
	move.w	#160,d2		Width of a screen line in bytes.
	move.l	a6,a1		Copy logical screen address.
	mulu.w	(a0)+,d2	Calculate distance down screen...
	add.l	d2,a1		and add to screen addr.

	move.w	(a0),d0		Copy the X co-ord of the star.
	asr.w	#4,d0		Now calculate it's byte offset;
	asl.l	#3,d0		The byte off set of the X co-ord.
	move.w	(a0)+,d2	as above
	sub.w	d0,d2		final bit offset calculation.
	bset	d2,2(a1,d0)	Set bit #D2, with D0 as byte offset in plane 1
	rts
	
plot15	* Plot a pixel in color 15 - much faster than using O/S.

	moveq	#0,d0
	move.w	#160,d2		Width of a screen line in bytes.
	move.l	a6,a1		Copy logical screen address.
	mulu.w	(a0)+,d2	Calculate distance down screen...
	add.l	d2,a1		and add to screen addr.
	move.w	(a0),d0		Copy the X co-ord of the star.
	asr.w	#4,d0		Now calculate it's byte offset;
	asl.l	#3,d0		The byte off set of the X co-ord.
	move.w	(a0)+,d2	as above
	sub.w	d0,d2		final bit offset calculation.
 	bset	d2,0(a1,d0)	Set bit #D2, with D0 as byte offset in plane 0
	bset	d2,2(a1,d0)	Set bit #D2, with D0 as byte offset in plane 1
	bset	d2,4(a1,d0)	Set bit #D2, with D0 as byte offset in plane 2
	bset	d2,6(a1,d0)	Set bit #D2, with D0 as byte offset in plane 3
	rts
	
oldstar	dc.w	0	Hold's a semi-random number, used for paralax
starmem	dc.l	0	Holds the address of the coordinates array.


initscreen
	move.w #3,-(sp)		Physbase code.
	trap #14
	addq.l #2,sp
	move.l d0,fstscreen	Store current screen address

* Allocate memory for a second screen

	move.l #32256,-(sp)	Need 32K for screen, extra 256 bytes see below
	move.w #$48,-(sp)	Malloc function code
	trap #1
	addq.l #6,sp

* Calculate screen addr - screen alignd to a 256 byte boundry

	add.l	#256,d0		D0 holds screen memory addr from above call
	divu	#256,d0		Find modulus of screen addr.
	mulu	#256,d0		Find modulus of screen addr.
	move.l	d0,secscreen	And store second screen addr.

* Clear the screens

	move.l	d0,a6		Addr of screen to clear (calculated above).
	bsr	cls		Jump to screen clearing routine.
	move.l	fstscreen,a6	Get addr of fstscreen...
	bsr	cls		And clear it.
	clr.b	screenflag	Inform swapscrn that fstscrn is the physcl scrn
	move.l	secscreen,a6	Inform routines of where to draw.
	rts			End of routine - return.

swapscreens	
	tst.b	screenflag	Is fstscreen physical screen ?
	beq.s	swap2		Yes so fstscreen become logical
	clr.b	screenflag	Flip the screenflag flag
	move.w	#-1,-(sp)
	move.l	secscreen(pc),-(sp)
	move.l	fstscreen(pc),-(sp)
	move.w	#5,-(sp)	
	trap	#14
	add.l	#12,sp
	move.l	secscreen,physicalscreen
	move.l	fstscreen,a6	Get drawing routines to draw to logical screen
	move.w	#37,-(sp)	Vsync code (wait for electron gun to flyback)
	trap	#14
	addq.l	#2,sp
	rts

swap2	seq.b	screenflag	Flip the screenflag flag
	move.w	#-1,-(sp)
	move.l	fstscreen,-(sp)
	move.l	secscreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	fstscreen,physicalscreen
	move.l	secscreen,a6
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts

cls	* Clears the routines pointed to by A6

	move.l	a6,a0		Copy the screen stars addr
	movem	spaces,d0-d7
clsloop
	rept	1000
	movem.l	d0-d7,(a0)	Clear screen at A0 then incr A0
	lea	32(a0),a0
	endr
	rts

spaces	ds.l	8

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	rts
user	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

setcols	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,oldcols
	movem.l	cols,d0-d7
	movem.l	d0-d7,$ff8240
	rts
restcols
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ff8240
	rts

oldsp	dc.l	0
oldcols	ds.l	16

fstscreen
	dc.l	0	Physical addr of screen when program starts.
secscreen
	dc.l	0	Physical addr of additional screen created by
physicalscreen
	dc.l	0	Points to scrn beng displayed, used by scroller
screenflag
	dc.b	0	Used by SWAPSCREENS to determin physical screen
	EVEN

cols	dc.w	0,$333,$222,$344,$700,$050,$030,0,$660,0,$043,$003
	dc.w	$566,$077,$055,$555,$777
	ds.b	5000
