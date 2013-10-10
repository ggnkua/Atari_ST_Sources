nbvbl:	equ	5

temps:	equ	5

	opt	o+,w-


vsync:	macro
	move.l	d7,-(sp)
	move.l	$466.w,d7
.\@l1:
	cmp.l	$466.w,d7
	beq.s	.\@l1
	move.l	(sp)+,d7
	endm

debut:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$70.w,savvbl

	MOVE.L	$44E,oldecr

	move.w	#0,-(sp)
	move.L	#-1,-(sp)
	move.L	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	jsr	calctexte

	LEA	lame(PC),A0
	LEA	MUSIC(PC),A1
	MOVE.L	A1,12(A0)
	MOVE.W	#0,16(A0)

	MOVE.W	#$2700,SR
	BSR	lame

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w

	move.w	#$2300,sr
	move.l	#vblst,$70.w

	lea	img+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy82:
	move.l	(a0)+,(a1)+
	dbf	d0,copy82

	lea	img+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w56:
	vsync
	dbf	d0,w56

	lea	img+2,a6
	jsr	colorout

	jsr	phrase

	lea	img2+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy28:
	move.l	(a0)+,(a1)+
	dbf	d0,copy28


	lea	img2+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w24:
	vsync
	dbf	d0,w24

	lea	img2+2,a6
	jsr	colorout

	jsr	phrase

	lea	img+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy3:
	move.l	(a0)+,(a1)+
	dbf	d0,copy3

	lea	img+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w3:
	vsync
	dbf	d0,w3

	lea	img+2,a6
	jsr	colorout

	jsr	phrase

	lea	img2+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy22:
	move.l	(a0)+,(a1)+
	dbf	d0,copy22


	lea	img2+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w22:
	vsync
	dbf	d0,w22

	lea	img2+2,a6
	jsr	colorout

	jsr	phrase

error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:


	move.l	#vbl,$70.w

main:
	lea	img+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy:
	move.l	(a0)+,(a1)+
	dbf	d0,copy

	lea	img+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w:
	vsync
	dbf	d0,w

	lea	img+2,a6
	jsr	colorout

	jsr	phrase

	lea	img2+34,a0
	move.l	log,a1
	move.w	#7999,d0
copy2:
	move.l	(a0)+,(a1)+
	dbf	d0,copy2


	lea	img2+2,a6
	jsr	colorin


	move.w	#50*temps,d0
w2:
	vsync
	dbf	d0,w2

	lea	img2+2,a6
	jsr	colorout

	jsr	phrase

	bra	main

sortie:
	move.l	savvbl,$70.w

error_clavier2:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier2
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier2
.vidbuff:


	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w

	MOVE.W	#$2700,SR
	bsr	lame+4
	move.w	#$2300,sr

	move.w	#4000,d0
w39:	dbf	d0,w39

	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w


	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.w	-(sp)
	trap	#1

vbl:
	BSR	lame+8
	cmp.b	#$39,$fffffc02.w
	bne.s	past
	move.l	#sortie,2(sp)
past:
	addq.l	#1,$466.w
	rte

vblst:
	BSR	lame+8
	addq.l	#1,$466.w
	rte

lame:	INCLUDE	ST_MAG.S

**********      fade in / fade out     **************

colorin	move.w	#0,D7

BO_IN	rept	nbvbl
	vsync
	endr
	move.w	D7,D0
	move.l	A6,A0
	bsr	FADE
	addq.w	#1,D7
	cmp.w	#8,D0
	ble	BO_IN

	rts

colorout	move.w	#8,D7

BO_OUT	rept	nbvbl
	vsync
	endr
	move.w	D7,D0
	move.l	A6,A0
	bsr	FADE
	subq.w	#1,D7
	tst.w	D0
	bge	BO_OUT

	rts

FADE	lea	$ffFF8240.w,A1
	move.w	#$F,D1

LOOPF	move.w	(A0)+,D2		* on prend une couleur
	move.w	D2,D3
	lsr.w	#8,D3
	and.w	#$F,D3
	move.w	D2,D4
	lsr.w	#4,D4
	and.w	#$F,D4
	move.w	D2,D5
	and.w	#$F,D5
	muls	D0,D3
	divs	#8,D3
	lsl.w	#8,D3
	muls	D0,D4
	divs	#8,D4
	lsl.w	#4,D4
	muls	D0,D5
	divs	#8,D5
	move.w	D3,D2
	add.w	D4,D2
	add.w	D5,D2
	move.w	D2,(A1)+
	dbf	D1,LOOPF
	rts


phrase:

	move.l	log,a0
	moveq	#0,d0
	move.w	#7999,d1
.eff:
	move.l	d0,(a0)+
	dbf	d1,.eff

	move.l	pttex,a0
	lea	affich,a1
.loop1:
	move.w	(a0)+,d0
	cmp.w	#-2,d0
	beq.s	.fini
	move.w	d0,(a1)+
	bra.s	.loop1

.fini:
	move.w	d0,(a1)+
	cmp.l	ftexte,a0
	blt.s	.ok1
	lea	texte,a0
.ok1:
	move.l	a0,pttex

	jsr	puttexte

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#4*50,d0
.t:
	vsync
	dbf	d0,.t

	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w

	rts

puttexte:
	move.l	log,a0
	lea	160*96(a0),a0
	lea	affich,a1
.loop1:
	move.w	(a1)+,d0
	cmp.w	#-2,d0
	beq	.fin

	lea	font,a2
	adda.w	d0,a2

st	set	0
	rept	8
	move.b	(a2)+,st(a0)
	move.b	(a2)+,st+2(a0)
	move.b	(a2)+,st+4(a0)
	move.b	(a2)+,st+6(a0)
st	set	st+160
	endr

	move.w	(a1)+,d0
	cmp.w	#-2,d0
	beq	.fin

	lea	font,a2
	adda.w	d0,a2

st	set	0
	rept	8
	move.b	(a2)+,st+1(a0)
	move.b	(a2)+,st+2+1(a0)
	move.b	(a2)+,st+4+1(a0)
	move.b	(a2)+,st+6+1(a0)
st	set	st+160
	endr

	addq.l	#8,a0
	bra	.loop1

.fin:
	rts


calctexte:
	lea	texini,a0
	lea	texte,a1
loopt:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq	fint

	cmp.b	#-2,d0
	bne.s	space
	move.w	#-2,(a1)+
	bra	contt
space:	

	cmp.b	#32,d0
	bne.s	excla
	move.w	#32*26,(a1)+
	bra	contt
excla:
	cmp.b	#33,d0
	bne.s	inter
	move.w	#32*27,(a1)+
	bra	contt
inter:
	cmp.b	#63,d0
	bne.s	point
	move.w	#32*28,(a1)+
	bra	contt
point:
	cmp.b	#46,d0
	bne.s	vir
	move.w	#32*29,(a1)+
	bra	contt
vir:
	cmp.b	#44,d0
	bne.s	pvir
	move.w	#32*30,(a1)+
	bra	contt
pvir:
	cmp.b	#59,d0
	bne.s	pg
	move.w	#32*31,(a1)+
	bra	contt
pg:
	cmp.b	#40,d0
	bne.s	pd
	move.w	#32*32,(a1)+
	bra	contt
pd:
	cmp.b	#41,d0
	bne.s	lettre
	move.w	#32*33,(a1)+
	bra	contt
	
lettre:
	cmp.b	#65,d0
	blt.s	contt
	cmp.b	#90,d0
	bgt.s	contt
	sub.w	#65,d0
	lsl.w	#5,d0
	move.w	d0,(a1)+

contt:
	bra	loopt

fint:
	move.l	a1,ftexte
	rts

	

	section	data

pal:	incbin	"a:\xerox\pal.pal"
	even

font:	incbin	"a:\xerox\font.bin"
	even

pttex:	dc.l	texte

MUSIC	INCBIN	a:\xerox\*.mod
	even

img:	incbin	"a:\xerox\ran*.pi1"
	even

img2:	incbin	"a:\xerox\sorcier.pi1"
	even

texini:
	dc.b	"   SOUNDTRACK MUSIC BY SCOOPEX (AMIGA)",-2
	dc.b	"    SORCERER BY MEGADETH (PENDRAGONS)",-2
	dc.b	"RANK XEROX BY THE SERGEANT (BUSHWACKERS)",-2
	dc.b	"   CODE AND FONT BY TERENCE (PENDRAGONS)",-2
	dc.b	"  SHTROUMPF PARTY SUPPORTED BY TERENCE",-2
	dc.b	"  WERE HERE  THE SERGEANT AND MEGADETH",-2
	DC.B	"WAS NOT HERE MECHANOID (PHONE IS ENOUGH)",-2
	DC.B	"  PENWACKERS IS THE MUST FOR YOU !!! ",-2
	DC.B	"BYE ! RENDEZ VOUS IN OUR NEXT PRODUCT...",-2
	DC.B	"SPECIAL HI TO CHIPYNOU, EDDIE, CERISE !!",-2
 	dc.b	-1
	even
	
	
	section	bss

ftexte:	ds.l	1
texte:	ds.b	1000

affich:	ds.b	250

noir:	ds.w	16

log:	ds.l	1
oldecr:	ds.l	1
savcol:	ds.w	16
savvbl:	ds.l	1

ecrans:	ds.b	256+32000
	end