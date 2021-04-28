* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 systm_03.s                                   *
* Reading the keyboard in Part 6                                      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include systm_02.s

read_key:
* reads in a character from the keyboard; wait for it
* returns the code in the lower byte of upper word of d0
	move.w	#2,-(sp)	look at keyboard
	move.w	#2,-(sp)	wait for key press
	trap	#13		BIOS call
	addq.l	#4,sp		tidy stack
	rts

