* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			3D_05.s                                   *
*              Example program for Part 5                         *
* A program to illustrate illumination and hidden surface removal *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* This is the program to assemble. It includes all the others.
* A rotating ST monolith with hidden surface removal and illumination.

*	SECTION TEXT
	opt	d+
	bra main
	include	systm_02.s	housekeeping file
	include	core_03.s	subroutines
	include	core_04.s	illumination, hidden surface removal

main	bsr	find_screens	find the addresses of the two screens
	bsr	init_LineA	set up Line A pointer
	bsr	hide_mse	exterminate the mouse
	bsr	palette_set	set up the shades of blue and red

* transfer all the data from my lists to program lists
	bsr	transfer
* place it in the world frame
	move.w	#0,Oox		on the ground		
	move.w	#100,Ooz	100 in front
	clr.w	Ooy		dead centre
* Initialize angles for rotation
	clr.w	otheta		
	move.w	#50,ophi	tilt it forward
	clr.w	ogamma
* Initialize screens
	clr.w	screenflag	0=screen 1 draw, 1=screen 2 draw
	bsr	clear1		clear the screens
	bsr	clear2

* Start the rotation about the xw axis 
loop5	move.w	#360,d7		a cycle
loop4	move.w	d7,otheta	next theta
	move.w	d7,-(sp)	save the angle
	tst.w	screenflag	screen 1 or screen2?
	beq	screen_1	draw on screen 1, display screen2
	bsr	draw2_disp1	draw on screen 2, display screen1
	bsr	clear2		but first wipe it clean
	clr.w	screenflag	and set the flag for next time
	bra	screen_2
screen_1:
	bsr	draw1_disp2	draw on 1, display 2
	bsr	clear1		but first wipe it clean
	move.w	#1,screenflag	and set the flag for next time
screen_2:
	bsr	otranw		object-to-world transform

* pass on the new coords
	move.w	oncoords,d7
	move.w	d7,vncoords
	subq.w	#1,d7
	lea	wcoordsx,a0
	lea	wcoordsy,a1
	lea	wcoordsz,a2
	lea	vcoordsx,a3
	lea	vcoordsy,a4
	lea	vcoordsz,a5
loop6	move.w	(a0)+,(a3)+
	move.w	(a1)+,(a4)+
	move.w	(a2)+,(a5)+
	dbra	d7,loop6

* Test for visibility and lighting
	bsr	illuminate	if it's visible find the shade
* Complete the drawing
	bsr	perspective	perspective
	bsr	polydraw	finish the picture
	move.w	(sp)+,d7
* Check for termination
	bsr	scan_keys	has a key been pressed?
	tst	d0		if so
	bne	term		back to caller
	sub.w	#10,d7		otherwise increment in 10 degree steps
	bgt	loop4		next angle
	bra	loop5		or repeat 
term	bsr	rstr_scrn	restore the screen
	move.w	#$4c,-(sp)	terminate and 
	trap	#1		back to caller

*	SECTION DATA
	include	data_01.s
	include	data_03.s
	include	data_04.s
*	SECTION BSS
	include	bss_03.s
	include	bss_04.s
	END
