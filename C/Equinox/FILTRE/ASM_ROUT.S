	.EXPORT	convert_sample
	.EXPORT calc_one_data		
;	d0=format d1=signe d2=taille a0=pointeur		
convert_sample:
	movem.l	d0-d7/a0-a6,-(a7)
	cmp.w	#8,d0
	beq.b	to16bits
	lsr.l	#1,d2
	lsl.w	#8,d1
boucle1:add.w	d1,(a0)+
	subq.l	#1,d2
	bne.b	boucle1
	bra.b	fin_convert
to16bits:
	add.l	d2,a0
	move.l	a0,a1
	add.l	d2,a1
boucle2:move.b	-(a0),d3
	add.b	d1,d3
	clr.b	-(a1)
	move.b	d3,-(a1)
	subq.l	#1,d2
	bne.b	boucle2
fin_convert:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

calc_one_data:
	movem.l	d1-d4/a0-a2,-(sp)
	add.l	d0,d0
	lea		(a0,d0.l),a2
	add.w	d1,a1
	add.w	d1,a1
	exg		d0,d1
	move.l	d2,d3
	moveq	#0,d2
	subq.w	#1,d0
convo:	cmp.l	a0,a2
	blt.b	sort
	move.w	-(a1),d1
	muls	(a0)+,d1
	add.l	d1,d1
	swap	d1
	ext.l	d1
	add.l	d1,d2
	dbra	d0,convo
sort:	bsr		test_dep
	moveq	#0,d1
	tst.w	d2
	bpl.s	positif
	neg.l	d2
	moveq	#-1,d1
positif:move.l	d2,d4
	mulu	d3,d4
	clr.w	d4
	swap	d4
	swap	d3
	mulu	d3,d2
	add.l	d4,d2
	tst.w	d1
	beq.s	no_inv
	neg.l	d2
no_inv:	bsr		test_dep
	move.l	d2,d0
	movem.l	(sp)+,d1-d4/a0-a2
	rts
test_dep:
	cmp.l	#-32768,d2
	bge.b	nodep1
	move.l	#-32768,d2
nodep1:	cmp.l	#32767,d2
	ble.b	nodep2
	move.l	#32767,d2
nodep2:	rts
