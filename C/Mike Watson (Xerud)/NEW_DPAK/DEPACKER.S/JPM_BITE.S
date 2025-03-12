	movem.l	d0-a6,-(a7)
	movea.l	a1,a2
	subq.l	#4,a0
	add.l	-(a0),a2
	movea.l	a2,a4
	subq.l	#4,a0

	move.w	-(a0),d0
umain:	bsr	tr4
	bcs.s	c1

	moveq	#8,D1
	moveq	#1,D3
	bsr.s	tr4
	bcs.s	b2

	moveq	#3,D1
	clr.w	D4
j8:	bsr.s	n1
	move.w	D2,d3
	add.w	D4,d3

j1:	moveq	#7,d1
j2:	lsr.w	#1,d0
	bne.s	.2
	move.w	-(a0),d0
	roxr.w	#1,d0
.2:	roxl.w	#1,d2
	dbf	d1,j2
	move.b	d2,-(a2)
	dbf	d3,j1
	bra.s	ecxit

h8:	moveq	#8,D1
	move.l	d1,d4
	bra.s	j8

c1:	moveq	#2,d1
	bsr.s	n1
	cmpi.b	#2,d2
	blt.s	r34
	bgt.s	h8
	moveq	#8,d1
	bsr.s	n1
	move.w	d2,d3
	move.w	#$d,d1
	bra.s	b2

r34:	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
b2:	bsr.s	n1
r3:	subq.w	#1,a2
	move.b	0(a2,d2.W),(a2)
	dbf	d3,r3

ecxit:	cmpa.l	a2,a1
	blt.s	umain
	movem.l	(a7)+,d0-a6
	rts
	
tr4:	lsr.w	#1,d0
	bne.s	.1
	move.w	-(a0),d0
	roxr.w	#1,d0
.1:	rts

n1:	subq.w	#1,d1
	clr.w	d2
.1:	lsr.w	#1,d0
	bne.s	.2
	move.w	-(a0),d0
	roxr.w	#1,d0
.2:	roxl.w	#1,d2
	dbf	d1,.1
	rts
