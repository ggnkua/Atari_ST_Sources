
; depack automation v 2.3r / 2.51

	movem.l	d0-a6,-(a7)
	addq.l	#4,a0
	move.l	a0,a4
	move.l	(a0)+,d5
	add.l	d5,a1
	add.l	(a0),a0
	suba.l	#4,a0
	tst.w	-(a0)
	bpl.s	.AUT1
	subq.l	#1,a0
.AUT1:	move.b	-(a0),d0
.AUT2:	lsl.b	#1,d0
	bne.s	.AUT3
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT3:	bcc.s	.AUT10
	clr.w	d1
	lsl.b	#1,d0
	bne.s	.AUT4
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT4:	bcc.s	.AUT9
	lea	.nums(PC),a3
	moveq	#3,d3
.AUT5:	clr.w	d1
	move.b	0(a3,d3.W),d2
	ext.w	d2
	moveq	#-1,d4
	lsl.w	d2,d4
	not.w	d4
	subq.w	#1,d2
.AUT6:	lsl.b	#1,d0
	bne.s	.AUT7
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT7:	roxl.w	#1,d1
	dbf	d2,.AUT6
	tst.w	d3
	beq.s	.AUT8
	cmp.w	d1,d4
	dbne	d3,.AUT5
.AUT8:	move.b	4(a3,d3.W),d2
	ext.w	d2
	add.w	d2,d1
	bra.s	.AUT9

.nums:	dc.b	$0A,$03,$02,$02,$0E,$07,$04,$01

.AUT9:	move.b	-(a0),-(a1)
	dbf	d1,.AUT9
.AUT10:	move.l	a4,a3
	addq.l	#$8,a3
	cmp.l	a3,a0
	ble	.BYENOW
	lea	.nums2(PC),a3
	moveq	#3,d2
.AUT11:	lsl.b	#1,d0
	bne.s	.AUT12
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT12:	bcc.s	.AUT13
	dbf	d2,.AUT11
.AUT13:	clr.w	d1
	addq.w	#1,d2
	move.b	0(a3,d2.W),d3
	beq.s	.AUT16
	ext.w	d3
	subq.w	#1,d3
.AUT14:	lsl.b	#1,d0
	bne.s	.AUT15
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT15:	roxl.w	#1,d1
	dbf	d3,.AUT14
.AUT16:	move.b	5(a3,d2.W),d3
	ext.w	d3
	add.w	d3,d1
	bra.s	.AUT161
.nums2:	dc.b	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02
.AUT161:	cmp.w	#2,d1
	beq.s	.AUT22
	lea	.nums3(PC),a3
	moveq	#1,d3
.AUT17:	lsl.b	#1,d0
	bne.s	.AUT18
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT18:	bcc.s	.AUT19
	dbf	d3,.AUT17
.AUT19:	addq.w	#1,d3
	clr.w	d2
	move.b	0(a3,d3.W),d4
	ext.w	d4
.AUT20:	lsl.b	#1,d0
	bne.s	.AUT21
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT21:	roxl.w	#1,d2
	dbf	d4,.AUT20
	lsl.w	#1,d3
	add.w	4(a3,d3.W),d2
	bra.s	.AUT26

.nums3:	dc.b	$0B,$04,$07,$00,$01,$20,$00,$00
	dc.b	$00,$20,$00,$00

.AUT22:	clr.w	d2
	moveq	#5,d3
	clr.w	d4
	lsl.b	#1,d0
	bne.s	.AUT23
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT23:	bcc.s	.AUT24
	moveq	#8,d3
	moveq	#$40,d4
.AUT24:	lsl.b	#1,d0
	bne.s	.AUT25
	move.b	-(a0),d0
	roxl.b	#1,d0
.AUT25:	roxl.w	#1,d2
	dbf	d3,.AUT24
	add.w	d4,d2
.AUT26:	lea	0(a1,d2.W),a2
	ext.l	d1
	add.l	d1,a2
	subq.w	#1,d1
.AUT27:	move.b	-(a2),-(a1)
	dbf	d1,.AUT27
	bra	.AUT2
.BYENOW:
	movem.l	(a7)+,d0-a6
	rts
