	movem.l	a0-a6/D0-d7,-(a7)
	lea	-$180(a7),a7
	movea.l	a7,a2
	bsr	.rnc121A
	moveq	#0,d1
	cmpi.l	#$524E4301,d0
	bne	.rnc1211
	bsr	.rnc121A
	move.l	d0,$180(a7)
	lea	$A(a0),a3
	movea.l	a1,a5
	lea	0(a5,d0.L),a6
	bsr	.rnc121A
	lea	0(a3,d0.L),a4
	clr.w	-(a7)
	cmpa.l	a4,a5
	bcc.s	.rnc1208
	moveq	#0,d0
	move.b	-2(a3),d0
	lea	0(a6,d0.L),a0
	cmpa.l	a4,a0
	bls.s	.rnc1208
	addq.w	#2,a7
	move.l	a4,d0
	btst	#0,d0
	beq.s	.rnc1203
	addq.w	#1,a4
	addq.w	#1,a0
.rnc1203:	move.l	a0,d0
	btst	#0,d0
	beq.s	.rnc1204
	addq.w	#1,a0
.rnc1204:	moveq	#0,d0
.rnc1205:	cmpa.l	a0,a6
	beq.s	.rnc1206
	move.b	-(a0),d1
	move.w	d1,-(a7)
	addq.b	#1,d0
	bra.s	.rnc1205
.rnc1206:	move.w	d0,-(a7)
	adda.l	d0,a0
.rnc1207:	lea	-$20(a4),a4
	movem.l	(a4),d0-d7
	movem.l	d0-d7,-(a0)
	cmpa.l	a3,a4
	bhi.s	.rnc1207
	suba.l	a4,a3
	adda.l	a0,a3
.rnc1208:	moveq	#0,d7
	move.b	1(a3),d6
	rol.w	#8,d6
	move.b	(a3),d6
	moveq	#2,d0
	moveq	#2,d1
	bsr	.rnc1217
.rnc1209:	movea.l	a2,a0
	bsr	.rnc121C
	lea	$80(a2),a0
	bsr	.rnc121C
	lea	$100(a2),a0
	bsr	.rnc121C
	moveq	#-1,d0
	moveq	#$10,d1
	bsr	.rnc1217
	move.w	d0,d4
	subq.w	#1,d4
	bra.s	.rnc120C
.rnc120A:	lea	$80(a2),a0
	moveq	#0,d0
	bsr.s	.rnc1213
	neg.l	d0
	lea	-1(a5,d0.L),a1
	lea	$100(a2),a0
	bsr.s	.rnc1213
	move.b	(a1)+,(a5)+
.rnc120B:	move.b	(a1)+,(a5)+
	dbf	d0,.rnc120B
.rnc120C:	movea.l	a2,a0
	bsr.s	.rnc1213
	subq.w	#1,d0
	bmi.s	.rnc120E
.rnc120D:	move.b	(a3)+,(a5)+
	dbf	d0,.rnc120D
	move.b	1(a3),d0
	rol.w	#8,d0
	move.b	(a3),d0
	lsl.l	d7,d0
	moveq	#1,d1
	lsl.w	d7,d1
	subq.w	#1,d1
	and.l	d1,d6
	or.l	d0,d6
.rnc120E:	dbf	d4,.rnc120A
	cmpa.l	a6,a5
	bcs.s	.rnc1209
	move.w	(a7)+,d0
	beq.s	.rnc1210
.rnc120F:	move.w	(a7)+,d1
	move.b	d1,(a5)+
	subq.b	#1,d0
	bne.s	.rnc120F
.rnc1210:	bra.s	.rnc1212
.rnc1211:	move.l	d1,$180(a7)
.rnc1212:	lea	$180(a7),a7
	movem.l	(a7)+,a0-a6/D0-d7
	rts
.rnc1213:	move.w	(a0)+,d0
	and.w	d6,d0
	sub.w	(a0)+,d0
	bne.s	.rnc1213
	move.b	$3C(a0),d1
	sub.b	d1,d7
	bge.s	.rnc1214
	bsr.s	.rnc1219
.rnc1214:	lsr.l	d1,d6
	move.b	$3D(a0),d0
	cmpi.b	#2,d0
	blt.s	.rnc1216
	subq.b	#1,d0
	move.b	d0,d1
	move.b	d0,d2
	move.w	$3E(a0),d0
	and.w	d6,d0
	sub.b	d1,d7
	bge.s	.rnc1215
	bsr.s	.rnc1219
.rnc1215:	lsr.l	d1,d6
	bset	d2,d0
.rnc1216:	rts
.rnc1217:	and.w	d6,d0
	sub.b	d1,d7
	bge.s	.rnc1218
	bsr.s	.rnc1219
.rnc1218:	lsr.l	d1,d6
	rts
.rnc1219:	add.b	d1,d7
	lsr.l	d7,d6
	swap	d6
	addq.w	#4,a3
	move.b	-(a3),d6
	rol.w	#8,d6
	move.b	-(a3),d6
	swap	d6
	sub.b	d7,d1
	moveq	#$10,d7
	sub.b	d1,d7
	rts
.rnc121A:	moveq	#3,d1
.rnc121B:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.rnc121B
	rts
.rnc121C:	moveq	#$1F,d0
	moveq	#5,d1
	bsr.s	.rnc1217
	subq.w	#1,d0
	bmi.s	.rnc1222
	move.w	d0,d2
	move.w	d0,d3
	lea	-$10(a7),a7
	movea.l	a7,a1
.rnc121D:	moveq	#$F,d0
	moveq	#4,d1
	bsr.s	.rnc1217
	move.b	d0,(a1)+
	dbf	d2,.rnc121D
	moveq	#1,d0
	ror.l	#1,d0
	moveq	#1,d1
	moveq	#0,d2
	movem.l	d5-d7,-(a7)
.rnc121E:	move.w	d3,d4
	lea	$C(a7),a1
.rnc121F:	cmp.b	(a1)+,d1
	bne.s	.rnc1221
	moveq	#1,d5
	lsl.w	d1,d5
	subq.w	#1,d5
	move.w	d5,(a0)+
	move.l	d2,d5
	swap	d5
	move.w	d1,d7
	subq.w	#1,d7
.rnc1220:	roxl.w	#1,d5
	roxr.w	#1,d6
	dbf	d7,.rnc1220
	moveq	#$10,d5
	sub.b	d1,d5
	lsr.w	d5,d6
	move.w	d6,(a0)+
	move.b	d1,$3C(a0)
	move.b	d3,d5
	sub.b	d4,d5
	move.b	d5,$3D(a0)
	moveq	#1,d6
	subq.b	#1,d5
	lsl.w	d5,d6
	subq.w	#1,d6
	move.w	d6,$3E(a0)
	add.l	d0,d2
.rnc1221:	dbf	d4,.rnc121F
	lsr.l	#1,d0
	addq.b	#1,d1
	cmpi.b	#$11,d1
	bne.s	.rnc121E
	movem.l	(a7)+,d5-d7
	lea	$10(a7),a7
.rnc1222:	rts
