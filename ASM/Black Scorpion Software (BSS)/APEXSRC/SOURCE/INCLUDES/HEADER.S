
*-----------------------------------------------------------------------*

	include	incdir\mfp.s
	include	incdir\blit.s
;	include	incdir\cache.s
	include	incdir\stdequ.s
	include	incdir\dspequ.s
	include	incdir\video.s

cache		macro
		endm
	
cacheon	macro
		endm

cacheoff	macro
		endm

;norm			=	ienab|denab|iclr|dclr|ibrst|dbrst|wa

*-----------------------------------------------------------------------*
*	Standard macros									*
*-----------------------------------------------------------------------*

hidemouse		macro				; mouse macros
	dc.w		$A00A
	endm

showmouse		macro
	dc.w		$A009
	endm

push	macro
	move.\0	\1,-(sp)
	endm
	
pop	macro
	move.\0	(sp)+,\1
	endm

pushall		macro
	movem.l	d0-d7/a0-a6,-(sp)
	endm
	
popall		macro
	movem.l	(sp)+,d0-d7/a0-a6
	endm
	
*-----------------------------------------------------------------------*
*	Display macros									*
*-----------------------------------------------------------------------*

seticon	macro
		push.w	CURRENT_FUNCTION
		push.w	THIS_STATION
		move.w	#\1,CURRENT_FUNCTION
		move.w	#\2,THIS_STATION
		endm

reseticon	macro
		pop.w		THIS_STATION
		pop.w		CURRENT_FUNCTION
		endm

delay		macro						; vbi delay macro
		move.w	#\1,TIMER
.wt\@		tst.w		TIMER
		bne.s		.wt\@
		endm

waitblit	macro
		move.b	\1,(\3)
.wb\@		bset		\2,(\3)
		bne.s		.wb\@
		endm

init_tool	macro
		tst.b		FREEZE_ICONS
		beq.s		.frez
		rts
.frez		st		FREEZE_ICONS
		bsr.s		.tool
		sf		FREEZE_ICONS
		rts
.tool
		endm

word		macro
WD_\1		move.w	d0,(a1)+
		endm	
	
bcop		macro
CB_\1		move.w	(a0)+,(a1)+
		endm	

wcop		macro
WC_\1		move.w	(a6)+,(a1)+
		endm	

remap		macro
		bclr		d3,\1
		add.b		d1,d1
		bcc.s		.ns\@
		bset		d3,\1
.ns\@	
		endm

circle_range		macro
		cmp.w		MinY,d1
		bge.s		.nm\@
		move.w	d1,MinY
.nm\@		cmp.w		MaxY,d1
		ble.s		.nx\@
		move.w	d1,MaxY
.nx\@
		endm

rand		macro
		move.l	SEED,\1
		mulu.l	#RF,\1
		add.l		#RA,\1
		move.l	\1,SEED
		swap		\1
		endm

rgb		macro
		dc.l		(\1<<(2+16))+(\2<<(2+8))+(\3<<2)
		endm

Index		macro
		add.w		\1,\1		; *2
		move.w	\1,\2
		asl.w		#3,\1		; *2*8 = *16
		add.w		\2,\1		; *16+*2 = *18 = (2*9)
		endm

xresfactor	macro
		cmp.w		#1,x_factor
		beq.s		.n\@
		ext.l		\1
		add.l		\1,\1
		IFEQ		NARG-2	
		ext.l		\2
		add.l		\2,\2
		ENDC
.n\@
		endm

yresfactor	macro
		cmp.w		#1,y_factor
		beq.s		.n\@
		ext.l		\1
		add.l		\1,\1
		IFEQ		NARG-2	
		ext.l		\2
		add.l		\2,\2
		ENDC
.n\@
		endm

dcoff		macro
;		move.w	#ienab|dfrz|wa,\1
;		movec		\1,CACR
		endm

dcon		macro
;		move.w	#ienab|denab|wa,\1
;		movec		\1,CACR
		endm

dcfrz		macro
;		move.w	#ienab|denab|dfrz|wa,\1
;		movec		\1,CACR
		endm

dcfree	macro
;		move.w	#ienab|denab|wa,\1
;		movec		\1,CACR
		endm

dspwrite	macro
		IFEQ		NARG-1
.ww\@		btst		#1,$FFFFA202.w
		beq.s		.ww\@
		move.w	\1,$FFFFA206.w
		ELSEIF
.ww\@		btst		#1,\2
		beq.s		.ww\@
		move.w	\1,\3
		ENDC
		endm

dspwritel	macro
.ww\@		btst		#1,$FFFFA202.w
		beq.s		.ww\@
		move.l	\1,$FFFFA204.w
		endm

dspread	macro
		IFEQ		NARG-1
.wr\@		btst		#0,$FFFFA202.w
		beq.s		.wr\@
		move.w	$FFFFA206.w,\1
		ELSEIF
.ww\@		btst		#0,\2
		beq.s		.ww\@
		move.w	\3,\1
		ENDC
		endm

*-----------------------------------------------------------------------*
*		Icon macros									*
*-----------------------------------------------------------------------*

icon_jump	macro
		dc.w	0	; link to new list
		dc.l	\1	; address of list
		endm

both_jump	macro
		dc.w	0	; link to new list
		dc.l	\1
		dc.l	\1
		dc.w	-2
		endm

		rsreset
icon_name	rs.w		1
icon_x1	rs.w		1
icon_y1	rs.w		1
icon_x2	rs.w		1
icon_y2	rs.w		1
icon_help	rs.l		1
icon_len	rs.b		0

icon		macro
		IFLT		NARG-5
		icon_jump	\1
		dc.l		0,0
		ELSEIF
		IFND		I_\1
I_\1		=		icon_num
		ENDC
		dc.w		icon_num,\2,\3,\2+\4-1,\3+\5-1
		IFEQ		NARG-6
		dc.l		\1_\6
		ELSEIF
		dc.l		0
		ENDC
		ENDC
		section	data
		dc.l		\1
		section	text
icon_num	set		icon_num+1
		endm

baricon	macro
		icon		\1,\2*16,\3,016,016,help
		endm

*-----------------------------------------------------------------------*
*		Gadget macros								*
*-----------------------------------------------------------------------*

D_zone	macro		x,y,w,h,A
		icon_jump	.Ijp\@		; next icon
		dc.l		.Nxt\@		; next gadget
		dc.w		dialog_zone		; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0
		dc.w		-1			; ident (none)
.Ijp\@	icon		Zone_\5,\1,\2,\3,\4
.Nxt\@
		endm

D_grovzone	macro		x,y,w,h,A
		icon_jump	.Ijp\@		; next icon
		dc.l		.Nxt\@		; next gadget
		dc.w		dialog_grovzone	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0
		dc.w		-1			; ident (none)
.Ijp\@	icon		Zone_\5,\1,\2,\3,\4
.Nxt\@
		endm

D_groove	macro					; X,Y,W,H
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_groove	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0
		dc.w		-1			; i.d. (none)
.s\@
		endm

D_mainframe	macro					; X,Y,W,H,TEXT
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_mainframe	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		.DT\@			; text address
		dc.w		-1			; i.d. (none)
.DT\@		dc.b		\5,0			; text string
		even
.s\@		;D_zone	\1,\2-mensize,mensize,mensize,DQUIT
		endm

D_frame_up	macro					; X,Y,W,H
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_frame_up	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0
		dc.w		-1			; i.d. (none)
.s\@
		endm

D_miniframe	macro					; X,Y,W,H,TEXT
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_miniframe	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		.DT\@			; text address
		dc.w		-1			; i.d. (none)
.DT\@		dc.b		\5,0			; text string
		even
.s\@		;D_zone	\1,\2-mensize,mensize,mensize,DQUIT
		endm

D_microframe	macro					; X,Y,W,H,TEXT
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_microframe	; gadget type
		dc.w		\1,\2,\3-1,\4	; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0			; text address
		dc.w		-1			; i.d. (none)
.s\@
		endm

D_panel_dn	macro					; X,Y,W,H
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_panel_dn	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		0
		dc.w		-1			; i.d. (none)
.s\@
		endm

D_radbutton	macro					; X,Y,W,H,TYPE,GROUP,NAME,TEXT
		IFEQ		bit_num
		bss
\6_BITS:	ds.w		1			; button flag register
		text
		ENDC
		icon_jump	.I\@			; next icon
		dc.l		.N\@			; next gadget
		dc.w		dialog_radbutton	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		bit_num		; bit number for button flag
		dc.l		\6_BITS		; button flag register
		IFEQ		NARG-8
		dc.l		.T\@			; text string address
		dc.w		icon_num		; ident
.T\@		dc.b		\8,0			; text string
		even
		ELSEIF
		dc.l		0
		dc.w		icon_num		; ident
		ENDC
.I\@		icon		Button_\6_\7,\1,\2,\3,\4
.N\@	
		IFND		Bit_\6_\7
Bit_\6_\7:	=		bit_num
		ENDC
bit_num	set		bit_num+1
		endm

D_outline	macro					; X,Y,W,H,TEXT
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_outline	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		0		
		dc.l		0
		dc.l		.DT\@			; text address
		dc.w		-1			; i.d. (none)
.DT\@		dc.b		\5,0			; text string
		even
.s\@
		endm
		
D_frmbutton	macro					; X,Y,W,H,TYPE,GROUP,NAME,TEXT
		IFEQ		bit_num
		bss
\6_BITS:	ds.w		1			; button flag register
		text
		ENDC
		icon_jump	.I\@			; next icon
		dc.l		.N\@			; next gadget
		dc.w		dialog_frmbutton	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		bit_num		; bit number for button flag
		dc.l		\6_BITS		; button flag register
		IFEQ		NARG-8
		dc.l		.T\@			; text string address
		dc.w		icon_num		; ident
.T\@		dc.b		\8,0			; text string
		even
		ELSEIF
		dc.l		0
		dc.w		icon_num		; ident
		ENDC
.I\@		icon		Button_\6_\7,\1,\2,\3,\4
.N\@	
		IFND		Bit_\6_\7
Bit_\6_\7:	=		bit_num
		ENDC
bit_num	set		bit_num+1
		endm

D_panbutton	macro					; X,Y,W,H,TYPE,GROUP,NAME,TEXT
		IFEQ		bit_num
		bss
\6_BITS:	ds.w		1			; button flag register
		text
		ENDC
		icon_jump	.I\@			; next icon
		dc.l		.N\@			; next gadget
		dc.w		dialog_panbutton	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		bit_num		; bit number for button flag
		dc.l		\6_BITS		; button flag register
		IFEQ		NARG-8
		dc.l		.T\@			; text string address
		dc.w		icon_num		; ident
.T\@		dc.b		\8,0			; text string
		even
		ELSEIF
		dc.l		0
		dc.w		icon_num		; ident
		ENDC
.I\@		icon		Button_\6_\7,\1,\2,\3,\4
.N\@
Bit_\6_\7:	=		bit_num
bit_num	set		bit_num+1
		endm

D_editbutton	macro				; X,Y,W,H,TYPE,GROUP,NAME,NUM
		IFEQ		bit_num
		bss
\5_BITS:	ds.w		1			; button flag register
		text
		ENDC
		icon_jump	\5\6I\@		; next icon
		dc.l		\5\6N\@		; next gadget
		dc.w		dialog_editbutton	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		bit_num		; bit number for button flag
		dc.w		\8			; lower limit
		dc.w		\9			; upper limit
\6_VAL:	dc.l		\7			; actual value
		dc.w		icon_num		; ident
\5\6I\@	icon		Button_\5_\6,\1,\2,\3,\4
\5\6N\@
Bit_\5_\6:	=		bit_num
bit_num	set		bit_num+1
		endm

D_routine	macro		address
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_rout		; gadget type
		dc.w		0,0,0,0
		dc.w		0
		dc.l		0
		dc.l		\1			; routine address
		dc.w		-1			; ident (none)
.s\@
		endm

D_text	macro		address
		icon_jump	.s\@			; next icon
		dc.l		.s\@			; next gadget
		dc.w		dialog_text		; gadget type
		dc.w		0,0,0,0
		dc.w		0
		dc.l		0
		dc.l		\1			; routine address
		dc.w		-1			; ident (none)
.s\@
		endm

D_editline	macro					; X,Y,W,H,TYPE,GROUP,NAME,NUM
		IFEQ		bit_num
		bss
\5_BITS:	ds.w		1			; button flag register
		text
		ENDC
		icon_jump	\5\6I\@		; next icon
		dc.l		\5\6N\@		; next gadget
		dc.w		dialog_editline	; gadget type
		dc.w		\1,\2,\3,\4		; x,y,w,h
		dc.w		bit_num		; bit number for button flag
		dc.w		\8			; lower limit (characters)
		dc.w		\9			; upper limit (characters)
\5\6_strptr:
		dc.l		\7			; pointer to actual string
		dc.w		icon_num		; ident
\5\6I\@	icon		Button_\5_\6,\1,\2,\3,\4
\5\6N\@
Bit_\5_\6:	=		bit_num
bit_num	set		bit_num+1
		endm
		
end_gadget	macro
		dc.l		0
		dc.w		-1
		endm

*-----------------------------------------------------------------------*
*	Structures										*
*-----------------------------------------------------------------------*

			rsreset
partial_menu	rs.b	1		
full_menu		rs.b	1		
no_menu		rs.b	1		

			rsreset
dialog_mainframe	rs.b	1
dialog_frame_up	rs.b	1
dialog_miniframe	rs.b	1
dialog_microframe	rs.b	1
dialog_grovzone	rs.b	1
dialog_radbutton	rs.b	1
dialog_outline	rs.b	1
dialog_frmbutton	rs.b	1
dialog_panbutton	rs.b	1
dialog_text		rs.b	1
dialog_zone		rs.b	1
dialog_rout		rs.b	1
dialog_editbutton	rs.b	1
dialog_groove	rs.b	1
dialog_editline	rs.b	1

			rsreset
j_jump		rs.b	6
g_next		rs.l	1
g_type		rs.w	1
g_x			rs.w	1
g_y			rs.w	1
g_w			rs.w	1
g_h			rs.w	1
g_varlen		rs.w	1
g_var			rs.l	1
g_text		rs.l	1
g_ident		rs.w	1
g_len			rs.b	0

			rsreset
dtype_delta		rs.b	1
dtype_rawdelta	rs.b	1
dtype_raw		rs.b	1
dtype_superstor	rs.b	1

			rsreset
delta_type:		rs.l	1	; 0=compressed 1=uncompressed 2=block 3=super
delta_size:		rs.l	1
delta_head:		rs.b	0

			rsreset
block_slot:		rs.l	1
block_size:		rs.l	1
block_head:		rs.b	0

			rsreset
box_x1		rs.w	1
box_y1		rs.w	1
box_x2		rs.w	1
box_y2		rs.w	1
box_c			rs.w	1

			rsreset
			rs.l	1
sy1			rs.w	1
sx1			rs.w	1
sx2			rs.w	1
			rsreset
ly1			rs.w	1
lx1			rs.w	1
lx2			rs.w	1

			rsreset
tween_frame		rs.b	1
tween_segment	rs.b	1
tween_all		rs.b	1

default2frame	rs.b	1
default2all		rs.b	1

			rsreset
STRAM_only		rs.b	1
VRAM_only		rs.b	1
STRAM_preferred	rs.b	1
VRAM_preferred	rs.b	1

			rsreset
modecode_copy	rs.w	1
xres_copy		rs.w	1
yres_copy		rs.w	1
xfactor_copy	rs.w	1
yfactor_copy	rs.w	1
physwid_copy	rs.w	1
logwid_copy		rs.w	1
canwid_copy		rs.w	1
canhig_copy		rs.w	1
cansize_copy	rs.l	1
physize_copy	rs.l	1
scrsize_copy	rs.l	1
true_copy		rs.b	1
extend_copy		rs.b	1
gensol_copy		rs.b	1
video_copy_len	rs.b	0

			rsreset
guide_state		rs.w	1
guide_name		rs.w	1
guide_x1_1		rs.w	1
guide_y1_1		rs.w	1
guide_x2_1		rs.w	1
guide_y2_1		rs.w	1
guide_x1_2		rs.w	1
guide_y1_2		rs.w	1
guide_x2_2		rs.w	1
guide_y2_2		rs.w	1
guide_next		rs.w	1
guide_len		rs.b	0

			rsreset
station_draw	rs.b	1
station_cell	rs.b	1
station_colour	rs.b	1
station_video	rs.b	1
station_pro		rs.b	1
station_aproc	rs.b	1
station_morph	rs.b	1
station_text	rs.b	1

*-----------------------------------------------------------------------*
*		Program equates								*
*-----------------------------------------------------------------------*

max_handles:	=	200

;virtual_start	=	10000

screen_height	=	228
mouse_height	=	15

phys_width		=	320
draw_height		=	200
full_height		=	200+20

left_button		=	2
right_button	=	1

max_canvas_index	=	11
max_edges:		=	2000
max_deltas:		=	4000
max_blocks:		=	max_deltas+32

gcode:		=	$DEAD
blockterm		=	-1

menu_cols		=	256
mensize		=	13

iface_visible	=	31

iface_white		=	31
iface_lgrey		=	20
iface_grey		=	11
iface_dgrey		=	5
iface_black		=	0

iface_yellow	=	98
iface_orange	=	95
iface_red		=	93
iface_green		=	153
iface_blue		=	158
iface_panel		=	100

iface_lmetal	=	255
iface_metal		=	252
iface_dmetal	=	250

iface_lgold		=	248
iface_gold		=	245
iface_dgold		=	243

first_ade		=	36
off_table		=	72
data_table		=	76
form_width		=	80
form_height		=	82

INITSEED		=	$79D3f5b5
RF			=	$F75D3791
RA			=	$1397f957


*-----------------------------------------------------------------------*

DOBAR_Ymin:		=	098
DOBAR_Xmin:		=	160-100
DOBAR_Ymax:		=	115
DOBAR_Xmax:		=	160+100

PBAR_Xmin:		=	20+16
PBAR_Ymin:		=	171+16

PBAR_Xmax:		=	283-16
PBAR_Ymax:		=	180+16

SBAR_Xmin:		=	PBAR_Xmin+8
SBAR_Ymin:		=	PBAR_Ymin
SBAR_Xmax:		=	PBAR_Xmax-8
SBAR_Ymax:		=	PBAR_Ymax
SBAR_Width:		=	7

TBAR_Xmin:		=	8
TBAR_Ymin:		=	101
TBAR_Xmax:		=	12
TBAR_Ymax:		=	155
TBAR_Height:	=	6

AirSizBarWidth	=	6
AirSizBarXmin	=	80+6
AirSizBarYmin	=	101-4
AirSizBarXmax	=	AirSizBarXmin+64
AirSizBarYmax	=	AirSizBarYmin+4

AirFloBarWidth	=	6
AirFloBarXmin	=	80+6
AirFloBarYmin	=	136-4
AirFloBarXmax	=	AirFloBarXmin+64
AirFloBarYmax	=	AirFloBarYmin+4

FilterBarWidth	=	6
FilterBarXmin	=	80+6+64-18-4
FilterBarYmin	=	136-4-56+32-8
FilterBarXmax	=	FilterBarXmin+64
FilterBarYmax	=	FilterBarYmin+4

BmenX			=	48+25
BmenY			=	52

rgby			=	16-32+2-7
uv_x			=	-8
uv_y			=	7

y_x			=	32+8

RedBarXmin		=	84
RedBarYmin		=	43+rgby
RedBarXmax		=	190
RedBarYmax		=	52+rgby

GrnBarXmin		=	84
GrnBarYmin		=	57+rgby
GrnBarXmax		=	190
GrnBarYmax		=	66+rgby

BluBarXmin		=	84
BluBarYmin		=	71+rgby
BluBarXmax		=	190
BluBarYmax		=	80+rgby

ConvBar1_X		=	31+43
ConvBar1_Y		=	36+9+13+1+20

ConvBar2_X		=	31+43
ConvBar2_Y		=	36+9+13+1+20+32

Hue1BarXmin		=	ConvBar1_X+4
Hue1BarYmin		=	ConvBar1_Y+3
Hue1BarXmax		=	ConvBar1_X+110
Hue1BarYmax		=	ConvBar1_Y+12

Sat1BarXmin		=	ConvBar1_X+4
Sat1BarYmin		=	ConvBar1_Y+17
Sat1BarXmax		=	ConvBar1_X+110
Sat1BarYmax		=	ConvBar1_Y+26

Bri1BarXmin		=	ConvBar1_X+4
Bri1BarYmin		=	ConvBar1_Y+31
Bri1BarXmax		=	ConvBar1_X+110
Bri1BarYmax		=	ConvBar1_Y+40

Hue2BarXmin		=	ConvBar2_X+4
Hue2BarYmin		=	ConvBar2_Y+3
Hue2BarXmax		=	ConvBar2_X+110
Hue2BarYmax		=	ConvBar2_Y+12

Sat2BarXmin		=	ConvBar2_X+4
Sat2BarYmin		=	ConvBar2_Y+17
Sat2BarXmax		=	ConvBar2_X+110
Sat2BarYmax		=	ConvBar2_Y+26

Bri2BarXmin		=	ConvBar2_X+4
Bri2BarYmin		=	ConvBar2_Y+31
Bri2BarXmax		=	ConvBar2_X+110
Bri2BarYmax		=	ConvBar2_Y+40

ValBarXmin		=	ConvBar2_X+4
ValBarYmin		=	ConvBar2_Y+3-14-6
ValBarXmax		=	ConvBar2_X+110
ValBarYmax		=	ConvBar2_Y+12-14-6
