	moveq.l		#0,d1
	lea		temp_type_text,a1
	move.l		(a5),a4
	move.l		(a4),a4
.lp_gftxt
	addq.w		#1,d1
	move.b		(a4)+,(a1)+
	bne		.lp_gftxt
	move.w		d1,temp_type_txtsize
	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gftext_tbl.w,pc,d0.w*4])

.gftext_tbl
	dc.l	.GFTEXTg_box
	dc.l	.GFTEXTg_text
	dc.l	.GFTEXTg_boxtext
	dc.l	.GFTEXTg_image
	dc.l	.GFTEXTg_progdef
	dc.l	.GFTEXTg_ibox
	dc.l	.GFTEXTg_button
	dc.l	.GFTEXTg_boxchar
	dc.l	.GFTEXTg_string
	dc.l	.GFTEXTg_ftext
	dc.l	.GFTEXTg_fboxtext
	dc.l	.GFTEXTg_icon
	dc.l	.GFTEXTg_title
	dc.l	.GFTEXTg_cicon

	dc.l	0		.GFTEXTg_bounding
	dc.l	0		.GFTEXTg_bounded
	dc.l	.GFTEXT_pix
	dc.l	.GFTEXTg_line
	dc.l	0		.GFTEXTg_check
	*------------------------------------------------------------------------------*
.GFTEXTg_box
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
.GFTEXTg_text
	move.l		(a5),a4
	lea		4(a4),a3
	xaloc_free	a3
	lea		8(a4),a3
	xaloc_free	a3
	move.b		#G_TEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_boxtext
	move.l		(a5),a4
	lea		4(a4),a3
	xaloc_free	a3
	lea		8(a4),a3
	xaloc_free	a3
	move.b		#G_BOXTEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_image
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
.GFTEXTg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_ibox
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
.GFTEXTg_button
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,a5
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GFTEXTg_button
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GFTEXTg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_boxchar
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
.GFTEXTg_string
	free_obj	a6
	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,(a5)
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GFTEXTg_string
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GFTEXTg_string
	move.b		#G_STRING,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_ftext
	move.b		#G_FTEXT,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_fboxtext
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_icon
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
.lp_cp_GFTEXTg_icon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GFTEXTg_icon

	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_title
	rts
	*------------------------------------------------------------------------------*
.GFTEXTg_cicon
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
.lp_cp_GFTEXTg_cicon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GFTEXTg_cicon

	rts
	*------------------------------------------------------------------------------*
.GFTEXT_pix
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
.GFTEXTg_line
	free_obj	a6
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
