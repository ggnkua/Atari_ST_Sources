/********************************************************************
 *	[Tabsize = 4]											   v1.41*
 *																	*
 *	GEM_MSG: GEM index master listing header file					*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (C) 1993 - 94, Bitgate Software.  All Rights Reserved	*
 *																	*
 *	Contains updated indices to:									*
 *	""""""""""""""""""""""""""""									*
 *		o MultiTOS version 4.1										*
 *		o AES 1.0 - FalconAES 5.0 (5.0 is an unsupported version)	*
 *		o Geneva 1.03 												*
 *		o WinLIB PRO												*
 *		o Pure C Help Communication Protocol						*
 *		o GEM View 0.03												*
 *		o GEM XACC 1.01, GEM XACC 2.00								*
 *		o Gemini 1.12												*
 *		o Venus 1.21												*
 *		o WindClass 1.00											*
 *		o Enhanced GEM 1.00 - 2.10									*
 *		o GemLIB													*
 *		o Steve Woodford's Custom Library							*
 *		o InterFace and Zoom!										*
 *		o Let 'em Fly 1.00 - 1.30									*
 *		o XAES Background											*
 *		o XAES 0.01	- 1.00											*
 *		o Fluid 1.31												*
 *		o Sascha Blank's Library version 2.00						*
 *		o GEM-Force library											*
 *		o SysGEM 1.03.1												*
 *		o Windoze (PatchLevel release 2)							*
 *		o Big Is Gem (BIG) version 1.88								*
 *		o Easy GEM 1.19												*
 *		o GEM/1, GEM/2												*
 *																	*
 *	Please refer to GEM_MSG.DOC for copyrights and other material.	*
 *																	*
 ********************************************************************/

#ifndef __NEWAES__
#define __NEWAES__
#define	MSG(a,b,c)	((int)(((((a)<<(3+8))&0xf800)|(((b)<<6)&0x07c0)|((c)&0x003f))))
#define	MN_SELECTED			0x000A
#define	WM_REDRAW			0x0014
#define	WM_TOPPED			0x0015
#define	WM_CLOSED			0x0016
#define	WM_FULLED			0x0017
#define	WM_ARROWED			0x0018
#define	WM_HSLID			0x0019
#define	WM_VSLID			0x001A
#define	WM_SIZED			0x001B
#define	WM_MOVED			0x001C
#define	WM_NEWTOP			0x001D
#define	WM_UNTOPPED			0x001E
#define	WM_ONTOP			0x001F
#define	WM_BOTTOMED			0x0021
#define	WM_ICONIFY			0x0022
#define	WM_UNICONIFY		0x0023
#define	WM_ALLICONIFY		0x0024
#define	WM_TOOLBAR			0x0025
#define	AC_OPEN				0x0028
#define	AC_CLOSE			0x0029
#define	AP_TERM				0x0032
#define	CT_UPDATE			0x0032
#define	AP_TFAIL			0x0033
#define	CT_MOVE				0x0033
#define	CT_NEWTOP			0x0034
#define	AP_RESCHG			0x0039
#define	SHUT_COMPLETED		0x003C
#define	RESCH_COMPLETED		0x003D
#define	AP_DRAGDROP			0x003F
#define	SH_EXIT				0x0044
#define	SH_START			0x0045
#define	SH_WDRAW			0x0048
#define	CH_EXIT				0x0050
#define	ACC_ID				0x0400
#define	ACC_OPEN			0x0401
#define	AC_HELP				0x0401
#define	ACC_CLOSE			0x0402
#define	AC_REPLY			0x0402
#define	ACC_ACC				0x0403
#define	AC_VERSION			0x0403
#define	ACC_EXIT			0x0404
#define	AC_COPY				0x0404
#define	ACC_ACK				0x0500
#define	ACC_TEXT			0x0501
#define	ACC_KEY				0x0502
#define	ACC_META			0x0503
#define	ACC_IMG				0x0504
#define	WM_DIALOG			0x0A00
#define	WM_KEYBD			0x0A01
#define	WM_BUTTON			0x0A02
#define	WM_TEXT				0x0A03
#define	WM_HOTKEY			0x0A04
#define	WM_FKEY				0x0A05
#define	WM_HELP				0x0A06
#define	WM_UNDO				0x0A07
#define	WM_MENU				0x0A08
#define	WM_CLIP				0x0A09
#define	WM_TIMECHG			0x0A0A
#define	WM_GETHELP			0x0A0B
#define	WM_SLIDER			0x0A0C
#define	WM_CREATED			0x0B00
#define	WM_KILL				0x0B01
#define	WM_TIMER			0x0B02
#define	WM_PAINT			0x0B03
#define	WM_CLOSEALL			0x0F00
#define	WM_PROGEND			0x0F01
#define	WM_SAVE				0x1000
#define	WM_SAVEAS			0x1001
#define	WM_PRINT			0x1002
#define	WM_UNDO				0x1003
#define	WM_CUT				0x1004
#define	WM_COPY				0x1005
#define	WM_PASTE			0x1006
#define	WM_SELECTALL		0x1007
#define	WM_FIND				0x1008
#define	WM_REPLACE			0x1009
#define	WM_FINDNEXT			0x100A
#define	WM_HELP				0x100B
#define	WM_DELETE			0x100C
#define	X_MU_DIALOG			0x4000
#define	AV_PROTOKOLL		0x4700
#define	VA_PROTOSTATUS		0x4701
#define	AV_GETSTATUS		0x4703
#define	AV_STATUS			0x4704
#define	VA_SETSTATUS		0x4705
#define	AV_SENDKEY			0x4710
#define	VA_START			0x4711
#define	AV_ASKFILEFONT		0x4712
#define	VA_FILEFONT			0x4713
#define	AV_ASKCONFONT		0x4714
#define	VA_CONFONT			0x4715
#define	AV_ASKOBJECT		0x4716
#define	VA_OBJECT			0x4717
#define	AV_OPENCONSOLE		0x4718
#define	VA_CONSOLEOPEN		0x4719
#define	AV_OPENWIND			0x4720
#define	VA_WINDOPEN			0x4721
#define	AV_STARTPROG		0x4722
#define	VA_PROGSTART		0x4723
#define	AV_ACCWINDOPEN		0x4724
#define	VA_DRAGACCWIND		0x4725
#define	AV_ACCWINDCLOSED	0x4726
#define	VIEW_FILE			0x5600
#define	VIEW_FAILED			0x5601
#define	VIEW_OPEN			0x5602
#define	VIEW_CLOSED			0x5603
#define	VIEW_DATA			0x5604
#define	VIEW_GETMFDB		0x5605
#define	VIEW_SETMFDB		0x5606
#define	VIEW_MFDB			0x5607
#define	WM_SHADED			0x5758
#define	WM_UNSHADED			0x5759
#define	X_MN_SELECTED		0xE000
#define	X_WM_SELECTED		0xE100
#define	X_GET_HELP			0xE200
#define	X_DRAGDROP			0xE300
#define	WC_CREATE			MSG('W','C', 0)
#define	WC_DESTROY			MSG('W','C', 1)
#define	WC_DEAD				MSG('W','C', 2)
#define	WC_GETHDL			MSG('W','C', 3)
#define	WC_GETMENU			MSG('W','C', 4)
#define	WC_PINMENU			MSG('W','C', 5)
#define	WC_SELMENU			MSG('W','C', 6)
#define	WC_TIMER			MSG('W','C', 7)
#define	WC_KEYBD			MSG('W','C', 8)
#define	WC_BUTTON			MSG('W','C', 9)
#define	WC_RSFIX			MSG('W','C',10)
#define	WC_SHOW				MSG('W','C',11)
#define	WC_HIDE				MSG('W','C',12)
#define	WC_ISVIS			MSG('W','C',13)
#define	WC_SETNAME			MSG('W','C',14)
#define	WC_SETINFO			MSG('W','C',15)
#define	WC_SETICON			MSG('W','C',16)
#define	WC_ISICON			MSG('W','C',17)
#define	WC_APPICON			MSG('W','C',18)
#define	WC_PAINT			MSG('W','C',19)
#define	WC_OBJDRW			MSG('W','C',20)
#define	WC_OBJPNT			MSG('W','C',21)
#define	WC_FORMDO			MSG('W','C',22)
#define	WC_BKGND			MSG('W','C',23)
#define	WC_EDIT				MSG('W','C',24)
#define	WC_NEWEDIT			MSG('W','C',25)
#define	WC_CICON			MSG('W','C',26)
#define	WC_GETXTXT			MSG('W','C',27)
#define	WC_SETXTXT			MSG('W','C',28)
#define	WC_PRINT			MSG('W','C',29)
#define	WC_NEWLINE			MSG('W','C',30)
#define	WC_SETPOS			MSG('W','C',31)
#define	WC_CLEOP			MSG('W','C',32)
#define	WC_CLEOL			MSG('W','C',33)
#define	WC_SCROLL			MSG('W','C',34)
#define	WC_CURSOR			MSG('W','C',35)
#define	WC_DRAW				MSG('W','C',36)
#define	WC_GETSTATE			MSG('W','C',37)
#define	WC_SETATTR			MSG('W','C',38)
#define	WC_SETHGHT			MSG('W','C',39)
#define	WC_SETCOL			MSG('W','C',40)
#define	WC_SETFNT			MSG('W','C',41)
#define	WC_SETINDNT			MSG('W','C',42)

#define	WF_KIND				0x0001
#define	WF_NAME				0x0002
#define	WF_INFO				0x0003
#define	WF_WORKXYWH			0x0004
#define	WF_CURRXYWH			0x0005
#define	WF_PREVXYWH			0x0006
#define	WF_FULLXYWH			0x0007
#define	WF_HSLIDE			0x0008
#define	WF_VSLIDE			0x0009
#define	WF_TOP				0x000A
#define	WF_FIRSTXYWH		0x000B
#define	WF_NEXTXYWH			0x000C
#define	WF_RESVD			0x000D
#define	WF_NEWDESK			0x000E
#define	WF_HSLSIZE			0x000F
#define	WF_VSLSIZE			0x0010
#define	WF_SCREEN			0x0011
#define	WF_COLOR			0x0012
#define	WF_DCOLOR			0x0013
#define	WF_OWNER			0x0014
#define	WF_BEVENT			0x0018
#define	WF_BOTTOM			0x0019
#define	WF_ICONIFY			0x001A
#define	WF_UNICONIFY		0x001B
#define	WF_UNICONIFYXYWH	0x001C
#define	WF_TOOLBAR			0x001E
#define	WF_FTOOLBAR			0x001F
#define	WF_NTOOLBAR			0x0020
#define	WM_M_BDROPPED		0x0064
#define	X_WF_MENU			0x1100
#define	X_WF_DIALOG			0x1101
#define	X_WF_DIALWID		0x1300
#define	X_WF_DIALHT			0x1400
#define	X_WF_DFLTDESK		0x1500
#define	X_WF_MINMAX			0x1600
#define	WF_MINIMIZE			0x4E20
#define	WF_UNUNTOPPABLE		0x4E21
#define	WF_FLYING			0x4E22
#define	WF_TEXT				0x4E23
#define	WF_TIMER			0x4E24
#define	WF_DIALOG			0x4E25
#define	WF_UNSIZABLE		0x4E26
#define	WF_CUSTOMWIN		0x4E27
#define	WF_SLIDEPOS			0x4E28
#define	WF_WINX				0x5758
#define	WF_WINXCFG			0x5759
#define	WF_MINIMIZE			0x613A
#define	WF_UNUNTOPPABLE		0x613B
#define	WF_MODAL			0x613C
#define	WF_FLYING			0x613E
#define	WF_TEXT				0x613F
#define	WF_TIMER			0x6140
#define	WF_DIALOG			0x6141
#endif

#ifndef __NEWKIND__
#define	__NEWKIND__
#define	WI_NONE				0x0000
#define	NAME				0x0001
#define	WI_MARGT			0x0001
#define	WI_FULLED			0x0001
#define	CLOSER				0x0002
#define	WI_MOVET			0x0002
#define	WI_LOCKED			0x0002
#define	FULLER				0x0004
#define	WI_MARGL			0x0004
#define	WI_FIRSTDRW			0x0004
#define	MOVER				0x0008
#define	WI_MOVEL			0x0008
#define	INFO				0x0010
#define	WI_FULLED			0x0010
#define	WI_ONTOP			0x0010
#define	SIZER				0x0020
#define	WI_MENU				0x0020
#define	WI_NOTOP			0x0020
#define	UPARROW				0x0040
#define	WI_RESIDENT			0x0040
#define	DNARROW				0x0080
#define	VSLIDE				0x0100
#define	WI_NOSCROLL			0x0100
#define	LFARROW				0x0200
#define	RTARROW				0x0400
#define	HSLIDE				0x0800
#define	CASCADE				0x1000
#define	SMALLER				0x2000
#define	MENUWORK			0x4000
#define	WTYP_TOOL			0x4000
#define	OPTIONS				0x8000
#define	WTYP_MENU			0x8000
#endif

#ifndef __NEWSHEL__
#define	__NEWSHEL__
#define	X_SHLOADSAVE		-1
#define	SHW_RUNANY			0
#define	X_SHOPEN			0
#define	SHW_RUNAPP			1
#define	X_SHACCESS			1
#define	SHW_RESVD			2
#define	X_SHCLOSE			2
#define	SHW_RUNACC			3
#define	SHW_SHUTDOWN		4
#define	SHW_NEWREZ			5
#define	SHW_RESERVED		6
#define	SHW_BROADCAST		7
#define	SHW_ENVIRON			8
#define	SHW_MSGTYPE			9
#define	SHW_SENDTOAES		10
#endif

#ifndef __NEWGETINFO__
#define	__NEWGETINFO__
#define	GET_FONT_INFO		0
#define	GET_SMFONT_INFO		1
#define	GET_MONSUPPORT		2
#define	GET_AES_LANGUAGE	3
#define	GET_GEN_INFO1		4
#define	GET_GEN_INFO2		5
#define	GET_GEN_INFO3		6
#define	GET_RESVD			7
#define	GET_MOUSE_SUPPORT	8
#define	GET_MENU_SUPPORT	9
#define	GET_SHEL_WRITE		10
#define	GET_WIND_SUPPORT	11
#define	GET_MSG_SENT_APP	12
#define	GET_OBJ_INFO		13
#define	GET_FORMLIB_INFO	14
#endif

#ifndef __NEWSTATE__
#define	__NEWSTATE__
#define	NORMAL				0x0000
#define	SELECTED			0x0001
#define	CROSSED				0x0002
#define	CHECKED				0x0004
#define	DISABLED			0x0008
#define	OUTLINED			0x0010
#define	SHADOWED			0x0020
#define	DRAW3D				0x0040
#define	X_PREFER			0x0040
#define	WHITEBAK			0x0080
#define	X_DRAW3D			0x0080
#define	X_ROUNDED			0x0100
#define	X_KBD_EQUIV			0x0200
#define	X_SMALLTEXT			0x0400
#define	MENUTYPE			0x2000
#define	ALREADYMOD			0x4000
#define	X_BOLD				0x4000
#define	X_ITALICS			0x8000
#define	X_MAGIC				0x9000
#define	X_MAGMASK			0xF000
#endif

#ifndef __NEWFLAGS__
#define	__NEWFLAGS__
#define	NONE				0x0000
#define	FL3DNONE			0x0000
#define	SELECTABLE			0x0001
#define	DEFAULT				0x0002
#define	EXIT				0x0004
#define	EDITABLE			0x0008
#define	RBUTTON				0x0010
#define	LASTOB				0x0020
#define	TOUCHEXIT			0x0040
#define	HIDETREE			0x0080
#define	INDIRECT			0x0100
#define	FL3DIND				0x0200
#define	FL3DBAK				0x0400
#define	FL3DACT				0x0600
#define	FL3DMASK			0x0600
#define	SUBMENU				0x0800
#define	HANDSLIDE			0x0800
#define	OBFLAGS11			0x0800
#define	OBFLAGS12			0x1000
#define	FLYIN				0x1000
#define	MENUSIDE			0x2000
#define	SNAPIN				0x2000
#define	OBFLAGS13			0x2000
#define	FRCCENT				0x4000
#define	OBFLAGS14			0x4000
#define	BOXFRAMETITLE		0x8000
#define	CENTER				0x8000
#define	OBFLAGS15			0x8000
#endif

#ifndef __NEWEVNTMULTI__
#define	__NEWEVNTMULTI__
#define	MU_KEYBD			0x0001
#define	MU_BUTTON			0x0002
#define	MU_BUTTON1			0x0002
#define	MU_M1				0x0004
#define	MU_M2				0x0008
#define	MU_MESAG			0x0010
#define	MU_TIMER			0x0020
#define	MU_TIMER1			0x0020
#define	MU_TIMER2			0x0040
#define	MU_TIMER3			0x0080
#define	MU_M3_OLD			0x0080
#define	MU_TIMER4			0x0100
#define	MU_M4_OLD			0x0100
#define	MU_M3				0x0200
#define	MU_M4				0x0400
#define	MU_GET_MESSAG		0x4000
#define	MU_NO_HANDLER		0x8000
#define	MU_BUTTON2			0x8000
#define	BEV_HEIRM			50
#define	BEV_FREEPU			51
#define	BEV_WFORM			52
#define	BEV_WMENU			53
#define	BEV_WHEIR			54
#define	BEV_TOOL			55
#endif

#ifndef __NEWMOUSE__
#define	__NEWMOUSE__
#define	ARROW				0
#define	TEXT_CRSR			1
#define	HOURGLASS			2
#define	BUSYBEE				2
#define	POINT_HAND			3
#define	FLAT_HAND			4
#define	THIN_CROSS			5
#define	THICK_CROSS			6
#define	OUTLN_CROSS			7
#define	X_LFTRT				8
#define	X_UPDOWN			9
#define	INIT_MOUSE			50
#define	LOAD_MOUSE			51
#define	LRSLIDE_MOUSE		52
#define	UDSLIDE_MOUSE		53
#define	URMOVE_MOUSE		54
#define	ULMOVE_MOUSE		55
#define	LLMOVE_MOUSE		56
#define	LRMOVE_MOUSE		57
#define	CLIP_MOUSE			58
#define	DIALOG_MOUSE		59
#define	TEXT_MOUSE			60
#define	TIMER_MOUSE			61
#define	TRASH_MOUSE			62
#define	USER_DEF			255
#define	M_OFF				256
#define	M_ON				257
#define	M_SAVE				258
#define	M_RESTORE			259
#define	M_PREVIOUS			260
#define	ANIMATED_MOUSE		300
#define	COLOR_MOUSE			301
#define	GET_MOUSE			400
#define	SAVE_MOUSE			401
#define	PREV_MOUSE			402
#define	NEXT_MOUSE			403
#define	FIRST_MOUSE			404
#define	LAST_MOUSE			405
#define	CLEAR_MOUSE			406
#define	FIND_MOUSE			407
#define	NEWPOS_MOUSE		408
#define	X_MRESET			1000
#define	X_MGET				1001
#define	X_SET_SHAPE			1100
#endif

#ifndef __NEWEXTOBTYPE__
#define	__NEWEXTOBTYPE__
#define	POPUP_BTN			0
#define	POPUP_SELECT		0
#define	CHECKBOX			1
#define	POPUP_CYCLE			1
#define	HEADER				2
#define	POPUP_CHECK			2
#define	POPUP_BTN_CHK		2
#define	POPUP_RADIO			2
#define	RADIO				3
#define	UNDERLINE			4
#define	POPUP_CYCLE_CHK		4
#define	HOTKEY				5
#define	CHKHOTKEY			6
#define	RBHOTKEY			7
#define	INDHOTKEY			8
#define	FLYDIAL				9
#define	TXTDEFAULT			10
#define	USERFLY				11
#define	HELP_BTN			12
#define	ATTR_TEXT			13
#define	CYCLE_BUTTON		14
#define	ARROW_LEFT			15
#define	ARROW_RIGHT			16
#define	SCALE				16
#define	ARROW_UP			17
#define	FLYING				17
#define	SPECIAL_MOVE		17
#define	B_MOVE				17
#define	ARROW_DOWN			18
#define	CUSTOM				18
#define	CHECKBOX			18
#define	RADIOBTN			18
#define	POPUPBTN			18
#define	SPECIAL_BUTTON		18
#define	B_COCHE				18
#define	B_RADIO				18
#define	UNDERLINE			19
#define	SPECIAL_TEXT		19
#define	UNDO_BTN			19
#define	BOXFRAME			20
#define	BOXTITLE			20
#define	SPECIAL_FRAME		20
#define	B_FRAME				20
#define	HELPBTN				21
#define	B_HELP				21
#define	CYCLEBTN			22
#define	CIRCLE				22
#define	B_POPUP				22
#define	B_LIST				23
#define	CUSTBTN				24
#define	DROPDOWN			25
#define	B_EDIT				25
#define	MENUDETATCH			30
#define	B_DEFAULT			30
#define	B_UNDER				30
#define	UNDOBTN				31
#define	B_UNDO				31
#define	MENULINE			40
#define	MENUEFFECTS			41
#define	B_HIERM				41
#define	B_FNCP				51
#define	FLYALL				0x0100
#define	ET_FORMATTEXT		0x0100
#define	ET_HELPBUT			0x0100
#define	ET_RTDNARROW		0x0100
#define	USD_CARRE			0x0100
#define	ED_CLIP				0x0100
#define	FLYNOCL				0x0200
#define	ET_SCROLLBAR		0x0200
#define	ET_EDITTITLE		0x0200
#define	ET_SECTIONTITLE		0x0200
#define	ET_LFUPARROW		0x0200
#define	USD_ROND			0x0200
#define	ET_SCROLLTHUMB		0x0300
#define	ET_POPUPTITLE		0x0300
#define	USD_POPUP			0x0300
#define	ET_SECTIONBOX		0x0400
#define	ET_CHECKBOX			0x0400
#define	ET_CANCELBUT		0x0400
#define	ET_POPUPCYCLE		0x0400
#define	USD_XPOPUP			0x0400
#define	ET_SPECIALITEM		0x0700
#define	KEYDIAL				0x0800
#define	ET_ITALICTEXT		0x0800
#define	NODUPE				0x1000
#define	G_HOTKEY			0x1000
#define	TKNEXT				0x1000
#define	ET_BOLDTEXT			0x1000
#define	SPECIAL				0x2000
#define	G_IND				0x2000
#define	ET_POWERKEY			0x2000
#define	G_RB				0x3000
#define	FLYER				0x4000
#define	G_CHK				0x4000
#define	ET_DUPLICATED		0x4000
#define	G_UNMODAL			0x4000
#define	G_FLY				0x5000
#define	GLOBOFF				0x7100
#define	EXAPPL				0x8000
#define	G_MODAL				0x8000
#define	ET_CUSTOMIZED		0x8000
#define	MAGIC				0x8900
#define	USD_RQARROW			0xF800
#define	USD_LQARROW			0xF900
#define	USD_RTARROW			0xFA00
#define	USD_LFARROW			0xFB00
#define	USD_UPARROW			0xFC00
#define	USD_DNARROW			0xFD00
#endif