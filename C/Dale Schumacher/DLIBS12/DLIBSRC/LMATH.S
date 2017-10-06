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
	.text
	.globl	ldiv
ldiv:
	move.l	4(a7),d0
	bpl	ld1
	neg.l	d0
ld1:
	move.l	8(a7),d1
	bpl	ld2
	neg.l	d1
	eor.b	#$80,4(a7)
ld2:
	bsr	i_ldiv		/* d0 = d0/d1 */
	tst.b	4(a7)
	bpl	ld3
	neg.l	d0
ld3:
	rts

	.globl	lmul
lmul:
	move.l	4(a7),d0
	bpl	lm1
	neg.l	d0
lm1:
	move.l	8(a7),d1
	bpl	lm2
	neg.l	d1
	eor.b	#$80,4(a7)
lm2:
	bsr	i_lmul		/* d0 = d0*d1 */
	tst.b	4(a7)
	bpl	lm3
	neg.l	d0
lm3:
	rts

	.globl	lrem
lrem:
	move.l	4(a7),d0
	bpl	lr1
	neg.l	d0
lr1:
	move.l	8(a7),d1
	bpl	lr2
	neg.l	d1
lr2:
	bsr	i_ldiv		/* d1 = d0%d1 */
	move.l	d1,d0
	tst.b	4(a7)
	bpl	lr3
	neg.l	d0
lr3:
	rts

	.globl	ldivu
ldivu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	bsr	i_ldiv
	rts

	.globl	lmulu
lmulu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	bsr	i_lmul
	rts

	.globl	lremu
lremu:
	move.l	4(a7),d0
	move.l	8(a7),d1
	bsr	i_ldiv
	move.l	d1,d0
	rts

* A in d0, B in d1, return A*B in d0
i_lmul:
	move.l	d3,a2		/* save d3 */
	move.w	d1,d2
	mulu	d0,d2		/* d2 = Al * Bl */

	move.l	d1,d3
	swap	d3
	mulu	d0,d3		/* d3 = Al * Bh */

	swap	d0
	mulu	d1,d0		/* d0 = Ah * Bl */

	add.l	d3,d0		/* d0 = (Ah*Bl + Al*Bh) */
	swap	d0
	clr.w	d0		/* d0 = (Ah*Bl + Al*Bh) << 16 */

	add.l	d2,d0		/* d0 = A*B */
	move.l	a2,d3		/* restore d3 */
	rts

*A in d0, B in d1, return A/B in d0, A%B in d1
i_ldiv:
	tst.l	d1
	bne	nz1

*	divide by zero
	divu	#0,d0		/* cause trap */
	move.l	#$80000000,d0
	move.l	d0,d1
	rts
nz1:
	move.l	d3,a2		/* save d3 */
	cmp.l	d1,d0
	bhi	norm
	beq	is1
*	A<B, so ret 0, rem A
	move.l	d0,d1
	clr.l	d0
	move.l	a2,d3		/* restore d3 */
	rts
*	A==B, so ret 1, rem 0
is1:
	moveq.l	#1,d0
	clr.l	d1
	move.l	a2,d3		/* restore d3 */
	rts
*	A>B and B is not 0
norm:
	cmp.l	#1,d1
	bne	not1
*	B==1, so ret A, rem 0
	clr.l	d1
	move.l	a2,d3		/* restore d3 */
	rts
*  check for A short (implies B short also)
not1:
	cmp.l	#$ffff,d0
	bhi	slow
*  A short and B short -- use 'divu'
	divu	d1,d0		/* d0 = REM:ANS */
	swap	d0		/* d0 = ANS:REM */
	clr.l	d1
	move.w	d0,d1		/* d1 = REM */
	clr.w	d0
	swap	d0
	move.l	a2,d3		/* restore d3 */
	rts
* check for B short
slow:
	cmp.l	#$ffff,d1
	bhi	slower
* A long and B short -- use special stuff from gnu
	move.l	d0,d2
	clr.w	d2
	swap	d2
	divu	d1,d2		/* d2 = REM:ANS of Ahi/B */
	clr.l	d3
	move.w	d2,d3		/* d3 = Ahi/B */
	swap	d3

	move.w	d0,d2		/* d2 = REM << 16 + Alo */
	divu	d1,d2		/* d2 = REM:ANS of stuff/B */

	move.l	d2,d1
	clr.w	d1
	swap	d1		/* d1 = REM */

	clr.l	d0
	move.w	d2,d0
	add.l	d3,d0		/* d0 = ANS */
	move.l	a2,d3		/* restore d3 */
	rts
*	A>B, B > 1
slower:
	move.l	#1,d2
	clr.l	d3
moreadj:
	cmp.l	d0,d1
	bhs	adj
	add.l	d2,d2
	add.l	d1,d1
	bpl	moreadj
* we shifted B until its >A or sign bit set
* we shifted #1 (d2) along with it
adj:
	cmp.l	d0,d1
	bhi	ltuns
	or.l	d2,d3
	sub.l	d1,d0
ltuns:
	lsr.l	#1,d1
	lsr.l	#1,d2
	bne	adj
* d3=answer, d0=rem
	move.l	d0,d1
	move.l	d3,d0
	move.l	a2,d3		/* restore d3 */
	rts
