* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 systm_04.s                                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
set_up	bsr	find_screens	find the addresses of the two screens
	bsr	wrt_scrn1_tbl	write a row address table for screen1
	bsr	wrt_scrn2_tbl	ditto                         screen2
	bsr	hline_lu
	bsr	hide_mse	exterminate the mouse
	bsr	palette_set	set up the shades of blue and red
	bsr	init_joy	insert my joystick handler
	rts
