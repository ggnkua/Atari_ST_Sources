	text
****************************************************************************************************
*ASCIDECTOBIN	CONVERT A DECIMAL ASCII STRING POINTED TO BY A0 INTO A BINARY NUMBER		   *
*	THAT IS PASSED BACK IN D0								   *
*												   *
*	 A0 = Pointer to ASCII decimal string to convert					   *
*												   *
*	 D0 = Binary resoult									   *
****************************************************************************************************
ascidectobin:	movem.l	d1-3/a0-1,-(sp)
		moveq	#0,d0
		movea.l	a0,a1
.adecbin1:	tst.b	(a1)+
		bne.s	.adecbin1
		subq.l	#1,a1
		move.l	a1,d1
		sub.l	a0,d1
		subq.l	#1,d1
		blt.s	.ok
		moveq	#0,d2
		moveq	#0,d3
		bra.s	.adecbin3
.adecbin2:	move.l	d0,d2
		lsl.l	#2,d0
		add.l	d2,d0
		lsl.l	#1,d0
.adecbin3:	move.b	(a0)+,d3
		cmp.b	#48,d3
		blo.s	.error
		cmp.b	#57,d3
		bhi.s	.error
		sub.b	#48,d3
		add.l	d3,d0
		dbra	d1,.adecbin2
.ok:		or.b	#1,ccr
		bra.s	.exit
.error:		and.b	#-2,ccr
.exit:		movem.l	(sp)+,d1-3/a0-1
		rts
