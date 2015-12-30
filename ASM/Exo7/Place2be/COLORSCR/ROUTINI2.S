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
