
***************************************************************************
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷   E A R T H   (C) 1995 by F.POEYDOMENGE ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
***************************************************************************



TAILLE	=	192	; Taille sphere ( en pixels )
CPUTIME	=	0
STOPIMG	=	0
FINAL	=	0

	bra	FINZONEPARAM
vbl_max:	dc.l	-1
	include	INIT.S
FINZONEPARAM:

***************************************************************************

Hautbande	equ	384
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

	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp
	btst	#0,d0
	beq	QUIT

***************************************************************************

;#----------------------------------------------------------------------#
;# Initialisation GENERALES de la d‚mo ...			#
;#----------------------------------------------------------------------#
	bsr	SAUVEGARDE_CONTEXTE
	bsr	NOUVEAU_CONTEXTE

***************************************************************************

;#----------------------------------------------------------------------#
;# Initialisation SPECIFIQUES de la d‚mo ...			#
;#----------------------------------------------------------------------#

	lea	mod,a0	;***
	bsr	init_mod
	move.l	#my_vbl,$70.w

***************************************************************************

	ADR_ECRAN	#ecranmoy,logmoy
	set_screen	logmoy,logmoy,#tv60_640_200_4

	clr.w	$ffff8240.w
	move.w	#$555,$ffff8242.w
	move.w	#$555,$ffff8244.w
	move.w	#$555,$ffff8246.w
	bsr	vsync

	pea	txt
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#660,d7
zob:	bsr	vsync
	dbra	d7,zob

	bra	fintxt
txt:	dc.b	27,"E"
	dc.b	27,"Y",32+06,32+20,"÷÷÷÷÷÷÷÷÷÷÷÷   E A R T H   ÷÷÷÷÷÷÷÷÷÷÷÷"
	dc.b	27,"Y",32+10,32+20,"Code:              Gaston  "
	dc.b	27,"Y",32+11,32+20,"Replay routine:    Nullos / Dnt Crew"
	dc.b	27,"Y",32+12,32+20,"Music:             Domm   / Animal Mine"
	dc.b	27,"Y",32+16,32+20,"÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷"
	dc.b	0
	even
fintxt:	

***************************************************************************

	move.w	#TAILLE,-(sp)
	bsr	CALC_LARGEUR	
	addq.w	#2,sp
	
	include	genere.t

***************************************************************************

	lea	generejsr,a0
	lea	adrgenere,a2
	lea	BUFFER2+2,A3

	move.w	#TAILLE-1,d1
EARTHGENERE:
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
	move.l	(a2,d0.w*2),(a0)+	
fin_mk_xsr:
	dbra	d1,EARTHGENERE
	move.w	#$4e75,(a0)+

***************************************************************************

MAKE_IMAGE_VIRTUELLE:
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

;#----------------------------------------------------------------------#
;# D‚but de la boucle principale de la d‚mo ...			#
;#----------------------------------------------------------------------#	
DEBUT:	
	ADR_ECRAN	#ecran1,log1
	ADR_ECRAN	#ecran2,log2
	move.l	log1,log
	move.l	log1,logaux

colfond=$39c7
colfond2=$3a3a3a3a
	lea	avecran,a0
	move.l	#(384*2*240*2+384*2*100+256*4*2)/4-1,d0
clrscr:	move.l	#colfond*65536+colfond,(a0)+
	subq.l	#1,d0
	bne.s	clrscr
	set_screen2	#tv50_384_240_tc,log1	
	move.l	#colfond2,$ffff9800.w

	move.w	$FFFF82A8.w,oldvidel1
	move.w	$FFFF82AA.w,oldvidel2
	add.w	#8,$FFFF82A8.w	
	sub.w	#8,$FFFF82AA.w	

	;--------------------------------------------------------------

	move.w	#$2300,sr

	movec.l	cacr,d0
	bclr	#0,d0	
	bclr	#8,d0	
	movec.l	d0,cacr
	
	;--------------------------------------------------------------

	move.l	#4*2,vitesse
	move.w	#0,bounding
	move.w	#1,direction
	move.w	#360,compteur_moi	
	move.w	#0,looping
	jsr	MAPPE_MONDE

	move.w	#90,screenx
	move.l	#180,addscreen	
	move.l	#20*Xrsl*2,addyscreen
	
	move.l	#4*2,vitesse
	move.w	#1,bounding
	move.w	#1,direction
	move.w	#0,compteur_moi
	move.w	#1,looping
	jsr	MAPPE_MONDE
	
***************************************************************************

;#----------------------------------------------------------------------#
;# Et voil…, that's all folk ! cassos ...			#
;#----------------------------------------------------------------------#	
QUIT:	move.w	oldvidel1,$FFFF82A8.w
	move.w	oldvidel2,$FFFF82AA.w
	bsr	vsync

	move.l	#my_vbl2,$70.w
	lea	mod,a0
	bsr	init_mod	;*** bsr stop_mod

	bsr	RESTAURE_CONTEXTE
	clr.w	-(sp)
	trap	#1

***************************************************************************

MAPPE_MONDE:
	move.l	posx,d7

	tst.w	bounding
	bne.s	test
	move.l	#180,addscreen
	move.l	#20*Xrsl*2,addyscreen
test:
	move.b	logaux+1,$ffff8201.w
	move.b	logaux+2,$ffff8203.w
	move.b	logaux+3,$ffff820d.w
	bsr	vsync
	IFEQ	CPUTIME-1
	move.l	#-1,$ffff9800.w
	ENDC

	move.l	log,a6
	lea	(image2,d7.l),a5

	ifeq	CPUTIME-1
	clr.l	$ffff9800.w
	endc
	movem.l	d0-a4,-(sp)
	jsr	generejsr	
	movem.l	(sp)+,d0-a4
	ifeq	CPUTIME-1
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
	bra.s	swap2
swap1:	move.l	log1,log
	move.l	log2,d0
	add.l	addscreen,d0
	add.l	addyscreen,d0
	sub.l	#188+384*2*40,d0 
swap2:	move.l	d0,logaux

test1:	tst.w	bounding
	beq	test2

	; Bouge de Gauche a Droite de l'ecran	

	move.w	direction,d0
	lsl.w	#1,d0
	add.w	d0,screenx
	
	cmpi.w	#2-4,screenx
	bne.s	notinf
	move.w	#1,direction
	move.w	#6-4,screenx
notinf:
	cmpi.w	#184+4,screenx
	bne.s	notsup
	move.w	#-1,direction
	move.w	#180+4,screenx
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
	bne	MAPPE_MONDE
	subq.w	#1,compteur_moi
	bne	MAPPE_MONDE
	rts

***************************************************************************
	
	include	calclarg.t
	even

	include	dsp_play.t
	even

my_vbl:	bsr	Play_Mod
	addq.l	#1,$466.w
	RTE

my_vbl2:	addq.l	#1,$466.w
	RTE

;#----------------------------------------------------------------------#	
;# Sauvegarde du contexte d'origine au lancement de la d‚mo ...	#
;#----------------------------------------------------------------------#	
SAUVEGARDE_CONTEXTE:
	super
	get_colors
	get_screen
	get_mfp
	get_cacr
	adr_ecran	#ecran1,adr_ecran1
	adr_ecran	#ecran2,adr_ecran2
	RTS

;#----------------------------------------------------------------------#	
;# Remet le contexte d'origine avant de quitter la d‚mo ...		#
;#----------------------------------------------------------------------#	
RESTAURE_CONTEXTE:
	clr_oldphysbase
	clr_oldlogbase
	set_screen	old_logbase,old_physbase,#tv60_640_200_4
	put_colors
	put_cacr
	put_mfp
	mouse_on
	flush_keyboard
	RTS

;#----------------------------------------------------------------------#	
;# Installe le nouveau contexte dans lequel va tourner la d‚mo ...	#
;#----------------------------------------------------------------------#	
NOUVEAU_CONTEXTE:
	move.w	#$2700,sr
	ini_vbl
	set_cacr	#%100010001
	move.w	#$2300,sr
	mouse_off
	flush_keyboard
	clr.l	$ffff9800.w
	clr.w	$ffff8240.w
	clrscr	adr_ecran1,#320*200*2/4-1
	clrscr	adr_ecran2,#320*200*2/4-1
	set_screen	adr_ecran1,adr_ecran2,#tv50_384_240_tc
	RTS

***************************************************************************

	SECTION DATA

image:	incbin	earth.xga	
finimage:

mod:	incbin	680xx.ntk
	even
	
bound:	incbin	bound.tab
endbound:
ptrbound:	dc.l	bound+22

degrade:	incbin	degrade.rip

***************************************************************************

	SECTION BSS
	
	even
log1:	ds.l	1
log2:	ds.l	1
logaux:	ds.l	1

posx:	ds.l	1
direction:	ds.w	1
screenx:	ds.w	1
addscreen:	ds.l	1
addyscreen:	ds.l	1

vitesse:	ds.l	1	;vitesse de rotation
bounding:	ds.w	1	;est ce que la boule rebondit ? 1=oui
compteur_moi:	
	ds.w	1	;nb de vbl avant de quitter
looping:	ds.w	1	;on tourne indefiniment ? 1=oui 0=non

reajuste:	ds.w	1
log:	ds.l	1
oldmodecode:ds.w	1
oldadrlog:	ds.l	1
oldvidel1:	ds.w	1
oldvidel2:	ds.w	1

generejsr:	ds.b	10*220 	; si la boule fait 220 de diamŠtre
genere:	ds.b	40000
adrgenere:	ds.b	220*4

buffer:	ds.b	500
buffer2:	ds.b	500
sbuffer2:	ds.w	1
	even

ecranmoy:	ds.b	32000+256
logmoy:	ds.l	1

adr_ecran1:	ds.l	1
adr_ecran2:	ds.l	1

avecran:	ds.b	384*100*2
ecran1:	ds.b	384*240*2+256
ecran2:	ds.b	384*240*2+256

image2:	ds.w	409600
