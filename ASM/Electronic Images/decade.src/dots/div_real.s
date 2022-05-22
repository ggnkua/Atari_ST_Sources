	move.l	#319,d5		* Top
	move.l	#318,d4		* / bottom.

	move.l	d5,d0
	divu	d4,d0
	move	d0,d5
	swap	d5
	clr	d0
	divu	d4,d0
	move	d0,d5
	
* Returns with MSW as INT part and LSW as FRAC part.
* NOTE that .5 is 32768 (.5 of a word!)
* In this example returns with FRAC 21845 (whick is .3 of 65535/word in!)
* Just divide FRAC by 65535 so humans can unnerstand the converted FRAC!

	moveq.l	#0,d1
	swap	d5
	move.w	d5,d1
	bsr	conv
		
	move.w	#'.',d0
	bsr	writit
		
	swap	d5
	move.w	d5,d1
	
	bsr	conv
	
*	move.w	int(pc),d1
*	bsr	conv
*	move.b	#'.',d0
*	bsr	writit
*	move.w	frac(pc),d1
*	bsr	conv
	

	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)
	trap	#1
	
	
conv:	movem.l	d0-d5/a0,-(sp)
	clr.l	d3
	lea.l	pten(pc),a0
	tst.l	d1
	bpl.s	wrnpos
	moveq.w	#'-',d0
	bsr	writit
	bra.s	wrnnext
wrnpos:	neg.l	d1
wrnnext:move.l	(a0)+,d2
	beq.s	wrndone
	clr.b	d0
wrnloop:add.l	d2,d1
	bgt.s	wrndig
	addq.b	#1,d0
	bra.s	wrnloop
wrndig:	sub.l	d2,d1
wrnnot0:moveq.l	#1,d3
wrnconv:addi.b	#'0',d0
	bsr	writit
	bra.s	wrnnext
wrndone:movem.l	(sp)+,d0-d5/a0
	rts

		
writit:	movem.l	a0-a6/d0-d7,-(sp)	
	move.w	d0,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,a0-a6/d0-d7
	rts
	
pten:	dc.l	1000000000,100000000,10000000,1000000,100000,10000
	dc.l	1000,100,10,1
	dc.l	0
	
int:	dc.l	94000
frac:	dc.l	0