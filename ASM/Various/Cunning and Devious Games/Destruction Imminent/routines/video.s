	*A:\VIDEO.S
	********************************************************
	*           double buffered screen routines            *
	*     screen2 is always visible, screen1 is hidden     *
	*    initvideo - initialises routines (corrupts a0)    *
	*scrnswap - swaps screen1 with screen2 (corrupts a0-a1)*
	********************************************************

initvideo	move.b	#0,$ff8260	Switch to low resolution
	move.l	#screen2,a0	Get screen address
	move.b	1(a0),$ff8201	Set high byte
	move.b	2(a0),$ff8203	Set low byte
	rts			Return

scrnswap	move.l	screen1,a0	Address of screen 1
	move.l	screen2,a1	Address of screen 2
	move.l	a0,screen2	Swap screen 1
	move.l	a1,screen1	With screen 2
	move.l	#screen2,a0	Get screen address
	move.b	1(a0),$ff8201	Set high byte
	move.b	2(a0),$ff8203	Set low byte
	rts			Return

screen1	dc.l	$f8000		Position of screen 1
screen2	dc.l	$f0000		Position of screen 2