
	move.l	source,a4	;pointe sur le premier octet charg‚
	lea	33(a4),a4	;saute la r‚solution et les palettes (33 octets)

	move.b	(a4)+,d0	;nb octets du premier segment
	asl	#8,d0
	move.b	(a4)+,d0

	addq	#2,a4		;2 octets donnant la longueur
				;du deuxieme segment /2 (inutilis‚)
	move.l	a4,a2		;pointe sur le premier segment
	add	d0,a4		;pointe sur le deuxieme segment
	moveq	#0,d0		;offset ‚cran=0
	move.l	destin,a3	;pointe sur l'‚cran … afficher
	move.l	a4,a5		;debut deuxieme segment=fin premier segment
	bra.s	lbl77
lbl84:
	move.b	(a2)+,d1
	ext.w	d1
	cmp.b	#2,d1
	bhs.s	lbl72

	move.b	(a2)+,d1
	asl	#8,d1
	move.b	(a2)+,d1
	tst.b	-3(a2)
	beq.s	lbl72
	neg	d1

lbl72:	tst	d1
	bpl.s	lbl79
	neg	d1
	bra.s	lbl80
lbl82:
	move.b	(a4)+,0(a3,d0.w)
	move.b	(a4)+,1(a3,d0.w)
	add	#160,d0
	cmp	#$7D00,d0
	blo.s	lbl80
	sub	#$7CF8,d0
	cmp	#160,d0
	blo.s	lbl80
	sub	#$9E,d0
lbl80:	dbra	d1,lbl82
	bra.s	lbl77

lbl83:
	move.b	(a4),0(a3,d0.w)
	move.b	(a4),1(a3,d0.w)
	add	#160,d0
	cmp	#$7D00,d0
	blo.s	lbl79
	sub	#$7CF8,d0
	cmp	#160,d0
	blo.s	lbl79
	sub	#$9E,d0
lbl79:	dbra	d1,lbl83
	addq	#2,a4
lbl77:	cmp.l	a5,a2
	blo.s	lbl84
	illegal

source:	dc.l	$40000
destin:	dc.l	$78000

