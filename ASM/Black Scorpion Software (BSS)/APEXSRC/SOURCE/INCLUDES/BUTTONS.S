
Button_DRAW_NORM:
	move.w	#1<<Bit_DRAW_NORM,DRAW_BITS
	rts
Button_DRAW_STREAK:
	move.w	#1<<Bit_DRAW_STREAK,DRAW_BITS
	rts
Button_DRAW_LASSOO:
	move.w	#1<<Bit_DRAW_LASSOO,DRAW_BITS
	rts

Button_LINE_NORM:
	move.w	#1<<Bit_LINE_NORM,LINE_BITS
	rts
Button_LINE_GRAD:
	move.w	#1<<Bit_LINE_GRAD,LINE_BITS
	rts
Button_LINE_INT:
	move.w	#1<<Bit_LINE_INT,LINE_BITS
	rts

Button_CURVE_BEZIER:
	move.w	#1<<Bit_CURVE_BEZIER,CURVE_BITS
	rts
Button_CURVE_BETAC:
	move.w	#1<<Bit_CURVE_BETAC,CURVE_BITS
	rts
Button_CURVE_BETAS:
	move.w	#1<<Bit_CURVE_BETAS,CURVE_BITS
	rts
Button_CURVE_BETAG:
	move.w	#1<<Bit_CURVE_BETAG,CURVE_BITS
	rts

Button_BOX1_SQUARE:
	eor.w		#1<<Bit_BOX1_SQUARE,BOX1_BITS
	rts
Button_BOX2_WIRE:
	move.w	#1<<Bit_BOX2_WIRE,BOX2_BITS
	rts
Button_BOX2_SOLID:
	move.w	#1<<Bit_BOX2_SOLID,BOX2_BITS
	rts
Button_BOX2_GRAD:
	move.w	#1<<Bit_BOX2_GRAD,BOX2_BITS
	rts
Button_BOX2_QUAD:
	move.w	#1<<Bit_BOX2_QUAD,BOX2_BITS
	rts

Button_CIRCLE_WIRE:
	move.w	#1<<Bit_CIRCLE_WIRE,CIRCLE_BITS
	rts
Button_CIRCLE_SOLID:
	move.w	#1<<Bit_CIRCLE_SOLID,CIRCLE_BITS
	rts
Button_CIRCLE_SPHERE:
	move.w	#1<<Bit_CIRCLE_SPHERE,CIRCLE_BITS
	rts

Button_POLY_WIRE:
	move.w	#1<<Bit_POLY_WIRE,POLY_BITS
	rts
Button_POLY_SOLID:
	move.w	#1<<Bit_POLY_SOLID,POLY_BITS
	rts
Button_POLY_TRIP:
	move.w	#1<<Bit_POLY_TRIP,POLY_BITS
	rts

Button_FILL_SOLID:
	move.w	#1<<Bit_FILL_SOLID,FILL_BITS
	rts
Button_FILL_BRUSH:
	move.w	#1<<Bit_FILL_BRUSH,FILL_BITS
	rts
Button_FILL_GRAD:
	move.w	#1<<Bit_FILL_GRAD,FILL_BITS
	rts

Button_AIR_FREE:
	move.w	#1<<Bit_AIR_FREE,AIR_BITS
	rts
Button_AIR_CTRL:
	move.w	#1<<Bit_AIR_CTRL,AIR_BITS
	rts

Button_PASTE_XRAY:
	move.w	#1<<Bit_PASTE_XRAY,PASTE_BITS
	jsr		MAKE_BLOCKMASK
	rts

Button_PASTE_SOLI:
	move.w	#1<<Bit_PASTE_SOLI,PASTE_BITS
	jsr		MAKE_BLOCKMASK
	rts

Button_GRID_USE:
	eor.w		#1<<Bit_GRID_USE,GRID_BITS
	rts

Button_WIPE_WB1:
	jsr		Press_button
	jsr		HIDE_MOUSE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	push.w	BRUSH_SELECTED
	move.w	#0,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	move.w	LOG_HANDLE,TAB_HANDLE
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	pop.w		BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		print_brush_menu
	jsr		SHOW_MOUSE
	jsr		Release_button
	rts

Button_WIPE_WB2:
	jsr		Press_button
	jsr		HIDE_MOUSE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	push.w	BRUSH_SELECTED
	move.w	#1,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	move.w	LOG_HANDLE,TAB_HANDLE
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	pop.w		BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		print_brush_menu
	jsr		SHOW_MOUSE
	jsr		Release_button
	rts

Button_WIPE_WB3:
	jsr		Press_button
	jsr		HIDE_MOUSE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	push.w	BRUSH_SELECTED
	move.w	#2,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	move.w	LOG_HANDLE,TAB_HANDLE
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	pop.w		BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		print_brush_menu
	jsr		SHOW_MOUSE
	jsr		Release_button
	rts

Button_WIPE_WB4:
	jsr		Press_button
	jsr		HIDE_MOUSE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	push.w	BRUSH_SELECTED
	move.w	#3,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	move.w	LOG_HANDLE,TAB_HANDLE
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	pop.w		BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		print_brush_menu
	jsr		SHOW_MOUSE
	jsr		Release_button
	rts

Button_TWEEN_PING:
	eor.w		#1<<Bit_TWEEN_PING,TWEEN_BITS
	rts

Button_TWEEN_START:
	jsr		Press_button
	delay		2
	move.w	CUR_DELTAFRAME,SEGMENT_START
	jsr		Update_tween_combo
	jsr		Release_button
	rts
Button_TWEEN_END:
	jsr		Press_button
	delay		2
	move.w	CUR_DELTAFRAME,SEGMENT_END
	jsr		Update_tween_combo
	jsr		Release_button
	rts
	
Button_ASK_ABORT:
Button_ASK_YES:
	move.w	#1<<Bit_ASK_ABORT,ASK_BITS
	move.w	#1<<Bit_ASK_YES,ASK_BITS
	st		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts
Button_ASK_GO:
Button_ASK_NO:
	move.w	#1<<Bit_ASK_GO,ASK_BITS
	move.w	#1<<Bit_ASK_NO,ASK_BITS
	sf		OK_CANCEL
	move.w	#-1,DIALOG_BITS
	rts

Button_MORPH1_PREVIEW:
	move.w	#1<<Bit_MORPH1_PREVIEW,MORPH1_BITS
	rts
Button_MORPH1_PICTURE:
	move.w	#1<<Bit_MORPH1_PICTURE,MORPH1_BITS
	rts

Button_MORPH2_DISTORT:
	move.w	#1<<Bit_MORPH2_DISTORT,MORPH2_BITS
	rts
Button_MORPH2_MORPH:
	move.w	#1<<Bit_MORPH2_MORPH,MORPH2_BITS
	rts

Button_VIDEO_PAL:
	tst.b		VGA_FLAG
	bne.s		.rts
	move.w	VIDEO_BITS,d0
	bclr		#Bit_VIDEO_NTSC,d0
	bset		#Bit_VIDEO_PAL,d0
	move.w	d0,VIDEO_BITS
.rts	rts

Button_VIDEO_NTSC:
	tst.b		VGA_FLAG
	bne.s		.rts
	move.w	VIDEO_BITS,d0
	bclr		#Bit_VIDEO_PAL,d0
	bset		#Bit_VIDEO_NTSC,d0
	move.w	d0,VIDEO_BITS
.rts	rts

Button_RES_LOW:
	lea		VIDEO_STRUCTURE,a6
	move.w	#1<<Bit_RES_LOW,RES_BITS
	move.w	#320,VIDEO_WIDTH
	move.w	#200,VIDEO_HEIGHT
	jsr		reset_canvas_size
	jsr		Update_video_combo
	rts

Button_RES_HIGH:
	lea		VIDEO_STRUCTURE,a6

;	tst.b		VGA_FLAG
;	beq.s		.ok
;	cmp.w		#1<<Bit_VCOL_TRUE,VCOL_BITS
;	bne.s		.ok
;	clr.b		gensol_copy(a6)
;	clr.b		extend_copy(a6)
;	move.w	#1<<Bit_BCOL_BIT18,BCOL_BITS
;	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
;	move.l	#%111111001111110011111100,COLMASK
;	move.w	#1<<2,COLSHIFT

.ok	move.w	#1<<Bit_RES_HIGH,RES_BITS
	move.w	#640,VIDEO_WIDTH
	move.w	#400,VIDEO_HEIGHT
	jsr		reset_canvas_size
	jsr		Update_video_combo
	rts

Button_RES_MED2:
	move.w	#1<<Bit_RES_MED2,RES_BITS
	move.w	#320,VIDEO_WIDTH
	move.w	#400,VIDEO_HEIGHT
	jsr		reset_canvas_size
	jsr		Update_video_combo
	rts

Button_RES_MED1:
	lea		VIDEO_STRUCTURE,a6

;	tst.b		VGA_FLAG
;	beq.s		.ok
;	cmp.w		#1<<Bit_VCOL_TRUE,VCOL_BITS
;	bne.s		.ok
;	clr.b		gensol_copy(a6)
;	clr.b		extend_copy(a6)
;	move.w	#1<<Bit_BCOL_BIT18,BCOL_BITS
;	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
;	move.l	#%111111001111110011111100,COLMASK
;	move.w	#1<<2,COLSHIFT

.ok	move.w	#1<<Bit_RES_MED1,RES_BITS
	move.w	#640,VIDEO_WIDTH
	move.w	#200,VIDEO_HEIGHT
	jsr		reset_canvas_size
	jsr		Update_video_combo
	rts

Button_VIDEO_CANWIDu:
	jsr		Press_button
	move.l	edit_list,line_ptr
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	add.l		#16,d0
	cmp.l		#2048,d0
	ble.s		.ok
	move.l	#2048,d0
.ok	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	rts

Button_VIDEO_CANWIDd:
	jsr		Press_button
	move.l	edit_list,line_ptr
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	sub.l		#16,d0
	bpl.s		.ok
	moveq		#0,d0
.ok	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	rts

Button_VIDEO_CANHIGu:
	jsr		Press_button
	move.l	edit_list+4,line_ptr
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	add.l		#16,d0
	cmp.l		#1024,d0
	ble.s		.ok
	move.l	#1024,d0
.ok	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	rts

Button_VIDEO_CANHIGd:
	jsr		Press_button
	move.l	edit_list+4,line_ptr
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	sub.l		#16,d0
	bpl.s		.ok
	moveq		#0,d0
.ok	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	rts

Button_VIDEO_CANWID:
	pushall
	move.l	edit_list,line_ptr
	jsr		Press_button
	jsr		edit_line
	jsr		update_canwid
	jsr		Release_button
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	move.w	#iface_white,CHAR_COL
	jsr		NUM2ASCII
	move.w	#iface_grey,CHAR_COL
	jsr		show_line
	popall	
	rts

Button_VIDEO_CANHIG:
	pushall
	move.l	edit_list+4,line_ptr
	jsr		Press_button
	jsr		edit_line
	jsr		update_canhig
	jsr		Release_button
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	move.w	#iface_white,CHAR_COL
	jsr		NUM2ASCII
	move.w	#iface_grey,CHAR_COL
	jsr		show_line
	popall	
	rts

Button_VIDEO_CW384:
	move.w	#384,d0
	bra		CWCLIP
Button_VIDEO_CW512:
	move.w	#512,d0
	bra		CWCLIP
Button_VIDEO_CW640:
	move.w	#640,d0
	bra		CWCLIP
Button_VIDEO_CW768:
	move.w	#768,d0
CWCLIP:
	pushall
	jsr		Press_button
	move.l	edit_list,line_ptr
	move.l	line_ptr,a0
	ext.l		d0
	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	popall
	rts

Button_VIDEO_CH240:
	move.w	#240,d0
	bra		CHCLIP
Button_VIDEO_CH288:
	move.w	#288,d0
	bra		CHCLIP
Button_VIDEO_CH480:
	move.w	#480,d0
	bra		CHCLIP
Button_VIDEO_CH576:
	move.w	#576,d0
CHCLIP:
	pushall
	jsr		Press_button
	move.l	edit_list+4,line_ptr
	move.l	line_ptr,a0
	ext.l		d0
	cmp.l		#log_height,d0
	ble.s		.ok
	move.l	#log_height,d0
.ok	move.l	d0,g_text(a0)
	jsr		Update_video_combo
	jsr		Release_button
	popall
	rts

Button_BCOL_BIT9:
	clr.b		VIDEO_STRUCTURE+gensol_copy
	move.w	#1<<Bit_BCOL_BIT9,BCOL_BITS
	sf		VIDEO_STRUCTURE+extend_copy
	move.l	#%111000001110000011100000,COLMASK
	move.w	#1<<5,COLSHIFT
	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
	rts
Button_BCOL_BIT12:
	clr.b		VIDEO_STRUCTURE+gensol_copy
	move.w	#1<<Bit_BCOL_BIT12,BCOL_BITS
	sf		VIDEO_STRUCTURE+extend_copy
	move.l	#%111100001111000011110000,COLMASK
	move.w	#1<<4,COLSHIFT
	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
	rts
Button_VCOL_COL256:
Button_BCOL_BIT18:
	clr.b		VIDEO_STRUCTURE+gensol_copy
	move.w	#1<<Bit_BCOL_BIT18,BCOL_BITS
	sf		VIDEO_STRUCTURE+extend_copy
	move.l	#%111111001111110011111100,COLMASK
	move.w	#1<<2,COLSHIFT
	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
	jsr		Update_video_combo
	rts

Button_BCOL_BIT24:
	clr.b		VIDEO_STRUCTURE+gensol_copy
	move.w	#1<<Bit_BCOL_BIT24,BCOL_BITS
	st		VIDEO_STRUCTURE+extend_copy
	move.l	#%111111111111111111111111,COLMASK
	move.w	#1<<0,COLSHIFT
	move.w	#1<<Bit_VCOL_COL256,VCOL_BITS
	rts

Button_VCOL_GREY:
	clr.b		VIDEO_STRUCTURE+gensol_copy
	move.w	#1<<Bit_BCOL_BIT24,BCOL_BITS
	st		VIDEO_STRUCTURE+extend_copy
	move.l	#%111111111111111111111111,COLMASK
	move.w	#1<<0,COLSHIFT
	move.w	#1<<Bit_VCOL_GREY,VCOL_BITS
	jsr		Update_video_combo
	rts

Button_VCOL_TRUE:
	lea		VIDEO_STRUCTURE,a6
	sf		extend_copy(a6)
	move.b	#%00100000,gensol_copy(a6)
	clr.w		BCOL_BITS
	move.w	#1<<Bit_VCOL_TRUE,VCOL_BITS
	move.l	#%111110001111110011111000,COLMASK
	move.w	#1<<2,COLSHIFT

;	tst.b		VGA_FLAG
;	beq.s		.done
;	cmp.w		#1<<Bit_RES_LOW,RES_BITS
;	beq.s		.done
;	cmp.w		#1<<Bit_RES_MED2,RES_BITS
;	beq.s		.done
;	cmp.w		#1<<Bit_RES_HIGH,RES_BITS
;	beq.s		.hi
;	move.w	#1<<Bit_RES_LOW,RES_BITS
;	move.w	#320,VIDEO_WIDTH
;	move.w	#200,VIDEO_HEIGHT
;	jsr		reset_canvas_size
;	bra.s		.done
;.hi	move.w	#1<<Bit_RES_MED2,RES_BITS
;	move.w	#320,VIDEO_WIDTH
;	move.w	#400,VIDEO_HEIGHT
;	jsr		reset_canvas_size

.done	jsr		Update_video_combo
	rts

Button_DISKOP_REPLACE:
	move.w	#1<<Bit_DISKOP_REPLACE,DISKOP_BITS
	rts
Button_DISKOP_ABOVE:
	move.w	#1<<Bit_DISKOP_ABOVE,DISKOP_BITS
	rts
Button_DISKOP_BELOW:
	move.w	#1<<Bit_DISKOP_BELOW,DISKOP_BITS
	rts
Button_DISKOP_INSERT:
	move.w	#1<<Bit_DISKOP_INSERT,DISKOP_BITS
	rts
Button_DISKOP_PATCH:
	move.w	#1<<Bit_DISKOP_PATCH,DISKOP_BITS
	rts
Button_DISKOP_PRECEDE:
	move.w	#1<<Bit_DISKOP_PRECEDE,DISKOP_BITS
	rts
Button_DISKOP_APPEND:
	move.w	#1<<Bit_DISKOP_APPEND,DISKOP_BITS
	rts

Button_DISKFUNC_LOAD:
	move.w	#1<<Bit_DISKFUNC_LOAD,DISKFUNC_BITS
	jsr		LOAD_FILE
	st		FIRST_DRAW
	rts

Button_DISKFUNC_EDIT:
	move.w	#1<<Bit_DISKFUNC_EDIT,DISKFUNC_BITS
	push.w	PASTE_BITS
	st		edit
	st		first_edit_cycle
	jsr		LOAD_FILE
	sf		edit
	pop.w		PASTE_BITS
	st		FIRST_DRAW
	rts

Button_DISKFUNC_CUT:
	move.w	#1<<Bit_DISKFUNC_CUT,DISKFUNC_BITS
	st		cut_mode
	jsr		SAVE_FILE
	sf		cut_mode
	st		FIRST_DRAW
	rts

Button_DISKFUNC_SAVE:
	move.w	#1<<Bit_DISKFUNC_SAVE,DISKFUNC_BITS
	sf		cut_mode
	jsr		SAVE_FILE
	st		FIRST_DRAW
	rts

Button_DISKFLAG_MIPMAP:
	move.w	DISKFLAG_BITS,d0
	bchg		#Bit_DISKFLAG_MIPMAP,d0
	move.w	d0,DISKFLAG_BITS
	rts

Button_DISKFLAG_MAKECOL:
	move.w	DISKFLAG_BITS,d0
	bclr		#Bit_DISKFLAG_NEWCOL,d0
	bset		#Bit_DISKFLAG_MAKECOL,d0
	bclr		#Bit_DISKFLAG_KEEPCOL,d0
	move.w	d0,DISKFLAG_BITS
	rts

Button_DISKFLAG_KEEPCOL:
	move.w	DISKFLAG_BITS,d0
	bclr		#Bit_DISKFLAG_NEWCOL,d0
	bclr		#Bit_DISKFLAG_MAKECOL,d0
	bset		#Bit_DISKFLAG_KEEPCOL,d0
	move.w	d0,DISKFLAG_BITS
	rts

Button_DISKFLAG_NEWCOL:
	move.w	DISKFLAG_BITS,d0
	bset		#Bit_DISKFLAG_NEWCOL,d0
	bclr		#Bit_DISKFLAG_MAKECOL,d0
	bclr		#Bit_DISKFLAG_KEEPCOL,d0
	move.w	d0,DISKFLAG_BITS
	rts

Button_DISKFLAG_WRAP:
	move.w	DISKFLAG_BITS,d0
	bchg		#Bit_DISKFLAG_WRAP,d0
	move.w	d0,DISKFLAG_BITS
	rts

Button_DISKTYP1_JPG:
	move.w	#1<<Bit_DISKTYP1_JPG,DISKTYP1_BITS
	rts
Button_DISKTYP1_PC1:
	move.w	#1<<Bit_DISKTYP1_PC1,DISKTYP1_BITS
	rts
Button_DISKTYP1_GIF:
	move.w	#1<<Bit_DISKTYP1_GIF,DISKTYP1_BITS
	rts
Button_DISKTYP1_LBM:
	move.w	#1<<Bit_DISKTYP1_LBM,DISKTYP1_BITS
	rts
Button_DISKTYP1_CFN:
	move.w	#1<<Bit_DISKTYP1_CFN,DISKTYP1_BITS
	rts
Button_DISKTYP1_TGA:
	move.w	#1<<Bit_DISKTYP1_TGA,DISKTYP1_BITS
	rts
Button_DISKTYP1_MTV:
	move.w	#1<<Bit_DISKTYP1_MTV,DISKTYP1_BITS
	rts
Button_DISKTYP1_PCS:
	move.w	#1<<Bit_DISKTYP1_PCS,DISKTYP1_BITS
	rts
Button_DISKTYP1_SPU:
	move.w	#1<<Bit_DISKTYP1_SPU,DISKTYP1_BITS
	rts
Button_DISKTYP1_FLI:
	move.w	#1<<Bit_DISKTYP1_FLI,DISKTYP1_BITS
	rts
Button_DISKTYP1_ANM:
	move.w	#1<<Bit_DISKTYP1_ANM,DISKTYP1_BITS
	rts
Button_DISKTYP1_SEQ:
	move.w	#1<<Bit_DISKTYP1_SEQ,DISKTYP1_BITS
	rts
Button_DISKTYP1_BLK:
	move.w	#1<<Bit_DISKTYP1_BLK,DISKTYP1_BITS
	rts
Button_DISKTYP1_CTL:
	move.w	#1<<Bit_DISKTYP1_CTL,DISKTYP1_BITS
	rts
Button_DISKTYP1_DAC:
	move.w	#1<<Bit_DISKTYP1_DAC,DISKTYP1_BITS
	rts

Button_DISKTYP1_CFG:
	jsr		Press_button
	jsr		write_prefs
	jsr		Release_button
	rts

Button_DIALOG_QUIT:
	move.w	#-1,DIALOG_BITS
	rts

Button_REMAP_BLOCK:
	move.w	#1<<Bit_REMAP_BLOCK,REMAP_BITS
	rts
Button_REMAP_IMAGE:
	move.w	#1<<Bit_REMAP_IMAGE,REMAP_BITS
	rts
	
Button_DSIZE_N256:
	move.w	DSIZE_BITS,d0
	bclr		#Bit_DSIZE_N512,d0
	bset		#Bit_DSIZE_N256,d0
	move.w	d0,DSIZE_BITS
	rts
Button_DSIZE_N512:
	move.w	DSIZE_BITS,d0
	bset		#Bit_DSIZE_N512,d0
	bclr		#Bit_DSIZE_N256,d0
	move.w	d0,DSIZE_BITS
	rts
Button_DSIZE_WIDE:
	eor.w		#1<<Bit_DSIZE_WIDE,DSIZE_BITS
	jsr		init_pip
	rts

Button_EXP_FAST:
	move.w	#1<<Bit_EXP_FAST,EXP_BITS
	rts
Button_EXP_X2:
	move.w	#1<<Bit_EXP_X2,EXP_BITS
	move.w	#2,exposure
	move.w	#3,shifter
	rts
Button_EXP_X4:
	move.w	#1<<Bit_EXP_X4,EXP_BITS
	move.w	#4,exposure
	move.w	#2,shifter
	rts
Button_EXP_X8:
	move.w	#1<<Bit_EXP_X8,EXP_BITS
	move.w	#8,exposure
	move.w	#1,shifter
	rts
Button_EXP_X16:
	move.w	#1<<Bit_EXP_X16,EXP_BITS
	move.w	#16,exposure
	move.w	#0,shifter
	rts
		
Button_COLOUR_REDUCE:
	pushall
	move.l	edit_list,line_ptr
	jsr		Press_button
	jsr		edit_line
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	move.w	d0,colours_needed
	jsr		Release_button
	popall	
	rts

Button_TEXT_SIZE:
	pushall
	move.l	edit_list,line_ptr
	jsr		Press_button
	jsr		edit_line
	move.l	line_ptr,a0
	move.l	g_text(a0),scaler
	jsr		Release_button
	popall	
	rts
	
Button_TEXT_SPACE:
	pushall
	move.l	edit_list+4,line_ptr
	jsr		Press_button
	jsr		edit_line
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	move.w	d0,cfnxgap2
	jsr		Release_button
	popall	
	rts

Button_TEXT_SMOOTH:
	pushall
	move.l	edit_list+8,line_ptr
	jsr		Press_button
	jsr		edit_line
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	move.w	d0,cfnsmooth
	jsr		Release_button
	popall	
	rts

Button_ANI_A512:
	move.w	#1<<Bit_ANI_A512,ANI_BITS
	rts
Button_ANI_A256:
	move.w	#1<<Bit_ANI_A256,ANI_BITS
	rts
Button_ANI_A128:
	move.w	#1<<Bit_ANI_A128,ANI_BITS
	rts
Button_FILM_WRAP:
	eor.w		#1<<Bit_FILM_WRAP,FILM_BITS
	rts

Button_REPL_NRM:
	move.w	#1<<Bit_REPL_NRM,REPL_BITS
	rts
Button_REPL_INV:
	move.w	#1<<Bit_REPL_INV,REPL_BITS
	rts

Button_SCALER_FINE:
	move.w	#1<<Bit_SCALER_FINE,SCALER_BITS
	rts
Button_SCALER_CHOP:
	move.w	#1<<Bit_SCALER_CHOP,SCALER_BITS
	rts

Button_SCALER2_FIT:
	move.w	#1<<Bit_SCALER2_FIT,SCALER2_BITS
	rts
Button_SCALER2_KEEP:
	move.w	#1<<Bit_SCALER2_KEEP,SCALER2_BITS
	rts

Button_FLAG_BYTEPIXEL:
	move.w	#1<<Bit_FLAG_BYTEPIXEL,FLAG_BITS
	rts
Button_FLAG_BITPLANES:
	move.w	#1<<Bit_FLAG_BITPLANES,FLAG_BITS
	rts

Button_DIAL_CYB:
	move.w	#1<<Bit_DIAL_CYB,DIAL_BITS
	sf		killspin
	rts
Button_DIAL_FAST:
	move.w	#1<<Bit_DIAL_FAST,DIAL_BITS
	st		killspin
	rts

Button_SORT_LUM:
	jsr		Press_button
	move.b	#sort_LUM,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT_CHR:
	jsr		Press_button
	move.b	#sort_CHR,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT_RED:
	jsr		Press_button
	move.b	#sort_RED,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT_GRN:
	jsr		Press_button
	move.b	#sort_GRN,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT_BLU:
	jsr		Press_button
	move.b	#sort_BLU,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT2_REV:
	jsr		Press_button
	move.b	#sort_REV,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts
Button_SORT2_PER:
	jsr		Press_button
	move.b	#sort_PER,sort_type
	move.w	#-1,DIALOG_BITS
	jsr		Release_button
	rts

Button_RGB_RGB:
	move.w	#1<<Bit_RGB_RGB,RGB_BITS
	jsr		Convert_RGB_2_SLIDER
	move.l	#WIN_Colourstation,d0
	jsr		refresh_passive
	rts
Button_RGB_CMY:
	move.w	#1<<Bit_RGB_CMY,RGB_BITS
	jsr		Convert_RGB_2_SLIDER
	move.l	#WIN_Colourstation,d0
	jsr		refresh_passive
	rts
Button_RGB_HSV:
	move.w	#1<<Bit_RGB_HSV,RGB_BITS
	jsr		Convert_RGB_2_SLIDER
	move.l	#WIN_Colourstation,d0
	jsr		refresh_passive
	rts
Button_PCK_YUV:
	move.w	#1<<Bit_PCK_YUV,PCK_BITS
	jsr		Update_rgb_sliders
	jsr		Draw_YUV_zones
	move.l	#WIN_Colourstation,d0
	jsr		refresh_passive
	rts
Button_PCK_HSV:
	move.w	#1<<Bit_PCK_HSV,PCK_BITS
	jsr		Update_rgb_sliders
	jsr		Draw_YUV_zones
	move.l	#WIN_Colourstation,d0
	jsr		refresh_passive
	rts

Button_PIP_ENAB:
	eor.w		#1<<Bit_PIP_ENAB,PIP_BITS
	rts
	
Button_CUT_RECT:
	move.w	#1<<Bit_CUT_RECT,CUT_BITS
	rts

Button_CUT_JACK:
	move.w	#1<<Bit_CUT_JACK,CUT_BITS
	rts

Button_PROC_STD:
	move.w	#1<<Bit_PROC_STD,PROC_BITS
	sf		ACCEL
	rts
Button_PROC_FAST:
	move.w	#1<<Bit_PROC_FAST,PROC_BITS
	st		ACCEL
	rts

Button_GEN_ON:
	move.w	#1<<Bit_GEN_ON,GEN_BITS
	st		GENLOCK
	push.w	#37
	trap		#14
	addq		#2,sp
	move.w	$FFFF8266.w,d0
	bset		#5,d0
	and.b		#$BF,d0
	move.w	d0,$FFFF8266.w
	bset		#0,$FFFF820A.w
	rts
Button_GEN_OFF:
	move.w	#1<<Bit_GEN_OFF,GEN_BITS
	sf		GENLOCK
	rts	

Button_HANDLE_LARGE:
	move.w	#1<<Bit_HANDLE_LARGE,HANDLE_BITS
	st		LARGE_HANDLES
	rts
Button_HANDLE_SMALL:
	move.w	#1<<Bit_HANDLE_SMALL,HANDLE_BITS
	sf		LARGE_HANDLES
	rts

Button_OPER_MAT:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_MAT,OPER_BITS
	move.w	#1,MATCODE
	rts
Button_OPER_LGHT:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_LGHT,OPER_BITS
	move.w	#2,MATCODE
	rts
Button_OPER_DARK:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_DARK,OPER_BITS
	move.w	#3,MATCODE
	rts
Button_OPER_SAT:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_SAT,OPER_BITS
	move.w	#4,MATCODE
	rts
Button_OPER_FADE:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_FADE,OPER_BITS
	move.w	#5,MATCODE
	rts
Button_OPER_WASH:
	and.w		#%11000000,OPER_BITS
	or.w		#1<<Bit_OPER_WASH,OPER_BITS
	move.w	#6,MATCODE
	rts
Button_OPER_COMP:
	eor.w		#1<<Bit_OPER_COMP,OPER_BITS
	rts

Button_REDUCE_DITHER:
	eor.w		#1<<Bit_REDUCE_DITHER,REDUCE_BITS
	rts
Button_REDUCE_GREY:
	eor.w		#1<<Bit_REDUCE_GREY,REDUCE_BITS
	rts

Button_REDUCE_SPAC:
	move.w	REDUCE_BITS,d0
	bclr		#Bit_REDUCE_FREQ,d0
	bset		#Bit_REDUCE_SPAC,d0
	move.w	d0,REDUCE_BITS
	rts

Button_REDUCE_FREQ:
	move.w	REDUCE_BITS,d0
	bset		#Bit_REDUCE_FREQ,d0
	bclr		#Bit_REDUCE_SPAC,d0
	move.w	d0,REDUCE_BITS
	rts

Button_ENAB_HUE:
	eor.w		#1<<Bit_ENAB_HUE,ENAB_BITS
	jsr		Draw_hsv2_zone
	rts
Button_ENAB_SAT:
	eor.w		#1<<Bit_ENAB_SAT,ENAB_BITS
	jsr		Draw_hsv2_zone
	rts
Button_ENAB_BRI:
	eor.w		#1<<Bit_ENAB_BRI,ENAB_BITS
	jsr		Draw_hsv2_zone
	rts

Button_VIEW_HUE:
	eor.w		#1<<Bit_VIEW_HUE,VIEW_BITS
	rts
Button_VIEW_SAT:
	eor.w		#1<<Bit_VIEW_SAT,VIEW_BITS
	rts
Button_VIEW_BRI:
	eor.w		#1<<Bit_VIEW_BRI,VIEW_BITS
	rts

Button_VIEW_GO:
	rts

Button_COMP_SKIP:
	move.w	#1<<Bit_COMP_SKIP,COMP_BITS
	sf		heavycomp
	rts
Button_COMP_RLE:
	move.w	#1<<Bit_COMP_RLE,COMP_BITS
	st		heavycomp
	rts

Button_BRUSH_B1:
	move.w	#1<<Bit_BRUSH_B1,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#-1,(a0)
	rts
Button_BRUSH_B2:
	move.w	#1<<Bit_BRUSH_B2,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#0,(a0)
	rts
Button_BRUSH_B3:
	move.w	#1<<Bit_BRUSH_B3,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#1,(a0)
	rts
Button_BRUSH_B4:
	move.w	#1<<Bit_BRUSH_B4,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#2,(a0)
	rts
Button_BRUSH_B5:
	move.w	#1<<Bit_BRUSH_B5,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#3,(a0)
	rts
Button_BRUSH_B6:
	move.w	#1<<Bit_BRUSH_B6,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#4,(a0)
	rts
Button_BRUSH_B7:
	move.w	#1<<Bit_BRUSH_B7,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#5,(a0)
	rts
Button_BRUSH_B8:
	move.w	#1<<Bit_BRUSH_B8,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#6,(a0)
	rts
Button_BRUSH_B9:
	move.w	#1<<Bit_BRUSH_B9,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#7,(a0)
	rts
Button_BRUSH_B10:
	move.w	#1<<Bit_BRUSH_B10,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#8,(a0)
	rts
Button_BRUSH_B11:
	move.w	#1<<Bit_BRUSH_B11,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#9,(a0)
	rts
Button_BRUSH_B12:
	move.w	#1<<Bit_BRUSH_B12,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#10,(a0)
	rts
Button_BRUSH_B13:
	move.w	#1<<Bit_BRUSH_B13,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#11,(a0)
	rts
Button_BRUSH_B14:
	move.w	#1<<Bit_BRUSH_B14,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#12,(a0)
	rts
Button_BRUSH_B15:
	move.w	#1<<Bit_BRUSH_B15,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#13,(a0)
	rts
Button_BRUSH_B16:
	move.w	#1<<Bit_BRUSH_B16,BRUSH_BITS
	move.l	BRUSH_RECORD1,a0
	move.w	#14,(a0)
	rts

Button_BRUSH2_C1:
	move.w	#1<<Bit_BRUSH2_C1,BRUSH2_BITS
	move.l	BRUSH_RECORD2,a0
	move.w	#15,(a0)
	move.w	#0,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	rts
Button_BRUSH2_C2:
	move.w	#1<<Bit_BRUSH2_C2,BRUSH2_BITS
	move.l	BRUSH_RECORD2,a0
	move.w	#16,(a0)
	move.w	#1,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	rts
Button_BRUSH2_C3:
	move.w	#1<<Bit_BRUSH2_C3,BRUSH2_BITS
	move.l	BRUSH_RECORD2,a0
	move.w	#17,(a0)
	move.w	#2,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	rts
Button_BRUSH2_C4:
	move.w	#1<<Bit_BRUSH2_C4,BRUSH2_BITS
	move.l	BRUSH_RECORD2,a0
	move.w	#18,(a0)
	move.w	#3,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	rts

Button_BTYPE_NORM:
	cmp.l		#BRUSH_TYPE,BRUSH_RECORD1
	beq.s		.no
	move.l	#BRUSH_TYPE,BRUSH_RECORD1
	move.l	#DUMMY_TYPE,BRUSH_RECORD2
	move.l	BRUSH_RECORD1,a0
	move.l	BRUSH_RECORD2,a1
	move.w	(a0),d0
	move.w	(a1),(a0)
	move.w	d0,(a1)
	move.w	#1<<Bit_BTYPE_NORM,BTYPE_BITS
.no	rts

Button_BTYPE_CUST:
	cmp.l		#BRUSH_TYPE,BRUSH_RECORD2
	beq.s		.no
	move.l	#BRUSH_TYPE,BRUSH_RECORD2
	move.l	#DUMMY_TYPE,BRUSH_RECORD1
	move.l	BRUSH_RECORD1,a0
	move.l	BRUSH_RECORD2,a1
	move.w	(a0),d0
	move.w	(a1),(a0)
	move.w	d0,(a1)
	move.w	#1<<Bit_BTYPE_CUST,BTYPE_BITS
.no	rts

Button_IFACE_PROT:
	move.w	#1<<Bit_IFACE_PROT,IFACE_BITS
	rts

Button_IFACE_FREE:
	move.w	#1<<Bit_IFACE_FREE,IFACE_BITS
	rts
	
