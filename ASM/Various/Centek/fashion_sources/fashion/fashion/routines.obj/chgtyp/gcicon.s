	moveq.l		#0,d1
	lea		temp_type_text,a1
	move.l		(a5),a4
	move.l		ib_ptext(a4),a4
.lp_gtxt
	addq.w		#1,d1
	move.b		(a4)+,(a1)+
	bne		.lp_gtxt
	move.w		d1,temp_type_txtsize

	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gcicon_tbl.w,pc,d0.w*4])

.gcicon_tbl
	dc.l	.GCICONg_box
	dc.l	.GCICONg_text
	dc.l	.GCICONg_boxtext
	dc.l	.GCICONg_image
	dc.l	.GCICONg_progdef
	dc.l	.GCICONg_ibox
	dc.l	.GCICONg_button
	dc.l	.GCICONg_boxchar
	dc.l	.GCICONg_string
	dc.l	.GCICONg_ftext
	dc.l	.GCICONg_fboxtext
	dc.l	.GCICONg_icon
	dc.l	.GCICONg_title
	dc.l	.GCICONg_cicon

	dc.l	0		.GCICONg_bounding
	dc.l	0		.GCICONg_bounded
	dc.l	.GCICONg_pix
	dc.l	.GCICONg_line
	dc.l	.GCICONg_check
	*------------------------------------------------------------------------------*
.GCICONg_box
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		ib_char(a4),d5
	and.w		#$ff00,d5
	move.l		#$41FE0000,d4
	or.w		d5,d4

	free_obj	a6

	move.l		d4,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_text
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	xaloc_free	a4
	xaloc_aloc	temp_type_txtsize,a4
	move.l		d0,(a4)
	string_copy	#temp_type_text,d0
	move.w		temp_type_txtsize,te_txtlen(a4)

	rts
	*------------------------------------------------------------------------------*
.GCICONg_boxtext

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4

	move.l		(a5),a4
	xaloc_free	a4
	xaloc_aloc	temp_type_txtsize,a4
	move.l		d0,(a4)
	string_copy	#temp_type_text,d0
	move.w		temp_type_txtsize,te_txtlen(a4)

	move.w		#$1100,te_color(a4)
	move.w		#-1,te_thickness(a4)

	rts
	*------------------------------------------------------------------------------*
.GCICONg_image
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		ib_char(a4),d5
	and.w		#$ff00,d5
	move.l		#$41FE0000,d4
	or.w		d5,d4

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
.GCICONg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GCICONg_ibox
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		ib_char(a4),d5
	and.w		#$ff00,d5
	move.l		#$41FE0000,d4
	or.w		d5,d4

	free_obj	a6

	move.l		d4,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_button
	free_obj	a6

	move.w		temp_type_txtsize,d5
	xaloc_aloc	d5,a5
	move.l		d0,a5
	move.l		d0,a4
	lea		temp_type_text,a3
	subq.w		#1,d5
.lp_cp_GCICONg_button
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GCICONg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_boxchar
	move.l		(a5),a4

	move.w		ib_char(a4),d3

	free_obj	a6

	move.l		#$41FE1100,(a5)
	move.b		d3,(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_string
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
.GCICONg_ftext
	move.l		(a5),a4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4

	xaloc_free	a4
	xaloc_aloc	#2,a4
	move.l		d0,(a4)
	move.l		d0,a2
	move.b		#0,(a2)

	lea		4(a4),a3
	xaloc_free	a3
	xaloc_aloc	temp_type_txtsize,a3
	move.l		d0,(a3)
	string_copy	#temp_type_text,d0

	lea		8(a4),a3
	xaloc_free	a3
	xaloc_aloc	#2,a3
	move.l		d0,(a3)
	move.l		d0,a2
	move.b		#0,(a2)

	move.w		temp_type_txtsize,te_tmplen(a4)
	clr.w		te_txtlen(a4)

	rts
	*------------------------------------------------------------------------------*
.GCICONg_fboxtext
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		ib_char(a4),d5
	and.w		#$ff00,d5
	move.l		#$41FE0000,d4
	or.w		d5,d4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FBOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4

	xaloc_free	a4
	xaloc_aloc	#2,a4
	move.l		d0,(a4)
	move.l		d0,a2
	move.b		#0,(a2)

	lea		4(a4),a3
	xaloc_free	a3
	xaloc_aloc	temp_type_txtsize,a3
	move.l		d0,(a3)
	string_copy	#temp_type_text,d0

	lea		8(a4),a3
	xaloc_free	a3
	xaloc_aloc	#2,a3
	move.l		d0,(a3)
	move.l		d0,a2
	move.b		#0,(a2)

	move.w		temp_type_txtsize,te_tmplen(a4)
	clr.w		te_txtlen(a4)

	move.w		d4,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_icon
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
.lp_cp_GCICONg_cicon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GCICONg_cicon
	rts
	*------------------------------------------------------------------------------*
.GCICONg_title
	rts
	*------------------------------------------------------------------------------*
.GCICONg_cicon
	rts
	*------------------------------------------------------------------------------*
.GCICONg_bounding
	rts
	*------------------------------------------------------------------------------*
.GCICONg_bounded
	rts
	*------------------------------------------------------------------------------*
.GCICONg_pix
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
.GCICONg_line
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GCICONg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
