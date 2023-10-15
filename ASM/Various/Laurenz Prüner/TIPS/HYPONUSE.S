; Assembler-Routine zu Errechnen der Hypothenuse (sqrt(a*a+b*b))
; IN: d0.w (a) und d1.w (b) -> d0.w (Hypothenuse)
hyponuse:
	movem.l	d1-d4,-(sp)
	muls	d0,d0		; Parameter a quadrieren
	muls	d1,d1		; Parameter b quadrieren
	add.l	d0,d1		; a*a+b*b
	beq.s	hypoend		; 0, dann schon	fertig
	move.l	d1,d0
	moveq.l	#0,d2
	cmp.l	#$10000,d1
	bcs.s	hypo1
	swap	d1
	moveq.l	#$10,d2
hypo1:
	cmp.w	#1,d1
	beq.s	hypo2
	addq.w	#1,d2
	lsr.w	#1,d1
	bra.s	hypo1
hypo2:
	asr.w	#1,d2
	moveq.l	#1,d3
	asl.w	d2,d3
	move.w	d3,d2
	asl.w	#1,d2
	bne.s	hypo3
	subq.w	#1,d2
hypo3:
	move.w	d2,d1
	sub.w	d3,d1
	cmp.w	#1,d1
	beq.s	hypo4
	asr.w	#1,d1
	add.w	d3,d1
	move.w	d1,d4
	mulu	d1,d1
	cmp.l	d0,d1
	bhi.s	hypo5
	bcs.s	hypo6
	move.w	d4,d0
hypoend:
	movem.l	(sp)+,d1-d4
	rts
hypo5:
	move.w	d4,d2
	bra.s	hypo3
hypo6:
	move.w	d4,d3
	bra.s	hypo3
hypo4:
	move.w	d3,d0
	bra.s	hypoend


