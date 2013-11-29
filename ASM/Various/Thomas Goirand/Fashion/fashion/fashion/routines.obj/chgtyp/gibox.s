	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gibox_tbl.w,pc,d0.w*4])

.gibox_tbl
	dc.l	.GIBOXg_box
	dc.l	.GIBOXg_text
	dc.l	.GIBOXg_boxtext
	dc.l	.GIBOXg_image
	dc.l	.GIBOXg_progdef
	dc.l	.GIBOXg_ibox
	dc.l	.GIBOXg_button
	dc.l	.GIBOXg_boxchar
	dc.l	.GIBOXg_string
	dc.l	.GIBOXg_ftext
	dc.l	.GIBOXg_fboxtext
	dc.l	.GIBOXg_icon
	dc.l	.GIBOXg_title
	dc.l	.GIBOXg_cicon

	dc.l	0		.GIBOXg_bounding
	dc.l	0		.GIBOXg_bounded
	dc.l	.GIBOXg_pix
	dc.l	.GIBOXg_line
	dc.l	.GIBOXg_check
	*------------------------------------------------------------------------------*
.GIBOXg_box
	and.w		#$ff00,2(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_text
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d6,te_color(a4)
	move.l		d6,d5
	swap		d5
	moveq.l		#0,d4
	move.b		d5,d4
	move.w		d4,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_boxtext
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4

	move.w		d6,te_color(a4)
	move.l		d6,d5
	swap		d5
	move.b		d5,d4
	extb.l		d4
	move.w		d4,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_image
	move.w		2(a5),d6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d6,bi_color(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_progdef
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GIBOXg_ibox
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_boxchar
	move.b		#G_BOXCHAR,ob_type+1(a6)
	move.b		#"A",(a5)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_string
	move.b		#G_STRING,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_ftext
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FTEXT,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4

	move.w		d6,te_color(a4)
	move.l		d6,d5
	swap		d5
	move.b		d5,d4
	extb.l		d4
	move.w		d4,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_fboxtext
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FBOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d6,te_color(a4)
	move.l		d6,d5
	swap		d5
	moveq.l		#0,d4
	move.b		d5,d4
	extb.l		d4
	move.w		d4,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_icon
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	move.w		#$1041,d6
	move.w		d6,ib_char(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_title
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_cicon
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GCICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_CICON,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	move.w		#$1041,d6
	move.w		d6,ib_char(a4)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_bounding
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_bounded
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_pix
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
.GIBOXg_line
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GIBOXg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
