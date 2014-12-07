NB_SINUS	=	274*2
NB_PAL	=	19

	trap	#0
**********************************
*    ROUTINE OVERSCAN 460*274    *
**********************************
*        BY: DYNO OF EXO7        *
**********************************
	opt o+

super:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.l	#ecran,d0
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log			; Log=adresse nouvel ecran
	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w

**********************************
* INSTALLE LES NOUVELLES HBL-VBL *
**********************************
	bsr	initmfp
	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

	bsr	affiche_lignes_verticales	
	bsr	precalcule_jsr
	bsr	adresse_1_ere_lettre	
	bsr	remplace_overgd_par_bas
*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
DEMONSTRATION:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	
	
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	scrolle
	bsr	change_jsr	


	* DONNEES OVERSCAN *
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
	
	* COULEURS A AFFICHER A LA PROCHAINE LIGNE *
	lea	palnoire,a4
	movem.l	(a4)+,d3/d4/d5/d6/d7/a0/a1/a2
	move.l	pt_buffercol,a4
	
top:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d0
wait:	dbra	d0,wait
	clr.b	$ffff820a.w
	dcb.w	16,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	24,$4e71

*****************
* STABILISATION	*
*****************
	move.b	$ffff8209.w,d0
	ext.w	d0
	neg.w	d0
	lsr.w	d0,d0
	moveq	#0,d0
	dcb.w	35-1-5,$4e71

adrsaut:
	jsr	bufferjsr
	
	clr.w	$ffff8240.w
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq.s	findemo
	bra	DEMONSTRATION

**********************
* COMPTEUR DE LIGNES *
**********************	
high_border:	dc.w	0

***********************************
* RESTAURE LES ANCIENS PARAMETRES *
***********************************
findemo:
	movem.l	oldcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	vsync
	move.b	oldrez,$ffff8260.w
	bsr	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	bsr	vsync
	bsr	finmfp
	clr.w	(sp)
	trap	#1

*****************************************************************
* SCROLLE LE BUFFER DES COULEURS ET AFFICHE LES NVELLES LETTRES *
*****************************************************************
scrolle:
	add.l	#16*2,pt_buffercol
	cmpi.l	#buffercol+275*16*2,pt_buffercol
	bne.s	nodeb
	move.l	#buffercol,pt_buffercol
nodeb:	

	* TEST SI NOUVELLE LETTRE *
	cmpi.w	#16,pt_lettre
	bne.s	afflettre
	* NOUVELLE LETTRE *
	clr.w	pt_lettre
	move.l	pt_texte,a0
	move.w	(a0),d0
	lea	fonte,a0
	lea	(a0,d0.w),a0
	move.l	a0,adr_lettre

	add.w	#32,nb_palette
	cmpi.w	#32*NB_PAL,nb_palette
	bne.s	pasderniere
	move.w	#0,nb_palette
pasderniere:
	addq.l	#2,pt_texte
	cmpi.l	#fintexte,pt_texte
	bne.s	nofintxt2
	move.l	#texte,pt_texte
nofintxt2:		
afflettre:

	* TESTE SI ON AFFICHE UN PETIT ESPACE ENTRE 2 LETTRES *
	cmpi.w	#15,pt_lettre
	beq.s	espace
	* PAS D'ESPACE *
	move.l	adr_lettre,a0
	move.w	pt_lettre,d0
	lsl.w	#3,d0
	lea	(a0,d0.w),a0
	move.l	pt_buffercol,a1
	lea	274*16*2(a1),a2
	lea	-16*2(a1),a3
	* PALETTE D'AFFICHAGE *
	lea	palette,a4
	move.w	nb_palette,d4
	lea	(a4,d4.w),a4
	* LES 16 PIXELS DE LARGE *
	moveq	#7,d1
affp:	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d3
	and.l	#%00001111,d3
	lsr.w	#4,d0

	lsl.w	#1,d0
	lsl.w	#1,d3
	move.w	(a4,d0),(a2)+
	move.w	(a4,d3),(a2)+
	move.w	(a4,d0),(a3)+
	move.w	(a4,d3),(a3)+
	dbra	d1,affp
	addq.w	#1,pt_lettre
	bra.s	finespace
espace:	
	* UN ESPACE *
	move.l	pt_buffercol,a1
	lea	274*16*2(a1),a2
	lea	-16*2(a1),a3
	rept	8
	clr.l	(a2)+
	clr.l	(a3)+
	endr
	addq.w	#1,pt_lettre		
finespace:
	rts
	
****************************************************
* 228EME LIGNE : JSR OVERGDx REMPLACE PAR JSR BASx *
* 274EME : RTS                                     *
****************************************************
change_jsr:
	* ON REMET LES ANCIENS JSR *
	move.l	pt_bufferjsr,a0
	move.l	save_over,228*6+2(a0)
	move.w	#$4eb9,274*6(a0)
 	* ON AVANCE LA COURBE DE 4 PAS (4*6=24) *
	add.l	#24,pt_bufferjsr
	add.l	#24,adrsaut+2
	cmpi.l	#bufferjsr+NB_SINUS*6,pt_bufferjsr
	bne.s	nofinsin
	move.l	#bufferjsr,pt_bufferjsr
	move.l	#bufferjsr,adrsaut+2
nofinsin:	
	* ON MET LE JSR BASx ET LE RTS *
	move.l	pt_bufferjsr,a0
	move.l	228*6+2(a0),d0
	lea	suite1,a0
	clr.w	d2
	moveq	#15,d1
teste2:	addq.w	#4,d2
	cmp.l	(a0)+,d0
	bne.s	teste2
	lea	suite2,a1
	lea	-4(a1,d2.w),a1
	move.l	pt_bufferjsr,a0
	move.l	228*6+2(a0),save_over
	move.l	(a1),228*6+2(a0)
	move.w	#$4e75,274*6(a0)
	rts
		
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

*******************************************************
* ROUTINES INTEGREES : 16 OVERGD ( PR CHAQUE POSITION *
* DANS LE SCROLL ) + 16 BAS ( ID )                    *
*******************************************************
	include		a:\colorscr\bigbloc.s

************************
* ROUTINES HBLs ET VBL *
************************
hbl:	rte
tstht:	subq.w	#1,high_border
	rte
vbl:	move.w	#33,high_border
	move.l	#tstht,$68.w
	addq.l	#1,v466
	rte
	
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
	
*****************************
* AFFICHE LIGNES VERTICALES *
*****************************
affiche_lignes_verticales
	move.l	log,a0
	move.w	#204/4-1,d0		; une ligne vide
cls1:	clr.l	(a0)+
	dbra	d0,cls1
	move.w	#274-1,d0
cls2:	rept	28
	move.l	#%01010101010101010011001100110011,(a0)+
	move.l	#%00001111000011110000000011111111,(a0)+
	endr
	clr.l	(a0)+
	clr.w	(a0)+
	dbra	d0,cls2
	rts
***************************************
* SUIVANT COURBE , PRECALCULE LES JSR *
***************************************
precalcule_jsr:
	lea	courbe,a0
	lea	bufferjsr,a1
	lea	suite1,a2
	move.w	#NB_SINUS-1,d7
rempli:	move.w	#$4eb9,(a1)+
	clr.l	d0
	move.b	(a0)+,d0
	lsl.l	#2,d0
	move.l	(a2,d0.w),(a1)+
	dbra	d7,rempli

	lea	courbe,a0
	move.w	#273,d7
rempli2:	
	move.w	#$4eb9,(a1)+
	clr.l	d0
	move.b	(a0)+,d0
	lsl.l	#2,d0
	move.l	(a2,d0.l),(a1)+
	dbra	d7,rempli2
	rts
***********************
* ADRESSE 1ERE LETTRE *
***********************
adresse_1_ere_lettre:
	clr.w	pt_lettre
	move.l	pt_texte,a0
	move.w	(a0),d0
	lea	fonte,a0
	lea	(a0,d0.w),a0
	move.l	a0,adr_lettre
	addq.l	#2,pt_texte
	cmpi.l	#fintexte,pt_texte
	bne.s	nofintxt
	move.l	#texte,pt_texte
nofintxt:		
	rts
****************************************************
* 228EME LIGNE : JSR OVERGDx REMPLACE PAR JSR BASx *
* 274EME : RTS                                     *
****************************************************
remplace_overgd_par_bas:
	move.l	pt_bufferjsr,a0
	move.l	228*6+2(a0),d0
	lea	suite1,a0
	clr.w	d2
	moveq	#15,d1
teste:	addq.w	#4,d2
	cmp.l	(a0)+,d0
	bne.s	teste
	lea	suite2,a1
	lea	-4(a1,d2.w),a1
	move.l	pt_bufferjsr,a0
	move.l	228*6+2(a0),save_over
	move.l	(a1),228*6+2(a0)
	move.w	#$4e75,274*6(a0)
	rts



	************
	SECTION DATA
	************
	
* DU NOIR *
palnoire:	dcb.w	16,0

palette:	
	dc.w	0,0,$777,$666,$555,$444,$333,$222,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$007,$006,$005,$004,$003,$002,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$770,$660,$550,$440,$330,$220,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$070,$060,$050,$040,$030,$020,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$765,$654,$543,$432,$321,$210,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$077,$066,$055,$044,$033,$022,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$756,$645,$534,$423,$312,$201,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$357,$246,$135,$024,$013,$002,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$753,$642,$531,$420,$310,$200,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$375,$264,$153,$042,$031,$020,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$735,$624,$513,$402,$301,$200,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$537,$426,$315,$204,$103,$002,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$707,$606,$505,$404,$303,$202,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$567,$456,$345,$234,$123,$012,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$700,$600,$500,$400,$300,$200,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$573,$462,$351,$240,$130,$020,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$675,$564,$453,$342,$231,$120,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$576,$465,$354,$243,$132,$021,$222,$333,$444,$555,$777,0,0,0
	dc.w	0,0,$657,$546,$435,$324,$213,$102,$222,$333,$444,$555,$777,0,0,0
nb_palette:	dc.w	32*0

* PALETTE CODEE SOUS FORME DE COULEURS RGB *
fonte:	incbin	a:\colorscr\colorfnv.bin

pt_buffercol:	dc.l	buffercol
pt_texte:	dc.l	texte
pt_lettre:	dc.w	0
adr_lettre:	dc.l	0

* WELCOME TO EVERYBODY ... *
texte:	dcb.w	2,0
	incbin	a:\colorscr\txv.dat
fintexte:

* SINUSOIDE : DC.B x ... *
courbe:	include	a:\colorscr\courbe.dat
fincourbe:
	even

* LES 16 ROUTINES D'OVERSCAN *
suite1:	dc.l	overgd0,overgd1,overgd2,overgd3,overgd4,overgd5,overgd6
	dc.l	overgd7,overgd8,overgd9,overgd10,overgd11,overgd12,overgd13
	dc.l	overgd14,overgd15
	
* LES 16 ROUTINES D'OUVERTURE DE LA BORDURE BASSE *
suite2:	dc.l	bas0,bas1,bas2,bas3,bas4,bas5,bas6,bas7,bas8,bas9,bas10
	dc.l	bas11,bas12,bas13,bas14,bas15	

pt_bufferjsr:	dc.l	bufferjsr
		
	***********
	SECTION BSS
	***********
	
save_over:	ds.l	1	

oldecr:	ds.l	1
oldrez:	ds.w	1
oldmfp:	ds.b	24
oldvec:	ds.l	24
oldcol:	ds.w	16

log:		ds.l	1+16
buffercol:	ds.w	16*274*2+16*2
bufferjsr:	ds.b	6*NB_SINUS+6*274+1000
ecran:		ds.b	63020+256
