* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 wrld_scn.s				*
* 		A multi-object scene				*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* A world scene consisting of various types of graphics primitives
* in motion. The viewer is free to "fly" to any location. At any
* position a patch consisting of 4*4 "tiles" is visible.
* Joystick controls Yaw and pitch. F1 and F2 control roll
* Don't hold down keys as keyboard buffer is not cleared. 

*	SECTION TEXT
	opt	d+
	bra main
	include systm_05.s
	include	core_07.s

main:
* Initialize the system.
	bsr	init_vars	initialise view transform
	bsr	flg_init	initialize flags

loop:	
* Read input and make adjustments.
	bsr	swap_scn	swap the screens
	bsr	dircosines	regenerate view matrix
	bsr	joy_read	see which direction to move
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
