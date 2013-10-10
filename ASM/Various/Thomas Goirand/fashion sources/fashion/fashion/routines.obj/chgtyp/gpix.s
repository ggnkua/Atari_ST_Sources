	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gpix_tbl.w,pc,d0.w*4])

.gpix_tbl
	dc.l	.GPIXg_box
	dc.l	.GPIXg_text
	dc.l	.GPIXg_boxtext
	dc.l	.GPIXg_image
	dc.l	.GPIXg_progdef
	dc.l	.GPIXg_ibox
	dc.l	.GPIXg_button
	dc.l	.GPIXg_boxchar
	dc.l	.GPIXg_string
	dc.l	.GPIXg_ftext
	dc.l	.GPIXg_fboxtext
	dc.l	.GPIXg_icon
	dc.l	.GPIXg_title
	dc.l	.GPIXg_cicon

	dc.l	0		.GPIXg_bounding
	dc.l	0		.GPIXg_bounded
	dc.l	.GPIXg_pix
	dc.l	.GPIXg_line
	dc.l	.GPIXg_check
	*------------------------------------------------------------------------------*
.GPIXg_box
	free_obj	a6

	move.l		#$41FE1100,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_text
	move.l		(a5),a4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GPIXg_boxtext
	free_obj	a6
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
.GPIXg_image
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GIMAGE
	move.l		ob_spec(a0),(a5)
	move.b		#G_IMAGE,ob_type+1(a6)
	objc_real	a6
	rts
	*------------------------------------------------------------------------------*
.GPIXg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GPIXg_ibox
	free_obj	a6

	move.l		#$41FE1100,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_button
	free_obj	a6
	move.b		#G_BUTTON,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_boxchar
	free_obj	a6

	move.l		#$41FE1100,(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_string
	free_obj	a6
	move.b		#G_STRING,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_ftext
	move.l		(a5),d6

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	lsl.w		#8,d5
	move.l		#$41FE1000,d4
	or.w		d5,d4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d4,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_fboxtext
	free_obj	a6
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
.GPIXg_icon
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.b		#"A",d6
	move.w		d6,ib_char(a4)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_title
	rts
	*------------------------------------------------------------------------------*
.GPIXg_cicon
	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GICON
	move.l		ob_spec(a0),(a5)
	move.b		#G_ICON,ob_type+1(a6)
	objc_real	a6
	move.l		(a5),a4
	move.b		#"A",d6
	move.w		d6,ib_char(a4)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_bounding
	rts
	*------------------------------------------------------------------------------*
.GPIXg_bounded
	rts
	*------------------------------------------------------------------------------*
.GPIXg_pix
	rts
	*------------------------------------------------------------------------------*
.GPIXg_line
	free_obj	a6
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GPIXg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
