*	Created by TT-Digger v7.1
*	Fri Sep 07 21:19:10 2007

*	TT-Digger v7

	globl	ecvt, fcvt, ftoa

	data
buf:
	ds 		34

	text
* fp0 value D0 ndig A0 *dec A1 *sign

ecvt:
	clr 	d1
	bra.s	L3688

fcvt:
	move	#1,d1
L3688:
	move.l	a2,-(a7)
	move.l	d3,-(a7)
	lea 	buf.l,a2
	ext.l	d0
	cmp.l 	#32,d0
	bls.s	L3728
	moveq	#32,d0
	bra.s	L3728

ftoa:
	move.l	a2,-(a7)
	move.l	d3,-(a7)
#ifdef __DOUBLE_64__
	fmove.d	(a0),fp0
#else
	fmove.x	(a0),fp0
#endif
	movea.l	a1,a2
	movea.l	12(a7),a0
L3722:
	movea.l	16(a7),a1
	clr 	(a1)
L3728:
	ftst	fp0
	fbeq 	L3882
	fslt	(a1)
	fabs	fp0
	flog10	fp0,fp1
	fmove.l	FPCR,d2
	moveq	#32,d3
	fmove.l	d3,FPCR
 	fint	fp1

	fmove.l	d2,FPCR
	fmove.l	fp1,d2
	addq.l	#1,d2
	move	d2,(a0)
	tst 	d1
	ble.s	L3782
	add.l 	d2,d0
L3782:
	ftentox	fp1
	fdiv	fp1,fp0
	fneg.l	d0,fp1
	ftentox	fp1
	moveq	#5,d3
	fmul	d3,fp1
	fadd	fp1,fp0
	moveq	#10,d3
	fmove	d3,fp2
	fcmp	fp2,fp0			; 10 :: x
	fblt 	L3828
	move	(a0),d3			; >=
	ext.l	d3
	addq.l	#1,d3
	move	d3,(a0)
	fdiv	fp2,fp0
L3828:
	subq.l	#1,d0
	bge.s	L3838
	move.b	#48,(a2)+
	bra.s	L3864

L3838:
	fintrz	fp0,fp1
	fsub	fp1,fp0
	fmove.l	fp1,d2
	add.l	#48,d2
	move.b	d2,(a2)+
	fmul	fp2,fp0
	subq.l 	#1,d0
	cmp.l	#-1,d0
	bne 	L3838
L3864:
	clr.b	(a2)
	clr.l 	d0
	lea 	buf.l,a0
	move.l	(a7)+,d3
	movea.l	(a7)+,a2
	rts

L3878:
	move.b	#48,(a2)+
L3882:
	subq.l 	#1,d0
	cmp.l	#-1,d0
	bne 	L3878
	clr.b	(a2)
	clr 	(a0)
	clr.b	(a1)
	bra.s	L3864


