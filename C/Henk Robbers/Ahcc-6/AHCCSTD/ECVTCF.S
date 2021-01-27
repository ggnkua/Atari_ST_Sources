*	Created by TT-Digger v7.1
*	Fri Sep 07 21:19:10 2007

*	TT-Digger v7
*	Hacked by H.Robbers for use on Coldfire CPU's

#define FPU 0
	globl	ecvtcf, ecvt, log10, pow10, tus1, tus2, sfint, slog10

	data
buf:
	ds 		34

	text

* fp0 value d0 ndig a0 *dec a1 *sign

ecvtcf:
	ext.l	d0
	cmp.l 	#32,d0
	bls.s	L3728
	moveq	#32,d0
L3728:
	clr.b	(a1)
	ftst	fp0
	fbeq 	L3882
	fslt	(a1)
	lea 	buf.l,a1
	fabs	fp0
#if FPU
	flog10	fp0,fp1
#else
	move.l	a0, -(sp)
	move.l	a1, -(sp)
	move.l	d0, -(sp)
	move.l	d1, -(sp)
	move.l	d2, -(sp)
	fmove.d	fp0, -(sp)
	jsr 	log10
	fmove	fp0,fp1
	fmove.d	(sp)+, fp0
	move.l	(sp)+, d2
	move.l	(sp)+, d1
	move.l	(sp)+, d0
	move.l	(sp)+, a1
	move.l	(sp)+, a0
#endif

	fmove.l	FPCR,d1
	moveq	#32,d2
	fmove.l	d2,FPCR
	fint	fp1
	fmove.l	d1,FPCR

	fmove.l	fp1,d1
	addq.l	#1,d1
	move	d1,(a0)
	move	d1, tus1

#if FPU
	ftentox	fp1
#else
	move.l	a0, -(sp)
	move.l	a1, -(sp)
	move.l	d0, -(sp)
	move.l	d1, -(sp)
	move.l	d2, -(sp)
	fmove.d	fp0,-(sp)
	fmove.l	fp1,d0				; !
	jsr 	pow10
	fmove	fp0,fp1
	fmove.d	(sp)+,fp0
	move.l	(sp)+, d2
	move.l	(sp)+, d1
	move.l	(sp)+, d0
	move.l	(sp)+, a1
	move.l	(sp)+, a0
#endif
	fdiv	fp1,fp0
	fneg.l	d0,fp1
#if FPU
	ftentox	fp1
#else
	move.l	a0, -(sp)
	move.l	a1, -(sp)
	move.l	d0, -(sp)
	move.l	d1, -(sp)
	move.l	d2, -(sp)
	fmove.d	fp0,-(sp)
	fmove.l	fp1,d0				; !
	jsr 	pow10
	fmove	fp0,fp1
	fmove.d	(sp)+,fp0
	move.l	(sp)+, d2
	move.l	(sp)+, d1
	move.l	(sp)+, d0
	move.l	(sp)+, a1
	move.l	(sp)+, a0
#endif

	moveq	#5,d2
	fmul	d2,fp1
	fadd	fp1,fp0
	fmove.d	fp0, sfint
	moveq	#10,d2
	fmove	d2,fp2
	fcmp	fp2,fp0
	fblt 	L3828
	move	(a0),d2
	ext.l	d2
	addq.l	#1,d2
	move	d2,(a0)
	move	d2, tus2
	fdiv	fp2,fp0
L3828:
	move 	d0, tus1
	subq.l	#1,d0
	bge.s	L3838
	move.b	#48,(a1)+
	bra.s	L3864

L3838:
	fintrz	fp0,fp1
	fsub	fp1,fp0
	fmove.l	fp1,d1
	add.l	#48,d1
	move.b	d1,(a1)+
	fmul	fp2,fp0
	subq.l 	#1,d0
	cmp.l	#-1,d0
	bne 	L3838
L3864:
	clr.b	(a1)
	clr.l 	d0
	lea 	buf.l,a0
	rts

L3878:
	move.b	#48,(a1)+
L3882:
	subq.l 	#1,d0
	cmp.l	#-1,d0
	bne 	L3878
	clr.b	(a1)
	clr 	(a0)
	bra.s	L3864


