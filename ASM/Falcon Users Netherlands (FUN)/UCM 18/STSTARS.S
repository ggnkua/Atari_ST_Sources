* Double buffering starfield.
* A little demonstration by earx/fun.
* Please run in ST-LOW.

NumberOfStars:	=	500

* Change to supervisor-mode.
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

* Save old screenaddress.
	move	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,old_screenaddress

* Save old palette.
	lea	$ffff8240.w,a1
	lea	old_palette_table,a0
	moveq	#16-1,d7
save_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,save_palette_loop

* Set new palette.
	lea	$ffff8240.w,a0
	lea	starpal_table,a1
	moveq	#16-1,d7
new_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,new_palette_loop

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#160*200,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Calculate starpositions.
	lea	star_tbl,a0
	move.w	#NumberOfStars,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	move.l	#$12345678,d0
calcstar_loop:
        move.l  d0,d1                           * Store d0 temporarily.
        mulu.w  d0,d0                           * Multiply d0*d0.
        eor.l   d1,d0                           * Exclusive OR it.
        addq.l  #7,d0                           * Add constant to it.
	moveq	#0,d2
	move.w	d0,d2
	divu.w	#320,d2
	swap	d2
	move.w	d2,(a0)+
	move.l	d0,d2
	swap	d2
	andi.l	#$0000ffff,d2
	divu.w	#200,d2
	swap	d2
	move.w	d2,(a0)+
	dbra	d7,calcstar_loop

* Execute the main loop.
main_loop:

	move.l	logical_screen,a0
	bsr	CLEAR_SCREEN

* Draw graphics onto the logical screen.
	lea	star_tbl,a1
	move.w	(a1)+,d7
	lsr.w	#3,d7
	subq.w	#1,d7

pixel_loop:
	move.l	logical_screen,a0		* Get screenaddress.
	movem.w	(a1),d0-d1			* Get X, Y.
	addq.w	#2,d0
	cmpi.w	#320,d0
	blt.s	x_ok
	subi.w	#320,d0
x_ok:	move.w	d0,(a1)+
	addq	#2,a1
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,pixel_loop			* Loop, until all pixels are done.

	move.w	star_tbl,d7
	lsr.w	#2,d7
	subq.w	#1,d7

pixel_loop2:
	move.l	logical_screen,a0		* Get screenaddress.
	addq	#2,a0
	movem.w	(a1),d0-d1			* Get X, Y.
	addq.w	#1,d0
	cmpi.w	#320,d0
	blt.s	x_ok2
	subi.w	#320,d0
x_ok2:	move.w	d0,(a1)+
	addq	#2,a1
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,pixel_loop2			* Loop, until all pixels are done.

	move.w	star_tbl,d7
	lsr.w	#1,d7
	subq.w	#1,d7
	move.w	layer_3_move,d6
	not.w	d6
	move.w	d6,layer_3_move

pixel_loop3:
	move.l	logical_screen,a0		* Get screenaddress.
	addq	#4,a0
	movem.w	(a1),d0-d1			* Get X, Y.
	tst.w	d6
	beq.s	no_move
	addq.w	#1,d0
no_move:
	cmpi.w	#320,d0
	blt.s	x_ok3
	subi.w	#320,d0
x_ok3:	move.w	d0,(a1)+
	addq	#2,a1
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,pixel_loop3			* Loop, until all pixels are done.

* Swap screenbuffers.
	move.l	logical_screen,d0
	move.l	physical_screen,logical_screen
	move.l	d0,physical_screen

* Set new screenaddress.
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Wait for the VBL...
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp

	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne	main_loop			* If not, keep looping.

* Restore old palette.
	lea	$ffff8240.w,a0
	lea	old_palette_table,a1
	moveq	#16-1,d7
restore_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,restore_palette_loop

* Restore old screenaddress.	
	move.l	old_screenaddress,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Terminate program.
	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* INPUT: a0: screenaddress
CLEAR_SCREEN:
	add.l	#160*200,a0			* Get end of screen.
	moveq	#0,d0				* Clear all regs..
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	move.w	#153-1,d7

clearloop:
	movem.l	d0-d6/a1-a6,-(a0)               * Move 13 longs to mem.
	movem.l	d0-d6/a1-a6,-(a0)               * etc.
	movem.l	d0-d6/a1-a6,-(a0)               * etc.
	movem.l	d0-d6/a1-a6,-(a0)
	dbra	d7,clearloop

* Clear the tail.
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d5,-(a0)
	rts

* One bitplane dot plotting routine for ST-LOW.
* INPUT: d0.w: x coordinate
*        d1.w: y coordinate
*        a0: start of screenaddress (add 2, 4, 6 to get other bitplanes)
PLOT_PIXEL:
	move.w	d0,d2				* Backup x-coordinate.
	andi.w	#$fff0,d0			* Calculate bitplane.
	sub.w	d0,d2				* / Calculate
	subi.w	#15,d2				* | bitnumber
	neg.w	d2				* \ in bitplane.
	mulu.w	#160,d1				* y-coord -> y_offset
	lsr.w	#1,d0				* x-offset.
	add.w	d0,d1				* Calculate screenoffset.
	move.w	(a0,d1.l),d0			* Get bitplane word.
	bset	d2,d0				* Activate the bit.
	move.w	d0,(a0,d1.l)			* Put the word back.
	rts

	DATA

starpal_table:
	DC.W	$0000	0000
	DC.W	$0777	0001
	DC.W	$0555	0010
	DC.W	$0777	0011
	DC.W	$0333	0100
	DC.W	$0777	0101
	DC.W	$0555	0110
	DC.W	$0777	0111
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000
	DC.W	$0000



	BSS

layer_3_move:
	DS.W	1
star_tbl:
	DS.W	1+2*NumberOfStars
old_screenaddress:
	DS.L	1				* Here we store the old GEM screenaddress.
old_palette_table:
	DS.W	16				* Here we store the old GEM palette.
logical_screen:
	DS.L	1				* Address of logical (invisible) screen.
physical_screen:
	DS.L	1				* Address of physical (visible) screen.
screen_buffer:
	DS.B	256				* This for alignment on 256-byte boundary.
	DS.B	32000				* Memory to hold one ST-LOW screen.
	DS.B	32000				* Memory to hold one ST-LOW screen.