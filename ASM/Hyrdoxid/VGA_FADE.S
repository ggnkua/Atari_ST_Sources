FADE_OUT
;pic en a1
	move.l	a1,a2
	move	#255,d0
	lea	$ffff9800,a0
	lea	COL,a3
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
FADE_ONE
	move.l	a2,a1
	move	#255,d1
FADE_RVB
	move.w	(a1)+,d2
	cmpi.b	#0,d2
	beq.s	OK
	subq	#1,d2	
OK
	move.b	(a1)+,d3
	cmpi.b	#0,d3
	beq.s	OK5
	subq	#1,d3	
OK5
	move.b	(a1)+,d4
	cmpi.b	#0,d4
	beq.s	OK3
	subq	#1,d2	
OK3
	or.w	d2,(a3)+
	or.b	d3,(a3)+
	or.b	d2,(a3)
	move.l	(a3),(a0)+
	dbf	d0,FADE_RVB
	bsr	VBL
	dbf	d1,FADE_ONE
	rts