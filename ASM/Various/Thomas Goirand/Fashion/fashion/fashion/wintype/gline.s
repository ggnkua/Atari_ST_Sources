************************************
*** Fenetre d'edition des G_LINE ***
************************************

	include	structs.s
	include	zlib.i
	include	aes.i

	include	..\fashion.s

	XREF	ed_sel_win
	XREF	ed_sel_objc
	XREF	tab_adr
	XDEF	gline_window
gline_window
	move.w	d1,d7
	move.l	ed_sel_win,a5
	lea	ed_sel_objc,a6
	move.l	d0,a4
	cmp.w	#LINE_POS000,d1
	blt	.suite1
	cmp.w	#LINE_POS111,d1
	ble	edit_line_pos
.suite1
	cmp.w	#LINE_DEB00,d1
	blt	.suite2
	cmp.w	#LINE_DEB10,d1
	ble	edit_debut
.suite2
	cmp.w	#LINE_FIN00,d1
	blt	.suite3
	cmp.w	#LINE_FIN10,d1
	ble	edit_fin
.suite3
	cmp.w	#LINE_SENS0,d1
	blt	.suite4
	cmp.w	#LINE_SENS1,d1
	ble	edit_line_sens
.suite4
	cmp.w	#LINE_MOTIF000,d1
	blt	.suite5
	cmp.w	#LINE_MOTIF111,d1
	ble	edit_line_motif
.suite5
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
edit_line_motif
	trouve_objc	a5,(a6)
	move.l		a0,a4
	cmp.b		#G_LINE,ob_type+1(a4)
	bne		.not_g_line

	moveq.l		#0,d5
	move.w		d7,d5
	sub.w		#LINE_MOTIF000,d5

	bfins		d5,ob_spec(a0){25:3}	; place les 3 bits de poid faible de d5 dans les bits 26-24 de l'ob_spec (normalement)

	redraw_objc	a5,(a6)

.not_g_line
	addq.w		#2,a6
	cmp.w		#-1,(a6)
	bne		edit_line_sens
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
edit_line_sens
	trouve_objc	a5,(a6)
	move.l		a0,a4
	cmp.b		#G_LINE,ob_type+1(a4)
	bne		.not_g_line

	moveq.l		#0,d5
	move.w		d7,d5
	sub.w		#LINE_SENS0,d5

	bfins		d5,ob_spec(a0){0:1}	; place les 3 bits de poid faible de d5 dans les bits 26-24 de l'ob_spec (normalement)

	redraw_objc	a5,(a6)

.not_g_line
	addq.w		#2,a6
	cmp.w		#-1,(a6)
	bne		edit_line_sens
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
edit_line_pos
	trouve_objc	a5,(a6)
	move.l		a0,a4
	cmp.b		#G_LINE,ob_type+1(a4)
	bne		.not_g_line

	moveq.l		#0,d5
	move.w		d7,d5
	sub.w		#LINE_POS000,d5

	bfins		d5,ob_spec(a0){5:3}	; place les 3 bits de poid faible de d5 dans les bits 26-24 de l'ob_spec (normalement)

	redraw_objc	a5,(a6)

.not_g_line
	addq.w		#2,a6
	cmp.w		#-1,(a6)
	bne		edit_line_pos
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
edit_debut
	trouve_objc	a5,(a6)
	move.l		a0,a4
	cmp.b		#G_LINE,ob_type+1(a4)
	bne		.not_g_line

	moveq.l		#0,d5
	move.w		d7,d5
	sub.w		#LINE_DEB00,d5

	bfins		d5,ob_spec(a0){3:2}	; place les 3 bits de poid faible de d5 dans les bits 26-24 de l'ob_spec (normalement)

	redraw_objc	a5,(a6)

.not_g_line
	addq.w		#2,a6
	cmp.w		#-1,(a6)
	bne		edit_debut
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
edit_fin
	trouve_objc	a5,(a6)
	move.l		a0,a4
	cmp.b		#G_LINE,ob_type+1(a4)
	bne		.not_g_line

	moveq.l		#0,d5
	move.w		d7,d5
	sub.w		#LINE_FIN00,d5

	bfins		d5,ob_spec(a0){1:2}	; place les 3 bits de poid faible de d5 dans les bits 26-24 de l'ob_spec (normalement)

	redraw_objc	a5,(a6)

.not_g_line
	addq.w		#2,a6
	cmp.w		#-1,(a6)
	bne		edit_fin
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	XDEF	reinit_gline_window
reinit_gline_window

* Reinitialise les bits de la fenetre
	rsrc_gaddr	#0,#LINE_EDITOR
	trouve_objc	addr_out,#LINE_POS000
	lea		-24(a0),a6
	trouve_objc	addr_out,#LINE_POS111
	move.l		a0,a5
.lp_reinit_pos
	lea		24(a6),a6
	bset		#DISABLED,ob_states+1(a6)
	bclr		#SELECTED,ob_states+1(a6)
	cmp.l		a5,a6
	bne		.lp_reinit_pos

	trouve_objc	addr_out,#LINE_DEB00
	lea		-24(a0),a6
	trouve_objc	addr_out,#LINE_DEB10
	move.l		a0,a5
.lp_reinit_deb
	lea		24(a6),a6
	bset		#DISABLED,ob_states+1(a6)
	bclr		#SELECTED,ob_states+1(a6)
	cmp.l		a5,a6
	bne		.lp_reinit_deb

	trouve_objc	addr_out,#LINE_FIN00
	lea		-24(a0),a6
	trouve_objc	addr_out,#LINE_FIN10
	move.l		a0,a5
.lp_reinit_fin
	lea		24(a6),a6
	bset		#DISABLED,ob_states+1(a6)
	bclr		#SELECTED,ob_states+1(a6)
	cmp.l		a5,a6
	bne		.lp_reinit_fin

	trouve_objc	addr_out,#LINE_SENS0
	lea		-24(a0),a6
	trouve_objc	addr_out,#LINE_SENS1
	move.l		a0,a5
.lp_reinit_sens
	lea		24(a6),a6
	bset		#DISABLED,ob_states+1(a6)
	bclr		#SELECTED,ob_states+1(a6)
	cmp.l		a5,a6
	bne		.lp_reinit_sens

	trouve_objc	addr_out,#LINE_MOTIF000
	lea		-24(a0),a6
	trouve_objc	addr_out,#LINE_MOTIF111
	move.l		a0,a5
.lp_reinit_motif
	lea		24(a6),a6
	bset		#DISABLED,ob_states+1(a6)
	bclr		#SELECTED,ob_states+1(a6)
	cmp.l		a5,a6
	bne		.lp_reinit_motif

	find_tab_l	#tab_adr,addr_out
	cmp.w		#-1,d0
	beq		.suite1
	wd_redraw_gem	d0
.suite1
	rts


