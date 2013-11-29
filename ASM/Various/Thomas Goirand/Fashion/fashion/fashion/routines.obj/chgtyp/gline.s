	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gline_tbl.w,pc,d0.w*4])

.gline_tbl
	dc.l	.GLINEg_box
	dc.l	.GLINEg_text
	dc.l	.GLINEg_boxtext
	dc.l	.GLINEg_image
	dc.l	.GLINEg_progdef
	dc.l	.GLINEg_ibox
	dc.l	.GLINEg_button
	dc.l	.GLINEg_boxchar
	dc.l	.GLINEg_string
	dc.l	.GLINEg_ftext
	dc.l	.GLINEg_fboxtext
	dc.l	.GLINEg_icon
	dc.l	.GLINEg_title
	dc.l	.GLINEg_cicon

	dc.l	0		.GLINEg_bounding
	dc.l	0		.GLINEg_bounded
	dc.l	.GLINEg_pix
	dc.l	.GLINEg_line
	dc.l	.GLINEg_check
	*------------------------------------------------------------------------------*
.GLINEg_box
	move.l		#$41FE1100,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_text
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GLINEg_boxtext
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		#$1100,te_color(a4)
	move.w		#-1,te_thickness(a4)

	rts
	*------------------------------------------------------------------------------*
.GLINEg_image
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GLINEg_progdef
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GLINEg_ibox
	move.l		#$41FE1100,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_boxchar
	move.l		#$41FE1100,(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_string
	move.b		#G_STRING,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_ftext
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		#$1100,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_fboxtext
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FBOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		#$1100,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GLINEg_icon
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GLINEg_title
	rts
	*------------------------------------------------------------------------------*
.GLINEg_cicon
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GLINEg_bounding
	rts
	*------------------------------------------------------------------------------*
.GLINEg_bounded
	rts
	*------------------------------------------------------------------------------*
.GLINEg_pix
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
.GLINEg_line
	rts
	*------------------------------------------------------------------------------*
.GLINEg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
