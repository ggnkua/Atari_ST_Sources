;	Macros AES

;	Objet

NORMAL	=	0

SELECTABLE	=	1
DEFAULT	=	2
EXIT	=	4
EDITABLE	=	8
RBUTTON	=	16
LASTOB	=	32
TOUCHEXIT	=	64
HIDETREE	=	128
INDIRECT	=	256

SELECTED	=	1
CROSSED	=	2
CHECKED	=	4
DISABLED	=	8
OUTLINED	=	16
SHADOWED	=	32

G_BOX	=	20
G_TEXT	=	21
G_BOXTEXT	=	22
G_IMAGE	=	23
G_USERDEF	=	24
G_IBOX	=	25
G_BUTTON	=	26
G_BOXCHAR	=	27
G_STRING	=	28
G_FTEXT	=	29
G_FBOXTEXT	=	30
G_ICON	=	31
G_TITLE	=	32

;	Application services

AES_LARGEFONT	=	0
AES_SMALLFONT	=	1
AES_SYSTEM	=	2
AES_LANGUAGE	=	3
AES_PROCESS	=	4
AES_PCGEM	=	5
AES_INQUIRE	=	6
AES_MOUSE	=	8
AES_MENU	=	9
AES_SHELL	=	10
AES_WINDOW	=	11
AES_MESSAGE	=	12
AES_OBJECT	=	13
AES_FORM	=	14

APP_FIRST	=	0
APP_NEXT	=	1
APP_SYSTEM	=	1
APP_APPLICATION	=	2
APP_ACCESSORY	=	4
APP_SHELL	=	8

APPEVNT_TIMER	=	0
APPEVNT_BUTTON	=	1
APPEVNT_MOUSE	=	2
APPEVNT_KEYBOARD	=	3

;	Event

LEFT_BUTTON	=	1
RIGHT_BUTTON	=	2
MIDDLE_BUTTON	=	4
OTHER_BUTTON	=	8
K_RSHIFT	=	1
K_LSHIFT	=	2
K_CTRL	=	4
K_ALT	=	8

MN_SELECTED	=	10
WM_REDRAW	=	20
WM_TOPPED	=	21
WM_CLOSED	=	22
WM_FULLED	=	23
WM_ARROWED	=	24
WM_HSLID	=	25
WM_VSLID	=	26
WM_SIZED	=	27
WM_MOVED	=	28
WM_NEWTOP	=	29
WM_UNTOPPED	=	30
WM_ONTOP	=	31
WM_BOTTOM	=	33
WM_ICONIFY	=	34
WM_UNICONIFY	=	35
WM_ALLICONIFY	=	36
WM_TOOLBAR	=	37
AC_OPEN	=	40
AC_CLOSE	=	41
AP_TERM	=	50
AP_TFAIL	=	51
SHUT_COMPLETED	=	60
RESCH_COMPLETED	=	61
AP_DRAGDROP	=	63
SH_WDRAW	=	72
CH_EXIT	=	90

WA_UPPAGE	=	0
WA_DNPAGE	=	1
WA_UPLINE	=	2
WA_DNLINE	=	3
WA_LFPAGE	=	4
WA_RTPAGE	=	5
WA_LFLINE	=	6
WA_RTLINE	=	7

MO_ENTER	=	0
MO_LEAVE	=	1

MU_KEYBD	=	0
MU_BUTTON	=	1
MU_M1	=	2
MU_M2	=	3
MU_MESAG	=	4
MU_TIMER	=	5

;	Form

FMD_START	=	0
FMD_GROW	=	1
FMD_SHRINK	=	2
FMD_FINISH	=	3

FERR_FILENOTFOUND	=	2
FERR_PATHNOTFOUND	=	3
FERR_NOHANDLES	=	4
FERR_ACCESSDENIED	=	5
FERR_LOWMEM	=	8
FERR_BADENVIRON	=	10
FERR_BADFORMAT	=	11
FERR_BADDRIVE	=	15
FERR_DELETEDIR	=	16
FERR_NOFILES	=	18

;	File selector

FSEL_CANCEL	=	0
FSEL_OK	=	1

;	Graphics

ARROW	=	0
TEXT_CRSR	=	1
BUSY_BEE	=	2
POINT_HAND	=	3
FLAT_HAND	=	4
THIN_CROSS	=	5
THICK_CROSS	=	6
OUTLN_CROSS	=	7
USER_DEF	=	255
M_OFF	=	256
M_ON	=	257
M_SAVE	=	258
M_LAST	=	259
M_RESTORE	=	260

;	Menu

ME_INQUIRE	=	0
ME_ATTACH	=	1
ME_REMOVE	=	2

MENU_REMOVE	=	0
MENU_INSTALL	=	1
MENU_INQUIRE	=	-1

UNCHECK	=	0
CHECK	=	1

DISABLE	=	0
ENABLE	=	1

SCROLL_LISTBOX	=	-1

REG_NEWNAME	=	-1

HIGHLIGHT	=	0
UNHIGHLIGHT	=	1

;	Object

NO_DRAW	=	0
REDRAW	=	1

ED_START	=	0
ED_INIT	=	1
ED_CHAR	=	2
ED_END	=	3

OO_LAST	=	-1
OO_FIRST	=	0

SV_INQUIRE	=	0
SV_SET	=	1
LK3DIND	=	1
LK3DACT	=	2
INDBUTCOL	=	3
ACTBUTCOL	=	4
BACKGRCOL	=	5
AD3DVAL	=	6

;	Ressource

R_TREE	=	0
R_OBJECT	=	1
R_TEDINFO	=	2
R_ICONBLK	=	3
R_BITBLK	=	4
R_STRING	=	5
R_IMAGEDATA	=	6
R_OBSPEC	=	7
R_TEPTEXT	=	8
R_TEPMPLT	=	9
R_TEPVALID	=	10
R_IBPMASK	=	11
R_IBPDATA	=	12
R_IBPTEXT	=	13
R_BIPDATA	=	14
R_FRSTR	=	15
R_FRIMG	=	16

;	Scrap

;	Shell

SHEL_BUFSIZE	=	-1

SWM_LAUCH	=	0
SWM_LAUCHNOW	=	1
SWM_LAUCHACC	=	3
SWM_SHUTDOWN	=	4
SWM_REZCHANGE	=	5
SWM_BROADCAST	=	7
SWM_ENVIRON	=	8
SWM_NEWMSG	=	9
SWM_AESMSG	=	10

;	Window

WC_BORDER	=	0
WC_WORK	=	1

NAME	=	1
CLOSER	=	2
FULLER	=	4
MOVER	=	8
INFO	=	16
SIZER	=	32
UPARROW	=	64
DNARROW	=	128
VSLIDE	=	256
LFARROW	=	512
RTARROW	=	1024
HSLIDE	=	2048
SMALLER	=	16384

WF_NAME	=	2
WF_INFO	=	3
WF_WORKXYWH	=	4
WF_CURRXYWH	=	5
WF_PREVXYWH	=	6
WF_FULLXYWH	=	7
WF_HSLIDE	=	8
WF_VSLIDE	=	9
WF_TOP	=	10
WF_FIRSTXYWH	=	11
WF_NEXTXYWH	=	12
WF_NEWDESK	=	14
WF_HSLSIZE	=	15
WF_VSLSIZE	=	16
WF_SCREEN	=	17
WF_COLOR	=	18
WF_DCOLOR	=	19
WF_OWNER	=	20
WF_BEVENT	=	24
WF_BOTTOM	=	25
WF_ICONIFY	=	26
WF_UNICONIFY	=	27
WF_UNICONIFYXYWH	=	28
WF_TOOLBAR	=	30
WF_FTOOLBAR	=	31
WF_NTOOLBAR	=	32

END_UPDATE	=	0
BEG_UPDATE	=	1
END_MCTRL	=	2
BEG_MCTRL	=	3

; -------------	Fonctions

AES	MACRO	opcode
	move	#\1,d0
	jsr	_call_aes
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
