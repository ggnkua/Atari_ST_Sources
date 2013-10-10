	TEXT

; Inverse les bits de d0, utilise d1
meth1:
	REPT	15
	lsr.w	#1,d0
	addx.w	d1,d1
	ENDR
	add.w	d1,d1
	add.b	d0,d1
	swap	d0
	swap	d1
	REPT	15
	lsr.w	#1,d1
	addx.w	d1,d1
	ENDR
	add.w	d1,d1
	add.b	d0,d1
	swap	d1

	move.l	d1,d0
	rts

; Autre m‚thode, plus rapide
meth2:
	lea.l	table(pc),a0
	moveq	#0,d1
	moveq	#0,d2
	move.b	d0,d2
	add.b	(a0,d2.w),d1
	lsl.w	#8,d1
	lsr.w	#8,d0
	move.b	d0,d2
	add.b	(a0,d2.w),d1
	swap	d1
	swap	d0
	move.b	d0,d2
	add.b	(a0,d2.w),d1
	lsl.w	#8,d1
	lsr.w	#8,d0
	move.b	d0,d2
	add.b	(a0,d2.w),d1

	move.l	d1,d0
	rts

table:	DS.b	256	; Les nbrs de 0 … 255, bits invers‚s


; Comptage des bits … 1 de d0.l dans d1.b

	move.b	d2,-(sp)
	sub.b	d2,d2
	move.b	d2,d1
	REPT	16
	add.w	d0,d0
	addx.b	d2,d1
	ENDR
	swap	d0
	REPT	16
	add.w	d0,d0
	addx.b	d2,d1
	ENDR
	move.b	(sp)+,d2

	rts


; Ecriture de d0.l en (a0) quelque soit la parit‚ de a0

	move.w	a0,d1	; 4
	btst	#0,d1	; 12
	beq.s	adr_paire	; 8/12
	move.b	d0,(a0)+	; 8
	lsr.l	#8,d0	; 24
	move.w	d0,(a0)+	; 8
	swap	d0	; 4
	move.b	d0,(a0)	; 8
	
	rts

adr_paire:	move.l	d0,(a0)	; 12

	rts
