**********************************
*         INTRO EUROSWAP         *
*                                *
**********************************
*        BY: DYNO OF EXO7        *
**********************************
***** NOM DES JEUX *****
; utiliser le prog en GFA pour creer le nouveau fichier binaire
NOMBRE	=	3		; nombre de jeux ds le titre
DECAL	=	12		; nombre de lignes de decalage par
				; rapport au logo Euroswap
***** NUMERO DE CD *****
CD1	=	9		; Centaines
CD2	=	4		; Dizaines
CD3	=	5		; Unites
***** CHANGEMENT DE L' EFFET DANS LE LOGO EUROSWAP *****
DELAI	=	2		; pas trop sinon ca fait (tres) saccade
DUREE	=	72		; avant la reapparition de l' effet
; voir au label 'Rastercol:' pour changer la couleur des rasters
***** NUMERO DE LA MUSIQUE *****
MUSIC	=	5 
***** POSITION DU SCROLL SUR L' ECRAN *****
HAUTEUR		=	240
	opt x-,o-
super:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.b	#$12,$fffffc02.w
	dc.w	$a00a
*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.b	$ffff820a.w,oldfrq
	move.l	#ecran_dist,d0
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log3			; Log=adresse nouvel ecran
**********************************
* INSTALLE LES NOUVELLES HBL-VBL *
**********************************
	bsr	initmfp
	moveq.w	#MUSIC,d0
	jsr	zik
	move.l	#vbl,$70.w
	
	;
	; ...
	;
	bsr	vsync
	move.b	#2,$ffff820a.w
	move.b	log3+1,$ffff8201.w
	move.b	log3+2,$ffff8203.w
	bsr	vsync
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	log3,a1
	lea	present+34+160*32,a0
	move.l	#7999-(160*32)/4,d0
affipres:
	move.l	(a0)+,(a1)+
	dbra	d0,affipres

	lea	fondu,a0
	move.w	#15,d0
fonduon:
	move.l	d0,-(sp)
	rept	3
	bsr	vsync
	endr
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	(sp)+,d0
	dbra	d0,fonduon

	move.w	#49,d1
w2:	move.w	#-1,d0
w:	dbra	d0,w
	dbra	d1,w2
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	fondu2,a0
	move.w	#15,d0
fonduoff:
	move.l	d0,-(sp)
	rept	3
	bsr	vsync
	endr
	lea	-32(a0),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	(sp)+,d0
	dbra	d0,fonduoff

	move.l	log3,a0
	move.w	#230*274/4-1,d0
reclr:	clr.l	(a0)+
	dbra	d0,reclr

	bsr	predecalage_fonte_trois_plans
	bsr	generation2
	bsr	initialise_texte_et_courbe

	lea	table,a0
	bsr	recalcule_table
	lea	table2,a0
	bsr	recalcule_table
	lea	table3,a0
	bsr	recalcule_table
	lea	table4,a0
	bsr	recalcule_table
	
	****************************
	** affiche logo euro swap **
	lea	euroswap+32,a0
	move.l	log3,a1
	lea	230*2-68+230*4+8*3(a1),a1
	move.w	#23,d0
affeuro:	
	move.w	#39,d1
affligne:
	move.l	(a0)+,(a1)+
	dbra	d1,affligne
	lea	230-160(a1),a1
	dbra	d0,affeuro

	****************
	** affiche CD **
	lea	cd,a0
	move.l	log3,a1
	lea	230*2-68+230*(4+25)+8*20(a1),a1
	move.w	#15,d0
affcd:	
	move.w	#5,d1
affligne2:
	move.l	(a0)+,(a1)+
	dbra	d1,affligne2
	lea	230-6*4(a1),a1
	dbra	d0,affcd

	***********************
	** affiche  no de cd **
	lea	font3pl+(CD1+16)*128,a0
	lea	font3pl+(CD2+16)*128,a1
	lea	font3pl+(CD3+16)*128,a2
	move.l	log3,a3
	lea	230*2-68+230*(4+25+14)+8*20(a3),a3
	rept	16
	move.l	(a0)+,(a3)
	move.l	(a0)+,4(a3)
	move.l	(a1)+,8(a3)
	move.l	(a1)+,12(a3)
	move.l	(a2)+,16(a3)
	move.l	(a2)+,20(a3)
	lea	230(a3),a3
	endr

	*******************
	** affiche titre **
	lea	titre,a0
	move.l	log3,a1
	lea	DECAL*230+230*2+-68+230*(4+25)+8*3(a1),a1
	move.w	#NOMBRE*7-1,d0
afftitre:	
	move.w	#32-1,d1
afflig:
	move.l	(a0)+,(a1)+
	dbra	d1,afflig
	lea	230-32*4(a1),a1
	dbra	d0,afftitre

	bsr	affiche_texte

AVDEMONSTRATION3:
	* setscreen *
	move.b	log3+1,$ffff8201.w
	move.b	log3+2,$ffff8203.w
*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
HAUTEURTXT	=	16*5*230


; !!! TO REMOVE
St	set	0
	rept	8
	move.l	euroswap+St,$ffff8240+St.w
St	set	St+4
	endr


	clr.l	compteur
	clr.w	comptable
	move.l	#table,adrtable
	move.l	#table,getadrtable
	clr.w	rastcompt
	move.l	#HAUTEURTXT,adrecran
	move.l	#-24*4,compt_vbl
	move.l	#-230*16,compt_vbl2
	move.l	#bigtxt,adrtext

DEMONSTRATION3:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	
	move.w	#$700,$ffff8240.w
	jsr	zik+8
	
	add.l	#24*4,compt_vbl
	add.l	#230*16,compt_vbl2	
	cmpi.l	#24*4*9,compt_vbl
	bne.s	noloopvbl
	clr.l	compt_vbl
	clr.l	compt_vbl2
noloopvbl:

	clr.l	compt_hbl

	addq.w	#1,rastcompt
	cmpi.w	#DELAI,rastcompt
	bne.s	pasrecop
	clr.w	rastcompt
	lea	rastercolfin-0,a1
	lea	rastercolfin-2,a0
	move.w	(a0),d1
	move.w	#DUREE-2,d0
recop:	move.w	-(a0),-(a1)
	dbra	d0,recop
	move.w	d1,(a0)
pasrecop:	

	move.l	adrtable,adrtable2
	addq.l	#4,adrtable
	addq.w	#1,comptable
	cmpi.w	#1+48*2+24*9,comptable
	bne	notloop
	move.l	getadrtable,adrtable
	move.l	getadrtable,adrtable2
	clr.w	comptable
	
	addq.l	#1,compteur
	cmpi.l	#3,compteur
	bne	notloop
	clr.l	compteur
	add.l	#24*4*9,adrtext
	cmpi.l	#finbigtxt,adrtext
	bne.s	nhy
	move.l	#bigtxt,adrtext
nhy:

	cmp.l	#table,getadrtable
	bne.s	notab1
	move.l	#table2,getadrtable
	bra.s	notab4
notab1:
	cmp.l	#table2,getadrtable
	bne.s	notab2
	move.l	#table3,getadrtable
	bra.s	notab4
notab2:
	cmp.l	#table3,getadrtable
	bne.s	notab3
	move.l	#table4,getadrtable
	bra.s	notab4
notab3:
	cmp.l	#table4,getadrtable
	bne.s	notab4
	move.l	#table,getadrtable
notab4:
	move.l	getadrtable,adrtable
	move.l	getadrtable,adrtable2
notloop:
	
	move.l	#sprit1pl,adrsprit1pl
	move.l	compteur,d0
	mulu	#49*12*2,d0
	add.l	d0,adrsprit1pl
	
	bsr	calcule_adresses1
	
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
		
	clr.w	$ffff8240.w
top:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	dcb.w	85,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	17,$4e71
	move.b	#2,$ffff820a.w

*****************
* STABILISATION	*
*****************
	moveq	#0,d6
wsync:	move.b	$ffff8209.w,d6
	beq.s	wsync
	not.w	d6
	lsr.w	d6,d6
	dcb.w	74,$4e71
	move.w	a6,(a6)
	nop
	move.b	d0,(a6)
	dcb.w	89-5,$4e71

	jsr	buffergen2

********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
finoverscan:

	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq.s	findemo
	bra	DEMONSTRATION3

high_border:	dc.w	0
***********************************
* RESTAURE LES ANCIENS PARAMETRES *
***********************************
findemo:
	moveq.w	#0,d0
	jsr	zik
	movem.l	oldcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr.s	vsync
	move.b	oldrez,$ffff8260.w
	bsr.s	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	move.b	oldfrq,$ffff820a.w
	bsr.s	vsync
	bsr	finmfp
	
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	clr.w	(sp)
	trap	#1
	
******************
* ATTENDS LA VBL *
******************
vsync:	move.l	d0,-(sp)
	move.l	v466,d0
vl:	cmp.l	v466,d0
	beq.s	vl
	move.l	(sp)+,d0
	rts
v466:	dc.l	0

**********************
* ROUTINES INTEGREES *
**********************

overgd:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	dcb.w	89,$4e71
	rts

copy3plans0:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	move.l	adrtext,a2		; [20=>5]
	add.l	compt_vbl,a2	; [24=>6]
	dcb.w	89-5-6,$4e71
	rts

copy3plans1:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	move.l	adrecran,a1	; [20=>5]
	move.l	(a2)+,d0	; [12=>3]
	dcb.w	13-8,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	add.l	compt_vbl2,a1	; [24=>6]
	dcb.w	12-6,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	lea	troisplans2,a0	; [12=>3]
	add.l	d0,a0		; [8 =>2]
	add.l	compt_hbl,a1	; [24=>6]
	add.l	log3,a1		; [24=>6]
	add.l	#230*2-68+8,a1	; [16=>4]
	rept	5
	addq.l	#6,a0		; [8 =>2]
	move.w	(a0)+,(a1)+		; [20=>5]
	move.l	(a0)+,(a1)+		; [12=>3]
	lea	230-6(a1),a1	; [8 =>2]
	endr
	dcb.w	89-81,$4e71
	rts

copy3plans2:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	rept	6
	addq.l	#6,a0		; [8 =>2]
	move.w	(a0)+,(a1)+		; [20=>5]
	move.l	(a0)+,(a1)+		; [12=>3]
	lea	230-6(a1),a1	; [8 =>2]
	endr
	addq.l	#8,compt_hbl	; [28=>7]
	dcb.w	89-79,$4e71
	rts

adrtext:	dc.l	0
adr3plans:	dc.l	0
adrecran:	dc.l	0
compt_hbl:	dc.l	0
compt_vbl:	dc.l	0
compt_vbl2:	dc.l	0

raster:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	move.w	(a0)+,$ffff8242.w	; [16=>4]
	dcb.w	89-4,$4e71
	rts

rastercol:
	dc.w	$100,$200,$310,$420,$531,$642,$753
	dc.w	$642,$531,$420,$310,$200,$100
	dcb.w	DUREE-13,0
rastercolfin:

clear1:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	move.l	log3,a0			; [20=>5]
	add.l	#230*2-68+230*HAUTEUR+8,a0	; [16=>4]
	dcb.w	13-9,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	move.w	#$304,$ffff8242.w	; [16=>4]
	dcb.w	12-4,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	movem.l	zero,d3-d7/a1-a4	; [88=>22]
	movem.l	d3-d6,(a0)		; [44=>11]
	lea	4*4(a0),a0		; [8 =>2]
	dcb.w	89-35,$4e71
	rts

clear2:	
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	movem.l	d3-d6,(a0)		; [40=>10]
	dcb.w	13-10,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	movem.l	d3-d6,4*4(a0)	; [44=>11]
	dcb.w	12-11,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	movem.l	d3-d7/a1-a4,8*4(a0)	; [84=>21]
	movem.l	d3-d7/a1-a4,17*4(a0)	; [84=>21]
	movem.l	d3-d7/a1-a4,26*4(a0)	; [84=>21]
	movem.l	d3-d7/a1-a4,35*4(a0)	; [84=>21]
	move.w	d3,44*4(a0)		; [12=> 3]
	lea	44*4+2(a0),a0	; [8 => 2]
	;dcb.w	89-89,$4e71
	rts

bas1:
	move.b	D0,(A5)	; [8]
	move.w	A5,(A5)	; [8]
	dcb.w	10,$4e71
	move.w	D0,(A5)	; [8]
	nop
	move.w	A6,(A6)	; [8]
	nop		; [4]
	move.b	D0,(A6)	; [8]
	dcb.w	11,$4e71
	move.w	A6,(A6)	; [8]
	move.w	A5,(A5)	; [8]
	move.b	D0,(A6)	; [8]
	dcb.w	89,$4e71
	rts

bas2:
	move.b	D0,(A5)	; [8]
	move.w	A5,(A5)	; [8]
	dcb.w	13,$4e71
	move.w	A6,(A6)	; [8]
	nop		; [4]
	move.b	D0,(A6)	; [8]
	dcb.w	12,$4e71
	move.w	A6,(A6)
	nop
	move.b	D0,(A6)
	dcb.w	89,$4e71
	rts

ligne1:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	move.l	log3,a0			; [20=>5]
	add.l	#230*2-68+230*HAUTEUR-14,a0	; [16=>4]
	lea	position,a2			; [12=>3]
	lea	letinit,a3			; [12=>3]
	dcb.w	89-15,$4e71
	rts

ligne2:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	lea	14(a0),a0
	lea	texte2,a4
	move.w	(a2)+,d6
	ext.l	d6
	move.w	(a3)+,d7
	lea	(a4,d7.w),a4
	lea	troisplans2,a1
	add.l	(a4)+,a1
	lea	6(a1,d6.w),a1
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	subq.l	#6,a0
	lea	troisplans2,a1
	add.l	d6,a1
	move.l	a1,d4
	dcb.w	89-41,$4e71	
	rts

ligne3:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	dcb.w	13-8,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	dcb.w	12-10,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	
	rept	2
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	endr
	
	dcb.w	89-87,$4e71
	rts

setcolorscroll:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
St	set	0
	rept	8
	move.l	pal_3plansscr+St,$ffff8240+St.w
St	set	St+4
	endr
	dcb.w	89-64,$4e71
	rts

setcolormid:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
St	set	0
	rept	8
	move.l	pal_3plansmid+St,$ffff8240+St.w
St	set	St+4
	endr
	dcb.w	89-64,$4e71
	rts

setcolortop:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
St	set	0
	rept	8
	move.l	euroswap+St,$ffff8240+St.w
St	set	St+4
	endr
	lea	rastercol,a0
	dcb.w	89-67,$4e71
	rts
	
************************
* ROUTINES HBLs ET VBL *
************************
tstht:	subq.w	#1,high_border
	rte
vbl:	move.w	#33,high_border
	move.l	#tstht,$68.w
	addq.l	#1,v466
	rte
	
****************************************
* GENERE LE CODE INTEGRE DE L'OVERSCAN *
****************************************
generation2:
	lea	routines2,a0
	lea	buffergen2,a1
	move.w	#271,d0
lg:	move.l	(a0)+,a2
rep:	move.w	(a2)+,(a1)+
	cmpi.w	#$4e75,(a2)
	bne.s	rep
	dbra	d0,lg
	move.w	#$4e75,(a1)+	; RTS
	rts

***************************
* SAUVE LES REGISTRES MFP *
***************************
initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	moveq.w	#16,d0
savemfp:move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+32
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,oldvec+64

	bclr	#3,$fffffa17.w
	clr.b	$fffffa19.w		; Arret timer A
	move.b	#0,$fffffa1b.w		;  ...   ...  B
	move.b	#1,$fffffa07.w		; Timer B seul
	move.b	#1,$fffffa13.w		; ..
	clr.b	$fffffa09.w		; Pas de timer C-D
	clr.b	$fffffa15.w		; ..
	rte
	
******************************
* RESTAURE LES REGISTRES MFP *
******************************
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	moveq	#16,d0
restmfp:move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+32,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+64,d0-d7
	movem.l	d0-d7,$58.w
	rte

***********************************
* PREDECALAGE DE LA FONTE UN PLAN *
***********************************
predecalage_fonte_trois_plans:
	lea	troisplans2,a1
	lea	troisplans,a6
	move.w	#20*3-1,d0
tsleschar:
	moveq	#15,d1
les8decal:
	* Recopie *
	move.l	a6,a0
	move.w	#10,d2
mots:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,mots
	* Scrolle 
	move.l	a6,a0
	move.w	#10,d2
scro:	moveq	#0,d3
	roxl	d3
	roxl	6(a0)
	roxl	(a0)
	moveq	#0,d3
	roxl	d3
	roxl	8(a0)
	roxl	2(a0)
	moveq	#0,d3
	roxl	d3
	roxl	10(a0)
	roxl	4(a0)
	lea	12(a0),a0
	dbra	d2,scro

	dbra	d1,les8decal
	lea	132(a6),a6
	dbra	d0,tsleschar
	rts

calcule_adresses1:
	move.l	pt_courbe2,a0
	lea	position,a1
	lea	letinit,a2
	moveq	#10,d1
calcing:
	move.w	(a0)+,d0
	add.w	d0,(a1)
	cmpi.w	#16*132,(a1)
	blt.s	sdf
	sub.w	#16*132,(a1)
	addq.w	#4,(a2)
	move.w	(a2),d0
	sub.w	longueur_texte2,d0
	bne.s	sdf
	move.w	#0,(a2)
sdf:
	cmpi.w	#0,(a1)
	bge.s	sdg
	add.w	#16*132,(a1)
	subq.w	#4,(a2)
	cmpi.w	#-4,(a2)
	bne.s	sdg
	move.w	longueur_texte2,(a2)
	subq.w	#4,(a2)
sdg:
	addq.l	#2,a1
	addq.l	#2,a2
	dbra	d1,calcing
	
	addq.l	#2,pt_courbe2		* 2*11
	cmpi.l	#fincourbe2,pt_courbe2
	bne.s	pfc
	move.l	#courbe2,pt_courbe2
pfc:	rts

***************************************
* RECOPIE DEBUT TEXTE+COURBE A LA FIN *
***************************************
initialise_texte_et_courbe:
	move.l	#fintexte2,d0		*
	sub.l	#texte2,d0
	move.w	d0,longueur_texte2
	lea	texte2,a0		*
	lea	fintexte2,a1
	moveq	#29,d0
rec:	move.l	(a0)+,(a1)+
	dbra	d0,rec
	lea	courbe2,a0		*
	lea	fincourbe2,a1
	moveq	#10,d0
rec2:	move.w	(a0)+,(a1)+
	dbra	d0,rec2
	rts

;**********************
;*** TEXTE STATIQUE ***
;**********************
transparent:
	move.b	d0,(a5)	; [8]
	move.w	a5,(a5)	; [8]
	dcb.w	13,$4e71
	move.w	a6,(a6)	; [8]
	nop		; [4]
	move.b	d0,(a6)	; [8]
	dcb.w	12,$4e71
	move.w	a6,(a6)	; [8]
	nop
	move.b	d0,(a6)	; [8]
	move.l	adrtable2,a2
	move.l	(a2)+,a4
	move.l	a2,adrtable2
	move.l	adrsprit1pl,a3
	move.w	(a3)+,(a4)
d	set	230
	rept	11
	move.w	(a3)+,d(a4)
d	set	d+230
	endr
	move.l	a3,adrsprit1pl
	dcb.w	89-70,$4e71
	rts

affiche_texte:
	lea	avbigtxt,a6
	move.w	#0,d6
ligne:	move.w	#0,d7
colonne:
	move.l	log3,a0
	adda.l	#230*2-68,a0
	add.l	#HAUTEURTXT+8,a0
	clr.l	d1
	move.w	d7,d1
	lsl.l	#3,d1
	lea	(a0,d1.l),a0
	clr.l	d1
	move.w	d6,d1
	mulu	#230*16,d1
	lea	(a0,d1.l),a0
	move.l	(a6)+,d0
	lea	troisplans2,a1
	lea	(a1,d0.l),a1
	rept	11
	addq.l	#6,a1
	move.l	(a1)+,(a0)
	move.w	(a1)+,4(a0)
	move.w	#-1,6(a0)
	lea	230(a0),a0
	endr

	addq.w	#1,d7
	cmpi.w	#24,d7
	bne	colonne	
	addq.w	#1,d6
	cmpi.w	#9,d6
	bne	ligne	
	rts

recalcule_table:
Ripit:
	move.w	(a0),d0
	move.w	2(a0),d1
	cmpi.w	#-1,d0
	beq.s	Fripit
	cmpi.w	#-1,d1
	beq.s	Fripit
	mulu	#8,d0
	mulu	#230*16,d1
	add.l	d0,d1
	add.l	log3,d1
	add.l	#230*2-68+HAUTEURTXT+8,d1
	addq.l	#6,d1
	move.l	d1,(a0)+
	bra.s	Ripit
Fripit:	rts

	************
	SECTION DATA
	************
zero:	dcb.l	16,0

position:	dc.w	0,144,288,432,576,720,864,1008,1152,1296,1440
letinit:	dcb.w	11,4*0
A=2

pt_courbe2:	dc.l	avcourbe2
avcourbe2:	dcb.w	12,132*2
courbe2:	incbin	data\crb4712.dat	
		dcb.w	0
fincourbe2:	dcb.w	11,0

longueur_texte2:	dc.w	0
texte2:			dcb.l	30,0
			incbin	data\txtdist1.dat
fintexte2:		dcb.l	30,0

routines2:
	dc.l	overgd,overgd,overgd	; 3
	dc.l	setcolortop		; +1=4
	rept	24		; +24=28
	dc.l	raster
	endr
    
	dc.l	clear1		; +1=29
	rept	14		; +14=43
	dc.l	clear2
	endr
	dc.l	ligne1		; +1=44
	rept	3		; +30=74
	dc.l	ligne2
	dc.l	ligne3,ligne3,ligne3
	dc.l	ligne3,ligne3,ligne3
	dc.l	ligne3,ligne3,ligne3
	endr
	dc.l	ligne2		; +1=75
	dc.l	ligne3,ligne3	; +2=77
	dc.l	setcolormid		; +1=78
	dc.l	ligne3,ligne3,ligne3	; +3=81
	dc.l	ligne3,ligne3,ligne3	; +3=84
	dc.l	ligne3		; +1=85
	rept	7		; +70=155
	dc.l	ligne2
	dc.l	ligne3,ligne3,ligne3
	dc.l	ligne3,ligne3,ligne3
	dc.l	ligne3,ligne3,ligne3
	endr
	rept	19		; +19=174
	dc.l	overgd
	endr 
	dc.l	copy3plans0		; +1=175
	rept	24		; +48=223
	dc.l	copy3plans1,copy3plans2
	endr
	dc.l	transparent,transparent	; +2=225
	dc.l	transparent,transparent	; +2=227

	dc.l	bas1
	dc.l	bas2
	
	dc.l	setcolorscroll
	rept	45
	dc.l	transparent
	endr
	dc.l	overgd,overgd

troisplans:	incbin	data\fontor.dat
pal_3plansmid:	dc.w	$000,$222,$321,$432,$543,$654,$765,$777
		dcb.w	8,$0
pal_3plansscr:	dc.w	$000,$222,$312,$423,$534,$645,$756,$777
		dcb.w	8,$0

euroswap:	incbin	data\euroswap.dat
cd:		incbin	data\cd.dat
font3pl:	incbin	data\font3pl.dat
;titre:		incbin	data\titre.dat
titre:		dcb.w   1344,$0

adrtable:	dc.l	table
adrtable2:	dc.l	table
getadrtable:	dc.l	table

	even
table:	incbin	data\table1
table2:	incbin	data\table2
table3:	incbin	data\table3
table4:	incbin	data\table4

avbigtxt:	dcb.l	24*9,0
bigtxt:		incbin	data\bigtxt.dat
finbigtxt:

adrsprit1pl:	dc.l	0
sprit1pl:	incbin	data\sprit1pl.dat	; Effet d' apparition
sprit3pl:	dcb.b	1176,0			; Transparent
sprit2pl:	incbin	data\sprit2pl.dat	; Effet d' effacement

zik:	incbin	data\exorip.mus
present:	incbin	data\present.pi1
palnoire:	dcb.w	16,0

fondu:
	dcb.w	16,$000
	dcb.w	16,$111
	dcb.w	16,$222
	dcb.w	16,$333
	dcb.w	16,$444
	dcb.w	16,$555
	dcb.w	16,$666
	dcb.w	16,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$666,$767,$667,$667,$667,$667,$667,$677,$677,$677,$677,$677,$766,$766,$766,$766
	dc.w	$555,$756,$557,$557,$557,$557,$557,$567,$577,$577,$577,$577,$755,$755,$755,$755
	dc.w	$444,$745,$446,$447,$447,$447,$447,$457,$467,$477,$477,$477,$644,$744,$744,$744
	dc.w	$333,$634,$335,$336,$337,$337,$337,$347,$357,$367,$377,$377,$533,$633,$733,$733
	dc.w	$222,$523,$224,$225,$226,$227,$227,$237,$247,$257,$267,$277,$422,$522,$622,$722
	dc.w	$111,$412,$113,$114,$115,$116,$117,$127,$137,$147,$157,$167,$311,$411,$511,$611
	dc.w	$000,$301,$002,$003,$004,$005,$006,$017,$027,$037,$047,$057,$200,$300,$400,$500
fondu2:
	***********
	SECTION BSS
	***********
oldecr:	ds.l	1
oldrez:	ds.w	1
oldfrq:	ds.w	1
oldmfp:	ds.b	24
oldvec:	ds.l	24
oldcol:	ds.w	16
log3:		ds.l	1
rastcompt:	ds.w	1
compteur:	ds.l	1
comptable:	ds.w	1
troisplans2:	ds.b	7920*16
buffergen2:	ds.b	80000
ecran_dist:	ds.b	63020+256