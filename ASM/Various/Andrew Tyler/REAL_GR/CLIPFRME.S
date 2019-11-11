* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991	Clipfrme.s                          *
* A program to clip and fast fill a polygon to a window (clip frame)*
* defined by the limits stored at xmin, xmax, ymin and ymax.        *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	SECTION TEXT
	opt	d+		debugging info
	bra main
	include	systm_01.s	the housekeeping file
	include	core_01.s	and the subroutines

main	bsr	find_phys	locate the physical screen
	bsr	wrt_phys_tbl	where the rows start
	lea	phys_tbl_y,a0	the row look-up table pointer
	move.l	a0,screen	pass it
	bsr	hline_lu	the masks for filling words
	bsr	hide_mse	exterminate the mouse
* Set up the data
	move.w	#12-1,d7	6 pairs of points for the vertices
	lea	crds_in,a0	destination
	move.l	a0,a3		ready for drawing
	lea	my_data,a1	from here
clp_loop	
	move.w	(a1)+,(a0)+	transfer
	dbra	d7,clp_loop		them all

	move.w	#5,no_in	5 sides to this polygon
	move.w	my_colour,colour	set the colour
	move.w	my_xmin,xmin	set the
	move.w	my_xmax,xmax	clip
	move.w	my_ymin,ymin	frame
	move.w	my_ymax,ymax	limits
	bsr	clip		window it
	bsr	poly_fil	fill it
loop_again:
	bsr	scan_keys	has a key been pressed?
	tst	d0
	beq	loop_again	no, try again
	move.w	#$4c,-(sp)
	trap	#1

*	SECTION DATA
* A pentagon
my_data		dc.w	20,100,200,20,300,80,260,180,140,180,20,100
* which is blue
my_colour	dc.w	4
my_xmin		dc.w	50
my_xmax		dc.w	270
my_ymin		dc.w	50
my_ymax		dc.w	150

*	SECTION BSS
	include bss_01.s

	END
