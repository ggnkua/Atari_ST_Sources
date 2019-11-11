* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 polyfil0.s                                 *
* A program to fill a polygon using the Line A routine $a004 .      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*	SECTION TEXT

main	bsr 	poly		fill the buffer with x coordinates
	bsr	a004		use the x coords to draw the lines
	bra	main		keep going to cover the mouse	

* A subroutine to fill the buffer with x values 16 and 256 to scan fill
* a rectangle between the limits x=16 to x=256 and y=50 to y=150.
poly	lea	xbuf,a0		point to start of buffer
	move	#50,d0		initial y=50
	lsl	#2,d0		*4 for the offset into the table
	adda.w	d0,a0		pointer to the initial long word
	move.l	#$00100100,d0	high word=16,low word=256
	move	#100-1,d7	fill 100 lines (up to y=150)
poly1	move.l	d0,(a0)+	fill the next long word
	dbra	d7,poly1	for all the y values
	rts
* Initialise the  a-line parameter block. Find its address.
a004	dc.w	init		returns the address in a0
* Set the constants for a horizontal line
	move.w	#1,fg_bp1(a0)	Set
	clr.w	fg_bp2(a0)	for
	clr.w	fg_bp3(a0)	mono-
	clr.w	fg_bp4(a0)	chrome
	clr.w	wrt_mod(a0)	overwrite.
	lea	fill,a2		Here is 
	move.l	a2,patptr(a0)	the fill pattern
	move.w	#4-1,patmsk(a0)	consisting of 4 lines.
	clr.w	multifil(a0)	The pattern is for one plane.
* Fill a line at a time using the $a004 routine.
	lea	xbuf,a1		pointer to base address
	move	#50,d1		start at y=50 
	move	d1,d2		save it
	lsl.w	#2,d1		y*4 is the offset into the table	
	adda.w	d1,a1		here is the first line
	move	#100-1,d7	draw 100 lines (counter is 1 less)
	subq	#1,d2		reduce initial y
	move.w	d2,y1(a0)	for the loop
* Here is the loop which fills each scan line in succession
poly2	addq.w	#1,y1(a0)	next y in the loop
	move.w	(a1)+,x1(a0)	next x1
	move.w	(a1)+,x2(a0)	next x2
	movem.l	d7/a0-a1,-(sp)	save the registers
	dc.w	hline		draw the line
	movem.l	(sp)+,d7/a0-a1	restore the registers
	dbra	d7,poly2	repeat for all y values
	rts
	
*	SECTION DATA
	include	data_00.s	add in the data file
 
*	SECTION BSS
xbuf	ds.l	100		all the scan line x-coords.		

	END
