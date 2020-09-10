	opt	x+
	bsr	res
loop	bsr.s	rysuj
	bsr.s	VBL
	bra.s	loop
VBL	move.w	#0,$ffff8240.w
	move.l	d0,-(a7)
	move.l	$466.w,d0
vbl	cmp.l	$466.w,d0
	beq.s	vbl
	cmp.b	#$39,$fffffc02.w
	bne.s	kpsdj
	move.w	#-1,$ffff8240.w
	move.w	#-0,$ffff825e.w
	clr.l	(a7)
	trap	#1
kpsdj	move.l	(a7)+,d0
	move.w	#39,$ffff8240.w
	rts

rysuj	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	counter(pc),d0
	lea	way(pc),a0
	lea	$78000,a1
	move.w	0(a0,d0.w),d1 *pobierz dla
	move.w	2(a0,d0.w),d2 *spritea
	move.w	-2(a0,d0.w),d3 *pobierz dla
	move.w	-4(a0,d0.w),d4 *maski
	cmp.w	#-1,d1
	bne.s	nie_kon
	move.w	way(pc),d1
	move.w	(way+2)(pc),d2
	clr.w	counter
nie_kon
	add.l	d3,a1
	lea	adresy2(pc),a0
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a0,d4.w),a0
	moveq	#28,d7
maskuj_to
	movem.l	(a0)+,d0/d3-d6
	and.l	d0,(a1)
	and.l	d3,8(a1)
	and.l	d4,16(a1)
	and.l	d5,24(a1)
	and.l	d6,32(a1)
	movem.l	(a0)+,d3-d6
	and.l	d3,40(a1)
	and.l	d4,48(a1)
	and.l	d5,56(a1)
	and.l	d6,64(a1)
	lea	160(a1),a1
	dbf	d7,maskuj_to
	lea	adresy1(pc),a0
	lea	$78000,a1
	add.l	d2,a1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a0,d1.w),a0
	moveq	#28,d7
naszkicuj_to
	movem.l	(a0)+,d0/d3-d6
	or.l	d0,(a1)
	or.l	d3,8(a1)
	or.l	d4,16(a1)
	or.l	d5,24(a1)
	or.l	d6,32(a1)
	movem.l	(a0)+,d3-d6
	or.l	d3,40(a1)
	or.l	d4,48(a1)
	or.l	d5,56(a1)
	or.l	d6,64(a1)
	lea	160(a1),a1
	dbf	d7,naszkicuj_to


	addq.w	#4,counter
	rts
res	
	lea	new(pc),a0
	move.w	#31*261,d7
	moveq	#0,d0
psgj	move.l	d0,(a0)+
	dbf	d7,psgj
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	#$78000,d0
	lea	$ffff8200.w,a0
	swap	d0
	move.b	d0,1(a0)
	swap	d0
	lsr.w	#8,d0
	move.b	d0,3(a0)
	move.b	#2,10(a0)
	move.b	#0,96(a0)
	lea	pal(pc),a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,64(a0)
czycz	lea	$78000,a0
	move.w	#1333,d7
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
clin	movem.l	d0-d5,(a0)
	lea	24(a0),a0
	dbf	d7,clin
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	lea	atari(pc),a0
	lea	new(pc),a1
	lea	adresy1(pc),a2
	move.l	a0,(a2)+
	move.l	a1,(a2)+
	moveq	#1,d4  ;przesuniecie
	moveq	#14,d7 ;ilosc przesuniec
item	moveq	#8,d5  ;dlugosc spritea
	moveq	#28,d6 ;wysokosc spritea
set
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	swap	d0
	swap	d1
	lsr.l	d4,d0
	lsr.l	d4,d1
	or.w	d0,4(a1)
	or.w	d1,6(a1)
	swap	d0
	swap	d1
	or.w	d0,(a1)
	or.w	d1,2(a1)
	addq.l	#4,a1
	dbf	d5,set
	moveq	#8,d5
	dbf	d6,set
	addq.l	#1,d4
	move.l	a1,(a2)+
	lea	atari(pc),a0
	dbf	d7,item
	lea	atari(pc),a0
	move.l	adresy2(pc),a1
	move.w	#16*29-1,d7
zaneguj
	movem.l	(a0)+,d0-d4
	not.l	d0
	not.l	d1
	not.l	d2
	not.l	d3
	not.l	d4
	movem.l	d0-d4,(a1)
	movem.l	(a0)+,d0-d3
	not.l	d0
	not.l	d1
	not.l	d2
	not.l	d3
	movem.l	d0-d3,20(a1)
	add.l	#36,a1
	dbf	d7,zaneguj
	lea	adresy2(pc),a0
	moveq	#15,d7
	move.l	(a0)+,d0
	move.l	#1044,d1
obl	add.l	d1,d0
	move.l	d0,(a0)+
	dbf	d7,obl
	lea	way(pc),a0
	lea	way2(pc),a1
	move.l	a0,d6
	move.l	a1,d7
	move.l	a0,a1
	sub.l	d6,d7
	divu	#4,d7
przelicz
	lea	$78000,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d5
	move.w	(a0)+,d1
	move.w	(a0)+,d0
u	mulu	#160,d0
powtorz
	cmp.w	#16,d1
	blt.s	wiec_dodaj
	sub.w	#16,d1
	add.w	#8,d5
	bra.s	powtorz
wiec_dodaj
	add.w	d5,d0
	move.w	#$8000,d3
	lsr.w	d1,d3
	or.w	d3,(a2,d0.w)
	move.w	d1,(a1)+
	move.w	d0,(a1)+
	dbf	d7,przelicz
	rts
counter	ds.l	2
way
	include	data\okrag.s
	;include	data\funkcja4.s
	;include	data\kokarda3.s
	;include	data\kokarda4.s
	;include	data\atariway.s
	;include	data\atariwax.s
way2	dc.l	-1
	ds.l	10

adresy1	ds.l	16
adresy2	ds.l	16
***************************************
* ATARI 2-BIT LOGO BY PETER (-QUANT-) *
***************************************
pal	dc.w	$0000,$0400,$0520,$0630,$0024,$0036,$0047,$0057
	dc.w	$0000,$0111,$0222,$0333,$0444,$0555,$0666,$0777
atari
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00EF00E9
	ds.l	1
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$004F004F
	ds.l	1
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$BE807F00,$38493849
	ds.l	1
	dc.l	$00000000,$00000000,$0008001C,$07FF07FF
	dc.l	$FC02FC07,$00030001,$FFE0FFC0,$38493849
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$003E003E,$07FF07FF
	dc.l	$FC0FFC0F,$80038003,$FFF0FFF0,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$003E007F,$07FF07FF
	dc.l	$FC0FFC1F,$8007C003,$C1F880F0,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$007F007F,$000E000E
	dc.l	$001F001F,$C003C007,$80780078,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$00F7007F,$800E000E
	dc.l	$003D001F,$E007C007,$003C0038,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$006B00F7,$000E800E
	dc.l	$001A003D,$C007E007,$003C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$00F700E3,$800E800E
	dc.l	$003D0038,$E007E007,$001C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$01E300E3,$C00E800E
	dc.l	$00780038,$F007E007,$001C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$00C101E3,$800EC00E
	dc.l	$00300078,$6007F007,$001C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$01E301C1,$C00EC00E
	dc.l	$00780070,$F0077007,$001C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$03C101C1,$E00EC00E
	dc.l	$00F00070,$78077007,$001C001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$018003C1,$C00EE00E
	dc.l	$006000F0,$30077807,$0038001C,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$03C10380,$E00EE00E
	dc.l	$00F000E0,$78073807,$003C0038,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$07800380,$F00EE00E
	dc.l	$01E000E0,$3C073807,$00700078,$38003800
	ds.l	1
	dc.l	$003B003B,$EE00EE00,$03000780,$600EF00E
	dc.l	$00C001E0,$18073C07,$01E000F0,$38003800
	ds.l	1
	dc.l	$0073003B,$E700EE00,$07800700,$F00E700E
	dc.l	$01E001C0,$3C071C07,$17E00FC0,$38003800
	ds.l	1
	dc.l	$00330073,$E600E700,$0F000700,$780E700E
	dc.l	$03C001C0,$1E071C07,$1E803F00,$38003800
	ds.l	1
	dc.l	$00730073,$E700E700,$07FF0FFF,$F00EF80E
	dc.l	$01FF03FF,$FC07FE07,$1C003C00,$38003800
	ds.l	1
	dc.l	$007300F3,$E700E780,$0FFF0FFF,$F80EF80E
	dc.l	$03FF03FF,$FE07FE07,$1E001E00,$38003800
	ds.l	1
	dc.l	$00E300F3,$E380E780,$1FFF0FFF,$FC0EF80E
	dc.l	$07FF03FF,$FF07FE07,$0F000F00,$38003800
	ds.l	1
	dc.l	$01E301E3,$E3C0E3C0,$0C001E00,$180E3C0E
	dc.l	$03000780,$06070F07,$07800780,$38003800
	ds.l	1
	dc.l	$0BC307E3,$E1E8E3F0,$1E001C00,$3C0E1C0E
	dc.l	$07800700,$0F070707,$03C003C0,$38003800
	ds.l	1
	dc.l	$7FC37FC3,$E1FFE1FF,$3C001C00,$1E0E1C0E
	dc.l	$0F000700,$07870707,$01E001E0,$38003800
	ds.l	1
	dc.l	$7F837F83,$E0FFE0FF,$18003C00,$0C0E1E0E
	dc.l	$06000F00,$03070787,$00F000F0,$38003800
	ds.l	1
	dc.l	$7E037F03,$E03FE07F,$3C003800,$1E0E0E0E
	dc.l	$0F000E00,$07870387,$00780078,$38003800
	ds.l	1
	dc.l	$74037803,$E017E00F,$38003800,$0E0E0E0E
	dc.l	$0E000E00,$03870387,$003C003C,$38003800
	ds.l	1
new	ds.l	4