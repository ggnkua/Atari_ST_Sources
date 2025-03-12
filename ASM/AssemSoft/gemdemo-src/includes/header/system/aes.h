	ifnd	AES_H
AES_H:		set 1
**********************************
* GEM AES ROUTINES AND CONSTANTS *
**********************************

* the AES functions
APPL_INIT:	= 10	;Initializes an application (returns application ID)
APPL_READ:	= 11	;Read data from message pipe
APPL_WRITE:	= 12	;Write data to message pipe
APPL_FIND:	= 13	;Locate a system process
APPL_TPLAY:	= 14	;Play back recorded events
APPL_TRECORD:	= 15	;Record keyboard and mouse events
APPL_SEARCH:	= 18	
APPL_EXIT:	= 19	
EVNT_KEYBD:	= 20
EVNT_BUTTON:	= 21
EVNT_MOUSE:	= 22
EVNT_MESAG:	= 23
EVNT_TIMER:	= 24
EVNT_MULTI:	= 25
EVNT_DCLICK:	= 26
MENU_BAR:	= 30
MENU_ICHECK:	= 31
MENU_IENABLE:	= 32
MENU_TNORMAL:	= 33
MENU_TEXT:	= 34
MENU_REGISTER:	= 35
MENU_POPUP:	= 36
MENU_ATTACH:	= 37
MENU_ISTART:	= 38
MENU_SETTINGS:	= 39
OBJC_ADD:	= 40
OBJC_DELETE:	= 41
OBJC_DRAW:	= 42
OBJC_FIND:	= 43
OBJC_OFFSET:	= 44
OBJC_ORDER:	= 45
OBJC_EDIT:	= 46
OBJC_CHANGE:	= 47
OBJ_SYSVAR:	= 48
FORM_DO:	= 50
FORM_DIAL:	= 51
FORM_ALERT:	= 52
FORM_ERROR:	= 53
FORM_CENTER:	= 54
FORM_KEYBD:	= 55
FORM_BUTTON:	= 56

GRAF_RUBBERBOX: = 70
GRAF_DRAGBOX:	= 71
GRAF_MOVEBOX	= 72
GRAF_GROWBOX	= 73
GRAF_SHRINKBOX	= 74
GRAF_WATCHBOX	= 75
GRAF_SLIDEBOX	= 76
GRAF_HANDLE	= 77
GRAF_MOUSE	= 78
GRAF_MKSTATE	= 79
SCRP_READ	= 80
SCRP_WRITE	= 81
FSEL_INPUT	= 90
FSEL_EXINPUT	= 91
WIND_CREATE	= 100
WIND_OPEN	= 101
WIND_CLOSE	= 102
WIND_DELETE	= 103
WIND_GET	= 104
WIND_SET	= 105
WIND_FIND	= 106
WIND_UPDATE	= 107
WIND_CALC	= 108
WIND_NEW	= 109
RSRC_LOAD	= 110
RSRC_FREE	= 111
RSRC_GADDR	= 112
RSRC_SADDR	= 113
RSRC_OBFIX	= 114
RSRC_RCFIX	= 115
SHEL_READ	= 120
SHEL_WRITE	= 121
SHEL_GET	= 122
SHEL_PUT	= 123
SHEL_FIND	= 124
SHEL_ENVRN	= 125
APPL_GETINFO	= 130


********	WIND_SET, WIND_GET MODES
wf_name		= 2
wf_info		= 3
wf_workxywh	= 4
wf_currxywh	= 5
wf_prevxywh	= 6
wf_fullxywh	= 7
wf_hslide	= 8
wf_vslide	= 9
wf_top		= 10
wf_firstxywh	= 11
wf_nextxywh	= 12
wf_newdesk	= 14
wf_hslize	= 15
wf_vslize	= 16
wf_screen	= 17
wf_color	= 18
wf_dcolor	= 19
wf_owner	= 20
wf_bevent	= 24
wf_bottom	= 25
wf_iconfy	= 26
wf_uniconfy	= 27
wf_toolbar	= 30
wf_ftoolbar	= 31
wf_ntoolbar	= 32

********	Window "widgets" bits
NAME		= 0
CLOSER		= 1
FULLER		= 2
MOVER		= 3
INFO		= 4
SIZER		= 5
UPARROW		= 6
DNARROW		= 7
VSLIDE		= 8
LFARROW		= 9
RTARROW		= 10
HSLIDE		= 11
SMALLER		= 14

********	MESSAGE TYPES
mn_selected	= 10
mn_xselected	= 11 ;Invented by me.. is it ok to use 11?
wm_xredraw	= 12 ;Invented by me..
wm_weupdate	= 13 ;Invented by be
wm_redraw	= 20
wm_topped	= 21
wm_closed	= 22
wm_fulled	= 23
wm_arrowed	= 24
wm_hslid	= 25
wm_vslid	= 26
wm_sized	= 27
wm_moved	= 28
wm_untopped	= 30
wm_ontop	= 31
wm_bottom	= 33
wm_iconfy	= 34
wm_uniconfy	= 35
wm_alliconfy	= 36
wm_toolbar	= 37
ac_open		= 40
ac_close	= 41
ap_term		= 50
ap_tfail	= 51
ap_reschg	= 57
shut_completed	= 60
resch_completed	= 61
ap_dragdrop	= 63
sh_wdraw	= 72
ch_exit		= 90

**********	WA_ messages
WA_UPPAGE:	= 0
WA_DNPAGE:	= 1
WA_UPLINE:	= 2
WA_DNLINE:	= 3
WA_LFPAGE:	= 4
WA_RTPAGE:	= 5
WA_LFLINE:	= 6
WA_RTLINE:	= 7

**********	Event multi event bits
MU_KEYBD	= 0
MU_BUTTON	= 1
MU_M1		= 2
MU_M2		= 3
MU_MESAG	= 4
MU_TIMER	= 5

*********	Keyboard shift-states
ks_rshft	= 0
ks_lshft	= 1
ks_ctrl		= 2
ks_alt		= 3

*********	Mouse Button state/mask
bm_left		= 0
bm_right	= 1
bm_middle	= 2

bs_left		= 0
bs_right	= 1
bs_middle	= 2

;rscobj_size	= 24	;Size of one object in a resrouce tree

*********	OBJECT structure

	rsset 0
ob_next		rs.w 1	;1st child object (one level up)
ob_head		rs.w 1	;last child	(one level up)
ob_tail		rs.w 1	;Next object on same level
ob_type		rs.w 1
ob_flags	rs.w 1
ob_state	rs.w 1
ob_spec		rs.l 1
ob_x		rs.w 1
ob_y		rs.w 1
ob_width	rs.w 1
ob_height	rs.w 1
ob_ssize	= __RS


**********	OBJECT TYPES
G_BOX		= 20
G_TEXT		= 21
G_BOXTEXT	= 22
G_IMAGE		= 23
G_PROGDEF	= 24
G_IBOX		= 25
G_BUTTON	= 26
G_BOXCHAR	= 27
G_STRING	= 28
G_FTEXT		= 29
G_FBOXTEXT	= 30
G_ICON		= 31
G_TITLE		= 32
G_CICON		= 33

**********	Extended Object types defined by me

;when ob_type = G_STRING
XO_3DMENUSEP	= 28

;When ob_type = G_BOX

;-- Sliders --
XO_SLIDE	= 3	;Slider without arrows
XO_ASLIDE	= 4	;Slider with arrows
XO_SPARNT	= 5	;was 1
XO_SCHILD	= 6	;was 2
XO_SULARW	= 7	;Arrow, up/left
XO_SDRARW	= 8	;Arrow, Down/right

;-- Dialog-Folders --
XO_FLDRPARENT	= 10
XO_FLDRBAR	= 11
XO_FLDRTITLE	= 12
XO_FLDRENTRY	= 13

;-- Editable field --
XO_EDITABLE	= 20
XO_TEXTFRAME	= 21


**********	RSRC_GADDR modes
R_TREE		= 0
R_OBJECT	= 1
R_TEDINFO	= 2
R_ICONBLOCK	= 3
R_BITBLK	= 4
R_STRING	= 5
R_IMAGEDATA	= 6
R_OBSPEC	= 7
R_TEPTEXT	= 8
R_TEPTMPLT	= 9
R_TEPVALID	= 10
R_IBPMASK	= 11
R_IBPDATA	= 12
R_IBPTEXT	= 13
R_BIPDATA	= 14
R_FRSTR		= 15
R_FRIMG		= 16

R_TREE_XTINF	= 17

**********	OBJECT FLAGS
OF_SELECTABLE	= 0
OF_DEFAULT	= 1
OF_EXIT		= 2
OF_EDITABLE	= 3
OF_RBUTTON	= 4
OF_LASTOB	= 5
OF_TOUCHEXIT	= 6
OF_HIDETREE	= 7
OF_INDIRECT	= 8
OF_FL3DIND	= 9
OF_FL3DACT	= 10
OF_SUBMENU	= 11
OF_12		= 12
OF_13		= 13
OF_14		= 14
OF_15		= 15

OF_EDITING	= OF_12

*********	OBJECT STATE FLAGS
OS_SELECTED	= 0
OS_CROSSED	= 1
OS_CHECKED	= 2
OS_DISABLED	= 3
OS_OUTLINED	= 4
OS_SHADOWED	= 5
OS_WHITEBAK	= 6
OS_DRAW3D	= 7

;MY OWN DEFS
OS_DDIS3D	= 8

********* Structure TEDINFO
	rsset 0
te_ptext	rs.l 1
te_ptmplt	rs.l 1
te_pvalid	rs.l 1
te_font		rs.w 1
te_fontid	rs.w 1
te_just		rs.w 1
te_color	rs.w 1
te_fontsize	rs.w 1
te_thickness	rs.w 1
te_txtlen	rs.w 1
te_tmplen	rs.w 1
te_ssize	= __RS

********* Structure BITBLK
	rsset 0
bi_pdata	rs.l 1
bi_wb		rs.w 1
bi_hl		rs.w 1
bi_x		rs.w 1
bi_y		rs.w 1
bi_color	rs.w 1
bi_ssize	= __RS

********* Structure ICONBLK
	rsset 0
ib_pmask	rs.l 1
ib_pdata	rs.l 1
ib_ptext	rs.l 1
ib_char		rs.w 1
ib_xchar	rs.w 1
ib_ychar	rs.w 1
ib_xicon	rs.w 1
ib_yicon	rs.w 1
ib_wicon	rs.w 1
ib_hicon	rs.w 1
ib_xtext	rs.w 1
ib_ytext	rs.w 1
ib_wtext	rs.w 1
ib_htext	rs.w 1
ib_ssize	= __RS

********* Structure CICONBLK
	rsset ib_ssize
cicon		rs.l 1
ciconblk_ssize	= __RS

********* Structure CICON
	rsset 0
num_planes	rs.w 1
col_data	rs.l 1
col_mask	rs.l 1
sel_data	rs.l 1
sel_mask	rs.l 1
next_res	rs.l 1
cicon_ssize	= __RS

********* Structure rsh_ciconblk
monoicon	rsset ib_ssize
n_cicons	rs.l 1	;This where the number of cicons are placed in the resource file
mono_data	rs.w 1	;monochrome data starts here

********* Structure APPLBLK
	rsset 0
ab_code:	rs.l 1	;Pointer to routine that draws the object, called by AES
ab_param:	rs.l 1	;This will contain the original ob_spec pointer/data

abp_ob_type:	rs.w 1	;This element is added by me (extended ob_type)
abp_whofst:	rs.w 1	;
abp_xywhofst:	rs.w 1	;
abp_flags:	rs.w 1	;Original object flags (cause we need to clr the 3d bits)
abp_objscol:	rs.w 1	;Color to use when object is selected
;abp_parent:	rs.w 1	;Parent object of the group this object belongs too. (sliders, )
abp_ID:		rs.l 1	;ID
abp_cobj:	rs.l 1	;Address 

abp_misc_f:	rs.l 1	;Misc flags - meaning depends on object type..
abp_misc_p:	rs.l 1	;Misc Pointer - meaning depends on object type..
;abp_function:	rs.l 1	;If used, pointer to a routine to execute - depends on object
abp_formdo:	rs.l 1	;Formdo function for this object.
abp_keybd:	rs.l 1	;Keyboard function for this object
abp_xobspec:	rs.l 1	;eXtended OBject SPEC pointer
abp_attach:	rs.l 1	;Pointer to a linked list of xobspec-pointers attached to this object
ab_ssize:	= __RS

;------------------------------------------------------
;-- Extended obspec (abp_xobspec) for slider objects --
;------------------------------------------------------
spbf_usiz:	= 0
spbf_upos:	= 1

;Slider Parameter Block - used by slider objects
	rsreset
xos_size:	rs.w 1	;Size
xos_type:	rs.w 1	;contains the same as abp_ob_type
xos_parent:	rs.w 1	;Parent of this slider structure
xos_aindex:	rs.w 1
xos_tree:	rs.l 1	;Tree
xos_atree:	rs.l 1
xos_arrower:	rs.l 1	;Arrower function
xos_pager:	rs.l 1	;Pager function
xos_dragger:	rs.l 1	;Drag function
xos_update:	rs.l 1	;Update function

xos_ssize:	= __RS

;......................................................................
;Flags..
spbf_orient:	= 0	;This bit is 0 for a horizontal, or 1 for a vertical slider.

		rsset xos_ssize
spb_flags:	rs.l 1
spb_relp2realp	rs.l 1
spb_dir:	rs.b 1
spb_orient:	rs.b 1
spb_rels:	rs.w 1
spb_relp:	rs.w 1
spb_total:	rs.l 1
spb_visible:	rs.l 1
spb_kvisible:	rs.l 1
spb_first:	rs.l 1

spb_ssize	= __RS

;......................................................................
		rsset xos_ssize
xedi_flags:	rs.l 1
xedi_vslide:	rs.l 1
xedi_hslide:	rs.l 1
xedi_ssize:	= __RS

;......................................................................
		rsset xos_ssize
xedl_flags:	rs.l 1
xedl_vslide:	rs.l 1
xedl_hslide:	rs.l 1
xedl_sszie:	= __RS

;......................................................................
	rsreset
atob_next:	rs.l 1
atob_xos:	rs.l 1

********
abf_cursenable	= 0	;Cursor enable (0 = not enabled, 1 = enabled)
abf_cursvisble	= 1	;Cursor visible (0 = cursor offscreen, 1 = cursor onscreen)
abf_cursstate	= 2	;Cursor status (0 = off - don't draw, 1 = on - draw)


********* Structure PARAMBLK
	rsset 0
pb_tree		rs.l 1
pb_obj		rs.w 1
pb_prevstate	rs.w 1
pb_currstate	rs.w 1
pb_x		rs.w 1
pb_y		rs.w 1
pb_w		rs.w 1
pb_h		rs.w 1
pb_xc		rs.w 1
pb_yc		rs.w 1
pb_wc		rs.w 1
pb_hc		rs.w 1
pb_param	rs.l 1
pb_ssize	= __RS

********* Structure RSC HEADER
	rsset 0
rsh_vrsn	rs.w 1	;Version number or the .rsc file
rsh_object	rs.w 1	;Offset to OBJECT structures
rsh_tedinfo	rs.w 1	;Offset to TEDINFO structures
rsh_iconblk	rs.w 1	;Offset to ICONBLK structures
rsh_bitblk	rs.w 1	;Offset to BITBLK structures
rsh_frstr	rs.w 1	;Offset to string pointer table
rsh_string	rs.w 1	;Offset to string data
rsh_imdata	rs.w 1	;Offset to Image data
rsh_frimg	rs.w 1	;Offset to Image pointer table
rsh_trindex	rs.w 1	;Offset to tree pointer table
rsh_nobs	rs.w 1	;Number of OBJECTS in the file
rsh_ntree	rs.w 1	;Number of TREEs in the file
rsh_nted	rs.w 1	;Number of TEDINFOs in the file
rsh_nib		rs.w 1	;Number of ICONBLKs in the file
rsh_nbb		rs.w 1	;Number of BITBLKs in the file
rsh_nstring	rs.w 1	;Number of free strings in the file
rsh_nimages	rs.w 1	;Number of free images in the file
rsh_rssize	rs.w 1	;Size of the file in bytes

;This part is used if extended .rsc file
	rsset 0
filesize	rs.l 1
cicon_offset	rs.l 1
cicon_rgbtab	rs.l 1




*********** Structure used by my custom objects (cob = Custon OBject stucture)

	IFD	a6_bss
	rsset end_aesvdipb
	ELSEIF

	rsset 0
aespb		rs.l 1
vdipb		rs.l 1

***************VDI arrays
contrl		rs.w 12
intin		rs.w 128
ptsin		rs.w 256
intout		rs.w 128
ptsout		rs.w 12

********* AES Arrays
control		rs.w 0
opcode		rs.w 1
sintin		rs.w 1
sintout		rs.w 1
saddrin		rs.w 1
saddrout	rs.w 1

global		rs.w 0
ap_version	rs.w 2
ap_count	rs.w 2
ap_id		rs.w 2
ap_private	rs.w 4
ap_ptree	rs.w 4
ap_1resv	rs.w 4
ap_2resv	rs.w 4
ap_3resv	rs.w 4
ap_4resv	rs.w 4

int_in		rs.w 128
int_out		rs.w 128
addrin		rs.l 5
addrout		rs.l 5
	ENDC

cob_cluttoxx	rs.l 1
cob_linebuff	rs.l 1	;Pointer to a buffer to use when printing text
cob_lbufsize	rs.w 1	;Size of the buffer

cob_aes_v	rs.w 1	;AES version
cob_gdos_v	rs.l 1	;GDos version
cob_vditxt	rs.l 1	;VDI text print opcode
cob_grafh	rs.w 1	;Graf Handle
cob_vdih	rs.w 1	;VDI handle
cob_scrnx	rs.w 1	;Screen vertical size
cob_scrny	rs.w 1	;Screen horizontal size
cob_planes	rs.w 1	;Color depth
cob_bpg		rs.w 1	;Byte per "group" of pixels (one group = 16 pixels)
cob_scanlenght	rs.w 1	;Lenght of a scanling in bytes
cob_dformat	rs.w 1	;Device format of the current video hardware.
		;0 = couldn't be determined
		;1 = standard Motorola format
		;2 = Intel byteswapped format.
		;3 = Crazy Dots 15-bit
		;4 = motorola 15-bit
		
	;AES Big font info
cob_aebfnt_pnt	rs.w 1	;Size of the AES big font in points
cob_aebfnt_id	rs.w 1	;ID of the AES big font
cob_aebfnt_type	rs.w 1	;0 = system font, 1 = outline font

	;AES Small font info
cob_aesfnt_pnt	rs.w 1	;Size of the AES small font in points
cob_aesfnt_id	rs.w 1	;ID of the AES small font
cob_aesfnt_type	rs.w 1	;0 = system font, 1 = outline font

cob_language	rs.w 1	

cob_clip_x	rs.w 1
cob_clip_y	rs.w 1
cob_clip_w	rs.w 1
cob_clip_h	rs.w 1

cob_3doffset	rs.w 1
cob_button	rs.w 1
cob_exit	rs.w 1
cob_default	rs.w 1
cob_outlined	rs.w 1
cob_3dobjcolor	rs.w 1	;Color of 3d objects
cob_3ddiscolor	rs.w 1
cob_3dtxtcolor	rs.w 1
cob_objcolor	rs.w 1	;Color of non-3d objects	
cob_wb_color	rs.w 1	;Color to use on WHITEBAK'ed objects
cob_ssize	= __RS

	endc	;AES_H
