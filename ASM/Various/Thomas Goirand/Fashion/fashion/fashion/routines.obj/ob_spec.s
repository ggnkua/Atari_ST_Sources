	opt	C24+
	XDEF	get_indirect_rout
	XDEF	set_indirect_rout
	XDEF	del_indirect_rout

	include	structs.s
	include	zlib.i
	include	util.i
	include	aes.i

	include	..\fashion.s
	include	..\memory.s
	include	..\macro.i

	XDEF	set_one_text_line

	XDEF	get_objc_info
	XDEF	label_win,label_objc
	XREF	LABEL_adr,wd_create_form,obtype_inferieur_a_256

	XREF	find_max_entree_w_rout,find_to_deroule_rout,find_selected_title_rout,find_selected_entree_rout

	XREF	tab_adr,tab_x,tab_y,tab_h,tab_w,tab_handle

*--------------------------------------------------------------------------------------------------------------------------*
*******************************************************************
*** Routine trouvant un chunk dans la partie indirec d'un objet ***
*******************************************************************
*** Renvois dans a0 l'adresse du debut du chunk demande ***
*** Et dans a1 l'adresse du debut du bloc precedent ***
*** le chunk ayan la structure suivante :
*** rs.l	1	; pointeur sur chunk suivant (a zero si pas de chunk)
*** rs.b	4	; nom du chunk
*** rs.b	xxx	; une chaine ou un bloc
*******************************************************************
get_indirect_rout
	movem.l	d6-d7/a6,-(sp)
	move.l	16+6(sp),a6		; adresse du formulaire
	move.w	16+4(sp),d7		; index de l'arbre
	move.l	16+0(sp),d6		; nom du chunk (4 char ASCII)

* Trouve le premier chunk
	trouve_objc	a6,d7
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.error
	move.l		ob_spec(a0),a0
	add.l		#4,a0


* Puis cherche dans la liste
.loop
	cmp.l		obck_name(a0),d6
	beq		.trouve
	move.l		obck_next(a0),a0
	tst.l		a0
	beq		.error
	bra		.loop
.trouve

* Si trouve, alors on sort (a0 contient l'adresse du chunk)
	movem.l	(sp)+,d6-d7/a6
	rts
.error
	move.l	#0,a0
	movem.l	(sp)+,d6-d7/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
********************************************************
*** Set chunk permet de donner un valeur a un chunk  ***
*** Si un valeur etait deja presente, alors elle est ***
*** efface, si aucun chunk, alors on cree la partie  ***
*** indirecte de l'objet                             ***
********************************************************
set_indirect_rout
	movem.l	d4-d7/a2-a6,-(sp)
	move.l	40+10(sp),a6		; adresse du formulaire
	move.w	40+8(sp),d7		; index de l'objet
	move.l	40+4(sp),d6		; nom du chunk (4 char ASCII)
	move.l	40+0(sp),a5		; adresse du bloc ou de la chaine a ajouter/remplacer

	trouve_objc		a6,d7
	move.l			a0,a4		; adresse de l'objet a modifier

	string_size		a5
	move.l			d0,d5		; taille de la chaine a ajouter

	lea			ob_spec(a4),a3

	get_indirect	a6,d7,d6
	tst.l			a0
	beq			.pas_trouve
	move.l			a0,a2

	move.l			obck_prev(a2),a0
	tst.l			a0
	beq			.premier_chunk

* On a trouve le bon chunk, et il n'est pas en premiere position
	move.l			d5,d4
	add.l			#obck_string,d4
	xaloc_grow		d4,a0
	move.l			(a0),a2
	bra			.new_chunk_ready
	*---*
* On a trouve le bon chunk, mais il est en premiere position
.premier_chunk
	move.l			d5,d4
	add.l			#obck_string+4,d4
	xaloc_grow		d4,a3
	move.l			(a3),a2
	addq.l			#4,a2
	bra			.new_chunk_ready
	*---*

.pas_trouve
	btst	#INDIRECT-8,ob_flags(a4)
	beq	.aucun_chunk

* On a pas trouver le bon chunk, mais il existe deja une liste de chunk
* On insert donc en debut de liste juste apres le premier chunk
	move.l		(a3),a2
	addq.l		#4,a2
	move.l		(a2),pointeur_temporaire
	tst.l		(a2)
	beq		.suite1
	xaloc_moveptr	a2,#pointeur_temporaire,(a2)	; deplace le pointeur sur suivant du premier chunk
.suite1	
	move.l		d5,d4
	add.l		#obck_string,d4
	xaloc_aloc	d4,a2
	move.l		d0,(a2)
	move.l		d0,a1

	lea		obck_prev(a1),a0
	move.l		a2,(a0)
	xaloc_addptr	a0

	move.l		pointeur_temporaire,(a1)
	tst.l		(a1)
	beq		.suite2
	xaloc_moveptr	#pointeur_temporaire,a1,(a1)
.suite2	move.l		a1,a2
	bra		.new_chunk_ready
	*---*

* Nouveau_bit_indirect
.aucun_chunk
	bset		#INDIRECT-8,ob_flags(a4)
	move.l		(a3),pointeur_temporaire

	cmp.b			#G_BOX,ob_type+1(a4)
	beq			.no_ob_spec_ptr
	cmp.b			#G_IBOX,ob_type+1(a4)
	beq			.no_ob_spec_ptr
	cmp.b			#G_BOXCHAR,ob_type+1(a4)
	beq			.no_ob_spec_ptr
	cmp.b			#G_LINE,ob_type+1(a4)
	beq			.no_ob_spec_ptr
	cmp.b			#G_CHECK,ob_type+1(a4)
	beq			.no_ob_spec_ptr

* On fabrique une nouvelle liste chaine, en redirigeant l'ob_spec grace au bit INDIRECT
* Ici l'ob_spec est un pointeur
	xaloc_moveptr	a3,#pointeur_temporaire,(a3)
	move.l		d5,d4
	add.l		#obck_string+4,d4
	xaloc_aloc	d4,a3
	move.l		d0,ob_spec(a4)
	move.l		d0,a3
	move.l		pointeur_temporaire,(a3)
	xaloc_moveptr	#pointeur_temporaire,a3,(a3)
	lea		4(a3),a2
	clr.l		obck_next(a2)
	clr.l		obck_prev(a2)
	bra		.new_chunk_ready
	*---*

* Ici l'ob_spec est une valeur
.no_ob_spec_ptr
	move.l		d5,d4
	add.l		#obck_string+4,d4
	xaloc_aloc	d4,a3
	move.l		d0,ob_spec(a4)
	move.l		d0,a3
	move.l		pointeur_temporaire,(a3)
	lea		4(a3),a2
	clr.l		obck_next(a2)
	clr.l		obck_prev(a2)
	bra		.new_chunk_ready
	*---*

* Reste a remplir le chunk avec sa chaine...
.new_chunk_ready
	move.l		d6,obck_name(a2)
	lea		obck_string(a2),a3
	string_copy	a5,a3

	movem.l		(sp)+,d4-d7/a2-a6
	rts
	bss
pointeur_temporaire	ds.l	1
	text
*--------------------------------------------------------------------------------------------------------------------------*
***************************************************************
*** del_indirect supprime un chunk de la liste chaine ***
***************************************************************
del_indirect_rout
	movem.l	d4-d7/a0-a6,-(sp)
	move.l	48+6(sp),a6		; adresse du formulaire
	move.w	48+4(sp),d7		; index de l'arbre
	move.l	48+0(sp),d6		; nom du chunk (4 char ASCII)
	get_indirect	a6,d7,d6
	move.l			a0,a5
	tst.l			a0
	beq			.error

	tst.l		obck_prev(a5)
	beq		.pas_premier
* On elimine le premier chunk...
	tst.l		obck_next(a5)
	beq		.premier_et_dernier

* ...qui n'est pas le seul chunk
	lea		obck_string(a5),a3
	string_size	a3
	move.l		d0,d5
	move.l		d0,d4
	add.l		#obck_string+4,d4
	trouve_objc	a6,d7
	lea		ob_spec(a0),a0
	xaloc_grow	d4,a0			; redimentionnement du premier bloc

	move.l		(a5),a4
	lea		obck_prev(a4),a3
	xaloc_supptr	a3
	move.l		(a4),pointeur_temporaire
	tst.l		(a4)
	beq		.suite
	xaloc_moveptr	a4,pointeur_temporaire,(a4)
.suite	move.l		obck_name(a4),obck_name(a5)
	lea		obck_string(a4),a1
	lea		obck_string(a5),a2
	string_copy	a4,a5			; copie du second bloc dans le premier
	xaloc_free	a5
	move.l		pointeur_temporaire,(a5)
	tst.l		(a5)
	beq		.suite2
	xaloc_moveptr	#pointeur_temporaire,a5,(a5)
.suite2	movem.l		(sp)+,d4-d7/a0-a6
	rts

* ...qui est le dernier chunk
.premier_et_dernier
	trouve_objc	a6,d7
	bclr		#INDIRECT-8,ob_flags(a0)
	lea		ob_spec(a0),a3
	move.l		ob_spec(a0),a4
	cmp.b		#G_BOX,ob_type+1(a0)
	beq		.first_n_last_obspec_isnot_ptr
	cmp.b		#G_IBOX,ob_type+1(a0)
	beq		.first_n_last_obspec_isnot_ptr
	cmp.b		#G_BOXCHAR,ob_type+1(a0)
	beq		.first_n_last_obspec_isnot_ptr
	cmp.b		#G_LINE,ob_type+1(a0)
	beq		.first_n_last_obspec_isnot_ptr

	move.l		(a4),pointeur_temporaire
	xaloc_moveptr	a4,#pointeur_temporaire,(a4)
	xaloc_free	a3
	move.l		pointeur_temporaire,(a3)
	xaloc_moveptr	#pointeur_temporaire,a3,(a3)
	movem.l		(sp)+,d4-d7/a0-a6
	rts

.first_n_last_obspec_isnot_ptr
	move.l		(a4),d4
	xaloc_free	a3
	move.l		d4,(a3)
	movem.l		(sp)+,d4-d7/a0-a6
	rts

.pas_premier
	tst.l		obck_next(a5)
	beq		.au_milieu
* On vire le dernier chunk de la liste
	lea		obck_prev(a5),a1
	move.l		obck_prev(a5),a2
	xaloc_supptr	a1
	xaloc_free	a2
	clr.l		(a2)
	movem.l		(sp)+,d4-d7/a0-a6
	rts

* On crame un chunk au milieu d'une liste
.au_milieu
* Trouve les chunks precedent et suivant
	move.l		obck_prev(a5),a3
	move.l		obck_next(a5),a4

	move.l		(a5),pointeur_temporaire
	xaloc_moveptr	a0,#pointeur_temporaire,(a0)	; on sauve le pointeur sur suivant

	lea		obck_prev(a4),a1
	xaloc_supptr	a1
	move.l		a3,(a1)
	xaloc_addptr	a1

	lea		4(a5),a0
	xaloc_supptr	a0

	xaloc_free	a3
	move.l		pointeur_temporaire,(a3)
	xaloc_moveptr	a3,#pointeur_temporaire,(a3)	; que l'on restitue
	movem.l		(sp)+,d4-d7/a0-a6
	rts
.error	moveq.l	#-1,d0
	movem.l		(sp)+,d4-d7/a0-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
get_objc_info
	movem.l		d1-a6,-(sp)
	move.l		60+2(sp),a6	; adresse du formulaire
	move.w		60+0(sp),d7	; index de l'objet a editer

* Copie de l'ob_type etendu dans le formulaire
	rsrc_gaddr	#0,#LABEL
	move.l		addr_out,LABEL_adr
	trouve_objc	addr_out,#LABEL_OBTYPE
	move.l		ob_spec(a0),a4
	trouve_objc	a6,d7
	move.l		a0,a5		; adresse de l'objet edite
	moveq.l		#0,d6
	move.b		ob_type(a0),d6
	long_2_chaine	d6,(a4),#3	

* Update les coordonnes
	moveq.l		#0,d6
	move.w		ob_x(a5),d6
	trouve_objc	LABEL_adr,#LABEL_X
	move.l		ob_spec(a0),a1
	long_2_chaine	d6,(a1),#5	; x

	moveq.l		#0,d6
	move.w		ob_y(a5),d6
	trouve_objc	LABEL_adr,#LABEL_Y
	move.l		ob_spec(a0),a1
	long_2_chaine	d6,(a1),#5	; y

	moveq.l		#0,d6
	move.w		ob_w(a5),d6
	trouve_objc	LABEL_adr,#LABEL_W
	move.l		ob_spec(a0),a1
	long_2_chaine	d6,(a1),#5	; w

	moveq.l		#0,d6
	move.w		ob_h(a5),d6
	trouve_objc	LABEL_adr,#LABEL_H
	move.l		ob_spec(a0),a1
	long_2_chaine	d6,(a1),#5	; h

* Update le pointeur ki va bien dans le popup
	moveq.l		#0,d6
	move.b		ob_type+1(a5),d6
	sub.w		#20,d6
	add.w		#PP_G_BOX,d6

	rsrc_gaddr	#0,#LABEL
	give_txt_ptr	addr_out,#LABEL_POP_OBTYPE
	move.l		a0,a4
	rsrc_gaddr	#0,#POPUP
	give_txt_adr	addr_out,d6
	move.l		a0,(a4)

* On gise ou degrise le champ editable "label"
* "bulle d'aide" et "commentaire"
	rsrc_gaddr		#0,#LABEL
	trouve_objc		a6,d7
	get_indirect	a6,d7,#"LABL"
	tst.l			a0
	beq			.pas_de_chunk_label
	lea			obck_string(a0),a2

	trouve_objc		addr_out,#LABEL_LABEL_TTL
	bset			#SELECTED,ob_states+1(a0)

	trouve_objc		addr_out,#LABEL_LABEL
	bclr			#DISABLED,ob_states+1(a0)
	move.l			ob_spec(a0),a1
	string_copy		a2,(a1)

	trouve_objc		addr_out,#LABEL_COMMENT_TT
	bclr			#DISABLED,ob_states+1(a0)

* si il y a un champ "label", alors il peut y avoir un champ "commentaire" ???
	get_indirect	a6,d7,#"COMT"
	tst.l			a0
	beq			.no_comment

* Oui, alors affichons !
	lea			obck_string(a0),a2
	trouve_objc		addr_out,#LABEL_COMMENT_TT
	bset			#SELECTED,ob_states+1(a0)

	trouve_objc		addr_out,#LABEL_COMMENT
	bclr			#DISABLED,ob_states+1(a0)
	move.l			ob_spec(a0),a1
	string_copy		a2,(a1)

	bra			.chunk_label_ok

.no_comment
	trouve_objc		addr_out,#LABEL_COMMENT_TT
	bclr			#SELECTED,ob_states+1(a0)
	trouve_objc		addr_out,#LABEL_COMMENT
	bset			#DISABLED,ob_states+1(a0)
	move.l			ob_spec(a0),a0
	move.l			(a0),a0
	move.b			#0,(a0)
	bra			.chunk_label_ok


.pas_de_chunk_label
	trouve_objc		addr_out,#LABEL_LABEL_TTL
	bclr			#SELECTED,ob_states+1(a0)

	trouve_objc		addr_out,#LABEL_COMMENT_TT
	bset			#DISABLED,ob_states+1(a0)
	bclr			#SELECTED,ob_states+1(a0)

	trouve_objc		addr_out,#LABEL_COMMENT
	bset			#DISABLED,ob_states+1(a0)
	move.l			ob_spec(a0),a1
	move.l			(a1),a1
	move.b			#0,(a1)

	trouve_objc		addr_out,#LABEL_LABEL
	bset			#DISABLED,ob_states+1(a0)
	bset			#DISABLED,ob_states+1(a0)
	move.l			ob_spec(a0),a1
	move.l			(a1),a1
	move.b			#0,(a1)

.chunk_label_ok
	lea		ob_spec(a5),a4
	btst		#INDIRECT-8,ob_flags(a5)
	beq		.suite
	move.l		(a4),a4		; a4 pointe vers la structure dependante du type de l'objet
.suite
	moveq.l		#0,d6
	move.b		ob_type+1(a5),d6
	move.w		d6,d0
	sub.w		#20,d0			; la table commence a partir de l'objet #20
	jmp		([.ed_table_de_saut.w,pc,d0.w*4])

* L'objet n'a qu'un texte unique
.ed_g_button
.ed_g_string
.ed_g_title
	jsr		set_one_text_line
	jsr		set_hide_pixflag
	jsr		set_hide_char
	trouve_objc	LABEL_adr,#LABEL_PTEXT
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.l		(a4),a2
.lp_cpstring
	move.b		(a2)+,(a3)+
	bne		.lp_cpstring

	bra		.ed_end
* L'objet a une tedinfo
.ed_g_text
.ed_g_boxtext
.ed_g_ftext
.ed_g_fboxtext
	jsr		set_hide_char
	jsr		set_one_text_line
	jsr		set_hide_pixflag
	trouve_objc	LABEL_adr,#LABEL_PTEXT
	move.l		ob_spec(a0),a3
	move.l		(a3),a3

	move.l		(a4),a1
	move.l		(a1),a1
.lp_cp_text
	move.b		(a1)+,(a3)+
	bne		.lp_cp_text

	cmp.w		#G_TEXT,d6
	beq		.ed_end
	cmp.w		#G_BOXTEXT,d6
	beq		.ed_end

	jsr		set_all_text_line
	trouve_objc	LABEL_adr,#LABEL_PTMPLT
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.l		(a4),a1
	move.l		4(a1),a1
.lp_cp_pvalid
	move.b		(a1)+,(a3)+
	bne		.lp_cp_pvalid

	trouve_objc	LABEL_adr,#LABEL_PVALID
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.l		(a4),a1
	move.l		8(a1),a1
.lp_cp_pvalid2
	move.b		(a1)+,(a3)+
	bne		.lp_cp_pvalid2

	bra		.ed_end

.ed_g_image
	bra		.ed_end
.ed_g_icon
.ed_g_cicon
* Le texte de l'icone
	jsr		set_one_text_line
	jsr		set_hide_pixflag
	jsr		set_show_char
	trouve_objc	LABEL_adr,#LABEL_PTEXT
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.l		(a4),a1
	move.l		ib_ptext(a1),a1
.lp_cp_txticon
	move.b		(a1)+,(a3)+
	bne		.lp_cp_txticon

* Son caractere
	trouve_objc	LABEL_adr,#LABEL_CHAR
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.l		(a4),a1
	move.b		ib_char+1(a1),(a3)+
	move.b		#0,(a3)

	bra		.ed_end

* Uniquement un caractere
.ed_g_boxchar
	jsr		set_no_text_line
	jsr		set_hide_pixflag
	jsr		set_show_char
	trouve_objc	LABEL_adr,#LABEL_CHAR
	move.l		ob_spec(a0),a3
	move.l		(a3),a3
	move.b		(a4),(a3)+
	move.b		#0,(a3)
	bra		.ed_end

.ed_g_pix
	jsr		set_one_text_line
	jsr		set_hide_char
	jsr		set_show_pixflag
	trouve_objc	LABEL_adr,#LABEL_PTEXT
	move.l		ob_spec(a0),a3
	move.l		(a3),a3

	move.l		(a4),a1
	move.l		(a1),a1
.lp_cp_chemingpix
	move.b		(a1)+,(a3)+
	bne		.lp_cp_chemingpix

	trouve_objc	LABEL_adr,#LABEL_MOSAIC
	btst		#GPIX_MOSAIC,gpix_flags+3(a3)
	beq		.no_mosaic
	bset		#SELECTED,ob_states+1(a0)
	bra		.mosaic_ok
.no_mosaic
	bclr		#SELECTED,ob_states+1(a0)
.mosaic_ok

	trouve_objc	LABEL_adr,#LABEL_MOSAIC
	btst		#GPIX_ALTERN,gpix_flags+3(a3)
	beq		.no_altern
	bset		#SELECTED,ob_states+1(a0)
	bra.s		.altern_ok
.no_altern
	bclr		#SELECTED,ob_states+1(a0)
.altern_ok

	bra		.ed_end

* Ben la, ya rien a editer... un peu nazebrock...
.ed_g_progdef
.ed_g_ibox
.ed_g_box
.ed_g_line
	jsr		set_no_text_line
	jsr		set_hide_char
	jsr		set_hide_pixflag

.ed_end
	wd_create	LABEL_adr,#wd_create_form,#-1,#0,#0,#0
	find_tab_l	#tab_adr,LABEL_adr
	move.w		d0,d3
	wd_redraw_gem	d3		; au cas ou la fenetre serait deja ouverte, on la redessine

	move.l		a6,label_win
	move.w		d7,label_objc

	movem.l		(sp)+,d1-a6
	rts

.ed_table_de_saut		 			; et c'est beaucoup plus rapide !
	dc.l	.ed_g_box
	dc.l	.ed_g_text
	dc.l	.ed_g_boxtext
	dc.l	.ed_g_image
	dc.l	.ed_g_progdef
	dc.l	.ed_g_ibox
	dc.l	.ed_g_button
	dc.l	.ed_g_boxchar
	dc.l	.ed_g_string
	dc.l	.ed_g_ftext
	dc.l	.ed_g_fboxtext
	dc.l	.ed_g_icon
	dc.l	.ed_g_title
	dc.l	.ed_g_cicon

	dc.l	0		g_bounding
	dc.l	0		g_bounded
	dc.l	.ed_g_pix
	dc.l	.ed_g_line
	dc.l	0		g_check
*--------------------------------------------------------------------------------------------------------------------------*
**** Fenetre d'edition du label **************************************
	XDEF	label_window
label_window
	cmp.w	#LABEL_OK,d1
	beq	lelabel_ok2
	cmp.w	#LABEL_APPLIQUER,d1
	beq	lelabel_ok2
	cmp.w	#LABEL_POP_OBTYPE,d1
	beq	popup
	cmp.w	#LABEL_LOAD_PIX,d1
	beq	select_pix
	cmp.w	#LABEL_LABEL_TTL,d1
	beq	ajoute_un_label
	cmp.w	#LABEL_COMMENT_TT,d1
	beq	ajoute_un_commentaire
	rts
*--------------------------------------------------------------------------------------------------------------------------*
ajoute_un_label
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_COMMENT_TT
	bchg		#DISABLED,ob_states+1(a0)
	trouve_objc	addr_out,#LABEL_LABEL
	bchg		#DISABLED,ob_states+1(a0)
	btst		#DISABLED,ob_states+1(a0)
	beq		.no_comment
	trouve_objc	addr_out,#LABEL_COMMENT
	btst		#DISABLED,ob_states+1(a0)
	bne		.no_comment
	bset		#DISABLED,ob_states+1(a0)
	trouve_objc	addr_out,#LABEL_COMMENT_TT
	bclr		#SELECTED,ob_states+1(a0)
	redraw_objc_gem	addr_out,#LABEL_COMMENT

.no_comment
	redraw_objc_gem	addr_out,#LABEL_COMMENT_TT
	redraw_objc_gem	addr_out,#LABEL_LABEL
	rts
*--------------------------------------------------------------------------------------------------------------------------*
ajoute_un_commentaire
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_COMMENT
	bchg		#DISABLED,ob_states+1(a0)
	redraw_objc_gem	addr_out,#LABEL_COMMENT
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XREF	fsel_select_gpix
select_pix
	move.l		d0,a5
	move.w		d1,d6
	trouve_objc	label_win,label_objc
	move.l		ob_spec(a0),a6
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a6),a6
.not_indirect

	string_copy	(a6),#load_pix_temp_file
	file_select	#load_pix_temp_file,#fsel_select_gpix

	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_PTEXT
	move.l		ob_spec(a0),a4
	string_copy	#load_pix_temp_file,(a4)
	redraw_objc_gem	addr_out,#LABEL_PTEXT
	xobjc_change	a5,d6
	rts
	bss
load_pix_temp_file	ds.b	1024
	text
*--------------------------------------------------------------------------------------------------------------------------*
popup
* Taille avant changement
;	objc_size	label_win,label_objc,#size_redraw_old

	XREF	popup_change_type
	jsr		popup_change_type
	move.l		label_win,-(sp)
	move.w		label_objc,-(sp)
	jsr		get_objc_info
	addq.l		#6,sp

	bra		yopyop

* Taille apres changement
	objc_size	label_win,label_objc,#size_redraw_new

* On prend la plus grande taille
	lea		size_redraw_old,a3
	lea		size_redraw_new,a4

	move.w		(a3),d0		; X
	move.w		(a4),d1
	cmp.w		d0,d1
	bge		.ok_gauche
	move.w		d1,(a3)
.ok_gauche
	add.l		#2,a3
	add.l		#2,a4

	move.w		(a3),d0		; Y
	move.w		(a4),d1
	cmp.w		d0,d1
	bge		.ok_haut
	move.w		d1,(a3)
.ok_haut
	add.l		#2,a3
	add.l		#2,a4

	move.w		(a3),d0		; W
	move.w		(a4),d1
	cmp.w		d0,d1
	bhs		.ok_largeur
	move.w		d1,(a3)
.ok_largeur
	add.l		#2,a3
	add.l		#2,a4

	move.w		(a3),d0		; H
	move.w		(a4),d1
	cmp.w		d0,d1
	bge		.ok_hauteur
	move.w		d1,(a3)
.ok_hauteur

	objc_offset	label_win,label_objc
	move.w		int_out+2,d0
	move.w		int_out+4,d1
	lea		size_redraw_old,a3
	add.w		d0,(a3)
	add.w		d1,2(a3)
	form_dial	#3,(a3)+,(a3)+,(a3)+,(a3)

yopyop
	redraw_objc_gem	label_win,label_objc
	rts
	bss
size_redraw_old	ds.w	8
size_redraw_new	ds.w	8
	text
*--------------------------------------------------------------------------------------------------------------------------*
lelabel_ok2
	move.w		d1,d5
	xobjc_change	d0,d1
	move.l		label_win,a6
	move.w		label_objc,d7

	objc_size	a6,d7,#old_cords

	trouve_objc	a6,d7
	move.l		a0,a5

* Actualise les coordonnes
	trouve_objc	LABEL_adr,#LABEL_X
	move.l		ob_spec(a0),a0
	chaine_2_long	(a0)
	move.w		d0,ob_x(a5)

	trouve_objc	LABEL_adr,#LABEL_Y
	move.l		ob_spec(a0),a0
	chaine_2_long	(a0)
	move.w		d0,ob_y(a5)

	trouve_objc	LABEL_adr,#LABEL_W
	move.l		ob_spec(a0),a0
	chaine_2_long	(a0)
	move.w		d0,ob_w(a5)

	trouve_objc	LABEL_adr,#LABEL_H
	move.l		ob_spec(a0),a0
	chaine_2_long	(a0)
	move.w		d0,ob_h(a5)

* Actualise l'ob_type etendu avec verif de debordement (<256)
	trouve_objc	LABEL_adr,#LABEL_OBTYPE
	move.l		ob_spec(a0),a0
	move.l		(a0),a0
	chaine_2_long	a0
	cmp.w		#256,d0
	bge		not_more_than_256
	move.b		d0,ob_type(a5)

	move.w		ob_w(a5),objet_w

* On met a jours la partie chunk de l'objet
* On commence par le label
	trouve_objc	LABEL_adr,#LABEL_LABEL_TTL
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_chunk_label

	give_txt_adr		LABEL_adr,#LABEL_LABEL
	set_indirect	label_win,label_objc,#"LABL",a0

* Puis le commentaire
	trouve_objc	LABEL_adr,#LABEL_COMMENT_TT
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_chunk_comment

	give_txt_adr		LABEL_adr,#LABEL_COMMENT
	set_indirect	label_win,label_objc,#"COMT",a0
	bra			.ok_chunk

* Et enfin la bulle d'aide

.no_chunk_comment
	del_indirect	label_win,label_objc,#"COMT"
	bra			.ok_chunk
.no_chunk_label
	del_indirect	label_win,label_objc,#"COMT"
	del_indirect	label_win,label_objc,#"LABL"

.ok_chunk
	lea		ob_spec(a5),a4
	btst		#INDIRECT-8,ob_flags(a5)
	beq		.suite
	move.l		(a4),a4		; a4 pointe vers la structure dependante du type de l'objet
.suite
	moveq.l		#0,d6
	move.b		ob_type+1(a5),d6
	move.w		d6,d0
	jmp		([(label_table_de_saut-20*4).w,pc,d0.w*4])

ed_label_g_title
ed_label_g_button
ed_label_g_string
	give_txt_adr	LABEL_adr,#LABEL_PTEXT
	move.l		a0,a3
	string_size	a0
	moveq.l		#0,d4
	move.w		d0,d4
	addq.l		#1,d0
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	lsl.w		#3,d4
	move.w		d4,ob_w(a5)

	bra		ed_label_end

ed_label_g_text
ed_label_g_boxtext
	move.l		(a4),a4
	give_txt_adr	LABEL_adr,#LABEL_PTEXT
	move.l		a0,a3
	string_size	a0
	move.w		d0,d4
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	subq.l		#1,d4
	move.w		d4,te_txtlen(a4)
	move.w		d4,te_tmplen(a4)
	lsl.w		#3,d4
	move.w		d4,ob_w(a5)

	bra		ed_label_end
ed_label_g_ftext
ed_label_g_fboxtext
	move.l		(a4),a4
	give_txt_adr	LABEL_adr,#LABEL_PTEXT
	move.l		a0,a3
	string_size	a0
	move.l		d0,d1
	subq.l		#1,d1
	move.w		d1,te_txtlen(a4)
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	addq.l		#4,a4
	give_txt_adr	LABEL_adr,#LABEL_PTMPLT
	move.l		a0,a3
	string_size	a0
	move.w		d0,d4
	addq.l		#1,d0
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	addq.l		#4,a4
	give_txt_adr	LABEL_adr,#LABEL_PVALID
	move.l		a0,a3
	string_size	a0
	addq.l		#1,d0
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	move.w		d4,te_tmplen(a4)
	lsl.w		#3,d4
	move.w		d4,ob_w(a5)

	bra		ed_label_end

ed_label_g_boxchar
	give_txt_adr	LABEL_adr,#LABEL_CHAR
	move.b		(a0),(a4)
	bra		ed_label_end
ed_label_g_cicon
ed_label_g_icon
	give_txt_adr	LABEL_adr,#LABEL_PTEXT
	move.l		a0,a3
	move.l		(a4),a4
	lea		ib_ptext(a4),a2
	string_size	a3
	xaloc_grow	d0,a2
	string_copy	a3,(a2)

	give_txt_adr	LABEL_adr,#LABEL_CHAR
	move.b		(a0),ib_char+1(a4)

	bra		ed_label_end
ed_label_g_pix
	move.l		(a4),a4
	give_txt_adr	LABEL_adr,#LABEL_PTEXT
	move.l		a0,a3
	string_size	a0
	move.w		d0,d4
	addq.l		#1,d0
	xaloc_grow	d0,a4
	string_copy	a3,(a4)

	move.l		d7,-(sp)
	move.l		gpix_flags(a4),d7
	trouve_objc	LABEL_adr,#LABEL_MOSAIC
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_mozaic
	bset		#GPIX_MOSAIC,d7
	bra		.mozaic_ok
.no_mozaic
	bclr		#GPIX_MOSAIC,d7
.mozaic_ok

	trouve_objc	LABEL_adr,#LABEL_ALTERNE
	btst		#SELECTED,ob_states+1(a0)
	beq		.no_altern
	bset		#GPIX_ALTERN,d7
	bra		.altern_ok
.no_altern
	bclr		#GPIX_ALTERN,d7
.altern_ok

	bset		#GPIX_DISKLOAD,d7
	move.l		d7,gpix_flags(a4)
	move.l		(sp)+,d7
	bra		ed_label_end
ed_label_g_image
ed_label_g_box
ed_label_g_progdef
ed_label_g_ibox
ed_label_g_line


ed_label_end

* Si il s'agit d'un menu deroulant...
	move.l		label_win,a5
	sub.l		#mtree_objets,a5
	cmp.l		#rptt_menu,mtree_type(a5)
	bne		not_in_a_menu

* ...alors on doit alligner les options de menu sur la taille de l'objet.
	trouve_objc	label_win,label_objc
	cmp.b		#G_TITLE,ob_type+1(a0)
	beq		.titre_de_menu
	cmp.b		#G_STRING,ob_type+1(a0)
	beq		.entree_de_menu
	bra		big_error

* C'est un titre de menu, il faut donc realigner les titres suivants et leurs G_BOX correspondant
.titre_de_menu
	move.l		a0,a4
	move.w		ob_w(a0),d1
	sub.w		objet_w,d1	; calcul de l'increment a realiser sur les G_TITLE a droite de celui edite
* Adaptation de la postion des autres titre de menu (et deroulant correspondant)
	move.w		ob_x(a4),d3
	trouve_parent	label_objc,label_win
	move.w		d0,d4
	trouve_objc	label_win,d4
	move.w		ob_head(a0),d2
.lp_align_menu
	trouve_objc	label_win,d2
	cmp.w		ob_x(a0),d3
	bge		.avant
* Alignement
	add.w		d1,ob_x(a0)
	move.l		label_win,-(sp)
	move.w		d2,-(sp)
	jsr		find_to_deroule_rout
	addq.l		#6,sp
	move.l		a0,-(sp)
	trouve_objc	label_win,d0
	add.w		d1,ob_x(a0)
	move.l		(sp)+,a0
.avant
	move.w		ob_next(a0),d2
	cmp.w		d2,d4
	bne		.lp_align_menu
	bra		not_in_a_menu

.entree_de_menu
	trouve_parent	label_objc,label_win
	move.w		d0,d4

* On cherche la taille que doit avoir le menu
	trouve_objc	label_win,d4
	move.w		ob_head(a0),d3
	moveq.l		#0,d6
.lp_trouve_max_w
	trouve_objc	label_win,d3
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.suite_trouve_max_w
	move.l		(a1),a1
.suite_trouve_max_w
	move.l		(a1),a1
	moveq.l		#-1,d2
.lp_count_char
	addq.w		#1,d2	; compte le nombre de caractere de l'objet
	tst.b		(a1)+
	bne		.lp_count_char
	cmp.w		d2,d6
	bhs		.pas_plus_grand
	move.w		d2,d6
.pas_plus_grand
	move.w		ob_next(a0),d3
	cmp.w		d3,d4
	bne		.lp_trouve_max_w

	lsl.w		#3,d6

* On doit agrandir toute la G_BOX et ses fils
	trouve_objc	label_win,d4
	move.w		d6,ob_w(a0)
	move.w		ob_head(a0),d3
.lp_agrandi_deroule
	trouve_objc	label_win,d3
	move.w		d6,ob_w(a0)
	move.w		ob_next(a0),d3
	cmp.w		d3,d4
	bne		.lp_agrandi_deroule

* On doit agrandir uniquement la G_STRING edite
not_in_a_menu
* Calul de la zone a reafficher
	objc_size	a6,d7,#new_cords
	lea		old_cords,a0
	movem.l		d0-d7,-(sp)
	movem.w		(a0),d0-d7

	add.w		d0,d2
	add.w		d1,d3
	add.w		d4,d6
	add.w		d5,d7	; transforme au format VDI
	subq.w		#1,d2
	subq.w		#1,d3
	subq.w		#1,d6
	subq.w		#1,d7

	cmp.w		d0,d4
	ble		.no_x1
	move.w		d0,d4
.no_x1	cmp.w		d1,d5
	ble		.no_y1
	move.w		d1,d5	; prend le rectange englobant les deux rectangles
.no_y1	cmp.w		d2,d6
	bge		.no_x2
	move.w		d2,d6
.no_x2	cmp.w		d3,d7
	bge		.no_y2
	move.w		d3,d7
.no_y2

	sub.w		d4,d6	; retransforme le rectange destination en coordonnes AES
	addq.w		#1,d6
	sub.w		d5,d7
	addq.w		#1,d4

	find_tab_l	#tab_adr,label_win
	get_tab		#tab_handle,d0
	cmp.w		#0,d0
	beq		.no_redraw
	redraw_cords	d0,d4,d5,d6,d7
.no_redraw
	movem.l		(sp)+,d0-d7

	redraw_objc_gem	label_win,label_objc
	cmp.w		#LABEL_APPLIQUER,d5
	beq		.do_not_close
	wd_close	LABEL_adr
.do_not_close
	rts

* On a detecter un menu, mais on edite ni un titre, ni une entree : c'est koi alors ???
big_error
	illegal
	rts
* Message d'erreur si ob_type etendu superieur a 255
not_more_than_256
	form_alert	#1,#obtype_inferieur_a_256
	rts

label_table_de_saut		 			; et c'est beaucoup plus rapide !
	dc.l	ed_label_g_box
	dc.l	ed_label_g_text
	dc.l	ed_label_g_boxtext
	dc.l	ed_label_g_image
	dc.l	ed_label_g_progdef
	dc.l	ed_label_g_ibox
	dc.l	ed_label_g_button
	dc.l	ed_label_g_boxchar
	dc.l	ed_label_g_string
	dc.l	ed_label_g_ftext
	dc.l	ed_label_g_fboxtext
	dc.l	ed_label_g_icon
	dc.l	ed_label_g_title
	dc.l	ed_label_g_cicon

	dc.l	0		g_bounding
	dc.l	0		g_bounded
	dc.l	ed_label_g_pix
	dc.l	ed_label_g_line
	dc.l	0		g_check


	bss
label_objc	ds.w	1	; represente la fenetre et l'objet dont on edite
label_win	ds.l	1	; les labels, ob_type et commentaire

objet_w		ds.w	1	; largeur de l'objet avant edition

* Attention ! Ne pas separer les deux lignes suivante ! (car movem)
old_cords	ds.w	4	; ancienne coordonnes de l'objet
new_cords	ds.w	4	; nouvelles coordonnes de l'objet
	text

*--------------------------------------------------------------------------------------------------------------------------*
**************************************************************************************
*** Fonctions cachant ou redimentionnant une partie de la boite d'edition du label ***
**************************************************************************************
set_one_text_line
	movem.l		d0-d3/a0-a3,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_PTMPLT_TTL
	bset		#HIDETREE,ob_flags+1(a0)
	trouve_objc	addr_out,#LABEL_HIDALLTXT
	bclr		#HIDETREE,ob_flags+1(a0)
	move.w		#32,ob_h(a0)

	move.l		addr_out,a0
	move.w		#196,ob_h(a0)
	jsr		set_size
	movem.l		(sp)+,d0-d3/a0-a3
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_all_text_line
	movem.l		d0-d3/a0-a3,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_PTMPLT_TTL
	bclr		#HIDETREE,ob_flags+1(a0)
	trouve_objc	addr_out,#LABEL_HIDALLTXT
	bclr		#HIDETREE,ob_flags+1(a0)
	move.w		#100,ob_h(a0)

	move.l		addr_out,a0
	move.w		#264,ob_h(a0)
	jsr		set_size
	movem.l		(sp)+,d0-d3/a0-a3
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_no_text_line
	movem.l		d0-d3/a0-a3,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_HIDALLTXT
	bset		#HIDETREE,ob_flags+1(a0)

	move.l		addr_out,a0
	move.w		#154,ob_h(a0)
	jsr		set_size
	movem.l		(sp)+,d0-d3/a0-a3
	rts

*--------------------------------------------------------------------------------------------------------------------------*
set_size
	move.l		a0,a3
	wind_calc	#0,#%1011,ob_x(a0),ob_y(a0),ob_w(a0),ob_h(a0)
	find_tab_l	#tab_adr,a3
	move.w		d0,d3
	cmp.w		#-1,d3
	beq		.no_resize
	put_tab_w	#tab_x,d3,int_out+2
	put_tab_w	#tab_y,d3,int_out+4
	put_tab_w	#tab_w,d3,int_out+6
	put_tab_w	#tab_h,d3,int_out+8
	get_tab		#tab_handle,d3
	tst.w		d0
	beq		.no_resize
	wind_set	d0,#WF_CURRXYWH,int_out+2,int_out+4,int_out+6,int_out+8
.no_resize
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_show_char
	movem.l		d0-d2/a0-a2,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_HIDCHAR
	bclr		#HIDETREE,ob_flags+1(a0)
	movem.l		(sp)+,d0-d2/a0-a2
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_hide_char
	movem.l		d0-d2/a0-a2,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_HIDCHAR
	bset		#HIDETREE,ob_flags+1(a0)
	movem.l		(sp)+,d0-d2/a0-a2
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_show_pixflag
	movem.l		d0-d2/a0-a2,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_HIDPIXFLAG
	bclr		#HIDETREE,ob_flags+1(a0)
	movem.l		(sp)+,d0-d2/a0-a2
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_hide_pixflag
	movem.l		d0-d2/a0-a2,-(sp)
	rsrc_gaddr	#0,#LABEL
	trouve_objc	addr_out,#LABEL_HIDPIXFLAG
	bset		#HIDETREE,ob_flags+1(a0)
	movem.l		(sp)+,d0-d2/a0-a2
	rts
