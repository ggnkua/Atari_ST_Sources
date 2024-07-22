	movem.l	d0-a6,-(a7)
	lea	(a0),a6
	lea	(a1),a3
	lea	(a3),a1
	cmpi.l	#"Vic2",(a0)+
	bne	.xff
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	lea	buf00(pc),a2
	moveq	#(1024/8)-1,d7
.x00:	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d7,.x00
	subi.l	#1024,d4
	adda.l	d4,a0
	bclr	#0,d3
	adda.l	d3,a1
	lea	16(a1),a1
	lsr.l	#2,d4
	subq.l	#1,d4
.x01:	move.l	-(a0),d0
	swap	d0
	move.l	d0,-(a1)
	dbf	d4,.x01
	lea	(a1),a4
	lea	buf00(pc),a6
	lea	512(a6),a5
	move	510(a6),d4
	lea	512(a5),a0
	lea	256(a0),a1
	moveq	#0,d0
	moveq	#9,d1
.x02:	move	d0,d6
	moveq	#0,d7
	move	d4,d5
.x03:	addq	#1,d7
	cmp	d1,d7
	beq.s	.x06
	lsr.b	#1,d6
	bcc.s	.x04
	move	0(a5,d5.w),d5
	bpl.s	.x03
	bra.s	.x05
.x04:	move	0(a6,d5.w),d5
	bpl.s	.x03
.x05:	move.b	d5,(a1)+
	move.b	d7,(a0)+
	bra.s	.x07
.x06:	lsr	#1,d5
	move.b	d5,(a1)+
	st	(a0)+
.x07:	addq.b	#1,d0
	bne.s	.x02
	lea	512(a5),a2
	lea	256(a2),a1
	move.l	(a4)+,d6
	swap	d6
	moveq	#16,d7
	moveq	#0,d0
	moveq	#0,d4
	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x09
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x08
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x10
.x08:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x10
.x09:	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x0a	
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x0b
.x0a:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x0b:	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x0c:	dbf	d7,.x0d
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x0d:	lsr.l	#1,d6
	bcc.s	.x0e
	move	0(a5,d5.w),d5
	bpl.s	.x0c
	bra.s	.x0f
.x0e:	move	0(a6,d5.w),d5
	bpl.s	.x0c
.x0f:	move.b	d5,d0
.x10:	move	d0,d2
.x11:	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x13
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x12
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x1a
.x12:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x1a
.x13:	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x14
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x15
.x14:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x15:	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x16:	dbf	d7,.x17
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x17:	lsr.l	#1,d6
	bcc.s	.x18
	move	0(a5,d5.w),d5
	bpl.s	.x16
	bra.s	.x19
.x18:	move	0(a6,d5.w),d5
	bpl.s	.x16
.x19:	move.b	d5,d0
.x1a:	cmp.b	d0,d2
	beq.s	.x1c
	move.b	d0,(a3)+
	addq.l	#1,buf01
.x1b:	subq.l	#1,d3
	bne.s	.x11
.xff:
	movem.l	(a7)+,d0-a6
	rts
.x1c:	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x1e
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x1d
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x25
.x1d:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x25
.x1e:	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x1f
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x20
.x1f:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x20:	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x21:	dbf	d7,.x22
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x22:	lsr.l	#1,d6
	bcc.s	.x23
	move	0(a5,d5.w),d5
	bpl.s	.x21
	bra.s	.x24
.x23:	move	0(a6,d5.w),d5
	bpl.s	.x21
.x24:	move.b	d5,d0
.x25:	tst.b	d0
	beq	.x2f
	move	d0,d1
	addq	#2,d1
	move.b	d6,d0
	move.b	0(a2,d0.w),d4
	bmi.s	.x27
	move.b	0(a1,d0.w),d0
	cmp	d4,d7
	bcs.s	.x26
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x2e
.x26:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x2e
.x27:	moveq	#8,d4
	cmp	d4,d7
	bcs.s	.x28
	lsr.l	d4,d6
	sub	d4,d7
	bra.s	.x29
.x28:	lsr.l	d7,d6
	sub	d7,d4
	moveq	#16,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
	lsr.l	d4,d6
	sub	d4,d7
.x29:	moveq	#0,d5
	move.b	0(a1,d0.w),d5
	add	d5,d5
.x2a:	dbf	d7,.x2b
	moveq	#15,d7
	swap	d6
	move	(a4)+,d6
	swap	d6
.x2b:	lsr.l	#1,d6
	bcc.s	.x2c
	move	0(a5,d5.w),d5
	bpl.s	.x2a
	bra.s	.x2d
.x2c:	move	0(a6,d5.w),d5
	bpl.s	.x2a
.x2d:	move.b	d5,d0
.x2e:	move.b	d0,(a3)+
	addq.l	#1,buf01
	subq.l	#1,d3
	dbeq	d1,.x2e
	bne	.x11
	bra	.xff
.x2f:	move.b	d2,(a3)+
	addq.l	#1,buf01
	bra	.x1b
buf01:	ds.l	0	
