	opt s-
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,oldstk
	move.l $70,oldint
	moveq #0,d0
	bsr music	
	move.l #int,$70
	clr.w $ffff8240.w
	move.w #$777,$ffff825e.w
	lea crack,a0
	lea $140.w,a1
cc	move.l (a0)+,(a1)+
	cmp.l #oldstk,a0
	blt cc
	move.l #$140,$bc.w
	move.l #$14c,$80.w
	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
notr	move.l oldint,$70
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	move.l oldstk,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp  
	clr.w -(sp)
	trap #1
int	movem.l d0-d7/a0-a6,-(sp)
	bsr (music+4)
	movem.l (sp)+,d0-d7/a0-a6
	move.l $84.w,$24.w
	move.l oldint,-(sp)
	rts
crack	move.b #$60,$1276(a2)
.1	move.l a2,2(sp)
	rte
	move.b #$60,$1258(a2)
	bra.s .1
oldstk	dc.l 0
oldint	dc.l 0
music	incbin "c:\music\runman.mus"
text	dc.b 27,'f',27,'E'
	dc.b "Cynix Present",10,13
	dc.b "~~~~~~~~~~~~~",10,10,13
	dc.b "Sky Strike",10,10,13
	dc.b "Hacked by Absu - but who cares ?",10,13
	dc.b "Original supplied by Mike",10,10,10,13
	even
	dc.w 0
