|//////////////////////////////////////////////////////////////////////////////
|//
|//  This file is part of the Atari Machine Specific Library,
|//  and is Copyright 1992 by Warwick W. Allison.
|//
|//  You are free to copy and modify these sources, provided you acknowledge
|//  the origin by retaining this notice, and adhere to the conditions
|//  described in the file COPYING.
|//
|//////////////////////////////////////////////////////////////////////////////
	.text

	.globl	_JoyISR

_JoyISR:
	movel	#_JoyFlags,a1
	moveq	#0,d0
	movel	sp@(4),a0	| Get joystick packet.
	moveb	a0@(1),d0
	cmpb	#0xFF,a0@
	bne		Joy0
	moveb	a0@(2),d0
	addl	#4,a1
Joy0:	
	movel	d0,a1@

	rts
