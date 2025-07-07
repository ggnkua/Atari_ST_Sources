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
*	fpmul
*
	.globl	_fpmult
	.globl	_fpmul
	.globl	fpmul
fpmul:
_fpmul:
_fpmult:
	move.l	d3,a1		* save d3
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.b	d0,d2
	beq	ret0
	move.b	d1,d3
	beq	ret0

	and.b	#$7f,d0
	and.b	#$7f,d1
	eor.b	d2,d3
	bpl	mpos
* result negative
	movem.l	d4-d5,-(sp)
	bsr	_u_mul
	movem.l	(sp)+,d4-d5
	tst.b	d0
	beq	ret0
	move.l	a1,d3		* restore d3
	or.b	#$80,d0
	rts
* result positive
mpos:
	movem.l	d4-d5,-(sp)
	bsr	_u_mul
	movem.l	(sp)+,d4-d5
	move.l	a1,d3		* restore d3
	rts
ret0:
	move.l	a1,d3		* restore d3
	clr.l	d0
	rts

_u_mul:
	move.l	d3,a2		* save d3
	move.b	d0,d2
	add.b	d1,d2
	cmp.b	#$40,d2
	bls	underfl
	cmp.b	#$bf,d2
	bhi	overfl
	sub.b	#$40,d2		* result exp

	clr.b	d0
	clr.b	d1
	move.w	d0,d3
	mulu.w	d1,d3
*	clr.w	d3	already 0 since low bytes 0
	swap	d3

	move.w	d0,d4
	move.w	d1,d5
	swap	d0
	swap	d1
	mulu	d0,d5
	mulu	d1,d4
	add.l	d3,d4	* no carry since d3 <= fe01 && d4 <= fffe0001
	add.l	d4,d5
	bcc	nocar
	move.w	#1,d5
	bra	t1
nocar:
	clr.w	d5
t1:
	swap	d5

	mulu	d1,d0
	add.l	d5,d0
	bcc	nocar2
	roxr.l	#1,d0
	addq.b	#1,d2
	bmi	overfl
	bra	norm
nocar2:
	bmi	norm
	add.l	d0,d0	* only need at most 1 shift since started norm AB
	subq.b	#1,d2
	beq	underfl
norm:
	tst.b	d0
	bpl	noround
	add.l	#$80,d0
	bcc	nocar3
	roxr.l	#1,d0
	addq.b	#1,d2
	bmi	overfl
nocar3:
noround:
	move.l	a2,d3		* restore d3
	move.b	d2,d0
	rts

underfl:
	move.l	a2,d3		* restore d3
	clr.l	d0
	rts
overfl:
	move.l	a2,d3		* restore d3
	move.l	#$ffffff7f,d0
	rts
