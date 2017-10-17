	even
	text
****************************************************************************************************
*BINTOBIN	CONVERT BINARY NUMBER PASSED IN D0 TO A BINARY ASCII STRING			   *
*		WHOSE ADDRESS IS PASSED IN A0							   *
*												   *
*	 D0 = Binary number to convert								   *
*	 A0 = Pointer to string to contain the resoulting binary ASCII string			   *
****************************************************************************************************
bintobin	movem.l	d0-2/a0,-(sp)
		moveq	#31,d1
		moveq	#24,d2
.binabin1	lsl.l	#1,d0
		addx.b	d2,d2
		move.b	d2,(a0)+
		moveq	#24,d2
		dbra	d1,.binabin1
.binabintrm	moveq	#0,d0
		bne.s	.binabin2
		clr.b	(a0)
		bra.s	.binabinterm
.binabin2	move.b	#32,(a0)+
		move.b	#0,(a0)
		move.b	#0,.binabintrm+1
.binabinterm	movem.l	(sp)+,d0-2/a0
		rts
