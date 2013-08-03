*************************************
*Taktownica by Vat (alias Mr.Nobody)*
* ciag instrukcji zawarty miedzy... *
* zabiera tyle taktow o ile grafika *
* jest przesunieta wzgledem koloru. *
*************************************
graphcs	equ	$f0f0 ;shif, if need!
graphct	equ	$ff00
Begin:	;opt	x+
	bsr	Rez
	clr.w	$484.w
MAINLOOP
	BSR	COLCYCLE
	BSR	VBL
	BRA.S	MAINLOOP

COLCYCLE:
	move.w	#$2700,sr
	lea	$ffff8209.w,a0
	lea	cycle(pc),a1
	lea	1000(a1),a2
	moveq	#0,d0
.sync	move.b	(a0),d0
	beq.s	.sync
	jmp	(a1,d0.w)
cycle	dcb.w	$4e71,120-1

*************************************
*===================================*

podstaw
	move.w	d2,d3


*===================================*
*************************************

	LEA	$FFFF8240.W,A0
	MOVE.W	(A0),-(A7)
	MOVE.W	#$770,(A0)
	MOVE.W	#$760,(A0)
	MOVE.W	#$750,(A0)
	MOVE.W	#$740,(A0)
	MOVE.W	#$630,(A0)
	MOVE.W	#$520,(A0)
	MOVE.W	#$410,(A0)
	MOVE.W	#$300,(A0)
	MOVE.W	#$200,(A0)
	MOVE.W	#$300,(A0)
	MOVE.W	#$410,(A0)
	MOVE.W	#$520,(A0)
	MOVE.W	#$630,(A0)
	MOVE.W	#$740,(A0)
	MOVE.W	#$750,(A0)
	MOVE.W	#$760,(A0)
	MOVE.W	#$770,(A0)
	MOVE.W	(A7)+,(A0)
	move.w	#$40,2(a0)
	move.w	#$2300,sr
	rts

VBL:
	move.w	$468.w,d0
.sync	cmp.w	$468.w,d0
	beq.s	.sync
	cmp.b	#$39,$fffffc02.w
	beq.s	Koniec
	rts
Koniec
	move.b	#7,$484.w
	move.b	#8,$fffffc02.w
	clr.l	(a7)
	trap	#1
	illegal

*************************************

Rez:
	CLR.L	-(A7)
	MOVE.W	#32,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	move.b	#18,$fffffc02.w
	move.b	#2,$ffff820a.w
	move.b	#0,$ffff8260.w
	move.l	#$70080,$ffff8200.w
	lea	$78000,a0
	moveq	#0,d0
	move.w	#1999,d7
.clrscr	dcb.w	$20c0,4
	dbf	d7,.clrscr
	moveq	#18,d7
	lea	$78000,a0
	move.w	#graphcs,d0
	move.w	#graphct,d1
.Loop
	move.w	d0,(a0)
	move.w	d1,320(a0)
	addq.l	#8,a0
	dbf	d7,.Loop
	rts
EndPrg	end
