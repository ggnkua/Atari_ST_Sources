; scroll with 70/50 tilt!
; try F1 and F2
x:
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	$44e,a0
	move.b	#2,$ffff820a.w
	move.w	#0,$ffff825e.w
	move.w	#7999,d0
.lp:	move.l	#$10001,(a0)+
	dbra	d0,.lp
	move.b	#0,$ffff8260.w

.loop:
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	moveq	#2,d1
	moveq	#0,d2
	lea	$ffff8260.w,a1
	move.b	$fffffc02.w,d3

	move.w	#$2700,sr
	lea	$ffff8209.w,a0
	moveq	#0,d0
.wait:	move.b	(a0),d0
	beq.s	.wait
	not.w	d0
	lsr.w	d0,d0


	cmp.b	#59,d3
	bne.s	.skipthis
	move.b	d1,(a1)
	nop
	move.b	d2,(a1)
.skipthis:
	cmp.b	#60,d3
	bne.s	.skipdis
	move.b	d1,(a1)
	nop
	nop
	nop
	move.b	d2,(a1)
.skipdis:

	move.w	#$2300,sr

	cmp.b	#185,$fffffc02.w
	bne	.loop
	move.b	#1,$ffff8260.w
	illegal
	