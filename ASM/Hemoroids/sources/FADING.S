	lea	Colors,a0
	move.w	#$208,d0
	move.w	#$072,d1
	moveq	#42,d2
	bsr.s	Fade
	move.w	#$072,d0
	move.w	#$802,d1
	moveq	#43,d2
	bsr.s	Fade
	move.w	#$802,d0
	move.w	#$208,d1
	moveq	#43,d2
	
Fade
	moveq	#$f,d3
	and.w	d0,d3
	moveq	#$f,d4
	and.w	d1,d4
	lsl.w	#8,d3
	lsl.w	#8,d4
	sub.w	d3,d4
	ext.l	d4
	divs	d2,d4
	move.w	d2,d6
	subq.w	#1,d6
	move.l	a0,a1
	move.w	d6,d7
.blue
	move.w	d3,d5
	lsr.w	#8,d5
	move.w	d5,(a0)+
	add.w	d4,d3
	dbra	d7,.blue
	
	move.l	a1,a0
	move.w	#$f0,d3
	and.w	d0,d3
	move.w	#$f0,d4
	and.w	d1,d4
	lsl.w	#4,d3
	lsl.w	#4,d4
	sub.w	d3,d4
	ext.l	d4
	divs	d2,d4
	move.w	d6,d7
.green
	move.w	d3,d5
	and.w	#$f00,d5
	lsr.w	#4,d5
	or.w	d5,(a0)+
	add.w	d4,d3
	dbra	d7,.green
	
	move.l	a1,a0
	and.w	#$f00,d0
	and.w	#$f00,d1
	sub.w	d0,d1
	ext.l	d1
	divs	d2,d1
.red
	move.w	d0,d5
	and.w	#$f00,d5
	or.w	d5,(a0)+
	add.w	d1,d0
	dbra	d6,.red
	rts
