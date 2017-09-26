*** Definition d'un formulaire en fenetre ***
	text
	include	d:\code\include\aes.i
	include	d:\code\include\structs.s
	include	d:\code\include\zlib.i
	include	d:\code\new\rsc.s

	XREF	opt_num,opt_arbre,x_mouse_clik,y_mouse_clik
	XREF	tampon,hauteur_menu,appl_name,options
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
*--------------------------*
*--------------------------*
*--------------------------*
	XDEF	wd_create_form,wd_gadget_form
wd_create_form
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !
	get_tab		#tab_adr,d7
	move.l		d0,a6			; l'adresse du formulaire
	get_tab		#tab_x,d7
	move.l		d0,d3
	cmp.w		#-1,d3			; si X est a -1, alors on doit centrer le formulaire
	bne		wd_create_form_2	; sinon, on prend les coordonnes mise en X et Y.

* On centre de formulaire.
	form_center	a6			; on centre le formulaire
	wind_calc	#0,#%1011,ob_x(a6),ob_y(a6),ob_w(a6),ob_h(a6)
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
	move.w		int_out+4,ob_y(a6)

	move.w		#100,d5
	move.w		#100,d6
	sub.w		int_out+6,d5	; d5 & d6 sont la difference de taille entre
	sub.w		int_out+8,d6	; le formulaire et la fenetre
	add.w		ob_w(a6),d5
	add.w		ob_h(a6),d6
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
	movem.l		(sp)+,d1-a6
	moveq.l		#0,d0
	rts
*--------------------------*
*--------------------------*
*--------------------------*
wd_key_form

	rts
*--------------------------*
*--------------------------*
*--------------------------*
* Recois l'offset dans les tableau par la pile
wd_clic_form
	move.w		4(sp),d4
	get_tab		#tab_adr,d4
	move.l		d0,d3

	objc_find	d0,#0,#20,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
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
	get_tab		#tab_handle,d4
	wind_set2	d0,#WF_TOP
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
	cmp.w		#WM_MOVED,tampon
	bne		reuteusseu
	get_tab		#tab_kind,d7
	wind_calc	#1,d0,tampon+8,tampon+10,tampon+12,tampon+14

	get_tab		#tab_adr,d7		; si c'est un formulaire en fenetre,
	move.l		d0,a0			; alors on deplace celui-ci
	move.w		int_out+2,ob_x(a0)
	move.w		int_out+4,ob_y(a0)
reuteusseu
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
	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a0			; correspondante a la surface de travail de la fenetre
;	move.w		a6,ob_x(a0)
;	move.w		2(a6),ob_y(a0)

	objc_draw	a0,#0,#20,d4,d5,d6,d7
	rts