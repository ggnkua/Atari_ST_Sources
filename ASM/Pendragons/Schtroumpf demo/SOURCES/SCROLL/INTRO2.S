
*CONTACT : LAURENT DERVAL (THE SERGEANT)
*          68 RUE KELLERMANN
*          28200 CHATEAUDUN
*          FRANCE
          
*          OR

*          FOR CODING...
          
*          ERIC DEZERT (TERENCE / PENDRAGONS)
*          1 RUE LE MOYNE DE BIENVILLE
*          45100 ORLEANS
*          FRANCE


nbli:	equ	8		* hauteur du scrolling

hauteur:	equ	1		* hauteur du scrolling

posimg:	equ	10		* position de l'image

vsync:	macro
	move.l	$466.w,d0
.\@l1:
	cmp.l	$466.w,d0
	beq.s	.\@l1
	endm

	move.w	sr,d0
	btst	#13,d0
	bne.s	yeah

	clr.	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

yeah:
	LEA	DBSS,A0
	lea	FBSS,a1
.loop1:
	move.b	#0,(a0)+
	cmp.l	a1,a0
	bne.s	.loop1

	move.l	$44e,oldecr

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w


	move.l	log,a0
	moveq	#0,d0
	move.w	#8000-1,d1
loopcls:
	move.l	d0,(a0)+
	dbf	d1,loopcls

	vsync
	move.b	#0,$ffff8260.w
	vsync

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	image+34,a0
	move.l	log,a1
	lea	posimg*160(a1),a1
	move.w	#7999,d0
looping:
	move.l	(a0)+,(a1)+
	dbf	d0,looping

	lea	image2+34,a0
	move.w	#((43*160)/4)-1,d0
looping2:
	move.l	(a0)+,(a1)+
	dbf	d0,looping2

	moveq	#1,d0
	jsr	zik

	bsr	calctexte

	bsr	initmfp

	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

main:
	vsync
	cmp.b	#$39,$fffffc02.w
	bne.s	main

	bsr	finmfp

	moveq	#0,d0
	jsr	zik
	jsr	zik+6


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
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w

	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	vsync


	clr.w	-(sp)
	trap	#1

hbl:	rte

scroll:
	move.l	log,a0
	lea	hauteur*160(a0),a0
	move.w	#nbli-1,d7

.loop1:
	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+2(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+4(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+6(a0)
st	set	st-8
	endr

	lea	160(a0),a0
	dbf	d7,.loop1

	lea	-8*160(a0),a0

	move.w	posx,d6
	subq.w	#1,d6
	bge.s	.ok2

	move.l	pttex,a1
	move.w	(a1)+,d0
	cmp.l	ftexte,a1
	blt.s	.ok1
	lea	texte,a1
.ok1:
	move.w	d0,offl
	move.l	a1,pttex
	moveq	#7,d6

.ok2:	
	move.w	d6,posx

	move.w	offl,d0
	lea	font,a2
	adda.w	d0,a2

	moveq	#0,d5
	bset	d6,d5

	

st	set	0
	rept	nbli
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+2(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+4(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+6(a0)
st	set	st+160
	endr
	
	rts

calctexte:
	lea	tex_init,a0
	lea	texte,a1
loopt:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq	fint

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



initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move.w	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w 	    Arret Timer A (Reg control)
	clr.b	$fffffa1b.w 	    Arret Timer B (Reg control)

	move.b	#%00000001,$fffffa07.w  On lance le timer B seul
	move.b	#%00000001,$fffffa13.w  Pareil avec le masque
	
	move.b	#%00000000,$fffffa09.w  Pas de Timer C et D
	move.b	#%00000000,$fffffa15.w
	
	
	
	rte
	
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	rte
	

VBL22:
	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	
	lea	$ffff820a.w,a0	Frequence	
	lea	$ffff8260.w,a1	Resolution
	lea	$ffff8209.w,a2
	dcb.w	79,$4e71
	
*~~~~~	Border haut     ~~~~~*
	move.b	#0,(a0)		60 Hz
	dcb.w	16,$4e71
	move.b	#2,(a0)		50 Hz

	move.l	#raster1,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#posimg-1,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w

	movem.l	(sp)+,d0-a6
	rte
	
vbl:
	move.l	#VBL22,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#98,$fffffa21.w	|
	move.b	#4,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	movem.l	d0-a6,-(sp)
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	zik+6
	move.w	#4000,d0
w:	dbf	d0,w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	movem.l	(sp)+,d0-a6
	addq.l	#1,$466.w
	rte

raster1:
	movem.l	a0-a1,-(sp)
	lea	image+2,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	movem.l	(sp)+,a0-a1
	move.l	#bas,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#195+24,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte

bas:
	move.b	#0,$fffffa1b.w
	dcb.w	95+2+4,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	14,$4e71
	move.b	#2,$ffff820a.w
	move.b	#0,$ffff820a.w
	dcb.w	14,$4e71
	move.b	#2,$ffff820a.w
	rte
	
	section	data

pal:	incbin	"a:\scroll\pal.pal"
	even

log:	dc.l	$f8000+2

tex_init:
	dc.b	"                           "
	dc.b	"YO BOYS ! AFTER THE HARD LABOUR DAY OF THE TRANSBEAUCE II WHERE OVER TWO HUNDREDS AND FIFTY PEOPLE WENT WE ARE"
	DC.B	" NOW AT THE SMALLEST CODING PARTY EVER MADE .... THE SHTROUMF PARTY , WE ARE THREE COOL GUYS HERE WHO ATTEND THIS PARTY..."
	DC.B	" WE ARE FIRST OF ALL TERENCE (I AM TYPING THIS AMAZING NOW ?) MEGADETH AND THE SERGEANT . WE MET DIS WEEK END TO FINISH THE "
	DC.B	"TRANSBEAUCE DEMO TWO BUT WE MADE THIS LITTLE DEMOS INSTEAD. THAT IS FAR MUCH MORE FUNNY ! IN FACT THE SERGEANT WILL DECIDE TO RELEASE"
	DC.B	" THE TRANSBEAUCE DEMO IN DECEMBER , EARLIER TIME. MEGADETH AND THE SERGEANT ARE NOW TYPING A STUPID SCROLLTEXT ON THE LAMEST SCREEN EVER CODED"
	DC.B	" ON OUR GOOD OLD ST. THIS DEMO WAS MADE BECAUSE WE FIRST DESIGNED A SINGLE DEMO AND THEN DECIDED TO MADE A COMPLETE DEMO AND TO SPREAD THE SOURCES"
	DC.B	" WITH IT. WE ARE COOL GUYS ARENT WE ? (AND WE FUCK YOU ALL !!) . SO SPREAD THIS AHEAD AND TO CONTACT US WRITE TO LAURENT DERVAL SIXTY EIGHT BOULEVARD "
	DC.B	"KELLERMANN TWENTY EIGHT TWO HUNDREDS CHATEAUDUN FRANCE. (NO ILLEGAL SWAPPING JUST DEMO FREAK ACCEPTED) THAT ADRESS IS ESPECIALLY SENT TO POMPEY PIRATES"
	DC.B	" AS THEY USE THE SERGEANT S FONTS AND AS HE WOULD BE VERY PLEASE TO CONTACT THEIR FUCKING GOOD GRAPHIC MAN ! "
	DC.B	"A LITTLE WORD , TO SAY TO THE PEOPLE WHO PHONED ME FEW MINUTES AGO TO TRY AGAIN AS I ONLY GOT SHIT SOUND ON THE LINE... HELLOS TO ALL PRETTY GIRLS ALL AROUND"
	DC.B	" THE WORLD ESPECIALLY LAURENT S GIRLFRIENDS ON RTEL !!! THERE ARE TOO MANY NAMES TO WRITE THEM ALL HERE !! KISS FROM TERENCE TO ALL THEM !! "
	DC.B	" GOOD BYE BOYS LET S CUT... THIS SCROLLINE DOES NOT WRAP ...."
	DC.B	"                                                           "
	dc.b	"                           "
	dc.b	-1
	

font:	incbin	"a:\scroll\font.bin"
	even

pttex:	dc.l	texte

posx:	dc.w	7

offl:	dc.w	32*26

image:
	incbin	"a:\scroll\pen*.pi1"		* nom du fichier .pi1
	even
image2:
	incbin	"a:\scroll\pascal.pi1"	* nom du fichier .pi1 num 2
	even

zik:
	incbin	"a:\scroll\decade1.mus"	* musique (count zero !!!)
	even

	section	bss

DBSS:
oldecr:	ds.l	1
savcol:	ds.w	16

oldmfp	ds.b	24
oldvec	ds.l	24

texte:	ds.b	4000

ftexte:	ds.l	1

ecrans:	ds.b	256
	ds.b	44000
FBSS:
	end

	


