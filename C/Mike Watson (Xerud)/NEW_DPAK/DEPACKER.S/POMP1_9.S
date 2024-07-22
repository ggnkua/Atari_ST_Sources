	movem.l	d0-a6,-(a7)
	bsr.s	.getone
	move.l	d0,d5
	bsr.s	.unpack
	movem.l	(a7)+,d0-a6
	rts

.getone:	moveq	#0,d1
	subq.l	#4,a3
.loop:	asl.l	#8,d0
	move.b	(a3,d1.w),d0
	addq.w	#1,d1
	cmpi.w	#4,d1
	bne.s	.loop
	rts

.unpack:	bsr.s	.getone
	movea.l	a3,a0	
;	add.l	#$c,a3
;	sub.l	d0,a3	
	movea.l	a2,a3	
	add.l	d5,a2	

.empty:	move.b	-(a0),d0	
	beq.s	.empty	
.umain:	moveq	#0,d2
	bsr.s	.shifter
	bcs.s	.rep

	move.b	-(a0),d2
.output:	move.b	d2,-(a2)
	bra.s	.ecxit

.rep3:	moveq	#15,d4
	moveq	#2,d3
	bsr.s	.leader
	bne.s	.rloop
	move.w	d4,d2
	bra.s	.output

.rep:	bsr.s	.shifter
	bcc.s	.repeat
	bsr.s	.shifter
	bcc.s	.rep3
	bsr.s	.shifter
	bcs.s	.rep4
.special:	moveq	#2,d1
	bsr	.nibit
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.output
	
.rep4:	bsr.s	.shifter
	bcc.s	.rep5	
	moveq	#15,d4	
	move.w	#3,d3
	bsr.s	.leader
	bne.s	.rloop
	move.b	(a2),-(a2)

.ecxit:	cmpa.l	a2,a3
	blt.s	.umain
	rts

.rep5:	moveq	#4,d3
	bra.s	.reps
.repeat:	bsr.s	.shifter
	bcs.s	.rep2
	moveq	#1,d1
.1:	lsr.b	#1,d0
	bne.s	.2
	move.b	-(a0),d0
	roxr.b	#1,d0
.2:	addx.w	d2,d2
	dbf	d1,.1
	
	move.w	d2,d1	
	beq.s	.runing	
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.nibit
	move.w	d2,d3
.reps:	bsr.s	.lead1	
.rloop:	movea.l	a2,a1
	add.l	d2,a1	
.replp:	move.b	-(a1),-(a2)
	dbf	d3,.replp
	bra.s	.ecxit

.shifter:	lsr.b	#1,d0
	bne.s	.noz
	move.b	-(a0),d0
	roxr.b	#1,d0
.noz:	rts
.lead1:	moveq	#0,d4
.leader:	moveq	#1,d1

	moveq	#0,d2
.n1:	lsr.b	#1,d0
	bne.s	.n2
	move.b	-(a0),d0
	roxr.b	#1,d0
.n2:	addx.w	d2,d2
	dbf	d1,.n1

	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.nibit
	rts	
.nibs:	moveq	#7,d1
.nibit:	moveq	#0,d2
.nlp:	lsr.b	#1,d0
	bne.s	.nlp1
	move.b	-(a0),d0
	roxr.b	#1,d0
.nlp1:	addx.w	d2,d2
	dbf	d1,.nlp
	rts
.runing:	bsr.s	.lead1
	move.w	d2,d3
	moveq	#1,d2
	bra.s	.rloop
.rep2:	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.rloop
