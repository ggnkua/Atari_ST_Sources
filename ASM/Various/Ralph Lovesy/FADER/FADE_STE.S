;Fades all colours to black (STE only)
;ENTRY Colour palette holds current colours
;      Supervisor mode enabled
;EXIT  Colour palette set to all black

fadeoff	move.w	#16-1,d0	16 stages!
.loop1 	move.w	#16-1,d1
	move.l	#$ffff8240,a0
.loop2	move.w	(a0),d2
	move.w	d2,d3
	andi.w	#$F,d2
	lsr.w	#4,d3
	move.w	d3,d4
	andi.w	#$F,d3
	lsr.w	#4,d4
	andi.w	#$F,d4
	tst.w	d2
	beq.s	.end1
	btst	#3,d2	Test additional bit!
	beq.s	.clear1
	bclr	#3,d2
	bra.s	.end1

.clear1	bset	#3,d2
	subq.w	#1,d2
.end1	tst.w	d3
	beq.s	.end2
	btst	#3,d3	Test additional bit!
	beq.s	.clear2
	bclr	#3,d3
	bra.s	.end2

.clear2	subq.w	#1,d3
	bset	#3,d3
.end2	tst.w	d4
	beq.s	.end3
	btst	#3,d4	Test additional bit!
	beq.s	.clear3
	bclr	#3,d4
	bra.s	.end3

.clear3	subq.w	#1,d4
	bset	#3,d4
.end3	lsl.w	#8,d4
	lsl.w	#4,d3
	or.w	d4,d2
	or.w	d3,d2
	andi.w	#$fff,d2	Not really needed, since
	move.w	d2,(a0)+	extra bits are ignored...
	dbra	d1,.loop2
	
	move.l	$466,d5
.vblank	cmp.l	$466,d5
	beq.s	.vblank
	dbra	d0,.loop1
	rts

* STE Fade on: Again, see ST(FM) fadeon routine for main comments.

;Fade on colours to values in new palette (STE)
;ENTRY a2=address of new palette
;      Supervisor mode enabled
;EXIT  Palette changed to new palette

fadeon	move.w	#16-1,d0	16 colours
.loop1 	move.w	#16-1,d1
	move.l	#$ffff8240,a0
	move.l	a2,a1
.loop2	move.w	(a0),d2
	move.w	d2,d3
	andi.w	#$F,d2
	lsr.w	#4,d3
	move.w	d3,d4
	andi.w	#$F,d3
	lsr.w	#4,d4
	andi.w	#$F,d4
	move.w	(a1)+,d5
	move.w	d5,d6
	andi.w	#$F,d5
	lsr.w	#4,d6
	move.w	d6,d7
	andi.w	#$F,d6
	lsr.w	#4,d7
	andi.w	#$F,d7
	
	cmp.w	d2,d5
	beq.s	.end1
	btst	#3,d2	Test additional bit!
	beq.s	.clear1
	bclr	#3,d2
	addq.w	#1,d2
	bra.s	.end1

.clear1	bset	#3,d2
.end1	cmp.w	d3,d6
	beq.s	.end2
	btst	#3,d3	Test additional bit!
	beq.s	.clear2
	bclr	#3,d3
	addq.w	#1,d3
	bra.s	.end2

.clear2	bset	#3,d3
.end2	cmp.w	d4,d7
	beq.s	.end3
	btst	#3,d4	Test additional bit!
	beq.s	.clear3
	bclr	#3,d4
	addq.w	#1,d4
	bra.s	.end3

.clear3	bset	#3,d4
.end3	lsl.w	#8,d4
	lsl.w	#4,d3
	or.w	d4,d2
	or.w	d3,d2
	andi.w	#$fff,d2
	move.w	d2,(a0)+
	dbra	d1,.loop2

	move.l	$466,d5
.vblank	cmp.l	$466,d5
	beq.s	.vblank
	dbra	d0,.loop1
	rts
