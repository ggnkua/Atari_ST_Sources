
* binary math operations performed by the FPU
	globl	asinh, acosh, atan2, pow, floor
	globl	ceil, fmod, modf, frexp, ldexp

module ferr33

	btst	#24,d0
	beq.s	L1
	move	#33,errno.l
	rts

L1:
	move	#34,errno.l
	rts
endmod

module asinh

	fmove	fp0,fp1
	fmul	fp1
	fadd	#1,fp1
	fsqrt	fp1
	fadd	fp1,fp0
	flogn	fp0
	rts
endmod

module acosh

	fmove	fp0,fp1
	fmul	fp1
	fsub	#1,fp1
	fsqrt	fp1
	fadd	fp1,fp0
	flogn	fp0
	rts
endmod

module atan2

	fdiv	fp1,fp0
	fatan	fp0
	ftst	fp1
	fblt 	L4272
	fbun 	L4304
	rts

L4272:
	fmovecr	#0,fp1
	ftst	fp0
	fble 	L4294
	fsub	fp1,fp0
	fbun 	L4304
	rts

L4294:
	fadd	fp1,fp0
	fbun 	L4304
	rts

L4304:
	move	#33,errno.l
	rts
endmod

module pow
	fmove.l	fp1,d0
	fcmp.l	d0,fp1
	fbne 	L4534
	tst.l	d0
	bpl.s	L4492
	neg.l	d0
	moveq	#1,d1
	fmove.l	d1,fp1
	fdiv	fp0,fp1
	fmove	fp1,fp0
L4492:
	moveq	#1,d1
	fmove.l	d1,fp1
L4498:
	lsr.l	#1,d0
	bcc.s	L4506
	fmul	fp0,fp1
L4506:
	beq.s	L4514
	fmul	fp0,fp0
	bra.s	L4498

L4514:
	fmove	fp1,fp0
	rts

L4534:
	flogn	fp0
	fmul	fp1,fp0
	fetox	fp0
	rts
endmod

module floor
	fmove.l	FPCR,d0
	move.b	#32,d0
	fmove.l	d0,FPCR
	fint	fp0
	move.b	#0,d0
	fmove.l	d0,FPCR
	rts
endmod

module ceil
	fmove.l	FPCR,d0
	move.b	#48,d0
	fmove.l	d0,FPCR
	fint	fp0
	move.b	#0,d0
	fmove.l	d0,FPCR
	rts
endmod

module frexp

	fgetexp	fp0,fp1
	fmove	fp1,(a0)
	fgetman	fp0
	rts
endmod

module ldexp

	fscale	fp1,fp0
	fmove.l	FPSR,d0
	and.l	#0x3000000,d0
	bne 	ferr33
	rts
endmod

module modf

	fintrz	fp0,fp1
	fmove.x	fp1,(a0)
	fsub	fp1,fp0
	rts
endmod

module fmod

	fmod	fp1,fp0
	rts
endmod


