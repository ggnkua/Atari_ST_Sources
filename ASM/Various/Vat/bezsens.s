Screen	equ	$78000
	opt	x+
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	lea	$ffffe,a7
	bsr	Res
Looop
	bsr	Draw
	bsr	Vbl
	bra.s	Looop

Vbl	move.w	$468.w,d0
.sync	cmp.w	$468.w,d0
	beq.s	.sync
	cmp.b	#$39,$fffffc02.w
	beq.s	Koncz
ertees	rts
Koncz	clr.l	(a7)
	trap	#1
Draw
	lea	Screen,a0
	lea	XYZ(pc),a1
	lea	Cnt(pc),a2
	lea	Pixies(pc),a4
	move.w	(a2),d0
	cmp.w	#200,d0
	beq	ertees
	and.w	#3,d0
	cmp.w	#1,d0
	beq.s	Lewo
	cmp.w	#2,d0
	beq.s	Gora
	cmp.w	#3,d0
	beq	Prawo
Dol
	addq.w	#1,(a2)
	move.w	(a2),d7
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1),d0
	move.w	2(a1),d1
	mulu	#160,d1
	move.w	d0,d2
	and.w	#15,d2
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a4,d2.w),d2
.drw	or.w	d2,(a0,d1.w)
	lea	160(a0),a0
	addq.w	#1,2(a1)
	dbf	d7,.drw
	rts
Lewo
	addq.w	#1,(a2)
	move.w	(a2),d7
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1),d0
	move.w	2(a1),d1
	mulu	#160,d1
	move.w	d0,d2
	and.w	#15,d2
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a4,d2.w),d2
.drw	or.w	d2,(a0,d1.w)
	lsl.w	#1,d2
	bne.s	.dbf
	subq.w	#8,d1
	moveq	#1,d2
.dbf	subq.w	#1,(a1)
	dbf	d7,.drw
	rts
Gora
	addq.w	#1,(a2)
	move.w	(a2),d7
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1),d0
	move.w	2(a1),d1
	mulu	#160,d1
	move.w	d0,d2
	and.w	#15,d2
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a4,d2.w),d2
.drw	or.w	d2,(a0,d1.w)
	lea	-160(a0),a0
	subq.w	#1,2(a1)
	dbf	d7,.drw
	rts
Prawo
	addq.w	#1,(a2)
	move.w	(a2),d7
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1),d0
	move.w	2(a1),d1
	mulu	#160,d1
	move.w	d0,d2
	and.w	#15,d2
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,d1
	add.w	d2,d2
	move.w	(a4,d2.w),d2
.drw	or.w	d2,(a0,d1.w)
	ror.w	#1,d2
	bpl.s	.dbf
	addq.w	#8,d1
.dbf	addq.w	#1,(a1)
	dbf	d7,.drw
	rts

Res
	lea	Screen,a0
	move.l	a0,d1
	rol.w	#8,d1
	move.l	d1,$ffff8200.w
	move.w	#$70,$ffff8242.w
	moveq	#0,d0
	move.w	#1999,d7
.clrscr	dcb.w	$20c0,4
	dbf	d7,.clrscr
	rts
Pixies	dc.w	$8000,$4000,$2000,$1000
	dc.w	$800,$400,$200,$100
	dc.w	$80,$40,$20,$10
	dc.w	8,4,2,1
XYZ	dc.w	160,99
Cnt	dc.w	0


