	move.l	4(sp),a0	
	
	lea	pas(pc),a6

	move.l	a0,a2
	move.l	a0,a3
	add.l	#32000,a3

loopv1:	
	tst.l	(a2)+		
	bne.s	finlpv1
	cmpa.l	a2,a3	
	beq	err
	bra.s	loopv1

finlpv1:
	move.l	a2,d0
	sub.l	a0,d0
	divu.w	#160,d0
	move.w	d0,(a6)
	move.w	d0,d5

loopv2:	
	tst.l	-(a3)		
	bne.s	finlpv2
	bra.s	loopv2

finlpv2:
	move.l	a3,d0
	sub.l	a0,d0
	divu.w	#160,d0
	move.w	d0,2(a6)
	move.w	d0,d7
	addq.w	#1,d7	
	cmp.w	d5,d7

ret:	moveq.l	#0,d0
	move.w	d5,d1

	move.l	a0,a4
	move.w	d5,d3
	mulu.w	#160,d3	
	add.l	d3,a4
	move.l	a4,a3		

loop:	
	move.w	d0,d3
	and.l	#$fff0,d3
	lsr.w   #1,d3
	move.l	a3,a1
	add.l	d3,a1
	move.l	(a1),d2
	move.w	d0,d3
	and.l	#$f,d3
	neg.w	d3
	add.w	#15,d3
	btst.l	d3,d2 
	bne.s	ext1
	swap 	d2
	btst.l	d3,d2	
	bne.s	ext1
	move.l	4(a1),d2
	btst.l	d3,d2 
	bne.s	ext1
	swap    d2
	btst.l	d3,d2
	bne.s	ext1

	addq.w	#1,d1
	add.l	#160,a3
	cmp.w	d1,d7
	bne.s	loop
	addq.w	#1,d0
	move.w	d5,d1
	move.l	a4,a3
	bra.s	loop	


ext1:	move.w	d0,4(a6)

	move.w	#319,d0
	move.w	d5,d1

	move.l	a4,a3		

loop2:	
	move.w	d0,d3
	and.l	#$fff0,d3
	lsr.w   #1,d3
	move.l	a3,a1
	add.l	d3,a1
	move.l	(a1),d2
	move.w	d0,d3
	and.l	#$f,d3
	neg.w	d3
	add.w	#15,d3
	btst.l	d3,d2 
	bne.s	ext2
	swap 	d2
	btst.l	d3,d2	
	bne.s	ext2
	move.l	4(a1),d2
	btst.l	d3,d2 
	bne.s	ext2
	swap    d2
	btst.l	d3,d2
	bne.s	ext2

	addq.w	#1,d1
	add.l	#160,a3
	cmp.w	d1,d7
	bne.s	loop2
	subq.w	#1,d0
	move.w	d5,d1
	move.l	a4,a3
	bra.s	loop2	

ext2:	move.w	d0,6(a6)

fin:	move.l	a6,d0

	rts

pas:	nop
	nop	
	nop
	nop

err:	move.w		#-1,(a6)
	bra.s		fin

