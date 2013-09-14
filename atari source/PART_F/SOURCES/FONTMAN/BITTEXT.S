*******************************************************************************
*	BITTEXT.S
*
*	Kenneth Soohoo	January 8, 1990
*	Copyright 1990 Atari Corporation
*
*
*******************************************************************************
*
*	void text_to_bitmap(screen, width, planes)
*	long screen;
*	int width, planes;
*
*	Directs text output (via line-a variable tweaks) to any memory
*	location (word aligned), with any form width (in bytes), in 
*	1, 2, or 4 planes.  Saves the currrent, applicable varibales
*	for restoration with the text_to_screen() call.
*	Returns nothing.
*
*	void text_to_screen()
*	
*	Restores the line-a variables to the values previous to the
*	text_to_bitmap() call.  Text_to_bitmap() must have been called
*	before, in order to set up.
*
*******************************************************************************

	.include "atari.s"

	.globl	_text_to_bitmap
	.globl	_text_to_screen

LINEA_INIT	=	$A000		; get line A pointers

WIDTH		=	2
BYTES_LIN	=	-2
PLANES		=	0

	.text

_text_to_bitmap:
	link	a6, #0
	movem.l	d2-d7/a2-a5, -(sp)

	Logbase
	move.l	d0, oldadrs
	move.l	8(a6), d0		; point logical base over here!
	Setscreen d0, #-1, #-1

	dc.w	LINEA_INIT		; get line A pointers

	move.w	12(a6), d0		; Width of screen in bytes
	move.w	BYTES_LIN(a0), oldwidth
	move.w	d0, BYTES_LIN(a0)	; set bytes per line
	move.w	d0, WIDTH(a0)

	move.w	PLANES(a0), oldplanes
	move.w	14(a6), PLANES(a0)	; set number of planes

	movem.l	(sp)+, d2-d7/a2-a5
	unlk	a6

	rts

	.even
_text_to_screen:
	link	a6, #0
	movem.l	d2-d7/a2-a5, -(sp)
	
	move.l	oldadrs, d0		; move all the old values for
	Setscreen d0, #-1, #-1

	dc.w	LINEA_INIT		; get line A pointers

	move.w	oldwidth, BYTES_LIN(a0)
	move.w	oldwidth, WIDTH(a0)
	move.w	oldplanes, PLANES(a0)

	movem.l	(sp)+, d2-d7/a2-a5
	unlk	a6

	rts

*
*	Storage area for swap out of line-a variables for screen
*
	.data
	.even
oldadrs:	.dc.l	1
	.even
oldwidth:	.dc.w	1
oldplanes:	.dc.w	1
