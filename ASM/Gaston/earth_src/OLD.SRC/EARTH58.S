TAILLE	=	180
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
	bra	debutdemo
	dc.b	"                "
	dc.b	"<  E A R T H  > "
	dc.b	"                "
	dc.b	"Contact adress :"
	dc.b	"POEYDOMENGE     "
	dc.b	"        Frederic"
	dc.b	"38 lot. Oyhanto "
	dc.b	"64990 Lahonce   "
	dc.b	"          France"
	dc.b	"                "
debutdemo:

***************************************************************************
	include	h:\macro\init_mac.s
	INITIALISE

***************************************************************************
	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp
	btst	#0,d0
	beq	QUIT

***************************************************************************

	ADR_ECRAN	#ecranmoy,logmoy
	move.w	#1,-(sp)
	move.l	logmoy,-(sp)
	move.l	logmoy,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	clr.w	$ffff8240.w
	move.w	#$555,$ffff8242.w
	move.w	#$555,$ffff8244.w
	move.w	#$555,$ffff8246.w
	bsr	vsync

	pea	txt
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#200,d1
zob:	move.w	#10000,d0
wob:	dbra	d0,wob
	dbra	d1,zob

	bra	fintxt
txt:	dc.b	27,"E"
	dc.b	27,"Y",32+06,32+30,"<<<  E A R T H  >>>"
	dc.b	27,"Y",32+12,32+20,"Code:              Gaston / ( no crew )"
	dc.b	27,"Y",32+13,32+20,"Replay routine:    Nullos / Dnt Crew"
	dc.b	27,"Y",32+14,32+20,"Music:             Domm   / Animal Mine"
	dc.b	0
	even
fintxt:	

***************************************************************************

	***** CALCULE LES LARGEURS DE CHAQUE LIGNE *****
	move.w	#TAILLE,-(sp)
	bsr	CALC_LARGEUR	
	addq.w	#2,sp
	
	include	'h:\demos\earth\genere.s'
***************************************************************************
	lea	generejsr,a0
	lea	adrgenere,a2
	lea	BUFFER2+2,A3

	move.w	#TAILLE-1,d1
earthgenere:
	move.w	(largeur,d1.w*2),d0

	move.l	(a2,d0.w*2),d2
	sub.l	a0,d2
	subq.l	#2,d2
	
	cmpi.l	#32767,d2
	bhi.s	mk_jsr
mk_bsr:	move.w	#$6100,(a0)+
	move.w	d2,(a0)+
	bra.s	fin_mk_xsr
mk_jsr:	move.w	#$4eb9,(a0)+
	move.l	(a2,d0.w*2),(a0)+	; jsr ([a2,d0.w*2])
fin_mk_xsr:

	move.w	(a3)+,d0
	subq.w	#1,d0
	mulu	#largimage*2,d0
	beq.s	eg2
	move.w	#$4bed,(a0)+
	move.w	d0,(a0)+
eg2:
	dbra	d1,earthgenere
	move.w	#$4e75,(a0)+

***************************************************************************
Make_image_virtuelle:
	lea	image2,a1
	lea	degrade,a3
	
	lea	image,a0
	move.w	#Largimage/4-1,d1
premiere_partie:
	move.l	a0,a2
	clr.l	d2
	move.w	#Largimage/2-1,d0	
copy11:	move.b	(a2)+,d2
	move.w	(a3,d2.w*2),(a1)+
	dbra	d0,copy11
	move.l	a0,a2
	clr.l	d2
	move.w	#Largimage/2-1,d0	
copy12:	move.b	(a2)+,d2
	move.w	(a3,d2.w*2),(a1)+
	dbra	d0,copy12
	lea	2*largimage/4(a0),a0
	dbra	d1,premiere_partie
	

***************************************************************************
DEBUT:	

	ADR_ECRAN	#ecran,log1
	ADR_ECRAN	#ecran2,log2
	move.l	log1,log
colfond=$39c7
colfond2=$3a3a3a3a
	lea	avecran,a0
	move.l	#(384*2*240*2+384*2*100+256*4*2)/4-1,d0
clrscr:	move.l	#colfond*65536+colfond,(a0)+
	subq.l	#1,d0
	bne.s	clrscr
	SETSCREEN2	tv50_384_240_tc,log1	
	move.l	#colfond2,$ffff9800.w

	move.w	$FFFF82A8.w,oldvidel1
	move.w	$FFFF82AA.w,oldvidel2
	add.w	#20,$FFFF82A8.w	
	sub.w	#20,$FFFF82AA.w	

	;--------------------------------------------------------------
	move.w	#$2300,sr

	movec.l	cacr,d0
	bclr	#0,d0	; INST
	bclr	#8,d0	; DONN
	movec.l	d0,cacr
	
	lea	TransC(pc),a0
	lea	ExTransC(pc),a1
	pmove.l	tc,(a1) ; sauve l'ancien
	pmove.l	(a0),tc ; met le nouveau
	bra.s	fin_pmmu
TransC:	dc.l	%00000000111100000000000000000000
ExTransC:	dc.l	0
fin_pmmu:
	;--------------------------------------------------------------

	move.l	#4*2,vitesse
	move.w	#0,bounding
	move.w	#1,direction
	move.w	#360,compteur	; #360,compteur
	move.w	#0,looping
	jsr	Mappemonde

	move.w	#90,screenx
	move.l	#180,addscreen	; 180
	move.l	#20*Xrsl*2,addyscreen
	
	move.l	#4*2,vitesse
	move.w	#1,bounding
	move.w	#1,direction
	move.w	#0,compteur
	move.w	#1,looping
	jsr	Mappemonde
	
	***********	
	* THE END *
	***********	
QUIT:	lea	ExTransC,a1
	pmove.l	(a1),tc

	move.w	oldvidel1,$FFFF82A8.w
	move.w	oldvidel2,$FFFF82AA.w
	bsr	vsync

	RESTAURE

Mappemonde:
	move.l	posx,d7

	tst.w	bounding
	bne.s	test
	move.l	#180,addscreen
	move.l	#20*Xrsl*2,addyscreen
test:
	bsr	vsync

	move.l	log,a6
	lea	(image2,d7.l),a5

	ifeq	DEBUG-1
	clr.l	$ffff9800.w
	endc
	movem.l	d0-a4,-(sp)
	move.w	#$2700,sr
	jsr	generejsr	
	move.w	#$2300,sr
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
	sub.l	#188+384*2*40,d0
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
	sub.l	#188+384*2*40,d0 
	move.w	#-1,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
swap2:

test1:	tst.w	bounding
	beq	test2

	; Bouge de Gauche a Droite de l'ecran	
	move.w	direction,d0
	lsl.w	#1,d0
	add.w	d0,screenx
	
	cmpi.w	#2-10,screenx
	bne.s	notinf
	move.w	#1,direction
	move.w	#6-10,screenx
notinf:
	cmpi.w	#184+10,screenx
	bne.s	notsup
	move.w	#-1,direction
	move.w	#180+10,screenx
notsup:
	move.w	screenx,d0
	ext.l	d0
	lsl.l	#1,d0
	move.l	d0,addscreen

	; Mouvement vertical : rebondit ...
	move.l	ptrbound,a0
	move.w	(a0)+,d0
	cmp.l	#endbound,a0
	bne.s	contt
	lea	bound,a0
contt:
	move.l	a0,ptrbound
	mulu	#Xrsl*2,d0
	move.l	d0,addyscreen
	
test2:
	; Pour bouger l'image mapp‚e ...
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
	bne	Mappemonde
	subq.w	#1,compteur
	bne	Mappemonde
	rts
	
	include	'h:\demos\earth\calclarg.s'
***********
* DONNEES *
***********
	SECTION DATA

image:	incbin	h:\demos\earth\g2.xga
finimage:
	
bound:	incbin	h:\demos\earth\bound.tab
endbound:
ptrbound:	dc.l	bound+22

degrade:	incbin	h:\demos\earth\degrade2.rip

	SECTION BSS
	
	even
log1:	ds.l	1
log2:	ds.l	1

posx:	ds.l	1
direction:	ds.w	1
screenx:	ds.w	1
addscreen:	ds.l	1
addyscreen:	ds.l	1

vitesse:	ds.l	1	;vitesse de rotation
bounding:	ds.w	1	;est ce que la boule rebondit ? 1=oui
compteur:	ds.w	1	;nb de vbl avant de quitter
looping:	ds.w	1	;on tourne indefiniment ? 1=oui 0=non

reajuste:	ds.w	1
log:		ds.l	1
oldmodecode:	ds.w	1
oldadrlog:		ds.l	1
oldvidel1:	ds.w	1
oldvidel2:	ds.w	1

generejsr:	ds.b	10*220 ; si la boule fait 250 de diamŠtre
genere:	ds.b	40000
adrgenere:	ds.b	220*4

buffer:	ds.b	500
buffer2:	ds.b	500
sbuffer2:	ds.w	1
	even

ecranmoy:	ds.b	32000+256
logmoy:	ds.l	1

avecran:	ds.b	384*100*2
	ds.b	256*4
ecran:	ds.b	384*240*2
ecran2:	ds.b	384*240*2
	ds.b	256*4

image2:	ds.w	409600