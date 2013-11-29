*** Definition d'un formulaire en fenetre ***
FLECHE_INC	equ	4
	text

	include	vdi.i
	include	aes.i
	include	zlib.i
	include	gemdos.i

	include	structs.s
	include	util.i

	include	..\fashion.s
	include	..\macro.i
	include	..\memory.s

*--------------------------* Message d'erreur
	XREF	sans_slider_impossible
*--------------------------* Variables ZLIBs
	XREF	x_max,y_max
	XREF	x_mouse_clik,y_mouse_clik,s_mouse_clik,n_mouse_clik
	XREF	tampon,hauteur_menu,appl_name,options
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
	XREF	evnt_key,evnt_state,ascii_key
*--------------------------* Variable VDI / AES
	XREF	contrl1
*--------------------------* Variable Fashion
	XREF	wd_create_form,wd_gadget_form
	XDEF	wd_create_drag_window
	XREF	ed_sel_objc,ed_sel_win,label_objc,label_win
	XREF	COLOR_adr,FLAG_adr,TEDINFO_adr,LABEL_adr
	XREF	reinit_flag_window
	XREF	reinit_gline_window
	XREF	reinit_tedinfo_window
	XREF	grid_origin_x,grid_origin_y
	XREF	copy_to_buff_rout,copy_to_formul_rout,erase_list_rout
wd_create_drag_window
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7			; l'offset dans les tableaux suffit !

	move.w		#4,form_border

	move.w		d7,-(sp)
	bsr		wd_create_form			; c'est presque la meme fenetre, sauf quelques routines
	addq.l		#2,sp

	put_tab_l	#tab_gadget,d7,#wd_gadget_drag	; le pointeur sur la routine de gadget et finalement
	put_tab_l	#tab_clic,d7,#wd_clic_drag	; le pointeur sur la routine de clic
	put_tab_l	#tab_rout,d7,#wd_redraw_drag	; le pointeur sur la routine de redraw
	put_tab_l	#tab_key,d7,#wd_key_drag	; le pointeur sur la routine de key

* Doit-on placer des assenceurs horisontales ?
	move.w		x_max,d5
	move.w		y_max,d6
	lsr.w		#1,d5
	lsr.w		#1,d6
	get_tab		#tab_w,d7
	cmp.w		d5,d0
	blt		.no_sliders_x

	get_tab		#tab_h,d7
	cmp.w		d6,d0
	blt		.no_sliders_x_n_y
.go_sliders
	put_tab_w	#tab_w,d7,d5
	put_tab_w	#tab_h,d7,d6

	put_tab_w	#tab_kind,d7,#%111111101111		; les attribues AES
* On verifie qu'avec tout ca, la fenetre n'a pas des coordonnes trop grandes...
	get_tab		#tab_x,d7
	move.w		d0,d3
	get_tab		#tab_y,d7
	move.w		d0,d4
	wind_calc	#1,#%111111101111,d3,d4,d5,d6
	get_tab		#tab_adr,d7
	move.l		d0,a6
	move.w		ob_w(a6),d0
	add.w		form_border,d0
	add.w		form_border,d0
	cmp.w		int_out+6,d0
	bgt		.no_change_x
	move.w		d0,int_out+6
.no_change_x
	move.w		ob_h(a6),d0
	add.w		form_border,d0
	add.w		form_border,d0
	cmp.w		int_out+8,d0
	bgt		.no_change_y
	move.w		d0,int_out+8
.no_change_y
	wind_calc	#0,#%111111101111,int_out+2,int_out+4,int_out+6,int_out+8
	put_tab_w	#tab_w,d7,int_out+6
	put_tab_w	#tab_h,d7,int_out+8
	move.w		ob_x(a6),d0
	add.w		form_border,d0
	move.w		d0,ob_x(a6)
	move.w		ob_y(a6),d0
	add.w		form_border,d0
	move.w		d0,ob_y(a6)
* Puis on quitte en donnant l'adresse de la routine qui sera appele apres la creation de fenetre
	movem.l		(sp)+,d1-a6
	move.l		#tu_calcul_sliders,d0
	rts
.no_sliders_x
	get_tab		#tab_h,d7
	cmp.w		d6,d0
	bgt		.go_sliders
.no_sliders_x_n_y
	put_tab_w	#tab_kind,d7,#%1111		; les attribues AES
	movem.l		(sp)+,d1-a6
	moveq.l		#0,d0
	rts
*------------------------------------------------*
* On reprend ici apres la creation de la fenetre
*------------------------------------------------*
tu_calcul_sliders
	move.w		4(sp),d7
	get_tab		#tab_kind,d7
	cmp.w		#%111111101111,d0
	bne		.ok

	move.w		ob_x(a6),d0
	add.w		form_border,d0
	move.w		d0,ob_x(a6)

	move.w		ob_y(a6),d0
	add.w		form_border,d0
	move.w		d0,ob_y(a6)

	bsr		slide_calc_size
	bsr		slide_calc_pos

	get_tab		#tab_adr,d7
	move.l		d0,a6


.ok	rts
;************************************* Routine de key dans la fenetre ******************************************************
wd_key_drag
	move.b	evnt_key,d7
	move.b	evnt_key+1,d6
	cmp.b	#27,d6
	beq	.escape
	cmp.b	#$4B,d7
	beq	.fleche_gauche
	cmp.b	#$4D,d7
	beq	.fleche_droite
	cmp.b	#$48,d7
	beq	.fleche_haute
	cmp.b	#$50,d7
	beq	.fleche_basse
	cmp.b	#$0E,d7
	beq	.backspace
*----------------* Ajout d'un caractere dans la chaine
* On verifie que l'objet est assez grand pour contenir un caractere en plus
	give_txt_ptr	curs_win,curs_obj
	move.l		a0,a6
	string_size	(a6)
	moveq.l		#0,d7
	moveq.l		#0,d5
	move.w		d0,d7
	move.w		d0,d5
	addq.w		#1,d7
	lsl.w		#3,d7	; Trouve la taille en pixel de la chaine (+1 caractere : celui a ajoute)

	trouve_objc	curs_win,curs_obj
	move.w		ob_w(a0),d6	; et la taille de l'objet

	cmp.w		d6,d7		; assez grand ?
	ble		.ok_assez_grand
	rts
.ok_assez_grand

* Puis on ajoute ce caractere a la position actuelle du curseur
	moveq.l		#0,d7
	move.b		evnt_key+1,d7

	moveq.l		#0,d0
	move.w		d5,d0
	addq.w		#2,d0
	xaloc_grow	d0,a6	; agrandissement de la taille du buffer pour la chaine (taille de la chaine + le caractere a ajoute + le zero de fin de chaine)

	move.l		(a6),a5

	move.w		curs_pos,d4
	lea		(a5,d4.w),a5

	move.b		(a5),d0
	move.b		d7,(a5)+
.lp_add_char
	move.b		(a5),d1
	move.b		d0,(a5)+
	beq		.end_add_char
	move.b		d1,d0
	bra		.lp_add_char

.end_add_char
	add.w		#1,curs_pos

	redraw_objc	curs_win,curs_obj
	dial_bouton	curs_win,curs_obj
	rts

*----------------*
.escape
* Des objets sont-ils selectionne
	move.l		ed_sel_win,a6
	tst.l		a6
	bne		.ya_une_selection
	rts
.ya_une_selection
	lea		ed_sel_objc,a5
.lp_escape
* Si oui, alors on les deselectionne
	redraw_objc_gem	a6,(a5)+
;	xobjc_change	a6,(a5)+
	cmp.w		#-1,(a5)
	bne		.lp_escape
	move.l		#0,ed_sel_win
	move.l		#-1,ed_sel_objc
* Et on reinitialise les fenetres falgs, color et tedinfo (fontes et alignement)
	jsr		reinit_color_window_rout
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	find_tab_l	#tab_adr,addr_out
	wd_redraw_gem	d0
	bsr		reinit_flag_window
	rsrc_gaddr	#0,#FLAG
	find_tab_l	#tab_adr,addr_out
	wd_redraw_gem	d0
	jsr		reinit_tedinfo_window
	jsr		reinit_gline_window
	rts
*----------------*
.backspace
	tst.w		curs_pos
	bne		.suite_back	; le curseur est au debut de la chaine ?
	rts
.suite_back
	trouve_objc	curs_win,curs_obj
	give_txt_ptr	curs_win,curs_obj
	move.l		a0,a6
	move.l		(a0),a5
	moveq.l		#0,d7
	move.w		curs_pos,d7
	subq.l		#1,d7
	add.l		d7,a5
	lea		1(a5),a4
.lp_backspace
	move.b		(a4)+,(a5)+
	bne		.lp_backspace
	string_size	(a6)
	moveq.l		#0,d6
	move.w		d0,d6
	addq.w		#1,d6

	xaloc_grow	d6,a6

	sub.w		#1,curs_pos

	dial_bouton	curs_win,curs_obj
	rts
*----------------*
.fleche_gauche
	move.w	curs_pos,d6
	bne	.suite_fleche_gauche
	rts
.suite_fleche_gauche
	sub.w	#1,curs_pos
	bra	.fleche_redraw_curs

*----------------*
.fleche_droite
	trouve_objc	curs_win,curs_obj
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.dr_not_indirect
	move.l		ob_spec(a0),a0
	move.l		(a0),a0
	bra		.cok_droite
.dr_not_indirect
	move.l		ob_spec(a0),a0
.cok_droite
	move.w		#-1,d5
.boucle_calcul_taille_chaine
	addq.w		#1,d5
	tst.b		(a0)+
	bne		.boucle_calcul_taille_chaine
	cmp.w		curs_pos,d5
	bgt		.suite_fleche_droite
	rts
.suite_fleche_droite
	add.w		#1,curs_pos
	bra		.fleche_redraw_curs
*----------------*
.fleche_haute
	trouve_objc	curs_win,curs_obj
	move.l		a0,a4
	cmp.w		#-1,(a4)
	beq		.non_trouve
	move.w		#1,d6
	sub.l		#24,a4
.boucle_cherche_obj_precedent
	lea		txt_objc_list,a5
	moveq.l		#0,d0
	move.b		ob_type+1(a4),d0
.boucle_test_type
	cmp.w		(a5)+,d0
	beq		.objc_trouve
	tst.w		(a5)
	bne		.boucle_test_type

	cmp.w		#-1,(a4)
	beq		.non_trouve

	addq.w		#1,d6
	sub.l		#24,a4
	bra		.boucle_cherche_obj_precedent

.objc_trouve
	move.w		curs_obj,d5
	sub.w		d6,curs_obj
	dial_bouton	curs_win,d5
	trouve_objc	curs_win,curs_obj
	move.l		a0,a1
	move.l		ob_spec(a0),a0
	btst		#INDIRECT-8,ob_flags(a1)
	beq		.haut_not_indirect
	move.l		(a0),a0
.haut_not_indirect
	move.w		#-1,d4
.calc_taille_chaine
	addq.w		#1,d4
	tst.b		(a0)+
	bne		.calc_taille_chaine
	move.w		d4,curs_pos
	dial_bouton	curs_win,curs_obj
.non_trouve
	rts
*----------------*
.fleche_basse
	trouve_objc	curs_win,curs_obj
	move.l		a0,a4
	move.w		ob_flags(a4),d0
	btst		#LASTOB,d0
	bne		.non_trouved
	move.w		#1,d6
	add.l		#24,a4
.loop_find_obj_next
	lea		txt_objc_list,a5
	moveq.l		#0,d0
	move.b		ob_type+1(a4),d0
.loop_test_type
	cmp.w		(a5)+,d0
	beq		.objc_finded
	tst.w		(a5)
	bne		.loop_test_type

	move.w		ob_flags(a4),d0
	btst		#LASTOB,d0
	bne		.non_trouved

	addq.w		#1,d6
	add.l		#24,a4
	bra		.loop_find_obj_next
.objc_finded
	move.w		curs_obj,d5
	add.w		d6,curs_obj
	dial_bouton	curs_win,d5
	trouve_objc	curs_win,curs_obj
	move.l		a0,a1
	move.l		ob_spec(a0),a0
	btst		#INDIRECT-8,ob_flags(a1)
	beq		.bas_not_indirect
	move.l		(a0),a0
.bas_not_indirect
	move.w		#-1,d4
.calcul_taille_chaine
	addq.w		#1,d4
	tst.b		(a0)+
	bne		.calcul_taille_chaine
	move.w		d4,curs_pos
	dial_bouton	curs_win,curs_obj

.non_trouved
	rts
*----------------*
.fleche_redraw_curs
	dial_bouton	curs_win,curs_obj
	rts
;************************************* Routine de clic dans la fenetre *****************************************************
wd_clic_drag
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d6		; l'offset dans les tableaux suffit !

	get_tab		#tab_handle,d6
	move.w		d0,d5
	wind_get	d5,#WF_TOP
	cmp.w		int_out+2,d5
	beq		.ok_1er_plan

	wind_set	d5,#WF_TOP
	movem.l		(sp)+,d1-a6
	rts
.ok_1er_plan
	get_tab		#tab_adr,d6
	move.l		d0,a5

	objc_find	a5,#0,#20,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
	cmp.w		#-1,d0
	bne		.on_a_trouve_un_objet
	movem.l		(sp)+,d1-a6
	rts
.on_a_trouve_un_objet
	move.w		d0,d7

	cmp		#0,d0
	bne		.clic_is_not_objc_root	; si on a clike sur l'objet root et que la fenetre n'est
	get_tab		#tab_handle,d6		; pas au premier plan, alors on top cette fenetre
	move.l		d0,d5
	wind_get	#0,#10
	cmp.w		int_out+2,d5
	beq		.clic_is_not_objc_root	; sinon, on fait un clic normal.
	wind_set	d6,#10
	movem.l		(sp)+,d1-a6
	rts

.clic_is_not_objc_root
	cmp.w		#2,n_mouse_clik
	bne		.pas_double_clic
*-------------------------------------------------------------------------------------------------*
* On a double-clike dans un objet, on veut donc editer son label, son ob_type ou son commentaire
	move.l		a5,-(sp)
	move.w		d7,-(sp)
	XREF		get_objc_info
	jsr		get_objc_info
	addq.l		#6,sp
	movem.l		(sp)+,d1-a6
	rts

.pas_double_clic
	cmp.w		#2,s_mouse_clik
	bne		bouton_gauche
*-------------------------------------------------------------------------------------------------*
* clic gauche
	* cliquer-relacher -> selectionner/deselectionner un objet
	* cliquer-glisser  -> deplace un objet dans une fenetre
* clic droit
	* cliquer-relacher -> copier un objet et ses fils d'une fenetre a l'autre
	* cliquer-glisser  -> redimentionne un objet dans une fenetre

.drag_evnt_multi
	evnt_multi	#4+2,#1,#2,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1 ; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0			; on a relacher le bouton -> on veut donc copier l'objet
	bne		go_copy_objet		; sinon, on a bouger la sourie... -> donc on veut deplacer l'objet
	btst		#2,d0
	bne		redimentionne_lobjet_routine
	bra		.drag_evnt_multi	; on n'accepte que cest 2 messages...

* Doit-on selectionner l'objet ou le redimentionner ?
bouton_gauche
	vq_key_s
	cmp.w		#%1000,intout	; si alternate + bouton gauche, alors selection multiple
	beq		multiple_select

.drag_evnt_multi
	evnt_multi	#4+2,#1,#1,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1
						; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0				; on a relacher le bouton -> on veut donc copier l'objet
	bne		selectionne_lobjet	; sinon, on a bouger la sourie... -> donc on veut deplacer l'objet
	btst		#2,d0
	bne		deplace_lobjet
	bra		.drag_evnt_multi	; on n'accepte que cest 2 messages...

go_copy_objet
	tst.w		d7
	beq		.pas_control
	vq_key_s
	cmp.w		#%100,intout
	bne		.pas_control

	trouve_parent	d7,a5
	move.w		d0,d7

.pas_control
	get_tab		#tab_adr,d6
	copy_objet	d0,d7
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
multiple_select
	move.w		x_mouse_clik,d3
	move.w		y_mouse_clik,d4

* Trouve l'objet clik‚ et les coordonnees mini des objets dans le rubber
	objc_find	a5,#0,#100,d3,d4
	move.w		int_out,parent_id

	objc_offset	a5,int_out

	move.w		d3,d1
	sub.w		int_out+2,d1
	move.w		d1,parent_x	; x_min

	move.w		d4,d2
	sub.w		int_out+4,d2
	move.w		d2,parent_y	; y_min

	trouve_objc	a5,parent_id
	move.l		a0,a3
	cmp.w		#-1,ob_head(a0)
	beq		.no_selection

* Dessinne un rectangle de redimentionnement
	graf_rubberbox	d3,d4,#$8001,#$8001

	move.w		int_out+2,d5
	move.w		int_out+4,d7

	lea		ed_sel_objc,a4
	cmp.w		#-1,(a4)
	bne		.trouve_la_fin_de_liste

	move.l		a5,ed_sel_win
	bra		.ok

.trouve_la_fin_de_liste
	cmp.w		#-1,(a4)+
	bne		.trouve_la_fin_de_liste		; on ajoute en fin de liste
	subq.l		#2,a4

.ok

* Trouve tous les objets dans le rectangle de selection et ajout l'id dans la liste
	move.w		parent_id,d1
	move.w		ob_head(a3),d2
	move.w		parent_x,d3
	move.w		parent_y,d4
	add.w		d3,d5
	add.w		d4,d7
.lp_select
	trouve_objc	a5,d2

	move.w		ob_x(a0),d0
	cmp.w		d0,d3
	bgt		.not_this

	add.w		ob_w(a0),d0
	cmp.w		d0,d5
	blt		.not_this

	move.w		ob_y(a0),d0
	cmp.w		d0,d4
	bgt		.not_this

	add.w		ob_h(a0),d0
	cmp.w		d0,d7
	blt		.not_this

	move.w		d2,-(sp)
	bsr		set_obj
	addq.l		#2,sp

.not_this
	move.w		ob_next(a0),d2
	cmp.w		d2,d1
	bne		.lp_select

	wd_redraw_gem	d6
.no_selection
	movem.l		(sp)+,d1-a6
	rts
	*----------------------------------------*
* Ajoute ou suprime un objet dans la liste de selection
set_obj
	movem.l		d7/a5/a6,-(sp)
	move.w		16(sp),d7
	lea		ed_sel_objc,a6
.lp_set
	cmp.w		(a6),d7
	beq		.trouved
	cmp.w		#-1,(a6)+
	bne		.lp_set
* Si pas trouver, alors on ajoute en fin de liste
	subq.l		#2,a6
	move.w		d7,(a6)+
	move.l		#-1,(a6)
	movem.l		(sp)+,d7/a5/a6
	rts
* Si trouve, alors on enleve de la liste
.trouved
	lea		2(a6),a5
.lp_out_obj
	move.w		(a5)+,(a6)+
	cmp.w		#-1,-2(a6)
	bne		.lp_out_obj
	move.w		#-1,(a6)
	movem.l		(sp)+,d7/a5/a6
	rts
	*----------------------------------------*
	bss
parent_adr	ds.l	1
parent_id	ds.w	1
parent_x	ds.w	1
parent_y	ds.w	1
*--------------------------------------------------------------------------------------------------------------------------*
************************************************
*** Deplace un objet et ses fils a la sourie ***
************************************************
	bss
grid_x	ds.w	1
grid_y	ds.w	1
previous_x	ds.w	1
previous_y	ds.w	1
last_cord_obj	ds.w	8
new_cord_obj	ds.w	8
	text
deplace_lobjet
	tst.w		d7
	beq		.pas_control
	vq_key_s
	cmp.w		#%100,intout
	bne		.pas_control

	trouve_parent	d7,a5
	move.w		d0,d7

.pas_control

	rsrc_gaddr	#0,#PREF
	move.l		addr_out,a6
	give_txt_adr	a6,#PREF_GRIDX
	chaine_2_long	a0
	move.w		d0,grid_x
	give_txt_adr	a6,#PREF_GRIDY
	chaine_2_long	a0
	move.w		d0,grid_y

* sauvegarde des coordonnees de la sourie.
	move.w		int_out+2,d5
	move.w		int_out+4,d4
	move.w		d5,x_mouse_clik
	move.w		d4,y_mouse_clik

* La fenetre est-elle bien au premier plan ?
	wind_get	#0,#10
	get_tab		#tab_handle,d6
	cmp.w		int_out+2,d0
	beq		.tst_deplace
	wind_set	d0,#10
.fin_deplace
	movem.l		(sp)+,d1-a6
	rts

* Sagit-il de l'objet root ?
.tst_deplace
	tst.w		d7
	beq		.fin_deplace		; si oui on sort

* On calcul les X et Y maxi de l'objet (dans a3.w et a4.w)
	trouve_parent	d7,a5
;	move.w		d0,d6
	trouve_objc	a5,d0
	move.w		ob_w(a0),a3
	move.w		ob_h(a0),a4
	trouve_objc	a5,d7
	sub.w		ob_w(a0),a3	; X et Y maxi dans a3.w/a4.w
	sub.w		ob_h(a0),a4

	objc_offset	a5,d7
	move.w		x_mouse_clik,d0
	move.w		y_mouse_clik,d1		; rapport a la sourie au moment du clic
	sub.w		int_out+2,d0		; deplacement relatif par
	sub.w		int_out+4,d1
	move.w		d0,previous_x
	move.w		d1,previous_y

	bra		.deplace_lobjet_now

.deplace_lobjet_premierplan
* On determine le deplacement relatif de l'objet
	move.w		int_out+2,d5
	move.w		int_out+4,d4
	move.w		d5,x_mouse_clik
	move.w		d4,y_mouse_clik

.deplace_lobjet_now

* Update d5 et d6 pour tenir compte de l'endroit dans l'objet ou l'on a clique (mode special sacha)
	sub.w		previous_x,d5	; coordonnees ecran du coin en haut a gauche
	sub.w		previous_y,d4	; de l'objet sans tenir compte de la grille

	objc_size	a5,d7,#last_cord_obj

	move.w		int_out+8,d0
	btst		#0,d0
	bne		.shifted
	btst		#1,d0
	beq		.not_shifted

.shifted

* Update d5 et d6 pour tenir compte de la grille et de l'endroit dans l'objet ou l'on a clique
	moveq.l		#0,d0
	move.w		grid_origin_x,d0
	divu.w		grid_x,d0
	swap		d0

	moveq.l		#0,d1
	move.w		d5,d1
	sub.w		d0,d1		; x' = x - origine_x

	move.w		grid_x,d2
	lsr.w		#1,d2
	add.w		d2,d1		; x" = x' + (grid_x / 2)   cad arrondi au plus proche pas (pas a gauche)

	divu.w		grid_x,d1
	mulu.w		grid_x,d1	; x"'= x" alligne sur le pas
	add.w		d0,d1		; decallage pour l'origine de la grille
	move.w		d1,d5

* Idem pour le Y
	moveq.l		#0,d0
	move.w		grid_origin_y,d0
	divu.w		grid_y,d0
	swap		d0

	moveq.l		#0,d1
	move.w		d4,d1
	sub.w		d0,d1		; y' = y - origine_y

	move.w		grid_y,d2
	lsr.w		#1,d2
	add.w		d2,d1		; y" = y' + (grid_y / 2)   cad arrondi au plus proche pas (pas en haut)

	divu.w		grid_y,d1
	mulu.w		grid_y,d1	; y"'= y" alligne sur le pas
	add.w		d0,d1		; decallage pour l'origine de la grille
	move.w		d1,d4

.not_shifted
	trouve_parent	d7,a5
	objc_offset	a5,d0
;	objc_offset	a5,d6
	sub.w		int_out+2,d5
	sub.w		int_out+4,d4

* Et on update l'objet en consequence, tout en limitant au dimention de l'objet pere !
	trouve_objc	a5,d7
	move.l		a0,a6

	tst.w		d5		; ne depace pas a gauche
	bgt		.x_is_ok1
	clr.w		d5
.x_is_ok1
	cmp.w		d5,a3		; ni a droite
	bgt		.x_is_ok2
	move.w		a3,d5
.x_is_ok2
	move.w		d5,ob_x(a0)

* Idem Y
	tst.w		d4		; ni en haut
	bgt		.y_is_ok1
	clr.w		d4
.y_is_ok1
	cmp.w		d4,a4		; in en bas !
	bgt		.y_is_ok2
	move.w		a4,d4
.y_is_ok2
	move.w		d4,ob_y(a0)

* On redessine le parent mais en ne prenant que le rectangle qui a changer (le rectangle englobant l'ancienne position
* et la nouvelle) : pour ce faire on place le rectangle dans new_cord_obj
	movem.l		d0-d2/a0/a1,-(sp)

	objc_size	a5,d7,#new_cord_obj
	lea		last_cord_obj,a0
	lea		new_cord_obj,a1

	move.w		(a0),d0
	move.w		(a1),d1
	move.w		d0,d2
	sub.w		d1,d2
	bpl		.x_positif
	neg.w		d2
.x_positif
	add.w		d2,4(a1)	; prend la lageur du rectangle englobant

	cmp.w		d0,d1
	ble		.dep_gauche
	move.w		(a0),(a1)	; garde le X le plus a gauche

.dep_gauche

	move.w		2(a0),d0	; idem pour les Y et H
	move.w		2(a1),d1
	move.w		d0,d2
	sub.w		d1,d2
	bpl		.y_positif
	neg.w		d2
.y_positif
	add.w		d2,6(a1)

	cmp.w		d0,d1
	ble		.dep_haut
	move.w		2(a0),2(a1)

.dep_haut

	get_tab		#tab_handle,d6

	redraw_cords	d0,(a1),2(a1),4(a1),6(a1)

	movem.l		(sp)+,d0-d2/a0/a1

;	redraw_cords	#2,#0,#0,x_max,y_max

;	trouve_parent	d7,a5
;	redraw_objc	a5,d0

	move.l		a4,-(sp)
	rsrc_gaddr	#0,#MAIN
	move.l		addr_out,a4
	moveq.l		#0,d4
	moveq.l		#0,d5
	move.w		ob_x(a6),d4
	move.w		ob_y(a6),d5
	give_txt_adr	a4,#MAIN_XPOSREL
	long_2_chaine	d4,a0,#5
	give_txt_adr	a4,#MAIN_YPOSREL
	long_2_chaine	d5,a0,#5

	objc_offset	a5,d7
	move.w		int_out+2,d4
	move.w		int_out+4,d5
	sub.w		ob_x(a5),d4
	sub.w		ob_y(a5),d5
	give_txt_adr	a4,#MAIN_XPOSROOT
	long_2_chaine	d4,a0,#5
	give_txt_adr	a4,#MAIN_YPOSROOT
	long_2_chaine	d5,a0,#5

	redraw_objc	a4,#MAIN_CORDS
	move.l		(sp)+,a4

.deplace_evnt_multi
	evnt_multi	#4+2,#1,#1,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1
						; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0			; on a relacher le bouton -> on a fini le deplacement
	bne		.fin_deplacement	; sinon, on a bouger la sourie... -> donc on veut continuer a deplacer
	btst		#2,d0
	bne		.deplace_lobjet_premierplan
	bra		.deplace_evnt_multi	; on n'accepte que cest 2 messages...

.fin_deplacement

	movem.l		(sp)+,d1-a6
	rts
*-------------------------------------------------------------------------------------------------*
redimentionne_lobjet_routine
	tst.w		d7
	beq		.pas_control
	vq_key_s
	cmp.w		#%100,intout
	bne		.pas_control

	trouve_parent	d7,a5
	move.w		d0,d7

.pas_control
	rsrc_gaddr	#0,#PREF
	move.l		addr_out,a6
	give_txt_adr	a6,#PREF_GRIDX
	chaine_2_long	a0
	move.w		d0,grid_x
	give_txt_adr	a6,#PREF_GRIDY
	chaine_2_long	a0
	move.w		d0,grid_y

	tst.w		d7
	bne		.redimentionne_lobjet

.redimentionne_lobjet_root
* Calcul les W et H mini de l'objet root
	cmp.w		#-1,ob_head(a0)
	bne		.des_fils
.des_fils
	trouve_objc	a5,ob_head(a5)
	move.w		ob_x(a0),d6
	add.w		ob_w(a0),d6
	move.w		ob_y(a0),d7
	add.w		ob_h(a0),d7
.boucle_des_fils
	move.w		ob_x(a0),d5
	add.w		ob_w(a0),d5
	cmp.w		d5,d6
	bge		.pas_plus_large
	move.w		d5,d6
.pas_plus_large
	move.w		ob_y(a0),d5
	add.w		ob_h(a0),d5
	cmp.w		d5,d7
	bge		.pas_plus_haut
	move.w		d5,d7
.pas_plus_haut
	tst.w		ob_next(a0)
	beq		.fini_les_objets
	trouve_objc	a5,ob_next(a0)
	bra		.boucle_des_fils
.fini_les_objets
	move.w		ob_x(a5),d4
	move.w		ob_y(a5),d5
	vsl_color	#1
	vswr_mode	#3
	graf_mouse	#256
	wind_update	#1
	wind_update	#3
.boucle_rectangle
	v_rect		d4,d5,x_mouse_clik,y_mouse_clik	; affichage du rectangle
	evnt_multi	#4+2,#1,#2,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1
						; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0			; on a relacher le bouton -> on veut donc copier l'objet
	bne		.fin_dimention		; sinon, on a bouger la sourie... -> donc on veut deplacer l'objet
	btst		#2,d0
	bne		.redim_objet_root
	bra		.redimentionne_evnt_multi	; on n'accepte que cest 2 messages...

.redim_objet_root
	v_rect		d4,d5,x_mouse_clik,y_mouse_clik	; effacement du rectangle
* On verifie que le rectangle choisi n'est pas trop petit
* En X...
	move.w		d4,d0
	add.w		d6,d0
	cmp.w		int_out+2,d0
	blt		.ok_x
	move.w		d0,x_mouse_clik
	bra		.ok2_x
.ok_x
	move.w		int_out+2,x_mouse_clik
.ok2_x
* ... et en Y !
	move.w		d5,d0
	add.w		d7,d0
	cmp.w		int_out+4,d0
	blt		.ok_y
	move.w		d0,y_mouse_clik
	bra		.ok2_y
.ok_y
	move.w		int_out+4,y_mouse_clik
.ok2_y

	bra		.boucle_rectangle

* On a lache la sourie, in faut maintenant redimentionner l'objet root !
.fin_dimention
	v_rect		d4,d5,x_mouse_clik,y_mouse_clik	; effacement du rectangle
* Cliping du rectangle sur les W et H mini
	move.w		d4,d0
	add.w		d6,d0
	cmp.w		int_out+2,d0
	blt		.newok_x
	move.w		d0,x_mouse_clik
	bra		.newok2_x
.newok_x
	move.w		int_out+2,x_mouse_clik
.newok2_x
* ... et en Y !
	move.w		d5,d0
	add.w		d7,d0
	cmp.w		int_out+4,d0
	blt		.newok_y
	move.w		d0,y_mouse_clik
	bra		.newok2_y
.newok_y
	move.w		int_out+4,y_mouse_clik
.newok2_y
* Reinitialisation du contexte.
	wind_update	#2
	wind_update	#0
	graf_mouse	#257
	vswr_mode	#1
* Redimentionnement de l'objet root.
	move.w		x_mouse_clik,d6
	move.w		y_mouse_clik,d7
	sub.w		d4,d6
	sub.w		d5,d7
	cmp.w		#4,d6
	bgt		.w_ok
	move.w		#4,d6
.w_ok
	cmp.w		#4,d7
	bgt		.h_ok
	move.w		#4,d7
.h_ok
	move.w		d6,ob_w(a5)
	move.w		d7,ob_h(a5)
	find_tab_l	#tab_adr,a5
	move.w		d0,d7
	get_tab		#tab_kind,d7
	cmp.w		#%1111,d0
	beq		.resize_form
* Si on a des sliders, alors il faut verifier que la fenetre n'est pas trop grande si le formulaire a ete redimentionne
	get_tab		#tab_handle,d7
	wind_get	d0,#WF_WORKXYWH
* Doit-on resizer ?
	move.w		ob_w(a5),d5
	add.w		form_border,d5
	add.w		form_border,d5
	move.w		ob_h(a5),d6
	add.w		form_border,d6
	add.w		form_border,d6
	cmp.w		int_out+6,d5
	bgt		.no_size_x
	move.w		d5,int_out+6
	cmp.w		int_out+8,d6
	bgt		.size_xy
	move.w		d6,int_out+8
.size_xy
	wind_calc	#0,#%111111101111,int_out+2,int_out+4,int_out+6,int_out+8
	get_tab		#tab_handle,d7
	wind_set	d0,#WF_CURRXYWH,int_out+2,int_out+4,int_out+6,int_out+8
	bra		.no_size_wind
.no_size_x
	cmp.w		int_out+8,d6
	bgt		.no_size_wind
	move.w		d6,int_out+8
	bra		.size_xy

.no_size_wind
* Doit-on deplacer le formulaire ?
	move.w		ob_x(a5),d3
	add.w		form_border,d3
	add.w		form_border,d3
	add.w		ob_w(a5),d3

	move.w		ob_y(a5),d4
	add.w		form_border,d4
	add.w		form_border,d4
	add.w		ob_h(a5),d4

	get_tab		#tab_handle,d7
	wind_get	d0,#WF_WORKXYWH
	move.w		int_out+2,d1
	add.w		int_out+6,d1
	cmp.w		d1,d3
	bgt		.no_deplace_x
	move.w		d1,d0
	sub.w		ob_w(a5),d0
	sub.w		form_border,d0
	move.w		d0,ob_x(a5)
.no_deplace_x
	move.w		int_out+4,d1
	add.w		int_out+8,d1
	cmp.w		d1,d4
	bgt		.no_deplace_y
	move.w		d1,d0
	sub.w		ob_h(a5),d0
	sub.w		form_border,d0
	move.w		d0,ob_y(a5)
.no_deplace_y
	wd_redraw_gem	d7
	bsr		slide_calc_pos
	bsr		slide_calc_size
	movem.l		(sp)+,d1-a6
	rts
* S'il n'y a pas de slider, un simple redimentionnement de la fenetre suffit.
.resize_form
	wind_calc	#0,#%1111,ob_x(a5),ob_y(a5),ob_w(a5),ob_h(a5)
	put_tab_w	#tab_x,d7,int_out+2
	put_tab_w	#tab_y,d7,int_out+4
	put_tab_w	#tab_w,d7,int_out+6
	put_tab_w	#tab_h,d7,int_out+8
	get_tab		#tab_handle,d7
	wind_set	d0,#WF_CURRXYWH,int_out+2,int_out+4,int_out+6,int_out+8
	movem.l		(sp)+,d1-a6
	rts
*-------------------------------------------------------------------------------------------------------------*
* Redimentionnement a la sourie d'un objet autre que l'objet racine.
.redimentionne_lobjet
* La fenetre est-elle au premier plan ?
	move.w		int_out+2,d2
	move.w		int_out+4,d3
	move.w		d4,d2
	move.w		d5,d3

	wind_get	#0,#10
	get_tab		#tab_handle,d6
	cmp.w		int_out+2,d0
	beq		.redim_premierplan
	wind_set	d0,#10
	movem.l		(sp)+,d1-a6
	rts

.redim_premierplan
* Quelques infos diverses...
	trouve_parent	d7,a5		; l'index du parent pour faire un redraw.
	move.w		d0,d6
	trouve_objc	a5,d7		; l'adresse de l'objet pour modifier ses dimention.
	move.l		a0,a4

* calcul de la taille maximum de l'objet
	objc_offset	a5,d7
	move.w		int_out+2,a6	; coordonnee x et y de l'objet a redimentionner
	move.w		int_out+4,a3

	trouve_objc	a5,d6		; l'adresse du parent pour le cliping.

	move.l		a0,-(sp)
	objc_offset	a5,d6		; coordonne x et y du coin en bas a droite de l'objet parent
	move.l		(sp)+,a2

	move.w		int_out+2,a0
	move.w		int_out+4,a1
	add.w		ob_w(a2),a0
	add.w		ob_h(a2),a1

	sub.w		a6,a0
	sub.w		a3,a1
	move.w		a0,a6
	move.w		a1,a3	; a3 et a6 contienne les W et H maxi de l'objet a redimentionner
* On est pres de quel coin de l'objet ???
.redim_lobjet_premierplan
	objc_offset	a5,d7
	sub.w		int_out+2,d2	; coordonnees sourie - coordonnees de l'objet = W et H
	sub.w		int_out+4,d3

* on place les W et H dans l'objet tout et clipant
* pour pas qu'il sorte de la boite parent et en respectant la grille
	cmp.w		d2,a6		; le W ne doit pas depasser de la boite parent
	bgt.s		.w_is_ok
	move.w		a6,d2
.w_is_ok

* Est-ce que on appuis sur SHIFT, cad est-ce qu'on utilise la grille ?
	move.w		int_out+8,d0
	btst		#0,d0
	bne		.yalagrille
	btst		#1,d0
	bne		.yalagrille

	bra		.yapas_la_grille

* On aligne W sur le pas de la grille
.yalagrille
	cmp.w		grid_x,d2
	bge		.grid_pas_trop_w	; taille mini = celle de la grille
	move.w		grid_x,d2
.grid_pas_trop_w
	movem.l		d1/d3-d5,-(sp)
	move.w		d2,d0
	move.w		grid_x,d1
	divu.w		d1,d0
	mulu.w		d1,d0	; arrondi par default
	move.w		d2,d3
	sub.w		d0,d3
	lsr.w		#1,d1
	cmp.w		d1,d3	; a gauche ou a droite ?
	blt		.align_gauche
	add.w		grid_x,d0
.align_gauche
	move.w		d0,d2
	movem.l		(sp)+,d1/d3-d5

* Meme routine pour les H
	cmp.w		grid_y,d3
	bge		.grid_pas_trop_h
	move.w		grid_y,d3
.grid_pas_trop_h
	movem.l		d1/d2/d4/d5,-(sp)
	move.w		d3,d0
	move.w		grid_y,d1
	divu.w		d1,d0
	mulu.w		d1,d0
	move.w		d3,d2
	sub.w		d0,d2
	lsr.w		#1,d1
	cmp.w		d1,d2
	blt		.align_haut
	add.w		grid_y,d0
.align_haut
	move.w		d0,d3
	movem.l		(sp)+,d1/d2/d4/d5

* On verrifi que l'objet n'est ni trop petit ni trop grand
.yapas_la_grille
	cmp.w		#2,d2
	bge		.w_mini_ok
	move.w		#2,d2
.w_mini_ok

	cmp.w		#2,d3
	bge		.h_mini_ok
	move.w		#2,d3
.h_mini_ok

	cmp.w		a6,d2
	ble		.w_maxi_ok		
	move.w		a6,d2
.w_maxi_ok

	cmp.w		a3,d3
	ble		.h_maxi_ok		
	move.w		a3,d3
.h_maxi_ok		

* On test le type de l'objet, et on verifie qu'en fonction de ce type l'objet a les bonnes dimention
* pour afficher le texte de celui-ci


* Et enfin on modifi ses largeur et hauteur
	move.w		d2,ob_w(a4)
	move.w		d3,ob_h(a4)

	redraw_objc	a5,d6		; et on redessine le parent.

	movem.l		d1-a6,-(sp)
	rsrc_gaddr	#0,#MAIN
	move.l		addr_out,a3
	move.w		ob_w(a4),d4
	move.w		ob_h(a4),d5
	give_txt_adr	a3,#MAIN_WPOS
	long_2_chaine	d4,a0,#5
	give_txt_adr	a3,#MAIN_HPOS
	long_2_chaine	d5,a0,#5

	redraw_objc	a3,#MAIN_WPOS
	redraw_objc	a3,#MAIN_HPOS
	movem.l		(sp)+,d1-a6

.redimentionne_evnt_multi
	evnt_multi	#4+2,#1,#2,#0,#1,d4,d5,#1,#1
	move.w		int_out+2,d2
	move.w		int_out+4,d3
	move.w		d2,d4
	move.w		d3,d5
						; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0				; on a relacher le bouton -> on veut donc copier l'objet
	bne		.fin_redimentionne	; sinon, on a bouger la sourie... -> donc on veut deplacer l'objet
	btst		#2,d0
	bne		.redim_lobjet_premierplan
	bra		.redimentionne_evnt_multi	; on n'accepte que cest 2 messages...


.fin_redimentionne
	movem.l		(sp)+,d1-a6
	rts

****************************************************************************************************************************
****************************************************************************************************************************
****************************************************************************************************************************
*** On veut selectionner l'objet d7 de la fenettre d6
* Params :
* d7 = objet qu'on vient de cliquer
* d6 = offset de la fenettre dans le tableau ZLIB
* a5 = adresse du formulaire
selectionne_lobjet
* On verifi que l'objet n'existe pas deja dans la selection
	tst.w		d7
	beq		.pas_control
	vq_key_s
	cmp.w		#%100,intout
	bne		.pas_control

	trouve_parent	d7,a5
	move.w		d0,d7

.pas_control
	redraw_objc_gem	a5,d7
;	xobjc_change	a5,d7
	lea		ed_sel_objc,a3
	move.l		ed_sel_win,d5
	beq		.nouvel_selection
	cmp.l		a5,d5
	beq		.meme_fenetre
;* On a selectionne un objet alors qu'une fenetre a deja des objets selectionnes
.loop_deselection
	redraw_objc_gem	d4,(a3)
;	xobjc_change	d4,(a3)
	addq.l		#2,a3
	cmp.w		#-1,(a3)
	bne		.loop_deselection
	lea		ed_sel_objc,a3

;* Puisqu'on a une liste vide, il "suffit" de placer l'adresse de la fenetre et l'index du bouton.
.nouvel_selection
	move.l		a5,ed_sel_win
	move.w		d7,ed_sel_objc
	move.l		#-1,ed_sel_objc+2
	bra		.liste_is_ok

;* Notre objet est-il deja dans la liste ? Si oui, alors on l'enleve la liste
.meme_fenetre
	cmp.w	(a3),d7
	beq	.deja_dans_la_liste
	cmp.w	#-1,(a3)+
	bne	.meme_fenetre

;* Ici, l'objet n'est pas dans la liste, il faut donc le rajouter...
	subq.l	#2,a3
	move.w	d7,(a3)+
	move.l	#-1,(a3)
	bra	.liste_is_ok

;* L'objet est-il seul dans la liste d'objet ?
.deja_dans_la_liste
	cmp.l	#ed_sel_objc,a3
	bne	.retire_lobjet
	cmp.w	#-1,2(a3)
	beq	.dernier_objet_liste_vide

;* L'objet est deja dans la liste, il faut donc le retirer
.retire_lobjet
	lea	2(a3),a2
.boucle_retire_objet
	move.w	(a2),(a3)+
	cmp.w	#-1,(a2)+
	bne	.boucle_retire_objet
	bra	.liste_is_ok

.dernier_objet_liste_vide
	move.l		#-1,ed_sel_objc
	clr.l		ed_sel_win

	reinit_color_window
	bsr		reinit_flag_window
	jsr		reinit_tedinfo_window
	jsr		reinit_gline_window

	find_tab_l	#tab_adr,COLOR_adr
	cmp.l		#-1,d0
	beq		.liste_vide_redraw1
	wd_redraw	d0
.liste_vide_redraw1
	find_tab_l	#tab_adr,FLAG_adr
	cmp.l		#-1,d0
	beq		.liste_vide_redraw2
	wd_redraw	d0
.liste_vide_redraw2
	movem.l		(sp)+,d1-a6
	rts

.liste_is_ok
************************************************************************************************
*** La liste est desormait comme il faut : il faut maintenant reafficher les caracteristique ***
*** des l'objets contenu dans le tableau ed_sel_objc[...]                                    ***
************************************************************************************************
* On place les bits de l'objet dans le formulaire FLAG
;	evnt_timer	#40
;	xobjc_change	ed_sel_win,d7
;	evnt_timer	#40
;	xobjc_change	ed_sel_win,d7


	rsrc_gaddr	#0,#FLAG
	move.l		addr_out,fenetre_avekeu_les_flags
	move.l		addr_out,a4

* boucle de positionnement des flags dans le formulaire
	lea		ed_sel_objc,a6
	cmp.w		#-1,(a6)
	bne		.suite_affiche
	jsr		reinit_tedinfo_window
	reinit_color_window
	movem.l		(sp)+,d1-a6
	rts
.suite_affiche
	move.l		a6,a3
	clr.w		d5	; compteur de flag
boucle_reaffiche_flag
	move.l		a3,a6
	move.w		#FLAG_0,d0
	add.w		d5,d0
	trouve_objc	a4,d0
	move.w		ob_states(a0),d1	; pret pour une modification
	bclr		#DISABLED,d1

	trouve_objc	a5,(a6)
	move.w		ob_flags(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	beq		.flag_a_zero

.flag_a_un
	cmp.w		#-1,(a6)
	beq		.dernier_objet_un
	trouve_objc	a5,(a6)
	move.w		ob_flags(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	bne		.flag_a_un

	bra		.dernier_objet_deferent

.flag_a_zero
	cmp.w		#-1,(a6)
	beq		.dernier_objet_zero
	trouve_objc	a5,(a6)
	move.w		ob_flags(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	beq		.flag_a_zero

	bra		.dernier_objet_deferent

.dernier_objet_un
	bset		#SELECTED,d1		; selectionne
	move.w		#%0000000100000000,d2	; texte en noire
	bra		fin_boucle_attribut

.dernier_objet_zero
	bclr		#SELECTED,d1		; non selectionne
	move.w		#%0000000100000000,d2	; texte en noire
	bra		fin_boucle_attribut

.dernier_objet_deferent
	bset		#SELECTED,d1		; selectionne
	move.w		#%001000000000,d2	; texte en ROUGE

fin_boucle_attribut
	move.w		#FLAG_0,d0
	add.w		d5,d0
	trouve_objc	a4,d0
	move.w		d1,ob_states(a0)
	move.l		ob_spec(a0),a1
	move.w		d2,te_color(a1)
	addq.w		#1,d5
	cmp.w		#16,d5
	bne		boucle_reaffiche_flag

	*************************************
	lea		ed_sel_objc,a6
	move.l		a6,a3
	clr.w		d5	; compteur de flag

boucle_reaffiche_state
	move.l		a3,a6
	move.w		#STATE_0,d0
	add.w		d5,d0
	trouve_objc	a4,d0
	move.w		ob_states(a0),d1	; pret pour une modification
	bclr		#DISABLED,d1

	trouve_objc	a5,(a6)
	move.w		ob_states(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	beq		.flag_a_zero

.flag_a_un
	cmp.w		#-1,(a6)
	beq		.dernier_objet_un
	trouve_objc	a5,(a6)
	move.w		ob_states(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	bne		.flag_a_un

	bra		.dernier_objet_deferent

.flag_a_zero
	cmp.w		#-1,(a6)
	beq		.dernier_objet_zero
	trouve_objc	a5,(a6)
	move.w		ob_states(a0),d0
	addq.l		#2,a6
	btst		d5,d0
	beq		.flag_a_zero

	bra		.dernier_objet_deferent

.dernier_objet_un
	bset		#SELECTED,d1		; selectionne
	move.w		#%0000000100000000,d2	; texte en noire
	bra		fin_boucle_state

.dernier_objet_zero
	bclr		#SELECTED,d1		; non selectionne
	move.w		#%0000000100000000,d2	; texte en noire
	bra		fin_boucle_state

.dernier_objet_deferent
	bset		#SELECTED,d1		; selectionne
	move.w		#%001000000000,d2	; texte en ROUGE

fin_boucle_state
	move.w		#STATE_0,d0
	add.w		d5,d0
	trouve_objc	a4,d0
	move.w		d1,ob_states(a0)
	move.l		ob_spec(a0),a1
	move.w		d2,te_color(a1)
	addq.w		#1,d5
	cmp.w		#16,d5
	bne		boucle_reaffiche_state

* on grise le lastob
	trouve_objc	a4,#FLAG_5
	move.w		ob_states(a0),d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)

* on grise le indirect
	trouve_objc	a4,#FLAG_8
	move.w		ob_states(a0),d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)
* on fait un redraw de la fenetre FLAG...
	find_tab_l	#tab_adr,fenetre_avekeu_les_flags
	cmp.l		#-1,d0
	beq		fenetre_flag_pas_ouverte
	wd_redraw_gem	d0
fenetre_flag_pas_ouverte

**************************************
*** Affichage des infos de couleur ***
**************************************
	move.l		ed_sel_win,a6
	lea		ed_sel_objc,a5

	XREF		reinit_tedinfo_window
	jsr		reinit_tedinfo_window

	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,fenetre_avekeu_les_couleurs
	move.l		addr_out,a4

	reinit_color_window

	lea		ed_sel_objc,a5
boucle_info_couleur_et_texte
	graf_obj_attrb	a6,(a5)+
	cmp.w		#-1,(a5)
	bne		boucle_info_couleur_et_texte

	find_tab_l	#tab_adr,fenetre_avekeu_les_couleurs
	cmp.l		#-1,d0
	beq		ben_la_fenetre_flag_est_pas_ouverte_donc_rts
	wd_redraw_gem	d0

ben_la_fenetre_flag_est_pas_ouverte_donc_rts
	rsrc_gaddr	#0,#TEDINFO_EDIT
	find_tab_l	#tab_adr,addr_out
	cmp.l		#-1,d0
	beq		fenetre_tedinfo_edit_closed
	wd_redraw_gem	d0
fenetre_tedinfo_edit_closed

	rsrc_gaddr	#0,#LINE_EDITOR
	find_tab_l	#tab_adr,addr_out
	cmp.l		#-1,d0
	beq		fenetre_gline_closed
	wd_redraw_gem	d0
fenetre_gline_closed

	movem.l		(sp)+,d1-a6
	rts
	bss
fenetre_avekeu_les_couleurs	ds.l	1
fenetre_avekeu_les_flags	ds.l	1
;ed_sel_win		ds.l	1	; ces variables sont definies dans le ..\MAIN.S
;ed_sel_objc		ds.w	256
	text
*-------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------------------------*
*--------------------------*
*--------------------------*
*--------------------------*
wd_gadget_drag
	move.w		4(sp),d7
	cmp.w		#WM_CLOSED,tampon
	bne		not_closed

	get_tab		#tab_adr,d7	; place une donnee dans le tableau
	wd_close	d0

	rts
	*---------------*

not_closed
	cmp.w		#WM_SIZED,tampon
	beq		gadget_sized
	cmp.w		#WM_MOVED,tampon
	bne		gadget_not_sized
gadget_sized
	get_tab		#tab_kind,d7
	move.w		d0,d6
	cmp.w		#%111111101111,d0	; s'il n'y a pas de slider, ya rien a calculer
	beq		.size_slider

* Dans le cas ou les sliders sont absent, on a juste a deplacer le formulaire et la fenetre
	move.w		tampon+8,int_in+4	; on dit au gem de d‚placer sa fenetre
	move.w		tampon+10,int_in+6
	move.w		tampon+12,int_in+8
	move.w		tampon+14,int_in+10
	wind_set2	tampon+6,#5

	wind_calc	#1,d0,tampon+8,tampon+10,tampon+12,tampon+14
	get_tab		#tab_adr,d7			; c'est un formulaire en fenetre,
	move.l		d0,a0				; donc on deplace celui-ci
	move.w		int_out+2,ob_x(a0)
	move.w		int_out+4,ob_y(a0)
	bra		.ok

* Sinon, il faut verifier que la fenetre n'est pas trop grande, effectuer le deplacement/redimentionnement,
* et enfin placer le formulaire au bon endroit
.size_slider
	wind_calc	#1,d0,tampon+8,tampon+10,tampon+12,tampon+14
	get_tab		#tab_adr,d7
	move.l		d0,a6
	move.w		ob_w(a6),d3
	move.w		ob_h(a6),d4
	add.w		form_border,d3
	add.w		form_border,d4
	add.w		form_border,d3
	add.w		form_border,d4
	cmp.w		int_out+6,d3
	bge		.x_pas_trop_grand
	move.w		d3,int_out+6
.x_pas_trop_grand
	cmp.w		int_out+8,d4
	bge		.y_pas_trop_grand
	move.w		d4,int_out+8
.y_pas_trop_grand
	wind_calc	#0,d6,int_out+2,int_out+4,int_out+6,int_out+8
	put_tab_w	#tab_w,d7,int_out+6
	put_tab_w	#tab_h,d7,int_out+8
	wind_set	tampon+6,#WF_CURRXYWH,int_out+2,int_out+4,int_out+6,int_out+8

	bsr		slide_calc_size

* On recalcul la position du formulaire en fonction des positions de sliders
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_HSLIDE
	move.w		int_out+2,d5
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0

	move.w		ob_w(a0),d4
	add.w		form_border,d4
	add.w		form_border,d4
	sub.w		int_out+6,d4
	mulu.w		d5,d4
	divu.w		#1000,d4
	move.w		int_out+2,d3
	sub.w		d4,d3
;	cmp.w		int_out+2,d3
;	bne		.suite_x
;	addq.w		#2,d3
;.suite_x
	add.w		form_border,d3
	move.w		d3,ob_x(a0)

	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_VSLIDE
	move.w		int_out+2,d5
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0

	move.w		ob_h(a0),d4
	add.w		form_border,d4
	add.w		form_border,d4
	sub.w		int_out+8,d4
	mulu.w		d5,d4
	divu.w		#1000,d4
	move.w		int_out+4,d3
	sub.w		d4,d3
;	cmp.w		int_out+4,d3
;	bne		.suite_y
;	addq.w		#2,d3
;.suite_y
	add.w		form_border,d3
	move.w		d3,ob_y(a0)

	wd_redraw_gem	d7
.ok
	rts
gadget_not_sized
	cmp.w		#WM_ARROWED,tampon
	bne		.not_arrowed
*--------------------------------------------------------------------------------------------------------------------------*
	cmp.w		#WA_RTPAGE,tampon+8
	bne		.not_WA_RTPAGE
* Deplacement d'une page a droite
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		ob_x(a0),d5	; on trouve la coordonne du bord droit si le formulaire etait deplace d'une page
	sub.w		int_out+6,d5
	add.w		ob_w(a0),d5
	add.w		form_border,d5
	move.w		int_out+2,d4	; et la coordonnee actuelle
	add.w		int_out+6,d4
	cmp.w		d5,d4
	bgt		.trop_a_droite
	move.w		int_out+6,d3
	sub.w		d3,ob_x(a0)
	bra		slide_calc_pos
.trop_a_droite
	move.w		int_out+2,d3
	add.w		int_out+6,d3
	sub.w		ob_w(a0),d3
	sub.w		form_border,d3
	move.w		d3,ob_x(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_WA_RTPAGE
	cmp.w		#WA_LFPAGE,tampon+8
	bne		.not_left_page
* Deplacement d'une page a gauche
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		int_out+2,d5	; coordonnee de la fenetre
	add.w		#2,d5
	move.w		ob_x(a0),d4
	sub.w		form_border,d4
	add.w		int_out+6,d4	; coordonnee du formulaire apres deplacement
	cmp.w		d5,d4
	bgt		.trop_de_deplacement_gauche

	move.w		int_out+6,d3
	add.w		d3,ob_x(a0)
	bra		slide_calc_pos
.trop_de_deplacement_gauche
	move.w		int_out+2,d3
	add.w		form_border,d3
	move.w		d3,ob_x(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_left_page
	cmp.w		#WA_DNPAGE,tampon+8
	bne		.not_down_page
* Deplacement d'une page vers le bas
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		ob_y(a0),d5	; on trouve la coordonne du bord droit si le formulaire etait deplace d'une page
	sub.w		int_out+8,d5
	add.w		ob_h(a0),d5
	add.w		form_border,d5
	move.w		int_out+4,d4	; et la coordonnee actuelle
	add.w		int_out+8,d4
	cmp.w		d5,d4
	bgt		.trop_en_bas
	move.w		int_out+8,d3
	sub.w		d3,ob_y(a0)
	bra		slide_calc_pos
.trop_en_bas
	move.w		int_out+4,d3
	add.w		int_out+8,d3
	sub.w		ob_h(a0),d3
	sub.w		form_border,d3
	move.w		d3,ob_y(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_down_page
	cmp.w		#WA_UPPAGE,tampon+8
	bne		.not_up_page
* Deplacement d'une page en haut
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		int_out+4,d5	; coordonnee de la fenetre
	add.w		#2,d5
	move.w		ob_y(a0),d4
	sub.w		form_border,d4
	add.w		int_out+8,d4	; coordonnee du formulaire apres deplacement
	cmp.w		d5,d4
	bgt		.trop_en_haut

	move.w		int_out+8,d3
	add.w		d3,ob_y(a0)
	bra		slide_calc_pos
.trop_en_haut
	move.w		int_out+4,d3
	add.w		form_border,d3
	move.w		d3,ob_y(a0)
	bra		slide_calc_pos
*--------------------------------------------------------------------------------------------------------------------------*
.not_up_page
	cmp.w		#WA_RTLINE,tampon+8
	bne		.not_fleche_droite
* Deplacement d'une colone a droite
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		ob_x(a0),d5	; on trouve la coordonne du bord droit si le formulaire etait deplace d'une page
	sub.w		form_border,d5
	sub.w		#FLECHE_INC,d5
	add.w		ob_w(a0),d5
	move.w		int_out+2,d4	; et la coordonnee actuelle
	add.w		int_out+6,d4
	cmp.w		d5,d4
	bgt		.trop_a_droite2
	move.w		#FLECHE_INC,d3
	sub.w		d3,ob_x(a0)
	bra		slide_calc_pos
.trop_a_droite2
	move.w		int_out+2,d3
	add.w		int_out+6,d3
	sub.w		ob_w(a0),d3
	sub.w		form_border,d3
	move.w		d3,ob_x(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_fleche_droite
	cmp.w		#WA_LFLINE,tampon+8
	bne		.not_fleche_gauche
* Deplacement d'une colone a gauche
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		int_out+2,d5	; coordonnee de la fenetre
	move.w		ob_x(a0),d4
	sub.w		form_border,d4
	add.w		#FLECHE_INC,d4		; coordonnee du formulaire apres deplacement
	cmp.w		d5,d4
	bgt		.trop_a_gauche2

	move.w		#FLECHE_INC,d3
	add.w		d3,ob_x(a0)
	bra		slide_calc_pos
.trop_a_gauche2
	move.w		int_out+2,d3
	add.w		form_border,d3
	move.w		d3,ob_x(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_fleche_gauche
	cmp.w		#WA_DNLINE,tampon+8
	bne		.not_fleche_basse
* Deplacement d'une ligne en bas
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		ob_y(a0),d5	; on trouve la coordonne du bord droit si le formulaire etait deplace d'une page
	sub.w		form_border,d5
	sub.w		#FLECHE_INC,d5
	add.w		ob_h(a0),d5
	move.w		int_out+4,d4	; et la coordonnee actuelle
	add.w		int_out+8,d4
	cmp.w		d5,d4
	bgt		.trop_en_bas2
	move.w		#FLECHE_INC,d3
	sub.w		d3,ob_y(a0)
	bra		slide_calc_pos
.trop_en_bas2
	move.w		int_out+4,d3
	add.w		int_out+8,d3
	sub.w		ob_h(a0),d3
	sub.w		form_border,d3
	move.w		d3,ob_y(a0)
	bra		slide_calc_pos

*--------------------------------------------------------------------------------------------------------------------------*
.not_fleche_basse
	cmp.w		#WA_UPLINE,tampon+8
	bne		.not_fleche_haute
* Deplacement d'une ligne vers le haut
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		int_out+4,d5	; coordonnee de la fenetre
	move.w		ob_y(a0),d4
	sub.w		form_border,d4
	add.w		#FLECHE_INC,d4		; coordonnee du formulaire apres deplacement
	cmp.w		d5,d4
	bgt		.trop_en_haut2

	move.w		#FLECHE_INC,d3
	add.w		d3,ob_y(a0)
	bra		slide_calc_pos
.trop_en_haut2
	move.w		int_out+4,d3
	add.w		form_border,d3
	move.w		d3,ob_y(a0)
	bra		slide_calc_pos

.not_fleche_haute
	rts
*--------------------------------------------------------------------------------------------------------------------------*
.not_arrowed
	cmp.w		#WM_HSLID,tampon
	bne		.not_h_slided
* On a deplace le slider horizontale
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0

	move.w		ob_w(a0),d4
	add.w		form_border,d4
	add.w		form_border,d4
	sub.w		int_out+6,d4
	move.w		tampon+8,d5
	mulu.w		d5,d4
	divu.w		#1000,d4
	move.w		int_out+2,d3
	sub.w		d4,d3
	add.w		form_border,d3
	move.w		d3,ob_x(a0)
	wd_redraw_gem	d7
	bra		slide_calc_pos
*--------------------------------------------------------------------------------------------------------------------------*
.not_h_slided
	cmp.w		#WM_VSLID,tampon
	bne		.not_v_slided
* On a deplace le slider verticale
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH
	get_tab		#tab_adr,d7
	move.l		d0,a0

	move.w		ob_h(a0),d4
	add.w		form_border,d4
	add.w		form_border,d4
	sub.w		int_out+8,d4
	move.w		tampon+8,d5
	mulu.w		d5,d4
	divu.w		#1000,d4
	move.w		int_out+4,d3
	sub.w		d4,d3
	add.w		form_border,d3
	move.w		d3,ob_y(a0)
	wd_redraw_gem	d7
	bra		slide_calc_pos

.not_v_slided
	cmp.w		#WM_FULLED,tampon
	bne		.reuteusseu
	get_tab		#tab_kind,d7
	move.w		d0,d6
	get_tab		#tab_handle,d7
	move.w		d0,d5
	cmp.w		#%111111101111,d6
	beq		.enleve_slider
	put_tab_w	#tab_kind,d7,#%111111101111

	wind_close	d5
	wind_delete	d5
	get_tab		#tab_x,d7
	move.w		d0,d3
	get_tab		#tab_y,d7
	move.w		d0,d4
	get_tab		#tab_w,d7
	move.w		d0,d6
	get_tab		#tab_h,d7
	move.w		d0,a6
	wind_create	#%111111101111,d3,d4,d6,d0
	move.w		int_out,d5
	put_tab_w	#tab_handle,d7,d5

	wind_calc	#1,#%111111101111,d3,d4,d6,a6
	get_tab		#tab_adr,d7
	move.l		d0,a0

	move.w		int_out+2,d1
	add.w		form_border,d1
	move.w		d1,ob_x(a0)

	move.w		int_out+4,d1
	add.w		form_border,d1
	move.w		d1,ob_y(a0)

	move.w		a6,d0
	wind_open	d5,d3,d4,d6,d0
	bsr		slide_calc_size

.reuteusseu
	rts
.enleve_slider
* On verifie que le formulaire n'est pas trop grand pour la fenetre...
	get_tab		#tab_adr,d7
	move.l		d0,a6
	wind_calc	#0,#%1111,ob_x(a6),ob_y(a6),ob_w(a6),ob_h(a6)
	move.w		int_out+2,d3
	move.w		int_out+4,d4
	move.w		int_out+6,d6
	move.w		int_out+8,a6
	move.w		x_max,d0
	move.w		y_max,d1
	cmp.w		int_out+6,d0
	blt		.formulaire_trop_grand
	cmp.w		int_out+8,d1
	blt		.formulaire_trop_grand

* On place le formulaire dans les bonnes coordonnes
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.l		a4,d0
	move.w		d0,ob_x(a0)
	move.l		a5,d0
	move.w		d0,ob_y(a0)

	put_tab_w	#tab_kind,d7,#%1111
	put_tab_w	#tab_w,d7,int_out+6
	put_tab_w	#tab_h,d7,int_out+8

	get_tab		#tab_x,d7
	move.w		d0,d3
	get_tab		#tab_y,d7
	move.w		d0,d4

	move.w		int_out+6,d6
	move.w		int_out+8,d0

	wind_close	d5
	wind_delete	d5
	move.w		a6,d0
	wind_create	#%1111,d3,d4,d6,d0
	move.w		int_out,d5
	move.w		a6,d0
	wind_calc	#1,#%1111,d3,d4,d6,d0
	get_tab		#tab_adr,d7
	move.l		d0,a0
	move.w		int_out+2,ob_x(a0)
	move.w		int_out+4,ob_y(a0)
	put_tab_w	#tab_handle,d7,d5
	move.w		a6,d0
	wind_open	d5,d3,d4,d6,d0
	rts

.formulaire_trop_grand
	form_alert	#1,#sans_slider_impossible
	rts
*****************************************************************************************************
***** Reactualise les sliders horizontaux et verticaux en fonction de la position du formulaire *****
***** Parametre : d7 = index de la fenetre dans MES tableaux                                    *****
*****************************************************************************************************
slide_calc_size
	get_tab		#tab_handle,d7			; c'est un formulaire en fenetre,
	wind_get	d0,#WF_WORKXYWH

	get_tab		#tab_adr,d7
	move.l		d0,a6
	move.w		int_out+6,d5
	move.w		int_out+8,d6
* Calcul de la taille du slider horizontal
	move.w		d5,d1
	move.w		ob_w(a6),d0
	add.w		form_border,d0
	add.w		form_border,d0
	mulu.w		#1000,d1
	divu.w		d0,d1
	cmp.w		#1000,d1
	blt		.fenetre_plus_petite_que_le_formulaire
	move.w		#1000,d1
.fenetre_plus_petite_que_le_formulaire
	get_tab		#tab_handle,d7
	wind_set	d0,#15,d1

* Calcul de la taille du slider vertical
	move.w		d6,d1
	move.w		ob_h(a6),d0
	add.w		form_border,d0
	add.w		form_border,d0
	mulu.w		#1000,d1
	divu.w		d0,d1
	cmp.w		#1000,d1
	blt		.fenetre_2plus_petite_que_le_formulaire
	move.w		#1000,d1
.fenetre_2plus_petite_que_le_formulaire
	get_tab		#tab_handle,d7
	wind_set	d0,#16,d1
	rts
*****************************************************************************************************
***** Reactualise les sliders horizontaux et verticaux en fonction de la position du formulaire *****
***** Parametre : d7 = index de la fenetre dans MES tableaux                                    *****
*****************************************************************************************************
slide_calc_pos
	get_tab		#tab_adr,d7
	move.l		d0,a6
	get_tab		#tab_handle,d7
	move.w		d0,d6
	wind_get	d6,#WF_WORKXYWH

	move.w		ob_w(a6),d5	; calcul de la position du slider horizontale
	add.w		form_border,d5
	add.w		form_border,d5	; largeur affichable
	sub.w		int_out+6,d5	; largeur non affich‚
	beq		.zero1

	move.w		int_out+2,d4
	sub.w		ob_x(a6),d4
	add.w		form_border,d4
	mulu.w		#1000,d4
	divu.w		d5,d4

;	tst.w		d4
;	bge		.suite
.zero1
	moveq.l		#0,d4
.suite
	wind_set	d6,#WF_HSLIDE,d4

	move.w		ob_h(a6),d5	; calcul de la position du slider verticale
	add.w		form_border,d5
	add.w		form_border,d5
	sub.w		int_out+8,d5
	beq		.zero2
	move.w		int_out+4,d4
	sub.w		ob_y(a6),d4
	add.w		form_border,d4
	mulu.w		#1000,d4
	divu.w		d5,d4

	tst.w		d4
	bge		.suite2
.zero2
	moveq.l		#0,d4
.suite2
	wind_set	d6,#WF_VSLIDE,d4
	wd_redraw_gem	d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*--------------------------*
wd_redraw_drag
* On test pour savoir dans quel mode on affiche la fenetre (slider ou pas)
	get_tab		#tab_kind,d3		; on d‚place le formulaire a la coordonn‚e
	cmp.w		#%111111101111,d0
	bne		.pas_de_sliders

	move.l		d6,-(sp)
	move.l		d7,-(sp)

	add.w		d4,d6
	add.w		d5,d7
	subq.w		#1,d6
	subq.w		#1,d7
	v_bar		d4,d5,d6,d7

	move.l		(sp)+,d7
	move.l		(sp)+,d6

.pas_de_sliders
	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a6			; correspondante a la surface de travail de la fenetre

* On doit ajouter un "G_IBOX selectionne" par dessus chaque objet selectionne
	movem.l		d1-a4,-(sp)
	cmp.w		#-1,ed_sel_objc
	beq		.no_add_ibox
	cmp.l		ed_sel_win,a6
	bne		.no_add_ibox

* On trouve de la place a la fin de l'arbre
	lea		-24(a6),a4
.lp_find_end_tree
	lea		24(a4),a4
	btst		#LASTOB,ob_flags+1(a4)
	beq		.lp_find_end_tree
	lea		24(a4),a4

* Copie de l'IBOX dans le buffer de copie
	rsrc_gaddr	#0,#TYPES
	move.l		addr_out,-(sp)
	move.w		#TYPES_IBOX,-(sp)
	bsr		copy_to_buff_rout
	addq.l		#6,sp

	move.l		#0,a5
	lea		ed_sel_objc,a3
.lp_add_ibox
	move.w		(a3)+,d6
	cmp.w		#-1,d6
	beq		.no_add_ibox

	addq.l		#1,a5
* Copie dans le buffer destination
	clr.l		-(sp)
	move.w		d6,-(sp)
	move.l		ed_sel_win,-(sp)
	bsr		copy_to_formul_rout
	lea		10(sp),sp

	trouve_objc	ed_sel_win,d6
	move.w		ob_w(a0),ob_w(a4)
	move.w		ob_h(a0),ob_h(a4)
	lea		24(a4),a4
	bra		.lp_add_ibox


.no_add_ibox
	movem.l		(sp)+,d1-a4

	objc_draw	a6,#0,#20,d4,d5,d6,d7

	movem.l		d1-a4,-(sp)
	cmp.w		#-1,ed_sel_objc
	beq		.no_supp_ibox
	cmp.l		ed_sel_win,a6
	bne		.no_supp_ibox
* Maintenant on enleve tous les objets IBOX ajoute pour visualise la selection
	lea		-24(a6),a4
	moveq.l		#-1,d6
.lp_find_end_tree_supp
	addq.w		#1,d6
	lea		24(a4),a4
	btst		#LASTOB,ob_flags+1(a4)
	beq		.lp_find_end_tree_supp

	lea		ibox_list,a4
.lp_sup_gibox
	move.w		d6,(a4)+
	subq.w		#1,d6
	subq.l		#1,a5
	tst.l		a5
	bne		.lp_sup_gibox
	move.l		#-1,(a4)+

	move.l		a6,ibox_win
	erase_list	#ibox_list,#ibox_win
.no_supp_ibox
	movem.l		(sp)+,d1-a4

*--------------------------*
* Si la fenetre est en premier plan...
	get_tab		#tab_handle,d3
	move.l		d0,d7
	wind_get	#0,#10
	cmp.w		int_out+2,d7
	bne		.not_on_top

* ...dessin du curseur
* Connait-on le numero de l'objet a dessiner ?
	cmp.l		curs_win,a6
	beq		.pos_curs_connu
	clr.w		d6
	move.l		a6,a4
.boucle_recherche_objc
	lea		txt_objc_list,a5
	moveq.l		#0,d0
	move.b		ob_type+1(a4),d0
.boucle_test_type
	cmp.w		(a5)+,d0
	beq		.objc_trouve
	tst.w		(a5)
	bne		.boucle_test_type

	move.w		ob_flags(a4),d0
	btst		#LASTOB,d0
	bne		.not_on_top

	addq.w		#1,d6
	add.l		#24,a4
	bra		.boucle_recherche_objc
.objc_trouve
	objc_offset	a6,d6	; coordonnees de l'objet dans int_out+2 / +4
	cmp.w		#G_ICON,d0
	beq		.obj_icone
	cmp.w		#G_CICON,d0
	beq		.obj_icone
	move.l		a6,curs_win
	move.w		d6,curs_obj
	trouve_objc	a6,d6
	move.l		a0,a1
	move.l		ob_spec(a0),a0
	btst		#INDIRECT-8,ob_flags(a1)
	beq		.redraw_not_indirect
	move.l		(a0),a0
.redraw_not_indirect
	move.w		#-1,d5
.boucle_calcul_taille_chaine
	addq.w		#1,d5
	tst.b		(a0)+
	bne		.boucle_calcul_taille_chaine
	move.w		d5,curs_pos
	bra		.affichage_curs
.pos_curs_connu
	move.w		curs_obj,d6
	trouve_objc	a6,d6
	move.l		a0,a4
	objc_offset	a6,d6	; coordonnees de l'objet dans int_out+2 / +4
.affichage_curs
* On a trouve un objet dont l'ob_spec est un pointeur sur une chaine de texte
	move.w		curs_pos,d5
	lsl.w		#3,d5

	cmp.b		#G_BUTTON,ob_type+1(a4)
	bne		.ceci_nest_pas_un_gbutton

* Le texte pouvant etre centree, il faut calculer la taille de l'espace avant le texte
	move.l		ob_spec(a4),a0
	btst		#INDIRECT-8,ob_flags(a4)
	beq		.cok_cpasindirect
	move.l		(a0),a0
.cok_cpasindirect
	move.w		#-1,d0
.size_chaine
	addq.w		#1,d0
	tst.b		(a0)+
	bne		.size_chaine
	lsl.w		#3,d0
	move.w		ob_w(a4),d1
	sub.w		d0,d1
	asr.w		#1,d1
	add.w		d1,d5

.ceci_nest_pas_un_gbutton
	add.w		int_out+2,d5	; X
	move.w		int_out+4,d4	; Y

	subq.w		#1,d5	; achement plus joli !

* L'objet peut etre tres haut, donc il faut calcule en Y aussi !
	move.w		ob_h(a4),d0
	sub.w		#16,d0
	bgt		.suite_calc
	clr.w		d0
.suite_calc
	lsr.w		#1,d0
	add.w		d0,d4

	vsl_color	#2		; puis on definie le type de ligne
	vsl_ends	#0,#0		; que l'on vat tracer pout le sample
	vsl_type	#0		; (couleur2=rouge, a bout carre, et sans pointille)

	move.w		d5,ptsin
	move.w		d4,ptsin+2
	move.w		d5,ptsin+4
	add.w		#12,d4
	move.w		d4,ptsin+6
	v_pline		#2		; on trace la ligne entre le point 1 et le point 2

.obj_icone

.not_on_top
	rts
	data
txt_objc_list	dc.w	G_BUTTON,G_STRING,0,G_ICON,G_TITLE,G_CICON,0
curs_obj	ds.w	1
curs_win	ds.l	1
curs_pos	ds.w	1
form_border	ds.w	1
	bss
ibox_win	ds.l	1
ibox_list	ds.w	nbr_of_objc
	text
