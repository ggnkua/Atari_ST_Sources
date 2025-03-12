*-----------------------------------------------------------------------*
*			 Falcon Apex Animator 68030 sourcecode			*
*-----------------------------------------------------------------------*
*	   		 (C) 1994 Black Scorpion Software (BSS)			*
*-----------------------------------------------------------------------*

; bounce/segment

			COMMENT	HEAD=7

;			OPT	W-
;			OPT	O+,W-

english		=	0
french		=	1
german		=	2

release		=	$FFFF
beta			=	$0000
demo			=	$DEAD

copycode		=	release

language		=	english

*-----------------------------------------------------------------------*
*	Assembly conditions								*
*-----------------------------------------------------------------------*

use_fastram
;debug
nicetimers
;protection
;register
;cutdown
;preview
;FORCEPATH
;SOFTVIDEO
;CUSTOM
;SNAPCODE
;RGBHARD
moveborders

;warning
;EXPOSE_CHEAT

INTRO
FINALGFX
READERS
WRITERS
VIDEO

GEM_IKBD

*-----------------------------------------------------------------------*

	include	includes\header.s

*-----------------------------------------------------------------------*

version1	=	2+'0'
version2	=	4+'0'
version3	=	1+'0'

version		macro
			dc.b		"v",version1,".",version2,version3
			endm

;apexdata_linelen	=	32
apexdata_linelen	=	26

apexdata_len		=	apexdata_linelen*5

undo_thresh		=	(800*600)+256

log_height		=	3072

*-----------------------------------------------------------------------*
*	Macro to insert space for details 
*-----------------------------------------------------------------------*
INFO_POINT	macro
	dc.b	'_SERIAL_'		; code for insert point
	ds.b	5*26			; space for user details
	endm

*-----------------------------------------------------------------------*

	ifd		EXPOSE_CHEAT
EXPOSE:
	endc

APEX:	move.l	sp,a5
	lea		USP_STACK,sp
	move.l	$04(a5),a5
	move.l	$0C(a5),d0
	add.l		$14(a5),d0
	add.l		$1C(a5),d0
	add.l		#$100,d0
	push.l	d0
	push.l	a5
	push.w	d0
	push.w	#$4A
	trap		#1
	lea		12(sp),sp
*-----------------------------------------------------------------------*
;	lea		BSS_START,a0
;	move.l	#(BSS_STOP-BSS_START)/4,d0
;	moveq		#0,d1
;.clr	move.l	d1,(a0)+
;	subq.l	#1,d0
;	bne.s		.clr
*-----------------------------------------------------------------------*
	jsr		Get_MonitorType
	tst.b		d0
	bpl		codeskip
	jmp		Exit_Direct

*-----------------------------------------------------------------------*
	dc.b		"Scorpion"
	dc.l		copycode
*-----------------------------------------------------------------------*

			ifd		register

*-----------------------------------------------------------------------*
apexdata:
*-----------------------------------------------------------------------*
;			dc.b		" Doug Little              ",0
;			dc.b		" Neil Stewart             ",0
;			dc.b		" Andy Younger             ",0
;			dc.b		" Dave Murphy              ",0
;			dc.b		" Phil Matthews            ",0
;			dc.b		" Dave Encill              ",0
;			dc.b		" Yorkshire T.V.           ",0
;			dc.b		" Free demo...             ",0
*-----------------------------------------------------------------------*
;			dc.b		" Intern. "
;			version
;			dc.b		"                 ",0
*-----------------------------------------------------------------------*
			dc.b		" Release. "
			version
			dc.b		"                ",0
*-----------------------------------------------------------------------*
			dc.b		" Dated 25/03/97           ",0
			dc.b		" (C) 1996 BSS             ",0
			dc.b		" Black Scorpion           ",0
*-----------------------------------------------------------------------*

			elseif

			even

			dc.b	'keyslot!'

apexdataspace:		INFO_POINT

apexdata	=	apexdataspace+4

			endc

			even

*-----------------------------------------------------------------------*
codeskip:
*-----------------------------------------------------------------------*
	jsr		Appl_init
	jsr		Graf_handle
	jsr		V_OpenVWork
	lea		int_out,a0
	move.w	(a0)+,DESKTOP_WIDTH
	move.w	(a0)+,DESKTOP_HEIGHT
	addq		#1,DESKTOP_WIDTH
	addq		#1,DESKTOP_HEIGHT
	jsr		V_CloseVWork
	jsr		Appl_exit
*-----------------------------------------------------------------------*
	jsr		Init_DSP
*-----------------------------------------------------------------------*
*	Store old screen data								*
*-----------------------------------------------------------------------*
	push.w	#2
	trap		#14
	addq		#2,sp
	move.l	d0,GEM_SCR
*-----------------------------------------------------------------------*
	dc.w		$A000
	move.l	4(a1),a0
	move.l	data_table(a0),FONT8X8
	move.l	8(a1),a0
	move.l	data_table(a0),FONT8X16
	move.l	#$FCFCFC,COLMASK
	move.w	#1<<2,COLSHIFT
	lea		INITIAL_COLOURS,a0
	lea		COLOURS,a1
	jsr		COPYCOLS
*-----------------------------------------------------------------------*
	hidemouse
	pea		SSP_STACK
	move.w	#32,-(sp)
	trap		#1
	move.l	d0,OLD_SSP
*-----------------------------------------------------------------------*
	
	cache		norm
	sf		active
*-----------------------------------------------------------------------*
	include	includes\apexprot.s
*-----------------------------------------------------------------------*
*	Choose video mode and configure screen memory				*
*-----------------------------------------------------------------------*
Strt:	jsr		Remap_menu_colours
	jsr		Init_mouse
	jsr		Update_palette
	bsr		Mouse_draw
	bsr		Init_VideoMemory
	st		safe
	move.b	#left_button,ICON_BUTTON
	move.w	#I_Draw_brush,ICON	
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	move.w	#station_draw,CURRENT_STATION
*-----------------------------------------------------------------------*
*	Main program code									*
*-----------------------------------------------------------------------*

MAIN_MENU_LOOP:
	ifd		warning
	lea		WIN_INTRO_Alert,a0
	jsr		Dialog
	endc
	jsr		OPEN_MENU

MENU_LOOP:

.loop	bsr		Check_main_macros
	bsr.s		Check_functions
	tst.b		d0
	bne.s		.loop
	jsr		FIND_HELP
	jsr		PRINT_HELP
	jsr		show_pip
	IFD		SNAPCODE
	jsr		SNAPSHOT
	ENDC
	tst.b		PROGRAM_QUIT
	beq.s		.loop
	ifd		warning
	lea		WIN_INTRO_Alert,a0
	jsr		Dialog
	endc
	jmp		Exit_Pulldown
	
Check_functions:
	move.w	ICON,d0
	ble.s		.no
	clr.w		ICON
	push.w	d0
	clr.l		HELP_TEXT
	jsr		PRINT_HELP
	pop.w		d0
	jsr		([FUNCTION_TABLE-4.l,d0.w*4])
	jsr		EMPTY_BUFFER
	clr.b		WAIT_FUNCTION
	moveq		#1,d0
	rts
.no	moveq		#0,d0
ARTS:	rts

*-----------------------------------------------------------------------*
*	Screen mode handlers and general video setup				*
*-----------------------------------------------------------------------*

*-----------------------------------*
Init_VideoMemory:				*
*-----------------------------------*
	jsr		HIDE_MOUSE
	push.b	FREEZE_MENUS
	st		FREEZE_MENUS
	push.b	FREEZE_ICONS
	st		FREEZE_ICONS
	push.b	HOLD_INFOBAR
	st		HOLD_INFOBAR
	push.b	HOLD_VBLANK	
	st		HOLD_VBLANK

	jsr		.main

	pop.b		HOLD_VBLANK
	pop.b		HOLD_INFOBAR
	pop.b		FREEZE_ICONS
	pop.b		FREEZE_MENUS
	jsr		SHOW_MOUSE
	st		UNDO_ENABLE
	cmp.l		#undo_thresh,CANVAS_SIZE
	blt.s		.fine
	sf		UNDO_ENABLE
.fine:
	jsr		LOCATE_RAM
	move.l	STRAM_USED,STRAM_SYS
	move.l	VRAM_USED,VRAM_SYS
	rts



.main	push.w	AIRBRUSH_SIZE
	move.w	#4,AIRBRUSH_SIZE
	jsr		resize_airbrush
	pop.w		AIRBRUSH_SIZE
	jsr		Init_PasteBuffer
	jsr		Init_MorphBuffer
	bsr		Mouse_draw
	ifd		moveborders
	move.w	SCAN_STOP.w,OLD_SCAN_STOP
	move.w	SCAN_START.w,OLD_SCAN_START
	endc
*-----------------------------------*
Video_ReTry:				*
*-----------------------------------*
;	delay		1
	ifd		moveborders
	move.w	OLD_SCAN_STOP,SCAN_STOP.w
	move.w	OLD_SCAN_START,SCAN_START.w
	endc
	move.w	#iface_lgrey,CHAR_COL
	jsr		Update_palette_zone
	tst.b		FIRST_VIDEO
	beq.s		.cont

	lea		WIN_Setup_video,a0
	jsr		Dialog
*-----------------------------------*
.cont

	sf		texture_available
	st		FIRST_VIDEO
*-----------------------------------*
	jsr		disable_stabilizer
	ifd		moveborders
	move.w	#0,SCAN_START.w
	move.w	#2,SCAN_STOP.w
	endc
*-----------------------------------*
	bsr		Clear_fontbuffer
	bsr		Clear_deltas
	bsr		Init_VideoDriver
	sf		Memory_error
*-----------------------------------*
	jsr		Init_FirstDelta
	tst.b		Memory_error
	bne		Video_error
*-----------------------------------*
	bsr		Init_ScreenBuffers
	tst.b		Memory_error
	bne		Video_error
*-----------------------------------*
*	Initialise video paramenters	*
*-----------------------------------*
	bsr		Init_video_variables
	jsr		Init_Y_table
	jsr		Init_font
	jsr		Create_plane_table
	jsr		Init_palette
	jsr		Init_mouse
*-----------------------------------*
*	Change Video-mode			*
*-----------------------------------*
	jsr		clear_video
;	delay		1
	move.w	NEW_MODECODE,d0
	move.l	PHYS_SCR,a0
	jsr		set_video
	jsr		check_genlock
	jsr		Init_Video_extras
	bsr		Mouse_full
*-----------------------------------------------------------------------*
*	Init program									*
*-----------------------------------------------------------------------*
	jsr		INIT_RECOLOUR_LIST
	jsr		clear_video
	st		PALETTE_CHANGED
	st		BITMAP_CHANGED
	jsr		Get_changes
	jsr		init_pip
*-----------------------------------------------------------------------*
*	Program start									*
*-----------------------------------------------------------------------*
	st		MENUPAL_CHANGED
	st		VIDEO_CHANGED
	jsr		Update_palette_zone
	move.w	X_RESOLUTION,d0
	lsr.w		d0
	move.w	d0,MOUSE_X
	move.w	Y_RESOLUTION,d0
	lsr.w		d0
	move.w	d0,MOUSE_Y
	sf		HOLD_COORDS
	jsr		Refresh_info_bar
*-----------------------------------*
	move.w	CANVAS_WIDTH,Morph_width
	move.w	CANVAS_HEIGHT,Morph_height
	clr.w		Morph_x1
	clr.w		Morph_y1
	move.w	CANVAS_WIDTH,Proc_width
	move.w	CANVAS_HEIGHT,Proc_height
	clr.w		Proc_x1
	clr.w		Proc_y1
	move.w	CANVAS_WIDTH,Pro_width
	move.w	CANVAS_HEIGHT,Pro_height
	clr.w		Pro_x1
	clr.w		Pro_y1
	move.w	#255,FG_INDEX
	move.w	#0,BG_INDEX
	move.w	#254,COL1_INDEX
	move.w	#255,COL2_INDEX
	ifd		moveborders
	move.w	SCAN_STOP.w,OLD_SCAN_STOP
	move.w	SCAN_START.w,OLD_SCAN_START
	endc
	clr.w		Window_X
	clr.w		Window_Y
	clr.w		Scale_factor
	jsr		Get_colours
	jsr		Send_fg_2_picker
	jsr		Init_PasteBuffer
	jsr		create_air_mask
	jsr		enable_stabilizer
	rts
*-----------------------------------*
*	Memory problem			*
*-----------------------------------*
Video_error:
	jsr		clear_video
	bsr		Shrink_ScreenBuffers
*-----------------------------------*
	bra		Video_ReTry
*-----------------------------------*

Reset_screens:
	move.l	GEM_SCR,a0
	jsr		unkeep_video
	jsr		EMPTY_BUFFER
	rts

Reset_palette:
	pea		GEM_PALETTE
	move.w	GEM_MODECODE,d0
	and.w		#%111,d0
	beq.s		.bpl1
	subq		#1,d0
	beq.s		.bpl2
	subq		#1,d0
	beq.s		.bpl4
.bpl8	move.w	#256,d0
	bra.s		.keep
.bpl4	moveq		#16,d0
	bra.s		.keep
.bpl2	moveq		#4,d0
	bra.s		.keep
.bpl1	moveq		#2,d0
.keep	push.w	d0
	push.w	#0
	push.w	#93
	trap		#14
	lea		10(sp),sp
	rts

Keep_palette:
	pea		GEM_PALETTE
	move.w	GEM_MODECODE,d0
	and.w		#%111,d0
	beq.s		.bpl1
	subq		#1,d0
	beq.s		.bpl2
	subq		#1,d0
	beq.s		.bpl4
.bpl8	move.w	#256,d0
	bra.s		.keep
.bpl4	moveq		#16,d0
	bra.s		.keep
.bpl2	moveq		#4,d0
	bra.s		.keep
.bpl1	moveq		#2,d0
.keep	push.w	d0
	push.w	#0
	push.w	#94
	trap		#14
	lea		10(sp),sp
	rts

Prepare_for_AES:
	pushall
.wt	tst.b		BUTTONS
	bne.s		.wt
	jsr		Reset_vectors
	move.l	GEM_SCR,a0
	jsr		unkeep_video
	jsr		EMPTY_BUFFER
	jsr		Reset_palette
	showmouse
	popall
	rts

Prepare_for_CUSTOM:
	pushall
	hidemouse
	jsr		EMPTY_BUFFER
	move.l	PHYS_SCR,a0
	move.w	NEW_MODECODE,d0
	jsr		set_video
	bsr.s		VSYNC
	jsr		Init_Video_extras
	jsr		Init_vectors
	jsr		clear_video
	jsr		Update_palette_zone
	popall
	rts

VSYNC:
	pushall
	push.w	#37
	trap		#14
	addq		#2,sp
	popall
	rts

check_genlock:
	tst.b		GENLOCK
	beq.s		.ok
	tst.b		VGA_FLAG
	bne.s		.ok
	push.w	#37
	trap		#14
	addq		#2,sp
	move.w	$FFFF8266.w,d0
	bset		#5,d0
	and.b		#$BF,d0
	move.w	d0,$FFFF8266.w
	bset		#0,$FFFF820A.w
.ok	rts

FIRST_VIDEO:	ds.w	1

*-----------------------------------*
Init_video_variables:			*
*-----------------------------------*
	lea		VIDEO_STRUCTURE,a6
	move.w	modecode_copy(a6),NEW_MODECODE
	move.w	xres_copy(a6),X_RESOLUTION
	move.w	yres_copy(a6),Y_RESOLUTION
	move.w	xfactor_copy(a6),x_factor
	move.w	yfactor_copy(a6),y_factor
	move.w	physwid_copy(a6),physwid
	move.w	logwid_copy(a6),logwid
	move.w	canwid_copy(a6),CANVAS_WIDTH
	move.w	canhig_copy(a6),CANVAS_HEIGHT
	move.l	cansize_copy(a6),CANVAS_SIZE
	move.l	physize_copy(a6),PHYS_SIZE
	move.l	scrsize_copy(a6),SCREEN_SIZE
	move.b	true_copy(a6),TRUE_FLAG
	move.b	extend_copy(a6),EXTEND
	move.b	gensol_copy(a6),gensol
	rts
	
*-----------------------------------*

Mouse_full:
	move.w	#full_height,d0
	yresfactor	d0
	subq		#1,d0
	move.w	d0,MOUSE_YC
	rts

Mouse_draw:
	move.w	#draw_height,d0
	yresfactor	d0
	subq		#1,d0
	move.w	d0,MOUSE_YC
	rts
	
*-----------------------------------*
Create_ScreenBuffers:			*
*-----------------------------------*
	sf		Memory_error
*-----------------------------------*
*	Create PHYS_SCR			*
*-----------------------------------*
	move.l	SCREEN_SIZE,d0
	add.l		#256,d0
	jsr		Add_normal
	tst.l		d0
	bmi		.err
	move.w	d0,PHYS_HANDLE
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,PHYS_SCR
	move.l	d0,MOUSE_SCR
	move.l	d0,a0
	move.l	SCREEN_SIZE,d0
	jsr		memclr
*-----------------------------------*
*	Create LOG_SCR			*
*-----------------------------------*
	move.l	#256,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,LOG_HANDLE
*-----------------------------------*
*	Create PACK_SCR			*
*-----------------------------------*
	move.l	#256,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,PACK_HANDLE
*-----------------------------------*
*	Create FRAME_SCR			*
*-----------------------------------*
	move.l	#256,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,FRAME_HANDLE
*-----------------------------------*
*	Create MAIN graphic-bar		*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,MAINGFX_HANDLE
*-----------------------------------*
*	Create SLIDER graphic-bar	*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,SLIDEGFX_HANDLE
*-----------------------------------*
*	Create GENERAL graphic-bar	*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,GENGFX_HANDLE
*-----------------------------------*
*	Create SWAP graphic-bar		*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,SWAPGFX_HANDLE
*-----------------------------------*
*	Create TEXTURE buffer		*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi		.err
	move.w	d0,TEXTURE_HANDLE
*-----------------------------------*
*	Create AIR buffer			*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,AIRBRUSH_HANDLE
*-----------------------------------*
*	Create FONT buffer		*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,CFN_HANDLE
*-----------------------------------*
*	Create PASTE buffers		*
*-----------------------------------*
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,BRUSH_1_HANDLE
	move.w	d0,BRUSH_HANDLE
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,BRUSH_2_HANDLE
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,BRUSH_3_HANDLE
	moveq		#2,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,BRUSH_4_HANDLE
	clr.w		BRUSH_SELECTED
	clr.w		LAST_BRUSH_SELECTED
.err	rts

*-----------------------------------*
Shrink_ScreenBuffers:			*
*-----------------------------------*
*	Shrink TEXTURE buffer		*
*-----------------------------------*
	move.w	TEXTURE_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
*-----------------------------------*
*	Shrink SWAP graphic-bar		*
*-----------------------------------*
	move.w	SWAPGFX_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
*-----------------------------------*
*	Shrink GENERAL graphic-bar	*
*-----------------------------------*
	move.w	GENGFX_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
*-----------------------------------*
*	Shrink SLIDER graphic-bar	*
*-----------------------------------*
	move.w	SLIDEGFX_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
*-----------------------------------*
*	Shrink MAIN graphic-bar		*
*-----------------------------------*
	move.w	MAINGFX_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
*-----------------------------------*
*	Shrink PACK_SCR			*
*-----------------------------------*
	move.w	PACK_HANDLE,d0
	move.l	CANVAS_SIZE,d1
	add.l		#256,d1
	jsr		Translate_block
	move.w	d0,PACK_HANDLE
*-----------------------------------*
*	Shrink FRAME_SCR			*
*-----------------------------------*
	move.w	FRAME_HANDLE,d0
	move.l	CANVAS_SIZE,d1
	add.l		#256,d1
	jsr		Translate_block
	move.w	d0,FRAME_HANDLE
*-----------------------------------*
*	Shrink LOG_SCR			*
*-----------------------------------*
	move.w	LOG_HANDLE,d0
	move.l	CANVAS_SIZE,d1
	add.l		#256,d1
	jsr		Translate_block
	move.w	d0,LOG_HANDLE
*-----------------------------------*
*	Shrink PHYS_SCR			*
*-----------------------------------*
	move.w	PHYS_HANDLE,d0
	move.l	SCREEN_SIZE,d1
	add.l		#256,d1
	jsr		Resize_block
*-----------------------------------*
*	Locate screen buffers		*
*-----------------------------------*
	move.w	PHYS_HANDLE,d0
	jsr		Find_block
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,PHYS_SCR
	move.l	d0,MOUSE_SCR
*-----------------------------------*
	move.w	LOG_HANDLE,d0
	jsr		Find_block
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,LOG_SCR
*-----------------------------------*
	move.w	PACK_HANDLE,d0
	jsr		Find_block
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,PACK_SCR
*-----------------------------------*
	move.w	FRAME_HANDLE,d0
	jsr		Find_block
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,FRAME_SCR
*-----------------------------------*
.no	sf		Memory_error
	rts

*-----------------------------------*
Init_ScreenBuffers:			*
*-----------------------------------*
*	Resize PHYS_SCR			*
*-----------------------------------*
	move.l	VIDEO_STRUCTURE+scrsize_copy,d1
	add.l		#256,d1
	move.w	PHYS_HANDLE,d0
	jsr		Resize_block
	tst.l		d0
	bmi		.err
*-----------------------------------*
*	Resize LOG_SCR			*
*-----------------------------------*
	move.l	VIDEO_STRUCTURE+cansize_copy,d1
	add.l		#256,d1
	move.w	LOG_HANDLE,d0
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,LOG_HANDLE
*-----------------------------------*
*	Resize FRAME_SCR			*
*-----------------------------------*
	move.l	VIDEO_STRUCTURE+cansize_copy,d1
	add.l		#256,d1
	move.w	FRAME_HANDLE,d0
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,FRAME_HANDLE
*-----------------------------------*
*	Resize PACK_SCR			*
*-----------------------------------*
	move.l	VIDEO_STRUCTURE+cansize_copy,d1
	add.l		#256,d1
	move.w	PACK_HANDLE,d0
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,PACK_HANDLE
*-----------------------------------*
*	Resize MAIN graphic-bar		*
*-----------------------------------*
	move.w	MAINGFX_HANDLE,d0
	move.w	#320*16,d1
	jsr		adjust_blocksize
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,MAINGFX_HANDLE
*-----------------------------------*
*	Resize SLIDER graphic-bar	*
*-----------------------------------*
	move.w	SLIDEGFX_HANDLE,d0
	move.w	#320*16,d1
	jsr		adjust_blocksize
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,SLIDEGFX_HANDLE
*-----------------------------------*
*	Resize GENERAL graphic-bar	*
*-----------------------------------*
	move.w	GENGFX_HANDLE,d0
	move.w	#32*88,d1
	jsr		adjust_blocksize
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,GENGFX_HANDLE
*-----------------------------------*
*	Resize SWAP graphic-bar		*
*-----------------------------------*
	move.w	SWAPGFX_HANDLE,d0
	move.w	#32*80,d1
	jsr		adjust_blocksize
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,SWAPGFX_HANDLE
*-----------------------------------*
*	Resize TEXTURE buffer		*
*-----------------------------------*
	move.w	TEXTURE_HANDLE,d0
	move.w	#64*72,d1
	jsr		adjust_blocksize
	jsr		Translate_block
	tst.l		d0
	bmi		.err
	move.w	d0,TEXTURE_HANDLE
*-----------------------------------*
	move.w	PHYS_HANDLE,d0
	jsr		Find_block
	move.l	a0,d0
	add.l		#255,d0
	clr.b		d0
	move.l	d0,PHYS_SCR
	move.l	d0,MOUSE_SCR
	move.w	LOG_HANDLE,d0
	jsr		Find_block
	move.l	a0,LOG_SCR
	move.l	a0,SCALE_SCR
	move.w	FRAME_HANDLE,d0
	jsr		Find_block
	move.l	a0,FRAME_SCR
	move.w	PACK_HANDLE,d0
	jsr		Find_block
	move.l	a0,PACK_SCR
*-----------------------------------*
	move.l	VIDEO_STRUCTURE+scrsize_copy,d1
	add.l		#256,d1
	move.l	d1,SCR_SIZE
	move.l	VIDEO_STRUCTURE+cansize_copy,d1
	add.l		#256,d1
	move.l	d1,LOG_SIZE
	move.l	d1,FRAME_SIZE
	move.l	d1,PACK_SIZE

;	move.w	#32,d1
;	mulu		VIDEO_STRUCTURE+yfactor_copy,d1
;	mulu		VIDEO_STRUCTURE+xres_copy,d1
;	add.l		#256,d1
;	move.l	d1,MENBAR_SIZE
;	move.l	d1,FRMBAR_SIZE

*-----------------------------------*
*	Clear ScreenBuffers
*-----------------------------------*
	move.l	LOG_SCR,a0
	move.l	VIDEO_STRUCTURE+cansize_copy,d0
	jsr		memclr
*-----------------------------------*
	move.l	PACK_SCR,a0
	move.l	VIDEO_STRUCTURE+cansize_copy,d0
	jsr		memclr
*-----------------------------------*
	move.l	FRAME_SCR,a0
	move.l	VIDEO_STRUCTURE+cansize_copy,d0
	jsr		memclr
.err	rts

clear_video:
	move.l	PHYS_SCR,a0
	move.l	SCREEN_SIZE,d0
	jmp		memclr

adjust_blocksize:
	mulu		VIDEO_STRUCTURE+xfactor_copy,d1
	mulu		VIDEO_STRUCTURE+yfactor_copy,d1
	tst.b		VIDEO_STRUCTURE+true_copy
	beq.s		.ok
	add.l		d1,d1
.ok	addq.l	#8,d1
	rts	

adjust_blocksize_test:
	mulu		x_factor,d1
	mulu		y_factor,d1
	tst.b		TRUE_FLAG
	beq.s		.ok
	add.l		d1,d1
.ok	addq.l	#8,d1
	rts	

memory_reqd:
	move.l	SCREEN_SIZE,d0
	add.l		#256,d0
	add.l		CANVAS_SIZE,d0
	add.l		#256,d0
	add.l		CANVAS_SIZE,d0
	add.l		#256,d0
	add.l		CANVAS_SIZE,d0
	add.l		#256,d0
	move.w	#320*16,d1
	bsr		adjust_blocksize_test
	add.l		d1,d0
	move.w	#320*16,d1
	bsr		adjust_blocksize_test
	add.l		d1,d0
	move.w	#32*88,d1
	bsr		adjust_blocksize_test
	add.l		d1,d0
	move.w	#32*80,d1
	bsr		adjust_blocksize_test
	add.l		d1,d0
	move.w	#64*72,d1
	bsr		adjust_blocksize_test
	add.l		d1,d0				; total req'd
	tst.b		VRAM
	beq.s		.done				; if no vram, need this much stram
	move.l	d0,d2
	sub.l		SCREEN_SIZE,d2
	sub.l		#256,d2			; vram can account for this much
	move.l	VRAM_LENGTH,d3
	cmp.l		d2,d3				; and no more
	ble.s		.no
	move.l	d2,d3
.no	sub.l		d3,d0
.done	rts	

;	include	rescode.s

	include	incdir\rescode2.s
	
*-----------------------------------------------*
Init_variables:
*-----------------------------------------------*
	clr.w		Delta_count
	clr.w		LAST_FRAME
	bsr		Mouse_full
*-----------------------------------------------*
*	Fixed preset options				*
*-----------------------------------------------*
	jsr		Button_BRUSH_B1
	jsr		Button_BRUSH2_C1
	move.w	#1<<Bit_GEN_OFF,GEN_BITS
	clr.w		GRID_BITS
	clr.w		SORT_BITS
	clr.w		SORT2_BITS
*-----------------------------------------------*
*	Floating preset options				*
*-----------------------------------------------*
	lea		VIDEO_STRUCTURE,a6
	move.w	X_RESOLUTION,xres_copy(a6)
	move.w	Y_RESOLUTION,yres_copy(a6)
	move.w	x_factor,xfactor_copy(a6)
	move.w	y_factor,yfactor_copy(a6)
	move.w	physwid,physwid_copy(a6)
	move.w	logwid,logwid_copy(a6)
	move.w	CANVAS_WIDTH,canwid_copy(a6)
	move.w	CANVAS_HEIGHT,canhig_copy(a6)
	move.l	CANVAS_SIZE,cansize_copy(a6)
	move.l	PHYS_SIZE,physize_copy(a6)
	move.l	SCREEN_SIZE,scrsize_copy(a6)
	move.b	TRUE_FLAG,true_copy(a6)
	move.b	EXTEND,extend_copy(a6)
	move.b	gensol,gensol_copy(a6)
*-----------------------------------------------*
	move.w	X_RESOLUTION,d0
	lsr.w		d0
	move.w	d0,MOUSE_X
	move.w	Y_RESOLUTION,d0
	lsr.w		d0
	move.w	d0,MOUSE_Y
*-----------------------------------*
	moveq		#(1<<Bit_VIDEO_PAL),d0
	move.w	GEM_MODECODE,d1
	and.w		#pal,d1
	bne.s		.ok2
	eor.w		#(1<<Bit_VIDEO_PAL)|(1<<Bit_VIDEO_NTSC),d0
.ok2	tst.b		VGA_FLAG
	beq.s		.nv2
	bclr		#Bit_VIDEO_PAL,d0
	bclr		#Bit_VIDEO_NTSC,d0
.nv2	move.w	d0,VIDEO_BITS
*-----------------------------------*
	move.w	#255,FG_INDEX
	move.w	#0,BG_INDEX
	move.w	#254,COL1_INDEX
	move.w	#255,COL2_INDEX
	move.w	#-1,DIALOG_BITS
	st		HOLD_COORDS
	rts
	
Set_Palette:
	tst.b		TRUE_FLAG
	bne.s		.skip
	pea		COLOURS
	push.w	#256
	push.w	#0
	push.w	#93
	trap		#14
	lea		10(sp),sp
	rts
.skip	clr.l		$FFFF9800.w
	rts

Get_MonitorType:
	sf		VGA_FLAG
	push.w	#89
	trap		#14
	addq		#2,sp
	tst.w		d0
	beq.s		.mono
	cmp.w		#2,d0
	seq		VGA_FLAG
	moveq		#0,d0
	rts
.mono	moveq		#-1,d0
	rts

*-----------------------------------------------------------------------*
setup2:	
*-----------------------------------------------------------------------*
	jsr		Init_paths
	jsr		read_prefs
*-----------------------------------------------------------------------*
	jsr		normal_zoom
	jsr		Init_Blocklists
	jsr		Init_variables
	jsr		Prepare_font
	jsr		Init_font
	jsr		Init_colours
	jsr		Init_digilines
*-----------------------------------------------------------------------*
*	Create buffers for screens and internal management			*
*-----------------------------------------------------------------------*
	jsr		Create_ScreenBuffers
	tst.b		Memory_error
	beq.s		.nerr
	jmp		Exit_DeAllocate
*-----------------------------------------------------------------------*
*	Enter 320*200 256-colour mode for video selector			*
*-----------------------------------------------------------------------*
.nerr	addq.b	#1,HOLD_VBLANK
*-----------------------------------------------------------------------*
	move.w	#vga|pal,d2
	move.w	GEM_MODECODE,d0
	and.w		d2,d0
	not.w		d2
	move.w	d0,d3
	move.w	NEW_MODECODE,d1
	move.w	d1,d4
	and.w		d2,d1
	or.w		d1,d0
	eor.w		d3,d4
	btst		#vga_bit,d4
	beq.s		.ok
	bclr		#pal_bit,d0
	eor.w		#lace,d0
.ok:	or.w		#$8000,d0
	move.w	d0,NEW_MODECODE
	move.l	PHYS_SCR,a0
	jsr		set_video	
	jsr		check_genlock
	jsr		Init_Video_extras
	rts
	
*-----------------------------------------*
Init_VideoDriver:					*
*-----------------------------------------*
	lea		VIDEO_STRUCTURE,a6
*-----------------------------------------*
	move.w	NEW_MODECODE,d7		; get basis for new modecode
	and.w		#vga,d7			; keep vga flag
*-----------------------------------------*
	move.w	VCOL_BITS,d0		; get colour flags
	moveq		#0,d1
	btst		#Bit_VCOL_TRUE,d0		; check for TC
	beq.s		.ntc
	moveq		#1,d1				; set true flag
	or.w		#true,d7			; update modecode
.ntc	move.b	d1,true_copy(a6)
	bne.s		.n256
	or.w		#bpl8,d7			; otherwise 256-col
*-----------------------------------------*
.n256	move.w	VIDEO_BITS,d0
	or.w		#pal,d7			; set up pal if selected
	move.w	#20,ms
	btst		#Bit_VIDEO_NTSC,d0
	beq.s		.pal
	move.w	#16,ms
	bclr		#pal_bit,d7			; otherwise ntsc
.pal	cmp.w		#1<<Bit_RES_HIGH,RES_BITS
	beq.s		.dw
	cmp.w		#1<<Bit_RES_MED1,RES_BITS
	bne.s		.ndw
.dw	or.w		#hires,d7			; set up high-res
.ndw	cmp.w		#1<<Bit_RES_HIGH,RES_BITS
	beq.s		.dh
	cmp.w		#1<<Bit_RES_MED2,RES_BITS
	bne.s		.ndh
.dh	or.w		#lace,d7			; set up interlace
.ndh	move.w	d7,d0				; keep copy of non-corrected lace bit
	btst		#vga_bit,d7
	beq.s		.nv2
	move.w	#14,ms
	eor.w		#lace,d7			; if vga, lace is inverse
*-----------------------------------------*
.nv2	move.w	d7,modecode_copy(a6)	; store new modecode
*-----------------------------------------*
	move.w	#200,yres_copy(a6)	; initial y-res
	move.w	#1,yfactor_copy(a6)	; initial y-factor
	btst		#lace_bit,d0		; check for lace
	beq.s		.ylow
	lsl.w		yres_copy(a6)		; if so, double y-res
	lsl.w		yfactor_copy(a6)		; and double y-factor
*-----------------------------------------*
.ylow	move.w	#320,xres_copy(a6)	; initial x-res
	move.w	#1,xfactor_copy(a6)	; initial x-factor
	btst		#hires_bit,d7		; check for lace
	beq.s		.xlow
	lsl.w		xres_copy(a6)		; if so, double x-res
	lsl.w		xfactor_copy(a6)		; and double x-factor
*-----------------------------------------*
.xlow	tst.b		true_copy(a6)		; check for true colour
	bne.s		.true				; if so, exit
*-----------------------------------------*
.plan	move.w	xres_copy(a6),d1
	and.w		#-16,d1
	move.w	d1,physwid_copy(a6)
	move.w	canwid_copy(a6),d1
	and.w		#-16,d1
	move.w	d1,logwid_copy(a6)
*-----------------------------------------*
	move.w	canwid_copy(a6),d0
	mulu		canhig_copy(a6),d0
	move.l	d0,cansize_copy(a6)
*-----------------------------------------*
	move.w	#200,d0
	mulu		yfactor_copy(a6),d0
	mulu		xres_copy(a6),d0
	move.l	d0,physize_copy(a6)
*-----------------------------------------*
	move.w	#240,d0
	tst.b		VGA_FLAG
	bne.s		.vga1
	move.w	#230,d0
.vga1	mulu		yfactor_copy(a6),d0
	mulu		xres_copy(a6),d0
	move.l	d0,scrsize_copy(a6)
	bra.s		.exit
*-----------------------------------------*
.true	move.w	xres_copy(a6),d1
	add.w		d1,d1
	move.w	d1,physwid_copy(a6)
	move.w	canwid_copy(a6),d1
	add.w		d1,d1
	move.w	d1,logwid_copy(a6)
*-----------------------------------------*
	move.w	canwid_copy(a6),d0
	mulu		canhig_copy(a6),d0
	add.l		d0,d0
	move.l	d0,cansize_copy(a6)
*-----------------------------------------*
	move.w	#200,d0
	mulu		yfactor_copy(a6),d0
	mulu		xres_copy(a6),d0
	add.l		d0,d0
	move.l	d0,physize_copy(a6)
*-----------------------------------------*
	move.w	#240,d0
	tst.b		VGA_FLAG
	bne.s		.vga2
	move.w	#230,d0
.vga2	mulu		yfactor_copy(a6),d0
	mulu		xres_copy(a6),d0
	add.l		d0,d0
	move.l	d0,scrsize_copy(a6)
*-----------------------------------------*
.exit	rts

*-----------------------------------------*
Clear_fontbuffer:
*-----------------------------------------*
	move.w	CFN_HANDLE,d0
	moveq		#2,d1
	jsr		Resize_block
	sf		font_loaded
	rts

*-----------------------------------------*
Clear_deltas:					*
*-----------------------------------------*
	tst.w		Delta_count
	beq.s		.rts
	jsr		Frame_end
.cont	move.w	CUR_DELTAFRAME,d0
	beq.s		.repd
	jsr		Remove_frame
	subq		#1,CUR_DELTAFRAME
	bra.s		.cont
.repd	move.l	LOG_SCR,a0
	jsr		CLEAR_CANVAS
	jsr		COPY_LOG_2_FRAME
	st		BITMAP_CHANGED
	jsr		Get_changes
.rts	rts

*-----------------------------------------------------------------------*

	include	includes\memory.s

*-----------------------------------------------------------------------*
		
Redraw_menu_icons:
	tst.b		FREEZE_MENUS
	bne		.rts
	tst.b		DRAW_LOOP
	bne		.rts		
	pushall
	jsr		Remap_menu_bars
	jsr		HIDE_MOUSE
	move.w	MAINGFX_HANDLE,d0
	jsr		Find_block
	jsr		Draw_menu_bar
	move.w	GENGFX_HANDLE,d0
	jsr		Find_block
	jsr		Draw_menu_bar
	jsr		update_ram_bar
	jsr		Update_time_bar
	move.w	SLIDEGFX_HANDLE,d0
	jsr		Find_block
	jsr		Draw_menu_bar
	jsr		Update_pos_bar
	move.w	SWAPGFX_HANDLE,d0
	jsr		Find_block
	jsr		Draw_menu_bar
	bsr		Update_tween_button
	move.w	CURRENT_STUDIO,d1
	jsr		Select_icon
	move.w	CURRENT_FUNCTION,d1
	cmp.w		#last_tool,d1
	bge.s		.go
	move.w	THIS_STATION,d7
	cmp.w		CURRENT_STATION,d7
	bne.s		.skip
.go	jsr		Select_icon
.skip	st		active
	jsr		SHOW_MOUSE
	popall
.rts	rts

Select_icon:
	tst.w		d1
	ble.s		.exit
	mulu		#icon_len,d1
	lea		ICON_DEFINITIONS,a0
	lea		2-icon_len(a0,d1),a0
	move.w	(a0)+,d6
	bmi.s		.exit
	move.w	(a0),d7
	bsr		Press_icon
.exit	rts

Draw_menu_bar:
	cacheoff	d7
	move.w	(a0)+,d5
	tst.b		TRUE_FLAG
	beq.s		.ok
	add.w		d5,d5			; bytes/data
.ok	move.w	physwid,d4
	sub.w		d5,d4
	ext.l		d4			; bytes/skip
	lsr.w		#2,d5			; longs/data
	moveq		#16-1,d6
	and.w		d5,d6
	neg.w		d6
	lea		.jmp(pc,d6.w*2),a6
	lsr.w		#4,d5
	move.w	(a0)+,d7
	subq		#1,d7
	move.l	PHYS_SCR,a1
	move.w	(a0)+,d0
	tst.b		TRUE_FLAG
	beq.s		.ok2
	add.w		d0,d0
.ok2	add.w		d0,a1
	move.w	(a0)+,d0
	mulu		physwid,d0
	add.l		d0,a1
.ylp	move.w	d5,d6
	jmp		(a6)
.xlp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
.jmp	dbra		d6,.xlp
	add.l		d4,a1
	dbra		d7,.ylp
	cacheon	d7
	rts
	
Update_tween_button:
	moveq		#0,d0
	move.b	TWEEN_TYPE,d0
	move.b	(TWEEN_LOOKUP.l,d0.w),TWEEN_DATA
	move.w	#2,d1
	move.w	#(10*16),d2
	move.w	#15,d3
	move.w	#(11*16)-1,d4
	lea		TWEEN_DATA,a0
	jsr		centre_justify
	rts
	
Press_icon:
	tst.b		TRUE_FLAG
	bne		Press_icon_true
	and.w		#-16,d6
	move.l	PHYS_SCR,a0
	xresfactor	d6
	add.l		d6,a0
	yresfactor	d7
	add.l		(PHYS_Y.l,d7.w*4),a0
	move.w	physwid,d1
	moveq		#16,d0
	yresfactor	d0
	subq		#1,d0
	mulu		d0,d1
	add.l		d1,a0
	moveq		#16,d0
	yresfactor	d0
	subq		#2,d0
	move.w	physwid,d5
	cmp.w		#2,x_factor
	beq.s		.ylo2	
.ylop	sub.w		d5,a0
po	set		0
	rept		8
	move.w	po(a0),d1
	lsr.w		d1
	move.w	d1,po(a0,d5.w)
po	set		po+2
	endr
	dbra		d0,.ylop
	moveq		#0,d0
	bra		.stop
.ylo2	sub.w		d5,a0
po	set		0
	rept		8
	move.w	00+po(a0),d1
	swap		d1
	move.w	16+po(a0),d1
	lsr.l		d1
	move.w	d1,16+po(a0,d5.w)
	swap		d1
	move.w	d1,00+po(a0,d5.w)
po	set		po+2
	endr
	dbra		d0,.ylo2
	moveq		#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.stop	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

Press_icon_true:
	add.w		d6,d6
	move.l	PHYS_SCR,a0
	xresfactor	d6
	add.l		d6,a0
	yresfactor	d7
	add.l		(PHYS_Y.l,d7.w*4),a0
	moveq		#16,d0
	xresfactor	d0
	push.w	d0
	push.l	a0
	move.w	physwid,d1
	moveq		#16,d0
	yresfactor	d0
	subq		#1,d0
	mulu		d0,d1
	add.l		d1,a0
	moveq		#16,d0
	yresfactor	d0
	subq		#2,d0
	move.w	physwid,d5
	moveq		#16,d4
	xresfactor	d4
	add.w		d4,a0
	add.w		d4,a0
	subq		#2,d4
	move.l	a0,a1
	subq		#2,a0
.ylp	sub.w		d5,a0
	move.l	a0,a2
	move.l	a1,a3
	move.w	d4,d6
.xlp	move.w	-(a2),-(a3)
	dbra		d6,.xlp
	clr.w		-(a3)
	sub.w		d5,a1
	dbra		d0,.ylp
	pop.l		a1
	pop.w		d0
	subq		#1,d0
.x	clr.w		(a1)+
	dbra		d0,.x
	rts
	
Update_pos_bar:
Update_position_bar:
	move.w	CUR_DELTAFRAME,d0
	addq.w	#1,d0
	jsr		NUM2ASCII
	lea		NUM_TEXT,a0
	lea		POSBAR_TEXT,a1
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	subq		#1,d0
.cop1	move.b	(a0)+,(a1)+
	dbra		d0,.cop1

;	push.l	a1
;	move.w	Delta_count,d0
;	jsr		NUM2ASCII
;	pop.l		a1
;	move.b	#':',(a1)+
;	lea		NUM_TEXT,a0
;	move.b	(a0)+,d0
;	addq		#1,d0
;	add.b		d0,POSBAR_TEXT
;	subq		#2,d0
;.cop2	move.b	(a0)+,(a1)+
;	dbra		d0,.cop2

	moveq		#PBAR_Xmin,d0
	move.w	#PBAR_Xmax,d1
	move.b	POSBAR_TEXT,d7
	ext.w		d7
	mulu		#6,d7
	addq		#4,d7
	addq		#1,d1
	sub.w		d0,d1
	ext.l		d1
	push.w	d1
	divu		Delta_count,d1
	move.w	d1,d3			; width
	pop.w		d1
	move.w	d3,d4
	sub.w		d7,d4
	bpl.s		.ok1
	add.w		d4,d1
.ok1	mulu		CUR_DELTAFRAME,d1
	divu		Delta_count,d1
	add.w		d1,d3
	add.w		d0,d1
	add.w		d0,d3			; x2
	add.w		d1,d7			; x max
	move.w	d3,d4
	sub.w		d7,d4
 	bpl.s		.okwd
	sub.w		d4,d3
.okwd	move.w	#PBAR_Xmax,d4
	sub.w		d3,d4
	bpl.s		.okx1
	add.w		d4,d1
	add.w		d4,d3
.okx1	cmp.w		#PBAR_Xmin,d1
	bge.s		.okx2
	moveq		#PBAR_Xmin,d1
.okx2	move.w	#PBAR_Ymin,d2
	move.w	#PBAR_Ymax,d4
	movem.w	d1/d3,-(sp)
	jsr		Depressed_bar
	movem.w	(sp)+,d1/d3
	sub.w		d1,d3
	lsr.w		d3
	moveq		#0,d0
	move.b	POSBAR_TEXT,d0
	mulu		#3,d0
	sub.w		d0,d1
;	addq		#1,d1
	add.w		d3,d1
	add.w		x_factor,d1
	move.w	d1,CHAR_X
	move.w	#PBAR_Ymin+5,CHAR_Y
	jsr		Centre_CHAR_Y
	lea		POSBAR_TEXT,a0
	jsr		PRINT_ASCIINUM_A0
.stop	rts

Centre_CHAR_Y:
	moveq		#5,d4
	cmp.w		#1,x_factor
	beq.s		.ok
	moveq		#7,d4
.ok	lsr.w		d4
	divu		y_factor,d4
	sub.w		d4,CHAR_Y
	rts
	
Redraw_position_bar:
	tst.b		DRAW_LOOP
	bne.s		.no
	cmp.b		#no_menu,MENU_STATE
	beq.s		.no
	move.w	#PBAR_Xmin,d1
	move.w	#PBAR_Xmax-PBAR_Xmin,d3
	move.w	#PBAR_Ymin,d2
	move.w	#PBAR_Ymax-PBAR_Ymin,d4
	move.w	SLIDEGFX_HANDLE,d0			
	bsr		Patch_menu
	bsr		Update_pos_bar
.no	rts

Update_shuttle_bar:
	move.w	#SBAR_Xmin,d0
	move.w	#SBAR_Xmax,d1
	moveq		#SBAR_Width,d7
	sub.w		d0,d1
	mulu		CURRENT_DIST,d1
	divu		MAXIMUM_DIST,d1
	add.w		d0,d1
	addq		#1,d1
	move.w	d1,d3
	move.w	d7,d2
	lsr.w		d2
	sub.w		d2,d1
	add.w		d2,d3
	move.w	#SBAR_Ymin+2,d2
	move.w	#SBAR_Ymax-2,d4
	subq		#1,d3
	jsr		Raised_bar
.stop	rts

Patch_menu:
	movem.l	d1-d4,-(sp)
	jsr		Find_block
	movem.l	(sp)+,d1-d4
	addq		#1,d3
	addq		#1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	tst.b		TRUE_FLAG
	bne.s		.true
.bpl	and.w		#-16,d1
	add.w		#16,d3
	lsr.w		#4,d3
	move.l	PHYS_SCR,a1
	add.w		d1,a1
	move.w	d2,d5
	mulu		physwid,d5
	add.l		d5,a1
	move.w	4(a0),d0
	sub.w		d0,d1
	move.w	6(a0),d0
	sub.w		d0,d2
	move.w	0(a0),d5
	ext.l		d5
	addq.l	#8,a0
	add.w		d1,a0
	mulu		d5,d2
	add.l		d2,a0
	subq		#1,d4
.ylp	move.w	d3,d6
	subq		#1,d6
	move.l	a0,a3
	move.l	a1,a2
.xlp	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	dbra		d6,.xlp
	add.l		d5,a0
	add.w		physwid,a1		
	dbra		d4,.ylp
	bra		.rts
.true	move.l	PHYS_SCR,a1
	move.w	d1,d5
	add.w		d5,d5
	add.w		d5,a1
	move.w	d2,d5
	mulu		physwid,d5
	add.l		d5,a1
	move.w	4(a0),d0
	sub.w		d0,d1
	move.w	6(a0),d0
	sub.w		d0,d2
	move.w	0(a0),d5
	add.w		d5,d5
	ext.l		d5
	addq.l	#8,a0
	add.w		d1,d1
	add.w		d1,a0
	mulu		d5,d2
	add.l		d2,a0
	subq		#1,d3
	subq		#1,d4
.ylp2	move.w	d3,d6
	move.l	a0,a3
	move.l	a1,a2
.xlp2	move.w	(a3)+,(a2)+
	dbra		d6,.xlp2
	add.l		d5,a0
	add.w		physwid,a1		
	dbra		d4,.ylp2
.rts	rts

*-----------------------------------------------------------------------*
setup1:
*-----------------------------------------------------------------------*
	sf		compat_mode
	IFD		RGBHARD
	st		force_hard
	ELSEIF
	sf		force_hard
	ENDC
	ifd		SOFTVIDEO
	st		compat_mode
	endc
	jsr		keep_video
	jsr		Keep_palette
*-----------------------------------------------------------------------*
*	Read CPX cookie / work out GEM ram needed					*
*-----------------------------------------------------------------------*
	jsr		ReadCookie	
*-----------------------------------------------------------------------*
*	Get length of TT-RAM								*
*-----------------------------------------------------------------------*
	moveq		#VRAM_only,d0
	jsr		Get_ram

	ifnd		use_fastram
	clr.l		d0
	endc

	sf		VRAM
	tst.l		d0
	sne		VRAM
	move.l	d0,vram_free
*-----------------------------------------------------------------------*
*	Get length of ST-RAM								*
*-----------------------------------------------------------------------*
	moveq		#STRAM_only,d0
	jsr		Get_ram

;	move.l	#(1024*1024*1),d0

	tst.l		d0
	bne.s		.cont
	jmp		Exit_merr
.cont	move.l	d0,stram_free
*-----------------------------------------------------------------------*
*	Allocate correct amount of TT-RAM (minus menuspace if poss)		*
*-----------------------------------------------------------------------*
TTram	moveq		#0,d0
	tst.b		VRAM
	beq.s		.noTT
	move.l	vram_free,d0
	move.w	vram_code,d1
	beq.s		.grab
	cmp.w		#grab_max,d1
	beq.s		.max
.leav	sub.l		vram_value,d0
	bra.s		.grab
.max	cmp.l		vram_value,d0
	ble.s		.grab
	move.l	vram_value,d0
.grab	tst.l		d0
	bgt.s		.go
	sf		VRAM
	bra.s		.noTT
.go	and.b		#-4,d0
	move.l	d0,VRAM_LENGTH
	jsr		Allocate_VRAM
	addq.l	#3,d0
	and.b		#-4,d0
.noTT	move.l	d0,VRAM_START
*-----------------------------------------------------------------------*
*	Allocate correct amount of ST-RAM (minus menuspace if reqd)		*
*-----------------------------------------------------------------------*
STram	move.l	stram_free,d0
	move.w	stram_code,d1
	beq.s		.grab
	cmp.w		#grab_max,d1
	beq.s		.max
.leav	sub.l		stram_value,d0
	bra.s		.grab
.max	cmp.l		stram_value,d0
	ble.s		.grab
	move.l	stram_value,d0
.grab	push.l	d0
	jsr		memory_reqd
	move.l	d0,d7
	add.l		#8192,d7		; room to move
	pop.l		d0
	cmp.l		d7,d0			;#(phys_width*230)+10000,d0
	bpl.s		.cont
	jmp		Exit_merr
.cont	and.b		#-4,d0
	move.l	d0,STRAM_LENGTH
	jsr		Allocate_STRAM
	addq.l	#3,d0
	and.b		#-4,d0
	move.l	d0,STRAM_START
	rts

*-----------------------------------------------------------------------*
*	Keyboard macro interpreter							*
*-----------------------------------------------------------------------*

MAIN_MACROS		dc.l	Draw_macros

Do_extra_macros:
	pushall
	st		WAIT_FUNCTION
	bsr.s		Check_extra_macros
	bsr		Check_functions
	popall
	rts

Check_extra_macros:
	jsr		GET_CHAR
	tst.b		d1
	beq.s		.rts
	move.b	d1,MACRO_KEY
	lea		Extra_macros,a0
	bsr.s		Check_macros
.rts	rts

Check_main_macros:
	jsr		GET_CHAR
	tst.b		d1
	beq.s		.rts
	move.l	MAIN_MACROS(pc),a0
	bsr.s		Check_macros
.rts	rts

Check_macros:
	move.b	d1,scancode
	moveq		#0,d2
	move.b	d1,d2
	move.w	-2(a0,d2.w*2),d2
	beq.s		.rts
	move.w	d2,ICON
	clr.b		ICON_BUTTON
	clr.b		MACRO_KEY
.rts	rts
	
*-----------------------------------------------------------------------*
*	Main program subroutines							*
*-----------------------------------------------------------------------*

Permanent_tool:
	move.w	THIS_STATION,OLD_TSTATION
	move.w	CURRENT_FUNCTION,OLD_FUNCTION
	move.l	FUNCTION_ADDR,OLD_FUNCTION_ADDR
	rts

Reset_tool:
	move.w	OLD_TSTATION,THIS_STATION
	move.w	OLD_FUNCTION,CURRENT_FUNCTION
	move.l	OLD_FUNCTION_ADDR,FUNCTION_ADDR
	rts

OLD_TSTATION:	ds.w	1

Setup_tool:
	bsr.s		Update_chstate
	move.l	a0,FUNCTION_ADDR
	move.w	d0,CURRENT_FUNCTION
	move.w	d1,THIS_STATION
	bsr		Redraw_menu_icons
.skip	rts
	
Update_chstate:
	pushall
	move.b	CROSSHAIR,d0
	cmp.b		CROSSCOPY,d0
	beq.s		.out
	jsr		HIDE_MOUSE
	move.b	CROSSCOPY,CROSSHAIR
	jsr		SHOW_MOUSE
.out	popall
	rts

Tool_dialog_box:
	pushall
	push.w	THIS_STATION
	push.w	CURRENT_FUNCTION
	move.w	d0,CURRENT_FUNCTION
	move.w	d1,THIS_STATION
	cmp.w		#I_Draw_brush,LAST_ICON
	blt.s		.no
	cmp.w		#I_Draw_exchange,LAST_ICON
	bgt.s		.no
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.no
.go	move.w	d0,OLD_FUNCTION
.no	push.l	a1
	bsr		Redraw_menu_icons
	pop.l		a0
	jsr		Dialog
	jsr		Check_menu
	pop.w		CURRENT_FUNCTION
	pop.w		THIS_STATION
	popall
	rts

Keep_undo:
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	st		UNDO_VALID
	rts

Keep_undo_maybe:
	tst.b		UNDO_ENABLE
	beq.s		.rts
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	st		UNDO_VALID
.rts	rts
	
Undo_changes:
	tst.b		UNDO_VALID
	beq.s		.err
	jsr		HIDE_MOUSE
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	lsr.l		#2,d0
	jsr		SWAP_LONGS
	st		BITMAP_CHANGED
	jsr		Superscaler
	jsr		SHOW_MOUSE
.err	rts

Restore_image:
	jsr		HIDE_MOUSE
	jsr		Keep_undo
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	st		BITMAP_CHANGED
	jsr		Superscaler
	jsr		SHOW_MOUSE
.err	rts

Check_tool_dialog:
	move.b	ICON_BUTTON,d2
	beq.s		.cont
	cmp.b		#left_button,d2
	beq.s		.cont
	bsr		Tool_dialog_box
.cont	rts

*-----*	Tool functions		*-----------------------------------*
	
Draw_brush:
	moveq		#I_Draw_brush,d0
	moveq		#station_draw,d1
	lea		Draw_brush_code,a0
	lea		WIN_Draw_brush,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts

Draw_brush_code:
	init_tool
	st		BITMAP_CHANGED
	move.w	DRAW_BITS,d0
	btst		#Bit_DRAW_LASSOO,d0
	bne		Lassoo_zone
	bsr		INIT_PENCIL
	jsr		Keep_undo_maybe
;	bsr		Keep_undo
	bsr		SET_PHYS_CANVAS
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	move.w	#8,brush_deviance
	push.w	DRAW_BITS
	cmp.w		#15,BRUSH_TYPE
	blt.s		.con2
	move.w	#1<<Bit_DRAW_STREAK,DRAW_BITS
.con2	tst.w		BRUSH_TYPE
	bpl.s		.loop
	clr.w		brush_deviance
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.w	DRAW_BITS,d0
	btst		#Bit_DRAW_STREAK,d0
	beq.s		.line
	move.w	d3,X1
	move.w	d4,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	d3,d1
	move.w	d4,d2
	move.w	FG_COLOUR,d0
	tst.w		BRUSH_TYPE
	bmi.s		.dot
	bsr		DRAW_LOG_BRUSH
	bra.s		.done
.dot	jsr		PLOT_LOG_DOT
	bra.s		.done
.line	move.w	X2,X1
	move.w	Y2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BRUSHLINE
.done	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	pop.w		DRAW_BITS
	clr.w		brush_deviance
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	bsr		SET_LOG_CANVAS
	bsr		MOUSE_WAITMODE
	rts

Pro_area:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Pro_area,d0
	moveq		#station_pro,d1
	lea		Pro_area_code,a0
	bsr		Setup_tool
	jsr		HIDE_MOUSE
	st		CROSSHAIR
	jsr		SHOW_MOUSE
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	jsr		Check_menu
.skip	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
	endc
.exit	rts

Pro_area_code:
	ifnd		cutdown
	init_tool
	jsr		Init_cut_coords
	bsr		INIT_PENCIL
	bsr		Keep_undo
	sf		UNDO_VALID
	sf		CROSSHAIR
	push.b	ENABLE_GUIDES
	st		SOFTWARE_MOUSE
	sf		ENABLE_GUIDES
	jsr		Superscaler
	jsr		Update_mouseptr
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d3-d4,-(sp)
	bsr		COPYBACK
	jsr		Remove_mouseptr
	movem.w	(sp)+,d3-d4
	bsr		Scale_D3D4
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	jsr		DRAW_LOG_OUTLINE
	jsr		Superscale_zone
	jsr		Print_cut_coords
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	jsr		Refresh_info_bar
	clr.w		brush_deviance
	bsr		COPYBACK
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	cmp.w		d3,d1
	ble.s		.ok1
	exg		d3,d1
.ok1	cmp.w		d4,d2
	ble.s		.ok2
	exg		d4,d2
.ok2	move.w	d1,Pro_x1
	move.w	d2,Pro_y1
	move.w	d3,Pro_x2
	move.w	d4,Pro_y2
	sub.w		d1,d3
	addq		#1,d3
	move.w	d3,Pro_width
	sub.w		d2,d4
	addq		#1,d4
	move.w	d4,Pro_height
	jsr		Remove_mouseptr
	pop.b		ENABLE_GUIDES
	sf		SOFTWARE_MOUSE
	jsr		Superscaler
	bsr		Update_chstate
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	bsr		Reset_tool
	endc
	rts

Pro_go:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.rts
.ok	jsr		Keep_undo
	jsr		HIDE_MOUSE
	seticon	I_Pro_go,station_pro
	jsr		Redraw_menu_icons
	addq.b	#1,BUSY
*-----------------------------------------*
*	Init animation range			*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	d0,LEFT_LIMIT
	move.w	d0,RIGHT_LIMIT
	move.w	#1,TFRAME
	move.w	#1,CURFRAME
	move.w	#0,LEFT_CLIP
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_CLIP
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		.strt
	move.w	Delta_count,TFRAME
	move.w	LEFT_CLIP,LEFT_LIMIT
	move.w	RIGHT_CLIP,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
	sub.w		d0,d1
	addq		#1,d1
	move.w	d1,TFRAME
	cmp.w		#3,d1
	blt		.done
*-----------------------------------------*
*	Check mode & get info from user	*
*-----------------------------------------*
.cont	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
.strt	tst.b		TRUE_FLAG
	bne.s		.tc
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.done
.tc	push.w	CUR_DELTAFRAME
	move.w	LEFT_LIMIT,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.skp1
	jsr		Frame_goto
.skp1	jsr		Redraw_menu_icons
	jsr		Superscaler
*-----------------------------------------*
*	Start DSP filter				*
*-----------------------------------------*
	jsr		Init_DSP_HSVMASK
	move.w	TFRAME,MAXFRAME
	st		FRAMECOUNT
*-----------------------------------------------*
.loop	move.l	LOG_SCR,a0
	move.w	Pro_y1,d0
	mulu		logwid,d0
	move.w	Pro_x1,d1
	ext.l		d1
	add.l		d1,d1
	add.l		d0,d1
	add.l		d1,a0
	move.w	Pro_height,d7
	subq		#1,d7
.ylp	move.l	a0,a1
	move.w	Pro_width,d6
	subq		#1,d6
.xlp	dspwrite	(a1)
	dspread	(a1)+
	dbra		d6,.xlp
	add.w		logwid,a0
	dbra		d7,.ylp
	st		BITMAP_CHANGED
*-----------------------------------------------*
	jsr		Superscaler
	cmp.b		#tween_frame,TWEEN_TYPE
	bne.s		.ct
	pop.w		d0
	bra		.done
.ct	jsr		Get_changes				; store 'LOG' & void 'PACK'
	tst.l		d0
	bmi		.err
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		RIGHT_LIMIT,d0
	ble.s		.ok2
	move.w	LEFT_LIMIT,d0
.ok2	jsr		Frame_goto
	jsr		Redraw_menu_icons
	jsr		Superscaler
	tst.b		BUTTONS
	bne.s		.err
	tst.b		Memory_error
	bne.s		.err
	addq		#1,CURFRAME
	subq		#1,TFRAME
	bne		.loop
.err	pop.w		d0
	jsr		Frame_goto
.done	subq.b	#1,BUSY
	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	jsr		Superscaler
	reseticon
	jsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	endc
.rts	rts

DO_AFILL:
	move.l	sp,stack
	move.w	d1,fill_x
	move.w	d2,fill_y

	move.l	EDGEBUFFER_PTR,d0
	move.l	d0,sp
	add.l		#64000,sp
	add.l		#256,d0
	move.l	d0,EDGEBUFFER_LIMIT

	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	mulu		CANVAS_HEIGHT,d0
	lsr.l		#3,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.err
	move.l	a0,MASK_SCR

	move.l	LOG_SCR,a0
	move.l	MASK_SCR,a1
	bsr		HSVMASK_SCREEN
	jsr		Init_DSP_HSVMASK

	sf		FILL_ERROR
	push.w	fill_x
	push.w	fill_y
	bsr		SEED_FILL
	addq		#4,sp

.err	move.l	stack,sp
	rts

Pro_fill:
	ifnd		cutdown
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.go
.ok	moveq		#I_Pro_fill,d0
	moveq		#station_pro,d1
	lea		Pro_fill_code,a0
	lea		WIN_Draw_fill,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	endc
.go	rts

Pro_fill_code:
	ifnd		cutdown
	init_tool
	jsr		HIDE_MOUSE
	move.w	FILL_BITS,d0
	bsr		Keep_undo
	jsr		Superscaler
	addq.b	#1,BUSY
*-----------------------------------------*
	move.l	#64000,d0
	bsr		MALLOCATE_normal
	tst.l		d0
	bmi		.prob
	move.l	a0,EDGEBUFFER_PTR
*-----------------------------------------*
	move.w	FILL_BITS,d0
	and.w		#1<<Bit_FILL_BRUSH,d0
	beq.s		.ntxt
*-----------------------------------------*
	move.l	CANVAS_SIZE,d0
	add.l		#256,d0
	bsr		MALLOCATE_fast
	tst.l		d0
	bmi		.prob
	move.l	a0,BACK_SCR
*-----------------------------------------*
	move.l	#HORIZONTAL_MASK,LINE_TYPE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	jsr		READ_LOG_PIXEL		; get mask base
	move.w	d0,OLD_COL
	move.l	BACK_SCR,a0
	bsr		TILE_BACKGROUND
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_AFILL
	bra		.fin
*-----------------------------------------*
.ntxt	move.w	FILL_BITS,d0
	and.w		#1<<Bit_FILL_SOLID,d0
	beq.s		.nbrs
*-----------------------------------------*
	move.l	#HORIZONTAL_HSVMASK,LINE_TYPE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	jsr		READ_LOG_PIXEL		; get mask base
	move.w	d0,OLD_COL
	move.w	d0,FG_COLOUR
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_AFILL
	bra		.fin
*-----------------------------------------*
.nbrs	move.l	#GRADIENT_2D_TRUE,LINE_TYPE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	jsr		READ_LOG_PIXEL		; get mask base
	move.w	d0,OLD_COL
	move.w	CANVAS_WIDTH,d0
	mulu		CANVAS_HEIGHT,d0
	lsr.l		#3,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.prob
	move.l	a0,BACK_SCR
	move.l	a0,a1
	move.l	LOG_SCR,a0
	bsr		HSVMASK_SCREEN
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_AFILL
*-----------------------------------------*
.fin	jsr		Superscaler
	st		BITMAP_CHANGED
.prob	bsr		MRELEASE
	subq.b	#1,BUSY
	jsr		SHOW_MOUSE
	endc
	rts

Pro_brush:
	ifnd		cutdown
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
.ok	moveq		#I_Pro_brush,d0
	moveq		#station_pro,d1
	lea		Pro_brush_code,a0
	lea		WIN_Draw_brush,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	endc
.err	rts

Pro_brush_code:
	ifnd		cutdown
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	push.b	UNDO_ENABLE
	st		UNDO_ENABLE
	move.w	OPER_BITS,d3
	and.w		#1<<Bit_OPER_COMP,d3
	beq.s		.c
	sf		UNDO_ENABLE
.c	jsr		Keep_undo_maybe
	pop.b		UNDO_ENABLE
;	bsr		Keep_undo
	bsr		SET_PHYS_CANVAS
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	move.w	#8,brush_deviance
	bsr		Init_DSP_HSVMASK
	tst.w		BRUSH_TYPE
	bpl.s		.loop
	clr.w		brush_deviance
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.w	d3,X1
	move.w	d4,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	d3,d1
	move.w	d4,d2
	tst.w		BRUSH_TYPE
	bmi.s		.dot
	bsr		DRAW_LOG_HSV
	bra.s		.done
.dot	jsr		PLOT_LOG_HSV
.done	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	clr.w		brush_deviance
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	bsr		SET_LOG_CANVAS
	bsr		MOUSE_WAITMODE
	endc
	rts

Pro_airbrush:
	ifnd		cutdown
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.go
.ok	moveq		#I_Pro_airbrush,d0
	moveq		#station_pro,d1
	lea		Pro_airbrush_code,a0
	lea		WIN_Draw_airbrush,a1
	bsr		Check_tool_dialog
	jsr		create_air_mask
	bsr		Setup_tool
	bsr		Permanent_tool
	endc
.go	rts
	
create_air_mask:
	pushall
	jsr		resize_airbrush
	tst.l		d0
	bmi		.err
	tst.b		TRUE_FLAG
	beq		.err
	move.w	AIRBRUSH_HANDLE,d0
	jsr		Find_block
	move.w	AIRBRUSH_SIZE,NAIR_SIZE
	moveq		#0,d5
	move.w	NAIR_SIZE,d5
	lsr.w		d5
	moveq		#0,d4
	move.w	#256,d4
	swap		d4
	divu.l	d5,d4
	move.w	AIRBRUSH_FLOW,d7
	lsl.w		#8,d7
	lsl.w		#2,d7
	swap		d7
	move.w	NAIR_SIZE,d7
	subq		#1,d7
	moveq		#0,d2
.ylp	swap		d7
	move.w	NAIR_SIZE,d6
	subq		#1,d6
	moveq		#0,d1
.xlp	move.w	d5,d0
	sub.w		d1,d0
	lsl.w		#6,d0
	muls		d0,d0
	move.w	d5,d3
	sub.w		d2,d3
	lsl.w		#6,d3
	muls		d3,d3
	add.l		d3,d0
	push.l	d1
	push.l	d2
	jsr		Root
	pop.l		d2
	pop.l		d1
	lsr.l		#6,d0
	move.l	d5,d3
	sub.w		d0,d3
	bpl.s		.pos
	moveq		#0,d3
.pos	mulu		d7,d3
	mulu.l	d4,d0:d3
	move.w	d0,(a0)+
	addq		#1,d1
	dbra		d6,.xlp
	addq		#1,d2
	swap		d7
	dbra		d7,.ylp
.err	popall
	rts		

resize_airbrush:
	tst.b		TRUE_FLAG
	beq		.kill
	pushall
	addq.b	#1,HOLD_VBLANK
	move.w	AIRBRUSH_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),OAB_SIZE
	move.w	AIRBRUSH_HANDLE,d0
	jsr		Remove_block
	move.w	AIRBRUSH_SIZE,d0
	addq		#1,d0
	mulu		d0,d0
	add.l		d0,d0
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,AIRBRUSH_HANDLE
	move.w	AIRBRUSH_SIZE,NAIR_SIZE
	subq.b	#1,HOLD_VBLANK
	popall	
	moveq		#0,d0
	rts
.err	move.l	OAB_SIZE,d0
	jsr		Add_fast
	move.w	d0,AIRBRUSH_HANDLE
	subq.b	#1,HOLD_VBLANK
	popall	
	moveq		#-1,d0
	rts
.kill	pushall
	addq.b	#1,HOLD_VBLANK
	moveq		#8,d1
	move.w	AIRBRUSH_HANDLE,d0
	jsr		Resize_block
	subq.b	#1,HOLD_VBLANK
	popall
	moveq		#-1,d0
	rts
	
draw_dspair_true:
	move.w	AIRBRUSH_HANDLE,d0
	jsr		Find_block
	move.w	NAIR_SIZE,d4
	move.w	d4,d5
	move.l	LOG_SCR,a4
	move.w	logwid,scrwid
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	move.l	a0,a6
	moveq		#0,d2
.clpt	move.w	d7,d0
	bpl.s		.clpb
	add.w		d0,d5			; crop height
	ble		ACend
	muls		d4,d0			; width in bytes
	add.l		d0,d0
	sub.l		d0,a6			; drop into data
	moveq		#0,d7			; clip top
.clpb	move.w	SCR_HEIGHT,d0	; y-limit
	sub.w		d7,d0
	sub.w		d5,d0			; check for overhang
	bpl.s		.clpr
	add.w		d0,d5			; crop height
	ble		ACend
.clpr	move.w	SCR_WIDTH,d0	; x-limit
	sub.w		d6,d0			; minus x-pos
	sub.w		d4,d0			; minus width
	bpl.s		.clpl			; neg if inside
	add.w		d0,d4			; adjust width
	ble		ACend			; zero width?
	neg.w		d0
	add.w		d0,d0
	move.w	d0,d2			; source x-modulus
.clpl	move.w	d6,d0
	bpl.s		.prnt
	add.w		d0,d4
	ble		ACend
	add.w		d0,d0
	sub.w		d0,a6
	sub.w		d0,d2
	moveq		#0,d6
.prnt	move.l	a4,a0
	mulu		scrwid,d7
	add.l		d7,a0
	add.w		d6,d6
	add.w		d6,a0
	move.l	a0,a1
	move.w	scrwid,d7
	sub.w		d4,d7
	sub.w		d4,d7
	ext.l		d7
	ext.l		d2
	subq		#1,d4
	bmi		ACend
	subq		#1,d5
	bmi		ACend
.ylp	move.w	d4,d1
.xlp	dspwrite	(a1)
	dspwrite	(a6)+
	dspread	(a1)+	
	dbra		d1,.xlp	
	add.l		d2,a6
	add.l		d7,a1
	dbra		d5,.ylp
ACend	rts

Pro_airbrush_code:
	ifnd		cutdown
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	jsr		Keep_undo_maybe
;	bsr		Keep_undo
	st		SOFTWARE_MOUSE
	move.w	NAIR_SIZE,d0
	lsr.w		d0
	addq		#1,d0
	move.w	d0,brush_deviance
	jsr		Init_DSP_HSVAIR
.loop	jsr		Do_extra_macros
	move.w	CANVAS_WIDTH,X1
	move.w	CANVAS_HEIGHT,Y1
	move.w	#0,X2
	move.w	#0,Y2
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	cmp.w		#1<<Bit_AIR_FREE,AIR_BITS
	beq.s		.cont
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq		.skip
.cont	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	bsr		Scale_D3D4
	move.w	d3,X1
	move.w	d4,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	NAIR_SIZE,d0
	lsr.w		d0
	sub.w		d0,d3
	sub.w		d0,d4
	move.w	d3,d6
	move.w	d4,d7
	jsr		draw_dspair_true
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	jsr		Superscale_zone
.skip	cmp.b		#left_button,BUTTONS
	beq		.loop
	clr.w		brush_deviance
	sf		SOFTWARE_MOUSE
	bsr		MOUSE_WAITMODE
	endc
	rts

SET_PHYS_CANVAS:
	tst.b		DRAW_LOOP
	beq.s		.rts
	move.w	CANVAS_WIDTH,d0
	cmp.w		X_RESOLUTION,d0
	bne.s		.rts
	move.w	CANVAS_HEIGHT,d0
	cmp.w		Y_RESOLUTION,d0
	bne.s		.rts
	st		NO_SCALE
	tst.w		Scale_factor
	bne.s		.rts
	st		PHYS_CANVAS
	move.l	LOG_SCR,HOLD_SCR
	move.l	PHYS_SCR,LOG_SCR
.rts	rts

SET_LOG_CANVAS:
	sf		NO_SCALE
	tst.b		PHYS_CANVAS
	beq.s		.rts
	sf		PHYS_CANVAS
	move.l	HOLD_SCR,LOG_SCR
	jsr		COPY_PHYS_2_LOG
.rts	rts


Draw_line:
	moveq		#I_Draw_line,d0
	moveq		#station_draw,d1
	lea		Draw_line_code,a0
	lea		WIN_Draw_line,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts

Draw_line_code:
	init_tool
	st		BITMAP_CHANGED
	jsr		Init_cut_coords
	bsr		INIT_PENCIL
	bsr		Keep_undo
	move.l	#Line_primitive,PRIMITIVE
	move.w	LINE_BITS,d0
	and.w		#1<<Bit_LINE_GRAD,d0
	beq.s		.ok1
	move.l	#Gradline_primitive,PRIMITIVE
.ok1	move.w	LINE_BITS,d0
	and.w		#1<<Bit_LINE_INT,d0
	beq.s		.ok2
	move.l	#Intline_primitive,PRIMITIVE
.ok2	move.w	#8,brush_deviance
	tst.w		BRUSH_TYPE
	bpl.s		.loop
	clr.w		brush_deviance
.loop	jsr		Drag_primitive
	jsr		([PRIMITIVE.l])
.prob	clr.w		brush_deviance
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	rts

Draw_grid:
	moveq		#I_Draw_grid,d0
	moveq		#station_draw,d1
	lea		Draw_grid_code,a0
	lea		WIN_Draw_grid,a1
	bsr		Check_tool_dialog
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.rts
	bsr		Setup_tool
	bsr		Permanent_tool
.rts	rts

Draw_grid_code:
	init_tool
	st		BITMAP_CHANGED
	jsr		Init_cut_coords
	bsr		INIT_PENCIL
	bsr		Keep_undo
	clr.w		GRID_XSTART
	clr.w		GRID_YSTART
	move.w	#1,GRID_WIDTH
	move.w	#1,GRID_HEIGHT
	move.w	#8,brush_deviance
	tst.w		BRUSH_TYPE
	bpl.s		.loop
	clr.w		brush_deviance
.loop	move.l	#Box_primitive,PRIMITIVE
	push.w	BOX2_BITS
	push.w	FG_COLOUR
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	move.w	d0,FG_COLOUR
	move.w	#1<<Bit_BOX2_WIRE,BOX2_BITS
	jsr		Drag_primitive
	pop.w		FG_COLOUR
	pop.w		BOX2_BITS
.prob	move.w	X1,GRID_XSTART
	move.w	Y1,GRID_YSTART
	move.w	X2,d0
	sub.w		X1,d0
	addq		#1,d0
	move.w	d0,GRID_WIDTH
	move.w	Y2,d0
	sub.w		Y1,d0
	addq		#1,d0
	move.w	d0,GRID_HEIGHT
	move.w	GRID_XSTART,d0
	ext.l		d0
	move.w	GRID_WIDTH,d1
	divu		d1,d0
	mulu		d1,d0
	neg.w		d0
	add.w		GRID_XSTART,d0
	move.w	d0,GRID_XSTARTM
	move.w	GRID_YSTART,d0
	ext.l		d0
	move.w	GRID_HEIGHT,d1
	divu		d1,d0
	mulu		d1,d0
	neg.w		d0
	add.w		GRID_YSTART,d0
	move.w	d0,GRID_YSTARTM
	jsr		Superscaler
	clr.w		brush_deviance
	bsr		MOUSE_WAITMODE
	rts
	
Draw_box:
	moveq		#I_Draw_box,d0
	moveq		#station_draw,d1
	lea		Draw_box_code,a0
	lea		WIN_Draw_box,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts

Draw_box_code:
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	bsr		Keep_undo
	move.w	BOX2_BITS,d0
	btst		#Bit_BOX2_QUAD,d0
	bne.s		.quad
	btst		#Bit_BOX2_GRAD,d0
	bne.s		.grad
	bra		.norm
.grad	move.l	#Gradient_box_primitive,PRIMITIVE
	bra.s		.go
.quad	move.l	#Rainbow_box_primitive,PRIMITIVE
.go	clr.w		brush_deviance
	bsr		Drag_primitive
	jsr		([PRIMITIVE.l])
	bsr		Draw_handles
	move.w	BOX2_BITS,d0
	btst		#Bit_BOX2_GRAD,d0
	beq.s		.prob
	move.w	HANDLE_COUNT,d0
	lea		HANDLE_LIST,a0
	lea		(a0,d0.w*4),a1
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	add.w		(a0)+,d1
	add.w		(a0)+,d2
	lsr.w		d1
	lsr.w		d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	addq		#1,HANDLE_COUNT
	bsr		Rotate_primitive
.prob	jsr		COPYBACK
	jsr		([PRIMITIVE.l])
	clr.w		brush_deviance
	jsr		Superscaler
	bra.s		.exit	
.norm	move.l	#Box_primitive,PRIMITIVE
	clr.w		brush_deviance
	jsr		Drag_primitive
	jsr		([PRIMITIVE.l])
	clr.w		brush_deviance
	jsr		Superscaler
.exit	sf		SOFTWARE_MOUSE
	bsr		MOUSE_WAITMODE
	rts

COPYBACK:
	tst.b		ENABLE_GUIDES
	beq.s		CopyBack
	push.l	PACK_SCR
	move.l	FRAME_SCR,PACK_SCR
	bsr.s		CopyBack
	pop.l		PACK_SCR
	rts

Copy_Y1:			ds.w	1
Copy_Y2:			ds.w	1
Copy_X1:			ds.w	1
Copy_X2:			ds.w	1
Window_X:			ds.w	1
Window_Y:			ds.w	1

CopyBack:
	addq.b	#1,BUSY
	tst.b		TRUE_FLAG
	bne		COPYBACK_TRUE
	jsr		Get_max_window
	move.w	Copy_X1(pc),d1
	move.w	Copy_Y1(pc),d2
	move.w	Copy_X2(pc),d3
	move.w	Copy_Y2(pc),d4
	bsr		Clip_LOG_X1Y1_ABS
	bsr		Clip_LOG_X2Y2_ABS
	move.w	d1,Copy_X1
	move.w	d2,Copy_Y1
	move.w	d3,Copy_X2
	move.w	d4,Copy_Y2
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	Copy_Y1(pc),d0
	move.w	d0,d1
	move.w	d1,d2
	move.l	(LOG_Y.l,d1.w*4),d1
	add.l		d1,a0
	add.l		d1,a1
	move.w	Copy_Y2(pc),d1
	sub.w		d0,d1		; height d1
	ble.s		.no
	move.w	Copy_X1(pc),d2
	move.w	Copy_X2(pc),d4
	move.w	d2,d3
	and.w		#-16,d3
	add.w		d3,a0
	add.w		d3,a1
	add.w		#15,d4
	lsr.w		#4,d2
	lsr.w		#4,d4		; width
	sub.w		d2,d4
	ble.s		.no
	move.w	logwid,d5
	move.w	d4,d6
	lsl.w		#4,d6
	sub.w		d6,d5
	ext.l		d5
	subq		#1,d1
	subq		#1,d4
.ylop	move.w	d4,d6
.xlop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra		d6,.xlop
	add.l		d5,a0
	add.l		d5,a1
	dbra		d1,.ylop
.no	subq.b	#1,BUSY
	rts
	
COPYBACK_TRUE:
	jsr		Get_max_window
	move.w	Copy_X1(pc),d1
	move.w	Copy_Y1(pc),d2
	move.w	Copy_X2(pc),d3
	move.w	Copy_Y2(pc),d4
	bsr		Clip_LOG_X1Y1_ABS
	bsr		Clip_LOG_X2Y2_ABS
	move.w	d1,Copy_X1
	move.w	d2,Copy_Y1
	move.w	d3,Copy_X2
	move.w	d4,Copy_Y2
	st		BLIT_FREEZE
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	Copy_Y1(pc),d0
	move.w	d0,d1
	move.w	d1,d2
	move.l	(LOG_Y.l,d1.w*4),d1
	add.l		d1,a0
	add.l		d1,a1
	move.w	Copy_Y2(pc),d1
	sub.w		d0,d1			; height d1
	ble		CBend
	move.w	Copy_X1(pc),d2
	move.w	Copy_X2(pc),d4
	move.w	d2,d3
	add.w		d3,d3
	add.w		d3,a0
	add.w		d3,a1
	sub.w		d2,d4
	ble.s		CBend
	move.w	logwid,d5
	sub.w		d4,d5
	sub.w		d4,d5
	ext.l		d5
	subq		#1,d4
	subq		#1,d1
	moveq		#16-1,d6
	and.w		d4,d6
	lsr.w		#4,d4
	move.l	(CBJUMPS.l,d6.w*4),a5
	cacheoff	d3
CBylp	move.w	d4,d3
	jmp		(a5)
	bcop		16
	bcop		15
	bcop		14
	bcop		13
	bcop		12
	bcop		11
	bcop		10
	bcop		9
	bcop		8
	bcop		7
	bcop		6
	bcop		5
	bcop		4
	bcop		3
	bcop		2
	bcop		1
	dbra		d3,CBxlp	
	bra.s		CBxnd
CBxlp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra		d3,CBxlp	
CBxnd	add.l		d5,a0
	add.l		d5,a1
	dbra		d1,CBylp	
CBend	cacheon	d1
	sf		BLIT_FREEZE
	subq.b	#1,BUSY
	rts
	
Draw_curve:
	moveq		#I_Draw_curve,d0
	moveq		#station_draw,d1
	lea		Draw_curve_code,a0
	lea		WIN_Draw_curve,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts
	
Draw_curve_code:
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	bsr		Keep_undo
	jsr		Init_DSP_CURVE
	move.w	#100,splines
	move.w	#8+4,brush_deviance
	tst.w		BRUSH_TYPE
	bpl.s		.big
	move.w	#4,brush_deviance
.big	cmp.w		#1<<Bit_CURVE_BETAS,CURVE_BITS
	beq.s		.def
	cmp.w		#1<<Bit_CURVE_BETAG,CURVE_BITS
	bne.s		.ndef
.def	move.w	#max_handles,MAX_HANDLES
	move.w	#4,MIN_HANDLES
	move.l	#Draw_spline,PRIMITIVE
	subq		#4,brush_deviance
	jsr		Define_primitive
	tst.l		d0
	bmi.s		.prob
	jsr		([PRIMITIVE.l])
.prob	clr.w		brush_deviance
	bra		.exit
.ndef	move.l	#Draw_bezier,SPLINE_ROUT
	cmp.w		#1<<Bit_CURVE_BEZIER,CURVE_BITS
	beq.s		.norm
	lsr.w		splines
	move.l	#Draw_beta,SPLINE_ROUT
.norm	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.w	d3,X2
	move.w	d4,Y2
	bsr		COPYBACK
	move.w	X1,Px1
	move.w	Y1,Py1
	move.w	X1,d3
	add.w		X2,d3
	lsr.w		d3
	jsr		Grid_D3D4
	move.w	d3,Px2
	move.w	d3,Px3
	move.w	Y1,Py2
	move.w	Y2,Py3
	move.w	X2,Px4
	move.w	Y2,Py4
	jsr		([SPLINE_ROUT.l])
	move.w	Px1,d1
	move.w	Py1,d2
	bsr		Draw_handle
	move.w	Px2,d1
	move.w	Py2,d2
	bsr		Draw_handle
	move.w	Px3,d1
	move.w	Py3,d2
	bsr		Draw_handle
	move.w	Px4,d1
	move.w	Py4,d2
	bsr		Draw_handle
	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	lea		HANDLE_LIST,a0
	move.w	Px1,(a0)+
	move.w	Py1,(a0)+
	move.w	Px2,(a0)+
	move.w	Py2,(a0)+
	move.w	Px3,(a0)+
	move.w	Py3,(a0)+
	move.w	Px4,(a0)+
	move.w	Py4,(a0)+
	move.w	#4,HANDLE_COUNT
.wb	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	jsr		SHOW_MOUSE
.wl	jsr		WAIT_MOUSE
	cmp.b		#left_button,ICON_BUTTON
	beq.s		.look
	bsr		MOUSE_DRAWMODE
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	bra		.stop
.look	bsr		FIND_HANDLE
	tst.l		HANDLE_PTR
	bne.s		.hit
.hold	tst.b		BUTTONS
	bne.s		.hold
	bra.s		.wl
.hit	bsr		MOUSE_DRAWMODE
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
.drag	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.con2
	cmp.w		d1,d3
	bne.s		.con2
	cmp.w		d2,d4
	beq		.ski2
.con2	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	lea		HANDLE_LIST,a0
	move.w	(a0)+,Px1
	move.w	(a0)+,Py1
	move.w	(a0)+,Px2
	move.w	(a0)+,Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	jsr		Remove_mouseptr
	bsr		COPYBACK
	move.w	CANVAS_HEIGHT,Y1
	move.w	#-1,Y2
	move.w	CANVAS_WIDTH,X1
	move.w	#-1,X2
	jsr		([SPLINE_ROUT.l])
	move.w	Px1,d1
	move.w	Py1,d2
	bsr		Update_range
	bsr		Draw_handle
	move.w	Px2,d1
	move.w	Py2,d2
	bsr		Update_range
	bsr		Draw_handle
	move.w	Px3,d1
	move.w	Py3,d2
	bsr		Update_range
	bsr		Draw_handle
	move.w	Px4,d1
	move.w	Py4,d2
	bsr		Update_range
	bsr		Draw_handle
	jsr		Superscale_zone
	jsr		Update_mouseptr
.ski2	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.drag
	bra		.wb
.stop	bsr		COPYBACK
	jsr		([SPLINE_ROUT.l])
	clr.w		brush_deviance
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
.exit	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	rts

Draw_spline:
	cmp.w		#1<<Bit_CURVE_BETAG,CURVE_BITS
	beq		Draw_betagon
	lea		HANDLE_LIST,a0
	move.w	(a0),Px1
	move.w	2(a0),Py1
	move.w	(a0),Px2
	move.w	2(a0),Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	lea		HANDLE_LIST,a0
	move.w	(a0),Px1
	move.w	2(a0),Py1
	move.w	(a0)+,Px2
	move.w	(a0)+,Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	subq		#4,d0
.bits	push.w	d0
	push.l	a0
	move.w	(a0)+,Px1
	move.w	(a0)+,Py1
	move.w	(a0)+,Px2
	move.w	(a0)+,Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	pop.l		a0
	addq.l	#4,a0
	pop.w		d0
	dbra		d0,.bits
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	subq		#1,d0
	add.w		d0,d0
	add.w		d0,d0
	add.w		d0,a0
	push.l	a0
	move.w	2(a0),Py4
	move.w	(a0),Px4
	move.w	2(a0),Py3
	move.w	(a0),Px3
	move.w	-(a0),Py2
	move.w	-(a0),Px2
	move.w	-(a0),Py1
	move.w	-(a0),Px1
	bsr		Draw_beta_part
	pop.l		a0
	move.w	2(a0),Py4
	move.w	(a0),Px4
	move.w	2(a0),Py3
	move.w	(a0),Px3
	move.w	2(a0),Py2
	move.w	(a0),Px2
	move.w	-(a0),Py1
	move.w	-(a0),Px1
	bsr		Draw_beta_part
	rts

Draw_betagon:
	move.w	HANDLE_COUNT,d0
	subq		#2,d0
	lea		HANDLE_LIST,a0
	move.w	0(a0,d0.w*4),Px1
	move.w	2(a0,d0.w*4),Py1
	move.w	4(a0,d0.w*4),Px2
	move.w	6(a0,d0.w*4),Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	move.w	HANDLE_COUNT,d0
	subq		#1,d0
	lea		HANDLE_LIST,a0
	move.w	0(a0,d0.w*4),Px1
	move.w	2(a0,d0.w*4),Py1
	move.w	(a0)+,Px2
	move.w	(a0)+,Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	subq		#4,d0
.bits	push.w	d0
	push.l	a0
	move.w	(a0)+,Px1
	move.w	(a0)+,Py1
	move.w	(a0)+,Px2
	move.w	(a0)+,Py2
	move.w	(a0)+,Px3
	move.w	(a0)+,Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	pop.l		a0
	addq.l	#4,a0
	pop.w		d0
	dbra		d0,.bits
	move.w	HANDLE_COUNT,d0
	subq		#3,d0
	lea		HANDLE_LIST,a0
	move.w	0(a0,d0.w*4),Px1
	move.w	2(a0,d0.w*4),Py1
	move.w	4(a0,d0.w*4),Px2
	move.w	6(a0,d0.w*4),Py2
	move.w	8(a0,d0.w*4),Px3
	move.w	10(a0,d0.w*4),Py3
	move.w	(a0)+,Px4
	move.w	(a0)+,Py4
	bsr		Draw_beta_part
	rts

Draw_handles:
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	subq		#1,d0
.hnd	push.w	d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	push.l	a0
	bsr		Update_range
	bsr		Draw_handle
	pop.l		a0
	pop.w		d0
	dbra		d0,.hnd
	rts
	
FIND_HANDLE:
	clr.l		HANDLE_PTR
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	move.w	BUTTON_X,d3
	move.w	BUTTON_Y,d4
	bsr		Scale_D3D4
	subq		#1,d0
.loop	move.w	(a0)+,d1
	move.w	(a0)+,d2
	addq		#2,d1
	cmp.w		d3,d1
	blt.s		.next
	subq		#5,d1
	cmp.w		d3,d1
	bge.s		.next
	addq		#2,d2
	cmp.w		d4,d2
	blt.s		.next
	subq		#5,d2
	cmp.w		d4,d2
	bge.s		.next
	subq.l	#4,a0
	move.l	a0,HANDLE_PTR
	bra.s		.rts
.next	dbra		d0,.loop
.rts	rts

FIND_HANDLE_PTR:
	clr.l		HANDLE_PTR
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	move.w	BUTTON_X,d3
	move.w	BUTTON_Y,d4
	bsr		Scale_D3D4
	subq		#1,d0
.loop	move.l	(a0)+,a1
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	addq		#2,d1
	cmp.w		d3,d1
	blt.s		.next
	subq		#5,d1
	cmp.w		d3,d1
	bge.s		.next
	addq		#2,d2
	cmp.w		d4,d2
	blt.s		.next
	subq		#5,d2
	cmp.w		d4,d2
	bge.s		.next
	subq.l	#4,a0
	move.l	a0,HANDLE_PTR
	bra.s		.rts
.next	addq.l	#6,a0
	dbra		d0,.loop
.rts	rts

Draw_handle:
	tst.b		LARGE_HANDLES
	bne.s		.go		
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	jsr		PLOT_LOG_DOT
	bra.s		.no		
.go	move.w	d1,d3
	move.w	d2,d4
	subq		#2,d1
	subq		#2,d2
	addq		#2,d3
	addq		#2,d4
	jsr		DRAW_LOG_OUTROUND
.no	rts

Update_range:
	cmp.w		X1,d1
	bge.s		.nsx1
	move.w	d1,X1
.nsx1	cmp.w		Y1,d2
	bge.s		.nsy1
	move.w	d2,Y1
.nsy1	cmp.w		X2,d1
	ble.s		.nsx2
	move.w	d1,X2
.nsx2	cmp.w		Y2,d2
	ble.s		.nsy2
	move.w	d2,Y2
.nsy2	rts

Draw_bezier:
	dspwrite	Px1
	dspwrite	Py1
	dspwrite	Px2
	dspwrite	Py2
	dspwrite	Px3
	dspwrite	Py3
	dspwrite	Px4
	dspwrite	Py4	
	dspwrite	splines
	st		first
	move.w	splines,d0
	subq		#1,d0
.draw	push.w	d0
	dspread	d1
	dspread	d2
	bsr		Clip_LOG_X1Y1
	move.w	d1,d3
	move.w	d2,d4
	tst.b		first
	bne.s		.use
	move.w	OXD,d1
	move.w	OYD,d2
.use	move.w	d3,OXD
	move.w	d4,OYD
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BRUSHLINE
	clr.b		first		
	pop.w		d0
	dbra		d0,.draw
	rts	

Draw_beta:
	move.l	Px1,OPx1
	move.l	Px3,OPx3
	move.l	Py1,OPy1
	move.l	Py3,OPy3
	bsr		Draw_beta_part
	move.w	OPx1,Px1
	move.w	OPx1,Px2
	move.w	OPx2,Px3
	move.w	OPx3,Px4
	move.w	OPy1,Py1
	move.w	OPy1,Py2
	move.w	OPy2,Py3
	move.w	OPy3,Py4
	bsr		Draw_beta_part
	move.w	OPx4,Px1
	move.w	OPx4,Px2
	move.w	OPx3,Px3
	move.w	OPx2,Px4
	move.w	OPy4,Py1
	move.w	OPy4,Py2
	move.w	OPy3,Py3
	move.w	OPy2,Py4
	bsr		Draw_beta_part
	move.w	OPx1,Px1
	move.w	OPx1,Px2
	move.w	OPx1,Px3
	move.w	OPx2,Px4
	move.w	OPy1,Py1
	move.w	OPy1,Py2
	move.w	OPy1,Py3
	move.w	OPy2,Py4
	bsr.s		Draw_beta_part
	move.w	OPx4,Px1
	move.w	OPx4,Px2
	move.w	OPx4,Px3
	move.w	OPx3,Px4
	move.w	OPy4,Py1
	move.w	OPy4,Py2
	move.w	OPy4,Py3
	move.w	OPy3,Py4
	bsr.s		Draw_beta_part
	move.l	OPx1,Px1
	move.l	OPx3,Px3
	move.l	OPy1,Py1
	move.l	OPy3,Py3
	rts
	
Draw_beta_part:
	dspwrite	Px1
	dspwrite	Py1
	dspwrite	Px2
	dspwrite	Py2
	dspwrite	Px3
	dspwrite	Py3
	dspwrite	Px4
	dspwrite	Py4
	dspwrite	splines
	st		first
	move.w	splines,d0
	subq		#1,d0
	bmi.s		.err
.draw	push.w	d0
	dspread	d1
	dspread	d2
	bsr		Clip_LOG_X1Y1
	move.w	d1,d3
	move.w	d2,d4
	tst.b		first
	bne.s		.use
	move.w	OXD,d1
	move.w	OYD,d2
.use	move.w	d3,OXD
	move.w	d4,OYD
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BRUSHLINE
	clr.b		first		
	pop.w		d0
	dbra		d0,.draw
.err	rts	

Px1:	ds.w		1
Px2:	ds.w		1
Px3:	ds.w		1
Px4:	ds.w		1
Py1:	ds.w		1
Py2:	ds.w		1
Py3:	ds.w		1
Py4:	ds.w		1
OPx1:	ds.w		1
OPx2:	ds.w		1
OPx3:	ds.w		1
OPx4:	ds.w		1
OPy1:	ds.w		1
OPy2:	ds.w		1
OPy3:	ds.w		1
OPy4:	ds.w		1

Draw_circle:
	moveq		#I_Draw_circle,d0
	moveq		#station_draw,d1
	lea		Draw_circle_code,a0
	lea		WIN_Draw_circle,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts

Draw_circle_code:
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	move.l	X1,X_STORE
	bsr		Keep_undo
	move.l	#Circle_primitive,PRIMITIVE
	clr.w		brush_deviance
	bsr		Drag_primitive
	move.w	CIRCLE_BITS,d0
	and.w		#1<<Bit_CIRCLE_SPHERE,d0
	beq.s		.norm
	bsr.s		Sphere
	bra.s		.done
.norm	jsr		([PRIMITIVE.l])
.done	clr.w		brush_deviance
	jsr		Superscaler	
	bsr		MOUSE_WAITMODE
	rts
	
Sphere:
	push.w	FG_COLOUR
	tst.b		TRUE_FLAG
	beq.s		.bpl
	move.w	FIRST_COLOUR,d0
	move.w	LAST_COLOUR,d1
	bfextu	d0{16:5},d2
	move.w	d2,Point_RED1
	bfextu	d1{16:5},d2
	move.w	d2,Point_RED2
	bfextu	d0{21:6},d2
	move.w	d2,Point_GREEN1
	bfextu	d1{21:6},d2
	move.w	d2,Point_GREEN2
	bfextu	d0{27:5},d2
	move.w	d2,Point_BLUE1
	bfextu	d1{27:5},d2
	move.w	d2,Point_BLUE2
	bra.s		.true
.bpl	move.w	FIRST_COLOUR,Point_BLUE1
	move.w	LAST_COLOUR,Point_BLUE2
	clr.w		Point_RED1
	clr.w		Point_RED2
	clr.w		Point_GREEN1
	clr.w		Point_GREEN2
.true	move.w	x_factor,d4
	sub.w		y_factor,d4
	bpl.s		.skip
	asr.w		radius
.skip	move.w	radius,d1
	ext.l		d1
	move.w	#1024,d2
	swap		d2
	clr.w		d2
	divs.l	d1,d2
	move.w	d1,d7
	bpl.s		.okd7
	neg.w		d7
.okd7	clr.l		sine_index
	move.w	radius,circle_radius
.loop	pushall
	move.w	sine_index,d4
	move.w	(SINE+(2048*2).l,d4.w*2),d4
	neg.w		d4
	move.w	#$4000,d5
	sub.w		d4,d5
	move.w	Point_RED1,d0
	move.w	Point_RED2,d1
	mulu.w	d4,d0
 	mulu.w	d5,d1
	add.l		d0,d1
	divu.l	#$4000,d1
	lsl.w		#5,d1
	lsl.w		#6,d1
	move.w	d1,d7
	move.w	Point_GREEN1,d0
	move.w	Point_GREEN2,d1
	mulu.w	d4,d0
 	mulu.w	d5,d1
	add.l		d0,d1
	divu.l	#$4000,d1
	lsl.w		#5,d1
	or.w		d1,d7
	move.w	Point_BLUE1,d0
	move.w	Point_BLUE2,d1
	mulu.w	d4,d0
 	mulu.w	d5,d1
	add.l		d0,d1
	divu.l	#$4000,d1
	or.w		d1,d7
	move.w	d7,FG_COLOUR
	lea		HANDLE_LIST,a0
	move.w	6(a0),2(a0)
	move.w	4(a0),d0
	add.w		circle_radius,d0
	move.w	d0,(a0)
	jsr		([PRIMITIVE.l])
	popall
	add.l		d2,sine_index
	subq		#1,circle_radius
	dbra		d7,.loop
	pop.w		FG_COLOUR
	rts

circle_radius:	ds.w	1
sine_index:		ds.l	1

circle:		
	lea		Circle_data,a5
	move.w	#-1,MaxY
	move.w	CANVAS_HEIGHT,MinY
	lea		solid_circle(pc),a6
	move.w	CIRCLE_BITS,d0
	and.w		#1<<Bit_CIRCLE_WIRE,d0
	beq.s		.sol
	lea		hollow_circle(pc),a6
.sol	ext.l		d4
	ext.l		d5
	ext.l		d7
	clr.l		d6
	move.l	d7,d3
	add.l		d3,d3
	neg.l		d3
	addq.l	#3,d3
	bra.s		.ci40
.ci10	push.l	a6
	jsr		(a6)
	pop.l		a6
	tst.l		d3
	bgt.s		.ci20
	move.l	d6,d0
	asl.l		#2,d0
	add.l		d0,d3
	addq.l	#6,d3
	bra.s		.ci30
.ci20	move.l	d6,d0
	sub.l		d7,d0
	asl.l		#2,d0
	add.l		d0,d3
	addq.l	#8,d3
	addq.l	#2,d3
	subq.l	#1,d7
.ci30	addq.l	#1,d6
.ci40	cmp.l		d6,d7
	bgt.s		.ci10
	cmp.l		d6,d7
	bne.s		.ci50
	jsr		(a6)
.ci50	rts

solid_circle
	push.l	d2
	push.l	d3
	move.w	x_factor,d2
	move.w	y_factor,d3
	cmp.w		d2,d3
	beq.s		.zero
	subq		#1,d2
	subq		#1,d3
	bra.s		.strt
.zero	moveq		#0,d2
	moveq		#0,d3
.strt	move.l	d6,d0		; bbr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	add.l		d5,d1
	cmp.w		CANVAS_HEIGHT,d1
	bge.s		.err1
	move.w	d0,2(a5,d1.w*4)
	circle_range
.err1	move.l	d7,d0		; brr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	add.l		d5,d1
	cmp.w		CANVAS_HEIGHT,d1
	bge.s		.err2
	move.w	d0,2(a5,d1.w*4)
	circle_range
.err2	move.l	d7,d0		; trr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	bmi.s		.err3
	move.w	d0,2(a5,d1.w*4)
	circle_range
.err3	move.l	d6,d0		; rtt
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	bmi.s		.err4
	move.w	d0,2(a5,d1.w*4)
	circle_range
.err4	move.l	d6,d0		; ttl
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	bmi.s		.err5
	move.w	d0,0(a5,d1.w*4)
	circle_range
.err5	move.l	d7,d0		; llt
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	bmi.s		.err6
	move.w	d0,0(a5,d1.w*4)
	circle_range
.err6	move.l	d7,d0		; llb
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	add.l		d5,d1
	cmp.w		CANVAS_HEIGHT,d1
	bge.s		.err7
	move.w	d0,0(a5,d1.w*4)
	circle_range
.err7	move.l	d6,d0		; lbb
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	add.l		d5,d1
	cmp.w		CANVAS_HEIGHT,d1
	bge.s		.err8
	move.w	d0,0(a5,d1.w*4)
	circle_range
.err8	pop.l		d3
	pop.l		d2
	rts

hollow_circle:
	push.l	d0
	push.l	d3
	move.w	x_factor,d0
	move.w	y_factor,d3
	cmp.w		d0,d3
	beq.s		.zero
	subq		#1,d0
	subq		#1,d3
	bra.s		.strt
.zero	moveq		#0,d0
	moveq		#0,d3
.strt	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; bbr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; brr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; trr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; rtt
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; ttl
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; llt
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; llb
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; lbb
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	FG_COLOUR,d0
	jsr		PLOT_LOG_DOT
	movem.l	(sp)+,d0-d7
	pop.l		d3
	pop.l		d0
	rts

phys_circle:		
	move.w	d0,OXD
	lea		Circle_data,a5

	move.w	d5,d3
	sub.w		d7,d3
	move.w	d3,MinY
	move.w	d5,d3
	add.w		d7,d3
	move.w	d3,MaxY

	ext.l		d4
	ext.l		d5
	ext.l		d7
	clr.l		d6
	move.l	d7,d3
	add.l		d3,d3
	neg.l		d3
	addq.l	#3,d3
	bra.s		.ci40
.ci10	push.l	a6
	bsr.s		.draw
	pop.l		a6
	tst.l		d3
	bgt.s		.ci20
	move.l	d6,d0
	asl.l		#2,d0
	add.l		d0,d3
	addq.l	#6,d3
	bra.s		.ci30
.ci20	move.l	d6,d0
	sub.l		d7,d0
	asl.l		#2,d0
	add.l		d0,d3
	addq.l	#8,d3
	addq.l	#2,d3
	subq.l	#1,d7
.ci30	addq.l	#1,d6
.ci40	cmp.l		d6,d7
	bgt.s		.ci10
	cmp.l		d6,d7
	bne.s		.ci50
	bsr.s		.draw
.ci50	move.w	MinY,d0
	lea		(Circle_data.l,d0.w*4),a0
	move.w	MaxY,d1
	sub.w		MinY,d1
	bmi.s		.err
	move.w	MinY,d3
.ylp	push.w	d1
	push.w	d3
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	OXD,d0
	jsr		horizontal_menuline
	pop.w		d3
	addq		#1,d3
	pop.w		d1
	dbra		d1,.ylp
.err	rts
.draw	lea		Circle_data,a5
	push.l	d2
	push.l	d3
	move.w	x_factor,d2
	move.w	y_factor,d3
	cmp.w		d2,d3
	beq.s		.zero
	subq		#1,d2
	subq		#1,d3
	bra.s		.strt
.zero	moveq		#0,d2
	moveq		#0,d3
.strt
	move.l	d6,d0		; bbr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	add.l		d5,d1
	move.w	d0,2(a5,d1.w*4)
.err1	move.l	d7,d0		; brr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	add.l		d5,d1
	move.w	d0,2(a5,d1.w*4)
.err2	move.l	d7,d0		; trr
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	move.w	d0,2(a5,d1.w*4)
.err3	move.l	d6,d0		; rtt
	asr.l		d3,d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	move.w	d0,2(a5,d1.w*4)
.err4	move.l	d6,d0		; ttl
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	move.w	d0,0(a5,d1.w*4)
.err5	move.l	d7,d0		; llt
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	neg.l		d1
	add.l		d5,d1
	move.w	d0,0(a5,d1.w*4)
.err6	move.l	d7,d0		; llb
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d6,d1
	asr.l		d2,d1
	add.l		d5,d1
	move.w	d0,0(a5,d1.w*4)
.err7	move.l	d6,d0		; lbb
	asr.l		d3,d0
	neg.l		d0
	add.l		d4,d0
	move.l	d7,d1
	asr.l		d2,d1
	add.l		d5,d1
	move.w	d0,0(a5,d1.w*4)
.err8

	pop.l		d3
	pop.l		d2
	rts
	
	ifd		crap
.draw	push.l	d0
	push.l	d3
	move.w	x_factor,d0
	move.w	y_factor,d3
	cmp.w		d0,d3
	beq.s		.zero
	subq		#1,d0
	subq		#1,d3
	bra.s		.strt
.zero	moveq		#0,d0
	moveq		#0,d3
.strt	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; bbr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; brr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; trr
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; rtt
	asr.l		d3,d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; ttl
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; llt
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	neg.l		d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d7,d1		; llb
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d6,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d6,d1		; lbb
	asr.l		d3,d1
	neg.l		d1
	add.l		d4,d1
	move.l	d7,d2
	asr.l		d0,d2
	add.l		d5,d2
	move.w	OXD,d0
	jsr		DRAW_MENU_DOT
	movem.l	(sp)+,d0-d7
	pop.l		d3
	pop.l		d0
	rts
	endc

Draw_polygon:
	moveq		#I_Draw_polygon,d0
	moveq		#station_draw,d1
	lea		Draw_polygon_code,a0
	lea		WIN_Draw_polygon,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts
	
Draw_polygon_code:
	init_tool
	bsr		INIT_PENCIL
	bsr		Keep_undo
	move.l	#(max_edges*4+max_edges*4*4),d0
	bsr		MALLOCATE_fast
	tst.l		d0
	bmi		.prob
	move.l	a0,EDGEBUFFER_PTR
	move.w	POLY_BITS,d0
	btst		#Bit_POLY_TRIP,d0
	bne.s		.rain
.wire	move.l	#Wire_poly_primitive,PRIMITIVE
	move.w	#3,MIN_HANDLES
	move.w	#50,MAX_HANDLES
	bra.s		.go
.rain	move.l	#Rainbow_poly_primitive,PRIMITIVE
	move.w	#3,MIN_HANDLES
	move.w	#3,MAX_HANDLES
.go	clr.w		brush_deviance
	bsr.s		Define_primitive
	tst.l		d0
	bmi.s		.prob
	move.w	POLY_BITS,d0
	btst		#Bit_POLY_SOLID,d0
	beq.s		.wir2
	move.w	HANDLE_COUNT,d0
	move.w	d0,STREAM_COUNT
	subq		#1,d0
	lea		HANDLE_LIST,a0
	move.l	EDGEBUFFER_PTR,a1
	move.l	(a0),d1
.lp	move.l	(a0)+,(a1)+
.nxt	dbra		d0,.lp
	move.l	d1,(a1)+
	bsr		CALC_EDGEBUFFERS
	bsr		FILL_EDGEBUFFERS
.wir2	jsr		([PRIMITIVE.l])
	st		BITMAP_CHANGED
.prob	bsr		MRELEASE
	jsr		Superscaler
	clr.w		brush_deviance
	bsr		MOUSE_WAITMODE
	rts

Define_primitive:
	jsr		SHOW_MOUSE
	jsr		Init_cut_coords
	clr.w		HANDLE_COUNT
	addq		#4,brush_deviance
	bra.s		.go
.wl1	jsr		WAIT_MOUSE
.go	cmp.b		#left_button,ICON_BUTTON
	beq.s		.cont
.wb2	tst.b		BUTTONS
	bne.s		.wb2
	bra.s		.done
.cont	jsr		HIDE_MOUSE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	lea		HANDLE_LIST,a0
	move.w	HANDLE_COUNT,d0
	move.w	d1,0(a0,d0.w*4)
	move.w	d2,2(a0,d0.w*4)
	addq		#1,HANDLE_COUNT
	bsr		Draw_handle
	jsr		Superscaler
	jsr		SHOW_MOUSE
.wb3	tst.b		BUTTONS
	bne.s		.wb3
	move.w	HANDLE_COUNT,d0
	cmp.w		MAX_HANDLES,d0
	bne.s		.wl1
.done	move.w	HANDLE_COUNT,d0
	cmp.w		MIN_HANDLES,d0
	blt		Define_aborted
	jsr		HIDE_MOUSE
	jsr		([PRIMITIVE.l])	
	bsr		Draw_handles
	jsr		Superscaler
	jsr		SHOW_MOUSE
	bra.s		.wl
.wb	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	jsr		SHOW_MOUSE
.wl	jsr		WAIT_MOUSE
	cmp.b		#left_button,ICON_BUTTON
	beq.s		.look
	bsr		MOUSE_DRAWMODE
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	bra		.stop
.look	bsr		FIND_HANDLE
	tst.l		HANDLE_PTR
	bne.s		.hit
.hold	tst.b		BUTTONS
	bne.s		.hold
	bra.s		.wl
.hit	bsr		MOUSE_DRAWMODE
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
.drag	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.con2
	cmp.w		d1,d3
	bne.s		.con2
	cmp.w		d2,d4
	beq.s		.ski2
.con2	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	jsr		Remove_mouseptr
	bsr		COPYBACK
	move.w	CANVAS_HEIGHT,Y1
	move.w	#-1,Y2
	move.w	CANVAS_WIDTH,X1
	move.w	#-1,X2
	jsr		([PRIMITIVE.l])	
	bsr		Draw_handles
	jsr		Superscale_zone
	jsr		Print_cut_coords
	jsr		Update_mouseptr
.ski2	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.drag
	bra		.wb
.stop	bsr		COPYBACK
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	jsr		Refresh_info_bar
	moveq		#0,d0
Define_end:
	rts
Define_aborted:
	bsr		MOUSE_DRAWMODE
	jsr		COPY_UNDO_2_LOG
	jsr		Refresh_info_bar
	moveq		#-1,d0
	bra.s		Define_end

Drag_primitive:
	addq		#4,brush_deviance
	jsr		Init_cut_coords
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	lea		HANDLE_LIST,a0
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	#2,HANDLE_COUNT
	bsr		FIND_HANDLE
	tst.l		HANDLE_PTR
	beq		.stop
.hit	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
.drag	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.con2
	cmp.w		d1,d3
	bne.s		.con2
	cmp.w		d2,d4
	beq.s		.ski2
.con2	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	jsr		Remove_mouseptr
	bsr		COPYBACK
	move.w	CANVAS_HEIGHT,Y1
	move.w	#-1,Y2
	move.w	CANVAS_WIDTH,X1
	move.w	#-1,X2
	jsr		([PRIMITIVE.l])	
	bsr		Draw_handles
	jsr		Superscale_zone
	jsr		Print_cut_coords
	jsr		Update_mouseptr
.ski2	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.drag
.stop	bsr		COPYBACK
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	jsr		Refresh_info_bar
	rts

Rotate_primitive:
	jsr		SHOW_MOUSE
	jsr		WAIT_MOUSE
	bsr		MOUSE_DRAWMODE
	cmp.b		#right_button,BUTTONS
	beq		.err
	move.w	HANDLE_COUNT,d0
	lea		(HANDLE_LIST.l,d0.w*4),a0
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq		#1,HANDLE_COUNT
	move.w	HANDLE_COUNT,d0
	lea		(HANDLE_LIST-8.l,d0.w*4),a0
	move.w	(a0)+,X1
	move.w	(a0)+,Y1
	move.w	(a0)+,X2
	move.w	(a0)+,Y2
	bsr		Get_angle
	move.w	d0,INITIAL_ANGLE
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	bsr		FIND_HANDLE
	tst.l		HANDLE_PTR
	beq		.stop
.drag	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.con2
	cmp.w		d1,d3
	bne.s		.con2
	cmp.w		d2,d4
	beq		.ski2
.con2	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	jsr		Remove_mouseptr
	bsr		COPYBACK
	move.w	HANDLE_COUNT,d0
	lea		(HANDLE_LIST-8.l,d0.w*4),a0
	move.w	(a0)+,X1
	move.w	(a0)+,Y1
	move.w	(a0)+,X2
	move.w	(a0)+,Y2
	bsr		Get_angle
	move.w	d0,d1
	sub.w		INITIAL_ANGLE,d0
	move.w	d1,INITIAL_ANGLE
	sub.w		d0,Z_ANGLE
	move.w	CANVAS_HEIGHT,Y1
	move.w	#-1,Y2
	move.w	CANVAS_WIDTH,X1
	move.w	#-1,X2
	jsr		([PRIMITIVE.l])
	move.w	HANDLE_COUNT,d0
	lea		(HANDLE_LIST-8.l,d0.w*4),a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	jsr		DRAW_LOG_LINE
	bsr		Draw_handles
	jsr		Superscale_zone
	jsr		Update_mouseptr
.ski2	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.drag
.stop	bsr		COPYBACK
	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
.err	rts
	
INITIAL_ANGLE:	ds.w	1

Get_angle:
	move.w	X2,d0
	sub.w		X1,d0
	asl.w		#2,d0
	muls		d0,d0
	move.w	Y2,d1
	sub.w		Y1,d1
	asl.w		#2,d1
	muls		d1,d1
	add.l		d1,d0
	bsr.s		Root
	move.w	X2,d3
	sub.w		X1,d3
	swap		d3
	clr.w		d3
	asl.l		#2,d3
	divs.l	d0,d3
	asr.l		#2,d3
	subq.l	#1,d3
	move.w	#4096/8,d1
	move.w	#4096-1,d4
	lea		SINE,a0
	move.w	Y2,d0
	cmp.w		Y1,d0
	blt.s		Hem2
Hem1:	move.w	#4096/2,d0
.loop	move.w	(a0,d0.w*2),d2
	cmp.w		d3,d2
	bgt.s		.over
	blt.s		.undr
	rts
.over	add.w		d1,d0
	lsr.w		d1
	bne.s		.loop
	rts
.undr	sub.w		d1,d0
	lsr.w		d1
	bne.s		.loop
.zero	rts
Hem2:	moveq		#0,d0
.loop	and.w		d4,d0
	move.w	(a0,d0.w*2),d2
	cmp.w		d3,d2
	bgt.s		.over
	blt.s		.undr
	rts
.over	sub.w		d1,d0
	lsr.w		d1
	bne.s		.loop
	rts
.undr	add.w		d1,d0
	lsr.w		d1
	bne.s		.loop
.zero	rts

Root:	move.l	d0,d3
	beq.s		.zero
	move.l	#1<<15,d0
	move.l	d0,d1
	lsr.l		d1
.loop	move.l	d0,d2
	mulu.l	d2,d2
	cmp.l		d3,d2
	bgt.s		.over
	blt.s		.undr
	rts
.over	sub.l		d1,d0
	lsr.l		d1
	bne.s		.loop
	rts
.undr	add.l		d1,d0
	lsr.l		d1
	bne.s		.loop
.zero	rts

Wire_poly_primitive:
	move.w	HANDLE_COUNT,d7
	subq		#1,d7
	lea		HANDLE_LIST,a0
	lea		(a0,d7.w*4),a1
	move.w	(a1)+,d1
	move.w	(a1)+,d2
.loop	move.w	(a0)+,d3
	move.w	(a0)+,d4
	pushall
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_LINE
	popall
	move.w	d3,d1
	move.w	d4,d2
	dbra		d7,.loop
	rts

Circle_primitive:
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	(a0)+,d0
	move.w	x_factor,d6
	sub.w		d3,d0
	cmp.w		y_factor,d6
	beq.s		.n1
	yresfactor	d0
.n1	lsl.w		#2,d0
	muls		d0,d0
	move.w	(a0)+,d5
	sub.w		d4,d5
	cmp.w		y_factor,d6
	beq.s		.n2
	xresfactor	d5
.n2	lsl.w		#2,d5
	muls		d5,d5
	add.l		d5,d0
	bsr		Root
	lsr.l		#2,d0
	move.w	d0,radius
	move.w	-4(a0),d0
	sub.w		radius,d0
	move.w	d0,X1
	move.w	-4(a0),d0
	add.w		radius,d0
	move.w	d0,X2
	move.w	-2(a0),d0
	sub.w		radius,d0
	move.w	d0,Y1
	move.w	-2(a0),d0
	add.w		radius,d0
	move.w	d0,Y2
	move.w	-4(a0),d4
	move.w	-2(a0),d5
	move.w	radius,d7
	bsr		circle

fill_circle:
	move.w	CIRCLE_BITS,d0
	and.w		#1<<Bit_CIRCLE_WIRE,d0
	bne.s		.err
	move.w	MinY,d0
	lea		(Circle_data.l,d0.w*4),a0
	move.w	MaxY,d1
	sub.w		MinY,d1
	bmi.s		.err
	move.w	MinY,d3
.ylp	push.w	d1
	push.w	d3
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	FG_COLOUR,d0
	jsr		horizontal_logline
	pop.w		d3
	addq		#1,d3
	pop.w		d1
	dbra		d1,.ylp
.err	rts

Line_primitive:
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BRUSHLINE
	rts

Gradline_primitive:
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	FIRST_COLOUR,d0
	bsr		Get_RGB
	move.w	d1,Point_RED2
	move.w	d2,Point_GREEN2
	move.w	d3,Point_BLUE2
	move.w	X2,d1
	move.w	Y2,d2
	move.w	LAST_COLOUR,d0
	jsr		Get_RGB
	move.w	d1,Point_RED1
	move.w	d2,Point_GREEN1
	move.w	d3,Point_BLUE1
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.l	LOG_SCR,a0
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	move.w	logwid,scrwid
	jsr		DRAW_GRADLINE
	rts

Intline_primitive:
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	lea		Point_RED1,a1
	jsr		Fetch_RGB
	move.w	X2,d1
	move.w	Y2,d2
	lea		Point_RED2,a1
	jsr		Fetch_RGB
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.l	LOG_SCR,a0
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	move.w	logwid,scrwid
	jsr		DRAW_GRADLINE
	rts

Box_primitive:
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	BOX1_BITS,d5
	btst		#Bit_BOX1_SQUARE,d5
	beq.s		.ign
	move.w	d3,d5
	sub.w		d1,d5
	move.w	d5,OXD
	bpl.s		.xpl1
	neg.w		d5
.xpl1	move.w	d4,d6
	sub.w		d2,d6
	move.w	d6,OYD
	bpl.s		.ypl1
	neg.w		d6
.ypl1	move.w	d5,d7
	cmp.w		d5,d6
	ble.s		.lt1
	move.w	d6,d7
.lt1	move.w	d1,d3
	move.w	d2,d4
	add.w		d7,d3
	tst.w		OXD
	bpl.s		.xpl2
	sub.w		d7,d3
	sub.w		d7,d3
.xpl2	add.w		d7,d4
	tst.w		OYD
	bpl.s		.ign
	sub.w		d7,d4
	sub.w		d7,d4
.ign	cmp.w		d1,d3
	bge.s		.ok1
	exg		d1,d3
.ok1	cmp.w		d2,d4
	bge.s		.ok2
	exg		d2,d4
.ok2	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BLOCK
	rts
	
	
*-----------------------------------------------------------------------*
*	RAINBOW - POLYGON ROUTINE							*
*-----------------------------------------------------------------------*

Point_scale:		ds.w	1

Point_X1:			ds.w	1
Point_Y1:			ds.w	1

Point_RED1:			ds.w	1
Point_GREEN1:		ds.w	1
Point_BLUE1:		ds.w	1

Point_X2:			ds.w	1
Point_Y2:			ds.w	1

Point_RED2:			ds.w	1
Point_GREEN2:		ds.w	1
Point_BLUE2:		ds.w	1

Point_RED1_Copy:		ds.w	1
Point_GREEN1_Copy:	ds.w	1
Point_BLUE1_Copy:		ds.w	1
Point_RED2_Copy:		ds.w	1
Point_GREEN2_Copy:	ds.w	1
Point_BLUE2_Copy:		ds.w	1

Store_RGB:
	move.w	d1,(a1)+
	move.w	d2,(a1)+
Fetch_RGB:
	movem.l	d7/a0/a1,-(sp)
	bsr		READ_LOG_PIXEL
	movem.l	(sp)+,d7/a0/a1
	tst.b		TRUE_FLAG
	bne.s		.true
	move.w	d0,d1
	moveq		#0,d2
	moveq		#0,d3
	bra.s		.rts
.true	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	and.w		#%1111100000000000,d1
	and.w		#%0000011111100000,d2
	and.w		#%0000000000011111,d3
	lsr.w		#8,d1
	lsr.w		#3,d2
	lsl.w		#3,d3
.rts	lsl.w		#7,d1
	lsl.w		#7,d2
	lsl.w		#7,d3
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	rts

Get_RGB:
	tst.b		TRUE_FLAG
	bne.s		.true
	move.w	d0,d1
	moveq		#0,d2
	moveq		#0,d3
	bra.s		.rts
.true	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	and.w		#%1111100000000000,d1
	and.w		#%0000011111100000,d2
	and.w		#%0000000000011111,d3
	lsr.w		#8,d1
	lsr.w		#3,d2
	lsl.w		#3,d3
.rts	lsl.w		#7,d1
	lsl.w		#7,d2
	lsl.w		#7,d3
	rts

Scale_RGB:
	movem.l	d4-d6,-(sp)
	move.w	FIRST_COLOUR,d0
	bsr.s		Get_RGB
	mulu		Scaler1(pc),d1
	mulu		Scaler1(pc),d2
	mulu		Scaler1(pc),d3
	move.l	d1,d4
	move.l	d2,d5
	move.l	d3,d6
	move.w	LAST_COLOUR,d0
	tst.b		TRUE_FLAG
	bne.s		.ok
	addq		#1,d0
.ok	bsr.s		Get_RGB
	mulu		Scaler2(pc),d1
	mulu		Scaler2(pc),d2
	mulu		Scaler2(pc),d3
	add.l		d1,d4
	add.l		d2,d5
	add.l		d3,d6
	add.l		d4,d4
	add.l		d5,d5
	add.l		d6,d6
	swap		d4
	swap		d5
	swap		d6
	move.w	d4,(a1)+
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	movem.l	(sp)+,d4-d6
	rts

Scaler1:	ds.w	1
Scaler2:	ds.w	1

Rainbow_box_primitive:
	IFD		FINALGFX
	move.w	#4,Gourad_sides
	lea		HANDLE_LIST,a0
	lea		Gourad_edges,a1
.lp	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bsr		Store_RGB
	move.w	(a0),d1
	move.w	-2(a0),d2
	bsr		Store_RGB
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bsr		Store_RGB
	move.w	-8(a0),d1
	move.w	-2(a0),d2
	bsr		Store_RGB
	jmp		Gourad_fill
	ENDC
	rts

X_ANGLE:	ds.w	1
Y_ANGLE:	ds.w	1
Z_ANGLE:	ds.w	1

Gradient_box_primitive:
	IFD		FINALGFX
	move.w	#4,Gourad_sides
	lea		Gourad_colours,a1
	lea		SINE,a0
	move.w	Z_ANGLE,d0
	add.w		#4096/8,d0
	move.w	d0,d4
	add.w		#4096/4,d0
	move.w	d0,d5
	add.w		#4096/4,d0
	move.w	d0,d6
	add.w		#4096/4,d0
	move.w	d0,d7
	move.w	#4096-1,d0
	and.w		d0,d4
	and.w		d0,d5
	and.w		d0,d6
	and.w		d0,d7
	move.w	(a0,d4.w*2),d4
	move.w	(a0,d5.w*2),d5
	move.w	(a0,d6.w*2),d6
	move.w	(a0,d7.w*2),d7
	move.w	#16384,d0
	add.w		d0,d4
	add.w		d0,d5
	add.w		d0,d6
	add.w		d0,d7
	move.w	d4,Scaler1
	move.w	d6,Scaler2
	bsr		Scale_RGB
	move.w	d5,Scaler1
	move.w	d7,Scaler2
	bsr		Scale_RGB
	move.w	d6,Scaler1
	move.w	d4,Scaler2
	bsr		Scale_RGB
	move.w	d7,Scaler1
	move.w	d5,Scaler2
	bsr		Scale_RGB
	lea		HANDLE_LIST,a0
	lea		Gourad_edges,a1
	lea		Gourad_colours,a2
.lp	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a0),d1
	move.w	-2(a0),d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	-8(a0),d1
	move.w	-2(a0),d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	jmp		Gourad_fill
	ENDC

Rainbow_poly_primitive:
	IFD		FINALGFX
	move.w	HANDLE_COUNT,d7
	move.w	d7,Gourad_sides
	subq		#1,d7
	lea		HANDLE_LIST,a0
	lea		Gourad_edges,a1
.lp	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bsr		Store_RGB
	dbra		d7,.lp
	jmp		Gourad_fill
	ENDC
	rts

Gourad_Top:		ds.w		1
Gourad_Bot:		ds.w		1
Gourad_sides:	ds.w		1
Gourad_edges:	ds.w		5*4

Draw_fill:
	moveq		#I_Draw_fill,d0
	moveq		#station_draw,d1
	lea		Draw_fill_code,a0
	lea		WIN_Draw_fill,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts
	
Draw_fill_code:
	init_tool
	jsr		HIDE_MOUSE
	move.w	FILL_BITS,d0
	bsr		Keep_undo
	jsr		Superscaler
	addq.b	#1,BUSY
*-----------------------------------------*
	move.l	#64000,d0
	bsr		MALLOCATE_normal
	tst.l		d0
	bmi		.prob
	move.l	a0,EDGEBUFFER_PTR
*-----------------------------------------*
	move.w	FILL_BITS,d0
	and.w		#1<<Bit_FILL_BRUSH,d0
	beq.s		.ntxt
*-----------------------------------------*
	move.l	CANVAS_SIZE,d0
	add.l		#256,d0
	bsr		MALLOCATE_fast
	tst.l		d0
	bmi		.prob
	move.l	a0,BACK_SCR
*-----------------------------------------*
	move.l	#HORIZONTAL_MASK,LINE_TYPE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		READ_LOG_PIXEL
	move.w	d0,OLD_COL
	move.l	BACK_SCR,a0
	bsr		TILE_BACKGROUND
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_FILL
	bra		.fin
*-----------------------------------------*
.ntxt	move.w	FILL_BITS,d0
	and.w		#1<<Bit_FILL_SOLID,d0
	beq.s		.nbrs
*-----------------------------------------*
	move.l	#horizontal_logline_d,LINE_TYPE
	move.w	FG_COLOUR,NEW_COL
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		READ_LOG_PIXEL
	cmp.w		NEW_COL,d0
	beq		.prob
	move.w	d0,OLD_COL
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_FILL
	bra		.fin
*-----------------------------------------*
.nbrs	move.l	#GRADIENT_2D,LINE_TYPE
	tst.b		TRUE_FLAG
	beq.s		.ok
	move.l	#GRADIENT_2D_TRUE,LINE_TYPE
.ok	move.w	FG_COLOUR,NEW_COL
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		READ_LOG_PIXEL
	move.w	d0,OLD_COL
	move.w	CANVAS_WIDTH,d0
	mulu		CANVAS_HEIGHT,d0
	lsr.l		#3,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.prob
	move.l	a0,BACK_SCR
	move.l	a0,a1
	move.l	LOG_SCR,a0
	bsr		MASK_SCREEN
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		DO_FILL
*-----------------------------------------*
.fin	jsr		Superscaler
	st		BITMAP_CHANGED
.prob	jsr		MRELEASE
	subq.b	#1,BUSY
	jsr		SHOW_MOUSE
	rts

TILE_BACKGROUND:
	push.w	PASTE_BITS
	move.w	#1<<Bit_PASTE_SOLI,PASTE_BITS
	bsr		Find_brush
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	moveq		#0,d6
	moveq		#0,d7
	move.w	CANVAS_WIDTH,d6
	move.w	CANVAS_HEIGHT,d7
	divu		d3,d6
	divu		d4,d7
	addq		#1,d6
	addq		#1,d7
	move.w	BRUSH_XBASE,d1
	move.w	BRUSH_YBASE,d2
	ext.l		d1
	ext.l		d2
	divs		d3,d1
	divs		d4,d2
	muls		d3,d1
	muls		d4,d2
	neg.w		d1
	neg.w		d2
	tst.w		BRUSH_XBASE
	bmi.s		.okx
	sub.w		d3,d1
.okx	tst.w		BRUSH_YBASE
	bmi.s		.oky
	sub.w		d4,d2
.oky	add.w		BRUSH_XBASE,d1
	add.w		BRUSH_YBASE,d2
	move.l	BACK_SCR,a0
	move.w	d1,d0
.ylp	move.w	d6,d5
	move.w	d0,d1
.xlp	pushall
	jsr		PRINT_BACKBRUSH
	popall
	add.w		d3,d1	
	dbra		d5,.xlp
	add.w		d4,d2
	dbra		d7,.ylp
.err	pop.w		PASTE_BITS
	rts

HORIZONTAL_MASK:
	move.l	BACK_SCR,a0
	move.l	LOG_SCR,a1
	jsr		HORIZONTAL_COPY
	rts

GRADIENT_2D:
	move.w	d1,llft
	move.w	d2,lrgt
	move.w	CANVAS_WIDTH,d6
	lsr.w		#3,d6
	ext.l		d6
	move.l	BACK_SCR(pc),a2
	move.w	y1,d0
	mulu.w	d6,d0
	add.l		d0,a2
.scan	move.w	d1,d0
	lsr.w		#4,d0
	lea		(a2,d0.w*2),a0
	moveq		#16-1,d7
	and.w		d1,d7
	move.w	#$8000,d0
	lsr.w		d7,d0
	move.l	a0,a1
	move.w	y1,d4
.nxtu	subq		#1,d4
	bmi.s		.gotu
	sub.l		d6,a0
	move.w	d0,d5
	and.w		(a0),d5
	bne.s		.nxtu
.gotu	addq		#1,d4
	move.w	d4,ltop
	move.w	y1,d4
.nxtd	addq		#1,d4
	cmp.w		CANVAS_HEIGHT,d4
	bge.s		.gotd
	add.l		d6,a1
	move.w	d0,d5
	and.w		(a1),d5
	bne.s		.nxtd
.gotd	subq		#1,d4
	move.w	d4,lbot
	move.w	lrgt(pc),d0
	sub.w		llft(pc),d0
	lsr.w		d0
	bne.s		.ok3
	addq		#1,d0
.ok3	move.w	d1,d5
	sub.w		llft(pc),d5
	sub.w		d0,d5
	bmi.s		.ok1
	neg.w		d5
.ok1	add.w		d0,d5
	bpl.s		.ok5
	moveq		#0,d5
.ok5	ext.l		d0
	ext.l		d5
	swap		d5
	divu.l	d0,d5
	move.l	d5,d7
	move.w	lbot(pc),d0
	sub.w		ltop(pc),d0
	lsr.w		d0
	bne.s		.ok4
	addq		#1,d0
.ok4	move.w	d3,d5
	sub.w		ltop(pc),d5
	sub.w		d0,d5
	bmi.s		.ok2
	neg.w		d5
.ok2	add.w		d0,d5
	bpl.s		.ok6
	moveq		#0,d5
.ok6	ext.l		d0
	ext.l		d5
	swap		d5
	divu.l	d0,d5
	mulu.l	d5,d0:d7
	move.w	d0,d7
	swap		d7
	moveq		#1,d5
	swap		d5
	sub.l		d7,d5
	move.w	LAST_COLOUR,d4
	ext.l		d4
	mulu.l	d4,d5
	move.w	FIRST_COLOUR,d4
	ext.l		d4
	mulu.l	d4,d7
	add.l		d5,d7
	swap		d7
	move.w	d7,d0
	pushall
	move.w	y1,d2
	jsr		PLOT_LOG_DOT
	popall
	addq		#1,d1
	cmp.w		lrgt(pc),d1
	ble		.scan
	rts

GRADIENT_2D_TRUE:
	move.w	d1,llft
	move.w	d2,lrgt
	move.w	CANVAS_WIDTH,d6
	lsr.w		#3,d6
	ext.l		d6
	move.l	BACK_SCR(pc),a2
	move.w	y1,d0
	mulu.w	d6,d0
	add.l		d0,a2
.scan	move.w	d1,d0
	lsr.w		#4,d0
	lea		(a2,d0.w*2),a0
	moveq		#16-1,d7
	and.w		d1,d7
	move.w	#$8000,d0
	lsr.w		d7,d0
	move.l	a0,a1
	move.w	y1,d4
.nxtu	subq		#1,d4
	bmi.s		.gotu
	sub.l		d6,a0
	move.w	d0,d5
	and.w		(a0),d5
	bne.s		.nxtu
.gotu	addq		#1,d4
	move.w	d4,ltop
	move.w	y1,d4
.nxtd	addq		#1,d4
	cmp.w		CANVAS_HEIGHT,d4
	bge.s		.gotd
	add.l		d6,a1
	move.w	d0,d5
	and.w		(a1),d5
	bne.s		.nxtd
.gotd	subq		#1,d4
	move.w	d4,lbot
	move.w	lrgt(pc),d0
	sub.w		llft(pc),d0
	lsr.w		d0
	bne.s		.ok3
	moveq		#1,d0
.ok3	move.w	d1,d5
	sub.w		llft(pc),d5
	sub.w		d0,d5
	bmi.s		.ok1
	neg.w		d5
.ok1	add.w		d0,d5
	bpl.s		.ok5
	moveq		#0,d5
.ok5	ext.l		d0
	ext.l		d5
	swap		d5
	divu.l	d0,d5
	move.l	d5,d7
	move.w	lbot(pc),d0
	sub.w		ltop(pc),d0
	lsr.w		d0
	bne.s		.ok4
	moveq		#1,d0
.ok4	move.w	d3,d5
	sub.w		ltop(pc),d5
	sub.w		d0,d5
	bmi.s		.ok2
	neg.w		d5
.ok2	add.w		d0,d5
	bpl.s		.ok6
	moveq		#0,d5
.ok6	ext.l		d0
	ext.l		d5
	swap		d5
	divu.l	d0,d5
	mulu.l	d5,d0:d7
	move.w	d0,d7
	swap		d7
	moveq		#1,d5
	swap		d5
	sub.l		d7,d5
	bpl.s		.pos
	moveq		#0,d5
.pos	pushall
	move.l	d1,a1
	move.w	LAST_COLOUR,d0
	bsr		Get_RGB
	ext.l		d1
	ext.l		d2
	ext.l		d3
	mulu.l	d5,d1
	mulu.l	d5,d2
	mulu.l	d5,d3
	move.l	d1,d4
	move.l	d2,d5
	move.l	d3,d6
	move.w	FIRST_COLOUR,d0
	bsr		Get_RGB
	ext.l		d1
	ext.l		d2
	ext.l		d3
	mulu.l	d7,d1
	mulu.l	d7,d2
	mulu.l	d7,d3
	add.l		d1,d4
	add.l		d2,d5
	add.l		d3,d6
	swap		d4
	swap		d5
	swap		d6
	bfins		d4,d0{16:8+7}
	bfins		d5,d0{21:8+7}
	bfins		d6,d0{27:8+7}
	move.l	a1,d1
	move.w	y1,d2
	jsr		PLOT_LOG_DOT
	popall
	addq		#1,d1
	cmp.w		lrgt(pc),d1
	ble		.scan
	rts

ltop:	ds.w		1
lbot:	ds.w		1
llft:	ds.w		1
lrgt:	ds.w		1

MASK_SCR:	ds.l	1	
BACK_SCR:	ds.l	1
LINE_TYPE:	ds.l	1

stack:	ds.l	1

fill_x:	ds.w	1
fill_y:	ds.w	1

DO_FILL:
	move.l	sp,stack
	move.w	d1,fill_x
	move.w	d2,fill_y

	move.l	EDGEBUFFER_PTR,d0
	move.l	d0,sp
	add.l		#64000,sp
	add.l		#256,d0
	move.l	d0,EDGEBUFFER_LIMIT

	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	mulu		CANVAS_HEIGHT,d0
	lsr.l		#3,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.err
	move.l	a0,MASK_SCR

	move.l	LOG_SCR,a0
	move.l	MASK_SCR,a1
	bsr.s		MASK_SCREEN

	sf		FILL_ERROR
	push.w	fill_x
	push.w	fill_y
	bsr		SEED_FILL
	addq		#4,sp

.err	move.l	stack,sp
	rts

MASK_SCREEN:
	tst.b		TRUE_FLAG
	bne.s		MTRU
.BPL:	move.w	OLD_COL,d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d3-d6
	move.w	CANVAS_HEIGHT,d7
	bra		.ys
.ylp	move.w	CANVAS_WIDTH,d2
	lsr.w		#4,d2
	bra		.xs
.xlp	move.l	(a0)+,d0
	eor.l		d3,d0
	move.l	(a0)+,d1
	eor.l		d4,d1
	or.l		d1,d0
	move.l	(a0)+,d1
	eor.l		d5,d1
	or.l		d1,d0
	move.l	(a0)+,d1
	eor.l		d6,d1
	or.l		d1,d0
	move.w	d0,d1
	swap		d0
	or.w		d0,d1
	not.w		d1
	move.w	d1,(a1)+
.xs	dbra		d2,.xlp
.ys	dbra		d7,.ylp
	rts

MTRU:	move.w	OLD_COL,d2
	move.w	#$8000,d4
	move.w	CANVAS_HEIGHT,d7
	bra.s		.ys
.ylp2	move.w	CANVAS_WIDTH,d6
	bra.s		.xs
.xlp2	cmp.w		(a0)+,d2
	bne.s		.skip
	or.w		d5,d0
.skip	lsr.w		d5
	bcc.s		.next
	move.w	d0,(a1)+
.xs	moveq		#0,d0
	move.w	d4,d5
.next	dbra		d6,.xlp2
	cmp.w		d4,d5
	beq.s		.ys
	move.w	d0,(a1)+
.ys	dbra		d7,.ylp2
	rts

HSVMASK_SCREEN:
	move.w	OLD_COL,MASK_COLOUR
	jsr		Init_DSP_HSVMASKFILL
	move.w	OLD_COL,d2
	move.w	#$8000,d4
	move.w	CANVAS_HEIGHT,d7
	bra		.ys
.ylp2	move.w	CANVAS_WIDTH,d6
	bra.s		.xs
.xlp2	dspwrite	(a0)+
	dspread	d2
	beq.s		.skip
	or.w		d5,d0
.skip	lsr.w		d5
	bcc.s		.next
	move.w	d0,(a1)+
.xs	moveq		#0,d0
	move.w	d4,d5
.next	dbra		d6,.xlp2
	cmp.w		d4,d5
	beq.s		.ys
	move.w	d0,(a1)+
.ys	dbra		d7,.ylp2
	rts

SEED_FILL:
;	d1.w		x-coord
;	d2.w		y-coord

	tst.b		FILL_ERROR
	beq.s		examine_horizontal
	rts

examine_horizontal:
	cmp.l		EDGEBUFFER_LIMIT,sp
	sle		FILL_ERROR

look_left:
	move.w	sx1(sp),d1
	move.w	sy1(sp),d2
	move.w	d2,y1
	move.w	d1,d0
	lsr.w		#4,d0
	lea		([MASK_SCR.w,pc],d0.w*2),a0
	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	mulu		d2,d0
	add.l		d0,a0
	moveq		#0,d6
	move.w	(a0),d0
	not.w		d0
	bra.s		.slow
.next	move.w	(a0),d0
	not.w		d0
	bne.s		.slow			; scan slowly if at line start/end
	move.w	d6,(a0)
.fast	subq.l	#2,a0			; advance 1 word
	sub.w		#16,d1		; advance 16 pixels
	and.w		#-16,d1
	add.w		#16-1,d1
	bpl.s		.next			; repeat until start of line
	moveq		#0,d1
	bra.s		.done
.slow	move.w	#$8000,d4
	moveq		#16-1,d3
	and.w		d1,d3
	lsr.w		d3,d4
.scan	move.w	d0,d5
	and.w		d4,d5
	bne.s		.stop
	move.w	d4,d5
	not.w		d5
	and.w		d5,(a0)
	add.w		d4,d4
	bcs.s		.fast
	subq		#1,d1
	bra.s		.scan
.stop	addq		#1,d1
.done	move.w	d1,x1

look_right:
	move.w	sx1(sp),d1
	move.w	sy1(sp),d2
	addq		#1,d1
	move.w	d2,y1
	move.w	d1,d0
	lsr.w		#4,d0
	lea		([pc,MASK_SCR.w],d0.w*2),a0
	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	mulu		d2,d0
	add.l		d0,a0
	moveq		#0,d6
	move.w	CANVAS_WIDTH,d7
	subq		#1,d7
	move.w	(a0),d0
	not.w		d0
	bra.s		.strt
.next	move.w	(a0),d0
	not.w		d0
	bne.s		.slow			; scan slowly if at line start/end
	move.w	d6,(a0)		; clear word
.fast	addq.l	#2,a0			; advance 1 word
	add.w		#16,d1		; advance 16 pixels
	and.w		#-16,d1
.strt	cmp.w		d7,d1
	ble.s		.next			; repeat until start of line
	move.w	d7,d1
	bra.s		.done
.slow	move.w	#$8000,d4
	moveq		#16-1,d3
	and.w		d1,d3
	lsr.w		d3,d4
.scan	move.w	d0,d5
	and.w		d4,d5
	bne.s		.stop
	move.w	d4,d5
	not.w		d5
	and.w		d5,(a0)
	lsr.w		d4
	bcs.s		.fast
	addq		#1,d1
	bra.s		.scan
.stop	subq		#1,d1
.done	move.w	d1,x2

draw_line:
	move.w	NEW_COL,d0
	move.w	x1,d1
	move.w	x2,d2
	move.w	y1,d3
	jsr		([LINE_TYPE.w,pc])

examine_vertical:
	move.w	x2,-(sp)
	move.w	x1,-(sp)
	move.w	y1,-(sp)

look_above:
	move.w	lx1(sp),d1
	move.w	ly1(sp),d2
	subq		#1,d2
	bmi.s		look_below
.next	move.w	d1,d0
	lsr.w		#4,d0
	lea		([pc,MASK_SCR.w],d0.w*2),a0
	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	mulu		d2,d0
	add.l		d0,a0
	move.w	(a0),d0
	not.w		d0
	bne.s		.slow
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	bsr		SEED_FILL
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	add.w		#16,d1
	and.w		#-16,d1
	cmp.w		lx2(sp),d1
	ble.s		.next
	bra.s		.done
.slow	moveq		#16-1,d3
	and.w		d1,d3
	move.w	#$8000,d4
	lsr.w		d3,d4
	and.w		d4,d0
	bne.s		.skip
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	bsr		SEED_FILL
	move.w	(sp)+,d2
	move.w	(sp)+,d1
.skip	addq		#1,d1
	cmp.w		lx2(sp),d1
	ble.s		.next
.done

look_below:
	move.w	x1,d1
	move.w	y1,d2
	move.w	lx1(sp),d1
	move.w	ly1(sp),d2
	addq		#1,d2
	cmp.w		CANVAS_HEIGHT,d2
	bge.s		vertical_done
.next	move.w	d1,d0
	lsr.w		#4,d0
	lea		([pc,MASK_SCR.w],d0.w*2),a0
	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	mulu		d2,d0
	add.l		d0,a0
	move.w	(a0),d0
	not.w		d0
	bne.s		.slow
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	bsr		SEED_FILL
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	add.w		#16,d1
	and.w		#-16,d1
	cmp.w		lx2(sp),d1
	ble.s		.next
	bra.s		.done
.slow	moveq		#16-1,d3
	and.w		d1,d3
	move.w	#$8000,d4
	lsr.w		d3,d4
	and.w		d4,d0
	bne.s		.skip
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	bsr		SEED_FILL
	move.w	(sp)+,d2
	move.w	(sp)+,d1
.skip	addq		#1,d1
	cmp.w		lx2(sp),d1
	ble.s		.next
.done

vertical_done:
	addq.l	#6,sp
	rts
	
Draw_airbrush:
	moveq		#I_Draw_airbrush,d0
	moveq		#station_draw,d1
	lea		Draw_airbrush_code,a0
	lea		WIN_Draw_airbrush,a1
	bsr		Check_tool_dialog
	bsr		Setup_tool
	bsr		Permanent_tool
	rts

Draw_airbrush_code:
	init_tool
	st		BITMAP_CHANGED
	bsr		INIT_PENCIL
	bsr		Keep_undo
	st		SOFTWARE_MOUSE
	move.w	#8,brush_deviance
	tst.w		BRUSH_TYPE
	bpl.s		.loop
	move.w	#1,brush_deviance
.loop	jsr		Do_extra_macros
	move.w	CANVAS_WIDTH,X1
	move.w	CANVAS_HEIGHT,Y1
	move.w	#0,X2
	move.w	#0,Y2
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	cmp.w		#1<<Bit_AIR_FREE,AIR_BITS
	beq.s		.cont
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq		.skip
.cont	move.w	AIRBRUSH_FLOW,d7
.dots	push.w	d7	
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	bsr		Scale_D3D4
	lea		SINE,a0
	rand		d0
	and.w		#4096-1,d0
	move.w	(a0,d0.w*2),d1
	add.w		#4096/4,d0
	and.w		#4096-1,d0
	move.w	(a0,d0.w*2),d2
	ext.l		d1
	ext.l		d2
	add.l		d1,d1
	add.l		d2,d2
	rand		d0
	and.l		#255,d0
	muls.l	d0,d1
	muls.l	d0,d2
	asr.l		#8,d1
	asr.l		#8,d2
	move.w	AIRBRUSH_SIZE,d0
	muls.w	d0,d1
	muls.w	d0,d2
	cmp.w		#1,x_factor
	beq.s		.nx
	add.l		d1,d1
.nx	cmp.w		#1,y_factor
	beq.s		.ny
	add.l		d2,d2
.ny	swap		d1
	swap		d2
	ext.l		d1
	ext.l		d2
	add.w		d3,d1
	add.w		d4,d2
	cmp.w		X1,d1
	bge.s		.nux1
	move.w	d1,X1
.nux1	cmp.w		X2,d1
	ble.s		.nux2
	move.w	d1,X2
.nux2	cmp.w		Y1,d2
	bge.s		.nuy1
	move.w	d2,Y1
.nuy1	cmp.w		Y2,d2
	ble.s		.nuy2
	move.w	d2,Y2
.nuy2	move.w	FG_COLOUR,d0
	tst.w		BRUSH_TYPE
	bmi.s		.dot
	bsr		DRAW_LOG_BRUSH
	bra.s		.done
.dot	jsr		PLOT_LOG_DOT
.done	pop.w		d7
	dbra		d7,.dots
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	jsr		Superscale_zone
.skip	cmp.b		#left_button,BUTTONS
	beq		.loop
	clr.w		brush_deviance
	sf		SOFTWARE_MOUSE
	bsr		MOUSE_WAITMODE
	rts

SEED:	dc.l		INITSEED


Kill_morphlines:
	tst.w		GUIDE_COUNT
	beq.s		.err
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
.loop	clr.w		guide_state(a0)
	move.w	guide_next(a0),d0
	bmi.s		.done
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	bra.s		.loop
.done	clr.w		GUIDE_COUNT
	clr.w		FIRST_GUIDE
	clr.w		GUIDE_SELECTED
.err	rts


Morph_line:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Morph_line,d0
	moveq		#station_morph,d1
	lea		Morph_line_code,a0
	bsr		Setup_tool
	bsr		Permanent_tool
	sf		MORPH_HANDLES
	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
	endc
.exit	rts

Morph_line_code:
	ifnd		cutdown
	init_tool
	bsr		INIT_PENCIL
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
*-----------------------------------------*
* Get tween range / check frame integrity	*
*-----------------------------------------*
	jsr		get_range
	jsr		sort_range
	move.w	CUR_DELTAFRAME,d2
	cmp.w		d0,d1				; quit if only 1 frame
	beq		.err
	cmp.w		d0,d2				; quit if below 1st frame
	blt		.err
	cmp.w		d1,d2				; quit if after last frame
	bgt		.err
*-----------------------------------------*
	move.w	X1,X2
	move.w	Y1,Y2
	cmp.w		#max_handles,GUIDE_COUNT
	bge		.err
	bsr		Add_line
	tst.l		d0
	bmi		.err
	clr.w		OLD_Y1
	move.w	CANVAS_HEIGHT,OLD_Y2
	move.w	#4,brush_deviance
*-----------------------------------------*
.strt	move.w	GUIDE_SELECTED,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	move.l	a0,HANDLE_PTR
	move.w	guide_x1_1(a0),X1
	move.w	guide_y1_1(a0),Y1
*-----------------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,guide_x2_1(a0)
	move.w	d4,guide_y2_1(a0)
	move.w	d3,guide_x2_2(a0)
	move.w	d4,guide_y2_2(a0)
	move.w	d3,X2
	move.w	d4,Y2
	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	move.w	GUIDE_SELECTED,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	move.w	guide_x1_1(a0),d1
	move.w	guide_y1_1(a0),d2
	sub.w		guide_x2_1(a0),d1
	sub.w		guide_y2_1(a0),d2
	or.w		d1,d2
	beq.s		.kill
	move.w	guide_x1_2(a0),d1
	move.w	guide_y1_2(a0),d2
	sub.w		guide_x2_2(a0),d1
	sub.w		guide_y2_2(a0),d2
	or.w		d1,d2
	bne.s		.err
.kill	bsr		delete_line	
	jsr		Remove_mouseptr
	jsr		Superscaler
	bra.s		.ex
.err	jsr		Remove_mouseptr
.ex	sf		SOFTWARE_MOUSE
	bsr		MOUSE_WAITMODE
	endc
	rts

Morph_drag:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Morph_drag,d0
	moveq		#station_morph,d1
	lea		Morph_drag_code,a0
	bsr		Setup_tool
	bsr		Permanent_tool
	st		MORPH_HANDLES
	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
	endc
.exit	rts

Morph_drag_code:
	ifnd		cutdown
	init_tool
	bsr		INIT_PENCIL
	st		SOFTWARE_MOUSE
*-----------------------------------------*
	tst.w		GUIDE_COUNT
	beq		.err
	jsr		get_range
	jsr		sort_range
	move.w	d0,OLAY_START
	move.w	d1,OLAY_END
	move.w	CUR_DELTAFRAME,d2
	cmp.w		d0,d1				; quit if only 1 frame
	beq		.err
	cmp.w		d0,d2				; continue if on 1st frame
	beq.s		.strt
	cmp.w		d1,d2				; continue if on last frame
	bne		.err				; otherwise, exit.
*-----------------------------------------*
.strt	clr.w		OLD_Y1
	move.w	CANVAS_HEIGHT,OLD_Y2
	move.w	#4,brush_deviance
	jsr		Update_mouseptr
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
*-----------------------------------------*
	lea		HANDLE_LIST,a1
	clr.w		HANDLE_COUNT
	moveq		#0,d1
	move.w	OLAY_START,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.next
	moveq		#8,d1
.next	lea		guide_x1_1(a0,d1.w),a2
	move.l	a2,(a1)+
	move.l	guide_x2_1(a0,d1.w),(a1)+
	move.w	guide_name(a0),(a1)+
	lea		guide_x2_1(a0,d1.w),a2
	move.l	a2,(a1)+
	move.l	guide_x1_1(a0,d1.w),(a1)+
	move.w	guide_name(a0),(a1)+
	addq		#2,HANDLE_COUNT
	move.w	guide_next(a0),d0
	bmi.s		.done
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0		; address of data
	bra.s		.next	
*-----------------------------------------*
.done	bsr		FIND_HANDLE_PTR
	move.l	HANDLE_PTR,d0
	beq		.stop
	move.l	d0,a0
	move.w	4(a0),X1
	move.w	6(a0),Y1
	move.w	8(a0),GUIDE_SELECTED
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.l	([HANDLE_PTR.l]),a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	move.w	d3,X2
	move.w	d4,Y2
	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	move.w	GUIDE_SELECTED,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	move.w	guide_x1_1(a0),d1
	move.w	guide_y1_1(a0),d2
	sub.w		guide_x2_1(a0),d1
	sub.w		guide_y2_1(a0),d2
	or.w		d1,d2
	beq.s		.kill
	move.w	guide_x1_2(a0),d1
	move.w	guide_y1_2(a0),d2
	sub.w		guide_x2_2(a0),d1
	sub.w		guide_y2_2(a0),d2
	or.w		d1,d2
	bne.s		.stop
.kill	bsr		delete_line	
.stop	jsr		Remove_mouseptr
	jsr		Superscaler
.err	sf		SOFTWARE_MOUSE
	bsr		MOUSE_WAITMODE
	endc
	rts

Morph_del_l:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		HIDE_MOUSE
	seticon	I_Morph_del_l,station_morph
	bsr		Redraw_menu_icons
	delay		8
	tst.b		MORPH_HANDLES
	beq		.err
	tst.w		GUIDE_COUNT
	beq		.err
	jsr		get_range
	cmp.w		d0,d1			; quit if only 1 frame
	beq.s		.err
	bsr		delete_line
.err	jsr		Superscaler
	reseticon
	bsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	endc
.exit	rts

delete_line:
	ifnd		cutdown
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	move.l	a0,a1
	move.w	GUIDE_SELECTED,d1
.loop	cmp.w		guide_name(a0),d1
	beq.s		.del
	move.l	a0,a1
	move.w	guide_next(a0),d0
	bmi.s		.err
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	bra.s		.loop
.del	clr.w		guide_state(a0)
	move.w	guide_next(a0),d0
	move.w	guide_name(a0),d1
	cmp.w		FIRST_GUIDE,d1
	bne.s		.nfrs
	move.w	d0,FIRST_GUIDE
	bra.s		.frst
.nfrs	move.w	d0,guide_next(a1)
.frst	subq		#1,GUIDE_COUNT
	bne.s		.many
	clr.w		FIRST_GUIDE
.many	move.w	FIRST_GUIDE,GUIDE_SELECTED
	endc
.err	rts

Morph_del_a:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		HIDE_MOUSE
	seticon	I_Morph_del_a,station_morph
	bsr		Redraw_menu_icons
	delay		12
	tst.w		GUIDE_COUNT
	beq.s		.err
	bsr		Kill_morphlines
	jsr		Superscaler
.err	reseticon
	bsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	endc
.exit	rts

Morph_area:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Morph_area,d0
	moveq		#station_morph,d1
	lea		Morph_area_code,a0
	bsr		Setup_tool
	jsr		HIDE_MOUSE
	st		CROSSHAIR
	jsr		SHOW_MOUSE
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	jsr		Check_menu
.skip	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
	endc
.exit	rts

Morph_area_code:
	ifnd		cutdown
	init_tool
	bsr		Init_cut_coords
	bsr		INIT_PENCIL
	bsr		Keep_undo
	sf		UNDO_VALID
	sf		CROSSHAIR
	push.b	ENABLE_GUIDES
	st		SOFTWARE_MOUSE
	sf		ENABLE_GUIDES
	jsr		Superscaler
	jsr		Update_mouseptr
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d3-d4,-(sp)
	bsr		COPYBACK
	jsr		Remove_mouseptr
	movem.w	(sp)+,d3-d4
	bsr		Scale_D3D4
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	jsr		DRAW_LOG_OUTLINE
	jsr		Superscale_zone
	jsr		Print_cut_coords
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		Refresh_info_bar
	clr.w		brush_deviance
	bsr		COPYBACK
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	cmp.w		d3,d1
	ble.s		.ok1
	exg		d3,d1
.ok1	cmp.w		d4,d2
	ble.s		.ok2
	exg		d4,d2
.ok2	move.w	d1,Morph_x1
	move.w	d2,Morph_y1
	move.w	d3,Morph_x2
	move.w	d4,Morph_y2
	sub.w		d1,d3
	addq		#1,d3
	move.w	d3,Morph_width
	sub.w		d2,d4
	addq		#1,d4
	move.w	d4,Morph_height
	jsr		Remove_mouseptr
	pop.b		ENABLE_GUIDES
	sf		SOFTWARE_MOUSE
	jsr		Superscaler
	bsr		Update_chstate
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	bsr		Reset_tool
	endc
	rts

*-----------------------------------------------*
Morph_go:
*-----------------------------------------------*
	ifnd		cutdown
	jsr		Get_changes				; store any changes
	tst.l		d0
	bmi		.rts
*-----------------------------------------------*
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	jsr		Check_menu
.skip	sf		Memory_error
*-----------------------------------------------*
	move.w	#1,CURFRAME				; startframe=1
	tst.w		GUIDE_COUNT
	beq		.err2	
*-----------------------------------------------*
	jsr		get_range
	jsr		sort_range
	move.w	d0,OLAY_START
	move.w	d1,OLAY_END
	cmp.w		d0,d1					; quit if only 1 frame
	beq		.err2
	cmp.b		#tween_frame,TWEEN_TYPE		; go ahead if only 1 frame
	bne.s		.nchk
	move.w	CUR_DELTAFRAME,d2
	cmp.w		d0,d2					; quit if below 1st frame
	blt		.err
	cmp.w		d1,d2					; quit if after last frame
	bgt		.err
*-----------------------------------------------*
.nchk	moveq		#default2frame,d0			; frame mode = 1 frame
	jsr		init_tween				; work out TWEEN range
	tst.l		d0
	bmi		.err
*-----------------------------------------------*
	move.w	TWEEN_END,d0
	sub.w		TWEEN_START,d0
	addq		#1,d0
	move.w	d0,MAXFRAME
*-----------------------------------------------*
	cmp.w		#1<<Bit_MORPH2_MORPH,MORPH2_BITS
	bne.s		.go
	tst.b		TRUE_FLAG				; stop if not in truecolour
	beq		.err1
*-----------------------------------------------*
.go	cmp.b		#tween_frame,TWEEN_TYPE		; go ahead if only 1 frame
	beq.s		.cont
	tst.b		TWEEN_FLAG
	beq		.err					; stop if error ocurred
	move.w	TWEEN_START,d0
	jsr		Frame_goto
*-----------------------------------------------*
.cont	jsr		HIDE_MOUSE
	seticon	I_Morph_go,station_morph
	bsr		Redraw_menu_icons
	st		FRAMECOUNT
*-----------------------------------------------*
.next	sf		ENABLE_GUIDES
	jsr		Superscaler
	bsr		SET_PHYS_CANVAS
	addq.b	#1,BUSY
	jsr		Start_morph
	cmp.w		#1<<Bit_MORPH2_DISTORT,MORPH2_BITS
	beq.s		.dist
.mrph	jsr		Render_morph_DSP
	bra.s		.done
.dist	jsr		Render_distort_DSP
.done	cmp.w		#1<<Bit_MORPH1_PREVIEW,MORPH1_BITS
	beq.s		.no
	st		BITMAP_CHANGED
.no	subq.b	#1,BUSY
	bsr		SET_LOG_CANVAS
	st		ENABLE_GUIDES
	jsr		Superscaler
	bsr		advance_tween
	tst.l		d0
	bmi		.exit
	tst.b		ABORT_TWEEN
	bne.s		.exit
	tst.b		TWEEN_FLAG
	beq.s		.exit
	tst.b		Memory_error
	beq.s		.next
	bsr		reset_tween
*-----------------------------------------------*
.exit	reseticon
	bsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
.err	tst.b		MENU_UP
	beq.s		.rts
	not.b		MENU_UP
	jsr		Check_menu
.rts	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	rts
.err1	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
.err2	lea		WIN_CFG_Alert,a0
	jsr		DO_ALERT
	bra		.err
	endc
	rts
	
*-----------------------------------------------*
Morph_options:
*-----------------------------------------------*
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	moveq		#I_Morph_options,d0
	moveq		#station_morph,d1
	lea		WIN_Setup_morph,a1
	bra		Tool_dialog_box
	endc
.err	rts

*-----------------------------------------------*
init_tween:
*-----------------------------------------------*
	move.w	CUR_DELTAFRAME,OLD_CUR_FRAME	; keep initial frame
	move.w	#1,TWEEN_DIR
	sf		ABORT_TWEEN
*-----------------------------------------------*
	cmp.b		#default2frame,d0
	beq.s		.fram
*-----------------------------------------------*
.all	clr.w		TWEEN_START
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,TWEEN_END
	st		TWEEN_FLAG
	cmp.b		#tween_segment,TWEEN_TYPE	; is tweening required
	beq.s		.mult
	bra		.exit
*-----------------------------------------------*
.fram	move.w	CUR_DELTAFRAME,TWEEN_START
	move.w	CUR_DELTAFRAME,TWEEN_END
	sf		TWEEN_FLAG
*-----------------------------------------------*
.cont	cmp.b		#tween_frame,TWEEN_TYPE		; is tweening required
	bne		.mult
.exit	moveq		#0,d0
	rts
*-----------------------------------------------*
.mult	jsr		segment_check
	tst.b		OK_CANCEL
	beq.s		.err
	move.w	RANGE_START,TWEEN_START
	move.w	RANGE_END,TWEEN_END
	move.w	RANGE_DIR,TWEEN_DIR
	st		TWEEN_FLAG
	bra.s		.exit
.err	moveq		#-1,d0
	rts

check_framerange:
	move.w	Delta_count,d1
	subq		#1,d1
	cmp.w		d1,d0
	ble.s		.ok
	move.w	d1,d0
.ok	rts

clip_segment:
	move.w	SEGMENT_START,d0
	jsr		check_framerange
	move.w	d0,SEGMENT_START
	move.w	SEGMENT_END,d0
	jsr		check_framerange
	move.w	d0,SEGMENT_END
	rts

*-----------------------------------------------*
advance_tween:
*-----------------------------------------------*
	tst.b		TWEEN_FLAG
	beq		.exit
*-----------------------------------------------*
	jsr		Get_changes
	tst.l		d0
	bmi.s		.err	
*-----------------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	cmp.w		TWEEN_END,d0
	bne.s		.cont
	st		ABORT_TWEEN
	bra.s		.exit
.cont	addq		#1,CURFRAME
	add.w		TWEEN_DIR,d0
	jsr		Frame_goto
.exit	moveq		#0,d0
.err	rts

*-----------------------------------------------*
reset_tween:
*-----------------------------------------------*
	tst.b		TWEEN_FLAG
	beq.s		.no
	move.w	OLD_CUR_FRAME,d0
	jsr		Frame_goto
.no	rts

*-----------------------------------------------*
get_range:
*-----------------------------------------------*
	move.w	#1,RANGE_DIR
	move.w	Delta_count,d1
	subq		#1,d1
	moveq		#0,d0	
	cmp.b		#tween_segment,TWEEN_TYPE
	bne.s		.rts
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
.rts	cmp.w		d1,d0
	ble.s		.rght
	neg.w		RANGE_DIR
.rght	move.w	d0,RANGE_START
	move.w	d1,RANGE_END
	rts
	
*-----------------------------------------------*
sort_range:
*-----------------------------------------------*
	move.w	RANGE_START,d0
	move.w	RANGE_END,d1
	cmp.w		d1,d0
	ble.s		.rght
	exg		d1,d0
	neg.w		RANGE_DIR
.rght	move.w	d0,RANGE_START
	move.w	d1,RANGE_END
	rts
	
RANGE_START:	ds.w	1
RANGE_END:		ds.w	1
RANGE_DIR:		ds.w	1

*-----------------------------------------------*

Colour_cut:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	seticon	I_Colour_cut,station_colour
	bsr		Redraw_menu_icons
	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	move.w	d2,PALCOPY_COUNT
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		Colour_cut_BUFFER,a2
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	move.l	(a1,d3.w*4),(a2)+
	dbra		d2,.loop
	st		Colour_cut_READY
	delay		5
	reseticon
	bsr		Redraw_menu_icons
.exit	rts

Colour_cut_READY:	dc.b	0
			even

Colour_paste:
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	tst.b		Colour_cut_READY
	beq		.rts
	seticon	I_Colour_paste,station_colour
	bsr		Redraw_menu_icons
	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	cmp.w		PALCOPY_COUNT,d2
	ble.s		.ok4
	move.w	PALCOPY_COUNT,d2
.ok4	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		Colour_cut_BUFFER,a2
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	move.l	(a2)+,(a1,d3.w*4)
	dbra		d2,.loop
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	delay		2
	jsr		Update_palette
	reseticon
	bsr		Redraw_menu_icons
	jsr		Update_palette_zone
.rts	rts

PALCOPY_COUNT:	ds.w	1
	
Colour_exchange:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	seticon	I_Colour_exchange,station_colour
	bsr		Redraw_menu_icons
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	move.w	FG_INDEX,d1
	move.w	BG_INDEX,d2
	moveq		#0,d3
	moveq		#0,d4
	move.b	(a0,d1.w),d3
	move.b	(a0,d2.w),d4
	move.l	(a1,d3.w*4),d5
	move.l	(a1,d4.w*4),(a1,d3.w*4)
	move.l	d5,(a1,d4.w*4)
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	delay		2
	jsr		Update_palette
	reseticon
	bsr		Redraw_menu_icons
	jsr		Update_palette_zone
.exit	rts

Colour_spread:
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	seticon	I_Colour_spread,station_colour
	bsr		Redraw_menu_icons
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	move.w	COL1_INDEX,d5
	move.w	COL2_INDEX,d6
	cmp.w		d5,d6
	bge.s		.ok4	
	exg		d5,d6
.ok4	move.w	d5,CUR_INDEX
	move.w	d5,INDEX1
	move.w	d6,INDEX2
	move.w	INDEX2,d7
	sub.w		INDEX1,d7
.loop	move.w	INDEX2,d0
	sub.w		INDEX1,d0
	move.w	d0,INDEX_SCALER
	move.w	CUR_INDEX,d1
	sub.w		INDEX1,d1
	move.w	d1,INDEX2_SCALER
	sub.w		d1,d0
	move.w	d0,INDEX1_SCALER
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	moveq		#0,d5
	moveq		#0,d6
	move.w	INDEX1,d0
	move.b	(a0,d0.w),d0
	move.b	1(a1,d0.w*4),d1
	move.b	2(a1,d0.w*4),d2
	move.b	3(a1,d0.w*4),d3
	move.w	INDEX1_SCALER,d0
	mulu		d0,d1
	mulu		d0,d2
	mulu		d0,d3
	move.w	INDEX2,d0
	move.b	(a0,d0.w),d0
	move.b	1(a1,d0.w*4),d4
	move.b	2(a1,d0.w*4),d5
	move.b	3(a1,d0.w*4),d6
	move.w	INDEX2_SCALER,d0
	mulu		d0,d4
	mulu		d0,d5
	mulu		d0,d6
	add.l		d1,d4
	add.l		d2,d5
	add.l		d3,d6
	move.w	INDEX_SCALER,d0
	divu		d0,d4
	divu		d0,d5
	divu		d0,d6
	move.w	CUR_INDEX,d0
	move.b	(a0,d0.w),d0
	and.b		COLMASK+1,d4
	and.b		COLMASK+2,d5
	and.b		COLMASK+3,d6
	move.b	d4,1(a1,d0.w*4)
	move.b	d5,2(a1,d0.w*4)
	move.b	d6,3(a1,d0.w*4)
	addq		#1,CUR_INDEX
	dbra		d7,.loop
	lea		COLOURS,a0
	lea		COLOURS,a1
	jsr		COPYCOLS
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	delay		2
	jsr		Update_palette
	reseticon
	bsr		Redraw_menu_icons
	jsr		Update_palette_zone
.rts	rts

CUR_INDEX:		ds.w	1
INDEX_SCALER:	ds.w	1
INDEX1:		ds.w	1
INDEX2:		ds.w	1
INDEX1_SCALER:	ds.w	1
INDEX2_SCALER:	ds.w	1

Colour_flip:
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.go
	rts
.go	seticon	I_Colour_flip,station_colour
	bsr		Redraw_menu_icons
	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		(4+PALETTE_COPY.l,d2.w*4),a2
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	move.l	(a1,d3.w*4),-(a2)
	dbra		d2,.loop

cflip	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		PALETTE_COPY,a2
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	move.l	(a2)+,(a1,d3.w*4)
	dbra		d2,.loop
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	delay		2
	jsr		Update_palette
	reseticon
	jsr		Redraw_menu_icons
	jsr		Update_palette_zone
.exit	rts

		rsreset
sort_NONE	rs.b	1
sort_LUM	rs.b	1
sort_REV	rs.b	0
sort_CHR	rs.b	1
sort_PER	rs.b	0
sort_RED	rs.b	1
sort_GRN	rs.b	1
sort_BLU	rs.b	1

Colour_sort:
	move.b	#sort_NONE,sort_type
	move.w	#I_Colour_sort,d0
	moveq		#station_colour,d1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.cont
	lea		WIN_Colour_sort2,a1
	jsr		Tool_dialog_box
	cmp.b		#sort_NONE,sort_type
	beq		.rts
	cmp.b		#sort_REV,sort_type
	beq		unsort
	bra		applysort
.cont	lea		WIN_Colour_sort,a1
	jsr		Tool_dialog_box
	cmp.b		#sort_NONE,sort_type
	beq		.rts
	lea		COLOURS,a0
	lea		COLOURS,a1
	jsr		COPYCOLS
	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	move.w	COL2_INDEX,SORT_INDEX	
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	move.w	COL1_INDEX,SORT_INDEX	
	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	move.w	d2,SORT_LENGTH
	cmp.b		#sort_LUM,sort_type
	beq		lumasort	
	cmp.b		#sort_CHR,sort_type
	beq		chromasort	
	cmp.b		#sort_RED,sort_type
	beq		redsort	
	cmp.b		#sort_GRN,sort_type
	beq		greensort	
	cmp.b		#sort_BLU,sort_type
	beq		bluesort	
.rts	rts

lumasort:
	bsr		Init_DSP_RGB_YUV
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	1(a1,d3.w*4),d5
	move.b	2(a1,d3.w*4),d6
	move.b	3(a1,d3.w*4),d7
	dspwrite	#1
	dspwrite	d5
	dspwrite	d6
	dspwrite	d7
	dspread	d5
	dspread	d6
	dspread	d7
	move.b	d5,0(a1,d3.w*4)
	dbra		d2,.loop
.rts	lea		COLOURS,a1
	bsr		sort_indices
	rts

chromasort:
	bsr		Init_DSP_RGB_YUV
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	lea		PALETTE_COPY,a6
.loop	moveq		#0,d3
	move.b	(a0,d1.w),d3
	lea		(a1,d3.w*4),a2
	add.w		d4,d1
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	1(a2),d5
	move.b	2(a2),d6
	move.b	3(a2),d7
	lea		(a6,d3.w*4),a2
	dspwrite	#1
	dspwrite	d5
	dspwrite	d6
	dspwrite	d7
	dspread	d5
	dspread	d6
	dspread	d7
	add.w		#128,d6
	add.w		#128,d7
	and.b		#%11100000,d6
	and.b		#%11100000,d7
	move.b	d6,(a2)+
	move.b	d7,(a2)+
	move.b	d5,(a2)+
	dbra		d2,.loop
.rts	lea		PALETTE_COPY,a1
	bsr		sort_indices
	rts

redsort:
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	lea		PALETTE_COPY,a6
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	lea		(a1,d3.w*4),a2
	lea		(a6,d3.w*4),a3
	add.w		d4,d1
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	1(a2),(a3)+
	move.b	2(a2),(a3)+
	move.b	3(a2),(a3)+
	dbra		d2,.loop
.rts	lea		PALETTE_COPY,a1
	bsr		sort_indices
	rts

greensort:
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	lea		PALETTE_COPY,a6
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	lea		(a1,d3.w*4),a2
	lea		(a6,d3.w*4),a3
	add.w		d4,d1
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	2(a2),(a3)+
	move.b	1(a2),(a3)+
	move.b	3(a2),(a3)+
	dbra		d2,.loop
.rts	lea		PALETTE_COPY,a1
	bsr		sort_indices
	rts

bluesort:
	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	lea		PALETTE_COPY,a6
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	lea		(a1,d3.w*4),a2
	lea		(a6,d3.w*4),a3
	add.w		d4,d1
	moveq		#0,d5
	moveq		#0,d6
	moveq		#0,d7
	move.b	3(a2),(a3)+
	move.b	2(a2),(a3)+
	move.b	1(a2),(a3)+
	dbra		d2,.loop
.rts	lea		PALETTE_COPY,a1
	bsr		sort_indices
	rts

sort_indices:
	push.l	a1
	move.w	SORT_INDEX,d0
	move.w	SORT_LENGTH,d5
	lea		(INDEX_TABLE.l,d0.w),a0
	subq		#1,d5
	ble.s		.done
	moveq		#0,d4
	moveq		#0,d6
	moveq		#0,d7
.main	move.b	(a0,d7.w),d4
	move.l	(a1,d4.l*4),d1
	move.l	d7,d6
.loop	move.b	1(a0,d6.w),d4
	cmp.l		(a1,d4.l*4),d1
	bls.s		.next
	move.b	1(a0,d6.w),d4
	move.b	(a0,d7.w),d2
	move.b	d4,(a0,d7.w)
	move.b	d2,1(a0,d6.w)
	move.l	(a1,d4.w*4),d1
.next	addq.l	#1,d6
	cmp.l		d5,d6
	bne.s		.loop
	addq.l	#1,d7
	cmp.l		d5,d7
	bne.s		.main
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	pop.l		a0
	move.l	a0,a1
	jsr		COPYCOLS
	rts

applysort:
	move.w	#256-1,d2
	moveq		#0,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	lea		PALETTE_COPY,a6
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	move.l	(a1,d3.w*4),(a6)+
	addq		#1,d1
	dbra		d2,.loop
.rts	lea		PALETTE_COPY,a0
	lea		COLOURS,a1
	jsr		COPYCOLS
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED

unsort:
	lea		INDEX_TABLE,a0
	move.w	#256-1,d0
.clr	move.b	d0,(a0,d0.w)
	dbra		d0,.clr
	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		Redraw_menu_icons
	jsr		Update_palette
	jsr		SHOW_MOUSE
	rts	
	
SORT_INDEX:		ds.w	1
SORT_LENGTH:	ds.w	1
	
Colour_grey:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	seticon	I_Colour_grey,station_colour
	bsr		Redraw_menu_icons
	bsr		Init_DSP_RGB_YUV
	move.w	COL2_INDEX,d0
	sub.w		COL1_INDEX,d0
	bpl.s		.ok1
	subq		#1,d0
	moveq		#-1,d4
	bra.s		.ok2
.ok1	addq		#1,d0
	moveq		#1,d4
.ok2	move.w	d0,d2
	bpl.s		.ok3
	neg.w		d2
.ok3	subq		#1,d2
	move.w	COL1_INDEX,d1
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	moveq		#0,d3
.loop	move.b	(a0,d1.w),d3
	add.w		d4,d1
	dspwrite	#1
	moveq		#0,d5
	move.b	1(a1,d3.w*4),d5
	dspwrite	d5
	move.b	2(a1,d3.w*4),d5
	dspwrite	d5
	move.b	3(a1,d3.w*4),d5
	dspwrite	d5
	dspread	d6
	dspread	d0
	dspread	d0
	and.w		#$FF,d6
	move.w	d6,d5
	swap		d5
	move.b	d6,d5
	ror.w		#8,d5
	move.b	d6,d5
	and.l		COLMASK,d5
	move.l	d5,(a1,d3.w*4)
	dbra		d2,.loop
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	delay		2
	jsr		Update_palette
	reseticon
	jsr		Update_palette_zone
	bsr		Redraw_menu_icons
.exit	rts

Init_DSP_RGB_YUV:
	pushall
	moveq		#1,d1
	move.l	#DSPYUV_L,d0
	lea		DSPYUV,a0
	jsr		DspExecProg
	popall
	rts

Init_DSP_CURVE:
	pushall
	moveq		#1,d1
	move.l	#DSPCURVE_L,d0
	lea		DSPCURVE,a0
	jsr		DspExecProg
	cmp.w		#1<<Bit_CURVE_BEZIER,CURVE_BITS
	beq.s		.bz
	dspwrite	#1
	bra.s		.go
.bz	dspwrite	#0
.go	popall
	rts

Init_DSP_RGB_HSV:
	pushall
	moveq		#1,d1
	move.l	#DSPHSV_L,d0
	lea		DSPHSV,a0
	jsr		DspExecProg
	popall
	rts

Init_DSP_HSVMASK:
	pushall
	moveq		#1,d1
	move.l	#DSPHSVM_L,d0
	lea		DSPHSVM,a0
	jsr		DspExecProg
	dspwrite	MATCODE
	dspwrite	CURRENT_VALPOS
	dspwrite	CURRENT_HUE2POS
	dspwrite	CURRENT_SAT2POS
	dspwrite	CURRENT_BRI2POS
	dspwrite	MASK_COLOUR
	move.w	CURRENT_HUE1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_HUE,d0
	bne.s		.g1
	move.w	#255,d1
.g1	dspwrite	d1
	move.w	CURRENT_SAT1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_SAT,d0
	bne.s		.g2
	move.w	#255,d1
.g2	dspwrite	d1
	move.w	CURRENT_BRI1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_BRI,d0
	bne.s		.g3
	move.w	#255,d1
.g3	dspwrite	d1
	dspwrite	ENAB_BITS
	popall
	rts

Init_DSP_HSVMASKFILL:
	pushall
	moveq		#1,d1
	move.l	#DSPHSVM_L,d0
	lea		DSPHSVM,a0
	jsr		DspExecProg
	dspwrite	#0
	dspwrite	#255
	dspwrite	#255
	dspwrite	#255
	dspwrite	#255
	dspwrite	OLD_COL
	move.w	CURRENT_HUE1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_HUE,d0
	bne.s		.g1
	move.w	#255,d1
.g1	dspwrite	d1
	move.w	CURRENT_SAT1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_SAT,d0
	bne.s		.g2
	move.w	#255,d1
.g2	dspwrite	d1
	move.w	CURRENT_BRI1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_BRI,d0
	bne.s		.g3
	move.w	#255,d1
.g3	dspwrite	d1
	dspwrite	#7
	popall
	rts

Init_DSP_HSVAIR:
	pushall
	moveq		#1,d1
	move.l	#DSPHSV_L,d0
	lea		DSPHSV,a0
	jsr		DspExecProg
	move.w	FG_COLOUR,d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	dspwrite	#1	
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	popall
	dspread	d3
	dspread	d2
	dspread	d1
	pushall
	moveq		#1,d1
	move.l	#DSPHSVM_L,d0
	lea		DSPHSVM,a0
	jsr		DspExecProg
	dspwrite	#7
	dspwrite	CURRENT_VALPOS
	popall
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	pushall
	dspwrite	MASK_COLOUR
	move.w	CURRENT_HUE1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_HUE,d0
	bne.s		.g1
	move.w	#255,d1
.g1	dspwrite	d1
	move.w	CURRENT_SAT1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_SAT,d0
	bne.s		.g2
	move.w	#255,d1
.g2	dspwrite	d1
	move.w	CURRENT_BRI1POS,d1
	move.w	VIEW_BITS,d0
	and.w		#1<<Bit_VIEW_BRI,d0
	bne.s		.g3
	move.w	#255,d1
.g3	dspwrite	d1
	dspwrite	ENAB_BITS
	popall
	rts
	
sort_type:	ds.b	1
		even


*-----------------------------------------------------------------------*
*	Digitiser support									*
*-----------------------------------------------------------------------*

init_pip:
	tst.b		expose_flag
	bne.s		.low
	move.w	x_factor,d2
	add.w		y_factor,d2
	cmp.w		#4,d2
	bne.s		.low
	jsr		getsize_256x160
	bra.s		.nm
.low	jsr		getsize_128x80
.nm	rts

show_pip:
	ifnd		cutdown
	cmp.w		#1<<Bit_IFACE_FREE,IFACE_BITS
	beq		.skip	
	tst.b		DIALOG_FLAG
	bne		.skip
	tst.b		MENU_UP
	bne		.skip
	tst.w		PIP_BITS
	beq		.skip
	IFND		EXPOSE_CHEAT
	tst.b		TRUE_FLAG
	beq		bplpip
	ENDC
	bra		truepip
	endc
.skip	rts

grab	macro
	IFND		EXPOSE_CHEAT
	move.w	#\1,DIGICTRL
	ENDC
	endm

select		macro
	IFND		EXPOSE_CHEAT
	move.w	\1,DIGICTRL
	ENDC
	endm

waitgrab		macro
	IFND		EXPOSE_CHEAT
.wg\@	move.w	DIGICTRL,d1
	and.w		#3,d1
	bne.s		.wg\@
	ENDC
	endm


Video_photo:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.rt
	move.b	matrix_flag,d0
	or.b		expose_flag,d0
	beq.s		.err
	jsr		HIDE_MOUSE
	seticon	I_Video_photo,station_video
	bsr		Redraw_menu_icons
	addq.b	#1,BUSY
;	clr.w		eyesync
	move.w	#1,eyesync
	jsr		expose
	jsr		init_pip
	subq.b	#1,BUSY
	reseticon
	jsr		Superscaler
	bsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	endc
.err	rts

.rt	move.w	#station_video,THIS_STATION
	lea		WIN_Video_photo,a1
	moveq		#I_Video_photo,d0
	moveq		#station_video,d1
	jmp		Tool_dialog_box

view_loop:
	bsr		grab_a_field
.wait_loop:
	jsr		WAIT_TIMER
	tst.b		matrix_flag
	bne.s		.sk
	waitgrab
	select	#odd_frame
.sk	tst.b		TRUE_FLAG
	beq.s		.skip
	IFD		EXPOSE_CHEAT
	lea		EXPOSE+20,a0
	ELSEIF
	lea		DIGIPAGE,a0
	ENDC
	jsr		([centre_rout.l])
.skip	bsr		grab_a_field
	tst.b		BUTTONS
	beq.s		.wait_loop
	rts

grab_a_field:
	tst.b		matrix_flag
	beq.s		.exp
	moveq		#FIELDeven,d0
	jmp		grab_eyefield
.exp	grab		type_direct
	rts

*-----------------------------------------*
Video_film:
	ifnd		cutdown
*-----------------------------------------*
*	Grab short animation from digitiser	*
*-----------------------------------------*
	moveq		#I_Video_film,d0
	moveq		#station_video,d1
	lea		WIN_Video_film,a1
	cmp.b		#right_button,ICON_BUTTON
	beq		Tool_dialog_box
	move.b	expose_flag,d0
	or.b		matrix_flag,d0
	beq		.none
	move.l	$FFFF9800.w,.temp
;	clr.w		eyesync
	move.w	#1,eyesync
	init_tool
	tst.b		MENU_UP
	bne.s		.sk1
	not.b		MENU_UP
	jsr		Check_menu
.sk1	bsr		Keep_undo
	jsr		HIDE_MOUSE
	cache		ienab|iclr|dclr
*-----------------------------------------*
*	Create frame grab-list			*
*-----------------------------------------*
	move.l	#4096*2,d0
	jsr		MALLOCATE_normal
	tst.l		d0
	bmi		.exit_direct
	move.w	d0,GRAB_LIST_HANDLE
*-----------------------------------------*
	move.l	LOG_SCR,a0
	move.l	CANVAS_SIZE,d0
	jsr		memclr
	jsr		Superscaler
*-----------------------------------------*
*	Find size of image & init routines	*
*-----------------------------------------*
	cmp.w		#1<<Bit_ANI_A512,ANI_BITS
	bne.s		.n1z
	bsr		getsize_512x256
	move.l	#centre_512x256,centre_rout
	move.l	#store_512x256,store_rout
	bra.s		.n4z
.n1z	cmp.w		#1<<Bit_ANI_A256,ANI_BITS
	bne.s		.n2z
	bsr		getsize_256x160
	move.l	#centre_256x160,centre_rout
	move.l	#store_256x160,store_rout
	bra.s		.n4z
.n2z	bsr		getsize_128x80
	move.l	#centre_128x80,centre_rout
	move.l	#store_128x80,store_rout
.n4z	move.w	grab_width,d0
	mulu.w	grab_height,d0
	add.l		d0,d0
	move.l	d0,GRAB_SIZE
*-----------------------------------------*
	jsr		view_loop
	cmp.b		#right_button,BUTTONS
	bne		.grab
	jsr		COPY_UNDO_2_LOG
	beq		.exit_dealloc
*-----------------------------------------*
.grab	sf		grab_full
	sf		grab_stop
*-----------------------------------------*
	move.l	#4096,d0
	tst.b		TRUE_FLAG
	bne.s		.non
	add.l		#65536,d0
.non:	jsr		Add_fast
	move.w	d0,BUFFER1_HANDLE
	bmi		.exit_dealloc
*-----------------------------------------*
	clr.w		GRAB_INDEX			; current position
	clr.w		GRAB_LIMIT			; wrap limit
*-----------------------------------------*
	not.l		$FFFF9800.w
*-----------------------------------------*
.grab_loop:
*-----------------------------------------*
	jsr		grab_a_field
*-----------------------------------------*
*	Add no more frames once full		*
*-----------------------------------------*
	tst.b		grab_full
	bne.s		.no_new_frames
*-----------------------------------------*
.add_frame:
*-----------------------------------------*
*	Add new frame to ring			*
*-----------------------------------------*
	move.l	GRAB_SIZE,d0
	st		lock_errors
	jsr		Add_fast
	sf		lock_errors
	tst.l		d0
	bpl.s		.fok
*-----------------------------------------*
	st		grab_full
*-----------------------------------------*
	move.w	FILM_BITS,d2
	btst		#Bit_FILM_WRAP,d2
	beq		.finish_grab_nowrap
*-----------------------------------------*
	bra.s		.no_new_frames
*-----------------------------------------*
.fok:	move.w	d0,-(sp)
	move.w	GRAB_LIST_HANDLE,d0
	jsr		Find_block
	move.w	GRAB_LIMIT,d1
	move.w	(sp)+,(a0,d1.w*2)
	addq.w	#1,GRAB_LIMIT
*-----------------------------------------*
.no_new_frames:
*-----------------------------------------*
*	Abort if no frames possible		*
*-----------------------------------------*
	tst.w		GRAB_LIMIT
	beq		.exit_dealloc
*-----------------------------------------*
*	Wrap check only if full			*
*-----------------------------------------*
	tst.b		grab_full
	beq.s		.don
*-----------------------------------------*
*	Wrap if enabled				*
*-----------------------------------------*
	move.w	GRAB_INDEX,d1
	cmp.w		GRAB_LIMIT,d1
	bne.s		.nic
	clr.w		d1
.nic:	move.w	d1,GRAB_INDEX
*-----------------------------------------*
*	Find address of current block		*
*-----------------------------------------*
.don:	move.w	GRAB_LIST_HANDLE,d0
	jsr		Find_block
	move.w	GRAB_INDEX,d1
	move.w	d1,GRAB_ENDFRAME
	move.w	(a0,d1.w*2),d0
	jsr		Find_block
	move.l	a0,GRAB_PTR
*-----------------------------------------*
*	Record frame into block			*
*-----------------------------------------*
	jsr		WAIT_TIMER
	tst.b		matrix_flag
	bne.s		.sk
	waitgrab
	select	#odd_frame
	IFD		EXPOSE_CHEAT
	lea		EXPOSE+20,a0
	ELSEIF
	lea		DIGIPAGE,a0
	ENDC
.sk:	st		suppress_pip8
	jsr		([store_rout.l])
	sf		suppress_pip8
*-----------------------------------------*
*	Advance frame				*
*-----------------------------------------*
	move.w	GRAB_INDEX,d1
	addq		#1,d1
	move.w	d1,GRAB_INDEX
*-----------------------------------------*
	tst.b		BUTTONS
	bne		.grab_loop
*-----------------------------------------*
.finish_grab:
*-----------------------------------------*
	tst.b		grab_full
	bne		.wrapped
*-----------------------------------------*
.finish_grab_nowrap:
*-----------------------------------------*
*	Return to start if no wrap used	*
*-----------------------------------------*
	clr.w		GRAB_INDEX
	bra		.store
*-----------------------------------------*
.wrapped:
*-----------------------------------------*
	move.w	GRAB_ENDFRAME,d1
	addq.w	#1,d1
	cmp.w		GRAB_LIMIT,d1
	bne.s		.nw
	clr.w		d1
.nw:	move.w	d1,GRAB_INDEX
*-----------------------------------------*
.store:
*-----------------------------------------*
	move.w	BUFFER1_HANDLE,d0
	jsr		Remove_block
*-----------------------------------------*
	not.l		$FFFF9800.w
	jsr		Superscaler
	move.l	LOG_SCR,a0
	move.l	CANVAS_SIZE,d0
	jsr		memclr
	tst.w		GRAB_LIMIT
	beq		.exit_dealloc
*-----------------------------------------*
	move.w	GRAB_LIMIT,GRAB_BLOCKCOUNT
	move.w	GRAB_LIMIT,MAXFRAME
	move.w	#1,CURFRAME
	st		FRAMECOUNT
	bra.s		.go1
*-----------------------------------------*
*	Image store-loop				*
*-----------------------------------------*
.rb:	tst.b		BUTTONS
	beq.s		.nab
*-----------------------------------------*
*	Abort - clean up locked memory	*
*-----------------------------------------*
.release_loop:
*-----------------------------------------*
	move.w	GRAB_LIST_HANDLE,d0
	jsr		Find_block
	move.w	GRAB_ENDFRAME,d0
	move.w	(a0,d0.w*2),d0
	jsr		Remove_block
	move.w	GRAB_ENDFRAME,d0
	subq.w	#1,d0
	bpl.s		.no_rel_wrap
	move.w	GRAB_LIMIT,d0
	subq.w	#1,d0
*-----------------------------------------*
.no_rel_wrap:
*-----------------------------------------*
	move.w	d0,GRAB_ENDFRAME
	subq.w	#1,GRAB_BLOCKCOUNT
	bgt.s		.release_loop
*-----------------------------------------*
	bra		.exit_dealloc
*-----------------------------------------*
.nab:	jsr		Frame_right_ins_invoke
*-----------------------------------------*
*	Locate next block handle & wrap	*
*-----------------------------------------*
.go1:	move.w	GRAB_LIST_HANDLE,d0
	jsr		Find_block
	move.w	GRAB_INDEX,d0
	move.w	(a0,d0.w*2),GRAB_HANDLE
	addq.w	#1,d0
	cmp.w		GRAB_LIMIT,d0
	bne.s		.nof
	clr.w		d0
.nof:	move.w	d0,GRAB_INDEX
*-----------------------------------------*
	move.w	grab_width,d0
	move.w	grab_height,d1
	jsr		GetAspect
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.w	grab_width,source_width
	move.w	grab_height,source_height
	move.w	CANVAS_WIDTH,d2
	sub.w		dest_width,d2
	move.w	CANVAS_HEIGHT,d3
	sub.w		dest_height,d3
	lsr.w		d2
	lsr.w		d3
	move.w	d2,dest_x
	move.w	d3,dest_y
*-----------------------------------------*
	move.w	GRAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,source_image
	move.l	LOG_SCR,dest_image
*-----------------------------------------*
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.w	#fmat_wordpixel,source_format
	jsr		Colour_handler
	jsr		reduce_handler
	sf		image_inverted
	sf		colours_available
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
*-----------------------------------------*
	move.w	GRAB_HANDLE,d0
	jsr		Remove_block
*-----------------------------------------*
	st		BITMAP_CHANGED
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	jsr		Superscaler
	jsr		Update_palette
*-----------------------------------------*
.retry_loop:
*-----------------------------------------*
	st		lock_errors
	jsr		Get_changes
	sf		lock_errors
	tst.l		d0
	bpl.s		.cnt
*-----------------------------------------*
*	Abort if no blocks left			*
*-----------------------------------------*
	tst.w		GRAB_BLOCKCOUNT
	beq.s		.err
*-----------------------------------------*
*	Release last block & retry		*
*-----------------------------------------*
	move.w	GRAB_LIST_HANDLE,d0
	jsr		Find_block
	move.w	GRAB_ENDFRAME,d0
	move.w	(a0,d0.w*2),d0
	jsr		Remove_block
	move.w	GRAB_ENDFRAME,d0
	subq.w	#1,d0
	bpl.s		.no_ret_wrap
	move.w	GRAB_LIMIT,d0
	subq.w	#1,d0
*-----------------------------------------*
.no_ret_wrap:
*-----------------------------------------*
	move.w	d0,GRAB_ENDFRAME
	subq.w	#1,MAXFRAME
	subq.w	#1,GRAB_BLOCKCOUNT
	bgt.s		.retry_loop
*-----------------------------------------*
.cnt:
*-----------------------------------------*
	addq		#1,CURFRAME
	subq		#1,GRAB_BLOCKCOUNT	
	bgt		.rb
*-----------------------------------------*
.err:
*-----------------------------------------*
.exit_dealloc:
	move.l	.temp,$FFFF9800.w
	jsr		MRELEASE
.exit_direct:
	sf		FRAMECOUNT
	clr.w		dest_x
	clr.w		dest_y
	jsr		Superscaler
	bsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	bsr		Refresh_info_bar
	bsr		Reset_tool
.rts	jsr		init_pip
	cache		norm
	endc
.none	rts

.temp	ds.l		1

GRAB_ENDFRAME:		ds.w	1
GRAB_LIMIT:			ds.w	1
GRAB_BLOCKCOUNT:		ds.w	1

grab_full:			ds.b	1
grab_stop:			ds.b	1
				even

POSSIBLE_GRABS_COPY:	ds.w	1
POSSIBLE_GRABS:		ds.w	1
ACTUAL_GRABS_COPY:	ds.w	1
ACTUAL_GRABS:		ds.w	1

GRAB_LIST_HANDLE:		ds.w	1
GRAB_LIST_PTR:		ds.l	1
GRAB_LIST_END:		ds.l	1

GRAB_INDEX:			ds.w	1
GRAB_HANDLE:		ds.w	1
GRAB_PTR:			ds.l	1
GRAB_SIZE:			ds.l	1

centre_rout:		ds.l	1
store_rout:			ds.l	1

getsize_512x256:
	tst.b		matrix_flag
	bne.s		.mat
	move.w	#256,d7
	cmp.w		#2,y_factor
	beq.s		.go1
	move.w	#200,d7	
.go1	move.w	#512,d6
	cmp.w		#2,x_factor
	beq.s		.go2
	move.w	#320,d6
.go2	move.w	d6,grab_width
	move.w	d7,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go
	move.w	#200,grab_height
.go	rts

.mat	move.w	#256,d7
	cmp.w		#2,y_factor
	beq.s		.go3
	move.w	#200,d7	
.go3	move.w	eyesize,d6
	lsr.w		d6
	cmp.w		#2,x_factor
	beq.s		.go4
	move.w	#320,d6
.go4	move.w	d6,grab_width
	move.w	d7,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go5
	move.w	#160,grab_height
.go5	jsr		initfield_384x288
	rts
	
getsize_256x160:
	tst.b		matrix_flag
	beq.s		.exp
	move.w	eyesize,d2
	lsr.w		#2,d2
	move.w	d2,grab_width
	move.w	#128,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go
	move.w	#80,grab_height
.go	jsr		initfield_192x144
	rts
.exp	move.w	#256,grab_width
	move.w	#160,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go2
	move.w	#100,grab_height
.go2	rts

getsize_128x80:
	tst.b		matrix_flag
	beq.s		.exp
	move.w	eyesize,d2
	lsr.w		#3,d2
	move.w	d2,grab_width
	move.w	#64,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go
	move.w	#40,grab_height
.go	jsr		initfield_96x72
	rts
.exp	move.w	#128,grab_width
	move.w	#80,grab_height
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_WIDE,d2
	beq.s		.go2
	move.w	#50,grab_height
.go2	rts

*-----------------------------------------*
*	Centre clipped 512*256 window		*
*-----------------------------------------*

centre_512x256:
	tst.b		matrix_flag
	bne		centre_384x288
	move.l	PHYS_SCR,a1
	move.w	#256,d7
	sub.w		grab_height,d7
	mulu		#512*2,d7
	add.l		d7,a0
	move.w	grab_height,d7
	subq		#1,d7
	move.w	Y_RESOLUTION,d1
	sub.w		grab_height,d1
	lsr.w		d1
	add.l		(PHYS_Y.l,d1.w*4),a1
.go
	cmp.w		#1,x_factor
	beq		centre_320
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		#512,d0
	lsr.w		d0
	add.w		d0,d0
	add.w		d0,a1

grab_512:
	cacheoff	d6
.Y	move.l	a1,a2
	add.l		a6,a1
	moveq		#4-1,d6
.X	move.l	(a0)+,(a2)+
	rept		64-1
	move.l	(a0)+,(a2)+
	endr
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

centre_320:
	cacheoff	d6
	add.l		#(256-160)*2,a0
	move.l	#512*2,a6
.Y	move.l	a0,a2
	add.l		a6,a0
	moveq		#2-1,d6
.X	move.l	(a2)+,(a1)+
	rept		80-1
	move.l	(a2)+,(a1)+
	endr
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

*-----------------------------------------*
*	Centre 360*288 MATRIX window		*
*-----------------------------------------*

centre_384x288:
	move.l	PHYS_SCR,a1
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		grab_width,d0
	asr.w		d0
	add.w		d0,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	add.w		d0,a1
	move.w	Y_RESOLUTION,d0
	sub.w		grab_height,d0
	asr.w		d0
	muls		physwid,d0
	bpl.s		.ok2
	moveq		#0,d0
.ok2	add.l		d0,a1
	move.l	a1,eyebuffer
	move.w	physwid,d0
	ext.l		d0
	move.l	d0,eyeline
	jmp		fetchfield_384x288_clipped

*-----------------------------------------*
*	Centre 256*160 window			*
*-----------------------------------------*

centre_256x160:
	tst.b		matrix_flag
	bne		centre_192x144
	cacheoff	d0
	move.l	PHYS_SCR,a1
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		grab_width,d0
	lsr.w		d0
	add.w		d0,d0
	add.w		d0,a1
	move.w	Y_RESOLUTION,d0
	sub.w		grab_height,d0
	lsr.w		d0
	mulu		physwid,d0
	add.l		d0,a1
	lea		digi_lines,a3
	move.w	#160,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7
	move.l	#128,d0
.Y	move.l	a0,a4
	add.l		(a3)+,a4
	move.l	a1,a2
	add.l		a6,a1
	moveq		#8-1,d6
.X
ost	set		0
	rept		32
	move.w	ost(a4),(a2)+
ost	set		ost+4
	endr
	add.l		d0,a4
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

*-----------------------------------------*
*	Centre 180*144 MATRIX window		*
*-----------------------------------------*

centre_192x144:
	move.l	PHYS_SCR,a1
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		grab_width,d0
	lsr.w		d0
	add.w		d0,d0
	add.w		d0,a1
	move.w	Y_RESOLUTION,d0
	sub.w		grab_height,d0
	lsr.w		d0
	mulu		physwid,d0
	add.l		d0,a1
	move.l	a1,eyebuffer
	move.w	physwid,d0
	ext.l		d0
	move.l	d0,eyeline
	jsr		fetchfield_192x144
	rts

*-----------------------------------------*
*	Centre 128*80 window			*
*-----------------------------------------*

centre_128x80:
	tst.b		matrix_flag
	bne		centre_96x72
	cacheoff	d0
	move.l	PHYS_SCR,a1
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		grab_width,d0
	lsr.w		d0
	add.w		d0,d0
	add.w		d0,a1
	move.w	Y_RESOLUTION,d0
	sub.w		grab_height,d0
	lsr.w		d0
	mulu		physwid,d0
	add.l		d0,a1
	lea		digi_lines,a3
	move.w	#80,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7
	move.l	#256,d0
.Y	move.l	a0,a4
	add.l		(a3),a4
	addq.l	#8,a3
	move.l	a1,a2
	add.l		a6,a1
	moveq		#4-1,d6
.X
ost	set		0
	rept		32
	move.w	ost(a4),(a2)+
ost	set		ost+8
	endr
	add.l		d0,a4
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

*-----------------------------------------*
*	Centre 90*72 MATRIX window		*
*-----------------------------------------*

centre_96x72:
	move.l	PHYS_SCR,a1
	move.w	physwid,a6
	move.w	X_RESOLUTION,d0
	sub.w		grab_width,d0
	lsr.w		d0
	add.w		d0,d0
	add.w		d0,a1
	move.w	Y_RESOLUTION,d0
	sub.w		grab_height,d0
	lsr.w		d0
	mulu		physwid,d0
	add.l		d0,a1
	move.l	a1,eyebuffer
	move.w	physwid,d0
	ext.l		d0
	move.l	d0,eyeline
	jsr		fetchfield_96x72
	rts

*-----------------------------------------*
*	Store window				*
*-----------------------------------------*

store_512x256:
	tst.b		matrix_flag
	bne		store_384x288
	move.l	GRAB_PTR,a1
	move.w	#256,d7
	sub.w		grab_height,d7
	mulu		#512*2,d7
	add.l		d7,a0
	move.w	grab_height,d7
	subq		#1,d7
.go	cmp.w		#1,x_factor
	beq		scentre_320

sgrab_512:
	cacheoff	d6
.Y	moveq		#4-1,d6
.X	move.l	(a0)+,(a1)+
	rept		64-1
	move.l	(a0)+,(a1)+
	endr
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

scentre_320:
	cacheoff	d6
	add.l		#(256-160)*2,a0
	move.l	#512*2,a6
.Y	move.l	a0,a2
	add.l		a6,a0
	moveq		#2-1,d6
.X	move.l	(a2)+,(a1)+
	rept		80-1
	move.l	(a2)+,(a1)+
	endr
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

store_384x288:
	move.l	GRAB_PTR,eyebuffer
	move.w	grab_width,d0
	add.w		d0,d0
	ext.l		d0
	move.l	d0,eyeline
	jmp		fetchfield_384x288_clipped

store_256x160:
	tst.b		matrix_flag
	bne		store_192x144
	cacheoff	d6
	move.l	GRAB_PTR,a1
	lea		digi_lines,a3
	move.w	#160,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7
	move.l	#128,d0
.Y	move.l	a0,a4
	add.l		(a3)+,a4
	moveq		#8-1,d6
.X
ost	set		0
	rept		32
	move.w	ost(a4),(a1)+
ost	set		ost+4
	endr
	add.l		d0,a4
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts
	
store_192x144:
	move.l	GRAB_PTR,eyebuffer
	move.w	grab_width,d0
	add.w		d0,d0
	ext.l		d0
	move.l	d0,eyeline
	jmp		fetchfield_192x144	

store_128x80:
	tst.b		matrix_flag
	bne		store_96x72
	cacheoff	d6
	move.l	GRAB_PTR,a1

	lea		digi_lines,a3
	move.w	#80,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7

	move.l	#256,d0
.Y	move.l	a0,a4
	add.l		(a3),a4
	addq.l	#8,a3
	moveq		#4-1,d6
.X
ost	set		0
	rept		32
	move.w	ost(a4),(a1)+
ost	set		ost+8
	endr
	add.l		d0,a4
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d6
	rts

store_96x72:
	move.l	GRAB_PTR,eyebuffer
	move.w	grab_width,d0
	add.w		d0,d0
	ext.l		d0
	move.l	d0,eyeline
	jmp		fetchfield_96x72

photo_ptr:		ds.l	1
photo_size:		ds.l	1
exposure:		ds.w	1
shifter:		ds.w	1
grab_nheight:	ds.w	1

PHOTO_HANDLE:	ds.w	1

even_frame	=	0
odd_frame	=	1
type_direct	=	2
type_lace	=	3

adj_lace:
	move.w	DSIZE_BITS,d7
	and.w		#1<<Bit_DSIZE_N512,d7
	beq.s		.no
	add.w		d0,d0
	add.w		d1,d1
.no	rts
	
adj_wide:
	move.w	DSIZE_BITS,d7
	and.w		#1<<Bit_DSIZE_WIDE,d7
	beq.s		.no
	mulu		#160,d0
	mulu		#160,d1
	lsr.l		#8,d0
	lsr.l		#8,d1
.no	rts

get_photosize:
	tst.b		matrix_flag
	beq.s		.exp
.mat	move.w	eyesize,grab_width
	move.w	#288,d0
	move.w	#288,d1
	bsr		adj_lace
	bsr		adj_wide
	move.w	d0,grab_height
	move.w	d1,grab_nheight
	rts
.exp	move.w	#512,grab_width
	move.w	#256,d0
	move.w	#160,d1
	bsr		adj_lace
	bsr		adj_wide
	move.w	d0,grab_height
	move.w	d1,grab_nheight
	rts
	
expose:
	jsr		get_photosize
	cmp.w		#1<<Bit_EXP_FAST,EXP_BITS
	bne		long_exposure

short_exposure:
	jsr		prepare_matrixframe
	move.w	grab_width,d0
	move.w	grab_height,d1
	mulu		d1,d0
	add.l		d0,d0
	move.l	d0,photo_size
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	move.w	d0,PHOTO_HANDLE
	jsr		Find_block
	move.l	a0,photo_ptr
	bsr		grab_frame
	bra		reduce_photo

long_exposure:
	jsr		prepare_matrixframe_e
	move.w	grab_width,d0
	move.w	grab_height,d1
	mulu		d1,d0
	lsl.l		#2,d0
	move.l	d0,photo_size
	jsr		Add_fast
	tst.l		d0
	bpl.s		.cont
	rts
.cont	move.w	d0,PHOTO_HANDLE
	jsr		Find_block
	move.l	a0,photo_ptr
	move.l	photo_size,d0
	jsr		memclr
	move.w	exposure,d0
	subq		#1,d0
.exp	push.w	d0
	bsr		expose_frame
	pop.w		d0
	dbra		d0,.exp
	moveq		#29,d2
	moveq		#20,d3
	moveq		#9,d4
	sub.w		shifter,d2
	sub.w		shifter,d3
	sub.w		shifter,d4
	move.l	photo_ptr,a0
	move.l	a0,a1
	cacheoff	d6
	move.w	grab_height,d7
	subq		#1,d7
.ylp	move.w	grab_width,d6
	lsr.w		#2,d6
	subq		#1,d6
.xlp	move.l	(a0)+,d1
	bfins		d1,d0{16:d2}
	bfins		d1,d0{21:d3}
	bfins		d1,d0{27:d4}
	move.w	d0,(a1)+
	move.l	(a0)+,d1
	bfins		d1,d0{16:d2}
	bfins		d1,d0{21:d3}
	bfins		d1,d0{27:d4}
	move.w	d0,(a1)+
	move.l	(a0)+,d1
	bfins		d1,d0{16:d2}
	bfins		d1,d0{21:d3}
	bfins		d1,d0{27:d4}
	move.w	d0,(a1)+
	move.l	(a0)+,d1
	bfins		d1,d0{16:d2}
	bfins		d1,d0{21:d3}
	bfins		d1,d0{27:d4}
	move.w	d0,(a1)+
	dbra		d6,.xlp
	dbra		d7,.ylp
	cacheon	d6
	move.l	photo_size,d1
	lsr.l		d1
	move.w	PHOTO_HANDLE,d0
	jsr		Resize_block

reduce_photo:
	move.w	grab_width,d0
	move.w	grab_nheight,d1
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N512,d2
	bne.s		.nhlf
	lsr.w		d0
.nhlf	jsr		GetAspect
	move.w	new_imagewidth,dest_width
	move.w	new_imageheight,dest_height
	move.w	grab_width,source_width
	move.w	grab_height,source_height
	move.w	CANVAS_WIDTH,d2
	sub.w		dest_width,d2
	move.w	CANVAS_HEIGHT,d3
	sub.w		dest_height,d3
	lsr.w		d2
	lsr.w		d3
	move.w	d2,dest_x
	move.w	d3,dest_y
	move.w	PHOTO_HANDLE,d0
	jsr		Find_block
	move.l	a0,photo_ptr
	move.l	photo_ptr,source_image
	move.l	LOG_SCR,dest_image
	move.w	CANVAS_WIDTH,dest_scrwidth
	move.w	#fmat_wordpixel,source_format
	jsr		Colour_handler
	jsr		reduce_handler
	sf		image_inverted
	sf		colours_available
	st		sacrifice
	jsr		CONVERT_IMAGE
	sf		sacrifice
	clr.w		dest_x
	clr.w		dest_y
	st		MENUPAL_CHANGED
	st		BITMAP_CHANGED
	st		PALETTE_CHANGED
	jsr		Update_palette
	jsr		Remap_menu_bars
	move.w	PHOTO_HANDLE,d0
	jsr		Remove_block
	rts

grab_frame:
	tst.b		matrix_flag
	bne		grab_matrixframe
	move.l	#512*2,a6
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne		.norm
	add.l		a6,a6
	waitgrab
	grab		type_lace
	not.l		$FFFF9800.w
	waitgrab
	not.l		$FFFF9800.w
	push.w	grab_height
	lsr.w		grab_height
	move.l	photo_ptr,a2
	moveq		#odd_frame,d0
	jsr		.grab_page
	move.l	photo_ptr,a2
	add.l		#512*2,a2
	moveq		#even_frame,d0
	jsr		.grab_page
	pop.w		grab_height
	rts
.norm	grab		type_direct
	not.l		$FFFF9800.w
	waitgrab
	not.l		$FFFF9800.w
	move.l	photo_ptr,a2
	moveq		#odd_frame,d0
	jsr		.grab_page
	rts
.grab_page
	cacheoff	d7
	IFD		EXPOSE_CHEAT
	lea		EXPOSE+20,a0
	ELSEIF
	lea		DIGIPAGE,a0
	ENDC
	select	d0
	move.w	#256,d7
	sub.w		grab_height,d7
	mulu		#512*2,d7
	add.l		d7,a0
	move.w	grab_height,d7
	subq		#1,d7
.ylp	move.l	a0,a3
	move.l	a2,a4
	move.w	#(512/(32*2))-1,d6
.xlp	move.l	(a3)+,(a4)+
	rept		31
	move.l	(a3)+,(a4)+
	endr
	dbra		d6,.xlp
	lea		512*2(a0),a0
	add.l		a6,a2
	dbra		d7,.ylp
	cacheon	d7
	rts

grab_matrixframe:
	moveq		#FIELDeven,d0
	jsr		grab_eyefield
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne.s		.norm
	move.l	photo_ptr,eyebuffer
	moveq		#0,d0
	move.w	eyesize,d0
	add.l		d0,d0
	move.l	d0,eyeline
	not.l		$FFFF9800.w
	jsr		([eyefetcher.l])
	not.l		$FFFF9800.w
	rts
.norm	move.l	photo_ptr,eyebuffer
	moveq		#0,d0
	move.w	eyesize,d0
	add.l		d0,d0
	move.l	d0,eyeline
	moveq		#FIELDodd,d0
	jsr		grab_eyefield
	not.l		$FFFF9800.w
	jsr		([eyefetcher.l])
	not.l		$FFFF9800.w
	rts
	
expose_frame:
	tst.b		matrix_flag
	bne		expose_matrixframe
	move.l	#512*4,a6
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne		.norm
	add.l		a6,a6
	waitgrab
	grab		type_lace
	not.l		$FFFF9800.w
	waitgrab
	not.l		$FFFF9800.w
	push.w	grab_height
	lsr.w		grab_height
	move.l	photo_ptr,a2
	moveq		#odd_frame,d0
	jsr		accumulate_page
	move.l	photo_ptr,a2
	add.l		#512*4,a2
	moveq		#even_frame,d0
	jsr		accumulate_page
	pop.w		grab_height
	rts
.norm	grab		type_direct
	not.l		$FFFF9800.w
	waitgrab
	not.l		$FFFF9800.w
	move.l	photo_ptr,a2
	moveq		#odd_frame,d0
	jsr		accumulate_page
	rts

accumulate_page:
	IFD		EXPOSE_CHEAT
	lea		EXPOSE+20,a0
	ELSEIF
	lea		DIGIPAGE,a0
	ENDC
	select	d0
	move.l	#%1111100000000000,d4
	move.l	#%0000011111100000,d5
	move.l	#%0000000000011111,d6
	move.w	#256,d7
	sub.w		grab_height,d7
	mulu		#512*2,d7
	add.l		d7,a0
	move.w	grab_height,d7
	subq		#1,d7
	cacheoff	d1
.ylp	swap		d7
	move.l	a0,a3
	move.l	a2,a4
	move.w	#(512/4)-1,d7
.xlp
	rept		4
	move.w	(a3)+,d1
	move.l	d1,d2
	move.l	d1,d3
	and.l		d4,d1
	and.l		d5,d2
	and.l		d6,d3
	swap		d1
	lsr.l		#7,d1
	lsl.l		#5,d2
	or.l		d1,d2
	or.l		d2,d3
	add.l		d3,(a4)+
	endr
	dbra		d7,.xlp
	lea		512*2(a0),a0
	add.l		a6,a2
	swap		d7
	dbra		d7,.ylp
	cacheon	d7
	rts

prepare_matrixframe_e:
	tst.b		matrix_flag
	bne.s		.go
	rts
.go	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne.s		.norm
	jmp		initfield_768x576e
.norm	jmp		initfield_768x288e

prepare_matrixframe:
	tst.b		matrix_flag
	bne.s		.go
	rts
.go	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne.s		.norm
	jmp		initfield_768x576
.norm	jmp		initfield_768x288
	
expose_matrixframe:
	move.w	DSIZE_BITS,d2
	and.w		#1<<Bit_DSIZE_N256,d2
	bne.s		.norm
	move.l	photo_ptr,eyebuffer
	moveq		#0,d0
	move.w	eyesize,d0
	lsl.l		#2,d0
	move.l	d0,eyeline
	not.l		$FFFF9800.w
	jsr		([eyefetcher.l])
	not.l		$FFFF9800.w
	rts
.norm	move.l	photo_ptr,eyebuffer
	moveq		#0,d0
	move.w	eyesize,d0
	lsl.l		#2,d0
	move.l	d0,eyeline
	moveq		#FIELDeven,d0
	jsr		grab_eyefield
	not.l		$FFFF9800.w
	jsr		([eyefetcher.l])
	not.l		$FFFF9800.w
	rts

Video_size:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Video_size,d0
	moveq		#station_video,d1
	lea		WIN_Video_size,a1
	bra		Tool_dialog_box
.exit	rts

Video_pip:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Video_pip,d0
	moveq		#station_video,d1
	lea		WIN_PIP_options,a1
	bra		Tool_dialog_box
.exit	rts

truepip
	tst.b		matrix_flag
	bne.s		.matrix
	tst.b		expose_flag
	bne		.expose
	rts
.matrix
	move.l	PHYS_SCR,a1
	move.w	#16,d0
	tst.b		rgb_selector_on
	beq.s		.ok2
	move.w	#64,d0
.ok2	yresfactor	d0
	mulu		physwid,d0
	add.l		d0,a1
	move.w	eyesize,d0
	lsr.w		#3,d0
	move.w	d0,bpleyesize
	move.w	X_RESOLUTION,d0
	move.w	x_factor,d2
	add.w		y_factor,d2
	cmp.w		#4,d2
	bne.s		.ok
	sub.w		bpleyesize,d0	
.ok	sub.w		bpleyesize,d0
	add.w		d0,d0
	add.w		d0,a1
	move.l	a1,eyebuffer
	moveq		#0,d0
	move.w	physwid,d0
	move.l	d0,eyeline
	jsr		([eyefetcher.l])
	clr.w		eyesync
	moveq		#FIELDeven,d0
	jmp		grab_eyefield
.expose
	move.w	DIGICTRL,d1
	and.w		#3,d1
	bne		.skip
	IFND		EXPOSE_CHEAT
	select	#odd_frame
	lea		DIGIPAGE,a0
	ELSEIF
	lea		EXPOSE+20,a0
	ENDC
	move.l	PHYS_SCR,a1
	move.w	#16,d0
	tst.b		rgb_selector_on
	beq.s		.ok1
	move.w	#64,d0
.ok1	yresfactor	d0
	mulu		physwid,d0
	add.l		d0,a1
	move.w	X_RESOLUTION,d0
	sub.w		#124,d0
	add.w		d0,d0
	add.w		d0,a1

	lea		digi_lines,a3
	move.w	#80,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7

	move.w	#248,a5
	cacheoff	d6
	move.w	physwid,a6
.Y	move.l	a0,a4
	add.l		(a3),a4
	lea		8(a3),a3
	move.l	a1,a2
	add.l		a6,a1
	moveq		#4-1,d6
.X
ost	set		16
	rept		31
	move.w	ost(a4),(a2)+
ost	set		ost+8
	endr
	add.l		a5,a4
	dbra		d6,.X
	dbra		d7,.Y
	cacheon	d7
	grab		type_direct
.skip	rts

bplpip:
	tst.b		matrix_flag
	bne.s		.matrix
	tst.b		expose_flag
	bne		.expose
	rts
.matrix
	move.l	PHYS_SCR,a1
	move.w	#16,d0
	tst.b		rgb_selector_on
	beq.s		.ok1
	move.w	#64,d0
.ok1	yresfactor	d0
	mulu		physwid,d0
	add.l		d0,a1
	move.w	eyesize,d0
	lsr.w		#3,d0
	move.w	x_factor,d2
	add.w		y_factor,d2
	cmp.w		#4,d2
	bne.s		.ok
	add.w		d0,d0
.ok	and.w		#-16,d0
	neg.w		d0
	add.w		X_RESOLUTION,d0
	add.w		d0,a1
	move.l	a1,eyebuffer
	moveq		#0,d0
	move.w	physwid,d0
	move.l	d0,eyeline
	jsr		([eyefetcher.l])
	clr.w		eyesync
	moveq		#FIELDeven,d0
	jmp		grab_eyefield
.expose
	move.w	DIGICTRL,d1
	and.w		#3,d1
	bne		.skip
	IFND		EXPOSE_CHEAT
	select	#odd_frame
	lea		DIGIPAGE,a0
	ELSEIF
	lea		EXPOSE+20,a0
	ENDC
	move.l	PHYS_SCR,a1
	move.w	#16,d0
	yresfactor	d0
	mulu		physwid,d0
	add.l		d0,a1
	move.w	X_RESOLUTION,d0
	sub.w		#128,d0
	and.w		#-16,d0
	add.w		d0,a1

	lea		digi_lines,a3
	move.w	#80,d0
	sub.w		grab_height,d0
	lsr.w		d0
	ext.l		d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,d0
	add.l		d0,a3
	move.w	grab_height,d7
	subq		#1,d7

	moveq		#8,d5
	move.w	physwid,a6
	lea		IFACE_COLOURS,a5
.Y	move.l	a0,a4
	add.l		(a3),a4
	lea		8(a3),a3
	move.l	a1,a2
	add.l		a6,a1
	moveq		#8-1,d6
.xlp	swap		d6
	move.w	#16-1,d6
.blp	moveq		#32-1,d0
	move.w	(a4),d0
	add.l		d5,a4
	lsr.w		#6,d0
	and.w		#32-1,d0
	move.w	(a5,d0.w*2),d0
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	dbra		d6,.blp
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	swap		d6
	dbra		d6,.xlp
	dbra		d7,.Y
	grab		type_direct
.skip	rts

*-----------------------------------------------------------------------*

Pro_mask:
	ifnd		cutdown
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.exit
.ok	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Pro_mask,d0
	moveq		#station_pro,d1
	lea		WIN_Mask_sliders,a1
	bra		Tool_dialog_box
	endc
.exit	rts

Pro_options:
	ifnd		cutdown
	tst.b		TRUE_FLAG
	bne.s		.ok
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra.s		.exit
.ok	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Pro_options,d0
	moveq		#station_pro,d1
	lea		WIN_CONV_sliders,a1
	bra		Tool_dialog_box
	endc
.exit	rts

*-----------------------------------------------*
*	Add line to control-list			*
*-----------------------------------------------*
Add_line:							*
*-----------------------------------------------*
	cmp.w		#max_handles,GUIDE_COUNT
	beq		.err
	tst.w		GUIDE_COUNT
	beq		.new
*-----------------------------------------------*
	move.w	FIRST_GUIDE,d1
.lk1	mulu		#guide_len,d1
	lea		(MORPH_BUFFER.l,d1.l),a1
	move.w	guide_next(a1),d1			; check for last
	bpl.s		.lk1					; if so, quit
*-----------------------------------------------*
.last	move.l	a1,a2					; keep last slot
	lea		MORPH_BUFFER,a1			; start of slots
	move.w	GUIDE_COUNT,d1			; number of slots
	moveq		#0,d0
.lk2	cmp.w		#gcode,guide_state(a1)		; check for empty
	bne.s		.free					; if so, use it
	addq		#1,d0
	lea		guide_len(a1),a1			; and look again
	dbra		d1,.lk2		
.free	move.w	d0,guide_next(a2)			; end of line list
*-----------------------------------------------*
.stor	move.w	#gcode,guide_state(a1)		; slot is now used
	move.w	d0,guide_name(a1)
	move.w	X1,guide_x1_1(a1)			; keep line info
	move.w	Y1,guide_y1_1(a1)
	move.w	X2,guide_x2_1(a1)
	move.w	Y2,guide_y2_1(a1)
	move.w	X1,guide_x1_2(a1)			; keep line info
	move.w	Y1,guide_y1_2(a1)
	move.w	X2,guide_x2_2(a1)
	move.w	Y2,guide_y2_2(a1)
	move.w	#-1,guide_next(a1)		; end of line list
	move.w	d0,GUIDE_SELECTED
	addq		#1,GUIDE_COUNT
	bra.s		.fin
*-----------------------------------------------*
*	If frame has no list, create one		*
*-----------------------------------------------*
.new	lea		MORPH_BUFFER,a1			; start of slots
	moveq		#0,d0
	move.w	d0,FIRST_GUIDE
	bra.s		.stor
*-----------------------------------------------*
*	Exit routine					*
*-----------------------------------------------*
.fin	moveq		#0,d0
	bra.s		.rts
.err	moveq		#-1,d0
.rts	rts

lock_errors:		ds.b	1
				even
grab_width:			ds.w	1
grab_height:		ds.w	1

*-----*	Sub-tools			*-----------------------------------*

INIT_PENCIL:
	bsr.s		MOUSE_DRAWMODE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	move.w	d1,OM_X
	move.w	d2,OM_Y
	not.w		OM_X
	not.w		OM_Y
	bsr		Scale_D1D2
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d1,X2
	move.w	d2,Y2
	move.w	d1,OLD_X1
	move.w	d2,OLD_Y1
	move.w	d1,OLD_X2
	move.w	d2,OLD_Y2
	rts

MOUSE_DRAWMODE:
	addq.b	#1,HOLD_VBLANK
	subq.b	#1,MOUSE_LEVEL
	bpl.s		.rts
	cmp.b		#-1,MOUSE_LEVEL
	blt.s		.rts
	pushall
	move.b	#0,MOUSE_ON
	jsr		MousePtr_driver
	popall
.rts	jsr		Mouse_draw
	subq.b	#1,HOLD_VBLANK
	rts

MOUSE_WAITMODE:
	jsr		Mouse_full
	bsr		SHOW_MOUSE
	rts

Lassoo_zone:
	bsr		INIT_PENCIL
	bsr		Keep_undo
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	move.l	#(max_edges*4+max_edges*4*4),d0
	bsr		MALLOCATE_fast
	tst.l		d0
	bmi		.prob	
	move.l	a0,EDGEBUFFER_PTR
	move.w	X1,(a0)+
	move.w	Y1,(a0)+
	move.w	X1,X_COORD
	move.w	Y1,Y_COORD
	move.w	#0,STREAM_COUNT
	move.l	a0,STREAM_PTR
	move.w	#8,brush_deviance
	tst.w		BRUSH_TYPE
	bpl.s		.loop
	clr.w		brush_deviance
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.w	X2,X1
	move.w	Y2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.w	FG_COLOUR,d0
	move.l	STREAM_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	addq		#1,STREAM_COUNT
	move.l	a0,STREAM_PTR
	jsr		DRAW_LOG_BRUSHLINE
	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	cmp.w		#max_edges-4,STREAM_COUNT
	bge.s		.stop
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
.stop	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	move.l	STREAM_PTR,a0
	move.w	X_COORD,(a0)+
	move.w	Y_COORD,(a0)+
	addq		#1,STREAM_COUNT
	move.l	a0,STREAM_PTR
	move.w	X_COORD,d1
	move.w	Y_COORD,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.w	FG_COLOUR,d0
	jsr		DRAW_LOG_BRUSHLINE
	addq.b	#1,BUSY
	bsr		CALC_EDGEBUFFERS
	bsr		FILL_EDGEBUFFERS
	subq.b	#1,BUSY
	jsr		Superscaler
.prob	bsr		MRELEASE
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	rts

Lassoo_cut:
	bsr		INIT_PENCIL
	bsr		Keep_undo
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
	push.w	BRUSH_TYPE
	move.w	#-1,BRUSH_TYPE
	move.l	#(max_edges*4+max_edges*4*4),d0
	bsr		MALLOCATE_fast
	tst.l		d0
	bmi		.prob	
	move.l	a0,EDGEBUFFER_PTR
	move.w	X1,(a0)+
	move.w	Y1,(a0)+
	move.w	X1,X_COORD
	move.w	Y1,Y_COORD
	move.w	#0,STREAM_COUNT
	move.l	a0,STREAM_PTR
	clr.w		brush_deviance
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d1-d4,-(sp)
	jsr		Remove_mouseptr
	movem.w	(sp)+,d1-d4
	bsr		Scale_D3D4
	move.w	X2,X1
	move.w	Y2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	move.l	STREAM_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	addq		#1,STREAM_COUNT
	move.l	a0,STREAM_PTR
	move.w	IFACE_COLOURS+2*iface_white,d0
	or.b		gensol,d0
	jsr		DRAW_LOG_BRUSHLINE
	jsr		Superscale_zone
	jsr		Update_mouseptr
.skip	cmp.w		#max_edges-4,STREAM_COUNT
	bge.s		.stop
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
.stop	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	move.l	STREAM_PTR,a0
	move.w	X_COORD,(a0)+
	move.w	Y_COORD,(a0)+
	addq		#1,STREAM_COUNT
	move.l	a0,STREAM_PTR
	move.l	LOG_SCR,a0
	move.l	CANVAS_SIZE,d0

	tst.b		TRUE_FLAG
	beq.s		.bpl
	move.w	BG_COLOUR,d1
	lsr.l		#1,d0
	jsr		FILL_WORDS
	bra.s		.tr
.bpl	jsr		memclr

.tr	addq.b	#1,BUSY
	bsr.s		CALC_EDGEBUFFERS
	bsr		COPY_EDGEBUFFERS
	subq.b	#1,BUSY
	move.w	#0,X1
	move.w	#0,Y1
	move.w	#0,X2
	move.w	#0,Y2
;	push.w	BG_COLOUR
;	clr.w		BG_COLOUR
	move.w	LOG_HANDLE,TAB_HANDLE
	bsr		clip_area
	bsr		CUT_BRUSH
;	pop.w		BG_COLOUR
	tst.l		d0
	bmi.s		.no
	bsr		MAKE_BLOCKMASK
.no	jsr		COPY_UNDO_2_LOG
.prob	pop.w		BRUSH_TYPE
	bsr		Update_chstate
	bsr		MRELEASE
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	rts

CALC_EDGEBUFFERS:
*-----------------------------------*
	move.l	EDGEBUFFER_PTR,a3	; pointer to the coords. of vertices
	lea		max_edges*4(a3),a2		; destination
	move.l	a2,a4
	move.w	STREAM_COUNT,d7	; no. edges in polygon
	clr.w		STREAM_COUNT
	subq		#1,d7
	bmi		.rts
*-----------------------------------*
.Read	move.w	(a3)+,d0		; next x1 
	move.w	(a3)+,d1		; next y1
	move.w	(a3),d2		; next x2
	move.w	2(a3),d3		; next y2
*-----------------------------------*
.Draw	cmp.w		d1,d3			; (y2-y1)=dy
	beq.s		.Next			; ignore horizontals altogether
	bpl.s		.Asc			; slope > 0
	exg		d0,d2			; exchange x1 and x2
	exg		d1,d3			; exchange y1 and y2
.Asc	sub.w		d1,d3			; now dy is +ve
	move.w	d1,d5
	sub.w		d0,d2			; Check the sign of the slope (x2-x1)=dx
*-----------------------------------* Fraction loop
	swap		d2
	clr.w		d2
	ext.l		d3
	divs.l	d3,d2
	move.l	d2,d6
	lsr.l		d6
	move.w	d6,d1
	move.w	d2,d4
	swap		d2
	subq		#1,d3
.calc	move.w	d0,(a2)+
	add.w		d4,d1
	addx.w	d2,d0
	move.w	d5,(a2)+
	addq		#1,STREAM_COUNT	
	move.w	STREAM_COUNT,d6
	subq		#2,d6
	bmi.s		.ns
	push.w	d7
	lea		-4(a2),a5
.ys	move.l	-(a5),d7
	cmp.w		6(a5),d7
	ble.s		.ns1
	move.l	4(a5),(a5)
	move.l	d7,4(a5)
.ns1	move.l	(a5),d7
	cmp.w		d7,d5
	bne.s		.ns2
	cmp.w		6(a5),d5
	bne.s		.ns2
	swap		d7
	cmp.w		4(a5),d7
	ble.s		.ns2
	move.l	4(a5),(a5)
	swap		d7
	move.l	d7,4(a5)
.ns2	dbra		d6,.ys
	pop.w		d7
.ns	addq		#1,d5
	dbra		d3,.calc
.Next	dbra		d7,.Read
.rts	rts

FILL_EDGEBUFFERS:
	move.l	EDGEBUFFER_PTR,a3
	lea		max_edges*4(a3),a3
	move.w	STREAM_COUNT,d7	; no. edges in polygon
	lsr.w		d7
	subq		#1,d7
	bmi.s		.err
.fill	push.w	d7
	move.w	(a3)+,d1
	move.w	(a3)+,d3
	move.w	(a3)+,d2
	move.w	FG_COLOUR,d0
	addq		#2,a3
	push.l	a3
	jsr		horizontal_logline
	pop.l		a3
	pop.w		d7
	dbra		d7,.fill
.err	rts

COPY_EDGEBUFFERS:
	move.l	EDGEBUFFER_PTR,a3
	lea		max_edges*4(a3),a3
	move.w	STREAM_COUNT,d7	; no. edges in polygon
	lsr.w		d7
	subq		#1,d7
	bmi.s		.err
.fill	push.w	d7
	move.w	(a3)+,d1
	move.w	(a3)+,d3
	move.w	(a3)+,d2
	addq.l	#2,a3
	push.l	a3
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	jsr		HORIZONTAL_COPY
	pop.l		a3
	pop.w		d7
	dbra		d7,.fill
.err	rts

SCR_WIDTH:	ds.w	1
SCR_HEIGHT:	ds.w	1

DRAW_PHYS_BRUSH:
	move.l	PHYS_SCR,a0
	move.w	physwid,scrwid
	move.w	X_RESOLUTION,SCR_WIDTH
	move.w	Y_RESOLUTION,SCR_HEIGHT
	bra.s		print_brush
	
DRAW_LOG_BRUSH:
	move.l	LOG_SCR,a0
	move.w	logwid,scrwid
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	
print_brush:
;	d0		colour
;	d1,d2		x,y
	cmp.w		#15,BRUSH_TYPE
	blt.s		.cnt
	move.w	d1,d6
	move.w	d2,d7
	jsr		DRAW_SPRITE_CNT
	rts
.cnt	tst.b		TRUE_FLAG
	bne		print_brush_true
	move.w	d0,a6
	moveq		#16-1,d5		; height
	moveq		#0,d7			; graphic index
	move.l	a0,a3			; screen
	move.w	BRUSH_TYPE,d6
	lsl.w		#5,d6
	lea		BRUSHES,a0
	add.w		d6,a0
.Xclp	subq		#8,d1
	bmi		Brush_left
	move.w	SCR_WIDTH,d4
	sub.w		#16+1,d4
	cmp.w		d4,d1
	bgt		Brush_right
.Prnt	move.w	d1,d4
	and.w		#-16,d1
	add.w		d1,a3
	lsr.w		#2,d1
	add.w		d1,a2
.Yclp	add.w		d2,d7
	subq		#8,d2
	bpl.s		.ntop
	sub.w		d2,d7
	add.w		d2,d5
	bmi		.out
	add.w		d2,d2
	sub.w		d2,a0
	moveq		#0,d2
	bra.s		.nbot
.ntop	move.w	SCR_HEIGHT,d6
	sub.w		#16,d6
	sub.w		d2,d6
	bpl.s		.nbot
	add.w		d6,d5
	bmi		.out
.nbot	mulu		scrwid,d2
	add.l		d2,a3
	moveq		#16-1,d0
	and.w		d4,d0
	neg.w		d0
	add.w		#16,d0
.prlp	move.w	a6,d1
	add.w		d1,d1
	movem.l	(PLANE_TABLE.l,d1.w*8),d1/d2/a4/a6
	move.w	d5,d7
.lp	moveq		#-1,d6		; empty mask register
	move.w	(a0)+,d6		; get mask
	rol.l		d0,d6			; and scroll it
	move.l	d6,d5
	swap		d5
	move.w	d6,d3
	move.w	d5,d6
	move.w	d3,d5
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	not.l		d5
	not.l		d6
	lea		-32(a3),a3
	move.l	d1,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	d2,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	a4,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	a6,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	d1,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	d2,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	a4,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	a6,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	lea		-32(a3),a3
	add.w		scrwid,a3
	dbra		d7,.lp
.out	rts

Brush_left:
	move.w	d1,d4
.Yclp	add.w		d2,d7
	subq		#8,d2
	bpl.s		.ntop
	sub.w		d2,d7
	add.w		d2,d5
	bmi		.out
	add.w		d2,d2
	sub.w		d2,a0
	moveq		#0,d2
	bra.s		.nbot
.ntop	move.w	SCR_HEIGHT,d6
	sub.w		#16,d6
	sub.w		d2,d6
	bpl.s		.nbot
	add.w		d6,d5
	bmi.s		.out
.nbot	mulu		scrwid,d2
	add.l		d2,a3
	moveq		#16-1,d0
	and.w		d4,d0
	neg.w		d0
	add.w		#16,d0
.prlp	move.w	a6,d1
	add.w		d1,d1
	movem.l	(PLANE_TABLE.l,d1.w*8),d1/d2/a4/a6
	move.w	d5,d7
.lp	moveq		#-1,d6		; empty mask register
	move.w	(a0)+,d6		; get mask
	rol.l		d0,d6			; and scroll it
	move.l	d6,d5
	swap		d5
	move.w	d6,d3
	move.w	d5,d6
	move.w	d3,d5
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	and.l		d5,(a3)+
	not.l		d5
	lea		-16(a3),a3
	move.l	d1,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	d2,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	a4,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	move.l	a6,d3
	and.l		d5,d3
	or.l		d3,(a3)+
	lea		-16(a3),a3
	add.w		scrwid,a3
	dbra		d7,.lp
.out	rts

Brush_right:
	cmp.w		SCR_WIDTH,d1
	bge		.out
	move.w	d1,d4
	and.w		#-16,d1
	add.w		d1,a3
	lsr.w		#2,d1
	add.w		d1,a2
.Yclp	add.w		d2,d7
	subq		#8,d2
	bpl.s		.ntop
	sub.w		d2,d7
	add.w		d2,d5
	bmi		.out
	add.w		d2,d2
	sub.w		d2,a0
	moveq		#0,d2
	bra.s		.nbot
.ntop	move.w	SCR_HEIGHT,d6
	sub.w		#16,d6
	sub.w		d2,d6
	bpl.s		.nbot
	add.w		d6,d5
	bmi.s		.out
.nbot	mulu		scrwid,d2
	add.l		d2,a3
	moveq		#16-1,d0
	and.w		d4,d0
	neg.w		d0
	add.w		#16,d0
.prlp	move.w	a6,d1
	add.w		d1,d1
	movem.l	(PLANE_TABLE.l,d1.w*8),d1/d2/a4/a6
	move.w	d5,d7
.lp	moveq		#-1,d6		; empty mask register
	move.w	(a0)+,d6		; get mask
	rol.l		d0,d6			; and scroll it
	move.l	d6,d5
	swap		d5
	move.w	d6,d3
	move.w	d5,d6
	move.w	d3,d5
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	and.l		d6,(a3)+
	not.l		d6
	lea		-16(a3),a3
	move.l	d1,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	d2,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	a4,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	move.l	a6,d3
	and.l		d6,d3
	or.l		d3,(a3)+
	lea		-16(a3),a3
	add.w		scrwid,a3
	dbra		d7,.lp
.out	rts

print_brush_true:
	move.w	d0,a5
	moveq		#0,d3			; scroll count
	move.w	BRUSH_TYPE,d6
	lsl.w		#5,d6
	lea		BRUSHES,a6
	add.w		d6,a6
	move.l	a0,a4
	subq		#8,d1
	subq		#8,d2
	move.w	d1,d6
	move.w	d2,d7
	moveq		#16,d4
	moveq		#16,d5
.clpt	move.w	d7,d0
	bpl.s		.clpb
	add.w		d0,d5			; crop height
	ble.s		.end
	add.w		d0,d0
	sub.w		d0,a6			; drop into data
	moveq		#0,d7			; clip top
.clpb	move.w	SCR_HEIGHT,d0	; y-limit
	sub.w		d7,d0
	sub.w		d5,d0			; check for overhang
	bpl.s		.clpr
	add.w		d0,d5			; crop height
	ble.s		.end
.clpr	move.w	SCR_WIDTH,d0	; x-limit
	sub.w		d6,d0			; minus x-pos
	sub.w		d4,d0			; minus width
	bpl.s		.clpl			; neg if inside
	add.w		d0,d4			; adjust width
	ble.s		.end			; zero width?
	neg.w		d0
	add.w		d0,d0
.clpl	move.w	d6,d0
	bpl.s		.prnt
	add.w		d0,d4
	ble.s		.end
	sub.w		d0,d3
	moveq		#0,d6
.prnt	move.w	a5,d0
	move.l	a4,a0
	mulu		scrwid,d7
	add.l		d7,a0
	add.w		d6,d6
	add.w		d6,a0
	subq		#1,d4
	subq		#1,d5
.ylp	move.l	a0,a1
	move.w	d4,d1
	move.w	(a6)+,d2
	lsl.w		d3,d2
.xlp	add.w		d2,d2
	bcs.s		.no
	move.w	d0,(a1)
.no	addq.l	#2,a1
	dbra		d1,.xlp
	add.w		scrwid,a0
	dbra		d5,.ylp
.end	rts

DRAW_LOG_HSV:
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a2
	move.w	OPER_BITS,d3
	and.w		#1<<Bit_OPER_COMP,d3
	beq.s		.c
	move.l	LOG_SCR,a2
.c	move.w	logwid,scrwid
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	cmp.w		#15,BRUSH_TYPE
	blt.s		.cnt
	move.w	d1,d6
	move.w	d2,d7
	jsr		DRAW_SPRITE_CNT
	rts
.cnt	move.w	d0,a5
	moveq		#0,d3			; scroll count
	move.w	BRUSH_TYPE,d6
	lsl.w		#5,d6
	lea		BRUSHES,a6
	add.w		d6,a6
	subq		#8,d1
	subq		#8,d2
	move.w	d1,d6
	move.w	d2,d7
	moveq		#16,d4
	moveq		#16,d5
.clpt	move.w	d7,d0
	bpl.s		.clpb
	add.w		d0,d5			; crop height
	ble		.end
	add.w		d0,d0
	sub.w		d0,a6			; drop into data
	moveq		#0,d7			; clip top
.clpb	move.w	SCR_HEIGHT,d0	; y-limit
	sub.w		d7,d0
	sub.w		d5,d0			; check for overhang
	bpl.s		.clpr
	add.w		d0,d5			; crop height
	ble.s		.end
.clpr	move.w	SCR_WIDTH,d0	; x-limit
	sub.w		d6,d0			; minus x-pos
	sub.w		d4,d0			; minus width
	bpl.s		.clpl			; neg if inside
	add.w		d0,d4			; adjust width
	ble.s		.end			; zero width?
	neg.w		d0
	add.w		d0,d0
.clpl	move.w	d6,d0
	bpl.s		.prnt
	add.w		d0,d4
	ble.s		.end
	sub.w		d0,d3
	moveq		#0,d6
.prnt	move.w	a5,d0
	mulu		scrwid,d7
	add.l		d7,a0
	add.l		d7,a2
	add.w		d6,d6
	add.w		d6,a0
	add.w		d6,a2
	subq		#1,d4
	subq		#1,d5
	move.w	scrwid,d0
	ext.l		d0
.ylp	move.l	a0,a1
	move.l	a2,a4
	move.w	d4,d1
	move.w	(a6)+,d2
	lsl.w		d3,d2
.xlp	add.w		d2,d2
	bcs.s		.no
	dspwrite	(a4)
	dspread	(a1)
.no	addq.l	#2,a1
	addq.l	#2,a4
	dbra		d1,.xlp
	add.l		d0,a0
	add.l		d0,a2
	dbra		d5,.ylp
.end	rts

PLOT_LOG_HSV:
	tst.w		d1
	bmi.s		.rts
	tst.w		d2
	bmi.s		.rts
	cmp.w		CANVAS_WIDTH,d1
	bge.s		.rts
	cmp.w		CANVAS_HEIGHT,d2
	bge.s		.rts
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a2
	move.w	OPER_BITS,d3
	and.w		#1<<Bit_OPER_COMP,d3
	beq.s		.c
	move.l	LOG_SCR,a2
.c	add.w		d1,d1
	add.w		d1,a0
	add.w		d1,a2
	mulu		logwid,d2
	add.l		d2,a0
	add.l		d2,a2
	dspwrite	(a2)
	dspread	(a0)
.rts	rts

Clip_PHYS_X1Y1:
	cmp.w		X_RESOLUTION,d1
	blt.s		.okx1
	move.w	X_RESOLUTION,d1
	subq		#1,d1
	bra.s		.okx2
.okx1	tst.w		d1
	bpl.s		.okx2
	moveq		#0,d1
.okx2	cmp.w		Y_RESOLUTION,d2
	blt.s		.oky1
	move.w	Y_RESOLUTION,d2
	subq		#1,d2
	bra.s		.oky2
.oky1	tst.w		d2
	bpl.s		.oky2
	moveq		#0,d2
.oky2	rts

Clip_PHYS_X2Y2:
	cmp.w		X_RESOLUTION,d3
	blt.s		.okx1
	move.w	X_RESOLUTION,d3
	subq		#1,d3
	bra.s		.okx2
.okx1	tst.w		d3
	bpl.s		.okx2
	moveq		#0,d3
.okx2	cmp.w		Y_RESOLUTION,d4
	blt.s		.oky1
	move.w	Y_RESOLUTION,d4
	subq		#1,d4
	bra.s		.oky2
.oky1	tst.w		d4
	bpl.s		.oky2
	moveq		#0,d4
.oky2	rts

Clip_LOG_X1Y1:
	cmp.w		CANVAS_WIDTH,d1
	blt.s		.okx1
	move.w	CANVAS_WIDTH,d1
	subq		#1,d1
	bra.s		.okx2
.okx1	tst.w		d1
	bpl.s		.okx2
	moveq		#0,d1
.okx2	cmp.w		CANVAS_HEIGHT,d2
	blt.s		.oky1
	move.w	CANVAS_HEIGHT,d2
	subq		#1,d2
	bra.s		.oky2
.oky1	tst.w		d2
	bpl.s		.oky2
	moveq		#0,d2
.oky2	rts

Clip_LOG_X1Y1_ABS:
	cmp.w		CANVAS_WIDTH,d1
	blt.s		.okx1
	move.w	CANVAS_WIDTH,d1
	bra.s		.okx2
.okx1	tst.w		d1
	bpl.s		.okx2
	moveq		#0,d1
.okx2	cmp.w		CANVAS_HEIGHT,d2
	blt.s		.oky1
	move.w	CANVAS_HEIGHT,d2
	bra.s		.oky2
.oky1	tst.w		d2
	bpl.s		.oky2
	moveq		#0,d2
.oky2	rts

Clip_LOG_X2Y2:
	cmp.w		CANVAS_WIDTH,d3
	blt.s		.okx1
	move.w	CANVAS_WIDTH,d3
	subq		#1,d3
	bra.s		.okx2
.okx1	tst.w		d3
	bpl.s		.okx2
	moveq		#0,d3
.okx2	cmp.w		CANVAS_HEIGHT,d4
	blt.s		.oky1
	move.w	CANVAS_HEIGHT,d4
	subq		#1,d4
	bra.s		.oky2
.oky1	tst.w		d4
	bpl.s		.oky2
	moveq		#0,d4
.oky2	rts

Clip_LOG_X2Y2_ABS:
	cmp.w		CANVAS_WIDTH,d3
	blt.s		.okx1
	move.w	CANVAS_WIDTH,d3
	bra.s		.okx2
.okx1	tst.w		d3
	bpl.s		.okx2
	moveq		#0,d3
.okx2	cmp.w		CANVAS_HEIGHT,d4
	blt.s		.oky1
	move.w	CANVAS_HEIGHT,d4
	bra.s		.oky2
.oky1	tst.w		d4
	bpl.s		.oky2
	moveq		#0,d4
.oky2	rts

Scale_D1D2:
	move.w	Scale_factor,d7
	asr.w		d7,d1
	asr.w		d7,d2
	add.w		Window_X,d1
	add.w		Window_Y,d2
Grid_D1D2:
	tst.w		GRID_BITS
	beq.s		.rts
	add.w		GRID_WIDTH,d1
	add.w		GRID_HEIGHT,d2
	ext.l		d1
	ext.l		d2
	push.w	d0
	move.w	GRID_WIDTH,d0
	divs		d0,d1
	muls		d0,d1
	move.w	GRID_HEIGHT,d0
	divs		d0,d2
	muls		d0,d2
	sub.w		GRID_WIDTH,d1
	sub.w		GRID_HEIGHT,d2
	pop.w		d0
.rts	rts

Scale_D3D4:
	move.w	Scale_factor,d7
	asr.w		d7,d3
	asr.w		d7,d4
	add.w		Window_X,d3
	add.w		Window_Y,d4
Grid_D3D4
	tst.w		GRID_BITS
	beq.s		.rts
	add.w		GRID_WIDTH,d3
	add.w		GRID_HEIGHT,d4
	ext.l		d3
	ext.l		d4
	push.w	d0
	move.w	GRID_WIDTH,d0
	divs		d0,d3
	muls		d0,d3
	move.w	GRID_HEIGHT,d0
	divs		d0,d4
	muls		d0,d4
	sub.w		GRID_WIDTH,d3
	sub.w		GRID_HEIGHT,d4
	pop.w		d0
.rts	rts

Extra_Cpick:
	bsr		HIDE_MOUSE
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	bsr		READ_PHYS_PIXEL
	move.w	d0,FG_COLOUR
	move.w	d0,MASK_COLOUR
	tst.b		TRUE_FLAG
	beq.s		.go
	
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.w	d1,TEMP_RED
	move.w	d2,TEMP_GRN
	move.w	d3,TEMP_BLU

.go	jsr		find_index
	tst.b		rgb_selector_on
	beq.s		.no
	cmp.b		#no_menu,MENU_STATE
	beq.s		.no
	jsr		Draw_sample_zone
	jsr		Convert_RGB_2_SLIDER
.no	jsr		Mark_colours
	bsr		SHOW_MOUSE
	rts
	
TEMP_RED:	ds.w	1
TEMP_GRN:	ds.w	1
TEMP_BLU:	ds.w	1

find_index:
	tst.b		TRUE_FLAG
	bne.s		.err
	lea		INDEX_TABLE,a0
	move.w	FG_COLOUR,d1
	moveq		#0,d0
	move.w	#256-1,d7
.look	move.b	(a0,d7.w),d0
	cmp.w		d0,d1
	beq.s		.ok
	dbra		d7,.look
.ok	move.w	d7,FG_INDEX
.err	rts

Extra_playleft:
	jsr		disable_pbar
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_left,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		Get_changes
	move.w	#0,LEFT_LIMIT
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_LIMIT
	cmp.b		#tween_segment,TWEEN_TYPE
	bne.s		.con2	
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
*-----------------------------------------*
*	Set up buffers				*
*-----------------------------------------*
.con2	st		FREEZE_ICONS
	st		ANIMATING
	jsr		COPY_FRAME_2_LOG
	jsr		Superscaler			; update screen
	push.l	FRAME_SCR
	move.l	LOG_SCR,FRAME_SCR
	move.l	LOG_SCR,HOLD_SCR
*-----------------------------------------*
*	Check for canvas = phys?		*
*-----------------------------------------*
	tst.b		ENABLE_GUIDES
	bne.s		.diff
	tst.w		Scale_factor
	bne.s		.diff
	tst.b		DRAW_LOOP
	beq.s		.diff
	move.w	X_RESOLUTION,d0
	cmp.w		CANVAS_WIDTH,d0
	bne.s		.diff
	move.w	Y_RESOLUTION,d0
	cmp.w		CANVAS_HEIGHT,d0
	bne.s		.diff
*-----------------------------------------*
*	Full-screen with fast update		*
*-----------------------------------------*
.phys	st		PHYS_CANVAS			; deltas now made to phys-screen
	move.l	PHYS_SCR,FRAME_SCR	; new anim-buffer
	move.l	PHYS_SCR,HOLD_SCR
*-----------------------------------------*
*	Animate-loop				*
*-----------------------------------------*
.diff	tst.b		BUTTONS
	bne.s		.diff
.next	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	move.w	LEFT_LIMIT,d1
	cmp.w		d1,d0
	bge.s		.l1
	move.w	RIGHT_LIMIT,d0
	cmp.w		LEFT_LIMIT,d0
	beq.s		.l1
	move.w	TWEEN_BITS,d1
	and.w		#1<<Bit_TWEEN_PING,d1
	beq.s		.l1
	move.w	LEFT_LIMIT,d0
	addq		#1,d0
	bra		link_2
.l1	move.w	d0,CUR_DELTAFRAME
*-----------------------------------------*
	tst.b		PHYS_CANVAS
	bne.s		.pscr
*-----------------------------------------*
.lscr	jsr		Update_position
	jsr		Update_palette
	jsr		Superscaler
	bra.s		.cont
*-----------------------------------------*
.pscr	st		UPDATE_PALETTE
	jsr		Update_position
*-----------------------------------------*
.cont	bsr		WAIT_TIMER
	bsr		Zoom_mode_handler
	jsr		Redraw_position_bar
	jsr		Do_extra_macros
	tst.b		BUTTONS
	bne.s		.stop
	move.b	MACRO_KEY,d0
	beq		.next
.stop	clr.b		ICON_BUTTON
	clr.b		MACRO_KEY
*-----------------------------------------*
*	Put screens back				*
*-----------------------------------------*
	pop.l		FRAME_SCR
	sf		PHYS_CANVAS
	move.l	HOLD_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.l	HOLD_SCR,a0
	move.l	LOG_SCR,a1
	cmp.l		a0,a1
	beq.s		.done
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
*-----------------------------------------*
*	Exit routine				*
*-----------------------------------------*
.done	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.rts	sf		FREEZE_ICONS
	sf		ANIMATING
	jsr		enable_pbar
	rts
	
link_1	=	.l1

Extra_playright:
	jsr		disable_pbar
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_right,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		Get_changes
	move.w	#0,LEFT_LIMIT
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_LIMIT
	cmp.b		#tween_segment,TWEEN_TYPE
	bne.s		.con2
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
*-----------------------------------------*
*	Set up buffers				*
*-----------------------------------------*
.con2	st		FREEZE_ICONS
	st		ANIMATING
	jsr		COPY_FRAME_2_LOG
	jsr		Superscaler			; update screen
	push.l	FRAME_SCR
	move.l	LOG_SCR,FRAME_SCR
	move.l	LOG_SCR,HOLD_SCR
*-----------------------------------------*
*	Check for canvas = phys?		*
*-----------------------------------------*
	tst.b		ENABLE_GUIDES
	bne.s		.diff
	tst.w		Scale_factor
	bne.s		.diff
	tst.b		DRAW_LOOP
	beq.s		.diff
	move.w	X_RESOLUTION,d0
	cmp.w		CANVAS_WIDTH,d0
	bne.s		.diff
	move.w	Y_RESOLUTION,d0
	cmp.w		CANVAS_HEIGHT,d0
	bne.s		.diff
*-----------------------------------------*
*	Full-screen with fast update		*
*-----------------------------------------*
.phys	st		PHYS_CANVAS			; deltas now made to phys-screen
	move.l	PHYS_SCR,FRAME_SCR	; new anim-buffer
	move.l	PHYS_SCR,HOLD_SCR		; new anim-buffer
*-----------------------------------------*
*	Animate-loop				*
*-----------------------------------------*
.diff	tst.b		BUTTONS
	bne.s		.diff
	clr.b		ICON_BUTTON
.next	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	move.w	RIGHT_LIMIT,d1
	cmp.w		d1,d0
	ble.s		.l2
	move.w	LEFT_LIMIT,d0
	cmp.w		RIGHT_LIMIT,d0
	beq.s		.l2
	move.w	TWEEN_BITS,d1
	and.w		#1<<Bit_TWEEN_PING,d1
	beq.s		.l2
	move.w	RIGHT_LIMIT,d0
	subq		#1,d0
	bra		link_1
.l2	move.w	d0,CUR_DELTAFRAME
*-----------------------------------------*
	tst.b		PHYS_CANVAS
	bne.s		.pscr
*-----------------------------------------*
.lscr	jsr		Update_position
	jsr		Update_palette
	jsr		Superscaler
	bra.s		.cont
*-----------------------------------------*
.pscr	st		UPDATE_PALETTE
	jsr		Update_position
*-----------------------------------------*
.cont	bsr		WAIT_TIMER
	bsr		Zoom_mode_handler
	jsr		Redraw_position_bar
	jsr		Do_extra_macros
	tst.b		BUTTONS
	bne.s		.stop
	move.b	MACRO_KEY,d0
	beq		.next
.stop	clr.b		ICON_BUTTON
	clr.b		MACRO_KEY
*-----------------------------------------*
*	Put screens back				*
*-----------------------------------------*
	pop.l		FRAME_SCR
	sf		PHYS_CANVAS
	move.l	HOLD_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.l	HOLD_SCR,a0
	move.l	LOG_SCR,a1
	cmp.l		a0,a1
	beq.s		.done
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
*-----------------------------------------*
*	Exit routine				*
*-----------------------------------------*
.done	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.rts	sf		FREEZE_ICONS
	sf		ANIMATING
	jsr		enable_pbar
	rts

link_2	=	.l2

nr		=	4

Init_DSP_NR:
	pushall
	moveq		#1,d1
	move.l	#DSPNR_L,d0
	lea		DSPNR,a0
	jsr		DspExecProg
	dspwrite	nrthresh
	popall
	rts

Init_DSP_MB:
	pushall
	moveq		#1,d1
	move.l	#DSPNR_L,d0
	lea		DSPNR,a0
	jsr		DspExecProg
	dspwrite	#255
	popall
	rts

Aproc_area:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Aproc_area,d0
	moveq		#station_aproc,d1
	lea		Aproc_area_code,a0
	jsr		Setup_tool
	jsr		HIDE_MOUSE
	st		CROSSHAIR
	jsr		SHOW_MOUSE
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	jsr		Check_menu
.skip	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
	endc
.exit	rts

Aproc_area_code:
	ifnd		cutdown
	init_tool
	bsr		Init_cut_coords
	bsr		INIT_PENCIL
	jsr		Keep_undo
	sf		UNDO_VALID
	sf		CROSSHAIR
	push.b	ENABLE_GUIDES
	st		SOFTWARE_MOUSE
	sf		ENABLE_GUIDES
	jsr		Superscaler
	jsr		Update_mouseptr
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d3-d4,-(sp)
	bsr		COPYBACK
	jsr		Remove_mouseptr
	movem.w	(sp)+,d3-d4
	bsr		Scale_D3D4
	move.w	d3,X2
	move.w	d4,Y2
	move.w	X1,d1
	move.w	Y1,d2
	jsr		DRAW_LOG_OUTLINE
	jsr		Superscale_zone
	jsr		Print_cut_coords
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		Refresh_info_bar
	clr.w		brush_deviance
	bsr		COPYBACK
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	cmp.w		d3,d1
	ble.s		.ok1
	exg		d3,d1
.ok1	cmp.w		d4,d2
	ble.s		.ok2
	exg		d4,d2
.ok2	move.w	d1,Proc_x1
	move.w	d2,Proc_y1
	move.w	d3,Proc_x2
	move.w	d4,Proc_y2
	sub.w		d1,d3
	addq		#1,d3
	move.w	d3,Proc_width
	sub.w		d2,d4
	addq		#1,d4
	move.w	d4,Proc_height
	jsr		Remove_mouseptr
	pop.b		ENABLE_GUIDES
	sf		SOFTWARE_MOUSE
	jsr		Superscaler
	jsr		Update_chstate
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
	jsr		Reset_tool
	endc
	rts

Aproc_go:
	ifnd		cutdown
	cmp.b		#right_button,ICON_BUTTON
	beq		.err
	bsr		HIDE_MOUSE
	seticon	I_Aproc_go,station_aproc
	jsr		Redraw_menu_icons
	delay		8
	move.l	GO_CODE,a0
	jsr		(a0)
	reseticon
	jsr		Redraw_menu_icons
	jsr		Refresh_info_bar
	bsr		SHOW_MOUSE
	endc
.err:	rts	

Aproc_dolby:
	ifnd		cutdown
	jsr		Extra_dummy
	moveq		#station_aproc,d1
	move.w	d1,THIS_STATION
	move.w	d1,OLD_TSTATION
	moveq		#I_Aproc_dolby,d0
	move.w	d0,CURRENT_FUNCTION
	move.w	d0,OLD_FUNCTION
	jsr		Redraw_menu_icons
	move.l	#Aproc_dolby_code,GO_CODE
	endc
	rts

Aproc_dolby_code:
	ifnd		cutdown
	sf		Memory_error
	jsr		Superscaler
	jsr		Get_changes
	tst.l		d0
	bmi		.done
	move.w	#8,nrthresh
	jsr		blur_loop
.done	jsr		Superscaler
	endc
.rts	rts

Aproc_defocus:
	ifnd		cutdown
	moveq		#I_Aproc_defocus,d0
	moveq		#station_aproc,d1
	lea		WIN_Aproc_motion,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.ok
	jmp		Tool_dialog_box
.ok	jsr		Extra_dummy
	moveq		#station_aproc,d1
	move.w	d1,THIS_STATION
	move.w	d1,OLD_TSTATION
	moveq		#I_Aproc_defocus,d0
	move.w	d0,CURRENT_FUNCTION
	move.w	d0,OLD_FUNCTION
	jsr		Redraw_menu_icons
	move.l	#Aproc_defocus_code,GO_CODE	
	endc
	rts

Aproc_defocus_code:
	ifnd		cutdown
	sf		Memory_error
	jsr		Superscaler
	jsr		Get_changes
	tst.l		d0
	bmi		.done
	jsr		mpeg_loop
.done	jsr		Superscaler
	endc
.rts	rts

	ifnd		cutdown
mpeg_loop:
*-----------------------------------------*
*	Init animation range			*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	d0,LEFT_LIMIT
	move.w	d0,RIGHT_LIMIT
	move.w	#1,TFRAME
	move.w	#1,CURFRAME
	move.w	#0,LEFT_CLIP
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_CLIP
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		.strt
	move.w	Delta_count,TFRAME
	move.w	LEFT_CLIP,LEFT_LIMIT
	move.w	RIGHT_CLIP,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
	sub.w		d0,d1
	addq		#1,d1
	move.w	d1,TFRAME
	cmp.w		#3,d1
	blt		.done
*-----------------------------------------*
*	Check mode & get info from user	*
*-----------------------------------------*
.cont	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
.strt	tst.b		TRUE_FLAG
	bne.s		.tc
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.done
.tc	push.w	CUR_DELTAFRAME
	move.w	LEFT_LIMIT,d0
	jsr		Frame_goto
	jsr		Redraw_menu_icons
	jsr		Superscaler
*-----------------------------------------*
*	Prepare buffers				*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	jsr		get_prev_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f-1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
	move.w	TFRAME,MAXFRAME
	st		FRAMECOUNT
*-----------------------------------------------*

.loop	move.w	Proc_height,d7
	add.w		tile_ysize,d7
	subq		#1,d7
	ext.l		d7
	divu		tile_ysize,d7
	subq		#1,d7
.ylp	move.w	Proc_width,d6
	add.w		tile_xsize,d6
	subq		#1,d6
	ext.l		d6
	divu		tile_xsize,d6
	subq		#1,d6
.xlp	push.w	d6
	push.w	d7
	mulu		tile_xsize,d6
	mulu		tile_ysize,d7
	add.w		Proc_x1,d6
	add.w		Proc_y1,d7
	move.w	d6,tile_x1
	move.w	d7,tile_y1
	move.w	tile_xsize,tile_width
	move.w	tile_ysize,tile_height
	move.w	tile_x1,d6
	add.w		tile_width,d6
	sub.w		CANVAS_WIDTH,d6
	bmi.s		.okx
	sub.w		d6,tile_width
.okx	move.w	tile_y1,d6
	add.w		tile_height,d6
	sub.w		CANVAS_HEIGHT,d6
	bmi.s		.oky
	sub.w		d6,tile_height
.oky	jsr		do_tile
	pop.w		d7
	pop.w		d6
	dbra		d6,.xlp
	dbra		d7,.ylp
*-----------------------------------------------*
	jsr		Superscaler
	st		BITMAP_CHANGED
	jsr		Get_changes				; store 'LOG' & void 'PACK'
	tst.l		d0
	bmi		.err
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		RIGHT_LIMIT,d0
	ble.s		.ok2
	move.w	LEFT_LIMIT,d0
.ok2	jsr		Frame_goto
	jsr		Redraw_menu_icons
	move.w	CUR_DELTAFRAME,d0
	jsr		get_prev_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f-1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
	jsr		Superscaler
	tst.b		BUTTONS
	bne.s		.err
	tst.b		Memory_error
	bne.s		.err
	addq		#1,CURFRAME
	subq		#1,TFRAME
	bne		.loop
.err	jsr		MRELEASE
	pop.w		d0
	jsr		Frame_goto
.done	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	rts

do_tile:
	jsr		get_tile
	moveq		#0,d1
	move.w	CURRENT_MTHRESH,d1
	cmp.l		d1,d0
	bgt.s		.no
	jsr		put_tile
.no	rts

tile_x1:	ds.w	1
tile_y1:	ds.w	1

tile_xsize:	dc.w	8
tile_ysize:	dc.w	8

tile_width	ds.w	1
tile_height	ds.w	1

get_tile:
	move.l	LOG_SCR,a0
	move.l	PACK_SCR,a1
	move.w	tile_x1,d7
	add.w		d7,d7
	add.w		d7,a0
	add.w		d7,a1
	move.w	tile_y1,d7
	mulu		logwid,d7
	add.l		d7,a0
	add.l		d7,a1
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.w	tile_height,d7
	subq		#1,d7
.ylp	push.w	d7
	move.w	tile_width,d6
	subq		#1,d6
	push.l	a0
	push.l	a1
.xlp	push.w	d6
	move.w	(a0)+,d6
	move.w	(a1)+,d7
	bfextu	d6{16:8},d0
	bfextu	d7{16:8},d5
	and.l		#%11111000,d0
	and.l		#%11111000,d5
	sub.l		d5,d0
	bpl.s		.p1
	neg.l		d0
.p1	mulu		d0,d0
	add.l		d0,d1
	bfextu	d6{21:8},d0
	bfextu	d7{21:8},d5
	and.l		#%11111100,d0
	and.l		#%11111100,d5
	sub.l		d5,d0
	bpl.s		.p2
	neg.l		d0
.p2	mulu		d0,d0
	add.l		d0,d2
	bfextu	d6{27:8},d0
	bfextu	d7{27:8},d5
	and.l		#%11111000,d0
	and.l		#%11111000,d5
	sub.l		d5,d0
	bpl.s		.p3
	neg.l		d0
.p3	mulu		d0,d0
	add.l		d0,d3
	pop.w		d6
	dbra		d6,.xlp
	pop.l		a1
	pop.l		a0
	add.w		logwid,a0
	add.w		logwid,a1
	pop.w		d7
	dbra		d7,.ylp
	move.w	tile_width,d0
	mulu		tile_height,d0
	divu.l	d0,d1
	divu.l	d0,d2
	divu.l	d0,d3
	add.l		d3,d2
	add.l		d2,d1
	move.l	d1,d0
	rts

put_tile:
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	tile_x1,d7
	add.w		d7,d7
	add.w		d7,a0
	add.w		d7,a1
	move.w	tile_y1,d7
	mulu		logwid,d7
	add.l		d7,a0
	add.l		d7,a1
*-----------------------------------------------*
	move.w	tile_height,d7
	subq		#1,d7
.ylp	move.w	tile_width,d6
	subq		#1,d6
	push.l	a1
	push.l	a0
.xlp	move.w	(a0)+,(a1)+
	dbra		d6,.xlp
	pop.l		a0
	pop.l		a1
	add.w		logwid,a0
	add.w		logwid,a1
	dbra		d7,.ylp
	rts

blur_loop:
*-----------------------------------------*
*	Init animation range			*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	d0,LEFT_LIMIT
	move.w	d0,RIGHT_LIMIT
	move.w	#1,TFRAME
	move.w	#1,CURFRAME
	move.w	#0,LEFT_CLIP
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_CLIP
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		.strt
	move.w	Delta_count,TFRAME
	move.w	LEFT_CLIP,LEFT_LIMIT
	move.w	RIGHT_CLIP,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
	sub.w		d0,d1
	addq		#1,d1
	move.w	d1,TFRAME
	cmp.w		#3,d1
	blt		.done
*-----------------------------------------*
*	Check mode & get info from user	*
*-----------------------------------------*
.cont	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
.strt	tst.b		TRUE_FLAG
	bne.s		.tc
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.done
.tc	push.w	CUR_DELTAFRAME
	move.w	LEFT_LIMIT,d0
	jsr		Frame_goto
	jsr		Redraw_menu_icons
	jsr		Superscaler
*-----------------------------------------*
*	Start DSP filter				*
*-----------------------------------------*
	jsr		Init_DSP_NR
*-----------------------------------------*
*	Prepare buffers				*
*-----------------------------------------*
	move.l	CANVAS_SIZE,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.w	d0,BUFFER1_HANDLE	
	move.w	CUR_DELTAFRAME,d0
	jsr		get_prev_frame
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	FRAME_SCR,a0
	move.l	BUFFER1_PTR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; buffer_scr = f-1
	move.w	CUR_DELTAFRAME,d0
	jsr		get_next_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f+1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
*-----------------------------------------------*
	move.w	TFRAME,MAXFRAME
	st		FRAMECOUNT
.loop	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	LOG_SCR,a1
	move.l	PACK_SCR,a2
	move.w	Proc_x1,d7
	add.w		d7,d7
	add.w		d7,a0
	add.w		d7,a1
	add.w		d7,a2
	move.w	Proc_y1,d7
	mulu		logwid,d7
	add.l		d7,a0
	add.l		d7,a1
	add.l		d7,a2
	move.w	Proc_width,.temp_xl
	move.w	Proc_height,.temp_yl
	subq		#1,.temp_xl
	subq		#1,.temp_yl
*-----------------------------------------------*
	move.w	Proc_height,d7
	subq		#1,d7
.ylp	move.w	Proc_width,d6
	subq		#1,d6
	push.l	a2
	push.l	a1
	push.l	a0
.xlp	push.w	d7
	push.w	d6
*-----------------------------------------------*
	neg.w		d6
	neg.w		d7
	add.w		Proc_width,d6
	add.w		Proc_height,d7
	subq		#1,d6
	subq		#1,d7
*-----------------------------------------------*
	lea		.nr_return,a6
	tst.w		d6
	bne		.lclear
	tst.w		d7
	beq		nr_ltclip
	cmp.w		.temp_yl,d7
	beq		nr_lbclip
	bra		nr_lmclip
.lclear
	cmp.w		.temp_xl,d6
	bne		.rclear
	tst.w		d7
	beq		nr_rtclip
	cmp.w		.temp_yl,d7
	beq		nr_rbclip
	bra		nr_rmclip
.rclear
	tst.w		d7
	beq		nr_mtclip
	cmp.w		.temp_yl,d7
	beq		nr_mbclip
	bra		nr_noclip
.temp_xl:
	ds.w		1
.temp_yl:
	ds.w		1
.nr_return:
	addq.l	#2,a0
	addq.l	#2,a2
	dspread	(a1)+	
*-----------------------------------------------*
	pop.w		d6
	pop.w		d7
	dbra		d6,.xlp
	pop.l		a0
	pop.l		a1
	pop.l		a2
	add.w		logwid,a0
	add.w		logwid,a1
	add.w		logwid,a2
	dbra		d7,.ylp
*-----------------------------------------------*
	jsr		Superscaler
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	FRAME_SCR,a0
	move.l	BUFFER1_PTR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; buffer_scr = f-1
	st		BITMAP_CHANGED
	jsr		Get_changes				; store 'LOG' & void 'PACK'
	tst.l		d0
	bmi		.err
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		RIGHT_LIMIT,d0
	ble.s		.ok2
	move.w	LEFT_LIMIT,d0
.ok2	jsr		Frame_goto
	jsr		Redraw_menu_icons
	move.w	CUR_DELTAFRAME,d0
	jsr		get_next_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f+1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
	jsr		Superscaler
	tst.b		BUTTONS
	bne.s		.err
	tst.b		Memory_error
	bne.s		.err
	addq		#1,CURFRAME
	subq		#1,TFRAME
	bne		.loop
.err	jsr		MRELEASE
	pop.w		d0
	jsr		Frame_goto
.done	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	rts

nr_noclip:
	dspwrite	(a1)
	dspwrite	#6
	dspwrite	2(a1)
	dspwrite	-2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_ltclip:
	dspwrite	(a1)
	dspwrite	#4
	dspwrite	2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_lmclip:
	dspwrite	(a1)
	dspwrite	#5
	dspwrite	2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_lbclip:
	dspwrite	(a1)
	dspwrite	#4
	dspwrite	2(a1)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_mtclip:
	dspwrite	(a1)
	dspwrite	#5
	dspwrite	2(a1)
	dspwrite	-2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_mbclip:
	dspwrite	(a1)
	dspwrite	#5
	dspwrite	2(a1)
	dspwrite	-2(a1)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_rtclip:
	dspwrite	(a1)
	dspwrite	#4
	dspwrite	-2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_rmclip:
	dspwrite	(a1)
	dspwrite	#5
	dspwrite	-2(a1)
	move.w	logwid,d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)

nr_rbclip:
	dspwrite	(a1)
	dspwrite	#4
	dspwrite	-2(a1)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a1,d0.w),d1
	dspwrite	d1
	dspwrite	(a0)
	dspwrite	(a2)
	jmp		(a6)



blur_loop2:
*-----------------------------------------*
*	Init animation range			*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	d0,LEFT_LIMIT
	move.w	d0,RIGHT_LIMIT
	move.w	#1,TFRAME
	move.w	#1,CURFRAME
	move.w	#0,LEFT_CLIP
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_CLIP
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		.strt
	move.w	Delta_count,TFRAME
	move.w	LEFT_CLIP,LEFT_LIMIT
	move.w	RIGHT_CLIP,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
	sub.w		d0,d1
	addq		#1,d1
	move.w	d1,TFRAME
	cmp.w		#3,d1
	blt		.done
*-----------------------------------------*
*	Check mode & get info from user	*
*-----------------------------------------*
.cont	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
.strt	tst.b		TRUE_FLAG
	bne.s		.tc
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.done
.tc	push.w	CUR_DELTAFRAME
	move.w	LEFT_LIMIT,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.skp1
	jsr		Frame_goto
.skp1	jsr		Redraw_menu_icons
	jsr		Superscaler
*-----------------------------------------*
*	Start DSP filter				*
*-----------------------------------------*
	jsr		Init_DSP_NR
*-----------------------------------------*
*	Prepare buffers				*
*-----------------------------------------*
	move.w	TFRAME,MAXFRAME
	st		FRAMECOUNT
.loop	jsr		Keep_undo
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	Proc_x1,d7
	add.w		d7,d7
	add.w		d7,a0
	add.w		d7,a1
	move.w	Proc_y1,d7
	mulu		logwid,d7
	add.l		d7,a0
	add.l		d7,a1
	move.w	Proc_width,.temp_xl
	move.w	Proc_height,.temp_yl
	subq		#1,.temp_xl
	subq		#1,.temp_yl
*-----------------------------------------------*
	move.w	Proc_height,d7
	subq		#1,d7
.ylp	move.w	Proc_width,d6
	subq		#1,d6
	push.l	a1
	push.l	a0
.xlp	push.w	d7
	push.w	d6
*-----------------------------------------------*
	neg.w		d6
	neg.w		d7
	add.w		Proc_width,d6
	add.w		Proc_height,d7
	subq		#1,d6
	subq		#1,d7
*-----------------------------------------------*
	lea		.nr_return,a6
	tst.w		d6
	bne		.lclear
	tst.w		d7
	beq		nr_ltclip2
	cmp.w		.temp_yl,d7
	beq		nr_lbclip2
	bra		nr_lmclip2
.lclear
	cmp.w		.temp_xl,d6
	bne		.rclear
	tst.w		d7
	beq		nr_rtclip2
	cmp.w		.temp_yl,d7
	beq		nr_rbclip2
	bra		nr_rmclip2
.rclear
	tst.w		d7
	beq		nr_mtclip2
	cmp.w		.temp_yl,d7
	beq		nr_mbclip2
	bra		nr_noclip2
.temp_xl:
	ds.w		1
.temp_yl:
	ds.w		1
.nr_return:
	addq.l	#2,a0
	dspread	(a1)+	
*-----------------------------------------------*
	pop.w		d6
	pop.w		d7
	dbra		d6,.xlp
	pop.l		a0
	pop.l		a1
	add.w		logwid,a0
	add.w		logwid,a1
	dbra		d7,.ylp
*-----------------------------------------------*
	st		BITMAP_CHANGED
	jsr		Superscaler
	cmp.b		#tween_frame,TWEEN_TYPE
	bne.s		.ct
	pop.w		d0
	bra		.done
.ct	jsr		Get_changes				; store 'LOG' & void 'PACK'
	tst.l		d0
	bmi		.err
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		RIGHT_LIMIT,d0
	ble.s		.ok2
	move.w	RIGHT_LIMIT,d0
.ok2	jsr		Frame_goto
	jsr		Redraw_menu_icons
	jsr		Superscaler
	tst.b		BUTTONS
	bne.s		.err
	tst.b		Memory_error
	bne.s		.err
	addq		#1,CURFRAME
	subq		#1,TFRAME
	bne		.loop
.err	pop.w		d0
	jsr		Frame_goto
.done	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	rts

nr_noclip2:
	dspwrite	(a0)
	dspwrite	#4+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_ltclip2:
	dspwrite	(a0)
	dspwrite	#2+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_lmclip2:
	dspwrite	(a0)
	dspwrite	#3+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_lbclip2:
	dspwrite	(a0)
	dspwrite	#2+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_mtclip2:
	dspwrite	(a0)
	dspwrite	#3+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_mbclip2:
	dspwrite	(a0)
	dspwrite	#3+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	2(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_rtclip2:
	dspwrite	(a0)
	dspwrite	#2+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_rmclip2:
	dspwrite	(a0)
	dspwrite	#3+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)

nr_rbclip2:
	dspwrite	(a0)
	dspwrite	#2+4
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	(a0)
	dspwrite	-2(a0)
	move.w	logwid,d0
	neg.w		d0
	move.w	(a0,d0.w),d1
	dspwrite	d1
	jmp		(a6)
	
	endc

Aproc_dejag:
	ifnd		cutdown
	jsr		Extra_dummy
	moveq		#station_aproc,d1
	move.w	d1,THIS_STATION
	move.w	d1,OLD_TSTATION
	moveq		#I_Aproc_dejag,d0
	move.w	d0,CURRENT_FUNCTION
	move.w	d0,OLD_FUNCTION
	jsr		Redraw_menu_icons
	move.l	#Aproc_dejag_code,GO_CODE	
	endc
	rts

Aproc_dejag_code:
	ifnd		cutdown
	sf		Memory_error
	jsr		Superscaler
	jsr		Get_changes
	tst.l		d0
	bmi		.done
	move.w	#256,nrthresh
	jsr		blur_loop2
.done	jsr		Superscaler
	endc
.rts	rts

Aproc_mblur:
	ifnd		cutdown
	jsr		Extra_dummy
	moveq		#station_aproc,d1
	move.w	d1,THIS_STATION
	move.w	d1,OLD_TSTATION
	moveq		#I_Aproc_mblur,d0
	move.w	d0,CURRENT_FUNCTION
	move.w	d0,OLD_FUNCTION
	jsr		Redraw_menu_icons
	move.l	#Aproc_mblur_code,GO_CODE	
	endc
	rts

Aproc_mblur_code:
	ifnd		cutdown
	sf		Memory_error
	jsr		Superscaler
	jsr		Get_changes
	tst.l		d0
	bmi		.done
*-----------------------------------------*
*	Init animation range			*
*-----------------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	d0,LEFT_LIMIT
	move.w	d0,RIGHT_LIMIT
	move.w	#1,TFRAME
	move.w	#1,CURFRAME
	move.w	#0,LEFT_CLIP
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_CLIP
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		.strt
	move.w	Delta_count,TFRAME
	move.w	LEFT_CLIP,LEFT_LIMIT
	move.w	RIGHT_CLIP,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
	sub.w		d0,d1
	addq		#1,d1
	move.w	d1,TFRAME
	cmp.w		#3,d1
	blt		.done
*-----------------------------------------*
*	Check mode & get info from user	*
*-----------------------------------------*
.cont	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
.strt	tst.b		TRUE_FLAG
	bne.s		.tc
	lea		WIN_NTC_Alert,a0
	jsr		DO_ALERT
	bra		.done
.tc	push.w	CUR_DELTAFRAME
	move.w	LEFT_LIMIT,d0
	jsr		Frame_goto
	jsr		Redraw_menu_icons
	jsr		Superscaler
*-----------------------------------------*
*	Start DSP filter				*
*-----------------------------------------*
	jsr		Init_DSP_MB
*-----------------------------------------*
*	Prepare buffers				*
*-----------------------------------------*
	move.l	CANVAS_SIZE,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi		.err
	move.w	d0,BUFFER1_HANDLE	
	move.w	CUR_DELTAFRAME,d0
	jsr		get_prev_frame
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	FRAME_SCR,a0
	move.l	BUFFER1_PTR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; buffer_scr = f-1
	move.w	CUR_DELTAFRAME,d0
	jsr		get_next_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f+1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
	move.w	TFRAME,MAXFRAME
	st		FRAMECOUNT
*-----------------------------------------------*
.loop	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	LOG_SCR,a1
	move.l	PACK_SCR,a2
	move.w	Proc_x1,d7
	add.w		d7,d7
	add.w		d7,a0
	add.w		d7,a1
	add.w		d7,a2
	move.w	Proc_y1,d7
	mulu		logwid,d7
	add.l		d7,a0
	add.l		d7,a1
	add.l		d7,a2
*-----------------------------------------------*
	move.w	Proc_height,d7
	subq		#1,d7
.ylp	move.w	Proc_width,d6
	subq		#1,d6
	push.l	a2
	push.l	a1
	push.l	a0
.xlp	push.w	d7
	push.w	d6
*-----------------------------------------------*
	dspwrite	(a1)
	dspwrite	#3
	dspwrite	(a1)
	dspwrite	(a0)+
	dspwrite	(a2)+
	dspread	(a1)+	
*-----------------------------------------------*
	pop.w		d6
	pop.w		d7
	dbra		d6,.xlp
	pop.l		a0
	pop.l		a1
	pop.l		a2
	add.w		logwid,a0
	add.w		logwid,a1
	add.w		logwid,a2
	dbra		d7,.ylp
*-----------------------------------------------*
	jsr		Superscaler
	move.w	BUFFER1_HANDLE,d0
	jsr		Find_block
	move.l	a0,BUFFER1_PTR
	move.l	FRAME_SCR,a0
	move.l	BUFFER1_PTR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; buffer_scr = f-1
	st		BITMAP_CHANGED
	jsr		Get_changes				; store 'LOG' & void 'PACK'
	tst.l		d0
	bmi		.err
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		RIGHT_LIMIT,d0
	ble.s		.ok2
	move.w	LEFT_LIMIT,d0
.ok2	jsr		Frame_goto
	jsr		Redraw_menu_icons
	move.w	CUR_DELTAFRAME,d0
	jsr		get_next_frame
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; pack_scr = f+1
	move.w	CUR_DELTAFRAME,d0
	jsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy				; log_scr = f
	jsr		Superscaler
	tst.b		BUTTONS
	bne.s		.err
	tst.b		Memory_error
	bne.s		.err
	addq		#1,CURFRAME
	subq		#1,TFRAME
	bne		.loop
.err	jsr		MRELEASE
	pop.w		d0
	jsr		Frame_goto
*-----------------------------------------*
*	Exit routine				*
*-----------------------------------------*
.done	jsr		Superscaler
	sf		FRAMECOUNT
	jsr		Refresh_info_bar
	endc
.rts	rts

get_prev_frame:
	subq		#1,d0
	cmp.w		LEFT_CLIP,d0
	bge.s		.ok
	move.w	LEFT_CLIP,d0
.ok	jsr		Update_position
	rts

get_next_frame:
	addq		#1,d0
	cmp.w		RIGHT_CLIP,d0
	ble.s		.ok
	move.w	RIGHT_CLIP,d0
.ok	jsr		Update_position
	rts

LEFT_CLIP:	ds.w	1
RIGHT_CLIP:	ds.w	1

WAIT_TIMER:
.wv	tst.w		TIMER
	bne.s		.wv
	moveq		#1,d0
	add.w		CURRENT_TIME,d0
	move.w	d0,TIMER
	rts

Zoom_mode_handler:
	tst.b		ENABLE_GUIDES
	bne		.slow
	tst.w		Scale_factor
	bne.s		.slow
*-----------------------------------------*
*	Full-screen with fast update		*
*-----------------------------------------*
.fast	tst.b		PHYS_CANVAS
	bne		.exit
	tst.b		ENABLE_GUIDES
	bne		.exit
	tst.b		DRAW_LOOP
	beq		.exit
	move.w	X_RESOLUTION,d0
	cmp.w		CANVAS_WIDTH,d0
	bne		.exit
	move.w	Y_RESOLUTION,d0
	cmp.w		CANVAS_HEIGHT,d0
	bne.s		.exit
	move.l	FRAME_SCR,a0
	move.l	PHYS_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.l	PHYS_SCR,FRAME_SCR	; new anim-buffer
	move.l	PHYS_SCR,HOLD_SCR		; new anim-buffer
	st		PHYS_CANVAS			; deltas now made to phys-screen
	bra.s		.exit
*-----------------------------------------*
*	Normal scaling update			*
*-----------------------------------------*
.slow	tst.b		PHYS_CANVAS
	beq.s		.exit
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,FRAME_SCR		; new anim-buffer
	move.l	FRAME_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.l	LOG_SCR,HOLD_SCR		; new anim-buffer
	sf		PHYS_CANVAS			; deltas now made to frame-screen
.exit	rts

READ_PHYS_PIXEL:
	move.l	PHYS_SCR,a0
	tst.b		TRUE_FLAG
	bne		READ_PHYS_PIXEL_TRUE
	move.w	d2,d7
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d7,a0
	move.w	d1,d7
	moveq		#-16,d1
	and.w		d7,d1
	lea		16(a0,d1.w),a0
	moveq		#2-1,d6
	moveq		#0,d0
.rep	move.w	-(a0),d5
	move.w	-(a0),d4
	move.w	-(a0),d3
	move.w	-(a0),d2
	rol.w		d7,d2
	rol.w		d7,d3
	rol.w		d7,d4
	rol.w		d7,d5
	add.w		d5,d5
	addx.w	d0,d0
	add.w		d4,d4
	addx.w	d0,d0
	add.w		d3,d3
	addx.w	d0,d0
	add.w		d2,d2
	addx.w	d0,d0
	dbra		d6,.rep
	rts

READ_LOG_PIXEL:
	move.l	LOG_SCR,a0
READ_SCR_PIXEL:
	tst.b		TRUE_FLAG
	bne.s		READ_LOG_PIXEL_TRUE
	move.w	d2,d7
	move.l	(LOG_Y.l,d7.w*4),d7
	add.l		d7,a0
	move.w	d1,d7
	moveq		#-16,d1
	and.w		d7,d1
	lea		16(a0,d1.w),a0
	moveq		#2-1,d6
	moveq		#0,d0
.rep	move.w	-(a0),d5
	move.w	-(a0),d4
	move.w	-(a0),d3
	move.w	-(a0),d2
	rol.w		d7,d2
	rol.w		d7,d3
	rol.w		d7,d4
	rol.w		d7,d5
	add.w		d5,d5
	addx.w	d0,d0
	add.w		d4,d4
	addx.w	d0,d0
	add.w		d3,d3
	addx.w	d0,d0
	add.w		d2,d2
	addx.w	d0,d0
	dbra		d6,.rep
	rts
	
READ_PHYS_PIXEL_TRUE:
	add.w		d1,d1
	add.w		d1,a0
	move.l	(PHYS_Y.l,d2.w*4),d2
	add.l		d2,a0
	move.w	(a0),d0
	rts

READ_LOG_PIXEL_TRUE:
	add.w		d1,d1
	add.w		d1,a0
	move.l	(LOG_Y.l,d2.w*4),d2
	add.l		d2,a0
	move.w	(a0),d0
	rts

READ_PIXEL:
	move.w	d2,d7
	mulu		scrwid,d7
	add.l		d7,a0
	moveq		#16-1,d7
	and.w		d1,d7
	lsr.w		#4,d1
	mulu		wrdwid,d1	
	lea		16(a0,d1.w),a0
	moveq		#2-1,d6
	moveq		#0,d0
.rep	move.w	-(a0),d5
	move.w	-(a0),d4
	move.w	-(a0),d3
	move.w	-(a0),d2
	rol.w		d7,d2
	rol.w		d7,d3
	rol.w		d7,d4
	rol.w		d7,d5
	add.w		d5,d5
	addx.b	d0,d0
	add.w		d4,d4
	addx.b	d0,d0
	add.w		d3,d3
	addx.b	d0,d0
	add.w		d2,d2
	addx.b	d0,d0
	dbra		d6,.rep
	rts

*-----*	Block functions		*-----------------------------------*

Cell_cut:
	moveq		#I_Cell_cut,d0
	moveq		#station_cell,d1
	lea		Cell_cut_code,a0
	lea		WIN_Cell_cut,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.no
	jmp		Tool_dialog_box
.no	jsr		Setup_tool
	bsr		HIDE_MOUSE
	st		CROSSHAIR
	bsr		SHOW_MOUSE
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	bsr		Check_menu
.skip	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
	rts

Cell_cut_code:
	init_tool
	move.w	CUT_BITS,d0
	btst		#Bit_CUT_JACK,d0
	bne		Lassoo_cut
	bsr		cut_block_loop
	jsr		Reset_tool
	rts

cut_block_loop:
	bsr		Init_cut_coords
	bsr		INIT_PENCIL
	jsr		Keep_undo
	clr.b		CROSSHAIR
	clr.w		brush_deviance
	st		SOFTWARE_MOUSE
	jsr		Update_mouseptr
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
.wait	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.skip
.cont	movem.w	d3-d4,-(sp)
	jsr		COPYBACK
	jsr		Remove_mouseptr
	movem.w	(sp)+,d3-d4
	bsr		Scale_D3D4
	move.w	X1,d1
	move.w	Y1,d2
	tst.w		GRID_BITS
	beq.s		.ok
	subq		#1,d3
	subq		#1,d4
.ok	move.w	d3,X2
	move.w	d4,Y2
	jsr		DRAW_LOG_OUTLINE
	bsr		Superscale_zone
	bsr		Print_cut_coords
	jsr		Update_mouseptr
.skip	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		Refresh_info_bar
	jsr		COPYBACK
	move.w	LOG_HANDLE,TAB_HANDLE
	bsr.s		CUT_BRUSH
	tst.l		d0
	bmi.s		.out
	bsr		MAKE_BLOCKMASK
.out	jsr		Remove_mouseptr
	sf		SOFTWARE_MOUSE
	bsr		Superscaler
	jsr		Update_chstate
	bsr		Superscaler
	bsr		MOUSE_WAITMODE
	rts

CUT_BRUSH:
	move.w	X1,d0
	bpl.s		.o1
	moveq		#0,d0
.o1	move.w	X2,d1
	bpl.s		.o2
	moveq		#0,d1
.o2	cmp.w		d0,d1
	bge.s		.okx
	exg		d0,d1
.okx	move.w	d0,X1
	move.w	d1,X2
	move.w	X1,BRUSH_XBASE
	move.w	X1,CUT_XBASE
	move.w	Y1,d0
	bpl.s		.o3
	moveq		#0,d0
.o3	move.w	Y2,d1
	bpl.s		.o4
	moveq		#0,d1
.o4	cmp.w		d0,d1
	bge.s		.oky
	exg		d0,d1
.oky	move.w	d0,Y1
	move.w	d1,Y2
	move.w	Y1,BRUSH_YBASE
	move.w	Y1,CUT_YBASE
	move.w	X2,d1
	sub.w		X1,d1
	addq		#1,d1
	move.w	Y2,d2
	sub.w		Y1,d2
	addq		#1,d2
	bsr		Resize_brush
	tst.l		d0
	bmi		.err
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,TAB_SCR
	move.w	X2,d1
	sub.w		X1,d1
	addq		#1,d1
	move.w	d1,File_Width
	move.w	d1,CUT_XSIZE
	move.w	Y2,d2
	sub.w		Y1,d2
	addq		#1,d2
	move.w	d2,File_Height
	move.w	d2,CUT_YSIZE
	tst.b		TRUE_FLAG
	bne		CUT_BRUSH_TRUE
	move.w	d1,d6
	add.w		#15,d6
	lsr.w		#4,d6
	subq		#1,d6
	move.w	d6,a4
	bsr		Find_brush
	move.l	a0,a2
	move.w	File_Width,(a2)+
	move.w	File_Height,(a2)+
	movem.l	a0-a1/a3-a6/d0-d7,-(sp)
	move.w	#256-1,d0
	lea		COLOURS,a0
.clp	addq.l	#1,a0
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	dbra		d0,.clp
	movem.l	(sp)+,a0-a1/a3-a6/d0-d7
	move.w	Y1,d2
	mulu		logwid,d2
	move.l	TAB_SCR,a0
	add.l		d2,a0
	moveq		#-16,d1
	and.w		X1,d1
	add.w		d1,a0
	moveq		#16-1,d5
	and.w		X1,d5
	moveq		#16-1,d1
	and.w		File_Width,d1
	moveq		#-1,d0
	lsr.w		d1,d0
	not.w		d0
	bne.s		.go
	not.w		d0
.go	move.w	File_Height,d7
	subq		#1,d7
	move.l	a0,a1
.ylp	move.l	a1,a0
	move.w	a4,d6
.xlp	addq		#2,a2
	move.w	(a0)+,d1
	swap		d1
	move.w	16-2(a0),d1
	lsl.l		d5,d1
	swap		d1
	move.w	(a0)+,d2
	swap		d2
	move.w	16-2(a0),d2
	lsl.l		d5,d2
	swap		d2
	move.w	(a0)+,d3
	swap		d3
	move.w	16-2(a0),d3
	lsl.l		d5,d3
	swap		d3
	move.w	(a0)+,d4
	swap		d4
	move.w	16-2(a0),d4
	lsl.l		d5,d4
	swap		d4
	tst.w		d6
	bne.s		.n1
	and.w		d0,d1
	and.w		d0,d2
	and.w		d0,d3
	and.w		d0,d4
.n1	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)+
	move.w	(a0)+,d1
	swap		d1
	move.w	16-2(a0),d1
	lsl.l		d5,d1
	swap		d1
	move.w	(a0)+,d2
	swap		d2
	move.w	16-2(a0),d2
	lsl.l		d5,d2
	swap		d2
	move.w	(a0)+,d3
	swap		d3
	move.w	16-2(a0),d3
	lsl.l		d5,d3
	swap		d3
	move.w	(a0)+,d4
	swap		d4
	move.w	16-2(a0),d4
	lsl.l		d5,d4
	swap		d4
	tst.w		d6
	bne.s		.n2
	and.w		d0,d1
	and.w		d0,d2
	and.w		d0,d3
	and.w		d0,d4
.n2	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)+
	dbra		d6,.xlp
	add.w		logwid,a1
	dbra		d7,.ylp
.done	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts

CUT_BRUSH_TRUE:
	subq		#1,d1
	move.w	d1,a4
	bsr.s		Find_brush
	move.l	a0,a2
	move.w	File_Width,(a2)+
	move.w	File_Height,(a2)+
	move.w	Y1,d2
	mulu		logwid,d2
	move.l	TAB_SCR,a0
	add.l		d2,a0
	move.w	X1,d1
	add.w		d1,d1
	add.w		d1,a0
.go	move.w	File_Height,d7
	subq		#1,d7
	move.l	a0,a1
.ylp	move.l	a1,a0
	move.w	a4,d6
.xlp	move.w	(a0)+,(a2)+
	dbra		d6,.xlp
	add.w		logwid,a1
	dbra		d7,.ylp
.done	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts
	
Find_brush:
	move.w	BRUSH_HANDLE,d0
	jsr		Find_block
	rts

Resize_brush:
;	d1		width in pixels
;	d2		height in pixels
	st		done
	addq.b	#1,HOLD_VBLANK
	pushall
	add.l		d1,d1
	tst.b		TRUE_FLAG
	bne.s		.true
	lsr.l		d1
	add.w		#15,d1
	lsr.w		#4,d1
	mulu		#18,d1
.true	mulu		d2,d1
	addq.l	#4,d1
	tst.b		TRUE_FLAG
	bne.s		.tru2
	add.l		#768,d1
.tru2	movem.l	d1-a6,-(sp)
	move.w	BRUSH_HANDLE,d0
	jsr		Remove_block
	movem.l	(sp)+,d1-a6
	move.l	d1,d0
	jsr		Add_fast
	tst.l		d0
	bpl.s		.work
	move.l	#256,d0
	jsr		Add_fast
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	move.w	#1,(a0)+
	sf		done
.work	move.w	d0,BRUSH_HANDLE
	lea		BRUSH_HANDLES,a0
	move.w	BRUSH_SELECTED,d1
	mulu		#3,d1
	move.w	d0,(a0,d1.l*2)
	move.w	BRUSH_1_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),BRUSH_1_SIZE
	move.w	BRUSH_2_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),BRUSH_2_SIZE
	move.w	BRUSH_3_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),BRUSH_3_SIZE
	move.w	BRUSH_4_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),BRUSH_4_SIZE
	popall
	moveq		#0,d0
	tst.b		done
	bne.s		.ok
	moveq		#-1,d0
.ok	subq.b	#1,HOLD_VBLANK
	rts
		
MAKE_BLOCKMASK:
	tst.b		TRUE_FLAG
	bne.s		.rts
	bsr		Find_brush
	move.w	(a0)+,d6
	move.w	(a0)+,d7
	lea		768(a0),a0
	subq		#1,d7
	bmi.s		.rts
	move.w	d6,d5
	and.w		#$F,d5
	add.w		#15,d6
	and.w		#-16,d6
	lsr.w		#4,d6
	subq		#1,d6
	bmi.s		.rts
	move.w	PASTE_BITS,d0
	and.w		#1<<Bit_PASTE_XRAY,d0
	bne.s		xray
	bra.s		blok
.rts	rts

blok:	moveq		#-1,d0
	lsr.w		d5,d0
	cmp.w		#-1,d0
	bne.s		.cnt
	clr.w		d0	
.cnt	move.w	d6,a4
.ylp	move.w	a4,d6
.xlp	tst.w		d6
	beq.s		.end
	move.w	#0,(a0)
	bra.s		.nend
.end	move.w	d0,(a0)
.nend	lea		2*9(a0),a0
	dbra		d6,.xlp
	dbra		d7,.ylp
.rts	rts

xray:	move.w	d6,a4
.ylp	move.w	a4,d6
.xlp	move.w	2(a0),d1
	or.w		4(a0),d1
	or.w		6(a0),d1
	or.w		8(a0),d1
	or.w		10(a0),d1
	or.w		12(a0),d1
	or.w		14(a0),d1
	or.w		16(a0),d1
	not.w		d1
	move.w	d1,(a0)
	lea		2*9(a0),a0
	dbra		d6,.xlp
	dbra		d7,.ylp
	rts

Cell_autocut:
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	jsr		Keep_undo
	bsr		INIT_PENCIL
	seticon	I_Cell_autocut,station_cell
	jsr		Redraw_menu_icons
	move.w	CANVAS_WIDTH,tab_width
	move.w	CANVAS_HEIGHT,tab_height
	move.w	LOG_HANDLE,TAB_HANDLE
	sf		first_edit_cycle
	jsr		tab_screen
	move.w	X1,d1
	move.w	Y1,d2
	move.w	X2,d3
	move.w	Y2,d4
	jsr		DRAW_LOG_OUTLINE
	bsr		Superscaler
.exit	jsr		COPY_UNDO_2_LOG
	bsr		Superscaler
	reseticon
	jsr		Redraw_menu_icons
	bsr		Superscaler
	bsr		MOUSE_WAITMODE
	jsr		Reset_tool
.rts	rts

tab_screen:
	push.w	CANVAS_WIDTH
	push.w	CANVAS_HEIGHT
	push.w	logwid
	push.l	CANVAS_SIZE
	move.w	tab_width,d0
	move.w	d0,CANVAS_WIDTH
	tst.b		TRUE_FLAG
	beq.s		.ntc
	add.w		d0,d0
.ntc	move.w	d0,logwid
	move.w	tab_height,d1
	move.w	d1,CANVAS_HEIGHT
	mulu		d1,d0
	move.l	d0,CANVAS_SIZE
	move.w	#0,X1
	move.w	#0,Y1
	move.w	CANVAS_WIDTH,X2
	move.w	CANVAS_HEIGHT,Y2
	subq		#1,X2
	subq		#1,Y2
	tst.b		first_edit_cycle
	bne.s		.one
	move.w	#0,X2
	move.w	#0,Y2
	bsr		clip_area
.one	bsr		CUT_BRUSH
	tst.l		d0
	bmi.s		.err
	bsr		MAKE_BLOCKMASK
	moveq		#0,d0
.err	pop.l		CANVAS_SIZE
	pop.w		logwid
	pop.w		CANVAS_HEIGHT
	pop.w		CANVAS_WIDTH
	rts

tab_xlimit:	ds.w	1
tab_ylimit:	ds.w	1

clip_area:
	move.w	TAB_HANDLE,d0
	jsr		Find_block
	move.l	a0,TAB_SCR
	tst.b		TRUE_FLAG
	bne		clip_true

clip_bpl:
	move.l	TAB_SCR,a0
	moveq		#0,d7
.ylp1	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp1	move.w	(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	or.w		(a0)+,d0
	bne.s		.gtop
	dbra		d6,.xlp1
	addq		#1,d7
	cmp.w		CANVAS_HEIGHT,d7
	bne.s		.ylp1
	bra		.exit
.gtop	move.w	d7,Y1
	move.l	TAB_SCR,a0
	add.l		CANVAS_SIZE,a0
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp2	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp2	move.w	-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	or.w		-(a0),d0
	bne.s		.gbot
	dbra		d6,.xlp2
	dbra		d7,.ylp2
	bra		.exit
.gbot	move.w	d7,Y2
	move.l	TAB_SCR,a0
	moveq		#0,d6
.xlp3	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
	move.l	a0,a1
	moveq		#0,d0
.ylp3	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	lea		-16(a1),a1
	add.w		logwid,a1
	dbra		d7,.ylp3
	tst.w		d0
	bne.s		.glft
	lea		16(a0),a0
	addq		#1,d6
	move.w	CANVAS_WIDTH,d1
	lsr.w		#4,d1
	cmp.w		d1,d6
	bne.s		.xlp3
	bra		.exit
.glft	lsl.w		#4,d6
.fine	lsl.w		d0
	bcs.s		.ok
	addq		#1,d6
	bra.s		.fine
.ok	move.w	d6,X1
	move.l	TAB_SCR,a0
	add.w		logwid,a0
	lea		-16(a0),a0
	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp4	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
	move.l	a0,a1
	moveq		#0,d0
.ylp4	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	or.w		(a1)+,d0
	lea		-16(a1),a1
	add.w		logwid,a1
	dbra		d7,.ylp4
	tst.w		d0
	bne.s		.grgt
	lea		-16(a0),a0
	dbra		d6,.xlp4
	bra.s		.exit
.grgt	addq		#1,d6
	lsl.w		#4,d6
.fin2	lsr.w		d0
	bcs.s		.rok
	subq		#1,d6
	bra.s		.fin2
.rok	subq		#1,d6
	move.w	d6,X2
.exit	rts

clip_true:
	move.w	BG_COLOUR,d5
	move.l	TAB_SCR,a0
	moveq		#0,d7
.ylp1	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
.xlp1	cmp.w		(a0)+,d5
	bne.s		.gtop
	dbra		d6,.xlp1
	addq		#1,d7
	cmp.w		CANVAS_HEIGHT,d7
	bne.s		.ylp1
	bra		.exit
.gtop	move.w	d7,Y1
	move.l	TAB_SCR,a0
	add.l		CANVAS_SIZE,a0
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp2	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
.xlp2	cmp.w		-(a0),d5
	bne.s		.gbot
	dbra		d6,.xlp2
	dbra		d7,.ylp2
	bra		.exit
.gbot	move.w	d7,Y2
	move.l	TAB_SCR,a0
	moveq		#0,d6
.xlp3	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
	move.l	a0,a1
.ylp3	cmp.w		(a1),d5
	bne		.glft
	add.w		logwid,a1
	dbra		d7,.ylp3
	addq.l	#2,a0
	addq		#1,d6
	move.w	CANVAS_WIDTH,d1
	cmp.w		d1,d6
	bne.s		.xlp3
	bra		.exit
.glft	move.w	d6,X1
	move.l	TAB_SCR,a0
	add.w		logwid,a0
	subq.l	#2,a0
	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
	move.w	d6,d0
.xlp4	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
	move.l	a0,a1
.ylp4	cmp.w		(a1),d5
	bne		.grgt
	add.w		logwid,a1
	dbra		d7,.ylp4
	subq		#1,d0
	subq.l	#2,a0	
	dbra		d6,.xlp4
	bra.s		.exit
.grgt	move.w	d0,X2
.exit	rts

Get_blockzone:
	bsr		Find_brush
	move.w	X1,d1
	move.w	Y1,d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		(a0)+,d3
	add.w		(a0)+,d4
	bsr		Clip_LOG_X1Y1
	bsr		Clip_LOG_X2Y2
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	rts

Get_scalezone:
	bsr		Find_brush
	move.w	X1,d1
	move.w	Y1,d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		NEW_WIDTH,d3
	add.w		NEW_HEIGHT,d4
	bsr		Clip_LOG_X1Y1
	bsr		Clip_LOG_X2Y2
	move.w	d1,X1
	move.w	d2,Y1
	move.w	d3,X2
	move.w	d4,Y2
	rts

Cell_paste:
	moveq		#I_Cell_paste,d0
	moveq		#station_cell,d1
	lea		WIN_Cell_paste,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.n1
	jmp		Tool_dialog_box
.n1	init_tool
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	bsr		Check_menu
.skip	jsr		Keep_undo
	bsr		Init_brush_coords
	clr.w		brush_deviance
*-----------------------------------*
.prnt	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
*-----------------------------------*
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.stop
	jsr		COPYBACK
	bsr		INIT_PENCIL
	move.l	X1,X_STORE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.cont
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.cont	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	move.w	BRUSH_XBASE,X1
	move.w	BRUSH_YBASE,Y1
	bsr		Get_blockzone
	jsr		COPYBACK
	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_brush_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
.stop	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_LOG_SPRITE
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		Reset_tool
.exit	rts

Cell_under:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	move.w	#station_cell,THIS_STATION
	init_tool
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	bsr		Check_menu
.skip	jsr		Keep_undo
	bsr		Init_brush_coords
	clr.w		brush_deviance
	push.w	PASTE_BITS
	move.w	#1<<Bit_PASTE_SOLI,PASTE_BITS
*-----------------------------------*
.prnt	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		PRINT_DRAGBRUSH
	bsr		MASKBACK
	bsr		PRINT_DB_OUTLINE
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
*-----------------------------------*
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.stop
	jsr		COPYBACK
	bsr		INIT_PENCIL
	move.l	X1,X_STORE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.cont
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.cont	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	move.w	BRUSH_XBASE,X1
	move.w	BRUSH_YBASE,Y1
	bsr		Get_blockzone
	jsr		COPYBACK
	bsr		PRINT_DRAGBRUSH
	bsr		MASKBACK
	bsr		PRINT_DB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_brush_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
.stop	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_LOG_SPRITE
	bsr		MASKBACK
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		Reset_tool
	pop.w		PASTE_BITS	
.exit	rts

dump_screen:
	tst.b		first_edit_cycle
	beq		.cont
	clr.b		first_edit_cycle
	jsr		display_new_colours
	st		FREEZE_ICONS
	clr.b		GOT_PRESS
	clr.b		BUTTONS
	clr.b		ICON_BUTTON
	clr.w		ICON
	jsr		SHOW_MOUSE
	clr.b		BUTTONS
	st		MENUPAL_CHANGED
	jsr		Redraw_menu_icons
	jsr		Superscaler
.back	jsr		position_block
.wb	tst.b		BUTTONS
	bne.s		.wb
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.back
	clr.b		GOT_PRESS
	clr.b		BUTTONS
	clr.b		ICON_BUTTON
	clr.w		ICON
	jsr		HIDE_MOUSE
	sf		FREEZE_ICONS
	move.w	BRUSH_XBASE,d0
	sub.w		CUT_XBASE,d0
	move.w	d0,XDELTA
	move.w	BRUSH_YBASE,d0
	sub.w		CUT_YBASE,d0
	move.w	d0,YDELTA
.cont	move.w	CUT_XBASE,d0
	add.w		XDELTA,d0
	move.w	d0,BRUSH_XBASE
	move.w	CUT_YBASE,d0
	add.w		YDELTA,d0
	move.w	d0,BRUSH_YBASE
.go	jsr		Find_brush
	move.w	(a0)+,d0
	add.w		(a0)+,d0
	cmp.w		#2,d0
	beq		.rts
	clr.w		brush_deviance
	jsr		Keep_undo
	bsr		PRINT_DRAGBRUSH
	tst.b		dump_under
	beq.s		.ok1
	bsr		MASKBACK
.ok1	bsr		PRINT_DB_OUTLINE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_LOG_SPRITE
	tst.b		dump_under
	beq.s		.rts
	bsr		MASKBACK
.rts	rts

XDELTA:		ds.w	1
YDELTA:		ds.w	1
first_edit_cycle:	ds.b	1
			even

position_block:
	tst.b		MENU_UP
	bne.s		.skip
	not.b		MENU_UP
	bsr		Check_menu
.skip	jsr		Keep_undo
	bsr		Init_brush_coords
	clr.w		brush_deviance
*-----------------------------------*
.prnt	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
*-----------------------------------*
.wait	bsr		WAIT_MOUSE
	jsr		COPYBACK
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	bsr		INIT_PENCIL
	move.l	X1,X_STORE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.cont
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.cont	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	move.w	BRUSH_XBASE,X1
	move.w	BRUSH_YBASE,Y1
	bsr		Get_blockzone
	jsr		COPYBACK
	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_brush_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	jsr		COPYBACK
	bsr		Superscale_zone
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	bsr		MOUSE_WAITMODE
.exit	rts

Cell_move:
	moveq		#I_Cell_move,d0
	moveq		#station_cell,d1
	lea		WIN_Cell_move,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.skip
	jmp		Tool_dialog_box
.skip	init_tool
	jsr		position_block
	jsr		Reset_tool
	rts

Cell_invert:
	cmp.b		#right_button,ICON_BUTTON
	beq		.err
	move.w	#station_cell,THIS_STATION
	init_tool
	tst.b		MENU_UP
	bne.s		.up
	not.b		MENU_UP
	bsr		Check_menu
.up	jsr		Keep_undo
	bsr		Init_brush_coords
	clr.w		brush_deviance
*-----------------------------------*
.prnt	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
*-----------------------------------*
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		COPYBACK
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	cmp.w		X1,d1
	blt.s		.xflp
	cmp.w		X2,d1
	bge.s		.xflp
	cmp.w		Y1,d2
	blt.s		.yflp
	cmp.w		Y2,d2
	blt.s		.drag
.yflp	bsr		FLIP_BLOCK_Y
	bra.s		.wb
.xflp	bsr		FLIP_BLOCK_X
.wb	tst.b		BUTTONS
	bne.s		.wb
	bra		.prnt
*-----------------------------------*
.drag	bsr		INIT_PENCIL
	move.l	X1,X_STORE
	move.l	BRUSH_XBASE,X1
	bsr		Get_blockzone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	clr.w		brush_deviance
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.done
.cont	move.w	d3,d1
	move.w	d4,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.con2
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.con2	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	move.w	BRUSH_XBASE,X1
	move.w	BRUSH_YBASE,Y1
	bsr		Get_blockzone
	jsr		COPYBACK
	bsr		PRINT_DRAGBRUSH
	bsr		PRINT_DB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_brush_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
	bra		.wait
*-----------------------------------*
.exit	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_LOG_SPRITE
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		Reset_tool
.err	rts

Cell_rescale:
	cmp.b		#right_button,ICON_BUTTON
	beq		.err
	move.w	#station_cell,THIS_STATION
	init_tool
	tst.b		MENU_UP
	bne.s		.up
	not.b		MENU_UP
	bsr		Check_menu
.up	jsr		Keep_undo
	clr.w		brush_deviance
	jsr		INIT_SCALED_BLOCK
	tst.l		d0
	bmi		.exi2	
	move.w	NEW_HEIGHT,OLD_HEIGHT
	move.w	NEW_WIDTH,OLD_WIDTH
	bsr		Init_scale_coords
*-----------------------------------*
.prnt	bsr		PRINT_SCALEBRUSH
	bsr		PRINT_SB_OUTLINE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
*-----------------------------------*
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		COPYBACK
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	cmp.w		X2,d1
	bge.s		.rflp
	cmp.w		Y2,d2
	blt.s		.drag
.bflp	bsr		vscale_hi
	bra		.prnt
.rflp	bsr		hscale_hi
	bra		.prnt
*-----------------------------------*
.drag	bsr		MOUSE_DRAWMODE
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	move.w	d1,OM_X
	move.w	d2,OM_Y
	bsr		Scale_D1D2
	move.w	d1,X_STORE
	move.w	d2,Y_STORE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	clr.w		brush_deviance
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.done
.cont	move.w	d3,d1
	move.w	d4,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.con2
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.con2	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	jsr		COPYBACK
	bsr		PRINT_SCALEBRUSH
	bsr		PRINT_SB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_scale_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
	bra		.wait
*-----------------------------------*
.exit	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_SCALED_BLOCK
	bsr		HIDE_MOUSE
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		MRELEASE
.exi2	jsr		Reset_tool
.err	rts

hscale_hi:
	cmp.w		Y2,d2
	bge		hvscale_hi
	bsr		HIDE_MOUSE
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d1
	bsr		Scale_D1D2
	sub.w		BRUSH_XBASE,d1
	bgt.s		.nz
	moveq		#1,d1
.nz	move.w	d1,NEW_WIDTH
	bsr		scale
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		SHOW_MOUSE
	rts

vscale_hi:
	bsr		HIDE_MOUSE
.loop	jsr		Do_extra_macros
	move.w	MOUSE_Y,d2
	bsr		Scale_D1D2
	sub.w		BRUSH_YBASE,d2
	bgt.s		.nz
	moveq		#1,d2
.nz	move.w	d2,NEW_HEIGHT
	bsr		scale
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		SHOW_MOUSE
	rts

hvscale_hi:
	bsr		HIDE_MOUSE
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	bsr		Scale_D1D2
	push.w	d1
	push.w	d2
	bsr		Find_brush
	move.w	(a0)+,TMP_WIDTH
	move.w	(a0)+,TMP_HEIGHT
	pop.w		d2
	pop.w		d1
	move.w	d1,d3
	move.w	d2,d4
	sub.w		BRUSH_XBASE,d3
	sub.w		BRUSH_YBASE,d4
	sub.w		TMP_WIDTH,d3		
	sub.w		TMP_HEIGHT,d4
	muls		TMP_HEIGHT,d3
	muls		TMP_WIDTH,d4
	sub.w		BRUSH_XBASE,d1
	bgt.s		.nz1
	moveq		#1,d1
.nz1	sub.w		BRUSH_YBASE,d2
	bgt.s		.nz2
	moveq		#1,d2
.nz2	cmp.l		d3,d4
	bge.s		.d2
	move.w	d1,NEW_WIDTH
	move.w	OLD_WIDTH,d3
	ext.l		d3
	swap		d1
	clr.w		d1
	divs.l	d3,d1
	move.w	OLD_HEIGHT,d2
	ext.l		d2
	muls.l	d2,d1
	swap		d1
	move.w	d1,NEW_HEIGHT
	bne.s		.d1
	move.w	#1,NEW_HEIGHT
	bra.s		.d1
.d2	move.w	d2,NEW_HEIGHT
	move.w	OLD_HEIGHT,d3
	ext.l		d3
	swap		d2
	clr.w		d2
	divs.l	d3,d2
	move.w	OLD_WIDTH,d1
	ext.l		d1
	muls.l	d1,d2
	swap		d2
	move.w	d2,NEW_WIDTH
	bne.s		.d1
	move.w	#1,NEW_WIDTH
.d1	bsr		scale
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		SHOW_MOUSE
	rts

scale:
	jsr		COPYBACK
	bsr		PRINT_SCALEBRUSH
	bsr		PRINT_SB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_scale_coords
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	rts

FLIP_BLOCK_Y:
	bsr		Find_brush
	move.w	(a0)+,d6
	move.w	(a0)+,d7
	subq		#1,d7
	ble.s		.rts
	tst.b		TRUE_FLAG
	bne.s		.true
	lea		768(a0),a0
	add.w		#15,d6
	lsr.w		#4,d6
	move.w	d6,d0
	mulu		#18,d0
	move.l	d0,d1
	mulu		d7,d0
	mulu		#9,d6
	bra.s		.cont
.true	move.w	d6,d0
	add.w		d0,d0
	move.w	d0,d1
	ext.l		d1
	mulu		d7,d0
.cont	addq		#1,d7
	lsr.w		d7
	subq		#1,d7
	bmi.s		.rts
	lea		(a0,d0.l),a1	; last line
	subq		#1,d6
.ylp	move.l	a0,a2
	move.l	a1,a3
	move.w	d6,d5
.xlp	move.w	(a2),d4
	move.w	(a3),(a2)+
	move.w	d4,(a3)+
	dbra		d5,.xlp
	add.l		d1,a0
	sub.l		d1,a1
	dbra		d7,.ylp
.rts	rts

FLIP_BLOCK_X:
	bsr		Find_brush
	move.w	(a0)+,d6
	move.w	(a0)+,d7
	subq		#1,d7
	bmi		.rts
	tst.b		TRUE_FLAG
	bne		.true
.bpl	lea		768(a0),a5
	subq		#1,d6
	ble		.rts
	move.w	d6,a4
	addq		#1,d6
	move.w	d6,d4
	lsr.w		d4
	subq		#1,d4
	bmi		.rts
	add.w		#15,d6
	lsr.w		#4,d6
	move.w	d6,d3
	mulu		#18,d3
.ylp	move.l	a5,a0
	lea		-18(a5,d3.l),a1
	push.l	d3
	push.w	d4
	moveq		#16-1,d6
	move.w	a4,d5
	and.w		#16-1,d5
	neg.w		d5
	add.w		#16-1,d5
.xlp	move.l	a0,a2
	move.l	a1,a3
	moveq		#9-1,d3
.plan	move.w	(a3),d1
	move.w	(a2),d0
	move.w	d0,d2
	bclr		d6,d0
	btst		d5,d1
	beq.s		.n1
	bset		d6,d0
.n1	move.w	d0,(a2)+
	move.w	(a3),d1
	bclr		d5,d1
	btst		d6,d2
	beq.s		.n2
	bset		d5,d1
.n2	move.w	d1,(a3)+
	dbra		d3,.plan
	subq		#1,d6
	bpl.s		.nis
	moveq		#16-1,d6
	lea		18(a0),a0
.nis	addq		#1,d5
	and.w		#16-1,d5
	bne.s		.nid
	lea		-18(a1),a1
.nid	dbra		d4,.xlp
	pop.w		d4
	pop.l		d3
	add.l		d3,a5
	dbra		d7,.ylp
	bra.s		.rts
.true	move.w	d6,d0
	add.w		d0,d0
	move.w	d0,d1
	ext.l		d1
	addq		#1,d6
	lsr.w		d6
	subq		#1,d6
	bmi.s		.rts
.ylp2	move.l	a0,a2
	lea		(a0,d1.l),a3
	move.w	d6,d5
.xlp2	move.w	(a2),d4
	move.w	-(a3),(a2)+
	move.w	d4,(a3)
	dbra		d5,.xlp2
	add.l		d1,a0
	dbra		d7,.ylp2
.rts	rts

FIRST_LOOP:	ds.b	1
		even

Cell_rotate:
	cmp.b		#right_button,ICON_BUTTON
	beq		.err
	move.w	#station_cell,THIS_STATION
	init_tool
	tst.b		MENU_UP
	bne.s		.up
	not.b		MENU_UP
	bsr		Check_menu
.up	jsr		Keep_undo
	jsr		INIT_SCALED_BLOCK
	tst.l		d0
	bmi		.exi2	
	clr.w		X_ANGLE
	clr.w		Y_ANGLE
	clr.w		Z_ANGLE
	move.l	#PRINT_ROTBRUSH,PRIMITIVE
	bsr		Init_rotate_coords
	move.w	#3,brush_deviance
*-----------------------------------*
.prnt	bsr		PRINT_ROTBRUSH
	bsr		PRINT_RB_OUTLINE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
*-----------------------------------*
	jsr		HIDE_MOUSE
	jsr		mouse_short
	jsr		SHOW_MOUSE
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		HIDE_MOUSE
	jsr		mouse_short
	jsr		SHOW_MOUSE
*-----------------------------------*
	jsr		COPYBACK
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	cmp.w		BX1,d1
	blt.s		.lflp
	cmp.w		BX2,d1
	bge.s		.rflp
	cmp.w		BY1,d2
	blt.s		.tflp
	cmp.w		BY2,d2
	blt.s		.drag
.bflp	bsr		xrot_hi
	bra		.prnt
.tflp	bsr		xrot_hi
	bra		.prnt
.lflp	bsr		yrot_hi
	bra		.prnt
.rflp	bsr		yrot_hi
	bra		.prnt
*-----------------------------------*
.drag	bsr		MOUSE_DRAWMODE
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	move.w	d1,OM_X
	move.w	d2,OM_Y
	bsr		Scale_D1D2
	move.w	d1,X_STORE
	move.w	d2,Y_STORE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.done
.cont	move.w	d3,d1
	move.w	d4,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.con2
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.con2	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	jsr		COPYBACK
	bsr		PRINT_ROTBRUSH
	bsr		PRINT_RB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_rotate_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
	bra		.wait
*-----------------------------------*
.exit	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_ROTATED_BLOCK
	bsr		HIDE_MOUSE
	jsr		mouse_tall
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		MRELEASE
.exi2	jsr		Reset_tool
.err	rts

mouse_tall:
	move.w	Y_RESOLUTION,d1
	move.w	d1,d2
	divu		#5,d2
	move.w	d2,d3
	lsr.w		#2,d3
	sub.w		d3,d2
	add.w		d2,d1
	subq		#1,d1
	move.w	d1,MOUSE_YC
	rts

mouse_short:
	move.w	Y_RESOLUTION,d1
	subq		#1,d1
	move.w	d1,MOUSE_YC
	rts

Cell_distort:
	cmp.b		#right_button,ICON_BUTTON
	beq		.err
	move.w	#station_cell,THIS_STATION
	init_tool
	tst.b		MENU_UP
	bne.s		.up
	not.b		MENU_UP
	bsr		Check_menu
.up	jsr		Keep_undo
	jsr		INIT_SCALED_BLOCK
	tst.l		d0
	bmi		.exi2	
	clr.w		X_ANGLE
	clr.w		Y_ANGLE
	clr.w		Z_ANGLE
	move.l	#PRINT_PERBRUSH,PRIMITIVE
	bsr		Init_rotate_coords
	move.w	#3,brush_deviance
*-----------------------------------*
.prnt	bsr		PRINT_PERBRUSH
	bsr		PRINT_RB_OUTLINE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
*-----------------------------------*
	jsr		HIDE_MOUSE
	jsr		mouse_short
	jsr		SHOW_MOUSE
.wait	bsr		WAIT_MOUSE
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	jsr		HIDE_MOUSE
	jsr		mouse_short
	jsr		SHOW_MOUSE
	jsr		COPYBACK
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	cmp.w		BX1,d1
	blt.s		.lflp
	cmp.w		BX2,d1
	bge.s		.rflp
	cmp.w		BY1,d2
	blt.s		.tflp
	cmp.w		BY2,d2
	blt.s		.drag
.bflp	bsr		xrot_hi
	bra		.prnt
.tflp	bsr		xrot_hi
	bra		.prnt
.lflp	bsr		yrot_hi
	bra		.prnt
.rflp	bsr		yrot_hi
	bra		.prnt
*-----------------------------------*
.drag	bsr		MOUSE_DRAWMODE
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	move.w	d1,OM_X
	move.w	d2,OM_Y
	bsr		Scale_D1D2
	move.w	d1,X_STORE
	move.w	d2,Y_STORE
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	st		FIRST_LOOP
*-----------------------------------*
.loop	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.cont
	cmp.w		d1,d3
	bne.s		.cont
	cmp.w		d2,d4
	beq.s		.done
.cont	move.w	d3,d1
	move.w	d4,d2
	bsr		Scale_D1D2
	move.w	d1,d3
	move.w	d2,d4
	sub.w		X_STORE,d1
	sub.w		Y_STORE,d2
	tst.b		FIRST_LOOP
	bne.s		.con2
	move.w	d2,d5
	or.w		d1,d5
	beq.s		.done
.con2	clr.b		FIRST_LOOP
	move.w	d3,X_STORE
	move.w	d4,Y_STORE
	add.w		d1,BRUSH_XBASE
	add.w		d2,BRUSH_YBASE
	jsr		COPYBACK
	bsr		PRINT_PERBRUSH
	bsr		PRINT_RB_OUTLINE
	bsr		Superscale_zone
	bsr		Print_rotate_coords
.done	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.loop
	bsr		MOUSE_WAITMODE
	bra		.wait
*-----------------------------------*
.exit	jsr		COPYBACK
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_PERSPECTED_BLOCK
	bsr		HIDE_MOUSE
	jsr		mouse_tall
	bsr		Superscale_zone
	bsr		SHOW_MOUSE
	clr.w		brush_deviance
	bsr		Refresh_info_bar
	st		BITMAP_CHANGED
	jsr		MRELEASE
.exi2	jsr		Reset_tool
.err	rts

ANGLE_PTR:	ds.l	1

xrot_hi:
	move.l	#X_ANGLE,ANGLE_PTR
	bra		rotate
yrot_hi:
	cmp.w		BY2,d2
	bge		zrot_hi
	move.l	#Y_ANGLE,ANGLE_PTR
	bra		rotate
zrot_hi:
	move.l	#Z_ANGLE,ANGLE_PTR

rotate:
	bsr		MOUSE_DRAWMODE
	lea		HANDLE_LIST,a0
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	BX1,d1
	add.w		BX2,d1
	lsr.w		d1
	move.w	BY1,d2
	add.w		BY2,d2
	lsr.w		d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	#2,HANDLE_COUNT
	lea		HANDLE_LIST,a0
	push.l	X1
	push.l	X2
	move.w	(a0)+,X1
	move.w	(a0)+,Y1
	move.w	(a0)+,X2
	move.w	(a0)+,Y2
	jsr		Get_angle
	pop.l		X2
	pop.l		X1
	move.w	d0,INITIAL_ANGLE
	jsr		FIND_HANDLE
	tst.l		HANDLE_PTR
	beq		.stop
.drag	jsr		Do_extra_macros
	move.w	MOUSE_X,d3
	move.w	MOUSE_Y,d4
	move.w	OM_X,d1
	move.w	OM_Y,d2
	move.w	d3,OM_X
	move.w	d4,OM_Y
	tst.b		WAIT_FUNCTION
	beq.s		.con2
	cmp.w		d1,d3
	bne.s		.con2
	cmp.w		d2,d4
	beq		.ski2
.con2	bsr		Scale_D3D4
	move.l	HANDLE_PTR,a0
	move.w	d3,(a0)+
	move.w	d4,(a0)+
	jsr		COPYBACK
	lea		HANDLE_LIST,a0
	push.l	X1
	push.l	X2
	move.w	(a0)+,X1
	move.w	(a0)+,Y1
	move.w	(a0)+,X2
	move.w	(a0)+,Y2
	jsr		Get_angle
	pop.l		X2
	pop.l		X1
	move.w	d0,d1
	sub.w		INITIAL_ANGLE,d0
	move.w	d1,INITIAL_ANGLE
	sub.w		d0,([ANGLE_PTR.l])
	jsr		([PRIMITIVE.l])
	bsr		PRINT_RB_OUTLINE
	lea		HANDLE_LIST,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	jsr		DRAW_LOG_LINE
	jsr		Draw_handles
	bsr		Superscale_zone
	bsr		Print_rotate_coords
.ski2	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	cmp.b		#left_button,BUTTONS
	beq		.drag
.stop	jsr		COPYBACK
.err	bsr		MOUSE_WAITMODE
	rts

Print_brush_coords:
	move.w	#6*2,d1
	move.w	#222,d2
	move.w	#6*2+6*6-1,d3
	move.w	#222+6*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*10,d1
	move.w	#222,d2
	move.w	#6*10+6*6-1,d3
	move.w	#222+6*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*19,d1
	move.w	#222,d2
	move.w	#6*19+6*6-1,d3
	move.w	#222+6*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*28,d1
	move.w	#222,d2
	move.w	#6*28+6*6-1,d3
	move.w	#222+6*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*2,CHAR_X
	move.w	#222,CHAR_Y
	move.w	BRUSH_XBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*10,CHAR_X
	move.w	BRUSH_YBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*19,CHAR_X
	move.w	#222,CHAR_Y
	move.w	BRUSH_XBASE,d0
	sub.w		OLD_BRUSH_XBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*28,CHAR_X
	move.w	BRUSH_YBASE,d0
	sub.w		OLD_BRUSH_YBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	rts

Print_cut_coords:
	move.w	#6*3,d1
	move.w	#222,d2
	move.w	#6*3+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*12,d1
	move.w	#222,d2
	move.w	#6*12+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*20,d1
	move.w	#222,d2
	move.w	#6*20+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*28,d1
	move.w	#222,d2
	move.w	#6*28+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*3,CHAR_X
	move.w	#222,CHAR_Y
	move.w	X1,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*12,CHAR_X
	move.w	Y1,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*20,CHAR_X
	move.w	#222,CHAR_Y
	move.w	X2,d0
	sub.w		X1,d0
	bpl.s		.ok1
	neg.w		d0
.ok1	addq		#1,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*28,CHAR_X
	move.w	Y2,d0
	sub.w		Y1,d0
	bpl.s		.ok2
	neg.w		d0
.ok2	addq		#1,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	rts

Print_scale_coords:
	move.w	#6*33,d1
	move.w	#222,d2
	move.w	#6*33+6*11-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*3,d1
	move.w	#222,d2
	move.w	#6*3+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*12,d1
	move.w	#222,d2
	move.w	#6*12+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*20,d1
	move.w	#222,d2
	move.w	#6*20+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*28,d1
	move.w	#222,d2
	move.w	#6*28+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*3,CHAR_X
	move.w	#222,CHAR_Y
	move.w	BRUSH_XBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*12,CHAR_X
	move.w	BRUSH_YBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*20,CHAR_X
	move.w	#222,CHAR_Y
	move.w	NEW_WIDTH,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*28,CHAR_X
	move.w	NEW_HEIGHT,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*33,CHAR_X
	move.w	NEW_WIDTH,d0
	mulu		#3200,d0
	move.w	OLD_WIDTH,d1
	ext.l		d1
	divu.l	d1,d0
	lsr.l		#5,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	lea		PCNT1,a0
	jsr		PRINT_LINE
	move.w	NEW_HEIGHT,d0
	mulu		#3200,d0
	move.w	OLD_HEIGHT,d1
	ext.l		d1
	divu.l	d1,d0
	lsr.l		#5,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	lea		PCNT2,a0
	jsr		PRINT_LINE
	rts

Print_rotate_coords:
	move.w	#6*2,d1
	move.w	#222,d2
	move.w	#6*2+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*10,d1
	move.w	#222,d2
	move.w	#6*10+6*6-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*19,d1
	move.w	#222,d2
	move.w	#6*19+6*5-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*28,d1
	move.w	#222,d2
	move.w	#6*28+6*5-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*37,d1
	move.w	#222,d2
	move.w	#6*37+6*5-1,d3
	move.w	#222+8*1-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_BLOCK
	move.w	#6*2,CHAR_X
	move.w	#222,CHAR_Y
	move.w	BRUSH_XBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*10,CHAR_X
	move.w	BRUSH_YBASE,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	move.w	#6*19,CHAR_X
	move.w	#222,CHAR_Y
	move.w	X_ANGLE,d0
	and.w		#4096-1,d0
	muls		#360,d0
	divs		#4096,d0
	neg.w		d0
	add.w		#360,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	lea		PDEG,a0
	bsr		PRINT_LINE
	move.w	#6*28,CHAR_X
	move.w	Y_ANGLE,d0
	and.w		#4096-1,d0
	muls		#360,d0
	divs		#4096,d0
	neg.w		d0
	add.w		#360,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	lea		PDEG,a0
	bsr		PRINT_LINE
	move.w	#6*37,CHAR_X
	move.w	Z_ANGLE,d0
	and.w		#4096-1,d0
	muls		#360,d0
	divs		#4096,d0
	neg.w		d0
	add.w		#360,d0
	bsr		NUM2ASCII_SGN
	bsr		PRINT_ASCIINUM
	lea		PDEG,a0
	bsr		PRINT_LINE
	rts
	
PDEG		dc.b	"ø",0
PCNT1:	dc.b	"%,",0
PCNT2:	dc.b	"%",0
		even

Init_brush_coords:
	st		HOLD_INFOBAR
	move.w	#iface_visible,CHAR_COL
	move.w	#0,d1
	move.w	#222,d2
	move.w	#319,d3
	move.w	#222+7,d4
	moveq		#0,d0
	xresfactor	d3
	yresfactor	d2,d4
	bsr		DRAW_PHYS_BLOCK
	move.w	BRUSH_XBASE,OLD_BRUSH_XBASE
	move.w	BRUSH_YBASE,OLD_BRUSH_YBASE
	lea		BRUSH_COORD_TEXT,a0
	bsr		PRINT_LINE
	bsr		Print_brush_coords
	rts

Init_cut_coords:
	st		HOLD_INFOBAR
	move.w	#iface_visible,CHAR_COL
	move.w	#0,d1
	move.w	#222,d2
	move.w	#319,d3
	move.w	#222+7,d4
	moveq		#0,d0
	xresfactor	d3
	yresfactor	d2,d4
	bsr		DRAW_PHYS_BLOCK
	move.w	BRUSH_XBASE,OLD_BRUSH_XBASE
	move.w	BRUSH_YBASE,OLD_BRUSH_YBASE
	lea		CUT_COORD_TEXT,a0
	bsr		PRINT_LINE
	rts

Init_scale_coords:
	st		HOLD_INFOBAR
	move.w	#iface_visible,CHAR_COL
	move.w	#0,d1
	move.w	#222,d2
	move.w	#319,d3
	move.w	#222+7,d4
	moveq		#0,d0
	xresfactor	d3
	yresfactor	d2,d4
	bsr		DRAW_PHYS_BLOCK
	move.w	BRUSH_XBASE,OLD_BRUSH_XBASE
	move.w	BRUSH_YBASE,OLD_BRUSH_YBASE
	lea		CUT_COORD_TEXT,a0
	bsr		PRINT_LINE
	bsr		Print_scale_coords
	rts

Init_rotate_coords:
	st		HOLD_INFOBAR
	move.w	#iface_visible,CHAR_COL
	move.w	#0,d1
	move.w	#222,d2
	move.w	#319,d3
	move.w	#222+7,d4
	moveq		#0,d0
	xresfactor	d3
	yresfactor	d2,d4
	bsr		DRAW_PHYS_BLOCK
	move.w	BRUSH_XBASE,OLD_BRUSH_XBASE
	move.w	BRUSH_YBASE,OLD_BRUSH_YBASE
	lea		ROT_COORD_TEXT,a0
	bsr		PRINT_LINE
	bsr		Print_rotate_coords
	rts

Refresh_info_bar:
	clr.l		HELP_TEXT
	move.w	#iface_grey,CHAR_COL
	move.w	#0,d1
	move.w	#222,d2
	move.w	#319,d3
	move.w	#222+7,d4
	moveq		#0,d0
	xresfactor	d3
	yresfactor	d2,d4
	bsr		DRAW_PHYS_BLOCK
	push.b	HOLD_COORDS
	sf		HOLD_COORDS
	move.w	#-1,OLD_X_COORD
	move.w	#-1,OLD_Y_COORD
	move.l	#-1,FREE
	move.l	#-1,USED
	move.l	#-1,CURRENT
	move.l	#-1,AVERAGE
	move.b	#7,BUSY_TIME
	move.b	#-1,BUSY_STAT
	pop.b		HOLD_COORDS
	sf		HOLD_INFOBAR
	rts

PRINT_DRAGBRUSH:
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_LOG_SPRITE
	rts

PRINT_SCALEBRUSH:
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_SCALED_BLOCK
	rts

PRINT_ROTBRUSH:
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_ROTATED_BLOCK
	rts

PRINT_PERBRUSH:
	move.w	BRUSH_XBASE,d6
	move.w	BRUSH_YBASE,d7
	jsr		DRAW_PERSPECTED_BLOCK
	rts

PRINT_BACKBRUSH:
	push.l		LOG_SCR
	move.l		a0,LOG_SCR
	move.w		d1,d6
	move.w		d2,d7
	or.w		#(1<<altram_bit),LOG_HANDLE
	jsr		DRAW_LOG_SPRITE
	and.w		#~(1<<altram_bit),LOG_HANDLE
	pop.l		LOG_SCR
	rts
	
PRINT_DB_OUTLINE:
	move.w	BRUSH_XBASE,d1
	move.w	BRUSH_YBASE,d2
	bsr		Find_brush
	move.w	d1,d3
	move.w	d2,d4
	add.w		(a0)+,d3
	add.w		(a0)+,d4
	subq		#1,d3
	subq		#1,d4
	jsr		DRAW_LOG_OUTLINE
	rts	

PRINT_SB_OUTLINE:
	move.w	BRUSH_XBASE,d1
	move.w	BRUSH_YBASE,d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		NEW_WIDTH,d3
	add.w		NEW_HEIGHT,d4
	subq		#1,d3
	subq		#1,d4
	jsr		DRAW_LOG_OUTLINE
	rts	

PRINT_RB_OUTLINE:
	move.w	BX1,d1
	move.w	BY1,d2
	move.w	BX2,d3
	move.w	BY2,d4
	subq		#1,d3
	subq		#1,d4
	jsr		DRAW_LOG_OUTLINE
	rts	

MASKBACK:
	addq.b	#1,BUSY
	bsr		Get_max_window
	move.w	Copy_X1,d1
	move.w	Copy_Y1,d2
	move.w	Copy_X2,d3
	move.w	Copy_Y2,d4
	bsr		Clip_LOG_X1Y1_ABS
	bsr		Clip_LOG_X2Y2_ABS
	move.w	d1,Copy_X1
	move.w	d2,Copy_Y1
	move.w	d3,Copy_X2
	move.w	d4,Copy_Y2
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	Copy_Y1,d0
	move.l	(LOG_Y.l,d0.w*4),d0
	add.l		d0,a0
	add.l		d0,a1
	move.w	Copy_Y2,d7
	sub.w		Copy_Y1,d7
	subq		#1,d7
	bmi.s		.err
	tst.b		TRUE_FLAG
	bne		mbtrue
.vlp	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.hlp	move.w	(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	or.w		(a0)+,d1
	lea		-16(a0),a0
	not.w		d1
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	and.w		d1,(a1)+
	lea		-16(a1),a1
	move.l	(a0)+,d1
	or.l		d1,(a1)+
	move.l	(a0)+,d1
	or.l		d1,(a1)+
	move.l	(a0)+,d1
	or.l		d1,(a1)+
	move.l	(a0)+,d1
	or.l		d1,(a1)+
	dbra		d6,.hlp
	dbra		d7,.vlp
.err	subq.b	#1,BUSY
	rts

mbtrue:
	move.w	BG_COLOUR,d2
.vlp	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
.hlp	move.w	(a0)+,d1
	cmp.w		d2,d1
	beq.s		.cont
	move.w	d1,(a1)
.cont	addq.l	#2,a1
	dbra		d6,.hlp
	dbra		d7,.vlp
.err	subq.b	#1,BUSY
	rts

Cell_remap:
	moveq		#I_Cell_remap,d0
	moveq		#station_cell,d1
	lea		WIN_Tool_remap,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.okx
	jmp		Tool_dialog_box
.okx	bsr		HIDE_MOUSE
	seticon	I_Cell_remap,station_cell
	jsr		Redraw_menu_icons
	tst.b		TRUE_FLAG
	beq.s		.rb
	lea		WIN_NBP_Alert,a0
	jsr		DO_ALERT
	bra		.exit
.rb	bsr		Find_brush
	move.w	(a0)+,d0
	move.w	d0,image_width
	move.w	(a0)+,image_height
	add.w		#15,d0
	lsr.w		#4,d0
	mulu		#18,d0
	move.w	d0,scrwid
	lea		NEW_COLOURS,a1
	move.w	#256-1,d0
.copy	clr.b		(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d0,.copy
	addq.l	#2,a0
	move.l	a0,IMAGE_PTR
	cmp.w		#1<<Bit_REMAP_BLOCK,REMAP_BITS
	bne.s		.scr
.blk	lea		NEW_COLOURS,a0
	lea		COLOURS,a1
	bsr		TRANSLATE_COLOURS
	move.w	#18,wrdwid
	bsr		REMAP_BLOCK	
	bsr		MAKE_BLOCKMASK
	bsr		Find_brush
	addq.l	#4,a0
	lea		COLOURS,a1
	move.w	#256-1,d0
.cop2	addq.l	#1,a1
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbra		d0,.cop2
	bra.s		.exit
.scr	move.w	CANVAS_WIDTH,image_width
	move.w	CANVAS_HEIGHT,image_height
	move.w	logwid,scrwid
	move.l	LOG_SCR,IMAGE_PTR
	lea		COLOURS,a0
	lea		NEW_COLOURS,a1
	bsr		TRANSLATE_COLOURS
	move.w	#16,wrdwid
	bsr		REMAP_BLOCK	
	lea		NEW_COLOURS,a0
	lea		COLOURS,a1
	jsr		COPYCOLS
	st		BITMAP_CHANGED
	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	bsr		Update_palette
.exit	bsr		Superscaler
	reseticon
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts

REMAP_BLOCK:
	addq.b	#1,BUSY
	move.w	image_height,d2
	subq		#1,d2
.ylp	move.w	image_width,d1
	subq		#1,d1
.xlp	push.w	d1
	push.w	d2
	move.l	IMAGE_PTR,a0
	bsr		READ_PIXEL
	pop.w		d2
	pop.w		d1
	and.w		#$FF,d0
	lea		TRANSLATOR_TABLE,a0
	move.b	(a0,d0.w),d0
	push.w	d1
	push.w	d2
	move.l	IMAGE_PTR,a0
	bsr		WRITE_PIXEL_GEN
	pop.w		d2
	pop.w		d1
	dbra		d1,.xlp
	dbra		d2,.ylp
	subq.b	#1,BUSY
	rts	
	
IMAGE_PTR:		ds.l	1
image_width:	ds.w	1
image_height:	ds.w	1
wrdwid:		ds.w	1

Draw_exchange:
	moveq		#I_Draw_exchange,d0
	moveq		#station_draw,d1
	lea		Draw_exchange_code,a0
	lea		WIN_Draw_exchange,a1
	jsr		Check_tool_dialog
	jsr		Setup_tool
	jsr		Permanent_tool
.exit	rts
	
Draw_exchange_code:
	init_tool
	bsr		HIDE_MOUSE
	move.w	FILL_BITS,d0
	jsr		Keep_undo
	addq.b	#1,BUSY
*-----------------------------------------*
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	bsr		Scale_D1D2
	bsr		READ_LOG_PIXEL
	move.w	d0,OLD_COL
*-----------------------------------------*
	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	mulu		CANVAS_HEIGHT,d0
	lsr.l		#3,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.err
	move.l	a0,MASK_SCR
	move.l	a0,a1
	move.l	LOG_SCR,a0
	jsr		MASK_SCREEN
	move.w	FG_COLOUR,NEW_COL
	cmp.w		#1<<Bit_REPL_NRM,REPL_BITS
	beq.s		.nrm
	bsr		IMASK_WITH_LOG
	bra.s		.fin
.nrm	bsr		MASK_WITH_LOG
*-----------------------------------------*
.fin	bsr		Superscaler
	st		BITMAP_CHANGED
.err	jsr		MRELEASE
	subq.b	#1,BUSY
	bsr		SHOW_MOUSE
	rts

MASK_WITH_LOG:
	tst.b		TRUE_FLAG
	bne		.true
.bpl	move.l	MASK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	NEW_COL,d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1-d4
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp	push.w	d7
	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d1,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d2,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d3,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d4,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	dbra		d6,.xlp
	pop.w		d7
	dbra		d7,.ylp
	rts

.true	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	ext.l		d0
	move.l	MASK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	NEW_COL,d3
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp2	push.w	d7
	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
	moveq		#0,d7
.xlp2	move.w	d7,d4
	lsr.w		#3,d4
	lea		(a0,d4.w),a2
	move.w	d7,d5
	and.w		#8-1,d5
	neg.w		d5
	addq		#7,d5
	btst.b	d5,(a2)
	beq.s		.skip
	move.w	d3,(a1)	
.skip	addq.l	#2,a1
	addq		#1,d7
	dbra		d6,.xlp2
	add.l		d0,a0
	pop.w		d7
	dbra		d7,.ylp2
	rts

IMASK_WITH_LOG:
	tst.b		TRUE_FLAG
	bne		.true
.bpl	move.l	MASK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	NEW_COL,d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1-d4
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp	push.w	d7
	move.w	CANVAS_WIDTH,d6
	lsr.w		#4,d6
	subq		#1,d6
.xlp	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	(a1),d7
	and.l		d0,d7
	move.l	d1,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d2,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d3,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	move.l	(a1),d7
	not.l		d0
	and.l		d0,d7
	move.l	d4,d5
	not.l		d0
	and.l		d0,d5
	or.l		d5,d7
	move.l	d7,(a1)+	
	dbra		d6,.xlp
	pop.w		d7
	dbra		d7,.ylp
	rts

.true	move.w	CANVAS_WIDTH,d0
	add.w		#16-1,d0
	and.w		#-16,d0
	lsr.w		#3,d0
	ext.l		d0
	move.l	MASK_SCR,a0
	move.l	LOG_SCR,a1
	move.w	NEW_COL,d3
	move.w	CANVAS_HEIGHT,d7
	subq		#1,d7
.ylp2	push.w	d7
	move.w	CANVAS_WIDTH,d6
	subq		#1,d6
	moveq		#0,d7
.xlp2	move.w	d7,d4
	lsr.w		#3,d4
	lea		(a0,d4.w),a2
	move.w	d7,d5
	and.w		#8-1,d5
	neg.w		d5
	addq		#7,d5
	btst.b	d5,(a2)
	bne.s		.skip
	move.w	d3,(a1)	
.skip	addq.l	#2,a1
	addq		#1,d7
	dbra		d6,.xlp2
	add.l		d0,a0
	pop.w		d7
	dbra		d7,.ylp2
	rts

*-----*	Window functions		*-----------------------------------*


SOFTMOUSE_CHECKIN:
	tst.b		SOFTWARE_MOUSE
	beq.s		.norm
	bsr		Remove_mouseptr
	rts
.norm	bsr		HIDE_MOUSE
.rts	rts

SOFTMOUSE_CHECKOUT:
	tst.b		SOFTWARE_MOUSE
	beq.s		.norm
	bsr		Update_mouseptr
	rts
.norm	bsr		SHOW_MOUSE
.rts	rts

Special_start:
	move.w	CUR_DELTAFRAME,SEGMENT_START
	jsr		Update_tween_combo
	rts
	
Special_end:
	move.w	CUR_DELTAFRAME,SEGMENT_END
	jsr		Update_tween_combo
	rts
	
Extra_Wzoom:
	tst.b		NO_SCALE
	bne		.rts
	cmp.w		#3,Scale_factor
	beq		.rts
	move.w	Scale_factor,d2
	addq		#1,Scale_factor
	move.w	Window_X,d0
	move.w	X_RESOLUTION,d3
	lsr.w		#2,d3
	lsr.w		d2,d3
	add.w		d3,d0
	move.w	MOUSE_X,d3
	lsr.w		d2,d3
	add.w		d3,d0
	move.w	X_RESOLUTION,d3
	lsr.w		d3
	lsr.w		d2,d3
	sub.w		d3,d0
	bsr		Make_window_x
	move.w	d0,Window_X
	move.w	Window_Y,d0
	move.w	Y_RESOLUTION,d3
	lsr.w		#2,d3
	lsr.w		d2,d3
	add.w		d3,d0
	move.w	MOUSE_Y,d3
	lsr.w		d2,d3
	add.w		d3,d0
	move.w	Y_RESOLUTION,d3
	lsr.w		d3
	lsr.w		d2,d3
	sub.w		d3,d0
	move.w	d0,Window_Y
	push.w	Window_X
	push.w	Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.nupd
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.nupd	pop.w		d2
	pop.w		d1
	move.w	Scale_factor,d3
	sub.w		Window_X,d1
	sub.w		Window_Y,d2
	asl.w		d3,d2
	asl.w		d3,d1
	move.w	X_RESOLUTION,d3
	lsr.w		d3
	add.w		d3,d1
	move.w	Y_RESOLUTION,d3
	lsr.w		d3
	add.w		d3,d2
	bsr		Clip_PHYS_X1Y1
	move.w	d1,MOUSE_X
	move.w	d2,MOUSE_Y
.rts	rts

Extra_Wpan:
	tst.b		NO_SCALE
	bne.s		.rts
	tst.w		Scale_factor
	beq.s		.rts
	subq		#1,Scale_factor
	move.w	Scale_factor,d2
	move.w	Window_X,d0
	move.w	X_RESOLUTION,d3
	lsr.w		#2,d3
	lsr.w		d2,d3
	sub.w		d3,d0
	bsr		Make_window_x
	move.w	d0,Window_X
	move.w	Window_Y,d0
	move.w	Y_RESOLUTION,d3
	lsr.w		#2,d3
	lsr.w		d2,d3
	sub.w		d3,d0
	move.w	d0,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_center:
	tst.b		NO_SCALE
	bne		.rts
	move.l	MOUSE_X,TEMP_X
	move.w	TEMP_X,d1
	move.w	TEMP_Y,d2
	bsr		Scale_D1D2
	move.w	Scale_factor,d0
	addq		#1,d0
	move.w	X_RESOLUTION,d3
	move.w	Y_RESOLUTION,d4
	lsr.w		d0,d3
	lsr.w		d0,d4
	sub.w		d3,d1
	sub.w		d4,d2
	move.w	d1,d0
	bsr		Make_window_x
	push.w	Window_X
	push.w	Window_Y
	move.w	d0,Window_X
	move.w	d2,Window_Y
	bsr		Get_window_bounds
	pop.w		d2
	pop.w		d1
	sub.w		Window_X,d1
	sub.w		Window_Y,d2
	move.w	Scale_factor,d0
	lsl.w		d0,d1
	lsl.w		d0,d2
	add.w		d1,TEMP_X
	add.w		d2,TEMP_Y
	move.l	TEMP_X,MOUSE_X
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_fix:
	jsr		HIDE_MOUSE
	st		MENUPAL_CHANGED
	jsr		Remap_menu_bars
	jsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	rts

Extra_dummy:
	moveq		#I_Extra_dummy,d0
	move.w	#1000,d1
	lea		Extra_dummy_code,a0
	jsr		Setup_tool
	jsr		Permanent_tool
Extra_dummy_code:
	rts
	
TEMP_X:	ds.w	1
TEMP_Y:	ds.w	1

Get_window_bounds:
	move.w	Scale_factor,d1
	move.w	X_RESOLUTION,d0
	lsr.w		d1,d0
	neg.w		d0
	add.w		CANVAS_WIDTH,d0
	move.w	Window_X,d2
	bpl.s		.xnm
	clr.w		Window_X
	bra.s		.xok
.xnm	cmp.w		d0,d2
	ble.s		.xok
	bsr.s		Make_window_x
	move.w	d0,Window_X
.xok	move.w	Y_RESOLUTION,d0
	lsr.w		d1,d0
	neg.w		d0
	add.w		CANVAS_HEIGHT,d0
	move.w	Window_Y,d2
	bpl.s		.ynm
	clr.w		Window_Y
	bra.s		.yok
.ynm	cmp.w		d0,d2
	ble.s		.yok
	move.w	d0,Window_Y
.yok	rts

Make_window_x:
	tst.b		TRUE_FLAG
	bne.s		.no
	cmp.w		#3,Scale_factor
	beq.s		.x8
	addq		#8,d0
	and.w		#-16,d0
	bra.s		.no
.x8	addq		#4,d0
	and.w		#-8,d0
.no	rts

Extra_Wul:
	sub.w		#16,Window_X
	sub.w		#16,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wu:
	sub.w		#16,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wur:
	sub.w		#16,Window_Y
	add.w		#16,Window_X
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wl:
	sub.w		#16,Window_X
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wr:
	add.w		#16,Window_X
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wdl:
	sub.w		#16,Window_X
	add.w		#16,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wd:
	add.w		#16,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

Extra_Wdr:
	add.w		#16,Window_X
	add.w		#16,Window_Y
	bsr		Get_window_bounds
	tst.b		ANIMATING
	bne.s		.rts
	bsr		SOFTMOUSE_CHECKIN
	bsr		Superscaler
	bsr		SOFTMOUSE_CHECKOUT
.rts	rts

*-----*	Extra functions		*-----------------------------------*

Funct_cursor
	ifd		crap

	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Funct_cursor,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	sf		CROSSHAIR
	addq		#1,MOUSE_STYLE
	cmp.w		#4,MOUSE_STYLE
	beq.s		.ch
	blt.s		.ok
	clr.w		MOUSE_STYLE
	bra.s		.ok
.ch	st		CROSSHAIR
	bra.s		.done
.ok	bsr		Init_mouse
.done	delay		5
	bsr		SHOW_MOUSE
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	move.b	CROSSHAIR,CROSSCOPY
	rts
.err	moveq		#I_Funct_cursor,d0
	moveq		#0,d1
	lea		WIN_Prefs,a1
	jmp		Tool_dialog_box

	endc
	rts
	
Apex_disk:
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	moveq		#I_Apex_disk,d0
	moveq		#0,d1
	lea		WIN_Apex_disk,a1
	jmp		Tool_dialog_box
.err	rts

Apex_brush:
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	moveq		#I_Apex_brush,d0
	moveq		#0,d1
	lea		WIN_Apex_brush,a1
	jmp		Tool_dialog_box
.err	rts

Apex_video:
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	moveq		#I_Apex_video,d0
	moveq		#0,d1
	lea		WIN_Apex_video,a1
	sf		OK_CANCEL
	jsr		Tool_dialog_box
	tst.b		OK_CANCEL
	beq.s		.err
	push.w	CURRENT_FUNCTION
	move.w	#I_Apex_video,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		Init_VideoMemory
	pop.w		CURRENT_FUNCTION
	jsr		Swap_draw
	move.w	#I_Extra_dummy,ICON
.err	rts

Extra_reset:
	moveq		#I_Extra_reset,d0
	moveq		#0,d1
	lea		WIN_Extra_reset,a1
	sf		OK_CANCEL
	jsr		Tool_dialog_box
	tst.b		OK_CANCEL
	beq.s		.err
	sf		FIRST_VIDEO
	jsr		HIDE_MOUSE
	jsr		Init_VideoMemory
	jsr		Check_menu
	jsr		SHOW_MOUSE
.err	rts

Apex_quit:
	cmp.b		#right_button,ICON_BUTTON
	beq		.sleep
	moveq		#I_Apex_quit,d0
	moveq		#0,d1
	lea		WIN_Apex_quit,a1
	sf		OK_CANCEL
	jsr		Tool_dialog_box
	tst.b		OK_CANCEL
	beq.s		.err
	push.w	CURRENT_FUNCTION
	move.w	#I_Apex_quit,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	delay		8
	st		PROGRAM_QUIT
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
.err	rts
.sleep
	moveq		#I_Apex_quit,d0
	moveq		#0,d1
	lea		WIN_Apex_sleep,a1
	sf		OK_CANCEL
	jsr		Tool_dialog_box
	tst.b		OK_CANCEL
	beq.s		.err
	jsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Apex_quit,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		Prepare_for_AES
	move.l	#DropDownMenu,USER_ROUT
	jsr		USER_CALL
	jsr		Prepare_for_CUSTOM
	jsr		Refresh_info_bar
	jsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		SHOW_MOUSE
	rts

USER_CALL:
	move.l	sp,NEW_SSP
	move.l	sp,a0
	lea		-256(a0),a0
	move.l	a0,-(sp)
	move.w	#32,-(sp)
	trap		#1
	lea		10(sp),sp
	lea		GEM_STACK,sp
	jsr		([USER_ROUT.l])
	move.l	NEW_SSP,-(sp)
	move.w	#32,-(sp)
	trap		#1
	rts

*-----------------------------------------------------*

check_menus_open:
	tst.b		MENU_UP
	beq.s		.skip
	not.b		MENU_UP
	jsr		Check_menu
.skip	rts

Swap_draw:

	jsr		check_menus_open

	move.w	#-1,CURRENT_STATION
	move.w	#I_Swap_draw,CURRENT_STUDIO

	jsr		Redraw_menu_icons

	move.w	#station_draw,CURRENT_STATION
	move.l	#DRAWSTATION_ID,swapmenu_id

	jsr		read_swap_menu

	move.l	#Draw_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#DRAWSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO

	bsr		Superscaler

	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE

	rts

Swap_cell:
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	move.w	#I_Swap_cell,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_cell,CURRENT_STATION
	move.l	#CELLSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Draw_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#CELLSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts

Swap_colour:
	jsr		check_menus_open
	move.w	VCOL_BITS,d0
	and.w		#1<<Bit_VCOL_GREY,d0
	beq.s		.ok
	lea		WIN_NCM_Alert,a0
	jsr		DO_ALERT
	bra.s		.go
.ok	move.w	#-1,CURRENT_STATION
	move.w	#I_Swap_colour,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_colour,CURRENT_STATION
	move.l	#COLOURSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Draw_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#WIN_Colourstation,TOOL_ICONS
	move.l	TOOL_ICONS,PASSIVE_PTR
	move.l	TOOL_ICONS,ICON_LIST
	jsr		colour_zoom
	st		rgb_selector_on
	move.l	PASSIVE_PTR,d0
	jsr		Passive_dialog
	sf		ENABLE_GUIDES
.go	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts

Swap_video:
	ifnd		cutdown
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	move.w	#I_Swap_video,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_video,CURRENT_STATION
	move.l	#VIDEOSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Video_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#VIDEOSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	endc
	rts

Swap_pro:
	ifnd		cutdown
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	ifnd		preview
	move.w	#I_Swap_pro,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_pro,CURRENT_STATION
	move.l	#PROSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Pro_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#PROSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	endc
	endc
	rts

Swap_aproc:
	ifnd		cutdown
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	ifnd		preview
	move.w	#I_Swap_aproc,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_aproc,CURRENT_STATION
	move.l	#APROCSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Aproc_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#APROCSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	endc
	endc
	rts

Swap_morph:
	ifnd		cutdown
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	ifnd		preview
	move.w	#I_Swap_morph,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_morph,CURRENT_STATION
	move.w	#station_morph,THIS_STATION
	move.l	#MORPHSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Morph_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#MORPHSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	st		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	move.w	#I_Extra_dummy,ICON
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
	endc
	endc
	rts

Swap_text:
	jsr		check_menus_open
	move.w	#-1,CURRENT_STATION
	ifnd		preview
	move.w	#I_Swap_text,CURRENT_STUDIO
	jsr		Redraw_menu_icons
	move.w	#station_text,CURRENT_STATION
	move.l	#TEXTSTATION_ID,swapmenu_id
	jsr		read_swap_menu
	move.l	#Text_macros,MAIN_MACROS
	clr.l		PASSIVE_PTR
	move.l	#TEXTSTATION_ICONS,TOOL_ICONS
	move.l	TOOL_ICONS,ICON_LIST
	sf		rgb_selector_on
	jsr		normal_zoom
	sf		ENABLE_GUIDES
	move.b	#left_button,ICON_BUTTON
	bsr		HIDE_MOUSE
	move.w	#I_Extra_dummy,CURRENT_STUDIO
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	endc
	rts

normal_zoom:
	move.w	#16,Screen_Y1
	move.w	#200-16,Screen_Y2
	move.w	#16,zoom_top
	move.w	#200-16,zoom_bot
	rts

colour_zoom:
	move.w	#16+80-32,Screen_Y1
	move.w	#200-16,Screen_Y2
	move.w	#16+80-32,zoom_top
	move.w	#200-16,zoom_bot
	rts

Swap_none:
Frame_none:
	rts

*-----------------------------------------------------*

clear_textstring:
	clr.w		cfn_pos
	clr.w		cfn_count
	clr.l		linebuffer
	rts

draw_textstring:
	jsr		init_lastchar
	move.w	CANVAS_WIDTH,X1
	move.w	CANVAS_HEIGHT,Y1
	move.w	#0,X2
	move.w	#0,Y2
	push.l	cfn_y
	push.l	cfn_x
	jsr		reset_kerning
.loop	moveq		#0,d0
	move.b	(a0)+,d0
	beq.s		.done
	cmp.b		#13,d0
	beq.s		.cr
	move.w	d0,CFN
	pushall
	jsr		print_cfn
	popall
	bra.s		.loop
.done	jsr		store_charpos
	pop.l		cfn_x
	pop.l		cfn_y
	rts
.cr	move.l	(sp),cfn_x
	jsr		reset_kerning
	move.w	cfnygap,d0
	ext.l		d0
	muls.l	scaler,d0
	lsl.l		#3,d0
	add.l		d0,cfn_y
	bra.s		.loop

draw_lastchar:
	move.w	CANVAS_WIDTH,X1
	move.w	CANVAS_HEIGHT,Y1
	move.w	#0,X2
	move.w	#0,Y2
	push.l	cfn_y
	push.l	cfn_x
	lea		linebuffer,a0
	tst.b		(a0)
	beq.s		.exit
	jsr		load_charpos
.look	tst.b		(a0)+
	bne.s		.look
	moveq		#0,d0
	move.b	-2(a0),d0
	move.w	d0,CFN
	cmp.w		#13,d0
	bne.s		.ncr
	move.l	(sp),cfn_x
	jsr		reset_kerning
	move.w	cfnygap,d0
	ext.l		d0
	muls.l	scaler,d0
	lsl.l		#3,d0
	add.l		d0,cfn_y
	bra		.done
.ncr	jsr		print_cfn
.done	jsr		store_charpos
.exit	pop.l		cfn_x
	pop.l		cfn_y
	rts

init_lastchar:
	move.l	cfn_x,lc_cfn_x
	move.l	cfn_y,lc_cfn_y
	move.l	this_kern,lc_cfn_lk
	rts

store_charpos:
	move.l	cfn_x,lc_cfn_x
	move.l	cfn_y,lc_cfn_y
	move.l	this_kern,lc_cfn_lk
	rts

load_charpos:
	move.l	lc_cfn_x,cfn_x
	move.l	lc_cfn_y,cfn_y
	move.l	lc_cfn_lk,this_kern
	rts
	
add_cfn_2_string:
	and.w		#255,d0
	cmp.w		#8,d0
	beq.s		.bs
	cmp.w		#13,d0
	beq.s		.go
.add	cmp.w		#' ',d0
	blt.s		.rts
.go	move.w	cfn_pos,d1
	lea		(linebuffer.l,d1.w),a0
	move.b	d0,(a0)+
	clr.b		(a0)
	addq		#1,cfn_count
	addq		#1,cfn_pos
	bra.s		.rts
.bs	move.w	cfn_pos,d0
	beq.s		.rts
	subq		#1,d0
	move.w	d0,cfn_pos
	subq		#1,cfn_count
.bsc	move.b	(1+linebuffer.l,d0.w),(linebuffer.l,d0.w)
	beq.s		.rts
	addq		#1,d0
	bra.s		.bsc
.rts	rts

Text_options:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Text_options,d0
	moveq		#station_text,d1
	lea		WIN_Text_options,a1
	jmp		Tool_dialog_box
.exit	rts

Text_clear:
	cmp.b		#right_button,ICON_BUTTON
	beq		.rts
	bsr		HIDE_MOUSE
	seticon	I_Text_clear,station_text
	jsr		Redraw_menu_icons
	delay		8
	jsr		Clear_fontbuffer
	reseticon	
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.rts	rts

Text_type:
	cmp.b		#right_button,ICON_BUTTON
	beq.s		.err
	moveq		#I_Text_type,d0
	moveq		#station_text,d1
	lea		Text_type_code,a0
	jsr		Check_tool_dialog
	jsr		Setup_tool
	jsr		Permanent_tool
.err	rts
		
Text_type_code:
	tst.b		font_loaded
	beq		.rts
	init_tool
	jsr		INIT_PENCIL
	jsr		Keep_undo
	jsr		SET_PHYS_CANVAS
	st		SOFTWARE_MOUSE
	jsr		Init_DSP_CFN
	bsr		clear_textstring
	clr.l		cfn_x
	clr.l		cfn_y
	move.w	X1,cfn_x	
	move.w	Y1,cfn_y
.wb	tst.b		BUTTONS
	bne.s		.wb
	lea		linebuffer,a0
	jsr		draw_textstring	
	jsr		Superscale_zone
.loop	tst.b		BUTTONS
	beq.s		.cont
	cmp.b		#right_button,BUTTONS
	beq.s		.wipe
	bra		.dump
.cont	bsr		GET_CHAR
	tst.b		d0
	beq.s		.loop
	move.b	d0,CFN
	cmp.b		#27,d0
	beq		.wipe
	jsr		add_cfn_2_string
	cmp.b		#8,CFN
	bne.s		.char
.bs	jsr		COPYBACK
	lea		linebuffer,a0
	jsr		draw_textstring	
	bra.s		.done
.char	jsr		draw_lastchar
.done	jsr		Superscale_zone
	move.l	X1,OLD_X1
	move.l	X2,OLD_X2
	bra		.loop
.wipe	jsr		COPY_UNDO_2_LOG
	bra.s		.exit
.dump	jsr		COPY_UNDO_2_LOG
	lea		linebuffer,a0
	jsr		draw_textstring
.exit	st		BITMAP_CHANGED
	sf		SOFTWARE_MOUSE
	jsr		SET_LOG_CANVAS
	jsr		Superscaler
	bsr		MOUSE_WAITMODE
.rts	rts

redraw_cfn_cursor:
	push.l	last_kern
	push.l	this_kern
	push.l	cfn_x
	push.l	cfn_y
	jsr		load_charpos
	jsr		draw_cfn_cursor
	pop.l		cfn_y
	pop.l		cfn_x
	pop.l		this_kern
	pop.l		last_kern
	rts

draw_cfn_cursor:
	move.w	CFN_HANDLE,d0
	jsr		Find_block
	move.w	$1dc(a0),ascender
	move.w	$1e2(a0),descender
	lea		$2b4(a0),a1
	move.w	CFN,d1
	sub.w		#32,d1
	lsl.w		#4,d1
	lea		(a1,d1.w),a1
	move.l	this_kern,last_kern
	move.l	a1,this_kern
	jsr		find_new_x
	move.w	descender,d0
	sub.w		ascender,d0
	ext.l		d0
	muls.l	scaler,d0
	lsl.l		#3,d0
	swap		d0
	move.w	cfn_y,d2
	move.w	d2,d4
	sub.w		d0,d2
	move.w	cfn_x,d1
	move.w	d1,d3
	jsr		Clip_LOG_X1Y1
	jsr		Update_range
	jsr		Clip_LOG_X2Y2
	push.w	d1
	push.w	d2
	move.w	d3,d1
	move.w	d4,d2
	jsr		Update_range
	pop.w		d2
	pop.w		d1
	move.w	#31,d0
	bsr		DRAW_LOG_LINE
	rts	

remove_cfn_cursor:
	push.l	last_kern
	push.l	this_kern
	push.l	cfn_x
	push.l	cfn_y
	jsr		load_charpos
	jsr		undraw_cfn_cursor
	pop.l		cfn_y
	pop.l		cfn_x
	pop.l		this_kern
	pop.l		last_kern
	rts

undraw_cfn_cursor:
	move.w	CFN_HANDLE,d0
	jsr		Find_block
	move.w	$1dc(a0),ascender
	move.w	$1e2(a0),descender
	lea		$2b4(a0),a1
	move.w	CFN,d1
	sub.w		#32,d1
	lsl.w		#4,d1
	lea		(a1,d1.w),a1
	move.l	this_kern,last_kern
	move.l	a1,this_kern
	jsr		find_new_x
	move.w	descender,d0
	sub.w		ascender,d0
	ext.l		d0
	muls.l	scaler,d0
	lsl.l		#3,d0
	swap		d0
	move.w	cfn_y,d2
	move.w	d2,d4
	sub.w		d0,d2
	move.w	cfn_x,d1
	move.w	d1,d3
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	#20,d0
	bsr		DRAW_LOG_LINE
	rts	

Macro_record:
;	push.w	CURRENT_FUNCTION
;	move.w	#I_Macro_record,CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
;	delay		10
;;	move.l	#MACRO_BUFFER,MACRO_RECORD_PTR
;	clr.w		MACRO_RECORD_COUNT
;	st		MACRO_RECORD_FLAG
;	pop.w		CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
	rts

Macro_stop:
;	push.w	CURRENT_FUNCTION
;	move.w	#I_Macro_stop,CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
;	delay		10
;	sf		MACRO_RECORD_FLAG
;	sf		MACRO_PLAY_FLAG
;	sf		MACRO_PLAY_TRIGGER
;	pop.w		CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
	rts

Macro_play:
;	push.w	CURRENT_FUNCTION
;	move.w	#I_Macro_play,CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
;	delay		5
;;	move.l	#MACRO_BUFFER,MACRO_PLAYBACK_PTR
;	move.w	MACRO_RECORD_COUNT,MACRO_PLAY_COUNT
;	st		MACRO_PLAY_TRIGGER
;	pop.w		CURRENT_FUNCTION
;	jsr		Redraw_menu_icons
	rts

Apex_help:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	moveq		#I_Apex_help,d0
	moveq		#0,d1
	lea		WIN_Apex_help,a1
	jmp		Tool_dialog_box
.exit	rts

Apex_sys:
	cmp.b		#right_button,ICON_BUTTON
	beq		.exit
	lea		WIN_Apex_sys,a0
	jsr		Dialog
	jsr		HIDE_MOUSE
	jsr		Superscaler
	jsr		SHOW_MOUSE
.exit	rts

Apex_info:
	moveq		#I_Apex_info,d0
	cmp.b		#right_button,ICON_BUTTON
	bne		.rt
	lea		WIN_Apex_info,a1
	push.w	CURRENT_FUNCTION
	move.w	d0,CURRENT_FUNCTION
	cmp.w		#I_Draw_brush,LAST_ICON
	blt.s		.no
	cmp.w		#I_Draw_exchange,LAST_ICON
	bgt.s		.no
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.no
.go	move.w	d0,OLD_FUNCTION
.no	push.l	a1
	jsr		Redraw_menu_icons
	pop.l		a0
	pushall
	jsr		init_intro
	popall
	jsr		Dialog
	jsr		Check_menu
	pop.w		CURRENT_FUNCTION
	move.w	wormhole_handle,d0
	bmi.s		.exit
	jsr		Remove_block
.exit	rts
.rt	moveq		#0,d1
	lea		WIN_Prefs,a1
	jmp		Tool_dialog_box

rgb_selector_on:	ds.b	1
			even

*-----*	Frame functions		*-----------------------------------*

Frame_start:
	tst.w		CUR_DELTAFRAME
	beq.s		.rts
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_start,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
	clr.w		CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	jsr		COPY_FRAME_2_LOG
	bsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	st		FIRST_DRAW
.rts	rts

Frame_goto:
	push.w	d0
	bsr		HIDE_MOUSE
	bsr		Get_changes
	pop.w		d0
	move.w	d0,CUR_DELTAFRAME
	bsr		Update_position
	jsr		COPY_FRAME_2_LOG
	bsr		Update_palette
	bsr		Superscaler
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.rts	rts

Frame_left_ins_invoke:
	move.b	#left_button,ICON_BUTTON
Frame_left_ins:
	move.w	#1,tempword
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.last
	move.w	#10,tempword
	cmp.w		#1,Delta_count
	bne.s		.last
	move.w	#9,tempword
.last	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_left_ins,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
	tst.l		d0
	bmi		.err
	addq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	subq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
.loop	addq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	jsr		Insert_frame
	tst.l		d0
	bmi.s		.err
	subq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	subq		#1,tempword
	bne.s		.loop
	jsr		COPY_FRAME_2_LOG
	jsr		Update_palette
	bsr		Superscaler
.err	bsr		CHECK_FRAME
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts

Frame_left:
	cmp.b		#right_button,ICON_BUTTON
	beq		Extra_playleft
Frame_left_invoke:
	tst.w		CUR_DELTAFRAME
	beq.s		.rts
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_left,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
.back	bsr		RETREAT_FRAME
	bsr		Update_position
	jsr		COPY_FRAME_2_LOG
	bsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	st		FIRST_DRAW
.rts	rts
	
Frame_bar:
	cmp.b		#right_button,ICON_BUTTON
	beq		Shuttle_bar
	bsr		HIDE_MOUSE
	bsr		Get_changes
	move.w	#-1,OXD
	push.l	SCALE_SCR
	move.l	FRAME_SCR,SCALE_SCR
.lp	bsr		Get_barpos
	mulu		Delta_count,d0
	divu		#PBAR_Xmax-PBAR_Xmin,d0
	cmp.w		OXD,d0
	beq.s		.skip
	move.w	d0,OXD	
	move.w	d0,CUR_DELTAFRAME
	jsr		Redraw_position_bar
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	bsr		Update_palette
	bsr		Superscaler
.skip	cmp.b		#left_button,BUTTONS
	beq.s		.lp
	jsr		COPY_FRAME_2_LOG
	pop.l		SCALE_SCR
	bsr		SHOW_MOUSE
	rts
	
Shuttle_bar:
	bsr		HIDE_MOUSE
	bsr		Get_changes
	move.w	#-1,OXD
	push.w	MOUSE_Y
	push.l	SCALE_SCR
	move.l	FRAME_SCR,SCALE_SCR
	clr.w		CURPLAY
	clr.w		PLAYSPEED
	move.w	#SBAR_Xmin+1+(SBAR_Xmax-SBAR_Xmin)/2,d0
	xresfactor	d0
	move.w	d0,MOUSE_X
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	move.w	CUR_DELTAFRAME,d0
	swap		d0
	clr.w		d0
	move.l	d0,playvar
	clr.l		playinc
*-----------------------------------------*
.lp	bsr		Get_shuttlepos
	mulu		MAXIMUM_DIST,d0
	divu		#SBAR_Xmax-SBAR_Xmin,d0
	cmp.w		OXD,d0
	beq.s		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_DIST
*-----------------------------------------*
	move.w	MAXIMUM_DIST,d0
	move.w	CURRENT_DIST,d1
	add.w		d1,d1
	sub.w		d1,d0
	swap		d0
	clr.w		d0
	move.w	MAXIMUM_DIST,d1
	ext.l		d1
	divs.l	d1,d0
	move.w	#512,d1
	ext.l		d1
	muls.l	d1,d0
	asr.l		#6,d0
	move.l	d0,playinc
*-----------------------------------------*
.skip	move.w	Delta_count,d1
	swap		d1
	clr.w		d1
	move.l	playvar,d0
	sub.l		playinc,d0
	bpl.s		.nts
	add.l		d1,d0
.nts	cmp.l		d1,d0
	blt.s		.ntb
	sub.l		d1,d0
.ntb	move.l	d0,playvar
	swap		d0
	cmp.w		#1,Delta_count
	beq.s		.ski2
	tst.w		d0
	bpl.s		.o1
	moveq		#0,d0
.o1	move.w	Delta_count,d1
	subq		#1,d1
	cmp.w		d1,d0
	ble.s		.o2
	move.w	d1,d0
.o2	move.w	d0,CUR_DELTAFRAME
*-----------------------------------------*
.ski2	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	jsr		Redraw_position_bar
	jsr		Update_shuttle_bar
	jsr		Update_palette
	bsr		Superscaler
	cmp.b		#right_button,BUTTONS
	beq		.lp
*-----------------------------------------*
	jsr		Redraw_position_bar
	jsr		COPY_FRAME_2_LOG
	pop.l		SCALE_SCR
	move.w	MAXIMUM_DIST,d0
	lsr.w		d0
	move.w	d0,CURRENT_DIST
	jsr		Redraw_menu_icons
	pop.w		MOUSE_Y
	bsr		SHOW_MOUSE
	rts

playvar:	ds.l	1
playinc:	ds.l	1

Time_bar:
	bsr		HIDE_MOUSE
	move.w	#-1,OYD
	move.w	#TBAR_Xmin,SLIDER_XMIN
	move.w	#TBAR_Xmax,SLIDER_XMAX
	move.w	#TBAR_Ymin,SLIDER_YMIN
	move.w	#TBAR_Ymax,SLIDER_YMAX
	move.w	#TBAR_Height,SLIDER_HEIGHT
	move.w	CURRENT_TIME,CURRENT_BARSIZE
	move.w	MAXIMUM_TIME,MAXIMUM_BARSIZE
.lp	jsr		Get_vslide_pos
	cmp.w		OYD,d0
	beq		.skip
	move.w	d0,OYD	
	move.w	d0,CURRENT_TIME
	bsr		Update_time_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	bsr		SHOW_MOUSE
	rts

Update_time_bar:
	move.w	#TBAR_Xmin,SLIDER_XMIN
	move.w	#TBAR_Ymin,SLIDER_YMIN
	move.w	#TBAR_Xmax,SLIDER_XMAX
	move.w	#TBAR_Ymax,SLIDER_YMAX
	move.w	#TBAR_Height,SLIDER_HEIGHT
	move.w	CURRENT_TIME,CURRENT_BARSIZE
	move.w	MAXIMUM_TIME,MAXIMUM_BARSIZE
	move.w	GENGFX_HANDLE,d0			
	jmp		Update_vslide

;Time_bar:
;	bsr		HIDE_MOUSE
;	bsr		Get_changes
;	move.w	#-1,OXD
;	push.w	MOUSE_Y
;.lp	bsr.s		Get_timepos
;	mulu		MAXIMUM_TIME,d0
;	divu		#TBAR_Xmax-TBAR_Xmin,d0
;	cmp.w		OXD,d0
;	beq.s		.skip
;	move.w	d0,OXD	
;	move.w	d0,CURRENT_TIME
;	jsr		Redraw_time_bar
;.skip	cmp.b		#left_button,BUTTONS
;	beq.s		.lp
;	pop.w		MOUSE_Y
;	bsr		SHOW_MOUSE
;	rts
;
;Get_timepos:
;	move.w	MOUSE_X,d0
;	ext.l		d0
;	divu		x_factor,d0
;	cmp.w		#TBAR_Xmax,d0
;	blt.s		.ok0
;	move.w	#TBAR_Xmax-1,d0
;.ok0	sub.w		#TBAR_Xmin,d0
;	bpl.s		.ok1
;	moveq		#0,d0
;.ok1	rts
;
;Update_time_bar:
;	move.w	#TBAR_Xmin,d0		*tbar*
;	move.w	#TBAR_Xmax,d1
;	moveq		#TBAR_Width,d7
;	sub.w		d0,d1
;	mulu		CURRENT_TIME,d1
;	divu		MAXIMUM_TIME,d1
;	add.w		d0,d1
;	addq		#1,d1
;	move.w	d1,d3
;	move.w	d7,d2
;	lsr.w		d2
;	sub.w		d2,d1
;	add.w		d2,d3
;	move.w	#TBAR_Ymin+4,d2
;	move.w	#TBAR_Ymax-4,d4
;	movem.w	d1/d3,-(sp)
;	move.w	#TBAR_Xmin-2,d1
;	moveq		#7,d0
;	jsr		DRAW_MENU_BLOCK
;	movem.w	(sp)+,d1/d3
;	move.w	#TBAR_Ymin+3,d2
;	move.w	#TBAR_Ymax-3,d4
;	jsr		Raised_bar
;.stop	rts
;
;Redraw_time_bar:
;	cmp.b		#no_menu,MENU_STATE
;	beq.s		.no
;	move.w	#TBAR_Xmin-8,d1
;	move.w	#TBAR_Xmax-TBAR_Xmin+15,d3
;	move.w	#TBAR_Ymin-1+4,d2
;	move.w	#TBAR_Ymax-TBAR_Ymin+2-8,d4
;	move.w	FRMBAR_HANDLE,d0			
;	bsr.s		Patch_menu
;	bsr.s		Update_time_bar
;.no	rts

Get_shuttlepos:
	move.w	MOUSE_X,d0
	ext.l		d0
	divu		x_factor,d0
	cmp.w		#SBAR_Xmax,d0
	blt.s		.ok0
	move.w	#SBAR_Xmax-1,d0
.ok0	sub.w		#SBAR_Xmin,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	rts

Get_barpos:
	move.w	MOUSE_X,d0
	ext.l		d0
	divu		x_factor,d0
	cmp.w		#PBAR_Xmax,d0
	blt.s		.ok0
	move.w	#PBAR_Xmax-1,d0
.ok0	sub.w		#PBAR_Xmin,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	rts

Frame_right:
	cmp.b		#right_button,ICON_BUTTON
	beq		Extra_playright
Frame_right_invoke:
	move.w	Delta_count,d0
	subq		#1,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.rts
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_right,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
.back	bsr		ADVANCE_FRAME
	bsr		Update_position
	jsr		COPY_FRAME_2_LOG
	bsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	st		FIRST_DRAW
.rts	rts


Frame_right_ins_invoke:
	move.b	#left_button,ICON_BUTTON
Frame_right_ins:
	move.w	#1,tempword
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.last
	move.w	#10,tempword
	cmp.w		#1,Delta_count
	bne.s		.last
	move.w	#9,tempword
.last	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_right_ins,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
	tst.l		d0
	bmi		.err
	addq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	subq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
.loop	addq		#1,CUR_DELTAFRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Insert_frame
	tst.l		d0
	bmi.s		.err
	subq		#1,CUR_DELTAFRAME
	bsr		ADVANCE_FRAME
	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	subq		#1,tempword
	bne.s		.loop
	jsr		COPY_FRAME_2_LOG
	jsr		Update_palette
	bsr		Superscaler
.err	bsr		CHECK_FRAME
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts
	
tempword:	ds.w	1

Frame_end:
	move.w	Delta_count,d0
	subq		#1,d0
	cmp.w		CUR_DELTAFRAME,d0
	beq.s		.rts
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frame_end,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		Get_changes
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,CUR_DELTAFRAME
	bsr		Update_position
	bsr		COPY_FRAME_2_LOG
	bsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	st		FIRST_DRAW
.rts	rts

Frame_clear:
	st		BITMAP_CHANGED
	jsr		Keep_undo
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frames_delete,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	moveq		#0,d1
	moveq		#0,d2
	move.w	CANVAS_WIDTH,d3
	move.w	CANVAS_HEIGHT,d4
	subq		#1,d3
	subq		#1,d4
	moveq		#0,d0
	move.l	LOG_SCR,a0
	move.w	logwid,scrwid
	bsr		Draw_block
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
	rts
		
Frames_delete:
	cmp.b		#left_button,ICON_BUTTON
	beq		Frame_clear
	cmp.b		#tween_frame,TWEEN_TYPE
	beq		Frame_delete
	clr.w		LEFT_LIMIT
	move.w	Delta_count,d0
	subq		#1,d0
	move.w	d0,RIGHT_LIMIT
	cmp.b		#tween_all,TWEEN_TYPE
	beq.s		.cont
	move.w	SEGMENT_START,d0
	move.w	SEGMENT_END,d1
	cmp.w		d1,d0
	ble.s		.ord
	exg		d0,d1
.ord	move.w	d0,LEFT_LIMIT
	move.w	d1,RIGHT_LIMIT
.cont	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frames_delete,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	jsr		segment_check
	tst.b		OK_CANCEL
	beq		.done
	move.w	RIGHT_LIMIT,CUR_DELTAFRAME
.new	cmp.w		#1,Delta_count
	beq		.done
	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	move.w	d0,RIGHT_LIMIT
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		Delta_count,d0
	blt.s		.next
	moveq		#0,d0
.next	bsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	bpl.s		.prev
	move.w	Delta_count,d0
	subq		#1,d0
.prev	bsr		Update_position
	bsr		Make_deltas
	move.w	CUR_DELTAFRAME,d0
	bsr		Remove_frame
	move.w	CUR_DELTAFRAME,d0
	cmp.w		Delta_count,d0
	blt.s		.nwrp
	moveq		#0,d0
.nwrp	bsr		Keep_deltas
	bsr		CHECK_FRAME
	bsr		Update_position
	bsr		COPY_FRAME_2_LOG
	move.w	CUR_DELTAFRAME,d0
	cmp.w		LEFT_LIMIT,d0
	beq.s		.done
	move.w	RIGHT_LIMIT,CUR_DELTAFRAME
	bra		.new
.done	jsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.one	rts

segment_check:
	st		OK_CANCEL
	cmp.b		#tween_frame,TWEEN_TYPE
	beq.s		.rts
	sf		OK_CANCEL
	cmp.b		#tween_segment,TWEEN_TYPE
	beq.s		.seg
.all	lea		WIN_Funct_all,a0
	jsr		Dialog
	bra.s		.rts
.seg	lea		WIN_Funct_seg,a0
	jsr		Dialog
.rts	rts

Frame_delete:
	cmp.w		#1,Delta_count
	beq		.one
	bsr		HIDE_MOUSE
	push.w	CURRENT_FUNCTION
	move.w	#I_Frames_delete,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		Delta_count,d0
	blt.s		.next
	moveq		#0,d0
.next	bsr		Update_position
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	bpl.s		.prev
	move.w	Delta_count,d0
	subq		#1,d0
.prev	bsr		Update_position
	bsr		Make_deltas
	move.w	CUR_DELTAFRAME,d0
	bsr		Remove_frame
	move.w	CUR_DELTAFRAME,d0
	cmp.w		Delta_count,d0
	blt.s		.nwrp
	moveq		#0,d0
.nwrp	bsr		Keep_deltas
	bsr.s		CHECK_FRAME
	bsr		Update_position
	bsr		COPY_FRAME_2_LOG
	jsr		Update_palette
	bsr		Superscaler
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	bsr		SHOW_MOUSE
.one	rts

CHECK_FRAME:
	move.w	CUR_DELTAFRAME,d0
	bpl.s		.ok1
	clr.w		d0
.ok1	move.w	Delta_count,d1
	subq		#1,d1
	cmp.w		d1,d0
	ble.s		.fok
	move.w	d1,d0
.fok	move.w	d0,CUR_DELTAFRAME
	rts

ADVANCE_FRAME:
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	move.w	Delta_count,d1
	subq		#1,d1
	cmp.w		d1,d0
	ble.s		.fok
	move.w	d1,d0
.fok	move.w	d0,CUR_DELTAFRAME
	rts

RETREAT_FRAME:
	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	bpl.s		.fok
	moveq		#0,d0
.fok	move.w	d0,CUR_DELTAFRAME
	rts

Tween_menu:
	moveq		#I_Tween_menu,d0
	moveq		#0,d1
	lea		WIN_Tween_menu,a1
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.cnt
	push.w	Screen_Y2
	sub.w		#17,Screen_Y2
	st		tween_dialog
	jsr		Tool_dialog_box
	sf		tween_dialog
	pop.w		Screen_Y2
	rts
.cnt	push.w	CURRENT_FUNCTION
	move.w	#I_Tween_menu,CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	delay		8
	move.b	TWEEN_TYPE,d0
	cmp.b		#tween_frame,d0
	beq.s		.seg
	cmp.b		#tween_all,d0
	beq.s		.frm
	move.b	#tween_all,TWEEN_TYPE
	bra.s		.done
.frm	move.b	#tween_frame,TWEEN_TYPE
	bra.s		.done
.seg	move.b	#tween_segment,TWEEN_TYPE
.done	bsr		HIDE_MOUSE
	bsr		Superscaler
	bsr		SHOW_MOUSE
	pop.w		CURRENT_FUNCTION
	jsr		Redraw_menu_icons
	rts

tween_dialog:	ds.w	1

*-----*	Palette bar functions	*-----------------------------------*

Check_draw_window:
	tst.b		DIALOG_FLAG
	bne		.rts
	move.w	IFACE_BITS,d0
	and.w		#1<<Bit_IFACE_PROT,d0
	beq.s		.ncnt
	tst.b		DRAW_LOOP
	bne.s		.ncnt
	cmp.b		#left_button,ICON_BUTTON
	bne.s		.ncnt
	jsr		HIDE_MOUSE
.back	jsr		Extra_center
	cmp.b		#left_button,BUTTONS
	beq.s		.back
	jsr		SHOW_MOUSE
	bra.s		.rts
.ncnt	move.w	IFACE_BITS,d0
	and.w		#1<<Bit_IFACE_PROT,d0
	beq.s		.dpnt
	push.b	DRAW_LOOP
	jsr		Swap_menu
	pop.b		d0
	beq.s		.rts
	tst.b		DRAW_LOOP
	beq.s		.rts
	bra.s		.go
.dpnt	push.b	DRAW_LOOP
	jsr		Swap_menu
	pop.b		d0
	cmp.b		DRAW_LOOP,d0
	bne.s		.rts
.go	move.l	FUNCTION_ADDR,d1
	ble.s		.rts
	jmp		(d1.l)
.rts	rts

Swap_menu:
	cmp.b		#right_button,ICON_BUTTON
	bne.s		.stop
	not.b		MENU_UP
	bra.s		Check_menu
.stop	rts
	
Check_menu:
	tst.b		MENU_UP
	beq.s		.menu
.wind	bsr		CLOSE_MENU
	move.l	PACK_SCR,a0
	not.l		(a0)
	not.l		(a0)
	move.l	LOG_SCR,a0
	not.l		(a0)
	not.l		(a0)
	st		DRAW_LOOP
	bra.s		.rts
.menu	bsr		OPEN_MENU
.rts	tst.b		BUTTONS
	bne.s		.rts
	rts
	
Palette_colours:
	pushall
	st		HOLD_INFOBAR
	bsr		HIDE_MOUSE
	moveq		#0,d1
	moveq		#0,d2
	move.w	ICON_X,d1
	move.w	ICON_Y,d2
	divu		x_factor,d1
	divu		y_factor,d2
	sub.w		#200,d2
	bmi		.out
	ext.l		d2
	divu		#5,d2
	lsl.w		#6,d2
	ext.l		d1
	divu		#5,d1
	add.w		d2,d1
	move.w	d1,first_click
	move.w	#-1,last_click
	move.w	last_click,old_last_click
	push.w	COL1_INDEX
	push.w	COL2_INDEX
	move.w	#16,TIMER
.wait	tst.b		BUTTONS
	beq.s		.loop
	tst.w		TIMER
	bne.s		.wait
.loop	move.w	first_click,COL1_INDEX
	move.w	last_click,COL2_INDEX
	bmi.s		.err
	move.w	last_click,d0
	cmp.w		old_last_click,d0
	beq.s		.err
	cmp.w		first_click,d0
	beq.s		.err
.mark	bsr		Mark_colours
	move.w	last_click,old_last_click
.err	tst.b		BUTTONS
	beq.s		.stop
	moveq		#0,d1
	moveq		#0,d2
	move.w	MOUSE_X,d1
	move.w	MOUSE_Y,d2
	divu		x_factor,d1
	divu		y_factor,d2
	move.w	#-1,last_click
	sub.w		#200,d2
	bmi.s		.loop
	ext.l		d2
	divu		#5,d2
	lsl.w		#6,d2
	ext.l		d1
	divu		#5,d1
	add.w		d2,d1
	cmp.w		#255,d1
	bgt		.loop
	move.w	d1,last_click
	bra		.loop
.stop	pop.w		COL2_INDEX
	pop.w		COL1_INDEX
	move.w	last_click,d1
	bmi.s		.nodrag
	cmp.w		first_click,d1
	beq.s		.nodrag
	move.w	first_click,COL1_INDEX
	move.w	last_click,COL2_INDEX
	bra.s		.out
.nodrag
	move.w	first_click,d1
	cmp.b		#left_button,ICON_BUTTON
	beq.s		.left
	move.w	d1,BG_INDEX
	jsr		Send_bg_2_picker
	bra.s		.out
.left	move.w	d1,FG_INDEX
	jsr		Send_fg_2_picker
.out	bsr.s		Get_colours
	bsr		Mark_colours
	tst.b		rgb_selector_on
	beq.s		.no
	cmp.b		#no_menu,MENU_STATE
	beq.s		.no
	jsr		Draw_sample_zone
	jsr		Convert_RGB_2_SLIDER
.no	bsr		SHOW_MOUSE
	sf		HOLD_INFOBAR
	popall
	rts
	
first_click:	ds.w	1
last_click:		ds.w	1
old_last_click:	ds.w	1
	
Get_colours:
	lea		INDEX_TABLE,a0
	move.w	COL1_INDEX,d0
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	move.w	d0,FIRST_COLOUR
	move.w	COL2_INDEX,d0
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	move.w	d0,LAST_COLOUR
	lea		INDEX_TABLE,a0
	move.w	FG_INDEX,d0
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	move.w	d0,FG_COLOUR
	move.w	BG_INDEX,d0
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	move.w	d0,BG_COLOUR
	rts

Send_bg_2_picker:
	move.w	BG_INDEX,d0
	bra.s		Send_col_2_picker
Send_fg_2_picker:
	move.w	FG_INDEX,d0
Send_col_2_picker:
	lea		INDEX_TABLE,a0
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	move.w	d1,TEMP_RED
	move.w	d2,TEMP_GRN
	move.w	d3,TEMP_BLU
	rts
	
SHOW_MOUSE:					; a
	addq.b	#1,MOUSE_LEVEL
	bmi.s		.rts
	tst.b		MOUSE_LEVEL
	bgt.s		.rts
	pushall
	addq.b	#1,HOLD_VBLANK
	move.b	#1,MOUSE_ON
	bsr		MousePtr_driver
	subq.b	#1,HOLD_VBLANK
	popall
.rts	rts
	
HIDE_MOUSE:					; b
	subq.b	#1,MOUSE_LEVEL
	bpl.s		.rts
	cmp.b		#-1,MOUSE_LEVEL
	blt.s		.rts
	pushall
	addq.b	#1,HOLD_VBLANK
	move.b	#0,MOUSE_ON
	bsr		MousePtr_driver
	subq.b	#1,HOLD_VBLANK
	popall
.rts	rts

WAIT_MOUSE:
.wb	jsr		Do_extra_macros
	move.b	BUTTONS,d7
	beq.s		.wb
	cmp.b		#left_button|right_button,d7
	beq.s		.wb
	rts

WAIT_MOUSE2:
.wb	move.b	BUTTONS,d7
	beq.s		.wb
	cmp.b		#left_button|right_button,d7
	beq.s		.wb
	rts

WAIT_RELEASE:
.wb	tst.b		BUTTONS
	bne.s		.wb
	rts

cydial_x1:	ds.w	1
cydial_y1:	ds.w	1
cydial_x2:	ds.w	1
cydial_y2:	ds.w	1
killspin:	ds.w	1

quickdial:
	jsr		HIDE_MOUSE
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	subq		#1,d4
	jsr		Raised_bar
	jsr		SHOW_MOUSE
	popall
	rts
	
cyberdial:
	pushall
	tst.b		killspin
	bne		quickdial
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	sub.w		#160,d1
	sub.w		#100,d2
	sub.w		#160,d3
	sub.w		#100,d4
	lea		ICONX,a1
	lea		ICONY,a2
	lea		ICONZ,a3
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a2)+
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	move.w	d4,(a2)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a2)+
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	move.w	d4,(a2)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d3,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a2)+
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	move.w	d4,(a2)+
	moveq		#0,d5
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	#16,d5
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	#32+32,d5
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	d5,(a3)+
	move.w	#0+(32*2),object_xa
	move.w	#0+(32*4),object_ya
	move.w	#128-(32*2),object_za
	move.w	#160,object_x
	move.w	#100,object_y
	move.w	#1024,object_z
	move.l	#ICONX,xlist
	move.l	#ICONY,ylist
	move.l	#ICONZ,zlist
	move.l	#ICONO,slist
	jsr		load_object
	jsr		HIDE_MOUSE
	move.l	PHYS_SCR,a0
	move.l	PACK_SCR,a1
	move.l	PHYS_SIZE,d0
	jsr		memcpy
.l1	jsr		draw_object_bpl
	jsr		clear_object_bpl
	addq		#2,object_xa
	addq		#4,object_ya
	subq		#2,object_za
	and.w		#511,object_xa
	and.w		#511,object_ya
	and.w		#511,object_za
.wt	tst.w		TIMER
	bne.s		.wt
	move.w	#1,TIMER
	sub.w		#32,object_z	; 32 loops : end at 128,256,256
	bgt.s		.l1
	jsr		draw_object_bpl
	jsr		clear_object_bpl
	sf		UNDO_VALID
	jsr		SHOW_MOUSE
	popall
	rts

Dialog:
	tst.b		safe
	beq		.err
	push.b	HOLD_VBLANK
	clr.b		HOLD_VBLANK
	push.b	FIRST_DRAW
	push.w	DIALOG_BITS
	push.b	FREEZE_ICONS
	st		FREEZE_ICONS
	bsr		HIDE_MOUSE
	push.b	MOUSE_LEVEL
	move.b	#-1,MOUSE_LEVEL
	bsr		SHOW_MOUSE
	push.l	ICON_LIST
	push.w	ICON_USED
	clr.w		ICON
	push.b	DIALOG_FLAG
*-----------------------------------*
	st		DIALOG_FLAG
	clr.w		DIALOG_BITS
	clr.w		ASK_BITS
	move.l	a0,ICON_LIST
	st		FIRST_DRAW
	move.b	#full_menu,MENU_STATE
	move.w	#iface_grey,CHAR_COL
	clr.b		ICON_BUTTON
.strt	st		FREEZE_ICONS
	bsr		HIDE_MOUSE
	tst.b		FIRST_DRAW
	beq.s		.nbox
	bsr		Remap_menu_bars
.nbox	move.l	#edit_list,EDIT_PTR
	clr.w		EDIT_COUNT
	move.l	ICON_LIST,a0

.loop	move.w	g_type(a0),d0
	cmp.w		#dialog_editbutton,d0
	bne.s		.n1
	move.l	EDIT_PTR,a1
	move.l	a0,(a1)+
	move.l	a1,EDIT_PTR
	addq		#1,EDIT_COUNT
.n1	cmp.w		#-1,d0
	beq.s		.done
	cmp.w		#-2,d0
	beq.s		.skip
	tst.b		FIRST_DRAW
	bne.s		.ok
	cmp.w		#dialog_panbutton,d0
	beq.s		.ok
	cmp.w		#dialog_frmbutton,d0
	beq.s		.ok
	cmp.w		#dialog_radbutton,d0
	beq.s		.ok
	move.w	g_ident(a0),d1
	cmp.w		ICON_USED,d1
	bne.s		.skip
.ok	move.l	.rout(pc,d0.w*4),a6
	jsr		(a6)
.skip	move.l	g_next(a0),a0
	bra.s		.loop
.rout	dc.l		Setup_mainframe
	dc.l		Setup_frame_up
	dc.l		Setup_miniframe
	dc.l		Setup_microframe
	dc.l		Setup_grovzone
	dc.l		Setup_radbutton
	dc.l		Setup_outline
	dc.l		Setup_frmbutton
	dc.l		Setup_panbutton
	dc.l		Setup_text
	dc.l		Setup_zone
	dc.l		Setup_rout
	dc.l		Setup_editbutton
	dc.l		Setup_groove
.done	sf		FIRST_DRAW
	bsr		SHOW_MOUSE
	clr.b		FREEZE_ICONS
.wait	tst.w		DIALOG_BITS
	bne.s		.out
	IFD		SNAPCODE
	jsr		SNAPSHOT
	ENDC
	move.w	ICON,d0
	beq.s		.wait
	move.b	ICON_BUTTON,d1
	beq.s		.norm
	cmp.b		#left_button,d1
	beq.s		.norm
	move.w	#I_Button_DIALOG_QUIT,ICON
	move.w	ICON,d0
.norm	move.w	d0,ICON_USED
	push.l	ICON_LIST
	move.l	#PALETTE_BAR_ICONS,ICON_LIST
	jsr		Check_functions
	pop.l		ICON_LIST
.ed	bra		.strt
*-----------------------------------*
.out	tst.b		BUTTONS
	bne.s		.out
	pop.b		DIALOG_FLAG
	clr.w		ICON
	pop.w		ICON_USED
	pop.l		ICON_LIST
	bsr		HIDE_MOUSE
	bsr		EMPTY_BUFFER
	pop.b		MOUSE_LEVEL
	bsr		SHOW_MOUSE
	pop.b		FREEZE_ICONS
	pop.w		DIALOG_BITS
	pop.b		FIRST_DRAW
	pop.b		HOLD_VBLANK
.err	rts

Passive_dialog:
	tst.l		d0
	beq		.err
	move.l	d0,WIN_LIST
	st		FIRST_DRAW
	bsr		HIDE_MOUSE
	move.l	#edit_list,EDIT_PTR
	clr.w		EDIT_COUNT
	move.l	WIN_LIST,a0
.loop	move.w	g_type(a0),d0
	cmp.w		#dialog_editbutton,d0
	bne.s		.n1
	move.l	EDIT_PTR,a1
	move.l	a0,(a1)+
	move.l	a1,EDIT_PTR
	addq		#1,EDIT_COUNT
.n1	cmp.w		#-1,d0
	beq.s		.done
	cmp.w		#-2,d0
	beq.s		.skip
	move.l	.rout(pc,d0.w*4),a6
	jsr		(a6)
.skip	move.l	g_next(a0),a0
	bra.s		.loop
.rout	dc.l		Setup_mainframe
	dc.l		Setup_frame_up
	dc.l		Setup_miniframe
	dc.l		Setup_microframe
	dc.l		Setup_grovzone
	dc.l		Setup_radbutton
	dc.l		Setup_outline
	dc.l		Setup_frmbutton
	dc.l		Setup_panbutton
	dc.l		Setup_text
	dc.l		Setup_zone
	dc.l		Setup_rout
	dc.l		Setup_editbutton
	dc.l		Setup_groove
.done	bsr		SHOW_MOUSE
	sf		FIRST_DRAW
.err	rts

refresh_passive:
	tst.l		d0
	beq		.err
	move.l	d0,WIN_LIST
	st		FIRST_DRAW
	bsr		HIDE_MOUSE
	move.l	#edit_list,EDIT_PTR
	clr.w		EDIT_COUNT
	move.l	WIN_LIST,a0
.loop	move.w	g_type(a0),d0
	cmp.w		#dialog_editbutton,d0
	bne.s		.n1
	move.l	EDIT_PTR,a1
	move.l	a0,(a1)+
	move.l	a1,EDIT_PTR
	addq		#1,EDIT_COUNT
.n1	cmp.w		#-1,d0
	beq.s		.done
	cmp.w		#-2,d0
	beq.s		.skip
	cmp.w		#dialog_panbutton,d0
	beq.s		.go
	cmp.w		#dialog_frmbutton,d0
	beq.s		.go
	cmp.w		#dialog_radbutton,d0
	bne.s		.skip
.go	move.l	.rout(pc,d0.w*4),a6
	jsr		(a6)
.skip	move.l	g_next(a0),a0
	bra.s		.loop
.rout	dc.l		Setup_mainframe
	dc.l		Setup_frame_up
	dc.l		Setup_miniframe
	dc.l		Setup_microframe
	dc.l		Setup_grovzone
	dc.l		Setup_radbutton
	dc.l		Setup_outline
	dc.l		Setup_frmbutton
	dc.l		Setup_panbutton
	dc.l		Setup_text
	dc.l		Setup_zone
	dc.l		Setup_rout
	dc.l		Setup_editbutton
	dc.l		Setup_groove
.done	bsr		SHOW_MOUSE
	sf		FIRST_DRAW
.err	rts

PASSIVE_PTR:	ds.l	1
WIN_LIST:		ds.l	1

*-----------------------------------------------------------------------*
*	Dialog routines									*
*-----------------------------------------------------------------------*

Setup_mainframe:
	move.w	#147,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3	
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	push.l	a0
	move.w	d1,cydial_x1
	move.w	d2,cydial_y1
	move.w	d3,cydial_x2
	move.w	d4,cydial_y2
	jsr		cyberdial	
	subq		#1,cydial_y2
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq.w	#1,d1
	addq.w	#1,d2
	subq.w	#1,d3
	subq.w	#1,d4
	jsr		DRAW_MENU_TEXTURE
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	jsr		Raised_edge
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq		#6,d1
	addq		#6,d2
	subq		#6,d3
	subq		#6,d4
	jsr		Depressed_edge
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	add.w		#7,d1
	add.w		#7,d2
	sub.w		#7,d3
	sub.w		#7,d4
	jsr		Raised_edge
	move.w	cydial_x1,d1
	add.w		#20-2,d1
	move.w	d1,CHAR_X
	move.w	cydial_y1,d2
	addq		#7-2,d2
	move.w	d2,CHAR_Y
	pop.l		a0
	push.l	a0
	move.l	g_text(a0),a0
	sf		CHAR_SOLID
	jsr		solid_text
	pop.l		a0
	move.w	#iface_grey,CHAR_COL
	rts

Setup_frame_up:
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	subq		#1,d3
	subq		#1,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	bsr		Raised_bar
	rts

Setup_miniframe:
	move.w	#147,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3	
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	push.l	a0
	move.w	d1,cydial_x1
	move.w	d2,cydial_y1
	move.w	d3,cydial_x2
	move.w	d4,cydial_y2
	jsr		cyberdial	
	subq		#1,cydial_y2
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq.w	#1,d1
	addq.w	#1,d2
	subq.w	#1,d3
	subq.w	#1,d4
	jsr		DRAW_MENU_TEXTURE
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	jsr		Raised_edge
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq		#6,d1
	addq		#6,d2
	subq		#6,d3
	subq		#6,d4
	jsr		Depressed_edge
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq.w	#7,d1
	addq.w	#7,d2
	subq.w	#7,d3
	subq.w	#7,d4
	jsr		Raised_edge
	move.w	cydial_x1,d1
	add.w		#20-2,d1
	move.w	d1,CHAR_X
	move.w	cydial_y1,d2
	addq		#7-2,d2
	move.w	d2,CHAR_Y
	pop.l		a0
	push.l	a0
	move.l	g_text(a0),a0
	sf		CHAR_SOLID
	jsr		solid_text
	pop.l		a0
	move.w	#iface_grey,CHAR_COL
	rts

Setup_microframe:
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3	
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	push.l	a0
	move.w	d1,cydial_x1
	move.w	d2,cydial_y1
	move.w	d3,cydial_x2
	subq		#1,d4
	move.w	d4,cydial_y2
	jsr		DRAW_MENU_TEXTURE
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	jsr		Raised_edge
	pop.l		a0
	rts

Setup_grovzone:
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3	
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	push.l	a0
	subq		#2,d1
	subq		#2,d2
	addq		#1,d3
	addq		#1,d4
	move.w	d1,cydial_x1
	move.w	d3,cydial_x2
	move.w	d2,cydial_y1
	move.w	d4,cydial_y2
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	jsr		Depressed_bar
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq.w	#1,d1
	addq.w	#1,d2
	subq.w	#1,d3
	subq.w	#1,d4
	jsr		Raised_edge
	pop.l		a0
	rts

Setup_radbutton:
	move.w	#iface_grey-4,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	move.l	g_var(a0),a1
	move.w	(a1),d0
	move.w	g_varlen(a0),d5
	btst		d5,d0
	beq.s		.fals
	tst.b		FIRST_DRAW
	beq.s		.edg1
	bsr		Depressed_bar
	bra.s		.true
.edg1	bsr		Inner_edge
	bra.s		.true
.fals	tst.b		FIRST_DRAW
	beq.s		.edg2
	bsr		Raised_bar
	bra.s		.true
.edg2	bsr		Raised_edge
.true	tst.b		FIRST_DRAW
	beq		Setup_button2
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d1
	subq		#1,d2
	moveq		#iface_black,d0
	bsr		DRAW_MENU_BOX
	popall
	bra		Setup_button2

Setup_outline:
	move.w	#169,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3	
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	push.l	a0
	move.w	d1,cydial_x1
	move.w	d2,cydial_y1
	move.w	d3,cydial_x2
	subq		#1,d4
	move.w	d4,cydial_y2
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	jsr		Depressed_bar
	move.w	cydial_x1,d1
	move.w	cydial_y1,d2
	move.w	cydial_x2,d3
	move.w	cydial_y2,d4
	addq.w	#1,d1
	addq.w	#1,d2
	subq.w	#1,d3
	subq.w	#1,d4
	jsr		Raised_edge
	move.w	cydial_x1,d1
	add.w		#10,d1
	move.w	d1,CHAR_X
	move.w	cydial_y1,d2
	subq		#1,d2
	move.w	d2,CHAR_Y
	pop.l		a0
	push.l	a0
	move.l	g_text(a0),a0
	sf		CHAR_SOLID
	jsr		solid_text
	pop.l		a0
	move.w	#iface_grey,CHAR_COL
	rts
		
Setup_frmbutton:
	move.w	#250,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	move.l	g_var(a0),a1
	move.w	(a1),d0
	move.w	g_varlen(a0),d5
	btst		d5,d0
	beq.s		.fals
	tst.b		FIRST_DRAW
	beq.s		.edg1
	bsr		Depressed_bar_metal
	bra.s		.true
.edg1	bsr		Inner_edge_metal
	bra.s		.true
.fals	tst.b		FIRST_DRAW
	beq.s		.edg2
	bsr		Raised_bar_metal
	bra.s		.true
.edg2	bsr		Raised_edge_metal
.true	tst.b		FIRST_DRAW
	beq		Setup_button
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	subq		#1,d1
	subq		#1,d2
	addq		#1,d3
	addq		#1,d4
	moveq		#iface_black,d0
	bsr		DRAW_MENU_BOX
	popall
	bra		Setup_button

Setup_panbutton:
	move.w	#iface_dgold,CHAR_COL
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	move.l	g_var(a0),a1
	move.w	(a1),d0
	move.w	g_varlen(a0),d5
	btst		d5,d0
	beq.s		.fals
	tst.b		FIRST_DRAW
	beq.s		.edg1
	bsr		Depressed_bar_gold
	bra.s		.true
.edg1	bsr		Inner_edge_gold
	bra.s		.true
.fals	tst.b		FIRST_DRAW
	beq.s		.edg2
	bsr		Raised_bar_gold
	bra.s		.true
.edg2	bsr		Raised_edge_gold
.true	tst.b		FIRST_DRAW
	beq		Setup_button
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	subq		#1,d1
	subq		#1,d2
	addq		#1,d3
	addq		#1,d4
	moveq		#iface_black,d0
	bsr		DRAW_MENU_BOX
	popall	
	bra		Setup_button

Setup_text:
	pushall
	move.w	#iface_grey-4,CHAR_COL
	move.l	g_text(a0),a0
	bsr		PRINT_LINE_ADJ
	move.w	#iface_grey,CHAR_COL
	popall
	rts

Setup_zone:
	rts

Setup_rout:
	pushall
	move.l	g_text(a0),a0
	jsr		(a0)
	popall
	rts

Setup_editbutton:
	move.w	#iface_white,CHAR_COL
	tst.b		FIRST_DRAW
	beq		.ntxt
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	bsr		Raised_bar
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	subq		#1,d1
	subq		#1,d2
	addq		#1,d3
	addq		#1,d4
	moveq		#iface_black,d0
	push.l	a0
	bsr		DRAW_MENU_BOX
	pop.l		a0
	move.l	g_text(a0),d0
	push.l	a0
	bsr		NUM2ASCIIL
	pop.l		a0
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	lea		1+NUM_TEXT,a0
	bsr		centre_justify
	popall	
.ntxt	move.w	#iface_grey,CHAR_COL
	rts

Setup_groove:
	rts
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	subq		#1,d3
	subq		#1,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	subq		#1,d1
	subq		#1,d2
	addq		#1,d3
	addq		#1,d4
	bsr		Raised_edge
	subq		#1,d1
	subq		#1,d2
	addq		#1,d3
	addq		#1,d4
	bsr		Depressed_edge
	rts
	
Setup_button:
	move.l	g_text(a0),d0
	beq.s		.ntxt
	tst.b		FIRST_DRAW
	beq.s		.ntxt
	push.l	a0
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	move.l	d0,a0
	bsr.s		centre_justify
	pop.l		a0
.ntxt	move.w	#iface_grey,CHAR_COL
	rts

Setup_button2
	move.l	g_text(a0),d0
	beq.s		.ntxt
	tst.b		FIRST_DRAW
	beq.s		.ntxt
	push.l	a0
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	move.l	d0,a0
	bsr		left_justify
	pop.l		a0
.ntxt	move.w	#iface_grey,CHAR_COL
	rts

centre_justify:
	move.l	a0,a1
.end	tst.b		(a1)+
	bne.s		.end
	subq.l	#1,a1
	sub.l		a0,a1
	move.l	a1,d5
	mulu		#3,d5
	sub.w		x_factor,d5
	add.w		d2,d4
	lsr.w		d4
	add.w		d1,d3
	lsr.w		d3
	sub.w		d5,d3
	moveq		#5,d0
	cmp.w		#1,x_factor
	beq.s		.ok
	moveq		#7,d0
.ok	lsr.w		d0
	divu		y_factor,d0
	sub.w		d0,d4
	move.w	d3,CHAR_X
	move.w	d4,CHAR_Y
	bsr		PRINT_LINE
	rts

left_justify:
	addq		#8,d3
	move.w	d3,CHAR_X
	add.w		d2,d4
	lsr.w		d4
	moveq		#5,d0
	cmp.w		#1,x_factor
	beq.s		.ok
	moveq		#7,d0
.ok	lsr.w		d0
	divu		y_factor,d0
	sub.w		d0,d4
	move.w	d4,CHAR_Y
	bsr		PRINT_LINE
	rts

solid_text:
	cmp.w		#2,y_factor
	beq.s		.ok2
	subq		#1,CHAR_Y
.ok2	move.l	a0,a1
.end	tst.b		(a1)+
	bne.s		.end
	subq.l	#1,a1
	sub.l		a0,a1
	move.l	a1,d5
	mulu		#6,d5
	move.w	CHAR_X,d1
	move.w	d1,d3
	add.w		d5,d3
	subq		#3,d1
	addq		#1,d3
	move.w	CHAR_Y,d2
	move.w	d2,d4
	moveq		#6,d0
	divu		y_factor,d0
	add.w		d0,d4
	cmp.w		#1,x_factor
	bne.s		.n1
	subq		#1,d2
	subq		#1,d4
.n1	moveq		#iface_lgrey,d0
	jsr		DRAW_MENU_BLOCK
	bsr		PRINT_LINE
	rts

print_brush_menu:
	move.w	BRUSH_TYPE,X_COORD
	move.w	#-1,BRUSH_TYPE
	move.w	#BmenY,d2
	moveq		#2-1,d7
.ylp	push.w	d7
	move.w	#BmenX,d1
	moveq		#8-1,d7
.xlp	push.w	d7
	push.w	d1
	push.w	d2
	add.w		#10,d1
	add.w		#10,d2
	move.w	IFACE_COLOURS+2*iface_dgold,d0
	or.b		gensol,d0
	xresfactor	d1
	yresfactor	d2
	jsr		DRAW_MENU_BRUSH
	pop.w		d2
	pop.w		d1
	pop.w		d7
	add.w		#22,d1
	addq		#1,BRUSH_TYPE
	dbra		d7,.xlp
	pop.w		d7
	add.w		#22,d2
	dbra		d7,.ylp
	move.w	X_COORD,BRUSH_TYPE
	rts

percentage_box:
	pushall
	move.l	a0,a1
	lea		-g_len(sp),sp
	move.l	sp,a0
	move.w	#32+32-16,g_x(a0)
	move.w	#64+16+8,g_y(a0)
	move.w	#256-32,g_w(a0)
	move.w	#96-42-16,g_h(a0)
	move.l	a1,g_text(a0)
	jsr		Setup_miniframe
	lea		g_len(sp),sp
	popall
	rts

;Draw_disk_menu:
;	clr.w		DISKFUNC_BITS
;	lea		dm_text1,a0
;	bsr		PRINT_LINE_ADJ
;	rts

Draw_vidask_menu:
	lea		vidask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_resask_menu:
	lea		resask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_sleepask_menu:
	lea		sleepask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_quitask_menu:
	lea		quitask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_segask_menu:
	lea		segask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_allask_menu:
	lea		allask_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Draw_aboask_menu:
	lea		aboask_text,a0
	bsr		PRINT_LINE_ADJ
	rts
	
Draw_warning_menu:
;	lea		warning_text,a0
;	bsr		PRINT_LINE_ADJ
	rts

Draw_buserr:
	lea		buserr_text,a0
	bsr		PRINT_LINE_ADJ
	rts

Update_video_combo:
	pushall
	bsr		HIDE_MOUSE
	jsr		update_canwid
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	jsr		NUM2ASCIIL
	jsr		show_line
	jsr		update_canhig
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	jsr		NUM2ASCIIL
	jsr		show_line
	bsr		SHOW_MOUSE
	popall
	rts

Update_tween_combo:
	tst.b		tween_dialog
	beq		.no
	pushall
	bsr		HIDE_MOUSE
	move.w	#163+32+6,d1
	move.w	#163+33+6*4+6,d3
	move.w	#189-16,d2
	move.w	#189+4-16,d4
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_BLOCK
	move.w	#163+32+63+16+6,d1
	move.w	#163+33+63+6*4+16+6,d3
	move.w	#189-16,d2
	move.w	#189+4-16,d4
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_BLOCK
	move.w	#163+32+3+6,CHAR_X
	move.w	#189+2-16,CHAR_Y
	jsr		Centre_CHAR_Y
	move.w	SEGMENT_START,d0
	addq		#1,d0
	moveq		#4,d1
	bsr		NUM2ASCII_LZ
	bsr		PRINT_ASCIINUM
	move.w	#163+32+63+3+16+6,CHAR_X
	move.w	SEGMENT_END,d0
	addq		#1,d0
	moveq		#4,d1
	bsr		NUM2ASCII_LZ
	bsr		PRINT_ASCIINUM
	bsr		SHOW_MOUSE
	popall
.no	rts

*-----------------------------------------------------------------------*
*	Icon/menu graphic primitives							*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Grey bars										*
*-----------------------------------------------------------------------*

Raised_edge_direct:
	pushall
	bra.s		RE_direct

Raised_bar_direct:
	pushall
	bra		RB_direct
	
Raised_edge:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4

RE_direct:
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra.s		Redge

Raised_bar:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4

RB_direct:
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_lgrey,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Redge	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	moveq		#iface_white,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	moveq		#iface_grey,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	moveq		#iface_grey,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	moveq		#iface_white,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_DOT
	popall
	rts

Inner_edge:
	
Depressed_edge:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra.s		Dedge

Depressed_bar:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_lgrey,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Dedge	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	moveq		#iface_grey,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	moveq		#iface_white,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	moveq		#iface_white,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	moveq		#iface_grey,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	moveq		#iface_lgrey,d0
	bsr		DRAW_MENU_DOT
	popall
	rts

*-----------------------------------------------------------------------*
*	Blue bars										*
*-----------------------------------------------------------------------*

Raised_edge_metal:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra		Redge_metal

Raised_bar_metal:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_metal,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Redge_metal
	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	#iface_lmetal,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	move.w	#iface_dmetal,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	move.w	#iface_dmetal,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	move.w	#iface_lmetal,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	#iface_metal,d0
	bsr		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	#iface_metal,d0
	bsr		DRAW_MENU_DOT
	popall
	rts

Inner_edge_metal:
	
Depressed_edge_metal:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra.s		Dedge_metal

Depressed_bar_metal:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_metal,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Dedge_metal
	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	#iface_dmetal,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	move.w	#iface_lmetal,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	move.w	#iface_lmetal,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	move.w	#iface_dmetal,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	#iface_metal,d0
	bsr		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	#iface_metal,d0
	bsr		DRAW_MENU_DOT
	popall
	rts

*-----------------------------------------------------------------------*
*	Gold bars										*
*-----------------------------------------------------------------------*

Raised_edge_gold:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra		Redge_gold

Raised_bar_gold:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_gold,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Redge_gold
	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	#iface_lgold,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	move.w	#iface_dgold,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	move.w	#iface_dgold,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	move.w	#iface_lgold,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	#iface_gold,d0
	bsr		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	#iface_gold,d0
	bsr		DRAW_MENU_DOT
	popall
	rts

Inner_edge_gold:
	
Depressed_edge_gold:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	bra.s		Dedge_gold

Depressed_bar_gold:
;	d1,d2		x1,y1
;	d3,d4		x2,y2
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_gold,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_BLOCK
Dedge_gold
	move.w	box_x1(a6),d1
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	#iface_dgold,d0
	bsr		horizontal_menuline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	addq		#1,d2
	move.w	#iface_lgold,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	addq		#1,d2
	move.w	#iface_lgold,d0
	bsr		horizontal_menuline
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y1(a6),d4
	subq		#1,d2
	move.w	#iface_dgold,d0
	bsr		DRAW_MENU_LINE
	move.w	box_x1(a6),d1
	move.w	box_y2(a6),d2
	move.w	#iface_gold,d0
	bsr.s		DRAW_MENU_DOT
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	#iface_gold,d0
	bsr.s		DRAW_MENU_DOT
	popall
	rts
	
*-----------------------------------------------------------------------*
*	Basic primitives									*
*-----------------------------------------------------------------------*

DRAW_MENU_DOT:
	and.w		#$FF,d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0
	move.l	PHYS_SCR,a0
	move.w	physwid,scrwid
	bra.s		WRITE_PIXEL

PLOT_LOG_DOT:
	tst.w		d1
	bmi.s		RTS
	tst.w		d2
	bmi.s		RTS
	cmp.w		CANVAS_WIDTH,d1
	bge.s		RTS
	cmp.w		CANVAS_HEIGHT,d2
	bge.s		RTS
	move.l	LOG_SCR,a0
	move.w	logwid,scrwid
*-----------------------------------*
WRITE_PIXEL:
;	d0		colour
;	d1,d2		x,y
*-----------------------------------*
	tst.b		TRUE_FLAG
	bne.s		WRITE_PIXEL_TRUE
	moveq		#-16,d7
	and.w		d1,d7
	add.w		d7,a0
	move.w	d2,d7
	mulu		scrwid,d7
	add.l		d7,a0
	moveq		#1,d7
	swap		d7
	addq		#1,d7
	addq		#1,d1
	ror.l		d1,d7	
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1-d4
	not.l		d7
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	lea		-16(a0),a0
	not.l		d7
	move.l	d1,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d2,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d3,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d4,d5
	and.l		d7,d5
	or.l		d5,(a0)+
RTS:	rts

WRITE_PIXEL_TRUE:
	add.w		d1,d1
	add.w		d1,a0
	mulu		scrwid,d2
	add.l		d2,a0
	move.w	d0,(a0)
	rts

WRITE_PIXEL_GEN:
	tst.b		TRUE_FLAG
	bne.s		WRITE_PIXEL_TRUE
	move.w	d1,d7
	lsr.w		#4,d7
	mulu		wrdwid,d7
	add.l		d7,a0
	move.w	d2,d7
	mulu		scrwid,d7
	add.l		d7,a0
	moveq		#1,d7
	swap		d7
	addq		#1,d7
	addq		#1,d1
	ror.l		d1,d7	
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1-d4
	not.l		d7
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	and.l		d7,(a0)+
	lea		-16(a0),a0
	not.l		d7
	move.l	d1,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d2,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d3,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	move.l	d4,d5
	and.l		d7,d5
	or.l		d5,(a0)+
	rts

DRAW_MENU_LINE:
	and.w		#$FF,d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0

DRAW_PHYS_LINE:
	move.l	PHYS_SCR,a0
	move.w	physwid,scrwid
	bra.s		DRAW_LINE

DRAW_LOG_LINE:
	move.l	LOG_SCR,a0
	move.w	logwid,scrwid

DRAW_LINE:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	tst.b		TRUE_FLAG
	bne		DRAW_LINE_TRUE
	movem.l	d5-d7/a1-a6,-(sp)
	move.w	d0,a6
*-----------------------------------*
*	Reduce to quadrant		*
*-----------------------------------*
	moveq		#1,d6			; quadrant no.
	move.w	scrwid,d7
	cmp.w		d2,d4
	bpl.s		.T_B
	neg.w		d7
	neg.w		d6
.T_B:	cmp.w		d1,d3
	bpl.s		.L_R
	exg		d1,d3
	exg		d2,d4
	neg.w		d7
	add.w		d6,d6
.L_R:	addq		#1,d4
	tst.w		d7
	bpl.s		.down
	subq		#2,d4
.down	addq		#2,d3
	ext.l		d7
*-----------------------------------*
*	Access screen address		*
*-----------------------------------*
	moveq		#-16,d0
	and.w		d1,d0
	add.w		d0,a0
	move.w	d2,d0
	mulu		scrwid,d0
	add.l		d0,a0
	moveq		#1,d0
	swap		d0
	addq		#1,d0
	addq		#1,d1
	ror.l		d1,d0	
*-----------------------------------*
*	Is line acute/obtuse?		*
*-----------------------------------*
	sub.w		d1,d3
	sub.w		d2,d4
	bpl.s		.posi
	neg.w		d4
.posi	cmp.w		d4,d3
	blt.s		.Ylop			; obtuse angles
	bgt.s		.Xlop			; acute angles
	moveq		#1,d4
	swap		d4
	moveq		#0,d5
	bra.s		.Diag
*-----------------------------------*
.Xlop	swap		d4			; acute angle
	clr.w		d4
	divu		d3,d4			; m = dy / dx
	swap		d4			; clear remainder
	clr.w		d4
	swap		d4
	move.l	d4,d5
	lsr.w		d5
.Diag	subq		#1,d3
	bmi		.rts
	move.w	a6,d6
	add.w		d6,d6
	movem.l	(PLANE_TABLE.l,d6.w*8),d1/d2/a5/a6
.xlp	not.l		d0
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	not.l		d0
	lea		-16(a0),a0
	move.l	d1,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	d2,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a5,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a6,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	lea		-16(a0),a0
	add.l		d4,d5			; sum dy's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvy			; no
	clr.w		d5			; yes
	add.l		d7,a0			; move in y
.nmvy	ror.l		d0			; move in x
	bcc.s		.nxwr			; wrap round in x yet ?
	lea		16(a0),a0
.nxwr	swap		d5
	dbra		d3,.xlp
	bra.s		.rts
*-----------------------------------*
.Ylop	swap		d3			; acute angle
	clr.w		d3
	divu		d4,d3			; m = dy / dx
	swap		d3			; clear remainder
	clr.w		d3
	swap		d3
	move.l	d3,d5
	lsr.w		d5
	subq		#1,d4
	bmi.s		.rts
	move.w	a6,d6
	add.w		d6,d6
	movem.l	(PLANE_TABLE.l,d6.w*8),d1/d2/a5/a6
.ylp	not.l		d0
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	not.l		d0
	lea		-16(a0),a0
	move.l	d1,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	d2,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a5,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a6,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	lea		-16(a0),a0
	add.l		d3,d5			; sum dx's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvx			; no
	clr.w		d5			; yes
	ror.l		d0			; move in x
	bcc.s		.nmvx			; wrap round in x yet ?
	lea		16(a0),a0
.nmvx	add.l		d7,a0			; move in y
	swap		d5
	dbra		d4,.ylp
.rts	movem.l	(sp)+,d5-d7/a1-a6
	rts

DRAW_LINE_TRUE:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	movem.l	d5-d7/a1-a6,-(sp)
	move.w	d0,a6
*-----------------------------------*
*	Reduce to quadrant		*
*-----------------------------------*
	moveq		#1,d6			; quadrant no.
	move.w	scrwid,d7
	cmp.w		d2,d4
	bpl.s		.T_B
	neg.w		d7
	neg.w		d6
.T_B:	cmp.w		d1,d3
	bpl.s		.L_R
	exg		d1,d3
	exg		d2,d4
	neg.w		d7
	add.w		d6,d6
.L_R:	addq		#1,d4
	tst.w		d7
	bpl.s		.down
	subq		#2,d4
.down	addq		#2,d3
	ext.l		d7
*-----------------------------------*
*	Access screen address		*
*-----------------------------------*
	move.w	d1,d0
	add.w		d0,d0
	add.w		d0,a0
	move.w	d2,d0
	mulu		scrwid,d0
	add.l		d0,a0
	addq		#1,d1
*-----------------------------------*
*	Is line acute/obtuse?		*
*-----------------------------------*
	sub.w		d1,d3
	sub.w		d2,d4
	bpl.s		.posi
	neg.w		d4
.posi	cmp.w		d4,d3
	blt.s		.Ylop			; obtuse angles
	bgt.s		.Xlop			; acute angles
	moveq		#1,d4
	swap		d4
	moveq		#0,d5
	bra.s		.Diag
*-----------------------------------*
.Xlop	swap		d4			; acute angle
	clr.w		d4
	divu		d3,d4			; m = dy / dx
	swap		d4			; clear remainder
	clr.w		d4
	swap		d4
	move.l	d4,d5
	lsr.w		d5
.Diag	subq		#1,d3
	bmi.s		.rts
.xlp	move.w	a6,(a0)+
	add.l		d4,d5			; sum dy's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvy			; no
	clr.w		d5			; yes
	add.l		d7,a0			; move in y
.nmvy	swap		d5
	dbra		d3,.xlp
	bra.s		.rts
*-----------------------------------*
.Ylop	swap		d3			; acute angle
	clr.w		d3
	divu		d4,d3			; m = dy / dx
	swap		d3			; clear remainder
	clr.w		d3
	swap		d3
	move.l	d3,d5
	lsr.w		d5
	subq		#1,d4
	bmi.s		.rts
.ylp	move.w	a6,(a0)
	add.l		d3,d5			; sum dx's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvx			; no
	clr.w		d5			; yes
	addq.l	#2,a0
.nmvx	add.l		d7,a0			; move in y
	swap		d5
	dbra		d4,.ylp
.rts	movem.l	(sp)+,d5-d7/a1-a6
	rts

DRAW_GRADLINE:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	tst.b		TRUE_FLAG
	bne		DRAW_GRADLINE_TRUE
	movem.l	d5-d7/a1-a6,-(sp)
	move.w	d0,a6
*-----------------------------------*
*	Reduce to quadrant		*
*-----------------------------------*
	moveq		#1,d6			; quadrant no.
	move.w	scrwid,d7
	cmp.w		d2,d4
	bpl.s		.T_B
	neg.w		d7
	neg.w		d6
.T_B:	cmp.w		d1,d3
	bpl.s		.L_R
	exg		d1,d3
	exg		d2,d4
	move.w	Point_RED1,d0
	move.w	Point_RED2,Point_RED1
	move.w	d0,Point_RED2
	neg.w		d7
	add.w		d6,d6
.L_R:	addq		#1,d4
	tst.w		d7
	bpl.s		.down
	subq		#2,d4
.down	addq		#2,d3
	move.w	d7,.ls
*-----------------------------------*
*	Access screen address		*
*-----------------------------------*
	moveq		#-16,d0
	and.w		d1,d0
	add.w		d0,a0
	move.w	d2,d0
	mulu		scrwid,d0
	add.l		d0,a0
	moveq		#1,d0
	swap		d0
	addq		#1,d0
	addq		#1,d1
	ror.l		d1,d0	
*-----------------------------------*
*	Is line acute/obtuse?		*
*-----------------------------------*
	sub.w		d1,d3
	sub.w		d2,d4
	bpl.s		.posi
	neg.w		d4
.posi	cmp.w		d4,d3
	blt		.Ylop			; obtuse angles
	bgt.s		.Xlop			; acute angles
	moveq		#1,d4
	swap		d4
	moveq		#0,d5
	move.w	d3,d6
	move.w	(Div65536.l,d3.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d4,a1
	moveq		#0,d7
	bra.s		.Diag
*-----------------------------------*
.Xlop	swap		d4			; acute angle
	clr.w		d4
	divu		d3,d4			; m = dy / dx
	swap		d4			; clear remainder
	clr.w		d4
	swap		d4
	move.w	d3,d6
	move.w	(Div65536.l,d3.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d4,a1
	move.l	d4,d7
	lsr.w		d7
.Diag	move.w	Point_RED2,d5
	move.w	Point_RED1,d2
	sub.w		d2,d5
	muls		Point_scale,d5
	add.l		d5,d5
	swap		d5
	ext.l		d2
	swap		d6
	move.w	d2,d6
	add.l		d5,d2
	move.w	d6,d2
	swap		d6
	move.w	ccr,(a2)
	bra.s		.xs
*-----------------------------------*
.xlp	move.l	d6,a3
	move.w	(a2),ccr
	addx.l	d5,d2
	move.w	ccr,(a2)
	move.w	d2,d6
	lsr.w		#7,d6
	add.w		d6,d6
	movem.l	(PLANE_TABLE.l,d6.w*8),d1/a4/a5/a6
	not.l		d0
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	not.l		d0
	lea		-16(a0),a0
	move.l	d1,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a4,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a5,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a6,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	lea		-16(a0),a0
	move.l	a3,d6
	add.l		a1,d7			; sum dy's
	swap		d7
	tst.w		d7			; changed yet ?
	beq.s		.nmvy			; no
	clr.w		d7			; yes
	add.w		.ls(pc),a0		; move in y
.nmvy	ror.l		d0			; move in x
	bcc.s		.nxwr			; wrap round in x yet ?
	lea		16(a0),a0
.nxwr	swap		d7
.xs	dbra		d6,.xlp
	bra		.rts
*-----------------------------------*
.Ylop	swap		d3			; acute angle
	clr.w		d3
	divu		d4,d3			; m = dy / dx
	swap		d3			; clear remainder
	clr.w		d3
	swap		d3
	move.w	d4,d6
	move.w	(Div65536.l,d4.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d3,a1
	move.l	d3,d7
	lsr.w		d7
	move.w	Point_RED2,d5
	move.w	Point_RED1,d2
	sub.w		d2,d5
	muls		Point_scale,d5
	add.l		d5,d5
	swap		d5
	ext.l		d2
	swap		d6
	move.w	d2,d6
	add.l		d5,d2
	move.w	d6,d2
	swap		d6
	move.w	ccr,(a2)
	bra.s		.ys
*-----------------------------------*
.ylp	move.l	d6,a3
	move.w	(a2),ccr
	addx.l	d5,d2
	move.w	ccr,(a2)
	move.w	d2,d6
	lsr.w		#7,d6
	add.w		d6,d6
	movem.l	(PLANE_TABLE.l,d6.w*8),d1/a4/a5/a6
	not.l		d0
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	and.l		d0,(a0)+
	not.l		d0
	lea		-16(a0),a0
	move.l	d1,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a4,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a5,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	move.l	a6,d6
	and.l		d0,d6
	or.l		d6,(a0)+
	lea		-16(a0),a0
	move.l	a3,d6
	add.l		a1,d7			; sum dx's
	swap		d7
	tst.w		d7			; changed yet ?
	beq.s		.nmvx			; no
	clr.w		d7			; yes
	ror.l		d0			; move in x
	bcc.s		.nmvx			; wrap round in x yet ?
	lea		16(a0),a0
.nmvx	add.w		.ls(pc),a0		; move in y
	swap		d7
.ys	dbra		d6,.ylp
*-----------------------------------*
.rts	movem.l	(sp)+,d5-d7/a1-a6
	rts
.ls	ds.w		1
.xtnd	ds.w		1

DRAW_GRADLINE_TRUE:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	movem.l	d5-d7/a1-a6,-(sp)
	move.w	d0,a6
*-----------------------------------*
*	Reduce to quadrant		*
*-----------------------------------*
	moveq		#1,d6			; quadrant no.
	move.w	scrwid,d7
	cmp.w		d2,d4
	bpl.s		.T_B
	neg.w		d7
	neg.w		d6
.T_B:	cmp.w		d1,d3
	bpl.s		.L_R
	exg		d1,d3
	exg		d2,d4
	move.w	Point_RED1,d0
	move.w	Point_RED2,Point_RED1
	move.w	d0,Point_RED2
	move.w	Point_GREEN1,d0
	move.w	Point_GREEN2,Point_GREEN1
	move.w	d0,Point_GREEN2
	move.w	Point_BLUE1,d0
	move.w	Point_BLUE2,Point_BLUE1
	move.w	d0,Point_BLUE2
	neg.w		d7
	add.w		d6,d6
.L_R:	addq		#1,d4
	tst.w		d7
	bpl.s		.down
	subq		#2,d4
.down	addq		#2,d3
	move.w	d7,.ls
*-----------------------------------*
*	Access screen address		*
*-----------------------------------*
	move.w	d1,d0
	add.w		d0,d0
	add.w		d0,a0
	move.w	d2,d0
	mulu		scrwid,d0
	add.l		d0,a0
	addq		#1,d1
*-----------------------------------*
*	Is line acute/obtuse?		*
*-----------------------------------*
	sub.w		d1,d3
	sub.w		d2,d4
	bpl.s		.posi
	neg.w		d4
.posi	cmp.w		d4,d3
	blt		.Ylop			; obtuse angles
	bgt.s		.Xlop			; acute angles
	moveq		#1,d4
	swap		d4
	moveq		#0,d5
	move.w	d3,d6
	move.w	(Div65536.l,d3.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d4,a1
	moveq		#0,d7
	bra.s		.Diag
*-----------------------------------*
.Xlop	swap		d4			; acute angle
	clr.w		d4
	divu		d3,d4			; m = dy / dx
	swap		d4			; clear remainder
	clr.w		d4
	swap		d4
	move.w	d3,d6
	move.w	(Div65536.l,d3.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d4,a1
	move.l	d4,d7
	lsr.w		d7
.Diag	move.w	Point_RED2,d3
	move.w	Point_RED1,d0
	move.w	Point_GREEN2,d4
	move.w	Point_GREEN1,d1
	move.w	Point_BLUE2,d5
	move.w	Point_BLUE1,d2
	sub.w		d0,d3
	sub.w		d1,d4
	sub.w		d2,d5
	muls		Point_scale,d3
	muls		Point_scale,d4
	muls		Point_scale,d5
	add.l		d3,d3
	add.l		d4,d4
	add.l		d5,d5
	swap		d6
	move.w	d3,d6
	move.w	d4,d3
	move.w	d5,d4
	move.w	d6,d5
	swap		d3
	swap		d4
	swap		d5
	ext.l		d0
	ext.l		d1
	ext.l		d2
	move.w	d2,d6
	add.l		d5,d2
	move.w	d6,d2
	swap		d6
	move.w	ccr,(a2)
	bra.s		.xs
*-----------------------------------*
.xlp	move.l	d6,a3
	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	move.w	(a2),ccr
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	ccr,(a2)
	move.w	d6,(a0)+
	move.l	a3,d6
	add.l		a1,d7			; sum dy's
	swap		d7
	tst.w		d7			; changed yet ?
	beq.s		.nmvy			; no
	clr.w		d7			; yes
	add.w		.ls(pc),a0		; move in y
.nmvy	swap		d7
.xs	dbra		d6,.xlp
	bra		.rts
*-----------------------------------*
.Ylop	swap		d3			; acute angle
	clr.w		d3
	divu		d4,d3			; m = dy / dx
	swap		d3			; clear remainder
	clr.w		d3
	swap		d3
	move.w	d4,d6
	move.w	(Div65536.l,d4.w*2),Point_scale	; 1/length
	lea		.xtnd(pc),a2
	move.l	d3,a1
	move.l	d3,d7
	lsr.w		d7
	move.w	Point_RED2,d3
	move.w	Point_RED1,d0
	move.w	Point_GREEN2,d4
	move.w	Point_GREEN1,d1
	move.w	Point_BLUE2,d5
	move.w	Point_BLUE1,d2
	sub.w		d0,d3
	sub.w		d1,d4
	sub.w		d2,d5
	muls		Point_scale,d3
	muls		Point_scale,d4
	muls		Point_scale,d5
	add.l		d3,d3
	add.l		d4,d4
	add.l		d5,d5
	swap		d6
	move.w	d3,d6
	move.w	d4,d3
	move.w	d5,d4
	move.w	d6,d5
	swap		d3
	swap		d4
	swap		d5
	ext.l		d0
	ext.l		d1
	ext.l		d2
	move.w	d2,d6
	add.l		d5,d2
	move.w	d6,d2
	swap		d6
	move.w	ccr,(a2)
	bra.s		.ys
*-----------------------------------*
.ylp	move.l	d6,a3
	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	move.w	(a2),ccr
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	ccr,(a2)
	move.w	d6,(a0)
	move.l	a3,d6
	add.l		a1,d7			; sum dx's
	swap		d7
	tst.w		d7			; changed yet ?
	beq.s		.nmvx			; no
	clr.w		d7			; yes
	addq.l	#2,a0
.nmvx	add.w		.ls(pc),a0		; move in y
	swap		d7
.ys	dbra		d6,.ylp
*-----------------------------------*
.rts	movem.l	(sp)+,d5-d7/a1-a6
	rts
.ls	ds.w		1
.xtnd	ds.w		1

DRAW_PHYS_BRUSHLINE:
	move.l	PHYS_SCR,a0
	move.w	X_RESOLUTION,SCR_WIDTH
	move.w	Y_RESOLUTION,SCR_HEIGHT
	move.w	physwid,scrwid
	bra.s		DRAW_BRUSHLINE
	
DRAW_LOG_BRUSHLINE:
	move.l	LOG_SCR,a0
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	move.w	logwid,scrwid

DRAW_BRUSHLINE:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
*-----------------------------------*
*	Reduce to quadrant		*
*-----------------------------------*
	tst.w		BRUSH_TYPE
	bmi		DRAW_LINE
	moveq		#1,d7
	moveq		#1,d6
	cmp.w		d2,d4
	bpl.s		.T_B
	neg.w		d7
.T_B:	cmp.w		d1,d3
	bpl.s		.L_R
	exg		d1,d3
	exg		d2,d4
	neg.w		d7
.L_R:	addq		#1,d4
	tst.w		d7
	bpl.s		.down
	subq		#2,d4
.down	addq		#1,d3
*-----------------------------------*
*	Is line acute/obtuse?		*
*-----------------------------------*
	sub.w		d1,d3
	sub.w		d2,d4
	bpl.s		.posi
	neg.w		d4
.posi	cmp.w		d4,d3			; find appropriate routine
	blt.s		.Ylop			; obtuse angles
	bgt.s		.Xlop			; acute angles
	moveq		#1,d4
	swap		d4
	moveq		#0,d5
	bra.s		.Diag
*-----------------------------------*
.Xlop	swap		d4			; acute angle
	clr.w		d4
	divu		d3,d4			; m = dy / dx
	swap		d4			; clear remainder
	clr.w		d4
	swap		d4
	move.l	d4,d5
	lsr.w		d5
.Diag	subq		#1,d3
	bmi.s		.rts
.xlp	movem.l	d0-d6/d7/a0,-(sp)
	jsr		print_brush
	movem.l	(sp)+,d0-d6/d7/a0
	add.l		d4,d5			; sum dy's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvy			; no
	clr.w		d5			; yes
	add.w		d7,d2			; move in y
.nmvy	add.w		d6,d1
	swap		d5
	dbra		d3,.xlp
	bra.s		.rts
*-----------------------------------*
.Ylop	swap		d3			; acute angle
	clr.w		d3
	divu		d4,d3			; m = dy / dx
	swap		d3			; clear remainder
	clr.w		d3
	swap		d3
	move.l	d3,d5
	lsr.w		d5
	subq		#1,d4
	bmi.s		.rts
.ylp	movem.l	d0-d6/d7/a0,-(sp)
	jsr		print_brush
	movem.l	(sp)+,d0-d6/d7/a0
	add.l		d3,d5			; sum dx's
	swap		d5
	tst.w		d5			; changed yet ?
	beq.s		.nmvx			; no
	clr.w		d5			; yes
	add.w		d6,d1
.nmvx	add.w		d7,d2			; move in y
	swap		d5
	dbra		d4,.ylp
.rts	rts

DRAW_MENU_BLOCK:
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	and.w		#$FF,d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0
	bsr.s		DRAW_PHYS_BLOCK
	popall
	rts
	
DRAW_PHYS_BLOCK:
	move.l	PHYS_SCR,a0
	move.w	physwid,scrwid
	bra.s		Draw_block

DRAW_LOG_BLOCK:
	cmp.w		d1,d3
	bge.s		.ns1
	exg		d1,d3
.ns1	cmp.w		d2,d4
	bge.s		.ns2
	exg		d2,d4
.ns2	move.l	LOG_SCR,a0
	move.w	logwid,scrwid
	move.w	BOX2_BITS,d5
	btst		#Bit_BOX2_SOLID,d5
	beq		DRAW_LOG_CLIPBOX
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2

Draw_block:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen

	tst.b		TRUE_FLAG
	bne		Draw_block_true
	pushall


	rept		1
	
	cmp.w		d1,d3
	bpl.s		.xok
	exg		d1,d3
.xok:	cmp.w		d2,d4
	bpl.s		.yok
	exg		d2,d4
*-------------------------------------------------------*
*	Address screen location				*
*-------------------------------------------------------*
.yok:	lea		PLANE_TABLE,a6
	move.w		d2,d6
	mulu.w		scrwid,d6
	moveq		#-16,d7
	and.w		d1,d7
	add.l		d6,a0
	add.w		d7,a0
*-------------------------------------------------------*
*	Generate endmasks				*
*-------------------------------------------------------*
	moveq		#16-1,d6
	and.w		d1,d6
	moveq		#-1,d7
	lsr.w		d6,d7
	swap		d7
	lsr.w		d6,d7
	moveq		#-1,d6
	sub.w		d3,d6
	and.w		#16-1,d6
	moveq		#-1,d5
	lsl.w		d6,d5
	swap		d5
	lsl.w		d6,d5	
*-------------------------------------------------------*
*	Calculate line height				*
*-------------------------------------------------------*
	sub.w		d2,d4
*-------------------------------------------------------*
*	Calculate word length				*
*-------------------------------------------------------*
	moveq		#-16,d6
	and.w		d6,d1
	and.w		d6,d3
	sub.w		d1,d3
	lsr.w		#4,d3
*-------------------------------------------------------*
*	Calculate line-wrap increment			*
*-------------------------------------------------------*
	move.w		d3,d2
	addq.w		#1,d2
	lsl.w		#4,d2
	neg.w		d2
	add.w		scrwid,d2
	move.w		d2,a2
*-------------------------------------------------------*
*	Check for one-wide case				*
*-------------------------------------------------------*
	subq.w		#1,d3
	bmi		.single_word
*-------------------------------------------------------*
*	Read plane data					*
*-------------------------------------------------------*
	add.w		d0,d0
	movem.l		(a6,d0.w*8),a3-a6
*-------------------------------------------------------*
*	Endmask optimisations				*
*-------------------------------------------------------*
	btst		#15,d7
	bne		.multi_word_nle
	btst		#0,d5
	bne		.multi_word_nre
*-------------------------------------------------------*
*	Check for two-wide case				*
*-------------------------------------------------------*
	subq.w		#1,d3
	bmi		.double_word
*-------------------------------------------------------*
*	Multi word case					*
*-------------------------------------------------------*
.multi_word:
*-------------------------------------------------------*
	swap		d4
	move.w		d3,d4
	swap		d4
*-------------------------------------------------------*
.multi_loop:
*-------------------------------------------------------*
	swap		d4
	move.l		a0,a1
	move.l		(a0)+,d2
	move.l		d7,d1
	not.l		d1
	move.l		a3,d0
	and.l		d7,d0
	move.l		(a0)+,d3
	and.l		d1,d2
	or.l		d0,d2
	move.l		a4,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d7,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		d3,(a1)+
	move.l		d5,d1
	not.l		d1
	move.w		d4,d3
.xlp:	move.l		a3,(a0)+
	move.l		a4,(a0)+
	move.l		a5,(a0)+
	move.l		a6,(a0)+
	dbra		d4,.xlp
	move.w		d3,d4
	move.l		a0,a1
	move.l		(a0)+,d2
	move.l		a3,d0
	and.l		d5,d0
	and.l		d1,d2
	move.l		(a0)+,d3
	or.l		d0,d2
	move.l		a4,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d5,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		d3,(a1)+
	add.l		a2,a0
	swap		d4
	dbra		d4,.multi_loop
	bra		.rts
*-------------------------------------------------------*
*	Multi word case with no right endmask		*
*-------------------------------------------------------*
.multi_word_nre:
*-------------------------------------------------------*
	move.w		d3,d5
	move.l		d7,d1
	not.l		d1
*-------------------------------------------------------*
.multi_nre_loop:
*-------------------------------------------------------*
	move.l		a0,a1
	move.l		(a0)+,d2
	move.l		a3,d0
	and.l		d7,d0
	move.l		(a0)+,d3
	and.l		d1,d2
	or.l		d0,d2
	move.l		a4,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d7,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		d3,(a1)+
	move.w		d5,d3
.nrxl:	move.l		a3,(a0)+
	move.l		a4,(a0)+
	move.l		a5,(a0)+
	move.l		a6,(a0)+
	dbra		d3,.nrxl
	add.l		a2,a0
	dbra		d4,.multi_nre_loop
	bra		.rts
*-------------------------------------------------------*
*	Multi word case with no left endmask		*
*-------------------------------------------------------*
.multi_word_nle:
*-------------------------------------------------------*
	btst		#0,d5
	bne.s		.multi_word_ne
*-------------------------------------------------------*
	move.w		d3,d7
	move.l		d5,d1
	not.l		d1
*-------------------------------------------------------*
.multi_nle_loop:
*-------------------------------------------------------*
	move.l		a0,a1
	move.w		d7,d3
.nlxl:	move.l		a3,(a0)+
	move.l		a4,(a0)+
	move.l		a5,(a0)+
	move.l		a6,(a0)+
	dbra		d3,.nlxl
	move.l		a0,a1
	move.l		(a0)+,d2
	move.l		a3,d0
	and.l		d5,d0
	and.l		d1,d2
	move.l		(a0)+,d3
	or.l		d0,d2
	move.l		a4,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d5,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		d3,(a1)+
	add.l		a2,a0
	dbra		d4,.multi_nle_loop
	bra		.rts
*-------------------------------------------------------*
.single_word_ne:
*-------------------------------------------------------*
	lsl.w		#4,d0
	add.w		d0,a6
	movem.l		(a6),a3-a6
*-------------------------------------------------------*
*	Multi word case with endmasks			*
*-------------------------------------------------------*
.multi_word_ne:
*-------------------------------------------------------*
	addq.w		#1,d3
*-------------------------------------------------------*
.multi_ne_loop:
*-------------------------------------------------------*
	move.w		d3,d5
.nexl:	move.l		a3,(a0)+
	move.l		a4,(a0)+
	move.l		a5,(a0)+
	move.l		a6,(a0)+
	dbra		d5,.nexl
	add.l		a2,a0
	dbra		d4,.multi_ne_loop
	bra		.rts
*-------------------------------------------------------*
*	Single word case				*
*-------------------------------------------------------*
.single_word:
*-------------------------------------------------------*
	and.l		d7,d5
	move.l		d5,d1
	not.l		d1
	beq.s		.single_word_ne
*-------------------------------------------------------*
	lsl.w		#4,d0
	add.w		d0,a6
	move.l		(a6)+,d1
	move.l		(a6)+,d2
	and.l		d5,d1
	move.l		(a6)+,d3
	and.l		d5,d2
	move.l		(a6)+,d6
	and.l		d5,d3
	and.l		d5,d6
	not.l		d5
*-------------------------------------------------------*
.single_loop:
*-------------------------------------------------------*
	move.l		a0,a1
	move.l		(a0)+,d0
	and.l		d5,d0
	move.l		(a0)+,d7
	or.l		d1,d0
	move.l		d0,(a1)+
	and.l		d5,d7
	move.l		(a0)+,d0
	or.l		d2,d7
	move.l		d7,(a1)+
	and.l		d5,d0
	move.l		(a0)+,d7
	or.l		d3,d0
	move.l		d0,(a1)+
	and.l		d5,d7
	or.l		d6,d7
	move.l		d7,(a1)+
	add.l		a2,a0
	dbra		d4,.single_loop
	bra		.rts
*-------------------------------------------------------*
*	Double word case				*
*-------------------------------------------------------*
.double_word:
*-------------------------------------------------------*
	move.l		a0,a1
	move.l		(a0)+,d2
	move.l		d7,d1
	not.l		d1
	move.l		a3,d0
	and.l		d7,d0
	move.l		(a0)+,d3
	and.l		d1,d2
	or.l		d0,d2
	move.l		a4,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d7,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d7,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		d5,d1
	not.l		d1
	move.l		d3,(a1)+
	move.l		a3,d0
	and.l		d5,d0
	and.l		d1,d2
	move.l		(a0)+,d3
	or.l		d0,d2
	move.l		a4,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	move.l		(a0)+,d2
	move.l		a5,d0
	and.l		d5,d0
	move.l		d3,(a1)+
	and.l		d1,d2
	or.l		d0,d2
	move.l		(a0)+,d3
	move.l		a6,d0
	and.l		d5,d0
	move.l		d2,(a1)+
	and.l		d1,d3
	or.l		d0,d3
	add.l		a2,a0
	move.l		d3,(a1)+
	dbra		d4,.double_word
.rts:	popall
	rts

	endr

	rept		0

	move.w		d0,a6
.got	cmp.w		d1,d3
	bge.s		.xok
	exg		d1,d3
.xok	cmp.w		d2,d4
	bge.s		.yok
	exg		d2,d4
.yok	moveq		#-16,d0
	and.w		d1,d0
	add.w		d0,a0
	moveq		#-1,d0
	move.w	d1,d6
	and.w		#16-1,d6
	lsr.w		d6,d0
	move.w	d0,d6
	swap		d0
	move.w	d6,d0
	move.w	d3,d6
	addq		#1,d6
	neg.w		d6
	and.w		#16-1,d6
	moveq		#-1,d5
	lsl.w		d6,d5
	move.w	d5,d6
	swap		d5
	move.w	d6,d5		
	move.w	d2,d6
	mulu		scrwid,d6
	add.l		d6,a0
	and.w		#-16,d1
	and.w		#-16,d3
	sub.w		d1,d3
	lsr.w		#4,d3
	sub.w		d2,d4
	move.w	a6,d6
	add.w		d6,d6
	movem.l	(PLANE_TABLE.l,d6.w*8),a3/a4/a5/a6
	move.w	scrwid,d6
	ext.l		d6
	subq		#1,d3
	bmi		.one
	beq		.two
	subq		#1,d3
.ylp	swap		d4
	move.l	a0,a1
	move.l	d0,d1
	not.l		d1
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a3,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a4,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a5,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a6,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.w	d3,d4
.xlp	move.l	a3,(a1)+
	move.l	a4,(a1)+
	move.l	a5,(a1)+
	move.l	a6,(a1)+
	dbra		d4,.xlp
	move.l	a1,a2
	move.l	d5,d1
	not.l		d1
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a3,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a4,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a5,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a6,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	add.l		d6,a0
	swap		d4
	dbra		d4,.ylp
	bra		.rts
.two	move.l	a0,a1
	move.l	d0,d1
	not.l		d1
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a3,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a4,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a5,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	a6,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	a1,a2
	move.l	d5,d1
	not.l		d1
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a3,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a4,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a5,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	a6,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	add.l		d6,a0
	dbra		d4,.two
	bra.s		.rts
.one	and.l		d0,d5
	moveq		#-16,d0
	add.l		d6,d0
	move.l	a3,d1
	move.l	a4,d2
	move.l	a5,d3
	move.l	a6,d6
	and.l		d5,d1
	and.l		d5,d2
	and.l		d5,d3
	and.l		d5,d6
	not.l		d5
.lp	move.l	(a0),d7
	and.l		d5,d7
	or.l		d1,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d2,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d3,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d6,d7
	move.l	d7,(a0)+
	add.l		d0,a0
	dbra		d4,.lp
.rts	popall
	rts

	endr

Draw_block_true:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	movem.l	d5-d7/a1-a6,-(sp)
	move.w	d0,d5
	swap		d0
	move.w	d5,d0
.got	cmp.w		d1,d3
	bge.s		.xok
	exg		d1,d3
.xok	cmp.w		d2,d4
	bge.s		.yok
	exg		d2,d4
.yok	sub.w		d1,d3		; width
	bmi.s		Werr
	sub.w		d2,d4		; height
	bmi.s		Werr
	add.w		d1,d1
	add.w		d1,a0
	mulu		scrwid,d2
	add.l		d2,a0
	move.w	d4,d7

;	move.l	d0,d2
;	move.l	d0,d4
;	move.l	d0,d6
;	move.l	d0,a2
;	move.l	d0,a3
;	move.l	d0,a4
;	move.l	d0,a5
;	lea		32.w,a6

Wylp	move.l	a0,a1
	move.w	d3,d1
	moveq		#16-1,d5
	and.w		d1,d5
	lsr.w		#4,d1
	jmp		([WORDJUMPS.l,d5.w*4])
Wlop	word		16
	word		15
	word		14
	word		13
	word		12
	word		11
	word		10
	word		9
	word		8
	word		7
	word		6
	word		5
	word		4
	word		3
	word		2
	word		1
	dbra		d1,Wxlp
	bra.s		Wend
Wxlp
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	
;	movem.l	d0/d2/d4/d6/a2-a5,(a1)
;	add.l		a6,a1

	dbra		d1,Wxlp
Wend	add.w		scrwid,a0
	dbra		d7,Wylp	
Werr	movem.l	(sp)+,d5-d7/a1-a6
	rts

DRAW_MENU_TEXTURE:
	moveq		#iface_lgrey,d0
	tst.b		texture_available
	beq		DRAW_MENU_BLOCK
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	move.w	TEXTURE_HANDLE,d0
	bsr.s		DRAW_PHYS_TEXTURE
	popall
	rts
	
DRAW_PHYS_TEXTURE:
	move.l	PHYS_SCR,a0
	move.w	physwid,scrwid

Draw_texture:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	tst.b		TRUE_FLAG
	bne		Draw_texture_true
	pushall
	move.w	d0,a6
.got	cmp.w		d1,d3
	bge.s		.xok
	exg		d1,d3
.xok	cmp.w		d2,d4
	bge.s		.yok
	exg		d2,d4
.yok	moveq		#-16,d0
	and.w		d1,d0
	add.w		d0,a0
	moveq		#-1,d0
	move.w	d1,d6
	and.w		#16-1,d6
	lsr.w		d6,d0
	move.w	d0,d6
	swap		d0
	move.w	d6,d0
	move.w	d3,d6
	addq		#1,d6
	neg.w		d6
	and.w		#16-1,d6
	moveq		#-1,d5
	lsl.w		d6,d5
	move.w	d5,d6
	swap		d5
	move.w	d6,d5		
	move.w	d2,d6
	mulu		scrwid,d6
	add.l		d6,a0
	and.w		#-16,d1
	and.w		#-16,d3
	sub.w		d1,d3
	lsr.w		#4,d3
	sub.w		d2,d4
	push.l	d0
	push.l	a0
	move.w	a6,d0
	jsr		Find_block
	lea		8(a0),a6
	pop.l		a0
	pop.l		d0
	move.w	scrwid,d6
	ext.l		d6
	moveq		#0,d1
	move.l	d1,a4
	subq		#1,d3
	bmi		.one
.ylp	move.l	a4,d1
	and.w		#64-1,d1
	move.l	d1,a4
	addq.l	#1,a4
	lsl.l		#6,d1
	lea		(a6,d1.l),a5
	swap		d4
	move.l	a0,a1
	move.l	d0,d1
	not.l		d1
	move.l	(a1),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.l	(a1),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	d2,(a1)+
	move.w	d3,d4
	bra.s		.xs
.xlp	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+
.xs	dbra		d4,.xlp
	move.l	a1,a2
	move.l	d5,d1
	not.l		d1
	move.l	(a2),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	move.l	(a2),d2
	and.l		d1,d2
	move.l	(a5)+,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	d2,(a2)+
	add.l		d6,a0
	swap		d4
	dbra		d4,.ylp
	bra		.rts
.one	move.l	a4,d1
	and.w		#64-1,d1
	move.l	d1,a4
	addq.l	#1,a4
	lsl.l		#6,d1
	lea		(a6,d1.l),a5
	and.l		d0,d5
	moveq		#-16,d0
	add.l		d6,d0
	move.l	(a5)+,d1
	move.l	(a5)+,d2
	move.l	(a5)+,d3
	move.l	(a5)+,d6
	and.l		d5,d1
	and.l		d5,d2
	and.l		d5,d3
	and.l		d5,d6
	not.l		d5
.lp	move.l	(a0),d7
	and.l		d5,d7
	or.l		d1,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d2,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d3,d7
	move.l	d7,(a0)+
	move.l	(a0),d7
	and.l		d5,d7
	or.l		d6,d7
	move.l	d7,(a0)+
	add.l		d0,a0
	dbra		d4,.lp
.rts	popall
	rts

Draw_texture_true:
;	d0		colour
;	d1,d2		x1,y1
;	d3,d4		x2,y2
;	a0		screen
	pushall
	push.l	d0
	push.l	a0
	jsr		Find_block
	lea		8(a0),a6
	pop.l		a0
	pop.l		d0
.got	cmp.w		d1,d3
	bge.s		.xok
	exg		d1,d3
.xok	cmp.w		d2,d4
	bge.s		.yok
	exg		d2,d4
.yok	sub.w		d1,d3		; width
	bmi.s		.err
	sub.w		d2,d4		; height
	bmi.s		.err
	add.w		d1,d1
	add.w		d1,a0
	mulu		scrwid,d2
	add.l		d2,a0
	move.w	d4,d7
	sub.l		a4,a4
.ylp	move.l	a4,d1
	and.w		#64-1,d1
	move.l	d1,a4
	addq.l	#1,a4
	lsl.l		#6,d1
	lea		(a6,d1.l*2),a5
	move.l	a0,a1
	move.w	d3,d1
	moveq		#8-1,d5
	and.w		d1,d5
	lsr.w		#3,d1
	neg.w		d5
	jmp		.est(pc,d5.w*2)
.elp	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a5)+,(a1)+
.est	dbra		d1,.elp
	add.w		scrwid,a0
	dbra		d7,.ylp
.err	popall
	rts

		
horizontal_menuline:
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0
horizontal_physline:
	cmp.w		d1,d2
	bge.s		.sort
	exg		d1,d2
.sort	move.w	X_RESOLUTION,d4
	subq		#1,d4
	tst.w		d1
	bpl.s		.x1
	moveq		#0,d1
.x1	cmp.w		d4,d2
	ble.s		.x2
	move.w	d4,d2
.x2	tst.b		TRUE_FLAG
	bne		horimenuline_tc
	moveq		#-16,d7
	move.w	d0,d4
	move.w	d1,d0
	and.w		d7,d0
	lea		([PHYS_SCR.l],d0.w),a1
	add.l		(PHYS_Y.l,d3.w*4),a1
	bra		horizontal_line_bpl

horizontal_logline:
	cmp.w		d1,d2
	bge.s		.sort
	exg		d1,d2
.sort	move.w	CANVAS_WIDTH,d4
	subq		#1,d4
	tst.w		d1
	bpl.s		.x1
	moveq		#0,d1
.x1	cmp.w		d4,d2
	ble.s		.x2
	move.w	d4,d2
.x2

horizontal_logline_d:
	tst.b		TRUE_FLAG
	bne		horicanvasline_tc
	moveq		#-16,d7
	move.w	d0,d4
	move.w	d1,d0
	and.w		d7,d0
	lea		([LOG_SCR.l],d0.w),a1
	add.l		(LOG_Y.l,d3.w*4),a1

horizontal_line_bpl:
	push.l	a6
	moveq		#16-1,d3
	add.w		d4,d4
	movem.l	(PLANE_TABLE.l,d4.w*8),a3/a4/a5/a6
	move.w	d1,d4
	and.w		d3,d4
	moveq		#-1,d0
	lsr.w		d4,d0
	swap		d0
	lsr.w		d4,d0
	move.w	d2,d4
	addq		#1,d4
	neg.w		d4
	and.w		d3,d4
	moveq		#-1,d5
	lsl.w		d4,d5
	swap		d5
	lsl.w		d4,d5
	and.w		d7,d1
	and.w		d7,d2
	sub.w		d1,d2
	lsr.w		#4,d2
	move.w	d2,d3
	move.l	d0,d1
	not.l		d1
	move.l	d5,d2
	not.l		d2
	subq		#1,d3
	bmi.s		.one
	move.l	a3,d7
	and.l		d0,d7
	move.l	(a1),d6
	and.l		d1,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a4,d7
	and.l		d0,d7
	move.l	(a1),d6
	and.l		d1,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a5,d7
	and.l		d0,d7
	move.l	(a1),d6
	and.l		d1,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a6,d7
	and.l		d0,d7
	move.l	(a1),d6
	and.l		d1,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.w	d3,d6
	bra.s		.go
.xlp	move.l	a3,(a1)+
	move.l	a4,(a1)+
	move.l	a5,(a1)+
	move.l	a6,(a1)+
.go	dbra		d6,.xlp
	move.l	a3,d7
	and.l		d5,d7
	move.l	(a1),d6
	and.l		d2,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a4,d7
	and.l		d5,d7
	move.l	(a1),d6
	and.l		d2,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a5,d7
	and.l		d5,d7
	move.l	(a1),d6
	and.l		d2,d6
	or.l		d6,d7
	move.l	d7,(a1)+
	move.l	a6,d7
	and.l		d5,d7
	move.l	(a1),d6
	and.l		d2,d6
	or.l		d6,d7
	move.l	d7,(a1)+
.rts	pop.l		a6
	rts
.one	and.l		d0,d5
	move.l	a3,d1
	and.l		d5,d1
	move.l	a4,d2
	and.l		d5,d2
	move.l	a5,d3
	and.l		d5,d3
	move.l	a6,d4
	and.l		d5,d4
	not.l		d5
	move.l	d5,d7
	and.l		(a1),d7
	or.l		d1,d7
	move.l	d7,(a1)+
	move.l	d5,d7
	and.l		(a1),d7
	or.l		d2,d7
	move.l	d7,(a1)+
	move.l	d5,d7
	and.l		(a1),d7
	or.l		d3,d7
	move.l	d7,(a1)+
	move.l	d5,d7
	and.l		(a1),d7
	or.l		d4,d7
	move.l	d7,(a1)+
	pop.l		a6
	rts

horimenuline_tc:
	lea		([PHYS_SCR.l],d1.w*2),a1
	add.l		(PHYS_Y.l,d3.w*4),a1
	bra.s		horizontal_line_tc

horicanvasline_tc:
	lea		([LOG_SCR.l],d1.w*2),a1
	add.l		(LOG_Y.l,d3.w*4),a1

horizontal_line_tc:
	push.l	a6
	move.l	a1,a6
	sub.w		d1,d2
	addq		#1,d2
	move.w	d0,d1
	swap		d0
	move.w	d1,d0
	moveq		#16-1,d1
	and.w		d2,d1
	neg.w		d1
	lsr.w		#4,d2
	jmp		.strt(pc,d1.w*2)
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
.strt	dbra		d2,.xlp
	pop.l		a6
	rts
.xlp	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	dbra		d2,.xlp		
	pop.l		a6
	rts

HORIZONTAL_COPY:
;	a0	=	source
;	a1	=	dest
	tst.b		TRUE_FLAG
	bne		HCOPY_TRUE
	moveq		#0,d0
	move.w	d1,d0
	and.w		#-16,d0
	add.l		d0,a0
	add.l		d0,a1
	move.l	(LOG_Y.l,d3.w*4),d0
	add.l		d0,a0
	add.l		d0,a1
	move.l	a0,a3
	moveq		#-1,d0
	move.w	d1,d6
	and.w		#16-1,d6
	lsr.w		d6,d0
	move.w	d0,d6
	swap		d0
	move.w	d6,d0
	move.w	d2,d6
	addq		#1,d6
	neg.w		d6
	and.w		#16-1,d6
	moveq		#-1,d5
	lsl.w		d6,d5
	move.w	d5,d6
	swap		d5
	move.w	d6,d5		
	and.w		#-16,d1
	and.w		#-16,d2
	sub.w		d1,d2
	lsr.w		#4,d2
	move.w	d2,d3
	subq		#1,d3
	bmi.s		.one
	move.l	a1,a2
	move.l	(a2)+,d1
	move.l	(a2)+,d2
	move.l	(a2)+,d4
	move.l	(a2)+,d6
	not.l		d0
	and.l		d0,d1
	and.l		d0,d2
	and.l		d0,d4
	and.l		d0,d6
	not.l		d0
	move.l	(a3)+,d7
	and.l		d0,d7
	or.l		d7,d1
	move.l	(a3)+,d7
	and.l		d0,d7
	or.l		d7,d2
	move.l	(a3)+,d7
	and.l		d0,d7
	or.l		d7,d4
	move.l	(a3)+,d7
	and.l		d0,d7
	or.l		d7,d6
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d4,(a1)+
	move.l	d6,(a1)+
	move.w	d3,d6
	bra.s		.go
.xlp	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
.go	dbra		d6,.xlp
	move.l	a1,a2
	move.l	(a2)+,d1
	move.l	(a2)+,d2
	move.l	(a2)+,d4
	move.l	(a2)+,d6
	not.l		d5
	and.l		d5,d1
	and.l		d5,d2
	and.l		d5,d4
	and.l		d5,d6
	not.l		d5
	move.l	(a3)+,d7
	and.l		d5,d7
	or.l		d7,d1
	move.l	(a3)+,d7
	and.l		d5,d7
	or.l		d7,d2
	move.l	(a3)+,d7
	and.l		d5,d7
	or.l		d7,d4
	move.l	(a3)+,d7
	and.l		d5,d7
	or.l		d7,d6
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d4,(a1)+
	move.l	d6,(a1)+
	bra.s		.rts
.one	and.l		d0,d5
	move.l	(a3)+,d1
	move.l	(a3)+,d2
	move.l	(a3)+,d3
	move.l	(a3)+,d4
	and.l		d5,d1
	and.l		d5,d2
	and.l		d5,d3
	and.l		d5,d4
	not.l		d5
	move.l	(a1),d7
	and.l		d5,d7
	or.l		d1,d7
	move.l	d7,(a1)+
	move.l	(a1),d7
	and.l		d5,d7
	or.l		d2,d7
	move.l	d7,(a1)+
	move.l	(a1),d7
	and.l		d5,d7
	or.l		d3,d7
	move.l	d7,(a1)+
	move.l	(a1),d7
	and.l		d5,d7
	or.l		d4,d7
	move.l	d7,(a1)+
.rts	rts

HCOPY_TRUE:
	moveq		#0,d0
	move.w	d1,d0
	add.l		d0,d0
	add.l		d0,a0
	add.l		d0,a1
	move.l	(LOG_Y.l,d3.w*4),d0
	add.l		d0,a0
	add.l		d0,a1
	sub.w		d1,d2
	addq		#1,d2
	moveq		#8-1,d1
	and.w		d2,d1
	neg.w		d1
	lsr.w		#3,d2
	jmp		.strt(pc,d1.w*2)
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
.strt	dbra		d2,.xlp
	bra.s		.done
.xlp	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra		d2,.xlp		
.done	rts

HORIZONTAL_HSVMASK:
	move.l	LOG_SCR,a0
	moveq		#0,d0
	move.w	d1,d0
	add.l		d0,d0
	add.l		d0,a0
	move.l	(LOG_Y.l,d3.w*4),d0
	add.l		d0,a0
	sub.w		d1,d2
.xlp	dspwrite	(a0)
	dspread	(a0)+
	dbra		d2,.xlp
.done	rts
		
*-----------------------------------------------------------------------*
*	Draw scaled menu bar								*
*-----------------------------------------------------------------------*

read_main_menu:
	move.l	#MAINGFX_ID,menu_name
	move.w	MAINGFX_HANDLE,menu_handle
	jmp		read_menu

read_slider_menu:
	move.l	#SLIDEGFX_ID,menu_name
	move.w	SLIDEGFX_HANDLE,menu_handle
	jmp		read_menu

read_general_menu:
	move.l	#GENGFX_ID,menu_name
	move.w	GENGFX_HANDLE,menu_handle
	jmp		read_menu

read_swap_menu:
	move.l	swapmenu_id,menu_name
	move.w	SWAPGFX_HANDLE,menu_handle
	jmp		read_menu

read_texture:
	move.l	#TEXTURE_ID,menu_name
	move.w	TEXTURE_HANDLE,menu_handle
	jsr		read_menu
	st		texture_available
	rts
	
read_menu:
	move.l	menu_name,a0
	move.l	a0,sysfile_name
.look	cmp.b		#'.',(a0)+
	bne.s		.look
	subq.l	#1,a0
	cmp.b		#'x',-1(a0)
	beq.s		.go
	cmp.b		#'X',-1(a0)
	beq.s		.go
	move.w	y_factor,d0
	subq		#1,d0
	add.w		#'1',d0
	move.b	d0,-(a0)
	move.w	x_factor,d0
	subq		#1,d0
	add.w		#'1',d0
	move.b	d0,-(a0)
.go	move.l	#menu_data,sysfile_ptr
	move.l	#8,sysfile_size
	move.l	#12,sysfile_index
	jsr		READ_SYSFILE
	move.w	menu_handle,d0
	jsr		Find_block
	move.w	menu_width,(a0)+
	move.w	menu_height,(a0)+
	move.w	menu_x,(a0)+
	move.w	menu_y,(a0)+
	move.l	a0,sysfile_ptr
	move.w	menu_width,d1
	mulu		menu_height,d1
	move.l	d1,sysfile_size
	move.l	#20+768,sysfile_index
	jsr		READ_SYSFILE
	jsr		remap_menu
	rts
	
menu_data:
menu_width:		ds.w	1
menu_height:	ds.w	1
menu_x:		ds.w	1
menu_y:		ds.w	1
	
remap_menu:
	tst.b		TRUE_FLAG
	bne		.true
	move.w	menu_handle,d0
	jsr		Find_block
	lea		8(a0),a0
	lea		IFACE_COLOURS,a1
	move.w	menu_height,d7
	subq		#1,d7
.ylop	push.w	d7
	move.w	menu_width,d7
	lsr.w		#4,d7
	subq		#1,d7
	moveq		#0,d0
.xlop	push.w	d7
	moveq		#16-1,d7
	move.l	a0,a6
.bits	move.b	(a0)+,d0
	move.w	(a1,d0.w*2),d0
	swap		d1
	add.b		d0,d0
	addx.w	d1,d1
	swap		d1
	add.b		d0,d0
	addx.w	d1,d1
	swap		d2
	add.b		d0,d0
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d2,d2
	swap		d3
	add.b		d0,d0
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d3,d3
	swap		d4
	add.b		d0,d0
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d4,d4
	dbra		d7,.bits
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	move.l	d4,(a6)+
	move.l	d3,(a6)+
	move.l	d2,(a6)+
	move.l	d1,(a6)+
	pop.w		d7
	dbra		d7,.xlop
	pop.w		d7
	dbra		d7,.ylop
	rts
.true	move.w	menu_handle,d0
	jsr		Find_block
	move.l	sysfile_size,d1
	lea		8(a0,d1.l),a1
	lea		8(a0,d1.l*2),a2
	lea		IFACE_COLOURS,a0
	move.w	menu_height,d7
	subq		#1,d7
.ylp	move.w	menu_width,d6
	subq		#1,d6
.xlp	move.b	-(a1),d0
	move.w	(a0,d0.w*2),-(a2)
	dbra		d6,.xlp
	dbra		d7,.ylp
	rts

read_all_menus:
	jsr		Remap_menu_colours
	jsr		read_main_menu
	jsr		read_slider_menu
	jsr		read_general_menu
	jsr		read_swap_menu
	jsr		read_texture
	rts

Remap_menu_bars:
	tst.b		TRUE_FLAG
	beq.s		.bpl
	tst.b		VIDEO_CHANGED
	beq.s		.err
	jsr		read_all_menus
	jsr		Init_mouse
	sf		VIDEO_CHANGED
	bra.s		.err
.bpl	tst.b		MENUPAL_CHANGED
	beq.s		.err
	jsr		read_all_menus
	jsr		Init_mouse
	sf		MENUPAL_CHANGED
.err	rts

INIT_RECOLOUR_LIST:
	lea		IFACE_COLOURS,a1
	lea		INITIAL_COLOURS,a2
	moveq		#0,d7
	move.w	#menu_cols-1,d0
.lp	tst.b		TRUE_FLAG
	bne.s		.true
	move.w	d7,(a1)+
	bra.s		.nnn
.true	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.b	1(a2,d7.w*4),d1
	move.b	2(a2,d7.w*4),d2
	move.b	3(a2,d7.w*4),d3
	lsr.w		#8-5,d1
	lsr.w		#8-6,d2
	lsr.w		#8-5,d3
	lsl.w		#5,d1
	lsl.w		#6,d1
	lsl.w		#5,d2
	or.w		d1,d2
	or.w		d2,d3
	move.w	d3,(a1)+
.nnn	addq		#1,d7
	dbra		d0,.lp
	rts
	
Remap_menu_colours:
	tst.b		TRUE_FLAG
	bne		.err
	lea		COLOURS,a0
	move.w	#256,d0
	jsr		Init_DSPColSearch
	lea		INITIAL_COLOURS,a0
	lea		IFACE_COLOURS,a2
	move.w	#menu_cols-1,d7
.lp	addq.l	#1,a0
	moveq		#0,d6
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d6
	dspwrite	d6
	dspread	(a2)+
	dbra		d7,.lp
	move.w	#iface_grey,CHAR_COL
	bsr		Refresh_info_bar
.err	rts

TRANSLATE_COLOURS:
	addq.b	#1,BUSY
	pushall
	move.l	a1,a0
	move.w	#256,d0
	jsr		Init_DSPColSearch
	popall
	move.w	#256-1,d0
	lea		TRANSLATOR_TABLE,a2
.look	push.w	d0
	addq.l	#1,a0
	moveq		#0,d6
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d6
	dspwrite	d6
	move.b	(a0)+,d6
	dspwrite	d6
	dspread	d6
	move.b	d6,(a2)+
	pop.w		d0
	dbra		d0,.look
	subq.b	#1,BUSY
	rts

*-----------------------------------------------------------------------*
*	Superscaling screen copier							*
*-----------------------------------------------------------------------*

	include	includes\scalers.s

*-----------------------------------------------------------------------*
*	Menu bar colour zones								*
*-----------------------------------------------------------------------*
	
OPEN_MENU:
	jsr		Reset_tool
	bsr		HIDE_MOUSE
	jsr		Update_chstate
	move.w	zoom_top,Screen_Y1
	move.w	zoom_bot,Screen_Y2
	sf		DRAW_LOOP
	jsr		Redraw_menu_icons
	move.b	#partial_menu,MENU_STATE
	move.l	TOOL_ICONS,ICON_LIST
	move.l	PASSIVE_PTR,d0
	jsr		Passive_dialog
	bsr		Update_palette_zone
	bsr		Superscaler
	bsr		SHOW_MOUSE
	rts

zoom_top:	dc.w	16
zoom_bot:	dc.w	200-16

CLOSE_MENU:
	sf		active
	bsr		HIDE_MOUSE
	move.w	#0,Screen_Y1
	move.w	#200,Screen_Y2
	move.l	#PALETTE_BAR_ICONS,ICON_LIST
	bsr		Update_palette_zone
	bsr		Refresh_info_bar
	move.b	#no_menu,MENU_STATE
	bsr		Superscaler
	bsr		SHOW_MOUSE
	rts

*-----------------------------------------------------------------------*

ARTE:	rte
		
*-----------------------------------------------------------------------*
*	System subroutines								*
*-----------------------------------------------------------------------*

Allocate_STRAM:
	push.w	#STRAM_only
	push.l	d0
	push.w	#68
	trap		#1
	addq		#8,sp
	rts

Allocate_VRAM:
	push.w	#VRAM_only
	push.l	d0
	push.w	#68
	trap		#1
	addq		#8,sp
	rts

DeAllocate:
	push.l	d0
	push.w	#73
	trap		#1
	addq		#6,sp
	rts

Get_ram:
	push.w	d0
	pea		-1.w
	push.w	#68
	trap		#1
	addq		#8,sp
	rts

Exit_Pulldown:
	jsr		Reset_vectors
	jsr		Reset_screens
	jsr		Reset_palette
Exit_DeAllocate:
	tst.b		VRAM
	beq.s		.nvrm
	move.l	VRAM_START,d0
	bsr.s		DeAllocate
.nvrm	move.l	STRAM_START,d0
	bsr.s		DeAllocate
	bra.s		Exit_DeSuper
Exit_merr:
	bsr		merr_message
Exit_DeSuper:
	cache		reset
	move.l	OLD_SSP,-(sp)
	move.w	#32,-(sp)
	trap		#1
	lea		10(sp),sp
	showmouse
Exit_Direct:
	bsr		Appl_init
	bsr		V_Free
	bsr		DELAY
	bsr		DELAY
	bsr		DELAY
	bsr		DELAY
	bsr		Appl_exit
X:	clr.w		-(sp)
	trap		#1

merr_message:
	pea		merr_text
	push.w	#9
	trap		#1
	addq		#6,sp
	jsr		EMPTY_BUFFER
.no	jsr		GET_CHAR
	tst.b		d0
	beq.s		.no
	rts

Init_Video_extras:
	jsr		VSYNC
	bsr.s		Set_ScanParameters
	jsr		Update_palette
	rts

Set_ScanParameters:
	tst.b		VGA_FLAG
	bne.s		.vga
	ifd		moveborders
	sub.w		#30,SCAN_START.w
	add.w		#30,SCAN_STOP.w
	endc
	bra.s		.done
	nop
.vga
	ifd		moveborders
	sub.w		#20,SCAN_STOP.w
	add.w		#20,SCAN_START.w
	endc
.done	move.w	SCAN_START.w,vstart_pon
	move.w	SCAN_STOP.w,vstop_pon
	move.w	vstart_pon,vstart_poff
	move.w	vstop_pon,vstop_poff
	tst.b		VGA_FLAG
	bne.s		.vg2
	add.w		#30,vstart_poff
	sub.w		#30,vstop_poff
	bra.s		.dn2
.vg2	add.w		#60,vstart_poff
	sub.w		#60,vstop_poff
.dn2	rts

enable_pbar:
	ifd		moveborders
	move.w	vstart_pon,SCAN_START.w
	move.w	vstop_pon,SCAN_STOP.w
	endc
	rts

disable_pbar:
	cmp.b		#no_menu,MENU_STATE
	bne.s		.skip
	nop
	ifd		moveborders
	move.w	vstop_poff,SCAN_STOP.w
	move.w	vstart_poff,SCAN_START.w
	endc
.skip	rts


bus_dialog:
	lea		WIN_buserr,a0
	jsr		Dialog
	rts
	
BUS_VEC		=	8
	
Init_vectors:

	ifnd		nicetimers
	bsr		enable_stabilizer
	endc

	lea		vector_buffer,a0

	ifnd		nicetimers
	move.l	VBI_VEC.w,OLD_VBI
	move.l	VBI_VEC.w,(a0)+
	move.l	#NEW_VBI,VBI_VEC.w
	elseif
	move.l	$4d2.w,(a0)+
	move.l	#NEW_VBI,$4d2.w
	endc

	ifnd		nicetimers
	move.l	TIMER_B.w,(a0)+
	move.b	ENABLE_A.w,(a0)+
	move.b	MASK_A.w,(a0)+
	move.b	#0,CTRL_B.w
	bclr		#0,ENABLE_A.w
	move.l	#NEW_TB,TIMER_B.w
	move.b	#100,DATA_B.w
	bset		#0,ENABLE_A.w
	bset		#0,MASK_A.w
	endc

	ifd		SNAPCODE
	move.l	$502.w,(a0)+
	move.l	#SNAP_VEC,$502.w
	endc

	ifnd		debug
	move.l	$404.w,(a0)+
	move.l	#NEW_EC,$404.w


	move.l	BUS_VEC.w,(a0)+
	move.l	#bus_dialog,bus_code
	move.l	#bus_handler,BUS_VEC.w
	endc

	bsr		INIT_IKBD
	rts

Reset_vectors:
	bsr		RESET_IKBD

	lea		vector_buffer,a0

	ifnd		nicetimers
	move.l	(a0)+,VBI_VEC.w
	elseif
	move.l	(a0)+,$4d2.w
	endc

	ifnd		nicetimers
	move.b	#0,CTRL_B.w
	move.l	(a0)+,TIMER_B.w
	move.b	(a0)+,ENABLE_A.w
	move.b	(a0)+,MASK_A.w
	endc

	ifd		SNAPCODE
	move.l	(a0)+,$502.w
	endc

	ifnd		debug
	move.l	(a0)+,$404.w

	move.l	(a0)+,BUS_VEC.w
	endc

	ifnd		nicetimers
	bsr		disable_stabilizer
	endc

	rts


disable_stabilizer:
	tst.b		no_stabilizer
	bne.s		.off
	st		no_stabilizer
	move.l	#active_vbi,vbi_direction
.off:	rts

enable_stabilizer:
	tst.b		no_stabilizer
	beq.s		.on
	sf		no_stabilizer
	move.l	#active_vbi,vbi_direction
.on:	rts


NEW_EC:
	moveq		#-33,d0
	rts

NEW_TB:
	move.l	#active_vbi,vbi_direction
	move.b	#0,CTRL_B.w
	move.b	#255,DATA_B.w
	bclr		#0,IN_SERVICE_A.w
	rte
	
bus_handler:	
	pushall
	jsr		([bus_code.l])
	popall
	and.w		#%1111111011111111,10(sp)
	rte

matrix_bus:
	sf		matrix_flag
	rts
	
expose_bus:
	sf		expose_flag
	rts

tidy		ds.l	1	
return	ds.l	1
bus_code	ds.l	1
expose_flag	ds.b	1
		even

*-----------------------------------------------------------------------*
*	Text print routines								*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Print single character (8-plane)						*
*-----------------------------------------------------------------------*
*	d0		character								*
*	a1		screen								*
*-----------------------------------------------------------------------*

CHAR_X:		ds.w	1
CHAR_Y:		ds.w	1
CHAR_COL:		ds.w	1

PRINT_CHARACTER:
	tst.b		CHAR_SOLID
	bne		PRINT_CHAR_SOLID
	tst.b		TRUE_FLAG
	bne		PRINT_CHAR_TRUE
	move.w	CHAR_Y(pc),d7
	cmp.w		#1,x_factor
	bne.s		.ok
	cmp.w		#$81,d0
	blt.s		.ok
	cmp.w		#$a7,d0
	bgt.s		.ok
	subq		#1,d7
.ok	yresfactor	d7
	move.l	a1,a3
	add.l		(PHYS_Y.l,d7.w*4),a3
	move.w	CHAR_X(pc),d7
	xresfactor	d7
	sub.w		x_factor,d7
	addq		#1,d7
	moveq		#-16,d1
	and.w		d7,d1
	add.w		d1,a3
	and.w		#16-1,d7
	addq		#8,d7
	lea		(a6,d0.w),a2
	move.w	CHAR_COL(pc),d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1/d2/d3/a4	
	moveq		#6-1,d4
	cmp.w		#1,x_factor
	beq.s		.ylp
	moveq		#8-1,d4
.ylp	move.l	a3,a5
	moveq		#0,d0
	move.b	(a2),d0
	ror.l		d7,d0
	move.l	d0,d6
	swap		d6
	move.w	d0,d5
	move.w	d6,d0
	move.w	d5,d6
	not.l		d0
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	not.l		d0
	not.l		d6
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	not.l		d6
	lea		-32(a5),a5	
	move.l	d1,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d2,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d3,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	a4,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d1,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	d2,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	d3,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	a4,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	lea		256(a2),a2
	add.w		physwid,a3
	dbra		d4,.ylp
	rts

PRINT_CHAR_SOLID:
	tst.b		TRUE_FLAG
	bne		PRINT_CHAR_TRUE_SOLID
	move.w	CHAR_Y(pc),d7
	cmp.w		#1,x_factor
	bne.s		.ok
	cmp.w		#$81,d0
	blt.s		.ok
	cmp.w		#$a7,d0
	bgt.s		.ok
	subq		#1,d7
.ok	yresfactor	d7
	move.l	a1,a3
	add.l		(PHYS_Y.l,d7.w*4),a3
	move.w	CHAR_X(pc),d7
	xresfactor	d7
	sub.w		x_factor,d7
	addq		#1,d7
	moveq		#-16,d1
	and.w		d7,d1
	add.w		d1,a3
	and.w		#16-1,d7
	addq		#8,d7
	lea		(a6,d0.w),a2
	move.w	CHAR_COL(pc),d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),d1/d2/d3/a4	
	swap		d7
	move.w	#%11111100,d7
	swap		d7
	moveq		#6-1,d4
	cmp.w		#1,x_factor
	beq.s		.ylp
	swap		d7
	move.w	#%11111111,d7
	swap		d7
	moveq		#8-1,d4
.ylp	move.l	a3,a5
	moveq		#0,d0
	swap		d7
	move.w	d7,d0
	ext.l		d0
	swap		d7
	ror.l		d7,d0
	move.l	d0,d6
	swap		d6
	move.w	d0,d5
	move.w	d6,d0
	move.w	d5,d6
	not.l		d0
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	and.l		d0,(a5)+
	not.l		d0
	not.l		d6
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	and.l		d6,(a5)+
	not.l		d6
	moveq		#0,d0
	move.b	(a2),d0
	ror.l		d7,d0
	move.l	d0,d6
	swap		d6
	move.w	d0,d5
	move.w	d6,d0
	move.w	d5,d6
	lea		-32(a5),a5	
	move.l	d1,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d2,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d3,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	a4,d5
	and.l		d0,d5
	or.l		d5,(a5)+
	move.l	d1,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	d2,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	d3,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	move.l	a4,d5
	and.l		d6,d5
	or.l		d5,(a5)+
	lea		256(a2),a2
	add.w		physwid,a3
	dbra		d4,.ylp
	rts

PRINT_CHAR_TRUE:
	move.w	CHAR_Y(pc),d7
	cmp.w		#1,x_factor
	bne.s		.ok
	cmp.w		#$81,d0
	blt.s		.ok
	cmp.w		#$a7,d0
	bgt.s		.ok
	subq		#1,d7
.ok	yresfactor	d7
	move.l	a1,a3
	add.l		(PHYS_Y.l,d7.w*4),a3
	move.w	CHAR_X(pc),d7
	xresfactor	d7
	sub.w		x_factor,d7
	addq		#1,d7
	ext.l		d7
	add.l		d7,d7
	add.l		d7,a3
	lea		(a6,d0.w),a2
	move.w	CHAR_COL(pc),d1
	move.w	(IFACE_COLOURS.l,d1.w*2),d1
	or.b		gensol,d1
	move.w	#256,d6
	move.w	physwid,d7
	ext.l		d6
	ext.l		d7
	moveq		#6-1,d4
	moveq		#0,d3
	cmp.w		#1,x_factor
	beq.s		.ylp
	moveq		#8-1,d4
	moveq		#1,d3
.ylp	move.l	a3,a5
	move.b	(a2),d0
	add.b		d0,d0
	bcc.s		.n1
	move.w	d1,(a5)
.n1	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n2
	move.w	d1,(a5)
.n2	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n3
	move.w	d1,(a5)
.n3	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n4
	move.w	d1,(a5)
.n4	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n5
	move.w	d1,(a5)
.n5	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n6
	move.w	d1,(a5)
.n6	addq.l	#2,a5
	tst.b		d3
	beq.s		.next
	add.b		d0,d0
	bcc.s		.n7
	move.w	d1,(a5)
.n7	addq.l	#2,a5
	add.b		d0,d0
	bcc.s		.n8
	move.w	d1,(a5)
.n8	addq.l	#2,a5
.next	add.l		d6,a2
	add.l		d7,a3
	dbra		d4,.ylp
	rts

PRINT_CHAR_TRUE_SOLID:
	move.w	CHAR_Y(pc),d7
	cmp.w		#1,x_factor
	bne.s		.ok
	cmp.w		#$81,d0
	blt.s		.ok
	cmp.w		#$a7,d0
	bgt.s		.ok
	subq		#1,d7
.ok	yresfactor	d7
	move.l	a1,a3
	add.l		(PHYS_Y.l,d7.w*4),a3
	move.w	CHAR_X(pc),d7
	xresfactor	d7
	sub.w		x_factor,d7
	addq		#1,d7
	ext.l		d7
	add.l		d7,d7
	add.l		d7,a3
	lea		(a6,d0.w),a2
	move.w	CHAR_COL(pc),d1
	move.w	(IFACE_COLOURS.l,d1.w*2),d1
	or.b		gensol,d1
	move.w	#256,d6
	move.w	physwid,d7
	ext.l		d6
	ext.l		d7
	moveq		#6-1,d4
	moveq		#0,d3
	cmp.w		#1,x_factor
	beq.s		.ylp
	moveq		#8-1,d4
	moveq		#1,d3
.ylp	move.l	a3,a5
	move.b	(a2),d0
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n1
	move.w	d1,d2
.n1	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n2
	move.w	d1,d2
.n2	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n3
	move.w	d1,d2
.n3	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n4
	move.w	d1,d2
.n4	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n5
	move.w	d1,d2
.n5	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n6
	move.w	d1,d2
.n6	move.w	d2,(a5)+
	tst.b		d3
	beq.s		.next
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n7
	move.w	d1,d2
.n7	move.w	d2,(a5)+
	moveq		#0,d2
	add.b		d0,d0
	bcc.s		.n8
	move.w	d1,d2
.n8	move.w	d2,(a5)+
.next	add.l		d6,a2
	add.l		d7,a3
	dbra		d4,.ylp
	rts

clipcase:
	cmp.w		#1,x_factor
	beq.s		.go
	cmp.w		#1,y_factor
	beq.s		.go
	rts
.go	cmp.w		#'a',d0
	blt.s		.rts
	cmp.w		#'z',d0
	bgt.s		.rts
	sub.w		#'a'-'A',d0		
.rts	rts
	
PRINT_LINE:
	pushall
	move.l	FONT,a6
	move.l	PHYS_SCR,a1
.loop	moveq		#0,d0
	move.b	(a0)+,d0
	beq.s		.out
	cmp.w		#27,d0
	beq.s		.ctrl
	jsr		clipcase
	bsr		PRINT_CHARACTER
	move.w	textgap,d0
	add.w		d0,CHAR_X
	bra.s		.loop
.out	popall
	rts
.ctrl	move.b	(a0)+,d0
	cmp.b		#"Y",d0
	beq.s		.pos
	bra.s		.loop
.pos	moveq		#0,d0
	move.b	(a0)+,d0
	move.w	d0,CHAR_X
	moveq		#0,d0
	move.b	(a0)+,d0
	add.w		d0,CHAR_X
	moveq		#0,d0
	move.b	(a0)+,d0
	move.w	d0,CHAR_Y
	bra.s		.loop

PRINT_LINE_ADJ:
	pushall
	move.l	FONT,a6
	move.l	PHYS_SCR,a1
.loop	moveq		#0,d0
	move.b	(a0)+,d0
	beq.s		.out
	cmp.w		#27,d0
	beq.s		.ctrl
	jsr		clipcase
	bsr		PRINT_CHARACTER
	move.w	textgap,d0
	add.w		d0,CHAR_X
	bra.s		.loop
.out	popall
	rts
.ctrl	move.b	(a0)+,d0
	cmp.b		#"Y",d0
	beq.s		.pos
	bra.s		.loop
.pos	moveq		#0,d0
	move.b	(a0)+,d0
	move.w	d0,CHAR_X
	moveq		#0,d0
	move.b	(a0)+,d0
	add.w		d0,CHAR_X
	moveq		#0,d0
	move.b	(a0)+,d0
	moveq		#5,d4
	cmp.w		#1,x_factor
	beq.s		.ok
	moveq		#7,d4
.ok	lsr.w		d4
	divu		y_factor,d4
	sub.w		d4,d0
	move.w	d0,CHAR_Y
	bra.s		.loop

PRINT_ASCIINUM:
	move.l	ASCIINUM_PTR,a0
PRINT_ASCIINUM_A0:
	move.l	FONT,a6
	move.l	PHYS_SCR,a1
	moveq		#0,d7
	move.b	(a0)+,d7
	subq		#1,d7
	bmi.s		.exit
.prnt	push.w	d7
	moveq		#0,d0
	move.b	(a0)+,d0
	cmp.w		#' ',d0
	bmi.s		.ctrl
	bsr		PRINT_CHARACTER
	move.w	textgap,d2
	add.w		d2,CHAR_X
.ctrl	pop.w		d7
	dbra		d7,.prnt
.exit	rts

ASCIINUM_PTR:	dc.l	NUM_TEXT

ASCII2NUM:
	moveq		#0,d0
	lea		NUM_TEXT,a0
	moveq		#0,d7
	move.b	(a0)+,d7
	subq		#1,d7
	bmi.s		.out
.lp	mulu		#10,d0
	moveq		#0,d1
	move.b	(a0)+,d1
	sub.w		#'0',d1
	add.l		d1,d0
	dbra		d7,.lp
.out	rts

NUM2ASCII:
;	d0 	= 	number
	lea		NUM_TEXT,a0
	move.l	a0,a1
	moveq		#0,d2
	moveq		#'0',d3
	moveq		#10,d4
.loop	ext.l		d0
	divu		d4,d0
	move.l	d0,d1
	swap		d1
	add.w		d3,d1
	move.b	d1,-(a0)
	addq		#1,d2
	tst.w		d0
	bne.s		.loop
	move.b	d2,(a1)+
	subq		#1,d2
.copy	move.b	(a0)+,(a1)+
	dbra		d2,.copy
	clr.b		(a1)
	rts

NUM2ASCIIL:
;	d0 	= 	number
	lea		NUM_TEXT,a0
	move.l	a0,a1
	moveq		#0,d2
	moveq		#'0',d3
	moveq		#10,d4
.loop:
	clr.l		d1
	divu.l	d4,d1:d0
	add.l		d3,d1
	move.b	d1,-(a0)
	addq.w	#1,d2
	tst.l		d0
	bne.s		.loop
	move.b	d2,(a1)+
	subq.w	#1,d2
.copy	move.b	(a0)+,(a1)+
	dbra		d2,.copy
	clr.b		(a1)
	rts

NUM2ASCII_LZ:
;	d0 	= 	number
	lea		NUM_TEXT,a0
	move.l	a0,a1
	moveq		#0,d2
	moveq		#'0',d3
	moveq		#10,d4
	move.w	d1,d5
	subq		#1,d5
.loop	ext.l		d0
	divu		d4,d0
	move.l	d0,d1
	swap		d1
	add.w		d3,d1
	move.b	d1,-(a0)
	addq		#1,d2
	dbra		d5,.loop
	move.b	d2,(a1)+
	subq		#1,d2
.copy	move.b	(a0)+,(a1)+
	dbra		d2,.copy
	clr.b		(a1)
	rts

NUM2ASCII_SGN:
;	d0 	= 	number
	move.w	d0,d7
	bpl.s		.pl
	neg.w		d0
.pl	lea		NUM_TEXT,a0
	move.l	a0,a1
	moveq		#0,d2
	moveq		#'0',d3
	moveq		#10,d4
.loop	ext.l		d0
	divu		d4,d0
	move.l	d0,d1
	swap		d1
	add.w		d3,d1
	move.b	d1,-(a0)
	addq		#1,d2
	tst.w		d0
	bne.s		.loop
	tst.w		d7
	bpl.s		.pl2
	move.b	#'-',-(a0)
	addq		#1,d2
.pl2	move.b	d2,(a1)+
	subq		#1,d2
.copy	move.b	(a0)+,(a1)+
	dbra		d2,.copy
	rts

PRINT_NUM:
	move.l	FONT,a6
	move.l	PHYS_SCR,a1
.loop	ext.l		d7
	divu		#10,d7
	move.l	d7,d0
	swap		d0
	add.w		#'0',d0
	push.l	d7
	bsr		PRINT_CHARACTER
	pop.l		d7
	move.w	textgap,d0
	sub.w		d0,CHAR_X
	tst.w		d7
	bgt.s		.loop
	moveq		#' ',d0
	bsr		PRINT_CHARACTER
.out	rts

PRINT_COORDS:
	not.b		COORD_STROBE
	beq		.samx
	st		CHAR_SOLID
	move.w	#iface_visible,CHAR_COL
	move.w	MOUSE_Y,d7
	move.w	Scale_factor,d0
	lsr.w		d0,d7
	move.w	Y_RESOLUTION,d6
	lsr.w		d0,d6
	subq		#1,d6
	cmp.w		d6,d7
	bgt.s		.samy
	add.w		Window_Y,d7
	cmp.w		OLD_Y_COORD,d7
	beq.s		.samy
	move.w	d7,OLD_Y_COORD
	move.w	#320-(6*1),CHAR_X
	move.w	#222,CHAR_Y
	bsr		PRINT_NUM
.samy	move.w	MOUSE_X,d7
	move.w	Scale_factor,d0
	lsr.w		d0,d7
	move.w	Window_X,d6
	add.w		d6,d7
	cmp.w		OLD_X_COORD,d7
	beq.s		.samx
	move.w	d7,OLD_X_COORD
	move.w	#320-(6*6),CHAR_X
	move.w	#222,CHAR_Y
	bsr		PRINT_NUM
.samx	rts

PRINT_FRAME:
	tst.b		FRAMECOUNT
	beq		.rts
	move.w	LAST_CURFRAME,d0
	cmp.w		CURFRAME,d0
	beq.s		.rts
	move.w	d0,LAST_CURFRAME
	st		CHAR_SOLID
	move.w	#iface_visible,CHAR_COL
	move.w	#320-(6*18),CHAR_X
	move.w	#222,CHAR_Y
	lea		FTEXT,a0
	jsr		PRINT_LINE
	move.w	#320-(6*12),CHAR_X
	move.w	CURFRAME,d0
	moveq		#4,d1
	jsr		NUM2ASCII_LZ
	lea		NUM_TEXT+1,a0
	jsr		PRINT_LINE
	lea		SEPARATOR,a0
	jsr		PRINT_LINE
	move.w	MAXFRAME,d0
	moveq		#4,d1
	jsr		NUM2ASCII_LZ
	lea		NUM_TEXT+1,a0
	jsr		PRINT_LINE
.rts	rts

LAST_CURFRAME:	ds.w	1
CURFRAME:		ds.w	1
MAXFRAME:		ds.w	1
FRAMECOUNT:		ds.b	1
			even

busy_bar:
	addq.b	#1,BUSY_TIME
	and.b		#7,BUSY_TIME
	bne		.out
	st		CHAR_SOLID
	move.w	#iface_visible,CHAR_COL
	move.b	BUSY,d0
	cmp.b		BUSY_STAT,d0
	beq.s		.done
	move.b	d0,BUSY_STAT
.done	tst.b		BUSY
	beq.s		.out
	move.w	#222,CHAR_Y
	clr.w		CHAR_X
	move.l	FONT,a6
	move.l	PHYS_SCR,a1
	move.w	WT_NUM,d1
	move.l	(busy_list.l,pc,d1.w*4),a0
	push.l	FONT
	move.l	FONT,d0
	cmp.l		FONT8X8,d0
	bne.s		.go
	move.l	FONT8X16,FONT
.go	bsr		PRINT_LINE
	pop.l		FONT
	addq		#1,WT_NUM
	and.w		#8-1,WT_NUM
.out	rts

busy_list:
	dc.l		.bsy1
	dc.l		.bsy2
	dc.l		.bsy3
	dc.l		.bsy4
	dc.l		.bsy5
	dc.l		.bsy6
	dc.l		.bsy7
	dc.l		.bsy8

.bsy1	dc.b		"øøøø",0
.bsy2	dc.b		"ùøøø",0
.bsy3	dc.b		"ùùøø",0
.bsy4	dc.b		"ùùùø",0
.bsy5	dc.b		"ùùùù",0
.bsy6	dc.b		"øùùù",0
.bsy7	dc.b		"øøùù",0
.bsy8	dc.b		"øøøù",0

ram_info:
	jsr		LOCATE_RAM
	jsr		PRINT_USED
	jsr		PRINT_FREE
	rts

PRINT_FREE:
	move.l	TOTAL_FREE,d0
	bpl.s		.ok
	clr.l		d0
.ok:	divu.l	#1024,d0
	move.w	#iface_grey,CHAR_COL
	move.w	#80+13*6,CHAR_X
	move.w	#96,CHAR_Y
	move.w	y_factor,d1
	add.w		d1,CHAR_Y
	bsr		NUM2ASCIIL
	bsr		PRINT_ASCIINUM
	lea		KBYTES,a0
	jsr		PRINT_LINE
.done	rts

PRINT_USED:
	tst.w		Delta_count
	beq		.done
	move.l	TOTAL_USED,d0
	sub.l		STRAM_SYS,d0
	sub.l		VRAM_SYS,d0
	bpl.s		.ok
	clr.l		d0
.ok:	divu.l	#1024,d0
	move.w	#iface_grey,CHAR_COL
	move.w	#80+13*6,CHAR_X
	move.w	#88,CHAR_Y
	move.w	y_factor,d1
	add.w		d1,CHAR_Y
	bsr		NUM2ASCIIL
	bsr		PRINT_ASCIINUM
	lea		KBYTES,a0
	jsr		PRINT_LINE
.done	rts


LOCATE_RAM:
	move.l	STRAM_ADDR,d0
	sub.l		STRAM_START,d0
	move.l	d0,STRAM_USED
	move.l	VRAM_ADDR,d1
	sub.l		VRAM_START,d1
	move.l	d1,VRAM_USED
	add.l		d1,d0
	move.l	d0,TOTAL_USED

	move.l	STRAM_END,d0
	sub.l		STRAM_ADDR,d0
	move.l	d0,STRAM_FREE
	move.l	VRAM_END,d1
	sub.l		VRAM_ADDR,d1
	move.l	d1,VRAM_FREE
	add.l		d1,d0
	move.l	d0,TOTAL_FREE

;	move.l	BRUSH_1_SIZE,d0
;	add.l		BRUSH_2_SIZE,d0
;	add.l		BRUSH_3_SIZE,d0
;	add.l		BRUSH_4_SIZE,d0
;	move.l	d0,BRUSH_USED

;	move.l	SCR_SIZE,d0
;	add.l		LOG_SIZE,d0
;	add.l		PACK_SIZE,d0
;	add.l		FRAME_SIZE,d0
;	move.l	d0,SCREEN_USED

;	clr.l		STRAM_SYS
;	clr.l		VRAM_SYS

;	move.l	BRUSH_1_SIZE,d0
;	move.w	BRUSH_1_HANDLE,d3
;	bsr		find_typeused

;	move.l	BRUSH_2_SIZE,d0
;	move.w	BRUSH_2_HANDLE,d3
;	bsr		find_typeused

;	move.l	BRUSH_3_SIZE,d0
;	move.w	BRUSH_3_HANDLE,d3
;	bsr		find_typeused

;	move.l	BRUSH_4_SIZE,d0
;	move.w	BRUSH_4_HANDLE,d3
;	bsr		find_typeused

;	move.l	SCR_SIZE,d0
;	move.w	PHYS_HANDLE,d3
;	bsr		find_typeused

;	move.l	LOG_SIZE,d0
;	move.w	LOG_HANDLE,d3
;	bsr		find_typeused

;	move.l	PACK_SIZE,d0
;	move.w	PACK_HANDLE,d3
;	bsr		find_typeused

;	move.l	FRAME_SIZE,d0
;	move.w	FRAME_HANDLE,d3
;	bsr		find_typeused

	rts

;find_typeused:
;	clr.l		d1
;	clr.l		d2
;	btst		#altram_bit,d3
;	beq.s		.nb1
;	move.l	d0,d2
;	bra.s		.yb1
;.nb1:	move.l	d0,d1
;.yb1:	add.l		d1,STRAM_SYS
;	add.l		d2,VRAM_SYS
;	rts


CUR_TEXT:	dc.b	"K  ",0
AV_TEXT:	dc.b	":1 ",0
SPACE:	dc.b	32,32,0		
		even

STRAM_SYS:		ds.l	1
VRAM_SYS:		ds.l	1
;BRUSH_USED:		ds.l	1
;SCREEN_USED:	ds.l	1

TOTAL_USED:		ds.l	1
TOTAL_FREE:		ds.l	1

;MENBAR_SIZE:	ds.l	1
;FRMBAR_SIZE:	ds.l	1

FREE:			ds.l	1
USED:			ds.l	1
CURRENT:		ds.l	1

AVERAGE:		ds.w	1
	
*-----------------------------------------------------------------------*
*	Mouse routines									*
*-----------------------------------------------------------------------*

NMOUSE_X:			ds.w	1
NMOUSE_Y:			ds.w	1
OMOUSE_X:			ds.w	1
OMOUSE_Y:			ds.w	1
CMOUSE_X:			ds.w	1
CMOUSE_Y:			ds.w	1

Init_mouse:
	move.w	MOUSE_STYLE,d0
	cmp.w		#4,d0
	blt.s		.okc
	moveq		#3,d0
.okc	tst.b		TRUE_FLAG
	bne		Init_mouse_true
	lea		MOUSELIST,a0
	move.l	(a0,d0.w*4),a0
	lea		MOUSEPTR,a1
	lea		MOUSEMASK,a2
	lea		IFACE_COLOURS,a3
	moveq		#mouse_height-1,d6
	moveq		#0,d0
.line	moveq		#16-1,d7
.dots	push.w	d7
	moveq		#0,d7
	move.b	(a0)+,d0
	beq.s		.ok
	move.w	(a3,d0.w*2),d7
	bne.s		.ok
	move.b	d0,d7
.ok	add.b		d7,d7
	addx.w	d4,d4
	add.b		d7,d7
	swap		d4
	addx.w	d4,d4
	swap		d4
	add.b		d7,d7
	addx.w	d3,d3
	add.b		d7,d7
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d7,d7
	addx.w	d2,d2
	add.b		d7,d7
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d7,d7
	addx.w	d1,d1
	add.b		d7,d7
	swap		d1
	addx.w	d1,d1
	swap		d1
	pop.w		d7
	dbra		d7,.dots
	move.l	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.w	d1,d7
	or.w		d2,d7
	or.w		d3,d7
	or.w		d4,d7
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	or.w		d1,d7
	or.w		d2,d7
	or.w		d3,d7
	or.w		d4,d7
	not.w		d7
	move.w	d7,(a2)+
	dbra		d6,.line
	rts

Init_mouse_true:
	move.w	MOUSE_STYLE,d0
	lea		MOUSELIST,a0
	move.l	(a0,d0.w*4),a0
	lea		MOUSEPTR,a1
	lea		MOUSEMASK,a2
	lea		IFACE_COLOURS,a3
	move.w	#(16*mouse_height)-1,d6
	moveq		#0,d0
.line	moveq		#0,d7
	move.b	(a0)+,d0
	beq.s		.ok
	move.w	(a3,d0.w*2),d7
	bne.s		.ok
	move.w	d0,d7
.ok	move.w	d7,(a1)+
	beq.s		.norm
	moveq		#-1,d7		
.norm	not.w		d7
	move.w	d7,(a2)+
	dbra		d6,.line

;	addq.b	#1,HOLD_VBLANK
;	cache		norm|iclr
;	lea		Mod_code,a0
;	move.w	physwid,d1
;	moveq		#7-1,d0
;.lp:	move.w	d1,(a0)
;	add.w		physwid,d1
;	addq.l	#4,a0
;	dbra		d0,.lp
;	cache		norm|iclr
;	subq.b	#1,HOLD_VBLANK

	rts

MousePtr_driver:
	tst.b		MOUSE_ON		; is mouse on?
	beq.s		Stop_mouseptr	; just turned off.
	bpl.s		Move_mouseptr	; yes, print it
	rts

Stop_mouseptr:
	move.b	#-1,MOUSE_ON
	tst.b		ON_SCREEN
	beq.s		.quit
	sf		ON_SCREEN
	bsr.s		Remove_mouseptr
.quit	rts

Move_mouseptr:
	move.l	MOUSE_X,d0
	move.l	LAST_MOUSE,d1
	move.l	d0,LAST_MOUSE
	tst.b		ON_SCREEN
	beq.s		.upd
	cmp.l		d0,d1
	beq.s		.same
	bsr.s		Remove_mouseptr
.upd	bsr		Update_mouseptr
	st		ON_SCREEN
.same	rts

Remove_mouseptr:
	tst.b		CROSSHAIR
	bne		Remove_crosshair
	lea		MOUSEKEEP,a0
	move.l	MOUSE_SCR,a2
	move.w	OMOUSE_X(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.okx3
	moveq		#0,d0
.okx3	tst.b		TRUE_FLAG
	bne.s		.true
	and.w		#-16,d0
	bra.s		.plan
.true	add.w		d0,d0
.plan	add.w		d0,a2
	move.w	OMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.okx4
	moveq		#0,d0
.okx4	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	moveq		#mouse_height-1,d2
	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.plp
	add.w		d6,d2
	bmi.s		.out
.plp	move.l	a2,a3
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	a3,a2
	add.w		physwid,a2
	dbra		d2,.plp
.out	move.w	MOUSE_YC,MOUSE_VCLIP
	rts

Print_mouseptr:
	move.l	MOUSE_X,d0
	move.l	d0,NMOUSE_X
	move.l	d0,OMOUSE_X
	tst.b		CROSSHAIR
	bne		Print_crosshair
	bra		Draw_mouseptr
	
Update_mouseptr:
	move.l	MOUSE_X,d0
	move.l	d0,NMOUSE_X
	move.l	d0,OMOUSE_X
	tst.b		CROSSHAIR
	bne		Print_crosshair
	lea		MOUSEKEEP,a0
	move.l	MOUSE_SCR,a2
	move.w	NMOUSE_X(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.okx3
	moveq		#0,d0
.okx3	tst.b		TRUE_FLAG
	bne.s		.true
	and.w		#-16,d0
	bra.s		.plan
.true	add.w		d0,d0
.plan	add.w		d0,a2
	move.w	NMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.okx4
	moveq		#0,d0
.okx4	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	moveq		#mouse_height-1,d2
	move.w	physwid,d1
	ext.l		d1
	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.plp
	add.w		d6,d2
	bmi		Draw_mouseptr
.plp	move.l	a2,a3
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	lea		(a3,d1.l),a2
	dbra		d2,.plp

Draw_mouseptr:
	tst.b		TRUE_FLAG
	bne		Draw_mouseptr_true
	moveq		#mouse_height-1,d5
	lea		MOUSEMASK,a0
	lea		MOUSEPTR,a1
	move.l	MOUSE_SCR,a2
	move.w	NMOUSE_X(pc),d0
	subq		#mouse_height/2,d0
	bmi		off_left
	moveq		#mouse_height,d1
	add.w		d0,d1
	move.w	X_RESOLUTION,d2
	cmp.w		d2,d1
	bgt		off_right
	move.w	d0,d1
	and.w		#-16,d0
	add.w		d0,a2
	move.w	NMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.oky2
	add.w		d0,d5
	bmi		.out
	add.w		d0,d0
	sub.w		d0,a0
	add.w		d0,d0
	add.w		d0,d0
	add.w		d0,d0
	sub.w		d0,a1
	moveq		#0,d0
	bra.s		.oky3
.oky2	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.oky3
	add.w		d6,d5
	bmi		.out
.oky3	move.w	physwid,a4
	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	and.w		#16-1,d1
	neg.w		d1
	add.w		#16,d1
.prlp	moveq		#-1,d6
	move.w	(a0)+,d6
	rol.l		d1,d6
	move.l	d6,d3
	move.l	d6,d4
	swap		d4
	move.w	d6,d4
	swap		d6
	move.w	d6,d3
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d4,(a2)+
	and.l		d4,(a2)+
	and.l		d4,(a2)+
	and.l		d4,(a2)+
	lea		-32(a2),a2
	rept		8
	moveq		#0,d7
	move.w	(a1)+,d7
	lsl.l		d1,d7
	or.w		d7,16(a2)
	swap		d7
	or.w		d7,(a2)+
	endr
	add.l		a4,a2
	lea		-16(a2),a2
	dbra		d5,.prlp
.out	rts

off_right:
	sub.w		#16,d0
	move.w	d0,d1
	and.w		#-16,d0
	lea		16(a2,d0.w),a2
	move.w	NMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.oky2
	add.w		d0,d5
	bmi		.out
	add.w		d0,d0
	sub.w		d0,a0
	add.w		d0,d0
	add.w		d0,d0
	add.w		d0,d0
	sub.w		d0,a1
	moveq		#0,d0
	bra.s		.oky3
.oky2	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.oky3
	add.w		d6,d5
	bmi.s		.out
.oky3	move.w	physwid,a4
	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	and.w		#16-1,d1
.prlp	moveq		#-1,d6
	move.w	(a0)+,d6
	ror.l		d1,d6
	move.l	d6,d3
	swap		d3
	move.w	d6,d3
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	lea		-16(a2),a2
	rept		8
	move.w	(a1)+,d7
	lsr.w		d1,d7
	or.w		d7,(a2)+
	endr
	add.l		a4,a2
	lea		-16(a2),a2
	dbra		d5,.prlp
.out	rts

off_left:
	add.w		#16,d0
	move.w	d0,d1
	and.w		#-16,d0
	add.w		d0,a2
	move.w	NMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.oky2
	add.w		d0,d5
	bmi		.out
	add.w		d0,d0
	sub.w		d0,a0
	add.w		d0,d0
	add.w		d0,d0
	add.w		d0,d0
	sub.w		d0,a1
	moveq		#0,d0
	bra.s		.oky3
.oky2	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.oky3
	add.w		d6,d5
	bmi.s		.out
.oky3	move.w	physwid,a4
	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	and.w		#16-1,d1
	neg.w		d1
	add.w		#16,d1
.prlp	moveq		#-1,d6
	move.w	(a0)+,d6
	rol.l		d1,d6
	move.l	d6,d3
	swap		d3
	move.w	d6,d3
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	and.l		d3,(a2)+
	lea		-16(a2),a2
	rept		8
	moveq		#0,d7
	move.w	(a1)+,d7
	lsl.w		d1,d7
	or.w		d7,(a2)+
	endr
	add.l		a4,a2
	lea		-16(a2),a2
	dbra		d5,.prlp
.out	rts

Draw_mouseptr_true:
	moveq		#mouse_height-1,d5
	move.w	#mouse_height,a4		; mouse width	
	lea		MOUSEMASK,a0
	lea		MOUSEPTR,a1
	move.l	MOUSE_SCR,a2
	move.w	NMOUSE_X(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.nlft
	add.w		d0,a4				; clip left
	add.w		d0,d0
	sub.w		d0,a0
	sub.w		d0,a1
	moveq		#0,d0
.nlft	moveq		#mouse_height,d1
	add.w		d0,d1
	move.w	X_RESOLUTION,d2
	sub.w		d1,d2
	bpl.s		.nrt
	add.w		d2,a4
.nrt	move.w	d0,d1
	add.w		d0,d0
	add.w		d0,a2
	move.w	NMOUSE_Y(pc),d0
	subq		#mouse_height/2,d0
	bpl.s		.oky2
	add.w		d0,d5
	bmi.s		.out
	lsl.w		#5,d0
	sub.w		d0,a0
	sub.w		d0,a1
	moveq		#0,d0
	bra.s		.oky3
.oky2	move.w	MOUSE_YC(pc),d6
	sub.w		NMOUSE_Y(pc),d6
	subq		#mouse_height/2,d6
	bpl.s		.oky3
	add.w		d6,d5
	bmi.s		.out
.oky3	move.l	(PHYS_Y.l,d0.w*4),d0
	add.l		d0,a2
	subq		#1,a4
.ylp	move.l	a0,a5
	move.l	a1,a6
	move.l	a2,a3
	move.w	a4,d4
.xlp	move.w	(a5)+,d3
	and.w		d3,(a3)
	move.w	(a6)+,d3
	or.w		d3,(a3)+
	dbra		d4,.xlp
	add.w		physwid,a2
	lea		16*2(a0),a0
	lea		16*2(a1),a1
	dbra		d5,.ylp
.out	rts

MOUSE_YC		dc.w	draw_height
MOUSE_VCLIP		dc.w	draw_height

Print_crosshair:
	move.l	NMOUSE_X,CMOUSE_X
	bra.s		Draw_crosshair

Remove_crosshair:
	move.l	OMOUSE_X,CMOUSE_X
	bsr		Draw_crosshair
	move.w	MOUSE_YC,MOUSE_VCLIP
	rts

Draw_crosshair:
	tst.b		TRUE_FLAG
	bne		Draw_crosshair_true
	move.w	CMOUSE_X(pc),d0
	moveq		#16-1,d1
	and.w		d0,d1
	neg.w		d1
	add.w		#16-1,d1
	moveq		#0,d2
	bset		d1,d2
	swap		d2
	bset		d1,d2
	and.w		#-16,d0
	move.l	MOUSE_SCR,a1
	add.w		d0,a1
	moveq		#-2,d4
	add.w		physwid,d4
	ext.l		d4
	lea		14(a1),a1
	move.w	MOUSE_VCLIP,d0
	addq		#1,d0
	lsr.w		d0
	bcc.s		.even
	eor.w		d2,(a1)+
	add.l		d4,a1
.even	subq		#1,d0
.lp	eor.w		d2,(a1)+
	add.l		d4,a1
	eor.w		d2,(a1)+
	add.l		d4,a1
	dbra		d0,.lp
	moveq		#-1,d2
	move.w	CMOUSE_Y(pc),d0
	move.l	(PHYS_Y.l,d0.w*4),d0
	move.l	MOUSE_SCR,a1
	add.l		d0,a1
	move.w	#20/4,d3
	xresfactor	d3
	subq		#1,d3
	moveq		#14,d4
.plp	add.l		d4,a1
	not.w		(a1)+
	rept		4-1
	add.l		d4,a1
	not.w		(a1)+
	endr
	dbra		d3,.plp
	rts

Draw_crosshair_true:
	move.w	CMOUSE_X(pc),d0
	move.l	MOUSE_SCR,a1
	add.w		d0,d0
	add.w		d0,a1
	move.w	physwid,d4
	ext.l		d4
	move.w	MOUSE_VCLIP,d0
	addq		#1,d0
	lsr.w		d0
	bcc.s		.ev1
	not.w		(a1)
	add.l		d4,a1
.ev1	lsr.w		d0
	bcc.s		.ev2
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
.ev2	lsr.w		d0
	bcc.s		.ev3
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
.ev3
	subq.w	#1,d0
.lp	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	not.w		(a1)
	add.l		d4,a1
	dbra		d0,.lp

;	lsl.l		#3,d4
;	subq.w	#1,d0
;.lp	not.w		(a1)
;.mod	not.w		2(a1)
;	not.w		2(a1)
;	not.w		2(a1)
;	not.w		2(a1)
;	not.w		2(a1)
;	not.w		2(a1)
;	not.w		2(a1)
;	add.l		d4,a1
;	dbra		d0,.lp

	moveq		#-1,d2
	move.w	CMOUSE_Y(pc),d0
	move.l	(PHYS_Y.l,d0.w*4),d0
	move.l	MOUSE_SCR,a1
	add.l		d0,a1
	move.w	X_RESOLUTION,d3
	lsr.w		#4,d3	
	subq		#1,d3
.plp	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	not.l		(a1)+
	dbra		d3,.plp
	rts

;Mod_code:	=	.mod+2

*-----------------------------------------------------------------------*

Update_palette:
	tst.b		TRUE_FLAG
	bne		.true
*-----------------------------------*
.make	tst.b		EXTEND
	bne.s		.lace
*-----------------------------------*
.norm	lea		COLOURS,a0
	lea		PALETTE1,a1
	moveq		#(256/4)-1,d0
.copy
	rept		4
	move.l	(a0)+,d1
	lsl.l		#8,d1
	lsr.w		#8,d1
	move.l	d1,(a1)+
	endr
	dbra		d0,.copy
	move.l	#PALETTE1,HW_PALETTE
	bra		.rts
*-----------------------------------*
.lace	lea		COLOURS,a0
	lea		PALETTE1,a1
	lea		PALETTE2,a2
	lea		PULSE_1,a3
	lea		PULSE_2,a4
	bsr		load_palette
	lea		COLOURS,a0
	lea		PALETTE3,a1
	lea		PALETTE4,a2
	lea		PULSE_3,a3
	lea		PULSE_4,a4
	bsr		load_palette
	bra.s		.rts
*-----------------------------------*
.true	clr.l		$FFFF9800.w
.rts	rts

load_palette:
	moveq		#0,d0
	moveq		#0,d1
	moveq		#(256/4)-1,d7
.dacs
	rept		4
	addq.l	#1,a0
	move.b	(a0)+,d0
	move.b	(a3,d0.w),(a1)+
	move.b	(a4,d0.w),(a2)+
	move.b	(a0)+,d0
	move.b	(a3,d0.w),(a1)+
	move.b	(a4,d0.w),(a2)+
	move.b	(a0)+,d0
	addq.l	#1,a1
	move.b	(a3,d0.w),(a1)+
	addq.l	#1,a2
	move.b	(a4,d0.w),(a2)+
	endr
	dbra		d7,.dacs
	rts

PULSE_PHASE:	dc.l	PALETTE1
			dc.l	PALETTE2
			dc.l	PALETTE3
			dc.l	PALETTE4

HW_PALETTE:		ds.l	1

vbi_direction:	dc.l	active_vbi

*-----------------------------------*
NEW_VBI:					*
*-----------------------------------*

	ifnd		nicetimers

	tst.w		bypass_count
	bmi.s		active_vbi
	subq.w	#1,bypass_count
	jmp		([vbi_direction.l])

	endc

*-----------------------------------*
active_vbi:
*-----------------------------------*

	ifnd		nicetimers

	move.w	sr,keepsr
	move.w	#$2700,sr
	move.b	#0,CTRL_B.w
	move.b	#100,DATA_B.w
	move.b	#8,CTRL_B.w

	endc

*-----------------------------------*
	pea		(a0)
	pea		(a1)
	push.l	d0
*-----------------------------------*
	move.l	HW_PALETTE,d0
	beq.s		.npu
*-----------------------------------*
	lea		$FFFF9800.w,a1
	move.l	d0,a0
	move.w	#(256/8)-1,d0
.cop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra		d0,.cop
	clr.l		HW_PALETTE
*-----------------------------------*
.npu:	pop.l		d0
	pop.l		a1
	pop.l		a0
*-----------------------------------*
.cont

	ifnd		nicetimers

	move.w	keepsr,sr

	endc

*-----------------------------------*
	pushall
*-----------------------------------*
	tst.b		HOLD_VBLANK
	bne.s		.skip
	jsr		MousePtr_driver
	not.b		STROBE2
	bne.s		.skip
	jsr		information
*-----------------------------------*
*	Screen phasing routine		*
*-----------------------------------*
.skip	tst.b		EXTEND
	beq.s		.nlac
	moveq		#4-1,d0
	and.w		PHASE_COUNT(pc),d0
	lea		PULSE_PHASE,a0
	move.l	(a0,d0.w*4),HW_PALETTE
.nlac	addq.w	#1,PHASE_COUNT
*-----------------------------------*
	bsr		FIND_ICON
*-----------------------------------*
	tst.w		TIMER
	ble.s		.rts
	subq		#1,TIMER
*-----------------------------------*
.rts	popall
*-----------------------------------*

	ifnd		nicetimers

	addq.l	#1,$462.w
	addq.l	#1,$466.w
	move.w	#3,bypass_count
	tst.b		no_stabilizer
	bne.s		bypass_vbi
	move.l	#bypass_vbi,vbi_direction

	endc

*-----------------------------------*
bypass_vbi:
*-----------------------------------*

	ifnd		nicetimers

	IFD		CUSTOM
	rte
	ELSEIF
	jmp		([OLD_VBI.l])
	ENDC

	elseif

	rts

	endc
	
PHASE_COUNT:	ds.w	1
keepsr:		ds.w	1
bypass_count:	ds.w	1


;	ifd		protection
;	incbin	inc\venomous.key
;	ds.b		apexdata_len
;	endc

	INFO_POINT


*-----------------------------------*
information:
*-----------------------------------*
	tst.b		HOLD_STATS
	bne		.done
	tst.w		Delta_count
	beq		.done
	push.w	scrwid
	push.l	CHAR_X
	push.w	CHAR_COL
	push.b	CHAR_SOLID
*-----------------------------------*
	move.b	HOLD_COORDS,d0
	or.b		FRAMECOUNT,d0
	bne.s		.ncoo
	jsr		PRINT_COORDS
*-----------------------------------*
.ncoo	jsr		ram_bar
	tst.b		HOLD_INFOBAR
	bne.s		.skip
	jsr		busy_bar
	jsr		PRINT_FRAME
*-----------------------------------*
.skip	pop.b		CHAR_SOLID
	pop.w		CHAR_COL
	pop.l		CHAR_X
	pop.w		scrwid
.done	rts
	
ram_bar:
	tst.b		active
	beq.s		.rts
	tst.b		DRAW_LOOP
	bne.s		.rts
	cmp.b		#no_menu,MENU_STATE
	bne.s		.go
.rts	rts
.go	addq.b	#1,rambar_strobe
	and.b		#4-1,rambar_strobe
	bne.s		.rts
update_ram_bar:
	jsr		LOCATE_RAM
	move.l	STRAM_USED,d3
	sub.l		STRAM_SYS,d3
	bpl.s		.c1
	clr.l		d3
.c1:	move.l	STRAM_FREE,d1
	move.w	#178,d2
	move.w	IFACE_COLOURS+2*iface_red,d0
	movem.l	d0-d3,-(sp)
	bsr		draw_rambar
	movem.l	(sp)+,d0-d3
	tst.b		VRAM
	beq.s		.go
	move.l	VRAM_USED,d3
	sub.l		VRAM_SYS,d3
	bpl.s		.c2
	clr.l		d3
.c2:	move.l	VRAM_FREE,d1
	move.w	#180,d2
	move.w	IFACE_COLOURS+2*iface_blue,d0
.go:	bsr		draw_rambar
	rts

draw_rambar:	
	push.w	d0
	move.l	d2,d4
	addq.l	#1,d4

	add.l		d3,d1

	mulu.l	#29-2,d3
	divu.l	d1,d3
	addq.l	#2,d3

	push.w	d3
	move.w	d3,d1
	move.w	#29,d3
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		y_factor,d4
	subq		#1,d4
	move.w	IFACE_COLOURS+2*iface_white,d0
	or.b		gensol,d0
	push.w	d2
	push.w	d4
	jsr		DRAW_PHYS_BLOCK
	pop.w		d4
	pop.w		d2
	pop.w		d3
	pop.w		d0
	moveq		#2,d1
	xresfactor	d1,d3
	or.b		gensol,d0
	jsr		DRAW_PHYS_BLOCK
	rts

rambar_strobe:	ds.b	1
			even
			
*-----------------------------------------------------------------------*

FIND_ICON:
	tst.b		GOT_PRESS
	beq.s		.out
	tst.b		FREEZE_ICONS
	bne.s		.out
	move.w	BUTTON_X,d5
	move.w	BUTTON_Y,d6
	ext.l		d5
	ext.l		d6
	divs		x_factor,d5
	divs		y_factor,d6
	move.l	ICON_LIST(pc),a0
.loop	move.w	icon_name(a0),d0		; get ident
	ble.s		.done
	move.l	a0,a1
	lea		icon_len(a0),a0
	move.w	icon_x1(a1),d1
	cmp.w		d1,d5
	blt.s		.loop
	move.w	icon_x2(a1),d3
	cmp.w		d3,d5
	bgt.s		.loop
	move.w	icon_y1(a1),d2
	cmp.w		d2,d6
	blt.s		.loop
	move.w	icon_y2(a1),d4
	cmp.w		d4,d6
	bgt.s		.loop
	movem.w	d1-d4,ICON_AREA
	move.w	d0,ICON
	move.w	d0,LAST_ICON
	move.l	a0,ICON_PTR
	move.l	BUTTON_X,ICON_X
.out	clr.b		GOT_PRESS
	rts
.done	bne.s		.out
	move.l	2(a0),a0
	bra.s		.loop

ICON_PTR:	ds.l	1

FIND_HELP:
	tst.b		FREEZE_ICONS
	bne.s		.rts
	move.w	MOUSE_X,d5
	move.w	MOUSE_Y,d6
	ext.l		d5
	ext.l		d6
	divs		x_factor,d5
	divs		y_factor,d6
	move.l	ICON_LIST(pc),a0
	lea		-icon_len(a0),a0
.loop	lea		icon_len(a0),a0
.new	move.w	icon_name(a0),d0		; get ident
	ble.s		.done
	move.w	icon_x1(a0),d1
	cmp.w		d1,d5
	blt.s		.loop
	move.w	icon_x2(a0),d3
	cmp.w		d3,d5
	bgt.s		.loop
	move.w	icon_y1(a0),d2
	cmp.w		d2,d6
	blt.s		.loop
	move.w	icon_y2(a0),d4
	cmp.w		d4,d6
	bgt.s		.loop
	move.l	icon_help(a0),HELP_TEXT
.rts	rts
.done	beq.s		.next
	clr.l		HELP_TEXT
	rts
.next	move.l	2(a0),a0
	bra.s		.new

HELP_TEXT:	ds.l	1
ICON_LIST:	dc.l	DRAWSTATION_ICONS
TOOL_ICONS:	dc.l	DRAWSTATION_ICONS

PRINT_HELP:
	push.w	CHAR_COL
	push.b	CHAR_SOLID
	move.w	#10,CHAR_COL
	sf		CHAR_SOLID
	cmp.b		#no_menu,MENU_STATE
	beq		.same
	move.l	HELP_TEXT,d0
	cmp.l		OLD_HELP,d0
	beq		.same
	move.l	d0,OLD_HELP
	tst.l		d0
	beq.s		.clr
.new	push.l	d0
	jsr		HIDE_MOUSE
	bsr		patch_help
	move.w	#136,CHAR_X
	moveq		#4,d0
	add.w		y_factor,d0
	move.w	d0,CHAR_Y
	cmp.w		#2,y_factor
	beq.s		.go2
	cmp.w		#1,x_factor
	beq.s		.go
	subq		#1,CHAR_Y
	bra.s		.go
.go2	cmp.w		#2,x_factor
	beq.s		.go
	addq		#1,CHAR_Y
.go	pop.l		a0
	bsr		PRINT_LINE
	jsr		SHOW_MOUSE
	bra.s		.same
.clr	jsr		HIDE_MOUSE
	bsr		patch_help
	jsr		SHOW_MOUSE
.same	pop.b		CHAR_SOLID
	pop.w		CHAR_COL
	rts

patch_help:
	move.w	#135,d1
	move.w	#6*24,d3
	move.w	#4,d2
	move.w	#7,d4
	move.w	MAINGFX_HANDLE,d0			
	jmp		Patch_menu
	
*-----------------------------------------------------------------------*
*	Mouse routines									*
*-----------------------------------------------------------------------*

	IFD		GEM_IKBD

INIT_IKBD:
	pea		-1.w
	pea		-1.w
	pea		-1.w
	push.w	#16
	trap		#14
	add.w		#14,sp
	move.l	d0,a0
	move.l	(a0),GSX_PTR
	jsr		init_translator
	push.w	#34			get address	of ikbd vector table
	trap		#14
	addq		#2,sp
	move.l	d0,a0			in a0
	move.l	a0,OLD_KBD
	move.l	16(a0),OLDMPACK
	move.l	24(a0),OLDJPACK
	move.l	#MUS_PACK,16(a0)
	move.l	#ARTS,24(a0)
	rts

RESET_IKBD:
	move.l	OLD_KBD,a0
	move.l	OLDMPACK,16(a0)
	move.l	OLDJPACK,24(a0)
	rts

MUS_PACK:
	push.w	d0
	push.w	d1
	move.b	(a0)+,d1		buttons
.xpos	move.b	(a0)+,d0		delta	x
	ext.w		d0
	add.w		d0,MOUSE_X
	bpl.s		.xpl
	clr.w		MOUSE_X
.xpl	move.w	X_RESOLUTION,d0
	subq		#1,d0
	cmp.w		MOUSE_X,d0
	bge.s		.ypos
	move.w	d0,MOUSE_X
.ypos	move.b	(a0)+,d0		delta	x
	ext.w		d0
	add.w		d0,MOUSE_Y
	bpl.s		.ypl
	clr.w		MOUSE_Y
.ypl	move.w	MOUSE_Y,d0
	cmp.w		MOUSE_VCLIP,d0
	ble.s		.out
	move.w	MOUSE_VCLIP,MOUSE_Y
.out	and.b		#4-1,d1
	cmp.b		BUTTONS,d1
	beq.s		.exit
	move.b	d1,BUTTONS
	beq.s		.exit
	move.b	d1,ICON_BUTTON
	move.l	MOUSE_X,BUTTON_X
;	bmi.s		.exit
	move.b	#1,GOT_PRESS
.exit	pop.w		d1
	pop.w		d0
.none	rts

GET_CHAR:
	moveq		#0,d1
.get	push.w	#11
	trap		#1
	addq		#2,sp	
	moveq		#0,d1
	tst.b		d0
	beq.s		.rts
	push.w	#7
	trap		#1
	addq		#2,sp
	move.l	d0,d1
	swap		d1
	jsr		translate
.rts	rts

translate:
	and.w		#255,d1
	beq.s		.keep
	move.b	(translator_table.w,pc,d1.w),d2
	cmp.b		#-1,d2
	beq.s		.keep
	and.w		#255,d0
	move.b	(ASCII2SC.w,pc,d0.w),d2
	beq.s		.keep
	move.b	d2,d1
.keep	rts
	
EMPTY_BUFFER:
	pushall
.bak	push.w	#11
	trap		#1
	addq		#2,sp
	tst.l		d0
	beq.s		.out
	push.w	#7
	trap		#1
	addq		#2,sp
	bra.s		.bak
.out	popall
	rts

WAIT_KEY:
	push.w	#11
	trap		#1
	addq		#2,sp
	tst.l		d0
	beq.s		WAIT_KEY
	push.w	#7
	trap		#1
	addq		#2,sp
	rts

	ELSEIF

*-----------------------------------------------------------------------*
*	New IKBD routines									*
*-----------------------------------------------------------------------*

NEW_IKBD:

Main_IKBD:
	push.l	d0
	move.b	$FFFFFC00.w,d0
	and.w		#%0000000001110000,d0
	bne.s		IKBD_Error
	move.b	$FFFFFC02.w,d0
	addq.b	#8,d0
	cmp.b		#4,d0
	bcc.s		.data
	and.b		#4-1,d0
	cmp.b		BUTTONS,d0
	beq.s		.exit
	move.b	d0,BUTTONS
	beq.s		.exit
	move.b	d0,ICON_BUTTON
	move.l	MOUSE_X,BUTTON_X
	move.b	#1,GOT_PRESS
.exit	st		mouse_busy
	move.l	#Read_X_Packet,KBD_VEC.w	
	pop.l		d0
	bclr		#6,IN_SERVICE_B.w
	rte
.data	subq.b	#8,d0
	ble		IKBD_Exit
	pea		(a0)
	move.l	KEY_BUFFER(pc),a0
	move.b	d0,(a0)+
	cmp.l		#keybuff_end,a0
	blt.s		.cont
	lea		keybuff(pc),a0
.cont	move.l	a0,KEY_BUFFER
	pop.l		a0
IKBD_Exit:
	pop.l		d0
	bclr		#6,IN_SERVICE_B.w
	rte
IKBD_Error:
	move.l	#Main_IKBD,KBD_VEC.w
	pop.w		d0
	bclr		#6,IN_SERVICE_B.w
	rte

Read_X_Packet:
	push.l	d0
	move.b	$FFFFFC02.w,d0
	ext.w		d0
	add.w		d0,MOUSE_X
	bpl.s		.more
	clr.w		MOUSE_X
.more	move.w	X_RESOLUTION,d0
	subq		#1,d0
	cmp.w		MOUSE_X,d0
	bge.s		.less
	move.w	d0,MOUSE_X
.less	move.l	#Read_Y_Packet,KBD_VEC.w
	pop.l		d0
	bclr		#6,IN_SERVICE_B.w
	rte

Read_Y_Packet:
	push.l	d0
	move.b	$FFFFFC02.w,d0
	ext.w		d0
	add.w		d0,MOUSE_Y
	bpl.s		.more
	clr.w		MOUSE_Y
.more	move.w	MOUSE_Y,d0
	cmp.w		MOUSE_VCLIP,d0
	ble.s		.less
	move.w	MOUSE_VCLIP,MOUSE_Y
.less	move.l	#Main_IKBD,KBD_VEC.w
	sf		mouse_busy
	pop.l		d0
	bclr		#6,IN_SERVICE_B.w
	rte

KEY_BUFFER:		dc.l	keybuff

keybuff:		ds.b	32
keybuff_end:
mouse_busy:		ds.b	1
			even
OLD_IKBD:		ds.l	1

GET_CHAR:
	bset		#6,IN_SERVICE_B.w
	move.l	KEY_BUFFER(pc),a0
	subq.l	#1,a0
	cmp.l		#keybuff,a0
	bge.s		.nw1
	lea		-1+keybuff_end(pc),a0
.nw1	moveq		#0,d0
	moveq		#0,d1
	move.b	(a0),d1
	beq.s		.rts
	move.b	d0,(a0)
	move.l	a0,KEY_BUFFER
	move.b	(GSX_CODES.w,pc,d1),d0
.rts	bclr		#6,IN_SERVICE_B.w
	rts

WAIT_KEY:
	pushall
.test	bsr		GET_CHAR
	tst.b		d1
	beq.s		.test
	popall
	rts

EMPTY_BUFFER:
	pushall
.test	bsr		GET_CHAR
	tst.b		d1
	bne.s		.test
	popall
	rts	

INIT_IKBD:
	pea		-1.w
	pea		-1.w
	pea		-1.w
	push.w	#16
	trap		#14
	add.w		#14,sp
	move.l	d0,a0
	move.l	(a0),GSX_PTR
	jsr		init_translator
;	move.w	#$2700,sr
	move.l	KBD_VEC.w,OLD_IKBD
	move.l	#NEW_IKBD,KBD_VEC.w
;	move.w	#$2300,sr
;	move.b	#8,$FFFFFC02.w
	rts

RESET_IKBD:
.wait	tst.b		mouse_busy
	bne.s		.wait
;	move.w	#$2700,sr
	move.l	OLD_IKBD,KBD_VEC.w
;	move.w	#$2300,sr
	rts

MOUSE_SPEED:
	dc.b		$B
	dc.b		1,1
	even

MOUSE_RELATIVE:
	dc.b		8
	even
	
IKBD_RESET:
	dc.b		$80,1
	even

	ENDC

init_translator:
	lea		GSX_CODES,a0
	lea		ASCII2SC,a1
	move.w	#256-1,d7
.next	moveq		#118-1,d6
.slp	moveq		#0,d0
	move.b	d7,d0
	cmp.w		#'a',d0
	blt.s		.o
	cmp.w		#'z',d0
	bgt.s		.o
	sub.w		#'a'-'A',d0
.o	cmp.b		(a0,d6.w),d0
	bne.s		.no
	move.b	d6,(a1,d7.w)
.no	dbra		d6,.slp
	dbra		d7,.next
	rts

translator_table:
	dc.b		0				; null
	dc.b		0				; ESC
	dc.b		0				; 1
	dc.b		0				; 2
	dc.b		0				; 3
	dc.b		0				; 4
	dc.b		0				; 5
	dc.b		0				; 6
	dc.b		0				; 7
	dc.b		0				; 8
	dc.b		0				; 9
	dc.b		0				; 0
	dc.b		0				; -
	dc.b		0				; =
	dc.b		0				; BS
	dc.b		0				; TAB
	dc.b		0				; Q
	dc.b		0				; W
	dc.b		0				; E
	dc.b		0				; R
	dc.b		0				; T
	dc.b		0				; Y
	dc.b		0				; U
	dc.b		0				; I
	dc.b		0				; O
	dc.b		0				; P
	dc.b		0				; [
	dc.b		0				; ]
	dc.b		0				; RET
	dc.b		-1				* CNTL
	dc.b		0				; A
	dc.b		0				; S
	dc.b		0				; D
	dc.b		0				; F
	dc.b		0				; G
	dc.b		0				; H
	dc.b		0				; J
	dc.b		0				; K
	dc.b		0				; L
	dc.b		0				; ;
	dc.b		0				; '
	dc.b		0				; `
	dc.b		-1				* LEFT SHIFT
	dc.b		0				; #
	dc.b		0				; Z		**
	dc.b		0				; X
	dc.b		0				; C
	dc.b		0				; V
	dc.b		0				; B
	dc.b		0				; N
	dc.b		0				; M
	dc.b		0				; ,
	dc.b		0				; .
	dc.b		0				; /
	dc.b		-1				* RIGHT SHIFT
	dc.b		0	
	dc.b		-1				* ALT
	dc.b		0				; SPACE
	dc.b		-1				* CAPS
	dc.b		-1				; F1
	dc.b		-1				; F2
	dc.b		-1				; F3
	dc.b		-1				; F4
	dc.b		-1				; F5
	dc.b		-1				; F6
	dc.b		-1				; F7
	dc.b		-1				; F8
	dc.b		-1				; F9
	dc.b		-1				; F10
	dc.b		0
	dc.b		0
	dc.b		-1				; CLRHOME
	dc.b		-1				; UP ARROW
	dc.b		0
	dc.b		-1				; kpd -
	dc.b		-1				; LEFT ARROW
	dc.b		0
	dc.b		-1				; RIGHT ARROW
	dc.b		-1				; kpd +
	dc.b		0
	dc.b		-1				; DOWN ARROW
	dc.b		0
	dc.b		-1				; INSERT
	dc.b		0				; DELETE
	ds.b		96-84
	dc.b		0				; \		**
	dc.b		-1				; UNDO
	dc.b		-1				; HELP
	dc.b		-1				; kpd (
	dc.b		-1				; kpd )
	dc.b		-1				; kpd /
	dc.b		-1				; kpd *
	dc.b		-1				; kpd 7	*
	dc.b		-1				; kpd 8	*
	dc.b		-1				; kpd 9	*
	dc.b		-1				; kpd 4	*
	dc.b		-1				; kpd 5
	dc.b		-1				; kpd 6	*
	dc.b		-1				; kpd 1	*
	dc.b		-1				; kpd 2	*
	dc.b		-1				; kpd 3	*
	dc.b		-1				; kpd 0
	dc.b		-1				; kpd .
	dc.b		-1				; kpd ENTER
	ds.b		3
	even
		
ASCII2SC:
	ds.b		256

ESC	=	27
BS	=	8
TAB	=	9
CR	=	13
DEL	=	127

GSX_CODES:
	dc.b		0				; null
	dc.b		ESC				; ESC
	dc.b		"1"				; 1
	dc.b		"2"				; 2
	dc.b		"3"				; 3
	dc.b		"4"				; 4
	dc.b		"5"				; 5
	dc.b		"6"				; 6
	dc.b		"7"				; 7
	dc.b		"8"				; 8
	dc.b		"9"				; 9
	dc.b		"0"				; 0
	dc.b		"-"				; -
	dc.b		"="				; =
	dc.b		BS				; BS
	dc.b		TAB				; TAB
	dc.b		"Q"				; Q
	dc.b		"W"				; W
	dc.b		"E"				; E
	dc.b		"R"				; R
	dc.b		"T"				; T
	dc.b		"Y"				; Y
	dc.b		"U"				; U
	dc.b		"I"				; I
	dc.b		"O"				; O
	dc.b		"P"				; P
	dc.b		"["				; [
	dc.b		"]"				; ]
	dc.b		CR				; RET
	dc.b		-1				* CNTL
	dc.b		"A"				; A
	dc.b		"S"				; S
	dc.b		"D"				; D
	dc.b		"F"				; F
	dc.b		"G"				; G
	dc.b		"H"				; H
	dc.b		"J"				; J
	dc.b		"K"				; K
	dc.b		"L"				; L
	dc.b		";"				; ;
	dc.b		"'"				; '
	dc.b		"`"				; `
	dc.b		-1				* LEFT SHIFT
	dc.b		"#"				; #
	dc.b		"Z"				; Z		**
	dc.b		"X"				; X
	dc.b		"C"				; C
	dc.b		"V"				; V
	dc.b		"B"				; B
	dc.b		"N"				; N
	dc.b		"M"				; M
	dc.b		","				; ,
	dc.b		"."				; .
	dc.b		"/"				; /
	dc.b		-1				* RIGHT SHIFT
	dc.b		0	
	dc.b		-1				* ALT
	dc.b		" "				; SPACE
	dc.b		-1				* CAPS
	dc.b		-1				; F1
	dc.b		-1				; F2
	dc.b		-1				; F3
	dc.b		-1				; F4
	dc.b		-1				; F5
	dc.b		-1				; F6
	dc.b		-1				; F7
	dc.b		-1				; F8
	dc.b		-1				; F9
	dc.b		-1				; F10
	dc.b		0
	dc.b		0
	dc.b		-1				; CLRHOME
	dc.b		-1				; UP ARROW
	dc.b		0
	dc.b		-1				; kpd -
	dc.b		-1				; LEFT ARROW
	dc.b		0
	dc.b		-1				; RIGHT ARROW
	dc.b		-1				; kpd +
	dc.b		0
	dc.b		-1				; DOWN ARROW
	dc.b		0
	dc.b		-1				; INSERT
	dc.b		DEL				; DELETE
	ds.b		96-84
	dc.b		"\"				; \		**
	dc.b		-1				; UNDO
	dc.b		-1				; HELP
	dc.b		-1				; kpd (
	dc.b		-1				; kpd )
	dc.b		-1				; kpd /
	dc.b		-1				; kpd *
	dc.b		-1				; kpd 7	*
	dc.b		-1				; kpd 8	*
	dc.b		-1				; kpd 9	*
	dc.b		-1				; kpd 4	*
	dc.b		-1				; kpd 5
	dc.b		-1				; kpd 6	*
	dc.b		-1				; kpd 1	*
	dc.b		-1				; kpd 2	*
	dc.b		-1				; kpd 3	*
	dc.b		-1				; kpd 0
	dc.b		-1				; kpd .
	dc.b		-1				; kpd ENTER
	ds.b		3
	even

GSX_PTR:
	dc.l	GSX_CODES
	
*-------------------------------------------------------------------------*

Update_palette_zone:
Update_palette_bar:
Print_palette_bar:
	pushall
	lea		INDEX_TABLE,a0
	lea		COLOURS,a1
	moveq		#5,d3
	moveq		#5,d4
	xresfactor	d3
	yresfactor	d4
	moveq		#0,d0
	move.w	#201,d2
	yresfactor	d2
	move.w	#4-1,d7
.ylp	moveq		#0,d1
	move.w	#64-1,d6
.xlp	movem.l	d0-d7/a0-a1,-(sp)
	add.w		d1,d3
	add.w		d2,d4
	subq		#2,d3
	subq		#2,d4
	move.b	(a0,d0.w),d0
	bsr		INDEX2RGB
	bsr		DRAW_PHYS_BLOCK	
	movem.l	(sp)+,d0-d7/a0-a1
	addq		#1,d0
	add.w		d3,d1
	dbra		d6,.xlp
	add.w		d4,d2
	dbra		d7,.ylp
	bsr.s		Mark_colours
	popall
	rts

get_bgcolour:
	move.w	BG_COLOUR,d0
	bsr		INDEX2RGB
	tst.b		TRUE_FLAG
	beq.s		.err
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	move.b	d1,d0
	lsl.l		#8,d0
	move.b	d2,d0
	lsl.l		#8,d0
	move.b	d3,d0
.err	rts
	
INDEX2RGB:
	tst.b		TRUE_FLAG
	beq.s		.same
	move.l	(COLOURS.l,d0.w*4),d0
	bsr		RGB2WORD
.same	rts
	
RGB2WORD:
	push.l	d1
	moveq		#0,d1
	bfins		d0,d1{16:24}
	bfins		d0,d1{21:16}
	bfins		d0,d1{27:08}
	move.l	d1,d0
	pop.l		d1
	rts

Mark_colours:
	add.w		#60,Y_RESOLUTION
	bsr.s		Erase_markers
	bsr		Draw_markers
	sub.w		#60,Y_RESOLUTION
	move.w	COL1_INDEX,COL1_MARKER
	move.w	COL2_INDEX,COL2_MARKER
	move.w	FG_INDEX,FG_MARKER
	move.w	BG_INDEX,BG_MARKER
	rts
	
COL1_MARKER:	ds.w	1
COL2_MARKER:	ds.w	1
FG_MARKER:		ds.w	1
BG_MARKER:		ds.w	1
COL1_INDEX:		ds.w	1
COL2_INDEX:		ds.w	1
FG_INDEX:		ds.w	1
BG_INDEX:		ds.w	1
	
Erase_markers:
	move.w	COL1_MARKER,d0
	move.w	COL2_MARKER,d6
	cmp.w		d0,d6
	bge.s		.ok
	exg		d0,d6
.ok	move.w	#200,d2
	moveq		#4-1,d5
.lp	move.w	d0,d1
	move.w	d6,d3
	mulu		#5,d1
	mulu		#5,d3
	addq		#2,d3
	add.w		x_factor,d3
	movem.l	d0-d6,-(sp)
	move.w	d2,d4
	addq		#5,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d2
	add.w		y_factor,d2
	subq		#1,d4
	add.w		y_factor,d4
	moveq		#0,d0
	bsr		DRAW_PHYS_CLIPBOX
	movem.l	(sp)+,d0-d6
	sub.w		#64,d0
	sub.w		#64,d6
	addq		#5,d2
	dbra		d5,.lp
	move.w	COL1_MARKER,d1
	move.w	d1,d2
	lsr.w		#6,d2
	mulu		#5,d2
	add.w		#201,d2
	and.w		#63,d1
	mulu		#5,d1
	pushall
	move.w	d1,d3
	move.w	d2,d4
	addq		#2,d4
	add.w		y_factor,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d2
	addq		#1,d4
	subq		#1,d1
	subq		#1,d3
	bmi.s		.err
	moveq		#0,d0
	bsr		DRAW_PHYS_LINE
.err	popall
	addq		#2,d1
	add.w		x_factor,d1
	move.w	d1,d3
	move.w	d2,d4
	addq		#2,d4
	add.w		y_factor,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d2
	addq		#1,d4
	addq		#1,d1
	addq		#1,d3
	moveq		#0,d0
	bsr		DRAW_PHYS_LINE
	move.w	FG_MARKER,d1
	moveq		#0,d0
	jsr		colbox
	move.w	BG_MARKER,d1
	moveq		#0,d0
	jsr		colbox
	rts

Draw_markers:
	move.w	COL1_INDEX,d0
	move.w	COL2_INDEX,d6
	cmp.w		d0,d6
	bge.s		.ok
	exg		d0,d6
.ok	move.w	#200,d2
	moveq		#4-1,d5
.lp	move.w	d0,d1
	move.w	d6,d3
	mulu		#5,d1
	mulu		#5,d3
	addq		#2,d3
	add.w		x_factor,d3
	movem.l	d0-d6,-(sp)
	move.w	d2,d4
	addq		#5,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d2
	add.w		y_factor,d2
	subq		#1,d4
	add.w		y_factor,d4
	move.w	IFACE_COLOURS+2*iface_lgrey,d0
	or.b		gensol,d0
	bsr		DRAW_PHYS_CLIPBOX
	movem.l	(sp)+,d0-d6
	sub.w		#64,d0
	sub.w		#64,d6
	addq		#5,d2
	dbra		d5,.lp
	move.w	COL1_INDEX,d1
	move.w	IFACE_COLOURS+2*iface_lgrey,d0
	or.b		gensol,d0
	jsr		colbox
	move.w	FG_INDEX,d1
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	jsr		colbox
	move.w	BG_INDEX,d1
	move.w	IFACE_COLOURS+2*iface_lgrey,d0
	or.b		gensol,d0
	jsr		colbox
	rts	

colbox:
	move.w	d1,d2
	lsr.w		#6,d2
	mulu		#5,d2
	add.w		#201,d2
	and.w		#63,d1
	mulu		#5,d1
	move.w	d1,d3
	addq		#2,d3
	add.w		x_factor,d3
	move.w	d2,d4
	addq		#2,d4
	add.w		y_factor,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d2
	addq		#1,d4
	tst.w		d1
	bmi.s		.n1
	bsr		DRAW_PHYS_CLIPBOX
.n1	rts


DRAW_MENU_OUTLINE:
	pushall
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#1,d3
	subq		#1,d4
	and.w		#$FF,d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0
	bsr.s		DRAW_PHYS_BOX
	popall
	rts

DRAW_MENU_BOX:
	and.w		#$FF,d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	or.b		gensol,d0

DRAW_PHYS_BOX:
;	d0		colour
;	d1-d2		x1,y1
;	d3-d4		x2,y2
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	move.w	d0,box_c(a6)
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	box_c(a6),d0
	bsr		horizontal_physline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	move.w	box_c(a6),d0
	subq		#1,d4
	bsr		DRAW_PHYS_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	move.w	box_c(a6),d0
	bsr		horizontal_physline
	move.w	box_x1(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	move.w	box_c(a6),d0
	addq		#1,d2
	subq		#1,d4
	bsr		DRAW_PHYS_LINE
	rts

DRAW_LOG_BOX:
;	d0		colour
;	d1-d2		x1,y1
;	d3-d4		x2,y2
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	move.w	d0,box_c(a6)
	move.w	box_x2(a6),d2
	move.w	box_y1(a6),d3
	subq		#1,d2
	move.w	box_c(a6),d0
	bsr		horizontal_logline
	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	move.w	box_c(a6),d0
	subq		#1,d4
	bsr		DRAW_LOG_LINE
	move.w	box_x2(a6),d1
	move.w	box_x1(a6),d2
	move.w	box_y2(a6),d3
	move.w	box_c(a6),d0
	bsr		horizontal_logline
	move.w	box_x1(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	move.w	box_c(a6),d0
	addq		#1,d2
	subq		#1,d4
	bsr		DRAW_LOG_LINE
	rts

DRAW_LOG_OUTLINE:
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0

DRAW_LOG_CLIPBOX:
;	d1-d2		x1,y1
;	d3-d4		x2,y2
	cmp.w		d1,d3
	bge.s		.okx
	exg		d1,d3
.okx	cmp.w		d2,d4
	bge.s		.oky
	exg		d2,d4
.oky	tst.w		d3
	bmi		.rts
	tst.w		d4
	bmi		.rts
	cmp.w		CANVAS_WIDTH,d1
	bge		.rts
	cmp.w		CANVAS_HEIGHT,d2
	bge		.rts
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	move.w	d0,box_c(a6)
	move.w	d2,d4
	bmi.s		.nxt1
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	push.l	a6
	bsr		horizontal_logline
	pop.l		a6
.nxt1	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	move.w	CANVAS_WIDTH,d5
	subq		#1,d5
	cmp.w		d5,d1
	bgt.s		.nxt2
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_LOG_LINE
.nxt2	move.w	box_x2(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	move.w	CANVAS_HEIGHT,d5
	subq		#1,d5
	cmp.w		d5,d2
	bgt.s		.nxt3
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	push.l	a6
	bsr		horizontal_logline
	pop.l		a6
.nxt3	move.w	box_x1(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	tst.w		d1
	bmi.s		.rts
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_LOG_LINE
.rts	rts

DRAW_LOG_OUTROUND:
	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
	cmp.w		d1,d3
	bge.s		.okx
	exg		d1,d3
.okx	cmp.w		d2,d4
	bge.s		.oky
	exg		d2,d4
.oky	tst.w		d3
	bmi		.rts
	tst.w		d4
	bmi		.rts
	cmp.w		CANVAS_WIDTH,d1
	bge		.rts
	cmp.w		CANVAS_HEIGHT,d2
	bge		.rts
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	move.w	d0,box_c(a6)
	move.w	d2,d4
	bmi.s		.nxt1
	addq		#1,d1
	subq		#1,d3
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	push.l	a6
	bsr		horizontal_logline
	pop.l		a6
.nxt1	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	move.w	CANVAS_WIDTH,d5
	subq		#1,d5
	cmp.w		d5,d1
	bgt.s		.nxt2
	addq		#1,d2
	subq		#1,d4
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_LOG_LINE
.nxt2	move.w	box_x2(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	move.w	CANVAS_HEIGHT,d5
	subq		#1,d5
	cmp.w		d5,d2
	bgt.s		.nxt3
	subq		#1,d1
	addq		#1,d3
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	push.l	a6
	bsr		horizontal_logline
	pop.l		a6
.nxt3	move.w	box_x1(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	tst.w		d1
	bmi.s		.rts
	addq		#1,d2
	subq		#1,d4
	jsr		Clip_LOG_X1Y1
	jsr		Clip_LOG_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_LOG_LINE
.rts	rts

DRAW_PHYS_CLIPBOX:
;	d1-d2		x1,y1
;	d3-d4		x2,y2
	subq		#1,X_RESOLUTION
	cmp.w		d1,d3
	bge.s		.okx
	exg		d1,d3
.okx	cmp.w		d2,d4
	bge.s		.oky
	exg		d2,d4
.oky	subq		#1,d1
	addq		#1,d3
	tst.w		d3
	bmi		.rts
	tst.w		d4
	bmi		.rts
	cmp.w		X_RESOLUTION,d1
	bge		.rts
	cmp.w		Y_RESOLUTION,d2
	bge		.rts
	lea		BOXDATA,a6
	move.w	d1,box_x1(a6)
	move.w	d2,box_y1(a6)
	move.w	d3,box_x2(a6)
	move.w	d4,box_y2(a6)
	move.w	d0,box_c(a6)
	move.w	d2,d4
	bmi.s		.nxt1
	jsr		Clip_PHYS_X1Y1
	jsr		Clip_PHYS_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	bsr		horizontal_physline
.nxt1	move.w	box_x2(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x2(a6),d3
	move.w	box_y2(a6),d4
	move.w	X_RESOLUTION,d5
	subq		#1,d5
	cmp.w		d5,d1
	bgt.s		.nxt2
	jsr		Clip_PHYS_X1Y1
	jsr		Clip_PHYS_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_PHYS_LINE
.nxt2	move.w	box_x2(a6),d1
	move.w	box_y2(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	move.w	Y_RESOLUTION,d5
	subq		#1,d5
	cmp.w		d5,d2
	bgt.s		.nxt3
	jsr		Clip_PHYS_X1Y1
	jsr		Clip_PHYS_X2Y2
	move.w	box_c(a6),d0
	exg		d2,d3
	bsr		horizontal_physline
.nxt3	move.w	box_x1(a6),d1
	move.w	box_y1(a6),d2
	move.w	box_x1(a6),d3
	move.w	box_y2(a6),d4
	tst.w		d1
	bmi.s		.rts
	jsr		Clip_PHYS_X1Y1
	jsr		Clip_PHYS_X2Y2
	move.w	box_c(a6),d0
	bsr		DRAW_PHYS_LINE
.rts	addq		#1,X_RESOLUTION
	rts

Create_plane_table:
	tst.b		TRUE_FLAG
	bne.s		.no
	moveq		#0,d0
	move.w	#256-1,d7
	lea		PLANE_TABLE,a0	
.col	move.b	d0,d1
	moveq		#8-1,d3
.plan	moveq		#0,d2
	lsr.b		d1
	bcc.s		.zero
	not.w		d2
.zero	move.w	d2,(a0)+
	dbra		d3,.plan
	addq		#1,d0
	dbra		d7,.col
.no	rts

*-----------------------------------------------------------------------*
*	Delta memory management	routines						*
*-----------------------------------------------------------------------*

*-----------------------------------*
Init_PasteBuffer:				*
*-----------------------------------*
	move.w	LOG_HANDLE,TAB_HANDLE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	move.w	#3,BRUSH_SELECTED
	bsr		UPDATE_BRUSH
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	move.w	#2,BRUSH_SELECTED
	bsr		UPDATE_BRUSH
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	move.w	#1,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	move.w	#0,BRUSH_SELECTED
	jsr		UPDATE_BRUSH
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	rts

*-----------------------------------*
Clear_brush:				*
*-----------------------------------*
	tst.b		edit
	beq.s		.no
	push.w	TAB_HANDLE
	move.w	LOG_HANDLE,TAB_HANDLE
	clr.w		X1
	clr.w		Y1
	clr.w		X2
	clr.w		Y2
	jsr		CUT_BRUSH
	jsr		MAKE_BLOCKMASK
	pop.w		TAB_HANDLE
.no	rts

*-----------------------------------*
Init_MorphBuffer:				*
*-----------------------------------*
	jsr		Kill_morphlines
	rts
	
*-----------------------------------*
Init_FirstDelta:				*
*-----------------------------------*
	st		PALETTE_CHANGED
	tst.w		Delta_count
	bne.s		.no
	clr.w		CUR_DELTAFRAME
	moveq		#0,d0
	bsr		Insert_frame
.no	jsr		clip_segment
	rts
	
*---------------------------------------------------*

; FRAME_SCR = CUR_DELTAFRAME-1

; PACK_SCR = >>(LOG_SCR xor FRAME_SCR)<<

; FRAME_SCR = CUR_DELTAFRAME+1

; CUR_DELTAFRAME = PACK_SCR

; PACK_SCR = >>(LOG_SCR xor FRAME_SCR)<<

; CUR_DELTAFRAME+1 = PACK_SCR

*---------------------------------------------------*
	
*-----------------------------------*
Get_changes:				*
*-----------------------------------*
	tst.b		TRUE_FLAG
	bne.s		.np1
	tst.b		PALETTE_CHANGED
	beq.s		.np1
*-----------------------------------*
	move.w	CUR_DELTAFRAME,d0
	move.w	(Delta_list.l,d0.w*2),d0
	jsr		Find_block
	addq.l	#delta_head,a0
	lea		COLOURS,a1
	move.w	#256-1,d0
.copy	addq.l	#1,a1
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbra		d0,.copy
	clr.b		PALETTE_CHANGED
*-----------------------------------*
.np1	tst.b		BITMAP_CHANGED
	beq		.exit
*-----------------------------------*
*	IF FRAMES=1 then FRAME=LOG	*
*-----------------------------------*
	cmp.w		#1,Delta_count
	bne.s		.mult
	move.l	LOG_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
*-----------------------------------*
*	FRAME = CURRENT-1			*
*-----------------------------------*
.mult	move.w	CUR_DELTAFRAME,d0
	subq		#1,d0
	bpl.s		.prev
	move.w	Delta_count,d0
	subq		#1,d0
.prev	bsr		Update_position
*-----------------------------------*
*	PACK = >>(LOG xor FRAME)<<	*
*-----------------------------------*
	bsr		Make_deltas
*-----------------------------------*
*	FRAME = CURRENT+1			*
*-----------------------------------*
	move.w	CUR_DELTAFRAME,d0
	addq		#1,d0
	cmp.w		Delta_count,d0
	blt.s		.next
	moveq		#0,d0
.next	move.w	d0,NEXT_DELTAFRAME
	bsr		Update_position
*-----------------------------------*
*	keep backup of old frame	*
*-----------------------------------*
	move.w	CUR_DELTAFRAME,d0
	bsr.s		Backup_deltas
	tst.l		d0
	bmi.s		.err
*-----------------------------------*
*	CURRENT = PACK			*
*-----------------------------------*
	move.w	CUR_DELTAFRAME,d0
	bsr		Keep_deltas
	tst.l		d0
	bpl.s		.kept
*-----------------------------------*
*	Error! Kill backup and quit	*
*-----------------------------------*
	move.w	DELTABACK_HANDLE,d0
	jsr		Remove_block
	bra.s		.err	
*-----------------------------------*
*	PACK = >>(LOG xor FRAME)<<	*
*-----------------------------------*
.kept	bsr		Make_deltas
*-----------------------------------*
*	CURRENT+1 = PACK			*
*-----------------------------------*
	move.w	NEXT_DELTAFRAME,d0
	bsr		Keep_deltas
	tst.l		d0
	bpl.s		.done
*-----------------------------------*
*	Error! Use backup			*
*-----------------------------------*
	move.w	CUR_DELTAFRAME,d0
	bsr.s		Use_backup
*-----------------------------------*
*	Kill backup and quit		*
*-----------------------------------*
.done	move.w	DELTABACK_HANDLE,d0
	jsr		Remove_block
	clr.b		BITMAP_CHANGED
*-----------------------------------*
.exit	moveq		#0,d0
	bra.s		.rts
.err	moveq		#-1,d0
.rts	clr.b		UNDO_VALID
	rts
	
*-----------------------------------*
Backup_deltas:				*
*-----------------------------------*
*	Find size of delta to back-up	*
*-----------------------------------*
	move.w	(Delta_list.l,d0.w*2),DELTA_HANDLE
	move.w	DELTA_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),d0
*-----------------------------------*
*	Create storage block		*
*-----------------------------------*
	jsr		Add_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,DELTABACK_HANDLE
*-----------------------------------*
*	Copy data to storage		*
*-----------------------------------*
	move.w	DELTABACK_HANDLE,d0
	jsr		Find_block
	move.l	a0,a1	
	move.w	DELTA_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),d0
	jsr		memcpy
*-----------------------------------*
.exit	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts	

*-----------------------------------*
Use_backup:					*
*-----------------------------------*
*	Find size of backup-block	*
*-----------------------------------*
	move.w	(Delta_list.l,d0.w*2),DELTA_HANDLE
	move.w	DELTABACK_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),d1
*-----------------------------------*
*	Resize delta-frame		*
*-----------------------------------*
	move.w	DELTA_HANDLE,d0
	jsr		Translate_block
	tst.l		d0
	bmi.s		.err
	move.w	d0,DELTA_HANDLE
*-----------------------------------*
*	Copy data back to frame		*
*-----------------------------------*
	move.w	DELTA_HANDLE,d0
	jsr		Find_block
	move.l	a0,a1
	move.w	DELTABACK_HANDLE,d0
	jsr		Find_block
	move.l	block_size-block_head(a0),d0
	jsr		memcpy
*-----------------------------------*
	moveq		#0,d0
	bra.s		.exit
.err	moveq		#-1,d0
.exit	rts	

*-----------------------------------*
Make_deltas:				*
*-----------------------------------*
*	Pack delta				*
*-----------------------------------*
	move.l	LOG_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	PACK_SCR,a6
	move.l	CANVAS_SIZE,d3
	lea		(a6,d3.l),a3
	clr.l		(a3)+
	clr.l		(a3)+
	clr.l		(a3)+
	clr.l		(a3)+
	tst.b		TRUE_FLAG
	beq.s		SkipStore
	tst.b		heavycomp
	bne		SuperStore

*-----------------------------------*
SkipStore:					*
*-----------------------------------*
	addq.b	#1,BUSY
	lea		4(a6),a3			; bypass delta-counter
	move.l	d3,a5				; source limit
	lea		-256(a5),a5			; destination limit
	moveq		#4,d1				; byte counter (includes long-counter)
	moveq		#0,d2
	moveq		#0,d6
	moveq		#0,d7
*-----------------------------------*
*	Check for changes			*
*-----------------------------------*
.loop	move.l	(a0,d6.l),d0		; check data
	move.l	(a1,d6.l),d5
	eor.l		d5,d0
	bne.s		.keep				; store if changed
	moveq		#0,d0				; init dummy delta
	cmp.w		#32760,d7			; maximum relative distance
	bgt.s		.keep
*-----------------------------------*
*	No new changes			*
*-----------------------------------*
.next	addq.l	#4,d7				; advance relative index
	addq.l	#4,d6				; advance size-tracking
*-----------------------------------*
	cmp.l		d3,d6				; check for frame done
	bge.s		.done
	cmp.l		a5,d1				; check for maximum
	blt.s		.loop
	bra.s		.over
*-----------------------------------*
*	Keep new changes			*
*-----------------------------------*
.keep	move.l	4(a0,d6.l),d4		; (c+1) look ahead...
	move.l	4(a1,d6.l),d5
	eor.l		d5,d4
	beq.s		.norm
*-----------------------------------*
.cont	not.w		d7				; more data follows
	move.w	d7,(a3)+			; store coded offset
	moveq		#0,d7				; reset relative index
	move.l	d7,a2				; zero count
	move.l	a3,a4				; keep count pointer
	addq.l	#2,a3				; skip counter
	addq.l	#4,d1				; record offset+counter
	addq.l	#1,d2				; increment delta-count
*-----------------------------------*
.more	move.l	d0,(a3)+			; store delta
	move.l	d4,d0				; swap for new data
	addq.l	#1,a2				; record delta count
	addq.l	#4,d1				; record delta size
	cmp.l		a5,d1				; check for maximum
	bge.s		.ovr2
	addq.l	#4,d6				; advance size-tracking
	cmp.l		d3,d6				; check for frame done
	bge.s		.don2
	cmp.l		#32760,a2			; check for max stream-count
	beq.s		.stop
	move.l	4(a0,d6.l),d4		; look ahead...
	move.l	4(a1,d6.l),d5
	eor.l		d5,d4
	bne.s		.more
	move.l	8(a0,d6.l),d5		; look ahead...
	cmp.l		8(a1,d6.l),d5
	bne.s		.more
.stop	subq.l	#1,a2
	move.w	a2,(a4)
	bra.s		.fini
.don2	subq.l	#1,a2
	move.w	a2,(a4)
	bra.s		.done
.ovr2	subq.l	#1,a2
	move.w	a2,(a4)
	bra.s		.over
*-----------------------------------*
.norm	move.w	d7,(a3)+
	move.l	d0,(a3)+
	addq.l	#6,d1				; increment delta-size
	addq.l	#1,d2				; increment delta-count
*-----------------------------------*
	addq.l	#4,d6				; advance source
	moveq		#4,d7				; reset relative index
*-----------------------------------*
.fini	cmp.l		d3,d6				; check for frame done
	bge.s		.done
	cmp.l		a5,d1				; check for maximum
	blt		.loop
	bra.s		.over
*-----------------------------------*
*	Pack complete			*
*-----------------------------------*
.done	move.l	d2,(a6)			; store number of delta-longs
	moveq		#dtype_delta,d7		; this is a packed delta
	bra.s		.pckd
*-----------------------------------*
*	Pack aborted			*
*-----------------------------------*
.over	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	PACK_SCR,a2
	bsr		MAKE_XOR
	move.l	CANVAS_SIZE,d1
	moveq		#dtype_rawdelta,d7	; this is a packed delta
*-----------------------------------*
*	Now keep info on frame		*
*-----------------------------------*
.pckd	move.w	d7,PACK_TYPE
	move.l	d1,COMPRESSED
	subq.b	#1,BUSY
	rts

*-----------------------------------*
SuperStore:					*
*-----------------------------------*
	addq.b	#1,BUSY
	move.l	CANVAS_SIZE,d5
	lsr.l		d5
	move.l	LOG_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	PACK_SCR,a6
	lea		-64(a6,d5.l*2),a4
	addq.l	#4,a6
	moveq		#0,d4
	move.l	#32760,d1	; max packet-size
	move.w	(a0)+,d7	; initial byte
	move.w	(a1)+,d2
	eor.w		d2,d7
.restart
	move.l	a0,a3
	move.l	a1,a5
	move.w	(a3)+,d3
	move.w	(a5)+,d2
	eor.w		d2,d3
	cmp.w		d3,d7		; initial type-check
	bne.s		.init_copy
	move.w	(a3)+,d3
	move.w	(a5)+,d2
	eor.w		d2,d3
	cmp.w		d3,d7
	bne.s		.init_copy
.init_run:
	moveq		#1,d6		; initial byte-count
.run	move.w	(a0)+,d0
	move.w	(a1)+,d2
	eor.w		d2,d0
	cmp.l		d1,d6
	beq.s		.end_run
	cmp.w		d0,d7
	bne.s		.end_run
	addq.l	#1,d6
	subq.l	#1,d5
	bne.s		.run
.stop_run:
	move.w	d6,(a6)+	; store code
	move.w	d7,(a6)+	; store byte
	addq.l	#1,d4
	cmp.l		a4,a6
	bge		.over
	bra.s		.done
.end_run:
	move.w	d6,(a6)+	; store code
	move.w	d7,(a6)+	; store byte
	addq.l	#1,d4
	cmp.l		a4,a6
	bge		.over
	move.w	d0,d7		; new initial byte			
	subq.l	#1,d5
	bne.s		.restart
	bra.s		.done
.init_copy:
	move.l	a6,a2
	addq.l	#2,a6		; skip code
	moveq		#0,d6
	move.w	d7,d0
	bra.s		.keep
.copy	move.w	(a0)+,d0
	move.w	(a1)+,d2
	eor.w		d2,d0
	cmp.l		d1,d6
	beq.s		.end_copy
	move.l	a0,a3
	move.l	a1,a5
	move.w	(a3)+,d3
	move.w	(a5)+,d2
	eor.w		d2,d3
	cmp.w		d3,d0
	bne.s		.keep
	move.w	(a3)+,d3
	move.w	(a5)+,d2
	eor.w		d2,d3
	cmp.w		d3,d0
	bne.s		.keep
	move.w	(a3)+,d3
	move.w	(a5)+,d2
	eor.w		d2,d3
	cmp.w		d3,d0
	beq.s		.end_copy
.keep	move.w	d0,(a6)+
	addq.l	#1,d6
	cmp.l		a4,a6
	bge.s		.over
	subq.l	#1,d5
	bne.s		.copy
.stop_copy:
	neg.w		d6		; create code
	move.w	d6,(a2)	; store code
	addq.l	#1,d4
	bra.s		.done
.end_copy
	neg.w		d6		; create code
	move.w	d6,(a2)	; store code
	addq.l	#1,d4
	move.w	d0,d7		; new initial byte
	bra		.restart
*-----------------------------------*
*	Pack complete			*
*-----------------------------------*
.done	move.l	PACK_SCR,a1
	move.l	d4,(a1)			; store number of delta-longs
	move.l	a6,d1
	sub.l		PACK_SCR,d1
	moveq		#dtype_superstor,d7	; this is a packed delta
	bra.s		.pckd
*-----------------------------------*
*	Pack aborted			*
*-----------------------------------*
.over	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	PACK_SCR,a2
	bsr		MAKE_XOR
	move.l	CANVAS_SIZE,d1
	moveq		#dtype_rawdelta,d7	; this is a packed delta
*-----------------------------------*
*	Now keep info on frame		*
*-----------------------------------*
.pckd	move.w	d7,PACK_TYPE
	addq.l	#3,d1
	and.l		#-4,d1
	move.l	d1,COMPRESSED
	subq.b	#1,BUSY
	rts
	
heavycomp:	ds.b	1
		even
		
*-----------------------------------*
Keep_deltas:				*
*-----------------------------------*
*	d0		frame to store	*
*-----------------------------------*
	move.w	d0,FRAME
	bne		.norm
*-----------------------------------*
*	Float frame zero			*
*-----------------------------------*
	move.w	Delta_list,d0
	jsr		Find_block
*-----------------------------------*
*	Keep copy of frame 0 colours	*
*-----------------------------------*
	lea		delta_head(a0),a1
	lea		TEMP_COLS,a2
	bsr		COPY_TEMPCOLS
*-----------------------------------*
*	Range check on ram		*
*-----------------------------------*
	move.l		delta_size(a0),d3
	move.l		COMPRESSED,d1
*-----------------------------------*
*	Check for enough STRAM		*
*-----------------------------------*
.Schk	move.l		d1,d2
	move.w		Delta_list,d4
	btst		#altram_bit,d4
	beq.s		.n_ST
	sub.l		d3,d2
	blt.s		.Repl
.n_ST	add.l		([STRAM_ADDR.l]),d2
	add.l		#256,d2
	cmp.l		STRAM_END,d2
	ble.s		.Repl
*-----------------------------------*
*	Check for enough VRAM		*
*-----------------------------------*
.Vchk	tst.b		VRAM
	beq.s		.prob
	move.l		d1,d2
	move.w		Delta_list,d4
	btst		#altram_bit,d4
	bne.s		.n_V
	sub.l		d3,d2
	blt.s		.Repl
.n_V	add.l		([VRAM_ADDR.l]),d2
	add.l		#256,d2
	cmp.l		VRAM_END,d2
	ble.s		.Repl
*-----------------------------------*
*	Error occurred			*
*-----------------------------------*
.prob	lea		WIN_RAM_Alert,a0
	bsr		DO_ALERT
	bra		.err
*-----------------------------------*
*	Remove old frame 0		*
*-----------------------------------*
.Repl	move.w	Delta_list,d0
	jsr		Remove_block
*-----------------------------------*
*	Replace block at top of ram	*
*-----------------------------------*
	move.l	COMPRESSED,d0
	add.l		#delta_head+(3*256),d0
	jsr		Add_virtual
	move.w	d0,Delta_list
*-----------------------------------*
*	Replace palette in frame 0	*
*-----------------------------------*
	lea		delta_head(a0),a2
	lea		TEMP_COLS,a1
	bsr		COPY_TEMPCOLS
*-----------------------------------*
*	Store screen data			*
*-----------------------------------*
	move.l	a0,a2
	bra.s		.keep
*-----------------------------------*
*	Resize frame to accept data	*
*-----------------------------------*
.norm	move.w	FRAME,d0
	lea		(Delta_list.l,d0.w*2),a6
	move.w	(a6),d0
	move.w	d0,BLOCK
	move.l	COMPRESSED,d1
	addq.l	#delta_head,d1
	tst.b		TRUE_FLAG
	bne.s		.np1
	add.l		#256*3,d1
.np1	push.l	a6
	jsr		Translate_block
	pop.l		a6
	tst.l		d0
	bmi.s		.err
	move.w	d0,(a6)
	move.w	d0,BLOCK
*-----------------------------------*
*	Get address of block		*
*-----------------------------------*
	move.w	BLOCK,d0
	jsr		Find_block
	move.l	a0,a2
*-----------------------------------*
*	Store info in block header	*
*-----------------------------------*
.keep	move.w	PACK_TYPE,delta_type(a2)
	move.l	COMPRESSED,d1
	move.l	d1,delta_size(a2)
*-----------------------------------*
*	Store data in block		*
*-----------------------------------*
	move.l	PACK_SCR,a0
	lea		delta_head(a2),a1
	tst.b		TRUE_FLAG
	bne.s		.np2
	lea		256*3(a1),a1
.np2

	move.l	d1,d0
	jsr		memcpy

;	add.l		d0,a0
;	add.l		d0,a1

;	lsr.l		d1
;	move.l	d1,d0
;	jsr		COPY_WORDS_DOWN

*-----------------------------------*
*	Exit routine			*
*-----------------------------------*
.exit	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts

COPY_TEMPCOLS:
	tst.b		TRUE_FLAG
	bne.s		.no
	moveq		#(768/16)-1,d0
.copy	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbra		d0,.copy
.no	rts

*-----------------------------------*
Update_position:				*
*-----------------------------------*
;	d0		frame to show
*-----------------------------------*
	addq.b	#1,BUSY
	move.w	Delta_count,d1
	subq		#1,d1
	cmp.w		d1,d0
	ble.s		.show
	move.w	d1,d0			; clip to range
*-----------------------------------*
*	Bring FRAME_SCR up-to-date	*
*-----------------------------------*
.show	move.w	LAST_FRAME,d7	; frame to begin
	move.w	d0,LAST_FRAME	; this now old frame
	moveq		#1,d6			; direction = forward
	cmp.w		d0,d7
	beq		UDrts
*-----------------------------------*
	tst.b		TRUE_FLAG
	bne.s		.np1
	pushall
	move.w	(Delta_list.l,d0.w*2),d0
	jsr		Find_block
	addq.l	#delta_head,a0
	lea		COLOURS,a1
	move.w	#256-1,d0
.copy	addq.l	#1,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d0,.copy	
	tst.b		UPDATE_PALETTE
	beq.s		.no
	clr.b		UPDATE_PALETTE
	jsr		Update_palette
.no	popall
*-----------------------------------*
.np1	move.w	Delta_count,d5
	lsr.w		d5
	move.w	d0,d3
	move.w	d7,d4
	move.w	d4,d2
	sub.w		d3,d2
	bpl.s		.p1
	neg.w		d2
.p1	cmp.w		d5,d2
	ble.s		.keep
	exg		d3,d4
.keep	sub.w		d3,d4
	blt.s		.forw
.back	moveq		#-1,d6		; else backward
	addq		#1,d7			; advance to new frame
	addq		#1,d0
	cmp.w		Delta_count,d0
	blt.s		.forw
	moveq		#0,d0
.forw	move.w	d0,destination
*-----------------------------------------*	
UDlop	add.w		d6,d7					; advance to new frame
	bpl.s		.nov1
	move.w	Delta_count,d7
	subq		#1,d7
.nov1	cmp.w		Delta_count,d7
	blt.s		.nov2
	moveq		#0,d7
*-----------------------------------------*	
.nov2	push.w	d6
	push.w	d7
	move.w	(Delta_list.l,d7.w*2),d0
	jsr		Find_block
	move.w	delta_type(a0),d1
	addq.l	#delta_head,a0
	tst.b		TRUE_FLAG
	bne.s		.np2
	lea		256*3(a0),a0
.np2	move.l	FRAME_SCR,a1
*-----------------------------------------*	
	cmp.w		#dtype_delta,d1
	beq.s		DXor
	cmp.w		#dtype_rawdelta,d1
	beq.s		RXor
	cmp.w		#dtype_superstor,d1
	beq		SXor
*-----------------------------------------*	
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	bra		UDrtn
*-----------------------------------------*	
RXor:	move.l	CANVAS_SIZE,d0
	lsr.l		#2,d0
	bsr		XOR_LONGS
	bra		UDrtn
*-----------------------------------------*	
DXor:	move.l	(a0)+,d1
	subq.l	#1,d1
	bmi		DDone
	moveq		#0,d2
	move.l	d0,d3
	swap		d3
	tst.w		d3
	beq.s		.Dlp2
*-----------------------------------------*	
.Dlp1	move.w	(a0)+,d2
	bmi.s		.Chnk
	move.l	(a0)+,d3
	add.l		d2,a1
	eor.l		d3,(a1)
	subq.l	#1,d1
	bpl.s		.Dlp1
	bra		DDone
.Chnk	not.w		d2
	add.l		d2,a1
	move.w	(a0)+,d2
	moveq		#16-1,d3
	and.w		d2,d3
	lsr.l		#4,d2
	neg.w		d3
	jmp		.elop(pc,d3.w*4)
.loop	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	rept		16-2
	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	endr
.elop	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	dbra		d2,.loop
	subq.l	#1,d1
	bpl.s		.Dlp1
	bra.s		DDone
*-----------------------------------------*	
.Dlp2	move.w	(a0)+,d2
	bmi.s		.Chn2
	move.l	(a0)+,d3
	add.l		d2,a1
	eor.l		d3,(a1)
	dbra		d1,.Dlp2
	bra.s		DDone
.Chn2	not.w		d2
	add.l		d2,a1
	move.w	(a0)+,d2
	moveq		#16-1,d3
	and.w		d2,d3
	lsr.l		#4,d2
	neg.w		d3
	jmp		.elo2(pc,d3.w*4)
.lop2	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	rept		16-2
	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	endr
.elo2	move.l	(a0)+,d3
	eor.l		d3,(a1)+
	dbra		d2,.lop2
	dbra		d1,.Dlp2
DDone	bra		UDrtn
*-----------------------------------------*	
SXor:	move.l	(a0)+,d3
	ble.s		.err
.dcod	move.w	(a0)+,d1
	bmi.s		.copy
.run	beq.s		.err
	move.w	(a0)+,d2
	bne.s		.use
	lea		(a1,d1.w*2),a1
	subq.l	#1,d3
	bne.s		.dcod
	bra.s		.err
.use	subq		#1,d1
.rlp	eor.w		d2,(a1)+
	dbra		d1,.rlp
	subq.l	#1,d3
	bne.s		.dcod
	bra.s		.err
.copy	neg.w		d1
	subq		#1,d1
	bmi.s		.err
.clp	move.w	(a0)+,d2
	eor.w		d2,(a1)+
	dbra		d1,.clp
	subq.l	#1,d3
	bne.s		.dcod
.err
*-----------------------------------------*	
UDrtn	pop.w		d7
	pop.w		d6
	cmp.w		destination,d7		; has current been updated?
	bne		UDlop				; if not, repeat.
*-----------------------------------------*	
UDrts	subq.b	#1,BUSY
	rts

*-----------------------------------*
Remove_frame:				*
*-----------------------------------*
*	d0		frame number	*
*-----------------------------------*
	cmp.w		Delta_count,d0
	bge.s		.err1
*-----------------------------------*
*	Kill memory block			*
*-----------------------------------*
	lea		(Delta_list.l,d0.w*2),a0
	push.w	d0
	push.l	a0
	move.w	(a0),d0
	jsr		Remove_block
	pop.l		a0
	pop.w		d1
	tst.l		d0
	bmi.s		.err
*-----------------------------------*
*	Remove handle from list		*
*-----------------------------------*
	move.w	Delta_count,d0	; deltas present	(5)
	sub.w		d1,d0			; frame to delete (2)
	subq		#2,d0			; adjust for loop (5-2=3:lc=2:dbf=1)
	bmi.s		.done
	lea		2(a0),a1
.shft	move.w	(a1)+,(a0)+		; shift id-numbers down
	dbra		d0,.shft
	move.w	#-1,(a0)
.done	subq		#1,Delta_count
	jsr		clip_segment
	bra.s		.exit
*-----------------------------------*
*	Various errors			*	
*-----------------------------------*
.err1	lea		WIN_DFR_Alert,a0
	bsr		DO_ALERT
*-----------------------------------*
*	An error occurred			*	
*-----------------------------------*
.err	moveq		#-1,d0
	bra.s		.rts
*-----------------------------------*
*	No errors occurred		*	
*-----------------------------------*
.exit	moveq		#0,d0
*-----------------------------------*
.rts	rts
*-----------------------------------*

*-----------------------------------*
Insert_frame:				*
*-----------------------------------*
*	d0		frame number	*
*-----------------------------------*
	cmp.w		#max_deltas,Delta_count
	beq		.err1
	move.l	d0,-(sp)		; preserve
	moveq		#delta_head+4,d0
	tst.b		TRUE_FLAG
	bne.s		.np1
	add.l		#256*3,d0
.np1:	jsr		Add_virtual		; make new block
	move.l	a0,a2			; block address
	move.l	d0,d7			; keep handle in d7
	move.l	(sp)+,d0		; restore
	tst.l		d7			; check for errors
	bmi.s		.err			; if out of space, quit	
*-----------------------------------*
*	Check for insert/add		*
*-----------------------------------*
	cmp.w		Delta_count,d0	; range check for frames
	blt.s		.ins			; if in range, do insert
	move.w	Delta_count,d0	; otherwise add to list
*-----------------------------------*
*	Get new slot address		*
*-----------------------------------*
.ins	lea		Delta_list,a1	; list of handles in a4
	lea		(a1,d0.w*2),a4
*-----------------------------------*
*	Insert handle into list		*
*-----------------------------------*
	move.w	Delta_count,d1	; get number of handles
	lea		(a1,d1.w*2),a1
	sub.w		d0,d1			; get number to shift
	subq		#1,d1
	bmi.s		.stor
	move.w	#-1,2(a1)
.shft	move.w	-(a1),2(a1)
	dbra		d1,.shft		; exit with a4 pointing to new slot
.stor	move.w	d7,(a4)		; store handle here	
*-----------------------------------*
*	Init vars				*	
*-----------------------------------*
.Delt	move.l	#4,delta_size(a2)
	move.w	#dtype_delta,delta_type(a2)
	lea		delta_head(a2),a1
	tst.b		TRUE_FLAG
	bne.s		.np2
	lea		COLOURS,a0
	move.w	#256-1,d0
.copy	addq.l	#1,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	dbra		d0,.copy
.np2	clr.l		(a1)
	addq		#1,Delta_count
	bra.s		.exit
*-----------------------------------*
*	Various errors			*	
*-----------------------------------*
.err1	lea		WIN_DLT_Alert,a0
	bsr		DO_ALERT
*-----------------------------------*
*	An error occurred			*	
*-----------------------------------*
.err	moveq		#-1,d0
	bra.s		.rts
*-----------------------------------*
*	No errors occurred		*	
*-----------------------------------*
.exit	moveq		#0,d0
*-----------------------------------*
.rts	rts
*-----------------------------------*

*-----------------------------------------------------------------------*
*	Low-level screen routines							*
*-----------------------------------------------------------------------*

COPY_LOG_2_PHYS:
	move.l	LOG_SCR,a0
	move.l	PHYS_SCR,a1
	move.l	PHYS_SIZE,d0
	jmp		memcpy

COPY_PHYS_2_LOG:
	move.l	PHYS_SCR,a0
	move.l	LOG_SCR,a1
	move.l	PHYS_SIZE,d0
	jmp		memcpy

COPY_FRAME_2_LOG:
	move.l	FRAME_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jmp		memcpy

COPY_LOG_2_FRAME:
	move.l	LOG_SCR,a0
	move.l	FRAME_SCR,a1
	move.l	CANVAS_SIZE,d0
	jmp		memcpy

COPY_FRAME_2_PACK:
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jmp		memcpy

COPY_UNDO_2_LOG:
	move.l	PACK_SCR,a0
	move.l	LOG_SCR,a1
	move.l	CANVAS_SIZE,d0
	jmp		memcpy

*---------------------------------------------------------------*
;COPY_WORDS_DOWN:
*---------------------------------------------------------------*
	push.l	d0
	add.l		d0,d0
	jsr		memcpy_a0_a1_d0
	pop.l		d0
	add.l		d0,a0
	add.l		d0,a1
	add.l		d0,a0
	add.l		d0,a1
	rts

*---------------------------------------------------------------*
;COPY_WORDS_UP:
*---------------------------------------------------------------*
	push.l	d0
	add.l		d0,d0
	jsr		memcpy_a0_a1_d0
	pop.l		d0
	add.l		d0,a0
	add.l		d0,a1
	add.l		d0,a0
	add.l		d0,a1
	rts

*---------------------------------------------------------------*
CLEAR_CANVAS:
*---------------------------------------------------------------*
	move.l	CANVAS_SIZE,d0
	jmp		memclr

*---------------------------------------------------------------*
FILL_WORDS:
*---------------------------------------------------------------*
	move.w	d1,d2
	swap		d1
	move.w	d2,d1
	add.l		d0,d0
	jmp		memset_a0_d0_d1

SWAP_LONGS:
	addq.b	#1,BUSY
	cacheoff	d1
	moveq		#16-1,d1
	and.l		d0,d1
	bra.s		.strt
.long	move.l	(a0),d2
	move.l	(a1),(a0)+
	move.l	d2,(a1)+
.strt	dbra		d1,.long
	lsr.l		#4,d0
	move.l	a1,a2
	lea		32.w,a3
	bra.s		.next
.copy	movem.l	(a0),d1-d7/a6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	d1-d7/a6,(a2)
	add.l		a3,a2
	movem.l	(a0),d1-d7/a6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	d1-d7/a6,(a2)
	add.l		a3,a2
.next	dbra		d0,.copy
	cacheon	d1
	subq.b	#1,BUSY
	rts

XOR_LONGS:
	addq.b	#1,BUSY
	cacheoff	d1
	moveq		#32-1,d1
	and.l		d0,d1
	bra.s		.strt
.long	move.l	(a0)+,d2
	eor.l		d2,(a1)+
.strt	dbra		d1,.long
	lsr.l		#5,d0
	bra.s		.next
.copy	movem.l	(a0)+,d1-d7/a6
	eor.l		d1,(a1)+
	eor.l		d2,(a1)+
	eor.l		d3,(a1)+
	eor.l		d4,(a1)+
	eor.l		d5,(a1)+
	eor.l		d6,(a1)+
	eor.l		d7,(a1)+
	move.l	a6,d7
	eor.l		d7,(a1)+
	movem.l	(a0)+,d1-d7/a6
	eor.l		d1,(a1)+
	eor.l		d2,(a1)+
	eor.l		d3,(a1)+
	eor.l		d4,(a1)+
	eor.l		d5,(a1)+
	eor.l		d6,(a1)+
	eor.l		d7,(a1)+
	move.l	a6,d7
	eor.l		d7,(a1)+
	movem.l	(a0)+,d1-d7/a6
	eor.l		d1,(a1)+
	eor.l		d2,(a1)+
	eor.l		d3,(a1)+
	eor.l		d4,(a1)+
	eor.l		d5,(a1)+
	eor.l		d6,(a1)+
	eor.l		d7,(a1)+
	move.l	a6,d7
	eor.l		d7,(a1)+
	movem.l	(a0)+,d1-d7/a6
	eor.l		d1,(a1)+
	eor.l		d2,(a1)+
	eor.l		d3,(a1)+
	eor.l		d4,(a1)+
	eor.l		d5,(a1)+
	eor.l		d6,(a1)+
	eor.l		d7,(a1)+
	move.l	a6,d7
	eor.l		d7,(a1)+
.next	dbra		d0,.copy
	cacheon	d1
	subq.b	#1,BUSY
	rts
	
MAKE_XOR:
	addq.b	#1,BUSY
	cacheoff	d1
	move.l	CANVAS_SIZE,d7
	lsr.l		#5,d7
	subq		#1,d7
.loop	move.l	d7,a6
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a1)+,d4
	move.l	(a1)+,d5
	move.l	(a1)+,d6
	move.l	(a1)+,d7
	eor.l		d0,d4
	eor.l		d1,d5
	eor.l		d2,d6
	eor.l		d3,d7
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a1)+,d4
	move.l	(a1)+,d5
	move.l	(a1)+,d6
	move.l	(a1)+,d7
	eor.l		d0,d4
	eor.l		d1,d5
	eor.l		d2,d6
	eor.l		d3,d7
	move.l	d4,(a2)+
	move.l	d5,(a2)+
	move.l	d6,(a2)+
	move.l	d7,(a2)+
	move.w	a6,d7
	dbra		d7,.loop
	cacheon	d1
	subq.b	#1,BUSY
	rts
	
*-------------------------------------------------------------------------*
*				MASKED BLOCK-PRINT					  *
*-------------------------------------------------------------------------*

DRAW_SPRITE_MINI:
	move.l	a0,a4
	jsr		Find_brush
	move.w	(a0)+,d4	; block width
	move.w	(a0)+,d5	; block height
	moveq		#10,d0
	xresfactor	d0
	moveq		#10,d1
	yresfactor	d1
	sub.w		d0,d6
	sub.w		d1,d7
	moveq		#16,d0
	xresfactor	d0
	moveq		#16,d1
	yresfactor	d1
	add.w		y_factor,d1
	subq		#1,d1
	move.w	d6,d2
	add.w		d0,d2
	move.w	d2,SCR_WIDTH
	move.w	d7,d2
	add.w		d1,d2
	move.w	d2,SCR_HEIGHT
	move.w	physwid,scrwid
	bra.s		DSPR

DRAW_SPRITE_CNT:
	move.l	a0,a4
	jsr		Find_brush
	move.w	(a0)+,d4	; block width
	move.w	(a0)+,d5	; block height
	tst.w		GRID_BITS
	bne.s		.go
	move.w	d4,d0
	lsr.w		d0
	sub.w		d0,d6
	move.w	d5,d1
	lsr.w		d1
	sub.w		d1,d7
.go	cmp.w		d0,d1
	ble.s		.ok
	move.w	d1,d0
.ok	addq		#4,d0
	move.w	d0,brush_deviance
	bra.s		DSPR

wdth:	ds.w		1

DRAW_LOG_SPRITE:
	move.l	LOG_SCR,a0
	move.w	CANVAS_WIDTH,SCR_WIDTH
	move.w	CANVAS_HEIGHT,SCR_HEIGHT
	move.w	logwid,scrwid

DRAW_SPRITE:
;	d6		x
;	d7		y
;	a0		screen
	move.l	a0,a4
	jsr		Find_brush
	move.w	(a0)+,d4	; block width
	move.w	(a0)+,d5	; block height

DSPR:	tst.b		TRUE_FLAG
	bne		DRAW_SPRITE_TRUE
	lea		768(a0),a0
	move.l	a0,a6
	move.w	d4,d0
	add.w		#15,d0
	lsr.w		#4,d0
	mulu		#18,d0
	move.w	d0,wdth
	st		BLIT_FREEZE
	move.w	d6,d3
	bpl.s		.pos1
	and.w		#15,d3
.pos1	move.w	d3,d0
	lsr.w		#4,d3
	add.w		d4,d0
	add.w		#16-1,d0
	lsr.w		#4,d0
	sub.w		d3,d0			; width of screen sprite
	subq		#1,d0
	add.w		#15,d4
	move.w	d4,d3
	lsr.w		#4,d4
	sub.w		d0,d4
	mulu		#18,d4
	move.w	d4,src_yinc.w
	move.w	d0,d4
	move.b	#2,HOP.w
	move.w	#16,dst_xinc.w
	move.w	#18,src_xinc.w
	move.b	d6,d0			; get x-pos
	and.b		#$F,d0		; save bits 0-3 for 16-pixel scroll
	move.b	d0,skew.w		; scroll sprite right d0 pixels
	moveq		#-1,d1		;
	move.w	d1,endmask2.w
	lsr.w		d0,d1			;
	move.w	d1,endmask1.w	; set start mask
	move.w	d6,d0
	add.w		d3,d0
	lsr.w		#4,d3
	and.w		#$F,d0
	moveq		#-1,d1
	clr.w		d1
	addq		#1,d0
	lsr.l		d0,d1
	move.w	d1,endmask3.w	; set end mask
	tst.w		d4
	bne.s		.clpt
	and.w		d1,endmask1.w	; set end mask
.clpt	move.w	d7,d0			; d2,d5,a6,d7
	bpl.s		.clpb
	add.w		d0,d5
	ble		.end
	Index		d0,d2			; d0 = d0*10
	muls		d3,d0			; d0 = d0*sprwid
	sub.l		d0,a6			; drop into data
	moveq		#0,d7			; clip top
.clpb	move.w	SCR_HEIGHT,d0	; y-limit
	sub.w		d7,d0
	sub.w		d5,d0			; check for overhang
	bpl.s		.clpl
	add.w		d0,d5			; truncate height
	ble		.end
.clpl	move.w	SCR_WIDTH,d0	; x-limit
	subq		#1,d0
	sub.w		d6,d0			; minus x-pos
	asr.w		#4,d0			; in words
	sub.w		d4,d0			; minus width
	moveq		#-1,d3
	move.w	SCR_WIDTH,d1	; x-limit
	subq		#1,d1
	lsr.w		#4,d1
	sub.w		d0,d1
	sub.w		d4,d1
	bpl.s		.clpr			; inside screen
	add.w		d1,d4			; adjust width
	bmi		.end			; width is zero
	bne.s		.nmsk
	move.w	endmask3.w,d3
.nmsk	addq		#1,d1
	neg.w		d1
	Index		d1,d2			; index data
	add.w		d1,src_yinc.w
	add.w		d1,a6
	or.b		#1<<7,skew.w
	move.w	d3,endmask1.w
	moveq		#0,d6			; coord negative, clear x-pos
.clpr	tst.w		d0
	bpl.s		.addr			; neg if inside
	add.w		d0,d4			; adjust width
	bmi		.end			; zero width?
	move.w	d0,d1
	neg.w		d1
	Index		d1,d2
	add.w		d1,src_yinc.w
	move.w	#-1,endmask3.w
.addr	move.w	scrwid,d1
	mulu		d1,d7
	add.l		d7,a4
	and.w		#-16,d6		; find address on screen
	add.w		d6,a4
	move.w	d4,d0			; find screen line width
	lsl.w		#4,d0
	neg.w		d0
	add.w		d1,d0
	move.w	d0,dst_yinc.w
	lea		2(a6),a3
	addq		#1,d4
	move.w	d4,x_size.w
*-----------------------------------*
	move.w		LOG_HANDLE,d0
	or.w		BRUSH_HANDLE,d0
	and.w		#(1<<altram_bit),d0
	bne		.softcopy
	move.w		d4,d3
	mulu		d5,d3
	cmp.w		#20,d3
	ble.s		.softcopy
*-----------------------------------*
	move.b	#128,d0
	moveq		#7,d1
	moveq		#8-1,d2
	lea		blit_stat.w,a0
	move.w	PASTE_BITS,d3
	and.w		#1<<Bit_PASTE_XRAY,d3
	beq.s		.copy
*-----------------------------------*
.mask	move.l	a6,src_addr.w
	move.l	a4,dst_addr.w
	move.w	d5,y_size.w
	move.b	#1,blit_op.w
	waitblit	d0,d1,a0
	move.l	a3,src_addr.w
	move.l	a4,dst_addr.w
	move.w	d5,y_size.w
	move.b	#7,blit_op.w
	waitblit	d0,d1,a0
	addq.l	#2,a3
	addq.l	#2,a4
	dbra		d2,.mask
	bra.s		.end
*-----------------------------------*
.copy	move.b	#3,blit_op.w
.loop	move.l	a3,src_addr.w
	move.l	a4,dst_addr.w
	move.w	d5,y_size.w
	waitblit	d0,d1,a0
	addq.l	#2,a3
	addq.l	#2,a4
	dbra		d2,.loop
.end	sf		BLIT_FREEZE
	rts
*-----------------------------------*
.softcopy:
*-----------------------------------*
	move.l	a3,src_addr.w
	move.l	a4,dst_addr.w
	move.w	d5,y_size.w
	move.w	PASTE_BITS,d3
	and.w		#1<<Bit_PASTE_XRAY,d3
	bne.s		.softmask
	bsr.s		BLITCOPY
	addq.l	#8,a3
	addq.l	#8,a4
	bsr.s		BLITCOPY
	bra.s		.end
*-----------------------------------*
.softmask:
*-----------------------------------*
	move.l	a6,a3
	bsr		BLITMASK
	addq.l	#2,a3
	bsr		BLITMERGE
	addq.l	#8,a3
	addq.l	#8,a4
	bsr		BLITMERGE
	bra.s		.end

BLITCOPY:
	push.l	a3
	push.l	a4
	move.w	wdth,a5
	move.w	scrwid,a6
	lea		10.w,a2
	move.w	endmask1.w,d0
	swap		d0
	move.w	endmask3.w,d0
	move.w	x_size.w,d6
	subq		#2,d6
	bpl.s		.wide
	move.w	d0,d1
	swap		d0
	and.w		d0,d1
	move.w	d1,d0
	swap		d0
	move.w	d1,d0
.wide	swap		d6
	move.b	skew.w,d6
	move.l	a4,a1
	move.w	y_size.w,d7
	subq		#1,d7
.line	swap		d7
	move.l	a3,a0
	move.l	a1,a4
	tst.b		d6
	bpl.s		.fxsr
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	add.l		a2,a0
.fxsr	swap		d6
	move.w	d6,d7
	swap		d6
	bmi.s		.rght
.left	swap		d0
	move.w	d0,d5
	swap		d5
	move.w	d0,d5
	not.l		d5
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	subq.l	#8,a4
	move.w	(a0)+,d1
	move.l	d1,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d1
	move.w	(a0)+,d2
	move.l	d2,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d2
	move.w	(a0)+,d3
	move.l	d3,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d3
	move.w	(a0)+,d4
	move.l	d4,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d4
	swap		d0
	add.l		a2,a0
	addq.l	#8,a4
	subq		#1,d7
	bmi.s		.rght
.word	move.w	(a0)+,d1
	move.l	d1,d5
	lsr.l		d6,d5
	move.w	d5,(a4)+
	swap		d1
	move.w	(a0)+,d2
	move.l	d2,d5
	lsr.l		d6,d5
	move.w	d5,(a4)+
	swap		d2
	move.w	(a0)+,d3
	move.l	d3,d5
	lsr.l		d6,d5
	move.w	d5,(a4)+
	swap		d3
	move.w	(a0)+,d4
	move.l	d4,d5
	lsr.l		d6,d5
	move.w	d5,(a4)+
	swap		d4
	add.l		a2,a0
	addq.l	#8,a4
	dbra		d7,.word
.rght	move.w	d0,d5
	swap		d5
	move.w	d0,d5
	not.l		d5
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	subq.l	#8,a4
	move.w	(a0)+,d1
	lsr.l		d6,d1
	and.w		d0,d1
	or.w		d1,(a4)+
	move.w	(a0)+,d2
	lsr.l		d6,d2
	and.w		d0,d2
	or.w		d2,(a4)+
	move.w	(a0)+,d3
	lsr.l		d6,d3
	and.w		d0,d3
	or.w		d3,(a4)+
	move.w	(a0)+,d4
	lsr.l		d6,d4
	and.w		d0,d4
	or.w		d4,(a4)+
	add.l		a5,a3
	add.l		a6,a1
	swap		d7
	dbra		d7,.line
.err	pop.l		a4
	pop.l		a3
	rts	

BLITMASK:
	push.l	a3
	push.l	a4
	move.w	wdth,a5
	move.w	scrwid,a6
	lea		16.w,a2
	move.w	endmask1.w,d0
	swap		d0
	move.w	endmask3.w,d0
	move.w	x_size.w,d6
	subq		#2,d6
	bpl.s		.wide
	move.w	d0,d1
	swap		d0
	and.w		d0,d1
	move.w	d1,d0
	swap		d0
	move.w	d1,d0
.wide	swap		d6
	move.b	skew.w,d6
	move.l	a4,a1
	move.w	y_size.w,d7
	subq		#1,d7
.line	moveq		#-1,d1
	swap		d7
	move.l	a3,a0
	move.l	a1,a4
	tst.b		d6
	bpl.s		.fxsr
	move.w	(a0)+,d1
	swap		d1
	add.l		a2,a0
.fxsr	swap		d6
	move.w	d6,d7
	swap		d6
	bmi.s		.rght
.left	swap		d0
	move.w	(a0)+,d1
	move.l	d1,d5
	swap		d1
	lsr.l		d6,d5
	move.w	d0,d4
	not.w		d4
	or.w		d4,d5
	move.w	d5,d4
	swap		d5
	move.w	d4,d5
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	swap		d0
	add.l		a2,a0
	subq		#1,d7
	bmi.s		.rght
.word	move.w	(a0)+,d1
	move.l	d1,d5
	swap		d1
	lsr.l		d6,d5
	move.w	d5,d4
	swap		d5
	move.w	d4,d5
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	and.l		d5,(a4)+
	add.l		a2,a0
	dbra		d7,.word
.rght	move.w	(a0)+,d1
	lsr.l		d6,d1
	move.w	d0,d4
	not.w		d4
	or.w		d4,d1
	move.w	d1,d4
	swap		d1
	move.w	d4,d1
	and.l		d1,(a4)+
	and.l		d1,(a4)+
	and.l		d1,(a4)+
	and.l		d1,(a4)+
	add.l		a5,a3
	add.l		a6,a1
	swap		d7
	dbra		d7,.line
.err	pop.l		a4
	pop.l		a3
	rts	

BLITMERGE:
	push.l	a3
	push.l	a4
	move.w	wdth,a5
	move.w	scrwid,a6
	lea		10.w,a2
	move.w	endmask1.w,d0
	swap		d0
	move.w	endmask3.w,d0
	move.w	x_size.w,d6
	subq		#2,d6
	bpl.s		.wide
	move.w	d0,d1
	swap		d0
	and.w		d0,d1
	move.w	d1,d0
	swap		d0
	move.w	d1,d0
.wide	swap		d6
	move.b	skew.w,d6
	move.l	a4,a1
	move.w	y_size.w,d7
	subq		#1,d7
.line	swap		d7
	move.l	a3,a0
	move.l	a1,a4
	tst.b		d6
	bpl.s		.fxsr
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	swap		d1
	swap		d2
	swap		d3
	swap		d4
	add.l		a2,a0
.fxsr	swap		d6
	move.w	d6,d7
	swap		d6
	bmi.s		.rght
.left	swap		d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.l	d1,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d1
	move.l	d2,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d2
	move.l	d3,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d3
	move.l	d4,d5
	lsr.l		d6,d5
	and.w		d0,d5
	or.w		d5,(a4)+
	swap		d4
	swap		d0
	add.l		a2,a0
	addq.l	#8,a4
	subq		#1,d7
	bmi.s		.rght
.word	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.l	d1,d5
	lsr.l		d6,d5
	or.w		d5,(a4)+
	swap		d1
	move.l	d2,d5
	lsr.l		d6,d5
	or.w		d5,(a4)+
	swap		d2
	move.l	d3,d5
	lsr.l		d6,d5
	or.w		d5,(a4)+
	swap		d3
	move.l	d4,d5
	lsr.l		d6,d5
	or.w		d5,(a4)+
	swap		d4
	add.l		a2,a0
	addq.l	#8,a4
	dbra		d7,.word
.rght	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	lsr.l		d6,d1
	and.w		d0,d1
	or.w		d1,(a4)+
	lsr.l		d6,d2
	and.w		d0,d2
	or.w		d2,(a4)+
	lsr.l		d6,d3
	and.w		d0,d3
	or.w		d3,(a4)+
	lsr.l		d6,d4
	and.w		d0,d4
	or.w		d4,(a4)+
	add.l		a5,a3
	add.l		a6,a1
	swap		d7
	dbra		d7,.line
.err	pop.l		a4
	pop.l		a3
	rts	

DRAW_SPRITE_TRUE:
	move.l	a0,a6
	moveq		#0,d2
.clpt	move.w	d7,d0
	bpl.s		.clpb
	add.w		d0,d5			; crop height
	ble		WCend
	muls		d4,d0			; width in bytes
	add.l		d0,d0
	sub.l		d0,a6			; drop into data
	moveq		#0,d7			; clip top
.clpb	move.w	SCR_HEIGHT,d0	; y-limit
	sub.w		d7,d0
	sub.w		d5,d0			; check for overhang
	bpl.s		.clpr
	add.w		d0,d5			; crop height
	ble		WCend
.clpr	move.w	SCR_WIDTH,d0	; x-limit
	sub.w		d6,d0			; minus x-pos
	sub.w		d4,d0			; minus width
	bpl.s		.clpl			; neg if inside
	add.w		d0,d4			; adjust width
	ble		WCend			; zero width?
	neg.w		d0
	add.w		d0,d0
	move.w	d0,d2			; source x-modulus
.clpl	move.w	d6,d0
	bpl.s		.prnt
	add.w		d0,d4
	ble		WCend
	add.w		d0,d0
	sub.w		d0,a6
	sub.w		d0,d2
	moveq		#0,d6
.prnt	move.l	a4,a0
	mulu		scrwid,d7
	add.l		d7,a0
	add.w		d6,d6
	add.w		d6,a0
	move.l	a0,a1
	move.w	scrwid,d7
	sub.w		d4,d7
	sub.w		d4,d7
	ext.l		d7
	ext.l		d2
	subq		#1,d4
	bmi		WCend
	subq		#1,d5
	bmi		WCend
	cmp.w		#1<<Bit_PASTE_XRAY,PASTE_BITS
	beq.s		XrayTrue
	moveq		#16-1,d6
	and.w		d4,d6
	lsr.w		#4,d4
	move.l	(COPYJUMPS.l,d6.w*4),a5
WCylp	move.w	d4,d1
	jmp		(a5)
	wcop		16
	wcop		15
	wcop		14
	wcop		13
	wcop		12
	wcop		11
	wcop		10
	wcop		9
	wcop		8
	wcop		7
	wcop		6
	wcop		5
	wcop		4
	wcop		3
	wcop		2
	wcop		1
	dbra		d1,WCxlp	
	bra.s		WCxnd
WCxlp	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	move.l	(a6)+,(a1)+
	dbra		d1,WCxlp	
WCxnd	add.l		d2,a6
	add.l		d7,a1
	dbra		d5,WCylp	
WCend	rts

XrayTrue:
	move.w	BG_COLOUR,d1
.ylp	move.w	d4,d3
.xlp	move.w	(a6)+,d0
	cmp.w		d1,d0
	beq.s		.skip
	move.w	d0,(a1)
.skip	addq.l	#2,a1
	dbra		d3,.xlp
	add.l		d2,a6
	add.l		d7,a1
	dbra		d5,.ylp
	rts

INIT_SCALED_BLOCK:
	jsr		Find_brush
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	lea		768(a0),a5
	move.l	a5,texture_ptr
	move.w	d1,NEW_WIDTH
	move.w	d2,NEW_HEIGHT
	subq		#1,d1
	subq		#1,d2
	lea		polysource,a0
	move.l	a0,texture_in
	moveq		#0,d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d0,(a0)+
	move.w	d2,(a0)+
	moveq		#1,d1
	move.l	#DSPTCMAP_L,d0
	lea		DSPTCMAP,a0
	jsr		DspExecProg
	dspwrite	NEW_WIDTH
	move.l	#polylist_1,polygon_out
	move.l	#textlist_1,texture_out
	tst.b		TRUE_FLAG
	bne.s		.done
	move.w	NEW_WIDTH,d0
	mulu		NEW_HEIGHT,d0
	jsr		MALLOCATE_fast
	tst.l		d0
	bmi.s		.err
	move.w	d0,MAPBLOCK_HANDLE
	jsr		Find_block
	move.l	a0,a1
	move.l	a1,bpl_texture
	move.l	texture_ptr,a0
	move.w	NEW_WIDTH,File_Width
	move.w	NEW_HEIGHT,File_Height
	jsr		CONVERT_PLANES_2_BYTES
.done	moveq		#0,d0
	rts
.err	moveq		#-1,d0
	rts


bpl_texture:	ds.l	1
MAPBLOCK_HANDLE:	ds.w	1

DRAW_SCALED_BLOCK:
	IFD		FINALGFX
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	jsr		Find_brush
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	lea		polydest,a1
	move.l	a1,polygon_in
	move.w	d1,d3
	move.w	d2,d4
	add.w		NEW_WIDTH,d3
	add.w		NEW_HEIGHT,d4
	subq		#1,d3
	subq		#1,d4
	addq.l	#4,a0
	move.l	a0,texture_ptr
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.w	d1,(a1)+
	move.w	d4,(a1)+
	move.w	#4,polysides
	jmp		texture_map
	ENDC

DRAW_ROTATED_BLOCK:
	IFD		FINALGFX
	move.w	NEW_WIDTH,d0
	lsr.w		d0
	add.w		BRUSH_XBASE,d0
	move.w	d0,X_ORIGIN
	move.w	NEW_HEIGHT,d0
	lsr.w		d0
	add.w		BRUSH_YBASE,d0
	move.w	d0,Y_ORIGIN
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	jsr		Find_brush
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	addq.l	#4,a0
	move.l	a0,texture_ptr
	lea		polydest,a1
	move.l	a1,polygon_in
	move.w	#4,polysides
	move.w	d1,d3
	move.w	d2,d4
	add.w		NEW_WIDTH,d3
	add.w		NEW_HEIGHT,d4
	subq		#1,d3
	subq		#1,d4
	moveq		#0,d5
	move.l	X_IN,a4
	move.l	Y_IN,a5
	move.l	Z_IN,a6
	move.w	d1,(a4)+
	move.w	d2,(a5)+
	move.w	d5,(a6)+
	move.w	d3,(a4)+
	move.w	d2,(a5)+
	move.w	d5,(a6)+
	move.w	d3,(a4)+
	move.w	d4,(a5)+
	move.w	d5,(a6)+
	move.w	d1,(a4)+
	move.w	d4,(a5)+
	move.w	d5,(a6)+
	move.w	#4,COORDS
	move.w	X_ANGLE,d5
	move.w	Y_ANGLE,d6
	move.w	Z_ANGLE,d7
	bsr		TRANSFORM
	move.l	X_OUT,a4
	move.l	Y_OUT,a5
	move.l	polygon_in,a1
	move.w	(a4)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a5)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a5)+,(a1)+
	jmp		texture_map
	ENDC

DRAW_PERSPECTED_BLOCK:
	IFD		FINALGFX
	move.w	NEW_WIDTH,d0
	lsr.w		d0
	add.w		BRUSH_XBASE,d0
	move.w	d0,X_ORIGIN
	move.w	NEW_HEIGHT,d0
	lsr.w		d0
	add.w		BRUSH_YBASE,d0
	move.w	d0,Y_ORIGIN
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	jsr		Find_brush
	move.w	(sp)+,d2
	move.w	(sp)+,d1
	addq.l	#4,a0
	move.l	a0,texture_ptr
	lea		polydest,a1
	move.l	a1,polygon_in
	move.w	#4,polysides
	move.w	d1,d3
	move.w	d2,d4
	add.w		NEW_WIDTH,d3
	add.w		NEW_HEIGHT,d4
	subq		#1,d3
	subq		#1,d4
	moveq		#0,d5
	move.l	X_IN,a4
	move.l	Y_IN,a5
	move.l	Z_IN,a6
	move.w	d1,(a4)+
	move.w	d2,(a5)+
	move.w	d5,(a6)+
	move.w	d3,(a4)+
	move.w	d2,(a5)+
	move.w	d5,(a6)+
	move.w	d3,(a4)+
	move.w	d4,(a5)+
	move.w	d5,(a6)+
	move.w	d1,(a4)+
	move.w	d4,(a5)+
	move.w	d5,(a6)+
	move.w	#4,COORDS
	move.w	X_ANGLE,d5
	move.w	Y_ANGLE,d6
	move.w	Z_ANGLE,d7
	bsr		TRANSFORM
	bsr		PERSPECTIVE
	move.l	X_IN,a4
	move.l	polygon_in,a1
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	move.w	(a4)+,(a1)+
	jmp		texture_map
	ENDC
	rts
	
*-------------------------------------------------------------------------*
*				TRANSFORMATION ROUTINE					  *
*-------------------------------------------------------------------------*
* d5,d6,d7    - X,Y,Z world rotation values list in					  *
* COORDS	  - number to do								  *
*-------------------------------------------------------------------------*

		rsreset
MATRIX11 	rs.w	1	; 3*3 rotation matrix
MATRIX21 	rs.w	1
MATRIX31 	rs.w	1
MATRIX12 	rs.w	1
MATRIX22 	rs.w	1
MATRIX32 	rs.w	1
MATRIX13 	rs.w	1
MATRIX23 	rs.w	1
MATRIX33 	rs.w	1

sin_T:	equr	d2
sin_P:	equr	d3
sin_G:	equr	d4
cos_T:	equr	d5
cos_P:	equr	d6
cos_G:	equr	d7

sinX:		equr	sin_T
sinY:		equr	sin_P
sinZ:		equr	sin_G
cosX:		equr	cos_T
cosY:		equr	cos_P
cosZ:		equr	cos_G

cosine	macro
		and.w		#sinres-1,\1
		move.w	(a3,\1.w*2),\2
		add.w		#sinres/4,\1
		and.w		#sinres-1,\1
		move.w	(a3,\1.w*2),\3
		endm

shift		macro
		lsl.l		#2,\1
		swap		\1
		endm

sinres	=		4096

TRANSFORM:
	lea		SINE,a3		; sine table
	cosine	d5,sinX,cosX	; theta	(x)
	cosine	d6,sinY,cosY	; phi		(y)
	cosine	d7,sinZ,cosZ	; gamma	(z)
	lea		MATRIX,a6		; start of matrix
*-----------------------------------*
*	Matrix part 1			*
*-----------------------------------*
	move.w	cosY,d0		;
	muls		cosZ,d0		;
	shift		d0			;
	move.w	d0,MATRIX11(a6)	; < cos[y]*cos[z]
*-----------------------------------*
	move.w	cosY,d0		;
	muls		sinZ,d0		;
	neg.l		d0			;
	shift		d0			;
	move.w	d0,MATRIX12(a6)	; < -cos[y]*sin[z]
*-----------------------------------*
	move.w	sinY,MATRIX13(a6)	; < sin[y]
*-----------------------------------*
*	Matrix part 2			*
*-----------------------------------*
	move.w	cosX,d0		;
	muls		sinZ,d0		; 	cos[x]*sin[z]
	move.w	sinX,d1		;
	muls		sinY,d1		;
	shift		d1			;
	muls		cosZ,d1		;
	add.l		d1,d0			; 	sin[x]*sin[y]*cos[z] + cos[x]*sin[z]
	shift		d0			;
	move.w	d0,MATRIX21(a6)	; < sin[x]*sin[y]*cos[z] + cos[x]*sin[z]
*-----------------------------------*
	move.w	cosX,d0		;
	muls		cosZ,d0		; 	cos[x]*cos[z]
	move.w	sinX,d1		;
	muls		sinY,d1		;
	shift		d1			;
	muls		sinZ,d1		;	sin[x]*sin[y]*sin[z]
	sub.l		d1,d0			;
	shift		d0			;
	move.w	d0,MATRIX22(a6)	; < cos[x]*cos[z] - sin[x]*sin[y]*sin[z]
*-----------------------------------*
	move.w	sinX,d0		;
	muls		cosY,d0		;
	neg.l		d0			;
	shift		d0			;
	move.w	d0,MATRIX23(a6)	; < -sin[x]*cos[y]
*-----------------------------------*
*	Matrix part 3			*
*-----------------------------------*
	move.w	sinX,d0		;
	muls		sinZ,d0		; 	sin[x]*sin[z]
	move.w	cosX,d1		;
	muls		sinY,d1		;
	shift		d1			;
	muls		cosZ,d1		; 	cos[x]*sin[y]*cos[z]
	sub.l		d1,d0			;
	shift		d0			;
	move.w	d0,MATRIX31(a6)	; < sin[x]*sin[z] - cos[x]*sin[y]*cos[z]
*-----------------------------------*
	move.w	sinX,d0		;
	muls		cosZ,d0		;	sin[x]*cos[z]
	move.w	cosX,d1		;
	muls		sinY,d1		;
	shift		d1			;
	muls		sinZ,d1		;	cos[x]*sin[y]*sin[z]
	add.l		d1,d0			;
	shift		d0			;
	move.w	d0,MATRIX32(a6)	; < cos[x]*sin[y]*sin[z] + sin[x]*cos[z]
*-----------------------------------*
	move.w	cosX,d0		;
	muls		cosY,d0		;
	shift		d0			;
	move.w	d0,MATRIX33(a6)	; < cos[x]*cos[y]
*-----------------------------------*
	move.l	X_IN,a1
	move.l	Y_IN,a2
	move.l	Z_IN,a3
	move.l	X_OUT,a4
	move.l	Y_OUT,a5
	move.l	Z_OUT,a6
	move.w	COORDS,d0
	subq		#1,d0
.Loop	move.w	(a1)+,d1
	move.w	(a2)+,d2
	move.w	(a3)+,d3
	sub.w		X_ORIGIN,d1
	sub.w		Y_ORIGIN,d2
	sub.w		Z_ORIGIN,d3
	move.w	d1,d4
	move.w	d2,d5
	move.w	d3,d6
	lea		MATRIX,a0
	muls		(a0)+,d1
	muls		(a0)+,d2
	muls		(a0)+,d3
	add.l		d1,d2
	add.l		d2,d3
	shift		d3
	add.w		X_ORIGIN,d3
	move.w	d3,(a4)+
	move.w	d4,d1
	move.w	d5,d2
	move.w	d6,d3
	muls		(a0)+,d1
	muls		(a0)+,d2
	muls		(a0)+,d3
	add.l		d1,d2
	add.l		d2,d3
	shift		d3
	add.w		Y_ORIGIN,d3
	move.w	d3,(a5)+
	muls		(a0)+,d4
	muls		(a0)+,d5
	muls		(a0)+,d6
	add.l		d4,d5
	add.l		d5,d6
	shift		d6
	add.w		Z_ORIGIN,d6
	move.w	d6,(a6)+
	dbra		d0,.Loop
	rts

*-------------------------------------------------------------------------*
*				   PERSPECTIVE ROUTINE					  *
*-------------------------------------------------------------------------*
* X,Y,Z_TRANS - X,Y,Z world coordinate list in					  *
* PLOTBANK	  - X,Y screen coordinate list out					  *
* COORDS	  - number to do								  *
*-------------------------------------------------------------------------*
 
PERSPECTIVE:
	move.l	X_OUT,a1
	move.l	Y_OUT,a2
	move.l	Z_OUT,a3
	move.l	X_IN,a4
	move.w	COORDS,d0
	move.w	#500,d7
	move.w	#0,d5
	move.w	X_ORIGIN,a0
	move.w	Y_ORIGIN,a6
	moveq		#10,d6
*-----------------------------*
.perl	move.w	(a3)+,d4
	move.w	d7,d3
	sub.w		d4,d3
	bne.s		.nzer
	subq		#1,d3
.nzer	ext.l		d4
	asl.l		d6,d4
	divs		d3,d4
*-----------------------------*
*	Translate X - Coords	*
*-----------------------------*
	move.w	(a1)+,d1	; get x-coord
	sub.w		X_ORIGIN,d1
	move.w	d1,d2		; save
	ext.l		d2
	muls		d4,d1		; x-coord * z-multiplier
	asr.l		d6,d1		; shift back down
	add.l		d1,d2		; add to orig
	add.w		X_ORIGIN,d2
	move.w	d2,(a4)+
*-----------------------------*
*	Translate Y - Coords	*
*-----------------------------*
	move.w	(a2)+,d1	; get y-coord
	sub.w		Y_ORIGIN,d1
	move.w	d1,d2		; save
	ext.l		d2
	muls		d4,d1	 	; y-coord * z-multiplier
	asr.l		d6,d1		; shifted back down
	add.l		d1,d2		; add to orig
	add.w		Y_ORIGIN,d2
	move.w	d2,(a4)+
.pend	dbra		d0,.perl
	rts

X_IN:		dc.l	L_XBuffer+0*(4*2)
Y_IN:		dc.l	L_XBuffer+1*(4*2)
Z_IN:		dc.l	L_XBuffer+2*(4*2)
X_OUT:	dc.l	L_XBuffer+3*(4*2)
Y_OUT:	dc.l	L_XBuffer+4*(4*2)
Z_OUT:	dc.l	L_XBuffer+5*(4*2)

COORDS:	ds.w	1
X_ORIGIN:	ds.w	1
Y_ORIGIN:	ds.w	1
Z_ORIGIN:	ds.w	1

Zone_m_thresh:
	jsr		HIDE_MOUSE
	move.w	#-1,OYD
	move.w	#FilterBarXmin,SLIDER_XMIN
	move.w	#FilterBarXmax,SLIDER_XMAX
	move.w	#FilterBarYmin,SLIDER_YMIN
	move.w	#FilterBarYmax,SLIDER_YMAX
	move.w	#FilterBarWidth,SLIDER_WIDTH
	move.w	CURRENT_MTHRESH,CURRENT_BARSIZE
	move.w	MAXIMUM_MTHRESH,MAXIMUM_BARSIZE
.lp	bsr		Get_hslide_pos
	cmp.w		OYD,d0
	beq		.skip
	move.w	d0,OYD	
	move.w	d0,CURRENT_MTHRESH
	bsr		Update_motion_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		SHOW_MOUSE
	rts
			
Zone_air_size:
	jsr		HIDE_MOUSE
	move.w	#-1,OYD
	move.w	#AirSizBarXmin,SLIDER_XMIN
	move.w	#AirSizBarXmax,SLIDER_XMAX
	move.w	#AirSizBarYmin,SLIDER_YMIN
	move.w	#AirSizBarYmax,SLIDER_YMAX
	move.w	#AirSizBarWidth,SLIDER_WIDTH
	move.w	CURRENT_AIRSIZE,CURRENT_BARSIZE
	move.w	MAXIMUM_AIRSIZE,MAXIMUM_BARSIZE
.lp	bsr		Get_hslide_pos
	cmp.w		OYD,d0
	beq		.skip
	move.w	d0,OYD	
	move.w	d0,CURRENT_AIRSIZE
	bsr		Update_airsize_bar
	move.w	#206,d4
	move.w	#116,d5
	xresfactor	d4
	yresfactor	d5
	move.w	LAST_AIRSIZE,d7
	move.w	x_factor,d1
	or.w		y_factor,d1
	subq		#1,d1
	beq.s		.ns1
	add.w		d7,d7
.ns1	lsr.w		d7
	moveq		#iface_lgrey,d0
	jsr		phys_circle
	move.w	#206,d4
	move.w	#116,d5
	xresfactor	d4
	yresfactor	d5
	move.w	CURRENT_AIRSIZE,d7
	move.w	x_factor,d1
	or.w		y_factor,d1
	subq		#1,d1
	beq.s		.ns2
	add.w		d7,d7
.ns2	lsr.w		d7
	moveq		#iface_grey,d0
	jsr		phys_circle
	move.w	CURRENT_AIRSIZE,LAST_AIRSIZE	
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		SHOW_MOUSE
	move.w	CURRENT_AIRSIZE,d7
	cmp.w		#4,d7
	bge.s		.ok3
	moveq		#4,d7
.ok3	move.w	d7,AIRBRUSH_SIZE
	rts

Zone_air_flow:
	jsr		HIDE_MOUSE
	move.w	#-1,OYD
	move.w	#AirFloBarXmin,SLIDER_XMIN
	move.w	#AirFloBarXmax,SLIDER_XMAX
	move.w	#AirFloBarYmin,SLIDER_YMIN
	move.w	#AirFloBarYmax,SLIDER_YMAX
	move.w	#AirFloBarWidth,SLIDER_WIDTH
	move.w	CURRENT_AIRFLOW,CURRENT_BARSIZE
	move.w	MAXIMUM_AIRFLOW,MAXIMUM_BARSIZE
.lp	bsr		Get_hslide_pos
	cmp.w		OYD,d0
	beq		.skip
	move.w	d0,OYD	
	move.w	d0,CURRENT_AIRFLOW
	bsr		Update_airflow_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		SHOW_MOUSE
	move.w	CURRENT_AIRFLOW,d7
	tst.w		d7
	bgt.s		.ok3
	moveq		#1,d7
.ok3	move.w	d7,AIRBRUSH_FLOW
	jsr		create_air_mask
	rts

Update_air_sliders:
	jsr		HIDE_MOUSE
	bsr		Update_airsize_bar
	bsr		Update_airflow_bar
	move.w	#206,d4
	move.w	#116,d5
	xresfactor	d4
	yresfactor	d5
	move.w	MAXIMUM_AIRSIZE,d7
	move.w	x_factor,d1
	or.w		y_factor,d1
	subq		#1,d1
	beq.s		.ns2
	add.w		d7,d7
.ns2	lsr.w		d7
	moveq		#iface_lgrey,d0
	jsr		phys_circle
	move.w	#206,d4
	move.w	#116,d5
	xresfactor	d4
	yresfactor	d5
	move.w	CURRENT_AIRSIZE,d7
	move.w	x_factor,d1
	or.w		y_factor,d1
	subq		#1,d1
	beq.s		.ns3
	add.w		d7,d7
.ns3	lsr.w		d7
	moveq		#iface_grey,d0
	jsr		phys_circle
	move.w	CURRENT_AIRSIZE,LAST_AIRSIZE
	jsr		SHOW_MOUSE
	rts

Update_airsize_bar:
	move.w	#AirSizBarXmin,SLIDER_XMIN
	move.w	#AirSizBarYmin,SLIDER_YMIN
	move.w	#AirSizBarXmax,SLIDER_XMAX
	move.w	#AirSizBarYmax,SLIDER_YMAX
	move.w	#AirSizBarWidth,SLIDER_WIDTH
	move.w	CURRENT_AIRSIZE,CURRENT_BARSIZE
	move.w	MAXIMUM_AIRSIZE,MAXIMUM_BARSIZE
	move.l	#dummy_text,hslide_text
	bra		Update_hslide

Update_airflow_bar:
	move.w	#AirFloBarXmin,SLIDER_XMIN
	move.w	#AirFloBarYmin,SLIDER_YMIN
	move.w	#AirFloBarXmax,SLIDER_XMAX
	move.w	#AirFloBarYmax,SLIDER_YMAX
	move.w	#AirFloBarWidth,SLIDER_WIDTH
	move.w	CURRENT_AIRFLOW,CURRENT_BARSIZE
	move.w	MAXIMUM_AIRFLOW,MAXIMUM_BARSIZE
	move.l	#dummy_text,hslide_text
	bra		Update_hslide

Update_motion_bar:
	move.w	#FilterBarXmin,SLIDER_XMIN
	move.w	#FilterBarYmin,SLIDER_YMIN
	move.w	#FilterBarXmax,SLIDER_XMAX
	move.w	#FilterBarYmax,SLIDER_YMAX
	move.w	#FilterBarWidth,SLIDER_WIDTH
	move.w	CURRENT_MTHRESH,CURRENT_BARSIZE
	move.w	MAXIMUM_MTHRESH,MAXIMUM_BARSIZE
	move.l	#dummy_text,hslide_text
	bra		Update_hslide
	
*-----------------------------------------------------------------------*

Get_vslide_pos:
	move.w	MOUSE_Y,d0
	ext.l		d0
	divu		y_factor,d0
	move.w	SLIDER_YMAX,d1
	cmp.w		d1,d0
	ble.s		.ok0
	move.w	d1,d0
.ok0	sub.w		SLIDER_YMIN,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	mulu		MAXIMUM_BARSIZE,d0
	move.w	SLIDER_YMAX,d1
	sub.w		SLIDER_YMIN,d1
	divu		d1,d0
	rts

Get_hslide_pos:
	move.w	MOUSE_X,d0
	ext.l		d0
	divu		x_factor,d0
	move.w	SLIDER_XMAX,d1
	cmp.w		d1,d0
	ble.s		.ok0
	move.w	d1,d0
.ok0	sub.w		SLIDER_XMIN,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	mulu		MAXIMUM_BARSIZE,d0
	move.w	SLIDER_XMAX,d1
	sub.w		SLIDER_XMIN,d1
	divu		d1,d0
	rts

Update_vslide:
	push.w	SLIDER_YMAX
	move.w	SLIDER_XMIN,d1
	subq		#1,d1
	move.w	SLIDER_YMIN,d2
	move.w	SLIDER_XMAX,d3
	move.w	SLIDER_YMAX,d4
	subq		#1,d4
	jsr		Depressed_bar
	move.w	SLIDER_YMAX,d0
	sub.w		SLIDER_HEIGHT,d0
	move.w	d0,SLIDER_YMAX
	move.w	SLIDER_YMIN,d0
	move.w	SLIDER_YMAX,d1
	sub.w		d0,d1
	mulu		CURRENT_BARSIZE,d1
	divu		MAXIMUM_BARSIZE,d1
	add.w		d0,d1
	move.w	d1,d3
	add.w		SLIDER_HEIGHT,d3
	subq		#1,d3
	move.w	SLIDER_XMIN,d2
	move.w	SLIDER_XMAX,d4
	subq		#1,d2
	exg		d1,d2
	exg		d3,d4
	bsr		Raised_edge
	pop.w		SLIDER_YMAX
	rts

Update_hslide:
	jsr		HIDE_MOUSE
	move.w	SLIDER_XMIN,d1
	subq		#1,d1
	move.w	SLIDER_YMIN,d2
	subq		#1,d2
	move.w	SLIDER_XMAX,d3
	move.w	SLIDER_YMAX,d4
	jsr		Depressed_bar
	move.w	SLIDER_XMIN,d0
	move.w	SLIDER_XMAX,d1
	sub.w		SLIDER_WIDTH,d1
	sub.w		d0,d1
	mulu		CURRENT_BARSIZE,d1
	divu		MAXIMUM_BARSIZE,d1
	add.w		d0,d1
	move.w	d1,d3
	add.w		SLIDER_WIDTH,d3
	move.w	SLIDER_YMIN,d2
	move.w	SLIDER_YMAX,d4
	subq		#1,d1
	subq		#1,d2
	bsr		Raised_bar
	move.l	hslide_text,d0
	beq.s		.stop
	move.l	d0,a0
	jsr		centre_justify
.stop	jsr		SHOW_MOUSE
	rts

dummy_text:		dc.w	0
hslide_text:	ds.l	1

SLIDER_XMAX:	ds.w	1
SLIDER_XMIN:	ds.w	1
SLIDER_YMAX:	ds.w	1
SLIDER_YMIN:	ds.w	1
SLIDER_WIDTH:	ds.w	1
SLIDER_HEIGHT:	ds.w	1

CURRENT_BARSIZE:	ds.w	1
MAXIMUM_BARSIZE:	ds.w	1
OFI:			ds.b	1
			even
			
*-----------------------------------------------------------------------*

Press_button:
	pushall
	move.b	FREEZE_ICONS,OFI
	st		FREEZE_ICONS
	jsr		HIDE_MOUSE
	movem.w	ICON_AREA,d1-d4
	addq		#1,d3
	addq		#1,d4
	jsr		Depressed_edge
	jsr		SHOW_MOUSE
	popall
	rts

Release_button:
.lp	tst.b		BUTTONS
	bne.s		.lp	
	pushall
	jsr		HIDE_MOUSE
	movem.w	ICON_AREA,d1-d4
	addq		#1,d3
	addq		#1,d4
	jsr		Raised_edge
	jsr		SHOW_MOUSE
	clr.b		GOT_PRESS
	move.b	OFI,FREEZE_ICONS
	popall
	rts

Press_groove:
	pushall
	jsr		HIDE_MOUSE
	movem.w	ICON_AREA,d1-d4
	addq		#1,d3
	addq		#1,d4
	subq		#1,d1
	subq		#1,d2
	jsr		Depressed_edge
	jsr		SHOW_MOUSE
	popall
	rts

Release_groove:
.lp	tst.b		BUTTONS
	bne.s		.lp	
	pushall
	jsr		HIDE_MOUSE
	movem.w	ICON_AREA,d1-d4
	addq		#1,d3
	addq		#1,d4
	subq		#1,d1
	subq		#1,d2
	jsr		Raised_edge
	jsr		SHOW_MOUSE
	popall
	rts

*-----------------------------------------------------------------------*

UPDATE_BRUSH:
*-----------------------------------------*
	pushall
	move.w	LAST_BRUSH_SELECTED,d0
	mulu		#3,d0
	lea		(BRUSH_HANDLES+2.l,d0.l*2),a0
	move.w	BRUSH_XBASE,(a0)+
	move.w	BRUSH_YBASE,(a0)+
*-----------------------------------------*
	move.w	BRUSH_SELECTED,d0
	move.w	d0,LAST_BRUSH_SELECTED
	mulu		#3,d0
	lea		(BRUSH_HANDLES.l,d0.l*2),a0
	move.w	(a0)+,BRUSH_HANDLE
	move.w	(a0)+,BRUSH_XBASE
	move.w	(a0)+,BRUSH_YBASE
*-----------------------------------------*
	popall
	rts
	
	ifd		crap

Zone_pickbrush:
	pushall
	jsr		HIDE_MOUSE
	addq		#1,BRUSH_TYPE

	lea		Pen_coords,a0
	moveq		#0,d0
	moveq		#0,d1
	move.w	BUTTON_X,d0
	move.w	#BmenX,d3
	xresfactor	d3
	sub.w		d3,d0
	bmi		.miss
	moveq		#0,d5
	move.w	#22,d3
	xresfactor	d3
	divu		d3,d0
	cmp.w		#4,d0
	beq		.miss
	cmp.w		#5,d0
	bne.s		.nrm2
	moveq		#0,d0
	moveq		#1,d5
.nrm2	move.w	BUTTON_Y,d1
	move.w	#BmenY,d3
	yresfactor	d3
	sub.w		d3,d1
	bmi		.miss
	move.w	#22,d3
	yresfactor	d3
	divu		d3,d1
	tst.w		d5
	beq.s		.ok1
	moveq		#16,d0
	add.w		d1,d0
	bra.s		.done
.ok1	lsl.w		#2,d1
	add.w		d1,d0
.done	pushall
	lea		Pen_coords,a0
	move.w	BRUSH_TYPE,d0
	movem.w	(a0,d0.w*4),d1-d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		#20,d3
	add.w		#20,d4
	cmp.w		#16,BRUSH_TYPE
	blt.s		.norm
	subq		#4,d3
	subq		#4,d4
.norm	jsr		Raised_edge
	popall
	move.w	d0,BRUSH_TYPE
	pushall
	cmp.w		#16,d0
	blt.s		.nok
	move.w	BRUSH_SELECTED,d0
	lea		Brush_sel_coords,a0
	movem.w	(a0,d0.w*4),d1-d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		#20,d3
	add.w		#20,d4
	jsr		Raised_edge
.nok	popall
	movem.w	(a0,d0.w*4),d1-d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		#20,d3
	add.w		#20,d4
	cmp.w		#16,BRUSH_TYPE
	blt.s		.ok2
	pushall
	subq		#2,d1
	subq		#2,d2
	subq		#2,d3
	subq		#2,d4
	jsr		Depressed_edge
	popall
	subq		#4,d3
	subq		#4,d4
.ok2	jsr		Depressed_edge
.miss	subq		#1,BRUSH_TYPE
	jsr		SHOW_MOUSE
*-----------------------------------------*
	move.w	BRUSH_TYPE,d0
	sub.w		#15,d0
	bmi.s		.same
	move.w	d0,BRUSH_SELECTED
	bsr		UPDATE_BRUSH
*-----------------------------------------*
.same	popall
	rts
	
	endc

DRAW_MENU_BRUSH:
	move.l	PHYS_SCR,a0
	tst.w		BRUSH_TYPE
	bpl.s		.ok2
	move.w	physwid,scrwid
	jsr		WRITE_PIXEL
	bra.s		.ok3
.ok2	cmp.w		#15,BRUSH_TYPE
	blt.s		.nrm
	move.w	d1,d6
	move.w	d2,d7
	push.w	BRUSH_SELECTED
	move.w	BRUSH_TYPE,d0
	sub.w		#15,d0
	move.w	d0,BRUSH_SELECTED
	bsr		UPDATE_BRUSH
	jsr		DRAW_SPRITE_MINI
	pop.w		BRUSH_SELECTED
	bsr		UPDATE_BRUSH
	bra.s		.ok3
.nrm	jsr		DRAW_PHYS_BRUSH
.ok3	rts

DO_ALERT:
	tst.b		safe
	beq.s		.err
	pushall
	ifd		moveborders
	push.w	SCAN_START.w
	push.w	SCAN_STOP.w
	move.w	OLD_SCAN_STOP,SCAN_STOP.w
	move.w	OLD_SCAN_START,SCAN_START.w
	endc
	bsr.s		INIT_ALERT
	jsr		Dialog
	jsr		Check_menu
	st		ALERT
	ifd		moveborders
	pop.w		SCAN_STOP.w
	pop.w		SCAN_START.w
	endc
	popall
.err	rts
	
INIT_ALERT:
	clr.w		DIALOG_BITS
	rts
	
*-------------------------------------------------------------------------*

DELAY:
	push.w	#37
	trap		#14
	trap		#14
	trap		#14
	trap		#14
	trap		#14
	trap		#14
	addq		#2,sp
	rts

Appl_init:
	pushall
	lea		control,a0
	move.w	#10,(a0)
	move.w	#0,2(a0)
	move.w	#1,4(a0)
	move.w	#0,6(a0)
	move.w	#0,8(a0)
	bsr		AES
	popall
	rts

Appl_exit:
	pushall
	lea		control,a0
	move.w	#19,(a0)
	move.w	#0,2(a0)
	move.w	#1,4(a0)
	move.w	#0,6(a0)
	move.w	#0,8(a0)
	bsr		AES
.lp	tst.w		int_out
	beq.s		.lp
	popall
	rts
	
Graf_handle:
	lea		control,a0
	move.w	#77,(a0)
	move.w	#0,2(a0)
	move.w	#5,4(a0)
	move.w	#0,6(a0)
	bsr		AES
	move.w	int_out,handle
	rts

V_OpenVWork:
	lea		control,a0
	move.w	#100,(a0)
	move.w	#0,2(a0)
	move.w	#6,4(a0)
	move.w	#11,6(a0)
	move.w	#45,8(a0)
	move.w	handle,12(a0)
	lea		int_in,a0
	moveq		#1,d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	#2,(a0)+
	bsr		VDI
	move.w	control+12,vhandle
	rts

V_CloseVWork:
	lea		control,a0
	move.w	#101,(a0)
	move.w	#0,2(a0)
	move.w	#0,4(a0)
	move.w	#0,6(a0)
	move.w	#0,8(a0)
	move.w	vhandle,12(a0)
	bsr.s		VDI
	rts

V_Free:
	lea		control,a0
	move.w	#51,(a0)
	move.w	#9,2(a0)
	move.w	#1,4(a0)
	move.w	#0,6(a0)
	move.w	#0,8(a0)
	lea		int_in,a0
	move.w	#3,(a0)+	; flag
	move.w	#0,(a0)+	; smallbox
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+	; largebox
	move.w	#0,(a0)+
	move.w	DESKTOP_WIDTH,(a0)+
	move.w	DESKTOP_HEIGHT,(a0)+
	bsr.s		AES
	rts

AES:	move.l	#aespb,d1
	move.w	#200,d0
	trap		#2	
	rts

VDI:	move.l	#vdipb,d1
	moveq		#115,d0
	trap		#2	
	rts

Clear_MEM:
	move.l	DATA_START,a0
	move.l	DATA_SIZE,d0
	lsr.l		#2,d0
.loop	clr.l		(a0)+
	subq.l	#1,d0
	bne.s		.loop
	rts

Prepare_font:
	lea		MINIFONT,a0
	lea		TRUE_FONT,a1
	move.w	#256-1,d0
.char	move.b	(a0)+,(a1)
	move.b	(a0)+,256*1(a1)
	move.b	(a0)+,256*2(a1)
	move.b	(a0)+,256*3(a1)
	move.b	(a0)+,256*4(a1)
	move.b	(a0)+,256*5(a1)
	addq.l	#1,a1
	dbra		d0,.char
	lea		TRUE_FONT,a0
	lea		MINIFONT,a1
	move.w	#256-1,d0
.copy	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	dbra		d0,.copy
	rts
	
Init_font:
	move.l	#MINIFONT,FONT
	cmp.w		#1,x_factor
	beq.s		.rts
	move.l	FONT8X8,FONT
.rts	rts

FONT:	dc.l		MINIFONT

*-----------------------------------------------------------------------*
*	SYSTEM FILE HANDLING								*
*-----------------------------------------------------------------------*

READ_SYSFILE:
	move.l	sysfile_name,a0
	move.l	SYSTEM_PTR,a1
.copy	move.b	(a0)+,(a1)+
	bne.s		.copy
	lea		SYSTEM_PATH,a0
	jsr		OpenFile
	tst.l		d0
	bmi.s		.err
	move.w	d0,SYSFILE_HANDLE
	moveq		#1,d1
	move.l	sysfile_index,d2
	jsr		SeekFile
	move.l	sysfile_size,d1
	move.l	sysfile_ptr,a0
	move.w	SYSFILE_HANDLE,d0
	jsr		ReadFile
	move.w	SYSFILE_HANDLE,d0
	jsr		CloseFile
	moveq		#0,d0
.err	rts

WRITE_SYSFILE:
	move.l	sysfile_name,a0
	move.l	SYSTEM_PTR,a1
.copy	move.b	(a0)+,(a1)+
	bne.s		.copy
	lea		SYSTEM_PATH,a0
	jsr		CreateFile
	tst.l		d0
	bmi.s		.err
	move.w	d0,SYSFILE_HANDLE
	move.l	sysfile_size,d1
	move.l	sysfile_ptr,a0
	jsr		WriteFile
	move.w	SYSFILE_HANDLE,d0
	jsr		CloseFile
	moveq		#0,d0
.err	rts

*-----------------------------------------------------------------------*
*	DSP Subroutines and init code							*
*-----------------------------------------------------------------------*

*-----------------------------------*
Init_DSP:					*
*-----------------------------------*
	jsr		IsDspDrv
*-----------------------------------*
	jsr		DspFlushSubroutines
*-----------------------------------*
	moveq		#3,d0
	jsr		DspRemoveInterrupts
*-----------------------------------*
	lea		DSP_XAvail,a0
	lea		DSP_YAvail,a1
	jsr		DspAvailable
*-----------------------------------*
	move.l	DSP_XAvail,d0
	move.l	DSP_YAvail,d1
	jsr		DspReserve
*-----------------------------------*
	rts

*-----------------------------------*
Start_morph:				*
*-----------------------------------*
	move.l	#MORPHCODE_L,d0
	moveq		#1,d1
	lea		DSPMORPH,a0
	jsr		DspExecProg
*-----------------------------------*
	lea		GUIDE_COUNT,a0		; lines to send
	moveq		#1,d0				; word-count
	moveq		#0,d1
	jsr		DspBlkWords
*-----------------------------------*
	bsr		Get_start_guides
	lea		Guide_data,a0
	moveq		#0,d0
	move.w	GUIDE_COUNT,d0
	lsl.w		#2,d0
	moveq		#0,d1
	jsr		DspBlkWords
*-----------------------------------*
	bsr		Get_end_guides
	lea		Guide_data,a0
	moveq		#0,d0
	move.w	GUIDE_COUNT,d0
	lsl.w		#2,d0
	moveq		#0,d1
	jsr		DspBlkWords
*-----------------------------------*
	bsr		Get_tween_guides
	lea		Guide_data,a0
	moveq		#0,d0
	move.w	GUIDE_COUNT,d0
	lsl.w		#2,d0
	moveq		#0,d1
	jsr		DspBlkWords
*-----------------------------------*
	dspwrite	Morph_x1
	dspwrite	Morph_y1
	dspwrite	Morph_width
	dspwrite	Morph_height
	rts

*-----------------------------------------------------------------------*

*-----------------------------------------------*	
Render_morph_DSP:
*-----------------------------------------------*	
	move.w	CUR_DELTAFRAME,d0
	cmp.w		OLAY_START,d0
	beq		.stop
	cmp.w		OLAY_END,d0
	beq		.stop
*-----------------------------------------------*	
	move.w	OLAY_START,d0
	jsr		Update_position
*-----------------------------------------------*	
	move.l	FRAME_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
*-----------------------------------------------*	
	move.w	OLAY_END,d0
	jsr		Update_position
*-----------------------------------------------*	
	move.w	OLAY_END,d0
	sub.w		OLAY_START,d0
	move.w	d0,DEST_SCALER
	move.w	CUR_DELTAFRAME,d7
	sub.w		OLAY_START,d7
	move.w	d7,SOURCE2_SCALER
	sub.w		d7,d0
	move.w	d0,SOURCE1_SCALER
*-----------------------------------------------*	
	move.w	CANVAS_WIDTH,d0
	subq		#1,d0
	move.w	d0,MPic_width
	move.w	CANVAS_HEIGHT,d0
	subq		#1,d0
	move.w	d0,MPic_height
	lea		$FFFFA206.w,a6
	move.l	PACK_SCR,a1
	move.l	FRAME_SCR,a2
	move.l	LOG_SCR,a3
	move.w	Morph_x1,d0
	add.w		d0,d0
	add.w		d0,a3
	move.w	Morph_y1,d0
	move.l	(LOG_Y.l,d0.w*4),d0
	add.l		d0,a3
*-----------------------------------------------*	
	move.w	Morph_height,d7
	subq		#1,d7
*-----------------------------------------------*	
.Ylop	push.w	d7
	move.w	Morph_width,d7
	subq		#1,d7
	move.l	a3,a4
*-----------------------------------------------*	
.Xlop	btst		#0,-4(a6)
	beq.s		.Xlop
	move.w	(a6),d0
*-----------------------------------------------*	
.w2	btst		#0,-4(a6)
	beq.s		.w2
	move.w	(a6),d1
*-----------------------------------------------*	
.w3	btst		#0,-4(a6)
	beq.s		.w3
	move.w	(a6),d2
*-----------------------------------------------*	
.w4	btst		#0,-4(a6)
	beq.s		.w4
	move.w	(a6),d3
*-----------------------------------------------*	
	move.w	MPic_width(pc),d4
	move.w	MPic_height(pc),d5
	tst.w		d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	tst.w		d1
	bpl.s		.ok2
	moveq		#0,d1
.ok2	tst.w		d2
	bpl.s		.ok3
	moveq		#0,d2
.ok3	tst.w		d3
	bpl.s		.ok4
	moveq		#0,d3
.ok4	cmp.w		d4,d0
	ble.s		.ok5
	move.w	d4,d0
.ok5	cmp.w		d5,d1
	ble.s		.ok6
	move.w	d5,d1
.ok6	cmp.w		d4,d2
	ble.s		.ok7
	move.w	d4,d2
.ok7	cmp.w		d5,d3
	ble.s		.ok8
	move.w	d5,d3
*-----------------------------------------------*	
*	Fetch pixels from source1 + source2		*
*-----------------------------------------------*	
.ok8	move.w	CANVAS_WIDTH,d4
	mulu		d4,d1
	mulu		d4,d3
	ext.l		d0
	ext.l		d2
	add.l		d0,d1
	add.l		d2,d3
	move.w	(a2,d3.l*2),d6
	move.w	(a1,d1.l*2),d3
	moveq		#%11111,d1
	moveq		#%11111,d4
	moveq		#%111111,d2
	moveq		#%111111,d5
	and.w		d3,d1
	and.w		d6,d4
	lsr.w		#5,d3
	lsr.w		#5,d6
	and.w		d3,d2
	and.w		d6,d5
	lsr.w		#6,d3
	lsr.w		#6,d6
*-----------------------------------------------*	
*	Scale up R,G,B relative to frame number	*	
*-----------------------------------------------*	
	move.w	SOURCE1_SCALER(pc),d0
	mulu		d0,d1
	mulu		d0,d2
	mulu		d0,d3
	move.w	SOURCE2_SCALER(pc),d0
	mulu		d0,d4
	mulu		d0,d5
	mulu		d0,d6
*-----------------------------------------------*	
*	Get average RGB between two sources		*	
*-----------------------------------------------*	
	add.l		d4,d1
	add.l		d5,d2
	add.l		d6,d3
	move.w	DEST_SCALER(pc),d0
	divu		d0,d1
	divu		d0,d2
	divu		d0,d3
*-----------------------------------------------*	
*	Re-combine RGB into pixel-word		*	
*-----------------------------------------------*	
	moveq		#6+5,d0
	lsl.w		d0,d3	
	lsl.w		#5,d2
	or.w		d1,d2	
	or.w		d2,d3
*-----------------------------------------------*	
*	Plot pixel at x,y					*	
*-----------------------------------------------*
	move.w	d3,(a4)+
*-----------------------------------------------*
	dbra		d7,.Xlop
	add.w		logwid,a3
*-----------------------------------------------*
	cmp.b		#right_button,BUTTONS
	bne.s		.nq
	st		ABORT_TWEEN
	pop.w		d7
	bra.s		.stop
.nq	pop.w		d7
	dbra		d7,.Ylop
*-----------------------------------------------*
.stop	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	rts

MPic_width:			ds.w	1
MPic_height:		ds.w	1
SOURCE1_SCALER:		ds.w	1
SOURCE2_SCALER:		ds.w	1
DEST_SCALER:		ds.w	1

*-----------------------------------------------*	
Render_distort_DSP:
*-----------------------------------------------*	
	move.w	CUR_DELTAFRAME,d0
	cmp.w		OLAY_START,d0
	beq		.stop
*-----------------------------------------------*	
	move.w	OLAY_START,d0
	bsr		Update_position
*-----------------------------------------------*	
	move.w	OLAY_END,d0
	sub.w		OLAY_START,d0
	move.w	d0,DEST_SCALER
	move.w	CUR_DELTAFRAME,d7
	sub.w		OLAY_START,d7
	move.w	d7,SOURCE2_SCALER
	sub.w		d7,d0
	move.w	d0,SOURCE1_SCALER
*-----------------------------------------------*	
	move.w	CANVAS_WIDTH,d0
	subq		#1,d0
	move.w	d0,MPic_width
	move.w	CANVAS_HEIGHT,d0
	subq		#1,d0
	move.w	d0,MPic_height
	move.w	logwid,scrwid
*-----------------------------------------------*	
	move.w	Morph_y1,py
	move.w	Morph_height,d7
	subq		#1,d7
*-----------------------------------------------*	
.Ylop	push.w	d7
	move.w	Morph_x1,px
	move.w	Morph_width,d7
	subq		#1,d7
*-----------------------------------------------*	
.Xlop	push.w	d7
	lea		$FFFFA206.w,a6
*-----------------------------------------------*	
.w1	btst		#0,-4(a6)
	beq.s		.w1
	move.w	(a6),d1
*-----------------------------------------------*	
.w2	btst		#0,-4(a6)
	beq.s		.w2
	move.w	(a6),d2
*-----------------------------------------------*	
.w3	btst		#0,-4(a6)
	beq.s		.w3
	move.w	(a6),d3
*-----------------------------------------------*	
.w4	btst		#0,-4(a6)
	beq.s		.w4
	move.w	(a6),d4
*-----------------------------------------------*	
	move.w	MPic_width(pc),d5
	move.w	MPic_height(pc),d6
	tst.w		d1
	bpl.s		.ok1
	moveq		#0,d1
.ok1	tst.w		d2
	bpl.s		.ok2
	moveq		#0,d2
.ok2	cmp.w		d5,d1
	ble.s		.ok5
	move.w	d5,d1
.ok5	cmp.w		d6,d2
	ble.s		.ok6
	move.w	d6,d2
*-----------------------------------------------*	
*	Fetch and plot pixels				*
*-----------------------------------------------*	
.ok6	move.l	FRAME_SCR,a0
	jsr		READ_SCR_PIXEL
	move.w	px(pc),d1
	move.w	py(pc),d2
	move.l	LOG_SCR,a0
	jsr		WRITE_PIXEL
*-----------------------------------------------*
	addq		#1,px
	pop.w		d7
	dbra		d7,.Xlop
*-----------------------------------------------*
	cmp.b		#right_button,BUTTONS
	bne.s		.nq
	st		ABORT_TWEEN
	pop.w		d7
	bra.s		.stop
.nq	pop.w		d7
	addq		#1,py
	dbra		d7,.Ylop
*-----------------------------------------------*
.stop	move.w	CUR_DELTAFRAME,d0
	bsr		Update_position
	rts
	
px:	ds.w		1
py:	ds.w		1

*-----------------------------------------------------------------------*

Get_start_guides:
	moveq		#0,d1
	bra.s		Get_guides
Get_end_guides:
	move.w	OLAY_END,d1
	sub.w		OLAY_START,d1
	bra.s		Get_guides
Get_tween_guides:
	move.w	CUR_DELTAFRAME,d1
	sub.w		OLAY_START,d1
*-----------------------------------------*
Get_guides:
	move.w	OLAY_END,d2
	sub.w		OLAY_START,d2
	ext.l		d1
	ext.l		d2
	swap		d1
	divu.l	d2,d1				; T#
	move.l	d1,T
*-----------------------------------------*
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	lea		Guide_data,a1
*-----------------------------------------*
.loop	movem.l	a0-a1,-(sp)
*-----------------------------------------*
	move.l	T,d7
	moveq		#1,d6
	swap		d6
	sub.l		d7,d6				; (1.0-T#)
*-----------------------------------------*
	move.w	guide_x1_1(a0),d0
	move.w	guide_x1_2(a0),d1
	ext.l		d0
	ext.l		d1
	mulu.l	d6,d0
	mulu.l	d7,d1
	add.l		d0,d1
	swap		d1
	move.w	guide_y1_1(a0),d0
	move.w	guide_y1_2(a0),d2
	ext.l		d0
	ext.l		d2
	mulu.l	d6,d0
	mulu.l	d7,d2
	add.l		d0,d2
	swap		d2
	move.w	guide_x2_1(a0),d0
	move.w	guide_x2_2(a0),d3
	ext.l		d0
	ext.l		d3
	mulu.l	d6,d0
	mulu.l	d7,d3
	add.l		d0,d3
	swap		d3
	move.w	guide_y2_1(a0),d0
	move.w	guide_y2_2(a0),d4
	ext.l		d0
	ext.l		d4
	mulu.l	d6,d0
	mulu.l	d7,d4
	add.l		d0,d4
	swap		d4
*-----------------------------------------*
	movem.l	(sp)+,a0-a1
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.w	guide_next(a0),d0
	bmi.s		.done
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	bra		.loop
.done	rts

Init_Y_table:
	move.w	#(230*2)-1,d0
	subq		#1,d0
	moveq		#0,d1
	lea		PHYS_Y,a0
.lp	move.w	d1,d2
	mulu		physwid,d2
	move.l	d2,(a0)+
	addq		#1,d1
	dbra		d0,.lp
	move.w	#log_height-1,d0
	subq		#1,d0
	moveq		#0,d1
	lea		LOG_Y,a0
.lp2	move.w	d1,d2
	mulu		logwid,d2
	move.l	d2,(a0)+
	addq		#1,d1
	dbra		d0,.lp2
	rts

Init_palette:
	lea		INITIAL_COLOURS,a0
	lea		COLOURS,a1
	move.w	#256-1,d7
	moveq		#0,d1
	move.w	VCOL_BITS,d6
	and.w		#1<<Bit_VCOL_GREY,d6
	bne.s		.grey
.c256	move.l	(a0)+,d0
	and.l		COLMASK,d0
	move.l	d0,(a1)+
	dbra		d7,.c256
	rts
.grey	move.l	d1,(a1)+
	add.l		#$00010101,d1
	dbra		d7,.grey
	rts

Init_colours:
	lea		INDEX_TABLE+256,a0
	move.w	#256-1,d0
.lp	move.b	d0,-(a0)
	dbra		d0,.lp
	rts

Init_digilines:
	lea		digi_lines,a1
	move.l	#($10000*16)/10,d1
	moveq		#0,d0
	move.w	#160-1,d7	
.lp	move.w	d0,d2
	mulu		#1024,d2
	move.l	d2,(a1)+
	swap		d0
	add.l		d1,d0
	swap		d0
	dbra		d7,.lp
	rts
		
COPYCOLS:
	move.w	#256-1,d7
	move.l	COLMASK,d5
	move.l	d5,d4
	not.l		d4
	move.l	#$FFFFFF,d2
	and.l		d2,d4
.copy	move.l	(a0)+,d6
	and.l		d5,d6
	move.l	d6,d3
	add.l		d4,d3
	cmp.l		d2,d3
	bne.s		.cont
	move.l	d2,d6
.cont	move.l	d6,(a1)+
	dbra		d7,.copy
	rts
			
*-----------------------------------------------------------------------*

Print_RAM_Alert:
	pushall
	lea		RAM_ALERT_TEXT,a0
	bsr		PRINT_LINE_ADJ
	popall
	st		Memory_error
	rts

*-----------------------------------------------------------------------*

Extra_xray:
	eor.w		#1<<Bit_PASTE_XRAY,PASTE_BITS
	eor.w		#1<<Bit_PASTE_SOLI,PASTE_BITS
	jsr		MAKE_BLOCKMASK
	rts

Extra_gridswitch:
	eor.w		#1<<Bit_GRID_USE,GRID_BITS
	rts
	
reset_canvas_size:
	lea		VIDEO_STRUCTURE,a6
	move.l	edit_list,line_ptr
	move.l	line_ptr,a0
	move.w	VIDEO_WIDTH,d0
	move.w	d0,canwid_copy(a6)
	ext.l		d0
	move.l	d0,g_text(a0)
	move.l	edit_list+4,line_ptr
	move.l	line_ptr,a0
	move.w	VIDEO_HEIGHT,d0
	move.w	d0,canhig_copy(a6)
	ext.l		d0
	move.l	d0,g_text(a0)
	rts

update_canwid:
	move.l	edit_list,line_ptr
	lea		VIDEO_STRUCTURE,a6
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	addq		#2-1,d0
	and.w		#-2,d0
	cmp.w		#1<<Bit_VCOL_TRUE,VCOL_BITS
	beq.s		.ok
	add.w		#16-1,d0
	and.w		#-16,d0	
.ok	cmp.w		VIDEO_WIDTH,d0
	bge.s		.ok2
	move.w	VIDEO_WIDTH,d0
.ok2	move.w	d0,canwid_copy(a6)
	move.l	d0,g_text(a0)
	rts

update_canhig:
	move.l	edit_list+4,line_ptr
	lea		VIDEO_STRUCTURE,a6
	move.l	line_ptr,a0
	move.l	g_text(a0),d0
	cmp.w		VIDEO_HEIGHT,d0
	bge.s		.ok
	move.w	VIDEO_HEIGHT,d0
.ok	move.w	d0,canhig_copy(a6)
	move.l	d0,g_text(a0)
	rts


Zone_DQUIT:
	move.w	#-1,DIALOG_BITS
Zone_dummy:
	rts
	
edit_line:
	jsr		HIDE_MOUSE
	move.l	line_ptr,a0
	move.w	2+g_var(a0),d0
	moveq		#1,d1
.loop	ext.l		d0
	divu		#10,d0
	tst.w		d0
	beq.s		.go
	addq		#1,d1
	bra.s		.loop
.go	move.w	d1,line_len
	move.l	g_text(a0),d0
	jsr		NUM2ASCIIL
	jsr		show_line
	lea		STAR,a0
	jsr		PRINT_LINE
.new	jsr		GET_CHAR
	cmp.b		#13,d0
	beq.s		.done
	cmp.b		#8,d0
	bne.s		.nbs
	tst.b		NUM_TEXT
	beq.s		.new
	bsr		find_last
	clr.b		-(a0)
	subq.b	#1,NUM_TEXT
	jsr		show_line
	lea		STAR,a0
	jsr		PRINT_LINE
	bra.s		.new
.nbs	moveq		#0,d1
	move.b	NUM_TEXT,d1
	cmp.w		line_len,d1
	beq.s		.new
	cmp.b		#'0',d0
	blt.s		.new
	cmp.b		#'9',d0
	bgt.s		.new
	bsr		find_last
	move.b	d0,(a0)+
	clr.b		(a0)
	addq.b	#1,NUM_TEXT
	jsr		show_line
	lea		STAR,a0
	jsr		PRINT_LINE
	bra.s		.new
.done	jsr		show_line
	jsr		ASCII2NUM
	move.l	line_ptr,a0
	moveq		#0,d1
	move.w	g_var(a0),d1
	cmp.l		d1,d0
	bge.s		.ok1
	move.l	d1,d0
.ok1	move.w	2+g_var(a0),d1
	cmp.l		d1,d0
	ble.s		.ok2
	move.l	d1,d0
.ok2	move.l	d0,g_text(a0)
	jsr		NUM2ASCIIL
	jsr		show_line
	jsr		SHOW_MOUSE
	rts
	
find_last:
	lea		NUM_TEXT+1,a0
.lz	tst.b		(a0)+
	bne.s		.lz
	subq		#1,a0
	rts
	
show_line:
	jsr		HIDE_MOUSE
	jsr		clear_line
	move.l	line_ptr,a0
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	lea		NUM_TEXT+1,a0
	move.w	#iface_white,CHAR_COL
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts	

line_len:	ds.w	1
line_ptr:	ds.l	1
STAR:		dc.b	'',0
		even
	
clear_line:	
	move.l	line_ptr,a0
	move.w	g_x(a0),d1
	move.w	g_y(a0),d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		g_w(a0),d3
	add.w		g_h(a0),d4
	addq		#2,d1
	addq		#2,d2
	subq		#2,d3
	subq		#2,d4
	moveq		#iface_lgrey,d0
	jsr		DRAW_MENU_BLOCK
	rts

Draw_YUV_zones:
	tst.b		rgb_selector_on
	beq.s		.no
	jsr		Draw_sample_zone
	jsr		Convert_RGB_2_SLIDER
	bsr		Draw_CHROMA_zone
	bsr		Draw_LUMA_zone
.no	rts
	
Draw_CHROMA_zone:
	tst.b		TRUE_FLAG
	beq		.err
	jsr		HIDE_MOUSE
	cmp.w		#1<<Bit_PCK_YUV,PCK_BITS
	beq.s		.ok
	jsr		Init_DSP_RGB_HSV
	bra.s		.ok2
.ok	jsr		Init_DSP_RGB_YUV
.ok2	move.l	PHYS_SCR,a0
	move.w	#247+uv_x,d1
	move.w	#38+rgby+uv_y,d2
	xresfactor	d1
	yresfactor	d2
	add.w		d1,d1
	add.w		d1,a0
	mulu		physwid,d2
	add.l		d2,a0
	move.w	x_factor,d3
	move.w	y_factor,d4
	eor.w		#3,d3
	eor.w		#3,d4
	lsl.w		#2,d3
	lsl.w		#2,d4
	move.w	#64/2,d7
	yresfactor	d7
	subq		#1,d7
	moveq		#0,d2
.ylop	push.w	d7
	move.w	#64/2,d6
	xresfactor	d6
	subq		#1,d6
	move.w	#256,d1
	move.l	a0,a1
.xlop	sub.w		d3,d1
	push.w	d6
	dspwrite	#0
	dspwrite	#255
	dspwrite	d1
	dspwrite	d2
	dspread	d5
	dspread	d6
	dspread	d7
	bfins		d5,d0{16:8}
	bfins		d6,d0{21:8}
	bfins		d7,d0{27:8}
	move.w	d0,(a1)+
	pop.w		d6
	dbra		d6,.xlop
	add.w		d4,d2
	add.w		physwid,a0
	pop.w		d7
	dbra		d7,.ylop
	jsr		SHOW_MOUSE
.err	rts

Draw_LUMA_zone:
	tst.b		TRUE_FLAG
	beq		.err
	jsr		HIDE_MOUSE
	jsr		Init_DSP_RGB_HSV
	move.w	TEMP_LUMA,d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	dspwrite	#1
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	dspread	d1
	dspread	d2
	dspread	d3
	move.l	PHYS_SCR,a0
	move.w	#247+uv_x+y_x,d1
	move.w	#38+rgby+uv_y,d4
	xresfactor	d1
	yresfactor	d4
	add.w		d1,d1
	add.w		d1,a0
	mulu		physwid,d4
	add.l		d4,a0
	move.w	y_factor,d4
	eor.w		#3,d4
	lsl.w		#2,d4
	moveq		#0,d1
	move.w	#32,d7
	yresfactor	d7
	subq		#1,d7
.ylp	push.w	d7
	dspwrite	#0
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	dspread	d5
	dspread	d6
	dspread	d7
	cmp.w		#255,d5
	ble.s		.ok1
	move.w	#255,d5
.ok1	cmp.w		#255,d6
	ble.s		.ok2
	move.w	#255,d6
.ok2	cmp.w		#255,d7
	ble.s		.ok3
	move.w	#255,d7
.ok3	bfins		d5,d0{16:8}
	bfins		d6,d0{21:8}
	bfins		d7,d0{27:8}
	move.l	a0,a1
	moveq		#8,d6
	xresfactor	d6
	subq		#1,d6
.xlp	move.w	d0,(a1)+
	dbra		d6,.xlp
	add.w		physwid,a0
	add.w		d4,d1
	pop.w		d7
	dbra		d7,.ylp
	jsr		SHOW_MOUSE
.err	rts

Draw_sample_zone:
	jsr		HIDE_MOUSE
	move.w	FG_COLOUR,d0
	tst.b		TRUE_FLAG
	beq.s		.go
	move.w	TEMP_RED,d1
	move.w	TEMP_GRN,d2
	move.w	TEMP_BLU,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
.go	move.w	#247+uv_x+y_x+16,d1
	move.w	#38+rgby+uv_y,d2
	move.w	d1,d3
	move.w	d2,d4
	add.w		#8-1,d3
	add.w		#32-1,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#2,d3
	subq		#2,d4
	addq		#1,d1
	addq		#1,d2
	jsr		DRAW_PHYS_BLOCK
	jsr		SHOW_MOUSE
	rts

Convert_RGB_2_SLIDER:
	jsr		Init_DSP_RGB_HSV
	tst.b		TRUE_FLAG
	beq.s		.go
	move.w	TEMP_RED,d1
	move.w	TEMP_GRN,d2
	move.w	TEMP_BLU,d3
	bra.s		.tr
.go	move.w	FG_INDEX,d0
	move.b	(INDEX_TABLE.l,d0.w),d0
	lea		(1+COLOURS.l,d0.w*4),a0
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
.tr	cmp.w		#1<<Bit_RGB_RGB,RGB_BITS
	beq.s		.rgb
	cmp.w		#1<<Bit_RGB_HSV,RGB_BITS
	beq.s		.hsv
.cmy	neg.w		d1
	neg.w		d2
	neg.w		d3
	add.w		#255,d1
	add.w		#255,d2
	add.w		#255,d3
	move.w	d1,CURRENT_REDPOS
	move.w	d2,CURRENT_GRNPOS
	move.w	d3,CURRENT_BLUPOS
	bra		.done
.rgb	move.w	d1,CURRENT_REDPOS
	move.w	d2,CURRENT_GRNPOS
	move.w	d3,CURRENT_BLUPOS
	bra.s		.done
.hsv	dspwrite	#1
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	dspread	d3
	dspread	d2
	dspread	d1
	subq		#1,d2
	bpl.s		.ok
	moveq		#0,d2
.ok	and.w		#255,d1
	and.w		#255,d2
	and.w		#255,d3
	move.w	d1,CURRENT_REDPOS
	move.w	d2,CURRENT_GRNPOS
	move.w	d3,CURRENT_BLUPOS
.done	jsr		Update_rgb_sliders
	rts

Zone_red_slider:
	move.w	#-1,OXD
	move.w	#RedBarXmin,SLIDER_XMIN
	move.w	#RedBarXmax,SLIDER_XMAX
	move.w	#RedBarYmin,SLIDER_YMIN
	move.w	#RedBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_REDPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_REDPOS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_REDPOS
	bsr		Update_red_bar
	bsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	rts

Zone_grn_slider:
	move.w	#-1,OXD
	move.w	#GrnBarXmin,SLIDER_XMIN
	move.w	#GrnBarXmax,SLIDER_XMAX
	move.w	#GrnBarYmin,SLIDER_YMIN
	move.w	#GrnBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_GRNPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_GRNPOS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_GRNPOS
	bsr		Update_grn_bar
	bsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	rts

Zone_blu_slider:
	move.w	#-1,OXD
	move.w	#BluBarXmin,SLIDER_XMIN
	move.w	#BluBarXmax,SLIDER_XMAX
	move.w	#BluBarYmin,SLIDER_YMIN
	move.w	#BluBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BLUPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_BLUPOS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_BLUPOS
	bsr		Update_blu_bar
	bsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	rts

Zone_hue1_slider:
	move.w	#-1,OXD
	move.w	#Hue1BarXmin,SLIDER_XMIN
	move.w	#Hue1BarXmax,SLIDER_XMAX
	move.w	#Hue1BarYmin,SLIDER_YMIN
	move.w	#Hue1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_HUE1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_HUE1POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_HUE1POS
	bsr		Update_hue1_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_sat1_slider:
	move.w	#-1,OXD
	move.w	#Sat1BarXmin,SLIDER_XMIN
	move.w	#Sat1BarXmax,SLIDER_XMAX
	move.w	#Sat1BarYmin,SLIDER_YMIN
	move.w	#Sat1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_SAT1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_SAT1POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_SAT1POS
	bsr		Update_sat1_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_bri1_slider:
	move.w	#-1,OXD
	move.w	#Bri1BarXmin,SLIDER_XMIN
	move.w	#Bri1BarXmax,SLIDER_XMAX
	move.w	#Bri1BarYmin,SLIDER_YMIN
	move.w	#Bri1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BRI1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_BRI1POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_BRI1POS
	bsr		Update_bri1_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_hue2_slider:
	move.w	#-1,OXD
	move.w	#Hue2BarXmin,SLIDER_XMIN
	move.w	#Hue2BarXmax,SLIDER_XMAX
	move.w	#Hue2BarYmin,SLIDER_YMIN
	move.w	#Hue2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_HUE2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_HUE2POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_HUE2POS
	bsr		Update_hue2_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_sat2_slider:
	move.w	#-1,OXD
	move.w	#Sat2BarXmin,SLIDER_XMIN
	move.w	#Sat2BarXmax,SLIDER_XMAX
	move.w	#Sat2BarYmin,SLIDER_YMIN
	move.w	#Sat2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_SAT2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_SAT2POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_SAT2POS
	bsr		Update_sat2_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_bri2_slider:
	move.w	#-1,OXD
	move.w	#Bri2BarXmin,SLIDER_XMIN
	move.w	#Bri2BarXmax,SLIDER_XMAX
	move.w	#Bri2BarYmin,SLIDER_YMIN
	move.w	#Bri2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BRI2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_BRI2POS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_BRI2POS
	bsr		Update_bri2_bar
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Zone_val_slider:
	move.w	#-1,OXD
	move.w	#ValBarXmin,SLIDER_XMIN
	move.w	#ValBarXmax,SLIDER_XMAX
	move.w	#ValBarYmin,SLIDER_YMIN
	move.w	#ValBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_VALPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_VALPOS,MAXIMUM_BARSIZE
	jsr		Init_DSP_RGB_HSV
.lp	bsr		Get_hslide_pos
	cmp.w		OXD,d0
	beq		.skip
	move.w	d0,OXD	
	move.w	d0,CURRENT_VALPOS
	bsr		Update_val_slider
.skip	cmp.b		#left_button,BUTTONS
	beq		.lp
	rts

Convert_bars_2_col:
	cmp.w		#1<<Bit_RGB_RGB,RGB_BITS
	beq		.rgb
	cmp.w		#1<<Bit_RGB_CMY,RGB_BITS
	beq.s		.cmy
.hsv	move.w	CURRENT_REDPOS,d1
	move.w	CURRENT_GRNPOS,d2
	move.w	CURRENT_BLUPOS,d3
	dspwrite	#0
	dspwrite	d3
	dspwrite	d2
	dspwrite	d1
	dspread	d1
	dspread	d2
	dspread	d3
	bra.s		.done
.cmy	move.w	CURRENT_REDPOS,d1
	move.w	CURRENT_GRNPOS,d2
	move.w	CURRENT_BLUPOS,d3
	neg.w		d1
	neg.w		d2
	neg.w		d3
	add.w		#255,d1
	add.w		#255,d2
	add.w		#255,d3
	bra.s		.done
.rgb	move.w	CURRENT_REDPOS,d1
	move.w	CURRENT_GRNPOS,d2
	move.w	CURRENT_BLUPOS,d3
.done	tst.b		TRUE_FLAG
	beq.s		.go
	move.w	d1,TEMP_RED
	move.w	d2,TEMP_GRN
	move.w	d3,TEMP_BLU
	jsr		Draw_sample_zone
	bra.s		.end
.go	swap		d1
	ror.w		#8,d2
	move.w	d2,d1
	move.b	d3,d1
	move.w	FG_INDEX,d0
	move.b	(INDEX_TABLE.l,d0),d0
	and.l		COLMASK,d1
	move.l	d1,(COLOURS.l,d0.w*4)
	jsr		Update_palette
.end	st		PALETTE_CHANGED
	st		MENUPAL_CHANGED
	rts

Update_rgb_sliders:
	bsr		Update_red_bar
	bsr		Update_grn_bar
	bsr		Update_blu_bar
	rts

Update_source_sliders:
	bsr		Update_hue1_bar
	bsr		Update_sat1_bar
	bsr		Update_bri1_bar
	rts

Update_dest_sliders:
	bsr		Update_hue2_bar
	bsr		Update_sat2_bar
	bsr		Update_bri2_bar
	rts
	

RGB_btxt:
	dc.b		RED_abbrev,0
TWEEN_DATA:
	dc.b		FRM_abbrev,0
TWEEN_LOOKUP:
	dc.b		FRM_abbrev,SEG_abbrev,ALL_abbrev
	even

Update_red_bar:
	move.l	#RGB_btxt,hslide_text
	move.w	#RedBarXmin,SLIDER_XMIN
	move.w	#RedBarXmax,SLIDER_XMAX
	move.w	#RedBarYmin,SLIDER_YMIN
	move.w	#RedBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_REDPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_REDPOS,MAXIMUM_BARSIZE
	jsr		HIDE_MOUSE
	move.w	RGB_BITS,d0
	cmp.w		#1<<Bit_RGB_RGB,d0
	bne.s		.nrgb
	move.b	#RED_abbrev,RGB_btxt
	bra.s		.go
.nrgb	cmp.w		#1<<Bit_RGB_CMY,d0
	bne.s		.ncmy
	move.b	#CYN_abbrev,RGB_btxt
	bra.s		.go
.ncmy	move.b	#HUE_abbrev,RGB_btxt
.go	bsr		Update_hslide
	move.w	SLIDER_XMIN,d1
	add.w		#127,d1
	move.w	d1,d3
	add.w		#21,d3
	move.w	SLIDER_YMIN,d2
	move.w	d2,d4
	addq		#8,d4
	jsr		Raised_bar
	move.w	CURRENT_REDPOS,d0
	movem.w	d1-d4,-(sp)
	cmp.w		#1<<Bit_RGB_CMY,RGB_BITS
	beq.s		.int
	cmp.w		#1<<Bit_RGB_RGB,RGB_BITS
	bne.s		.skp
	move.w	#iface_red,CHAR_COL
.int	and.b		COLMASK+1,d0
	ext.l		d0
	divu		COLSHIFT,d0
.skp	moveq		#3,d1
	jsr		NUM2ASCII_LZ
	movem.w	(sp)+,d1-d4
	lea		NUM_TEXT+1,a0
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts
	
Update_grn_bar:
	move.l	#RGB_btxt,hslide_text
	move.w	#GrnBarXmin,SLIDER_XMIN
	move.w	#GrnBarXmax,SLIDER_XMAX
	move.w	#GrnBarYmin,SLIDER_YMIN
	move.w	#GrnBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_GRNPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_GRNPOS,MAXIMUM_BARSIZE
	jsr		HIDE_MOUSE
	move.w	RGB_BITS,d0
	cmp.w		#1<<Bit_RGB_RGB,d0
	bne.s		.nrgb
	move.b	#GRN_abbrev,RGB_btxt
	bra.s		.go
.nrgb	cmp.w		#1<<Bit_RGB_CMY,d0
	bne.s		.ncmy
	move.b	#MAG_abbrev,RGB_btxt
	bra.s		.go
.ncmy	move.b	#SAT_abbrev,RGB_btxt
.go	bsr		Update_hslide
	move.w	SLIDER_XMIN,d1
	add.w		#127,d1
	move.w	d1,d3
	add.w		#21,d3
	move.w	SLIDER_YMIN,d2
	move.w	d2,d4
	addq		#8,d4
	jsr		Raised_bar
	move.w	CURRENT_GRNPOS,d0
	movem.w	d1-d4,-(sp)
	cmp.w		#1<<Bit_RGB_CMY,RGB_BITS
	beq.s		.int
	cmp.w		#1<<Bit_RGB_RGB,RGB_BITS
	bne.s		.skp
	move.w	#iface_green,CHAR_COL
.int	and.b		COLMASK+2,d0
	ext.l		d0
	divu		COLSHIFT,d0
.skp	moveq		#3,d1
	jsr		NUM2ASCII_LZ
	movem.w	(sp)+,d1-d4
	lea		NUM_TEXT+1,a0
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts

Update_blu_bar:
	move.l	#RGB_btxt,hslide_text
	move.w	#BluBarXmin,SLIDER_XMIN
	move.w	#BluBarXmax,SLIDER_XMAX
	move.w	#BluBarYmin,SLIDER_YMIN
	move.w	#BluBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BLUPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_BLUPOS,MAXIMUM_BARSIZE
	jsr		HIDE_MOUSE
	move.w	RGB_BITS,d0
	cmp.w		#1<<Bit_RGB_RGB,d0
	bne.s		.nrgb
	move.b	#BLU_abbrev,RGB_btxt
	bra.s		.go
.nrgb	cmp.w		#1<<Bit_RGB_CMY,d0
	bne.s		.ncmy
	move.b	#YEL_abbrev,RGB_btxt
	bra.s		.go
.ncmy	move.b	#BLU_abbrev,RGB_btxt
.go	bsr		Update_hslide
	move.w	SLIDER_XMIN,d1
	add.w		#127,d1
	move.w	d1,d3
	add.w		#21,d3
	move.w	SLIDER_YMIN,d2
	move.w	d2,d4
	addq		#8,d4
	jsr		Raised_bar
	move.w	CURRENT_BLUPOS,d0
	movem.w	d1-d4,-(sp)
	cmp.w		#1<<Bit_RGB_CMY,RGB_BITS
	beq.s		.int
	cmp.w		#1<<Bit_RGB_RGB,RGB_BITS
	bne.s		.skp
	move.w	#iface_blue,CHAR_COL
.int	and.b		COLMASK+3,d0
	ext.l		d0
	divu		COLSHIFT,d0
.skp	moveq		#3,d1
	jsr		NUM2ASCII_LZ
	movem.w	(sp)+,d1-d4
	lea		NUM_TEXT+1,a0
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts

Update_val_slider:
	move.b	#'%',RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#ValBarXmin,SLIDER_XMIN
	move.w	#ValBarXmax,SLIDER_XMAX
	move.w	#ValBarYmin,SLIDER_YMIN
	move.w	#ValBarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_VALPOS,CURRENT_BARSIZE
	move.w	MAXIMUM_VALPOS,MAXIMUM_BARSIZE
	jsr		HIDE_MOUSE
	bsr		Update_hslide
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts

Update_hue1_bar:
	move.b	#HUE_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Hue1BarXmin,SLIDER_XMIN
	move.w	#Hue1BarXmax,SLIDER_XMAX
	move.w	#Hue1BarYmin,SLIDER_YMIN
	move.w	#Hue1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_HUE1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_HUE1POS,MAXIMUM_BARSIZE
	bra		Update_perc_slider

Update_hue2_bar:
	move.b	#HUE_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Hue2BarXmin,SLIDER_XMIN
	move.w	#Hue2BarXmax,SLIDER_XMAX
	move.w	#Hue2BarYmin,SLIDER_YMIN
	move.w	#Hue2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_HUE2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_HUE2POS,MAXIMUM_BARSIZE
	jsr		Draw_hsv2_zone
	bra		Update_hsv_slider

Update_sat1_bar:
	move.b	#SAT_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Sat1BarXmin,SLIDER_XMIN
	move.w	#Sat1BarXmax,SLIDER_XMAX
	move.w	#Sat1BarYmin,SLIDER_YMIN
	move.w	#Sat1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_SAT1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_SAT1POS,MAXIMUM_BARSIZE
	bra		Update_perc_slider

Update_sat2_bar:
	move.b	#SAT_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Sat2BarXmin,SLIDER_XMIN
	move.w	#Sat2BarXmax,SLIDER_XMAX
	move.w	#Sat2BarYmin,SLIDER_YMIN
	move.w	#Sat2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_SAT2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_SAT2POS,MAXIMUM_BARSIZE
	jsr		Draw_hsv2_zone
	bra		Update_hsv_slider

Update_bri1_bar:
	move.b	#BRI_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Bri1BarXmin,SLIDER_XMIN
	move.w	#Bri1BarXmax,SLIDER_XMAX
	move.w	#Bri1BarYmin,SLIDER_YMIN
	move.w	#Bri1BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BRI1POS,CURRENT_BARSIZE
	move.w	MAXIMUM_BRI1POS,MAXIMUM_BARSIZE
	bra		Update_perc_slider

Update_bri2_bar:
	move.b	#BRI_abbrev,RGB_btxt
	move.l	#RGB_btxt,hslide_text
	move.w	#Bri2BarXmin,SLIDER_XMIN
	move.w	#Bri2BarXmax,SLIDER_XMAX
	move.w	#Bri2BarYmin,SLIDER_YMIN
	move.w	#Bri2BarYmax,SLIDER_YMAX
	move.w	#9,SLIDER_WIDTH
	move.w	CURRENT_BRI2POS,CURRENT_BARSIZE
	move.w	MAXIMUM_BRI2POS,MAXIMUM_BARSIZE
	jsr		Draw_hsv2_zone

Update_hsv_slider:
	jsr		HIDE_MOUSE
	bsr		Update_hslide
	move.w	SLIDER_XMIN,d1
	add.w		#127,d1
	move.w	d1,d3
	add.w		#21,d3
	move.w	SLIDER_YMIN,d2
	move.w	d2,d4
	addq		#8,d4
	move.w	#iface_gold,d0
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	jsr		DRAW_MENU_BLOCK
	move.w	CURRENT_BARSIZE,d0
	movem.w	d1-d4,-(sp)
	moveq		#3,d1
	jsr		NUM2ASCII_LZ
	movem.w	(sp)+,d1-d4
	lea		NUM_TEXT+1,a0
	move.w	#iface_dgold,CHAR_COL
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts

Update_perc_slider:
	jsr		HIDE_MOUSE
	bsr		Update_hslide
	move.w	SLIDER_XMIN,d1
	add.w		#127,d1
	move.w	d1,d3
	add.w		#27,d3
	move.w	SLIDER_YMIN,d2
	move.w	d2,d4
	addq		#8,d4
	move.w	#iface_gold,d0
	addq		#1,d1
	addq		#1,d2
	subq		#1,d3
	subq		#1,d4
	jsr		DRAW_MENU_BLOCK
	move.w	CURRENT_BARSIZE,d7
	move.w	MAXIMUM_BARSIZE,d0
	mulu		#100,d7
	divu		d0,d7
	move.w	d7,d0
	ext.l		d0
	movem.w	d1-d4,-(sp)
	moveq		#3,d1
	jsr		NUM2ASCII_LZ
	move.b	#'%',(a1)+
	clr.b		(a1)
	movem.w	(sp)+,d1-d4
	lea		NUM_TEXT+1,a0
	move.w	#iface_dgold,CHAR_COL
	jsr		centre_justify
	move.w	#iface_grey,CHAR_COL
	jsr		SHOW_MOUSE
	rts
	
	IFD		SNAPCODE

SNAP_VEC:
	st		TAKE_SNAP
	rts
	
SNAPSHOT:
	tst.b		TAKE_SNAP
	beq.s		.rts
	sf		TAKE_SNAP		
	tst.b		TRUE_FLAG
	bne.s		.true
.rts	rts
.true	move.b	#$12,$fffffc02.w
	lea		SNAPNAME,a0
	jsr		CreateFile
	tst.l		d0
	bmi		.err
	move.w	d0,SNAP_HANDLE
	move.w	#320,d1
	move.w	#230,d2
	xresfactor	d1
	yresfactor	d2
	ror.w		#8,d1
	ror.w		#8,d2
	move.w	d1,TGA+12
	move.w	d2,TGA+14
	lea		TGA,a0
	move.l	#18,d1
	move.w	SNAP_HANDLE,d0
	jsr		WriteFile
	move.w	TGA+12,d1
	move.w	TGA+14,d2
	ror.w		#8,d1
	ror.w		#8,d2
	move.l	PHYS_SCR,a0
	subq		#1,d1
	subq		#1,d2
.ylp	push.w	d2
	push.w	d1
	move.w	d1,d4
	lea		TGA+18,a1
.xlp	move.w	(a0)+,d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.b	d3,(a1)+
	move.b	d2,(a1)+
	move.b	d1,(a1)+
	dbra		d4,.xlp
	push.l	a0
	lea		TGA+18,a0
	move.w	SNAP_HANDLE,d0
	move.w	#320*3,d1
	xresfactor	d1
	ext.l		d1
	jsr		WriteFile
	pop.l		a0
	pop.w		d1
	pop.w		d2
	dbra		d2,.ylp
	move.w	SNAP_HANDLE,d0
	jsr		CloseFile
	addq.b	#1,SNAPCOUNT
.err	move.b	#$8,$fffffc02.w
	rts

TAKE_SNAP:		ds.w		1
SNAP_HANDLE:	ds.w		1
SNAPNAME:		dc.b		"d:\snap"
SNAPCOUNT:		dc.b		"1.tga",0
			even
TGA:			incbin	"\apex\inc\tga.dat"
			ds.b		3*640
			even

	ENDC

;	ifd		protection
;	incbin	inc\scorpion.key
;	ds.b		apexdata_len
;	endc

	INFO_POINT

*-----------------------------------------------------------*
*	File I/O routines							*
*-----------------------------------------------------------*
	include	includes\fileio.s
*-----------------------------------------------------------*

*-----------------------------------------------------------*
*	Colour reduction engine						*
*-----------------------------------------------------------*
	include	includes\reduce.s
*-----------------------------------------------------------*
	include	includes\matrix.s

*-----------------------------------------------------------*
*	Image reading routines						*
*-----------------------------------------------------------*
	include	readers\readgif2.s
*-----------------------------------------------------------*
	include	readers\readflc.s
*-----------------------------------------------------------*
	IFD		READERS
*-----------------------------------------------------------*
	include	readers\readseq.s
*-----------------------------------------------------------*
	include	readers\readpc1.s
*-----------------------------------------------------------*
	include	readers\readlbm.s
*-----------------------------------------------------------*
	include	readers\readani.s
*-----------------------------------------------------------*
	include	readers\readpcs.s
*-----------------------------------------------------------*
	include	readers\readtga.s
*-----------------------------------------------------------*
	include	readers\readmtv.s
*-----------------------------------------------------------*
	include	readers\readjpg.s
*-----------------------------------------------------------*
	ENDC

;	OPT	O-,W-

*-----------------------------------------------------------*
*	Image writing routines						*
*-----------------------------------------------------------*
	IFD		WRITERS
*-----------------------------------------------------------*
;	include	writers\writegif.s
	include	writers\gif89ae.s
*-----------------------------------------------------------*
	include	writers\writeflc.s
*-----------------------------------------------------------*
	ENDC
	
*-----------------------------------------------------------*
*	SYSTEM libraries							*
*-----------------------------------------------------------*
	include	includes\dropdown.s
*-----------------------------------------------------------*
	include	includes\cookie.s
*-----------------------------------------------------------*
	include	includes\dsprout.s
*-----------------------------------------------------------*

*-----------------------------------------------------------*
*	Special graphics routines					*
*-----------------------------------------------------------*
	IFD		FINALGFX
*-----------------------------------------------------------*
	include	graphics\gourad.s
*-----------------------------------------------------------*
	include	graphics\texture.s
*-----------------------------------------------------------*
	include	graphics\calamus.s
*-----------------------------------------------------------*
	ENDC

	IFD		INTRO
	include	includes\intro.s
	ENDC
	
*-----------------------------------------------------------------------*
*	ICON DATA DEFINITION								*
*-----------------------------------------------------------------------*

icon_num	set	1

		data
FUNCTION_TABLE:
		text

*-----------------------------------------------------------------------*
*	Menu icon definitions								*
*-----------------------------------------------------------------------*

ICON_DEFINITIONS:
	include	includes\icons.s

*-----------------------------------------------------------------------*
*	Dialog box definitions								*
*-----------------------------------------------------------------------*

WINDOW_ICONS:
	ifeq		language-english
	include	language\dialogse.s
	endc
	ifeq		language-french
	include	language\dialogsf.s
	endc
	ifeq		language-german
	include	language\dialogsg.s
	endc

*-----------------------------------------------------------------------*
*	Dialog button code								*
*-----------------------------------------------------------------------*
	
MATCODE:	ds.w	1

Draw_hsv1_zone:
	pushall
	jsr		HIDE_MOUSE
	move.w	#Hue1BarXmax+72+1-17,d1
	move.w	#Hue1BarYmin+1+1,d2
	move.w	#Hue1BarXmax+72+24-2-17-3,d3
	move.w	#Hue1BarYmin+1+35-2,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#2,d3
	subq		#2,d4
	addq		#1,d1
	addq		#1,d2
	move.w	FG_COLOUR,d0
	jsr		DRAW_PHYS_BLOCK
	jsr		SHOW_MOUSE
	popall
	rts

Adjust_hsv2_sliders:
	pushall
	jsr		Init_DSP_RGB_HSV
	move.w	FG_COLOUR,d0
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	dspwrite	#1
	dspwrite	d1
	dspwrite	d2
	dspwrite	d3
	dspread	d3
	dspread	d2
	dspread	d1
	move.w	d1,CURRENT_HUE2POS
	move.w	d2,CURRENT_SAT2POS
	move.w	d3,CURRENT_BRI2POS	
	popall
	rts

Draw_hsv2_zone:
	pushall
	jsr		HIDE_MOUSE
	jsr		Init_DSP_RGB_HSV
	move.w	CURRENT_HUE2POS,d1
	move.w	CURRENT_SAT2POS,d2
	move.w	CURRENT_BRI2POS,d3
	dspwrite	#0
	move.w	#255,d7
	move.w	ENAB_BITS,d0
	move.w	d0,d6
	and.w		#1<<Bit_ENAB_HUE,d6
	bne.s		.ok1
	move.w	d7,d1
.ok1	move.w	d0,d6
	and.w		#1<<Bit_ENAB_SAT,d6
	bne.s		.ok2
	move.w	d7,d2
.ok2	move.w	d0,d6
	and.w		#1<<Bit_ENAB_BRI,d6
	bne.s		.ok3
	move.w	d7,d3
.ok3	dspwrite	d3
	dspwrite	d2
	dspwrite	d1
	dspread	d1
	dspread	d2
	dspread	d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w	#Hue2BarXmax+72+1-20,d1
	move.w	#Hue2BarYmin+1+1,d2
	move.w	#Hue2BarXmax+72+24-2-3-20,d3
	move.w	#Hue2BarYmin+1+35-2,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	add.w		x_factor,d3
	add.w		y_factor,d4
	subq		#2,d3
	subq		#2,d4
	addq		#1,d1
	addq		#1,d2
	jsr		DRAW_PHYS_BLOCK
	jsr		SHOW_MOUSE
	popall
	rts

Zone_pick_hsv1:
	pushall
	move.w	FG_COLOUR,MASK_COLOUR
	jsr		HIDE_MOUSE
	jsr		Draw_hsv1_zone
	jsr		SHOW_MOUSE
	popall
	rts

Zone_pick_hsv2:
	pushall
	jsr		HIDE_MOUSE
	jsr		Adjust_hsv2_sliders
	jsr		Update_dest_sliders
	jsr		Draw_hsv2_zone
	jsr		SHOW_MOUSE
	popall
	rts
	
MASK_COLOUR:	ds.w	1

increment_word:
	move.w	(a0),d0
	move.w	(a1),d1
	addq		#1,d0
	cmp.w		d1,d0
	ble.s		.ok
	move.w	d1,d0
.ok	move.w	d0,(a0)
	rts

decrement_word:
	subq		#1,(a0)
	bpl.s		.ok
	clr.w		(a0)
.ok	rts

Zone_red_up:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_REDPOS,a0
	lea		MAXIMUM_REDPOS,a1
	bsr		increment_word
	jsr		Update_red_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_REDPOS,a0
	lea		MAXIMUM_REDPOS,a1
	bsr		increment_word
	jsr		Update_red_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts
Zone_red_dn:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_REDPOS,a0
	bsr		decrement_word
	jsr		Update_red_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_REDPOS,a0
	bsr		decrement_word
	jsr		Update_red_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts
Zone_grn_up:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_GRNPOS,a0
	lea		MAXIMUM_GRNPOS,a1
	bsr		increment_word
	jsr		Update_grn_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_GRNPOS,a0
	lea		MAXIMUM_GRNPOS,a1
	bsr		increment_word
	jsr		Update_grn_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts
Zone_grn_dn:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_GRNPOS,a0
	bsr		decrement_word
	jsr		Update_grn_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_GRNPOS,a0
	bsr		decrement_word
	jsr		Update_grn_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts
Zone_blu_up:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_BLUPOS,a0
	lea		MAXIMUM_BLUPOS,a1
	bsr		increment_word
	jsr		Update_blu_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BLUPOS,a0
	lea		MAXIMUM_BLUPOS,a1
	bsr		increment_word
	jsr		Update_blu_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts
Zone_blu_dn:
	jsr		Press_groove
	jsr		Init_DSP_RGB_HSV
	lea		CURRENT_BLUPOS,a0
	bsr		decrement_word
	jsr		Update_blu_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BLUPOS,a0
	bsr		decrement_word
	jsr		Update_blu_bar
	jsr		Convert_bars_2_col
	jsr		Get_colours
	jsr		HIDE_MOUSE
	jsr		Draw_sample_zone
	jsr		SHOW_MOUSE
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		HIDE_MOUSE
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
	jsr		Release_groove
	rts

Zone_hue1_up:
	jsr		Press_groove
	lea		CURRENT_HUE1POS,a0
	lea		MAXIMUM_HUE1POS,a1
	bsr		increment_word
	jsr		Update_hue1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_HUE1POS,a0
	lea		MAXIMUM_HUE1POS,a1
	bsr		increment_word
	jsr		Update_hue1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_hue2_up:
	jsr		Press_groove
	lea		CURRENT_HUE2POS,a0
	lea		MAXIMUM_HUE2POS,a1
	bsr		increment_word
	jsr		Update_hue2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_HUE2POS,a0
	lea		MAXIMUM_HUE2POS,a1
	bsr		increment_word
	jsr		Update_hue2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_sat1_up:
	jsr		Press_groove
	lea		CURRENT_SAT1POS,a0
	lea		MAXIMUM_SAT1POS,a1
	bsr		increment_word
	jsr		Update_sat1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_SAT1POS,a0
	lea		MAXIMUM_SAT1POS,a1
	bsr		increment_word
	jsr		Update_sat1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_sat2_up:
	jsr		Press_groove
	lea		CURRENT_SAT2POS,a0
	lea		MAXIMUM_SAT2POS,a1
	bsr		increment_word
	jsr		Update_sat2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_SAT2POS,a0
	lea		MAXIMUM_SAT2POS,a1
	bsr		increment_word
	jsr		Update_sat2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_bri1_up:
	jsr		Press_groove
	lea		CURRENT_BRI1POS,a0
	lea		MAXIMUM_BRI1POS,a1
	bsr		increment_word
	jsr		Update_bri1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BRI1POS,a0
	lea		MAXIMUM_BRI1POS,a1
	bsr		increment_word
	jsr		Update_bri1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_bri2_up:
	jsr		Press_groove
	lea		CURRENT_BRI2POS,a0
	lea		MAXIMUM_BRI2POS,a1
	bsr		increment_word
	jsr		Update_bri2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BRI2POS,a0
	lea		MAXIMUM_BRI2POS,a1
	bsr		increment_word
	jsr		Update_bri2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts

Zone_hue1_dn:
	jsr		Press_groove
	lea		CURRENT_HUE1POS,a0
	lea		MAXIMUM_HUE1POS,a1
	bsr		decrement_word
	jsr		Update_hue1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_HUE1POS,a0
	lea		MAXIMUM_HUE1POS,a1
	bsr		decrement_word
	jsr		Update_hue1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_hue2_dn:
	jsr		Press_groove
	lea		CURRENT_HUE2POS,a0
	lea		MAXIMUM_HUE2POS,a1
	bsr		decrement_word
	jsr		Update_hue2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_HUE2POS,a0
	lea		MAXIMUM_HUE2POS,a1
	bsr		decrement_word
	jsr		Update_hue2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_sat1_dn:
	jsr		Press_groove
	lea		CURRENT_SAT1POS,a0
	lea		MAXIMUM_SAT1POS,a1
	bsr		decrement_word
	jsr		Update_sat1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_SAT1POS,a0
	lea		MAXIMUM_SAT1POS,a1
	bsr		decrement_word
	jsr		Update_sat1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_sat2_dn:
	jsr		Press_groove
	lea		CURRENT_SAT2POS,a0
	lea		MAXIMUM_SAT2POS,a1
	bsr		decrement_word
	jsr		Update_sat2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_SAT2POS,a0
	lea		MAXIMUM_SAT2POS,a1
	bsr		decrement_word
	jsr		Update_sat2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_bri1_dn:
	jsr		Press_groove
	lea		CURRENT_BRI1POS,a0
	lea		MAXIMUM_BRI1POS,a1
	bsr		decrement_word
	jsr		Update_bri1_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BRI1POS,a0
	lea		MAXIMUM_BRI1POS,a1
	bsr		decrement_word
	jsr		Update_bri1_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts
Zone_bri2_dn:
	jsr		Press_groove
	lea		CURRENT_BRI2POS,a0
	lea		MAXIMUM_BRI2POS,a1
	bsr		decrement_word
	jsr		Update_bri2_bar
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_BRI2POS,a0
	lea		MAXIMUM_BRI2POS,a1
	bsr		decrement_word
	jsr		Update_bri2_bar
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts

Zone_val_up:
	jsr		Press_groove
	lea		CURRENT_VALPOS,a0
	lea		MAXIMUM_VALPOS,a1
	bsr		increment_word
	jsr		Update_val_slider
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_VALPOS,a0
	lea		MAXIMUM_VALPOS,a1
	bsr		increment_word
	jsr		Update_val_slider
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts

Zone_val_dn:
	jsr		Press_groove
	lea		CURRENT_VALPOS,a0
	lea		MAXIMUM_VALPOS,a1
	bsr		decrement_word
	jsr		Update_val_slider
	move.w	#10,TIMER
.lp	tst.b		BUTTONS
	beq.s		.done
	tst.w		TIMER
	bne.s		.lp
.lp2	lea		CURRENT_VALPOS,a0
	lea		MAXIMUM_VALPOS,a1
	bsr		decrement_word
	jsr		Update_val_slider
	delay		1
	tst.b		BUTTONS
	bne.s		.lp2
.done	jsr		Release_groove
	rts

Zone_pick_y:
	tst.b		TRUE_FLAG
	beq		.rts
	jsr		HIDE_MOUSE
	cmp.b		#left_button,ICON_BUTTON
	beq.s		.go
	move.w	TEMP_RED,d1
	move.w	TEMP_GRN,d2
	move.w	TEMP_BLU,d3
	bfins		d1,d0{16:8}
	bfins		d2,d0{21:8}
	bfins		d3,d0{27:8}
	move.w	d0,TEMP_LUMA
	jsr		Draw_LUMA_zone
	bra.s		.done
.go	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	jsr		READ_PHYS_PIXEL
	move.w	d0,FG_COLOUR
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.w	d1,TEMP_RED
	move.w	d2,TEMP_GRN
	move.w	d3,TEMP_BLU
	jsr		Draw_sample_zone
	jsr		Convert_RGB_2_SLIDER
.done	jsr		SHOW_MOUSE
.rts	rts

Zone_pick_c:
	tst.b		TRUE_FLAG
	beq		.rts
	jsr		HIDE_MOUSE
	move.w	FG_INDEX,d0
	cmp.b		#left_button,ICON_BUTTON
	beq.s		.go
	move.w	BG_INDEX,d0
.go	move.w	TEMP_RED,d1
	move.w	TEMP_GRN,d2
	move.w	TEMP_BLU,d3
	swap		d1
	move.b	d2,d1
	ror.w		#8,d1
	move.b	d3,d1
	move.b	(INDEX_TABLE.l,d0.w),d0
	and.l		COLMASK,d1
	move.l	d1,(COLOURS.l,d0.w*4)
	jsr		Get_colours
	jsr		Update_palette_zone
	jsr		SHOW_MOUSE
.rts	rts

Zone_pick_uv:
	tst.b		TRUE_FLAG
	beq		.rts
	jsr		HIDE_MOUSE
	move.w	BUTTON_X,d1
	move.w	BUTTON_Y,d2
	jsr		READ_PHYS_PIXEL
	move.w	d0,FG_COLOUR
	bfextu	d0{16:8},d1
	bfextu	d0{21:8},d2
	bfextu	d0{27:8},d3
	and.w		#%11111000,d1
	and.w		#%11111100,d2
	and.w		#%11111000,d3
	move.w	d0,TEMP_LUMA
	move.w	d1,TEMP_RED
	move.w	d2,TEMP_GRN
	move.w	d3,TEMP_BLU
	jsr		Draw_sample_zone
	jsr		Convert_RGB_2_SLIDER
	jsr		Draw_LUMA_zone
	jsr		SHOW_MOUSE
.rts	rts

TEMP_LUMA:		ds.w	1

*-----------------------------------------------------------------------*
setup3:
*-----------------------------------------------------------------------*
*	Program initialisation								*
*-----------------------------------------------------------------------*
	jsr		Init_Y_table
	jsr		Init_vectors
*-----------------------------------------------------------------------*
	jsr		get_matrix
	tst.b		matrix_flag
	seq		expose_flag
	IFND		VIDEO
	sf		matrix_flag
	sf		expose_flag
	ENDC
	jsr		init_matrix
	jsr		init_pip
*-----------------------------------------------------------------------*
	jsr		Init_mouse
	jsr		Make_scaletables
	jsr		Create_plane_table
*-----------------------------------------------------------------------*
	subq.b	#1,HOLD_VBLANK
	rts

*-----------------------------------------------------------------------*

	INFO_POINT

*-----------------------------------------------------------------------*
	
	SECTION DATA
	
*-----------------------------------------------------------------------*
*		SYSTEM FILES								*
*-----------------------------------------------------------------------*

			ifd	cutdown
MAINGFX_ID:		dc.b	"maini00.ami",0
			elseif
			ifd	preview
MAINGFX_ID:		dc.b	"maindv00.ami",0
			elseif
MAINGFX_ID:		dc.b	"main00.ami",0
			endc
			endc

GENGFX_ID:		dc.b	"gen00.ami",0
SLIDEGFX_ID:	dc.b	"slider00.ami",0
DRAWSTATION_ID:	dc.b	"draw00.ami",0
CELLSTATION_ID:	dc.b	"cell00.ami",0
COLOURSTATION_ID:	dc.b	"colour00.ami",0
VIDEOSTATION_ID:	dc.b	"video00.ami",0
PROSTATION_ID:	dc.b	"pro00.ami",0
APROCSTATION_ID:	dc.b	"aproc00.ami",0
MORPHSTATION_ID:	dc.b	"morph00.ami",0
TEXTSTATION_ID:	dc.b	"text00.ami",0
TEXTURE_ID:		dc.b	"texturex.ami",0
			even

*-----------------------------------------------------------------------*
*		GEM AES COMMUNICATION TABLE						*
*-----------------------------------------------------------------------*

vdipb:	dc.l	control,int_in,pts_in,int_out,pts_out
aespb:	dc.l	control,global,int_in,int_out,addr_in,addr_out

*-----------------------------------------------------------------------*
*		DELTA TABLE									*
*-----------------------------------------------------------------------*

WORDJUMPS:	dc.l		WD_1
		dc.l		WD_2
		dc.l		WD_3
		dc.l		WD_4
		dc.l		WD_5
		dc.l		WD_6
		dc.l		WD_7
		dc.l		WD_8
		dc.l		WD_9
		dc.l		WD_10
		dc.l		WD_11
		dc.l		WD_12
		dc.l		WD_13
		dc.l		WD_14
		dc.l		WD_15
		dc.l		WD_16

COPYJUMPS:	dc.l		WC_1
		dc.l		WC_2
		dc.l		WC_3
		dc.l		WC_4
		dc.l		WC_5
		dc.l		WC_6
		dc.l		WC_7
		dc.l		WC_8
		dc.l		WC_9
		dc.l		WC_10
		dc.l		WC_11
		dc.l		WC_12
		dc.l		WC_13
		dc.l		WC_14
		dc.l		WC_15
		dc.l		WC_16

CBJUMPS:	dc.l		CB_1
		dc.l		CB_2
		dc.l		CB_3
		dc.l		CB_4
		dc.l		CB_5
		dc.l		CB_6
		dc.l		CB_7
		dc.l		CB_8
		dc.l		CB_9
		dc.l		CB_10
		dc.l		CB_11
		dc.l		CB_12
		dc.l		CB_13
		dc.l		CB_14
		dc.l		CB_15
		dc.l		CB_16

*-----------------------------------------------------------------------*
*		STARTUP PALETTE								*
*-----------------------------------------------------------------------*

INITIAL_COLOURS:
		incbin	"inc\apex.dac"

*-----------------------------------------------------------------------*
*		MOUSE DEFINITION								*
*-----------------------------------------------------------------------*

MOUSELIST:	dc.l		MOUSEDATA+(16*15)*0
		dc.l		MOUSEDATA+(16*15)*1
		dc.l		MOUSEDATA+(16*15)*2
		dc.l		MOUSEDATA+(16*15)*3

MOUSEDATA:	incbin	"inc\mice2.dat"

*-----------------------------------------------------------------------*
*		Colour phase offsets							*
*-----------------------------------------------------------------------*

INDEX_BASE:
val			set	0
			rept	256
			dc.b	val
val			set	val+1
			endr
			dc.b	255
			dc.b	255
			dc.b	255
			even

PULSE_1			=	INDEX_BASE+0
PULSE_2			=	INDEX_BASE+2
PULSE_3			=	INDEX_BASE+1
PULSE_4			=	INDEX_BASE+3

*-----------------------------------------------------------------------*
*		Dialog buttons								*
*-----------------------------------------------------------------------*

		include	includes\buttons.s


*-----------------------------------------------------------------------*
*		Keyboard shortcuts							*
*-----------------------------------------------------------------------*

		include	includes\shortcut.s

*-----------------------------------------------------------------------*
*		Preferences & support code						*
*-----------------------------------------------------------------------*

		include	includes\prefs.s

*-----------------------------------------------------------------------*
*		Additional text messages						*
*-----------------------------------------------------------------------*

Tx	set	56
Ty	set	56
Tg	set	8

		ifeq		language-english
		include	language\texte.s
		endc
		ifeq		language-french
		include	language\textf.s
		endc
		ifeq		language-german
		include	language\textg.s
		endc

rgb_text:	dc.b	27,"Y",0,069,047+rgby,"<"
		dc.b	27,"Y",0,069,061+rgby,"<"
		dc.b	27,"Y",0,069,075+rgby,"<"
		dc.b	27,"Y",0,199,047+rgby,">"
		dc.b	27,"Y",0,199,061+rgby,">"
		dc.b	27,"Y",0,199,075+rgby,">"
		dc.b	0

mask_text:	dc.b	27,"Y",0,Hue1BarXmin-15,Hue1BarYmin+4,"<"
		dc.b	27,"Y",0,Sat1BarXmin-15,Sat1BarYmin+4,"<"
		dc.b	27,"Y",0,Bri1BarXmin-15,Bri1BarYmin+4,"<"
		dc.b	27,"Y",0,Hue1BarXmax+9,Hue1BarYmin+4,">"
		dc.b	27,"Y",0,Sat1BarXmax+9,Sat1BarYmin+4,">"
		dc.b	27,"Y",0,Bri1BarXmax+9,Bri1BarYmin+4,">"
		dc.b	0

inking_text
		dc.b	27,"Y",0,ValBarXmin-15,ValBarYmin+4,"<"
		dc.b	27,"Y",0,Hue2BarXmin-15,Hue2BarYmin+4,"<"
		dc.b	27,"Y",0,Sat2BarXmin-15,Sat2BarYmin+4,"<"
		dc.b	27,"Y",0,Bri2BarXmin-15,Bri2BarYmin+4,"<"
		dc.b	27,"Y",0,ValBarXmax+9,ValBarYmin+4,">"
		dc.b	27,"Y",0,Hue2BarXmax+9,Hue2BarYmin+4,">"
		dc.b	27,"Y",0,Sat2BarXmax+9,Sat2BarYmin+4,">"
		dc.b	27,"Y",0,Bri2BarXmax+9,Bri2BarYmin+4,">"
		dc.b	0

INTRO_TEXT:
		dc.b	27,"Y",0,62,091,"  This version is registered to"
		dc.b	27,"Y",0,62,099,"  *--- The Ghost of Atari ----*"
		dc.b	0

BRUSH_COORD_TEXT:	dc.b	27,"Y",0,0,222
			dc.b	"X=      Y=      DX=      DY=",0
CUT_COORD_TEXT:	dc.b	27,"Y",0,0,222
			dc.b	"X1=      Y1=      "
			dc.b	WID_abbrev,"=      ",HIG_abbrev,"=",0
ROT_COORD_TEXT:	dc.b	27,"Y",0,0,222
			dc.b	"X=      Y=      Xø=      Yø=      Zø=",0

		INFO_POINT

*-----------------------------------------------------------------------*
*		Variables						*
*-----------------------------------------------------------------------*

GO_CODE:		dc.l	ARTS

swapmenu_id:	dc.l	DRAWSTATION_ID

PHYS_SIZE:		dc.l	phys_width*200
CANVAS_SIZE:	dc.l	phys_width*200
SCREEN_SIZE:	dc.l	phys_width*240
X_RESOLUTION:	dc.w	phys_width
Y_RESOLUTION:	dc.w	200
VIDEO_WIDTH:	dc.w	phys_width
VIDEO_HEIGHT:	dc.w	200
CANVAS_WIDTH:	dc.w	phys_width
CANVAS_HEIGHT:	dc.w	200
physwid:		dc.w	phys_width
logwid:		dc.w	phys_width
x_factor:		dc.w	1
y_factor:		dc.w	1
textgap:		dc.w	6
TRUE_FLAG:		dc.b	0
EXTEND:		dc.b	0
gensol:		dc.b	0
			even


CURRENT_HUE1POS:	dc.w	64
CURRENT_SAT1POS:	dc.w	128
CURRENT_BRI1POS:	dc.w	255
CURRENT_HUE2POS:	dc.w	128
CURRENT_SAT2POS:	dc.w	128
CURRENT_BRI2POS:	dc.w	128
CURRENT_AIRSIZE:	dc.w	20
CURRENT_AIRFLOW:	dc.w	20
CURRENT_VALPOS:	dc.w	128
CURRENT_TIME:	dc.w	1
LAST_AIRSIZE:	dc.w	20
AIRBRUSH_SIZE:	dc.w	20
AIRBRUSH_FLOW:	dc.w	20
NAIR_SIZE:		dc.w	4

CURRENT_MTHRESH:	dc.w	512
MAXIMUM_MTHRESH:	dc.w	1024

MAXIMUM_REDPOS:	dc.w	255
MAXIMUM_GRNPOS:	dc.w	255
MAXIMUM_BLUPOS:	dc.w	255
MAXIMUM_HUE1POS:	dc.w	255
MAXIMUM_SAT1POS:	dc.w	255
MAXIMUM_BRI1POS:	dc.w	255
MAXIMUM_HUE2POS:	dc.w	255
MAXIMUM_SAT2POS:	dc.w	255
MAXIMUM_BRI2POS:	dc.w	255
MAXIMUM_VALPOS:	dc.w	255
MAXIMUM_AIRSIZE:	dc.w	64-1
MAXIMUM_AIRFLOW:	dc.w	64-1
MAXIMUM_TIME:	dc.w	25-1
MAXIMUM_DIST:	dc.w	256

CURRENT_DIST:	dc.w	128
CURRENT_REDPOS:	dc.w	255
CURRENT_GRNPOS:	dc.w	255
CURRENT_BLUPOS:	dc.w	255

AIRBRUSH_HANDLE:	dc.w	-1
BLOCKTRACK_PTR	dc.l	BLOCKS
BLOCKTRACK_COUNT	dc.w	0

NEW_WIDTH:		ds.w	1	; 64
NEW_HEIGHT:		ds.w	1	; 64
Screen_Y1:		ds.w	1
Screen_Y2:		ds.w	1

BRUSH_RECORD1:	dc.l	BRUSH_TYPE
BRUSH_RECORD2:	dc.l	DUMMY_TYPE
DUMMY_TYPE:		dc.w	15
BRUSH_TYPE:		dc.w	-1

GRID_WIDTH:		dc.w	1
GRID_HEIGHT:	dc.w	1

*-----------------------------------------------------------------------*
*	Picture decoders									*
*-----------------------------------------------------------------------*

PCS_CONVERSION_TABLE:
	incbin	inc\pcs.pct

SPU_CONVERSION_TABLE:
	incbin	inc\spu.pct

*-----------------------------------------------------------------------*
*		DSP CODE									*
*-----------------------------------------------------------------------*

DSPMORPH:
			ifnd		cutdown
			incbin	"dsp\morph\morph.dsp"
			endc
DSPMORPH_E:		even

DSPTCMAP:		incbin	"dsp\texture\texture.dsp"
DSPTCMAP_E:		even

DSPDITHER:		incbin	"dsp\graphics\fsdithe2.dsp"
DSPDITHER_E:	even

DSPCSEARCH:		incbin	"dsp\graphics\findcols.dsp"
DSPCSEARCH_E:	even

DSPYUV:		incbin	"dsp\graphics\rgb_yuv.dsp"
DSPYUV_E:		even

DSPHSV:		incbin	"dsp\graphics\rgb_hsv.dsp"
DSPHSV_E:		even

DSPHSVM:		incbin	"dsp\graphics\hsvmask.dsp"
DSPHSVM_E:		even

DSPCURVE:		incbin	"dsp\graphics\bezier2.dsp"
DSPCURVE_E:		even

DSPCFN:		incbin	"dsp\graphics\cfndrive.dsp"
DSPCFN_E:		even

DSPNR:		incbin	"dsp\graphics\nr.dsp"
DSPNR_E:		even

DSPMIX:		incbin	"dsp\graphics\8bplmix.dsp"
DSPMIX_E:		even

DSP3D:		incbin	"dsp\geometry\apex3d.dsp"
DSP3D_E:		even
		
MORPHCODE_L:	=		(DSPMORPH_E-DSPMORPH)/3
DSPTCMAP_L:		=		(DSPTCMAP_E-DSPTCMAP)/3
DSPDITHER_L:	=		(DSPDITHER_E-DSPDITHER)/3
DSPCSEARCH_L:	=		(DSPCSEARCH_E-DSPCSEARCH)/3
DSPYUV_L:		=		(DSPYUV_E-DSPYUV)/3
DSPHSV_L:		=		(DSPHSV_E-DSPHSV)/3
DSPHSVM_L:		=		(DSPHSVM_E-DSPHSVM)/3
DSPCURVE_L:		=		(DSPCURVE_E-DSPCURVE)/3
DSPCFN_L:		=		(DSPCFN_E-DSPCFN)/3
DSPNR_L:		=		(DSPNR_E-DSPNR)/3
DSPMIX_L:		=		(DSPMIX_E-DSPMIX)/3
DSP3D_L:		=		(DSP3D_E-DSP3D)/3

*-----------------------------------------------------------------------*

ICONX:	incbin	"objects\icon.x"
ICONY:	incbin	"objects\icon.y"
ICONZ:	incbin	"objects\icon.z"
ICONO:	incbin	"objects\icon.obj"
		even
		
*-----------------------------------------------------------------------*
*		FONT DATA									*
*-----------------------------------------------------------------------*

MINIFONT:	incbin	"inc\apex.fnt"

*-----------------------------------------------------------------------*
*		ICON SCREENS								*
*-----------------------------------------------------------------------*

BRUSHES:	incbin	"inc\brushes1.dat"
		incbin	"inc\brushes2.dat"

*-----------------------------------------------------------------------*

SINE:		incbin	"inc\sinewave.dat"

video_modes:
		incbin	'..\grabvid\vga\vga8ll.set'
		incbin	'..\grabvid\vga\vga8lh.set'
		incbin	'..\grabvid\vga\vga8hl.set'
		incbin	'..\grabvid\vga\vga8hh.set'
		incbin	'..\grabvid\vga\vga16ll.set'
		incbin	'..\grabvid\vga\vga16lh.set'
		incbin	'..\grabvid\vga\vga16hl.set'
		incbin	'..\grabvid\vga\vga16hh.set'
		incbin	'..\grabvid\rgb50\rgb8llp.set'
		incbin	'..\grabvid\rgb50\rgb8lhp.set'
		incbin	'..\grabvid\rgb50\rgb8hlp.set'
		incbin	'..\grabvid\rgb50\rgb8hhp.set'
		incbin	'..\grabvid\rgb50\rgb16llp.set'
		incbin	'..\grabvid\rgb50\rgb16lhp.set'
		incbin	'..\grabvid\rgb50\rgb16hlp.set'
		incbin	'..\grabvid\rgb50\rgb16hhp.set'
		incbin	'..\grabvid\rgb60\rgb8lln.set'
		incbin	'..\grabvid\rgb60\rgb8lhn.set'
		incbin	'..\grabvid\rgb60\rgb8hln.set'
		incbin	'..\grabvid\rgb60\rgb8hhn.set'
		incbin	'..\grabvid\rgb60\rgb16lln.set'
		incbin	'..\grabvid\rgb60\rgb16lhn.set'
		incbin	'..\grabvid\rgb60\rgb16hln.set'
		incbin	'..\grabvid\rgb60\rgb16hhn.set'
		dc.w	-1

;		incbin	"inc\vga256.vid"
;		incbin	"inc\vgatrue.vid"
;		incbin	"inc\640x480t.vid"
;		IFD		RGBHARD
;		incbin	"inc\rgb256.vid"
;		incbin	"inc\rgbtrue.vid"
;		incbin	"inc\rgb256n.vid"
;		incbin	"inc\rgbtruen.vid"
;		ENDC

		dc.w		-1

*-----------------------------------------------------------------------*

	SECTION BSS

*-----------------------------------------------------------------------*
*	System-use variables								*
*-----------------------------------------------------------------------*

BSS_START:

;FILE_BUFFER:		ds.l	1
PRIMITIVE:			ds.l	1
DSP_XAvail:			ds.l	1
DSP_YAvail:			ds.l	1
DATA_START:			ds.l	1
DATA_SIZE:			ds.l	1
MOUSE_ADDR:			ds.l	1
FUNCTION_ADDR:		ds.l	1
OLD_FUNCTION_ADDR:	ds.l	1
MOUSE_SCR:			ds.l	1
SCALE_SCR:			ds.l	1
EDGEBUFFER_PTR:		ds.l	1
BUFFER1_PTR:		ds.l	1
MORPH_PTR:			ds.l	1
KEEP_STACK:			ds.l	1
SPLINE_ROUT:		ds.l	1
TOOLMENU_NAME:		ds.l	1
HOLD_SCR:			ds.l	1
;CANVAS_SIZE:		ds.l	1
;PHYS_SIZE:			ds.l	1
EDGEBUFFER_LIMIT:		ds.l	1
STREAM_PTR:			ds.l	1
MACRO_PLAYBACK_PTR:	ds.l	1
MACRO_RECORD_PTR:		ds.l	1
SSP:				ds.l	1
GEM_SCR:			ds.l	1
PHYS_SCR:			ds.l	1
LOG_SCR:			ds.l	1
FRAME_SCR:			ds.l	1
PACK_SCR:			ds.l	1
FRAME_MEM:			ds.l	1
COMPRESSED:			ds.l	1
OLDMPACK:			ds.l	1
OLDJPACK:			ds.l	1
OLD_KBD:			ds.l	1
radius:			ds.l	1
FONT6X6:			ds.l	1
FONT8X8:			ds.l	1
FONT8X16:			ds.l	1
COLMASK:			ds.l	1
OLD_HELP:			ds.l	1
OLD_SSP:			ds.l	1
T:				ds.l	1
LAST_MOUSE:			ds.l	1
sysfile_name:		ds.l	1
sysfile_size:		ds.l	1
sysfile_ptr:		ds.l	1
sysfile_index:		ds.l	1
OAB_SIZE:			ds.l	1
SCR_SIZE:			ds.l	1
LOG_SIZE:			ds.l	1
PACK_SIZE:			ds.l	1
FRAME_SIZE:			ds.l	1
menu_name:			ds.l	1
USER_ROUT:			ds.l	1

TFRAME:			ds.w	1
SYSFILE_HANDLE:		ds.w	1
LAST_ICON:			ds.w	1
menu_handle:		ds.w	1
MAINGFX_HANDLE:		ds.w	1
SLIDEGFX_HANDLE:		ds.w	1
GENGFX_HANDLE:		ds.w	1
SWAPGFX_HANDLE:		ds.w	1
TEXTURE_HANDLE:		ds.w	1
blkhandle:			ds.w	1
TMP_HEIGHT:			ds.w	1
TMP_WIDTH:			ds.w	1
OLD_HEIGHT:			ds.w	1
OLD_WIDTH:			ds.w	1
GRID_XSTART:		ds.w	1
GRID_XSTARTM:		ds.w	1
GRID_YSTART:		ds.w	1
GRID_YSTARTM:		ds.w	1
MAX_HANDLES:		ds.w	1
MIN_HANDLES:		ds.w	1
DESKTOP_WIDTH:		ds.w	1
DESKTOP_HEIGHT:		ds.w	1
BUTTON_X:			ds.w	1
BUTTON_Y:			ds.w	1
ICON_X:			ds.w	1
ICON_Y:			ds.w	1
LAST_BRUSH_SELECTED:	ds.w	1
BRUSH_XBASE:		ds.w	1
BRUSH_YBASE:		ds.w	1
brush_deviance:		ds.w	1
START_Y:			ds.w	1
STOP_Y:			ds.w	1
OXD:				ds.w	1
OYD:				ds.w	1
OLD_BRUSH_XBASE:		ds.w	1
OLD_BRUSH_YBASE:		ds.w	1
X_STORE:			ds.w	1
Y_STORE:			ds.w	1
MACRO_PLAY_COUNT:		ds.w	1
MACRO_RECORD_COUNT:	ds.w	1
CURPLAY:			ds.w	1
PLAYSPEED:			ds.w	1
PLAYDIR:			ds.w	1
FIRST_COLOUR:		ds.w	1
LAST_COLOUR:		ds.w	1
FG_COLOUR:			ds.w	1
BG_COLOUR:			ds.w	1
ICON_USED:			ds.w	1
SELECTED_BRUSH:		ds.w	1
;CANVAS_WIDTH:		ds.w	1
;CANVAS_HEIGHT:		ds.w	1
NEW_MODECODE:		ds.w	1
PHYS_HANDLE:		ds.w	1
LOG_HANDLE:			ds.w	1
FRAME_HANDLE:		ds.w	1
PACK_HANDLE:		ds.w	1
BUFFER1_HANDLE:		ds.w	1
BUFFER2_HANDLE:		ds.w	1
WT_NUM:			ds.w	1
OLD_X_COORD:		ds.w	1
OLD_Y_COORD:		ds.w	1
PLAY_TIMER:			ds.w	1
TIMER:			ds.w	1
palbarxgap:			ds.w	1
palbarygap:			ds.w	1
DELTA_HANDLE:		ds.w	1
DELTABACK_HANDLE:		ds.w	1
destination:		ds.w	1
NEXT_DELTAFRAME:		ds.w	1
PACK_TYPE:			ds.w	1
FRAME:			ds.w	1
BLOCK:			ds.w	1
CANWID_INDEX:		ds.w	1
CANHIG_INDEX:		ds.w	1
MINWID_INDEX:		ds.w	1
MINHIG_INDEX:		ds.w	1
FIRST_GUIDE:		ds.w	1
GUIDE_SELECTED:		ds.w	1
GUIDE_COUNT:		ds.w	1
STREAM_COUNT:		ds.w	1
WMOUSE_X:			ds.w	1
WMOUSE_Y:			ds.w	1
Scale_factor:		ds.w	1
Morph_x1:			ds.w	1
Morph_y1:			ds.w	1
Morph_x2:			ds.w	1
Morph_y2:			ds.w	1
Morph_width:		ds.w	1
Morph_height:		ds.w	1
Proc_x1:			ds.w	1
Proc_y1:			ds.w	1
Proc_x2:			ds.w	1
Proc_y2:			ds.w	1
Proc_width:			ds.w	1
Proc_height:		ds.w	1
Pro_x1:			ds.w	1
Pro_y1:			ds.w	1
Pro_x2:			ds.w	1
Pro_y2:			ds.w	1
Pro_width:			ds.w	1
Pro_height:			ds.w	1
TWEEN_DIR:			ds.w	1
OLD_CUR_FRAME:		ds.w	1
NEW_COL:			ds.w	1
OLD_COL:			ds.w	1
y1:				ds.w	1
x1:				ds.w	1
x2:				ds.w	1
splines:			ds.w	1
BRUSH_SELECTED:		ds.w	1
X1:				ds.w	1
Y1:				ds.w	1
X2:				ds.w	1
Y2:				ds.w	1
BX1:				ds.w	1
BY1:				ds.w	1
BX2:				ds.w	1
BY2:				ds.w	1
OLD_X1:			ds.w	1
OLD_Y1:			ds.w	1
OLD_X2:			ds.w	1
OLD_Y2:			ds.w	1
planebytes:			ds.w	1
planewords:			ds.w	1
;physwid:			ds.w	1
;logwid:			ds.w	1
scrwid:			ds.w	1
planes:			ds.w	1
MOUSE_STYLE:		ds.w	1
ICON:				ds.w	1
MOUSE_X:			ds.w	1
MOUSE_Y:			ds.w	1
X_COORD:			ds.w	1
Y_COORD:			ds.w	1
OM_X:				ds.w	1
OM_Y:				ds.w	1
SHADE_TYPE:			ds.w	1
OLD_FUNCTION:		ds.w	1
CURRENT_FUNCTION:		ds.w	1
CURRENT_STUDIO:		ds.w	1
LAST_FRAME:			ds.w	1
;X_RESOLUTION:		ds.w	1
;Y_RESOLUTION:		ds.w	1
;x_factor:			ds.w	1
;y_factor:			ds.w	1
;textgap:			ds.w	1
OLD_SCAN_START:		ds.w	1
OLD_SCAN_STOP:		ds.w	1
SEGMENT_START:		ds.w	1
SEGMENT_END:		ds.w	1
TWEEN_START:		ds.w	1
TWEEN_END:			ds.w	1
BRUSH_HANDLE:		ds.w	1
MinY:				ds.w	1
MaxY:				ds.w	1
COLSHIFT:			ds.w	1
CFN_HANDLE:			ds.w	1
tab_width:			ds.w	1
tab_height:			ds.w	1
LEFT_LIMIT:			ds.w	1
RIGHT_LIMIT:		ds.w	1
FRAME_DIR:			ds.w	1
nrthresh:			ds.w	1
vstart_pon:			ds.w	1
vstart_poff:		ds.w	1
vstop_pon:			ds.w	1
vstop_poff:			ds.w	1
CURRENT_STATION:		ds.w	1
THIS_STATION:		ds.w	1
ms:				ds.w	1

BRUSH_HANDLES:
BRUSH_1_HANDLE:		ds.w	1
BRUSH_1_XBASE:		ds.w	1
BRUSH_1_YBASE:		ds.w	1
BRUSH_2_HANDLE:		ds.w	1
BRUSH_2_XBASE:		ds.w	1
BRUSH_2_YBASE:		ds.w	1
BRUSH_3_HANDLE:		ds.w	1
BRUSH_3_XBASE:		ds.w	1
BRUSH_3_YBASE:		ds.w	1
BRUSH_4_HANDLE:		ds.w	1
BRUSH_4_XBASE:		ds.w	1
BRUSH_4_YBASE:		ds.w	1

BRUSH_1_SIZE:		ds.l	1
BRUSH_2_SIZE:		ds.l	1
BRUSH_3_SIZE:		ds.l	1
BRUSH_4_SIZE:		ds.l	1

*-----------------------------*


VRAM_BLOCKCOUNT:		ds.w	1
VRAM_MAXBLOCKS:		ds.w	1
VRAM_ADDR:			ds.l	1

VRAM_START:			ds.l	1
VRAM_END:			ds.l	1
VRAM_HANDLES:		ds.l	1
VRAM_LENGTH:		ds.l	1


*-----------------------------*

STRAM_BLOCKCOUNT:		ds.w	1
STRAM_MAXBLOCKS:		ds.w	1
STRAM_ADDR:			ds.l	1

STRAM_START:		ds.l	1
STRAM_END:			ds.l	1
STRAM_HANDLES:		ds.l	1
STRAM_LENGTH:		ds.l	1


*-----------------------------*

RAM_BLOCKCOUNT:		ds.l	1
RAM_MAXBLOCKS:		ds.l	1
RAM_ADDR:			ds.l	1

RAM_START:			ds.l	1
RAM_END:			ds.l	1
RAM_HANDLES:		ds.l	1

*-----------------------------------------------------------------------*

safe:				ds.b	1
texture_available:	ds.b	1
TWEEN_FLAG:			ds.b	1
MOUSE_LEVEL:		ds.b	1
MENU_UP:			ds.b	1
DRAW_LOOP:			ds.b	1
DO_PRINT:			ds.b	1
MENUPAL_CHANGED:		ds.b	1
VIDEO_CHANGED:		ds.b	1
PALETTE_CHANGED:		ds.b	1
BITMAP_CHANGED:		ds.b	1
WAIT_FUNCTION:		ds.b	1
DELTA_DISRUPTED:		ds.b	1
HOLD_STATS:			ds.b	1
HOLD_VBLANK:		ds.b	1
HOLD_COORDS:		ds.b	1
UNDO_VALID:			ds.b	1
CROSSCOPY:			ds.b	1
VGA_FLAG:			ds.b	1
FREEZE_ICONS:		ds.b	1
CLIP_TRUE:			ds.b	1
FORCE_REMAP:		ds.b	1
ALERT:			ds.b	1
ENABLE_GUIDES:		ds.b	1
PROGRAM_QUIT:		ds.b	1
Memory_error:		ds.b	1
SOFTWARE_MOUSE:		ds.b	1
first:			ds.b	1
PHYS_CANVAS:		ds.b	1
NO_SCALE:			ds.b	1
MACRO_KEY			ds.b	1
KEY:				ds.b	1
FREEZE_MENUS:		ds.b	1
;TRUE_FLAG:			ds.b	1
TWEEN_TYPE:			ds.b	1
FILL_ERROR:			ds.b	1
STENCIL_ON:			ds.b	1
ANIMATING:			ds.b	1
OK_CANCEL:			ds.b	1
MACRO_PLAY_FLAG:		ds.b	1
MACRO_PLAY_TRIGGER:	ds.b	1
MACRO_RECORD_FLAG:	ds.b	1
FIRST_DRAW:			ds.b	1
DIALOG_FLAG:		ds.b	1
MORPH_HANDLES:		ds.b	1
MENU_STATE:			ds.b	1
BLIT_FREEZE:		ds.b	1
CHAR_SOLID:			ds.b	1
BUSY:				ds.b	1
BUSY_STAT:			ds.b	1
BUSY_TIME:			ds.b	1
COORD_STROBE:		ds.b	1
STROBE2:			ds.b	1
ON_SCREEN:			ds.b	1
MOUSE_ON:			ds.b	1
CROSSHAIR:			ds.b	1
HOLD_INFOBAR:		ds.b	1
ICON_BUTTON:		ds.b	1
GOT_PRESS:			ds.b	1
BUTTONS:			ds.b	1
scancode:			ds.b	1
ABORT_TWEEN:		ds.b	1
VRAM:				ds.b	1
;EXTEND:			ds.b	1
UPDATE_PALETTE:		ds.b	1
ACCEL:			ds.b	1
font_loaded:		ds.b	1
done:				ds.b	1
LARGE_HANDLES:		ds.b	1
GENLOCK:			ds.b	1
;gensol:			ds.b	1
active:			ds.b	1
UNDO_ENABLE:		ds.b	1
no_stabilizer:		ds.b	1
				even

*-----------------------------------------------------------------------*

polysides:			ds.w	1

texture_ptr:		ds.l	1

polygon_in:			ds.l	1
texture_in:			ds.l	1
polygon_out:		ds.l	1
texture_out:		ds.l	1

polylist_1:			ds.l	10
textlist_1:			ds.l	10

polysource:			ds.l	8
polydest:			ds.l	10

*-----------------------------------------------------------------------*

palbardata:
palbarwidth:		ds.w	1
palbarheight:		ds.w	1

control:
opcode:			ds.w	1
sintin:			ds.w	1
sintout:			ds.w	1
saddrin:			ds.w	1
saddrout:			ds.w	1
				ds.w	6

global:
apversion:			ds.w	1
apcount:			ds.w	1
apid:				ds.w	1
apprivate:			ds.l	1
apptree:			ds.l	1
ap1resv:			ds.l	1	
ap2resv:			ds.l	1
ap3resv:			ds.l	1
ap4resv:			ds.l	1

int_in:			ds.b	256
pts_in:			ds.b	64
int_out:			ds.b	256
pts_out:			ds.b	64
addr_in:			ds.l	4
addr_out:			ds.l	4

handle:			ds.w	1
vhandle:			ds.w	1


ICON_AREA:			ds.w	4
BOXDATA:			ds.w	5

Gourad_colours:		ds.w	3*4

				ds.b	10
NUM_TEXT:			ds.b	1
				ds.b	10
				even
				
POSBAR_TEXT:		ds.b	16
VIDEO_STRUCTURE:		ds.b	video_copy_len
				even

MATRIX:			ds.w	9

OLD_VBI:			ds.l	1
vector_buffer:		ds.b	32

*-----------------------------------------------------------------------*
*	Poly-handle array									*
*-----------------------------------------------------------------------*

HANDLE_COUNT:	ds.w		1
HANDLE_PTR:		ds.l		1

Guide_data:
HANDLE_LIST:	ds.b		guide_len*max_handles
MORPH_BUFFER:	ds.b		guide_len*max_handles

*-----------------------------------------------------------------------*
*	Delta storage structures							*
*-----------------------------------------------------------------------*

CUR_DELTAFRAME:	ds.w		1
Delta_count:	ds.w		1
Delta_list:		ds.w		max_deltas
			
*-----------------------------------------------------------------------*
*	Memory management banks, structures and variables			*
*-----------------------------------------------------------------------*

EDIT_COUNT:		ds.w		1
EDIT_PTR:		ds.l		1
edit_list:		ds.l		4

handlebuffer1:	ds.l		max_blocks
handlebuffer2:	ds.l		max_blocks
BLOCKS:		ds.w		max_blocks

*-----------------------------------------------------------------------*

MOUSEMASK:		ds.w		16*16
MOUSEKEEP:		ds.w		16*16
MOUSEPTR:		ds.w		16*16

*-----------------------------------------------------------------------*

TRUE_FONT:
PLANE_TABLE:	ds.w		8*256
ScaleX2:		ds.w		256
ScaleX4:		ds.w		512
ScaleX8:		ds.w		1024

*-----------------------------------------------------------------------*

digi_lines:		ds.l		160

PALETTE1:		ds.l		256
PALETTE2:		ds.l		256
PALETTE3:		ds.l		256
PALETTE4:		ds.l		256

COLOURS:		ds.l		256

NEW_COLOURS:	ds.l		256

Colour_cut_BUFFER	ds.l		256

GEM_PALETTE:	ds.l		256

TRANSLATOR_TABLE:	ds.b		256

INDEX_TABLE:	ds.b		256

IFACE_COLOURS:	ds.w		menu_cols

TEMP_COLS:		ds.b		3*256

*-----------------------------------------------------------------------*
*	X-Buffers										*
*-----------------------------------------------------------------------*

apextext:
Circle_data:
buffer48k:

buffer24k_1:
L_XBuffer:		ds.w		log_height*4
buffer24k_2:
R_XBuffer:		ds.w		log_height*4

*-----------------------------------------------------------------------*

			ds.l		256
GEM_STACK:		ds.l		1
			ds.l		512
USP_STACK:		ds.l		1
			ds.l		512
SSP_STACK:		ds.l		1

PHYS_Y:		ds.l		230*2
LOG_Y:		ds.l		log_height

BSS_STOP:

*-----------------------------------------------------------------------*

BLOCK_AREA:

