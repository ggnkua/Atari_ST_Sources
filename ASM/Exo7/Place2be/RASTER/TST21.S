LIGNES		=	24*9
PALETTE_RASTERS	=	0	* 0..5

MUSIC_ON	=	0
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
	
*************************
* QQUES INITIALISATIONS *
*************************	
initdemo:
	move.l	$44e.w,oldecr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcol
	move.b	$ffff8260.w,oldrez
	clr.b	$ffff8260.w
	move.l	#ecran_rasters,d0
	clr.b	d0
	addi.l	#256,d0
	move.l	d0,log1			; Log=adresse nouvel ecran
	move.l	log1,log2
	addi.l	#63232,log2		; Log=adr 2eme ecran
**********************************
* REUNI LES 272 ROUTS EN 1 SEULE *
**********************************
	bsr	generation
**********************************
* INSTALLE LES NOUVELLES HBL-VBL *
**********************************
	IFEQ	MUSIC_ON-1
	moveq	#0,d0
	bsr	zik
	bsr	zik+18
	ENDC
	
	bsr	initmfp
	move.l	#vbl,$70.w

	bsr	predecalage_sprites_et_masques
	bsr	predecalage_fonte_un_plan
	bsr	precalcul_lignes_de_rasters
	bsr	precalcul_suite_des_lignes
	bsr	copie_motif_troue
	bsr	adr_1ere_lettre_et_masque
	bsr	affiche_1ere_lettre
****************
* INIT. ECRANS *
****************
	move.l	log1,visible
	move.l	log2,invisible
*******************************************
* BEN CA ALORS ! ON VOIT DANS LES BORDS ! *
*******************************************
DEMONSTRATION:
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

	IFEQ	MUSIC_ON-1
	bsr	zik+26
	ENDC
	CLR.W	$FFFF8240.W
	
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
	bsr.s	vsync
	move.b	oldrez,$ffff8260.w
	bsr.s	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	bsr.s	vsync
	bsr	finmfp
	IFEQ	MUSIC_ON-1
	moveq	#-1,d0
	bsr	zik
	bsr	zik+22
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	ENDC
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
	dcb.w	89,$4e71
	rts
bas:
	move.b	d0,(a5)
	dcb.w	14,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	85,$4e71
	rts
*****************************
* CALC_ADR_BLOC X + LIGNE X *
* = COPIE DE LA LIGNE SUR   *
* TOUT L'ECRAN              *
*****************************
calc_adr_bloc1:
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
	move.l	adresse,a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4(a0),a0
	dcb.w	56,$4e71
	rts
calc_adr_bloc2:
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
	move.l	adresse,a0
	lea	9*4(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc3:
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
	move.l	adresse,a0
	lea	9*4*2(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*2(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc4:
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
	move.l	adresse,a0
	lea	9*4*3(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*3(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc5:
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
	move.l	adresse,a0
	lea	9*4*4(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*4(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc6:
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
	move.l	adresse,a0
	lea	9*4*5(a0),a0
	movem.l	(a0),d4-d6
	move.l	invisible,a0
	lea	204+2*4+9*4*5(a0),a0
	dcb.w	66,$4e71
	rts
ligne1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	movem.l	d3-d6,(a0)
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	movem.l	d7/a1-a3,4*4(a0)
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	a4,8*4(a0)
	lea	230(a0),a0
	movem.l	d3-d7/a1-a4,(a0)
	movem.l	d3-d7/a1-a4,230(a0)
	movem.l	d3-d7/a1-a4,460(a0)
	movem.l	d3-d7/a1-a4,690(a0)
	rts
ligne2:
	move.b	d0,(a5)
;	dcb.w	2,$4e71
	lea	230*4(a0),a0
	
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	movem.l	d3-d6,(a0)
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	movem.l	d7/a1-a3,4*4(a0)
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	a4,8*4(a0)
	lea	230(a0),a0
	movem.l	d3-d7/a1-a4,(a0)
	movem.l	d3-d7/a1-a4,230(a0)
	movem.l	d3-d7/a1-a4,460(a0)
	movem.l	d3-d7/a1-a4,690(a0)
	rts
ligne3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	nop
	
	move.b	d1,(a6)
;	dcb.w	2,$4e71
	lea	230-4*3(a0),a0
	
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	lea	230-4*3(a0),a0
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	rept	8
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	lea	230-4*3(a0),a0
	endr
	nop
	rts
palette_back:
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

	lea	$ffff8240.w,a5
	lea	palette2,a6
	rept	8
	move.l	(a6)+,(a5)+
	endr
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	dcb.w	89-49
	rts
noppe:	nop
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
***********************************
* PREDECALAGE DES SPRITES-MASQUES *
***********************************
predecalage_sprites_et_masques:
	lea	sprite2,a1
	moveq	#15,d0
Predecalage_sprite:
	* Recopie *
	lea	sprite,a0
	move.w	#255,d1
Recop1:	move.l	(a0)+,(a1)+
	dbra	d1,Recop1
	
	* Scrolle *
	moveq	#3,d3
les4mots:
	move.w	d3,d4
	lsl.l	#1,d4
	lea	sprite,a0
	lea	(a0,d4.w),a0
	moveq	#0,d2
	roxr	d2
	moveq	#127,d1
Scroll1:roxr	(a0)
	addq.l	#8,a0
	dbra	d1,Scroll1
	dbra	d3,les4mots
	dbra	d0,Predecalage_sprite

	lea	masque2,a1
	moveq	#15,d0
Predecalage_masque:
	* Recopie *
	lea	masque,a0
	move.w	#255,d1
Recop2:	move.l	(a0)+,(a1)+
	dbra	d1,Recop2
	
	* Scrolle *
	moveq	#3,d3
les4mots2:
	move.w	d3,d4
	lsl.w	#1,d4
	lea	masque,a0
	lea	(a0,d4.w),a0
	moveq	#0,d2
	roxr	d2
	moveq	#127,d1
Scroll2:roxr	(a0)
	addq.l	#8,a0
	dbra	d1,Scroll2
	dbra	d3,les4mots2
	dbra	d0,Predecalage_masque
	rts
***********************************
* PREDECALAGE DE LA FONTE UN PLAN *
***********************************
predecalage_fonte_un_plan:
	lea	unplan2,a1
	lea	unplan,a6
	
	move.w	#20*3-1,d0
tsleschar:

	moveq	#7,d1
les8decal:
	* Recopie *
	move.l	a6,a0
	move.w	#10,d2
mots:	move.l	(a0)+,(a1)+
	dbra	d2,mots
	
	* Scrolle 
	move.l	a6,a0
	move.w	#10,d2
scro:	rept	2
	moveq	#0,d3
	roxl	d3
	roxl	2(a0)
	roxl	(a0)
	endr
	addq.l	#4,a0
	dbra	d2,scro

	dbra	d1,les8decal
	
	lea	44(a6),a6
	dbra	d0,tsleschar
	rts
***********************************
* PRECALCUL DES LIGNES DE RASTERS *
***********************************
precalcul_lignes_de_rasters:
	lea	offset,a0
	lea	bigbuffer,a4
Precalcul:
	lea	buffer,a3
	move.w	#130,d0
effa:	clr.w	(a3)+
	dbra	d0,effa

repeat:
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bmi.s	finrep			; Si -1 ou -2

	lea	sprite2,a1
	lea	(a1,d1.w),a1
	lea	masque2,a2
	lea	(a2,d1.w),a2
	lea	buffer,a3
	lea	(a3,d2.w),a3
	
	moveq	#7,d1
affiche_sprite:
	move.l	(a2)+,d0
	not.l	d0
	and.l	d0,(a3)
	move.l	(a1)+,d0
	add.l	d0,(a3)+
	dbra	d1,affiche_sprite

	bra.s	repeat
finrep:
	lea	buffer+16,a2
	moveq	#47,d0
Recopie_le_buffer:	
	move.l	(a2)+,(a4)+
	dbra	d0,Recopie_le_buffer

	cmpi.w	#-2,(a0)
	bne.s	Precalcul	
	rts
**********************************************
* PRECALCULE LA SUITE DES LIGNES A AFFICHERS *
**********************************************
precalcul_suite_des_lignes:
	lea	anim_rasters,a0
	lea	fin_anim_rasters,a1
multiplie:
	move.l	(a0),d0
	mulu	#192,d0
	add.l	#bigbuffer,d0
	move.l	d0,(a0)+
	cmp.l	a0,a1
	bne.s	multiplie
	rts
************************************
* COPIE LE GFX EN BAS DES 2 ECRANS *
************************************
copie_motif_troue:
	move.l	log1,a0
	move.l	log2,a2
	add.l	#204+230*241+8,a0
	add.l	#204+230*241+8,a2
	lea	back,a1
	moveq	#29-1,d0	31-1,d0
aaa:	moveq	#24-1,d1
aaa2:	move.l	(a1),(a0)+
	move.l	(a1)+,(a2)+
	move.w	(a1),(a0)+
	move.w	(a1)+,(a2)+
	clr.w	(a0)+
	clr.w	(a2)+
	dbra	d1,aaa2
	lea	7*4+2+8(a0),a0
	lea	7*4+2+8(a2),a2
	dbra	d0,aaa
	rts
******************************
* ADRESSE 1ERE LETTRE+MASQUE *
******************************
adr_1ere_lettre_et_masque:
	move.l	pt_texte1,a0
	move.w	(a0),d7
	lea	unplan2,a6
	lea	(a6,d7.w),a6
	lea	petitmasque,a4
	addq.l	#2,pt_texte1
	move.l	a6,pt_unplan2
	move.l	a4,pt_petitmasque
	rts
******************************************
* 1ERE POSITION DE 1ERE LETTRE DS BUFFER *
******************************************
affiche_1ere_lettre:
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
	rts



	************
	SECTION DATA
	************

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
;	dc.w	$007,$006,$005,$004,$003,$002,$001,$000
;	dc.w	$000,$001,$002,$003,$004,$005,$006,$007

* SPRITES ET MASQUES DE RASTERS VERT. *
sprite:		incbin	c:\raster\sprite.dat
masque:		incbin	c:\raster\masque.dat

* FORMAT UTILISE :             *
* 1W = OFFSET/DEBUT DE SPRITE2 *
* 1W =              DE BUFFER  *
* LES 2 A -1 : FIN DE LA LIGNE *
offset:	incbin	c:\raster\offsets.dat
	dc.w	-2,-2

	IFEQ	MUSIC_ON-1
zik:	incbin	c:\*.mus
	ENDC

* SEQUENCE D'ANIMATION *	
pt_anim:	dc.l	anim_rasters
anim_rasters:
	dc.l	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
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
back:	;dcb.b	230*30,0
	incbin	c:\raster\machin.dat	

* FONTE 16*11 EN 1 PLAN *
unplan:	incbin	c:\raster\unplan.dat
* LE TEXTE QUI VA AVAC LA FONTE *
texte1:	dc.w	0		* laisser sinon le 1er caractere clignote ...
	incbin	c:\raster\txt.dat
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

	***********
	SECTION BSS
	***********

* ECRANS *
log1:		ds.l	1
log2:		ds.l	1
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
buffergen:	ds.b	80000

* CALCUL D'1 LIGNE DE RASTERS *
buffer:		ds.b	16+230+16
* STOCKAGE DE CETTE LIGNE *
bigbuffer:	ds.b	192*LIGNES
finbigbuffer:


ecran_rasters:	ds.b	256
		ds.b	63232
		ds.b	63232
	END