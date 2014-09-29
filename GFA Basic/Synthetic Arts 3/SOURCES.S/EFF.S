*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS 2.4						  *
*	EFFACAGE MEMOIRE - VERSION MOVEM				  *
*-------------------------------------------------------------------------*

	move.l	4(sp),a0
	move.l	8(sp),d0

	movem.w	zero(pc),d1-d7/a1-a6
		
	cmp.l	#104,d0
	
	blt.s	endeff

megaloop:
	movem.l	d1-d7/a1-a6,(a0)
	lea	52(a0),a0
	sub.l   #52,d0
	cmp.l	#52,d0
	bge.s	megaloop

	tst.w	d0
	beq.s	fin

endeff:

loop:	move.w	d1,(a0)+
	subq.w	#2,d0
	tst.w	d0
	bne.s	loop

fin:	rts


zero:
	rept	13
	dc.w	0
	endr
