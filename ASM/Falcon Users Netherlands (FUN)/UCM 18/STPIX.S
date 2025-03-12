* Double buffering pixelplotter.
* A little demonstration by earx/fun.
* Please run in ST-LOW.

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

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#160*200,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Execute the main loop.
main_loop:

* Move the pixels a bit.
	lea	 pixel_tbl,a1
	move.w	(a1)+,d7
	subq.w	#1,d7

move_loop:
	movem.w	(a1),d0-d3
	add.w	d2,d0		* Add X-speed to X-position.
	add.w	d3,d1		* Add Y-speed to Y-position.

	cmpi.w	#320,d0
	blo.s	x_not_overflown
	neg.w	d2
	add.w	d2,d0
x_not_overflown:
	cmpi.w	#200,d1
	blo.s	y_not_overflown
	neg.w	d3
	add.w	d3,d1
y_not_overflown:

	movem.w	d0-d3,(a1)
	add.w	#10,a1
	dbra	d7,move_loop

	move.l	logical_screen,a0
	bsr	CLEAR_SCREEN

* Draw graphics onto the logical screen.
	lea	pixel_tbl,a1
	move.w	(a1)+,d7
	subq.w	#1,d7

pixel_loop:
	move.l	logical_screen,a0		* Get screenaddress.
	move.w	(a1)+,d0			* Get X of current pixel.
	move.w	(a1)+,d1			* Get Y of current pixel.
	addq	#4,a1
	add.w	(a1)+,a0			* Add bitplane offset to screenaddress.
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,pixel_loop			* Loop, until all pixels are done.

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

pixel_tbl:
	DC.W	10				* 10 pixels to plot.
	DC.W	160,100,1,1,0			* X, Y, X-speed, Y-speed, bitplane offset
	DC.W	162,102,1,1,2
	DC.W	164,104,1,1,4
	DC.W	166,106,1,1,6
	DC.W	168,108,1,1,0
	DC.W	170,110,1,1,2
	DC.W	172,112,1,1,4
	DC.W	174,114,1,1,6
	DC.W	176,116,1,1,0
	DC.W	178,118,1,1,2

	BSS

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