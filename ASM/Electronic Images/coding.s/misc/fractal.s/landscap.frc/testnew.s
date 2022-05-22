; Well here's the 'fast' sprite...  It's for a 64 x 56...  Well, you
; can adjust the height!!


spritehg	equ	56	; Sprite height.

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,oldsp

	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	clr.b	$ffff8260.w
	movem.l	pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	$ffff8201.w,scrnpos+1
	move.b	$ffff8203.w,scrnpos+2

	lea	sprite(pc),a0
	lea	mask(pc),a1
	move.w	#256-1,d0
genmask:
	move.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	not.w	d1
	move.w	d1,(a1)+
	dbra	d0,genmask

	lea	sprite(pc),a0
	move.w	#56-1,d4
convsp:	
	rept	2
	move.w	8(a0),d0
	swap	d0
	move.w	(a0),d0
	move.w	10(a0),d1
	swap	d1
	move.w	2(a0),d1
	move.w	12(a0),d2
	swap	d2
	move.w	4(a0),d2
	move.w	14(a0),d3
	swap	d3
	move.w	6(a0),d3
	movem.l	d0-d3,(a0)
	lea	16(a0),a0
	endr
	dbra	d4,convsp
	

key:
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp

	move.w	#$777,$ffff8240.w
	
	
mod1:	move.w	#0,d0		; Shift count.

	move.w	#0,a2
	cmpi.w	#8,d0
	ble.s	notswp
	move.w	#1,a2
notswp:

	bsr	putmask
	bsr	putdata


	clr.w	$ffff8240.w

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.w	#4,sp
	cmpi.b	#'m',d0
	bne	nxttst
	addq.w	#1,mod1+2
	bra	key
nxttst:	tst.w	d0
	beq	key	

	
	move.w	#$777,$ffff8240.w
	clr.w	$ffff8246.w
	
	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	
	clr.w	-(sp)
	trap	#1

putmask:
	move.w	d0,d1
	neg.w	d1
	add.w	#16,d1
	move.w	#%1111111111111111,d6
	move.w	d6,d7
	lsl.w	d1,d6
	lsr.w	d0,d7
	lea	mask(pc),a0
	move.l	scrnpos(pc),a1
	lea	16000(a1),a1
	moveq	#spritehg-1,d5
	cmp.w	#0,a2
	bne	swapmask
	
maskit1:
	move.l	#%11111111111111110000000000000000,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	d1,d4
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	ror.l	d0,d1		; Shift first chunk.
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	swap	d1
	ror.l	d0,d2
	and.w	d6,d1
	or.w	d1,d2
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	swap	d2
	ror.l	d0,d3
	or.w	d2,d3
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	swap	d3
	ror.l	d0,d4
	and.w	d7,d4
	or.w	d3,d4
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	swap	d4
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	lea	120(a1),a1
	dbra	d5,maskit1
	rts

swapmask:
	move.w	d0,-(sp)
	move.w	d0,d1
	moveq	#16,d0
	sub.w	d1,d0
maskit2:
	move.l	#%11111111111111110000000000000000,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	d1,d4
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	swap	d1
	rol.l	d0,d1		; Shift first chunk.
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	swap	d1
	swap	d2
	rol.l	d0,d2
	and.w	d6,d1
	or.w	d1,d2
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	swap	d2
	swap	d3
	rol.l	d0,d3
	or.w	d2,d3
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	swap	d3
	swap	d4
	rol.l	d0,d4
	and.w	d7,d4
	or.w	d3,d4
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	swap	d4
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	and.w	d4,(a1)+
	lea	120(a1),a1
	dbra	d5,maskit2
	move.w	(sp)+,d0
	rts	


putdata:
	lea	sprite(pc),a0
	move.l	scrnpos(pc),a1
	lea	16000(a1),a1
	moveq	#spritehg-1,d7
	move.w	#%1111111111111111,d6
	lsr.w	d0,d6
	move.w	d6,d5
	not.w	d6
	move.w	d6,a3
	cmp.w	#0,a2
	bne	swapdata

data1:	rept	2

	movem.l	(a0)+,d1-d4
	move.w	a3,d6
	ror.l	d0,d1
	and.w	d1,d6
	and.w	d5,d1
	or.w	d1,(a1)+
	swap	d1
	or.w	d1,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	ror.l	d0,d2
	and.w	d2,d6
	and.w	d5,d2
	or.w	d2,(a1)+
	swap	d2
	or.w	d2,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	ror.l	d0,d3
	and.w	d3,d6
	and.w	d5,d3
	or.w	d3,(a1)+
	swap	d3
	or.w	d3,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	ror.l	d0,d4
	and.w	d4,d6
	and.w	d5,d4
	or.w	d4,(a1)+
	swap	d4
	or.w	d4,6(a1)
	or.w	d6,14(a1)

	lea	8(a1),a1
	endr

	lea	128(a1),a1
	
	dbra	d7,data1
	rts

swapdata:
	move.w	d0,d1
	moveq	#16,d0
	sub.w	d1,d0
data2:	
	rept	2
	movem.l	(a0)+,d1-d4
	move.w	a3,d6
	swap	d1
	rol.l	d0,d1
	and.w	d1,d6
	and.w	d5,d1
	or.w	d1,(a1)+
	swap	d1
	or.w	d1,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	swap	d2
	rol.l	d0,d2
	and.w	d2,d6
	and.w	d5,d2
	or.w	d2,(a1)+
	swap	d2
	or.w	d2,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	swap	d3
	rol.l	d0,d3
	and.w	d3,d6
	and.w	d5,d3
	or.w	d3,(a1)+
	swap	d3
	or.w	d3,6(a1)
	or.w	d6,14(a1)

	move.w	a3,d6
	swap	d4
	rol.l	d0,d4
	and.w	d4,d6
	and.w	d5,d4
	or.w	d4,(a1)+
	swap	d4
	or.w	d4,6(a1)
	or.w	d6,14(a1)

	lea	8(a1),a1
	endr

	lea	128(a1),a1
	dbra	d7,data2

	rts



	
oldsp:	ds.l	1
scrnpos:ds.l	1

pal:	dc.w	$0,$11,$122,$233,$344,$762,$110,$221
	dc.w	$332,$443,$21,$32,$143,$710,$730,$455

sprite:	incbin	d:\sprite.fe4
mask:	ds.b	1792/4