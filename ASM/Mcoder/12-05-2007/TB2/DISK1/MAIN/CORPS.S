
corps:
	movem.l	regscroll,d4/a2-a5

	lea	bri,a7

	rept	colonne

	moveq	#0,d7		* 4
	move.b	(a2)+,d7		* 8
	lsl.w	#7,d7		* 20
	lea	(a7,d7.w),a4	* 12
	adda.w	d4,a4		*  8 = 52
	
	movem.l	(a4)+,d1-d4	44

	move.l	d1,(a3)+		12
	move.l	d2,(a3)+		12
	move.l	d1,(a4)+		12
	move.l	d2,(a4)+		12
	move.l	d1,(a5)+		12
	move.l	d2,(a5)+		12
	movem.l	d3-d4,230-8(a3)	28
	movem.l	d3-d4,230-8(a4)	28
	movem.l	d4-d4,230-8(a5)	28	200
	endr
