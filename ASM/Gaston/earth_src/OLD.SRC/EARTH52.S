TAILLE	=	194
DEBUG	=	0
***************************************************************************
js	equr	d7
compt	equr	d6
a	equr	d5
j	equr	d3
comptpas	equr	d2

Offset	equr	d6
ray	equr	d5
Y1	equr	d4
Largeur_Ligne	equr	d3
x	equr	d2
Total	equr	d1
buff	equr	a5
Y2	equr	a3
gen	equr	a2
adrgen	equr	a1
buff2	equr	a0

Hautbande	equ	384
***************************************************************************
Xrsl	equ	384
Largimage	equ	640+640
***************************************************************************
	jmp	DEMO
	even
image:	incbin	h:\pic.xga		; Trop gros pr les Datas !!
finimage:

DEMO:	
	***** SUPERVISEUR *****
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	***** SAUVERGARDE DU MODE GRAPHIQUE *****
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,oldmodecode
	
	***** SAUVE L' ADR. LOGIQUE DE L' ECRAN *****
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldadrlog

	***** CALCULE LES LARGEURS DE CHAQUE LIGNE *****
	move.w	#TAILLE,-(sp)
	bsr	CALC_LARGEUR	
	addq.w	#2,sp
	
	include	'h:\earth\genere.s'
***************************************************************************
	lea	generejsr,a0
	lea	adrgenere,a2
	lea	BUFFER2+2,A3

	move.w	#TAILLE-1,d1
earthgenere:
	move.w	(largeur,d1.w*2),d0
	move.w	#$4eb9,(a0)+
	move.l	(a2,d0.w*2),(a0)+	; jsr ([a2,d0.w*2])

	move.w	#$4bed,(a0)+
	move.w	(a3)+,d0
	subq.w	#1,d0
	mulu	#largimage*2,d0
	move.w	d0,(a0)+

	dbra	d1,earthgenere
	move.w	#$4e75,(a0)+

***************************************************************************
Make_image_virtuelle:
	lea	image2,a1
	
	lea	image,a0
	move.w	#Largimage/4-1,d1
premiere_partie:
	move.l	a0,a2
	move.w	#Largimage/2-1,d0	
copy11:	move.w	(a2)+,(a1)+
	dbra	d0,copy11
	move.l	a0,a2
	move.w	#Largimage/2-1,d0	
copy12:	move.w	(a2)+,(a1)+
	dbra	d0,copy12
	lea	2*2*largimage/4(a0),a0
	dbra	d1,premiere_partie
	

***************************************************************************
DEBUT:	

overscan	equ	%1000000		; mode : 384*240 TrueColor
	move.w	#%100100+overscan,-(sp)	
	move.w	#3,-(sp)
	move.l	#ecran,-(sp)
	move.l	#ecran,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	move.l	log1,log
	
	lea	avecran,a0
	move.w	#384*(240+40)*2/4-1,d0
clrscr1:	clr.l	(a0)+
	dbra	d0,clrscr1
	move.w	#384*240*2/4-1,d0
clrscr2:	clr.l	(a0)+
	dbra	d0,clrscr2
	clr.l	$ffff9800.w

	move.w	#%10001100000000,sr
	movec.l	cacr,d0
	bset	#0,d0	; INST
	bclr	#8,d0	; DONN
	movec.l	d0,cacr

	move.l	#2*2,vitesse
	move.w	#0,bounding
	move.w	#1,direction
	move.w	#750,compteur
	move.w	#0,looping
	jsr	Mappemonde
	
	move.l	#4*2,vitesse
	move.w	#1,bounding
	move.w	#1,direction
	move.w	#0,compteur
	move.w	#1,looping
	jsr	Mappemonde
	
	***********	
	* THE END *
	***********	
QUIT:

	move.w	#%10000000000000,sr
	
	move.w	oldmodecode,-(sp)
	move.w	#3,-(sp)
	move.l	oldadrlog,-(sp)
	move.l	oldadrlog,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	
Q:	clr.w	(sp)
	trap	#1

Mappemonde:
	
repeat:
	move.l	posx,d7

	tst.w	bounding
	bne.s	test
	move.l	#180,addscreen
	move.l	#20*Xrsl*2,addyscreen
test:

	move.l	$462.w,d0
vb:	cmp.l	$462.w,d0
	beq.s	vb
	
	move.l	log,a6
	lea	(image2,d7.l),a5

	ifeq	DEBUG-1
	clr.l	$ffff9800.w
	endc
	movem.l	d0-a4,-(sp)
	jsr	generejsr	
	movem.l	(sp)+,d0-a4
	ifeq	DEBUG-1
	move.l	#-1,$ffff9800.w
	endc

	move.l	log1,d0
	cmp.l	log,d0
	bne.s	swap1

	move.l	log2,log
	move.l	log1,d0
	add.l	addscreen,d0
	add.l	addyscreen,d0
	sub.l	#190+384*2*40,d0
	move.w	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	bra.s	swap2
swap1:	move.l	log1,log
	move.l	log2,d0
	add.l	addscreen,d0
	add.l	addyscreen,d0
	sub.l	#190+384*2*40,d0
	move.w	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
swap2:

test1:	tst.w	bounding
	beq	test2
	
	move.w	direction,d0
	lsl.w	#1,d0
	add.w	d0,screenx
	
	cmpi.w	#2,screenx
	bne.s	notinf
	move.w	#6,screenx
	move.w	#1,direction
notinf:
	cmpi.w	#184,screenx
	bne.s	notsup
	move.w	#180,screenx
	move.w	#-1,direction
notsup:
	move.w	screenx,d0
	ext.l	d0
	lsl.l	#1,d0
	move.l	d0,addscreen
	
	move.l	ptrbound,a0
	move.w	(a0)+,d0
	cmp.l	#endbound,a0
	bne.s	contt
	move.l	#bound,a0
contt:
	move.l	a0,ptrbound
	mulu	#Xrsl*2,d0
	move.l	d0,addyscreen
	
test2:
	tst.w	direction
	bmi.s	pas_droite
	move.l	vitesse,d0
	sub.l	d0,posx
	neg.l	d0
	cmp.l	posx,d0
	bne.s	pas_droite
	move.l	#(2*Largimage/4)*2,posx
	add.l	d0,posx
pas_droite:
	tst.w	direction
	bpl.s	pas_gauche
	move.l	vitesse,d0
	add.l	d0,posx
	cmpi.l	#(2*Largimage/4)*2,posx
	bne.s	pas_gauche
	clr.l	posx
pas_gauche:

	cmpi.b	#57,$fffffc02.w
	beq	QUIT
	
	tst.w	looping
	bne	repeat
	subq.w	#1,compteur
	bne	repeat
	rts
	
	include	'h:\earth\calclarg.s'
***********
* DONNEES *
***********
	section data
bound:	incbin	h:\earth\bound.tab
endbound:
ptrbound:	dc.l	bound

log1:	dc.l	ecran-2*0
log2:	dc.l	ecran2

posx:	dc.l	0
direction:	dc.w	0
screenx:	dc.w	0
addscreen:	dc.l	4
addyscreen:	dc.l	0

	section bss
	even

vitesse:	ds.l	1	;vitesse de rotation
bounding:	ds.w	1	;est ce que la boule rebondit ? 1=oui
compteur:	ds.w	1	;nb de vbl avant de quitter
looping:	ds.w	1	;on tourne indefiniment ? 1=oui 0=non

reajuste:	ds.w	1
log:		ds.l	1
oldmodecode:	ds.w	1
oldadrlog:		ds.l	1

generejsr:	ds.b	10*220 ; si la boule fait 250 de diamätre
adrgenere:	ds.b	220*4
genere:	ds.b	40000

buffer:	ds.b	500
buffer2:	ds.b	500
sbuffer2:	ds.w	1
	even
avecran:	ds.b	384*040*2
ecran:	ds.b	384*240*2
ecran2:	ds.b	384*240*2

image2:	ds.w	409600