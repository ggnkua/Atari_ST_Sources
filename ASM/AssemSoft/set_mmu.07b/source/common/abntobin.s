		text
****************************************************************************************************
*ASCIBINTOBIN	CONVERT A BINARY ASCII STRING POINTED TO BY A0 INTO A BINARY NUMBER		   *
*	PASSED BACK IN D0									   *
*												   *
*	 A0 = Pointer to ASCII binary string to convert					   *
*												   *
*	 D0 = Binary resoult									   *
****************************************************************************************************
ascibintobin:	movem.l	d1-2/a0-1,-(sp)
		moveq	#0,d0
		movea.l	a0,a1
.abinbin1:	tst.b	(a1)+
		bne.s	.abinbin1
		subq.l	#1,a1
		move.l	a1,d1
		sub.l	a0,d1
		subq.l	#1,d1
		bge.s	.abinbin3
		bra.s	.ok
.abinbin2:	lsl.l	#1,d0
.abinbin3:	move.b	(a0)+,d2
		cmp.b	#48,d2
		blo.s	.error
		cmp.b	#49,d2
		bhi.s	.error
		;add.b	(a0)+,d0
		add.b	d2,d0
		sub.b	#48,d0
		dbra	d1,.abinbin2
.ok:		or.b	#1,ccr
		bra.s	.exit
.error:		and.b	#-2,ccr
.exit:		movem.l	(sp)+,d1-2/a0-1
		rts
