* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 systm_01.s                                 *
* Subroutines and calls to the operating system in Chapter 4.       *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	include systm_00.s
scan_keys:
* See if a key has been pressed; don't wait (BIOS call BCONSTAT).
* returns -1 in d0 if a key was pressed
	move.w	#2,-(sp)	look at the keyboard
	move.w	#1,-(sp)	was a key pressed?
	trap	#13		bios call
	addq.l	#4,sp		tidy stack
	rts

read_key:
* Read a character from the keyboard; wait for it (BIOS call BCONIN).
* returns the code in the lower byte of the upper word of d0
	move.w	#2,-(sp)	look at the keyboard
	move.w	#2,-(sp)	wait for a key press
	trap	#13		bios call
	addq.l	#4,sp		tidy stack
	rts

hide_mse:
* Exterminate the mouse
	dc.w	$a000		init. a-line
	dc.w	$a00a		hide mouse
        rts
                                                            