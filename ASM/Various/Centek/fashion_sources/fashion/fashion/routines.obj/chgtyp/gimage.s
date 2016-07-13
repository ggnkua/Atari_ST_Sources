	moveq.l		#0,d0
	move.w		d7,d0
	sub.w		#20,d0

	cmp.w		#G_PIX,d7
	jmp		([.gimage_tbl.w,pc,d0.w*4])

.gimage_tbl
	dc.l	.GIMAGEg_box
	dc.l	.GIMAGEg_text
	dc.l	.GIMAGEg_boxtext
	dc.l	.GIMAGEg_image
	dc.l	.GIMAGEg_progdef
	dc.l	.GIMAGEg_ibox
	dc.l	.GIMAGEg_button
	dc.l	.GIMAGEg_boxchar
	dc.l	.GIMAGEg_string
	dc.l	.GIMAGEg_ftext
	dc.l	.GIMAGEg_fboxtext
	dc.l	.GIMAGEg_icon
	dc.l	.GIMAGEg_title
	dc.l	.GIMAGEg_cicon

	dc.l	0		.GIMAGEg_bounding
	dc.l	0		.GIMAGEg_bounded
	dc.l	.GIMAGEg_pix
	dc.l	.GIMAGEg_line
	dc.l	.GIMAGEg_check
	*------------------------------------------------------------------------------*
.GIMAGEg_box
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	move.l		#$41FE1100,d4
	or.w		d5,d4

	free_obj	a6

	move.l		d4,(a5)
	move.b		#G_BOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_text
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	lsl.w		#8,d5
	move.l		#$41FE1000,d4
	or.w		d5,d4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_TEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d4,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_boxtext
	move.l		(a5),d6

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	lsl.w		#8,d5
	move.l		#$41FE1000,d4
	or.w		d5,d4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_BOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d4,te_color(a4)
	move.w		#-1,te_thickness(a4)

	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_image
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_progdef
	free_obj	a6
	move.b		#G_PROGDEF,ob_type+1(a6)
	move.l		#user_blk,(a5)
 	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_ibox
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	move.l		#$41FE1100,d4
	or.w		d5,d4

	free_obj	a6

	move.l		d4,(a5)
	move.b		#G_IBOX,ob_type+1(a6)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_button
	free_obj	a6
	move.b		#G_BUTTON,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_boxchar
	move.l		(a5),a4

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	move.l		#$41FE1100,d4
	or.w		d5,d4

	free_obj	a6

	move.l		d4,(a5)
	move.b		#G_BOXCHAR,ob_type+1(a6)
	move.b		#"A",(a5)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_string
	free_obj	a6
	move.b		#G_STRING,ob_type+1(a6)
	xaloc_aloc	#2,a5
	move.l		d0,(a5)
	move.l		d0,a4
	move.b		#"a",(a4)+
	move.b		#0,(a4)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_ftext
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
.GIMAGEg_fboxtext
	move.l		(a5),d6

	moveq.l		#0,d5
	move.w		bi_color(a4),d5
	and.w		#7,d5
	lsl.w		#8,d5
	move.l		#$41FE1000,d4
	or.w		d5,d4

	free_obj	a6
	rsrc_gaddr	#0,#TYPES
	trouve_objc	addr_out,#TYPES_GFBOXTEXT
	move.l		ob_spec(a0),(a5)
	move.b		#G_FBOXTEXT,ob_type+1(a6)
	objc_real	a6

	move.l		(a5),a4
	move.w		d4,te_color(a4)
	move.w		#-1,te_thickness(a4)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_icon
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
.GIMAGEg_title
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_cicon
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
.GIMAGEg_bounding
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_bounded
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_pix
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
.GIMAGEg_line
	move.b		#G_LINE,ob_type+1(a6)
	move.l		#$CD010024,(a5)
	rts
	*------------------------------------------------------------------------------*
.GIMAGEg_check
	move.b		#G_CHECK,ob_type+1(a6)
	clr.l		(a5)
	rts
	*------------------------------------------------------------------------------*
