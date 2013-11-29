	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gprogdef_tbl.w,pc,d0.w*4])

.gprogdef_tbl
	dc.l	.GPROGDEFg_box
	dc.l	.GPROGDEFg_text
	dc.l	.GPROGDEFg_boxtext
	dc.l	.GPROGDEFg_image
	dc.l	.GPROGDEFg_progdef
	dc.l	.GPROGDEFg_ibox
	dc.l	.GPROGDEFg_button
	dc.l	.GPROGDEFg_boxchar
	dc.l	.GPROGDEFg_string
	dc.l	.GPROGDEFg_ftext
	dc.l	.GPROGDEFg_fboxtext
	dc.l	.GPROGDEFg_icon
	dc.l	.GPROGDEFg_title
	dc.l	.GPROGDEFg_cicon

	dc.l	0		.GPROGDEFg_bounding
	dc.l	0		.GPROGDEFg_bounded
	dc.l	.GPROGDEFg_pix
	dc.l	.GPROGDEFg_line
	dc.l	.GPROGDEFg_check
	*------------------------------------------------------------------------------*
.GPROGDEFg_box
	move.l		#$41FE1100,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_text
	move.l		(a5),a4

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		#$1111,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_boxtext
	move.l		(a5),d6

	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4

	move.l		(a5),a4
	move.w		#$1111,te_color(a4)
	move.w		#-1,te_thickness(a4)

	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_image
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_progdef
 	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_ibox
	move.l		#$41FE1100,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_button
	move.b		#G_BUTTON,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_boxchar
	move.b		#G_BOXCHAR,ob_type+1(a6)
	move.l		#$41FE1100,(a5)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_string
	move.b		#G_STRING,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_ftext
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
.GPROGDEFg_fboxtext
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
.GPROGDEFg_icon
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
.GPROGDEFg_title
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_cicon
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GCICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_CICON,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_bounding
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_bounded
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_pix
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
.GPROGDEFg_line
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GPROGDEFg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
