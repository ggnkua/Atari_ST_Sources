; Depack ICE v2.2 

ice_2_2_depack:
	movem.l d0-a6,-(sp)
	bsr.s	.ice2_204
	cmpi.l	#'Ice!',d0	
	bne.s	.ice2_203
	bsr.s	.ice2_204
	lea	-8(a0,d0.l),a5
	bsr.s	.ice2_204
	move.l	d0,(sp)
	movea.l	a1,a4
	movea.l	a1,a6
	adda.l	d0,a6
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.ice2_206
	bsr.s	.ice2_20a
	bcc.s	.ice2_203
	move.w	#$0f9f,d7
.pic00:	moveq	#3,d6	
.pic01:	move.w	-(a3),d4	
	moveq	#3,d5
.pic02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.pic02
	dbra	d6,.pic01
	movem.w	d0-d3,(a3)
	dbra	d7,.pic00
.ice2_203:	movem.l	(sp)+,d0-a6
	rts
.ice2_204:	moveq	#3,d1
.ice2_205:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,.ice2_205
	rts
.ice2_206:	bsr.s	.ice2_20a
	bcc.s	.ice2_209
	moveq	#0,d1
	bsr.s	.ice2_20a
	bcc.s	.ice2_208
	lea	.ice2_217(pc),a1
	moveq	#4,d3
.ice2_207:	move.l	-(a1),d0
	bsr.s	.ice2_20c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice2_207
	add.l	20(a1),d1
.ice2_208:	move.b	-(a5),-(a6)
	dbra	d1,.ice2_208
.ice2_209:	cmpa.l	a4,a6
	bgt.s	.ice2_20f
	rts
.ice2_20a:	add.b	d7,d7
	bne.s	.ice2_20b
	move.b	-(a5),d7
	addx.b	d7,d7
.ice2_20b:	rts
.ice2_20c:	moveq	#0,d1
.ice2_20d:	add.b	d7,d7
	bne.s	.ice2_20e
	move.b	-(a5),d7
	addx.b	d7,d7
.ice2_20e:	addx.w	d1,d1
	dbra	d0,.ice2_20d
	rts
.ice2_20f:	lea	.ice2_218(pc),a1
	moveq	#3,d2
.ice2_210:	bsr.s	.ice2_20a
	dbcc	d2,.ice2_210
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice2_211
	bsr.s	.ice2_20c
.ice2_211:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice2_213
	lea	.ice2_219(pc),a1
	moveq	#1,d2
.ice2_212:	bsr.s	.ice2_20a
	dbcc	d2,.ice2_212
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice2_20c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.ice2_215
	sub.w	d4,d1
	bra.s	.ice2_215
.ice2_213:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	.ice2_20a
	bcc.s	.ice2_214
	moveq	#8,d0
	moveq	#$3f,d2
.ice2_214:	bsr.s	.ice2_20c
	add.w	d2,d1
.ice2_215:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice2_216:	move.b	-(a1),-(a6)
	dbra	d4,.ice2_216
	bra	.ice2_206
	DC.B	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B	$00,$07,$00,$02,$00,$03,$00,$01
	DC.B	$00,$03,$00,$01
.ice2_217:	DC.B	$00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B	$00,$00,$00,$07,$00,$00,$00,$04
	DC.B	$00,$00,$00,$01
.ice2_218:	DC.B	$09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B	$01,$00
.ice2_219:	DC.B	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B	$00,$1f
