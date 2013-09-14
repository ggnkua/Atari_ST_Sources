SQRT	MACRO
	moveq	#0,\2
	bfffo	\1{0:31},\3
	beq.s	.\@zero
	neg.w	\3
	add.w	#31,\3
	lsr.w	#1,\3
	addx.w	\2,\3

	move.l	\1,\2
	lsr.l	\3,\2
	beq.s	.\@zero

	move.l	\1,\3
	divu.w	\2,\3
	add.w	\3,\2
	lsr.w	#1,\2
	beq.s	.\@zero

	move.l	\1,\3
	divu.w	\2,\3
	add.w	\3,\2
	lsr.w	#1,\2
	beq.s	.\@zero

	divu.w	\2,\1
	add.w	\2,\1

	lsr.w	#1,\1

.\@zero
	ENDM

;	move.l	#65536-2,d0
;	SQRT	d0,d1,d2
;	and.l	#$ffff,d0
;	rts



