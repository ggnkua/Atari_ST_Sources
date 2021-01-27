*	Created by TT-Digger v7.1
*	Fri Sep 07 21:19:10 2007

*	TT-Digger v7

	globl	ecvt, fcvt, ftoa

#define ndig d0
#define fsw  d1
#define pbuf a2
#define x fp0
#define y fp1

	data
buf:
	ds 		34

	text
* fp0 value D0 ndig A0 *dec A1 *sign

ecvt:
	clr 	fsw
	bra.s	L3688

fcvt:
	move	#1,fsw
L3688:
	move.l	a2,-(a7)
	move.l	d3,-(a7)
	lea 	buf.l,pbuf
	ext.l	ndig
	cmp.l 	#32,ndig
	bls.s	L3728
	moveq	#32,ndig
L3728:
	ftst	x
	fbeq 	L3882
	fslt	(a1)
	fabs	x
	flog10	x,y
	fmove.l	FPCR,d2
	moveq	#32,d3
	fmove.l	d3,FPCR
 	fint	y
	fmove.l	d2,FPCR
	fmove.l	y,d2
	addq.l	#1,d2
	move	d2,(a0)
	tst 	fsw
	ble.s	L3782
	add.l 	d2,ndig
L3782:
	ftentox	y
	fdiv	y,x
	fneg.l	ndig,y
	ftentox	y
	moveq	#5,d3
	fmul	d3,y
	fadd	y,x
	moveq	#10,d3
	fmove	d3,fp2
	fcmp	fp2,x
	fblt 	L3828
	move	(a0),d3
	ext.l	d3
	addq.l	#1,d3
	move	d3,(a0)
	fdiv	fp2,x
L3828:
	subq.l	#1,ndig
	bge.s	L3838
	move.b	#48,(pbuf)+
	bra.s	L3864

L3838:
	fintrz	x,y
	fsub	y,x
	fmove.l	y,d2
	add.l	#48,d2			; '0'
	move.b	d2,(pbuf)+
	fmul	fp2,x
	subq.l 	#1,ndig
	cmp.l	#-1,ndig
	bne 	L3838
L3864:
	clr.b	(pbuf)
	clr.l 	ndig
	lea 	buf.l,a0
	move.l	(a7)+,d3
	movea.l	(a7)+,a2
	rts

L3878:
	move.b	#48,(pbuf)+		; '0'
L3882:
	subq.l 	#1,ndig
	cmp.l	#-1,ndig
	bne 	L3878
	clr.b	(pbuf)
	clr 	(a0)
	clr.b	(a1)
	bra.s	L3864


