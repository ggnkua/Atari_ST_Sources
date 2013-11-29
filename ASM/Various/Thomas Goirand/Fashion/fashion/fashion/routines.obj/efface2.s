	include	aes.i
	include	structs.s
	include	zlib.i
	XREF	ed_sel_win
	XREF	ed_sel_objc
	XREF	tab_adr
***********************************************************************************
*** routine d'efacement de la liste d'objet trouve dans une fenetre DRAG...     ***
***********************************************************************************
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	XDEF	eface_objets_en_cours
eface_objets_en_cours
	tst.l		ed_sel_win
	bne		eface_objets_en_cours_suite
	form_alert	#1,#aucun_objet_selectionne
	rts
	data
	even
aucun_objet_selectionne	dc.b	"[2][Aucun objet selectionne :|"
	dc.b	"effacement impossible !|Veuillez cliquer|sur un objet.][ Ok ]",0
	even
	text
eface_objets_en_cours_suite
* on dresse une liste de tous les objets a effacer... et en meme temps on change les liens
* de maniere a retirer les objets de la "chaine" de l'arbre.
	move.l		#ed_sel_objc,a5
	move.l		#erased_objects,a4
***---***---***---***---***---***---***---***---***---***---***---***---***---***---***---***---
.boucle_delete
* on commence par enlever le lien
	move.w			(a5),d6
	trouve_parent	d6,ed_sel_win
	move.w			d0,d5
	trouve_objc		ed_sel_win,d5
	move.l			a0,a3
	cmp.w			ob_head(a0),d6
	beq				.eface_lien_parent

	move.w			ob_head(a3),d3
	trouve_objc		ed_sel_win,d3		; d3 contient l'objet precedent
	move.l			a0,a2
.boucle_trouve_lien
	cmp.w			ob_next(a2),d6				; si l'objet n'est pas le premier ni le dernier de
	beq				.efface_lien_meme_niveau	; la chaine, alors on update l'ob_next de
	move.w			ob_next(a2),d3
	trouve_objc		ed_sel_win,d3
	move.l			a0,a2
	bra				.boucle_trouve_lien			; l'objet precedent

.efface_lien_meme_niveau
	move.l			a0,a6
	trouve_objc		ed_sel_win,d6		; au mileu de la chaine d'enfant, on
	move.w			ob_next(a0),ob_next(a6)		; deplace l'ob_next de l'objet a effacer
	cmp.w			ob_next(a0),d5				; dans celle de l'objet precedent. En plus,
	bne				.suite_lien_efface			; si c'est le dernier objet, alors on update
	move.w			d3,ob_tail(a3)				; l'ob_tail du parent.
	bra				.suite_lien_efface

.eface_lien_parent
	move.l			a0,a6
	trouve_objc		ed_sel_win,d6		; s'il est le seul fils, alors on place -1
	cmp.w			ob_next(a0),d5
	bne				.eface_lien_parent_suite	; dans l'ob_head et ob_tail du parent
	move.l			#-1,2(a6)
	bra				.suite_lien_efface
.eface_lien_parent_suite
	move.w			ob_next(a0),ob_head(a6)		; s'il est le 1er fils, on modifie ob_head du pere

* les liens updates, il faut savoir quels sont les enfants de l'objet a effacer pour liberer
* ensuite de la place dans l'arbre. On rempli donc le tableau pointe par a4 de l'objet dans a5
* et de celui tout ses enfant.
.suite_lien_efface
	trouve_objc	ed_sel_win,d6
	move.w		d6,(a4)+
	move.w		(a5)+,d7
	move.l		a0,a6
	cmp.w		#-1,ob_head(a0)
	beq			.nefacepa_ya_pas_denfants
;	move.l		a5,-(sp)
	bsr			efface_enfant
;	move.l		(sp)+,a5
.nefacepa_ya_pas_denfants
	tst.w		(a5)
	bne			.boucle_delete
***---***---***---***---***---***---***---***---***---***---***---***---***---***---***---***---
* Subtilite a la Dave Small : on a l'impression que ca vat vite !
* les liens modifies, on peut alors faire un redraw de la fenetre avant meme d'efacer
* les objets de celle-ci (la modification des liens des objets modifie sufira pour eliminer
* les objets lors de l'affichage de l'arbre).
	find_tab_l	#tab_adr,ed_sel_win
	wd_redraw	d0
* on rentre ensuite dans une boucle d'efacement objets part objets
	clr.l		d7
	move.l		a4,d6
	sub.l		#erased_objects,d6
	lsr.l		#1,d6	; d6 contient maintenant le nombre d'objet a effacer
	subq.l		#1,d6	; -1 car on fait un dbf...

	lea			erased_objects,a4
.boucle_deffacage_dobjets
	move.w		(a4)+,d7
	trouve_objc	ed_sel_win,d7
	move.w		ob_flags(a0),d0
	btst		#LASTOB,d0
	bne			.dernier_objet_de_larbre
	move.l		a0,a1
	add.l		#24,a0

.deplace_les_objets_boucle
	movem.l		(a0)+,d0-d5
* on update les indexs des 3 premiers mots
	cmp.w		d7,d0
	blt			.suite_boucle_deffacage1
	subq.w		#1,d0
.suite_boucle_deffacage1
	swap		d0
	cmp.w		d7,d0
	blt			.suite_boucle_deffacage2
	subq.w		#1,d0
.suite_boucle_deffacage2
	swap		d1
	swap		d0
	cmp.w		d7,d1
	blt			.suite_boucle_deffacage3
	subq.w		#1,d1
.suite_boucle_deffacage3
	lea			24(a1),a1
	swap		d1
	movem.l		d0-d5,-(a1)
	lea			24(a1),a1
	btst		#16+5,d2	; LASTOB ??? si oui, on a fini l'effacage de l'objet : suivant SVP...
	beq			.deplace_les_objets_boucle
	move.w		#12,d0
.boucle_efface_apres_le_dernier_objet
	clr.l		(a1)+
	dbf			d0,.boucle_efface_apres_le_dernier_objet

* maintenant on update les liens du debut de l'arbre (avant que l'objet efface...)
	move.l		ed_sel_win,a6
	trouve_objc	a6,d7
.loop
	movem.w		(a6)+,d0-d2
	cmp.w		d0,d7
	bgt		.update_pas1
	subq.w		#1,d0
	move.w		d0,-6(a6)
.update_pas1
	cmp.w		d1,d7
	bgt		.update_pas2
	subq.w		#1,d1
	move.w		d1,-4(a6)
.update_pas2
	cmp.w		d2,d7
	bgt		.update_pas3
	subq.w		#1,d2
	move.w		d2,-2(a6)
.update_pas3
	add.l		#24-6,a6
	cmp.l		a0,a6
	bne		.loop

	dbf		d6,.boucle_deffacage_dobjets
	clr.l		ed_sel_win
	clr.l		ed_sel_objc
	rts

.dernier_objet_de_larbre
	move.w		8-24(a0),d0	; si c'est le dernier objet de l'arbre qu'on doit effacer,
	bset		#LASTOB,d0	; alors il faut juste modifier le LASTOB et effacer le
	move.w		d0,8-24(a0)	; dernier objet.
	move.w		#12,d0
.bouclealacon
	clr.l		(a0)+
	dbf			d0,.bouclealacon
	dbf			d6,.boucle_deffacage_dobjets
	rts
*****************************************************************************
*** boucle recurcive de recherche d'objet afin d'effacer un objet et tous ***
*** ses enfants                                                           ***
*****************************************************************************
* parametre : a6 pointe sur le pere
*             d7 est l'index du pere
*			  a4 pointe vers des places vide d'un tableau d'index a effacer.
* en sortie : le tableau erased_objects est rempli avec une liste de tous les
*			  enfants descendants de l'objet pere
efface_enfant:
	move.w		ob_head(a6),d5
	move.w		d5,(a4)+
.boucle_de_copy_si_plusieur_enfant
	trouve_objc	ed_sel_win,d5
	move.l		a0,a6
	cmp.w		#-1,ob_head(a6)
	beq		.pas_dapel_a_la_routine_recurcive
	bra		.apel_la_routine_recurcive
.pas_dapel_a_la_routine_recurcive
	cmp.w		ob_next(a6),d7			; y a-t-il un autre objet au meme plan ?
	bne		.objet_suivant
	rts						; non -> tous les objet fils sont copier dans (a4)+...
.objet_suivant
	move.w		ob_next(a6),d5
	move.w		d5,(a4)+
	bra		.boucle_de_copy_si_plusieur_enfant


.apel_la_routine_recurcive
	movem.l		d5/d7/a6,-(sp)
	move.w		d5,d7
	bsr		efface_enfant
	movem.l		(sp)+,d5/d7/a6
	bra		.pas_dapel_a_la_routine_recurcive
	bss
erased_objects	ds.w	256
	text
