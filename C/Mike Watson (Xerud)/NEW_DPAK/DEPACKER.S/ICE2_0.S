
; Depack ICE v2.0 

ice_2_0_depack:
	movem.l d0-a6,-(sp)	; save registers
	cmpi.l	#'Ice!',(a0)+
	bne.s	.ice207
	move.l	(a0)+,d0	; PACKED SIZE
	lea	-8(a0,d0.l),a5	; GET END OF PACKED PROG
	move.l	(a0)+,(sp)	; UNPACKED SIZE 
	lea	120(a1),a4		; DEPACK TO HERE
	movea.l a4,a6
	adda.l	(sp),a6
	movea.l a6,a3
	movea.l a6,a1
	lea	freespace2+120(pc),a2
	moveq	#$77,d0
.ice200:	move.b	-(a1),-(a2)
	dbra	d0,.ice200
	bsr	.ice20c
	bsr.s	.ice208
	bsr	.ice210
	bcc.s	.ice204
	movea.l a3,a1
	move.w	#$0f9f,d7
.ice201:	moveq	#3,d6
.ice202:	move.w	-(a1),d4
	moveq	#3,d5
.ice203:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice203
	dbra	d6,.ice202
	movem.w d0-d3,(a1)
	dbra	d7,.ice201
.ice204:	move.l	(sp),d0
	lea	-120(a4),a1
.ice205:	move.b	(a4)+,(a1)+
	dbra	d0,.ice205
	subi.l	#$010000,d0
	bpl.s	.ice205
	moveq	#$77,d0
	lea	freespace2+120(pc),a2
.ice206:	move.b	-(a2),-(a3)
	dbra	d0,.ice206
.ice207:	movem.l (sp)+,d0-a6
	rts
.ice208:	bsr.s	.ice210
	bcc.s	.ice20b
	moveq	#0,d1
	bsr.s	.ice210
	bcc.s	.ice20a
	lea	.ice21e(pc),a1
	moveq	#4,d3
.ice209:	move.l	-(a1),d0
	bsr.s	.ice213
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice209
	add.l	20(a1),d1
.ice20a:	move.b	-(a5),-(a6)
	dbra	d1,.ice20a
.ice20b:	cmpa.l	a4,a6
	bgt.s	.ice216
	rts
.ice20c:	moveq	#3,d0
.ice20d:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.ice20d
	rts
.ice20e:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice20f
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	.ice215
.ice20f:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	.ice215
.ice210:	add.l	d7,d7
	beq.s	.ice211
	rts
.ice211:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice212
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.ice212:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.ice213:	moveq	#0,d1
.ice214:	add.l	d7,d7
	beq.s	.ice20e
.ice215:	addx.w	d1,d1
	dbra	d0,.ice214
	rts
.ice216:	lea	.ice21f(pc),a1
	moveq	#3,d2
.ice217:	bsr.s	.ice210
	dbcc	d2,.ice217
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice218
	bsr.s	.ice213
.ice218:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice21a
	lea	.ice220(pc),a1
	moveq	#1,d2
.ice219:	bsr.s	.ice210
	dbcc	d2,.ice219
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice213
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.ice21c
.ice21a:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.ice210
	bcc.s	.ice21b
	moveq	#8,d0
	moveq	#$40,d2
.ice21b:	bsr.s	.ice213
	add.w	d2,d1
.ice21c:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice21d:	move.b	-(a1),-(a6)
	dbra	d4,.ice21d
	bra	.ice208
	dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b $00,$07,$00,$02,$00,$03,$00,$01
	dc.b $00,$03,$00,$01
.ice21e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b $00,$00,$00,$07,$00,$00,$00,$04
	dc.b $00,$00,$00,$01
.ice21f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b $01,$00
.ice220:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
	dc.b $00,$20
