* 32 Number convertor using the very
* quick exponent table method...

		move.l #987654321,d1
		bsr conv
		move #7,-(sp)
		trap #1
		addq.l #2,sp
		clr.w	-(sp)
		trap #1
	
conv:		movem.l d0-d5/a0,-(sp)
		MOVEQ #0,D3
		lea.l	pten(pc),a0
wrnpos:	neg.l	d1
wrnnext:	move.l (a0)+,d2
		beq.s	wrndone
		clr.b	d0
wrnloop:	add.l	d2,d1
		bgt.s	wrndig
		addq.b #1,d0
		bra.s	wrnloop
wrndig:	sub.l	d2,d1
		bra.s	wrnconv
		bra.s	wrnnext
wrnnot0:	moveq #1,d3
wrnconv:	addi.b #'0',d0
		bsr writit
		bra.s	wrnnext
wrndone:	movem.l (sp)+,d0-d5/a0
		rts

writit:	movem.l a0-a6/d0-d7,-(sp)	
		move d0,-(sp)
		move #6,-(sp)
		trap #1
		addq.l #4,sp
		movem.l (sp)+,a0-a6/d0-d7
		rts
	
pten:		dc.l	1000000000,100000000,10000000,1000000,100000,10000
		dc.l	1000,100,10,1
		dc.l	0