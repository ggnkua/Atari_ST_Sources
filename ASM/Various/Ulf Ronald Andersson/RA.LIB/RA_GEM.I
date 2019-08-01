;----------------------------------------------------------------------------
;File name:	RA_GEM.I			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1991.02.02
;(c)1998 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Symbol & Macro library for GEM operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_GEM_defined
RA_GEM_defined	set	1
;----------------------------------------------------------------------------
	include	RA_SYS.I
;----------------------------------------------------------------------------
;	Library macros:
;
;gem_aes	func,arg,arg,arg...
;sub_aes	func
;sub_vdi	func[,handle]
;
;vq_aes		=> 0 if aes is missing
;vq_gdos	=> 0 if gdos is missing
;vq_vgdos	=> -2 if gdos is missing, otherwise => version code
;aes_redraw	redraws entire AES screen, including menu line
;
;NB:	Use "make GEM_links" to include all referred code modules.
;
;NB:	The VDI arrays 'contrl', 'intin', 'ptsin', 'intout', and 'ptsout'
;	are not created in this lib, but must be defined elsewhere.
;NB:	Arrays 'contrl', 'intin', 'intout' are used both for AES and VDI.
;
;NB:	The AES arrays 'global', 'addrin', 'addrout' are created in the lib.
;----------------------------------------------------------------------------
	IFND	huge_program
huge_program	set	0
	ENDC
;----------------------------------------------------------------------------
;	VDI FUNCTION DEFINITIONS
;
v_opnwk		= $000B7f01
v_clswk		= $00007f02
v_clrwk		= $00007f03
v_updwk		= $00007f04
;Op $05 has subop's given further below
v_pline		= $ff007f06
v_pmarker	= $ff007f07
v_gtext		= $01ff7f08
v_fillarea	= $ff007f09
v_cellarray	= $02ff7f0a
;Op $0b has subop's given further below
vst_height	= $01007f0c
vst_rotation	= $00017f0d
vs_color	= $00047f0e
vsl_type	= $00017f0f
vsl_width	= $01007f10
vsl_color	= $00017f11
vsm_type	= $00017f12
vsm_height	= $01007f13
vsm_color	= $00017f14
vst_font	= $00017f15
vst_color	= $00017f16
vsf_interior	= $00017f17
vsf_style	= $00017f18
vsf_color	= $00017f19
vq_color	= $00027f1a
;$1b
vrq_locator	= $01007f1c
vsm_locator	= vrq_locator
vrq_valuator	= $00017f1d
vsm_valuator	= vrq_valuator
vrq_choice	= $00017f1e
vsm_choice	= vrq_choice
vrq_string	= $01027f1f
vsm_string	= vrq_string
vswr_mode	= $00017f20
vsin_mode	= $00027f21
;$22
vql_attributes	= $00007f23
vqm_attributes	= $00007f24
vqf_attributes	= $00007f25
vqt_attributes	= $00007f26
vst_alignment	= $00027f27
v_opnvwk	= $000b7f64
v_clsvwk	= $00007f65
vq_extnd	= $00017f66
v_contour	= $01017f67
v_contourfill	= v_contour
vsf_perimeter	= $00017f68
v_get_pixel	= $01007f69
vst_effects	= $00017f6a
vst_point	= $00017f6b
vsl_ends	= $00027f6c
vro_cpyfm	= $04017f6d
vr_trnfm	= $00007f6e
vsc_form	= $00257f6f
vsf_udpat	= $00ff7f70
vsl_udsty	= $00017f71
vr_recfl	= $02007f72
vqin_mode	= $00017f73
vqt_extent	= $00ff7f74
vqt_width	= $00017f75
vex_timv	= $00007f76
vex_time	= vex_timv
vst_load_fonts	= $00017f77
vst_unload_fonts= $00017f78
vrt_cpyfm	= $04037f79
v_show_c	= $00017f7a
v_hide_c	= $00007f7b
vq_mouse	= $00007f7c
vex_butv	= $00007f7d
vex_motv	= $00007f7e
vex_curv	= $00007f7f
vq_key_s	= $00007f80
vs_clip		= $02017f81
;;;vqt_name	= $xxxx7f82
;;;vqt_fontinfo	= $xxxx7f83
;
v_ftext		= $01ff7ff1	;\/ NVDI >=3.0, NB: ptsin size decides
v_ftext_offset	= $ffff7ff1	;/\ which function is used
;----------------------------------------------------------------------------
;	VDI subfunction definitions
;
vq_chcells	= $00000105
v_exit_cur	= $00000205
v_enter_cur	= $00000305
v_curup		= $00000405
v_curdown	= $00000505
v_curright	= $00000605
v_curleft	= $00000705
v_curhome	= $00000805
v_eeos		= $00000905	;\/ NB: info varies as to the
v_eeol		= $00000a05	;/\ order of these 2 functions
vs_curaddress	= $00020b05
v_curtext	= $00ff0c05
v_rvon		= $00000d05
v_rvoff		= $00000e05
vq_curaddress	= $00000f05
vq_tabstatus	= $00001005
v_hardcopy	= $00001105
v_dspcur	= $01001205
v_rmcur		= $00001305
v_form_adv	= $00001405
v_output_window	= $02001505
v_clear_disp_list=$00001605
;;;v_bit_image	= $xxxx1705
;
vs_palette	= $00013c05	;\
v_sound		= $00023d05	; > NB: PC-specific
vs_mute		= $00013e05	;/
;
vs_calibrate	= $00ff4c05
vq_calibrate	= $00004d05
;
vt_resolution	= $01005105
vt_axis		= $01005205
vt_origin	= $01005305
vq_tdimensions	= $00005405
vt_alignment	= $01005505
;
vqp_films	= $00005b05	;\
vqp_state	= $00005c05	; \
vsp_state	= $00155d05	;  \/ NB: info questionable !!!
vsp_save	= $00005e05	;  /\
vsp_message	= $00009500	; /
vqp_error	= $00006005	;/
;
v_meta_extents	= $02006205
v_write_meta	= $ffff6305
vm_filename	= $00ff6405
;
v_offset	= $00016505
v_fontinit	= $00026605	;fonthead at (intin[0]<<16)|intin[1]
;
v_bar		= $0200010b
v_arc		= $0402020b
v_pieslice	= $0402030b
v_circle	= $0300040b
v_ellipse	= $0200050b
v_ellarc	= $0202060b
v_ellpie	= $0202070b
v_rbox		= $0200080b
v_rfbox		= $0200090b
v_justified	= $02ff0a0b
;
v_bez		= $ffff0d06	;NVDI >= 2.10
v_bez_fill	= $ffff0d09	;NVDI >= 2.10
;
;
;----------------------------------------------------------------------------
;	AES FUNCTION DEFINITIONS
;
appl_init	= $01000a
appl_read	= $21100b
appl_write	= $21100c
appl_find	= $01100d
appl_tplay	= $21100e
appl_trecord	= $11100f
appl_bvset	= $210010	;new
appl_yield	= $010011	;new
appl_search	= $131012	;new
appl_exit	= $010013
;
evnt_keybd	= $010014
evnt_button	= $350015
evnt_mouse	= $550016
evnt_mesag	= $011017
evnt_timer	= $210018
evnt_multi	=$1071019
evnt_dclick	= $21001a
;
menu_bar	= $11101e
menu_icheck	= $21101f
menu_ienable	= $211020
menu_tnormal	= $211021
menu_text	= $112022
menu_register	= $111023
menu_unregister	= $110024	;new
menu_click	= $210025	;new
;
objc_add	= $211028
objc_delete	= $111029
objc_draw	= $61102a
objc_find	= $41102b
objc_offset	= $13102c
objc_order	= $21102d
objc_edit	= $42102e
objc_change	= $81102f
objc_sysvar	= $430030	;3-D MTOS/MagiC
;
form_do		= $111032
form_xdo	= $222032
form_dial	= $910033
form_xdial	= $a10033
form_alert	= $111034
form_error	= $110035
form_center	= $051036
form_keybd	= $331037
form_button	= $221038
;
graf_rubberbox	= $430046
graf_rubbox	= $430046
graf_dragbox	= $830047
graf_movebox	= $610048
graf_mbox	= $610048
graf_growbox	= $810049
graf_shrinkbox	= $81004a
graf_watchbox	= $41104b
graf_slidebox	= $31104c
graf_handle	= $05004d
graf_mouse	= $11104e
graf_mkstate	= $05004f
;
scrp_read	= $011050
scrp_write	= $011051
scrp_clear	= $010052	;new
;
fsel_input	= $02205a
fsel_exinput	= $02305b	;new
;
wind_create	= $510064
wind_open	= $510065
wind_close	= $110066
wind_delete	= $110067
wind_get	= $250068
wind_set	= $610069
wind_find	= $21006a
wind_update	= $11006b
wind_calc	= $65006c
wind_new	= $00006d
;
rsrc_load	= $01106e
rsrc_free	= $01006f
rsrc_gaddr	= $210170
rsrc_saddr	= $211071
rsrc_obfix	= $111072
rsrc_rcfix	= $011073	;MTOS/MagiC
;
shel_read	= $012078
shel_write	= $312079
shel_get	= $11107a
shel_put	= $11107b
shel_find	= $01107c
shel_envrn	= $01207d
shel_rdef	= $01207e	;new
shel_wdef	= $00207f	;new
;
appl_getinfo	= $150082
;
xgrf_stepcalc	= $660082	;PC/MagiC  NB: opcode = appl_getinfo
xgrf_2box	= $910083	;PC/MagiC
;
form_popup	= $211087
form_xerr	= $211088	;MagiC >= 2.0
;
;
;----------------------------------------------------------------------------
;	AES DATA DEFINITIONS
;
; Function flags for evnt_multi
;
MU_KEYBD	= $01
MU_BUTTON	= $02
MU_M1		= $04
MU_M2		= $08
MU_MESAG	= $10
MU_TIMER	= $20
;
;
; Function flag bits for evnt_multi
;
b_MU_KEYBD	= 0
b_MU_BUTTON	= 1
b_MU_M1		= 2
b_MU_M2		= 3
b_MU_MESAG	= 4
b_MU_TIMER	= 5
;
;----------------------------------------------------------------------------
;	Message event codes
;
MN_SELECTED	= $10
;
WM_REDRAW	= $14
WM_TOPPED	= $15
WM_CLOSED	= $16
WM_FULLED	= $17
WM_ARROWED	= $18
WM_HSLID	= $19
WM_VSLID	= $1A
WM_SIZED	= $1B
WM_MOVED	= $1C
WM_NEWTOP	= $1D	;in early MTOS only
WM_UNTOPPED	= $1E	;MTOS for info only
WM_ONTOP	= $1F	;MTOS for info only
WM_BOTTOM	= $21	;MTOS: call WIND_SET(WF_BOTTOM...)
WM_ICONIFY	= $22	;MTOS
WM_UNICONIFY	= $23	;MTOS
WM_ALLICONIFY	= $24	;MTOS
WM_TOOLBAR	= $25	;MTOS
;
AC_OPEN		= $28
AC_CLOSE	= $29
;
AP_TERM		= $32	;MTOS
AP_TFAIL	= $33	;MTOS
;
CT_KEY		= $35	;XCONTROL
;
AP_RESCHG	= $39	;MTOS
;
SHUT_COMPLETED	= $3C	;MTOS
RESCH_COMPLETED	= $3D	;MTOS
;
AP_DRAGDROP	= $3F	;MTOS
;
SH_WDRAW	= $48	;MTOS desktop redraw of windows for drive msg[3] (-1=all, 0=A:)
;
SC_CHANGED	= $50	;programs changing clipboard (used by Geneva & older MTOS as CH_EXIT)
;
CH_EXIT		= $5A	;MTOS msg[3]=childs ap_id,  msg[4]=exit_code
;
WM_M_BDROPPED	= $64	;
SM_M_SPECIAL	= $65	;MagiC screen manager commands
;
;----------------------------------------------------------------------------
;	Function codes for form_dial
;
FMD_START	= 0
FMD_GROW	= 1
FMD_SHRINK	= 2
FMD_FINISH	= 3
;
;----------------------------------------------------------------------------
;	Object type codes
;
G_BOX		= $14
G_TEXT		= $15
G_BOXTEXT	= $16
G_IMAGE		= $17
G_PROGDEF	= $18
G_IBOX		= $19
G_BUTTON	= $1A
G_BOXCHAR	= $1B
G_STRING	= $1C
G_FTEXT		= $1D
G_FBOXTEXT	= $1E
G_ICON		= $1F
G_TITLE		= $20
G_CICON		= $21
;
;------------------------------------
;	Object flags
;
NONE		= $00
SELECTABLE	= $01
DEFAULT		= $02
EXIT		= $04
EDITABLE	= $08
RBUTTON		= $10
LASTOB		= $20
TOUCHEXIT	= $40
HIDETREE	= $80
INDIRECT	= $100
FL3DMASK	= $600
FL3DNONE	= $000
FL3DIND		= $200
FL3DBAK		= $400
FL3DACT		= $600
;
;------------------------------------
;	Object states
;
NORMAL		= $00
SELECTED	= $01
CROSSED		= $02
CHECKED		= $04
DISABLED	= $08
OUTLINED	= $10
SHADOWED	= $20
;
;----------------------------------------------------------------------------
; 	Function codes for wind_set/wind_get
;
WF_KIND		= $01	;GET: p1 = window gadget flags
WF_NAME		= $02	;p1.p2 = *title
WF_INFO		= $03	;p1.p2 = *info
WF_WORKXYWH	= $04	;p1..p4 = x.y.w.h
WF_CURRXYWH	= $05	;p1..p4 = x.y.w.h
WF_PREVXYWH	= $06	;p1..p4 = x.y.w.h
WF_FULLXYWH	= $07	;p1..p4 = x.y.w.h
WF_HSLIDE	= $08	;p1 = horizontal slider pos 1..1000
WF_VSLIDE	= $09	;p1 = vertical slider pos 1..1000
WF_TOP		= $0A	;p1 = handle of topped window
WF_FIRSTXYWH	= $0B	;p1..p4 = x.y.w.h of first rectangle \/ p3=p4=0 means
WF_NEXTXYWH	= $0C	;p1..p4 = x.y.w.h of next rectangle  /\ end of list
WF_RESVD	= $0D
WF_NEWDESK	= $0E	;p1.p2 = *desktop object tree
WF_HSLSIZE	= $0F	;p1 = horizontal slider size 1..1000
WF_VSLSIZE	= $10	;p1 = vertical slider size 1..1000
WF_SCREEN	= $11	;p1.p2 = *buffer  p3.p4 = bytes  of aes menu/alert buffer
WF_COLOR	= $12
WF_DCOLOR	= $13
WF_OWNER	= $14	;MTOS GET: p1=ap_id p2=0(closed) p3=wind_above p4=wind_below
;	--------
WF_BEVENT	= $18	;MTOS: p1=1(untoppable)/0(normal)
WF_BOTTOM	= $19	;MTOS: p1 = handle of bottom window (excl desktop background)
WF_ICONIFY	= $1A	;MTOS GET: p1=0(normal)/non_0(iconified)  p2.p3=w.h of icon
WF_UNICONIFY	= $1B	;MTOS GET: p1..p4 = x.y.w.h from before iconification
;	--------
WF_TOOLBAR	= $1E	;MTOS: p1.p2 = *tree
WF_FTOOLBAR	= $1F	;MTOS GET:p1..p4 = x.y.w.h first rectangle \/ p3=p4=0
WF_NTOOLBAR	= $20	;MTOS GET:p1..p4 = x.y.w.h next rectangle  /\ at end
;
;
;
;----------------------------------------------------------------------------
;	Shape codes for graf_mouse
;
ARROW		= $00
TEXT_CRSR	= $01
HOURGLASS	= $02
BEE		= $02
POINT_HAND	= $03
FLAT_HAND	= $04
THIN_CROSS	= $05
THICK_CROSS	= $06
OUTLN_CROSS	= $07
USER_DEF	= $FF
M_OFF		= $100
M_ON		= $101
;----------------------------------------------------------------------------
;	Macro definitions
;----------------------------------------------------------------------------
GEM_links	MACRO
		_unidef	aes_redraw
		_unidef	sub_aes,sub_vdi,aes_data,vdi_data
		ENDM	;GEM_links
;------------------------------------
aes_redraw	MACRO
	_uniref	aes_redraw
	ifeq	huge_program
	bsr	aes_redraw_code
	elseif
	jsr	aes_redraw_code
	endc
	ENDM	;aes_redraw
;------------------------------------
aes_redraw_code	MACRO
	lea	zz_menu0(pc),a1
	lea	zz_menu1(pc),a2
	move	#14*24/4-1,d2
.movetree:
	move.l	(a1)+,(a2)+
	dbra	d2,.movetree
	lea	zz_menu1(pc),a2
	move	#14-1,d2
.obfix_loop:
	gem_aes	rsrc_obfix,d2,(a2)
	dbra	d2,.obfix_loop
;
	gem_aes	wind_get,!,#5
	move	intout+2(pc),zz_wx
	move	intout+4(pc),zz_wy
	move	intout+6(pc),zz_ww
	move	intout+8(pc),zz_wh
	gem_aes	form_dial,#0,!,!,!,!,zz_wx,zz_wy,zz_ww,zz_wh
	IFD	acc_flag
	tst	acc_flag
	bne.s	.done_menu_bar
	ENDC
	gem_aes	menu_bar,#1,zz_menu1
	gem_aes	menu_bar,!,zz_menu1
.done_menu_bar
	gem_aes	form_dial,#3,!,!,!,!,zz_wx,zz_wy,zz_ww,zz_wh
	rts
;
;NB:	There are 14 objects in each menu tree below
;
;'zz_menu0' is kept unaltered (no rsrc_obfix) to allow dynamic changes
;in font size and resolution between redraws
;
zz_menu0:
	dc.w	-1,1,4
	dc.w	25,0,0		*0*
	dc.l	0
	dc.w	0,0,80,25
;
	dc.w	4,2,2
	dc.w	20,0,0		*1*
	dc.l	$1100
	dc.w	0,0,80,$201
;
	dc.w	1,3,3
	dc.w	25,0,0		*2*
	dc.l	0
	dc.w	2,0,8,$301
;
	dc.w	2,-1,-1
	dc.w	32,0,0		*3*
	dc.l	zz_text1
	dc.w	0,0,8,$301
;
	dc.w	0,5,5
	dc.w	25,0,0		*4*
	dc.l	0
	dc.w	0,$301,80,23
;
	dc.w	4,6,13
	dc.w	20,0,0		*5*
	dc.l	$FF1100
	dc.w	2,0,17,8
;
	dc.w	7,-1,-1
	dc.w	28,0,0		*6*
	dc.l	zz_text2
	dc.w	0,0,17,1
;
	dc.w	8,-1,-1
	dc.w	28,0,8		*7*
	dc.l	zz_text3
	dc.w	0,1,17,1
;
	dc.w	9,-1,-1
	dc.w	28,0,0		*8*
	dc.l	zz_text4
	dc.w	0,2,17,1
;
	dc.w	10,-1,-1
	dc.w	28,0,0		*9*
	dc.l	zz_text5
	dc.w	0,3,17,1
;
	dc.w	11,-1,-1
	dc.w	28,0,0		*10*
	dc.l	zz_text6
	dc.w	0,4,17,1
;
	dc.w	12,-1,-1
	dc.w	28,0,0		*11*
	dc.l	zz_text7
	dc.w	0,5,17,1
;
	dc.w	13,-1,-1
	dc.w	28,0,0		*12*
	dc.l	zz_text8
	dc.w	0,6,17,1
;
	dc.w	5,-1,-1
	dc.w	28,32,0		*13*
	dc.l	zz_text9
	dc.w	0,7,17,1
zz_menu0_end:
;
zz_menu1:
	ds.b	zz_menu0_end-zz_menu0
;
;	Text data
;
zz_text1	dc.b	' Redraw',0
zz_text2	dc.b	'  Information... ',0
zz_text3	dc.b	'-----------------',0
zz_text4	dc.b	'  Accessory   1  ',0
zz_text5	dc.b	'  Accessory   2  ',0
zz_text6	dc.b	'  Accessory   3  ',0
zz_text7	dc.b	'  Accessory   4  ',0
zz_text8	dc.b	'  Accessory   5  ',0
zz_text9	dc.b	'  Accessory   6  ',0
		dc.b	0,0
;
;	window data
;
zz_wx:	ds.w	1
zz_wy:	ds.w	1
zz_ww	ds.w	1
zz_wh:	ds.w	1
;
	ENDM	;aes_redraw
;------------------------------------
vq_aes	MACRO
	move	#$c9,d0
	trap	#2
	sub	#$c9,d0
	ext.l	d0
	ENDM
;------------------------------------
_appl_yield	MACRO
	move.l	#$c9,d0
	trap	#2
	ENDM
;------------------------------------
vq_driver	MACRO
	pea	(-1).w
	trap	#2
	ENDM
;------------------------------------
vq_gdos	MACRO
	moveq	#-2,d0
	trap	#2
	addq	#2,d0
	ext.l	d0
	ENDM
;------------------------------------
vq_vgdos	MACRO
	moveq	#-2,d0
	trap	#2
	ENDM
;------------------------------------
o_head	MACRO	tree_pref,name,next,child_1,child_x
	ifnd	\1_o_df
\1_o_base:
\1_o_df	set	-1
	endc
\1_\2	= (*-\1_o_base)/24
	ifne	(*-\1_o_base-24*\1_\2)
	FAIL	Object '\2' misaligned in tree '\1'
	endc
	ifc	'?','\3'
	dc.w	-1
	elseif
	dc.w	\1_\3
	endc
	ifc	'?','\4'
	dc.w	-1
	elseif
	dc.w	\1_\4
	endc
	ifc	'?','\5'
	dc.w	-1
	elseif
	dc.w	\1_\5
	endc
	ENDM		;ends	MACRO o_head
;
o_name	MACRO	tree_pref,name
	ifnd	\1_o_df
\1_o_base:
\1_o_df	set	-1
	endc
\1_\2	= (*-\1_o_base)/24
	ENDM		;ends	MACRO o_name
;------------------------------------
__inaes	MACRO	op,v1,v2,v3,v4,v5,v6,v7,v8,v9,va
__ind	set	(\1)&_ind	;bit 30 flags indirection of addrin's
__aesii	set	(\1)>>20&255	;sintin   = bits 27..20
__aesio	set	(\1)>>16&15	;sintout  = bits 19..16
__aesai	set	(\1)>>12&15	;saddrin  = bits 15..12
__aesao	set	(\1)>>08&15	;saddrout = bits 11..8
__aesop	set	(\1)&255	;opcode   = bits  7..0
__stoff	set	0
	ifne	0<__aesii
	lea	intin,a0
	__stint	\2
	ifeq	$19=__aesop
	ifne	1<__aesii
	__stint	\3
	ifeq	$69=__aesop
	ifne	2<__aesii
	__stint	\4
	ifne	3<__aesii
	__stint	\5
	ifne	4<__aesii
	__stint	\6
	ifne	5<__aesii
	__stint	\7
	ifne	6<__aesii
	__stint	\8
	ifne	7<__aesii
	__stint	\9
	ifne	8<__aesii
	__stint	\a
	elseif
	gemaddrin	\a
	endc	;9ii
	elseif
	gemaddrin	\9
	endc	;8ii
	elseif
	gemaddrin	\8
	endc	;7ii
	elseif
	gemaddrin	\7
	endc	;6ii
	elseif
	gemaddrin	\6
	endc	;5ii
	elseif
	gemaddrin	\5,\6
	endc	;4ii
	elseif
	gemaddrin	\4,\5
	endc	;3ii
	elseif
;special for wind_set(wind_id,func,..)		intin[2]... untouched
	endc	;<>wind_set
	elseif
	gemaddrin	\3,\4
	endc	;2ii
	elseif
;special for evnt_multi(flags,..,*msgbuf)	intin[1]... untouched
	gemaddrin	\3
	endc	;<>evnt_multi
	elseif
	gemaddrin	\2,\3,\4
	endc	;1ii
	ENDM	;__inaes
;------------------------------------
__stint	MACRO	data
	ifc	'','\1'
	FAIL	Missing word operand in AES call
	mexit
	endc
	ifc	'()','\1'
__stoff	set	__stoff+2
	mexit
	endc
	ifne	__stoff
	add	#__stoff,a0
__stoff	set	0
	endc
	ifc	'!','\1'
	clr	(a0)+
	mexit
	endc
	ifc	'?','\1'
	move	#-1,(a0)+
	mexit
	endc
	move	\1,(a0)+
	ENDM	;__stint
;------------------------------------
__stlon	MACRO	data
	ifc	'','\1'
	FAIL	Missing long operand in AES call
	mexit
	endc
	ifc	'()','\1'
__stoff	set	__stoff+4
	mexit
	endc
	ifne	__stoff
	add	#__stoff,a0
__stoff	set	0
	endc
	ifc	'!','\1'
	clr.l	(a0)+
	mexit
	endc
	ifc	'?','\1'
	move.l	#-1,(a0)+
	mexit
	endc
	move.l	\1,(a0)+
	ENDM	;__stlon
;------------------------------------
;
__stptr	MACRO	data,dest
	ifc	'','\1'
	FAIL	Missing pointer operand in AES call
	mexit
	endc
	ifc	'()','\1'
	mexit
	endc
	ifc	'!','\1'
	clr.l	\2
	mexit
	endc
	ifc	'?','\1'
	move.l	#-1,\2
	mexit
	endc
	pea	\1
	move.l	(sp)+,\2
	ENDM	;__stptr
;------------------------------------
gemaddrin	MACRO	v1,v2,v3
	ifne	0<__aesai
	ifne	__ind<>0
	lea	addrin,a0
	__stlon	\1
	ifne	1<__aesai
	__stlon	\2
	ifne	2<__aesai
	__stlon	\3
	endc	;2<ai
	endc	;1<ai
	elseif	;__ind
	__stptr	\1,addrin
	ifne	1<__aesai
	__stptr	\2,addrin+4
	ifne	2<__aesai
	__stptr	\3,addrin+8
	endc	;2<ai
	endc	;1<ai
	endc	;__ind
	endc	;0<ai
	ENDM	;gemaddrin
;------------------------------------
gem_aes	MACRO	op,v1,v2,v3,v4,v5,v6,v7,v8,v9,va
	__inaes	\1,\2,\3,\4,\5,\6,\7,\8,\9,\a,\b
	sub_aes	#\1
	ENDM	;gem_aes
;------------------------------------
sub_aes	MACRO	v1
	_uniref	sub_aes
	move.l	\1,d0
	ifeq	huge_program
	bsr	sub_aes_code
	elseif
	jsr	sub_aes_code
	endc
	ENDM	;sub_aes
;------------------------------------
sub_aes_code	MACRO
	_uniref	aes_data
	lea	contrl,a0
	clr.b	(a0)+		;opcode is < $100
	move.b	d0,(a0)+	;opcode = bits 7..0
	clr.b	d0
	lsl.l	#7,d0		;bits 31..25 are unused
	rol.l	#5,d0
	move	d0,(a0)+	;sintin   = bits 24..20
	clr	d0
	rol.l	#4,d0
	move	d0,(a0)+	;sintout  = bits 19..16
	clr	d0
	rol.l	#4,d0
	move	d0,(a0)+	;saddrin  = bits 15..12
	clr	d0
	rol.l	#4,d0
	move	d0,(a0)+	;saddrout = bits 11..8
	move.l	aesptr,d1
	move	#$c8,d0
	trap	#2
	move.l	intout,d0
	swap	d0		;d0 = intout[1]<<16+intout[0]
	move.l	addrout,d1	;d1 = addrout[0]
	rts
	ENDM	;sub_aes_code
;------------------------------------
sub_vdi	MACRO	function,handle
	_uniref	sub_vdi
	move	\2,d1
	move.l	\1,d0
	ifeq	huge_program
	bsr	sub_vdi_code
	elseif
	jsr	sub_vdi_code
	endc
	ENDM	;sub_vdi
;------------------------------------
sub_vdi_code	MACRO
	_uniref	vdi_data
	lea	contrl,a0
	clr.b	(a0)
	move.b	d0,1(a0)	;opcode = bits 7..0
	clr.b	d0
	rol.l	#8,d0
	cmp.b	#$ff,d0
	beq.s	.noptsin
	move	d0,2(a0)	;s_ptsin  = bits 31..24
.noptsin:
	clr	d0
	rol.l	#8,d0
	cmp.b	#$ff,d0
	beq.s	.nointin
	move	d0,6(a0)	;s_intin  = bits 23..16
.nointin:
	clr	d0
	rol.l	#8,d0
	bclr	#7,d0		;handle flagged by bit 15
	bne.s	.nohandle
	move	d1,12(a0)
.nohandle:
	cmp.b	#$7f,d0
	beq.s	.nosubop
	move	d0,10(a0)	;subop = bits 14..8
.nosubop:
	move.l	vdiptr,d1
	move	#$73,d0
	trap	#2
	move.l	intout,d0
	swap	d0		;d0 = intout[1]<<16+intout[0]
	move.l	ptsout,d1	;d1 = ptsout[0]
	rts
	ENDM	;sub_vdi_code
;------------------------------------
aes_data_code	MACRO
aesptr:		dc.l	aes_pb
aes_pb:
aespb:		dc.l	contrl,global,intin,intout,addrin,addrout
global:
apversion:	dc.w	0
apcount:	dc.w	0
ap_id:		dc.w	0
apprivate:	dc.l	0
apptree:	dc.l	0
ap1resv:	dc.l	0
ap2resv:	dc.l	0
ap3resv:	dc.l	0
ap4resv:	dc.l	0
addrin:		dc.l	0,0,0
addrout:	dc.l	0
		ENDM	;aes_data_code
;------------------------------------
vdi_data_code	MACRO
vdiptr:		dc.l	vdi_pb
vdi_pb:
vdipb:		dc.l	contrl,intin,ptsin,intout,ptsout
		ENDM	;vdi_data_code
;----------------------------------------------------------------------------
	endc	;RA_GEM_defined
;----------------------------------------------------------------------------
;End of file:	RA_GEM.I
;----------------------------------------------------------------------------
