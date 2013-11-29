	include	structs.s
	include	zlib.i
	include	aes.i
	include	..\fashion.s

******************************************************
*** Affiche UN attribus dans le formulaire couleur ***
******************************************************
update_color_txt	macro	; couleur
	XREF	update_color_txt_rout
	move.w	\1,-(sp)
	bsr	update_color_txt_rout
	addq.l	#2,sp
	endm

update_color_cadre	macro	; couleur
	XREF	update_color_cadre_rout
	move.w	\1,-(sp)
	bsr	update_color_cadre_rout
	addq.l	#2,sp
	endm

update_color_surface	macro	; couleur
	XREF	update_color_surface_rout
	move.w	\1,-(sp)
	bsr	update_color_surface_rout
	addq.l	#2,sp
	endm

update_color_trame	macro	; couleur
	XREF	update_color_trame_rout
	move.w	\1,-(sp)
	bsr	update_color_trame_rout
	addq.l	#2,sp
	endm

update_opacite	macro	; opacite
	XREF	update_opacite_rout
	move.w	\1,-(sp)
	bsr	update_opacite_rout
	addq.l	#2,sp
	endm

update_taille_cadre	macro	; taille_cadre
	XREF	update_taille_cadre_rout
	bsr	update_taille_cadre_rout
	endm

update_obj_char	macro	; char
	XREF	update_obj_char_rout
	move.w	\1,-(sp)
	bsr	update_obj_char_rout
	addq.l	#2,sp
	endm

update_obj_justif	macro	; justification
	XREF	update_obj_justif_rout
	move.w	\1,-(sp)
	bsr	update_obj_justif_rout
	addq.l	#2,sp
	endm

update_line_pos	macro	; position des lignes
	XREF	update_line_pos
	move.w	\1,-(sp)
	bsr	update_line_pos
	addq.l	#2,sp
	endm

update_line_fill	macro	; position des lignes
	XREF	update_line_fill
	move.w	\1,-(sp)
	bsr	update_line_fill
	addq.l	#2,sp
	endm

update_line_extrem_start	macro	; position des lignes
	XREF	update_line_extrem_start
	move.w	\1,-(sp)
	bsr	update_line_extrem_start
	addq.l	#2,sp
	endm

update_line_extrem_end	macro	; position des lignes
	XREF	update_line_extrem_end
	move.w	\1,-(sp)
	bsr	update_line_extrem_end
	addq.l	#2,sp
	endm

update_line_sens	macro	; position des lignes
	XREF	update_line_sens
	move.w	\1,-(sp)
	bsr	update_line_sens
	addq.l	#2,sp
	endm

update_bit_obj		macro	; valeur_bit,adresse_arbre,index_objet
	XREF	update_bit_obj_rout
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	bsr	update_bit_obj_rout
	addq.l	#8,sp
	endm

update_te_font	macro	; valeur_te_font
	XREF	update_te_font_rout
	move.w	\1,-(sp)
	bsr	update_te_font_rout
	addq.l	#2,sp
	endm

update_fontlist	macro	; te_fontid
	move.w	\1,-(sp)
	XREF	update_fontlist_rout	; te_fontid
	bsr	update_fontlist_rout
	addq.l	#2,sp
	endm

update_tedinfo	macro	; a4 = pointeur sur tedinfo
	move.w			te_font(a4),d2
	update_te_font		d2

	cmp.w			#3,d2
	bge			.not_vectoriel
	update_fontlist		te_fontid(a4)

	XREF			update_font_size_rout
	jsr			update_font_size_rout
.not_vectoriel

	move.w			te_just(a4),d2
	move.w			d2,d0
	andi.w			#%11,d0
	update_obj_justif	d0

	move.w			d2,d0
	lsr.w			#2,d0
	and.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_GRAS

	move.w			d2,d0
	lsr.w			#3,d0
	andi.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_LIGHT

	move.w			d2,d0
	lsr.w			#4,d0
	andi.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_ITALIC

	move.w			d2,d0
	lsr.w			#5,d0
	andi.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_SOULIGNE

	move.w			d2,d0
	lsr.w			#6,d0
	andi.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_DETOURE

	move.w			d2,d0
	lsr.w			#7,d0
	andi.w			#1,d0
	update_bit_obj		d0,addr_out,#TED_OMBRE
	endm
*--------------------------------------------------------------------------------------------------------------------------*
	XDEF	graf_obj_attrb_rout
graf_obj_attrb_rout
	movem.l	d1-d2/a0-a4,-(sp)
	move.l	32+2(sp),a1		; adresse de l'arbre contenant l'objet
	move.w	32+0(sp),d1		; index de l'objet

	move.l	a0,a2
	trouve_objc	a1,d1
	move.l	a0,a3
	lea	ob_spec(a0),a4
	btst	#INDIRECT-8,ob_flags(a0)
	beq	.not_indirect
	move.l	(a4),a4
.not_indirect
	move.l	(a4),a4
	move.l	a4,d2
	moveq.l	#0,d1
	move.b	ob_type+1(a0),d1
	sub.w	#20,d1			; on soustrai 20 car le premier objet commence a #20
	jmp	([graf_obj_color_tbl.w,pc,d1.w*4])
********************************************
*** Table de saut en fonction des objets ***
********************************************
graf_obj_color_tbl
	dc.l	graf_attrb_g_box	; 20 g_box
	dc.l	graf_attrb_g_text	; 21 g_text
	dc.l	graf_attrb_g_boxtext	; 22 g_boxtext
	dc.l	graf_attrb_g_image	; 23 g_image
	dc.l	graf_attrb_g_progdef	; 24 g_progdef
	dc.l	graf_attrb_g_ibox	; 25 g_ibox
	dc.l	graf_attrb_g_button	; 26 g_button
	dc.l	graf_attrb_g_boxchar	; 27 g_boxchar
	dc.l	graf_attrb_g_string	; 28 g_string
	dc.l	graf_attrb_g_ftext	; 29 g_ftext
	dc.l	graf_attrb_g_fboxtext	; 30 g_fboxtext
	dc.l	graf_attrb_g_icon	; 31 g_icon
	dc.l	graf_attrb_g_title	; 32 g_title
	dc.l	graf_attrb_g_cicon	; 33 g_cicon
	dc.l	0	; g_bounding
	dc.l	0	; g_bounded
	dc.l	graf_attrb_g_pix
	dc.l	graf_attrb_g_line	; 37 g_line
	dc.l	0	; .crg_g_check

*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_box	; 20 g_box
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#%1111,d0
	update_color_cadre	d0
	move.w			d2,d0
	and.w			#%1111,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#4,d0
	and.w			#%111,d0
	update_color_trame	d0
	update_taille_cadre
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_text	; 21 g_text
	move.w			te_color(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#%1111,d0
	update_color_txt	d0
	move.w			d2,d0
	lsr.w			#7,d0
	and.w			#1,d0
	update_opacite		d0

	update_tedinfo

	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_boxtext	; 22 g_boxtext
	move.w			te_color(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#%1111,d0
	update_color_txt	d0
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#%1111,d0
	update_color_cadre	d0
	move.w			d2,d0
	and.w			#%1111,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#4,d0
	and.w			#%111,d0
	update_color_trame	d0
	move.w			d2,d0
	lsr.w			#7,d0
	and.w			#1,d0
	update_opacite		d0

	update_tedinfo

	update_obj_justif	te_just(a4)

	update_taille_cadre
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_image	; 23 g_image
	move.w			bi_color(a4),d0
	update_color_txt	d0
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_progdef	; 24 g_progdef
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_ibox	; 25 g_ibox
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#%1111,d0
	update_color_cadre	d0
	update_taille_cadre
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_button	; 26 g_button
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_boxchar	; 27 g_boxchar
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#%1111,d0
	update_color_txt	d0
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#%1111,d0
	update_color_cadre	d0
	move.w			d2,d0
	and.w			#%1111,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#4,d0
	and.w			#%111,d0
	update_color_trame	d0
	move.w			d2,d0
	lsr.w			#7,d0
	and.w			#1,d0
	update_opacite		d0
	update_taille_cadre
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_string	; 28 g_string
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_ftext	; 29 g_ftext
	move.w			te_color(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#%1111,d0
	update_color_txt	d0

	update_tedinfo

	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_fboxtext	; 30 g_fboxtext
	move.w			te_color(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#%1111,d0
	update_color_txt	d0
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#%1111,d0
	update_color_cadre	d0
	move.w			d2,d0
	and.w			#%1111,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#4,d0
	and.w			#%111,d0
	update_color_trame	d0
	move.w			d2,d0
	lsr.w			#7,d0
	and.w			#1,d0
	update_opacite		d0

	update_tedinfo

	update_taille_cadre

	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_icon	; 31 g_icon
	move.w			ib_char(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#$f,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#$f,d0
	update_color_txt	d0
	bra			end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_title	; 32 g_title
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_cicon	; 33 g_cicon
	move.w			ib_char(a4),d2
	move.w			d2,d0
	lsr.w			#8,d0
	and.w			#$f,d0
	update_color_surface	d0
	move.w			d2,d0
	lsr.w			#8,d0
	lsr.w			#4,d0
	and.w			#$f,d0
	update_color_txt	d0
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_pix
	bra	end_graf_obj_attrb
*--------------------------------------------------------------------------------------------------------------------------*
graf_attrb_g_line
	move.l		d2,d0
	swap		d0
	lsr.w		#8,d0
	and.w		#7,d0
	update_line_pos	d0

	move.l			d2,d0
	lsr.w			#4,d0
	and.w			#$7,d0
	update_line_fill	d0

	move.l				d2,d0
	swap				d0
	lsr.w				#8,d0
	lsr.w				#3,d0
	and.w				#3,d0
	update_line_extrem_start	d0

	move.l			d2,d0
	swap			d0
	lsr.w			#8,d0
	lsr.w			#5,d0
	and.w			#3,d0
	update_line_extrem_end	d0

	move.l			d2,d0
	rol.l			#1,d0
	and.w			#1,d0
	update_line_sens	d0

	move.w			d2,d0
	and.w			#7,d0
	update_color_surface	d0

	update_taille_cadre

;	bra	end_graf_obj_attrb
end_graf_obj_attrb
	movem.l	(sp)+,d1-d2/a0-a4
	rts
