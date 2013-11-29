	include	gemdos.i
	include	aes.i
	include	vdi.i
	include	zlib.i
	include	structs.s

	include	..\memory.s
	include	..\fashion.s
	include	..\macro.i

	text
	XREF	opt_num,opt_arbre,x_mouse_clik,y_mouse_clik,init_x,init_y,hauteur_menu,rsc_files
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind,tampon,x_max,y_max,n_mouse_clik
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,wd_create_drag_window

	XREF	open_new_arbre_window
	XREF	wd_create_editmenu,wd_create_form
	XREF	create_alert_edit
	XREF	EDIT_MENU_adr

	XDEF	wd_create_objet

	XREF	close_ressource_msg
*-----------------------*
*-----------------------*
*-----------------------*
wd_create_objet
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !

	get_tab		#tab_adr,d7
	move.l		d0,a0
	add.l		#wd_objc_header_size,a0
;	clr.l		(a0)

	get_tab		#tab_x,d7
	cmp.l		#-1,d0
	beq		wd_create_objet2

	get_tab		#tab_y,d7
	cmp.w		hauteur_menu,d0
	bge		.suite
	put_tab_w	#tab_y,d7,hauteur_menu			; Y
.suite
	bra		wd_create_objet3
wd_create_objet2
	move.w		x_max,d6
	lsr.w		#2,d6
	put_tab_w	#tab_x,d7,d6		; et on place les x,y,w&h dans les tableaux
	move.w		y_max,d5
	lsr.w		#2,d5
	put_tab_w	#tab_y,d7,d5		; et on place les x,y,w&h dans les tableaux
	lsl.w		#1,d6
	lsl.w		#1,d5
	put_tab_w	#tab_w,d7,d6
	put_tab_w	#tab_h,d7,d5

wd_create_objet3
	put_tab_w	#tab_kind,d7,#$1ff			; la fenetre a tous les attributs sauf les fleches du bas et le tapi roulant
	put_tab_l	#tab_gadget,d7,#wd_gadget_objet		; adresse de la routine des gadgets
	put_tab_l	#tab_clic,d7,#wd_clic_objet		; adresse de la routine de clic
	put_tab_l	#tab_rout,d7,#wd_redraw_objet		; adresse de la routine de redraw

	moveq.l		#0,d0
	movem.l		(sp)+,d1-a6
	rts		; puis on ouvre la fenetre
*-----------------------*
*--------------------------------------------------------------------------------------------------------------------------*
*-----------------------*
wd_clic_objet

	move.w		4(sp),d7	; recupere l'index de la fenˆtre

	top_wind_if_not_top_n_rts	d7
	

* On determine quel icone a ete clique...
	get_tab		#tab_adr,d7
	move.l		d0,a6
	move.w		x_mouse_clik,-(sp)
	move.w		y_mouse_clik,-(sp)
	move.l		a6,-(sp)
	bsr		find_cliked_obj
	addq.l		#8,sp
	add.w		wd_objc_skip(a6),d0
	subq.w		#1,d0

	moveq.l	#0,d6
	move.w	d0,d6		; d1 contien maintenant le numero de l'objet clike
* On verifie qu'un objet est bien sous la sourie. Pour ce faire, on compe le nombre d'objet
* present dans la structure, et on compare avec celui qui est passe en parametre.
	get_tab	#tab_adr,d7
	move.l	d0,a0
	add.l	#wd_objc_header_size,a0
	clr.w	d0
.boucle_compte_nombre_dobjet_dans_la_structure
	tst.l	(a0)
	beq.s	.comptage_fini
	addq.w	#1,d0
	add.l	#wd_objc_struct_size,a0
	bra	.boucle_compte_nombre_dobjet_dans_la_structure

.comptage_fini
	cmp.w		d0,d6
	blt		.ya_un_objet_sous_la_sourie

	move.w		d7,-(sp)
	bsr		open_new_arbre_window
	addq.l		#2,sp
	rts

.ya_un_objet_sous_la_sourie
* Si double clic, alors on ouvre une fenetre
	cmp.w		#2,n_mouse_clik
	beq		.doubled_clik

* Sinon on selectionne maintenant l'objet (en changeant un bit dans la structure)
	get_tab		#tab_adr,d7
	add.l		#wd_objc_header_size,d0
	mulu.l		#wd_objc_struct_size,d6
	add.l		d6,d0
	move.l		d0,a0
	bchg.b		#0,wd_objc_state+1(a0)

	wd_redraw	d7
	rts
*--------------------------------------------------------------------------------------------------------------------------*
.doubled_clik
	get_tab	#tab_adr,d7
	move.l	d0,d5		; adresse des donnees de la fenetre ou l'on a cliquer

* on trouve ensuite la structure ressource correspondant a la fenetre double clik‚e.
	lea		rsc_files,a0
.loopx1
	tst.l		(a0)					; corespondant a la fenetre toppe.
	beq		oups
	move.l		(a0)+,a6
	lea		mrsc_tree_list(a6),a5
	cmp.l		a5,d5
	bne		.loopx1

* puis on cherche l'espace memoire de l'arbre
	add.l		#mrsc_ptr,a6
	lea		(a6,d6.w*4),a6	; a6 pointe sur la structure de l'arbre selctionne, puis...
	move.l		(a6),a6
	add.l		#mtree_objets,a6	; sur l'arbre lui-meme
* on ouvre une fenetre en fonction du type d'arbre dans la fenetre
	move.w		x_max,d0
	move.w		y_max,d1
	sub.w		init_x,d0
	sub.w		init_y,d1
	lsr.w		#2,d0
	lsr.w		#2,d1
	add.w		init_x,d0
	add.w		init_y,d1

* On a quel type d'objet sous la sourie ?
	move.l		a5,a0
	add.l		#wd_objc_header_size,a0
	move.l		#wd_objc_struct_size,d2
	mulu.l		d6,d2
	lea		(a0,d2),a0
	cmp.w		#RB_DIALOG,wd_objc_icon(a0)
	beq		.cre_editdial
	cmp.w		#RB_ALERT,wd_objc_icon(a0)
	beq		.cre_alert
* On ouvre un type de fenetre en fonction du type

	*------------------ Menu editable -------------------*
* Ouverture de la fenetre d'edition de menu
	rsrc_gaddr	#0,#EDIT_MENU
	move.l		addr_out,a5

	tst.l		EDIT_MENU_adr
	bne		.suite_ouvre_from_edit
	move.l		a5,EDIT_MENU_adr

	move.w		y_max,ob_y(a5)
	move.w		ob_h(a5),d0
	sub.w		d0,ob_y(a5)
	move.w		#2,ob_x(a5)

	wind_calc	#0,#%1011,ob_x(a5),ob_y(a5),ob_w(a5),ob_h(a5)

.suite_ouvre_from_edit
	wd_create	a5,#wd_create_form,int_out+2,int_out+4,int_out+6,int_out+8

* Ouverture de la fenetre menu
	wd_create	a6,#wd_create_editmenu,#-1,#0,#0,#0
	rts

	*------------------ Alert editable -------------------*
.cre_alert
	move.l	a6,-(sp)
	jsr	create_alert_edit
	addq.l	#4,sp

	rts
	*------------------ Formulaire editable -------------------*
* Ouverture du dialogue a editer
.cre_editdial
	wd_create	a6,#wd_create_drag_window,d0,d1,#0,#0
	rts
oups
	illegal		; si on arrive ici, c'est que ya un problem... on double clic ds une fenetre qui n'existe pas !
*----------------------------------------------------------------------------------------------*
* Cacul le numero de l'icone clique (sans ajout du nombre d'icone skipe)
find_cliked_obj
	movem.l		d1/d2/d4-d7/a0-a2/a6,-(sp)
	move.l		44+0(sp),a6	; adresse des donnees de la fenetre
	move.w		44+4(sp),d7	; Y du clik
	move.w		44+6(sp),d6	; X du clik
	move.l		a6,-(sp)
	bsr		get_obj_per_line
	addq.l		#4,sp
	move.w		d0,d4
	find_tab_l	#tab_adr,a6
	move.w		d0,d5
	get_tab		#tab_handle,d5
	wind_get	d0,#WF_WORKXYWH
	sub.w		int_out+2,d6	; X et Y du clik dans la fenetre
	sub.w		int_out+4,d7
	moveq.l		#0,d2
	move.w		wd_objc_x(a6),d2
	moveq.l		#0,d0
	move.w		d6,d0
	add.w		d2,d0
	divu.w		d2,d0
;	bcs		pas_1er_pixel_x
;	subq.w		#1,d0
;pas_1er_pixel_x
	cmp.w		d0,d4
	blt		a_cote

	moveq.l		#0,d2
	move.w		wd_objc_y(a6),d2
	moveq.l		#0,d1
	move.w		d7,d1
	add.w		d2,d1
	divu.w		d2,d1
;	bcs		pas_1er_pixel_y
;	subq.w		#1,d1
;pas_1er_pixel_y
	subq.w		#1,d1
	mulu.w		d4,d1
	add.w		d1,d0
	movem.l		(sp)+,d1/d2/d4-d7/a0-a2/a6
	rts

a_cote
	move.w		#-1,d0
	movem.l		(sp)+,d1/d2/d4-d7/a0-a2/a6
	rts
*----------------------------------------------------------------------------------------------*
get_obj_per_line
	movem.l		d1/d2/d6/d7/a0-a2/a6,-(sp)
	move.l		36+0(sp),a6
	find_tab_l	#tab_adr,a6
	get_tab		#tab_handle,d0
	wind_get	d0,#WF_WORKXYWH
	move.w		int_out+6,d6
	moveq.l		#0,d2
	move.w		wd_objc_x(a6),d2
	moveq.l		#0,d1
	move.w		d6,d1
	divu.w		d2,d1
	move.w		d1,d0	; nombre d'icone par ligne

	mulu.w		d2,d1
	sub.w		d1,d6
	lsr.w		#1,d2
	cmp.w		d2,d6
	blt		.suite_get_per
	add.w		#1,d0	; plus l'icone affiche a moitie
.suite_get_per
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a6
	rts
*----------------------------------------------------------------------------------------------*
*-----------------------*
*-----------------------*
*-----------------------*
wd_gadget_objet
	move.w		4(sp),d7
	cmp.w		#WM_MOVED,tampon
	beq		.redraw_wd_ob
	cmp.w		#WM_SIZED,tampon
	beq		.redraw_wd_ob
	cmp.w		#WM_CLOSED,tampon
	beq		close_ressource
	rts

.redraw_wd_ob
	wind_set	tampon+6,#5,tampon+8,tampon+10,tampon+12,tampon+14
	find_tab_w	#tab_handle,tampon+6
	wd_redraw_gem	d0
	rts
*-----------------------*
close_ressource
	form_alert	#1,#close_ressource_msg
	cmp.w		#1,d0
	beq		.close_it
	rts

.close_it
	get_tab		#tab_adr,d7
	sub.l		#mrsc_tree_list,d0
	move.l		d0,a6
	lea		mrsc_ptr(a6),a5

	move.l		mrsc_ptrnbr(a6),d6
	beq		.no_tree

.loop_free_rsc
	move.l		(a5)+,a4
	lea		mtree_objets(a4),a3
	efface_tree	a3
	wd_kill		a3
	Mfree		a4

	subq.l		#1,d6
	bne		.loop_free_rsc

.no_tree
	get_tab		#tab_adr,d7	; place une donnee dans le tableau
	wd_kill		d0

	Mfree		a6

	move.l		a6,d0
	lea		rsc_files,a5
.loop_find_r
	cmp.l		(a5)+,d0
	bne		.loop_find_r

	lea		-4(a5),a4
.loop_vire_ptr
	move.l		(a5)+,d0
	move.l		d0,(a4)+
	tst.l		d0
	bne		.loop_vire_ptr
	rts
*-----------------------*
*-----------------------*
*-----------------------*
* Calcul et reafiche l'assenceur vertical...
wd_objet_calcul_slider
* On calcul d'abbord le nombre d'objet dans la structure
	rts
*-----------------------*
*-----------------------*
*-----------------------*
	data
wx1	dc.w	1
wy1	dc.w	1
wx2	dc.w	1
wy2	dc.w	1
ww	dc.w	1
wh	dc.w	1
_offset	dc.w	1
	text
wd_redraw_objet
* affichage d'un rectangle blanc
	move.w		d3,_offset
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

	vs_clip		#1,d4,d5,d6,d7		; cliping sur le rectangle a redessiner
	vsf_interior	#0					; on trace un rectangle
	vsf_perimeter	#0					; blanc dans le rectangle
	v_bar		d4,d5,d6,d7				; a redessiner
	vs_clip		#0,d4,d5,d6,d7			; cliping OFF

* affichage des objets dans le formulaire
;	find_tab_w	#tab_handle,tampon+6
;	move.w		d0,_offset
	get_tab		#tab_adr,_offset	; on trouve l'adresse de structure des donnees
	move.l		d0,a4

	tst.l		(a4)	; si les tailles des icones sont a 0, alors pas d'affichage.
	beq		.suite
	move.w		(a4)+,d7	; espace en x entre icone
	move.w		(a4)+,d6	; espace en y entre icone
	move.w		(a4)+,d5	; nombre d'icone a ne pas afficher en debut de liste
	mulu.w		#wd_objc_struct_size,d5
	add.l		d5,a4
	clr.w		d4		; coordonnee en X du prochain icone a afficher
	clr.w		d3		; coordonnee en Y du prochain icone a afficher

	rsrc_gaddr	#0,#ARBRE	; formulaire ou on affiche l'icone
	move.l		addr_out,a0
	move.l		a0,a3
	add.l		#24,a3		; on cherche l'objet numero 1

	move.w		(a6),ob_x(a0)	; le formulaire a afficher prend les dimention de la fenetre
	move.w		2(a6),ob_y(a0)	; de travail
	move.w		8(a6),ob_w(a0)	
***********************
* Correction de bug 2 *
***********************
;	move.w		12(a6),ob_h(a0)
	move.w		10(a6),ob_h(a0)	
	tst.l		(a4)
	beq		.suite
.loop
	move.l		(a4)+,a0	; adresse du formulaire
	move.w		(a4)+,d5	; index de l'icone
	move.l		(a4)+,a5	; adresse de la chaine
	move.w		(a4)+,d2	; etat de l'objet
	trouve_objc	a0,d5		; adresse de l'objet->a0

	move.w		ob_type(a0),ob_type(a3)		; on recopie une bonne partie de la structure
	move.w		ob_flags(a0),ob_flags(a3)	; de l'objet
	move.l		ob_spec(a0),ob_spec(a3)

	tst.w		d2
	beq		.suiteyop
	bset.b		#0,ob_states+1(a3)
	bra		.suiteyop2
.suiteyop
	bclr.b		#0,ob_states+1(a3)
.suiteyop2

	move.w		d4,ob_x(a3)	; puis on place les coordonnes de l'icone en X
	move.w		d3,ob_y(a3)	; et en Y

	move.l		ob_spec(a3),a2
	addq.l		#8,a2
	move.l		a5,(a2)

	move.l		a3,d0
	sub.l		#24,d0		; adresse du formulaire a afficher

	objc_draw	d0,#1,#1,wx1,wy1,ww,wh

	add.w		d7,d4		; gestion de l'increment des
	move.w		d7,d0
	lsr.w		#1,d0
	add.w		d4,d0
* Debug report *
	move.w		8(a6),d1
	cmp.w		d1,d0		; coordonnes en X et Y
	blt		.pas_de_retour_a_la_ligne
	add.w		d6,d3
* Debug report *
	move.w		10(a6),d0
	cmp.w		d0,d3
	bge		.suite		; si Y trop grand, on a fini d'affiche
	clr.w		d4
.pas_de_retour_a_la_ligne

	tst.l		(a4)		; reste-il des objet a afficher ?
	bne		.loop
.suite
	rts
