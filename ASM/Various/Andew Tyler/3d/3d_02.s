* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*			   3D_02.s                                  *
* A PROGRAM TO CLIP AND FAST FILL A POLYGON TO A WINDOW (CLIP FRAME)*
* DEFINED BY THE LIMITS STORED AT xmin, xmax, ymin and ymax.        *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* THIS IS THE PROGRAM YOU SHOULD ASSEMBLE. IT INCLUDES ALL THE OTHERS

*	SECTION TEXT
	opt	d+		debugging info
	bra main		don't run the includes
	include	systm_01.s	the housekeeping file
	include	core_01.s	and the subroutines

main	
*	initialization
	bsr	init_LineA	fetch the parameters pointer
	dc.w	$a00a		hide the mouse
	bsr	find_screens	find the two screen addresses
	bsr	clear1		wipe them clean
	bsr	clear2
	clr.w	screenflag	0 = draw on screen1; display screen2
	bsr	init_LineA	fetch the parameters pointer
* initialise the screens
	bsr	clear1		
* windowing with an widening clip frame
loop_again:
	move.w	#99,d5		y clip half range
	move.w	#159,d6		x clip half range
clp_loop1:
* Set up the data
	move.w	#12-1,d7	6 pairs of points for the vertices
	lea	crds_in,a0	destination
	move.l	a0,a3		ready for drawing
	lea	my_data,a1	from here
clp_loop0	
	move.w	(a1)+,(a0)+	transfer
	dbra	d7,clp_loop0	them all
	move.w	#5,no_in	5 sides to this polygon
	move.w	my_colour,colour	set the colour
* Set up the next clip frame
	move.w	#199,ymax	set
	sub.w	d5,ymax		the
	move.w	d5,ymin		clip	
	move.w	#319,xmax	frame
	sub.w	d6,xmax		limits
	move.w	d6,xmin
	movem.w	d5/d6,-(sp)	save clip frame
	tst.w	screenflag	screen1 or screen2?
	beq	screen_1	draw on screen1, display screen2
	bsr	draw2_disp1	draw on screen2, display screen1
	bsr	clear2		first wipe it clean
	clr.w	screenflag	set the flag for next time
	bra	screen_2
screen_1:
	bsr	draw1_disp2	draw 1, display 2
	bsr	clear1		first wipe it clean
	move.w	#1,screenflag	and set for next time
screen_2:
	bsr	clip		window it
	bsr	poly_fil	fill it
	movem.w	(sp)+,d5/d6	restore clip frame 
	subq.w	#2,d6		else reduce
	dbf	d5,clp_loop1	the clip frame
	bra	loop_again	repeat the cycle
out	clr.w	-(sp)
	trap	#1

*	SECTION DATA
	include	data_00.s
* A pentagon
my_data		dc.w	20,100,200,20,300,80,260,180,140,180,20,100
* which is blue
my_colour	dc.w	4

*	SECTION BSS
	include bss_01.s

	END
