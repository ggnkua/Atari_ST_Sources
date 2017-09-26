	include	aes.i
	include	structs.s
	include	zlib.i
	include	..\macro.i

* Variables ZLIB
	XREF	tab_adr
* Quelques messages d'erreurs
	XREF	aucun_objet_selected_4_del,root_selected_4_del

	bss
temp_selected_list	ds.l	1
temp_selected_tree	ds.l	1
	text

*--------------------------------------------------------------------------------------------------------------------------*
******************************************************************************************************
*** Efface une liste d'objet dans un arbre. Si un de ces objets a une descendance, elle est efface ***
******************************************************************************************************
	XDEF	erase_list_rout
erase_list_rout
* On verifie qu'on a pas selectionne l'objet root mais que D'AUTRE objets sont dans la liste
	movem.l		d1-a6,-(sp)
	move.l		60+4(sp),a4
	move.l		a4,temp_selected_list
	move.l		60+0(sp),a6
	move.l		a6,temp_selected_tree
	move.l		(a6),a6
	cmp.w		#-1,(a4)
	bne		des_objets_selectionne
	form_alert	#1,#aucun_objet_selected_4_del
	movem.l		(sp)+,d1-a6
	rts
des_objets_selectionne
	tst.w		(a4)+
	beq		objet_root_selected
	cmp.w		#-1,(a4)
	bne		des_objets_selectionne
	bra		ok_selection
objet_root_selected
	form_alert	#1,#root_selected_4_del
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
ok_selection
* On commence par dresser une liste des objets a enleve du vecteur d'objets
	lea		del_list,a5
	move.l		temp_selected_list,a4
boucle_find_objcs
	move.w		(a4)+,d7
	move.w		d7,(a5)+
	move.l		a6,-(sp)
	move.w		d7,-(sp)
	bsr		find_fils
	addq.l		#6,sp
	cmp.w		#-1,(a4)
	bne		boucle_find_objcs
	move.w		#-1,(a5)
*--------------------------------------------------------------------------------------------------------------------------*
* Puis on efface les liens des objets selectionnes
	move.l		temp_selected_list,a4
boucle_efface_liens
	move.w		(a4)+,d6
	trouve_parent	d6,a6
	move.w		d0,d5
	trouve_objc	a6,d5
	move.l		a0,a3
	move.w		ob_head(a0),d4
	cmp.w		d4,d6
	beq		objet_en_tete_de_liste
.boucle_find_objc
	trouve_objc	a6,d4
	move.w		d4,d0
	move.w		ob_next(a0),d4
	cmp.w		d4,d6
	bne		.boucle_find_objc
	cmp.w		ob_tail(a3),d6
	beq		objet_en_fin_de_liste
*----------------------*
objet_en_mileu_de_liste
	move.l		a0,a1
	trouve_objc	a6,d6
	move.w		ob_next(a0),ob_next(a1)
	bra		fin_efface_lien
*----------------------*
objet_en_tete_de_liste
	move.w		ob_tail(a3),d0
	cmp.w		ob_head(a3),d0
	bne		.plus_d1_objet
	move.w		#-1,ob_head(a3)
	move.w		#-1,ob_tail(a3)
	bra		fin_efface_lien
.plus_d1_objet
	trouve_objc	a6,d4
	move.w		ob_next(a0),ob_head(a3)
	bra		fin_efface_lien
*----------------------*
objet_en_fin_de_liste
	move.w		d0,ob_tail(a3)
	move.w		d5,ob_next(a0)
fin_efface_lien
	cmp.w		#-1,(a4)
	bne		boucle_efface_liens
*--------------------------------------------------------------------------------------------------------------------------*
* On redessinne la fenetre
	find_tab_l	#tab_adr,a6
;	wd_redraw_gem	d0
*--------------------------------------------------------------------------------------------------------------------------*
* On verifie qu'on a pas des doublons dans la liste d'objet a effacer
	lea		del_list,a5
boucle_verifi_doublon
	lea		2(a5),a4
	move.w		(a5),d0
	cmp.w		#-1,(a4)
	beq		verif_fini

boucle_verif_2
	cmp.w		(a4)+,d0
	beq		doublon

doublon_ok
	cmp.w		#-1,(a4)
	bne		verif_fini
	addq.l		#2,a5
	bra		boucle_verifi_doublon

doublon	lea		-2(a4),a3
	move.l		a4,a2
.boucle_enleve_doublon
	move.w		(a2)+,(a3)+
	cmp.w		#-1,-2(a2)
	bne		.boucle_enleve_doublon
	bra		doublon_ok

verif_fini
*--------------------------------------------------------------------------------------------------------------------------*
* On enleve les objets du vecteur
* Pour cela on trouve l'objet de fin
	lea		ob_flags+1(a6),a4
	moveq.l		#0,d1
	move.w		#LASTOB,d0
trouve_objet_de_fin
	addq.w		#1,d1
	lea		24(a4),a4
	btst		d0,(a4)
	beq		trouve_objet_de_fin
	bclr		d0,(a4)		; effacement de l'objet de fin
	lea		-(ob_flags+1)(a4),a4

* Puis on echange celui-ci avec l'objet en cours dans la liste
	lea		del_list,a5
boucle_echange_objets
	move.w		(a5)+,d7
	trouve_objc	a6,d7
	moveq.l		#11,d6

	free_obj	a0		; On desalou l'objet a effacer

* Dans le cas ou l'ob_spec est un pointeur...
	btst		#INDIRECT-8,ob_flags(a4)
	bne		.mvptr
	cmp.b		#G_BOX,ob_type+1(a4)
	beq		.suite
	cmp.b		#G_PROGDEF,ob_type+1(a4)
	beq		.suite
	cmp.b		#G_IBOX,ob_type+1(a4)
	beq		.suite
	cmp.b		#G_BOXCHAR,ob_type+1(a4)
	beq		.suite
.mvptr
	lea		ob_spec(a4),a2
	lea		ob_spec(a0),a1
	xaloc_moveptr	a2,a1,(a2)	; et on informe le gestionnaire de memoire du deplacement d'un pointeur
.suite
boucle_copy_last_objet
	move.w		(a4)+,(a0)+
	dbra		d6,boucle_copy_last_objet
* Tout en verifiant que des numero d'ordre ne pointait pas sur le dernier objet
	move.l		a6,a3
	moveq.l		#-1,d0
boucle_update_numero_dordre
	addq.w		#1,d0
	cmp.w		ob_next(a3),d1	; si pointage sur dernier objet
	bne.s		.ob_next_ok
	move.w		d7,ob_next(a3)	; alors remplacement par le nouveau numero d'ordre
.ob_next_ok
	cmp.w		ob_head(a3),d1
	bne.s		.ob_head_ok
	move.w		d7,ob_head(a3)
.ob_head_ok
	cmp.w		ob_tail(a3),d1
	bne.s		.ob_tail_ok
	move.w		d7,ob_tail(a3)
.ob_tail_ok
	lea		24(a3),a3
	cmp.w		d0,d1
	bgt		boucle_update_numero_dordre	; Pas la peine d'updater le dernier objet

* On fait le deplacement d'index dans la liste d'objet a efface aussi !
	lea		del_list,a0
.boucle_id_liste
	cmp.w		(a0)+,d1
	bne		.id_liste_ok
	move.w		d7,-2(a0)
.id_liste_ok
	cmp.w		#-1,(a0)
	bne		.boucle_id_liste

* Puis on passe a 'objet suivant !
	lea		-48(a4),a4
	subq.w		#1,d1
	cmp.w		#-1,(a5)
	bne		boucle_echange_objets
	bset		#LASTOB,ob_flags+1(a4)
*--------------------------------------------------------------------------------------------------------------------------*
* On efface la liste
	move.l		temp_selected_list,a4
	move.l		temp_selected_tree,a6
	move.l		#0,(a6)
	move.l		#-1,(a4)
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Trouve l'index des fils d'un objet recursivement, et en remplissant une liste en (a5)+
find_fils
	movem.l		d6/d7/a0/a6,-(sp)
	move.l		20+2(sp),a6
	move.w		20+0(sp),d7
	trouve_objc	a6,d7
	move.w		ob_head(a0),d6
	cmp.w		#-1,d6
	beq		end_find_fils
	move.w		d6,(a5)+
	trouve_objc	a6,d6
boucle_find_fils
	move.l		a6,-(sp)
	move.w		d6,-(sp)
	bsr		find_fils
	addq.l		#6,sp
	move.w		ob_next(a0),d6
	cmp.w		d6,d7
	beq		end_find_fils
	move.w		d6,(a5)+
	trouve_objc	a6,d6
	bra		boucle_find_fils
end_find_fils
	movem.l		(sp)+,d6/d7/a0/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	bss
del_list	ds.w	256