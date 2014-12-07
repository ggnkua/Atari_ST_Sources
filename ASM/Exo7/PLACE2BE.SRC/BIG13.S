MUSIC	=	1

* COLORSCR *
NB_SINUS	=	274*4+274*2+276+400
NB_PAL		=	19

* RASTERS *
LIGNES		=	200+24
PALETTE_RASTERS	=	2	* 0..5

* DIST *
HAUTEUR		=	243-12
HAUTEUR2	=	243

**********************************
* LES MAGIQUES RASTERS VERTICAUX *
*  PAS PRECALCULES POUR UN SOU   *
*  MAIS BIEN SUR EN OVERSCAN GD  *
**********************************
*        BY: DYNO OF EXO7        *
**********************************
	opt o+

super:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	move.b	#$12,$fffffc02.w
	dc.w	$a00a

	lea	DEBUT_BSS,a0
	lea	FIN_BSS,a1
tu_m_efface_tout_ca:
	clr.b	(a0)+
	cmp.l	a0,a1
	bne.s	tu_m_efface_tout_ca
		
*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.l	#ecran,d0		; Ecran color scroll
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log
	move.l	#ecran_rasters,d0	; 2 Ecrans : rasters
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log1
	move.l	log1,log2
	addi.l	#63232,log2
	move.l	log1,visible
	move.l	log2,invisible
	move.l	#ecran_dist,d0		; Ecran distorter
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log3

* INSTALLE LES NOUVELLES HBL-VBL *

	IFEQ	MUSIC-1
	moveq	#0,d0
	bsr	musique
	bsr	musique+18
	ENDC

	bsr	initmfp
	move.l	#vbl,$70.w

	bsr	generation3
	bsr	efface_log
	bsr	affiche_pres

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w
PRESENTATION:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	

	;
	; *********************************************************
	; * METTRE A CET ENDROIT LES routines4 A EXECUTER AVANT    *
	; * LE DEBUT DE L'OVERSCAN , CAD PENDANT LES 34 SCANLINES *
	; * PRECEDANT L'AFFICHAGE DE L'IMAGE                      *
	; *********************************************************
	;

	move.l	pt_backrast,pt_backrast2
	subq.l	#2,pt_backrast
	cmp.l	#backrast,pt_backrast
	bne.s	suiteback
	bra	FINPRESENTATION
suiteback:
	lea	rien,a3
	lea	rien,a4

	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
	
top4:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top4

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d6
wait4:	dbra	d6,wait4
	clr.b	$ffff820a.w
	dcb.w	16,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	24,$4e71

*****************
* STABILISATION	*
*****************
	move.b	$ffff8209.w,d6
	ext.w	d6
	neg.w	d6
	lsr.w	d6,d6
	dcb.w	35,$4e71

	jsr	buffergen3			* IT'S FULL !!!
	
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#57,$fffffc02.w
	beq	findemo
	bra	PRESENTATION
FINPRESENTATION:
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w

	* COLOR SCROLL *
	bsr	affiche_lignes_verticales	
	bsr	precalcule_jsr	
	bsr	adresse_1_ere_lettre	
	bsr	remplace_overgd_par_bas

	* RASTERS VERTICAUX *
	bsr	generation
	bsr	predecalage_sprites_et_masques
	bsr	predecalage_fonte_un_plan
	bsr	precalcul_lignes_de_rasters
	bsr	precalcul_suite_des_lignes
	bsr	copie_motif_troue
	bsr	adr_1ere_lettre_et_masque
	bsr	affiche_1ere_lettre

	* DISTORTER *
	bsr	predecalage_fonte_trois_plans
	bsr	generation2
	bsr	initialise_texte_et_courbe
	bsr	affiche_exo2

	move.l	log3,a1
	add.l	#204+24,a1
	rept	16
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	lea	230-6*4(a1),a1
	endr
	rept	16
	move.l	#$0000fffe,(a1)
	move.l	#0,4(a1)
	move.l	#0,8(a1)
	move.l	#$fffe0000,12(a1)
	move.l	#0,16(a1)
	move.l	#$0000fffe,20(a1)
	lea	230(a1),a1
	endr

*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
AVDEMONSTRATION1:
DEMONSTRATION1:
	* SWAPPE ECRANS *
	move.l	visible,aux
	move.l	invisible,visible
	move.l	aux,invisible

	* SETSCREEN *
	move.b	visible+1,$ffff8201.w
	move.b	visible+2,$ffff8203.w
	bsr	vsync

	move.w	#$2100,sr	

	* RECOPIE LE BUFFER *
	move.l	invisible,a1
	add.l	#204+230*250+8+6,a1
	move.w	offset_buffer,d0
	add.w	position,d0
	lea	buffscroll,a0
	lea	(a0,d0.w),a0
	moveq	#10,d0
affb:	move.w	(a0)+,(a1)
st	set	8
	rept	23
	move.w	(a0)+,st(a1)
st	set	st+8
	endr
	lea	7*4+2+2*4+24*8(a1),a1
	lea	26*2(a0),a0
	dbra	d0,affb
	
	* SAUVE LES REGISTRES *
	movem.l	d0-a6,-(sp)

	IFEQ	MUSIC-1
	bsr	musique+26
	ENDC
	
	* DONNEES OVERSCAN *	
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
	
;	bra	FinOverscan
top:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d6
wait:	dbra	d6,wait
	clr.b	$ffff820a.w
	dcb.w	16,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	24,$4e71

*****************
* STABILISATION	*
*****************
	move.b	$ffff8209.w,d6
	ext.w	d6
	neg.w	d6
	lsr.w	d6,d6
	dcb.w	35,$4e71

	jsr	buffergen			* IT'S FULL !!!
	
FinOverscan:	
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
	move.w	#$2300,sr

	* PALETTE RASTERS VERT. *
	movem.l	palette1+PALETTE_RASTERS*32,d0-d7
	movem.l	d0-d7,$ffff8240.w
	* CALCUL ADR NOUVELLE LIGNE *
	move.l	pt_anim,a0
	move.l	(a0),adresse
	addq.l	#4,pt_anim
	cmpi.l	#fin_anim_rasters,pt_anim
	bne.s	on_loope_pas
	move.l	#anim_rasters,pt_anim
on_loope_pas:

	* ANCIENS REGISTRES *
	movem.l	(sp)+,d0-a6

	* AFFICHE NVELLE LETTRE *
	add.w	#1100,offset_buffer
	cmpi.w	#8*1100,offset_buffer
	bne.s	on_continue
	* ADR LETTRE + MASQUE *
	clr.w	offset_buffer
	move.l	pt_texte1,a0
	move.w	(a0),d7
	lea	unplan2,a6
	lea	(a6,d7.w),a6
	lea	petitmasque,a4
	move.l	a6,pt_unplan2
	move.l	a4,pt_petitmasque
	* NVELLE LETTRE+POSITION *			
	addq.l	#2,pt_texte1
	cmpi.l	#fintexte1,pt_texte1
	bne.s	pas_fin_texte
	move.l	#texte1,pt_texte1
pas_fin_texte:
	addq.w	#2,position
	cmpi.w	#26*2,position
	bne.s	pas_fin_buffer
	move.w	#2,position
pas_fin_buffer:
on_continue:
	* COPIE LA POSITION DE LA LETTRE ACTUELLE *
	move.w	offset_buffer,d0
	add.w	position,d0
	lea	buffscroll,a0
	lea	(a0,d0.w),a0
	lea	23*2(a0),a0
	move.l	pt_petitmasque,a4
	move.l	(a4)+,d4
	move.l	a4,pt_petitmasque
	move.l	pt_unplan2,a6
	rept	11
	move.l	(a6)+,d6
	and.l	d4,(a0)
	or.l	d6,(a0)
	move.l	(a0),-25*2(a0)
	lea	50*2(a0),a0
	endr
	move.l	a6,pt_unplan2

	* TEST FIN *
	cmpi.b	#110,$fffffc02.w
	beq.s	AVDEMONSTRATION2
	cmpi.b	#111,$fffffc02.w
	beq	AVDEMONSTRATION3
	cmpi.b	#57,$fffffc02.w
	beq	findemo
	
	bra	DEMONSTRATION1
	
AVDEMONSTRATION2:
	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w
DEMONSTRATION2:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	
	
	movem.l	palnoire,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	scrolle
	bsr	change_jsr	
	IFEQ	MUSIC-1
	bsr	musique+26
	ENDC
	
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
	
top2:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top2

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d0
wait2:	dbra	d0,wait2
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
	beq	findemo
	cmpi.b	#109,$fffffc02.w
	beq	AVDEMONSTRATION1
	cmpi.b	#111,$fffffc02.w
	beq.s	AVDEMONSTRATION3
	
	bra	DEMONSTRATION2

AVDEMONSTRATION3:
	move.b	log3+1,$ffff8201.w
	move.b	log3+2,$ffff8203.w
DEMONSTRATION3:
	bsr	vsync

	movem.l	d0-a6,-(sp)
	move.w	#$2100,sr	
	
	movem.l	exo2+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	;
	; ...
	;

	rept	2
	bsr	calcule_adresses1
	bsr	calcule_adresses2
	endr
	
	IFEQ	MUSIC-1
	bsr	musique+26
	ENDC
	
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
		
top3:	stop	#$2100			; On attend la 34eme ligne
	tst.w	high_border
	bpl.s	top3

	move.w	#$2700,sr
*************************
* OUVERTURE BORDER HAUT *
*************************
	moveq	#23,d6
wait3:	dbra	d6,wait3
	clr.b	$ffff820a.w
	dcb.w	16,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	24,$4e71

*****************
* STABILISATION	*
*****************
	move.b	$ffff8209.w,d6
	ext.w	d6
	neg.w	d6
	lsr.w	d6,d6
	dcb.w	35,$4e71

	jsr	buffergen2
	
********************************
* ESPACE=FIN SINON ON CONTINUE *
********************************
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l1
	move.b	#0,d0
l1:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+26+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l2
	move.b	#0,d0
l2:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+36+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr
	
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	btst	#4,d0
	beq.s	l3
	move.b	#0,d0
l3:	clr.l	d1
	move.b	d0,d1
	lsl.l	#5,d1
	lea	equalizer,a0
	lea	(a0,d1.l),a0
	move.l	log3,a1
	add.l	#204+46+230,a1
	rept	16
	move.w	(a0)+,(a1)
	lea	230(a1),a1
	endr

	move.w	#$2300,sr
	movem.l	(sp)+,d0-a6
	cmpi.b	#109,$fffffc02.w
	beq	AVDEMONSTRATION1
	cmpi.b	#110,$fffffc02.w
	beq	AVDEMONSTRATION2
	cmpi.b	#57,$fffffc02.w
	beq.s	findemo
	bra	DEMONSTRATION3


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
	bsr.s	vsync
	move.b	oldrez,$ffff8260.w
	bsr.s	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	bsr.s	vsync
	bsr	finmfp

	IFEQ	MUSIC-1
	moveq	#-1,d0
	bsr	musique
	bsr	musique+22
	ENDC
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

*********************
* ROUTINES OVERSCAN *
*********************
	include	a:\raster\routover.s
	include	a:\colorscr\bigbloc.s
clear1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear12:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	movem.l	d3-d6,(a0)
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d6,4*4(a0)
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d7/a1-a4,8*4(a0)
	movem.l	d3-d7/a1-a4,17*4(a0)
	movem.l	d3-d7/a1-a4,26*4(a0)
	movem.l	d3-d7/a1-a4,35*4(a0)
	move.w	d3,44*4(a0)
	lea	44*4+2(a0),a0
;	dcb.w	3,$4e71
	rts

diste1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR-14,a0
	lea	position1,a2
	lea	letinit,a3
	rts
diste12:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2-14,a0
	lea	position2,a2
	lea	letinit2,a3
	rts
diste2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
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
	dcb.w	89-40,$4e71	
	rts
diste22:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	lea	14(a0),a0
	lea	texte22,a4
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
	dcb.w	89-40,$4e71	
	rts
diste3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	dcb.w	2,$4e71
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	nop
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
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
	dcb.w	2,$4e71
	rts
setcolorscroll:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
St	set	0
	rept	8
	move.l	pal_3plans+St,$ffff8240+St.w
St	set	St+4
	endr
	dcb.w	89-64,$4e71
	rts


***********************
* ROUTINES HBL ET VBL *
***********************
tstht:	subq.w	#1,high_border
	rte
vbl:	move.w	#33,high_border
	move.l	#tstht,$68.w
	addq.l	#1,v466
	rte
	
****************************************
* GENERE LE CODE INTEGRE DE L'OVERSCAN *
****************************************
generation:
	lea	routines,a0
	lea	buffergen,a1
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

**************
* PROCEDURES *
**************
	include	a:\raster\routinit.s
	include	a:\colorscr\routini2.s
****************************************
* GENERE LE CODE INTEGRE DE L'OVERSCAN *
****************************************
generation2:
	lea	routines2,a0
	lea	buffergen2,a1
	move.w	#271,d0
lg2:	move.l	(a0)+,a2
rep2:	move.w	(a2)+,(a1)+
	cmpi.w	#$4e75,(a2)
	bne.s	rep2
	dbra	d0,lg2
	move.w	#$4e75,(a1)+	; RTS
	rts
***********************************
* PREDECALAGE DE LA FONTE UN PLAN *
***********************************
predecalage_fonte_trois_plans:
	lea	troisplans2,a1
	lea	troisplans,a6
	move.w	#20*3-1,d0
tsleschar2:
	moveq	#15,d1
les8decal2:
	* Recopie *
	move.l	a6,a0
	move.w	#10,d2
mots2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d2,mots2
	* Scrolle 
	move.l	a6,a0
	move.w	#10,d2
scro2:	moveq	#0,d3
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
	dbra	d2,scro2

	dbra	d1,les8decal2
	lea	132(a6),a6
	dbra	d0,tsleschar2
	rts
calcule_adresses1:
	move.l	pt_courbe2,a0
	lea	position1,a1
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
pfc:
	rts

calcule_adresses2:
	move.l	pt_courbe22,a0
	lea	position2,a1
	lea	letinit2,a2
	moveq	#10,d1
calcing2:
	move.w	(a0)+,d0
	add.w	d0,(a1)
	cmpi.w	#16*132,(a1)
	blt.s	sdf2
	sub.w	#16*132,(a1)
	addq.w	#4,(a2)
	move.w	(a2),d0
	sub.w	longueur_texte22,d0
	bne.s	sdf2
	move.w	#0,(a2)
sdf2:
	cmpi.w	#0,(a1)
	bge.s	sdg2
	add.w	#16*132,(a1)
	subq.w	#4,(a2)
	cmpi.w	#-4,(a2)
	bne.s	sdg2
	move.w	longueur_texte22,(a2)
	subq.w	#4,(a2)
sdg2:
	addq.l	#2,a1
	addq.l	#2,a2
	dbra	d1,calcing2
	
	addq.l	#2,pt_courbe22		* 2*11
	cmpi.l	#fincourbe2,pt_courbe22
	bne.s	pfc2
	move.l	#courbe2,pt_courbe22
pfc2:
	rts

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

	move.l	#fintexte22,d0		*
	sub.l	#texte22,d0
	move.w	d0,longueur_texte22
	lea	texte22,a0		*
	lea	fintexte22,a1
	moveq	#29,d0
rec3:	move.l	(a0)+,(a1)+
	dbra	d0,rec3
	
	rept	12
	bsr	calcule_adresses2
	endr
	rts

***********************
* LE VAISSEAU DE RICK *
***********************
affiche_exo2:
	move.l	log3,a0
	lea	exo2+34,a1
	move.w	#204/4-1,d0
c:	clr.l	(a0)+
	dbra	d0,c
	move.w	#229*230/4-1,d0
c2:	move.l	(a1)+,(a0)+
	dbra	d0,c2
	rts
overgdpres:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	move.l	pt_backrast2,a0		* 5
	dcb.w	5,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	move.w	(a0)+,$ffff8242.w	* 4
	move.l	a0,pt_backrast2		* 5
	dcb.w	2,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	rept	17
	move.l	(a3),(a4)
	endr
	dcb.w	4,$4e71
	rts
rastpres1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11-4,$4e71
	move.w	#$777,$ffff8240.w
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89,$4e71
	rts
rastpres2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11-4,$4e71
	move.w	#$000,$ffff8240.w
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89,$4e71
	rts
affiche_pres:
	lea	textepres,a0
	moveq.w	#0,d0
lig:	moveq.w	#1,d1
col:	move.w	(a0)+,d2
	lea	samos,a1
	lea	(a1,d2.w),a1
	move.l	log,a2
	lea	204(a2),a2
	move.w	d0,d3
	mulu	#16*230,d3
	lea	(a2,d3.l),a2
	move.w	d1,d3
	lsl.w	#3,d3
	lea	(a2,d3.w),a2
	moveq	#14,d3
al:	move.w	(a1)+,(a2)
	lea	230(a2),a2
	dbra	d3,al
	addq.w	#1,d1
	cmpi.w	#26,d1
	bne.s	col
	addq.w	#1,d0
	cmpi.w	#16,d0
	bne.s	lig
	rts
efface_log:
	move.l	log,a0
	move.w	#204/4-1,d0		; une ligne vide
clsp1:	clr.l	(a0)+
	dbra	d0,clsp1
	move.w	#63020/4-1,d0
clsp2:	clr.l	(a0)+
	dbra	d0,clsp2
	rts
generation3:
	lea	routines4,a0
	lea	buffergen3,a1
	move.w	#271,d0
lg3:	move.l	(a0)+,a2
rep3:	move.w	(a2)+,(a1)+
	cmpi.w	#$4e75,(a2)
	bne.s	rep3
	dbra	d0,lg3
	move.w	#$4e75,(a1)+	; RTS
	sub.l	#buffergen3,a1
	rts

	
	
	************
	SECTION DATA
	************
	IFEQ	MUSIC-1
musique:	incbin	a:\*.mus
	ENDC

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
fonte:	incbin	a:\colorscr.2\colorfnv.bin

pt_buffercol:	dc.l	buffercol
pt_texte:	dc.l	texte
pt_lettre:	dc.w	0
adr_lettre:	dc.l	0

* WELCOME TO EVERYBODY ... *
texte:	dcb.w	2,0
	incbin	a:\colorscr.2\txv.dat
fintexte:

* SINUSOIDE : DC.B x ... *
courbe:	
	include	a:\colorscr\courbe.dat
	include	a:\colorscr\courbe.dat
	include	a:\colorscr\courbe1.dat
	include	a:\colorscr\courbe2.dat
	include	a:\colorscr\courbe3.dat
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
		

* LIGNE A RECOPIER *
adresse:	dc.l	bigbuffer

* RASTERS VERT. * 0=bois 1=Mauve 2=Vert 3=Vert2 4=Violet-Bleu 5=Bleu
palette1:	
	dc.w	$000,$200,$210,$311,$321,$422,$432,$533,$543,$644,$654,$755,$765,$765,$776,$776
	dc.w	$000,$200,$201,$311,$312,$422,$423,$533,$534,$644,$645,$755,$756,$756,$767,$767
	dc.w	$000,$020,$120,$131,$231,$242,$342,$353,$453,$464,$564,$575,$675,$675,$776,$776
	dc.w	$000,$020,$021,$131,$132,$242,$243,$353,$354,$464,$465,$575,$576,$576,$677,$677
	dc.w	$000,$002,$102,$113,$213,$224,$324,$335,$435,$446,$546,$557,$657,$657,$767,$767
	dc.w	$000,$002,$012,$113,$123,$224,$234,$335,$345,$446,$456,$557,$567,$567,$677,$677
* MOTIF DESSOUS LES RASTERS *
palette2:
	dc.w	$000,$111,$777,$743,$532,$420,$310,$000
	dcb.w	8,$007

* SPRITES ET MASQUES DE RASTERS VERT. *
sprite:		incbin	a:\raster\sprite.dat
masque:		incbin	a:\raster\masque.dat

* FORMAT UTILISE :         1W = OFFSET/DEBUT DE SPRITE2  +    *
* 1W =  OFFSET/DEBUT DE BUFFER / LES 2 A -1 : FIN DE LA LIGNE *
offset:	
	incbin	a:\raster\offsets.dat
	incbin	a:\noffset1.dat
	dc.w	-2,-2

* SEQUENCE D'ANIMATION *	
pt_anim:	dc.l	anim_rasters
anim_rasters:	
	rept	64
	dc.l	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
	endr
	
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
a	set	24
	rept	200
	dc.l	a
a	set	a+1
	endr
fin_anim_rasters:

* 272 ROUTINES DE L'OVERSCAN *
bloc:	macro
	dc.l	ligne1
	rept	47
	dc.l	ligne2
	endr
	endm
routines:
	dc.l	calc_adr_bloc1
	bloc
	dc.l	calc_adr_bloc2
	bloc
	dc.l	calc_adr_bloc3
	bloc
	dc.l	calc_adr_bloc4
	bloc
	dc.l	calc_adr_bloc5
	dc.l	ligne1
	rept	30
	dc.l	ligne2
	endr
	dc.l	bas
	rept	11
	dc.l	ligne2
	endr
	dc.l	palette_back
	rept	6
	dc.l	ligne2
	endr
	dc.l	calc_adr_bloc6
	rept	24
	dc.l	ligne3
	endr
	rept	2
	dc.l	noppe
	endr

* MOTIF A TROUS DE DESSOUS LES RASTERS *	
back:	incbin	a:\raster\machin.dat	

* FONTE 16*11 EN 1 PLAN *
unplan:	incbin	a:\raster\unplan.dat
* LE TEXTE QUI VA AVAC LA FONTE *
texte1:	dc.w	0		* laisser sinon le 1er caractere clignote ...
	incbin	a:\raster\txt.dat
fintexte1:

* POUR LE SCROLL EN 1 PLAN *	
offset_buffer:	dc.w	0
position:	dc.w	2
pt_texte1:	dc.l	texte1	
petitmasque:			* PR MASQUER LES CARACTERES *
	dc.l	$FFFF0000,$FFFC0000,$FFF00000,$FFC00000
	dc.l	$FF000000,$FC000000,$F0000000,$C0000000

pt_unplan2:	dc.l	0
pt_petitmasque:	dc.l	0

zero:	dcb.l	16,0

position1:	dc.w	0,144,288,432,576,720,864,1008,1152,1296,1440
letinit:	dcb.w	11,4*0
A=2
position2:	dc.w	A*132+0,A*132+144,A*132+288,A*132+432,A*132+576,A*132+720,A*132+864,A*132+1008,A*132+1152,A*132+1296,A*132+1440
letinit2:	dcb.w	11,4*0

pt_courbe2:	dc.l	avcourbe2
pt_courbe22:	dc.l	avcourbe2
avcourbe2:
	dcb.w	12,132*2
	dcb.w	48,132*7
	dcb.w	24,132*6
	dcb.w	12,132*5
	dcb.w	6,132*4
	dcb.w	3,132*3
courbe2:	
	incbin	a:\dist\crb6616.dat
	incbin	a:\dist\crb6616.dat
	incbin	a:\dist\crb18842.dat
	incbin	a:\dist\crb18842.dat
	incbin	a:\dist\crb18842.dat

	incbin	a:\dist\crb6616.dat
	incbin	a:\dist\crb6616.dat
	incbin	a:\dist\crb18842.dat
fincourbe2:	dcb.w	11,0

longueur_texte2:	dc.w	0
texte2:			dcb.l	12+30,0
			incbin	a:\dist\txtdist1.dat
fintexte2:		dcb.l	30,0
longueur_texte22:	dc.w	0
texte22:		dcb.l	12+31,0
			incbin	a:\dist\txtdist2.dat
fintexte22:		dcb.l	30,0

routines2:
	dc.l	clear1
	rept	14
	dc.l	clear2
	endr
	dc.l	diste1
	rept	11
	dc.l	diste2
	dc.l	diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3
	endr
	dc.l	clear12
	rept	14
	dc.l	clear2
	endr
	dc.l	diste12
	rept	8
	dc.l	diste22
	dc.l	diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3
	endr
	dc.l	diste22
	dc.l	diste3,diste3,diste3,diste3,diste3
	dc.l	bas,diste3,setcolorscroll
	dc.l	diste3,diste3,diste3
	rept	2
	dc.l	diste22
	dc.l	diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3,diste3
	endr
	rept	44-4-2*10
	dc.l	overgd
	endr
	
troisplans:	incbin	a:\dist\fontor.dat
pal_3plans:	dc.w	$000,$222,$321,$432,$543,$654,$765,$777
		dc.w	8,0
equalizer:	
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	0,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe,$fffe

textepres:	incbin	a:\pres.ptb\texte.dat
samos:	incbin	a:\pres.ptb\samos.dat
rien:	dc.l	0
	
* 272 routines4 DE L'OVERSCAN *
routines4:
	rept	0+8
	dc.l	overgdpres
	endr
	dc.l	rastpres1,rastpres2
	rept	226-8
	dc.l	overgdpres
	endr
	dc.l	bas
	rept	42-8
	dc.l	overgdpres
	endr
	dc.l	rastpres1,rastpres2
	rept	0+8
	dc.l	overgdpres
	endr

pt_backrast:	dc.l	finbackrast-274*2
pt_backrast2:	dc.l	0
backrast:
	dcb.w	274,0
	rept	13
	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$670,$570,$470,$370,$270,$170,$070
	dc.w	$071,$072,$073,$074,$075,$076,$077
	dc.w	$067,$057,$047,$037,$027,$017,$007
	dc.w	$107,$207,$307,$407,$507,$607,$707
	dc.w	$706,$705,$704,$703,$702,$701
	endr
	dcb.w	274+40,0
finbackrast:

exo2:	incbin	a:\dist\exo2.kid


	***********
	SECTION BSS
	***********
DEBUT_BSS:

save_over:	ds.l	1	

		ds.w	16*2
buffercol:	ds.w	16*274*2+16*2
		ds.b	1000
bufferjsr:	ds.b	6*NB_SINUS+6*274+1000

* ECRANS *
log:		ds.l	1
log1:		ds.l	1
log2:		ds.l	1
log3:		ds.l	1
visible:	ds.l	1
invisible:	ds.l	1
aux:		ds.l	1

* ANCIENNES VALEURS *
oldecr:		ds.l	1
oldrez:		ds.w	1
oldmfp:		ds.b	24
oldvec:		ds.l	24
oldcol:		ds.w	16




* PREDECALES *
sprite2:	ds.b	1024*16
masque2:	ds.b	1024*16
unplan2:	ds.b	2640*8

* 8 BUFFERS DE 50 CARACTERES *
buffscroll:	ds.b	50*11*2*8

* OVERSCAN1=RASTERS VERT. *
buffergen:	ds.b	20000
buffergen2:	ds.b	34000
buffergen3:	ds.b	30000

* CALCUL D'1 LIGNE DE RASTERS *
buffer:		ds.b	16+230+16
* STOCKAGE DE CETTE LIGNE *
bigbuffer:	ds.b	192*LIGNES
finbigbuffer:

troisplans2:	ds.b	7920*16

ecran_dist:		ds.b	63232+256
ecran:		ds.b	63232+256
ecran_rasters:	ds.b	256
		ds.b	63232
		ds.b	63232
		
FIN_BSS:
	END