/* ------------------------------------------------------------------------- */
/* ----- The smaller AES-Binding V1.2 --- (c) 1991-93 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */
/* ----- SMALLAES.H   Definition File -------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
/* Dieses Binding ist Public Domain. Žnderungen sind genau zu dokumentieren! */
/* ------------------------------------------------------------------------- */
/* This Binding is public domain. Changes have to be documented!	     */
/* ------------------------------------------------------------------------- */
/*	Autor:	Oliver Scheel						     */
/*		Rothehausstr. 28					     */
/*		W-5000 K”ln 30 (West-Geramny)				     */
/*	Net: 	Oliver_Scheel@k2.maus.de				     */
/* ------------------------------------------------------------------------- */

#ifndef __SMALLAES__
#define	__SMALLAES__
#define	__AES__

#include <portab.h>

/* ------------------------------------------------------------------------- */
/* ----- AES-Call ---------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/* ----- input: 1. Func.No. 2. int_in; 3. addr_in; 4. int_out; 5. addr_out - */
/* ------------------------------------------------------------------------- */

WORD aes(WORD args, ...);

/* ------------------------------------------------------------------------- */

EXTERN WORD	_app;		/* Turbo-C only */

/* ------------------------------------------------------------------------- */
/* ----- Constants --------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ----- Event Manager ----------------------------------------------------- */

#define	MU_KEYBD	0x0001		/* which event */
#define	MU_BUTTON	0x0002
#define	MU_M1		0x0004
#define	MU_M2		0x0008
#define	MU_MESAG	0x0010
#define	MU_TIMER	0x0020

#define	MN_SELECTED	10		/* event messages */
#define	WM_REDRAW	20
#define	WM_TOPPED	21
#define	WM_CLOSED	22
#define	WM_FULLED	23
#define	WM_ARROWED	24
#define	WM_HSLID	25
#define	WM_VSLID	26
#define	WM_SIZED	27
#define	WM_MOVED	28
#define	WM_NEWTOP	29
#define WM_UNTOPPED	30	/* AES 3.3 */
#define WM_ONTOP	31	/* AES 3.3 */
#define	AC_OPEN		40
#define	AC_CLOSE	41
#define	AP_TERM		50	/* AES 4.0 */
#define	AP_TFAIL	51	/* AES 4.0 */
#define AP_RESCHG	57	/* AES 4.0 */
#define SHUT_COMPLETED	60	/* AES 4.0 */
#define RESCH_COMPLETED	61	/* AES 4.0 */
#define AP_DRAGDROP	63	/* AES 4.0 */
#define SH_WDRAW	72	/* AES 4.0 */
#define CH_EXIT		80	/* AES 4.0 */


#define	K_RSHIFT	0x0001		/* keyboard states */
#define	K_LSHIFT	0x0002
#define	K_CTRL		0x0004
#define	K_ALT		0x0008

/* ----- Objects ----------------------------------------------------------- */

#define	G_BOX		20		/* object type */
#define	G_TEXT		21
#define	G_BOXTEXT	22
#define	G_IMAGE		23
#define	G_USERDEF	24
#define	G_IBOX		25
#define	G_BUTTON	26
#define	G_BOXCHAR	27
#define	G_STRING	28
#define	G_FTEXT		29
#define	G_FBOXTEXT	30
#define	G_ICON		31
#define	G_TITLE		32
#define G_CICON		33

#define	NONE		0x0000		/* object flags */
#define	SELECTABLE	0x0001
#define	DEFAULT		0x0002
#define	EXIT		0x0004
#define	EDITABLE	0x0008
#define	RBUTTON		0x0010
#define	LASTOB		0x0020
#define	TOUCHEXIT	0x0040
#define	HIDETREE	0x0080
#define	INDIRECT	0x0100
#define FL3DIND		0x0200
#define FL3DBAK		0x0400

#define FL3DACT		0x0600

#define	NORMAL		0x00		/* object states */
#define	SELECTED	0x01
#define	CROSSED		0x02
#define	CHECKED		0x04
#define	DISABLED	0x08
#define	OUTLINED	0x10
#define	SHADOWED	0x20


#if !defined(__COLORS)			/* object colors */
#define	__COLORS

#define	WHITE		 0
#define	BLACK		 1
#define	RED		 2
#define	GREEN		 3
#define	BLUE		 4
#define	CYAN		 5
#define	YELLOW		 6
#define	MAGENTA		 7
#define	LWHITE		 8
#define	LBLACK		 9
#define	LRED		10
#define	LGREEN		11
#define	LBLUE		12
#define	LCYAN		13
#define	LYELLOW		14
#define	LMAGENTA	15

#endif

#define	ROOT		 0
#define	MAX_LEN		81		/* max string length */
#define	MAX_DEPTH	 8		/* max depth of	search or draw */

#define	IBM		3		/* font	types */
#define	SMALL		5

#define	ED_START	0		/* editable text field definitions */
#define	ED_INIT		1
#define	ED_CHAR		2
#define	ED_END		3

#define	TE_LEFT		0		/* editable text justification */
#define	TE_RIGHT	1
#define	TE_CNTR		2

/* ----- Forms/Dialogs ----------------------------------------------------- */

#define	FMD_START	0		/* form_dial() */
#define	FMD_GROW	1
#define	FMD_SHRINK	2
#define	FMD_FINISH	3

/* ----- Graf handler ------------------------------------------------------ */

#define	ARROW		  0		/* mouse forms */
#define	TEXT_CRSR	  1
#define	HOURGLASS	  2
#define	BUSYBEE		  2
#define	POINT_HAND	  3
#define	FLAT_HAND	  4
#define	THIN_CROSS	  5
#define	THICK_CROSS	  6
#define	OUTLN_CROSS	  7
#define	USER_DEF	255
#define	M_OFF		256
#define	M_ON		257

#define M_SAVE		258
#define M_RESTORE	259
#define M_PREV		260

/* ----- Windows ----------------------------------------------------------- */

#define	NAME	0x0001			/* window elements */
#define	CLOSER	0x0002
#define	FULLER	0x0004
#define	MOVER	0x0008
#define	INFO	0x0010
#define	SIZER	0x0020
#define	UPARROW	0x0040
#define	DNARROW	0x0080
#define	VSLIDE	0x0100
#define	LFARROW	0x0200
#define	RTARROW	0x0400
#define	HSLIDE	0x0800

#define	WF_KIND			 1	/* wind_get/set */
#define	WF_NAME			 2
#define	WF_INFO			 3
#define	WF_WORKXYWH		 4
#define	WF_CURRXYWH		 5
#define	WF_PREVXYWH		 6
#define	WF_FULLXYWH		 7
#define	WF_HSLIDE		 8
#define	WF_VSLIDE		 9
#define	WF_TOP			10	/* Mag!X and AES 3.3 */
#define	WF_FIRSTXYWH		11
#define	WF_NEXTXYWH		12
#define	WF_RESVD		13
#define	WF_NEWDESK		14
#define	WF_HSLSIZE		15
#define	WF_VSLSIZE		16
#define	WF_SCREEN		17
#define WF_COLOR		18	/* AES 3.3 */
#define WF_DCOLOR		19	/* AES 3.3 */
#define WF_OWNER		20	/* AES 3.3 */
#define WF_BEVENT		24	/* AES 3.31 */
#define WF_BOTTOM		25	/* AES 3.31 */

#define	WA_UPPAGE 0			/* arrow events */
#define	WA_DNPAGE 1
#define	WA_UPLINE 2
#define	WA_DNLINE 3
#define	WA_LFPAGE 4
#define	WA_RTPAGE 5
#define	WA_LFLINE 6
#define	WA_RTLINE 7

#define	WC_BORDER 0			/* wind	calc flags */
#define	WC_WORK	  1

#define	END_UPDATE 0			/* update flags	*/
#define	BEG_UPDATE 1
#define	END_MCTRL  2
#define	BEG_MCTRL  3

/* ----- Resources --------------------------------------------------------- */

#define	R_TREE		 0
#define	R_OBJECT	 1
#define	R_TEDINFO	 2
#define	R_ICONBLK	 3
#define	R_BITBLK	 4
#define	R_STRING	 5		/* gets	pointer	to free	strings	*/
#define	R_IMAGEDATA	 6		/* gets	pointer	to free	images */
#define	R_OBSPEC	 7
#define	R_TEPTEXT	 8		/* sub ptrs in TEDINFO */
#define	R_TEPTMPLT	 9
#define	R_TEPVALID	10
#define	R_IBPMASK	11		/* sub ptrs in ICONBLK */
#define	R_IBPDATA	12
#define	R_IPBTEXT	13
#define	R_BIPDATA	14		/* sub ptrs in BITBLK */
#define	R_FRSTR		15		/* gets	addr of	ptr to free strings */
#define	R_FRIMG		16		/* gets	addr of	ptr to free images  */

/* ------------------------------------------------------------------------- */
/* ----- TypeDefs ---------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ----- Common ------------------------------------------------------------ */

typedef	struct orect
{
	struct	orect	*o_link;
	WORD	o_x;
	WORD	o_y;
	WORD	o_w;
	WORD	o_h;
} ORECT;

typedef	struct
{
	WORD	g_x;
	WORD	g_y;
	WORD	g_w;
	WORD	g_h;
} GRECT;

typedef	struct
{
	WORD	v_x1;
	WORD	v_y1;
	WORD	v_x2;
	WORD	v_y2;
} VRECT;

/* ----- Event Manager ----------------------------------------------------- */

typedef	struct				/* evnt_mouse() */
{
	WORD		m_out;
	WORD		m_x;
	WORD		m_y;
	WORD		m_w;
	WORD		m_h;
} MOBLK;

/* ----- Objects ----------------------------------------------------------- */

typedef	struct
{
	CHAR	*te_ptext;	/* ptr to text (must be	1st)	*/
	CHAR	*te_ptmplt;	/* ptr to template		*/
	CHAR	*te_pvalid;	/* ptr to validation		*/
	WORD	te_font;	/* font				*/
	WORD	te_junk1;	/* junk	WORD			*/
	WORD	te_just;	/* justification: left,	 right...*/
	WORD	te_color;	/* color information		*/
	WORD	te_junk2;	/* junk	WORD			*/
	WORD	te_thickness;	/* border thickness		*/
	WORD	te_txtlen;	/* text	string length		*/
	WORD	te_tmplen;	/* template string length	*/
} TEDINFO;


typedef	struct
{
	WORD	*ib_pmask;
	WORD	*ib_pdata;
	CHAR	*ib_ptext;
	WORD	ib_char;
	WORD	ib_xchar;
	WORD	ib_ychar;
	WORD	ib_xicon;
	WORD	ib_yicon;
	WORD	ib_wicon;
	WORD	ib_hicon;
	WORD	ib_xtext;
	WORD	ib_ytext;
	WORD	ib_wtext;
	WORD	ib_htext;
} ICONBLK;


typedef	struct
{
	WORD	*bi_pdata;		/* ptr to bit forms data	*/
	WORD	bi_wb;			/* width of form in bytes	*/
	WORD	bi_hl;			/* height in lines		*/
	WORD	bi_x;			/* source x in bit form		*/
	WORD	bi_y;			/* source y in bit form		*/
	WORD	bi_color;		/* foreground color		*/
} BITBLK;


typedef struct cicon_data
{
	WORD	num_planes;		/* number of planes		*/
	WORD	*col_data;		/* pointer to data bitmap	*/
	WORD	*col_mask;		/* pointer to mask bitmap	*/
	WORD	*sel_data;		/* pointer to selected bitmap	*/
	WORD	*sel_mask;
	struct	cicon_data	*next_res;
} CICON;


typedef struct
{
	ICONBLK	monoblk;		/* default monochrome icon	*/
	CICON	*mainlist;
} CICONBLK;


struct __parmblk;

#ifndef	__STDC__	/*
					 *	using this structure is	not possible
					 *	if ANSI	keywords only is ON
					 */
typedef	struct
{
	WORD STDARGS (*ub_code)(struct __parmblk *parmblock);
	LONG	  ub_parm;
} USERBLK;

typedef struct
{
	int cdecl (*ub_code)(struct __parmblk *parmblock);
	union obspecptr *ub_spec;	/* old ob_spec */
	int	ub_type;	/* old ob_type */
} EXAPPLBLK;

#endif

typedef	struct
{
	unsigned character   :	8;
	signed	 framesize   :	8;
	unsigned framecol    :	4;
	unsigned textcol     :	4;
	unsigned textmode    :	1;
	unsigned fillpattern :	3;
	unsigned interiorcol :	4;
} bfobspec;

typedef	struct
{
	unsigned framecol    :	   4;
	unsigned textcol     :	   4;
	unsigned textmode    :	   1;
	unsigned fillpattern :	   3;
	unsigned interiorcol :	   4;
} tfobspec;


typedef	union obspecptr
{
	LONG	 index;
	union obspecptr	*indirect;
	bfobspec obspec;
	TEDINFO	 *tedinfo;
	ICONBLK	 *iconblk;
	BITBLK	 *bitblk;
#ifndef	__STDC__
	USERBLK	*userblk;
	EXAPPLBLK *exapblk;
#endif
	CHAR	*free_string;
} OBSPEC;


typedef	struct
{
	WORD	ob_next;	/* -> object's next sibling	*/
	WORD	ob_head;	/* -> head of object's children	*/
	WORD	ob_tail;	/* -> tail of object's children	*/
	UWORD	ob_type;	/* object type:	BOX, CHAR, ...	*/
	UWORD	ob_flags;	/* object flags			*/
	UWORD	ob_state;	/* state: SELECTED, OPEN, ...	*/
	OBSPEC	ob_spec;	/* "out": -> anything else	*/
	WORD	ob_x;		/* upper left corner of	object	*/
	WORD	ob_y;		/* upper left corner of	object	*/
	WORD	ob_width;	/* object width			*/
	WORD	ob_height;	/* object height		*/
} OBJECT;


typedef	struct __parmblk
{
	OBJECT	*pb_tree;
	WORD	pb_obj;
	WORD	pb_prevstate;
	WORD	pb_currstate;
	WORD	pb_x,  pb_y,  pb_w,  pb_h;
	WORD	pb_xc,	pb_yc,	pb_wc,	pb_hc;
	LONG	pb_parm;
} PARMBLK;

/* ----- Menus ------------------------------------------------------------- */

typedef struct
{
	OBJECT	*mn_tree;
	WORD	mn_menu;
	WORD	mn_item;
	WORD	mn_scroll;
	WORD	mn_keystate;
} MENU;

typedef struct
{
	LONG	display;
	LONG	drag;
	LONG	delay;
	LONG	speed;
	LONG	height;
} MN_SET;

/* ----- Graf Handler ------------------------------------------------------ */

typedef	struct mfstr
{
	WORD	mf_xhot;
	WORD	mf_yhot;
	WORD	mf_nplanes;
	WORD	mf_fg;
	WORD	mf_bg;
	WORD	mf_mask[16];
	WORD	mf_data[16];
} MFORM;

/* ----- Resources --------------------------------------------------------- */

typedef	struct rshdr
{
	UWORD     rsh_vrsn;
	UWORD     rsh_object;
	UWORD     rsh_tedinfo;
	UWORD     rsh_iconblk;		/* list of ICONBLKS */
	UWORD     rsh_bitblk;
	UWORD     rsh_frstr;
	UWORD     rsh_string;
	UWORD     rsh_imdata;		/* image data */
	UWORD     rsh_frimg;
	UWORD     rsh_trindex;
	UWORD     rsh_nobs;		/* counts of various structs */
	UWORD     rsh_ntree;
	UWORD     rsh_nted;
	UWORD     rsh_nib;
	UWORD     rsh_nbb;
	UWORD     rsh_nstring;
	UWORD     rsh_nimages;
	UWORD     rsh_rssize;		/* total bytes in resource */
} RSHDR;

/* ------------------------------------------------------------------------- */
/* ----- AES Defines ------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ----- Applications ------------------------------------------------------ */

#define	appl_init()\
	aes(10)
#define	appl_read(id, length, buff)\
	aes(11, id, length, buff)
#define	appl_write(id, length, pbuff)\
	aes(12, id, length, pbuff)
#define	appl_find(pname)\
	aes(13, pname)
#define	appl_tplay(pmem, pnum, pscale)\
	aes(14, pnum, pscale, pmem)
#define	appl_trecord(rmem, rcount)\
	aes(15, rcount, rmem)
					/* only GEM/2 ... */
#define appl_bvset(vdisk, vhard)\
	aes(16, vdisk, vhard)
#define appl_yield()\
	aes(17)

#define appl_search(ap_smode, ap_sname, ap_stype, ap_sid)\
	aes(18, ap_smode, ap_sname, ap_stype, ap_sid)

#define	appl_exit()\
	aes(19)

#define appl_getinfo(ap_gtype, ap_gout1, ap_gout2, ap_gout3, ap_gout4)\
	aes(130, ap_gtype, ap_gout1, ap_gout2, ap_gout3, ap_gout4)

/* ----- Event Manager ----------------------------------------------------- */

#define	evnt_keybd()\
	aes(20)
#define	evnt_button(clicks, mask, state, mx, my, button, kstate)\
	aes(21, clicks, mask, state, mx, my, button, kstate)
#define	evnt_mouse(flags, x, y,	width, height, mx, my, button, kstate)\
	aes(22, flags, x, y, width, height, mx, my, button, kstate)
#define	evnt_mesag(pbuff)\
	aes(23, pbuff)
#define	evnt_timer(locount, hicount)\
	aes(24, locount, hicount)
#define	evnt_multi(flags, bclicks, bmask, bstate, m1flags, m1x,	m1y, m1width, m1height,	m2flags, m2x, m2y, m2width, m2height, mgpbuff, tlocount, thicount, mox,	moy, mobutton, mokstate, kreturn, breturn)\
	aes(25, flags,	bclicks, bmask,	bstate,	m1flags, m1x, m1y, m1width, m1height, m2flags, m2x, m2y, m2width, m2height, tlocount, thicount,	mgpbuff, mox, moy, mobutton, mokstate, kreturn,	breturn)

/* ----- Menu Manager ------------------------------------------------------ */

#define	menu_bar(tree, show)\
	aes(30, show, tree)
#define	menu_icheck(tree, item,	check)\
	aes(31, item, check, tree)
#define	menu_ienable(tree, item, enable)\
	aes(32, item, enable, tree)
#define	menu_tnormal(tree, title, normal)\
	aes(33, title,	normal,	tree)
#define	menu_text(tree,	item, text)\
	aes(34, item, tree, text)
#define	menu_register(rapid, pstring)\
	aes(35, rapid,	pstring)

#define menu_popup(me_menu, me_xpos, me_ypos, me_mdata)\
	aes(36, me_xpos, me_ypos, me_menu, me_mdata)
#define menu_attach(me_flag, me_tree, me_item, me_mdata)\
	aes(37, me_flag, me_item, me_tree, me_mdata)
#define menu_istart(me_flag, me_tree, me_imenu, me_item)\
	aes(38, me_flag, me_imenu, me_item, me_tree)
#define menu_settings(me_flag, me_values)\
	aes(39, me_flag, me_values)

/* ----- Objects ----------------------------------------------------------- */

#define	objc_add(tree, parent, child)\
	aes(40, parent, child,	tree)
#define	objc_delete(tree, object)\
	aes(41, object, tree)
#define	objc_draw(tree,	startob, depth,	xclip, yclip, wclip, hclip)\
	aes(42, startob, depth, xclip,	yclip, wclip, hclip, tree)
#define	objc_find(tree,	startob, depth,	mx, my)\
	aes(43, startob, depth, mx, my, tree)
#define	objc_offset(tree, object, xoff,	yoff)\
	aes(44, object, tree, xoff, yoff)
#define	objc_order(tree, object, newpos)\
	aes(45, object, newpos, tree)
#define	objc_edit(tree,	object,	char, idx, kind)\
	aes(46, object, char, *(idx), kind, tree, idx)
/*
#define	objc_edit(tree,	object,	char, idx, kind, newidx)\
	aes(46, object, char, idx, kind, tree, newidx) */
#define	objc_change(tree, object, resvd, xclip,	yclip, wclip, hclip, newstate, redraw)\
	aes(47, object, 0/*resvd*/, xclip, yclip, wclip, hclip, newstate, redraw, tree)

#define objc_sysvar(ob_smode, ob_swhich, ob_sival1, ob_sival2, ob_soval1, ob_soval2)\
	aes(48, ob_smode, ob_swhich, ob_sival1, ob_sival2, ob_soval1, ob_soval2)

/* ----- Forms/Dialogs ----------------------------------------------------- */

#define	form_do(tree, startob)\
	aes(50, startob, tree)
#define	form_dial(flag,	littlx,	littly,	littlw,	littlh,	bigx, bigy, bigw, bigh)\
	aes(51, flag, littlx, littly, littlw, littlh, bigx, bigy, bigw, bigh)
#define	form_alert(defbttn, string)\
	aes(52, defbttn, string)
#define	form_error(enum)\
	aes(53, enum)
#define	form_center(tree, x, y,	w, h)\
	aes(54, tree, x, y, w,	h)
#define	form_keybd(tree, object, obnext, char, nxtobject, nxtchar)\
	aes(55, object, char, obnext, tree, nxtobject,	nxtchar)
#define	form_button(tree, object, clicks, nxtobj)\
	aes(56, object, clicks, tree, nxtobj)

/* ----- Graf Handler ------------------------------------------------------ */

#define	graf_rubberbox(x, y, minwidth, minheight, lastwidth, lastheight)\
	aes(70, x, y, minwidth, minheight, lastwidth, lastheight)
#define	graf_dragbox(width, height, startx, starty, boundx, boundy, boundw, boundh, finishx, finishy)\
	aes(71, width,	height,	startx,	starty,	boundx,	boundy,	boundw,	boundh,	finishx, finishy)
#define	graf_movebox(width, height, sourcex, sourcey, destx, desty)\
	aes(72, width,	height,	sourcex, sourcey, destx, desty)
#define	graf_growbox(stx, sty, stwidth,	stheight, finx,	finy, finwidth,	finheight)\
	aes(73, stx, sty, stwidth, stheight, finx, finy, finwidth, finheight)
#define	graf_shrinkbox(finx, finy, finwidth, finheight,	stx, sty, stwidth, stheight)\
	aes(74, finx, finy, finwidth, finheight, stx, sty, stwidth, stheight)
#define	graf_watchbox(tree, object, instate, outstate)\
	aes(75, object, instate, outstate, tree)
#define	graf_slidebox(ptree, parent, object, vh)\
	aes(76, parent, object, vh, ptree)
#define	graf_handle(wchar, hchar, wbox,	hbox)\
	aes(77, wchar,	hchar, wbox, hbox)
#define	graf_mouse(number, faddr)\
	aes(78, number, faddr)
#define	graf_mkstate(mx, my, mstate, kstate)\
	aes(79, mx, my, mstate, kstate)

#define	graf_mbox	graf_movebox

/* ----- Scrap ------------------------------------------------------------- */

#define	scrp_read(pscrap)\
	aes(80, pscrap)
#define	scrp_write(pscrap)\
	aes(81, pscrap)
#define scrp_clear()\
	aes(82)

/* ----- File-Selector ----------------------------------------------------- */

#define	fsel_input(inpath, insel, exbutton)\
	aes(90, inpath, insel,	exbutton)
#define	fsel_exinput(inpath, insel, exbutton, label)\
	aes(91, inpath, insel,	label, exbutton)

/* ----- Windows ----------------------------------------------------------- */

#define	wind_create(kind, wx, wy, ww, wh)\
	aes(100, kind,	wx, wy,	ww, wh)
#define	wind_open(handle, x, y,	w, h)\
	aes(101, handle, x, y,	w, h)
#define	wind_close(handle)\
	aes(102, handle)
#define	wind_delete(handle)\
	aes(103, handle)
#define	wind_get(handle, field,	w1, w2,	w3, w4)\
	aes(104, handle, field, w1, w2, w3, w4)
#define	wind_set(handle, field,	w1, w2,	w3, w4)\
	aes(105, handle, field, w1, w2, w3, w4)
#define	wind_newdesk(handle, addr, object)\
	aes(105, handle, WF_NEWDESK, addr, object, 0)
#define	wind_find(mx, my)\
	aes(106, mx, my)
#define	wind_update(begend)\
	aes(107, begend)
#define	wind_calc(type,	kind, inx, iny,	inw, inh, outx,	outy, outw, outh)\
	aes(108, type,	kind, inx, iny,	inw, inh, outx,	outy, outw, outh)
#define	wind_new()\
	aes(109)

/* ----- Resources --------------------------------------------------------- */

#define	rsrc_load(pfname)\
	aes(110, pfname)
#define	rsrc_free()\
	aes(111)
#define	rsrc_gaddr(type, index,	addr)\
	aes(112, type,	index, addr)
#define	rsrc_saddr(type, index,	addr)\
	aes(113, type,	index, addr)
#define	rsrc_obfix(tree, object)\
	aes(114, object, tree)
#define rsrc_rcfix(rc_header)\
	aes(115, rc_header)

/* ----- Shell Functions --------------------------------------------------- */

#define	shel_read(pcmd,	ptail)\
	aes(120, pcmd,	ptail)
#define	shel_write(doex, isgr, iscr, pcmd, ptail)\
	aes(121, doex,	isgr, iscr, pcmd, ptail)
#define	shel_get(addr, len)\
	aes(122, len, addr)
#define	shel_put(addr, len)\
	aes(123, len, addr)
#define	shel_find(pbuff)\
	aes(124, pbuff)
#define	shel_envrn(pvalue, parm)\
	aes(125, pvalue, parm)
					/* only GEM/2 ... */
#define shel_rdef(lpcmd, lpdir)\
	aes(126, lpcmd, lpdir)
#define shel_wdef(lpcmd, lpdir)\
	aes(127, lpcmd, lpdir)\

/* ---- XGRFs -------------------------------------------------------------- */

					/* only GEM/2 ... */
#define xgrf_stepcalc(orgw, orgh, xc, yc, w, h, pcx, pcy, pcnt, pxstep, pystep)\
	aes(130, orgw, orgh, xc, yc, w, h, pcx, pcy, pcnt, pxstep, pystep)
#define xgrf_2box(xc, yc, w, h, corners, cnt, xstep, ystep, doubled)\
	aes(131, cnt, xstep, ystep, doubled, corners, xc, yc, w, h)

#endif

/* ----- end of SMALLAES.H ------------------------------------------------- */
