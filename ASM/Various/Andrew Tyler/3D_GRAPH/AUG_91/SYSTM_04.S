* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 systm_04.s                                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	include systm_03.s

set_up	bsr	find_screens	find the addresses of the two screens
	bsr	init_LineA	line A pointers
	bsr	hide_mse	exterminate the mouse
	bsr	palette_set	set up the shades of blue and red
	rts

		
