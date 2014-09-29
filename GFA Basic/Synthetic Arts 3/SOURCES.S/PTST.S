	move.l	4(sp),a0	*ecran
	move.w	8(sp),d0	*x1
	move.w	10(sp),d1
	
	addq.l	#4,a7

	mulu.w	#160,d1
	add.l	d1,a0

	clr.w	(a7)
	move.w	d0,d7
	and.l	#$fff0,d7
	lsr.w   #1,d7
	move.l	a0,a6
	add.l	d7,a6
	move.l	(a6)+,d6
	move.w	d0,d7
	and.l	#$f,d7
	neg.w	d7
	add.w	#15,d7
	btst.l	d7,d6 
	bne.s	bit1
ret1:	swap 	d6
	btst.l	d7,d6	
	bne.s	bit2
ret2:	move.l	(a6),d6
	btst.l	d7,d6 
	bne.s	bit3
ret3:	swap    d6
	btst.l	d7,d6 
	bne.s	bit4

ret4:	moveq.l	#0,d0
	move.b	(a7),d0
	
	subq.l	#4,a7

	rts

bit1:	bset.b	#1,(a7)
	bra.s	ret1

bit2:	bset.b	#0,(a7)
	bra.s	ret2

bit3:	bset.b	#3,(a7)
	bra.s	ret3

bit4:	bset.b	#2,(a7)
	bra.s	ret4
