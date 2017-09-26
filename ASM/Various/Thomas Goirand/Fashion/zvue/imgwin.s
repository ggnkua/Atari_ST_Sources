*** Definition d'un formulaire en fenetre ***
	text
	include	aes.i
	include	vdi.i
	include	structs.s
	include	zlib.i
	include	d:\code\new\rsc.s

	XREF	x_mouse_clik,y_mouse_clik
	XREF	tampon,hauteur_menu,appl_name
	XREF	tab_x,tab_y,tab_w,tab_h,tab_type,tab_kind
	XREF	tab_rout,tab_clic,tab_adr,tab_handle,tab_name,tab_gadget,tab_key
	XREF	gem_exit
	XREF	contrl
*--------------------------*
*--------------------------*
*--------------------------*
	XDEF	wd_create_img
wd_create_img
	movem.l		d1-a6,-(sp)
	move.w		60(sp),d7		; l'offset dans les tableaux suffit !
	get_tab		#tab_adr,d7
	move.l		d0,a6			; l'adresse de l'image
	move.l		d0,a0
	XREF		load_image
	bsr		load_image
	move.l		a1,a6
	put_tab_l	#tab_adr,d7,a6	; mfdb de l'image

	wind_calc	#0,#%1011,#100,#100,#100,#100	; 6 / 8

;	put_tab_w	#tab_x,d7,int_out+4
;	put_tab_w	#tab_y,d7,int_out+4
	move.w		int_out+6,d5
	move.w		int_out+8,d6
	sub.w		#100,d5
	sub.w		#100,d6
	add.w		mfdb_w(a6),d5
	add.w		mfdb_h(a6),d6
	put_tab_w	#tab_w,d7,d5
	put_tab_w	#tab_h,d7,d6

	XREF		x_max
	move.w		x_max,d4
	sub.w		d5,d4
	lsr.w		#1,d4
	put_tab_w	#tab_x,d7,d4

	XREF		y_max
	move.w		y_max,d4
	sub.w		d6,d4
	lsr.w		#1,d4
	put_tab_w	#tab_y,d7,d4

	put_tab_l	#tab_name,d7,#appl_name		; ainsi que le pointeur sur le texte de la bare de d‚placement,
	put_tab_w	#tab_kind,d7,#%1011		; les attribues AES
	put_tab_l	#tab_rout,d7,#wd_redraw		; le pointeur sur la routine de redraw
	put_tab_l	#tab_gadget,d7,#wd_gadget	; le pointeur sur la routine de gadget et finalement
	put_tab_l	#tab_clic,d7,#wd_clic		; le pointeur sur la routine de clic
	put_tab_l	#tab_key,d7,#wd_key		; le pointeur sur la routine de key
	moveq.l		#0,d0
	movem.l		(sp)+,d1-a6
	rts
*--------------------------*
*--------------------------*
*--------------------------*
wd_key
	XREF		exit_prog
	bra		exit_prog

*--------------------------*
*--------------------------*
*--------------------------*
* Recois l'offset dans les tableau par la pile
wd_clic
	rts
*--------------------------*
*--------------------------*
*--------------------------*
* L'offset dans les tableaux a ete empile avant le saut !
wd_gadget
	move.w		4(sp),d7
	rts
*--------------------------*
*--------------------------*
*--------------------------*
* De d4 a d7 on trouve les coordonnees du rectagle a redissinner, au format AES.
* D3 est l'offset dans les tableaux.
* a6 pointe vers une structure du type suivant, donnant les coordonnees de surface
*           de travail de la fenetre au format VDI et AES :
* X, Y, X2, Y2, W, H
	XREF		screen_mfdb
wd_redraw
	get_tab		#tab_adr,d3		; on d‚place le formulaire a la coordonn‚e
	move.l		d0,a4			; correspondante a la surface de travail de la fenetre

* tableau de word X1, Y1, X2, Y2 pour la source et destination -> ptsin

	movem.l		d6-d7,-(sp)
	add.w		d4,d6		; transformation AES -> VDI
	add.w		d5,d7
	subq.w		#1,d6
	subq.w		#1,d7

	move.w		d4,ptsin+8		; Les coordonnes de la destination
	move.w		d5,ptsin+10
	move.w		d6,ptsin+12
	move.w		d7,ptsin+14
	movem.l		(sp)+,d6-d7

	sub.w		(a6),d4
	sub.w		2(a6),d5
	move.w		d4,ptsin	; source
	move.w		d5,ptsin+2
	add.w		d4,d6
	add.w		d5,d7
	subq.w		#1,d6
	subq.w		#1,d7
	move.w		d6,ptsin+4	; !!! coordonnes en X1 / X2, Y1 / Y2 (vdi rules)
	move.w		d7,ptsin+6

	vro_cpyfm	#3,a4,#screen_mfdb
;	objc_draw	a0,#0,#20,d4,d5,d6,d7
	rts
