* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991     3D_06.s                                *
*               A Rotating 3D ST Cube for Part 6                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*	SECTION TEXT
	opt	d+
	bra main
	include	systm_04.s	screens and tables
	include	core_05.s	motion of the view frame
*********************************************************************
main	bsr	set_up		set up screens, line A, palette	
* transfer all the data
	bsr	transfer
	move.w	oncoords,vncoords
	move.w	vncoords,wncoords
* Initialise dynamical variables
	move.w	#-50,Ovx	view frame initial position
	move.w	#0,Ovy
	move.w	#150,Ovz
	clr.w	vtheta		initialize rotation angles to zero
	clr.w	vphi
	clr.w	vgamma
	clr.w	shearflg	set flag to no shear
	move.w	#25,vtheta_inc	initial rotation rates
	move.w	#25,vphi_inc
	clr.w	speed		
	clr.w	screenflag	0=screen 1 draw, 1=screen 2 draw
	bsr	clear1		clear the screens
	bsr	clear2
loop4:	
* Switch the screens each time round	
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
* look for changes in the rotation angles 
* see if the function keys have been pressed to change the speed
* or initiate a shear
	bsr	key_in
* Adjust to new rotation angles and speed
	bsr	angle_update
	bsr	speed_adj
* Construct the compound object from the same face at different positions
	move.w	nparts,d7	how many parts in the object
	subq	#1,d7
	lea	inst_angles,a0	list of instance angles for each part
	lea	inst_disp,a1	ditto	    displacements
* Do one face at a time
instance:
	move.w	d7,-(sp)	save the count
	move.w	(a0)+,otheta	next otheta
	move.w	(a0)+,ophi	next ophi
	move.w	(a0)+,ogamma	next ogamma
	move.w	(a1)+,Oox	next displacements
	move.w	(a1)+,Ooy
	move.w	(a1)+,Ooz
	movem.l	a0/a1,-(sp)	save position in list	
	bsr	otranw		object to world transform
	bsr	wtranv_1	construct the rotation transform
	bsr	shear		concatenate with shear (if flag set)
	bsr	wtranv_2	and transform the points
	bsr	illuminate	if it's visible find the shade
	bsr	perspective	perspective
	bsr	polydraw	draw this face
	movem.l	(sp)+,a0/a1	restore pointers
	move.w	(sp)+,d7	restore the parts count
	dbra	d7,instance	for all the parts of the object
	bra	loop4		draw the next frame
*	SECTION DATA
	include	data_03.s
	include	data_05.s
*	SECTION BSS
	include	bss_05.s

	END
