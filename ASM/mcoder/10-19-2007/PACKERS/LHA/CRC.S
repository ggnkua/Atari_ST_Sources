CRC16	=	$A001
makecrc:
O:
	lea	crctbl(pc),a0
	moveq	#0,d2
1$
	move	d2,d0
	moveq	#8-1,d1
2$
	lsr	#1,d0
	bcc.s	3$
	eor	#CRC16,d0
3$
	dbra	d1,2$
	move	d0,(a0)+

	addq.b	#1,d2
	bne.s	1$

	moveq	#0,d7
	moveq	#0,d6
same:

	lea	crctbl+2(pc),a0
	move	#$100,d2
1$
	addq.l	#1,d6		;compteur de tests

	move	d2,d0
	moveq	#8-1,d1
4$	add	d0,d0
	bcc.s	5$
	eor	d7,d0
5$	dbra	d1,4$

	cmp	(a0)+,d0
	bne.s	.notsame

	move	d7,d5

	add	#$100,d2
	bne.s	1$

	ILLEGAL

.notsame
	addq	#1,d7
	bne.s	same
	illegal

crctbl	ds.w	$100
