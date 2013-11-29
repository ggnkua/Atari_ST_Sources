*** Definition d'un formulaire en fenetre ***
	text
	include	aes.i
	include	structs.s
	include	zlib.i
	include	..\fashion.s

	XREF	opt_num,opt_arbre,x_mouse_clik,y_mouse_clik
	XREF	tampon,hauteur_menu,appl_name,options
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
*--------------------------*
*--------------------------*
*--------------------------*
	XDEF	wd_create_form_n_menu
wd_create_form_n_menu
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !
	get_tab		#tab_adr,d7
	move.l		d0,a5			; l'adresse du formulaire
	move.l		(a5),a6
	move.l		4(a5),a4
	get_tab		#tab_x,d7
	move.l		d0,d3
	cmp.w		#-1,d3			; si X est a -1, alors on doit centrer le formulaire
	bne		wd_create_form_2	; sinon, on prend les coordonnes mise en X et Y.

* On centre de formulaire.
	form_center	a6			; on centre le formulaire
	move.w		ob_h(a6),d0
	add.w		hauteur_menu,d0
	wind_calc	#0,#%1011,ob_x(a6),ob_y(a6),ob_w(a6),d0
	put_tab_w	#tab_x,d7,int_out+2	; et on place les x,y,w&h dans les tableaux
	put_tab_w	#tab_y,d7,int_out+4
	put_tab_w	#tab_w,d7,int_out+6
	put_tab_w	#tab_h,d7,int_out+8
	bra		wd_create_form_3

wd_create_form_2
; on calcul les coordonnees du formulaire
; a partir des coordonnes delivre en parametre
	get_tab		#tab_y,d7
	move.w		d0,d4

	wind_calc	#1,#%1011,d3,d4,#100,#100
	move.w		int_out+2,ob_x(a6)
	move.w		int_out+4,d0
	move.w		d0,ob_y(a4)
	add.w		hauteur_menu,d0
	move.w		d0,ob_y(a6)

	move.w		#100,d5
	move.w		#100,d6
	sub.w		int_out+6,d5	; d5 & d6 sont la difference de taille entre
	sub.w		int_out+8,d6	; le formulaire et la fenetre
	add.w		ob_w(a6),d5
	add.w		ob_h(a6),d6
	add.w		hauteur_menu,d6
	put_tab_w	#tab_w,d7,d5
	put_tab_w	#tab_h,d7,d6

	get_tab		#tab_y,d7		;   /\		Le Y minimale est egale
	move.l		d0,d6			;  /!!\		a la hauteur de la barre
	cmp.w		hauteur_menu,d6		; ------	de menu...
	bge.s		wd_create_form_3
	put_tab_w	#tab_y,d7,hauteur_menu


* On place le reste des infos
wd_create_form_3
	put_tab_l	#tab_name,d7,#appl_name		; ainsi que le pointeur sur le texte de la bare de d‚placement,
	put_tab_w	#tab_kind,d7,#%1011		; les attribues AES
	put_tab_l	#tab_rout,d7,#wd_redraw_form	; le pointeur sur la routine de redraw
	put_tab_l	#tab_gadget,d7,#wd_gadget_form	; le pointeur sur la routine de gadget et finalement
	put_tab_l	#tab_clic,d7,#wd_clic_form	; le pointeur sur la routine de clic
	put_tab_l	#tab_key,d7,#wd_key_form	; le pointeur sur la routine de key
	moveq.l		#0,d0
	movem.l		(sp)+,d1-a6
	rts
*--------------------------*
*--------------------------*
*--------------------------*
wd_key_form

	rts
*--------------------------*
*--------------------------*
*--------------------------*
	rsreset
mn_cord_x	rs.w	1
mn_cord_y	rs.w	1
mn_cord_w	rs.w	1
mn_cord_h	rs.w	1
mn_title_id	rs.w	1
mn_objc_id	rs.w	1
mn_gbox_id	rs.w	1
mn_struc_size	rs.w	1
	bss
menu_variables	ds.b	mn_struc_size
	text
* Recois l'offset dans les tableau par la pile
wd_clic_form
	move.w		4(sp),d3
* On clic dans le menu ou dans le formulaire ?
	get_tab		#tab_x,d3
	move.w		d0,d4
	get_tab		#tab_y,d3
	move.w		d0,d5
	get_tab		#tab_kind,d3
	wind_calc	#1,d0,d4,d5,#100,#100
	move.w		int_out+4,d7
	add.w		hauteur_menu,d7
	cmp.w		y_mouse_clik,d7
	blt		clic_on_formulaire
* On a clique dans le menu en fenetre
	get_tab		#tab_adr,d3
	move.l		d0,a6
	move.l		4(a6),a6

	objc_find	a6,#1,#2,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
	cmp.w		#-1,d0
	bne		.suite_menu_clik
.heu_ben_reuteusseu
	rts
.suite_menu_clik
	lea		24*2(a6),a4
	cmp.w		ob_head(a4),d0
	blt		.heu_ben_reuteusseu
	cmp.w		ob_tail(a4),d0
	bgt		.heu_ben_reuteusseu
	move.w		d0,d5
	subq.w		#3,d0
	move.w		d0,d7
	trouve_objc	a6,ob_tail(a6)
	trouve_objc	a6,ob_head(a0)
	tst.w		d7
	beq		entree_trouve
	subq.w		#1,d7
.loop_trouve_entree
	trouve_objc	a6,ob_next(a0)
	dbra		d7,.loop_trouve_entree
entree_trouve
	move.l		a0,d6
	move.l		a0,a5
* On trouve le G_BOX correspondant au G_TITLE ou on a clique + ses coordonnees
	sub.l		a6,d6
	divu.l		#24,d6
	lea		menu_variables,a3
	move.w		d6,mn_gbox_id(a3)
	objc_offset	a6,d6
	move.w		int_out+2,d0
	move.w		int_out+4,d1
	move.w		ob_w(a5),d2
	move.w		ob_h(a5),d3
	subq.w		#1,d0
	subq.w		#1,d1
	addq.w		#2,d2
	addq.w		#2,d3
	move.w		d0,mn_cord_x(a3)
	move.w		d1,mn_cord_y(a3)
	move.w		d2,mn_cord_w(a3)
	move.w		d3,mn_cord_h(a3)
	move.w		d5,mn_title_id(a3)
	objc_draw	a6,d6,#2,d0,d1,d2,d3	; affichage du G_BOX et de sa descendance
* On rentre dans la boucle de teste de la coordonnee de la sourie
loop_menu_multi
	evnt_multi	#4+2,#1,#2,#0,#1,x_mouse_clik,y_mouse_clik,#1,#1 ; on attend les boutons de la sourie ou un deplacement...
	btst		#1,d0			; on a relacher le bouton -> on sort de la boucle
	bne		go_bouton_relache	; sinon, on a bouger la sourie... -> donc se deplacer dans les menu
	btst		#2,d0
	bne		go_deplace_souris
	rts
go_bouton_relache
	rts
go_deplace_souris
	move.w		int_out+2,x_mouse_clik
	move.w		int_out+4,y_mouse_clik
	objc_find	a6,mn_gbox_id(a3),#2,d3,d4	; on trouve l'index de l'objet
	cmp.w		d0,d5
	beq		loop_menu_multi
	move.w		d0,d7
	trouve_objc	a6,d7
	cmp.b		#G_TITLE,ob_type+1(a0)
	beq		new_g_title
	bset		#SELECTED,ob_states+1(a0)

new_g_title
* On a clique dans le formulaire
clic_on_formulaire
	get_tab		#tab_adr,d3
	move.l		d0,a0
	move.l		(a0),d3

	objc_find	d3,#0,#20,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
	cmp.w		#-1,d0
	bne.s		.pas_de_retour_en_boucle1
	rts
.pas_de_retour_en_boucle1
	move.w		d0,d5
	move.w		d0,opt_num

	trouve_objc	d3,d0				; et on verifie qu'il est bien "selectable"
	move.w		ob_flags(a0),d0
	btst		#SELECTABLE,d0
	beq		.toppe_la_fenetre

	move.w		ob_states(a0),d0		; et pas "disabled"
	btst		#DISABLED,d0
	bne		.toppe_la_fenetre

	move.w		ob_flags(a0),d0
	btst		#EDITABLE,d0			; on gere les editable deferement...
	bne		.editable
	btst		#RBUTTON,d0			; on verifie que l'objet est
	beq		.no_radio_bouton		; un radio bouton

*~~~ debut de gestion des boutons RADIO ~~~*
	trouve_bouton_precedent	d5,d3	; si oui, alors on deselectionne l'objet precedement clike
	cmp.w		d0,d5				; si celui-ci n'est pas l'objet clike
	bne.s		.pas_de_retour_en_boucle4	; (si c'est cet objet, on boucle sans rien faire)
	rts
.pas_de_retour_en_boucle4
	move.w		d0,d4

	xobjc_change	d3,d4
*~~~ fin de gestion des boutons RADIO ~~~*
.no_radio_bouton
	xobjc_change	d3,d5

;	trouve_objc	d3,d5				; l'objet est-il "touchexit" ?
;	move.w		ob_flags(a0),d0
;	btst		#TOUCHEXIT,d0
;	illegal
;	bne		.suite_formulaire

;	evnt_multi	#%10011,#$102,#3,#0
; ici, il faudrait normalement gerer l'attente de relachement de la sourie.
; pour cela, il faut :
;		- tant que sourie au dessus de l'objet, ne rien faire
;		- sinon, deselectionner l'objet, et attendre que la sourie rentre au dessus de l'objet
; a tout moment, des que la sourie est relache, on verifie que le pointeur est au dessus de
; l'objet, et on continue. 

.suite_formulaire
	move.l	d3,opt_arbre
	jsr	options

	rts
.toppe_la_fenetre
	get_tab		#tab_handle,d3
	wind_set2	d0,#10
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*~~~ gestion des champs editables ~~~*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
.editable
	rsrc_gaddr	#0,#EDIT			; on trouve l'adresse de l'editable en formulaire
	move.l		addr_out,a5
	trouve_objc	addr_out,#EDIT_EDIT
	move.l		a0,a6

	trouve_objc	d3,opt_num
;	move.w		ob_w(a0),ob_w(a6)		; on recopie la taille de l'editable
;	move.w		ob_h(a0),ob_h(a6)

	move.l		ob_spec(a0),a4			; on trouve la largeur du texte
	move.w		te_tmplen(a4),d0		; et on en deduit la taille du formulaire
	lsl.w		#3,d0				; a afficher
	move.w		d0,ob_w(a6)			; on le place dans l'editable
	subq.w		#4,d0
;	add.w		#8,d0
	move.w		d0,ob_w(a5)			; on place cette valeur dans le formulaire

	move.l		ob_spec(a6),a3
	move.l		te_ptext(a4),te_ptext(a3)
	move.l		te_ptmplt(a4),te_ptmplt(a3)
	move.l		te_pvalid(a4),te_pvalid(a3)	; on recopie une partie de la structure ted_info
	move.l		te_txtlen(a4),te_txtlen(a3)
	move.l		te_tmplen(a4),te_tmplen(a3)

	objc_offset	d3,opt_num
	move.w		int_out+2,ob_x(a5)
	move.w		int_out+4,ob_y(a5)		; on en profite pour place ce formulaire en X et Y

	move.w		ob_x(a5),d4			; on elargi le rectangle du formulaire
	move.w		ob_y(a5),d5
	move.w		ob_w(a5),d6
	move.w		ob_h(a5),d7

	subq.w		#4,d4
	subq.w		#4,d5
	addq.w		#8,d6
	addq.w		#8,d7

	form_dial	#0,d4,d5,d6,d7,d4,d5,d6,d7	; on lance la gestion du formulaire
	objc_draw	a5,#0,#10,d4,d5,d6,d7
	form_do		a5,#0
	form_dial	#3,d4,d5,d6,d7,d4,d5,d6,d7

;	redraw_objc	d3,opt_num			; puis on fait un redraw de l'editable en formulaire

	state_bit_objc	a5,#EDIT_EDIT,#SELECTED,#0

	move.l		d3,opt_arbre			; on gere l'option
;	bsr.l		options
;	rts
	bra.l		options
*--------------------------*
*--------------------------*
*--------------------------*
* L'offset dans les tableaux a ete empile avant le saut !
wd_gadget_form
	move.w		4(sp),d7
	get_tab		#tab_kind,d7
	wind_calc	#1,d0,tampon+8,tampon+10,tampon+12,tampon+14

	get_tab		#tab_adr,d7		; si c'est un formulaire en fenetre,
	move.l		d0,a0			; alors on deplace celui-ci
	move.l		(a0),a6
	move.l		4(a0),a5
	move.w		int_out+2,ob_x(a6)
	move.w		int_out+2,ob_x(a5)
	move.w		int_out+4,d0
	move.w		d0,ob_y(a5)
	add.w		hauteur_menu,d0
	move.w		d0,ob_y(a6)
	rts

*--------------------------*
*--------------------------*
*--------------------------*
* De d4 a d7 on trouve les coordonnees du rectagle a redissinner, au format AES.
* D3 est l'offset dans les tableaux.
* a6 pointe vers une structure du type suivant, donnant les coordonnees de surface
*           de travail de la fenetre au format VDI et AES :
* X, Y, X2, Y2, W, H
wd_redraw_form
* Dessin du formulaire
	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a6			; correspondante a la surface de travail de la fenetre

	move.l		(a6),a1
	objc_draw	a1,#0,#20,d4,d5,d6,d7
* Dessin du menu
	move.l		4(a6),a5
	objc_draw	a5,#1,#2,d4,d5,d6,d7
	rts

