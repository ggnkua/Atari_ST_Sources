SIZE_TEXT	equ	24	; represente le nombre de pixels entre chaque objet

	include	structs.s
	include	zlib.i
	include	aes.i
	include	vdi.i
	include	gemdos.i
	include	util.i

	include	..\fashion.s

	XREF	x_mouse_clik,y_mouse_clik,x_max

	XREF	ed_sel_win
	XREF	ed_sel_objc
	XREF	tab_adr
	XREF	FNT_LIST_adr

	XREF	contrl

	XDEF	tedinfo_window
	XDEF	reinit_tedinfo_window
	XDEF	make_fonte_list

tedinfo_window
	move.l	ed_sel_win,a5
	lea	ed_sel_objc,a6
	move.l	d0,a4

	move.w		d1,d7
	objc_find	d0,#0,#20,x_mouse_clik,y_mouse_clik
	move.l		addr_out,d0
	cmp.l		FNT_LIST_adr,d0
	beq		set_fontid
	move.w		d7,d1

	cmp.w	#TED_GAUCHE,d1
	beq	justification_gauche
	cmp.w	#TED_DROITE,d1
	beq	justification_droite
	cmp.w	#TED_CENTRE,d1
	beq	justification_centre
	cmp.w	#TED_JUSTIF,d1
	beq	justification_justif
	cmp.w	#TED_SLIDE,d1
	beq	slide_font_list
	cmp.w	#TED_GRAS,d1
	beq	set_gras
	cmp.w	#TED_LIGHT,d1
	beq	set_light
	cmp.w	#TED_ITALIC,d1
	beq	set_italic
	cmp.w	#TED_SOULIGNE,d1
	beq	set_souligne
	cmp.w	#TED_DETOURE,d1
	beq	set_detoure
	cmp.w	#TED_OMBRE,d1
	beq	set_ombre
	cmp.w	#TED_PETIT,d1
	beq	set_petit
	cmp.w	#TED_MOYEN,d1
	beq	set_moyen
	cmp.w	#TED_GRAND,d1
	beq	set_grand
	cmp.w	#TED_GDOS,d1
	beq	set_gdos
	cmp.w	#TED_FONTLIST,d1
	beq	set_fontid
	cmp.w	#TED_SIZE,d1
	beq	set_fontsize
	cmp.w	#TED_UP,d1
	beq	slide_up
	cmp.w	#TED_DOWN,d1
	beq	slide_down
	cmp.w	#TED_SLIDEBOX,d1
	beq	slide_box
	rts
*--------------------------------------------------------------------------------------------------------------------------*
slide_up
	xobjc_change	d0,d1

	move.l		FNT_LIST_adr,a6
	move.w		ob_y(a6),d7
	add.w		#SIZE_TEXT,d7
	bmi		.not_to_up
	moveq.l		#0,d7
.not_to_up
	move.w		d7,ob_y(a6)

	rsrc_gaddr	#0,#TEDINFO_EDIT
	redraw_objc_gem	addr_out,#TED_FONTLIST

	trouve_objc	addr_out,#TED_FONTLIST
	move.l		a0,a5
	trouve_objc	addr_out,#TED_SLIDEBOX
	move.l		a0,a4
	trouve_objc	addr_out,#TED_SLIDE
	move.l		a0,a3

	move.w		ob_h(a6),d5
	sub.w		ob_h(a5),d5	; hauteur non affiche
	beq		.zero

	move.w		ob_y(a3),d4
	sub.w		ob_y(a6),d4
	mulu.w		ob_h(a4),d4
	divu.w		d5,d4
	bra		.suite
.zero
	moveq.l		#0,d4
.suite

	move.w		ob_h(a4),d5
	sub.w		ob_h(a3),d5
	cmp.w		d4,d5
	bge		.not_tomuch_down
	move.w		d5,d4
.not_tomuch_down

	move.w		d4,ob_y(a3)
	redraw_objc_gem	addr_out,#TED_SLIDEBOX
	evnt_timer	#20
	rts
*--------------------------------------------------------------------------------------------------------------------------*
slide_down
	xobjc_change	d0,d1

	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_FONTLIST

	move.l		FNT_LIST_adr,a6
	move.w		ob_h(a6),d6
	sub.w		ob_h(a0),d6
	neg		d6

	move.w		ob_y(a6),d7
	sub.w		#SIZE_TEXT,d7
	cmp.w		d7,d6
	ble		.not_to_down
	move.w		d6,d7
.not_to_down
	move.w		d7,ob_y(a6)

	redraw_objc_gem	addr_out,#TED_FONTLIST

	trouve_objc	addr_out,#TED_FONTLIST
	move.l		a0,a5
	trouve_objc	addr_out,#TED_SLIDEBOX
	move.l		a0,a4
	trouve_objc	addr_out,#TED_SLIDE
	move.l		a0,a3

	move.w		ob_h(a6),d5
	sub.w		ob_h(a5),d5	; hauteur non affiche
	beq		.zero

	move.w		ob_y(a3),d4
	sub.w		ob_y(a6),d4
	mulu.w		ob_h(a4),d4
	divu.w		d5,d4
	bra		.suite
.zero
	moveq.l		#0,d4
.suite
	move.w		ob_h(a4),d5
	sub.w		ob_h(a3),d5
	cmp.w		d4,d5
	bge		.not_tomuch_down
	move.w		d5,d4
.not_tomuch_down

	move.w		d4,ob_y(a3)
	redraw_objc_gem	addr_out,#TED_SLIDEBOX
	evnt_timer	#20
	rts
*--------------------------------------------------------------------------------------------------------------------------*
slide_box
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_fontsize
	rsrc_gaddr	#0,#POPUP
	move.l		addr_out,a3
	popup		a4,#TED_SIZE,a3,#POPUP_FNTSIZE
	move.w		d0,d7

* Converti la chaine en un long
	give_txt_adr	a3,d7
	move.l		a0,a3
	lea		temp_numeric_string,a2
	cmp.b		#" ",(a3)
	beq		.deux_chiffres
	move.b		(a3)+,(a2)+
	move.b		(a3)+,(a2)+
	move.b		(a3)+,(a2)+
	clr.b		(a2)+
	bra		.ok_cp
.deux_chiffres
	addq.l		#1,a3
	move.b		(a3)+,(a2)+
	move.b		(a3)+,(a2)+
	clr.b		(a2)+
.ok_cp
	chaine_2_long	#temp_numeric_string
	move.l		d0,d7

.lp_setfontsize
	move.w	(a6)+,d6
	trouve_objc	a5,d6
	move.b		ob_type+1(a0),d0
	cmp.b		#G_TEXT,d0
	bra		.do_size
	cmp.b		#G_BOXTEXT,d0
	bra		.do_size
	cmp.b		#G_FTEXT,d0
	bra		.do_size
	cmp.b		#G_FBOXTEXT,d0
	bne		.size_done
.do_size
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect

	move.w		d7,te_fontsize(a1)

	redraw_objc_gem	a5,d6

.size_done
	cmp.w	#-1,(a6)
	bne	.lp_setfontsize
	rts
	bss
temp_numeric_string	ds.b	8
	text
*--------------------------------------------------------------------------------------------------------------------------*
set_fontid
* Trouve l'objet clike et la fonte qu'il utilise
	move.l		FNT_LIST_adr,a3
	trouve_objc	a3,int_out
	move.l		ob_spec(a0),a0
	move.w		te_fontid(a0),d6
	move.w		te_font(a0),d5

.set_fontid_loop
	move.w		(a6)+,d7
	trouve_objc	a5,d7
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tefontid
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tefontid
	cmp.w		#G_TEXT,d0
	beq		.ok_tefontid
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tefontid
	bra		.end_tefontid
.ok_tefontid
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	move.w		d6,te_fontid(a1)
	move.w		d5,te_font(a1)
	redraw_objc_gem	a5,d7
.end_tefontid
	cmp.w		#-1,(a6)
	bne		.set_fontid_loop
	rsrc_gaddr	#0,#TEDINFO_EDIT
	redraw_objc_gem	addr_out,#TED_FONTLIST
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_petit
.loop_tefont
	move.w		(a6)+,d7
	trouve_objc	a5,d7
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_TEXT,d0
	beq		.ok_tefont
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tefont
	bra		.end_tefont
.ok_tefont
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	move.w		#5,te_font(a1)
	redraw_objc_gem	a5,d7
.end_tefont
	cmp.w		#-1,(a6)
	bne		.loop_tefont
	bsr		grise_fontlist
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SIZE
	bset		#DISABLED,ob_states+1(a0)
	redraw_objc_gem	addr_out,#TED_SIZE
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_moyen
.loop_tefont
	move.w		(a6)+,d7
	trouve_objc	a5,d7
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_TEXT,d0
	beq		.ok_tefont
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tefont
	bra		.end_tefont
.ok_tefont
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	move.w		#4,te_font(a1)
	redraw_objc_gem	a5,d7
.end_tefont
	cmp.w		#-1,(a6)
	bne		.loop_tefont
	bsr		grise_fontlist
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SIZE
	bset		#DISABLED,ob_states+1(a0)
	redraw_objc_gem	addr_out,#TED_SIZE
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_grand
.loop_tefont
	move.w		(a6)+,d7
	trouve_objc	a5,d7
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_TEXT,d0
	beq		.ok_tefont
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tefont
	bra		.end_tefont
.ok_tefont
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	move.w		#3,te_font(a1)
	redraw_objc_gem	a5,d7
.end_tefont
	cmp.w		#-1,(a6)
	bne		.loop_tefont
	bsr		grise_fontlist
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SIZE
	bset		#DISABLED,ob_states+1(a0)
	redraw_objc_gem	addr_out,#TED_SIZE
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_gdos
.loop_tefont
	move.w		(a6)+,d7
	trouve_objc	a5,d7
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tefont
	cmp.w		#G_TEXT,d0
	beq		.ok_tefont
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tefont
	bra		.end_tefont
.ok_tefont
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	move.w		te_font(a1),d0
	cmp.w		#3,d0
	blt		.end_tefont
	move.w		#2,te_font(a1)
	move.w		#1,te_fontid(a1)
	move.w		#10,te_fontsize(a1)

	XREF		update_fontlist_rout
	move.w		#1,-(sp)
	jsr		update_fontlist_rout
	addq.l		#2,sp
	redraw_objc_gem	a5,d7

	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SIZE
	bclr		#DISABLED,ob_states+1(a0)

.end_tefont
	cmp.w		#-1,(a6)
	bne		.loop_tefont
	rsrc_gaddr	#0,#TEDINFO_EDIT
	find_tab_l	#tab_adr,addr_out
	wd_redraw_gem	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_gras
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_THICKENED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_THICKENED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_light
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_LIGHT,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_LIGHT,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_italic
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_SKEWED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_SKEWED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_souligne
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_UNDERLINE,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_UNDERLINE,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_detoure
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_OUTLINED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_OUTLINED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
set_ombre
	trouve_objc	a4,d1
	btst		#SELECTED,ob_states+1(a0)
	beq		.donot_set

.set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bset		#TE_SHADOWED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.set
	rts
.donot_set
	move.w		(a6)+,d7
	redraw_objc_gem	a5,d7
	trouve_objc	a5,d7
	move.l		ob_spec(a0),a0
	bclr		#TE_SHADOWED,te_just+1(a0)
	cmp.w		#-1,(a6)
	bne		.donot_set
	rts
*--------------------------------------------------------------------------------------------------------------------------*
justification_gauche
.loop_justif
	trouve_objc	a5,(a6)+
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_TEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tedinfo
	bra		.end_justif
.ok_tedinfo
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	and.w		#$fffc,te_just(a1)
.end_justif
	cmp.w		#-1,(a6)
	bne		.loop_justif
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
justification_droite
.loop_justif
	trouve_objc	a5,(a6)+
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_TEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tedinfo
	bra		.end_justif
.ok_tedinfo
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	and.w		#$fffc,te_just(a1)
	or.w		#1,te_just(a1)
.end_justif
	cmp.w		#-1,(a6)
	bne		.loop_justif
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
justification_centre
.loop_justif
	trouve_objc	a5,(a6)+
	clr.w		d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_TEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tedinfo
	bra		.end_justif
.ok_tedinfo
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	and.w		#$fffc,te_just(a1)
	or.w		#%10,te_just(a1)
.end_justif
	cmp.w		#-1,(a6)
	bne		.loop_justif
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
justification_justif
.loop_justif
	trouve_objc	a5,(a6)+
	clr.w		d0
	move.b		ob_type+1(a0),d0
	cmp.w		#G_FTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_FBOXTEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_TEXT,d0
	beq		.ok_tedinfo
	cmp.w		#G_BOXTEXT,d0
	beq		.ok_tedinfo
	bra		.end_justif
.ok_tedinfo
	move.l		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.not_indirect
	move.l		(a1),a1
.not_indirect
	and.w		#$fffc,te_just(a1)
	or.w		#%11,te_just(a1)
.end_justif
	cmp.w		#-1,(a6)
	bne		.loop_justif
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
slide_font_list
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SLIDEBOX
	moveq.l		#0,d7
	move.w		ob_h(a0),d7
	trouve_objc	addr_out,#TED_SLIDE
	sub.w		ob_h(a0),d7		; Valeur maxi de ob_y du slider

	objc_offset	addr_out,#TED_SLIDE
	move.w		y_mouse_clik,d6		; deplacement de la souris par raport au 0 de l'objet
	sub.w		int_out+4,d6		; avant le debut de la boucle

	objc_offset	addr_out,#TED_SLIDEBOX
	move.w		int_out+4,d3		; position en Y du SLIDEBOX englobant

;	graf_mouse	#M_OFF

.slide_evnt_multi
* on attend les boutons de la sourie ou un deplacement (vertical uniquement)...
	evnt_multi	#4+2,#1,#1,#0,#1,#0,y_mouse_clik,x_max,#1

	btst		#1,d0
	bne		.mouse_released
	btst		#2,d0
	bne		.mouse_moved
	bra		.slide_evnt_multi

.mouse_moved

* Calcul de la position du slider en fonction du deplacement de la sourie
	move.w		int_out+4,d5
	move.w		d5,y_mouse_clik
	sub.w		d6,d5			; d5 = Y sourie - ofset par raport au 0 du slider
	sub.w		d3,d5			; d5 = position slidebox - d5

* Butes haute et basse du slider
	bge		.pas_trop_haut
	move.w		#0,d5
.pas_trop_haut
	cmp.w		d7,d5
	ble		.pas_trop_bas
	move.w		d7,d5
.pas_trop_bas					; on a maintenant d5 = position du slider

	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SLIDE
	move.w		d5,ob_y(a0)
	redraw_objc	addr_out,#TED_SLIDEBOX

	trouve_objc	addr_out,#TED_FONTLIST
	move.w		ob_h(a0),d2			; d2 = taille G_BOUNING

	move.l		FNT_LIST_adr,a1
	move.w		ob_h(a1),d4			; d4 = hauteur non affichee du G_BOUNDED
	sub.w		d2,d4

; ob_y du g_bounded = - (( position slider * hauteur du G_BOUNDED ) / debatement)

	move.w		d5,d1
	mulu.w		d4,d1

	trouve_objc	addr_out,#TED_SLIDEBOX
	move.w		ob_h(a0),d2

	trouve_objc	addr_out,#TED_SLIDE
	sub.w		ob_h(a0),d2

	divu.w		d2,d1

	neg.w		d1
	move.w		d1,ob_y(a1)
	redraw_objc	addr_out,#TED_FONTLIST
	bra		.slide_evnt_multi

.mouse_released
;	graf_mouse	#M_ON
	rsrc_gaddr	#0,#TEDINFO_EDIT
	xobjc_change	addr_out,#TED_SLIDE
	rts
*--------------------------------------------------------------------------------------------------------------------------*
* Creation de la liste de fontes
make_fonte_list
	vst_load_fonts
	moveq.l		#0,d7
	move.w		intout,d7	; nombre de fonte presentes en memeoire

	tst.w		d7
	bne		.yadesfontes

	rts
.yadesfontes
* On demande un bloc memoire pour acceuillir l'arbre contenant la liste de fontes
	move.l		d7,d6
	addq.l		#1,d6	; nombre de fontes + l'objet racine
	mulu.l		#24,d6	; * taille d'un objet
	Malloc		d6
	move.l		d0,FNT_LIST_adr	; adresse de la "fenetre FNT_LIST"
	move.l		d0,a4

* Remplissage de la G_BOUNDED racine
	move.l		#$ffff0001,(a4)
	move.w		d7,ob_tail(a4)
	move.w		#G_BOUNDED,ob_type(a4)
	move.l		#0,ob_flags(a4)
	move.l		#font_bounded,ob_spec(a4)
	move.w		#0,ob_x(a4)
	move.w		#0,ob_y(a4)

* Transformation du g_box en g_bounding
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_FONTLIST
	move.w		#G_BOUNDING,ob_type(a0)
	move.l		#font_bounding,ob_spec(a0)

* Largeur de la boite racine
	move.l		a0,a3
	move.w		ob_w(a3),d6	; largeur de la boite
	move.w		d6,ob_w(a4)
	move.w		d7,d0
	mulu.w		#SIZE_TEXT,d0
	move.w		d0,ob_h(a4)

* Mise a jours des infos gbo/gbd
	lea		font_bounded,a2
	move.l		addr_out,gbd_tree(a2)
	move.w		#TED_FONTLIST,gbd_index(a2)
	move.w		#0,gbd_flags(a2)

	lea		font_bounding,a2
	move.l		a4,gbo_tree(a2)
	move.w		#0,gbo_first(a2)
	move.w		#2,gbo_depth(a2)

* Ajout d'un objet par fonte
	moveq.l		#1,d4
	moveq.l		#0,d3
make_font_list_loop
	lea		24(a4),a4	; nouvel objet
	vqt_name	d4		; nom a placer dedant et id de la fonte (respectivement intout[1..n] et intou[0])
	addq.l		#1,d4		; numero du prochain objet = numero de la fonte +1 (bidouille)

* Remplissage d'un objet G_TEXT (ajoute a la fin de l'arbre)
	move.w		d4,ob_next(a4)
	move.l		#-1,ob_head(a4)
	move.w		#G_TEXT,ob_type(a4)
	move.w		#$11,ob_flags(a4)
	move.w		#$8,ob_states(a4)
	Malloc		#te_struc_size
	move.l		d0,ob_spec(a4)
	move.l		d0,a3		; adresse de la tedinfo (routine suivante)
	move.w		#0,ob_x(a4)
	move.w		d3,ob_y(a4)
	add.w		#SIZE_TEXT,d3
	move.w		d6,ob_w(a4)
	move.w		#SIZE_TEXT,ob_h(a4)

* Remplissage de la tedinfo du nouvel objet G_TEXT (au nom et a la forme de la fonte en question)
	move.w		#32,te_txtlen(a3)

	Malloc		#32
	move.l		d0,te_ptext(a3)

* Update du te_font en fonction du type de la fonte choisie
	cmp.w		#33,contrl
	bne		.peutetre_vectoriel
	move.w		#2,te_font(a3)		; bitmap
	bra		.tefont_is_ok

.peutetre_vectoriel
	tst		intout+66
	bne		.fontvectoriel_trouve
	move.w		#2,te_font(a3)		; bitmap
	bra		.tefont_is_ok

.fontvectoriel_trouve
	btst		#0,intout+67
	beq		.font_proportionnel
	move.w		#1,te_font(a3)		; monospace vectoriel
	bra		.tefont_is_ok

.font_proportionnel
	move.w		#0,te_font(a3)		; proportionel vectoriel

.tefont_is_ok

* Update du reste de la tedinfo
	move.w		intout,te_fontid(a3)
	move.w		#12,te_fontsize(a3)
	move.w		#$100,te_color(a3)
	clr.w		te_just(a3)
	clr.w		te_thickness(a3)

	moveq.l		#30,d1
	lea		intout+2,a1
	move.l		(a3),a0
.loop_cp_name
	move.w		(a1)+,d0
	move.b		d0,(a0)+
	dbf		d1,.loop_cp_name
	move.b		#0,(a1)+

	subq.l		#1,d7
	bne		make_font_list_loop
* On arrive au dernier objet, on doit updater son ob_next differament
	bset		#LASTOB,ob_flags+1(a4)
	move.w		#0,ob_next(a4)

* Calcul de la taille du slider
* hauteur slider = (slidebox * G_BOUNDING) / G_BOUNDED
	rsrc_gaddr	#0,#TEDINFO_EDIT

	trouve_objc	addr_out,#TED_FONTLIST
	move.w		ob_h(a0),d7
	trouve_objc	addr_out,#TED_SLIDEBOX
	move.w		ob_h(a0),d6
	mulu.w		d7,d6

	move.l		FNT_LIST_adr,a1
	divu.w		ob_h(a1),d6

	cmp.w		#6,d6
	bge		.suiteA			; Un minimum, tout de meme !
	move.w		#6,d6
.suiteA

	trouve_objc	addr_out,#TED_SLIDE
	move.w		d6,ob_h(a0)		; hauteur slider = d6
	rts
	bss
font_bounded	ds.b	sizeof_gbo	; un couple de g_bounding/g_bounded
font_bounding	ds.B	sizeof_gbd
	text
*--------------------------------------------------------------------------------------------------------------------------*
reinit_tedinfo_window
	movem.l		d1-a6,-(sp)
	rsrc_gaddr	#0,#TEDINFO_EDIT
	move.l		addr_out,a6

	trouve_objc	a6,#TED_PETIT
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_MOYEN
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_GRAND
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_GDOS
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_SIZE
	bset		#DISABLED,ob_states+1(a0)

	trouve_objc	a6,#TED_GAUCHE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_DROITE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_CENTRE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_JUSTIF
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)

	trouve_objc	a6,#TED_GRAS
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	trouve_objc	a6,#TED_LIGHT
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	trouve_objc	a6,#TED_SOULIGNE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	trouve_objc	a6,#TED_DETOURE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	trouve_objc	a6,#TED_ITALIC
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	trouve_objc	a6,#TED_OMBRE
	bset		#DISABLED,ob_states+1(a0)
	bclr		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)

	bsr		grise_fontlist

	find_tab_l	#tab_adr,a6
	cmp.w		#-1,d0
	beq		.no_redraw
	wd_redraw_gem	d0
.no_redraw
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
grise_fontlist
	move.l		FNT_LIST_adr,a0
.lp_reinit_fntlist
	lea		24(a0),a0
	bclr		#SELECTED,ob_states+1(a0)
	bset		#DISABLED,ob_states+1(a0)
	btst		#LASTOB,ob_flags+1(a0)
	beq		.lp_reinit_fntlist

	rsrc_gaddr	#0,#TEDINFO_EDIT
	redraw_objc_gem	addr_out,#TED_FONTLIST
	rts