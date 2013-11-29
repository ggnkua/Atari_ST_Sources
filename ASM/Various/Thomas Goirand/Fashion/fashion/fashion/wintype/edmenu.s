*** Definition d'un formulaire en fenetre ***
	text

	include	vdi.i
	include	aes.i
	include	structs.s
	include	zlib.i

	include	..\fashion.s
	include	..\macro.i

	XREF	opt_num,opt_arbre,x_mouse_clik,y_mouse_clik,n_mouse_clik
	XREF	tampon,hauteur_menu,appl_name,options
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
	XREF	init_x,init_y,x_max,y_max
	XREF	intout

*--------------------------*

	XDEF	edition_menu
	XDEF	wd_create_editmenu
	XDEF	efface_objc_dans_menu

	XDEF	find_max_entree_w_rout,find_to_deroule_rout,find_selected_title_rout,find_selected_entree_rout

*--------------------------*

MENU_ATTRB	equ	%101011
ENTREE_SIZE	equ	16
*--------------------------*
find_max_entree_w	macro	; adresse_menu,index_g_box_englobant
	move.l		\1,-(sp)
	move.w		\2,-(sp)
	bsr		find_max_entree_w_rout
	addq.l		#6,sp
	endm
*--------------------------*
find_to_deroule	macro	; adr_menu,index_g_title
	move.l		\1,-(sp)
	move.w		\2,-(sp)
	bsr		find_to_deroule_rout
	addq.l		#6,sp
	endm
*--------------------------*
find_selected_title	macro	; adresse
	move.l		\1,-(sp)
	bsr		find_selected_title_rout
	addq.l		#4,sp
	endm
*--------------------------*
find_selected_entree	macro	; adresse_menu,inde_g_box_englobant
	move.l		\1,-(sp)
	move.w		\2,-(sp)
	bsr		find_selected_entree_rout
	addq.l		#6,sp
	endm
*--------------------------*
wd_create_editmenu
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !
	get_tab		#tab_adr,d7
	move.l		d0,a5			; l'adresse du formulaire

	get_tab		#tab_x,d7
	cmp.w		#-1,d0
	bne		wd_create_menu2

* On calcul la position de la fenetre
	move.w		init_x,d6
	lsr.w		#1,d6
	add.w		init_x,d6
	put_tab_w	#tab_x,d7,d6

	move.w		init_y,d5
	lsr.w		#1,d5
	add.w		init_y,d5
	put_tab_w	#tab_y,d7,d5

	move.w		x_max,d4
	sub.w		d6,d4
	lsr.w		#1,d4
	put_tab_w	#tab_w,d7,d4

	move.w		y_max,d3
	sub.w		d5,d3
	lsr.w		#1,d3
	put_tab_w	#tab_h,d7,d4

wd_create_menu2
; on calcul les coordonnees du formulaire
; a partir des coordonnes delivre en parametre
	get_tab		#tab_y,d7		;   /\		Le Y minimale est egale
	move.l		d0,d6			;  /!!\		a la hauteur de la barre
	cmp.w		hauteur_menu,d6		; ------	de menu...
	bge.s		wd_create_form_3
	put_tab_w	#tab_y,d7,hauteur_menu

* On place le reste des infos
wd_create_form_3
	put_tab_l	#tab_name,d7,#appl_name		; ainsi que le pointeur sur le texte de la bare de d‚placement,
	put_tab_w	#tab_kind,d7,#MENU_ATTRB		; les attribues AES
	put_tab_l	#tab_rout,d7,#wd_redraw_edmenu	; le pointeur sur la routine de redraw
	put_tab_l	#tab_gadget,d7,#wd_gadget_edmenu	; le pointeur sur la routine de gadget et finalement
	put_tab_l	#tab_clic,d7,#wd_clic_edmenu	; le pointeur sur la routine de clic
	put_tab_l	#tab_key,d7,#wd_key_edmenu	; le pointeur sur la routine de key
	moveq.l		#0,d0
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
wd_key_edmenu

	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Recois l'offset dans les tableau par la pile
wd_clic_edmenu
	move.w		4(sp),d3
	get_tab		#tab_x,d3
	move.w		d0,d4
	get_tab		#tab_y,d3
	move.w		d0,d5
	get_tab		#tab_kind,d3
	wind_calc	#1,d0,d4,d5,#100,#100
	move.w		int_out+4,d7
	add.w		hauteur_menu,d7
	cmp.w		y_mouse_clik,d7
	blt		clic_on_derouled

* On a clique dans le menu en fenetre
	get_tab		#tab_adr,d3
	move.l		d0,a6

	objc_find	a6,#1,#2,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
	cmp.w		#-1,d0
	bne		.suite_menu_clik
	rts
.suite_menu_clik
	cmp.w		#1,d0
	bne		.suite_menu_clik2
	rts
.suite_menu_clik2
	move.w		d0,d6	; Numero du title doit etre selectionner (celui clike)

	cmp.w		#2,n_mouse_clik
	beq		edit_objet_menu

	find_selected_title	a6
	move.w			d0,d5	; Numero du title qui etais selectionne avant

	cmp.w		#-1,d5
	beq		do_not_deselect_title	; Si aucun title n'etait selectionne...

* Deselectionne l'entree de menu qui etait peut-etre selectionne
	find_to_deroule		a6,d5
	find_selected_entree	a6,d0
	cmp.w			#-1,d0
	beq			.do_not_deselect_entree
	trouve_objc		a6,d0
	bclr			#SELECTED,ob_states+1(a0)
.do_not_deselect_entree

* Deselectionne le menu qui etait peut-etre selectionne
	trouve_objc	a6,d5
	bclr		#SELECTED,ob_states+1(a0)
do_not_deselect_title
	cmp.w		d5,d6
	bne		.suite	; On veut peut-etre qu'aucun menu ne soit deroule ?

	rsrc_gaddr	#0,#EDIT_MENU
	xobjc_grise	addr_out,#EM_ADD_ENTREE
	xobjc_grise	addr_out,#EM_UP
	xobjc_grise	addr_out,#EM_DOWN
	xobjc_grise	addr_out,#EM_EFFACE
	xobjc_grise	addr_out,#EM_MARQUE
	xobjc_grise	addr_out,#EM_GRISE
	xobjc_grise	addr_out,#EM_SEPAR

	wd_redraw_gem	d3
	rts
.suite

	rsrc_gaddr	#0,#EDIT_MENU
	xobjc_degrise	addr_out,#EM_ADD_ENTREE
	xobjc_degrise	addr_out,#EM_UP
	xobjc_degrise	addr_out,#EM_DOWN
	xobjc_degrise	addr_out,#EM_EFFACE
	xobjc_grise	addr_out,#EM_MARQUE
	xobjc_degrise	addr_out,#EM_GRISE
	xobjc_degrise	addr_out,#EM_SEPAR

	trouve_objc	a6,d6
	bset		#SELECTED,ob_states+1(a0)
	move.l		a0,a5

	rsrc_gaddr		#0,#EDIT_MENU
	trouve_objc		addr_out,#EM_GRISE

	bclr			#SELECTED,ob_states+1(a0)
	btst			#DISABLED,ob_states+1(a5)
	beq			.not_disabled
	bset			#SELECTED,ob_states+1(a0)
.not_disabled

	xobjc_degrise		addr_out,#EM_GRISE

	wd_redraw_gem	d3
	rts
* On a cliquer sur une option du menu qu'il faut selectionner
clic_on_derouled
* On recherche le titre selectionne avant
	get_tab			#tab_adr,d3
	move.l			d0,a6
	find_selected_title	a6
	cmp.w			#-1,d0
	beq			.end
	move.w			d0,d7	; d7 = numero du titre
	find_to_deroule		a6,d7
	move.w			d0,d6	; d6 = numero du G_BOX englobant
* Et l'entree de menu eventuellement selectionne avant
	find_selected_entree	a6,d6
	move.w			d0,d5
	cmp.w			#-1,d0
	beq			.ne_deselectionne_pas
	trouve_objc		a6,d0
	bclr			#SELECTED,ob_states+1(a0)

* Bouton MARQUE pour l'instant en grise, idem pour GRISE
	rsrc_gaddr		#0,#EDIT_MENU
	xobjc_grise		addr_out,#EM_MARQUE
	xobjc_grise		addr_out,#EM_GRISE

.ne_deselectionne_pas
	objc_find		a6,d6,#20,x_mouse_clik,y_mouse_clik
	cmp.w			#-1,d0
	beq			.ok_letsredraw

* On veut editer l'option de menu ???
	cmp.w			#2,n_mouse_clik
	bne			.suite_derouled
	move.w			d0,d6
	bra			edit_objet_menu
.suite_derouled

	cmp.w			d5,d0
	beq			.laisse_deselectionne
	trouve_objc		a6,d0
	move.w			ob_states(a0),d4
	bset			#SELECTED,d4
	move.w			d4,ob_states(a0)

* Update du bouton MARQUE (selectionne ou non)
	rsrc_gaddr		#0,#EDIT_MENU
	trouve_objc		addr_out,#EM_MARQUE
	bclr			#SELECTED,ob_states+1(a0)
	btst			#CHECKED,d4
	beq			.not_marked
	bset			#SELECTED,ob_states+1(a0)
.not_marked
	xobjc_degrise		addr_out,#EM_MARQUE

* Update du bouton GRISE (selectionne ou non)
	trouve_objc		addr_out,#EM_GRISE
	bclr			#SELECTED,ob_states+1(a0)
	btst			#DISABLED,d4
	beq			.not_disabled
	bset			#SELECTED,ob_states+1(a0)
.not_disabled
	xobjc_degrise		addr_out,#EM_GRISE
	bra			.ok_letsredraw

.laisse_deselectionne
	find_selected_title	a6
	trouve_objc		a6,d0
	move.w			ob_states(a0),d6
	rsrc_gaddr		#0,#EDIT_MENU
	trouve_objc		addr_out,#EM_GRISE
	bclr			#SELECTED,ob_states+1(a0)
	btst			#DISABLED,d6
	beq			.ttl_not_disabled
	bset			#SELECTED,ob_states+1(a0)
.ttl_not_disabled
	xobjc_degrise		addr_out,#EM_GRISE


.ok_letsredraw

	wd_redraw_gem		d3
.end
	rts
*--------------------------------------------------------------------------------------------------------------------------*
edit_objet_menu
	move.l		a6,-(sp)
	move.w		d6,-(sp)
	XREF		get_objc_info
	jsr		get_objc_info
	addq.l		#6,sp
	rts

*--------------------------------------------------------------------------------------------------------------------------*
* Trouve la largeur maxi des chaines contenues dans le menu deroulant
find_max_entree_w_rout
	movem.l		d5-d7/a0/a6,-(sp)
	move.l		24+2(sp),a6		; adresse du formulaire
	move.w		24+0(sp),d7	; index du g_box englobant
	trouve_objc	a6,d7
	move.w		ob_head(a0),d6
	moveq.l		#0,d5
.loop	trouve_objc	a6,d6
	cmp.w		ob_w(a0),d5
	bgt		.suite
	move.w		ob_w(a0),d5
.suite	move.w		ob_next(a0),d6
	cmp.w		d6,d7
	bne		.loop
	move.w		d5,d0
	movem.l		(sp)+,d5-d7/a0/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Retourne l'index du G_STRING actuellement selectionne
find_selected_entree_rout
	movem.l		a6/d7,-(sp)
	move.l		12+2(sp),a6	; adresse de l'arbre
	move.w		12+0(sp),d7	; index du G_BOX ou on doit chercher
	trouve_objc	a6,d7
	move.w		ob_head(a0),d0
.loop_search
	trouve_objc	a6,d0
	btst		#SELECTED,ob_states+1(a0)
	bne		.trouved
	move.w		ob_next(a0),d0
	cmp.w		d0,d7
	bne		.loop_search

	moveq.l		#-1,d0
	movem.l		(sp)+,a6/d7
	rts
.trouved
	movem.l		(sp)+,a6/d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Retourne l'index du G_TITLE selectionne formulaire
find_selected_title_rout
	movem.l		d6/d7/a0/a6,-(sp)
	move.l		20(sp),a6	; adresse du menu
	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d7	; Index du G_IBOX racine des G_TITLEs
	trouve_objc	a6,ob_head(a0)
	move.w		ob_head(a0),d6
	trouve_objc	a6,ob_head(a0)	; Trouve le 1er G_TITLE du menu
* Trouve le G_TITLE selectionne
.loop_search
	btst		#SELECTED,ob_states+1(a0)
	bne		.trouved
	move.w		ob_next(a0),d6
	cmp.w		d6,d7
	beq		.not_trouved
	trouve_objc	a6,ob_next(a0)
	bra		.loop_search
* d6 est l'index du G_TITLE selectionne
.trouved
	moveq.l		#0,d0
	move.w		d6,d0
	movem.l		(sp)+,d6/d7/a0/a6
	rts
.not_trouved
	moveq.l		#-1,d0
	movem.l		(sp)+,d6/d7/a0/a6
	rts

*--------------------------------------------------------------------------------------------------------------------------*
* Retourne l'index du G_BOX correspondant au G_TITLE donne en paramettre
find_to_deroule_rout
	movem.l		d4-d7/a0/a6,-(sp)
	move.l		28+2(sp),a6	; Adresse du menu
	move.w		28+0(sp),d7	; index du G_TITLE dont on veut le G_BOX

	trouve_objc	a6,ob_head(a6)
	trouve_objc	a6,ob_head(a0)
	move.w		ob_head(a0),d6
	moveq.l		#0,d5
	cmp.w		d7,d6
	beq		.cest_le_premier

*; On compte dans d5 ne nombre de titre que l'on passe avant de trouver celui selectionne
.loop_search_title_num
	addq.w		#1,d5
	trouve_objc	a6,d6
	move.w		ob_next(a0),d6
	cmp.w		d7,d6
	bne		.loop_search_title_num

.cest_le_premier
	addq.w		#1,d5
	trouve_objc	a6,ob_tail(a6)
	move.w		ob_head(a0),d4
	trouve_objc	a6,ob_head(a0)
.loop_trouve_boite_correspondante
	subq.w		#1,d5
	beq		.trouved
	move.w		ob_next(a0),d4
	trouve_objc	a6,d4
	bra		.loop_trouve_boite_correspondante
.trouved
	move.w		d4,d0
	movem.l		(sp)+,d4-d7/a0/a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* L'offset dans les tableaux a ete empile avant le saut !
wd_gadget_edmenu
	move.w		4(sp),d7
	cmp.w		#WM_MOVED,tampon	; * on veut bouger la fenetre ?
	beq		mov_menu
	cmp.w		#WM_SIZED,tampon
	beq		mov_menu
	cmp.w		#WM_CLOSED,tampon
	beq		closed
	rts

	*------------*
closed
	get_tab		#tab_adr,d7	; place une donnee dans le tableau
	wd_close	d0
	rts
	*------------*
mov_menu
	move.w		tampon+8,int_in+4	; on dit au gem de d‚placer sa fenetre
	move.w		tampon+10,int_in+6
	move.w		tampon+12,int_in+8
	move.w		tampon+14,int_in+10
	wind_set2	tampon+6,#5

	get_tab		#tab_adr,d7		; si c'est un formulaire en fenetre,
	move.l		d0,a6
	get_tab		#tab_x,d3
	move.w		d0,d4
	get_tab		#tab_y,d3
	move.w		d0,d5
	get_tab		#tab_w,d3
	move.w		d0,d6
	get_tab		#tab_h,d3
	move.w		d0,d7

	wind_calc	#1,#MENU_ATTRB,d4,d5,d6,d7
	move.w		int_out+2,ob_x(a6)
	move.w		int_out+4,ob_y(a6)
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* De d4 a d7 on trouve les coordonnees du rectagle a redissinner, au format AES.
* D3 est l'offset dans les tableaux.
* a6 pointe vers une structure du type suivant, donnant les coordonnees de surface
*           de travail de la fenetre au format VDI et AES :
* X, Y, X2, Y2, W, H
wd_redraw_edmenu
* Dessin du formulaire
	movem.l		d3-d7,-(sp)
	move.w		d4,wx1
	move.w		d5,wy1
	move.w		d6,ww
	move.w		d7,wh

	add.w		d4,d6
	subq.w		#1,d6
	move.w		d6,wx2

	add.w		d5,d7
	subq.w		#1,d7
	move.w		d7,wy2

	vsf_interior	#0			; on trace un rectangle
	vsf_perimeter	#0			; blanc dans le rectangle
	v_bar		d4,d5,d6,d7		; a redessiner

	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a6			; correspondante a la surface de travail de la fenetre

	get_tab		#tab_x,d3
	move.w		d0,d4
	get_tab		#tab_y,d3
	move.w		d0,d5
	get_tab		#tab_w,d3
	move.w		d0,d6
	get_tab		#tab_h,d3
	move.w		d0,d7

	wind_calc	#1,#MENU_ATTRB,d4,d5,d6,d7
	move.w		int_out+2,ob_x(a6)
	move.w		int_out+4,ob_y(a6)
	movem.l		(sp)+,d3-d7

* Dessin de la barre de menu
	objc_draw	a6,#1,#20,d4,d5,d6,d7

* Dessin du sous-menu dont le G_TITLE est selectionne
	find_selected_title	a6
	cmp.w			#-1,d0
	beq			.end_draw
	find_to_deroule		a6,d0
	move.l		d0,d3
	trouve_objc	a6,d3
	objc_draw	a6,d3,#20,d4,d5,d6,d7
.end_draw
	rts
	data
wx1	dc.w	1
wy1	dc.w	1
wx2	dc.w	1
wy2	dc.w	1
ww	dc.w	1
wh	dc.w	1
*--------------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------------*
*--------------------------------------------------------------------------------------------------------------------------*
	text

edition_menu
* On verifie qu'une fenetre de type edition de menu est bien au premier plan
	move.l		d0,a4
	move.w		d1,d6

	wind_get	#0,#WF_TOP
	find_tab_w	#tab_handle,int_out+2
	cmp.w		#-1,d0
	bne		.suite
	rts
.suite	move.w		d0,d7
	get_tab		#tab_type,d7
	cmp.l		#wd_create_editmenu,d0
	beq		.suite2
	rts
.suite2	get_tab		#tab_adr,d7
	move.l		d0,a6		; adresse du menu a editer dans a6

	cmp.w	#EM_ADD_TITRE,d6
	beq	ajoute_titre_menu
	cmp.w	#EM_ADD_ENTREE,d6
	beq	ajoute_entree_menu
	cmp.w	#EM_UP,d6
	beq	menu_up
	cmp.w	#EM_DOWN,d6
	beq	menu_down
	cmp.w	#EM_EFFACE,d6
	beq	supprime
	cmp.w	#EM_SEPAR,d6
	beq	ajoute_separateur
	cmp.w	#EM_MARQUE,d6
	beq	marque_objet
	cmp.w	#EM_GRISE,d6
	beq	grise_objet

	rts
*--------------------------------------------------------------------------------------------------------------------------*
ajoute_separateur
	xobjc_change	a4,d6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
marque_objet
	find_selected_title	a6
	find_to_deroule		a6,d0
	find_selected_entree	a6,d0
	move.w			d0,d7
	trouve_objc		a6,d7
	bchg			#CHECKED,ob_states+1(a0)
	redraw_objc		a6,d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
grise_objet
	find_selected_title	a6
	move.l			d0,d7
	find_to_deroule		a6,d0
	find_selected_entree	a6,d0
	cmp.w			#-1,d0
	beq			.grise_titre
	move.w			d0,d7
.grise_titre
	trouve_objc		a6,d7
	bchg			#DISABLED,ob_states+1(a0)
	redraw_objc		a6,d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
ajoute_titre_menu
	xobjc_change	a4,d6

* On cherche l'index et l'adresse de la fin de l'arbre
	move.l		a6,a4
	lea		-24(a4),a4
	moveq.l		#-1,d5
.loop_search_end
	addq.w		#1,d5
	lea		24(a4),a4
	btst		#LASTOB,ob_flags+1(a4)
	beq		.loop_search_end

	bclr		#LASTOB,ob_flags+1(a4)	; On efface le lastob
	addq.w		#1,d5			; d5 est l'index de l'objet a ajouter
	lea		24(a4),a4		; a4 est son adresse

* Puis on cherche le numero du dernier G_TITLE de la liste
	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d4	; le G_IBOX "Active"
	trouve_objc	a6,d4
	move.l		a0,a5
	move.w		ob_tail(a0),d6
	trouve_objc	a6,d6
	move.l		a0,a3

* Ajoute un G_TITLE en fin d'arbre
	rsrc_gaddr	#0,#MENU_INTEMS
	trouve_objc	addr_out,#ITEM_TITRE

	moveq.l		#5,d0
.yo_cp_title
	move.l		(a0)+,(a4)+
	dbf		d0,.yo_cp_title

	lea		-24(a4),a2
* Calcul le deplacement en X de l'objet G_TITLE nouvellement ajoute
	moveq.l		#0,d0
	move.w		ob_head(a5),d3
.loop_calc_x
	trouve_objc	a6,d3
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.suite_loopx
	move.l		(a1),a1
.suite_loopx
	addq.w		#1,d0		; calcul la taille des chaines de chaque titre
	tst.b		(a1)+
	bne		.suite_loopx
	move.w		ob_next(a0),d3
	cmp.w		d4,d3
	bne		.loop_calc_x

	move.w		d0,d3
	lsl.w		#3,d3
	move.w		d3,ob_x(a2)

* On calcule la taille de la G_IBOX "Active" et on la modifie
	move.l		ob_spec(a2),a0
.loop
	addq.w		#1,d0
	tst.b		(a0)+
	bne		.loop

	lsl.w		#3,d0
	move.w		d0,ob_w(a5)

* Realoc l'objet G_TITLE et modifie les liens de l'arbre pour inserer l'objet G_TITLE
	objc_real	a2
	move.w		d4,ob_next(a2)
	move.w		d5,ob_next(a3)
	move.w		d5,ob_tail(a5)

* Ajoute le G_BOX et le G_STRING en fin d'arbre
	trouve_objc	addr_out,#ITEM_ENTREE-1	; Normalement, on pointe sur le G_BOX suivit du G_STRING
	move.l		a4,a5		; a5 c'est le G_BOX
	lea		24(a5),a3	; a3 le G_STRING
	moveq.l		#11,d0
.yo_cp_dropdown
	move.l		(a0)+,(a4)+
	dbf		d0,.yo_cp_dropdown

* Cherche l'objet englobant les G_BOX (dropdown) et fabrique les liens
	move.w		ob_tail(a6),d6
	trouve_objc	a6,d6
	move.l		a0,a2
	trouve_objc	a6,ob_tail(a2)

* Les liens pour le G_BOX avec son pere et son frere precedant
	addq.w		#1,d5
	move.w		d5,ob_next(a0)	; Le next du frere precedant
	move.w		d6,ob_next(a5)	; Le next du G_BOX ajoute (pointe vers le pere dopdowns)
	move.w		d5,ob_tail(a2)	; le tail du dopdowns G_IBOX
* Le liens avec le G_STRING
	move.w		d5,ob_next(a3)	; Le next du G_STRING fils
	addq.w		#1,d5
	move.w		d5,ob_head(a5)	; le head du G_BOX pere qu'on a ajoute
	move.w		d5,ob_tail(a5)	; te tail de celui-ci

* On realoc uniquement le G_STRING, le G_BOX ne contenant pas de pointeur dans son ob_spec
	objc_real	a3

* Calcul et update la position du G_BOX englobant le menu qui se deroule
	add.w		#16,d3
	move.w		d3,ob_x(a5)
.end
	wd_redraw_gem	d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
ajoute_entree_menu
* On trouve l'endroit ou ajouter la nouvelle G_STRING
	xobjc_change		a4,d6
	find_selected_title	a6
	cmp.w			#-1,d0
	beq			.end_error
	find_to_deroule		a6,d0
	move.w			d0,d6		; d6 = Index du g_box contenant
	trouve_objc		a6,d6
	move.l			a0,a5		; a5 = adresse du g_box englobant
	find_selected_entree	a6,d6
	move.w			d0,d4
	cmp.w			#-1,d0
	bne			.entree_trouve
	move.w			ob_tail(a5),d4	; d4 = index de l'entree juste au dessus de celle a ajouter
.entree_trouve
	trouve_objc		a6,d4
	move.l			a0,a4		; a4 = adresse de l'entree juste au dessus
	bclr			#SELECTED,ob_states+1(a0)

* Cherche l'index du dernier objet de l'arbre (trouve de la place)
	move.l	a6,a3
	lea	-24(a3),a3
	moveq.l	#-1,d3
.loop_search
	addq.w	#1,d3
	lea	24(a3),a3
	btst	#LASTOB,ob_flags+1(a3)
	beq	.loop_search
	addq.w	#1,d3		; d3 = index du G_STRING a ajouter

* Ajoute la G_STING en fin d'arbre
	bclr		#LASTOB,ob_flags+1(a3)
	lea		24(a3),a3
	rsrc_gaddr	#0,#MENU_INTEMS
	trouve_objc	addr_out,#ITEM_ENTREE
	move.l		a3,a2	; a2 = adresse du G_STRING ajoute
	moveq.l		#5,d0
.lp_cp	move.l		(a0)+,(a3)+
	dbf		d0,.lp_cp

* Realise les liens avec le G_BOX, son dernier fils et notre G_STRING
	trouve_objc	a6,ob_tail(a5)
	move.w		d3,ob_next(a0)
	move.w		d3,ob_tail(a5)
	move.w		d6,ob_next(a2)

* Update les coordonnes des G_STRING de la boite
	move.w		ob_y(a4),d2
	add.w		#ENTREE_SIZE,d2		; coordonne de notre nouvel G_STRING
	move.w		ob_head(a5),d1
.lp_cords
	trouve_objc	a6,d1
	cmp.w		ob_y(a0),d2
	bgt		.do_not_modif_y
	add.w		#ENTREE_SIZE,d2
.do_not_modif_y
	move.w		ob_next(a0),d1
	cmp.w		d1,d6
	bne		.lp_cords

* Update de la coordonne et selection de notre nouvelle G_STRING
	move.w		d2,ob_y(a2)
	bset		#SELECTED,ob_states+1(a2)

* Update la largeur du g_box englobant
	find_max_entree_w	a6,d6
	move.w		d0,d2
	move.w		d0,ob_w(a5)

* Update la lageur de toutes les g_stings a la largeur de la plus grande chaine
	move.w		ob_head(a5),d1
.lp_all_string_w
	trouve_objc	a6,d1
	move.w		d2,ob_w(a0)
	move.w		ob_next(a0),d1
	cmp.w		d1,d6
	bne		.lp_all_string_w

* Update de la hauteur de la g_box
	add.w		#ENTREE_SIZE,ob_h(a5)
	wd_redraw_gem	d7
	rts
.end_error
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Ici, on viens du menu deroulant (option DELETE, ou racourcie clavier)
efface_objc_dans_menu
	wind_get	#0,#WF_TOP
	find_tab_w	#tab_handle,int_out+2
	cmp.w		#-1,d0
	bne		.suite
	rts
.suite	move.w		d0,d7
	get_tab		#tab_type,d7
	cmp.l		#wd_create_editmenu,d0
	beq		.suite2
	rts
.suite2
	get_tab		#tab_adr,d7
	move.l		d0,a6
	bra		suite_efface_menu	
supprime
	xobjc_change	a4,d6
suite_efface_menu
	find_selected_title	a6
	cmp.w		#-1,d0
	beq		.end_error
	move.w		d0,d6
	find_to_deroule	a6,d6
	move.w		d0,d5
	find_selected_entree	a6,d5
	move.w		d0,d2
	cmp.w		#-1,d2
	beq		.erraze_title
* On efface une entree de menu
* On rempli la liste d'objet a effacer avec notre G_STRING
	move.w		d2,del_list
	move.l		#-1,del_list+2

*On update les coordonnes des objets plus bas que notre G_STRING
	trouve_objc	a6,d2
	move.w		ob_y(a0),d4
	trouve_objc	a6,d5
	sub.w		#ENTREE_SIZE,ob_h(a0)	; On en profite pour reduire la taille de la G_BOX englobante
	move.w		ob_head(a0),d3
.lp_updatex
	trouve_objc	a6,d3
	cmp.w		ob_y(a0),d4
	bgt		.not_update_y
	sub.w		#ENTREE_SIZE,ob_y(a0)
.not_update_y
	move.w		ob_next(a0),d3
	cmp.w		d3,d5
	bne		.lp_updatex
	move.l		a6,del_win
	erase_list	#del_list,#del_win
	wd_redraw_gem	d7
	rts

* On efface un titre, sa G_BOX correspondante, et tous les fils de cette G_BOX
.erraze_title

* On update les coordonnes des autres G_TITLE et G_BOX
	trouve_objc	a6,d6
	move.w		ob_x(a0),d4	; Coordonnee X de la G_GITLE a enlever
	move.w		ob_w(a0),d1
	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d3
	trouve_objc	a6,d3
	sub.w		d1,ob_w(a0)	; Au passage, on update la largeur de l'objet englobant les G_TITLE
	move.w		ob_head(a0),d2
.lp_update_x
	trouve_objc	a6,d2
	move.l		a0,a3
	cmp.w		ob_x(a0),d4
	bge		.suite
	sub.w		d1,ob_x(a0)	; L'updatement

	find_to_deroule	a6,d2
	trouve_objc	a6,d0
	sub.w		d1,ob_x(a0)	; Update de l'X du G_BOX

.suite	move.w		ob_next(a3),d2
	cmp.w		d2,d3
	bne		.lp_update_x

* On efface le titre et son G_BOX (et descendance) associe
	lea		del_list,a0
	move.w		d6,(a0)+
	move.w		d5,(a0)+
	move.l		#-1,(a0)+
	move.l		a6,del_win
	erase_list	#del_list,#del_win

	find_tab_l	#tab_adr,a6
	wd_redraw_gem	d0

.end_error	rts
	bss
del_list	ds.w	5
del_win		ds.l	1
	text
*--------------------------------------------------------------------------------------------------------------------------*
menu_up
	xobjc_change		a4,d6
	move.w	d7,-(sp)
	find_selected_title	a6
	move.w			d0,d7		; d7 = index du g_title conserne
	cmp.w			#-1,d0
	beq			.end_error
	find_to_deroule		a6,d7
	move.w			d0,d6		; d6 = index du g_box englobant
	find_selected_entree	a6,d0
	cmp.w			#-1,d0
	beq			.upmenu_title
	move.w			d0,d5		; d5 = index de l'entree a deplacer

* On verifie si l'entree est en haut
	trouve_objc	a6,d5
	move.l		a0,a5		; a5 = adresse du G_STRING a changer de place
	move.w		ob_y(a0),d4	; ancienne position de la G_STRING
	beq		.tesautop_monpote

* Puis on cherche le G_STRING juste au dessus celui a deplacer
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
	moveq.l		#-1,d2
.lp_up_entree
	trouve_objc	a6,d3
	cmp.w		ob_y(a0),d4
	ble		.suite_up_entree	; Plus haut que le G_STRING selectionne ?
	cmp.w		ob_y(a0),d2
	bgt		.suite_up_entree	; Plus bas que la hauteur deja trouve ?
	move.w		d3,d1
	move.w		ob_y(a0),d2			; Alors on conserve cet objet et sa coordonnee en y
.suite_up_entree
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_up_entree

* Enfin on echange leurs coordonnes
	trouve_objc	a6,d1
	move.w		ob_y(a0),d0
	move.w		ob_y(a5),ob_y(a0)
	move.w		d0,ob_y(a5)
	move.w		(sp)+,d7
	wd_redraw_gem	d7
	rts

	*----------------------------------------------*
* Il faut deplacer le G_TITLE
.upmenu_title

* On verifie si le titre est en haut
	trouve_objc	a6,d7
	move.l		a0,a5		; a5 = adresse du G_TITLESTRING a changer de place
	move.w		ob_x(a0),d4	; ancienne position du G_TITLE
	beq		.tesautop_monpote

* Puis on cherche le G_TITLE juste au dessus celui a deplacer
	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d6
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
	moveq.l		#-1,d2
.lp_up_title
	trouve_objc	a6,d3
	cmp.w		ob_x(a0),d4
	ble		.suite_up_title		; Plus haut que le G_STRING selectionne ?
	cmp.w		ob_x(a0),d2
	bgt		.suite_up_title		; Plus bas que la hauteur deja trouve ?
	move.w		d3,d1
	move.w		ob_x(a0),d2			; Alors on conserve cet objet et sa coordonnee en y
.suite_up_title
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_up_title

* Enfin on echange leurs coordonnes
	trouve_objc	a6,d1
	move.w		ob_x(a0),d0
	move.w		ob_x(a5),ob_x(a0)
	move.w		d0,ob_x(a5)

* Et celles des G_BOX correspondante
	find_to_deroule	a6,d1
	trouve_objc	a6,d0
	move.l		a0,a5
	find_to_deroule	a6,d7
	trouve_objc	a6,d0
	move.w		ob_x(a0),d0
	move.w		ob_x(a5),ob_x(a0)
	move.w		d0,ob_x(a5)

.tesautop_monpote
	move.w		(sp)+,d7
	wd_redraw_gem	d7
	rts
.end_error
	move.w		(sp)+,d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
menu_down
	xobjc_change		a4,d6
	move.w	d7,-(sp)
	find_selected_title	a6
	move.w			d0,d7		; d7 = index du g_title conserne
	cmp.w			#-1,d0
	beq			.end_error
	find_to_deroule		a6,d7
	move.w			d0,d6		; d6 = index du g_box englobant
	find_selected_entree	a6,d0
	cmp.w			#-1,d0
	beq			.upmenu_title
	move.w			d0,d5		; d5 = index de l'entree a deplacer

* On verifie si l'entree est en bas
	trouve_objc	a6,d5
	move.l		a0,a5		; a5 = adresse du G_STRING a changer de place
	move.w		ob_y(a0),d4	; ancienne position de la G_STRING
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
.lp_trouve_le_plus_bas
	trouve_objc	a6,d3
	cmp.w		ob_y(a0),d4
	blt		.pas_en_bas_entree
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_trouve_le_plus_bas
	bra		.tesautop_monpote
.pas_en_bas_entree

* Puis on cherche le G_STRING juste au dessus celui a deplacer
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
	move.w		#32000,d2
.lp_down_entree
	trouve_objc	a6,d3
	cmp.w		ob_y(a0),d4
	bge		.suite_down_entree	; Plus haut que le G_STRING selectionne ?
	cmp.w		ob_y(a0),d2
	blt		.suite_down_entree	; Plus bas que la hauteur deja trouve ?
	move.w		d3,d1
	move.w		ob_y(a0),d2			; Alors on conserve cet objet et sa coordonnee en y
.suite_down_entree
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_down_entree

* Enfin on echange leurs coordonnes
	trouve_objc	a6,d1
	move.w		ob_y(a0),d0
	move.w		ob_y(a5),ob_y(a0)
	move.w		d0,ob_y(a5)
	move.w		(sp)+,d7
	wd_redraw_gem	d7
	rts
	*----------------------------------------------*
* Il faut deplacer le G_TITLE
.upmenu_title

* On verifie si le titre est en bas
	trouve_objc	a6,d7
	move.l		a0,a5		; a5 = adresse du G_TITLE a changer de place
	move.w		ob_x(a0),d4	; ancienne position du G_TITLE

	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d6
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
.lp_trouve_le_plus_a_gauche
	trouve_objc	a6,d3
	cmp.w		ob_x(a0),d4
	blt		.pas_a_droite_menu
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_trouve_le_plus_a_gauche
	bra		.tesautop_monpote
.pas_a_droite_menu

* Puis on cherche le G_TITLE juste au dessus celui a deplacer
	trouve_objc	a6,ob_head(a6)
	move.w		ob_head(a0),d6
	trouve_objc	a6,d6
	move.w		ob_head(a0),d3
	move.w		#32000,d2
.lp_up_title
	trouve_objc	a6,d3
	cmp.w		ob_x(a0),d4
	bge		.suite_up_title		; Plus haut que le G_STRING selectionne ?
	cmp.w		ob_x(a0),d2
	blt		.suite_up_title		; Plus bas que la hauteur deja trouve ?
	move.w		d3,d1
	move.w		ob_x(a0),d2			; Alors on conserve cet objet et sa coordonnee en y
.suite_up_title
	move.w		ob_next(a0),d3
	cmp.w		d3,d6
	bne		.lp_up_title

* Enfin on echange leurs coordonnes
	trouve_objc	a6,d1
	move.w		ob_x(a0),d0
	move.w		ob_x(a5),ob_x(a0)
	move.w		d0,ob_x(a5)

* Et celles des G_BOX correspondante
	find_to_deroule	a6,d1
	trouve_objc	a6,d0
	move.l		a0,a5
	find_to_deroule	a6,d7
	trouve_objc	a6,d0
	move.w		ob_x(a0),d0
	move.w		ob_x(a5),ob_x(a0)
	move.w		d0,ob_x(a5)

.tesautop_monpote
	move.w		(sp)+,d7
	wd_redraw_gem	d7
	rts
.end_error
	move.w		(sp)+,d7
	rts
