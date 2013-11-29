*** Definition d'un formulaire en fenetre ***
	text
	include	aes.i
	include	structs.s
	include	zlib.i
	include	gemdos.i
	include	util.i

	include	..\rune.s
	include	..\memory.s

* XREF pour la lib
	XREF	opt_num,opt_arbre,x_mouse_clik,y_mouse_clik
	XREF	tampon,hauteur_menu,appl_name,options
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
	XREF	global
	XREF	n_mouse_clik

* XREF special pour RUNE
	XREF	FILEBROWS_adr
	XREF	brows_new
	XREF	last_fb_state
*--------------------------*
*--------------------------*
*--------------------------*
	XDEF	wd_create_brows
wd_create_brows
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !
	get_tab		#tab_adr,d7
	move.l		d0,a6			; l'adresse du formulaire
	get_tab		#tab_x,d7
	move.l		d0,d3

	put_tab_w	#tab_x,d7,#100
	put_tab_w	#tab_y,d7,#50
	put_tab_w	#tab_w,d7,#400
	put_tab_w	#tab_h,d7,#600

	lea		fb_path(a6),a5

* On place le reste des infos
wd_create_form_3
	put_tab_l	#tab_name,d7,a5			; ainsi que le pointeur sur le texte de la bare de d‚placement,
	put_tab_w	#tab_kind,d7,#%111101111	; les attribues AES
	put_tab_l	#tab_rout,d7,#wd_redraw_form	; le pointeur sur la routine de redraw
	put_tab_l	#tab_gadget,d7,#wd_gadget_form	; le pointeur sur la routine de gadget et finalement
	put_tab_l	#tab_clic,d7,#fbrows_clic	; le pointeur sur la routine de clic
	put_tab_l	#tab_key,d7,#fbrows_key		; le pointeur sur la routine de key
	movem.l		(sp)+,d1-a6
	moveq.l		#0,d0
	rts
*--------------------------*
*--------------------------*
*--------------------------*
fbrows_key
	rts
*--------------------------*
*--------------------------*
*--------------------------*
* Recois l'offset dans les tableau par la pile
fbrows_clic
	move.w		4(sp),d4
	get_tab		#tab_adr,d4
	move.l		d0,a6
	move.l		d0,opt_arbre

* Installe le formulaire specifique a une fenetre dans le pointeur du G_BOUNDING
	move.l		d0,a0
	move.l		fb_ptr(a0),a1
	move.l		FILEBROWS_adr,a4
	trouve_objc	a4,#BROWS_BOUND
	move.l		a0,a3
	move.l		ob_spec(a0),a2
	move.l		a1,gbo_tree(a2)

	get_tab		#tab_handle,d4
	wind_get	d0,#WF_WORKXYWH
	move.w		int_out+2,ob_x(a4)
	move.w		int_out+4,ob_y(a4)

* Quel objet est clike ?
	objc_find	FILEBROWS_adr,#0,#20,x_mouse_clik,y_mouse_clik	; on trouve l'index de l'objet
	cmp.w		#-1,d0
	bne.s		.pas_de_retour_en_boucle1
	rts
.pas_de_retour_en_boucle1
	move.l		addr_out,d7
	cmp.l		FILEBROWS_adr,d7
	beq		.no_gbound

*---------------------------*
* On a cliquer dans le G_BOUNDED, donc on a selectionne ou double clike sur un fichier
	move.w		d0,d6
	trouve_objc	d7,d6
	bchg		#SELECTED,ob_states+1(a0)

	objc_size	d7,d6,#red_cord
	objc_offset	d7,d6
	get_tab		#tab_handle,d4
	redraw_cords	d0,int_out+2,int_out+4,red_cord+4,red_cord+6
	cmp.w		#2,n_mouse_clik
	beq		.double_clik
	rts

*---------------------------*
.double_clik
	trouve_objc	d7,d6
	bchg		#SELECTED,ob_states+1(a0)	; deselection de l'objet et re redraw
	objc_size	d7,d6,#red_cord
	objc_offset	d7,d6
	get_tab		#tab_handle,d4
	redraw_cords	d0,int_out+2,int_out+4,red_cord+4,red_cord+6

	lea		.temp_path,a2
	get_tab		#tab_adr,d4			; copy le chemin de la fenetre
	move.l		d0,a1
	lea		fb_path(a1),a3
	string_copy	a3,a2

	move.w		d6,d0
	subq.l		#1,d0
	lea		fb_fbo(a1),a1
	move.l		(a1,d0.w*4),a1
	cmp.w		#FBOT_FOLD,fbo_type(a1)
	beq		.open_item
	cmp.w		#FBOT_PRG,fbo_type(a1)
	beq		.open_item
	rts
.open_item
* Separe le mask du reste du chemin
		lea		.temp_mask,a4
		move.l		a2,a3
.find_end_path	tst.b		(a3)+
		bne		.find_end_path
.find_mask	cmp.b		#"/",-(a3)
		beq		.ok
		cmp.b		#"\",(a3)
		bne		.find_mask
.ok		addq.l		#1,a3
		move.b		(a3),(a4)+
		clr.b		(a3)+
.cp_mask	move.b		(a3)+,(a4)+
		bne		.cp_mask

		lea		fbo_file_name(a1),a0			; trouve le nom de l'objet clike
		string_concat	a0,a2

	cmp.w		#FBOT_PRG,fbo_type(a1)
	beq		.open_prg

		string_concat	#.dos_slash,a2
		string_concat	#.temp_mask,a2

	move.l		a2,-(sp)
	jsr		brows_new
	addq.l		#4,sp
	rts

.temp_path	ds.b	1024
.temp_mask	ds.b	256
.dos_slash	dc.b	"\",0
.unix_slash	dc.b	"/",0

.open_prg
;	illegal
	dxsetpath	#.temp_path
;	pxexec		#0,#.temp_path,#1
	pexec		#0,#0,#.temp_path,#0
	
	rts
*---------------------------*
.no_gbound
* Verification des bits de ob_flags/ob_states
	move.w		d0,d5
	trouve_objc	d7,d5				; et on verifie qu'il est bien "selectable"
	move.w		ob_flags(a0),d0
	btst		#SELECTABLE,d0
	beq		toppe_la_fenetre

*--------------------------*
* Gestion d'un clic options a l'interieure d'une fenetre
	cmp.w		#FBRO_ICTXT,d5
	beq		inver_ictxt
	cmp.w		#FBRO_SIZE,d5
	beq		aff_size
	cmp.w		#FBRO_DATE,d5
	beq		aff_date
	cmp.w		#FBRO_TIME,d5
	beq		aff_time
	cmp.w		#FBRO_ATTRB,d5
	beq		aff_attrb
	cmp.w		#FBRO_POP_TRI,d5
	beq		popup_tri
	cmp.w		#FBRO_INVERT,d5
	beq		invert_tri
	rts
*--------------------------*
inver_ictxt
	bchg		#FB_ICON,fb_state+1(a6)
	bra		go_redraw
	rts
*--------------------------*
aff_size
	bchg		#FB_SIZE,fb_state+1(a6)
	bra		go_redraw
	rts
*--------------------------*
aff_date
	bchg		#FB_DATE,fb_state+1(a6)
	bra		go_redraw
	rts
*--------------------------*
aff_time
	bchg		#FB_TIME,fb_state+1(a6)
	bra		go_redraw
	rts
*--------------------------*
aff_attrb
	bchg		#FB_ATRB,fb_state+1(a6)
	bra		go_redraw
	rts
*--------------------------*
popup_tri
	rts
*--------------------------*
invert_tri
	rts
*--------------------------*
go_redraw
	move.w		fb_state(a6),last_fb_state
	objc_size	FILEBROWS_adr,d5,#red_cord
	get_tab		#tab_handle,d4
	redraw_cords	d0,red_cord,red_cord+2,red_cord+4,red_cord+6
	rts
	bss
red_cord	ds.w	4
	text
*--------------------------*
toppe_la_fenetre
	get_tab		#tab_handle,d4
	wind_set2	d0,#WF_TOP
	rts
*--------------------------*
*--------------------------*
*--------------------------*
* L'offset dans les tableaux a ete empile avant le saut !
wd_gadget_form
	move.w		4(sp),d7
	cmp.w		#WM_CLOSED,tampon
	beq		closed
	cmp.w		#WM_MOVED,tampon
	beq		moved
	cmp.w		#WM_SIZED,tampon
	beq		moved
	rts
moved
	move.w		tampon+8,int_in+4	; on dit au gem de d‚placer sa fenetre
	move.w		tampon+10,int_in+6
	move.w		tampon+12,int_in+8
	move.w		tampon+14,int_in+10
	wind_set2	tampon+6,#5
	rts
closed
	get_tab		#tab_adr,d7	; place une donnee dans le tableau
	wd_close	d0
	rts
*--------------------------*
*--------------------------*
*--------------------------*
* De d4 a d7 on trouve les coordonnees du rectagle a redissinner, au format AES.
* D3 est l'offset dans les tableaux.
* a6 pointe vers une structure du type suivant, donnant les coordonnees de surface
*           de travail de la fenetre au format VDI et AES :
* 0(a6)->X , 2(a6)->Y , 4(a6)->X2 , 6(a6)->Y2 , 8(a6)->W , 10(a6)->H
wd_redraw_form
* Place les coordonnees dans le formulaire racine
	movem.l		d1-d7,-(sp)
	move.l		FILEBROWS_adr,a5
	move.w		(a6),ob_x(a5)
	move.w		2(a6),ob_y(a5)
	move.w		8(a6),ob_w(a5)
	move.w		10(a6),ob_h(a5)

	trouve_objc	a5,#BROWS_TOP
	move.w		8(a6),ob_w(a0)
	move.w		ob_h(a0),d2

	trouve_objc	a5,#BROWS_BOTTOM
	move.w		8(a6),ob_w(a0)
	move.w		10(a6),d0
	sub.w		d2,d0
	move.w		d0,ob_h(a0)

	trouve_objc	a5,#BROWS_PIX
	move.w		8(a6),ob_w(a0)
	move.w		10(a6),ob_h(a0)

	trouve_objc	a5,#BROWS_BOUND
	move.w		8(a6),ob_w(a0)
	move.w		10(a6),ob_h(a0)
	move.l		ob_spec(a0),a4

* Fait pointer le G_BOUNDING sur le G_BOUNDED
	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a0			; correspondante a la surface de travail de la fenetre

	move.l		fb_ptr(a0),a1
	move.l		a1,gbo_tree(a4)
	move.w		8(a6),ob_w(a1)
	move.w		10(a6),ob_h(a1)

* Insere les bons etat des flags d'affichage
	move.w		fb_state(a0),d7
	trouve_objc	a5,#FBRO_ICTXT
	btst		#FB_ICON,d7
	beq		.en_text
	bclr		#SELECTED,ob_states+1(a0)
	bra		.ok_ictxt
.en_text
	bset		#SELECTED,ob_states+1(a0)
.ok_ictxt

	trouve_objc	a5,#FBRO_SIZE
	btst		#FB_SIZE,d7
	bne		.aff_size
	bclr		#SELECTED,ob_states+1(a0)
	bra		.ok_size
.aff_size
	bset		#SELECTED,ob_states+1(a0)
.ok_size

	trouve_objc	a5,#FBRO_DATE
	btst		#FB_DATE,d7
	bne		.aff_date
	bclr		#SELECTED,ob_states+1(a0)
	bra		.ok_date
.aff_date
	bset		#SELECTED,ob_states+1(a0)
.ok_date

	trouve_objc	a5,#FBRO_TIME
	btst		#FB_TIME,d7
	bne		.aff_time
	bclr		#SELECTED,ob_states+1(a0)
	bra		.ok_time
.aff_time
	bset		#SELECTED,ob_states+1(a0)
.ok_time

	trouve_objc	a5,#FBRO_ATTRB
	btst		#FB_ATRB,d7
	bne		.aff_attrb
	bclr		#SELECTED,ob_states+1(a0)
	bra		.ok_attrb
.aff_attrb
	bset		#SELECTED,ob_states+1(a0)
.ok_attrb

	movem.l		(sp)+,d1-d7
* Dessine enfin le formulaire
	objc_draw	a5,#0,#20,d4,d5,d6,d7
	rts
