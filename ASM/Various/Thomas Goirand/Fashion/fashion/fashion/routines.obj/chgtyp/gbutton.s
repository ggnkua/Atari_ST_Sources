	moveq.l		#0,d1
	lea		temp_type_text,a1
	move.l		(a5),a4
.lp_gtxt
	addq.w		#1,d1
	move.b		(a4)+,(a1)+
	bne		.lp_gtxt
	move.w		d1,temp_type_txtsize

	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gbutton_tbl.w,pc,d0.w*4])

.gbutton_tbl
	dc.l	.GBUTTONg_box
	dc.l	.GBUTTONg_text
	dc.l	.GBUTTONg_boxtext
	dc.l	.GBUTTONg_image
	dc.l	.GBUTTONg_progdef
	dc.l	.GBUTTONg_ibox
	dc.l	.GBUTTONg_button
	dc.l	.GBUTTONg_boxchar
	dc.l	.GBUTTONg_string
	dc.l	.GBUTTONg_ftext
	dc.l	.GBUTTONg_fboxtext
	dc.l	.GBUTTONg_icon
	dc.l	.GBUTTONg_title
	dc.l	.GBUTTONg_cicon

	dc.l	0		.GBUTTONg_bounding
	dc.l	0		.GBUTTONg_bounded
	dc.l	.GBUTTONg_pix
	dc.l	.GBUTTONg_line
	dc.l	.GBUTTONg_check
	*------------------------------------------------------------------------------*
.GBUTTONg_box
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_text
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
.GBUTTONg_boxtext
	free_obj	a6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	xaloc_free	a4
	xaloc_aloc	temp_type_txtsize,a4
	move.l		d0,(a4)
	string_copy	#temp_type_text,d0
	move.w		temp_type_txtsize,te_txtlen(a4)

	move.w		#$1110,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_image
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_ibox
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_button
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_boxchar
	free_obj	a6
	move.l		#$41FE1100,(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_string
	move.b		#G_STRING,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_ftext
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
.GBUTTONg_fboxtext
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

	move.w		#$1110,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_icon
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
.lp_cp_GBUTTONg_icon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBUTTONg_icon

	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_title
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_cicon
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
.lp_cp_GBUTTONg_cicon
	move.b		(a3)+,(a4)+
	dbf		d5,.lp_cp_GBUTTONg_cicon
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_bounding
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_bounded
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_pix
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
.GBUTTONg_line
	free_obj	a6
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GBUTTONg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
