	movem.l	d0-a6,-(a7)
	move.w	(a0),d0
	and.w	#$00ff,d0
	move.w	d0,res
	lea	34(a1),a4
	lea	34(a0),a1		; start of file

	movem.l	a0/a4,-(a7)
	bsr.s	.dp_degas
	moveq	#21,d0
.1:	move.b	(a1)+,(a4)+	; copy colour cycle info
	dbf	d0,.1
	movem.l	(a7)+,a0/a4
	lea	34(a0),a1
	moveq	#16,d0
.copy:	move.w	-(a1),-(a4)	; copy in pallete
	dbf	d0,.copy
	clr.b	(a4)		; set up header
	movem.l	(a7)+,d0-a6
	rts

.dp_degas:	move.l	#399,d1
	cmp.w	#2,res
	beq.s	.loop
	move.l	#199,d1		; 200 scanlines

.loop:	lea	buffer(pc),a0
	moveq	#-$80,d5
	cmp.w	#2,res
	bge.s	.dep00
	move.w	#$A0,d4
	bra.s	.dep01
.dep00:	moveq	#$50,d4
.dep01:	bra.s	.dep06
.dep02:	move.b	(a1)+,d7
	tst.b	d7
	blt.s	.dep04
	addq.b	#1,d7
.dep03:	move.b	(a1)+,(a0)+
	subq.w	#1,d4
	subq.b	#1,d7
	bne.s	.dep03
	bra.s	.dep06
.dep04:	move.b	d7,d0
	ext.w	d0
	cmp.w	d5,d0
	beq.s	.dep06
	move.b	d7,d0
	ext.w	d0
	neg.w	d0
	move.b	d0,d6
	addq.b	#1,d6
	move.b	(a1)+,d7
.dep05:	move.b	d7,(a0)+
	subq.w	#1,d4
	subq.b	#1,d6
	bne.s	.dep05
.dep06:	tst.w	d4
	bgt.s	.dep02
	movem.l	a0-a1,-(a7)
	bsr.s	biddle
	movem.l	(a7)+,a0-a1
	dbf	d1,.loop
	rts

biddle:	lea	buffer(pc),a6	; rearrange a scanline
	tst.w	res
	bne.s	.rear02
	move.l	a6,b_a_store
	lea	$28(a6),a2
	lea	$50(a6),a3
	lea	$78(a6),a5
	moveq	#0,d7
	bra.s	.rear01
.rear00:	move.l	a4,a0
	move.l	b_a_store(pc),a1
	move.w	(a1),(a0)
	addq.l	#2,b_a_store
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a2,a1
	move.w	(a1),(a0)
	addq.l	#2,a2
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a3,a1
	move.w	(a1),(a0)
	addq.l	#2,a3
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a5,a1
	move.w	(a1),(a0)
	addq.l	#2,a5
	addq.l	#2,a4
	addq.w	#1,d7
.rear01:	cmp.w	#$14,d7
	blt.s	.rear00
	bra.s	.exit
.rear02:	cmp.w	#1,res
	bne.s	.rear05
	move.l	a6,b_a_store
	lea	$50(a6),a2
	clr.w	d7
	bra.s	.rear04
.rear03:	move.l	a4,a0
	move.l	b_a_store(pc),a1
	move.w	(a1),(a0)
	addq.l	#2,b_a_store
	addq.l	#2,a4
	move.l	a4,a0
	move.l	a2,a1
	move.w	(a1),(a0)
	addq.l	#2,a2
	addq.l	#2,a4
	addq.w	#1,d7
.rear04:	cmp.w	#$28,d7
	blt.s	.rear03
	bra.s	.exit
.rear05:	clr.w	d7
	bra.s	.rear07
.rear06:	move.l	a4,a0
	move.l	a6,a1
	move.w	(a1),(a0)
	addq.l	#2,a6
	addq.l	#2,a4
	addq.w	#1,d7
.rear07:	cmp.w	#$28,d7
	blt.s	.rear06
.exit:	rts

b_a_store:	ds.l	1
res:	ds.w	1
