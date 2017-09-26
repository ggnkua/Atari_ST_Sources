	moveq.l		#0,d1
	lea		temp_type_text,a1
	move.l		(a5),a4
	move.l		(a4),a4
.lp_gtxt
	addq.w		#1,d1
	move.b		(a4)+,(a1)+
	bne		.lp_gtxt
	move.w		d1,temp_type_txtsize
	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gboxtext_tbl.w,pc,d0.w*4])

.gboxtext_tbl
	dc.l	.GBOXTEXTg_box
	dc.l	.GBOXTEXTg_text
	dc.l	.GBOXTEXTg_boxtext
	dc.l	.GBOXTEXTg_image
	dc.l	.GBOXTEXTg_progdef
	dc.l	.GBOXTEXTg_ibox
	dc.l	.GBOXTEXTg_button
	dc.l	.GBOXTEXTg_boxchar
	dc.l	.GBOXTEXTg_string
	dc.l	.GBOXTEXTg_ftext
	dc.l	.GBOXTEXTg_fboxtext
	dc.l	.GBOXTEXTg_icon
	dc.l	.GBOXTEXTg_title
	dc.l	.GBOXTEXTg_cicon

	dc.l	0		.GBOXTEXTg_bounding
	dc.l	0		.GBOXTEXTg_bounded
	dc.l	.GBOXTEXT_pix
	dc.l	.GBOXTEXTg_line
	dc.l	0		.GBOXTEXTg_check
	*------------------------------------------------------------------------------*
.GBOXTEXTg_box
	move.l		(a5),a4
	move.w		te_thickness(a4),d4
	swap		d4
	move.w		te_color(a4),d4
	free_obj	a6
	move.l		d4,(a5)
	move.b		#"A",(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_text
	move.b		#G_TEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_boxtext
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_image
	move.l		(a5),a4
	move.w		te_color,d4
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	move.w		d4,bi_color(a4)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_ibox
	move.l		(a5),a4
	move.w		te_thickness(a4),d4
	swap		d4
	move.w		te_color(a4),d4
	free_obj	a6
	move.l		d4,(a5)
	move.b		#"A",(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_button
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,a5
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GBOXTEXTg_button
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBOXTEXTg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_boxchar
	move.l		(a5),a4
	move.w		te_thickness(a4),d4
	swap		d4
	move.w		te_color(a4),d4
	free_obj	a6
	move.l		d4,(a5)
	move.b		#"A",(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_string
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,(a5)
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GBOXTEXTg_string
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBOXTEXTg_string
	move.b		#G_STRING,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_ftext
	move.l		(a5),a4

	lea		4(a4),a3
	move.l		(a4),(a3)
	xaloc_moveptr	a4,a3,(a4)	; deplace le texte de ptext vers tmplt

	string_size	(a3)
	move.w		d0,d4

	move.w		d4,te_tmplen(a4)
	clr.w		te_txtlen(a4)

	xaloc_aloc	#2,a4
	move.l		d0,(a4)
	move.l		d0,a2
	move.b		#0,(a2)

	lea		8(a4),a3
	xaloc_aloc	#2,a3
	move.l		d0,(a3)
	move.l		d0,a2
	move.b		#0,(a2)

	move.b		#G_FTEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_fboxtext
	move.l		(a5),a4

	lea		4(a4),a3
	move.l		(a4),(a3)
	xaloc_moveptr	a4,a3,(a4)	; deplace le texte de ptext vers tmplt

	string_size	(a3)
	move.w		d0,d4

	move.w		d4,te_tmplen(a4)
	clr.w		te_txtlen(a4)

	xaloc_aloc	#2,a4
	move.l		d0,(a4)
	move.l		d0,a2
	move.b		#0,(a2)

	lea		8(a4),a3
	xaloc_aloc	#2,a3
	move.l		d0,(a3)
	move.l		d0,a2
	move.b		#0,(a2)

	move.b		#G_FBOXTEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_icon
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	lea		ib_ptext(a4),a3
	xaloc_free	a3

	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a3
	move.l		d0,(a3)
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GBOXTEXTg_icon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBOXTEXTg_icon

	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_title
	rts
	*------------------------------------------------------------------------------*
.GBOXTEXTg_cicon
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GCICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_CICON,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	lea		ib_ptext(a4),a3
	xaloc_free	a3

	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a3
	move.l		d0,(a3)
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GBOXTEXTg_cicon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBOXTEXTg_cicon

	rts
	*------------------------------------------------------------------------------*
.GBOXTEXT_pix
	free_obj	a6
	move.b		#G_PIX,ob_type+1(a6)

	xaloc_aloc	#sizeof_gpix,a5
	move.l		d0,(a5)
	move.l		d0,a4
	string_size	#temp_gpix_img
	xaloc_aloc	d0,a4
	move.l		d0,(a4)
	string_copy	#temp_gpix_img,d0
	move.l		#3,gpix_flags(a4)
	rts

	*------------------------------------------------------------------------------*
.GBOXTEXTg_line
	free_obj	a6
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
