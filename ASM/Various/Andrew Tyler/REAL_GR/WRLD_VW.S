* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 wrld_vw.s				      *
*           Joystick control of the view frame                        *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*	SECTION TEXT
	opt	d+
	bra main
	include	systm_02.s	screens and tables
	include	systm_03.s	joystick
	include	systm_04.s	set up screens, palette, joystick
	include	core_06.s	new subroutines

main:	
	bsr	set_up		set up screens etc
* transfer all the data
	bsr	transfer
	move.w	oncoords,vncoords
	move.w	vncoords,wncoords
* Initialise dynamical variables
	move.w	#0,Ovx		view frame 
	move.w	#0,Ovy		starts off
	move.w	#-200,Ovz	200 behind world frame
* Set up view frame base vectors
* 1. iv
	lea	iv,a0		align 
	move.w	#$4000,(a0)+	view
	clr.w	(a0)+		frame
	clr.w	(a0)		axes
* 2. jv
	lea	jv,a0		with
	clr.w	(a0)+		the
	move.w	#$4000,(a0)+	world
	clr.w	(a0)		frame
* 3. kv
	lea	kv,a0		axes
	clr.w	(a0)+
	clr.w	(a0)+
	move.w	#$4000,(a0)

	clr.w	speed		start at rest
	clr.w	screenflag	0=screen 1 draw, 1=screen 2 draw
	clr.w	viewflag
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
* Look for changes in the view frame angles.
	bsr	in_joy		read joystick and rotate the view frame
* See if the function keys have been pressed to change the speed.
	bsr	key_in		
* Adjust to new velocity.
	bsr	vel_adj
* Recalculate the view frame base vectors and set up the world-view 
* transform matrix.
	bsr	dircosines
* See if the object is within the visible angle of view.
	bsr	viewtest
	tst.b	viewflag	is it visible?
	beq	loop4		no, try again
* Construct the compound object from the same face at different positions.
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
	bsr	w_tran_v	world to view transform
	bsr	illuminate	if it's not hidden find the shade
	bsr	perspective	perspective
	bsr	scrn_adj	centre window
	bsr	polydraw	draw this face
	movem.l	(sp)+,a0/a1	restore pointers
	move.w	(sp)+,d7	restore the parts count
	dbra	d7,instance	for all the parts of the object
	bra	loop4		draw the next frame

*	SECTION DATA
	include	data_03.s
	include	data_05.s
*	SECTION BSS
	include	bss_06.s

	END
