* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 ramview.s                                *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* A look at what goes on in the GEM variables area
* Display the bottom 32K of user RAM on the screen
* While it's on view you can use the keyboard, joystick or mouse
* to see where data is being altered. The screen is 32k long and
* starts at 2049 so with a ruler you can measure where in RAM the 
* variables are located.
* set up the screen

main	move.w	#-1,-(sp)	ignore resolution
	move.l	#2049,-(sp)	physical screen = bottom of user RAM
	move.l	#-1,-(sp)	forget the logical screen
	move.w	#5,-(sp)	xbios_setscreen
	trap	#14
	add.l	#12,sp		tidy
loop	bra	loop		idle
