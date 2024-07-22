	movem.l	d0-a6,-(sp)
;	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	.sp2_05
	tst.w	(a0)
	bne.s	.sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
;	move.l	d1,(sp)
.sp2_01:
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	bsr.s	.sp2_06
.sp2_05:	movem.l	(sp)+,d0-a6
	rts	
.sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	.sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
.sp2_07:	add.l	d0,d0
	bne.s	.sp2_08
	jsr	(a3)
.sp2_08:	bcs.s	.sp2_24
	move.b	-(a0),d1
	bra.s	.sp2_13
.sp2_09:	moveq	#2,d2
	bsr.s	.sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	.sp2_13
.sp2_10:	add.l	d0,d0
	bne.s	.sp2_11
	jsr	(a3)
.sp2_11:	bcs	.sp2_33
	moveq	#3,d2
	bsr.s	.sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	.sp2_12
	not.w	d2
.sp2_12:	move.b	(a1),d1
	add.w	d2,d1
.sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
.sp2_14: cmp.l	a1,a2
	bne.s	.sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
.sp2_15:	move.l	d7,d2
.sp2_16:	move.l	d6,d1
.sp2_17:	add.l	d0,d0
	bne.s	.sp2_18
	jsr	(a3)
.sp2_18:	addx	d1,d1
	dbf	d2,.sp2_17
.sp2_19:	move.l	d1,d2
	rts
.sp2_20:	bsr.s	.sp2_15
.sp2_21:	beq.s	.sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	.sp2_19
.sp2_22:	add.w	d7,d2
	add.w	d2,d2
.sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	.sp2_17
.sp2_24:	add.l	d0,d0
	bne.s	.sp2_25
	jsr	(a3)
.sp2_25:	bcs.s	.sp2_27
	add.l	d0,d0
	bne.s	.sp2_26
	jsr	(a3)
.sp2_26:	bcs.s	.sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	.sp2_36
.sp2_27:	add.l	d0,d0
	bne.s	.sp2_28
	jsr	(a3)
.sp2_28:	bcs.s	.sp2_29
	bsr.s	.sp2_15
	beq.s	.sp2_13
	moveq	#1,d3
	bra.s	.sp2_35
.sp2_29:	add.l	d0,d0
	bne.s	.sp2_30
	jsr	(a3)
.sp2_30:	bcs	.sp2_09
	add.l	d0,d0
	bne.s	.sp2_31
	jsr	(a3)
.sp2_31:	bcs.s	.sp2_32
	bsr.s	.sp2_15
	beq.s	.sp2_12
	moveq	#2,d3
	bra.s	.sp2_35
.sp2_32:	moveq	#3,d3
	bsr.s	.sp2_20
	bra.s	.sp2_36
.sp2_33:	bsr.s	.sp2_15
	beq.s	.sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	.sp2_23
	move.l	d2,d3
	bsr.s	.sp2_20
	bra.s	.sp2_36
.sp2_34:	bsr.s	.sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	.sp2_36
.sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	.sp2_21
.sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
.sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,.sp2_37
	move.w	d5,(a5)
	bra	.sp2_14
.sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	.sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
.sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts
