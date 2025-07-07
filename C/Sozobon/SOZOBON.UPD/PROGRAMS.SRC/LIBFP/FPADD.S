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
*	fpsub
*
	.globl	fpsub
	.globl	_fpsub
fpsub:
_fpsub:
	eor.b	#$80,11(sp)	* negate B, fall through
*
*	fpadd
*
	.globl	fpadd
	.globl	_fpadd
fpadd:
_fpadd:
	move.l	d3,a1		* save d3
	move.l	4(sp),d0	* A
	move.l	8(sp),d1	* B
	move.b	#$7f,d3

	move.b	d0,d2
	eor.b	d1,d2
	bpl	same_sign
* different signs
	and.b	d3,d0
	and.b	d3,d1

	cmp.b	d0,d1
	bne	sk1
	cmp.l	d0,d1
sk1:
	ble	norev1
	move.l	d0,d2
	move.l	d1,d0
	move.l	d2,d1
	eor.b	#$80,7(sp)
norev1:
	bsr	u_sub_

	tst.b	7(sp)
	bpl	notneg1
	tst.b	d0
	beq	notneg1
	or.b	#$80,d0
notneg1:
	move.l	a1,d3		* restore d3
	rts
* same signs
same_sign:
	and.b	d3,d0
	and.b	d3,d1

	cmp.b	d0,d1
	bne	sk2
	cmp.l	d0,d1
sk2:
	ble	norev2
	move.l	d0,d2
	move.l	d1,d0
	move.l	d2,d1
norev2:
	bsr	u_add_

	tst.b	7(sp)
	bpl	notneg2
	tst.b	d0
	beq	notneg2
	or.b	#$80,d0
notneg2:
	move.l	a1,d3		* restore d3
	rts
*
*	unsigned fp add (d0+d1), d0 >= d1
*
u_add_:
	move.l	d3,a2	* save d3
	move.b	d0,d2	* result exp
	sub.b	d1,d0
	clr.l	d3
	move.b	d0,d3	* diff of exps

	clr.b	d0
	clr.b	d1

	cmp.b	#24,d3
	bge	out1
	lsr.l	d3,d1
	add.l	d1,d0
	bcc	out1
	roxr.l	#1,d0
	addq.b	#1,d2
	bmi	overflow
out1:
	move.l	a2,d3	* restore d3
	move.b	d2,d0
	rts
overflow:
	move.l	a2,d3	* restore d3
	move.l	#$ffffff7f,d0
	rts
*
*	unsigned fp sub (d0-d1), d0 >= d1
*
u_sub_:
	move.l	d3,a2	* save d3
	move.b	d0,d2	* result exp
	sub.b	d1,d0
	clr.l	d3
	move.b	d0,d3	* diff of exps

	clr.b	d0
	clr.b	d1

	cmp.b	#24,d3
	bgt	out2
	lsr.l	d3,d1
	clr.b	d1
	sub.l	d1,d0
	beq	underfl
* normalize
nloop:
	tst.l	d0
	bmi	out2
	asl.l	#1,d0
	subq.b	#1,d2
	bne	nloop
* underflow
underfl:
	move.l	a2,d3	* restore d3
	clr.l	d0
	rts
out2:
	move.l	a2,d3	* restore d3
	move.b	d2,d0
	rts
