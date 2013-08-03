* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*				3D_04.s                               *
*           Example program for Part 4. Simple Rotations              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* A rotation of the ST monolith about the z axis.

* This is the file to assemble. It INCLUDE's all the other files.

*	SECTION TEXT
	opt	d+
	bra main
	include	systm_02.s	housekeeping file
	include	core_03.s	important subroutines

main	bsr	find_screens	find the addresses of the two screens
	bsr	init_LineA	set up Line A pointer
	bsr	hide_mse	exterminate the mouse

* Transfer all my data
	move.w	my_npoly,d7	no. of polygons
	beq	term		if none quit
	move.w	d7,npoly	pass it
	subq.w	#1,d7		the counter
	move.w	d7,d0		save it
	lea	my_nedges,a0	source
	lea	snedges,a1	destination
	lea	my_colour,a2	source
	lea	col_lst,a3	destination
loop0	move.w	(a0)+,(a1)+	transfer edge nos.
	move.w	(a2)+,(a3)+	transfer colours
	dbra	d0,loop0	
* Calculate the number of vertices altogether
	move.w	d7,d0		restore count
	lea	my_nedges,a6
	clr	d1
	clr	d2
loop1	add.w	(a6),d1		no more than this 
	add.w	(a6)+,d2	total number of vertices
	addq	#1,d2		and with last one repeated each time
	dbra	d0,loop1	
* Move the edge list
	subq	#1,d2		the counter
	lea	my_edglst,a0	source
	lea	sedglst,a1	destination
loop2	move.w	(a0)+,(a1)+	pass it
	dbra	d2,loop2
* and the coords list
 	move.w	d1,oncoords
	subq	#1,d1		the counter
	lea	ocoordsx,a1
	lea	my_datax,a0
	lea	ocoordsy,a3
	lea	my_datay,a2
	lea	ocoordsz,a5
	lea	my_dataz,a4
loop3	move.w	(a0)+,(a1)+
	move.w	(a2)+,(a3)+
	move.w	(a4)+,(a5)+
	dbra	d1,loop3
* and the window limits
	move.w	my_xmin,xmin	ready
	move.w	my_xmax,xmax	for
	move.w	my_ymin,ymin	clipping
	move.w	my_ymax,ymax

* Place it in the world frame
	move.w	#300,Oox	300 in the air
	move.w	#200,Ooz	200 in front
	clr.w	Ooy		dead centre
* Initialise for rotation
	clr.w	otheta		init angles
	move.w	#50,ophi	tilt it up 50 degrees
	clr.w	ogamma
	clr.w	screenflag	0=screen 1 draw, 1=screen 2 draw
	bsr	clear1		clear the screens
	bsr	clear2
* Start the rotation about the zw axis (can't rotate about the others
* or we'll see the back of it).
loop5	move.w	#360,d7		a cycle
loop4
	move.w	d7,ogamma	next angle gamma 
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
	bsr	otranw		rotational transform
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
* Complete the picture
	bsr	perspective	perspective
	bsr	polydraw	finish the picture
	move.w	(sp)+,d7
* Test for terminate
	bsr	scan_keys	has a key been pressed?
	tst	d0		if so
	bne	term		back to caller
	sub.w	#10,d7		otherwise
	bgt	loop4		next angle
	bra	loop5		or repeat the cycle 
term:
* Stop messing with the screens - draw and display on physical screen
	move.w	#-1,-(sp)
	move.l	screen2,-(sp)
	move.l	screen2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
* Terminate and back to caller
	move.w	#$4c,-(sp)	
	trap	#1		

*	SECTION DATA
	include	data_01.s
	include	data_03.s
*	SECTION BSS
	include	bss_03.s

	END
