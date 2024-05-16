increm	
	movem.w	(a0),d0-d5	
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	and.w	#$1ff,d0
	and.w	#$1ff,d1
	and.w	#$1ff,d2
	movem.w	d0-d2,(a0)
	rts

efface_objet
	move.l	work,a1
	lea	mul160,a2
	movem.w	(a0),d0-d3
	tst.w	d1
	bpl.s	.a
	moveq	#0,d1
.a	cmp.w	#239,d1
	blt.s	.x
	move.w	#239,d1
.x	tst.w	d3
	bpl.s	.c
	moveq	#0,d3
.c	cmp.w	#239,d3
	blt.s	.d
	move.w	#239,d3
.d	tst.w	d0
	bpl.s	.e
	moveq	#0,d0
.e	cmp.w	#383,d0
	blt.s	.f
	move.w	#383,d0
.f	tst.w	d2
	bpl.s	.g
	moveq	#0,d2
.g	cmp.w	#383,d2
	blt.s	.h
	move.w	#383,d2
.h	add.l	(a2,d1.w*4),a1
	sub.w	d1,d3
	bmi.s	.rt‚s
	and.w	#$fff0,d0
	and.w	#$fff0,d2
	move.w	d0,d4
	lsr.w	#1,d4
	add.w	d4,a1
	sub.w	d0,d2
	bmi.s	.rt‚s
	move.w	#192-8,d5
	lsr.w	#1,d2
	sub.w	d2,d5
	lsr.w	#3,d2
	moveq	#0,d6
	neg.w	d2	
.re	jmp     .clear(pc,d2.w*4)
.re1	
	rept	18
	move.l	d6,(a1)+		
	move.l	d6,(a1)+		
	endr
.clear	move.l	d6,(a1)+		
	move.l	d6,(a1)+		
	add.w	d5,a1
	dbf	d3,.re
.rt‚s	rts

ech_adr
	movem.l	adr_eff,d0-d3
	exg.l	d0,d2
	exg.l	d1,d3
	movem.l	d0-d3,adr_eff
	rts

