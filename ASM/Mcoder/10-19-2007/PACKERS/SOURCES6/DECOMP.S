source:	equ	$40000
dest:	equ	$50000

	lea	source,a0
	lea	dest,a1
	bra.s	suite

topo:	move.b	(a0)+,d1
	moveq	#7-1,d2
topo1:
	move.b	d1,d3
	add.b	d0,d0
	bpl.s	topo2
	move.b	(a0)+,d3
topo2:	move.b	d3,(a1)+
	dbra	d2,topo1
suite:
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	topo
	beq.s	fill16
	bclr	#6,d0
	bne.s	differe
	subq	#1,d0
	move.b	(a0)+,d1
fill8:	move.b	d1,(a1)+
	dbra	d0,fill8
	bra.s	suite

differe:
	subq	#1,d0
diff1:	move.b	(a0)+,(a1)+
	dbra	d0,diff1
	bra.s	suite

fill16:
	move.b	(a0)+,d1
	move.b	(a0)+,-(sp)
	move	(sp)+,d0
	move.b	d1,d0
	tst	d0
	beq.s	fini

	subq	#1,d0
	move.b	(a0)+,d1
fill1:	move.b	d1,(a1)+
	dbra	d0,fill1
	bra.s	suite
fini:
	rts
