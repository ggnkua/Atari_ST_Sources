;
; CE QU'IL FAUT FAIRE :
;
;
; OPTIMISATIONS A FAIRE :
;
;	AMELIORER ROUTINE SPRITE 3 PLANS (APRES ROL.W)
;	AMELIORER LES MOVEM -D(AN) PAR DES SUBQ
;
;	output	a:\auto\toki.prg
typemus = 1		;0,1,2,3
PLANS = 4		;4 PLANS pour affichage de Toki
DEBUG = 1		;0=d‚buggage
;
; premier essai d'animation de Toki
;
; d‚mo de sprites
;
nbvbl   = 2
ecran0  = $80000-32000
ecran1  = ecran0-32000
ramtop  = ecran1
hauteur = 176
largeur = 224
basemfp = $40
largeur_map = 256
X_MAP	= $430-largeur/2
Y_MAP	= $3F8-16-hauteur/2
	opt	o+,ow-
;
; animation d'un ‚cran largeur*hauteur
;
CPU	MACRO
	ifeq	DEBUG
	tst.b	touches+$f	;TAB
	beq.s	.\@
	move	#\1,$ffff8240.w
.\@
	endc
	ENDM
	offset	$200
ecran:	ds.l	1
sync:	ds.w	1
coordx	ds.w	1
coordy	ds.w	1
n_toki	ds.w	1
xtoki	ds.w	1
ytoki	ds.w	1
touche:	ds.b	1
	section	text
;
; nouvelle routine de sprite d‚calant
;
; d0=num‚ro du sprite ???
; a0=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
CLIPPE4	MACRO			;macro clipping 4 plans

	moveq	#$f,d5
	and	d1,d5
	add	d3,d5

	moveq	#15,d7		;D7=$F (gain=4 cycles)
	add	d7,d5
	add	d7,d3
	not	d7		;D7=$FFF0 (gain=4 cycles)
	and	d7,d5
	and	d7,d3
	lsr	#1,d5		;d5=nb octets pour effacement
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	A0=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#hauteur,d2
	blo.s	cliphau\@
	bge	retsp\@		;trop en bas
	neg	d2
	sub	d2,d4
	bls	retsp\@
	mulu	d3,d2
	add	d2,a0

;	moveq	#0,d2		;d2=offset ‚cran
	move	mul160(pc),d2
	bra.s	noclipbas\@
cliphau\@
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160(pc),a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	noclipbas\@
	sub	d0,d4
noclipbas\@

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	clipgau\@
	bge.s	retsp\@		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
;	bls.s	retsp\@
	blo.s	retsp\@
	sub	d1,d5

	move	d1,a3

	add	a3,a0

	or.b	#$40,d0		;indique clipping … gauche
	bra.s	noclipdro\@
clipgau\@
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	noclipdro\@
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	sub	d1,d5
	move	d1,a3

noclipdro\@
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d5=nb plans*8 … effacer
;	d4=nb lignes
;
	cmp	d3,d5
	bne.s	pacl\@
	btst	#6,d0
	bne.s	pacl\@
	tas	d0
pacl\@
;	add	d5,d5

	move.l	ecran,a1
	add	d2,a1

	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a0=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	LEA	newsprite(pc),a4
	jsr	(a4,d0.w)
retsp\@
	ENDM

CLIPPE3	MACRO			;macro clipping 3 plans

	moveq	#$f,d5
	and	d1,d5
	add	d3,d5

	moveq	#15,d7		;D7=$F (gain=4 cycles)
	add	d7,d5
	add	d7,d3
	not	d7		;D7=$FFF0 (gain=4 cycles)
	and	d7,d5
	and	d7,d3
	lsr	#1,d5		;d5=nb octets pour effacement
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	A0=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#hauteur,d2
	blo.s	cliphau\@
	bge	retsp\@		;trop en bas
	neg	d2
	sub	d2,d4
	bls	retsp\@
	mulu	d3,d2
	add	d2,a0

	lsr	#2,d2		;3 plans
	sub	d2,a0

;	moveq	#0,d2		;d2=offset ‚cran
	move	mul160(pc),d2
	bra.s	noclipbas\@
cliphau\@
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160(pc),a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	noclipbas\@
	sub	d0,d4
noclipbas\@

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	clipgau\@
	bge.s	retsp\@		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
;	bls.s	retsp\@
	blo.s	retsp\@
	sub	d1,d5

	move	d1,a3

	lsr	#2,d1		;3 plans
	sub	d1,a3

	add	a3,a0

	or.b	#$40,d0		;indique clipping … gauche
	bra.s	noclipdro\@
clipgau\@
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	noclipdro\@
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	sub	d1,d5
	move	d1,a3

	lsr	#2,d1		;3 plans
	sub	d1,a3

noclipdro\@
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d5=nb plans*8 … effacer
;	d4=nb lignes
;
	cmp	d3,d5
	bne.s	pacl\@
	btst	#6,d0
	bne.s	pacl\@
	tas	d0
pacl\@
;	add	d5,d5

	move.l	ecran,a1
	add	d2,a1

	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a0=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	LEA	newsprite(pc),a4
	jsr	(a4,d0.w)
retsp\@
	ENDM
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	lea	ramtop,sp
	move.l	#ecran0,d0
	move.l	d0,ecran
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	ifeq	DEBUG
	jsr	debugger
	endc

	jsr	initkbd

	move.l	#vbl,$70.w

	moveq	#1,d0
	jsr	musique

	move	#$2300,sr

	lea	ramtop,a0
	lea	$80000,a1
	moveq	#0,d0
fill_mem:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	fill_mem

	BSR	INITSCROLL
;
; init sprites de Toki
;
; recalcule les offsets de sprites
;
	lea	toki,a0
	move	(a0)+,d0
	moveq	#0,d1
	move	d0,d1
	asl	#3,d1
	add.l	a0,d1
	subq	#1,d0
renum:
	addq	#4,a0
	add.l	d1,(a0)+
	dbra	d0,renum
;
;
	clr	coordx
	move	#Y_MAP-32,coordy	;en bas (quelconque)
	move	#1,n_toki

	bsr	flippe_toki
;
; rafraichissement des vignettes
;
	move	#largeur,coordx
.refresh:
	clr	vitx
	clr	vity

	BSR	GERE_COORDONNEES

;	BSR	MOVESCROLL
	BSR	CALCPTRSCROLL
	BSR	REFRESHX
	BSR	REFRESHY

	subq	#4,coordx
	bne.s	.refresh

	clr	sync
bc:	tst	sync
	beq.s	bc
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
boucle:
	clr	vitx
	clr	vity

	move.b	joystick1,d0
	btst	#2,d0
	bne.s	.gau
	tst.b	touches+$4b	;gauche
	beq.s	.notgau
.gau	add	#-2*nbvbl,vitx
.notgau
	btst	#3,d0
	bne.s	.dro
	tst.b	touches+$4d	;droite
	beq.s	.notdro
.dro	add	#2*nbvbl,vitx
.notdro
	btst	#0,d0
	bne.s	.hau
	tst.b	touches+$48	;haut
	beq.s	.nothau
.hau	add	#-1*nbvbl,vity
.nothau
	btst	#1,d0
	bne.s	.bas
	tst.b	touches+$50	;bas
	beq.s	.notbas
.bas	add	#+1*nbvbl,vity
.notbas
;	move	#3000,d0
;.wait	dbra	d0,.wait
;	move	#$222,$ffff8240.w
;	bsr	flippe_toki
;	clr	$ffff8240.w

	BSR	GERE_COORDONNEES

	BSR	MOVESCROLL

	iflt	nbvbl-2
	move.l	ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	endc

	ifeq	DEBUG
	move.l	ecran,a6
	move	xscroll,d0
	bsr	print

	move.l	ecran,a6
	lea	8*3(a6),a6
	move	yscroll,d0
	bsr	print

	move.l	ecran,a6
	lea	8*6(a6),a6
	move	coordx,d0
	bsr	print

	move.l	ecran,a6
	lea	8*9(a6),a6
	move	coordy,d0
	bsr	print
	endc

	CPU	$333

	move	xtoki,d1	;coordonn‚e X
	move	ytoki,d2	;coordonn‚e Y

	move	n_toki,d0
	ifeq	1
	cmp	#1,d0
	bne.s	.paflip
	lea	flip_toki,a0
	moveq	#0,d3
	move.b	(a0)+,d3
	moveq	#0,d4
	move.b	(a0)+,d4
	moveq	#0,d5		;d‚calage en X
	move.b	(a0)+,d5
	moveq	#0,d6		;d‚calage en Y
	move.b	(a0)+,d5
	bra.s	.good
.paflip
	endc
	lea	toki+2,a0
	SUBQ	#1,D0
	asl	#3,d0
	add	d0,a0
	moveq	#0,d3
	move.b	(a0)+,d3
	moveq	#0,d4
	move.b	(a0)+,d4

	moveq	#0,d5
	move.b	(a0)+,d5
	moveq	#0,d6
	move.b	(a0)+,d6

	move.l	(a0),a0
.good
	sub	d4,d2		;Ytoki=Y bas !!!

	CLIPPE4

	ADD	#65536/7*nbvbl,.CHRONO
	BCC.S	.nonew
	ADDQ	#1,n_toki
	cmp	#7,n_toki
	blo.s	.nonew
	move	#1,n_toki
	bra.s	.nonew
.CHRONO	DC.W	0
.nonew
	CLR	$FFFF8240.W

	ifge	nbvbl-2
	move.l	ecran,d0
	lsr	#8,d0
1$	tst	sync
	beq.s	1$
	move.l	d0,$ffff8200.w
	endc

	eor.l	#ecran0^ecran1,ecran

bcl2:	cmp	#nbvbl,sync
	blo.s	bcl2

	beq.s	1$
	moveq	#-1,d1
2$	move	d1,$ffff8240.w
	dbra	d1,2$
1$
	CPU	$222
	clr	sync
	bra	boucle
vbl:
	addq	#1,sync
	movem.l	d0-d7/a0-a6,-(sp)

	moveq	#0,d0

	tst.b	touches+$3b
	beq.s	.paf1
	moveq	#1,d0
.paf1
	tst.b	touches+$3c
	beq.s	.paf2
	moveq	#2,d0
.paf2
	tst.b	touches+$3d
	beq.s	.paf3
	moveq	#3,d0
.paf3
	tst.b	touches+$3e
	beq.s	.paf4
	moveq	#4,d0
.paf4
	tst.b	touches+$3f
	beq.s	.paf5
	moveq	#5,d0
.paf5
	tst.b	touches+$40
	beq.s	.paf6
	moveq	#6,d0
.paf6
	tst.b	touches+$41
	beq.s	.paf7
	moveq	#7,d0
.paf7
	tst.b	touches+$42
	beq.s	.paf8
	moveq	#8,d0
.paf8
	tst.b	touches+$43
	beq.s	.paf9
	moveq	#9,d0
.paf9
	tst.b	touches+$44
	beq.s	.paf10
	moveq	#10,d0
.paf10
	cmp	lastmusic,d0
	beq.s	.same
	move	d0,lastmusic
	beq.s	.same
	jsr	musique
	bra.s	.notsame
.same
	jsr	musique+8
.notsame
	movem.l	(sp)+,d0-d7/a0-a6
	rte
lastmusic:dc.w	0
nbspr:	dc.w	0

	include	INCLUDES\kbd.s

	ifeq	DEBUG
print:
	moveq	#4-1,d7
hexa:	rol	#4,d0
	moveq	#$f,d1
	and	d0,d1
	asl	#3,d1
	lea	fonte(pc),a0
	add	d1,a0

x	set	0
	rept	5
	move.b	(a0)+,x(a6)
x	set	x+160
	endr

	addq	#1,a6
	move	a6,d1
	lsr	#1,d1
	bcs.s	2$
	addq	#6,a6
2$
	dbra	d7,hexa
	rts
	endc
;
; recentre le sprite par rapport … la coordonn‚e de Toki par rapport … la map
;
movex:	dc.w	0
movey:	dc.w	0
GERE_COORDONNEES
;
; gestion offset d‚placement en X
;  (lin‚aire pour Amiga, constant pour ST)
;
	ifeq	1
	moveq	#2,d0
	tst	vity
	beq.s	.none
	bpl.s	.positif
	moveq	#-2,d0
.positif
	add	movey,d0
	cmp	#16,d0
	blo.s	.okmovx
	sge	d0
	ext	d0
	and	#16,d0
.okmovx	move	d0,movey
.none
	endc

	move	#64,movex	;constante sur ST !!!
	move	#64,movey	;constante sur ST ???

	move	vitx,d0
	add	coordx,d0
	cmp	#X_MAP,d0
	blo.s	.23
	sge	d0
	ext	d0
	and	#X_MAP,d0
	neg	vitx
.23	move	d0,coordx

	move	vity,d0
	add	coordy,d0
	cmp	#Y_MAP,d0
	blo.s	.24
	sge	d0
	ext	d0
	and	#Y_MAP,d0
	neg	vity
.24	move	d0,coordy

	lea	boxes(pc),a6
	move	coordx,d6
	move	coordy,d7
.no	move	(a6)+,d4
	bmi.s	.centrage2		;DEBUG: doit brancher sur plante !!!
	movem	(a6)+,d0-d3
	cmp	d0,d6
	blo.s	.no
	cmp	d2,d6
	bhi.s	.no
	cmp	d1,d7
	blo.s	.no
	cmp	d3,d7
	bhi.s	.no
;
; d6=coordx,d7=coordy
; d4=type du scroll
;
	ifeq	DEBUG
	cmp	#.fincentrage-.centrage,d4
	bhs	plante
	endc
	jmp	.centrage(pc,d4.w)
.centrage
	bra.w	.nocentre		;0
	bra.w	.centregauche		;1
	bra.w	.centrebas		;2
	bra.w	.centredroit		;3
	bra.w	.centrehaut		;4
.fincentrage

.centrage2
	move	d6,d4		;coord Toki
	move	d7,d5
	bra.s	.calcy

.nocentre
	move	d0,d4		;coin gauche
	move	d1,d5
	bra.s	.calcy
.centrehaut:
	move	d0,d4		;X=X gauche
	move	d7,d5
	sub	movey,d5
	cmp	d1,d5
	bge.s	.cg1
	move	d1,d5
.cg1
	sub	#hauteur,d3
	cmp	d3,d5
	ble.s	.cg2
	move	d3,d5
.cg2
	bra.s	.calcy

.centredroit
	move	d1,d5		;Y=Y haut
	move	d6,d4
	add	movex,d4
	sub	#largeur,d4
	cmp	d0,d4
	bge.s	.cd1
	move	d0,d4
.cd1
	sub	#largeur,d2
	cmp	d2,d4
	ble.s	.cd2
	move	d2,d4
.cd2
	bra.s	.calcy

.centrebas
	move	d0,d4		;X=X gauche

	move	d7,d5		;Y
	add	movey,d5
	sub	#hauteur,d5
	cmp	d1,d5
	bge.s	.cntrb
	move	d1,d5
.cntrb
	sub	#hauteur,d3

	cmp	d3,d5
	ble.s	.cntrb2
	move	d3,d5
.cntrb2
	bra.s	.calcy

.centregauche
	move	d1,d5			;Y=Y haut
	move	d6,d4			;X
	sub	movex,d4
	cmp	d0,d4
	bge.s	.cgg1
	move	d0,d4
.cgg1
;	sub	#largeur,d2

	cmp	d2,d4
	ble.s	.cgg2
	move	d2,d4
.cgg2

;	sub	d0,d4
;	bpl.s	.m0
;	clr	d4
;.m0	add	d0,d4

.calcy
;
; ici d4=xscroll, d5=yscroll
;

;
; 1) borner le d‚placement d'‚cran
;
	tst	lastxscroll
	bmi.s	.nomajx
	move	d4,d0
	sub	lastxscroll,d0
	addq	#4,d0
	cmp	#8,d0
	blo.s	.nomajx

	sge	d0
	ext	d0
	and	#8,d0
	subq	#4,d0
	add	lastxscroll,d0
	move	d0,d4
.nomajx
	tst	lastyscroll
	bmi.s	.nomajy
	move	d5,d0
	sub	lastyscroll,d0
	addq	#4,d0
	cmp	#8,d0
	blo.s	.nomajy
	sge	d0
	ext	d0
	and	#8,d0
	subq	#4,d0
	add	lastyscroll,d0
	move	d0,d5
.nomajy
;
; 2) borner les valeurs du scroll
;
	cmp	#X_MAP-largeur,d4
	blo.s	.nox
	sge	d4
	ext	d4
	and	#X_MAP-largeur,d4
.nox
	cmp	#Y_MAP-hauteur,d5
	blo.s	.noy
	sge	d5
	ext	d5
	and	#Y_MAP-hauteur,d5
.noy
	move	d4,xscroll
	move	d4,lastxscroll
	move	d5,yscroll
	move	d5,lastyscroll
;
; 3) calcul des coordonn‚es relatives de Toki (par rapport aux
;      coordonn‚es du scrolling)
;
	sub	xscroll,d6
	sub	yscroll,d7
	move	d6,xtoki
	move	d7,ytoki
	rts
lastxscroll:dc.w	-1	;inutiles ??? (xscroll)
lastyscroll:dc.w	-1	;inutile ??? (yscroll)
;
; structure du scrolling :
;
;	type	contient le type du scrolling
;		0=centrage Toki bidon
;		1=centrage … gauche
;		2=centrage en bas
;		3=centrage … droite
;	x0,y0,x1,y1 repr‚sentent les coordonn‚es haut-gauche et bas-droite
;		     du scrolling
;	dans les cas du centrage gauche, la coordonn‚e Xdroite
;	 est la coordonn‚e X maximale
;
DCSCR	MACRO
	DC.W	\1*4,\2,\3,\4,\5
	ENDM
boxes:
	DCSCR	1,0,$2e0,X_MAP-largeur/2,Y_MAP		;1er scroll
	DCSCR	0,$1D0,0,$1D0+largeur,hauteur		;8Šme=‚cran ennemi
	DCSCR	3,$210,$180,X_MAP,$1b0			;3Šme scroll

	DCSCR	1,0,0,$1D0+largeur,hauteur		;7Šme scroll
	DCSCR	2,0,0,largeur,$2E0			;6Šme scroll
	DCSCR	3,0,$230,$210+largeur,$2E0		;5Šme scroll

	DCSCR	4,$210,$180,$210+largeur,$2e0		;4Šme scroll
	DCSCR	2,X_MAP-largeur,$180,X_MAP,Y_MAP	;2Šme scroll


	dc.w	-1			;fin de table
;
; animation d'un ‚cran largeur*hauteur
;
INITSCROLL:
	lea	bitmap,a0
	lea	endbitmap,a1
	move	#(largeur+16)*hauteur/2-1,d1
	moveq	#0,d0
clear_it:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	clear_it
	RTS

MOVESCROLL:
	BSR	CALCPTRSCROLL
	BSR	REFRESHX
	BSR	REFRESHY

	move.l	ecran,a0
	lea	(hauteur-1)*160+largeur/2+24+12*160(a0),a0
	move.l	a0,usp
;
; affichage du bas
;
	move	restey,d0
	sub	#16,d0
	bls.s	.not2

	move.l	ptrhaut,a6		;base ptr=ptrbuf+(hauteur-hauteur)

	move	#hauteur-1,d1
	sub	d0,d1
	asl	#3,d0			;*24
	move	d0,d2
	add	d0,d0
	add	d2,d0

	lea	endscroller(pc),a0
	sub	d0,a0

	move.l	#.retour2,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour2:
	addq	#6,sp
.not2
;
; la partie ci-dessous marche !!!!
;
	move	restey,d0
	cmp	#16,d0
	bhi.s	1$
	move	#hauteur,d0
	bra.s	2$
1$
	move	#hauteur+16,d0
	sub	restey,d0			;nb lignes en bas
2$
	move.l	ptrbuf,a6		;base ptr=ptrbuf+(hauteur-hauteur)

	asl	#3,d0			;*24
	move	d0,d2
	add	d0,d0
	add	d2,d0

	lea	endscroller(pc),a0	;saute le dernier lea
	sub	d0,a0			;(gain=8 cycles !!!)

	move.l	#.retour1,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour1:
	addq	#6,sp
	RTS

ymod:	dc.w	0
xscroll:dc.w	0
yscroll:dc.w	0
vitx:	ds.w	1
vity:	ds.w	1

ptrbuf:	ds.l	1
ptrbuf2:ds.l	1
restey:	ds.w	1
ptrvert1:ds.l	1
ptrvert2:ds.l	1
ptrhaut:ds.l	1
ptrbas:	ds.l	1
;
CALCPTRSCROLL:
	bsr	CALCNEWPTR

	move	restey,d0
	mulu	#(largeur+16)/2,d0
	move.l	a6,ptrhaut		;ptr pour afficheur
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrbuf		;ptr pour afficheur
	RTS
;
; calcul des pointeurs de rafraichissement pour le scroller
;  multidirectionnel !!!
;
; retourne a6=d‚but pointeur bitmap d‚cal‚
;
CALCNEWPTR
	moveq	#$f&-4,d1
	and	xscroll,d1		;d1=d‚calage
	lsr	#2,d1
	mulu	#bitmap1-bitmap0,d1

	moveq	#-16,d0
	and	xscroll,d0
	lsr	#1,d0			;xscroll/16*8

	lea	bitmap,a6
	add.l	d1,a6
	add	d0,a6

	MOVEQ	#0,D0
	move	yscroll,d0
	divu	#hauteur+16,d0
	swap	d0
	move	d0,restey

	moveq	#-16,d7
	and	restey,d7
	mulu	#(largeur+16)/2,d7
	move.l	a6,a0
	add.l	d7,a0
	move.l	a0,ptrbuf2
	lea	(largeur+16)*(hauteur+16)/2(a6),a0
	move.l	a0,ptrbas

adjust1	equ	16
adjust2	equ	0

	move.l	d7,d0
	add.l	#(largeur+16)*(hauteur+adjust1)/2,d0
	cmp.l	#(largeur+16)*(hauteur+16)/2,d0
	blo.s	3$
	sub.l	#(largeur+16)*(hauteur+16)/2,d0
3$
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrvert1

	move.l	d7,d0
	add.l	#(largeur+16)*(hauteur-adjust2)/2,d0
	cmp.l	#(largeur+16)*(hauteur+16)/2,d0
	blo.s	2$
	sub.l	#(largeur+16)*(hauteur+16)/2,d0
2$
	move.l	a6,a0
	add.l	d0,a0
	move.l	a0,ptrvert2
	RTS

REFRESHX:
	moveq	#$f&-4,d1
	and	xscroll,d1		;d1=d‚calage
	lea	coords0,a0
	add	d1,a0

	moveq	#-4,d7
	and	xscroll,d7
	cmp	(a0),d7
	beq	samecoord
	move	d7,d0
	sub	(a0),d7
	move	d0,(a0)
	lsr	#4,d0			;xscroll/16

	moveq	#0,d2
	move	yscroll,d2
	lsr	#4,d2
	mulu	#largeur_map,d2

	lea	blocks,a4
	moveq	#0,d6
	move	(a4),d6			;32K de map !!!
	add.l	d6,a4
	addq	#2,a4
	add	d0,a4			;pointeur map
	add.l	d2,a4

	move.l	ptrbas,d6
	move.l	ptrbuf2,a6

	tst	d7
	bmi.s	.left2
	lea	largeur/16(a4),a4
	lea	largeur/2(a6),a6
	add.l	#largeur/2,d6
.left2	tst	d1			;shift=0 ?
	beq.s	.left
	subq	#8,a6
	subq.l	#8,d6
.left
;	moveq	#$f&-4,d1
;	and	xscroll,d1
	lsr	#1,d1

	lea	shifter(pc),a2
	add	(a2,d1.w),a2

shifte	macro
	lea	.\@(pc),a3
	jmp	(a2)
.\@
	cmp.l	d6,a6
	blo.s	\@1
	lea	-(largeur+16)*(hauteur+16)/2(a6),a6
\@1
	endm

	move.l	#blocks+2,d7

x	set	0
	rept	(hauteur+16)/16
	MOVEQ	#0,D0
	MOVE.B	x(A4),D0
	ASL	#7,D0

	move.l	d7,a5
	ADD	D0,A5		;a5=source bitmap
;
; d5-d7/a2-a4 non utilis‚s dans shift.bin
;
	shifte
x	set	x+largeur_map
	endr
samecoord:
	rts

local_y:dc.w	0
REFRESHY:
	clr	local_y
	moveq	#-16,d7
	and	yscroll,d7
.reref
	moveq	#$f&-4,d1
	and	xscroll,d1		;d1=d‚calage
	lea	coords0+2,a0
	add	d1,a0

	cmp	(a0),d7
	bne.s	.diff
	addq	#4,xscroll		;rafraichissement next scroll
	addq	#4,local_y
	cmp	#4*4,local_y
	bne.s	.reref
.ret	move	local_y,d0
	sub	d0,xscroll
	rts
.diff
	move	d7,d0
	sub	(a0),d7
	move	d0,(a0)
	move	xscroll,d0	;correction bug scrolling diagonal !!!!
	and	#-4,d0		;28/03/90
	cmp	-2(a0),d0
	beq.s	.goodx
	sub	#16,local_y
	sub	#16,xscroll
	sub	#16,d0
	cmp	-2(a0),d0
	beq.s	.goodx
	move	d0,-2(a0)
	add	#16,xscroll
	add	#16,local_y
	ifeq	DEBUG
	move	#$8000,d0
.flash	move	d0,$ffff8240.w
	dbra	d0,.flash
	endc
.goodx
	tst	local_y
	beq.s	.shift0
	move	d1,-(sp)
	move	d7,-(sp)

	bsr	CALCNEWPTR

	move	(sp)+,d7
	move	(sp)+,d1
.shift0
	moveq	#0,d2
	move	yscroll,d2
	lsr	#4,d2
	mulu	#largeur_map,d2

	moveq	#0,d0
	move	xscroll,d0
	lsr	#4,d0			;xscroll/16

	lea	blocks,a4
	moveq	#0,d6
	move	(a4),d6
	add.l	d6,a4
	addq	#2,a4
	add	d0,a4			;pointeur map
	add.l	d2,a4

	move.l	ptrvert1,a6		;pointeur buffer
	tst	d7
	bmi.s	.left
	lea	(hauteur*256)/16(a4),a4
	move.l	ptrvert2,a6
.left
	tst	d1
	beq.s	.up
	subq	#8,a6
.up
;	moveq	#$f&-4,d1
;	and	xscroll,d1
	lsr	#1,d1

	lea	shifter(pc),a2
	add	(a2,d1.w),a2

	move.l	#blocks+2,d7

shifte2	macro
	lea	.\@(pc),a3
	jmp	(a2)
.\@
	endm

	rept	(largeur+16)/16
	MOVEQ	#0,D0
	MOVE.B	(A4)+,D0
	ASL	#7,D0
	move.l	d7,a5
	ADD	D0,A5			;a5=source bitmap
	shifte2
	lea	-(largeur+16)*16/2+8(a6),a6
	endr

	move	local_y,d0
	sub	d0,xscroll
	rts
plante:	dc.l	$4a780001		;tst 1.w

fastscroller
;
; la routine suivante fait 24 octets par ligne
;
x	set	hauteur*(largeur+16)/2
	rept	hauteur
x	set	x-(largeur+16)/2
	movem.l	x+56(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	movem.l	x(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	lea	-160+largeur/2(a7),a7
	endr
	illegal
endscroller

flippe_toki:
	lea	toki+2,a0
	move	#1,d0
	SUBQ	#1,D0
	asl	#3,d0
	add	d0,a0
	moveq	#0,d6
	move.b	(a0)+,d6	;taille en X
	moveq	#0,d7
	move.b	(a0)+,d7	;taille en Y
	moveq	#0,d4
	move.b	(a0)+,d4
	moveq	#0,d5
	move.b	(a0)+,d5
	move.l	(a0),a6

	lea	flip_toki,a5
	bsr	flippe_sprite
	rts
;
; retournement du sprite
;
; entr‚e :
;	a6=d‚but du sprite … flipper
;	a5=d‚but adresse … remplir
;	d6=taille en X
;	d7=taille en Y
;
flippe_sprite:
;
; 1) pr‚calcule la table de flipping (si ce n'est d‚j… fait...)
;
	lea	flipping(pc),a0
	tst.b	255(a0)
	bne.s	.ok
	moveq	#0,d0
.byte
	moveq	#1,d1
	move	d0,d2
.reverse
	lsr.b	#1,d2
	addx.b	d1,d1
	bcc.s	.reverse
	move.b	d1,(a0)+
	addq.b	#1,d0
	bne.s	.byte
.ok
;
; 2) calcule la nouvelle taille
;
	add	#15,d6
	and	#-16,d6
	move.b	d6,(a5)+	;nouvelle taille X
	move.b	d7,(a5)+	;nouvelle taille Y
	move.b	d4,(a5)+	;nouveau d‚calage en X
	move.b	d5,(a5)+	;nouveau d‚calage en Y
;
; 3) retourne le sprite
;
	moveq	#0,d0
	lea	flipping(pc),a0
	lsr	#1,d6
	move	d6,d4
	lsr	#3,d4		;d4=nb plans … flipper
	subq	#1,d7

	mulu	#(.last-.plane)/5,d4
	lea	.last(pc),a4
	sub	d4,a4
	add	d6,a5
	add	d6,d6
	move	d6,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
.col
	jmp	(a4)
;
; il faut mettre le flipping pour les sprites 3 plans
;
.plane
	rept	80/16
	move.b	(a6)+,d0
	move.b	(a6)+,d1
	move.b	(a6)+,d2
	move.b	(a6)+,d3
	move.b	(a6)+,d4
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.b	(a0,d6.w),-(a5)		;7
	move.b	(a6)+,d6
	move.b	(a0,d6.w),-(a5)		;6
	move.b	(a0,d4.w),-(a5)		;5
	move.b	(a0,d5.w),-(a5)		;4
	move.b	(a0,d2.w),-(a5)		;3
	move.b	(a0,d3.w),-(a5)		;2
	move.b	(a0,d0.w),-(a5)		;1
	move.b	(a0,d1.w),-(a5)		;0
	endr
.last
	add	a1,a5

	dbra	d7,.col
	rts
flipping:ds.b	256

palette:
	IFEQ	PLANS-4
	INCLUDE	INCLUDES\PAL4.S
	ELSEIF
	include	INCLUDES\palette.s
	ENDC

	ifeq	DEBUG
debugger:incbin	INCLUDES\debugger.bin
fonte:	incbin	INCLUDES\fonte.img
	endc
shifter:incbin	INCLUDES\shift3.bin
newsprite
	ifeq	PLANS-4
	incbin	INCLUDES\sprite18.bin
	elseif
	INCBIN	INCLUDES\3PLANS2.BIN
	endc
mul160
x	set	12*160+24
	rept	hauteur
	dc.w	x
x	set	x+160
	endr

toki
	ifeq	PLANS-4
	INCBIN	INCLUDES\MARCHE.DAT
	elseif
	incbin	INCLUDES\tokispr1.img
	endc

blocks:	incbin	INCLUDES\MAP4.IMG
musique:
	ifeq	typemus
	incbin	INCLUDES\MUSIQUE.bin
	endc
	ifeq	typemus-1
	incbin	INCLUDES\MADMUS.BIN
	endc
	ifeq	typemus-2
	incbin	INCLUDES\MAD2.IMG
	endc
	ifeq	typemus-3
	incbin	INCLUDES\SLAM1.IMG
	endc

coords0	dc.w	$8000,$8000	;lastx,lasty bitmap0
	dc.w	$8000,$8000	;bitmap1
	dc.w	$8000,$8000	;bitmap2
	dc.w	$8000,$8000	;bitmap3

	section	bss
	ds.b	16
bitmap:
bitmap0:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=0
	ds.b	16
bitmap1:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=4
	ds.b	16
bitmap2:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=8
	ds.b	16
bitmap3:ds.b	(largeur+16)*(hauteur+16)/2		;d‚calage=12
	ds.b	16
;	ds.b	(largeur+16)*(hauteur+16)/2*4		;d‚calage=12
endbitmap:
	ds.b	X_MAP/2
flip_toki:
