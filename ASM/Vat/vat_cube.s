*************************************
* PIXies rotation baj VAT of kors!! *
*************************************
Dist	equ	-512
Size	equ	256
IlePix	equ	8
	opt	x+
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	#$fff,$ffff8240.w
	move.w	#$444,$ffff825e.w
	bsr	Rez
	clr.b	$484.w
Loop
	bsr	Vbl
	bsr	CLRSCR
	bsr	Key
	bsr	ClearPix
	bsr	Rotate
	bsr	DrawPIX

	lea	FromTo(pc),a0
	bsr	PrepPkt
	bsr	DrawLine
	lea	FromTo+4(pc),a0
	bsr	PrepPkt
	bsr	DrawLine
	lea	FromTo+8(pc),a0
	bsr	PrepPkt
	bsr	DrawLine
	lea	FromTo+12(pc),a0
	bsr	PrepPkt
	bsr	DrawLine

	bra.s	Loop


Vbl	move.w	#0,$ffff8240.w
	move.l	$466.w,d0
Sync	cmp.l	$466.w,d0
	beq.s	Sync
	*move.w	#5,$ffff8240.w
	cmp.b	#$39,$fffffc02.w
	bne.s	.rts
	move.b	#7,$484.w
	clr.l	-(a7)
	trap	#1
.rts	rts

Key	move.b	$fffffc02.w,d0
	lea	CAlfa(pc),a0
	lea	(dist+2)(pc),a1
	lea	(size+2)(pc),a2
	cmp.b	#1,d0
	bne.s	.no0
	clr.l	(a0)+
	clr.w	(a0)
	bra.s	.rts
.no0	cmp.b	#2,d0
	bne.s	.no1
	addq.w	#2,(a0)
	bra.s	.rts
.no1	cmp.b	#3,d0
	bne.s	.no2
	subq.w	#2,(a0)
	bpl.s	.rts
	clr.w	4(a0)
	bra.s	.rts
.no2	cmp.b	#4,d0
	bne.s	.no3
	addq.w	#2,2(a0)
	bra.s	.rts
.no3	cmp.b	#5,d0
	bne.s	.no4
	subq.w	#2,2(a0)
	bpl.s	.rts
	clr.w	4(a0)
	bra.s	.rts
.no4	cmp.b	#6,d0
	bne.s	.no5
	addq.w	#2,4(a0)
	bra.s	.rts
.no5	cmp.b	#7,d0
	bne.s	.no6
	subq.w	#2,4(a0)
	bpl.s	.no6
	clr.w	4(a0)
	bra.s	.rts
.no6	cmp.b	#8,d0
	bne.s	.no7
	addq.w	#4,(a1)
	bra.s	.rts
.no7	cmp.b	#9,d0
	bne.s	.no8
	subq.w	#4,(a1)
.no8
.rts	rts


*************************************
*Lajn Drajwing rout baj Vat of kors!*
*************************************


PrepPkt

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	cmp.w	d0,d2
	bgt.s	.nochg
	exg	d0,d2
	exg	d1,d3
.nochg	rts

CLRSCR	lea	$f8000,a0
	moveq	#0,d0
	lea	8000(a0),a0
	moveq	#99,d7
Fuxem
i	set	0
	rept	20
	move.w	d0,i(a0)
i	set	i+8
	endr
	lea	160(a0),a0
	dbf	d7,Fuxem
	rts

DrawLine
	lea	Pixie(pc),a0
	lea	$f8000,a1
	cmp.w	d0,d2
	beq	Pion_0
	cmp.w	d1,d3
	beq	Poziom_0
	blt.s	kat0_90
	bgt	kat90_180
	rts
kat0_90
	move.w	d2,d4
	sub.w	d0,d4	; D4=dx
	bpl.s	.dx
	neg.w	d4
	move.w	d3,d6
	mulu	#160,d6
	add.w	d6,a1
	exg.l	d0,d2
	bra.s	.dx2
.dx	move.w	d1,d6
	mulu	#160,d6
	add.w	d6,a1
.dx2	move.w	d0,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d2
	lsr.w	#1,d0
	and.w	#$f8,d0
	add.w	d0,a1	;add x-pos

	move.w	d3,d5
	sub.w	d1,d5	; D5=dy
	bpl.s	.dy
	neg.w	d5
.dy	move.w	d5,d0
	move.w	d4,d1
	sub.w	d4,d5	; dx-dy
	bpl.s	kat45_90

	move.w	d4,d7
	subq.w	#1,d7
.drw	or.w	d2,(a1)
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	sub.w	d0,d1
	bgt.s	.no_sub
	add.w	d4,d1
	lea	-160(a1),a1
.no_sub	dbf	d7,.drw
	rts

kat45_90
	move.w	d0,d7
	subq.w	#1,d7
	move.w	d0,d3
.drw	or.w	d2,(a1)
	lea	-160(a1),a1
	sub.w	d1,d0
	bgt.s	.no_add
	add.w	d3,d0
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	dbf	d7,.drw
	rts

kat90_180
	move.w	d2,d4
	sub.w	d0,d4	; D4=dx
	bpl.s	.dx
	neg.w	d4
	move.w	d3,d6
	mulu	#160,d6
	add.w	d6,a1
	exg.l	d0,d2
	bra.s	.dx2
.dx	move.w	d1,d6
	mulu	#160,d6
	add.w	d6,a1
.dx2	move.w	d0,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d2
	lsr.w	#1,d0
	and.w	#$f8,d0
	add.w	d0,a1	;add x-pos

	move.w	d3,d5
	sub.w	d1,d5	; D5=dy
	bpl.s	.dy
	neg.w	d5
.dy	move.w	d5,d0
	move.w	d4,d1
	sub.w	d4,d5	; dx-dy
uu	bpl.s	kat135_180
	neg.w	d5
	move.w	d4,d7
	subq.w	#1,d7
.drw	or.w	d2,(a1)
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	sub.w	d0,d1
	bgt.s	.no_sub
	add.w	d4,d1
	lea	160(a1),a1
.no_sub	dbf	d7,.drw
	rts
kat135_180
	move.w	d0,d7
	subq.w	#1,d7
	move.w	d0,d3
.drw	or.w	d2,(a1)
	lea	160(a1),a1
	sub.w	d1,d0
	bgt.s	.no_add
	add.w	d3,d0
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	dbf	d7,.drw
	rts

Poziom_0
	move.w	d2,d4
	sub.w	d0,d4
	bpl.s	Poziom_1
	exg	d0,d2
	neg.w	d4
Poziom_1
	mulu	#160,d1
	add.w	d1,a1
	lea	(a1),a2
	move.w	d0,d4
	move.w	d2,d6
	and.w	#$f,d4
	and.w	#$f,d6
	add.w	d4,d4
	add.w	d6,d6
	move.w	(a0,d4.w),d4
	move.w	(a0,d6.w),d6
	and.w	#$ff0,d0
	and.w	#$ff0,d2
	lsr.w	#1,d0
	lsr.w	#1,d2
	add.w	d0,a1
	add.w	d2,a2
	cmpa.l	a1,a2
	beq.s	OneWrd
	move.w	d4,d5
	subq.w	#1,d5
	subq.w	#1,d6
	or.w	d5,d4
	not.w	d6
	or.w	d4,(a1)+
	addq.l	#6,a1
.drw	cmpa.l	a1,a2
	beq.s	LastWrd
	or.w	#-1,(a1)+
	addq.l	#6,a1
	bra.s	.drw
LastWrd	or.w	d6,(a1)
	rts
OneWrd	move.w	d4,d5
	subq.w	#1,d5
	subq.w	#1,d6
	or.w	d5,d4
	move.w	d4,d5
	not.w	d6
	and.w	d6,d4
	beq.s	zero
	or.w	d4,(a1)
	rts
zero	or.w	d5,(a1)
	or.w	d6,(a2)
	rts

Pion_0	move.w	d3,d4
	sub.w	d1,d4
	bpl.s	Pion_1
	neg.w	d4
	exg	d1,d3
Pion_1	move.w	d4,d7
	subq.w	#1,d7
	move.w	d0,d4
	and.w	#$f,d4
	add.w	d4,d4
	move.w	(a0,d4.w),d4
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,a1
	mulu	#160,d1
	add.w	d1,a1
.drw	or.w	d4,(a1)
	lea	160(a1),a1
	dbf	d7,.drw
	rts

Pixie	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001
FromTo	ds.l	64


*************************************
*************************************
*************************************
*************************************


ClearPix
	moveq	#IlePix-1,d0
	moveq	#0,d1
	lea	ToErase(pc),a0
	tst.l	(a0)
	bmi	Las
Pixy	move.l	(a0)+,a1
	move.w	d1,(a1)
	dbf	d0,Pixy
Las	rts

DrawPIX	lea	Line(pc),a6
	lea	Scan(pc),a1
	lea	ToErase(pc),a5
	pea	FromTo(pc)	;tutaj
	move.w	#IlePix-1,d5
Tug	move.w	#IlePix-2,d6
	lea	Dull(pc),a0
	move.w	2(a0),d7
	lea	(a0),a2
	lea	6(a0),a0
Wad	cmp.w	2(a0),d7
	ble.s	Ster
	lea	(a0),a2
	move.w	2(a0),d7
Ster	lea	6(a0),a0
	dbf	d6,Wad
Draw	movem.w	(a2),d0-d2
	move.w	#$1234,2(a2)
dist	add.w	#Dist,d1
size	muls	#Size,d0
	muls	#Size,d2
	divs	d1,d0
	divs	d1,d2
	add.w	#160,d0
	move.w	#100,d1
	sub.w	d2,d1
DrawB
	move.l	(a7)+,a3 ;pix
	move.w	d0,(a3)+ ;for
	move.w	d1,(a3)+ ;draw
	pea	(a3)	 ;line

	lea	(a4),a3
	add.w	d1,d1
Set	nop
Pixla	lea	Pixel(pc),a0
To	move.w	d0,d6
Show	and.w	#15,d6
it	add.w	d6,d6
On	move.w	(a0,d6.w),d6
Screen	nop
	add.w	d1,d1
	move.l	(a6,d1.w),a2
	add.w	d0,d0
	add.w	d0,d0
	add.w	(a1,d0.w),a2
	move.l	a2,(a5)+
	add.w	2(a1,d0.w),a3
	or.w	d6,(a2)	;Draw Pix!
	dbf	d5,Tug
	move.l	(a7)+,a3
	rts

Rotate	lea	Point(pc),a5
	lea	Dull(pc),a6
	lea	sinus(pc),a0
	lea	180(a0),a1
	moveq	#IlePix-1,d7
	movem.w	Alfa(pc),d0-d2
	move.w	d0,s0+2
	move.w	d0,c0+2
	move.w	d1,s1+2
	move.w	d1,c1+2
	move.w	d2,s2+2
	move.w	d2,c2+2
Nrot	movem.w	(a5)+,d0-d2
	move.w	d1,d3
	move.w	d2,d4
s0	move.w	0(a0),d5
c0	move.w	0(a1),d6
	muls	d6,d1	cos*y
	muls	d5,d4	sin*z
	muls	d6,d2	cos*z
	muls	d5,d3	sin*y
	sub.w	d4,d1
	add.w	d3,d2
	asr.w	#7,d1
	asr.w	#7,d2
	move.w	d0,d3
	move.w	d2,d4
s1	move.w	0(a0),d5
c1	move.w	0(a1),d6
	muls	d6,d0	
	muls	d5,d4	
	muls	d6,d2	
	muls	d5,d3	
	sub.w	d4,d0
	add.w	d3,d2
	asr.w	#7,d0
	asr.w	#7,d2
	move.w	d0,d3
	move.w	d1,d4
s2	move.w	0(a0),d5
c2	move.w	0(a1),d6
	muls	d6,d0	
	muls	d5,d4	
	muls	d6,d1	
	muls	d5,d3	
	sub.w	d4,d0
	add.w	d3,d1
	asr.w	#7,d0
	asr.w	#7,d1
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	dbf	d7,Nrot
AddAng	lea	Alfa(pc),a0
	lea	CAlfa(pc),a1
	move.w	#2,d1
OtAngle	move.w	(a0),d0
	add.w	(a1)+,d0
	bmi.s	LowAngl
	cmp.w	#720,d0
	bge.s	HighAng
OkAng	move.w	d0,(a0)+
	dbf	d1,OtAngle
	rts
LowAngl	add.w	#720,d0
	bra.s	OkAng
HighAng	sub.w	#720,d0
	bra.s	OkAng

Rez	lea	$f8000,a0
	moveq	#0,d0
	move.w	#999,d7
.clr	dcb.w	$20c0,8
	dbf	d7,.clr
	lea	Line(pc),a0
	lea	$f8000,a1
	move.w	#199,d0
qart	move.l	a1,(a0)+
	lea	160(a1),a1
	dbf	d0,qart
	lea	Scan(pc),a0
	moveq	#0,d0
	moveq	#19,d3
qaz	moveq	#0,d1
	moveq	#15,d2
qwea	move.w	d0,(a0)+
	move.w	d1,(a0)+
	add.w	#384,d1
	dbf	d2,qwea
	addq.w	#8,d0
	dbf	d3,qaz
	rts
Scan	ds.l	320
Line	ds.l	200
ToErase	dc.l	-1
	ds.l	IlePix-1
Point	dc.w	50,50,50
	dc.w	-50,50,50
	dc.w	-50,-50,50
	dc.w	50,-50,50
	dc.w	50,50,-50
	dc.w	-50,50,-50
	dc.w	-50,-50,-50
	dc.w	50,-50,-50
Dull	ds.w	3*IlePix
********* rotate parameters *********
CAlfa	dc.w	4
CBeta	dc.w	2
CGamma	dc.w	6
************** Angle ****************
Alfa	dc.w	0
Beta	dc.w	0
Gamma	dc.w	0
Pixel	dc.w	$8000,$4000,$2000,$1000
	dc.w	$800,$400,$200,$100
	dc.w	$80,$40,$20,$10,8,4,2,1
sinus:	dc.w 0,2,4,6,8,11,13,15,17,20
	dc.w 22,24,26,28,30,33,35,37,39,41
	dc.w 43,45,47,50,52,54,56,58,60,62
	dc.w 64,65,67,69,71,73,75,77,78,80
	dc.w 82,83,85,87,88,90,92,93,95,96
	dc.w 98,99,100,102,103,104,106,107,108,109
	dc.w 110,111,113,114,115,116,116,117,118,119
	dc.w 120,121,121,122,123,123,124,124,125,125
	dc.w 126,126,126,127,127,127,127,127,127,127
cos:	dc.w 128,127,127,127,127,127,127,127,126,126
	dc.w 126,125,125,124,124,123,123,122,121,121
	dc.w 120,119,118,117,116,116,115,114,113,111
	dc.w 110,109,108,107,106,104,103,102,100,99
	dc.w 98,96,95,93,92,90,88,87,85,83
	dc.w 82,80,78,77,75,73,71,69,67,65
	dc.w 64,62,60,58,56,54,52,50,47,45
	dc.w 43,41,39,37,35,33,30,28,26,24
	dc.w 22,20,17,15,13,11,8,6,4,2
	dc.w 0,-3,-5,-7,-9,-12,-14,-16,-18,-21
	dc.w -23,-25,-27,-29,-31,-34,-36,-38,-40,-42
	dc.w -44,-46,-48,-51,-53,-55,-57,-59,-61,-63
	dc.w -64,-66,-68,-70,-72,-74,-76,-78,-79,-81
	dc.w -83,-84,-86,-88,-89,-91,-93,-94,-96,-97
	dc.w -99,-100,-101,-103,-104,-105,-107,-108,-109,-110
	dc.w -111,-112,-114,-115,-116,-117,-117,-118,-119,-120
	dc.w -121,-122,-122,-123,-124,-124,-125,-125,-126,-126
	dc.w -127,-127,-127,-128,-128,-128,-128,-128,-128,-128
	dc.w -128,-128,-128,-128,-128,-128,-128,-128,-127,-127
	dc.w -127,-126,-126,-125,-125,-124,-124,-123,-122,-122
	dc.w -121,-120,-119,-118,-117,-117,-116,-115,-114,-112
	dc.w -111,-110,-109,-108,-107,-105,-104,-103,-101,-100
	dc.w -99,-97,-96,-94,-93,-91,-89,-88,-86,-84
	dc.w -83,-81,-79,-78,-76,-74,-72,-70,-68,-66
	dc.w -64,-63,-61,-59,-57,-55,-53,-51,-48,-46
	dc.w -44,-42,-40,-38,-36,-34,-31,-29,-27,-25
	dc.w -23,-21,-18,-16,-14,-12,-9,-7,-5,-3
	dc.w 0,2,4,6,8,11,13,15,17,20
	dc.w 22,24,26,28,30,33,35,37,39,41
	dc.w 43,45,47,50,52,54,56,58,60,62
	dc.w 64,65,67,69,71,73,75,77,78,80
	dc.w 82,83,85,87,88,90,92,93,95,96
	dc.w 98,99,100,102,103,104,106,107,108,109
	dc.w 110,111,113,114,115,116,116,117,118,119
	dc.w 120,121,121,122,123,123,124,124,125,125
	dc.w 126,126,126,127,127,127,127,127,127,127
