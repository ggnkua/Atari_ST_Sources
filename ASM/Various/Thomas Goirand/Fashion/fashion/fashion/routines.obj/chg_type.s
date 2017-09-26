
	XDEF	popup_change_type

	XREF	label_win,label_objc
	XREF	user_blk
	XREF	transformation_impossible
	XREF	temp_gpix_img

	include	structs.s
	include aes.i
	include	zlib.i
	include	..\macro.i
	include	..\fashion.s

popup_change_type
	move.l		d0,d7
	move.w		d1,d6
	rsrc_gaddr	#0,#POPUP
	popup		d7,d6,addr_out,#POPUP_OBTYPE
	cmp.w		#-1,d0
	beq		go_error
	move.w		d0,d7
	sub.w		#PP_G_BOX,d7
	add.w		#20,d7		; numero du nouveau type d'objet

	trouve_objc	label_win,label_objc
	move.l		a0,a6				; a6 = adresse de l'objet
	lea		ob_spec(a0),a5
	btst		#INDIRECT-8,ob_flags(a6)
	beq		.not_indirectX
	move.l		(a5),a5				; a5 = adresse pointe par l'ob_spec
.not_indirectX
	moveq.l		#0,d0
	move.b		ob_type+1(a0),d0
	sub.w		#20,d0
	jmp		([chg_type_tbl.w,pc,d0.w*4])

chg_type_tbl

	dc.l	g_box
	dc.l	g_text
	dc.l	g_boxtext
	dc.l	g_image
	dc.l	g_progdef
	dc.l	g_ibox
	dc.l	g_button
	dc.l	g_boxchar
	dc.l	g_string
	dc.l	g_ftext
	dc.l	g_fboxtext
	dc.l	g_icon
	dc.l	g_title
	dc.l	g_cicon

	dc.l	0		.crg_g_bounding
	dc.l	0		.crg_g_bounded
	dc.l	g_pix
	dc.l	g_line
	dc.l	0		.crg_g_check
go_error
	rts
*--------------------------------------------------------------------------------------------------------------------------*
g_box
g_boxchar
	include	chgtyp\gbox.s
g_text
	include	chgtyp\gtext.s
g_boxtext
	include	chgtyp\gboxtext.s
g_image
	include	chgtyp\gimage.s
g_progdef
	include	chgtyp\gprogdef.s
g_ibox
	include	chgtyp\gibox.s
g_button
g_string
	include	chgtyp\gbutton.s
g_ftext
	include	chgtyp\gftext.s
g_fboxtext
	include	chgtyp\gfbxtext.s
g_icon
	include	chgtyp\gicon.s
g_title
	illegal
g_cicon
	include	chgtyp\gcicon.s
g_bounding
	illegal
g_bounded
	illegal
g_pix
	include	chgtyp\gpix.s
g_line
	include	chgtyp\gline.s
g_check
	illegal
*--------------------------------------------------------------------------------------------------------------------------*
	bss
temp_type_text		ds.b	256
temp_type_txtsize	ds.w	1
	text
