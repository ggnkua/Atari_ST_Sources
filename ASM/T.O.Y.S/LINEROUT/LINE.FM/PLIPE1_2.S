*
*	LINE ROUT v 1.2
*

*	Coded by:   PeyloW of T.O.Y.S. for fun.

*	0,0-319,199	7	(+160,100)	(2400)
*	0,0-0,199	15	(+0,55)		(3055)
*	0,0-119,0	13	(+170,0)	(2770)
*	0,0-199,199	11	(+145,145)	(2345)

*-------------------------------*
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp

	move.w	#0,$ffff8260.w
	move.l	$44e,a0
	move.l	#7999,d0
clear:
	clr.l	(a0)+
	dbra	d0,clear
	
loop:

	move.w	#$707,$ffff8240.w
	
	rept	7
	move.l	$44e,a0
	move.l	#0,d0
	move.l	#0,d1
	move.l	#319,d2
	move.l	#199,d3	
	bsr	PLINE
	endr
	
	move.w	#$fff,$ffff8240.w
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	cmp.b	#$39,$fffffc02.w
	bne	loop

	move.w	#1,$ffff8260.w
	
	clr.w	-(sp)
	trap	#1
*-------------------------------*


PLINE:
	cmp.w	d0,d2		; x2 > x1 then flip
	blt.s	noflip
	exg.l	d0,d2
	exg.l	d1,d3
noflip:
	move.w	#160,d7		; line add.
	
	move.w	d3,d4		; ystart
	mulu	d7,d4
	add.w	d4,a0
	
	move.w	d2,d4		; xstart
	ror.w	d4
	and.w	#$7ff8,d4
	add.w	d4,a0
	
	move.w	#$8000,d6	; fix start mask
	move.w	d2,d4
	and.w	#$f,d4
	ror.w	d4,d6
	
	sub.w	d2,d0		; Delta x and y
	sub.w	d3,d1
	bge.s	noneg		; Negative delta y?
	neg.w	d1		; Japp
	neg.w	d7
noneg:
	cmp.w	d0,d1		; ver or hor line???
	bge.s	verticaly

horizontaly:
	
	move.w	d1,d4
	addq.w	#1,d4
	swap	d4
	divu	d0,d4		; d4=decimal add

	moveq	#0,d3
	move.w	d0,d5		; d5=loops
	
	cmp.w	#$5555,d4
	ble.s	horizontal2

horloop:
	or.w	d6,(a0)		; Set dot
	ror.w	d6		; rotate mask
	bcc.s	nocarry1	; end of mod 16 ?
	addq.w	#8,a0		; add to next bitplan
nocarry1:
	add.w	d4,d3		; y decimal
	bcc.s	nocarry2	; y step?
	add.w	d7,a0		; Yes it is
nocarry2:
	dbra	d5,horloop	; all dots please
	rts
	

horizontal2:
	moveq.l	#0,d2
horloop2:
	or.w	d6,d2		; Set dot in register
	ror.w	d6		; rotate mask
	bcc.s	nocarry4	; end of mod 16 ?
	or.w	d2,(a0)
	moveq.l	#0,d2
	addq.w	#8,a0		; add to next bitplan
nocarry4:
	add.w	d4,d3		; y decimal
	bcc.s	nocarry5	; y step?
	or.w	d2,(a0)
	moveq.l	#0,d2
	add.w	d7,a0		; Yes it is
nocarry5:
	dbra	d5,horloop2	; all dots please
	rts



verticaly:

	bne.s	notsame
	moveq	#-1,d4
	moveq	#1,d3
	bra.s	same	
notsame:
	move.w	d0,d4
	addq.w	#1,d4
	swap	d4
	divu	d1,d4		; d4=decimal add
	moveq	#0,d3
same:
	move.w	d1,d5		; d5=loops
	
verloop:
	or.w	d6,(a0)		; Set dot
	add.w	d7,a0		; Y step
	add.w	d4,d3		; X decimal
	bcc.s	nocarry3	; Time for x step?
	ror.w	d6		; ror mask
	bcc.s	nocarry3	; end of mod 16?
	addq.w	#8,a0		; Yes it is
nocarry3
	dbra	d5,verloop	; all dots here as well
	rts


