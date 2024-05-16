corps:
	movem.l	regscroll,d5/a2/a3-a5

	move.l	#bri,d6

	move.l	a2,$300.w
	
	rept	colonne-1

	moveq	#0,d1
	move.l	$300.w,a2
	move.b	(a2)+,d1
	move.l	a2,$300.w
	lsl.w	#7,d1
	move.l	d6,a2
	lea	(a2,d1.w),a2
	adda.w	d5,a2
	
	movem.l	(a2),d1-d4
	movem.l	d1-d2,(a3)
	movem.l	d1-d2,(a4)
	movem.l	d1-d2,(a5)
	movem.l	d3-d4,230(a3)
	movem.l	d3-d4,230(a4)
	movem.l	d3-d4,230(a5)

	addq.l	#8,a3
	addq.l	#8,a4
	addq.l	#8,a5

	endr

	moveq	#0,d1
	move.l	$300.w,a2
	move.b	(a2)+,d1
	move.l	a2,$300.w
	lsl.w	#7,d1
	move.l	d6,a2
	lea	(a2,d1.w),a2
	adda.w	d5,a2
	
	movem.l	(a2),d1-d4
	movem.l	d1-d2,(a3)
	movem.l	d1-d2,(a4)
	movem.l	d1-d2,(a5)
	movem.l	d3-d4,230(a3)
	movem.l	d3-d4,230(a4)
	movem.l	d3-d4,230(a5)

