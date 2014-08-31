	;enables ringer interrupt
	output	.ro

BSETIO	MACRO
	move.b	\2,d0
	bset	#\1,d0
	move.b	d0,\2
	ENDM

BCLRIO	MACRO
	move.b	\2,d0
	bclr	#\1,d0
	move.b	d0,\2
	ENDM

	move.l	$78.w,$138.w
	BSETIO	6,$fffa07
	BSETIO	6,$fffa13
	BCLRIO	6,$fffa0f
	move.b	#14,$ff8800
	BSETIO	4,$ff8802
	moveq	#-1,d0
	rts
