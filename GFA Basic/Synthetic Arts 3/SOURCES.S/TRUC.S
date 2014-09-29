	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	#3999,d0
	lea.l	nop(pc),a2	
	move.l	#-1,(a2)	
loop:	
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	moveq.l	#0,d1


loop1:	moveq.l	#0,d3
	move.l	(a0)+,d2	
loop2:	

	btst.l	d3,d2		
	bne.s	bit0
ret0:	swap	d2
	btst.l	d3,d2		
	bne.s	bit1
ret1:	addq.w	#1,d3
	btst.l	d3,d2	
	bne.s	bit3
ret3:	swap	d2
	btst.l	d3,d2
	bne.s	bit2
ret2:	addq.w	#1,d3
	addq.w	#1,d1
	cmp.w	#16,d3
	bne.s	loop2

	not.w	(a2)
	tst.w	(a2)
	beq.s	loop1

	ror.w	#8,d4
	ror.w	#8,d5
	ror.w	#8,d6
	ror.w	#8,d7

	move.w	d4,(a1)+
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	move.w	d7,(a1)+

	dbra.w	d0,loop

	rts

nop:	dc.l	0

bit0:	bset.l	d1,d7 	
	bra.s	ret0	

bit1	bset.l	d1,d6
	bra.s	ret1

bit2:	bset.l	d1,d5
	bra.s	ret2
	
bit3:	bset.l	d1,d4
	bra.s	ret3