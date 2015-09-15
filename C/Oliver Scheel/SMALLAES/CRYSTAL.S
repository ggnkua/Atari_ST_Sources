****************************************************************************
*
*	The Smaller AES-Binding	V1.2	(c) 1991-93 by Oliver Scheel
*
*	crystal.s
*
****************************************************************************

****************************************************************************
* Dieses Binding ist Public Domain. Žnderungen sind genau zu dokumentieren!
****************************************************************************
* This Binding is public domain. Changes have to be documented!
****************************************************************************
*	Autor:	Oliver Scheel
*		Rothehausstr. 28
*		W-5000 K”ln 30 (West-Geramny)
*	Net: 	Oliver_Scheel@k2.maus.de
****************************************************************************

		.globl	_crystal

****************************************************************************

__TC__		equ	1			; Turbo-C switch

****************************************************************************

		.text

_crystal:
.if __TC__
		move.l	a0,d1			; AESPB
.else
		move.l	4(sp),d1		; AESPB
.endif
		movem.l	d2-d3/a0-a3,-(sp)	; save regs
		move.w	#200,d0			; we want AES
		trap	#2
		movem.l	(sp)+,d2-d3/a0-a3	; restore regs
		rts

		.end
