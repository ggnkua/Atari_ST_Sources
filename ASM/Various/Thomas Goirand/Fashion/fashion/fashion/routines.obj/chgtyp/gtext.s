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
	jmp		([.gtext_tbl.w,pc,d0.w*4])

.gtext_tbl
	dc.l	.GTEXTg_box
	dc.l	.GTEXTg_text
	dc.l	.GTEXTg_boxtext
	dc.l	.GTEXTg_image
	dc.l	.GTEXTg_progdef
	dc.l	.GTEXTg_ibox
	dc.l	.GTEXTg_button
	dc.l	.GTEXTg_boxchar
	dc.l	.GTEXTg_string
	dc.l	.GTEXTg_ftext
	dc.l	.GTEXTg_fboxtext
	dc.l	.GTEXTg_icon
	dc.l	.GTEXTg_title
	dc.l	.GTEXTg_cicon

	dc.l	0		.GTEXTg_bounding
	dc.l	0		.GTEXTg_bounded
	dc.l	.GTEXT_pix
	dc.l	.GTEXTg_line
	dc.l	0		.GTEXTg_check
	*------------------------------------------------------------------------------*
.GTEXTg_box
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_text
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_boxtext
	move.b		#G_BOXTEXT,ob_type+1(a6)
	move.l		(a5),a4
	move.w		#1,te_thickness(a4)
	move.w		#$1111,te_color(a4)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_image
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	move.w		d6,bi_color(a4)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GTEXTg_ibox
	move.l		(a5),a4
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_button
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,a5
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GTEXTg_button
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GTEXTg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_boxchar
	move.l		(a5),a4
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.l		(a5),a4
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_string
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,(a5)
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GTEXTg_string
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GTEXTg_string
	move.b		#G_STRING,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_ftext
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
.GTEXTg_fboxtext
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
	move.w		#-1,te_thickness(a4)
	move.w		#$1111,te_color(a4)
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_icon
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
.lp_cp_GTEXTg_icon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GTEXTg_icon

	rts
	*------------------------------------------------------------------------------*
.GTEXTg_title
	rts
	*------------------------------------------------------------------------------*
.GTEXTg_cicon
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
.lp_cp_GTEXTg_cicon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GTEXTg_cicon

	rts
	*------------------------------------------------------------------------------*
.GTEXT_pix
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
.GTEXTg_line
	free_obj	a6
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
