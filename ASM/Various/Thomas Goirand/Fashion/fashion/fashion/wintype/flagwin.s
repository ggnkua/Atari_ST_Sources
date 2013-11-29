	include	aes.i
	include	structs.s
	include	zlib.i

	include	..\fashion.s

	XDEF	flag_window
	XDEF	reinit_flag_window

	XREF	FLAG_adr,tab_adr
	XREF	ed_sel_win,ed_sel_objc
flag_window
	move.l	d0,d7
	move.w	d1,d6
	cmp.w	#FLAG_0,d1
	blt	.pas_flag
	cmp.w	#FLAG_15,d1
	ble	bouton_de_flag
.pas_flag
	cmp.w	#STATE_0,d1
	blt	.pas_state
	cmp.w	#STATE_15,d1
	ble	bouton_de_state
.pas_state
	rts
*--------------------------------------------------------------------------------------------------------------------------*
bouton_de_flag
	trouve_objc	d7,d1
	move.l		ed_sel_win,a5
	lea		ed_sel_objc,a6
	sub.w		#FLAG_0,d1
	move.w		ob_states(a0),d0
	btst		#SELECTED,d0
	beq		deselection_flag
.boucle_selection_bit
	trouve_objc	a5,(a6)+
	move.w		ob_flags(a0),d0
	bset		d1,d0
	move.w		d0,ob_flags(a0)
	cmp.w		#-1,(a6)
	bne		.boucle_selection_bit
	bra		end_edit_flag

deselection_flag
	trouve_objc	a5,(a6)+
	move.w		ob_flags(a0),d0
	bclr		d1,d0
	move.w		d0,ob_flags(a0)
	cmp.w		#-1,(a6)
	bne		deselection_flag
end_edit_flag
	trouve_objc	d7,d6
	move.l		ob_spec(a0),a0
	move.w		#%0000000100000000,te_color(a0)	; texte en noire
	redraw_objc	d7,d6
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
bouton_de_state
	trouve_objc	d7,d1
	move.l		ed_sel_win,a5
	lea		ed_sel_objc,a6
	sub.w		#STATE_0,d1
	move.w		ob_states(a0),d0
	btst		#SELECTED,d0
	beq		deselection_state
.boucle_selection_bit
	trouve_objc	a5,(a6)+
	move.w		ob_states(a0),d0
	bset		d1,d0
	move.w		d0,ob_states(a0)
	cmp.w		#-1,(a6)
	bne		.boucle_selection_bit
	bra		end_edit_state

deselection_state
	trouve_objc	a5,(a6)+
	move.w		ob_states(a0),d0
	bclr		d1,d0
	move.w		d0,ob_states(a0)
	cmp.w		#-1,(a6)
	bne		deselection_state
end_edit_state
	trouve_objc	d7,d6
	move.l		ob_spec(a0),a0
	move.w		#%0000000100000000,te_color(a0)	; texte en noire
	redraw_objc	d7,d6
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts

*--------------------------------------------------------------------------------------------------------------------------*
reinit_flag_window
	movem.l		d0-d2/a0-a2,-(sp)
	rsrc_gaddr	#0,#FLAG
	move.l		addr_out,a2
	trouve_objc	a2,#FLAG_0

	move.w		#15,d0
.boucle_reinit_flags
	move.w		ob_states(a0),d1
	bclr		#SELECTED,d1
	bset		#DISABLED,d1
	move.w		d1,ob_states(a0)
	move.w		ob_spec(a0),a1
	move.w		#%0000000100000000,te_color(a1)	; texte en noire
	lea		24(a0),a0
	dbf		d0,.boucle_reinit_flags

	trouve_objc	a2,#STATE_0
	move.w		#15,d0
.boucle_reinit_states
	move.w		ob_states(a0),d1
	bclr		#SELECTED,d1
	bset		#DISABLED,d1
	move.w		d1,ob_states(a0)
	move.w		ob_spec(a0),a1
	move.w		#%0000000100000000,te_color(a1)	; texte en noire
	lea		24(a0),a0
	dbf		d0,.boucle_reinit_states
	movem.l		(sp)+,d0-d2/a0-a2
	rts