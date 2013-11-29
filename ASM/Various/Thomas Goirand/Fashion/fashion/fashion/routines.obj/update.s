	include	structs.s
	include	zlib.i
	include	aes.i

	include	..\fashion.s

	XDEF		update_fontlist_rout
	XREF		FNT_LIST_adr
update_fontlist_rout	; te_fontid
	movem.l		d1-a6,-(sp)
	move.w		60+0(sp),d7

	move.l		FNT_LIST_adr,a6
	move.l		a6,a5

.lp_search_fnt
	lea		24(a5),a5
	move.l		ob_spec(a5),a4
	cmp.w		te_fontid(a4),d7
	beq		.trouved
	btst		#LASTOB,ob_states+1(a5)
	beq		.lp_search_fnt


	movem.l		(sp)+,d1-a6
	rts

.trouved
	btst		#DISABLED,ob_states+1(a5)
	beq		.ok
	bsr		ungrise
.ok	bset		#SELECTED,ob_states+1(a5)
	movem.l		(sp)+,d1-a6
	rts

ungrise	move.l		a6,a3

.loop	lea		24(a3),a3
	bclr		#DISABLED,ob_states+1(a3)
	btst		#LASTOB,ob_flags+1(a3)
	beq		.loop
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_font_size_rout
update_font_size_rout
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_SIZE
	bclr		#DISABLED,ob_states+1(a0)
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_color_txt_rout
update_color_txt_rout
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_TXT0
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.color_txt_not_disabled
	bsr		unable_color_txt_buttons
.color_txt_not_disabled
	add.w		#CW_TXT0,d7
	trouve_objc	a6,d7
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
unable_color_txt_buttons
	trouve_objc	a6,#CW_TXT0
	move.l		a0,a5
	trouve_objc	a6,#CW_TXT15
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_color_txt_button
	move.w		ob_states(a5),d0
	bclr		#DISABLED,d0
	move.w		d0,ob_states(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_color_txt_button
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		update_line_pos
update_line_pos
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,a6
	trouve_objc	a6,#LINE_POS000
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.line_pos_not_disabled
	bsr		.unable_line_pos_buttons
.line_pos_not_disabled
	add.w		#LINE_POS000,d7
	trouve_objc	a6,d7
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
.unable_line_pos_buttons
	trouve_objc	a6,#LINE_POS000
	move.l		a0,a5
	trouve_objc	a6,#LINE_POS111
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_line_pos
	bclr		#DISABLED,ob_states+1(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_line_pos
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		update_line_fill
update_line_fill
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,a6
	trouve_objc	a6,#LINE_MOTIF000
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.line_pos_not_disabled
	bsr		.unable_line_fill_buttons
.line_pos_not_disabled
	add.w		#LINE_MOTIF000,d7
	trouve_objc	a6,d7
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
.unable_line_fill_buttons
	trouve_objc	a6,#LINE_MOTIF001
	move.l		a0,a5
	trouve_objc	a6,#LINE_MOTIF110
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_line_pos
	bclr		#DISABLED,ob_states+1(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_line_pos
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_line_extrem_start
update_line_extrem_start
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,a6
	trouve_objc	a6,#LINE_DEB00
	btst		#DISABLED,ob_states+1(a0)
	beq		.line_exterm_not_disabled
	bsr		.unable_line_start_buttons
.line_exterm_not_disabled
	add.w		#LINE_DEB00,d7
	trouve_objc	a6,d7
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
.unable_line_start_buttons
	trouve_objc	a6,#LINE_DEB00
	move.l		a0,a5
	trouve_objc	a6,#LINE_DEB10
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_line_start
	bclr		#DISABLED,ob_states+1(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_line_start
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_line_extrem_end
update_line_extrem_end
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,a6
	trouve_objc	a6,#LINE_FIN00
	btst		#DISABLED,ob_states+1(a0)
	beq		.line_exterm_not_disabled
	bsr		.unable_line_end_buttons
.line_exterm_not_disabled
	add.w		#LINE_FIN00,d7
	trouve_objc	a6,d7
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
.unable_line_end_buttons
	trouve_objc	a6,#LINE_FIN00
	move.l		a0,a5
	trouve_objc	a6,#LINE_FIN10
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_line_end
	bclr		#DISABLED,ob_states+1(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_line_end
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_line_sens
update_line_sens
	movem.l		d1/d2/d6/d7/a0-a2/a4-a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#LINE_EDITOR
	move.l		addr_out,a6
	trouve_objc	a6,#LINE_SENS0
	btst		#DISABLED,ob_states+1(a0)
	beq		.line_sens_not_disabled
	bsr		.unable_sens_buttons
.line_sens_not_disabled
	add.w		#LINE_SENS0,d7
	trouve_objc	a6,d7
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4-a6
	rts
.unable_sens_buttons
	trouve_objc	a6,#LINE_SENS0
	move.l		a0,a5
	trouve_objc	a6,#LINE_SENS1
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_line_sens
	bclr		#DISABLED,ob_states+1(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_line_sens
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_color_cadre_rout
update_color_cadre_rout
	movem.l		d1/d2/d6/d7/a0-a2/a4/a5/a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_CADRE0
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.color_cadre_not_disabled
	bsr		unable_color_cadre_buttons
.color_cadre_not_disabled
	add.w		#CW_CADRE0,d7
	trouve_objc	a6,d7
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4/a5/a6
	rts

unable_color_cadre_buttons
	trouve_objc	a6,#CW_CADRE0
	move.l		a0,a5
	trouve_objc	a6,#CW_CADRE15
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_color_cadre_button
	move.w		ob_states(a5),d0
	bclr		#DISABLED,d0
	move.w		d0,ob_states(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_color_cadre_button
	rts

*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_color_surface_rout
update_color_surface_rout
	movem.l		d1/d2/d6/d7/a0-a2/a4/a5/a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_FOND0
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.color_surface_not_disabled
	bsr		unable_color_surface_buttons
.color_surface_not_disabled
	add.w		#CW_FOND0,d7
	trouve_objc	a6,d7
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4/a5/a6
	rts

unable_color_surface_buttons
	trouve_objc	a6,#CW_FOND0
	move.l		a0,a5
	trouve_objc	a6,#CW_FOND15
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_color_surface_button
	move.w		ob_states(a5),d0
	bclr		#DISABLED,d0
	move.w		d0,ob_states(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_color_surface_button
	rts

*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_color_trame_rout
update_color_trame_rout
	movem.l		d1/d2/d6/d7/a0-a2/a4/a5/a6,-(sp)
	move.w		44(sp),d7
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_TRAME0
	move.l		a0,a5
	move.w		ob_states(a5),d6
	btst		#DISABLED,d6
	beq		.color_trame_not_disabled
	bsr		unable_color_trame_buttons
.color_trame_not_disabled
	add.w		#CW_TRAME0,d7
	trouve_objc	a6,d7
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)
	movem.l		(sp)+,d1/d2/d6/d7/a0-a2/a4/a5/a6
	rts

unable_color_trame_buttons
	trouve_objc	a6,#CW_TRAME0
	move.l		a0,a5
	trouve_objc	a6,#CW_TRAME7
	move.l		a0,a4
	add.l		#24,a4
.boucle_unable_color_trame_button
	move.w		ob_states(a5),d0
	bclr		#DISABLED,d0
	move.w		d0,ob_states(a5)
	add.l		#24,a5
	cmp.l		a5,a4
	bne		.boucle_unable_color_trame_button
	rts

*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_opacite_rout
update_opacite_rout
	movem.l		d0-d2/d6/d7/a0-a2/a6,-(sp)
	move.w		40(sp),d7
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_OPAQUE
	move.w		ob_states(a0),d6
	btst		#DISABLED,d6
	bne		.first_update
	tst.w		d7
	beq		.source_not_opaque

	btst		#SELECTED,d6
	bne		.end_update_opacite
	bset		#SELECTED,d6
	move.w		d6,ob_states(a0)
	move.l		ob_spec(a0),a0
	move.w		#%1000000000,te_color(a0)
	bra		.end_update_opacite

.source_not_opaque
	btst		#SELECTED,d6
	beq		.end_update_opacite
;* Le parametre et l'objet on des etats different : on passe donc le texte en rouge
	bset		#SELECTED,d6
	move.w		d6,ob_states(a0)
	move.l		ob_spec(a0),a0
	move.w		#%1000000000,te_color(a0)

.end_update_opacite
	movem.l		(sp)+,d0-d2/d6/d7/a0-a2/a6
	rts

.first_update
	bclr		#DISABLED,d6
	tst.w		d7
	beq		.not_opaque_lobjet
	bset		#SELECTED,d6
.not_opaque_lobjet
	move.w		d6,ob_states(a0)
	bra		.end_update_opacite
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_taille_cadre_rout
update_taille_cadre_rout			; ! Le popup doit etre tie dans l'ordre !
	movem.l		d0-d2/d7/a0-a6,-(sp)
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	trouve_objc	addr_out,#CW_PLUS
	bclr		#DISABLED,ob_states+1(a0)
	trouve_objc	addr_out,#CW_MOINS
	bclr		#DISABLED,ob_states+1(a0)
	movem.l		(sp)+,d0-d2/d7/a0-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	update_obj_justif_rout
update_obj_justif_rout
	movem.l		d0-d2/d7/a0-a2,-(sp)
	move.w		32(sp),d7
	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_GAUCHE
	bclr		#DISABLED,ob_states+1(a0)
	cmp.w		#0,d7
	bne		.pas_gauche
	bset		#SELECTED,ob_states+1(a0)
.pas_gauche
	trouve_objc	addr_out,#TED_CENTRE
	bclr		#DISABLED,ob_states+1(a0)
	cmp.w		#2,d7
	bne		.pas_centre
	bset		#SELECTED,ob_states+1(a0)
.pas_centre
	trouve_objc	addr_out,#TED_DROITE
	bclr		#DISABLED,ob_states+1(a0)
	cmp.w		#1,d7
	bne		.pas_droite
	bset		#SELECTED,ob_states+1(a0)
.pas_droite
	trouve_objc	addr_out,#TED_JUSTIF
	bclr		#DISABLED,ob_states+1(a0)
	cmp.w		#3,d7
	bne		.pas_justif
	bset		#SELECTED,ob_states+1(a0)
.pas_justif

	movem.l		(sp)+,d0-d2/d7/a0-a2
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		update_bit_obj_rout
update_bit_obj_rout	; valeur_bit_source,adresse_arbre,index_objet
	movem.l		d1-a6,-(sp)
	move.w		60+6(sp),d7
	move.l		60+2(sp),a6
	move.w		60+0(sp),d5

	trouve_objc	a6,d5
	btst		#DISABLED,ob_states+1(a0)
	bne		.first_update

	btst		#SELECTED,ob_states+1(a0)
	beq		.not_selected

	tst		d7
	bne		.pareil
	bra		.different
.not_selected
	tst		d7
	beq		.pareil
.different
	bset		#SELECTED,ob_states+1(a0)
	move.l		ob_spec(a0),a1
	move.w		#%1000000000,te_color(a1)

.pareil
	movem.l		(sp)+,d1-a6
	rts
.first_update
	bclr		#DISABLED,ob_states+1(a0)
	tst.w		d7
	beq		.do_not_set
	bset		#SELECTED,ob_states+1(a0)
.do_not_set
	movem.l		(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF		update_te_font_rout
update_te_font_rout	; valeur_te_font
	movem.l		d1-a6,-(sp)
	move.w		60+0(sp),d7

	rsrc_gaddr	#0,#TEDINFO_EDIT
	trouve_objc	addr_out,#TED_PETIT
	btst		#DISABLED,ob_states+1(a0)
	beq		.donot_degrise
	bsr		.degrise_le
.donot_degrise
	
	cmp.w		#5,d7
	beq		.petit
	cmp.w		#4,d7
	beq		.moyen
	cmp.w		#3,d7
	beq		.grand

	trouve_objc	addr_out,#TED_GDOS
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1-a6
	rts

.petit
	trouve_objc	addr_out,#TED_PETIT
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1-a6
	rts
.moyen
	trouve_objc	addr_out,#TED_MOYEN
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1-a6
	rts

.grand
	trouve_objc	addr_out,#TED_GRAND
	bset		#SELECTED,ob_states+1(a0)
	movem.l		(sp)+,d1-a6
	rts

.degrise_le
	bclr		#DISABLED,ob_states+1(a0)
	trouve_objc	addr_out,#TED_MOYEN
	bclr		#DISABLED,ob_states+1(a0)
	trouve_objc	addr_out,#TED_GRAND
	bclr		#DISABLED,ob_states+1(a0)
	tst.l		FNT_LIST_adr
	beq		.nogdos
	trouve_objc	addr_out,#TED_GDOS
	bclr		#DISABLED,ob_states+1(a0)
.nogdos
	rts
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	reinit_color_window_rout
reinit_color_window_rout
	movem.l		d1-d7/a0-a6,-(sp)
	rsrc_gaddr	#0,#OBJC_COLOR_WORD
	move.l		addr_out,a6
	trouve_objc	a6,#CW_TXT15
	move.l		a0,a5
	add.l		#24,a5
	trouve_objc	a6,#CW_TXT0
.rinit_boucle0
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	cmp.l		a0,a5
	bne		.rinit_boucle0

	trouve_objc	a6,#CW_CADRE15
	move.l		a0,a5
	add.l		#24,a5
	trouve_objc	a6,#CW_CADRE0
.rinit_boucle1
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	cmp.l		a0,a5
	bne		.rinit_boucle1

	trouve_objc	a6,#CW_FOND15
	move.l		a0,a5
	add.l		#24,a5
	trouve_objc	a6,#CW_FOND0
.rinit_boucle2
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	cmp.l		a0,a5
	bne		.rinit_boucle2

	trouve_objc	a6,#CW_TRAME7
	move.l		a0,a5
	add.l		#24,a5
	trouve_objc	a6,#CW_TRAME0
.rinit_boucle3
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	bset		#DISABLED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	cmp.l		a0,a5
	bne		.rinit_boucle3

	trouve_objc	a6,#CW_OPAQUE
	move.w		ob_states(a0),d0
	bset		#DISABLED,d0
	bclr		#SELECTED,d0
	move.w		d0,ob_states(a0)
	move.l		ob_spec(a0),a0
	move.w		#%100000000,te_color(a0)	; texte en noire

	trouve_objc	a6,#CW_PLUS
	move.w		ob_states(a0),d0
	bset		#DISABLED,d0
	bclr		#SELECTED,d0
	move.w		d0,ob_states(a0)

	trouve_objc	a6,#CW_MOINS
	move.w		ob_states(a0),d0
	bset		#DISABLED,d0
	bclr		#SELECTED,d0
	move.w		d0,ob_states(a0)

	movem.l		(sp)+,d1-d7/a0-a6
	rts


	rsrc_gaddr	#0,#FLAG
	move.l		addr_out,a6
	trouve_objc	a6,#FLAG_0
	move.l		a0,a5
	move.w		#15,d7
.rinit_flag
	move.w		ob_states(a5),d0
	bset		#DISABLED,d0
	bclr		#SELECTED,d0
	move.w		d0,ob_states(a5)
	move.l		ob_spec(a5),a0
	move.w		#%100000000,te_color(a0)	; texte en noire
	add.l		#24,a5
	dbra		d7,.rinit_flag

	trouve_objc	a6,#STATE_0
	move.l		a0,a5
	move.w		#15,d7
.rinit_state
	move.w		ob_states(a5),d0
	bset		#DISABLED,d0
	bclr		#SELECTED,d0
	move.w		d0,ob_states(a5)
	move.l		ob_spec(a5),a0
	move.w		#%100000000,te_color(a0)	; texte en noire
	add.l		#24,a5
	dbra		d7,.rinit_state

	movem.l		(sp)+,d1-d7/a0-a6
	rts

