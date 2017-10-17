		text
****************************************************************************************************
*ASCIHEXTOBIN	CONVERT A HEX ASCII STRING POINTED TO BY A0 INTO A BINARY NUMBER		   *
*	PASSED BACK IN D0									   *
*												   *
*	 A0 = Pointer to ASCII hexadecimal string to convert					   *
*												   *
*	 D0 = Binary resoult									   *
****************************************************************************************************
ascihextobin:	movem.l	d1-2/a0-1,-(sp)
		moveq	#0,d0
		movea.l	a0,a1
.ahexbin1:	tst.b	(a1)+
		bne.s	.ahexbin1
		subq.l	#1,a1
		move.l	a1,d2
		sub.l	a0,d2
		subq.l	#1,d2
		bge.s	.ahexbin3
		bra.s	.ok_exit
.ahexbin2:	or.b	d1,d0
		lsl.l	#4,d0
.ahexbin3:	move.b	(a0)+,d1
		cmp.b	#57,d1
		bhi.s	.ahexbin4
		cmp.b	#48,d1
		blo.s	.error
		sub.b	#48,d1
		dbra	d2,.ahexbin2
		bra.s	.ahexbintrm
.ahexbin4:	cmp.b	#97,d1
		blo.s	.no_conv
		cmp.b	#122,d1
		bhi.s	.no_conv
		sub.b	#32,d1
.no_conv:	cmp.b	#65,d1
		blo.s	.error
		cmp.b	#70,d1
		bhi.s	.error
		sub.b	#55,d1
		dbra	d2,.ahexbin2
.ahexbintrm:	or.b	d1,d0
.ok_exit:	or.b	#1,ccr
		bra.s	.exit
.error:		and.b	#-2,ccr
.exit:		movem.l	(sp)+,d1-2/a0-1
		rts

