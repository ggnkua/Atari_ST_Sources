* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 polyfil2.s                                 *
* A program to fast fill a polygon from a set of vertex coordinates *
* using the Bresenham algorithm to determine the outline.           *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*	SECTION TEXT
	opt	d+		put in labels for debugging
	bra main		here's the main program
	include	systm_01.s	include the housekeeping file
	include	core_00.s	and the subroutines

main	bsr	find_phys	locate the physical screen
	bsr	wrt_phys_tbl	set up the screen table
	lea	phys_tbl_y,a0	pointer to screen table
	move.l	a0,screen	pass it
	bsr	hline_lu	set up masks for filling words
	bsr	hide_mse	exterminate the mouse

* Transfer my polygon data to the program data block 
	move.w	#12-1,d7	6 pairs of points for the vertices
	lea	crds_in,a0	to be moved here
	lea	my_data,a1	from here.
loop	move.w	(a1)+,(a0)+	Transfer
	dbra	d7,loop		them all.

	move.w	#5,no_in	5 sides to this polygon
	move.w	my_colour,colour	set the colour

* Generate a polygon outline in xbuf, then scan fill it.
	bsr	poly_fil	set up the buffer and fill it
* If a key is being pressed, control returns to the desktop.
	bsr	scan_keys	has a key
	tst	d0		been pressed?
	beq	loop_again	no, execute again
	move.w	#$4c,-(sp)	gemdos call TERM - terminate
	trap	#1		back to calling program
loop_again:
	bra	main		keep going to cover the mouse (bee)

*	SECTION DATA

* A five-sided polygon (pentagon)
* Here are the vertices (first repeated at the end) in screen coords
* going anticlockwise.
my_data		dc.w	20,100,200,20,300,80,260,180,140,180,20,100
* Here is the colour - blue
my_colour	dc.w	4


*	SECTION	BSS
	include bss_00.s	variables calculated by the program

	END
