	output	a:\uta\omega.prg
	opt	o+,w-

	lea	Stack1(pc),a7
	pea	s(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	clr.w	-(a7)
	trap	#1
	
s	
	lea	s(pc),a6
	move.l	a7,Old_a7-s(a6)
	lea	Stack2(pc),a7
	move.l	$ffff8240.w,OldPal-s(a6)
	move.l	#$00030FFF,$ffff8240.w
	move.w	#2,-(a7)
	trap	#14
	move.l	d0,Scr-s(a6)
	move.w	#4,-(a7)
	trap	#14
	move.w	d0,Rez-s(a6)
	addq.l	#4,a7
	
	cmp.w	#0,d0
	beq.s	Low
	cmp.w	#2,d0
	beq	High
	cmp.w	#4,d0
	beq.s	TTmed
	bra	Sluta

PicIsOut
	moveq	#75,d7
Waita	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	cmp.b	#$39,$fffffc02.w
	beq.s	Sluta
	dbf	d7,Waita
Sluta	
	move.l	OldPal(pc),$ffff8240.w
	move.l	Old_A7(pc),a7
	rts



Low	lea	Bild(pc),a0
	move.l	Scr(pc),a1
	lea	5*8+70*160(a1),a1
	moveq	#$28,d0
Hight:	move.w	(a0)+,$00(a1)
	move.w	(a0)+,$08(a1)
	move.w	(a0)+,$10(a1)
	move.w	(a0)+,$18(a1)
	move.w	(a0)+,$20(a1)
	move.w	(a0)+,$28(a1)
	move.w	(a0)+,$30(a1)
	move.w	(a0)+,$38(a1)
	move.w	(a0)+,$40(a1)
	lea	160(a1),a1
	dbf	d0,Hight
	bra	PicIsOut

TTmed	lea	Bild(pc),a0
	move.l	Scr(pc),a1
	add.l	#16*8+200*320,a1	
	moveq	#$28,d0
Hight2:	move.w	(a0)+,$00(a1)
	move.w	(a0)+,$08(a1)
	move.w	(a0)+,$10(a1)
	move.w	(a0)+,$18(a1)
	move.w	(a0)+,$20(a1)
	move.w	(a0)+,$28(a1)
	move.w	(a0)+,$30(a1)
	move.w	(a0)+,$38(a1)
	move.w	(a0)+,$40(a1)
	lea	320(a1),a1
	dbf	d0,Hight2
	bra	PicIsOut

High	lea	Bild(pc),a0
	move.l	Scr(pc),a1
	lea	16*2+80*150(a1),a1	
	moveq	#$28,d0
Hight1:	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	lea	80-2*9(a1),a1
	dbf	d0,Hight1
	bra	PicIsOut


Rez	ds.w	1
Scr	ds.l	1
OldPal	ds.l	1
old_a7	ds.l	1


	
Bild
*
*  NEOchrome V2.27 cut buffer contents (left justified):
*  by Chaos, Inc. of the Delta Force (member of The Union)
*
*    pixels/scanline    = $008F (bytes/scanline: $0012)
*  # scanlines (height) = $0029
*
*  Monochrome mask (1 plane; background=0/non-background=1)
*
*
*
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0C00
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0001,$E000,$8000,$1000,$0380,$000E
		dc.w	$0000,$1C00,$000A,$001F,$FE00,$8000,$1000,$0200
		dc.w	$0008,$0000,$1000,$000E,$00FF,$FF80,$8000,$1000
		dc.w	$0300,$000E,$0000,$1800,$000E,$03FF,$FFE0,$8000
		dc.w	$1000,$0200,$0002,$0000,$1000,$000A,$07FF,$FFF0
		dc.w	$E000,$1000,$0380,$000E,$0000,$1C00,$000A,$0FFF
		dc.w	$9FF8,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$1FFE,$0FFC,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$1FFC,$0FFC,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0018,$3FFC,$07FE,$0FE0,$3E07,$E000,$1F00
		dc.w	$03F0,$7001,$E0FC,$3FF8,$07FE,$7FF1,$FF1F,$F000
		dc.w	$FFE0,$1FFE,$F80F,$FFFC,$7FF8,$07FE,$FFF7,$FF3F
		dc.w	$F003,$FFF0,$7FFF,$FC3F,$FFF8,$7FF8,$0FFF,$FFFF
		dc.w	$FFFF,$F80F,$FFF0,$FFFF,$FC7F,$FFF8,$7FF0,$0FFF
		dc.w	$FFFF,$FFFF,$F81F,$FFF1,$FF3F,$F8FF,$9FF0,$FFF0
		dc.w	$0FFF,$3FFF,$FFFF,$F83F,$CFF3,$FE3F,$F1FF,$1FF0
		dc.w	$FFF0,$0FFF,$3FFF,$FFFF,$F87F,$8FE3,$FE3F,$E3FF
		dc.w	$1FF0,$FFF0,$0FFE,$3FE3,$FF1F,$F8FF,$1FE7,$FC7F
		dc.w	$C3FE,$1FF0,$FFE0,$0FFE,$3FE1,$FF0F,$F8FF,$1FC7
		dc.w	$FC7F,$C7FE,$3FF0,$FFE0,$1FFE,$3FE1,$FF0F,$F9FF
		dc.w	$3F87,$FC7F,$87FC,$3FE0,$FFE0,$1FFC,$7FC1,$FE0F
		dc.w	$F1FF,$FF07,$F8FF,$8FFC,$3FE0,$FFE0,$1FFC,$7FC3
		dc.w	$FE0F,$F1FF,$FC07,$F8FF,$0FFC,$3FE0,$7FE0,$1FFC
		dc.w	$7FC3,$FE0F,$F3FF,$E003,$F9FF,$0FF8,$7FE0,$7FE0
		dc.w	$3FF8,$7FC3,$FE1F,$F3FF,$0003,$FFFE,$1FF8,$7FEE
		dc.w	$7FF0,$3FF8,$7F83,$FC1F,$FBFF,$00E1,$FFFC,$1FFC
		dc.w	$FFFE,$3FF0,$7FF0,$7F83,$FC1F,$FFFF,$83E1,$FFF8
		dc.w	$1FFF,$FFFE,$3FF8,$FFE0,$7F83,$FC1F,$FFFF,$FFC3
		dc.w	$FFC0,$1FFF,$FFFC,$1FFF,$FFC0,$FF87,$FC1F,$FDFF
		dc.w	$FFC7,$E000,$1FFF,$FFF8,$0FFF,$FF80,$FF87,$FC3F
		dc.w	$F9FF,$FF8F,$E000,$0FFF,$FFF0,$07FF,$FE00,$FF07
		dc.w	$F83F,$E1FF,$FF0F,$FFFE,$0FFE,$7FE0,$01FF,$F000
		dc.w	$FF07,$F83F,$80FF,$FC1F,$FFFF,$87F8,$7F80,$003E
		dc.w	$0000,$0000,$001C,$003F,$E01F,$FFFF,$C1E0,$3E00
		dc.w	$0000,$0000,$0000,$0000,$0000,$001F,$FFFF,$C000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$000F,$FFFF
		dc.w	$E000,$0000,$0000,$0000,$0000,$0000,$0000,$0007
		dc.w	$FFFF,$C000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0001,$FFFF,$C000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$1FFF,$8000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$00FF,$8000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$01FF,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$03FE,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$01F8,$0000
		dc.w	$0000

	BSS
	ds.b	128
Stack1	ds.b	128
Stack2