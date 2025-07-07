* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
*
* Permission is granted to anyone to use this software for any purpose
* on any computer system, and to redistribute it freely, with the
* following restrictions:
* 1) No charge may be made other than reasonable charges for reproduction.
* 2) Modified versions must be clearly marked as such.
* 3) The authors are not responsible for any harmful consequences
*    of using this software, even if they result from defects in it.
*
*
* _fpdiv
*
	.text
	.globl	_fpdiv
	.globl	fpdiv
fpdiv:
_fpdiv:
	link	a6,#-8
	move.l	12(a6),-(sp)
	jsr	_fpinv
	move.l	d0,-4(a6)
	move.l	-4(a6),(sp)
	move.l	12(a6),-(sp)
	jsr	_fpmul
	addq.w	#8,sp
	move.l	d0,-8(a6)
	move.l	-8(a6),-(sp)
	move.l	#$80000042,-(sp)
	jsr	_fpsub
	addq.w	#8,sp
	move.l	d0,-8(a6)
	move.l	-8(a6),-(sp)
	move.l	-4(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_fpmul
	addq.w	#8,sp
	move.l	d0,-(sp)
	jsr	_fpmul
	unlk	a6
	rts
	.data
*
* _fpinv
*
	.text
	.globl	_fpinv
_fpinv:
	link	a6,#-4
	move.l	d4,-(sp)
	move.l	8(a6),d4
	move.l	d4,d0
	and.l	#127,d0
	move.w	d0,-2(a6)
	move.l	d4,d0
	and.l	#128,d0
	move.w	d0,-4(a6)
	move.w	#129,d0
	sub.w	-2(a6),d0
	move.w	d0,-2(a6)
	cmp.w	#127,-2(a6)
	ble	L6
	move.w	-4(a6),d0
	or.w	#-129,d0
L5:
	move.l	(sp)+,d4
	unlk	a6
	rts
L6:
	swap	d4
	move.l	#$7fffffff,d0
	divu	d4,d0
	move.l	d0,d4
	swap	d4
	clr.w	d4
	move.w	-4(a6),d0
	ext.l	d0
	or.l	d4,d0
	move.w	-2(a6),d1
	ext.l	d1
	or.l	d1,d0
	bra	L5
