	text
init:
	move	#$FFFF,d0
	bsr	L150
	move	d0,d4
	clr	d0
	bsr	L150
	move.l	#data,(a7)
	move	#$9,-(a7)
	trap	#1
	move	#$2,(a7)
	trap	#14
	move.l	d0,a6
	adda.l	#$3EA8,a6
	clr	d5
slumpa:
	move	#$11,(a7)
	trap	#14
	add	d0,d6
	move	#$F,d7
loopa:
	adda	d6,a5
L3A:
	move	d5,d0
	lsr.w	#7,d0
	mulu	d0,d0
	move	d5,d1
	andi	#$7F,d1
	mulu	d1,d1
	add.l	d1,d0
	cmp.l	#$8000,d0
	bgt	L126
	move	d5,d0
	ror.w	#2,d0
	move	d0,d1
	andi	#$C000,d1
	lsr.w	#2,d1
	add	d1,d0
	move	d0,d1
	andi	#$3F80,d0
	lsr.w	#1,d0
	move	d0,d2
	lsr.w	#2,d0
	add	d0,d2
	andi	#$7F,d1
	move	d1,d3
	andi	#$7E,d3
	lsl.w	#3,d3
	add	d3,d2
	lsl.w	#2,d3
	add	d3,d2
	move	d1,d3
	lsr.w	#3,d3
	move.l	a6,a0
	suba.l	d3,a0
	bchg	d1,80(a0,d2.w)
	suba.l	d2,a0
	bchg	d1,-80(a0)
	not.b	d1
	adda.l	d3,a0
	bchg	d1,-79(a0,d3.w)
	move.l	a6,a0
	adda.l	d2,a0
	bchg	d1,81(a0,d3.w)
	not.b	d1
	move	d1,d3
	lsl.w	#4,d3
	move	d3,d2
	lsl.w	#2,d3
	add	d3,d2
	move	d0,d3
	andi	#$7E0,d3
	add	d3,d2
	add	d3,d2
	lsr.w	#1,d3
	add	d3,d2
	lsr.w	#4,d0
	move	d0,d3
	lsr.w	#3,d3
	move.l	a6,a0
	suba.l	d3,a0
	bchg	d0,80(a0,d2.w)
	suba.l	d2,a0
	bchg	d0,-80(a0)
	not.b	d0
	adda.l	d3,a0
	bchg	d0,-79(a0,d3.w)
	move.l	a6,a0
	adda.l	d2,a0
	bchg	d0,81(a0,d3.w)
	not.b	d0
	move	d0,d3
	sub	d1,d3
	bpl	LEE
	neg	d3
LEE:
	addi	#$1,d3
	andi	#$7E,d3
	lsl.w	#3,d3
	move	d3,d2
	lsl.w	#2,d3
	add	d3,d2
	add	d1,d0
	addi	#$1,d0
	move	d0,d1
	lsr.w	#3,d1
	move.l	a6,a0
	suba.l	d1,a0
	bchg	d0,0(a0,d2.w)
	suba.l	d2,a0
	bchg	d0,0(a0)
	not.b	d0
	adda.l	d1,a0
	bchg	d0,1(a0,d1.w)
	move.l	a6,a0
	adda.l	d2,a0
	bchg	d0,1(a0,d1.w)
L126:
	add	a5,d5
	bne	L3A
	move.l	#$600FF,(a7)
	trap	#1
	cmpi.b	#$20,d0				! Kollar space...
	beq	L144
	dbf	d7,loopa
	bra	slumpa
L144:
	addq.l	#6,a7
	move	d4,d0
	bsr	L150
	clr.l	-(a7)
	trap	#1
L150:
	move	d0,-(a7)
	move.l	#$70000,-(a7)
	trap	#14
	addq.l	#6,a7
	rts

	data


data:	dc.b	$1B
	dc.b	'f'
	dc.b	$0,$0
	end
