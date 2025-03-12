* Double buffering flickerless animation.
* A little demonstration by earx/fun.
* Please run Falcon highcolor 320*200.

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

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#640*200,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Execute the main loop.
main_loop:

* Clear pixels from the logical screen.
	move.l	newpixel_address,a1
	move.w	(a1)+,d7
	subq.w	#1,d7

clear_loop:
	move.l	logical_screen,a0		* Get screenaddress.
	move.w	(a1)+,d0			* Get X of current pixel.
	move.w	(a1)+,d1			* Get Y of current pixel.
	addq	#6,a1
	move.w	#$0000,d2			* pixelcolor = background color
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,clear_loop	

* Move the pixels a bit.
	move.l	oldpixel_address,a1
	move.l	newpixel_address,a2
	move.w	(a1)+,d7
	move.w	d7,(a2)+
	subq.w	#1,d7

move_loop:
	movem.w	(a1)+,d0-d4
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

	movem.w	d0-d4,(a2)
	add.w	#10,a2
	dbra	d7,move_loop

* Draw graphics onto the logical screen.
	move.l	newpixel_address,a1
	move.w	(a1)+,d7
	subq.w	#1,d7

pixel_loop:
	move.l	logical_screen,a0		* Get screenaddress.
	move.w	(a1)+,d0			* Get X of current pixel.
	move.w	(a1)+,d1			* Get Y of current pixel.
	addq	#4,a1
	move.w	(a1)+,d2
	bsr	PLOT_PIXEL			* Plot the pixel.
	dbra	d7,pixel_loop			* Loop, until all pixels are done.

* Swap pixelbuffers.
	move.l	newpixel_address,d0
	move.l	oldpixel_address,newpixel_address
	move.l	d0,oldpixel_address

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

* Restore old screenaddress.	
	move.l	old_screenaddress,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Terminate program.
	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********

* Pixel plotter for falcon 320*Y highcolor.
* INPUT: d0.w: x coordinate
*        d1.w: y coordinate
*        d2.w: color
*        a0: start of screenaddress
PLOT_PIXEL:
	add.w	d0,d0				* X*2 (for addressing WORDS, not bytes)
	add.w	d0,a0				* Add X-offset.
	mulu.w	#320*2,d1			* Get Y-offset.
	add.l	d1,a0				* Add Y-offset.
	move.w	d2,(a0)				* Put the pixel onscreen.
	rts

	DATA

oldpixel_address:
	DC.L	pixel_table
newpixel_address:
	DC.L	pixel_buffer

pixel_table:
	DC.W	10				* 10 pixels to plot.
	DC.W	160,100,1,1,$ffff		* X, Y, X-speed, Y-speed, color
	DC.W	162,102,1,1,$f800
	DC.W	164,104,1,1,$07e0
	DC.W	166,106,1,1,$001f
	DC.W	168,108,1,1,$f800
	DC.W	170,110,1,1,$07e0
	DC.W	172,112,1,1,$001f
	DC.W	174,114,1,1,$ffff
	DC.W	176,116,1,1,$f800
	DC.W	178,118,1,1,$07e0

	BSS

pixel_buffer:
	DS.W	1
	DS.W	10*5				* This is for double buffering.
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
	DS.L	32000				* Memory to hold one 320*200 highcolor screen.
	DS.L	32000				* Memory to hold one 320*200 highcolor screen.