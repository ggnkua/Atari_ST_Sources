glok	
	move.w	#1000,d6
	moveq.w	#0,d7
	lea	gauche,a0
	lea	droite,a2
	lea	ready,a4
	
	move.w	nb,d4
	subq	#1,d4
	lea	.calcul,a6
	moveq	#-1,d5
.next
	move.l	a0,a5
	move.l	#$80000000,d0
	moveq	#0,d2
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	move.w	(a4),d2
	move.w	2(a4),d3
	cmp.w	d1,d3
	beq	.calcul
	bgt.s	.descend
	cmp.w	d3,d6
	blt.s	.maxY
	move.w	d3,d6
.maxY
	move.l	a2,a5
	exg	d0,d2
	exg	d1,d3	

	lea	(a5,d1.w*2),a5
	sub.w	d1,d3
	sub.w	d0,d2	
	swap	d2
	ext.l	d3
	divs.l	d3,d2
	swap	d0

	tst.w	d1
	bpl.s	.no_clip
	moveq	#0,d6
	neg.w	d1
	sub.w	d1,d3
	bmi	.calcul
	beq	.calcul
	ext.l	d1
	muls.l	d2,d1
	add.l	d1,d0
	move.l	a2,a5	
	cmp.w	#239,d3
	blt.s	.no_clip3	
	move.w	#239,d3
	bra.s	.no_clip3
.no_clip
	add.w	d3,d1
	cmp.w	#239,d1
	ble.s	.no_clip3
	move.w	#239,d7
	sub.w	d7,d1
	sub.w	d1,d3
	bmi	.calcul	
.no_clip3
	move.w	d2,d1
	swap	d2
	
	neg.w	d3
	add.w	d1,d0
	swap	d0	
	move.w	d0,(a5)+		
	jmp	(a6,d3.w*4)



.descend
	cmp.w	d3,d7
	bgt.s	.minY
	move.w	d3,d7
.minY	
	lea	(a5,d1.w*2),a5
	sub.w	d1,d3
	sub.w	d0,d2	
	swap	d2
	ext.l	d3
	divs.l	d3,d2
	swap	d0



	tst.w	d1
	bpl.s	.no_clip1
	moveq	#0,d6
	neg.w	d1
	sub.w	d1,d3
	bmi	.calcul
	beq	.calcul
	ext.l	d1
	muls.l	d2,d1
	add.l	d1,d0
	move.l	a0,a5	
	cmp.w	#239,d3
	blt.s	.no_clip2	
	move.w	#239,d3
	bra.s	.no_clip2
.no_clip1
	add.w	d3,d1
	cmp.w	#239,d1
	ble.s	.no_clip2
	move.w	#239,d7
	sub.w	d7,d1
	sub.w	d1,d3
	bmi	.calcul	
.no_clip2
	moveq	#0,d5
	move.w	d2,d1
	swap	d2
	
	neg.w	d3
	add.w	d1,d0
	swap	d0	
	move.w	d0,(a5)+		
	jmp	(a6,d3.w*4)


	rept	250
	addx.l	d2,d0
	move.w	d0,(a5)+
	endr
.calcul	
	dbf	d4,.next			
	rts

