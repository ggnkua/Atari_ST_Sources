	move.l	4(sp),a0
	move.l	8(sp),a1

	move.w	#199,d0

loop:	rept	20
	move.w	(a0)+,d1
	or.w	(a0)+,d1	
	or.w	(a0)+,d1	
	or.w	(a0)+,d1
	not.w	d1
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	endr
	
	dbra.w	d0,loop

	rts