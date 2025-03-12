; Happy depacker
; I hate this, it was pulling so many values
; from the basepage that in the end I just
; build a dummy basepage for it to use. Oh and
; each program packed has a slightly different
; depacker which is very annoying.

	movem.l	d0-a6,-(a7)
	move.l	a0,.load_here
	lea	$898(a0),a1

	movem.l	776(a0),d0-d1
	movem.l	d0-d1,.HAP19
	lea	1456(a0),a1
	lea	.HAP34,a2
	move.l	#400-1,d0
.1:	move.b	(a1)+,(a2)+
	dbf	d0,.1
	move.l	1430(a0),.upl
	move.l	1434(a0),.pkl
	lea	$1c(a0),a1
	move.l	a1,.p_start
	move.l	2(a0),.p_size
	add.l	2(a0),a1
	move.l	a1,.d_start
	move.l	6(a0),.d_size
	add.l	6(a0),a1
	move.l	a1,.b_start
	move.l	10(a0),.b_size
	bra.s	.begin
.load_here:	dc.l	0
.basepage:	dc.l	.basepage
.b1:	dc.l	0
.p_start:	dc.l	0
.p_size:	dc.l	0
.d_start:	dc.l	0
.d_size:	dc.l	0
.b_start:	dc.l	0
.b_size:	dc.l	0

.begin:	move.l	a7,a6
	lea	.basepage(pc),a5
	move.l	$18(a5),d0
.HAP07:	bsr	.HAP22
	add.l	$1C(a5),d0
	add.l	#$100,d0
	addq.l	#1,d0
.HAP08:	move.l	d0,a3
	move.l	d0,d7
	move.l	$18(a5),a4
	move.l	$14(a5),d0
.HAP09:	move.b	-(a4),-(a3)
	subq.l	#1,d0
	bne.s	.HAP09
	move.l	$10(a5),a4
	lea	.HAP19(PC),a2
.HAP0A:	move.b	(a3),d0
	cmp.b	1(a2),d0
	beq.s	.HAP0C
	cmp.b	3(a2),d0
	beq.s	.HAP0E
	cmp.b	5(a2),d0
	beq.s	.HAP10
	move.b	(a3)+,(a4)+
.HAP0B:	cmp.l	a3,d7
	bcs.s	.HAP13
	bra.s	.HAP0A
.HAP0C:	addq.l	#1,a3
	clr.w	d1
	move.b	(a3)+,d2
	move.b	(a3)+,d1
	subq.w	#1,d1
.HAP0D:	move.b	d2,(a4)+
	dbf	d1,.HAP0D
	bra.s	.HAP0B
.HAP0E:	addq.l	#1,a3
	clr.w	d1
	move.b	(a3)+,d1
	move.b	7(a2),d2
	subq.w	#1,d1
.HAP0F:	move.b	d2,(a4)+
	dbf	d1,.HAP0F
	bra.s	.HAP0B
.HAP10:	addq.l	#1,a3
	moveq	#0,d6
	moveq	#0,d5
	move.b	1(a3),d6
	subq.b	#1,d6
.HAP11:	clr.w	d5
	move.b	(a3),d5
	subq.b	#1,d5
	lea	2(a3),a1
.HAP12:	move.b	(a1)+,(a4)+
	dbf	d5,.HAP12
	dbf	d6,.HAP11
	moveq	#0,d6
	move.b	(a3),d6
	lea	2(a3),a3
	add.l	d6,a3
	bra.s	.HAP0B
.HAP13:	lea	.HAP2A(PC),a0
.exit:	movem.l	(a7)+,d0-a6
	rts

.HAP19:	dc.b	$00,$0F,$00,$13,$00,$17,$00,$00

.HAP22:	movem.l	a0-a6/D0-d7,-(a7)
	lea	.HAP2B(PC),a6
	move.l	d0,(a6)
	lea	.HAP2C(PC),a6
	lea	.HAP42(PC),a6
	move.l	a5,(a6)
	lea	.HAP2F(PC),a0
	move.l	a7,(a0)
	move.l	$18(a5),a0
	lea	.HAP31(PC),a6
	move.l	$14(a5),(a6)
	add.l	$1C(a5),a0
	lea	$2000(a0),a0
	lea	-$1388(a7),a7
	lea	.HAP32(PC),a6
	move.l	a7,(a6)
	lea	-$A(a7),a7
.HAP23:	moveq	#7,d7
	lea	.HAP34(PC),a5
	move.w	#0,-(a7)
	lea	.HAP33(PC),a6
	clr.w	(a6)
	bsr	.HAP37
	addq.l	#2,a7
	bsr	.HAP40
	lea	.HAP30(PC),a6
	move.l	a2,(a6)
	move.l	a2,d0
	lea	.HAP31(PC),a6
	add.l	d0,(a6)
	addq.l	#2,(a6)
	moveq	#7,d7
	move.l	a2,a5
	move.l	.HAP32(PC),a2
	move.l	.load_here(pc),a4
	lea	$898(a4),a4
	lea	.HAP31(PC),a6
	move.l	(a6),a3
.HAP24:	cmp.l	a5,a3
	bls.s	.HAP29
	move.l	a2,a0
.HAP25:	cmp.w	#0,(a0)
	beq.s	.HAP28
	bsr	.HAP3C
	tst.w	d0
	beq.s	.HAP26
	move.w	4(a0),d1
	bra.s	.HAP27
.HAP26:	move.w	2(a0),d1
.HAP27:	and.l	#$FFFF,d1
	lsl.l	#3,d1
	move.l	a2,a0
	add.l	d1,a0
	bra.s	.HAP25
.HAP28:	move.b	7(a0),(a4)+
	bra.s	.HAP24
.HAP29:	lea	.HAP2C(PC),a6
	lea	.HAP2B(PC),a6
	lea	.HAP42(PC),a1
	move.l	(a1),a0
	move.l	$10(a0),d0
	lea	.pkl(PC),a6
	move.l	(a6),$14(a0)
	add.l	$14(a0),d0
	move.l	d0,$18(a0)
	lea	.HAP2F(PC),a6
	move.l	(a6),a7
	movem.l	(a7)+,a0-a6/D0-d7
	move.l	$18(a5),d0
	rts

.HAP2A:	dc.b	$00,$00
.HAP2B:	dcb.w	2,0
.HAP2C:	dc.b	$00,$00
.upl:	dc.b	$00,$00,$09,$C5
.pkl:	dc.b	$00,$00,$08,$B4
.HAP2F:	dcb.w	2,0
.HAP30:	dcb.w	2,0
.HAP31:	dcb.w	2,0
.HAP32:	dcb.w	2,0
.HAP33:	dc.b	$00,$00

.HAP34:	ds.b	400

.HAP37:	bsr.s	.HAP3C
	tst.b	d0
	beq.s	.HAP38
	lea	.HAP32(PC),a6
	move.l	(a6),a0
	move.w	4(a7),d0
	and.l	#$FFFF,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.w	#-1,(a0)
	lea	.HAP33(PC),a6
	addq.w	#1,(a6)
	move.w	(a6),2(a0)
	move.l	a0,-(a7)
	move.w	2(a0),-(a7)
	bsr.s	.HAP37
	addq.l	#2,a7
	move.l	(a7)+,a0
	lea	.HAP33(PC),a6
	addq.w	#1,(a6)
	move.w	(a6),4(a0)
	move.w	4(a0),-(a7)
	bsr.s	.HAP37
	addq.l	#2,a7
	rts
.HAP38:	lea	.HAP32(PC),a6
	move.l	(a6),a0
	move.w	4(a7),d0
	and.l	#$FFFF,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move.w	#0,(a0)
	moveq	#7,d1
	clr.w	d2
.HAP39:	bsr.s	.HAP3C
	tst.w	d0
	beq.s	.HAP3A
	bset	d1,d2
	bra.s	.HAP3B
.HAP3A:	bclr	d1,d2
.HAP3B:	subq.w	#1,d1
	cmp.w	#-1,d1
	bne.s	.HAP39
	move.w	d2,6(a0)
	rts
.HAP3C:	btst	d7,(a5)
	beq.s	.HAP3D
	move.w	#-1,d0
	bra.s	.HAP3E
.HAP3D:	clr.w	d0
.HAP3E:	subq.w	#1,d7
	cmp.w	#-1,d7
	beq.s	.HAP3F
	rts

.HAP3F:	moveq	#7,d7
	addq.l	#1,a5
	rts

.HAP40:	lea	.HAP42(PC),a0
	move.l	(a0),a1
	move.l	a1,a0
	move.l	$10(a0),a1
	move.l	a1,a2
	add.l	$14(a0),a1
	move.l	$14(a0),d0
	lea	.upl(PC),a0
	add.l	(a0),a2
	move.l	(a0),d1
	lsr.l	#3,d1
	add.l	d1,a2
	addq.l	#1,a2
	addq.l	#1,a1
	addq.l	#1,d0
.HAP41:	move.b	-(a1),-(a2)
	subq.l	#1,d0
	bne.s	.HAP41
	rts

.HAP42:	dcb.w	2,0
