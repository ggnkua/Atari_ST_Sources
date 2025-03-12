	***************************************
	*    generateur de sprites 3 plans    *
	*              V 1.3                  *
	*                                     *
	*      debut : 1 decembre 1990        *
	*   running version (1.0): 3/12/1990  *
	* debut V 1.3:   8 decembre 1990      *
	* fin   :        9 decembre 1990      *
	***************************************

* the still sea is darker than before

ligne_debut:	equ	14	* ligne maxi pour remplir
				* les premiers reg

hauteur:	equ	52
largeur:	equ	16

offset_img:	equ	0	* offset sprite
reg_use:		equ	7	* nb_reg disponibles - 1

	opt	o+,x+,w-

	section	text


	pea	texte
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	move.w	#$20,-(sp)		* superviseur
	trap	#1
	addq.l	#6,sp

	move.l	#final,pt_final
	move.l	#final2,pt_final2


	bsr	remplis_decalage	* remplis le buffer de decalage

	move.w	#15,d0
main_bo:
	move.w	d0,-(sp)
	move.w	(sp),d0
	jsr	aff_no
	bsr	vide_bss

*	rept	8
*	bsr	decale		* decale le buffer
*	endr

	bsr	copy_pred
	move.w	#0,nb_reg
	bsr	compte_occ6		* remplis table occurence
	bsr	elimine
	bsr	trie_occl		* trie .l
	bsr	elimine2		* elimine les occ trop faibles
	bsr	make_garder6	* 6 premieres lignes
	bsr	met_occ_in_movem	* charge movem et move.w et
				* conserve garder pour code
	

	bsr	compte_occ		* remplis table occurence
	bsr	elimine		* ajoute .w et .l
	bsr	trie_occl		* trie .l
	bsr	elimine2		* elimine les occ trop faibles
	bsr	elimine3		* elimine les occ deja ds reg
	bsr	remplis_instr	* analyse
	bsr	code		* codage suivant analyse effectu‚e
	bsr	put_in_final
	bsr	decale		* decale le buffer
	move.w	(sp)+,d0
	dbf	d0,main_bo

	bsr	sauve
	move.w	#$666,$ffff8240.w
	move.w	#$0,$ffff8248.w
	

	clr.w	-(sp)
	trap	#1	

handle:	ds.w	1
nom:
	dc.b	"i.spr",0
	even

put_in_final:
	move.l	a1,-(sp)

	move.w	#$4e75,-2(a1)

	move.l	debut_code,a2
	sub.l	#movem,a2

	move.l	pt_final2,d0
	move.l	pt_final,a1
	sub.l	#final,d0
	add.l	a2,d0
	move.l	d0,(a1)+
	move.l	a1,pt_final

	lea	movem,a0
	move.l	pt_final2,a1
	move.l	(sp)+,d0
	sub.l	a0,d0

	sub.l	#1,d0
.loop1:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop1

	move.l	a1,pt_final2
	rts

vide_bss:
	lea	debut_vide,a0
	lea	fin_vide,a1
	moveq	#0,d0
.loop1:
	move.b	d0,(a0)+
	cmp.l	a1,a0
	blt	.loop1
	rts

aff_no:
	move.l	#15,d1
	sub.w	d0,d1
	add.l	#1,d1
	lea	zero,a1
	move.l	$44e,a0
	lea	16*18(a0),a0
	add.w	d1,d1
	add.w	d1,d1
	jsr	(a1,d1.w)
	
	rts

sauve:
	move.w	#0,-(sp)		Create and Open File
	pea	nom
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	move.w	d0,handle

	move.l	pt_final2,d2
	sub.l	#final,d2
	
	
	pea	final		Save File
	move.l	d2,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	adda.l	#12,sp
	
	move.w	handle,-(sp)	Close File
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	
		
	rts




*******************************************


make_garder6:
	lea	liste_occl,a0
	lea	garder,a1
	moveq	#0,d7
.loop1:
	tst.l	(a0)
	beq	.fin

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.l	#1,d7
	cmp.l	#8,d7
	blt	.loop1
.fin:
	rts


*******************************************
elimine3:
	lea	garder,a0

.loop1:
	move.l	(a0),d0
	tst.l	d0
	beq	.fin
	move.l	12(a0),d1
	cmp.l	#2,d1
	bne	.long

	bsr	cherche_occw_l
	move.l	#0,4(a6)
	bra	.next
.long:
	bsr	cherche_occl
	move.l	#0,4(a6)

.next:
	lea	16(a0),a0
	cmp.l	#fgarder,a0
	blt	.loop1
.fin	
	rts

*******************************************

nouvelle:	ds.l	1
adr_nouv:	ds.l	1	* adresse du nouveau !

make_garder:
mg:
	move.l	#0,nouvelle   * nouvelle occurence rencontree ??
	move.l	#$8000-1,d1
	lea	garder,a0
	move.l	a0,a3
	move.l	#0,a5
	
.loop3:
	move.l	4(a0),d0
	cmp.l	d1,d0
	bge	.pas_de_change
	move.l	a0,a3
	move.l	d0,d1
	lea	garder-16,a0
.pas_de_change:
	lea	16(a0),a0
	cmp.l	#fgarder,a0
	blt	.loop3
	
	move.l	a3,a0	* a3=plus petit dans garder
	move.l	a0,adr_nouv
	
	lea	liste_occl,a1
	move.l	ligne,d1
	add.l	#1,d1

.loop1:
	move.l	(a0),d0
	tst.l	d0
	beq	.fin
	move.l	4(a0),d0
	move.l	a1,a2
	add.l	#3,d0

.loop2:
	cmp.l	8(a2),d1
	blt	.trop_tot

	cmp.l	4(a2),d0
	bge	.keep
*	move.l	a0,adr_nouv
	move.l	#1,nouvelle
	move.l	(a2),(a0)
	move.l	4(a2),4(a0)
	move.l	8(a2),8(a0)
	move.l	12(a2),12(a0)
	move.l	a2,a5

.trop_tot:
.keep:
	lea	16(a2),a2
	cmp.l	flistel,a2
	blt	.loop2

	lea	16(a0),a0
	cmp.l	fgarder,a0
	blt	.loop1
.fin:
	cmp.l	#1,nouvelle
	ble	.ok
	illegal
.ok
	cmp.l	#0,a5
	beq	.cont
	move.l	#0,4(a5)
.cont
	rts

*******************************************************

posecr:	ds.l	1	* pos courante sur ecr

code:
	lea	instr,a0
	move.l	dresultat,a1
	move.l	#0,posecr

	move.l	4(a0),d0
	sub.l	posecr,d0
	cmp.l	#0,d0
	beq	.pas_avance
	cmp.l	#8,d0
	bgt	.lea
.addq:
	add.l	d0,posecr
	subq.l	#1,d0
	lea	tab_addq,a3
	add.w	d0,d0
	move.w	(a3,d0),(a1)+
	bra	.pas_avance

.lea:
	move.w	#$41e8,(a1)+
	move.w	d0,(a1)+
	add.l	d0,posecr
.pas_avance:
boucle_code:
	cmp.l	#12*160+16-8,posecr
	blt	toto
*	illegal
toto:


	move.l	(a0),d0
	
	cmp.l	#1,d0
	beq	andld_orld
	
	cmp.l	#2,d0
	beq	andlr_orld
	
	cmp.l	#3,d0
	beq	andld_orlr
	
	cmp.l	#4,d0
	beq	andlr_orlr
	
	cmp.l	#5,d0
	beq	orld
	
	cmp.l	#6,d0
	beq	orlr
	
	cmp.l	#11,d0
	beq	andwd_orwd
	
	cmp.l	#12,d0
	beq	andwd_orwr
	
	cmp.l	#13,d0
	beq	andwr_orwd
	
	cmp.l	#14,d0
	beq	andwr_orwr
	
	cmp.l	#15,d0
	beq	orwd
	
	cmp.l	#16,d0
	beq	orwr
	
	cmp.l	#17,d0
	beq	andwd
	
	cmp.l	#18,d0
	beq	andwr
	
	cmp.l	#30,d0
	beq	moveld
	
	cmp.l	#31,d0
	beq	movelr
	
	cmp.l	#32,d0
	beq	movewd
	
	cmp.l	#33,d0
	beq	movewr
	
	cmp.l	#60,d0
	beq	moveq_d
	
	cmp.l	#61,d0
	beq	movew_d
	
	cmp.l	#62,d0
	beq	movel_d
	
	illegal

next_ins:
	move.l	24+4(a0),d0
	sub.l	posecr,d0
	cmp.l	#0,d0
	beq	.pas_avance
	cmp.l	#8,d0
	bgt	.lea
.addq:
	add.l	d0,posecr
	subq.l	#1,d0
	lea	tab_addq,a3
	add.w	d0,d0
	move.w	(a3,d0),(a1)+
	bra	.pas_avance

.lea:
	move.w	#$41e8,(a1)+
	move.w	d0,(a1)+
	add.l	d0,posecr
	
.pas_avance:
	lea	24(a0),a0
	cmp.l	finstr,a0
	blt	boucle_code
	rts
	
********************

moveq_d:
	move.l	8(a0),d0	* donnee
	move.l	12(a0),d7
	move.l	d7,d6
	move.l	d7,d5
	move.l	#$70,d2
	add.l	d7,d2
	add.l	d7,d2
	lsl.l	#8,d2
	add.b	d0,d2
	move.w	d2,(a1)+
	
	bsr	cherche_occl
	tst.b	d7
	bne	.trouve
	
	bsr	cherche_occw_l
	tst.b	d7
	bne	.trouve

	illegal	* si on ne trouve pas le registre dans liste_occ_l

.trouve	
	lea	garder_code,a2
	mulu	#16,d5
	add.l	d5,a2
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	#0,-12(a6)
	bra	next_ins


*************
	
movew_d:
	move.l	8(a0),d0
	move.l	12(a0),d7
	lea	tab_movew,a2
	move.l	d7,d6
	move.l	d7,d5
	add.l	d6,d6
	add.l	d6,d6
	move.w	(a2,d6.w),d6
	move.w	d6,(a1)+
	move.w	d0,(a1)+

	bsr	cherche_occl
	tst.b	d7
	bne	.trouve
	
	bsr	cherche_occw_l
	tst.b	d7
	bne	.trouve

	illegal	* si on ne trouve pas le registre dans liste_occ_l

.trouve	
	lea	garder_code,a2
	mulu	#16,d5
	add.l	d5,a2
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	#0,-12(a6)
	bra	next_ins

*************

movel_d:
	move.l	8(a0),d0
	move.l	12(a0),d7
	lea	tab_movel,a2
	move.l	d7,d6
	move.l	d6,d5
	mulu	#6,d6
	move.w	(a2,d6.w),d6
	move.w	d6,(a1)+
	move.l	d0,(a1)+

	bsr	cherche_occl
	tst.b	d7
	bne	.trouve
	
	illegal	* si on ne trouve pas le registre dans liste_occ_l

.trouve	
	lea	garder_code,a2
	mulu	#16,d5
	add.l	d5,a2
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	(a6)+,(a2)+
	move.l	#0,-12(a6)
	bra	next_ins

*************


andwd_orwd:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwd_orwd_lea

andwd_orwd_inc:
	move.w	#$250,(a1)+	* and.w #,(a0)
	move.w	16+2(a0),(a1)+
	move.w	#$0058,(a1)+	* or.w #,(a0)+
	move.w	14(a0),(a1)+
	add.l	#2,posecr
	bra	next_ins
	
andwd_orwd_lea:
	move.w	#$250,(a1)+	* and.w #,(a0)
	move.w	16+2(a0),(a1)+
	move.w	#$0050,(a1)+	* or.w #,(a0)
	move.w	14(a0),(a1)+
	bra	next_ins

****

andld_orld:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andld_orld_lea

andld_orld_inc:
	move.w	#$290,(a1)+	* and.l #,(a0)
	move.l	16(a0),(a1)+
	move.w	#$0098,(a1)+	* or.l #,(a0)+
	move.l	12(a0),(a1)+
	add.l	#4,posecr
	bra	next_ins
	
andld_orld_lea:
	move.w	#$290,(a1)+	* and.l #,(a0)
	move.l	16(a0),(a1)+
	move.w	#$090,(a1)+	* or.l #,(a0)
	move.l	12(a0),(a1)+
	bra	next_ins

****

andlr_orld:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andlr_orld_lea

andlr_orld_inc:	
	move.l	16(a0),d0
	bsr	quel_reg_l
	lea	tab_andld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.l dn,(a0)
	move.w	#$0098,(a1)+	* or.l #,(a0)+
	move.l	12(a0),(a1)+
	add.l	#4,posecr
	bra	next_ins
	
andlr_orld_lea:
	move.l	16(a0),d0
	bsr	quel_reg_l
	lea	tab_andld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.l dn,(a0)
	move.w	#$090,(a1)+	* or.l #,(a0)
	move.l	12(a0),(a1)+
	bra	next_ins

****

andld_orlr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andld_orlr_lea

andld_orlr_inc:	
	move.w	#$290,(a1)+	* and.l #,(a0) 
	move.l	16(a0),(a1)+
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)+
	add.l	#4,posecr
	bra	next_ins
	
andld_orlr_lea:
	move.w	#$290,(a1)+	* and.l #,(a0) 
	move.l	16(a0),(a1)+
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)
	bra	next_ins

****

andlr_orlr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andlr_orlr_lea

andlr_orlr_inc:	
	move.l	16(a0),d0
	bsr	quel_reg_l
	lea	tab_andld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.l dn,(a0)
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)+
	add.l	#4,posecr
	bra	next_ins
	
andlr_orlr_lea:
	move.l	16(a0),d0
	bsr	quel_reg_l
	lea	tab_andld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.l dn,(a0)
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)
	bra	next_ins

****

orld:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	orld_lea

orld_inc:
	move.w	#$0098,(a1)+	* or.l #,(a0)+
	move.l	12(a0),(a1)+
	add.l	#4,posecr
	bra	next_ins
	
orld_lea:
	move.w	#$090,(a1)+	* or.l #,(a0)
	move.l	12(a0),(a1)+
	bra	next_ins

****

orlr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	orlr_lea

orlr_inc:	
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)+
	add.l	#4,posecr
	bra	next_ins
	
orlr_lea:
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_orld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.l dn,(a0)
	bra	next_ins

****

andwd_orwr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwd_orwr_lea

andwd_orwr_inc:
	move.w	#$250,(a1)+	* and.w #,(a0)
	move.w	16+2(a0),(a1)+
	move.w	14(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)+
	add.l	#2,posecr
	bra	next_ins
	
andwd_orwr_lea:
	move.w	#$250,(a1)+	* and.w #,(a0)
	move.w	16+2(a0),(a1)+
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)
	bra	next_ins
	
****

andwr_orwd:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwr_orwd_lea

andwr_orwd_inc:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)
	move.w	#$0058,(a1)+	* or.w #,(a0)+
	move.w	14(a0),(a1)+
	add.l	#2,posecr
	bra	next_ins
	
andwr_orwd_lea:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)
	move.w	#$0050,(a1)+	* or.w #,(a0)
	move.w	14(a0),(a1)+
	bra	next_ins
	
****

andwr_orwr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwr_orwr_lea

andwr_orwr_inc:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)+
	add.l	#2,posecr
	bra	next_ins
	
andwr_orwr_lea:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)
	bra	next_ins

****

orwd:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	orwd_lea

orwd_inc:
	move.w	#$0058,(a1)+	* or.w #,(a0)+
	move.w	14(a0),(a1)+
	add.l	#2,posecr
	bra	next_ins
	
orwd_lea:
	move.w	#$0050,(a1)+	* or.w #,(a0)
	move.w	14(a0),(a1)+
	bra	next_ins

****

orwr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	orwr_lea

orwr_inc:
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)+
	add.l	#2,posecr
	bra	next_ins
	
orwr_lea:
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_orwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* or.w dn,(a0)
	bra	next_ins

	
****

andwr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwr_lea

andwr_inc:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)+
	add.l	#2,posecr
	bra	next_ins
	
andwr_lea:
	move.w	18(a0),d0
	bsr	quel_reg_w
	lea	tab_andwd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* and.w dn,(a0)
	bra	next_ins

****

andwd:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	andwd_lea

andwd_inc:
	move.w	#$0258,(a1)+	* and.w #,(a0)+
	move.w	18(a0),(a1)+
	add.l	#2,posecr
	bra	next_ins
	
andwd_lea:
	move.w	#$0250,(a1)+	* and.w #,(a0)
	move.w	18(a0),(a1)+
	bra	next_ins


moveld:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	moveld_lea

moveld_inc:
	move.w	#$20fc,(a1)+	* move.l #,(a0)+
	move.l	12(a0),(a1)+
	add.l	#4,posecr
	bra	next_ins

moveld_lea:
	move.w	#$20bc,(a1)+	* move.l #,(a0)
	move.l	12(a0),(a1)+
	bra	next_ins

movewd:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	movewd_lea

movewd_inc:
	move.w	#$30fc,(a1)+	* move.w #,(a0)+
	move.w	14(a0),(a1)+
	add.l	#2,posecr
	bra	next_ins

movewd_lea:
	move.w	#$30bc,(a1)+	* move.w #,(a0)
	move.w	14(a0),(a1)+
	bra	next_ins

	
****

movelr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	movelr_lea

movelr_inc:
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_moveld_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* move.l dn,(a0)+
	add.l	#4,posecr
	bra	next_ins
	
movelr_lea:
	move.l	12(a0),d0
	bsr	quel_reg_l
	lea	tab_moveld_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* move.l dn,(a0)
	bra	next_ins


movewr:
	move.l	24+4(a0),d1
	sub.l	4(a0),d1
	cmp.l	#4,d1
	bgt	movewr_lea

movewr_inc:
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_movewd_post,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* move.w dn,(a0)+
	add.l	#2,posecr
	bra	next_ins
	
movewr_lea:
	move.l	12(a0),d0
	bsr	quel_reg_w
	lea	tab_movewd_direct,a3
	add.w	d7,d7
	move.w	(a3,d7.w),(a1)+	* move.w dn,(a0)
	bra	next_ins



	
met_occ_in_movem:

	lea	garder,a0
	lea	garder_code,a1

.loop25:
	cmp.l	#0,(a0)
	beq	.next1
	cmp.l	#2,12(a0)
	beq	.next2
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
.next2:
	lea	16(a0),a0
	bra	.loop25
.next1:

	lea	garder,a0
.loop3:
	cmp.l	#0,(a0)
	beq	.next12
	cmp.l	#4,12(a0)
	beq	.next22
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
.next22:
	lea	16(a0),a0
	bra	.loop3
.next12:

	lea	garder_code,a0
	lea	garder,a1
	move.w	#7,d0
.loop4:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.loop4

	lea	garder,a0
	lea	movem,a1
	moveq	#0,d7
.loop1:
	tst.l	(a0)
	beq	.fin


	move.l	12(a0),d0
	cmp.l	#4,d0
	bne	.pas_movem

	move.l	(a0),(a1)+
	addq.l	#1,d7
	
.pas_movem:
	lea	16(a0),a0
	cmp.l	#8,d7
	blt	.loop1
	
.fin:
	move.l	a1,debut_code
	tst.l	d7
	beq	.pas_de_movem

	move.l	d7,d6
	mulu	#6,d6
	lea	tab_movem,a2
	move.l	(a2,d6.w),d6
	move.l	a1,d2
	move.l	d6,(a1)+	* movem.l
	sub.l	#movem,d2
	add.l	#4,d2
	neg.w	d2
	move.w	d2,(a1)+	*         d(pc)
	

.pas_de_movem:
	lea	garder,a0

.loop2:
	tst.l	(a0)
	beq	.fin2

	move.l	12(a0),d0
	cmp.l	#2,d0
	bne	.pas_movew

	move.l	(a0),d0
	cmp.w	#127,d0
	bgt	.pas_moveq

	cmp.w	#-128,d0
	blt	.pas_moveq

.moveq:
	move.l	#$70,d2
	add.l	d7,d2
	add.l	d7,d2
	lsl.l	#8,d2
	add.b	d0,d2
	move.w	d2,(a1)+
	add.l	#1,d7
	
	bra	.pas_movew

.pas_moveq:
	lea	tab_movew,a2
	move.l	d7,d6
	mulu	#4,d6
	move.w	(a2,d6.w),d6
	move.w	d6,(a1)+
	swap	d0
	move.w	d0,(a1)+
	add.l	#1,d7

.pas_movew:
	lea	16(a0),a0
	cmp.l	#8,d7
	blt	.loop2
.fin2:
	move.l	a1,dresultat
	move.l	debut_code,a1
	lea	adresse,a0
	sub.l	a0,a1
	move.l	a1,adresse

make_garder_code:
	lea	garder,a0
	lea	garder_code,a1

.loop1:
	move.l	(a0),d0
	tst.l	d0
	beq	.fin
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmp.l	#fgarder,a0
	blt	.loop1
.fin:
	rts
	

****************************************************************************
****************************************************************************
****************************************************************************

quel_reg_l:
	movem.l	a0/d6,-(sp)
	lea	garder_code,a0
	move.w	#0,d7
	move.w	#7,d6

.loop1:
	cmp.l	(a0),d0
	beq.s	.trouve
	add.l	#1,d7
	lea	16(a0),a0
	dbf	d6,.loop1
	illegal

.trouve:
	sub.l	#2,8(a0)
	movem.l	(sp)+,a0/d6
	rts

quel_reg_w:
	movem.l	a0/d6,-(sp)
	lea	garder_code,a0
	move.w	#0,d7
	move.w	#7,d6

.loop1:
	cmp.w	2(a0),d0
	beq.s	.trouve
	lea	16(a0),a0
	add.l	#1,d7
	dbf	d6,.loop1
	illegal

.trouve:
	sub.l	#1,8(a0)
	movem.l	(sp)+,a0/d6
	rts

ligne:	ds.l	1	* ligne courante

remplis_instr:

	move.l	#0,ligne
	lea	pred2,a0
	lea	instr,a1
	move.l	#0,offset
	move.l	#1,plan

boucle:
*	lea	instr+$30,a2
	cmp.l	#pred2+24*29,a0
	blt	yo
*	illegal
yo:
	move.l	#0,typed
	move.l	#0,typem
	move.l	#0,totald
	move.l	#0,totalm



	move.l	(a0),d0
	move.l	d0,donnee
	
	bsr	calc_msk
	move.l	d7,masque

*	cmp.l	#$10001,d7
*	bne	.ok4
*	illegal
*.ok4
	cmp.w	#0,d7
	beq	move

	cmp.w	#-1,d7
	beq	vide

	tst.w	d0
	beq	pas_or_l_and_l	* donne=0.w

	swap	d0
	tst.w	d0
	beq	pas_or_l_and_l	* ou donne=0000xxxx
	swap	d0
	bsr	cherche_l	* si occurence de donnee
	tst.b	d7
	beq	pas_or_l_dn *pas de registres pour donnee

dn_pour_or_l:

	swap	d0
	move.w	d0,d1
	swap	d0
	cmp.w	d0,d1
	beq	.pas_and_l	* si haut=bas ==> pas de and.l

	move.l	masque,d7
	move.l	d0,d1
	move.l	d7,d0
	move.l	d7,d6
	bsr	cherche_l	* occurence de masque

	tst.b	d7
	beq	.pas_dn_pour_and_l

.dn_pour_and_l:

	cmp.l	d6,d1
	bne	.pas_1_seul_registre_pour_donne_et_msk

.1_seul_registre_pour_donne_et_msk:

	move.l	#4,(a1)+	* instr: and.l dn/or.l dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#2,totald
	bra	next_one
	

.pas_1_seul_registre_pour_donne_et_msk:

	move.l	#4,(a1)+	* instr: and.l dn/or.l dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#2,totald
	bra	next_one
	
.pas_dn_pour_and_l:
	
	move.l	#3,(a1)+	* instr: and.l #/or.l dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#0,typem
	move.l	#2,totalm
	move.l	#2,totald
	bra	next_one

.pas_and_l:

	move.l	#6,(a1)+	* instr: or.l dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#2,totald
	bra	next_one


pas_or_l_dn:
*	swap	d0
*	move.w	d0,d1
*	swap	d0
*	cmp.w	d0,d1
*	beq	.pas_and_l	* si haut=bas ==> pas de and.l

	bsr	calc_msk	* masque dans d7
	move.l	d0,d1
	move.l	d7,d0
	move.l	d7,d6
	bsr	cherche_l	* occurence de masque

	tst.b	d7
	beq	.pas_dn_pour_and_l

.dn_pour_and_l:

	move.l	#2,(a1)+	* instr: and.l dn/or.l #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#2,totald
	bra	next_one
	
.pas_dn_pour_and_l:
	
	move.l	#1,(a1)+	* instr: and.l #/or.l #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.l	#-1,(a1)+	* pas de registre
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#2,totald
	bra	next_one

.pas_and_l:

	move.l	#5,(a1)+	* instr: or.l #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.l	#-1,(a1)+	* numero de registre donnee
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#4,typem
	move.l	#0,totalm
	move.l	#2,totald
	bra	next_one

pas_or_l_and_l:		* and.l / or.w ????

	cmp.l	#3,plan	* si on est sur 3 eme plan 
	beq	.plan3	* pas de and sur 4 eme plan

	move.l	donnee,d0
	swap	d0
	tst.w	d0
	beq	pas_or_l

	move.l	d0,donnee
	bra	pas_seul_and_w

.plan3:
*	swap	d0
	move.l	d0,donnee
	bra	pas_or_l


	bsr	cherche_w
	tst.b	d7
	beq	.pas_dn_pr_or_w
.dn_pr_or_w:
	move.l	masque,d0
	bsr	cherche_l
	tst.b	d7
	beq.s	.dn_pr_or_w_diese_pr_and_l

.dn_pr_or_w_dn_pr_and_l:
	move.l	#27,(a1)+	* instr: and.l dn/or.w dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#2,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#1,totald
	bra	next_one
	
.dn_pr_or_w_diese_pr_and_l:
	move.l	#25,(a1)+	* instr: and.l #/or.w dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#2,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#1,totald
	bra	next_one

.pas_dn_pr_or_w:
	move.l	masque,d0
	bsr	cherche_l
	tst.b	d7
	beq.s	.diese_pr_or_w_diese_pr_and_l

.diese_pr_or_w_dn_pr_and_l:
	move.l	#26,(a1)+	* instr: and.l dn/or.w #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+	* numero de registre masque
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#2,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#1,totald
	bra	next_one
	
.diese_pr_or_w_diese_pr_and_l:
	move.l	#24,(a1)+	* instr: and.l #/or.w #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.l	#-1,(a1)+	* numero de registre donnee
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#2,typed
	move.l	#4,typem
	move.l	#2,totalm
	move.l	#1,totald
	bra	next_one


pas_or_l:
	move.l	donnee,d0
	bsr	calc_msk
	move.l	d7,masque
	swap	d0
	tst.w	d0
	bne	pas_seul_and_w

	move.l	masque,d0
	bsr	cherche_w
	tst.b	d7
	beq	.pas_dn_pr_and_w_seul

.dn_pr_and_w_seul:
	move.l	#18,(a1)+	* and.w dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+	* numero de registre donnee
	move.w	#-1,(a1)+	* numero de registre donnee
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#0,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#0,totald
	bra	next_one

.pas_dn_pr_and_w_seul:
*	illegal
	move.l	#17,(a1)+	* and.w #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.l	#-1,(a1)+	* numero de registre donnee
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#0,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#0,totald
	bra	next_one

pas_seul_and_w:	
*	illegal		* WARNIG : bug possible !
	move.l	donnee,d0
	cmp.l	#3,plan
	bne	.pas_seul_or_w
	swap	d0
	move.l	d0,donnee
	moveq	#0,d1
	move.w	-4(a0),d1
	move.w	-2(a0),d2
	or.w	d2,d1
	move.w	(a0),d2		* d1=1er P or 2eme P
	move.w	d2,d3		* d2=3eme P
	eor.w	d1,d3
	or.w	d1,d3
	cmp.w	d2,d3		* test d'inclusion bit
				* a bit d'une donn‚e
				* dans une autre
	bne	.pas_seul_or_w
.ok3:	bsr	cherche_w
	tst.b	d7
	beq	.pas_dn_or_w_seul

.dn_or_w_seul:
	move.l	#16,(a1)+	* or.w dn
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#1,totald
	bra	next_one
	
.pas_dn_or_w_seul:
*	illegal
	move.l	#15,(a1)+	* or.w #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#1,totald
	bra	next_one

.pas_seul_or_w:
	move.l	donnee,d0
	bsr	cherche_w
	tst.b	d7
	beq	.pas_dn_or_w
.dn_or_w:
	move.l	masque,d0
	bsr	cherche_w
	tst.b	d7
	beq	.dn_or_w_diese_and_w

.dn_or_w_dn_and_w:
	move.l	#14,(a1)+	* and.w dn/or.w dn 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#1,totald
	bra	next_one

.dn_or_w_diese_and_w:
	move.l	#12,(a1)+	* and.w #/or.w dn 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#1,totald
	bra	next_one

.pas_dn_or_w:
	move.l	masque,d0
	bsr	cherche_w
	tst.b	d7
	beq	.diese_or_w_diese_and_w

.diese_or_w_dn_and_w:
	move.l	#13,(a1)+	* and.w dn/or.w # 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#1,totald
	bra	next_one

.diese_or_w_diese_and_w:
	move.l	#11,(a1)+	* and.w #/or.w # 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	masque,(a1)+	* masque
	move.l	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#2,typem
	move.l	#1,totalm
	move.l	#1,totald
	bra	next_one

move:
	move.l	donnee,d0
	bsr	cherche_l
	tst.b	d7
	beq.s	.pas_dn_move_l

.dn_move_l:
	move.l	#31,(a1)+	* move.l dn 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#2,totald
	bra	.next_move
	
.pas_dn_move_l:
	move.l	#30,(a1)+	* move.l #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#2,plan
	add.l	#4,offset
	lea	4(a0),a0
	move.l	#4,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#2,totald
	bra	.next_move

.next_move:
	moveq	#0,d0
	move.w	(a0),d0
	move.l	d0,donnee
	
	move.l	donnee,d0
	bsr	cherche_w
	tst.b	d7
	beq.s	.pas_dn_move_w

.dn_move_w:
	move.l	#33,(a1)+	* move.w dn 
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#1,totald
	bra	next_one
	
.pas_dn_move_w:
	move.l	#32,(a1)+	* move.w #
	move.l	offset,(a1)+	* offset_ecran
	move.l	plan,(a1)+		* plan
	move.l	donnee,(a1)+	* donnee
	move.l	#0,(a1)+		* masque
	move.w	#-1,(a1)+
	move.w	#-1,(a1)+
	add.l	#1,plan
	add.l	#2,offset
	lea	2(a0),a0
	move.l	#2,typed
	move.l	#0,typem
	move.l	#0,totalm
	move.l	#1,totald
	bra	next_one

totalm:	ds.l	1
totald:	ds.l	1
typed:	ds.l	1
typem:	ds.l	1

mema0:	ds.l	1
mema1:	ds.l	1



vide:	add.l	#4,plan
	add.l	#6,offset
	lea	6(a0),a0


next_one:
	move.l	a0,mema0
	move.l	a1,mema1
gere_occurence_donnee:

	move.l	donnee,d0

	tst.l	typed
	beq	gere_occurence_masque

	cmp.l	#2,typed
	bne	long_occd
	
word_occd:		* decremente .w
	bsr	cherche_occw_l

	tst.b	d7
	beq	gere_occurence_masque

	move.l	4(a6),d1
	sub.l	totald,d1	* on decremente
	move.l	d1,4(a6)
	bsr	make_garder

	cmp.l	#0,nouvelle
	beq	.vas_y_mon_pote

	move.l	adr_nouv,a6

	cmp.l	#2,12(a6)
	bne	.long
	moveq	#0,d0
	move.w	2(a6),d0
	bra	.ya
.long:
	move.l	(a6),d0
.ya:
	move.l	d0,donnee
	move.l	a6,d6
	sub.l	#garder,d6
	divu	#16,d6

.tst_taille:	
	cmp.l	#127,d0
	bgt	.pas_moveq
	
	cmp.l	#-128,d0
	blt	.pas_moveq

	move.l	#60,d4
	bra	.put_in

.pas_moveq:
	cmp.l	#2,12(a6)
	bne	.pas_movew
	move.l	#61,d4
	bra	.put_in
	
.pas_movew:
	move.l	#62,d4

.put_in:
	move.l	mema1,a1
	move.l	d4,(a1)+
	move.l	offset,(a1)+
	move.l	donnee,(a1)+
	move.l	d6,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	a1,mema1

.vas_y_mon_pote:
	bra	gere_occurence_masque

long_occd:
	bsr	cherche_occl
	tst.b	d7
	beq	real_next_one
	move.l	4(a6),d1
	sub.l	totald,d1
	move.l	d1,4(a6)
	bsr	make_garder

	cmp.l	#0,nouvelle
	beq	.vas_y_mon_pote

	move.l	adr_nouv,a6

	cmp.l	#2,12(a6)
	bne	.long
	illegal		* use in .l en load in .w
	bra	.ya
.long:
	move.l	(a6),d0
.ya:

	move.l	d0,donnee
	move.l	a6,d6
	sub.l	#garder,d6
	divu	#16,d6

.tst_taille:	
	cmp.l	#127,d0
	bgt	.pas_moveq
	
	cmp.l	#-128,d0
	blt	.pas_moveq

	move.l	#60,d4
	bra	.put_in

.pas_moveq:
	cmp.l	#2,12(a6)
	bne	.pas_movew
	illegal		* on utilise en long un .w seulement
			*    ====> BIG BUG !!!
*	move.l	#61,d4
	bra	.put_in
	
.pas_movew:
	move.l	#62,d4

.put_in:
	move.l	mema1,a1
	move.l	d4,(a1)+
	move.l	offset,(a1)+
	move.l	donnee,(a1)+
	move.l	d6,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	a1,mema1

.vas_y_mon_pote:

gere_occurence_masque:

	move.l	masque,d0

	tst.l	typem
	beq	real_next_one

	cmp.l	#2,typem
	bne	long_occm
	
word_occm:
	bsr	cherche_occw_l
	tst.b	d7
	beq	real_next_one
	move.l	4(a6),d1
	sub.l	totalm,d1
	move.l	d1,4(a6)
	bsr	make_garder

	cmp.l	#0,nouvelle
	beq	.vas_y_mon_pote

	move.l	adr_nouv,a6
	cmp.l	#2,12(a6)
	bne	.long
	moveq	#0,d0
	move.w	2(a6),d0
	bra	.ya
.long:
	move.l	(a6),d0
.ya:
	move.l	d0,donnee

	move.l	a6,d6
	sub.l	#garder,d6
	divu	#16,d6

.tst_taille:	
	cmp.l	#127,d0
	bgt	.pas_moveq
	
	cmp.l	#-128,d0
	blt	.pas_moveq

	move.l	#60,d4
	bra	.put_in

.pas_moveq:
	cmp.l	#2,12(a6)
	bne	.pas_movew
	move.l	#61,d4
	bra	.put_in
	
.pas_movew:
	move.l	#62,d4

.put_in:
	move.l	mema1,a1
	move.l	d4,(a1)+
	move.l	offset,(a1)+
	move.l	donnee,(a1)+
	move.l	d6,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	a1,mema1

.vas_y_mon_pote:

	bra	real_next_one

long_occm:
	bsr	cherche_occl
	tst.b	d7
	beq	real_next_one
	move.l	4(a6),d1
	sub.l	totalm,d1
	move.l	d1,4(a6)
	bsr	make_garder

	cmp.l	#0,nouvelle
	beq	.vas_y_mon_pote

	move.l	adr_nouv,a6
	cmp.l	#2,12(a6)
	bne	.long
	illegal		* use en .l et en .w ds liste_occ
	bra	.ya
.long:
	move.l	(a6),d0
.ya:
	move.l	d0,donnee

	move.l	a6,d6
	sub.l	#garder,d6
	divu	#16,d6

.tst_taille:	
	cmp.l	#127,d0
	bgt	.pas_moveq
	
	cmp.l	#-128,d0
	blt	.pas_moveq

	move.l	#60,d4
	bra	.put_in

.pas_moveq:
	cmp.l	#2,12(a6)
	bne	.pas_movew
	illegal	
*	move.l	#61,d4
	bra	.put_in
	
.pas_movew:
	move.l	#62,d4

.put_in:
	move.l	mema1,a1
	move.l	d4,(a1)+
	move.l	offset,(a1)+
	move.l	donnee,(a1)+
	move.l	d6,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	a1,mema1
.vas_y_mon_pote:

real_next_one:
	move.l	mema0,a0
	move.l	mema1,a1

	cmp.l	#3,plan
	ble	.ok_plan

	add.l	#2,offset
	lea	2(a0),a0
	move.l	#1,plan
	move.l	offset,d0
	move.l	d0,d1
	divu	#160,d1
	mulu	#160,d1
	sub.l	d1,d0

.cont2:
	cmp.l	#((largeur/2)+8),d0
	blt	.pas_change_ligne

	add.l	#160,d1
	move.l	d1,offset	* au debut de la ligne suivante
	add.l	#1,ligne

.pas_change_ligne:
.ok_plan:
	move.l	offset,d0
	cmp.l	#hauteur*160,d0
	blt	boucle
	move.l	a1,finstr
	rts

*********** comptage des occurences des donn‚es et des masques  *********


compte_occ:

	lea	pred2,a0
	lea	liste_occl,a1
	lea	liste_occw,a2

	move.l	a1,flistel
	move.l	a2,flistew

main_compte:

	move.l	a0,a4
	move.l	#2,d5
compte_occw:
	moveq	#1,d6
	moveq	#0,d0
	move.w	2(a0),d0


	tst.w	d0
	bne	.humungus1

	tst.l	d7
	bne	.donnee_existe_w
	
.humungus1:


	bsr	cherche_occw

	tst.b	d7
	bne	.donnee_existe_w

	lea	8(a0),a3

.loop1:
	cmp.w	2(a3),d0
	bne	.pas_donnee_w
	add.l	#1,d6
	move.l	#2,d5

.pas_donnee_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop1



*****************

* calcul pour si donnee.w se retrouve en mask

.donneew_egal_mask:

	lea	8(a0),a3
	cmp.w	#-1,d0
	beq	.egal_ff
	
.loop3:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#1,d6
	move.l	#4,d5
.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop3

.egal_ff

	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.l	d6,(a2)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a2)+
	move.l	d5,(a2)+
	move.l	a2,flistew

.donnee_existe_w:

*****************

compte_occl:
	move.l	a4,a0
	moveq	#2,d6
.ici:	move.l	(a0),d0

	tst.l	d0
	bne	.ya1
	move.l	a0,d4
	sub.l	#pred2,d4
	lsr.l	#3,d4
	lsl.l	#3,d4
	add.l	#pred2,d4
	move.l	d4,a4
	cmp.l	#0,(a4)
	bne	.ya1
	cmp.l	#0,4(a4)
	bne	.donnee_existe_l
	
.ya1:	

	swap	d0
	tst.w	d0
	bne	.tst2
	move.l	d0,d1
	bsr	calc_msk
	move.l	d1,d0
	swap	d0
	cmp.l	#-0,d7
	beq	.tst3
	lea	2(a0),a0
	bra	.ici
	

.tst2:
	swap	d0
	bsr	cherche_occl

	tst.b	d7
	bne	.donnee_existe_l
.tst3:
	lea	4(a0),a3

.loop1:
	cmp.l	(a3),d0
	bne	.pas_donnee_l
	add.l	#2,d6

.pas_donnee_l:
	lea	4(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop1


*****************


	move.l	d0,(a1)+
	move.l	d6,(a1)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a1)+
	move.l	#4,(a1)+
	move.l	a1,flistel

.donnee_existe_l:
	lea	4(a0),a0

compte_mask:
	move.l	#2,d5
	move.l	a4,a0

	moveq	#0,d1
	move.w	(a0),d1
	move.w	2(a0),d2
	or.w	d2,d1
	move.w	4(a0),d2		* d1=1er P or 2eme P
	move.w	d2,d3		* d2=3eme P
	eor.w	d1,d3
	or.w	d1,d3
	cmp.w	d2,d3		* test d'inclusion bit
				* a bit d'une donn‚e
				* dans une autre
	bne	.pas_seul_or_w
	tst.w	(a0)
	beq	.mask_existe_w

.pas_seul_or_w:
	moveq	#1,d6
	moveq	#0,d0
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0

	tst.w	d0
	beq	.mask_existe_w

	cmp.w	#-1,d0
	beq	.mask_existe_w

	bsr	cherche_occw

	tst.b	d7
	bne	.mask_existe_w

	lea	8(a0),a3

.loop1:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#1,d6
	move.l	#2,d5
.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop1


	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.l	d6,(a2)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a2)+
	move.l	d5,(a2)+
	move.l	a2,flistew

.mask_existe_w:


compte_maskl:
	move.l	#4,d5
	move.l	a4,a0

	moveq	#0,d1
	move.w	(a0),d1
	move.w	2(a0),d2
	or.w	d2,d1
	move.w	4(a0),d2		* d1=1er P or 2eme P
	move.w	d2,d3		* d2=3eme P
	eor.w	d1,d3
	or.w	d1,d3
	cmp.w	d2,d3		* test d'inclusion bit
				* a bit d'une donn‚e
				* dans une autre
	bne	.pas_seul_or_w
	tst.w	(a0)
	beq	.mask_existe_l
	tst.w	2(a0)
	beq	.mask_existe_l

.pas_seul_or_w:

	moveq	#2,d6
	moveq	#0,d0
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0

	tst.w	d0
	beq	.mask_existe_l

	cmp.w	#-1,d0
	beq	.mask_existe_l

	bsr	cherche_occl

	tst.b	d7
	bne	.mask_existe_l

	lea	8(a0),a3

.loop1:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#2,d6
	move.l	#4,d5

.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop1

	lea	(a0),a3

.loop11:
	cmp.w	(a3),d0
	bne	.pas_donnee_w1
	add.l	#1,d6
	move.l	#4,d5

.pas_donnee_w1:
	lea	2(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop11


	lea	(a0),a3

.loop12:
	cmp.l	(a3),d0
	bne	.pas_donnee_l1
	add.l	#2,d6
	move.l	#4,d5

.pas_donnee_l1:
	lea	4(a3),a3
	cmp.l	#fpred2,a3
	blt	.loop12

	move.l	d0,(a1)+
	move.l	d6,(a1)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	move.l	a1,flistel




.mask_existe_l:
	move.l	a4,a0
	lea	8(a0),a0
	cmp.l	#fpred2,a0
	blt	main_compte

	rts




**************************************
**************************************
**************************************

compte_occ6:

	lea	pred2,a0
	lea	liste_occl,a1
	lea	liste_occw,a2

	move.l	a1,flistel
	move.l	a2,flistew

main_compte6:

	move.l	a0,a4
*	move.w	#2,d1
	move.l	#2,d5
compte_occw6:
	moveq	#1,d6
	moveq	#0,d0
	move.w	2(a0),d0

	move.l	d0,d1
	bsr	calc_msk

	tst.w	d0
	bne	.humungus1

	tst.l	d7
	bne	.donnee_existe_w
	
.humungus1:
	bsr	cherche_occw

	tst.b	d7
	bne	.donnee_existe_w

	lea	8(a0),a3

.loop1:
	cmp.w	2(a3),d0
	bne	.pas_donnee_w
	add.l	#1,d6
	move.l	#2,d5

.pas_donnee_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop1



*****************

* calcul pour si donnee.w se retrouve en mask

.donneew_egal_mask6:

	lea	8(a0),a3
	
.loop3:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#1,d6
	move.l	#4,d5
.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop3



	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.l	d6,(a2)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a2)+
	move.l	d5,(a2)+
	move.l	a2,flistew

.donnee_existe_w:

*****************

compte_occl6:
	move.l	a4,a0
	moveq	#2,d6
.ici:	move.l	(a0),d0

	tst.l	d0
	bne	.ya1
	move.l	a0,d4
	sub.l	#pred2,d4
	lsr.l	#3,d4
	lsl.l	#3,d4
	add.l	#pred2,d4
	move.l	d4,a4
	cmp.l	#0,(a4)
	bne	.ya1
	cmp.l	#0,4(a4)
	bne	.donnee_existe_l
	
.ya1:	

	swap	d0
	tst.w	d0
	bne	.tst2
	move.l	d0,d1
	bsr	calc_msk
	move.l	d1,d0
	swap	d0
	cmp.l	#0,d7
	beq	.tst3
	lea	2(a0),a0
	bra	.ici
	

.tst2:
	swap	d0
	bsr	cherche_occl

	tst.b	d7
	bne	.donnee_existe_l
.tst3:
	lea	4(a0),a3

.loop1:
	cmp.l	(a3),d0
	bne	.pas_donnee_l
	add.l	#2,d6

.pas_donnee_l:
	lea	4(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop1


*****************


	move.l	d0,(a1)+
	move.l	d6,(a1)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a1)+
	move.l	#4,(a1)+
	move.l	a1,flistel

.donnee_existe_l:
	lea	4(a0),a0

compte_mask6:
	move.l	#2,d5
	move.l	a4,a0

	moveq	#0,d1
	move.w	(a0),d1
	move.w	2(a0),d2
	or.w	d2,d1
	move.w	4(a0),d2		* d1=1er P or 2eme P
	move.w	d2,d3		* d2=3eme P
	eor.w	d1,d3
	or.w	d1,d3
	cmp.w	d2,d3		* test d'inclusion bit
				* a bit d'une donn‚e
				* dans une autre
	bne	.pas_seul_or_w
	tst.w	(a0)
	beq	.mask_existe_w
*	bra	.mask_existe_w

.pas_seul_or_w:
	moveq	#1,d6
	moveq	#0,d0
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0

	tst.w	d0
	beq	.mask_existe_w

	cmp.w	#-1,d0
	beq	.mask_existe_w

	bsr	cherche_occw

	tst.b	d7
	bne	.mask_existe_w

	lea	8(a0),a3

.loop1:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#1,d6
	move.l	#2,d5
.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop1

	lea	(a0),a3

.loop11:
	cmp.w	(a3),d0
	bne	.pas_donnee_w1
	add.l	#1,d6
	move.l	#2,d5

.pas_donnee_w1:
	lea	2(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop11


	lea	(a0),a3

.loop12:
	cmp.l	(a3),d0
	bne	.pas_donnee_l1
	add.l	#2,d6
	move.l	#4,d5

.pas_donnee_l1:
	lea	4(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop12



	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.l	d6,(a2)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a2)+
	move.l	d5,(a2)+
	move.l	a2,flistew

.mask_existe_w:


compte_maskl6:
	move.l	#4,d5
	move.l	a4,a0

	moveq	#0,d1
	move.w	(a0),d1
	move.w	2(a0),d2
	or.w	d2,d1
	move.w	4(a0),d2		* d1=1er P or 2eme P
	move.w	d2,d3		* d2=3eme P
	eor.w	d1,d3
	or.w	d1,d3
	cmp.w	d2,d3		* test d'inclusion bit
				* a bit d'une donn‚e
				* dans une autre
	bne	.pas_seul_or_w
	tst.w	(a0)
	beq	.mask_existe_l
	tst.w	2(a0)
	beq	.mask_existe_l

.pas_seul_or_w:

	moveq	#2,d6
	moveq	#0,d0
	move.w	(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0

	tst.w	d0
	beq	.mask_existe_l

	cmp.w	#-1,d0
	beq	.mask_existe_l

	bsr	cherche_occl

	tst.b	d7
	bne	.mask_existe_l

	lea	8(a0),a3

.loop1:
	move.w	(a3),d1
	or.w	2(a3),d1
	or.w	4(a3),d1
	or.w	6(a3),d1
	not.w	d1
	cmp.w	d1,d0
	bne	.pas_mask_w
	add.l	#2,d6
	move.l	#4,d5

.pas_mask_w:
	lea	8(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop1

	lea	(a0),a3

.loop11:
	cmp.w	(a3),d0
	bne	.pas_donnee_w1
	add.l	#1,d6
	move.l	#4,d5

.pas_donnee_w1:
	lea	2(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop11


	lea	(a0),a3

.loop12:
	cmp.l	(a3),d0
	bne	.pas_donnee_l1
	add.l	#2,d6
	move.l	#4,d5

.pas_donnee_l1:
	lea	4(a3),a3
	cmp.l	#fpred2,a3
*	cmp.l	#pred2+6*((largeur/2)+8),a3
	blt	.loop12

	move.l	d0,(a1)+
	move.l	d6,(a1)+
	move.l	a0,d0
	bsr	no_ligne
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	move.l	a1,flistel




.mask_existe_l:
	move.l	a4,a0
	lea	8(a0),a0
	cmp.l	#pred2+ligne_debut*((largeur/2)+8),a0
	blt	main_compte6

	rts




**************************************
**************************************
**************************************




cherche_occl:
	lea	liste_occl,a6
	moveq	#0,d7
.loop1:
*	add.w	#1,$ffff8240.w
	cmp.l	(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	cmp.l	flistel,a6
	blt	.loop1
	rts

.trouve:
	move.l	#1,d7
	rts

cherche_occw:
	lea	liste_occw,a6
	moveq	#0,d7
.loop1:
*	add.w	#1,$ffff8240.w
	cmp.w	2(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	cmp.l	flistew,a6
	blt	.loop1
	rts

.trouve:
	move.l	#1,d7
	rts

cherche_occw_l:
	lea	liste_occl,a6
	moveq	#0,d7
.loop1:
*	add.w	#1,$ffff8240.w
	cmp.w	2(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	cmp.l	flistel,a6
	blt	.loop1
	rts

.trouve:
	move.l	#1,d7
	rts


no_ligne:
	move.l	d0,d7
	sub.l	#pred2,d7
	divu	#(largeur/2)+8,d7
	swap	d7
	move.w	#0,d7
	swap	d7
	rts

**********************************************

elimine:
	lea	liste_occw,a1
	lea	liste_occl,a0

main_elimine:
	move.l	(a0),d0
	move.l	a1,a2
.loop1:
	cmp.w	2(a2),d0
	bne	.pas_le_meme

	bsr	y_a_il_plus_grande_occ
	tst.b	d7
	bne	.pas_le_meme

	move.l	4(a0),d1
	add.l	4(a2),d1
	move.l	d1,4(a0)
	move.l	8(a0),d1
	cmp.l	8(a2),d1
	bgt	.w_plus_tot
	move.l	d1,8(a0)
	bra	.plus_tot_ok

.w_plus_tot:
	move.l	8(a2),8(a0)

.plus_tot_ok:
	move.w	#0,(a2)

.pas_le_meme:
	lea	16(a2),a2
	cmp.l	flistew,a2
	blt	.loop1
	lea	16(a0),a0
	cmp.l	flistel,a0
	blt	main_elimine

	lea	liste_occw,a1
elimine_w:
	move.w	(a1),d0

	tst.w	d0
	beq	.deja_compte

	move.l	(a1),(a0)+
	move.l	4(a1),(a0)+
	move.l	8(a1),(a0)+
	move.l	12(a1),(a0)+

.deja_compte:
	lea	16(a1),a1
	cmp.l	flistew,a1
	blt	elimine_w
	move.l	a0,flistel
	rts

y_a_il_plus_grande_occ:

	movem.l	d0-d1,-(sp)
	moveq	#0,d7
	lea	liste_occl,a6
	move.l	(a0),d0
	move.l	4(a0),d1
.loop1:
	cmp.w	2(a6),d0
	bne	.next
	cmp.l	4(a6),d1
	bge	.next
	move.l	#1,d7
	bra	.out

.next:
	lea	16(a6),a6
	cmp.l	flistel,a6
	blt	.loop1
	movem.l	(sp)+,d0-d1
	rts

.out:
	movem.l	(sp)+,d0-d1
	rts

********************************************************
* elimine occurence trop faible

elimine2:
	lea	liste_occl,a0

.loop1:
	move.l	12(a0),d0
	cmp.l	#2,d0
	bne	.long

	cmp.l	#2,4(a0)
	bge	.ca_passe

	moveq	#0,d1
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	bra	.next

.long:
	cmp.l	#3,4(a0)
	bge	.ca_passe

	moveq	#0,d1
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	bra	.next
.ca_passe:
	lea	16(a0),a0
	bra	.next
	
.next:	cmp.l	flistel,a0
	blt	.loop1

restruc:
	* enleve les zeros et update flistel

	lea	liste_occl,a0
	move.l	#0,a1

.loop1:
	tst.l	(a0)
	bne	.recopie
	move.l	a1,a3
	move.l	a0,a1

	cmp.l	#0,a3
	bne	.next

	move.l	a1,a2
	bra	.next
.recopie:
	cmp.l	#0,a1
	beq	.next
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	a1,a2
	move.l	#0,a1

	move.l	#0,(a0)
	move.l	#0,4(a0)
	move.l	#0,8(a0)
	move.l	#0,12(a0)

.next:
	lea	16(a0),a0
	cmp.l	flistel,a0
	blt	.loop1
	move.l	a2,flistel
	rts

********** recherche dans table d'occurences *************

cherche_w:		* recherche d'une donnee dans la table en word

	move.l	d1,-(sp)
	move.l	#0,d7
	tst.w	d0
	beq.s	.fin
	lea	garder,a6
	move.w	#reg_use,d1

.loop1:
*	add.w	#1,$ffff8240.w
	cmp.w	2(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	dbf	d1,.loop1
.fin:	move.l	(sp)+,d1
	rts

.trouve:	move.b	#1,d7
	move.l	(sp)+,d1
	rts


cherche_l:		* recherche d'une donnee dans la table en long

	move.l	d1,-(sp)
	move.b	#0,d7
	lea	garder,a6
	move.w	#reg_use,d1
.loop1:
*	add.w	#1,$ffff8240.w
	cmp.l	(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	dbf	d1,.loop1
.fin:	move.l	(sp)+,d1
	rts

.trouve:
	cmp.l	#0,12(a6)
	beq	.fin
	move.b	#1,d7
	move.l	(sp)+,d1
	rts


cherche_w2:		* recherche d'une donnee dans la table en word

	movem.l	d0-d6/a0-a5,-(sp)
	move.b	#0,d7
	tst.w	d0
	beq.s	.fin
.loop1:
*	add.w	#1,$ffff8240.w
	cmp.w	2(a6),d0
	bne	.pas_trouve
	cmp.l	#0,12(a6)
	bne	.trouve
.pas_trouve:
	lea	16(a6),a6
	cmp.l	flistew,a6
	blt	.loop1
.fin:	movem.l	(sp)+,d0-d6/a0-a5
	rts

.trouve:	move.b	#1,d7
	movem.l	(sp)+,d0-d6/a0-a5
	rts

*********** selection des registres a conserver  *********

select_occ:
	lea	garder,a2
	move.w	#reg_use,d5
.loop2:
	lea	liste_occl,a0
	lea	liste_occw,a6
	move.l	#0,posl
	move.l	#0,posw
	move.l	#0,occl
	move.l	#0,occw

.bo:
	move.l	(a0),d0
	move.l	4(a0),aux
	bsr	cherche_w2
	tst.b	d7
	beq.s	.pas_de_posw

	move.l	4(a0),d0
	add.l	4(a6),d0
	move.l	d0,aux
	move.l	a6,posw
	
.pas_de_posw:
	move.l	aux,d0
	cmp.l	occl,d0
	ble	.pas_sup_occl

	move.l	d0,occl
	move.l	a0,posl

.pas_sup_occl:
	lea	16(a0),a0
	cmp.l	flistel,a0
	blt	.bo
	
	move.l	posw,a3
	cmp.l	#0,a3
	beq	.pas_w
	move.l	#0,4(a3)
.pas_w:
	move.l	posl,a3
	move.l	#0,4(a3)
	move.l	(a3),(a2)+
	move.l	occl,(a2)+
	move.l	occl,(a2)+
	move.l	#0,(a2)+

	dbf	d5,.loop2

sc:

.cont:
	lea	liste_occw,a0
	lea	garder,a1
	moveq	#0,d7
.loop4:
	lea	liste_occw,a0
.loop3:
	move.l	4(a0),d0
	cmp.l	4(a1),d0
	ble.s	.pas_de_change
	bsr	dec_garder
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	#0,4(a0)
	moveq	#1,d7

.pas_de_change:
	lea	16(a0),a0
	cmp.l	flistew,a0
	blt	.loop3
	lea	16(a1),a1
	cmp.l	#garder+16*8,a1
	blt	.loop4
	tst.w	d7
	bne	.cont
	rts



dec_garder:
	movem.l	a0-a1/a6,-(sp)
	move.l	a1,a6
	lea	garder+8*16,a1
	lea	garder+7*16,a0
	
.loop1:
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	lea	-16(a0),a0
	lea	-16(a1),a1
	cmp.l	a6,a0
	bge	.loop1
	movem.l	(sp)+,a0-a1/a6
	rts
	
dec_garder2:
	movem.l	a0-a1/a6,-(sp)
	move.l	a1,a6
	lea	garder2+8*16,a1
	lea	garder2+7*16,a0
	
.loop1:
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	lea	-16(a0),a0
	lea	-16(a1),a1
	cmp.l	a6,a0
	bge	.loop1
	movem.l	(sp)+,a0-a1/a6
	rts
	

aux:	ds.l	1
occl:	ds.l	1
occw:	ds.l	1
posl:	ds.l	1
posw:	ds.l	1

*********** trie des occurences des donn‚es et des masques  *********
trie_occw:
	movem.l	d0-a6,-(sp)

.cont:
	lea	liste_occw,a0
	move.w	#0,d7

.bo:	move.l	4+16(a0),d0
	cmp.l	4(a0),d0
	ble.s	.ok
	movem.l	(a0),d0-d3
	move.l	16(a0),(a0)
	move.l	20(a0),4(a0)
	move.l	24(a0),8(a0)
	move.l	28(a0),12(a0)
	movem.l	d0-d3,16(a0)
	move.w	#1,d7
.ok:	lea	16(a0),a0
	cmp.l	flistew,a0
	blt.s	.bo
	tst.w	d7
	bne.s	.cont
	
	movem.l	(sp)+,d0-a6
	rts

trie_occl:
	movem.l	d0-a6,-(sp)

.cont:
	lea	liste_occl,a0
	move.w	#0,d7

.bo:	move.l	4+16(a0),d0
	cmp.l	4(a0),d0
	blt.s	.ok
	bgt	.ok2
	move.l	12+16(a0),d1
	cmp.l	12(a0),d1
	blt.s	.ok2
	bra	.ok

.ok2:	movem.l	(a0),d0-d3
	move.l	16(a0),(a0)
	move.l	20(a0),4(a0)
	move.l	24(a0),8(a0)
	move.l	28(a0),12(a0)
	movem.l	d0-d3,16(a0)
	move.w	#1,d7
.ok:	lea	16(a0),a0
	cmp.l	flistel,a0
	blt.s	.bo
	tst.w	d7
	bne.s	.cont
	
	movem.l	(sp)+,d0-a6
	rts



**************** calcul du masque *****************

calc_msk:
	movem.l	d0/a0,-(sp)
	move.l	a0,d0
	sub.l	#pred2,d0
	lsr.l	#3,d0
	lsl.l	#3,d0
	add.l	#pred2,d0
	move.l	d0,a0
	move.w	(a0),d7
	or.w	2(a0),d7
	or.w	4(a0),d7
	or.w	6(a0),d7
	not.w	d7
	move.w	d7,d0
	swap	d7
	move.w	d0,d7
	movem.l	(sp)+,d0/a0
	rts
	
**************** gestion decalage des sprites *****************

	
remplis_decalage:

	movem.l	d0-d1/a0-a1,-(sp)
	lea	image+34+offset_img,a0
	lea	pred,a1

	move.w	#hauteur,d0
.loop1:
	move.w	#(largeur/8)-1,d1
.loop2:
	move.l	(a0)+,(a1)+
	dbf	d1,.loop2
	
	lea	160-(largeur/2)(a0),a0
	lea	8(a1),a1
	dbf	d0,.loop1
	movem.l	(sp)+,d0-d1/a0-a1
	rts
	
	
decale:
	move.l	a2,-(sp)
	lea	pred,a2

st	set	0
	rept	hauteur

	roxr.w	st(a2)		1er plan
	roxr.w	st+8(a2)

	roxr.w	st+2(a2)		2em plan
	roxr.w	st+10(a2)

	roxr.w	st+4(a2)		3em plan
	roxr.w	st+12(a2)

	roxr.w	st+6(a2)		4em plan
	roxr.w	st+14(a2)

st	set	st+2*8
	endr
	move.l	(sp)+,a2
	rts


copy_pred:
	lea	pred,a0
	lea	pred2,a1
	move.w	#(hauteur*((largeur/2)+8))-1,d0

.loop:	move.b	(a0)+,(a1)+
	dbf	d0,.loop
	rts

	section	data

 image:	incbin	"i.pi1"
	even

texte:
*	incbin	"texte"
	dc.b	0
	even

tab_addq:
	addq.l	#1,a0
	addq.l	#2,a0
	addq.l	#3,a0
	addq.l	#4,a0
	addq.l	#5,a0
	addq.l	#6,a0
	addq.l	#7,a0
	addq.l	#8,a0

tab_andld_direct:
	and.l	d0,(a0)
	and.l	d1,(a0)
	and.l	d2,(a0)
	and.l	d3,(a0)
	and.l	d4,(a0)
	and.l	d5,(a0)
	and.l	d6,(a0)
	and.l	d7,(a0)

tab_andld_post:
	and.l	d0,(a0)+
	and.l	d1,(a0)+
	and.l	d2,(a0)+
	and.l	d3,(a0)+
	and.l	d4,(a0)+
	and.l	d5,(a0)+
	and.l	d6,(a0)+
	and.l	d7,(a0)+

tab_andwd_direct:
	and.w	d0,(a0)
	and.w	d1,(a0)
	and.w	d2,(a0)
	and.w	d3,(a0)
	and.w	d4,(a0)
	and.w	d5,(a0)
	and.w	d6,(a0)
	and.w	d7,(a0)


tab_andwd_post:
	and.w	d0,(a0)+
	and.w	d1,(a0)+
	and.w	d2,(a0)+
	and.w	d3,(a0)+
	and.w	d4,(a0)+
	and.w	d5,(a0)+
	and.w	d6,(a0)+
	and.w	d7,(a0)+


tab_orld_direct:
	or.l	d0,(a0)
	or.l	d1,(a0)
	or.l	d2,(a0)
	or.l	d3,(a0)
	or.l	d4,(a0)
	or.l	d5,(a0)
	or.l	d6,(a0)
	or.l	d7,(a0)

tab_orld_post:
	or.l	d0,(a0)+
	or.l	d1,(a0)+
	or.l	d2,(a0)+
	or.l	d3,(a0)+
	or.l	d4,(a0)+
	or.l	d5,(a0)+
	or.l	d6,(a0)+
	or.l	d7,(a0)+

tab_orwd_direct:
	or.w	d0,(a0)
	or.w	d1,(a0)
	or.w	d2,(a0)
	or.w	d3,(a0)
	or.w	d4,(a0)
	or.w	d5,(a0)
	or.w	d6,(a0)
	or.w	d7,(a0)

tab_orwd_post:
	or.w	d0,(a0)+
	or.w	d1,(a0)+
	or.w	d2,(a0)+
	or.w	d3,(a0)+
	or.w	d4,(a0)+
	or.w	d5,(a0)+
	or.w	d6,(a0)+
	or.w	d7,(a0)+

tab_moveld_direct:
	move.l	d0,(a0)
	move.l	d1,(a0)
	move.l	d2,(a0)
	move.l	d3,(a0)
	move.l	d4,(a0)
	move.l	d5,(a0)
	move.l	d6,(a0)
	move.l	d7,(a0)

tab_moveld_post:
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	move.l	d7,(a0)+

tab_movewd_direct:
	move.w	d0,(a0)
	move.w	d1,(a0)
	move.w	d2,(a0)
	move.w	d3,(a0)
	move.w	d4,(a0)
	move.w	d5,(a0)
	move.w	d6,(a0)
	move.w	d7,(a0)

tab_movewd_post:
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	move.w	d5,(a0)+
	move.w	d6,(a0)+
	move.w	d7,(a0)+


tab_movem:
	nop
	nop
	nop
	movem.l	tab_movem(pc),d0
	movem.l	tab_movem(pc),d0-d1
	movem.l	tab_movem(pc),d0-d2
	movem.l	tab_movem(pc),d0-d3
	movem.l	tab_movem(pc),d0-d4
	movem.l	tab_movem(pc),d0-d5
	movem.l	tab_movem(pc),d0-d6
	movem.l	tab_movem(pc),d0-d7
	
tab_movew:
	move.w	#1,d0
	move.w	#1,d1
	move.w	#1,d2
	move.w	#1,d3
	move.w	#1,d4
	move.w	#1,d5
	move.w	#1,d6
	move.w	#1,d7

tab_movel:
	move.l	#1000,d0
	move.l	#1000,d1
	move.l	#1000,d2
	move.l	#1000,d3
	move.l	#1000,d4
	move.l	#1000,d5
	move.l	#1000,d6
	move.l	#1000,d7

zero:	incbin	"zeroa99.bin"
	dc.w	$4e75
	even
	section	bss

pred:	ds.b	hauteur*((largeur/2)+8)
fpred:	even
	ds.w	1

debut_vide:
	ds.w	1
flistew:	ds.l	1
flistel:	ds.l	1
flistel2:	ds.l	1

nb_reg:	ds.w	1

plan:	ds.l	1
offset:	ds.l	1
donnee:	ds.l	1
masque:	ds.l	1

liste_occl:
ll:	ds.b	16*800
	even

liste_occl2:
ll2:	ds.b	16*800
	even
liste_occw:
	ds.b	16*800
	even


pred2:	ds.b	hauteur*((largeur/2)+8)
fpred2:	even
	ds.w	1
garder:	ds.b	16*8
fgarder:
	ds.b	16

garder2:	ds.b	16*8
	ds.b	16

garder_code:
	ds.b	16*8	* valeurs courantes dans registres
	ds.b	16

debut_code:ds.l	1
dresultat:	ds.l	1
finstr:	ds.l	1
instr:	ds.b	80000	* instruction       	4 octets
			* offset_courant    	4 octets
			* plan		4 octets
				*1=1er...4=4eme
			* donn‚e		4 octets
			* masque		4 octets
			* num‚ro de registre	4 octets

adresse:	ds.l	1
movem:	ds.l	8
resultat:	ds.b	30000
fin_vide:
pt_final:	ds.l	1
pt_final2:	ds.l	1
final:
	ds.l	16
final2:	ds.b	60000
	end	
