depack1	movem.l 	(a0)+,d0-d1/d5
	movea.l 	a1,a2
	adda.l 	d0,a0
	adda.l 	d1,a2
	move.l 	-(a0),d0
	eor.l 	d0,d5
l1	lsr.l 	#1,d0
	bne.s 	l2
	bsr 	l16
l2	bcs.s 	l9
	moveq 	#8,d1
	moveq 	#1,d3
	lsr.l 	#1,d0
	bne.s 	l3
	bsr 	l16
l3	bcs.s 	l11
	moveq 	#3,d1
	clr.w 	d4
l4	bsr 	l17
	move.w 	d2,d3
	add.w 	d4,d3
l5	moveq 	#7,d1
l6	lsr.l 	#1,d0
	bne.s 	l7
	bsr 	l16
l7	roxl.l 	#1,d2
	dbf 	d1,l6
	move.b 	d2,-(a2)
	dbf 	d3,l5
	bra.s 	l13
l8	moveq 	#8,d1
	moveq 	#8,d4
	bra.s 	l4
l9	moveq 	#2,d1
	bsr 	l17
	cmpi.b 	#2,d2
	blt.s 	l10
	cmpi.b 	#3,d2
	beq.s 	l8
	moveq 	#8,d1
	bsr.s 	l17
	move.w 	d2,d3
	move.w 	#12,d1
	bra.s 	l11
l10	move.w 	#9,d1
	add.w 	d2,d1
	addq.w 	#2,d2
	move.w 	d2,d3
l11	bsr.s 	l17
l12	subq.w 	#1,a2
	move.b 	0(a2,d2.w),(a2)
	dbf 	d3,l12
l13	cmpa.l 	a2,a1
	blt 	l1
	tst.l 	d5
	bne.s 	l14
	rts
l14	nop
l15	moveq 	#1,d0
	rts
l16	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
	rts
l17	subq.w 	#1,d1
	clr.w	 d2
l18	lsr.l 	#1,d0
	bne.s	 l19
	move.l 	-(a0),d0
	eor.l 	d0,d5
	move.b 	#$10,ccr
	roxr.l 	#1,d0
l19	roxl.l 	#1,d2
	dbf 	d1,l18
	rts
