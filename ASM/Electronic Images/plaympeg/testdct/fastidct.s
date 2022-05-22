			IMPORT pre_const

PSIZE		equ		16384
PMID		equ		PSIZE/2				
		EXPORT fastidct
		
fastidct:
		movem.l	d2-d7/a2-a4,-(sp)
		lea	pre_const,a1
		move.w	#1000,d7
.row_lp:
		;bfextu	d1{0:8},d0
		moveq	#0,d1
		move.b	d0,d1
		move.b	d0,d1
		subq	#1,d7
		bne.s	.row_lp		
		movem.l	(sp)+,d2-d7/a2-a4
		rts