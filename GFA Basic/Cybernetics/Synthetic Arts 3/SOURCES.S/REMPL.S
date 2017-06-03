*-------------------------------------------------------------------------*
*									  *
* 	-SYNTHETIC ARTS 2-			- CYBERNETICS 1992 -  	  *
*									  *
*	REMPLACEMENT COULEURS						  *
*									  *
*-------------------------------------------------------------------------*

	move.l	4(sp),a0	*ecran
	move.l	8(sp),a1	*v:crap&(0)
	move.w	12(sp),d0	*x1
	move.w	d0,a2
	move.w	14(sp),d1	*y1
	move.w	16(sp),d2	*x2
	move.w	18(sp),d3	*y2	

loop:	moveq.l	#0,d7
	move.w	d0,d4
	and.l	#$fff0,d4
	lsr.w   #1,d4
	move.l	a0,a3
	add.l	d4,a3
	move.l	(a3),d5
	move.w	d0,d4
	and.l	#$f,d4
	neg.w	d4
	add.w	#15,d4
	btst.l	d4,d5 
	bne.s	bit1
ret1:	swap 	d5
	btst.l	d4,d5	
	bne.s	bit2
ret2:	move.l	4(a3),d5
	btst.l	d4,d5 
	bne.s	bit3
ret3:	swap    d5
	btst.l	d4,d5
	bne.s	bit4

ret4:		
	lsl.w	#1,d7
	move.l	a1,a4
	add.l	d7,a4
	move.w	(a4),d6
	cmp.w	#-1,d6
	bne.s	pset

return:	
	addq.w	#1,d0
	cmp.w	d0,d2
	bne.s	loop
	addq.w	#1,d1
	move.w	a2,d0
	add.l	#160,a0
	cmp.w	d1,d3
	bne.s	loop	

	rts

bit1:	bset.l	#1,d7
	bra.s	ret1

bit2:	bset.l	#0,d7
	bra.s	ret2

bit3:	bset.l	#3,d7
	bra.s	ret3

bit4:	bset.l	#2,d7
	bra.s	ret4


pset:	moveq.l	#0,d7
	bset.l	d4,d7
	swap	d7
	bset.l	d4,d7
	not.l	d7
	and.l	d7,(a3)
	and.l	d7,4(a3)
	moveq.l	#0,d7
	btst.l	#0,d6
	bne.s	bit14
ret14:	swap	d7
	btst.l	#1,d6
	bne.s	bit24
ret24:	
	or.l	d7,(a3)
	moveq.l	#0,d7

	btst.l	#2,d6
	bne.s	bit34
ret34:	swap	d7
	btst.l	#3,d6
	bne.s	bit44
ret44:	
	or.l	d7,4(a3)

	bra	return

bit14:	bset.l	d4,d7
	bra.s	ret14

bit24:	bset.l	d4,d7
	bra.s	ret24

bit34:	bset.l	d4,d7
	bra.s	ret34

bit44:	bset.l	d4,d7
	bra.s	ret44
