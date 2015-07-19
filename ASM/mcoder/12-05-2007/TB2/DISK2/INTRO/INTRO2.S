**************************************************
* Intro du second disk de la Transbeauce demo II *
*          All coding Le sergent 1991 	     *
*  GFX by one of the best gfx man : Terence      *
*				     *
**************************************************

 	opt	o+,ow2-

vsync:	macro
	move.l	$466.w,d6
.\@1:	cmp.l	$466.w,d6
	beq.s	.\@1
	endm

vsync2:	macro
	move.l	d6,-(sp)
	move.l	$466.w,d6
.\@1:	cmp.l	$466.w,d6
	beq.s	.\@1
	move.l	(sp)+,d6
	endm

ech:	macro
	move.l	\1,d0
	move.l	\2,\1
	move.l	d0,\2
	endm

aff_spr:	macro

	cmp.l	#crb_x+21*4,(a0)
	bne.s	affff\@
	move.l	#crb_x+480*4+21*4,(a0)
affff\@:	subq.l	#4,(a0)
	cmp.l	#crb_y+19*4,4(a0)
	bne.s	affff1\@
	move.l	#crb_y+180*4+19*4,4(a0)
affff1\@:	subq.l	#4,4(a0)
	move.l	a2,a1
	move.l	(a0)+,a4
	adda.w	(a4)+,a1
	moveq	#0,d0
	move.w	(a4)+,d0	* decalage
	move.l	(a0)+,a4
	adda.l	(a4),a1	* adresse sur ecran
	move.l	a1,\1
	lea	\2,a3
	move.l	(a3,d0.w),a3
	jsr	(a3)
	endm

eff:	macro
	move.l	\1,a0
st	set	0
	
	rept	48
	movem.w	d0-d2,st(a0)
	movem.w	d0-d2,st+8(a0)
	movem.w	d0-d2,st+8*2(a0)
	movem.w	d0-d2,st+8*3(a0)
st	set	st+160
	endr
	endm

*
*
;	bra	debut
;	dc.b	"INTRO FOR THE SECOND DISK OF THE TRANSBEAUCE DEMO"
;	dc.b	" MAIN WORK WAS DONE BY MCODER SO PLEASE NEVER FORGET"
;	dc.b	" HIM EVEN WHEN HE WILL BE CODING ON SUPER FAMICOM !!!!"
;	even
debut:
	ifeq	1
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	endc

;	lea	dbss,a0
;	lea	fbss,a1
;	moveq	#0,d1
;loopboy:
;	move.b	d1,(a0)+
;	cmp.l	a1,a0
;	blt.s	loopboy


	move.l	$70.w,savvbl
	move.l	#vbl466,$70.w

	vsync
	move.b	#0,$ffff8260.w
	vsync

	movem.l	lolo,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,phy
	add.l	#32000,d0
	move.l	d0,log

	move.l	phy,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w

	move.l	phy,a1
	lea	204(a1),a1
	lea	dessin,a0

	MOVE	#278-1,D7
DECOMPV:
	MOVE	#(224-16)/8-1,D6
DECOMP:

SHIFT4	MACRO
	ADD	D0,D0
	ADDX	D1,D1
	ADD	D0,D0
	ADDX	D2,D2
	ADD	D0,D0
	ADDX	D3,D3
	ADD	D0,D0
	ADDX	D4,D4
	ENDM

	REPT	4
	MOVE	(A0)+,D0
	SHIFT4
	SHIFT4
	SHIFT4
	SHIFT4
	ENDR

	MOVEM	D1-D4,(A1)
	ADDQ	#8,A1
	DBRA	D6,DECOMP

	LEA	8+8+6(A1),A1

	DBRA	D7,DECOMPV

	jsr	INITMFP
	
	movem.l	palmenu,d0-d7
	movem.l	d0-d7,$ffff8240.w

mainmenu:
	STOP	#$2300
	cmp.b	#$62,$fffffc02.w
	bne.s	mainmenu
	
	jsr	FIN_MFP
;	move.l	savvbl,$70.w
;	illegal

*************************************************************
	move.l	#hbl,$120.w

	move.l	#vbldebut,$70.w
	
	
	movem.l	lolo,d0-d7
	movem.l	d0-d7,$ffff8240.w

	vsync
	move.l	phy,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w
	vsync


	vsync
	move.b	#0,$ffff8260.w
	vsync
	vsync
	move.b	#0,$ffff820a.w
	vsync
	vsync
	move.b	#2,$ffff820a.w
	vsync
	vsync
	move.b	#0,$ffff820a.w
	vsync
	vsync
	move.b	#2,$ffff820a.w
	vsync

	lea	crb_y,a0
.loopy:
	move.l	(a0),d0
	cmp.l	#32000-48*160,d0
	blt.s	.un1

	move.l	#32000-160*48,(a0)+
	bra.s	.k
.un1:
	move.l	d0,(a0)+
.k:
	cmp.l	#lolo2,a0
	blt.s	.loopy
	
deux:
	lea	crb_x,a0
.loopy:
	movem.w	(a0),d0-d1
	cmp.w	#136,d0
	blt.s	.un1

	move.w	#136,(a0)+
	move.w	#0,(a0)+
	bra.s	.k
.un1:
	move.w	d0,(a0)+
	move.w	d1,(a0)+
.k:
	cmp.l	#crb_y,a0
	blt.s	.loopy
	
	
	jsr	zik+4

	move.b	#$12,$fffffc02.w

	jsr	trans_p

	move.l	phy,a1
	move.w	#1999,d0
	moveq	#0,d1
looplo2:
	move.l	d1,(a1)+
	dbf	d0,looplo2


	lea	logo+32,a0
	move.w	#3959,d0
looplo:
	move.l	(a0)+,(a1)+
	dbf	d0,looplo

	move.w	#1999+40,d0
	moveq	#0,d1
looplo3:
	move.l	d1,(a1)+
	dbf	d0,looplo3


*	lea	logo,a0
*	lea	$ffff8240.w,a1
*	move.w	#15,d0
*loopcf:
*	move.w	(a0)+,(a1)+
*	move.w	#10-1,d1
*loopv:
*	vsync
*	dbf	d1,loopv
*	dbf	d0,loopcf

	lea	logo,a6
	bsr	colorin

	movem.l	logo,d0-d7
	movem.l	d0-d7,$ffff8240.w	

	moveq	#49,d0
toto:
	vsync2
	dbf	d0,toto

	lea	logo,a6
	bsr	colorout
	
.tyo:
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#%1111,d0
	tst.b	d0
	beq.s	.tyo

*************************************************************


	lea	sergent,a0
	move.l	phy,a1
	move.l	log,a2
	move.w	#3999,d7
	moveq	#0,d1
.loopcol:
	move.w	(a0)+,d0
	move.l	d1,(a1)
	move.l	d1,(a2)
	move.w	d1,4(a1)
	move.w	d1,4(a2)
	move.w	d0,6(a1)
	move.w	d0,6(a2)
	addq.l	#8,a1
	addq.l	#8,a2
	dbf	d7,.loopcol

	movem.l	pal1,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	pal22,d0-d3
	movem.l	d0-d3,$ffff8250.w


	move.l	#vbl,$70.w

wait:

	cmp.b	#$39,$fffffc02.w
	beq.s	sortie

	cmp.b	#$3b,$fffffc02.w
	bne.s	.f2

	movem.l	pal22,d0-d3
	movem.l	d0-d3,$ffff8250.w
.f2:
	cmp.b	#$3c,$fffffc02.w
	bne.s	.t

	movem.l	pal21,d0-d3
	movem.l	d0-d3,$ffff8250.w
.t
	vsync

	bra.s	wait
sortie:
	move.w	#$2700,sr
	movem.l	lolo,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#vbl466,$70.w

	move.w	#$2300,sr

	jsr	zik+8
	
	vsync
	move.b	#1,$ffff8260.w
	vsync

	move.l	savvbl,$70.w

	illegal

vbl:
	movem.l	d0-a6,-(sp)
;	cmp.b	#$38,$ffffffc02.w
;	bne.s	.ok
;	move.w	#$700,$ffff8240.w
;.ok:
	bsr	efface
	bsr	affiche
	bsr	yeux
	bsr	clip
	jsr	zik
;	move.w	#$00,$ffff8240.w

	movem.l	(sp)+,d0-a6
vbl466:
	addq.l	#1,$466.w
	rte

vbldebut:
	movem.l	d0-a6,-(sp)
	jsr	zik
	movem.l	(sp)+,d0-a6
	addq.l	#1,$466.w
	cmp.b	#$12,$fffffc02.w
	bne.s	.ok1
	move.l	#sortie,2(a7)
.ok1
	rte


	* a6=pointeur sur palette

**********      fade in / fade out     **************

colorin:	move.w	#0,D7

BO_IN:
	move.w	D7,D0
	move.l	A6,A0
	bsr.s	FADE
	addq.w	#1,D7
	cmp.w	#8,D0
	ble.s	BO_IN

	rts

colorout:	move.w	#8,D7

BO_OUT
	rept	5
	vsync
	endr
	move.w	D7,D0
	move.l	A6,A0
	bsr	FADE2
	subq.w	#1,D7
	tst.w	D0
	bge.s	BO_OUT

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
*	vsync2
	vsync2
	vsync2
	vsync2
	vsync2
	dbf	D1,LOOPF
	rts

FADE2:	lea	$ffFF8240.w,A1
	move.w	#$F,D1

LOOPF2:	move.w	(A0)+,D2		* on prend une couleur
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
	dbf	D1,LOOPF2
	rts



clip:
	move.l	log,d0
	move.l	phy,log
	move.l	d0,phy

	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w

	ech	old_spr11,old_spr12
	ech	old_spr21,old_spr22
	ech	old_spr31,old_spr32
	ech	old_spr41,old_spr42
	ech	old_spr51,old_spr52
	ech	old_spr61,old_spr62
	ech	old_spr71,old_spr72
	ech	old_spr81,old_spr82
	ech	old_spr91,old_spr92
*	ech	old_spr101,old_spr102
	rts

yeux:
	move.l	old_spr51,d0
	move.l	log,a1
	sub.l	a1,d0
	divu	#160,d0
	lea	tabyeux,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0
	move.l	(a0),a0

	lea	73*160+24(a1),a1

st	set	0
	rept	20
	move.w	(a0)+,st+6(a1)
	move.w	(a0)+,st+8+6(a1)
	move.w	(a0)+,st+16+6(a1)
	move.w	(a0)+,st+24+6(a1)
	move.w	(a0)+,st+32+6(a1)
	move.w	(a0)+,st+40+6(a1)
st	set	st+160
	endr
	rts

affiche:
	lea	pt_crb,a0

	move.l	log,a2

	aff_spr	old_spr11,t
	aff_spr	old_spr21,t
	aff_spr	old_spr31,t
	aff_spr	old_spr41,t
	aff_spr	old_spr51,t
	aff_spr	old_spr61,t
	aff_spr	old_spr71,t
	aff_spr	old_spr81,t
	aff_spr	old_spr91,t
*	aff_spr	old_spr101,t

	rts

efface:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

	eff	old_spr11
	eff	old_spr21
	eff	old_spr31
	eff	old_spr41
	eff	old_spr51
	eff	old_spr61
	eff	old_spr71
	eff	old_spr81
	eff	old_spr91
*	eff	old_spr101
	rts


trans_p:
	lea	t,a1
	move.l	a1,d0
	rept	16
	add.l	d0,(a1)+
	endr

	rts



vblmenu:
	move.l	#vbl2,$120.w		;timer B
	clr.b	$fffffa1b.w
	move.b	#$65,$fffffa21.w	;valeur non exacte !!!
	move.b	#4,$fffffa1b.w
	move.b	#%00000001,$fffffa07.w
	rte

*************************************************
*~~~	 Routine Fullscreen	~~~*
*************************************************

; Fullscreen qui marche sur sur tout stf et STE!!!!!
;
; nb blocs pour remplir l'‚cran :
;	26*17
;
; soit 412*276
;
; 63480 octets pour un ‚cran
;

nnop	macro
	ifgt	\1
	WAIT	\1,d2
	elseif
	IFNE	\1
	fail
	ENDC
	endc
	endm
;
; optimisations :
;	0=rien
;	1=NOP
;	2=OR.L D0,D0
;	3->???=LSR.L #,D0
;
WAIT	MACRO

	iflt	\1-(8+2*64)/4		;8+2n

	ifle	\1-2
	ifeq	\1-1
	nop
	elseif
	or.l	d0,d0
	endc
	elseif
	moveq	#(\1-3)*2,\2
	lsr.l	\2,\2
	endc
	elseif

N3	SET	(\1-7)-((\1-7)/5)*5
BEST	SET	3
MIN	SET	N3		;RECORD A BATTRE

N2	SET	(\1-6)&3
	IFLE	N2-MIN
BEST	SET	2
MIN	SET	N2
	ENDC

N1	SET	(\1-5)-((\1-5)/3)*3
	IFLE	N1-MIN
BEST	SET	1
MIN	SET	N1
	ENDC

	IFEQ	BEST-1
	MOVEQ	#(\1-5)/3,\2
\@	DBRA	\2,\@
	IFNE	N1
	DCB.W	N1,$4E71
	ENDC
	ENDC

	IFEQ	BEST-2
	MOVEQ	#(\1-6)/4,\2
\@	NOP
	DBRA	\2,\@
	IFNE	N2
	DCB.W	N2,$4E71
	ENDC
	ENDC

	IFEQ	BEST-3
	MOVEQ	#(\1-7)/5,\2
\@	NOP
	NOP
	DBRA	\2,\@
	IFNE	N3
	DCB.W	N3,$4E71
	ENDC
	ENDC

	endc
	ENDM

vbl2:
;	clr.b	$fffffa1b.w	
	clr.b	$fffffa07.w
	move	#$2100,sr

	stop	#$2100		; Synchro HBL
	move	#$2700,sr

	movem.l	d0/d1/d2/d3/d7/a0/a1/a2/a3/a4/a5,-(sp)	;56+16 cycles

;	movem.l	palmenu,d0/d1/d2/d3/d7/a0/a1/a2		;20+8*8=84=21 NOPs
;	movem.l	d0/d1/d2/d3/d7/a0/a1/a2,$ffff8240.w	;12+8*8=76=19 NOPs

	lea	$ffff820a.w,a0	; Overscan haut
	lea	$ffff8260.w,a1
	moveq	#0,d0
	moveq	#2,d1
	nnop	83-24			;-5 a +8
	move.b	d0,(a0)
	nnop	16
	move.b	d1,(a0)

	nnop	21		; Synchro SHIFTER
	move.b	$ffff8209.w,d2
	neg.b	d2
	lsr	d2,d2
				; 1ere ligne de fullscreen
	nnop	41

	move.b	d0,(a0)
	move.b	d1,(a0)

	nnop	13

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nnop	12

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nop
	move	#211-1,d7

SCROLL:	MACRO
	nnop	\1
	move.b	d0,(a0)
	move.b	d1,(a0)
	nnop	13

	ifeq	\1-86

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nnop	12

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	elseif

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)

	nnop	9

	move.b	d1,(a1)
	move.b	d1,(a0)
	move.b	d0,(a1)
	nnop	2

	endc

	ENDM

xfull1:
	SCROLL	86

	dbra	d7,xfull1

****************** Overscan bas pour tres anciens ST

	SCROLL	85

	moveq	#15-1,d7

xfull2:
	SCROLL	86

	dbra	d7,xfull2

****************** Overscan bas pour les autres STF/STE

	SCROLL	85

	moveq	#44-1,d7
xfull3:
	SCROLL	86

	dbra	d7,xfull3


	movem.l	(sp)+,d0/d1/d2/d3/d7/a0/a1/a2/a3/a4/a5
fullhbl:rte

hbl:	rte

*************************************************
*~~~      Diverses Initialisations Hard	~~~*
*************************************************
INITMFP:	move	sr,-(a7)
	move	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmf,a1
	move.w	#16,d0
savemfp:	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbf	d0,savemfp
	
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,oldvec+$40
	
	bclr	#3,$fffffa17.w	; mode aei
	
	
	move.l	#hbl,$68.w
	move.l	#vblmenu,$70.w
	move.l	#vbl2,$120.w
	
	move.b	#%00000001,$fffffa07.w	| iera
	move.b	#%00000001,$fffffa13.w	| imra
	move.b	#%00000000,$fffffa09.w	| ierb
	move.b	#%00000000,$fffffa15.w	| imrb
	
	rte

FIN_MFP:	move	sr,-(a7)
	move	#$2700,sr

	lea	oldmf,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
restmfp:	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbf	d0,restmfp
	move.b	#$c0,(a1)
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w
	rte

	section	data

pt_crb:
n:	set	180+21
m:	set	480+21
	rept	21
	dc.l	crb_x+m*4
	dc.l	crb_y+n*4
n:	set	n-4
m:	set	m-10
	endr

old_spr11:	dc.l	lolo
old_spr12:	dc.l	lolo
old_spr21:	dc.l	lolo
old_spr22:	dc.l	lolo
old_spr31:	dc.l	lolo
old_spr32:	dc.l	lolo
old_spr41:	dc.l	lolo
old_spr42:	dc.l	lolo
old_spr51:	dc.l	lolo
old_spr52:	dc.l	lolo
old_spr61:	dc.l	lolo
old_spr62:	dc.l	lolo
old_spr71:	dc.l	lolo
old_spr72:	dc.l	lolo
old_spr81:	dc.l	lolo
old_spr82:	dc.l	lolo
old_spr91:	dc.l	lolo
old_spr92:	dc.l	lolo
old_spr101:	dc.l	lolo
old_spr102:	dc.l	lolo

t:	incbin	"t.spr"
	even


crb_x:	incbin	"crb_x.bin"
	incbin	"crb_x.bin"
crb_y:	incbin	"crb_y.bin"
	incbin	"crb_y.bin"
lolo2:
fcourbe:	even


pal1:
	DC.W	0,$100,$210,$320
	DC.W	$431,$542,$653,$764
pal21:
	DCb.W	8,$777

pal22:
	DC.W	$777,$100,$210,$320
	DC.W	$431,$542,$653,$764

yeux1:
	incbin	"yeux1.1p"
yeux2:
	incbin	"yeux2.1p"
yeux3:
	incbin	"yeux3.1p"
yeux4:
	incbin	"yeux4.1p"

tabyeux:
	rept	40
	dc.l	yeux1
	endr
	rept	50
	dc.l	yeux2
	endr
	rept	40
	dc.l	yeux3
	endr
	rept	70
	dc.l	yeux4
	endr

zik:
	incbin	"killer.dat"
	even

sergent:	incbin	"sergent.1p"
	even

logo:
	incbin	"logo.4p"

palmenu:
	DC.W	0,$760,$640,$530
	DC.W	$322,$423,$534,$646
	DC.W	$526,$405,$304,$223
	DC.W	$334,$445,$556,$777
	
dessin:	incbin	"MAIN5.ful"
	even

	section	bss

dbss:

log:	ds.l	1
phy:	ds.l	1
savvbl:	ds.l	1

lolo:
	ds.b	50*160

oldmf	ds.b	17
oldvec	ds.l	24
oldpal	ds.w	16
oldec	ds.l	1
oldrez	ds.w	1

fbss
	ds.b	256
ecrans:	ds.b	32000+256
	ds.b	32000+256
	end
