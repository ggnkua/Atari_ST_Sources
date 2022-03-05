* FPDIV.S -- floating point divide	
* Copyright = David Brooks, 1989 All Rights Reserved
*
* This version works by a normal bitwise shift/subtract loop, with separate
* handling of the exponent and a final normalization.  26 bits are computed,
* to allow one normalization and one rounding step.  A certain amount of
* black magic and handwaving are involved, but please note that at no time
* do any bits leave the confines of the computer.
*
* Round-to-even is used for the ambiguous rounding case.
*
* float fpdiv(num, denom); (_fpdiv for explicit call; fpdiv for compiled /)

	.globl	fpdiv
	.globl	_fpdiv

fpdiv:
_fpdiv:
	move.l	d3,a1			* We don't need no wimpy stack frame
	moveq.l	#0,d0
	move.l	4(sp),d1
	beq	exit			* Numerator 0 - all done
	move.l	8(sp),d2
	beq	div0			* Divide by 0 - overflow
	clr.b	d1			* Work with mantissas
	clr.b	d2
	move.l	#$2000000,d3		* Position of msb of 26-bit field
cmpbit:
	cmp.l	d2,d1			* Compare against new divisor
	blo	nobit
	add.l	d3,d0			* Add in this bit
	sub.l	d2,d1			* and adjust
nobit:
	lsr.l	#1,d2
	lsr.l	#1,d3
	bne	cmpbit			* Done 26 bits?

	lsl.l	#6,d0			* Reposition
	tst.l	d1			* If there was a remainder...
	beq	doexp
	addq.l	#2,d0			* record a memory of it.  The 2 bit
					* .won't be lost by either of the
					* ..subsequent normalizations
doexp:
	moveq.l	#$7F,d1			* Calculate new exponent
	move.l	d1,d2
	and.b	7(sp),d1
	and.b	11(sp),d2
	sub.w	d2,d1
	add.w	#$41,d1			* Adjust
	tst.l	d0			* Check for already normalized or zero
	bmi	normok
normloop:
	subq.w	#1,d1			* Do one normalize step (there can't
	add.l	d0,d0			* .be more)
normok:
	add.l	#$80,d0			* Round up in most cases
	bcc	round1
	roxr.l	#1,d0			* The rounding caused overflow, sigh
	addq.w	#1,d1
round1:
	tst.b	d0			* See if trailer was exactly 0x80
	bne	ckexp
	and.w	#$FE00,d0		* It was: round to even

ckexp:					* Check exponent for sanity
	tst.w	d1
	ble	underflow
	cmp.w	#$7F,d1
	bgt	overflow
setexp:
	move.b	d1,d0			* Set exponent

	move.b	7(sp),d1		* Get signs
	move.b	11(sp),d2
	eor.b	d2,d1			* Form new sign
	and.b	#$80,d1			* Extract it
	or.b	d1,d0
exit:
	move.l	a1,d3
	rts
div0:
overflow:
	moveq.l	#$FFFFFFFF,d0
	moveq.l	#$7F,d1
	bra	setexp

underflow:
	moveq.l	#0,d0
	bra	exit

	.end
