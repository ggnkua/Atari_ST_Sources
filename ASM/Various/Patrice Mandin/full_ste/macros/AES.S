;	Macros AES

;	Objet

NORMAL	equ	0

SELECTABLE	equ	1
DEFAULT	equ	2
EXIT	equ	4
EDITABLE	equ	8
RBUTTON	equ	16
LASTOB	equ	32
TOUCHEXIT	equ	64
HIDETREE	equ	128
INDIRECT	equ	256

SELECTED	equ	1
CROSSED	equ	2
CHECKED	equ	4
DISABLED	equ	8
OUTLINED	equ	16
SHADOWED	equ	32

G_BOX	equ	20
G_TEXT	equ	21
G_BOXTEXT	equ	22
G_IMAGE	equ	23
G_USERDEF	equ	24
G_IBOX	equ	25
G_BUTTON	equ	26
G_BOXCHAR	equ	27
G_STRING	equ	28
G_FTEXT	equ	29
G_FBOXTEXT	equ	30
G_ICON	equ	31
G_TITLE	equ	32

;	Application services

AES_LARGEFONT	equ	0
AES_SMALLFONT	equ	1
AES_SYSTEM	equ	2
AES_LANGUAGE	equ	3
AES_PROCESS	equ	4
AES_PCGEM	equ	5
AES_INQUIRE	equ	6
AES_MOUSE	equ	8
AES_MENU	equ	9
AES_SHELL	equ	10
AES_WINDOW	equ	11
AES_MESSAGE	equ	12
AES_OBJECT	equ	13
AES_FORM	equ	14

APP_FIRST	equ	0
APP_NEXT	equ	1
APP_SYSTEM	equ	1
APP_APPLICATION	equ	2
APP_ACCESSORY	equ	4
APP_SHELL	equ	8

APPEVNT_TIMER	equ	0
APPEVNT_BUTTON	equ	1
APPEVNT_MOUSE	equ	2
APPEVNT_KEYBOARD	equ	3

;	Event

LEFT_BUTTON	equ	1
RIGHT_BUTTON	equ	2
MIDDLE_BUTTON	equ	4
OTHER_BUTTON	equ	8
K_RSHIFT	equ	1
K_LSHIFT	equ	2
K_CTRL	equ	4
K_ALT	equ	8

MN_SELECTED	equ	10
WM_REDRAW	equ	20
WM_TOPPED	equ	21
WM_CLOSED	equ	22
WM_FULLED	equ	23
WM_ARROWED	equ	24
WM_HSLID	equ	25
WM_VSLID	equ	26
WM_SIZED	equ	27
WM_MOVED	equ	28
WM_NEWTOP	equ	29
WM_UNTOPPED	equ	30
WM_ONTOP	equ	31
WM_BOTTOM	equ	33
WM_ICONIFY	equ	34
WM_UNICONIFY	equ	35
WM_ALLICONIFY	equ	36
WM_TOOLBAR	equ	37
AC_OPEN	equ	40
AC_CLOSE	equ	41
AP_TERM	equ	50
AP_TFAIL	equ	51
SHUT_COMPLETED	equ	60
RESCH_COMPLETED	equ	61
AP_DRAGDROP	equ	63
SH_WDRAW	equ	72
CH_EXIT	equ	90

WA_UPPAGE	equ	0
WA_DNPAGE	equ	1
WA_UPLINE	equ	2
WA_DNLINE	equ	3
WA_LFPAGE	equ	4
WA_RTPAGE	equ	5
WA_LFLINE	equ	6
WA_RTLINE	equ	7

MO_ENTER	equ	0
MO_LEAVE	equ	1

MU_KEYBD	equ	0
MU_BUTTON	equ	1
MU_M1	equ	2
MU_M2	equ	3
MU_MESAG	equ	4
MU_TIMER	equ	5

;	Form

FMD_START	equ	0
FMD_GROW	equ	1
FMD_SHRINK	equ	2
FMD_FINISH	equ	3

FERR_FILENOTFOUND	equ	2
FERR_PATHNOTFOUND	equ	3
FERR_NOHANDLES	equ	4
FERR_ACCESSDENIED	equ	5
FERR_LOWMEM	equ	8
FERR_BADENVIRON	equ	10
FERR_BADFORMAT	equ	11
FERR_BADDRIVE	equ	15
FERR_DELETEDIR	equ	16
FERR_NOFILES	equ	18

;	File selector

FSEL_CANCEL	equ	0
FSEL_OK	equ	1

;	Graphics

ARROW	equ	0
TEXT_CRSR	equ	1
BUSY_BEE	equ	2
POINT_HAND	equ	3
FLAT_HAND	equ	4
THIN_CROSS	equ	5
THICK_CROSS	equ	6
OUTLN_CROSS	equ	7
USER_DEF	equ	255
M_OFF	equ	256
M_ON	equ	257
M_SAVE	equ	258
M_LAST	equ	259
M_RESTORE	equ	260

;	Menu

ME_INQUIRE	equ	0
ME_ATTACH	equ	1
ME_REMOVE	equ	2

MENU_REMOVE	equ	0
MENU_INSTALL	equ	1
MENU_INQUIRE	equ	-1

UNCHECK	equ	0
CHECK	equ	1

DISABLE	equ	0
ENABLE	equ	1

SCROLL_LISTBOX	equ	-1

REG_NEWNAME	equ	-1

HIGHLIGHT	equ	0
UNHIGHLIGHT	equ	1

;	Object

NO_DRAW	equ	0
REDRAW	equ	1

ED_START	equ	0
ED_INIT	equ	1
ED_CHAR	equ	2
ED_END	equ	3

OO_LAST	equ	-1
OO_FIRST	equ	0

SV_INQUIRE	equ	0
SV_SET	equ	1
LK3DIND	equ	1
LK3DACT	equ	2
INDBUTCOL	equ	3
ACTBUTCOL	equ	4
BACKGRCOL	equ	5
AD3DVAL	equ	6

;	Ressource

R_TREE	equ	0
R_OBJECT	equ	1
R_TEDINFO	equ	2
R_ICONBLK	equ	3
R_BITBLK	equ	4
R_STRING	equ	5
R_IMAGEDATA	equ	6
R_OBSPEC	equ	7
R_TEPTEXT	equ	8
R_TEPMPLT	equ	9
R_TEPVALID	equ	10
R_IBPMASK	equ	11
R_IBPDATA	equ	12
R_IBPTEXT	equ	13
R_BIPDATA	equ	14
R_FRSTR	equ	15
R_FRIMG	equ	16

;	Scrap

;	Shell

SHEL_BUFSIZE	equ	-1

SWM_LAUCH	equ	0
SWM_LAUCHNOW	equ	1
SWM_LAUCHACC	equ	3
SWM_SHUTDOWN	equ	4
SWM_REZCHANGE	equ	5
SWM_BROADCAST	equ	7
SWM_ENVIRON	equ	8
SWM_NEWMSG	equ	9
SWM_AESMSG	equ	10

;	Window

WC_BORDER	equ	0
WC_WORK	equ	1

NAME	equ	1
CLOSER	equ	2
FULLER	equ	4
MOVER	equ	8
INFO	equ	16
SIZER	equ	32
UPARROW	equ	64
DNARROW	equ	128
VSLIDE	equ	256
LFARROW	equ	512
RTARROW	equ	1024
HSLIDE	equ	2048
SMALLER	equ	16384

WF_NAME	equ	2
WF_INFO	equ	3
WF_WORKXYWH	equ	4
WF_CURRXYWH	equ	5
WF_PREVXYWH	equ	6
WF_FULLXYWH	equ	7
WF_HSLIDE	equ	8
WF_VSLIDE	equ	9
WF_TOP	equ	10
WF_FIRSTXYWH	equ	11
WF_NEXTXYWH	equ	12
WF_NEWDESK	equ	14
WF_HSLSIZE	equ	15
WF_VSLSIZE	equ	16
WF_SCREEN	equ	17
WF_COLOR	equ	18
WF_DCOLOR	equ	19
WF_OWNER	equ	20
WF_BEVENT	equ	24
WF_BOTTOM	equ	25
WF_ICONIFY	equ	26
WF_UNICONIFY	equ	27
WF_UNICONIFYXYWH	equ	28
WF_TOOLBAR	equ	30
WF_FTOOLBAR	equ	31
WF_NTOOLBAR	equ	32

END_UPDATE	equ	0
BEG_UPDATE	equ	1
END_MCTRL	equ	2
BEG_MCTRL	equ	3

;	Fonctions

	TEXT

AES	MACRO	opcode
	move	#\1,d0
	JSR	_call_aes
	ENDM

APPL_INIT	MACRO
	AES	10
	move	_int_out,_ap_id
	ENDM

APPL_READ	MACRO	ap_id,length,message
	move	\1,_int_in
	move	\2,_int_in+2
	move.l	\3,_addr_in
	AES	11
	ENDM

APPL_WRITE	MACRO	ap_id,length,message
	move	\1,_int_in
	move	\2,_int_in+2
	move.l	\3,_addr_in
	AES	12
	ENDM

APPL_FIND	MACRO	fname
	move.l	\1,_addr_in
	AES	13
	ENDM

APPL_TPLAY	MACRO	mem,num,scale
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	14
	ENDM

APPL_TRECORD	MACRO	mem,num
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	15
	ENDM

APPL_SEARCH	MACRO	mode,fname
	move	\1,intin
	move.l	\2,_addr_in
	AES	18
	ENDM

APPL_EXIT	MACRO
	AES	19
	ENDM

APPL_GETINFO	MACRO	ap_gtype
	move	\1,_int_in
	AES	130
	ENDM

EVNT_KEYBD	MACRO
	AES	20
	ENDM

EVNT_BUTTON	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	AES	21
	move	_int_out+2,\4
	move	_int_out+4,\5
	move	_int_out+6,\6
	move	_int_out+8,\7
	ENDM

EVNT_MOUSE	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	AES	22
	move	_int_out+2,\6
	move	_int_out+4,\7
	move	_int_out+6,\8
	move	_int_out+8,\9
	ENDM

EVNT_MESAG	MACRO
	move.l	\1,_addr_in
	AES	23
	ENDM

EVNT_TIMER	MACRO
	move	\1,_int_in
	AES	24
	ENDM

EVNT_MULTI	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	move	\7,_int_in+12
	move	\8,_int_in+14
	move	\9,_int_in+16
	move	\A,_int_in+18
	move	\B,_int_in+20
	move	\C,_int_in+22
	move	\D,_int_in+24
	move	\E,_int_in+26
	move	\G,_int_in+28
	move	\H,_int_in+30
	move.l	\F,_addr_in
	AES	25
	move	_int_out+2,\I
	move	_int_out+4,\J
	move	_int_out+6,\K
	move	_int_out+8,\L
	move	_int_out+10,\M
	move	_int_out+12,\N
	ENDM

EVNT_DCLICK	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	AES	26
	ENDM

MENU_BAR	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	30
	ENDM

MENU_ICHECK	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	31
	ENDM

MENU_IENABLE	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	32
	ENDM

MENU_TNORMAL	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	33
	ENDM

MENU_TEXT	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move.l	\3,_addr_in+4
	AES	34
	ENDM

MENU_REGISTER	MACRO
	move	\1,_int_in
	move.l	\2,_addr_in
	AES	35
	ENDM

MENU_POPUP	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move.l	\3,_addr_in
	move.l	\4,_addr_in+4
	AES	36
	ENDM

OBJC_ADD	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	40
	ENDM

OBJC_DELETE	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	41
	ENDM

OBJC_DRAW	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\4,_int_in+4
	move	\5,_int_in+6
	move	\6,_int_in+8
	move	\7,_int_in+10
	AES	42
	ENDM

OBJC_FIND	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\4,_int_in+4
	move	\5,_int_in+6
	AES	43
	ENDM

OBJC_OFFSET	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	44
	move	_int_out+2,\3
	move	_int_out+4,\4
	ENDM

OBJC_ORDER	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	AES	45
	ENDM

OBJC_EDIT	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\5,_int_in+4
	AES	46
	move	_int_out+2,\4
	ENDM

OBJC_CHANGE	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\4,_int_in+4
	move	\5,_int_in+6
	move	\6,_int_in+8
	move	\7,_int_in+10
	move	\8,_int_in+12
	move	\9,_int_in+14
	AES	47
	ENDM

FORM_DO	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	50
	ENDM

FORM_DIAL	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	move	\7,_int_in+12
	move	\8,_int_in+14
	move	\9,_int_in+16
	AES	51
	ENDM

FORM_ALERT	MACRO
	move	\1,_int_in
	move.l	\2,_addr_in
	AES	52
	ENDM

FORM_ERROR	MACRO
	move	\1,_int_in
	AES	53
	ENDM

FORM_CENTER	MACRO
	move.l	\1,_addr_in
	AES	54
	move	_int_out+2,\2
	move	_int_out+4,\3
	move	_int_out+6,\4
	move	_int_out+8,\5
	ENDM

GRAF_RUBBERBOX	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	AES	70
	move	_int_out+2,\5
	move	_int_out+4,\6
	ENDM

GRAF_DRAGBOX	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	move	\7,_int_in+12
	move	\8,_int_in+14
	AES	71
	move	_int_out+2,\9
	move	_int_out+4,\A
	ENDM

GRAF_MOVEBOX	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	AES	72
	ENDM

GRAF_GROWBOX	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	move	\7,_int_in+12
	move	\8,_int_in+14
	AES	73
	ENDM

GRAF_SHRINKBOX	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	move	\7,_int_in+12
	move	\8,_int_in+14
	AES	74
	ENDM

GRAF_WATCHBOX	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\4,_int_in+4
	AES	75
	ENDM

GRAF_SLIDEBOX	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	move	\3,_int_in+2
	move	\4,_int_in+4
	AES	76
	ENDM

GRAF_HANDLE	MACRO
	AES	77
	move	_int_out+2,\1
	move	_int_out+4,\2
	move	_int_out+6,\3
	move	_int_out+8,\4
	ENDM

GRAF_MOUSE	MACRO
	move	\1,_int_in
	IFEQ	NARG-2
	move.l	\2,_addr_in
	ENDC
	AES	78
	ENDM

GRAF_MKSTATE	MACRO
	AES	79
	move	_int_in,\1
	move	_int_in+2,\2
	move	_int_in+4,\3
	move	_int_in+6,\4
	ENDM

SCRP_READ	MACRO
	move.l	\1,_addr_in
	AES	80
	ENDM

SCRP_WRITE	MACRO
	move.l	\1,_addr_in
	AES	81
	ENDM

FSEL_INPUT	MACRO
	move.l	\1,_addr_in
	move.l	\2,_addr_in+4
	AES	90
	ENDM	

FSEL_EXINPUT	MACRO
	move.l	\1,_addr_in+8
	move.l	\2,_addr_in
	move.l	\3,_addr_in+4
	AES	91
	ENDM	

WIND_CREATE	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	AES	100
	ENDM

WIND_OPEN	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	AES	101
	ENDM

WIND_CLOSE	MACRO
	move	\1,_int_in
	AES	102
	ENDM

WIND_DELETE	MACRO
	move	\1,_int_in
	AES	103
	ENDM

WIND_GET	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	AES	104
	move	_int_out+2,\3
	move	_int_out+4,\4
	move	_int_out+6,\5
	move	_int_out+8,\6
	ENDM

WIND_SET	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	AES	105
	ENDM

WIND_FIND	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	AES	106
	ENDM

WIND_UPDATE	MACRO
	move	\1,_int_in
	AES	107
	ENDM

WIND_CALC	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move	\4,_int_in+6
	move	\5,_int_in+8
	move	\6,_int_in+10
	AES	108
	move	_int_out+2,\7
	move	_int_out+4,\8
	move	_int_out+6,\9
	move	_int_out+8,\A
	ENDM

WIND_NEW	MACRO
	AES	109
	ENDM

RSRC_LOAD	MACRO
	move.l	\1,_addr_in
	AES	110
	ENDM

RSRC_FREE	MACRO
	AES	111
	ENDM

RSRC_GADDR	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move.l	\3,_addr_in
	AES	112
	move.l	_addr_out,\3
	ENDM

RSRC_SADDR	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	AES	113
	ENDM

RSRC_OBFIX	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	114
	ENDM

SHEL_READ	MACRO
	move.l	\1,_addr_in
	move.l	\2,_addr_in+4
	AES	120
	ENDM

SHEL_WRITE	MACRO
	move	\1,_int_in
	move	\2,_int_in+2
	move	\3,_int_in+4
	move.l	\4,_addr_in
	move.l	\5,_addr_in+4
	AES	121
	ENDM

SHEL_GET	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	122
	ENDM

SHEL_PUT	MACRO
	move.l	\1,_addr_in
	move	\2,_int_in
	AES	123
	ENDM

SHEL_FIND	MACRO
	move.l	\1,_addr_in
	AES	124
	ENDM

SHEL_ENVRN	MACRO
	move.l	\1,_addr_in
	move.l	\2,_addr_in+4
	AES	125
	ENDM
	
FILE_SELECT	MACRO
	FSEL_EXINPUT	\1,\2,\3
	move.l	\2,a0
	move.l	\4,a2
	move.l	a2,a1
	moveq	#127,d0
.fileselect1\@	move.b	(a0),d0
	cmp.b	#92,d0
	bne.s	.fileselect2\@
	lea	1(a2),a1
.fileselect2\@	move.b	(a0)+,(a2)+
	dbra	d0,.fileselect1\@
	move.l	a1,a2
	move.l	\3,a0
	moveq	#11,d0
.fileselect3\@	move.b	(a0)+,(a2)+
	dbra	d0,.fileselect3\@
	clr.b	(a2)
	ENDM

	DATA

_call_aes	move	d0,_op_code
	sub	#10,d0
	lsl	#2,d0
	lea	_aes_table,a0
	lea	_sint_in,a1
	moveq	#0,d1
	movep.l	d1,(a1)
	move.l	(a0,d0.w),d1
	movep.l	d1,1(a1)
	move.l	#_aes_params,d1
	move.l	#200,d0
	trap	#2
	rts

_aes_params	dc.l	_control,_global
	dc.l	_int_in,_int_out,_addr_in,_addr_out

_aes_table	dc.b	0,1,0,0
	dc.b	2,1,1,0
	dc.b	2,1,1,0
	dc.b	0,1,1,0
	dc.b	2,1,1,0
	dc.b	1,1,1,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	1,3,1,0
	dc.b	0,1,0,0

	dc.b	0,1,0,0
	dc.b	3,5,0,0
	dc.b	5,5,0,0
	dc.b	0,1,1,0
	dc.b	2,1,0,0
	dc.b	16,7,1,0
	dc.b	2,1,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	
	dc.b	1,1,1,0
	dc.b	2,1,1,0
	dc.b	2,1,1,0
	dc.b	2,1,1,0
	dc.b	1,1,2,0
	dc.b	1,1,1,0
	dc.b	2,1,2,0
	dc.b	3,1,1,0
	dc.b	1,1,1,0
	
	dc.B	2,1,1,0
	dc.b	1,1,1,0
	dc.b	6,1,1,0
	dc.b	4,1,1,0
	dc.b	1,3,1,0
	dc.b	2,1,1,0
	dc.b	4,2,1,0
	dc.b	8,1,1,0
	dc.b	4,3,0,0
	dc.b	0,0,0,0
	
	dc.b	1,1,1,0
	dc.b	9,1,0,0
	dc.b	1,1,1,0
	dc.b	1,1,1,0	
	dc.b	1,1,0,0
	dc.b	0,5,1,0
	dc.b	3,3,1,0
	dc.b	2,2,1,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0

	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0

	dc.b	4,3,0,0
	dc.b	8,3,0,0
	dc.b	6,1,0,0
	dc.b	8,1,0,0
	dc.b	8,1,0,0
	dc.b	4,1,1,0
	dc.b	3,1,1,0
	dc.b	0,5,0,0
	dc.b	1,1,1,0
	dc.b	0,5,0,0
	
	dc.b	0,1,1,0
	dc.b	0,1,1,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0

	dc.b	0,2,2,0
	dc.b	0,2,3,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0

	dc.b	5,1,0,0
	dc.b	5,1,0,0
	dc.b	1,1,0,0
	dc.b	1,1,0,0
	dc.b	2,5,0,0
	dc.b	6,1,0,0
	dc.b	2,1,0,0
	dc.b	1,1,0,0
	dc.b	6,5,0,0
	dc.b	0,0,0,0
	
	dc.b	0,1,1,0
	dc.b	0,1,0,0
	dc.b	2,1,0,0
	dc.b	2,1,1,0
	dc.b	1,1,1,0
	dc.b	0,0,0,0	
	dc.b	0,0,0,0	
	dc.b	0,0,0,0	
	dc.b	0,0,0,0	
	dc.b	0,0,0,0	

	dc.b	0,1,2,0
	dc.b	3,1,2,0
	dc.b	1,1,1,0
	dc.b	1,1,1,0
	dc.b	0,1,1,0
	dc.b	0,1,2,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	dc.b	0,0,0,0
	
	dc.b	1,5,0,0

	BSS

_global
_ap_version	ds.w	1
_ap_count	ds.w	1
_ap_id	ds.w	1
_ap_private	ds.l	1
_ap_ptree	ds.l	1
_ap_1resv	ds.l	1
_ap_2resv	ds.l	1
_ap_3resv	ds.l	1
_ap_4resv	ds.l	1

_control
_op_code	ds.w	1
_sint_in	ds.w	1
_sint_out	ds.w	1
_saddr_in	ds.w	1
_saddr_out	ds.w	1

_int_in	ds.w	16
_int_out	ds.w	8
_addr_in	ds.l	4
_addr_out	ds.l	4