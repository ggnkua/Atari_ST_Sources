**************************************
*** Fenetre d'edition des couleurs ***
**************************************

	include	structs.s
	include	zlib.i
	include	aes.i

	include	..\fashion.s

	XREF	ed_sel_win
	XREF	ed_sel_objc
	XDEF	color_window
	XREF	tab_adr
color_window
	move.l	ed_sel_win,a5
	lea	ed_sel_objc,a6
	move.l	d0,a4
	cmp.w	#CW_TXT0,d1
	blt	.suite1
	cmp.w	#CW_TXT15,d1
	ble	edit_txt_color
.suite1
	cmp.w	#CW_CADRE0,d1
	blt	.suite2
	cmp.w	#CW_CADRE15,d1
	ble	edit_cadre_color
.suite2
	cmp.w	#CW_FOND0,d1
	blt	.suite3
	cmp.w	#CW_FOND15,d1
	ble	edit_fond_color
.suite3
	cmp.w	#CW_TRAME0,d1
	blt	.suite4
	cmp.w	#CW_TRAME7,d1
	ble	edit_trame
.suite4
	cmp.w	#CW_OPAQUE,d1
	beq	edit_opacite
	cmp.w	#CW_PLUS,d1
	beq	cadre_plus_grand
	cmp.w	#CW_MOINS,d1
	beq	cadre_moins_grand
	rts

****************************************************************************************************************************
cadre_plus_grand
	xobjc_change	a4,d1
	moveq.l		#0,d7
.lp_plus_cadre
	trouve_objc	a5,(a6)
	move.b		ob_type+1(a0),d6
	cmp.w		#G_BOX,d6
	beq		.ob_spec
	cmp.w		#G_BOXCHAR,d6
	beq		.ob_spec
	cmp.w		#G_IBOX,d6
	beq		.ob_spec
	cmp.w		#G_LINE,d6
	beq		.g_line
	cmp.w		#G_BOXTEXT,d6
	beq		.ted_info
	cmp.w		#G_FBOXTEXT,d6
	beq		.ted_info
	bra		.end_cadre_plus
	*-------------*
.g_line
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind3
	move.l		(a1),a1
.Ok_not_ind3
	move.l		(a1),d0
	swap		d0
	add.b		#2,d0		; enleve 1 dans les bits 24-16 de l'ob_spec
	swap		d0
	move.l		d0,(a1)
	bra		.end_cadre_plus
	*-------------*
.ted_info
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind
	move.l		(a1),a1
.Ok_not_ind
	move.l		(a1),a1
	sub.w		#1,te_thickness(a1)		; enleve 1
	bra		.end_cadre_plus
	*-------------*
.ob_spec
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind2
	move.l		(a1),a1
.Ok_not_ind2
	move.l		(a1),d0
	swap		d0
	sub.b		#1,d0		; enleve 1 dans les bits 24-16 de l'ob_spec
	swap		d0
	move.l		d0,(a1)
	*-------------*
.end_cadre_plus
	redraw_objc	a5,(a6)+
	cmp.w		#-1,(a6)
	bne		.lp_plus_cadre
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
cadre_moins_grand
	xobjc_change	a4,d1
	moveq.l		#0,d7
.lp_plus_cadre
	trouve_objc	a5,(a6)
	move.b		ob_type+1(a0),d6
	cmp.w		#G_BOX,d6
	beq		.ob_spec
	cmp.w		#G_BOXCHAR,d6
	beq		.ob_spec
	cmp.w		#G_LINE,d6
	beq		.g_line
	cmp.w		#G_IBOX,d6
	beq		.ob_spec
	cmp.w		#G_BOXTEXT,d6
	beq		.ted_info
	cmp.w		#G_FBOXTEXT,d6
	beq		.ted_info
	bra		.end_cadre_plus
	*-------------*
.g_line
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind3
	move.l		(a1),a1
.Ok_not_ind3
	move.l		(a1),d0
	swap		d0
	sub.b		#2,d0		; ajoute 1 dans les bits 24-16 de l'ob_spec
	swap		d0
	move.l		d0,(a1)
	bra		.end_cadre_plus
	*-------------*
.ted_info
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind
	move.l		(a1),a1
.Ok_not_ind
	move.l		(a1),a1
	add.w		#1,te_thickness(a1)		; ajoute 1
	bra		.end_cadre_plus
	*-------------*
.ob_spec
	lea		ob_spec(a0),a1
	btst		#INDIRECT-8,ob_flags(a0)
	beq		.Ok_not_ind2
	move.l		(a1),a1
.Ok_not_ind2
	move.l		(a1),d0
	swap		d0
	add.b		#1,d0		; ajoute 1 dans les bits 24-16 de l'ob_spec
	swap		d0
	move.l		d0,(a1)
	*-------------*
.end_cadre_plus
	redraw_objc	a5,(a6)+
	cmp.w		#-1,(a6)
	bne		.lp_plus_cadre
	rts

****************************************************************************************************************************
edit_txt_color
	move.w	d1,d7
	move.w	d1,d6
	sub.w	#CW_TXT0,d7
boucle_chg_txt_color
	trouve_objc	a5,(a6)+
	move.w	ob_type(a0),d1
	and.w	#$ff,d1
	lea	chg_txt_col_tbl,a1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	(a1),a1
	jmp	(a1)

chg_txt_col_ob_spec	; 20 g_box ; 27 g_boxchar
	move.w	ob_spec+2(a0),d0
	and.w	#$f0ff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,ob_spec+2(a0)
	bra	chg_txt_col_end
chg_txt_col_ted_info	; 21 g_text ; 22 g_boxtext ; 29 g_ftext ; 30 g_fboxtext
	move.l	ob_spec(a0),a0
	move.w	te_color(a0),d0
	and.w	#$f0ff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,te_color(a0)
	bra	chg_txt_col_end
chg_txt_col_g_image	; 23 g_image
	move.l	ob_spec(a0),a0
	move.w	d7,bi_color(a0)
	bra	chg_txt_col_end
chg_txt_col_g_progdef	; 24 g_progdef
	bra	chg_txt_col_end
chg_txt_col_no_color	; 25 g_ibox ; 26 g_button ; 28 g_string ; 32 g_title
	bra	chg_txt_col_end
chg_txt_col_g_icon	; 31 g_icon ; 33 g_cicon
	move.l	ob_spec(a0),a0
	move.w	ib_char(a0),d0
	and.w	#$0fff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w	d0,ib_char(a0)
	bra	chg_txt_col_end
chg_txt_col_end
	cmp.w	#-1,(a6)
	bne	boucle_chg_txt_color
********************************************
*** Table de saut en fonction des objets ***
********************************************
	data
chg_txt_col_tbl
	dc.l	chg_txt_col_ob_spec	; 20 g_box
	dc.l	chg_txt_col_ted_info	; 21 g_text
	dc.l	chg_txt_col_ted_info	; 22 g_boxtext
	dc.l	chg_txt_col_g_image	; 23 g_image
	dc.l	chg_txt_col_g_progdef	; 24 g_progdef
	dc.l	chg_txt_col_no_color	; 25 g_ibox
	dc.l	chg_txt_col_no_color	; 26 g_button
	dc.l	chg_txt_col_ob_spec	; 27 g_boxchar
	dc.l	chg_txt_col_no_color	; 28 g_string
	dc.l	chg_txt_col_ted_info	; 29 g_ftext
	dc.l	chg_txt_col_ted_info	; 30 g_fboxtext
	dc.l	chg_txt_col_g_icon	; 31 g_icon
	dc.l	chg_txt_col_no_color	; 32 g_title
	dc.l	chg_txt_col_g_icon	; 33 g_cicon
	dc.l	0			g_bounding
	dc.l	0			g_bounded
	dc.l	chg_txt_col_no_color	g_pix
	dc.l	chg_txt_col_no_color	g_line
	dc.l	0			g_check
	text
*--------------------------------------------------------------------------------------------------------------------------*
;* Maintenant on reafiche le formulaire de couleur texte
	trouve_objc	a4,#CW_TXT0
	move.w		#15,d3
.boucle_update_bouton_color_txt
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	dbra		d3,.boucle_update_bouton_color_txt
	trouve_objc	a4,d6
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)

	redraw_objc	a4,#CW_TXTBOX
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
****************************************************************************************************************************
edit_cadre_color
	move.w	d1,d7
	move.w	d1,d6
	sub.w	#CW_CADRE0,d7
boucle_chg_cadre_color
	trouve_objc	a5,(a6)+
	move.w	ob_type(a0),d1
	and.w	#$ff,d1
	lea	chg_cadre_col_tbl,a1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	(a1),a1
	jmp	(a1)

chg_cadre_col_ob_spec	; 20 g_box ; 27 g_boxchar
	move.w	ob_spec+2(a0),d0
	and.w	#$0fff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w	d0,ob_spec+2(a0)
	bra	chg_cadre_col_end
chg_cadre_col_ted_info	; 21 g_text ; 22 g_boxtext ; 29 g_ftext ; 30 g_fboxtext
	move.l	ob_spec(a0),a0
	move.w	te_color(a0),d0
	and.w	#$0fff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w	d0,te_color(a0)
	bra	chg_cadre_col_end
chg_cadre_col_g_image	; 23 g_image
	bra	chg_cadre_col_end
chg_cadre_col_g_progdef	; 24 g_progdef
	bra	chg_cadre_col_end
chg_cadre_col_no_color	; 25 g_ibox ; 26 g_button ; 28 g_string ; 32 g_title
	bra	chg_cadre_col_end
chg_cadre_col_g_icon	; 31 g_icon
	bra	chg_cadre_col_end
chg_cadre_col_g_cicon	; 33 g_cicon
chg_cadre_col_end
	cmp.w	#-1,(a6)
	bne	boucle_chg_cadre_color
********************************************
*** Table de saut en fonction des objets ***
********************************************
	data
chg_cadre_col_tbl
	dc.l	chg_cadre_col_ob_spec	; 20 g_box
	dc.l	chg_cadre_col_ted_info	; 21 g_text
	dc.l	chg_cadre_col_ted_info	; 22 g_boxtext
	dc.l	chg_cadre_col_g_image	; 23 g_image
	dc.l	chg_cadre_col_g_progdef	; 24 g_progdef
	dc.l	chg_cadre_col_no_color	; 25 g_ibox
	dc.l	chg_cadre_col_no_color	; 26 g_button
	dc.l	chg_cadre_col_ob_spec	; 27 g_boxchar
	dc.l	chg_cadre_col_no_color	; 28 g_string
	dc.l	chg_cadre_col_ted_info	; 29 g_ftext
	dc.l	chg_cadre_col_ted_info	; 30 g_fboxtext
	dc.l	chg_cadre_col_g_icon	; 31 g_icon
	dc.l	chg_cadre_col_no_color	; 32 g_title
	dc.l	chg_cadre_col_g_cicon	; 33 g_cicon
	dc.l	0			g_bounding
	dc.l	0			g_bounded
	dc.l	chg_cadre_col_no_color	g_pix
	dc.l	chg_cadre_col_no_color	g_line
	dc.l	0			g_check
	text
*--------------------------------------------------------------------------------------------------------------------------*
;* Maintenant on reafiche le formulaire de couleur texte
	trouve_objc	a4,#CW_CADRE0
	move.w		#15,d3
.boucle_update_bouton_color_cadre
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	dbra		d3,.boucle_update_bouton_color_cadre
	trouve_objc	a4,d6
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)

	redraw_objc	a4,#CW_CADREBOX
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
****************************************************************************************************************************
edit_fond_color
	move.w	d1,d7
	move.w	d1,d6
	sub.w	#CW_FOND0,d7
boucle_chg_fond_color
	trouve_objc	a5,(a6)+
	move.w	ob_type(a0),d1
	and.w	#$ff,d1
	lea	chg_fond_col_tbl,a1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	(a1),a1
	jmp	(a1)

chg_fond_col_ob_spec	; 20 g_box ; 27 g_boxchar
	move.w	ob_spec+2(a0),d0
	and.w	#$fff0,d0
	move.w	d7,d1
	or.w	d1,d0
	move.w	d0,ob_spec+2(a0)
	bra	chg_fond_col_end
chg_fond_col_ted_info	; 21 g_text ; 22 g_boxtext ; 29 g_ftext ; 30 g_fboxtext
	move.l	ob_spec(a0),a0
	move.w	te_color(a0),d0
	and.w	#$fff0,d0
	move.w	d7,d1
	or.w	d1,d0
	move.w	d0,te_color(a0)
	bra	chg_fond_col_end
chg_fond_col_g_progdef	; 24 g_progdef
	bra	chg_fond_col_end
chg_fond_col_no_color	; 23 g_image ; 25 g_ibox ; 26 g_button ; 28 g_string ; 32 g_title
	bra	chg_fond_col_end
chg_fond_col_g_icon	; 31 g_icon ; 33 g_cicon
	move.l	ob_spec(a0),a0
	move.w	ib_char(a0),d0
	and.w	#$f0ff,d0
	move.w	d7,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,ib_char(a0)
	bra	chg_fond_col_end
chg_fond_col_end
	cmp.w	#-1,(a6)
	bne	boucle_chg_fond_color
********************************************
*** Table de saut en fonction des objets ***
********************************************
	data
chg_fond_col_tbl
	dc.l	chg_fond_col_ob_spec	; 20 g_box
	dc.l	chg_fond_col_ted_info	; 21 g_text
	dc.l	chg_fond_col_ted_info	; 22 g_boxtext
	dc.l	chg_fond_col_no_color	; 23 g_image
	dc.l	chg_fond_col_g_progdef	; 24 g_progdef
	dc.l	chg_fond_col_no_color	; 25 g_ibox
	dc.l	chg_fond_col_no_color	; 26 g_button
	dc.l	chg_fond_col_ob_spec	; 27 g_boxchar
	dc.l	chg_fond_col_no_color	; 28 g_string
	dc.l	chg_fond_col_ted_info	; 29 g_ftext
	dc.l	chg_fond_col_ted_info	; 30 g_fboxtext
	dc.l	chg_fond_col_g_icon	; 31 g_icon
	dc.l	chg_fond_col_no_color	; 32 g_title
	dc.l	chg_fond_col_g_icon	; 33 g_cicon
	dc.l	0			g_bounding
	dc.l	0			g_bounded
	dc.l	chg_fond_col_no_color	g_pix
	dc.l	chg_fond_col_ob_spec	g_line
	dc.l	0			g_check
	text
*--------------------------------------------------------------------------------------------------------------------------*
;* Maintenant on reafiche le formulaire de couleur texte
	trouve_objc	a4,#CW_FOND0
	move.w		#15,d3
.boucle_update_bouton_color_fond
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	dbra		d3,.boucle_update_bouton_color_fond
	trouve_objc	a4,d6
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)

	redraw_objc	a4,#CW_FONDBOX
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
****************************************************************************************************************************
edit_trame
	move.w	d1,d7
	move.w	d1,d6
	sub.w	#CW_TRAME0,d7
boucle_chg_trame_color
	trouve_objc	a5,(a6)+
	move.w	ob_type(a0),d1
	and.w	#$ff,d1
	lea	chg_trame_col_tbl,a1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	(a1),a1
	jmp	(a1)

chg_trame_col_ob_spec	; 20 g_box ; 27 g_boxchar
	move.w	ob_spec+2(a0),d0
	and.w	#$ff8f,d0
	move.w	d7,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w	d0,ob_spec+2(a0)
	bra	chg_trame_col_end
chg_trame_col_ted_info	; 21 g_text ; 22 g_boxtext ; 29 g_ftext ; 30 g_fboxtext
	move.l	ob_spec(a0),a0
	move.w	te_color(a0),d0
	and.w	#$ff8f,d0
	move.w	d7,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w	d0,te_color(a0)
	bra	chg_trame_col_end
chg_trame_col_g_image	; 23 g_image
chg_trame_col_g_progdef	; 24 g_progdef
chg_trame_col_no_color	; 25 g_ibox ; 26 g_button ; 28 g_string ; 32 g_title
chg_trame_col_g_icon	; 31 g_icon
	bra	chg_trame_col_end
	bra	chg_trame_col_end
chg_trame_col_g_cicon	; 33 g_cicon
chg_trame_col_end
	cmp.w	#-1,(a6)
	bne	boucle_chg_trame_color
********************************************
*** Table de saut en fonction des objets ***
********************************************
	data
chg_trame_col_tbl
	dc.l	chg_trame_col_ob_spec	; 20 g_box
	dc.l	chg_trame_col_ted_info	; 21 g_text
	dc.l	chg_trame_col_ted_info	; 22 g_boxtext
	dc.l	chg_trame_col_g_image	; 23 g_image
	dc.l	chg_trame_col_g_progdef	; 24 g_progdef
	dc.l	chg_trame_col_no_color	; 25 g_ibox
	dc.l	chg_trame_col_no_color	; 26 g_button
	dc.l	chg_trame_col_ob_spec	; 27 g_boxchar
	dc.l	chg_trame_col_no_color	; 28 g_string
	dc.l	chg_trame_col_ted_info	; 29 g_ftext
	dc.l	chg_trame_col_ted_info	; 30 g_fboxtext
	dc.l	chg_trame_col_g_icon	; 31 g_icon
	dc.l	chg_trame_col_no_color	; 32 g_title
	dc.l	chg_trame_col_g_cicon	; 33 g_cicon
	dc.l	0			g_bounding
	dc.l	0			g_bounded
	dc.l	chg_trame_col_no_color	g_pix
	dc.l	chg_trame_col_no_color	g_line
	dc.l	0			g_check
	text
*--------------------------------------------------------------------------------------------------------------------------*
;* Maintenant on reafiche le formulaire de couleur texte
	trouve_objc	a4,#CW_TRAME0
	move.w		#7,d3
.boucle_update_bouton_color_trame
	move.w		ob_states(a0),d0
	bclr		#SELECTED,d0
	bclr		#CROSSED,d0
	move.w		d0,ob_states(a0)
	add.l		#24,a0
	dbra		d3,.boucle_update_bouton_color_trame
	trouve_objc	a4,d6
	move.w		ob_states(a0),d0
	bset		#SELECTED,d0
	bset		#CROSSED,d0
	move.w		d0,ob_states(a0)

	redraw_objc	a4,#CW_TRAMEBOX
	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts
*--------------------------------------------------------------------------------------------------------------------------*
edit_opacite
	trouve_objc	a4,d1
	move.w		ob_states(a0),d7
	btst		#SELECTED,d0
boucle_chg_opacite
	trouve_objc	a5,(a6)+
	move.w	ob_type(a0),d1
	and.w	#$ff,d1
	lea	chg_opacite_col_tbl,a1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a1
	move.l	(a1),a1
	jmp	(a1)

chg_opacite_no_opak	; 31 g_icon ; 20 g_box ; 23 g_image  ; 25 g_ibox ; 26 g_button ; 28 g_string ; 32 g_title ; 33 g_cicon 
	bra	chg_opacite_col_end
chg_opacite_ted_info	; 21 g_text ; 22 g_boxtext ; 29 g_ftext ; 30 g_fboxtext
	move.l	ob_spec(a0),a0
	move.w	te_color(a0),d6
	btst	#SELECTED,d7
	beq	.unselect_opacite
	or.w	#%10000000,d6
	move.w	d6,te_color(a0)
	bra	chg_opacite_col_end
.unselect_opacite
	and.w	#%1111111101111111,d6
	move.w	d6,te_color(a0)
	bra	chg_opacite_col_end
chg_opacite_g_progdef	; 24 g_progdef
	bra	chg_opacite_col_end
chg_opacite_ob_spec	; 27 g_boxchar
	move.w	ob_spec+2(a0),d6
	btst	#SELECTED,d7
	beq	.unselect_opacite
	or.w	#%10000000,d6
	move.w	d6,ob_spec+2(a0)
	bra	chg_opacite_col_end
.unselect_opacite
	and.w	#%1111111101111111,d6
	move.w	d6,ob_spec+2(a0)
chg_opacite_col_end
	cmp.w	#-1,(a6)
	bne	boucle_chg_opacite

	find_tab_l	#tab_adr,a5
	wd_redraw	d0
	rts

********************************************
*** Table de saut en fonction des objets ***
********************************************
	data
chg_opacite_col_tbl
	dc.l	chg_opacite_no_opak	; 20 g_box
	dc.l	chg_opacite_ted_info	; 21 g_text
	dc.l	chg_opacite_ted_info	; 22 g_boxtext
	dc.l	chg_opacite_no_opak	; 23 g_image
	dc.l	chg_opacite_g_progdef	; 24 g_progdef
	dc.l	chg_opacite_no_opak	; 25 g_ibox
	dc.l	chg_opacite_no_opak	; 26 g_button
	dc.l	chg_opacite_ob_spec	; 27 g_boxchar
	dc.l	chg_opacite_no_opak	; 28 g_string
	dc.l	chg_opacite_ted_info	; 29 g_ftext
	dc.l	chg_opacite_ted_info	; 30 g_fboxtext
	dc.l	chg_opacite_no_opak	; 31 g_icon
	dc.l	chg_opacite_no_opak	; 32 g_title
	dc.l	chg_opacite_no_opak	; 33 g_cicon
	dc.l	0			g_bounding
	dc.l	0			g_bounded
	dc.l	chg_opacite_no_opak	g_pix
	dc.l	chg_opacite_no_opak	g_line
	dc.l	0			g_check
	text
*--------------------------------------------------------------------------------------------------------------------------*