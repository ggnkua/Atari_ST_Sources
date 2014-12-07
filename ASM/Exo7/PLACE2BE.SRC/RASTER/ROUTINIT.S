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
efface_buffer:	
	clr.w	(a3)+
	dbra	d0,efface_buffer

repeat_until_negatif:
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bmi.s	finrepun			; Si -1 ou -2

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

	bra.s	repeat_until_negatif
finrepun:
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
multiplie_par_192:
	move.l	(a0),d0
	mulu	#192,d0
	add.l	#bigbuffer,d0
	move.l	d0,(a0)+
	cmp.l	a0,a1
	bne.s	multiplie_par_192
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
