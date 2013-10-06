* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991  eulr_scn.s				  *
* 		   A multi-object scene				  *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* A world scene consisting of various types of graphics primitives
* in motion. The viewer is free to "fly" to any location with 
* flight simulator type control from the joystick. At any
* position a patch consisting of 4*4 "tiles" is visible.

*	SECTION TEXT
	opt	d+
	bra main
	include systm_05.s
	include	core_08.s

main:
* Initialize the system.
	bsr	init_vars	initialise view transform
	bsr	flg_init	initialize flags

loop:	
* Read input and make adjustments.
	bsr	swap_scn	swap the screens
	bsr	joy_look	see which direction to move
	bsr	angle_update	change the euler angles
	bsr	wtranv_1	construct the view transform
	bsr	vtran_move	move it to the base vectors
	bsr	in_key		update the speed
	bsr	adj_vel		adjust the velocity
	
* Draw the scene
	bsr	scne_drw	everything to complete the picture

* Draw the next frame
	bra	loop

*	SECTION DATA
	include	data_06.s
	include	data_07.s
	include	data_08.s
*	SECTION BSS
	include bss_07.s

	END
