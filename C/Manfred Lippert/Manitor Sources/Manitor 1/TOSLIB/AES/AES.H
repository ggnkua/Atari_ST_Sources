/*----------------------------------------------------------------------------------------
	aes.h, part of TOS Linker for CodeWarrior

	AES system calls for TOS
	
	26.10.1998 by Manfred Lippert
	based on MT_AES from Andreas Kromke

	last change: 12.11.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_aes_h__
#define __TOS_aes_h__

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !defined( __TOS )
	#include <..\gemdos\gemdos.h>
#endif

#include <..\vdi\vdi.h>

#if !TARGET_TOS
	#error AES-Lib used in Non-TOS Project
#endif
#if !MC68K
	#error AES-Lib used in Non-68K Project
#endif


typedef struct
{
        int16     g_x;    /* x, obere linke Ecke des Rechtecks */
        int16     g_y;    /* y, obere linke Ecke des Rechtecks */
        int16     g_w;    /* Breite des Rechtecks              */
        int16     g_h;    /* Hîhe des Rechtecks                */
} GRECT;

/****** GEMparams *******************************************************/

typedef struct {
	int16	*contrl;
	int16	*global;
	int16	*intin;
	int16	*intout;
	void	**addrin;
	void	**addrout;
} AESPB;

typedef struct {
	int16	contrl[5];
	int16	intin[16];
	int16	intout[16];
	void	*addrin[16];
	void	*addrout[16];
} PARMDATA;

typedef struct {
	int16	x;
	int16	y;
	int16	bstate;
	int16	kstate;
} EVNTDATA;

/* Low Level Interface */
extern C_CALL void _mt_aes(__A0(PARMDATA *d), __A1(int16 *ctrldata), int16 *global);

/* MultiTOS Drag&Drop definitions */

#define DD_OK		0
#define DD_NAK		1
#define DD_EXT		2
#define DD_LEN		3

#define DD_TIMEOUT	1000	/* timeout in ms */

#define DD_NUMEXTS	8		/* number of formats */
#define DD_EXTSIZE	32		/* length of format field */

#define DD_FNAME		"U:\\PIPE\\DRAGDROP.AA"
#define DD_NAMEMAX	128	/* max. length of format name */
#define DD_HDRMIN		9		/* min. length of Drag&Drop header */
#define DD_HDRMAX		( 8 + DD_NAMEMAX )	/* max. length */

extern int16 _app;			/* programm is application or accessory? */

/****** Application definitions *****************************************/

/* extended appl_write structure */

typedef struct {
	int16	dst_apid;
	int16	unique_flg;
	void	*attached_mem;
	int16	*msgbuf;
} XAESMSG;

extern C_CALL int16 appl_init( int16 *global );
extern C_CALL int16 appl_read( int16 ap_rid, int16 ap_rlength, void *ap_rpbuff, int16 *global );
extern C_CALL int16 appl_write( int16 ap_wid, int16 ap_wlength, void *ap_wpbuff, int16 *global );
extern C_CALL int16 appl_find( char *ap_fpname, int16 *global );
extern C_CALL int16 appl_tplay( void *ap_tpmem, int16 ap_tpnum, int16 ap_tpscale, int16 *global );
extern C_CALL int16 appl_trecord( void *ap_trmem, int16 ap_trcount, int16 *global );
extern C_CALL int16 appl_exit( int16 *global );
extern C_CALL int16 appl_search( int16 ap_smode, char *ap_sname, int16 *ap_stype, int16 *ap_sid, int16 *global );
extern C_CALL void appl_yield( int16 *global );
extern C_CALL int16 appl_getinfo( int16 ap_gtype, int16 *ap_gout1, int16 *ap_gout2, int16 *ap_gout3, int16 *ap_gout4, int16 *global );

#define	appl_bvset( disks, harddisks ) /* ignore (GEM for PC): void appl_bvset( int16 disks, int16 harddisks ); */


/****** Event definitions ***********************************************/

#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

#define MN_SELECTED		10
#define WM_REDRAW			20
#define WM_TOPPED			21
#define WM_CLOSED			22
#define WM_FULLED			23
#define WM_ARROWED		24
#define WM_HSLID			25
#define WM_VSLID			26
#define WM_SIZED			27
#define WM_MOVED			28
#define WM_NEWTOP			29
#define WM_UNTOPPED		30			/* GEM  2.x    */
#define WM_ONTOP			31			/* AES 4.0     */
#define WM_BOTTOMED		33			/* AES 4.1     */
#define WM_ICONIFY		34			/* AES 4.1     */
#define WM_UNICONIFY		35			/* AES 4.1     */
#define WM_ALLICONIFY	36			/* AES 4.1     */
#define AC_OPEN			40
#define AC_CLOSE			41
#define CT_UPDATE			50
#define CT_MOVE			51
#define CT_NEWTOP			52
#define CT_KEY				53
#define AP_TERM			50			/* AES 4.0     */
#define AP_TFAIL			51			/* AES 4.0     */
#define AP_RESCHG			57			/* AES 4.0     */
#define SHUT_COMPLETED	60			/* AES 4.0     */
#define RESCH_COMPLETED	61			/* AES 4.0     */
#define AP_DRAGDROP		63			/* AES 4.0     */
#define SH_WDRAW			72			/* MultiTOS    */
#define SC_CHANGED		80
#define PRN_CHANGED		82
#define FNT_CHANGED		83
#define THR_EXIT			88			/* MagiC 4.5	*/
#define PA_EXIT			89			/* MagiC 3     */
#define CH_EXIT			90			/* MultiTOS    */
#define WM_M_BDROPPED	100		/* KAOS 1.4    */
#define SM_M_SPECIAL		101		/* MAG!X       */
#define SM_M_RES2			102		/* MAG!X       */
#define SM_M_RES3			103		/* MAG!X       */
#define SM_M_RES4			104		/* MAG!X       */
#define SM_M_RES5			105		/* MAG!X       */
#define SM_M_RES6			106		/* MAG!X       */
#define SM_M_RES7			107		/* MAG!X       */
#define SM_M_RES8			108		/* MAG!X       */
#define SM_M_RES9			109		/* MAG!X       */
#define WM_SHADED			22360		/* [WM_SHADED apid 0 win 0 0 0 0] */
#define WM_UNSHADED		22361		/* [WM_UNSHADED apid 0 win 0 0 0 0] */

#define MSG_NOEVENT     0x0998

/* SM_M_SPECIAL codes */

#define SMC_TIDY_UP		0			/* MagiC 2	*/
#define SMC_TERMINATE	1			/* MagiC 2	*/
#define SMC_SWITCH		2			/* MagiC 2	*/
#define SMC_FREEZE		3			/* MagiC 2	*/
#define SMC_UNFREEZE		4			/* MagiC 2	*/
#define SMC_RES5			5			/* MagiC 2	*/
#define SMC_UNHIDEALL	6			/* MagiC 3.1	*/
#define SMC_HIDEOTHERS	7			/* MagiC 3.1	*/
#define SMC_HIDEACT		8			/* MagiC 3.1	*/


/* Keybord states */

#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_SHIFT	(K_LSHIFT|K_RSHIFT)
#define K_CTRL		0x0004
#define K_ALT		0x0008
#define K_CAPS		0x0010

typedef struct {	/* mouse rectangle for EVNT_multi() */
	int16	m_out;
	int16	m_x;
	int16	m_y;
	int16	m_w;
	int16	m_h;
} MOBLK;

typedef struct {	/* event structure for EVNT_multi(), etc. */
	int16	mwhich;
	int16	mx;
	int16	my;
	int16	mbutton;
	int16	kstate;
	int16	key;
	int16	mclicks;
	int16	reserved[9];
	int16	msg[16];
} EVNT;

/* special types for EventMulti */
typedef struct {
	/* input parameters */
	int16	flags, max_clicks, mask, state,
			m1flags, m1x, m1y, m1w, m1h,
			m2flags, m2x, m2y, m2w, m2h,
			lo, hi;
} EVENT_in;

typedef struct {
	/* output parameters */
	int16	which, x, y, but, shift, key, clicks;
} EVENT_out;

typedef struct {
	EVENT_in i;			/* input */
	EVENT_out o;		/* output */
	int16 msg[8];		/* message buffer */
} EVENT;


extern C_CALL int16 evnt_keybd( int16 *global );
extern C_CALL int16 evnt_button( int16 nclicks, int16 bmask, int16 bstate, EVNTDATA *ev,  int16 *global );
extern C_CALL int16 evnt_mouse( int16 flg_leave, GRECT16 *g, EVNTDATA *ev, int16 *global );
extern C_CALL int16 evnt_mesag( int16 *ev_mgpbuff,  int16 *global );
extern C_CALL int16 evnt_timer( uint32 ms,  int16 *global );
extern C_CALL int16 evnt_dclick( int16 ev_dnew, int16 ev_dgetset, int16 *global );

extern C_CALL int16 EvntMulti( EVENT *evnt_struct, int16 *global );

extern C_CALL int16 evnt_multi(
			int16 evtypes,
			int16 nclicks, int16 bmask, int16 bstate,
			int16 flg1_leave, GRECT16 *g1,
			int16 flg2_leave, GRECT16 *g2,
			int16 *msgbuf,
			uint32 ms,
			EVNTDATA *ev,
			int16 *keycode,
			int16 *nbclicks,
			int16 *global );

extern C_CALL void EVNT_multi( int16 evtypes, int16 nclicks, int16 bmask, int16 bstate,
					MOBLK *m1, MOBLK *m2, uint32 ms, EVNT *event, int16 *global );


/****** Object definitions **********************************************/

#define G_BOX			20u
#define G_TEXT			21u
#define G_BOXTEXT		22u
#define G_IMAGE		23u
#define G_USERDEF		24u
#define G_IBOX			25u
#define G_BUTTON		26u
#define G_BOXCHAR		27u
#define G_STRING		28u
#define G_FTEXT		29u
#define G_FBOXTEXT	30u
#define G_ICON			31u
#define G_TITLE		32u
#define G_CICON		33u
#define G_SWBUTTON	34u			/* MAG!X */
#define G_POPUP		35u			/* MAG!X */
#define G_RESVD1		36u			/* MagiC 3.1 */
#define G_EDIT			37u			/* editobjc.slb */
#define G_SHORTCUT	38u			/* MagiC 6 */


/* Object flags */

#define NONE			0x0000u
#define SELECTABLE	0x0001u
#define DEFAULT		0x0002u
#define EXIT			0x0004u
#define EDITABLE		0x0008u
#define RBUTTON		0x0010u
#define LASTOB			0x0020u
#define TOUCHEXIT		0x0040u
#define HIDETREE		0x0080u
#define INDIRECT		0x0100u
#define FL3DMASK		0x0600u
#define FL3DNONE		0x0000u
#define FL3DIND		0x0200u	/* 3D Indicator	AES 4.0	*/
#define FL3DBAK		0x0400u	/* 3D Background	AES 4.0	*/
#define FL3DACT		0x0600u	/* 3D Activator	AES 4.0	*/
#define SUBMENU		0x0800u

/* Object states */

#define NORMAL		0x00u
#define SELECTED	0x01u
#define CROSSED	0x02u
#define CHECKED	0x04u
#define DISABLED	0x08u
#define OUTLINED	0x10u
#define SHADOWED	0x20u
#define WHITEBAK	0x40u
#define DRAW3D		0x80u			/* GEM 2.x     */

/* objc_sysvar */

#define LK3DIND		1				/* AES 4.0		*/
#define LK3DACT		2				/* AES 4.0		*/
#define INDBUTCOL		3				/* AES 4.0		*/
#define ACTBUTCOL		4				/* AES 4.0		*/
#define BACKGRCOL		5				/* AES 4.0		*/
#define AD3DVALUE		6				/* AES 4.0		*/
#define MX_ENABLE3D	10				/* MagiC 3.0	*/
#define MENUCOL		11				/* MagiC 6.0	*/


typedef struct {	/* form_xdo definitions */
	char scancode;
	char nclicks;
	int16  objnr;
} SCANX;

typedef struct {
	SCANX	*unsh;
	SCANX	*shift;
	SCANX	*ctrl;
 	SCANX	*alt;
	void	*resvd;
} XDO_INF;

typedef struct _xted { /* scrollable textedit objects */
	char	*xte_ptmplt;
	char	*xte_pvalid;
	int16	xte_vislen;
	int16	xte_scroll;
} XTED;


/* Object colors */

#define WHITE		0
#define BLACK		1
#define RED			2
#define GREEN		3
#define BLUE		4
#define CYAN		5
#define YELLOW		6
#define MAGENTA	7
#define LWHITE		8
#define LBLACK		9
#define LRED		10
#define LGREEN		11
#define LBLUE		12
#define LCYAN		13
#define LYELLOW	14
#define LMAGENTA	15

#define ROOT		0
#define MAX_LEN	81		/* max string length */
#define MAX_DEPTH	8		/* max depth of search or draw */

#define IBM			3		/* font types */
#define SMALL		5


#define TE_LEFT	0		/* editable text justification */
#define TE_RIGHT	1
#define TE_CNTR	2

#define ED_START	0		/* editable text field definitions */
#define ED_INIT	1
#define ED_CHAR	2
#define ED_END		3
#define ED_CRSR	100		/* MAG!X       */
#define ED_DRAW	103		/* MAG!X 2.00  */


typedef struct orect {
     struct orect *o_link;
     int16     o_x;
     int16     o_y;
     int16     o_w;
     int16     o_h;
} ORECT;


/* Object structures */

typedef struct {
	char	*te_ptext;        /* ptr to text (must be 1st) */
	char	*te_ptmplt;       /* ptr to template */
	char	*te_pvalid;       /* ptr to validation */
	int16	te_font;          /* font */
	int16	te_junk1;         /* junk */
	int16	te_just;          /* justification: left, right... */
	int16	te_color;         /* color information */
	int16	te_junk2;         /* junk */
	int16	te_thickness;     /* border thickness */
	int16	te_txtlen;        /* text string length */
	int16	te_tmplen;        /* template string length */
} TEDINFO;


typedef struct {
	int16	*ib_pmask;
	int16	*ib_pdata;
	char	*ib_ptext;
	int16	ib_char;
	int16	ib_xchar;
	int16	ib_ychar;
	int16	ib_xicon;
	int16	ib_yicon;
	int16	ib_wicon;
	int16	ib_hicon;
	int16	ib_xtext;
	int16	ib_ytext;
	int16	ib_wtext;
	int16	ib_htext;
} ICONBLK;


typedef struct cicon_data {
	int16	num_planes;		/* number of planes in the following data */
	int16	*col_data;		/* pointer to color bitmap in standard form */
	int16	*col_mask;		/* pointer to single plane mask of col_data */
	int16	*sel_data;		/* pointer to color bitmap of selected icon */
	int16	*sel_mask;		/* pointer to single plane mask of selected icon */
	struct cicon_data *next_res;	/* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
	ICONBLK	monoblk;		/* default monochrome icon */
	CICON	*mainlist;		/* list of color icons for different resolutions */
} CICONBLK;

typedef struct {
	int16	*bi_pdata;	/* ptr to bit forms data */
	int16	bi_wb;		/* width of form in bytes */
	int16	bi_hl;		/* height in lines */
	int16	bi_x;			/* source x in bit form */
	int16	bi_y;			/* source y in bit form */
	int16	bi_color;	/* foreground color */
} BITBLK;

typedef struct {
	int16 CDECL (*ub_code)(struct __parmblk *parmblock);
	int32 ub_parm;
} USERBLK;

typedef struct {
	unsigned character	:  8;
	signed   framesize	:  8;
	unsigned framecol		:  4;
	unsigned textcol		:  4;
	unsigned textmode		:  1;
	unsigned fillpattern	:  3;
	unsigned interiorcol	:  4;
} bfobspec;

typedef union obspecptr {
	int32			index;
	union obspecptr *indirect;
	bfobspec		obspec;
	TEDINFO		*tedinfo;
	ICONBLK		*iconblk;
	CICONBLK		*ciconblk;
	BITBLK		*bitblk;
	USERBLK		*userblk;
	char			*free_string;
} OBSPEC;


typedef struct {
	int16		ob_next;		/* -> object's next sibling     */
	int16		ob_head;		/* -> head of object's children */
	int16		ob_tail;		/* -> tail of object's children */
	uint16	ob_type;		/* object type: BOX, CHAR,...   */
	uint16	ob_flags;	/* object flags                 */
	uint16	ob_state;	/* state: SELECTED, OPEN, ...   */
	OBSPEC	ob_spec;		/* "out": -> anything else      */
	int16		ob_x;			/* upper left corner of object  */
	int16		ob_y;			/* upper left corner of object  */
	int16		ob_width;	/* object width                 */
	int16		ob_height;	/* object height                */
} OBJECT;


typedef struct __parmblk {
	OBJECT	*pb_tree;
	int16		pb_obj;
	int16		pb_prevstate;
	int16		pb_currstate;
	int16		pb_x, pb_y, pb_w, pb_h;
	int16		pb_xc, pb_yc, pb_wc, pb_hc;
	int32		pb_parm;
} PARMBLK;


typedef struct {
	OBJECT	*mn_tree;
	int16		mn_menu;
	int16		mn_item;
	int16		mn_scroll;
	int16		mn_keystate;
} MENU;


typedef struct {
	int32	display;
	int32	drag;
	int32	delay;
	int32	speed;
	int16	height;
} MN_SET;


typedef struct {
	char	*string;		/* e.g. "TOS|KAOS|MAG!X" */
	int16	num;			/* number of actual string */
	int16	maxnum;		/* max. <num> */
} SWINFO;

typedef struct {
	OBJECT	*tree;	/* popup menu */
	int16		obnum;	/* actual object of <tree> */
} POPINFO;

/****** Menu definitions ************************************************/

/* menu_bar modes */

#define MENU_HIDE		0		/* TOS         */
#define MENU_SHOW		1		/* TOS         */
#define MENU_INSTL	100	/* MAG!X       */

extern C_CALL int16 menu_bar( OBJECT *me_btree, int16 me_bshow, int16 *global );
extern C_CALL int16 menu_icheck( OBJECT *me_ctree, int16 me_citem, int16 me_ccheck, int16 *global );
extern C_CALL int16 menu_ienable( OBJECT *me_etree, int16 me_eitem, int16 me_eenable, int16 *global );
extern C_CALL int16 menu_tnormal( OBJECT *me_ntree, int16 me_ntitle, int16 me_nnormal, int16 *global );
extern C_CALL int16 menu_text( OBJECT *tree, int16 objnr, const char *text, int16 *global );
extern C_CALL int16 menu_register( int16 apid, const char *text, int16 *global );
extern C_CALL int16 menu_popup( MENU *me_menu, int16 me_xpos, int16 me_ypos, MENU *me_mdata, int16 *global );
extern C_CALL int16 menu_attach( int16 me_flag, OBJECT *me_tree, int16 me_item, MENU *me_mdata, int16 *global );
extern C_CALL int16 menu_istart( int16 me_flag, OBJECT *me_tree, int16 me_imenu, int16 me_item, int16 *global );
extern C_CALL int16 menu_settings( int16 flag, MN_SET *values, int16 *global );
extern C_CALL int16 menu_unregister( int16 menuid, int16 *global );
extern C_CALL int16 menu_click( int16 val, int16 setit, int16 *global );                 /* GEM 3.x     */


/* Object prototypes */

extern C_CALL int16 objc_add( OBJECT *ob_atree, int16 ob_aparent, int16 ob_achild, int16 *global );
extern C_CALL int16 objc_delete( OBJECT *ob_dltree, int16 ob_dlobject, int16 *global );
extern C_CALL int16 objc_draw( OBJECT *tree, int16 start, int16 depth, GRECT16 *g, int16 *global );
extern C_CALL int16 objc_find( OBJECT *ob_ftree, int16 ob_fstartob, int16 ob_fdepth, int16 ob_fmx, int16 ob_fmy, int16 *global );
extern C_CALL int16 objc_offset( OBJECT *ob_oftree, int16 ob_ofobject, int16 *ob_ofxoff, int16 *ob_ofyoff, int16 *global );
extern C_CALL int16 objc_order( OBJECT *ob_ortree, int16 ob_orobject, int16 ob_ornewpos, int16 *global );
extern C_CALL int16 objc_edit( OBJECT *ob_edtree, int16 ob_edobject, int16 ob_edchar, int16 *ob_edidx, int16 ob_edkind, int16 *global );
extern C_CALL int16 objc_xedit( OBJECT *tree, int16 objnr, int16 key, int16 *cursor_xpos, int16 subfn, GRECT16 *r, int16 *global );
extern C_CALL int16 objc_change( OBJECT *tree, int16 objnr, int16 resvd, GRECT16 *g, int16 newstate, int16 redraw, int16 *global );
extern C_CALL int16 objc_sysvar( int16 mode, int16 which, int16 ival1, int16 ival2, int16 *oval1, int16 *oval2, int16 *global );	/* AES 4.0     */

extern C_CALL void objc_wdraw( OBJECT *tree, int16 object, int16 depth, GRECT16 *clip,
					int16 windowhandle, int16 *global );
extern C_CALL void objc_wchange( OBJECT *tree, int16 object, int16 newstate,
					GRECT16 *clip, int16 windowhandle,
					int16 *global);
extern C_CALL int16 graf_wwatchbox( OBJECT *tree, int16 object, int16 instate,
					int16 outstate,	int16 windowhandle,
					int16 *global);
extern C_CALL int16 form_wbutton( OBJECT *tree, int16 object, int16 nclicks,
					int16 *nextob, int16 windowhandle,
					int16 *global);
extern C_CALL int16 form_wkeybd( OBJECT *tree, int16 object, int16 nextob,
					int16 ichar, int16 *onextob, int16 *ochar,
					int16 windowhandle,
					int16 *global);
extern C_CALL int16 objc_wedit( OBJECT *tree, int16 object, int16 edchar,
					int16 *didx, int16 kind, int16 windowhandle,
					int16 *global);


/****** Form definitions ************************************************/

#define FMD_START		0
#define FMD_GROW		1
#define FMD_SHRINK	2
#define FMD_FINISH	3

extern C_CALL int16 form_do( OBJECT *tree, int16 startob, int16 *global );
extern C_CALL int16 form_xdo( OBJECT *tree, int16 startob, int16 *lastcrsr, XDO_INF *tabs, void *flydial, int16 *global );	/* MAG!X       */
extern C_CALL int16 form_dial( int16 subfn, GRECT16 *lg, GRECT16 *bg, int16 *global );
extern C_CALL int16 form_xdial( int16 subfn, GRECT16 *lg, GRECT16 *bg, void **flyinf, int16 *global );
extern C_CALL int16 form_alert( int16 fo_adefbttn, const char *fo_astring, int16 *global );
extern C_CALL int16 form_error( int16 fo_enum, int16 *global );
extern C_CALL int16 form_center( OBJECT *tree, GRECT16 *g, int16 *global );
extern C_CALL int16 form_keybd( OBJECT *fo_ktree, int16 fo_kobject,
					int16 fo_kobnext, int16 fo_kchar,
					int16 *fo_knxtobject, int16 *fo_knxtchar, int16 *global );
extern C_CALL int16 form_button( OBJECT *fo_btree, int16 fo_bobject, int16 fo_bclicks, int16 *fo_bnxtobj, int16 *global );
extern C_CALL int16 form_popup( OBJECT *tree, int16 x, int16 y, int16 *global );		/* MAG!X */
extern C_CALL int16 xfrm_popup(
				OBJECT *tree, int16 x, int16 y,
				int16 firstscrlob, int16 lastscrlob,
				int16 nlines,
				void	CDECL (*init)(OBJECT *tree, int16 scrollpos,
								int16 nlines, void *param),
				void *param, int16 *lastscrlpos, int16 *global );		/* MagiC 5.03 */
extern C_CALL int16 form_xerr( int32 errcode, char *errfile, int16 *global );        /* MAG!X       */


/****** Graph definitions ************************************************/


/* Mouse forms */

#define	ARROW			0
#define	TEXT_CRSR	1
#define	HOURGLASS	2
#define	BUSYBEE		2
#define	POINT_HAND	3
#define	FLAT_HAND	4
#define	THIN_CROSS	5
#define	THICK_CROSS	6
#define	OUTLN_CROSS	7
#define	USER_DEF		255
#define	M_OFF			256
#define	M_ON			257
#define	M_SAVE		258
#define	M_RESTORE	259

/* Mouse form definition block */

typedef struct mfstr {
	int16	mf_xhot;
	int16	mf_yhot;
	int16	mf_nplanes;
	int16	mf_fg;
	int16	mf_bg;
	int16	mf_mask[16];
	int16	mf_data[16];
} MFORM;


extern C_CALL int16 graf_rubberbox( int16 gr_rx, int16 gr_ry, int16 gr_minwidth,
                    int16 gr_minheight, int16 *gr_rlastwidth,
                    int16 *gr_rlastheight, int16 *global );
extern C_CALL int16 graf_dragbox( int16 w, int16 h, int16 begx, int16 begy, GRECT16 *g, int16 *endx, int16 *endy, int16 *global );
extern C_CALL int16 graf_movebox( int16 gr_mwidth, int16 gr_mheight, int16 gr_msourcex, int16 gr_msourcey, int16 gr_mdestx, int16 gr_mdesty, int16 *global );
extern C_CALL int16 graf_growbox( GRECT16 *startg, GRECT16 *endg, int16 *global );
extern C_CALL int16 graf_shrinkbox( GRECT16 *endg, GRECT16 *startg, int16 *global );
extern C_CALL int16 graf_watchbox( OBJECT *tree, int16 obj, int16 instate, int16 outstate, int16 *global );
extern C_CALL int16 graf_slidebox( OBJECT *gr_slptree, int16 gr_slparent, int16 gr_slobject, int16 gr_slvh, int16 *global );
extern C_CALL int16 graf_handle( int16 *gr_hwchar, int16 *gr_hhchar, int16 *gr_hwbox, int16 *gr_hhbox, int16 *global );
extern C_CALL int16 graf_xhandle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox, int16 *dev, int16 *global );    /* KAOS 1.4    */
extern C_CALL int16 graf_mouse( int16 gr_monumber, MFORM *gr_mofaddr, int16 *global );
extern C_CALL int16 graf_mkstate( EVNTDATA *ev, int16 *global );


/****** Scrap definitions ***********************************************/

extern C_CALL int16 scrp_read( char *sc_rpscrap, int16 *global );
extern C_CALL int16 scrp_write( char *sc_wpscrap, int16 *global );
extern C_CALL int16 scrp_clear( int16 *global );                               /* GEM 2.x     */

/****** File selector definitions ***************************************/


extern C_CALL int16 fsel_input( char *path, char *name, int16 *button, int16 *global );
extern C_CALL int16 fsel_exinput( char *path, char *name, int16 *button, char *label, int16 *global );

/****** Window definitions **********************************************/

#define NAME			0x0001
#define CLOSER			0x0002
#define FULLER			0x0004
#define MOVER			0x0008
#define INFO			0x0010
#define SIZER			0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE			0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE			0x0800
#define HOTCLOSEBOX	0x1000			/* GEM 2.x     */
#define BACKDROP		0x2000			/* KAOS 1.4    */
#define ICONIFIER		0x4000			/* AES 4.1     */
#define SMALLER		ICONIFIER


/* AES wind_s/get()- Modes */

#define WF_KIND				1
#define WF_NAME				2
#define WF_INFO				3
#define WF_WORKXYWH			4
#define WF_CURRXYWH			5
#define WF_PREVXYWH			6
#define WF_FULLXYWH			7
#define WF_HSLIDE				8
#define WF_VSLIDE				9
#define WF_TOP					10
#define WF_FIRSTXYWH			11
#define WF_NEXTXYWH			12
#define WF_RESVD				13
#define WF_NEWDESK			14
#define WF_HSLSIZE			15
#define WF_VSLSIZE			16
#define WF_SCREEN				17
#define WF_COLOR				18
#define WF_DCOLOR				19
#define WF_OWNER				20
#define WF_BEVENT				24
#define WF_BOTTOM				25
#define WF_ICONIFY			26			/* AES 4.1	*/
#define WF_UNICONIFY			27			/* AES 4.1	*/
#define WF_UNICONIFYXYWH	28			/* AES 4.1	*/
#define WF_M_BACKDROP		100		/* KAOS 1.4	*/
#define WF_M_OWNER			101		/* KAOS 1.4	*/
#define WF_M_WINDLIST		102		/* KAOS 1.4	*/
#define WF_MINXYWH			103		/* MagiC 6	*/
#define WF_SHADE				0x575d	/* WINX 2.3	*/
#define WF_STACK				0x575e	/* WINX 2.3	*/
#define WF_TOPALL				0x575f	/* WINX 2.3	*/
#define WF_BOTTOMALL			0x5760	/* WINX 2.3	*/

/* wind_set(WF_DCOLOR) */

#define W_BOX			0
#define W_TITLE		1
#define W_CLOSER		2
#define W_NAME			3
#define W_FULLER		4
#define W_INFO			5
#define W_DATA			6
#define W_WORK			7
#define W_SIZER		8
#define W_VBAR			9
#define W_UPARROW		10
#define W_DNARROW		11
#define W_VSLIDE		12
#define W_VELEV		13
#define W_HBAR			14
#define W_LFARROW		15
#define W_RTARROW		16
#define W_HSLIDE		17
#define W_HELEV		18
#define W_SMALLER		19				/* AES 4.1 */
#define W_BOTTOMER	20				/* MagiC 3 */

/* wind_set(WF_BEVENT) */

#define BEVENT_WORK	0x0001		/* AES 4.0 */
#define BEVENT_INFO	0x0002		/* MagiC 6 */

/* Window Messages */

#define WA_UPPAGE	0
#define WA_DNPAGE	1
#define WA_UPLINE	2
#define WA_DNLINE	3
#define WA_LFPAGE	4
#define WA_RTPAGE	5
#define WA_LFLINE	6
#define WA_RTLINE	7

#define WC_BORDER	0	/* wind calc flags */
#define WC_WORK	1

#define END_UPDATE	0	/* update flags */
#define BEG_UPDATE	1
#define END_MCTRL		2
#define BEG_MCTRL		3

extern C_CALL int16 wind_create( int16 kind, GRECT16 *maxsize, int16 *global );
extern C_CALL int16 wind_open( int16 whdl, GRECT16 *g, int16 *global );
extern C_CALL int16 wind_close( int16 whdl, int16 *global );
extern C_CALL int16 wind_delete( int16 whdl, int16 *global );
extern C_CALL int16 wind_get( int16 whdl, int16 subfn, int16 *g1, int16 *g2, int16 *g3, int16 *g4, int16 *global );
extern C_CALL int16 wind_get_rect( int16 whdl, int16 subfn, GRECT16 *g, int16 *global );
extern C_CALL int16 wind_get_ptr( int16 whdl, int16 subfn, void **v, int16 *global );
extern C_CALL int16 wind_get_int16( int16 whdl, int16 subfn, int16 *g1, int16 *global );
extern C_CALL int16 wind_set( int16 whdl, int16 subfn, int16 g1, int16 g2, int16 g3, int16 g4, int16 *global );
extern C_CALL int16 wind_set_string( int16 whdl, int16 subfn, char *s, int16 *global );
extern C_CALL int16 wind_set_rect( int16 whdl, int16 subfn, GRECT16 *g, int16 *global );
extern C_CALL int16 wind_set_ptr_int( int16 whdl, int16 subfn, void *s, int16 i, int16 *global );
extern C_CALL int16 wind_set_int( int16 whdl, int16 subfn, int16 g1, int16 *global );
extern C_CALL int16 wind_find( int16 wi_fmx, int16 wi_fmy, int16 *global );
extern C_CALL int16 wind_update( int16 wi_ubegend, int16 *global );
extern C_CALL int16 wind_calc( int16 subfn, int16 kind, GRECT16 *ing, GRECT16 *outg, int16 *global );
extern C_CALL void wind_new( int16 *global );

/****** Resource definitions ********************************************/

/* data strucure types */
#define R_TREE			0
#define R_OBJECT		1
#define R_TEDINFO		2
#define R_ICONBLK		3
#define R_BITBLK		4
#define R_STRING		5		/* gets pointer to free strings */
#define R_IMAGEDATA	6		/* gets pointer to free images */
#define R_OBSPEC		7
#define R_TEPTEXT		8		/* sub ptrs in TEDINFO */
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK		11		/* sub ptrs in ICONBLK */
#define R_IBPDATA		12
#define R_IBPTEXT		13
#define R_BIPDATA		14		/* sub ptrs in BITBLK */
#define R_FRSTR		15		/* gets addr of ptr to free strings */
#define R_FRIMG		16		/* gets addr of ptr to free images  */

typedef struct rshdr {
	uint16	rsh_vrsn;
	uint16	rsh_object;
	uint16	rsh_tedinfo;
	uint16	rsh_iconblk;	/* list of ICONBLKS */
	uint16	rsh_bitblk;
	uint16	rsh_frstr;
	uint16	rsh_string;
	uint16	rsh_imdata;		/* image data */
	uint16	rsh_frimg;
	uint16	rsh_trindex;
	uint16	rsh_nobs;		/* counts of various structs */
	uint16	rsh_ntree;
	uint16	rsh_nted;
	uint16	rsh_nib;
	uint16	rsh_nbb;
	uint16	rsh_nstring;
	uint16	rsh_nimages;
	uint16	rsh_rssize;		/* total bytes in resource */
} RSHDR;

extern C_CALL int16 rsrc_load( char *filename, int16 *global );
extern C_CALL int16 rsrc_free( int16 *global );
extern C_CALL int16 rsrc_gaddr( int16 type, int16 index, void *addr, int16 *global );
extern C_CALL int16 rsrc_saddr( int16 type, int16 index, void *o, int16 *global );
extern C_CALL int16 rsrc_obfix( OBJECT *re_otree, int16 re_oobject, int16 *global );
extern C_CALL int16 rsrc_rcfix( RSHDR *rsh, int16 *global );

extern C_CALL void recalc_cicon_colours( int16 palette[256][3], int16 *global );

/****** Shell definitions ***********************************************/

/* tail for default shell */

typedef struct {
	int16	dummy;	/* ein Nullwort */
	int32	magic;	/* 'SHEL', wenn ist Shell */
	int16	isfirst;	/* erster Aufruf der Shell */
	int32	lasterr;	/* letzter Fehler */
	int16	wasgr;	/* Programm war Grafikapp. */
} SHELTAIL;

/* shel_write modes for parameter "isover" */

#define SHW_IMMED		0		/* PC-GEM 2.x  */
#define SHW_CHAIN		1		/* TOS         */
#define SHW_DOS		2		/* PC-GEM 2.x  */
#define SHW_PARALLEL	100	/* MAG!X       */
#define SHW_SINGLE	101	/* MAG!X       */

/* shel_write modes for parameter "doex" */

#define SHW_NOEXEC		0
#define SHW_EXEC			1
#define SHW_EXEC_ACC		3		/* AES 3.3 */
#define SHW_SHUTDOWN		4		/* AES 3.3 */
#define SHW_RESCHNG		5		/* AES 3.3 */
#define SHW_BROADCAST	7		/* AES 4.0 */
#define SHW_INFRECGN		9		/* AES 4.0 */
#define SHW_AESSEND		10		/* AES 4.0 */
#define SHW_THR_CREATE	20		/* MagiC 4.5 */

/* extended shel_write() modes and parameter structure */

#define SHW_XMDLIMIT		256
#define SHW_XMDNICE		512
#define SHW_XMDDEFDIR	1024
#define SHW_XMDENV		2048
#define SHW_XMDFLAGS		4096

typedef struct {
	char	*command;
	int32	limit;
	int32	nice;
	char	*defdir;
	char	*env;
	int32	flags;		/* MagiC 6 */
} XSHW_COMMAND;

typedef struct {
	int32 CDECL (*proc)(void *par);
	void *user_stack;
	uint32 stacksize;
	int16 mode;		/* always set to 0! */
	int32 res1;		/* always set to 0! */
} THREADINFO;

extern C_CALL int16 shel_read( char *sh_rpcmd, char *sh_rptail, int16 *global );
extern C_CALL int16 shel_write( int16 sh_wdoex, int16 sh_wisgr, int16 sh_wiscr,
                char *sh_wpcmd, char *sh_wptail, int16 *global );
extern C_CALL int16 shel_get( char *sh_gaddr, int16 sh_glen, int16 *global );
extern C_CALL int16 shel_put( char *sh_paddr, int16 sh_plen, int16 *global );
extern C_CALL int16 shel_find( char *sh_fpbuff, int16 *global );
extern C_CALL int16 shel_envrn( char **sh_epvalue, char *sh_eparm, int16 *global );
extern C_CALL void	shel_rdef( char *cmd, char *dir, int16 *global );               /* GEM 2.x     */
extern C_CALL void	shel_wdef( char *cmd, char *dir, int16 *global );               /* GEM 2.x     */

/****** dummies ***********************************************/

#define	xgrf_stepcalc( a, b, c, d, e, f, g, h, i, j, k )	/* ignore function (GEM for PC): int16 xgrf_stepcalc( int16 orgw, int16 orgh, int16 xc, int16 yc, int16 w, int16 h, int16 *cx, int16 *cy, int16 *stepcnt, int16 *xstep, int16 *ystep ); */
#define	xgrf_2box( a, b, c, d, e, f, g, h, i )				/* ignore function (GEM for PC): int16 xgrf_2box( int16 xc, int16 yc, int16 w, int16 h, int16 corners, int16 stepcnt, int16 xstep, int16 ystep, int16 doubled ); */


/****** Wdialog definitions ***********************************************/

typedef	void	*DIALOG;

typedef	int16	CDECL (*HNDL_OBJ)( DIALOG *dialog, EVNT *events, int16 obj, int16 clicks, void *data );

extern C_CALL DIALOG	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, int16 code, void *data, int16 flags, int16 *global );
extern C_CALL int16	wdlg_open( DIALOG *dialog, char *title, int16 kind, int16 x, int16 y, int16 code, void *data, int16 *global );
extern C_CALL int16	wdlg_close( DIALOG *dialog, int16 *x, int16 *y, int16 *global );
extern C_CALL int16	wdlg_delete( DIALOG *dialog, int16 *global );

extern C_CALL int16	wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT16 *r, int16 *global );
extern C_CALL int16	wdlg_get_edit( DIALOG *dialog, int16 *cursor, int16 *global );
extern C_CALL void	*wdlg_get_udata( DIALOG *dialog, int16 *global );
extern C_CALL int16	wdlg_get_handle( DIALOG *dialog, int16 *global );

extern C_CALL int16	wdlg_set_edit( DIALOG *dialog, int16 obj, int16 *global );
extern C_CALL int16	wdlg_set_tree( DIALOG *dialog, OBJECT *tree, int16 *global );
extern C_CALL int16	wdlg_set_size( DIALOG *dialog, GRECT16 *size, int16 *global );
extern C_CALL int16	wdlg_set_iconify( DIALOG *dialog, GRECT16 *g, char *title, OBJECT *tree, int16 obj, int16 *global );
extern C_CALL int16	wdlg_set_uniconify( DIALOG *dialog, GRECT16 *g, char *title, OBJECT *tree, int16 *global );

extern C_CALL int16	wdlg_evnt( DIALOG *dialog, EVNT *events, int16 *global );
extern C_CALL void	wdlg_redraw( DIALOG *dialog, GRECT16 *rect, int16 obj, int16 depth, int16 *global );


/* Definitionen für <flags> */
#define	WDLG_BKGD	1				/* Hintergrundbedienung zulassen */

/* Funktionsnummern für <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1				/* Dialog initialisieren */
#define	HNDL_MESG	-2				/* Dialog initialisieren */
#define	HNDL_CLSD	-3				/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5				/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6				/* Zeichen für ein Edit-Feld überprüfen */
#define	HNDL_EDDN	-7				/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8				/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9				/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10				/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11				/* Dialog-Fenster ist nicht aktiv */

/****** Listbox definitions ***********************************************/
typedef	void	*LIST_BOX;

typedef	void	CDECL (*SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, void *user_data, int16 obj_index, int16 last_state );
typedef	int16	CDECL (*SET_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, int16 obj_index, void *user_data, GRECT16 *rect, int16 first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;			/* Zeiger auf den nächsten Eintrag in der Liste */
	int16	selected;					/* gibt an, ob das Objekt selektiert ist */

	int16	data1;					/* Daten für das Programm... */
	void	*data2;
	void	*data3;

} LBOX_ITEM;

#define	LBOX_VERT		1		/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO		2		/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4		/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL		8		/* Real-Time-Slider */
#define	LBOX_SNGL		16		/* nur ein anwählbarer Eint16rag */
#define	LBOX_SHFT		32		/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE		64		/* Status eines Eint16rags bei Selektion wechseln */
#define	LBOX_2SLDRS		128	/* Listbox hat einen hor. und einen vertikalen Slider */

/* #defines für Listboxen mit nur einem Slider */
#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst

#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to

extern C_CALL LIST_BOX	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, int16 visible_a, int16 first_a,
						  int16 *ctrl_objs, int16 *objs, int16 flags, int16 pause_a, void *user_data, void *dialog,
						  int16 visible_b, int16 first_b, int16 entries_b, int16 pause_b, int16 *global );

extern C_CALL void		lbox_update( LIST_BOX *box, GRECT16 *rect, int16 *global );
extern C_CALL int16	lbox_do( LIST_BOX *box, int16 obj, int16 *global );
extern C_CALL int16	lbox_delete( LIST_BOX *box, int16 *global );

extern C_CALL int16	lbox_cnt_items( LIST_BOX *box, int16 *global );
extern C_CALL OBJECT	*lbox_get_tree( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_avis( LIST_BOX *box, int16 *global );
extern C_CALL void		*lbox_get_udata( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_afirst( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_slct_idx( LIST_BOX *box, int16 *global );
extern C_CALL LBOX_ITEM	*lbox_get_items( LIST_BOX *box, int16 *global );
extern C_CALL LBOX_ITEM	*lbox_get_item( LIST_BOX *box, int16 n, int16 *global );
extern C_CALL LBOX_ITEM	*lbox_get_slct_item( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, int16 *global );
extern C_CALL int16	lbox_get_bvis( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_bentries( LIST_BOX *box, int16 *global );
extern C_CALL int16	lbox_get_bfirst( LIST_BOX *box, int16 *global );

extern C_CALL void		lbox_set_asldr( LIST_BOX *box, int16 first, GRECT16 *rect, int16 *global );
extern C_CALL void		lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, int16 *global );
extern C_CALL void		lbox_free_items( LIST_BOX *box, int16 *global );
extern C_CALL void		lbox_free_list( LBOX_ITEM *items, int16 *global );
extern C_CALL void		lbox_ascroll_to( LIST_BOX *box, int16 first, GRECT16 *box_rect, GRECT16 *slider_rect, int16 *global );
extern C_CALL void		lbox_set_bsldr( LIST_BOX *box, int16 first, GRECT16 *rect, int16 *global );
extern C_CALL void		lbox_set_bentries( LIST_BOX *box, int16 entries, int16 *global );
extern C_CALL void		lbox_bscroll_to( LIST_BOX *box, int16 first, GRECT16 *box_rect, GRECT16 *slider_rect, int16 *global );

/****** font selector definitions ***********************************************/

typedef	void	*FNT_DIALOG;

typedef	void	CDECL (*UTXT_FN)( int16 x, int16 y, int16 *clip_rect, int32 id, int32 pt, int32 ratio, char *string );

typedef struct _fnts_item
{
	struct	_fnts_item	*next;	/* Zeiger auf den nächsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;				/* Zeiger auf die Anzeige-Funktion für applikationseigene Fonts */
	int32		id;					/* ID des Fonts, >= 65536 für applikationseigene Fonts */
	int16		index;				/* Index des Fonts (falls VDI-Font) */
	int8		mono;				/* Flag für äquidistante Fonts */
	int8		outline;				/* Flag für Vektorfont */
	int16		npts;				/* Anzahl der vordefinierten Punkthöhen */
	char		*full_name;			/* Zeiger auf den vollständigen Namen */
	char		*family_name;			/* Zeiger auf den Familiennamen */
	char		*style_name;			/* Zeiger auf den Stilnamen */
	int8		*pts;				/* Zeiger auf Feld mit Punkthöhen */
	int32		reserved[4];			/* reserviert, müssen 0 sein */
} FNTS_ITEM;

/* Definitionen für <font_flags> bei fnts_create() */

#define FNTS_BTMP		1				/* Bitmapfonts anzeigen */
#define FNTS_OUTL		2				/* Vektorfonts anzeigen */
#define FNTS_MONO		4				/* äquidistante Fonts anzeigen */
#define FNTS_PROP		8				/* proportionale Fonts anzeigen */

/* Definitionen für <dialog_flags> bei fnts_create() */
#define FNTS_3D		1				/* 3D-Design benutzen */

/* Definitionen für <button_flags> bei fnts_open() */
#define FNTS_SNAME		0x01		/* Checkbox für die Namen selektieren */
#define FNTS_SSTYLE		0x02		/* Checkbox für die Stile selektieren */
#define FNTS_SSIZE		0x04		/* Checkbox für die Höhe selektieren */
#define FNTS_SRATIO		0x08		/* Checkbox für das Verhältnis Breite/Höhe selektieren */

#define FNTS_CHNAME	0x0100	/* Checkbox für die Namen anzeigen */
#define FNTS_CHSTYLE	0x0200	/* Checkbox für die Stile anzeigen */
#define FNTS_CHSIZE	0x0400	/* Checkbox für die Höhe anzeigen */
#define FNTS_CHRATIO	0x0800	/* Checkbox für das Verhältnis Breite/Höhe anzeigen */
#define FNTS_RATIO	0x1000	/* Verhältnis Breite/Höhe einstellbar */
#define FNTS_BSET		0x2000	/* Button "setzen" anwählbar */
#define FNTS_BMARK	0x4000	/* Button "markieren" anwählbar */

/* Definitionen für <button> bei fnts_evnt() */

#define FNTS_CANCEL	1		/* "Abbruch" wurde angewählt */
#define FNTS_OK		2		/* "OK" wurde gedrückt */
#define FNTS_SET		3		/* "setzen" wurde angewählt */
#define FNTS_MARK		4		/* "markieren" wurde betötigt */
#define FNTS_OPT		5		/* der applikationseigene Button wurde ausgewählt */

extern C_CALL FNT_DIALOG	*fnts_create( int16 vdi_handle, int16 no_fonts, int16 font_flags, int16 dialog_flags, char *sample, char *opt_button, int16 *global );
extern C_CALL int16	fnts_delete( FNT_DIALOG *fnt_dialog, int16 vdi_handle, int16 *global );
extern C_CALL int16	fnts_open( FNT_DIALOG *fnt_dialog, int16 button_flags, int16 x, int16 y, int32 id, int32 pt, int32 ratio, int16 *global );
extern C_CALL int16	fnts_close( FNT_DIALOG *fnt_dialog, int16 *x, int16 *y, int16 *global );

extern C_CALL int16	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, int32 id, int16 *global );
extern C_CALL int32	fnts_get_style( FNT_DIALOG *fnt_dialog, int32 id, int16 index, int16 *global );
extern C_CALL int16	fnts_get_name( FNT_DIALOG *fnt_dialog, int32 id, char *full_name, char *family_name, char *style_name, int16 *global );
extern C_CALL int16	fnts_get_info( FNT_DIALOG *fnt_dialog, int32 id, int16 *mono, int16 *outline, int16 *global );

extern C_CALL int16	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts, int16 *global );
extern C_CALL void		fnts_remove( FNT_DIALOG *fnt_dialog, int16 *global );
extern C_CALL int16	fnts_update( FNT_DIALOG *fnt_dialog, int16 button_flags, int32 id, int32 pt, int32 ratio, int16 *global );

extern C_CALL int16	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, int16 *button, int16 *check_boxes, int32 *id, int32 *pt, int32 *ratio, int16 *global );
extern C_CALL int16	fnts_do( FNT_DIALOG *fnt_dialog, int16 button_flags, int32 id_in, int32 pt_in, int32 ratio_in, int16 *check_boxes, int32 *id, int32 *pt, int32 *ratio, int16 *global );


/****** file selector definitions ***********************************************/
/* Sortiermodi */

#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4

/* Flags für Dateiauswahl */

#define DOSMODE		1
#define NFOLLOWSLKS	2
#define GETMULTI		8

/* fslx_set_flags */

#define SHOW8P3	1

typedef int16 CDECL (*XFSL_FILTER)(char *path, char *name, XATTR *xa);

extern C_CALL void * fslx_open(
			char *title,
			int16 x, int16 y,
			int16	*handle,
			char *path, int16 pathlen,
			char *fname, int16 fnamelen,
			char *patterns,
			XFSL_FILTER filter,
			char *paths,
			int16 sort_mode,
			int16 flags,
			int16 *global);

extern C_CALL int16 fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			int16 *button,
			int16 *nfiles,
			int16 *sort_mode,
			char **pattern, int16 *global );

extern C_CALL void * fslx_do(
			char *title,
			char *path, int16 pathlen,
			char *fname, int16 fnamelen,
			char *patterns,
			XFSL_FILTER filter,
			char *paths,
			int16 *sort_mode,
			int16 flags,
			int16 *button,
			int16 *nfiles,
			char **pattern, int16 *global );

extern C_CALL int16	fslx_getnxtfile( void *fsd, char *fname, int16 *global );
extern C_CALL int16	fslx_close( void *fsd, int16 *global );
extern C_CALL int16	fslx_set_flags( int16 flags, int16 *oldval, int16 *global );

/************************************************************************/

#include	<prdialog.h>	/* Struktur zum Einfügen eigener Drucker und Unterdialoge */
#include	<prsettng.h>	/* PRN_SETTINGS-Struktur */

typedef	void *PRN_DIALOG;

extern C_CALL PRN_DIALOG	*pdlg_create( int16 dialog_flags, int16 *global );
extern C_CALL int16	pdlg_delete( PRN_DIALOG *prn_dialog, int16 *global );
extern C_CALL int16	pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int16 option_flags, int16 x, int16 y, int16 *global );
extern C_CALL int16	pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y, int16 *global );

extern C_CALL int32	pdlg_get_setsize( int16 *global );

extern C_CALL int16	pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, int16 *global );
extern C_CALL int16	pdlg_remove_printers( PRN_DIALOG *prn_dialog, int16 *global );
extern C_CALL int16	pdlg_update( PRN_DIALOG *prn_dialog, char *document_name, int16 *global );
extern C_CALL int16	pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs, int16 *global );
extern C_CALL int16	pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog, int16 *global );
extern C_CALL PRN_SETTINGS	*pdlg_new_settings( PRN_DIALOG *prn_dialog, int16 *global );
extern C_CALL int16	pdlg_free_settings( PRN_SETTINGS *settings, int16 *global );
extern C_CALL int16	pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, int16 *global );
extern C_CALL int16	pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, int16 *global );
extern C_CALL int16	pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, int16 *global );
extern C_CALL int16	pdlg_save_default_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, int16 *global );

extern C_CALL int16	pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, int16 *button, int16 *global );
extern C_CALL int16	pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int16 option_flags, int16 *global );


/* <dialog_flags> für pdlg_create() */
#define	PDLG_3D					0x0001

/* <option_flags> für pdlg_open/do() */
#define	PDLG_PREFS				0x0000	/* Einstelldialog anzeigen */
#define	PDLG_PRINT				0x0001	/* Druckdialog anzeigen */

#define	PDLG_ALWAYS_COPIES	0x0010	/* immer Kopien anbieten */
#define	PDLG_ALWAYS_ORIENT	0x0020	/* immer Querformat anbieten */
#define	PDLG_ALWAYS_SCALE		0x0040	/* immer Skalierung anbieten */

#define	PDLG_EVENODD			0x0100	/* Option für gerade und ungerade Seiten anbieten */

/* <button> für pdlg_evnt()/pdlg_do */
#define	PDLG_CANCEL		1					/* "Abbruch" wurde angewählt */
#define	PDLG_OK			2					/* "OK" wurde gedrückt */


/****** edit object definitions *****************************************/

typedef void XEDITINFO;

extern C_CALL XEDITINFO *edit_create( int16 *global );
extern C_CALL int16 edit_open(OBJECT *tree, int16 obj, int16 *global);
extern C_CALL void edit_close(OBJECT *tree, int16 obj, int16 *global);
extern C_CALL void edit_delete(XEDITINFO *xi, int16 *global);
extern C_CALL int16 edit_cursor(OBJECT *tree, int16 obj, int16 whdl, int16 show, int16 *global);
extern C_CALL int16 edit_evnt(OBJECT *tree, int16 obj, int16 whdl,	EVNT *ev, int32 *errc, int16 *global);
extern C_CALL int16 edit_get_buf( OBJECT *tree, int16 obj, char **buf, int32 *buflen, int32 *txtlen, int16 *global );
extern C_CALL int16 edit_get_format( OBJECT *tree, int16 obj, int16 *tabwidth, int16 *autowrap, int16 *global );
extern C_CALL int16 edit_get_colour( OBJECT *tree, int16 obj, int16 *tcolour, int16 *bcolour, int16 *global );
extern C_CALL int16 edit_get_cursor( OBJECT *tree, int16 obj, char **cursorpos, int16 *global );
extern C_CALL int16 edit_get_font( OBJECT *tree, int16 obj,	int16 *fontID, int16 *fontH, int16 *fontPix, int16 *mono, int16 *global );
extern C_CALL void edit_set_buf( OBJECT *tree, int16 obj, char *buf, int32 buflen, int16 *global );
extern C_CALL void edit_set_format( OBJECT *tree, int16 obj, int16 tabwidth, int16 autowrap, int16 *global );
extern C_CALL void edit_set_font( OBJECT *tree, int16 obj, int16 fontID, int16 fontH, int16 fontPix, int16 mono, int16 *global );
extern C_CALL void edit_set_colour( OBJECT *tree, int16 obj, int16 tcolour, int16 bcolour, int16 *global );
extern C_CALL void edit_set_cursor( OBJECT *tree, int16 obj, char *cursorpos, int16 *global );
extern C_CALL int16 edit_resized( OBJECT *tree, int16 obj, int16 *oldrh, int16 *newrh, int16 *global );
extern C_CALL int16 edit_get_dirty( OBJECT *tree, int16 obj,	int16 *global );
extern C_CALL void edit_set_dirty( OBJECT *tree, int16 obj,	int16 dirty, int16 *global );
extern C_CALL void edit_get_sel( OBJECT *tree, int16 obj, char **bsel, char **esel, int16 *global );
extern C_CALL void edit_get_pos( OBJECT *tree, int16 obj, int16 *xscroll, int32 *yscroll, char **cyscroll, char **cursorpos, int16 *cx, int16 *cy, int16 *global );
extern C_CALL void edit_set_pos( OBJECT *tree, int16 obj, int16 xscroll, int32 yscroll, char *cyscroll, char *cursorpos, int16 cx, int16 cy, int16 *global );
extern C_CALL void edit_get_scrollinfo( OBJECT *tree, int16 obj, int32 *nlines, int32 *yscroll, int16 *yvis, int16 *yval, int16 *ncols, int16 *xscroll, int16 *xvis, int16 *global );
extern C_CALL int16 edit_scroll( OBJECT *tree, int16 obj, int16 whdl, int32 yscroll, int16 xscroll, int16 *global );

#endif
