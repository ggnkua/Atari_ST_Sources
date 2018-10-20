/*      AES.H

        GEM AES Definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __AES__ )
#define __AES__
#define __MTAES__

#include <portab.h>

/****** GEMparams *******************************************************/

typedef struct
{
	WORD	*contrl;
	WORD	*global;
	WORD	*intin;
	WORD	*intout;
	void	**addrin;
	void	**addrout;
} AESPB;

typedef struct
{
	WORD	contrl[5];
	WORD	intin[16];
	WORD	intout[16];
	void	*addrin[16];
	void	*addrout[16];
} PARMDATA;

typedef struct		/* wird nur fÅr den Haupt-Thread verwendet */
{
	WORD	contrl[15];
	WORD	global[15];
	WORD	intin[16];
	WORD	intout[16];
	void	*addrin[16];
	void	*addrout[16];
} GEMPARBLK;

typedef struct
{
	WORD	x;
	WORD	y;
	WORD	bstate;
	WORD	kstate;
} EVNTDATA;

typedef struct
{
	WORD	g_x;
	WORD	g_y;
	WORD	g_w;
	WORD	g_h;
} GRECT;

/* MultiTOS Drag&Drop definitions */

#define DD_OK		0
#define DD_NAK		1
#define DD_EXT		2
#define DD_LEN		3

#define DD_TIMEOUT	4000		/* Timeout in ms */

#define DD_NUMEXTS	8		/* Anzahl der Formate */
#define DD_EXTSIZE	32		/* LÑnge des Formatfelds */

#define DD_FNAME	"U:\\PIPE\\DRAGDROP.AA"
#define DD_NAMEMAX	128		/* maximale LÑnge eines Formatnamens */
#define DD_HDRMIN	9		/* minimale LÑnge des Drag&Drop-Headers */
#define DD_HDRMAX	( 8 + DD_NAMEMAX )	/* maximale LÑnge */



extern WORD	_app;
extern void	_crystal( AESPB *aespb );
extern GEMPARBLK	_GemParBlk;

/****** Application definitions *****************************************/

/* extended appl_write structure */

typedef struct
{
	WORD	dst_apid;
	WORD	unique_flg;
	void	*attached_mem;
	WORD	*msgbuf;
} XAESMSG;

extern void _appl_yield( void );								/* TOS */
extern WORD MT_appl_init( WORD *global );
extern WORD MT_appl_read( int ap_rid, int ap_rlength, void *ap_rpbuff, WORD *global );
extern WORD MT_appl_write( int ap_wid, int ap_wlength, void *ap_wpbuff, WORD *global );
extern WORD MT_appl_find( char *ap_fpname, WORD *global );
extern WORD MT_appl_tplay( void *ap_tpmem, int ap_tpnum, int ap_tpscale, WORD *global );
extern WORD MT_appl_trecord( void *ap_trmem, int ap_trcount, WORD *global );
extern WORD MT_appl_exit( WORD *global );
extern WORD MT_appl_search( int ap_smode, char *ap_sname, int *ap_stype, int *ap_sid, WORD *global );
extern void MT_appl_yield( WORD *global );						/* GEM 2.x */
extern WORD MT_appl_getinfo( WORD ap_gtype, WORD *ap_gout1, WORD *ap_gout2, WORD *ap_gout3, WORD *ap_gout4, WORD *global );

#define	appl_init() \
			MT_appl_init( 0L )
#define	appl_read( a, b, c ) \
			MT_appl_read( a, b, c, 0L )
#define	appl_write( a, b, c ) \
			MT_appl_write( a, b, c, 0L )
#define	appl_find( a ) \
			MT_appl_find( a, 0L )
#define	appl_tplay( a, b, c ) \
			MT_appl_tplay( a, b, c, 0L )
#define	appl_trecord( a, b ) \
			MT_appl_trecord( a, b, 0L )
#define	appl_exit() \
			MT_appl_exit( 0L )
#define	appl_search( a, b, c, d ) \
			MT_appl_search( a, b, c, d, 0L )
#define	appl_getinfo( a, b, c, d, e ) \
			MT_appl_getinfo( a, b, c, d, e, 0L )
#define	appl_yield() \
			MT_appl_yield( 0L )

#define	appl_bvset( disks, harddisks ) /* Funktion ignorieren (GEM fÅr Dose): void appl_bvset( int disks, int harddisks ); */

#define	vq_aes()	( appl_init() >= 0 )	/* WORD	vq_aes( void ); */


/****** Event definitions ***********************************************/

#define MU_KEYBD        0x0001
#define MU_BUTTON       0x0002
#define MU_M1           0x0004
#define MU_M2           0x0008
#define MU_MESAG        0x0010
#define MU_TIMER        0x0020

#define MN_SELECTED     10
#define WM_REDRAW       20
#define WM_TOPPED       21
#define WM_CLOSED       22
#define WM_FULLED       23
#define WM_ARROWED      24
#define WM_HSLID        25
#define WM_VSLID        26
#define WM_SIZED        27
#define WM_MOVED        28
#define WM_NEWTOP       29
#define WM_UNTOPPED      30                                 /* GEM  2.x    */
#define WM_ONTOP         31                                 /* AES 4.0     */
#define WM_BOTTOMED      33                                 /* AES 4.1     */
#define WM_ICONIFY       34                                 /* AES 4.1     */
#define WM_UNICONIFY     35                                 /* AES 4.1     */
#define WM_ALLICONIFY    36                                 /* AES 4.1     */
#define AC_OPEN		40
#define AC_CLOSE		41
#define CT_UPDATE		50
#define CT_MOVE		51
#define CT_NEWTOP		52
#define CT_KEY			53
#define AP_TERM          50                                 /* AES 4.0     */
#define AP_TFAIL         51                                 /* AES 4.0     */
#define AP_RESCHG        57                                 /* AES 4.0     */
#define SHUT_COMPLETED   60                                 /* AES 4.0     */
#define RESCH_COMPLETED  61                                 /* AES 4.0     */
#define AP_DRAGDROP      63                                 /* AES 4.0     */
#define SH_WDRAW         72                                 /* MultiTOS    */
#define SC_CHANGED       80                                 /* */
#define PRN_CHANGED		82
#define FNT_CHANGED		83
#define THR_EXIT		88							/* MagiC 4.5	*/
#define PA_EXIT          89                                 /* MagiC 3     */
#define CH_EXIT          90                                 /* MultiTOS    */
#define WM_M_BDROPPED    100                                /* KAOS 1.4    */
#define SM_M_SPECIAL     101                                /* MAG!X       */
#define SM_M_RES2        102                                /* MAG!X       */
#define SM_M_RES3        103                                /* MAG!X       */
#define SM_M_RES4        104                                /* MAG!X       */
#define SM_M_RES5        105                                /* MAG!X       */
#define SM_M_RES6        106                                /* MAG!X       */
#define SM_M_RES7        107                                /* MAG!X       */
#define SM_M_RES8        108                                /* MAG!X       */
#define SM_M_RES9        109                                /* MAG!X       */
#define WM_SHADED		22360						/* [WM_SHADED apid 0 win 0 0 0 0] */
#define WM_UNSHADED		22361						/* [WM_UNSHADED apid 0 win 0 0 0 0] */

/* SM_M_SPECIAL codes */

#define SMC_TIDY_UP		0							/* MagiC 2	*/
#define SMC_TERMINATE	1							/* MagiC 2	*/
#define SMC_SWITCH		2							/* MagiC 2	*/
#define SMC_FREEZE		3							/* MagiC 2	*/
#define SMC_UNFREEZE	4							/* MagiC 2	*/
#define SMC_RES5		5							/* MagiC 2	*/
#define SMC_UNHIDEALL	6							/* MagiC 3.1	*/
#define SMC_HIDEOTHERS	7							/* MagiC 3.1	*/
#define SMC_HIDEACT		8							/* MagiC 3.1	*/


/* Keybord states */

#define K_RSHIFT        0x0001
#define K_LSHIFT        0x0002
#define K_CTRL          0x0004
#define K_ALT           0x0008

typedef struct		/* Mausrechteck fÅr EVNT_multi() */
{
	WORD	m_out;
	WORD	m_x;
	WORD	m_y;
	WORD	m_w;
	WORD	m_h;
} MOBLK;

typedef struct		/* Ereignisstruktur fÅr EVNT_multi(), Fensterdialoge, etc. */
{
	WORD	mwhich;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;
	WORD	key;
	WORD	mclicks;
	WORD	reserved[9];
	WORD	msg[16];
} EVNT;

extern WORD MT_evnt_keybd( WORD *global );
extern WORD MT_evnt_button( int nclicks, int bmask, int bstate, EVNTDATA *ev,  WORD *global );
extern WORD MT_evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev, WORD *global );
extern WORD MT_evnt_mesag( int *ev_mgpbuff,  WORD *global );
extern WORD MT_evnt_timer( ULONG ms,  WORD *global );

extern WORD MT_evnt_multi(
			WORD evtypes,
			WORD nclicks, WORD bmask, WORD bstate,
			WORD flg1_leave, GRECT *g1,
			WORD flg2_leave, GRECT *g2,
			WORD *msgbuf,
			ULONG ms,
			EVNTDATA *ev,
			WORD *keycode,
			WORD *nbclicks,
			WORD *global );

extern void MT_EVNT_multi( WORD evtypes, WORD nclicks, WORD bmask, WORD bstate,
					MOBLK *m1, MOBLK *m2, ULONG ms, EVNT *event, WORD *global );

extern WORD	MT_evnt_dclick( int ev_dnew, int ev_dgetset, WORD *global );

#define	evnt_keybd() \
			MT_evnt_keybd( 0L )
#define	evnt_button( a, b, c, d ) \
			MT_evnt_button( a, b, c, d, 0L )
#define	evnt_mouse( a, b, c ) \
			MT_evnt_mouse( a, b, c, 0L )
#define	evnt_mesag( a ) \
			MT_evnt_mesag( a, 0L )
#define	evnt_timer( a ) \
			MT_evnt_timer( a, 0L )
#define	evnt_multi( a, b, c, d, e, f, g, h, i, j, k, l, m ) \
			MT_evnt_multi( a, b, c, d, e, f, g, h, i, j, k, l, m, 0L )
#define	EVNT_multi( a, b, c, d, e, f, g, h ) \
			MT_EVNT_multi( a, b, c, d, e, f, g, h, 0L )
#define	evnt_dclick( a, b ) \
			MT_evnt_dclick( a, b, 0L )

/****** Object definitions **********************************************/

#define G_BOX			20
#define G_TEXT			21
#define G_BOXTEXT		22
#define G_IMAGE		23
#define G_USERDEF		24
#define G_IBOX			25
#define G_BUTTON		26
#define G_BOXCHAR		27
#define G_STRING		28
#define G_FTEXT		29
#define G_FBOXTEXT		30
#define G_ICON			31
#define G_TITLE		32
#define G_CICON		33
#define G_SWBUTTON       34                                 /* MAG!X       */
#define G_POPUP          35                                 /* MAG!X       */
#define G_RESVD1		36							/* MagiC 3.1	*/



/* Object flags */

#define NONE         0x0000
#define SELECTABLE   0x0001
#define DEFAULT      0x0002
#define EXIT         0x0004
#define EDITABLE     0x0008
#define RBUTTON      0x0010
#define LASTOB       0x0020
#define TOUCHEXIT    0x0040
#define HIDETREE     0x0080
#define INDIRECT     0x0100
#ifndef FL3DMASK
#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200	/* 3D Indicator			  AES 4.0		*/
#define FL3DBAK      0x0400	/* 3D Background			  AES 4.0		*/
#define FL3DACT      0x0600	/* 3D Activator			  AES 4.0		*/
#endif
#define SUBMENU      0x0800

/* Object states */

#define NORMAL          0x00
#define SELECTED        0x01
#define CROSSED         0x02
#define CHECKED         0x04
#define DISABLED        0x08
#define OUTLINED        0x10
#define SHADOWED        0x20
#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

/* objc_sysvar */

#ifndef LK3DIND
#define LK3DIND      1                                      /* AES 4.0     */
#define LK3DACT      2                                      /* AES 4.0     */
#define INDBUTCOL    3                                      /* AES 4.0     */
#define ACTBUTCOL    4                                      /* AES 4.0     */
#define BACKGRCOL    5                                      /* AES 4.0     */
#define AD3DVALUE    6                                      /* AES 4.0     */
#define MX_ENABLE3D  10                                     /* MagiC 3.0   */
#endif


typedef struct	/* form_xdo definitions */
{
	char scancode;
	char nclicks;
	int  objnr;
} SCANX;

typedef struct
{
	SCANX	*unsh;
	SCANX	*shift;
	SCANX	*ctrl;
 	SCANX	*alt;
	void	*resvd;
} XDO_INF;

typedef struct _xted /* scrollable textedit objects */
{
	char	*xte_ptmplt;
	char	*xte_pvalid;
	WORD	xte_vislen;
	WORD	xte_scroll;
} XTED;


/* Object colors */
#if !defined(__COLORS)
#define __COLORS /*
                 using AES-colors and BGI-colors
                 is not possible
                 */

#define WHITE            0
#define BLACK            1
#define RED              2
#define GREEN            3
#define BLUE             4
#define CYAN             5
#define YELLOW           6
#define MAGENTA          7
#define LWHITE           8
#define LBLACK           9
#define LRED            10
#define LGREEN          11
#define LBLUE           12
#define LCYAN           13
#define LYELLOW         14
#define LMAGENTA        15

#endif

#define ROOT             0
#define MAX_LEN         81              /* max string length */
#define MAX_DEPTH        8              /* max depth of search or draw */


#define IBM             3               /* font types */
#define SMALL           5


#define TE_LEFT         0               /* editable text justification */
#define TE_RIGHT        1
#define TE_CNTR         2

#define ED_START        0               /* editable text field definitions */
#define ED_INIT         1
#define ED_CHAR         2
#define ED_END          3
#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */


typedef struct orect
{
	struct orect	*o_link;
	WORD	o_x;
	WORD	o_y;
	WORD	o_w;
	WORD	o_h;
} ORECT;


/* Object structures */

typedef struct
{
        char            *te_ptext;      /* ptr to text (must be 1st)    */
        char            *te_ptmplt;     /* ptr to template              */
        char            *te_pvalid;     /* ptr to validation            */
        int             te_font;        /* font                         */
        int             te_junk1;       /* junk int                     */
        int             te_just;        /* justification: left, right...*/
        int             te_color;       /* color information            */
        int             te_junk2;       /* junk int                     */
        int             te_thickness;   /* border thickness             */
        int             te_txtlen;      /* text string length           */
        int             te_tmplen;      /* template string length       */
} TEDINFO;


typedef struct
{
        int     *ib_pmask;
        int     *ib_pdata;
        char    *ib_ptext;
        int     ib_char;
        int     ib_xchar;
        int     ib_ychar;
        int     ib_xicon;
        int     ib_yicon;
        int     ib_wicon;
        int     ib_hicon;
        int     ib_xtext;
        int     ib_ytext;
        int     ib_wtext;
        int     ib_htext;
} ICONBLK;


typedef struct cicon_data {
    int    num_planes;            /* number of planes in the following data */
    int    *col_data;             /* pointer to color bitmap in standard form */
    int    *col_mask;             /* pointer to single plane mask of col_data */
    int    *sel_data;             /* pointer to color bitmap of selected icon */
    int    *sel_mask;             /* pointer to single plane mask of selected icon */
    struct cicon_data *next_res;  /* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
    ICONBLK monoblk;	          /* default monochrome icon */
    CICON *mainlist;	          /* list of color icons for different resolutions */
} CICONBLK;

typedef struct
{
        int     *bi_pdata;              /* ptr to bit forms data        */
        int     bi_wb;                  /* width of form in bytes       */
        int     bi_hl;                  /* height in lines              */
        int     bi_x;                   /* source x in bit form         */
        int     bi_y;                   /* source y in bit form         */
        int     bi_color;               /* foreground color             */
} BITBLK;


struct __parmblk;

#ifndef __STDC__        /*
                                         *      using this structure is not possible
                                         *      if ANSI keywords only is ON
                                         */
typedef struct
{
        int cdecl (*ub_code)(struct __parmblk *parmblock);
        long      ub_parm;
} USERBLK;
#endif

typedef struct
{
        unsigned character   :  8;
        signed   framesize   :  8;
        unsigned framecol    :  4;
        unsigned textcol     :  4;
        unsigned textmode    :  1;
        unsigned fillpattern :  3;
        unsigned interiorcol :  4;
} bfobspec;

typedef union obspecptr
{
        long     index;
        union obspecptr *indirect;
        bfobspec obspec;
        TEDINFO  *tedinfo;
        ICONBLK  *iconblk;
        CICONBLK *ciconblk;
        BITBLK   *bitblk;
#ifndef __STDC__
        USERBLK *userblk;
#endif
        char    *free_string;
} OBSPEC;


typedef struct
{
        int             ob_next;        /* -> object's next sibling     */
        int             ob_head;        /* -> head of object's children */
        int             ob_tail;        /* -> tail of object's children */
        unsigned int    ob_type;        /* object type: BOX, CHAR,...   */
        unsigned int    ob_flags;       /* object flags                 */
        unsigned int    ob_state;       /* state: SELECTED, OPEN, ...   */
        OBSPEC          ob_spec;        /* "out": -> anything else      */
        int             ob_x;           /* upper left corner of object  */
        int             ob_y;           /* upper left corner of object  */
        int             ob_width;       /* object width                 */
        int             ob_height;      /* object height                */
} OBJECT;


typedef struct __parmblk
{
        OBJECT  *pb_tree;
        int     pb_obj;
        int     pb_prevstate;
        int     pb_currstate;
        int     pb_x, pb_y, pb_w, pb_h;
        int     pb_xc, pb_yc, pb_wc, pb_hc;
        long    pb_parm;
} PARMBLK;


typedef struct
{
        OBJECT  *mn_tree;
        int     mn_menu;
        int     mn_item;
        int     mn_scroll;
        int	 mn_keystate;
} MENU;


typedef struct
{
        long   Display;
        long   Drag;
        long   Delay;
        long   Speed;
        int    Height;
} MN_SET;


typedef struct {
     char *string;                 /* etwa "TOS|KAOS|MAG!X"                */
     int  num;                     /* Nr. der aktuellen Zeichenkette       */
     int  maxnum;                  /* maximal erlaubtes <num>              */
     } SWINFO;

typedef struct {
     OBJECT *tree;                 /* Popup- MenÅ                          */
     int  obnum;                   /* aktuelles Objekt von <tree>          */
     } POPINFO;

/****** Menu definitions ************************************************/

/* menu_bar modes */

#define MENU_HIDE        0                                  /* TOS         */
#define MENU_SHOW        1                                  /* TOS         */
#define MENU_INSTL       100                                /* MAG!X       */

extern WORD	MT_menu_bar( OBJECT *me_btree, int me_bshow, WORD *global );
extern WORD	MT_menu_icheck( OBJECT *me_ctree, int me_citem, int me_ccheck, WORD *global );
extern WORD	MT_menu_ienable( OBJECT *me_etree, int me_eitem, int me_eenable, WORD *global );
extern WORD	MT_menu_tnormal( OBJECT *me_ntree, int me_ntitle, int me_nnormal, WORD *global );
extern WORD MT_menu_text( OBJECT *tree, WORD objnr, const char *text, WORD *global );
extern WORD MT_menu_register( WORD apid, const char *text, WORD *global );
extern WORD	MT_menu_popup( MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata, WORD *global );
extern WORD	MT_menu_attach( int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata, WORD *global );
extern WORD	MT_menu_istart( int me_flag, OBJECT *me_tree, int me_imenu, int me_item, WORD *global );
extern WORD MT_menu_settings( WORD flag, MN_SET *values, WORD *global );
extern WORD MT_menu_unregister( WORD menuid, WORD *global );
extern WORD	MT_menu_click( int val, int setit, WORD *global );                 /* GEM 3.x     */

#define	menu_bar( a, b ) \
			MT_menu_bar( a, b, 0L )
#define	menu_icheck( a, b, c ) \
			MT_menu_icheck( a, b, c, 0L )
#define	menu_ienable( a, b, c ) \
			MT_menu_ienable( a, b, c, 0L )
#define	menu_tnormal( a, b, c ) \
			MT_menu_tnormal( a, b, c, 0L )
#define	menu_text( a, b, c ) \
			MT_menu_text( a, b, c, 0L )
#define	menu_register( a, b ) \
			MT_menu_register( a, b, 0L )
#define	menu_popup( a, b, c, d ) \
			MT_menu_popup( a, b, c, d, 0L )
#define	menu_attach( a, b, c, d ) \
			MT_menu_attach( a, b, c, d, 0L )
#define	menu_istart( a, b, c, d ) \
			MT_menu_istart( a, b, c, d, 0L )
#define	menu_settings( a, b ) \
			MT_menu_settings( a, b, 0L )
#define	menu_unregister( a ) \
			MT_menu_unregister( a, 0L )
#define	menu_click( a, b ) \
			MT_menu_click( a, b, 0L )



/* Object prototypes */

extern WORD MT_objc_add( OBJECT *ob_atree, WORD ob_aparent, WORD ob_achild, WORD *global );
extern WORD MT_objc_delete( OBJECT *ob_dltree, WORD ob_dlobject, WORD *global );
extern WORD MT_objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g, WORD *global );
extern WORD MT_objc_find( OBJECT *ob_ftree, WORD ob_fstartob, WORD ob_fdepth, WORD ob_fmx, WORD ob_fmy, WORD *global );
extern WORD MT_objc_offset( OBJECT *ob_oftree, WORD ob_ofobject, WORD *ob_ofxoff, int *ob_ofyoff, WORD *global );
extern WORD MT_objc_order( OBJECT *ob_ortree, WORD ob_orobject, WORD ob_ornewpos, WORD *global );
extern WORD MT_objc_edit( OBJECT *ob_edtree, WORD ob_edobject, WORD ob_edchar, WORD *ob_edidx, WORD ob_edkind, WORD *global );
extern WORD MT_objc_xedit( OBJECT *tree, WORD objnr, WORD key, WORD *cursor_xpos, WORD subfn, GRECT *r, WORD *global );
extern WORD MT_objc_change( OBJECT *tree, WORD objnr, WORD resvd, GRECT *g, WORD newstate, WORD redraw, WORD *global );
extern WORD MT_objc_sysvar( WORD mode, WORD which, WORD ival1, WORD ival2, WORD *oval1, WORD *oval2, WORD *global );	/* AES 4.0     */

#define	objc_add( a, b, c ) \
			MT_objc_add( a, b, c, 0L )
#define	objc_delete( a, b ) \
			MT_objc_delete( a, b, 0L )
#define	objc_draw( a, b, c, d ) \
			MT_objc_draw( a, b, c, d, 0L )
#define	objc_find( a, b, c, d, e ) \
			MT_objc_find( a, b, c, d, e, 0L )
#define	objc_offset( a, b, c, d ) \
			MT_objc_offset( a, b, c, d, 0L )
#define	objc_order( a, b, c ) \
			MT_objc_order( a, b, c, 0L )
#define	objc_edit( a, b, c, d, e ) \
			MT_objc_edit( a, b, c, d, e, 0L )
#define	objc_xedit( a, b, c, d, e, f ) \
			MT_objc_xedit( a, b, c, d, e, f, 0L )
#define	objc_change( a, b, c, d, e, f ) \
			MT_objc_change( a, b, c, d, e, f, 0L )
#define	objc_sysvar( a, b, c, d, e, f ) \
			MT_objc_sysvar( a, b, c, d, e, f, 0L )

/****** Form definitions ************************************************/

#define FMD_START       0
#define FMD_GROW        1
#define FMD_SHRINK      2
#define FMD_FINISH      3

extern WORD MT_form_do( OBJECT *tree, WORD startob, WORD *global );
extern WORD MT_form_xdo( OBJECT *tree, WORD startob, WORD *lastcrsr, XDO_INF *tabs, void *flydial, WORD *global );	/* MAG!X       */
extern WORD MT_form_dial( WORD subfn, GRECT *lg, GRECT *bg, WORD *global );
extern WORD MT_form_xdial( WORD subfn, GRECT *lg, GRECT *bg, void **flyinf, WORD *global );
extern WORD MT_form_alert( WORD fo_adefbttn, const char *fo_astring, WORD *global );
extern WORD MT_form_error( WORD fo_enum, WORD *global );
extern WORD MT_form_center( OBJECT *tree, GRECT *g, WORD *global );
extern WORD MT_form_keybd( OBJECT *fo_ktree, WORD fo_kobject,
					WORD fo_kobnext, WORD fo_kchar,
					WORD *fo_knxtobject, WORD *fo_knxtchar, WORD *global );
extern WORD MT_form_button( OBJECT *fo_btree, WORD fo_bobject, WORD fo_bclicks, WORD *fo_bnxtobj, WORD *global );
extern WORD MT_form_popup( OBJECT *tree, WORD x, WORD y, WORD *global );		/* MAG!X */
extern WORD MT_xfrm_popup(
				OBJECT *tree, WORD x, WORD y,
				WORD firstscrlob, WORD lastscrlob,
				WORD nlines,
				void	cdecl (*init)(OBJECT *tree, WORD scrollpos,
								WORD nlines, void *param),
				void *param, WORD *lastscrlpos, WORD *global );		/* MagiC 5.03 */
extern WORD MT_form_xerr( long errcode, char *errfile, WORD *global );        /* MAG!X       */

#define	form_do( a, b ) \
			MT_form_do( a, b, 0L )
#define	form_xdo( a, b, c, d, e ) \
			MT_form_xdo( a, b, c, d, e, 0L )
#define	form_dial( a, b, c ) \
			MT_form_dial( a, b, c, 0L )
#define	form_xdial( a, b, c, d ) \
			MT_form_xdial( a, b, c, d, 0L )
#define	form_alert( a, b ) \
			MT_form_alert( a, b, 0L )
#define	form_error( a ) \
			MT_form_error( a, 0L )
#define	form_center( a, b ) \
			MT_form_center( a, b, 0L )
#define	form_keybd( a, b, c, d, e, f ) \
			MT_form_keybd( a, b, c, d, e, f, 0L )
#define	form_button( a, b, c, d ) \
			MT_form_button( a, b, c, d, 0L )
#define	form_popup( a, b, c ) \
			MT_form_popup( a, b, c, 0L )
#define	xfrm_popup( a, b, c, d, e, f, g, h, i ) \
			MT_xfrm_popup( a, b, c, d, e, f, g, h, i, 0L )
#define	form_xerr( a, b ) \
			MT_form_xerr( a, b, 0L )

/****** Graph definitions ************************************************/


/* Mouse forms */

#define	ARROW				0
#define	TEXT_CRSR		1
#define	HOURGLASS		2
#define	BUSYBEE			2
#define	POINT_HAND		3
#define	FLAT_HAND		4
#define	THIN_CROSS		5
#define	THICK_CROSS		6
#define	OUTLN_CROSS		7
#define	USER_DEF			255
#define	M_OFF				256
#define	M_ON				257
#define	M_SAVE			258
#define	M_RESTORE		259

/* Mouse form definition block */

typedef struct mfstr
{
        int     mf_xhot;
        int     mf_yhot;
        int     mf_nplanes;
        int     mf_fg;
        int     mf_bg;
        int     mf_mask[16];
        int     mf_data[16];
} MFORM;



extern WORD	MT_graf_rubberbox( int gr_rx, int gr_ry, int gr_minwidth,
                    int gr_minheight, int *gr_rlastwidth,
                    int *gr_rlastheight, WORD *global );
extern WORD	MT_graf_dragbox( WORD w, WORD h, WORD begx, WORD begy, GRECT *g, WORD *endx, WORD *endy, WORD *global );
extern WORD	MT_graf_movebox( int gr_mwidth, int gr_mheight, int gr_msourcex, int gr_msourcey, int gr_mdestx, int gr_mdesty, WORD *global );
extern WORD	MT_graf_growbox( GRECT *startg, GRECT *endg, WORD *global );
extern WORD	MT_graf_shrinkbox( GRECT *endg, GRECT *startg, WORD *global );
extern WORD	MT_graf_watchbox( OBJECT *tree, WORD obj, WORD instate, WORD outstate, WORD *global );
extern WORD	MT_graf_slidebox( OBJECT *gr_slptree, int gr_slparent, int gr_slobject, int gr_slvh, WORD *global );
extern WORD	MT_graf_handle( int *gr_hwchar, int *gr_hhchar, int *gr_hwbox, int *gr_hhbox, WORD *global );
extern WORD	MT_graf_xhandle( int *wchar, int *hchar, int *wbox, int *hbox, int *dev, WORD *global );    /* KAOS 1.4    */
extern WORD	MT_graf_mouse( int gr_monumber, MFORM *gr_mofaddr, WORD *global );
extern WORD	MT_graf_mkstate( EVNTDATA *ev, WORD *global );

#define	graf_rubbox( a, b, c, d, e, f ) \
			MT_graf_rubberbox( a, b, c, d, e, f, 0L )
#define	graf_dragbox( a, b, c, d, e, f, g ) \
			MT_graf_dragbox( a, b, c, d, e, f, g, 0L )
#define	graf_movebox( a, b, c, d, e, f ) \
			MT_graf_movebox( a, b, c, d, e, f, 0L )
#define	graf_growbox( a, b ) \
			MT_graf_growbox(a,b,0L )
#define	graf_shrinkbox( a, b ) \
			MT_graf_shrinkbox( a, b, 0L )
#define	graf_watchbox( a, b, c, d ) \
			MT_graf_watchbox( a, b, c, d, 0L )
#define	graf_slidebox( a, b, c, d ) \
			MT_graf_slidebox( a, b, c, d, 0L )
#define	graf_handle( a, b, c, d ) \
			MT_graf_handle( a, b, c, d, 0L )
#define	graf_xhandle( a, b, c, d, e ) \
			MT_graf_xhandle( a, b, c, d, e, 0L )
#define	graf_mouse( a, b ) \
			MT_graf_mouse( a, b, 0L )
#define	graf_mkstate( a ) \
			MT_graf_mkstate( a, 0L )

/****** Scrap definitions ***********************************************/

WORD	MT_scrp_read( char *sc_rpscrap, WORD *global );
WORD	MT_scrp_write( char *sc_wpscrap, WORD *global );
WORD	MT_scrp_clear( WORD *global );                               /* GEM 2.x     */

#define	scrp_read( a ) \
			MT_scrp_read( a, 0L )
#define	scrp_write( a ) \
			MT_scrp_write( a, 0L )
#define	scrp_clear() \
			MT_scrp_clear( 0L )

/****** File selector definitions ***************************************/


extern WORD	MT_fsel_input( char *path, char *name, WORD *button, WORD *global );
extern WORD	MT_fsel_exinput( char *path, char *name, WORD *button, char *label, WORD *global );

#define	fsel_input( a, b, c ) \
			MT_fsel_input( a, b, c, 0L )
#define	fsel_exinput( a, b, c, d ) \
			MT_fsel_exinput( a, b, c, d, 0L )

/****** Window definitions **********************************************/

#define NAME    0x0001
#define CLOSER  0x0002
#define FULLER  0x0004
#define MOVER   0x0008
#define INFO    0x0010
#define SIZER   0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE  0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE  0x0800
#define HOTCLOSEBOX      0x1000                             /* GEM 2.x     */
#define BACKDROP         0x2000                             /* KAOS 1.4    */
#define ICONIFIER        0x4000                             /* AES 4.1     */
#define SMALLER ICONIFIER


/* AES wind_s/get()- Modes */

#define WF_KIND          1
#define WF_NAME          2
#define WF_INFO          3
#define WF_WORKXYWH      4
#define WF_CURRXYWH      5
#define WF_PREVXYWH      6
#define WF_FULLXYWH      7
#define WF_HSLIDE        8
#define WF_VSLIDE        9
#define WF_TOP          10
#define WF_FIRSTXYWH	11
#define WF_NEXTXYWH     12
#define WF_RESVD        13
#define WF_NEWDESK      14
#define WF_HSLSIZE      15
#define WF_VSLSIZE      16
#define WF_SCREEN       17
#define WF_COLOR        18
#define WF_DCOLOR       19
#define WF_OWNER        20
#define WF_BEVENT       24
#define WF_BOTTOM       25
#define WF_ICONIFY       26                                 /* AES 4.1     */
#define WF_UNICONIFY     27                                 /* AES 4.1     */
#define WF_UNICONIFYXYWH 28                                 /* AES 4.1     */
#define WF_M_BACKDROP    100                                /* KAOS 1.4    */
#define WF_M_OWNER       101                                /* KAOS 1.4    */
#define WF_M_WINDLIST    102                                /* KAOS 1.4    */
#define WF_SHADE		0x575d						/* WINX 2.3	*/
#define WF_STACK		0x575e						/* WINX 2.3	*/
#define WF_TOPALL		0x575f						/* WINX 2.3	*/
#define WF_BOTTOMALL	0x5760						/* WINX 2.3	*/

/* wind_set(WF_DCOLOR) */

#define W_BOX            0
#define W_TITLE          1
#define W_CLOSER         2
#define W_NAME           3
#define W_FULLER         4
#define W_INFO           5
#define W_DATA           6
#define W_WORK           7
#define W_SIZER          8
#define W_VBAR           9
#define W_UPARROW       10
#define W_DNARROW       11
#define W_VSLIDE        12
#define W_VELEV         13
#define W_HBAR          14
#define W_LFARROW       15
#define W_RTARROW       16
#define W_HSLIDE        17
#define W_HELEV         18
#define W_SMALLER        19                                 /* AES 4.1     */
#define W_BOTTOMER       20                                 /* MagiC 3     */

#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

#define WC_BORDER 0                     /* wind calc flags */
#define WC_WORK   1

#define END_UPDATE 0                    /* update flags */
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

extern WORD	MT_wind_create( WORD kind, GRECT *maxsize, WORD *global );
extern WORD	MT_wind_open( WORD whdl, GRECT *g, WORD *global );
extern WORD	MT_wind_close( WORD whdl, WORD *global );
extern WORD	MT_wind_delete( WORD whdl, WORD *global );
extern WORD	MT_wind_get( WORD whdl, WORD subfn, WORD *g1, WORD *g2, WORD *g3, WORD *g4, WORD *global );
extern WORD	MT_wind_get_grect( WORD whdl, WORD subfn, GRECT *g, WORD *global );
extern WORD	MT_wind_get_ptr( WORD whdl, WORD subfn, void **v, WORD *global );
extern WORD	MT_wind_set( WORD whdl, WORD subfn, WORD g1, WORD g2, WORD g3, WORD g4, WORD *global );
extern WORD	MT_wind_set_string( WORD whdl, WORD subfn, char *s, WORD *global );
extern WORD	MT_wind_set_grect( WORD whdl, WORD subfn, GRECT *g, WORD *global );
extern WORD	MT_wind_find( int wi_fmx, int wi_fmy, WORD *global );
extern WORD	MT_wind_update( int wi_ubegend, WORD *global );
extern WORD	MT_wind_calc( WORD subfn, WORD kind,	GRECT *ing, GRECT *outg, WORD *global );
extern void	MT_wind_new( WORD *global );

#define	wind_create( a, b ) \
			MT_wind_create( a, b, 0L )
#define	wind_open( a, b ) \
			MT_wind_open( a, b, 0L )
#define	wind_close( a ) \
			MT_wind_close( a, 0L )
#define	wind_delete( a ) \
			MT_wind_delete( a,0L )
#define	wind_get( a, b, c, d, e, f ) \
			MT_wind_get( a, b, c, d, e, f, 0L )
#define	wind_get_grect( a, b, c ) \
			MT_wind_get_grect( a, b, c, 0L )
#define	wind_get_ptr( a, b, c ) \
			MT_wind_get_ptr( a, b, c, 0L )
#define	wind_set( a, b, c, d, e, f ) \
			MT_wind_set( a, b, c, d, e, f, 0L )
#define	wind_set_string( a, b, c ) \
			MT_wind_set_string( a, b, c, 0L )
#define	wind_set_grect( a, b, c ) \
			MT_wind_set_grect( a, b, c, 0L )
#define	wind_find( a, b ) \
			MT_wind_find( a, b, 0L )
#define	wind_update( a ) \
			MT_wind_update( a, 0L )
#define	wind_calc( a, b, c, d ) \
			MT_wind_calc( a, b, c, d, 0L )

/****** Resource definitions ********************************************/

                                /* data structure types */
#define R_TREE           0
#define R_OBJECT         1
#define R_TEDINFO        2
#define R_ICONBLK        3
#define R_BITBLK         4
#define R_STRING         5              /* gets pointer to free strings */
#define R_IMAGEDATA      6              /* gets pointer to free images */
#define R_OBSPEC         7
#define R_TEPTEXT        8              /* sub ptrs in TEDINFO */
#define R_TEPTMPLT       9
#define R_TEPVALID      10
#define R_IBPMASK       11              /* sub ptrs in ICONBLK */
#define R_IBPDATA       12
#define R_IBPTEXT       13
#define R_BIPDATA       14              /* sub ptrs in BITBLK */
#define R_FRSTR         15              /* gets addr of ptr to free strings */
#define R_FRIMG         16              /* gets addr of ptr to free images  */

typedef struct rshdr
{
	UWORD	rsh_vrsn;
	UWORD	rsh_object;
	UWORD	rsh_tedinfo;
	UWORD	rsh_iconblk;    /* list of ICONBLKS */
	UWORD	rsh_bitblk;
	UWORD	rsh_frstr;
	UWORD	rsh_string;
	UWORD	rsh_imdata;     /* image data */
	UWORD	rsh_frimg;
	UWORD	rsh_trindex;
	UWORD	rsh_nobs;       /* counts of various structs */
	UWORD	rsh_ntree;
	UWORD	rsh_nted;
	UWORD	rsh_nib;
	UWORD	rsh_nbb;
	UWORD	rsh_nstring;
	UWORD	rsh_nimages;
	UWORD	rsh_rssize;     /* total bytes in resource */
} RSHDR;

extern WORD MT_rsrc_load( char *filename, WORD *global );
extern WORD MT_rsrc_free( WORD *global );
extern WORD MT_rsrc_gaddr( WORD type, WORD index, void *addr, WORD *global );
extern WORD MT_rsrc_saddr( WORD type, WORD index, void *o, WORD *global );
extern WORD MT_rsrc_obfix( OBJECT *re_otree, int re_oobject, WORD *global );
extern WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global );

#define	rsrc_load( a ) \
			MT_rsrc_load( a, 0L )
#define	rsrc_free() \
			MT_rsrc_free( 0L )
#define	rsrc_gaddr( a, b, c ) \
			MT_rsrc_gaddr( a, b, c, 0L )
#define	rsrc_saddr( a, b, c ) \
			MT_rsrc_saddr( a, b, c, 0L )
#define	rsrc_obfix( a, b ) \
			MT_rsrc_obfix( a, b, 0L )
#define	rsrc_rcfix( a ) \
			MT_rsrc_rcfix( a, 0L )

/****** Shell definitions ***********************************************/

/* tail for default shell */

typedef struct
{
	int  dummy;                   /* ein Nullwort               */
	long magic;                   /* 'SHEL', wenn ist Shell     */
	int  isfirst;                 /* erster Aufruf der Shell    */
	long lasterr;                 /* letzter Fehler             */
	int  wasgr;                   /* Programm war Grafikapp.    */
} SHELTAIL;

/* shel_write modes for parameter "isover" */

#define SHW_IMMED        0                                  /* PC-GEM 2.x  */
#define SHW_CHAIN        1                                  /* TOS         */
#define SHW_DOS          2                                  /* PC-GEM 2.x  */
#define SHW_PARALLEL     100                                /* MAG!X       */
#define SHW_SINGLE       101                                /* MAG!X       */

/* shel_write modes for parameter "doex" */

#define SHW_NOEXEC       0
#define SHW_EXEC         1
#define SHW_EXEC_ACC	3							/* AES 3.3	*/
#define SHW_SHUTDOWN     4                                  /* AES 3.3     */
#define SHW_RESCHNG      5                                  /* AES 3.3     */
#define SHW_BROADCAST    7                                  /* AES 4.0     */
#define SHW_INFRECGN     9                                  /* AES 4.0     */
#define SHW_AESSEND      10                                 /* AES 4.0     */
#define SHW_THR_CREATE	20							/* MagiC 4.5	*/

/* extended shel_write() modes and parameter structure */

#define SHW_XMDLIMIT	256
#define SHW_XMDNICE		512
#define SHW_XMDDEFDIR	1024
#define SHW_XMDENV		2048

typedef struct {
	char	*command;
	long	limit;
	long nice;
	char *defdir;
	char *env;
} XSHW_COMMAND;

typedef struct {
	LONG cdecl (*proc)(void *par);
	void *user_stack;
	ULONG stacksize;
	WORD mode;		/* immer auf 0 setzen! */
	LONG res1;		/* immer auf 0L setzen! */
} THREADINFO;

extern WORD	MT_shel_read( char *sh_rpcmd, char *sh_rptail, WORD *global );
extern WORD	MT_shel_write( WORD sh_wdoex, WORD sh_wisgr, WORD sh_wiscr,
                char *sh_wpcmd, char *sh_wptail, WORD *global );
extern WORD	MT_shel_get( char *sh_gaddr, UWORD sh_glen, WORD *global );
extern WORD	MT_shel_put( char *sh_paddr, UWORD sh_plen, WORD *global );
extern WORD	MT_shel_find( char *sh_fpbuff, WORD *global );
extern WORD	MT_shel_envrn( char **sh_epvalue, char *sh_eparm, WORD *global );
extern void	MT_shel_rdef( char *cmd, char *dir, WORD *global );               /* GEM 2.x     */
extern void	MT_shel_wdef( char *cmd, char *dir, WORD *global );               /* GEM 2.x     */

#define	shel_read( a, b ) \
			MT_shel_read( a, b, 0L )
#define	shel_write( a, b, c, d, e ) \
			MT_shel_write( a, b, c, d, e, 0L )
#define	shel_get( a, b ) \
			MT_shel_get( a, b, 0L )
#define	shel_put( a, b) \
			MT_shel_put( a, b, 0L )
#define	shel_find( a ) \
			MT_shel_find( a, 0L )
#define	shel_envrn( a, b) \
			MT_shel_envrn( a, b, 0L )
#define	shel_rdef( a, b ) \
			MT_shel_rdef( a, b, 0L )
#define	shel_wdef( a, b ) \
			MT_shel_wdef( a, b, 0L )

/****** dummies ***********************************************/

#define	xgrf_stepcalc( a, b, c, d, e, f, g, h, i, j, k )	/* Funktion ignorieren (GEM fÅr Dose): int xgrf_stepcalc( int orgw, int orgh, int xc, int yc, int w, int h, int *cx, int *cy, int *stepcnt, int *xstep, int *ystep ); */
#define	xgrf_2box( a, b, c, d, e, f, g, h, i )			/* Funktion ignorieren (GEM fÅr Dose): int xgrf_2box( int xc, int yc, int w, int h, int corners, int stepcnt, int xstep, int ystep, int doubled ); */

/****** Wdialog definitions ***********************************************/

typedef	void	*DIALOG;
						
typedef	WORD	(cdecl *HNDL_OBJ)( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

extern DIALOG	*MT_wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags, WORD *global );
extern WORD	MT_wdlg_open( DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data, WORD *global );
extern WORD	MT_wdlg_close( DIALOG *dialog, WORD *global );
#if 0
extern WORD	MT_wdlg_close( DIALOG *dialog, WORD *x, WORD *y, WORD *global );
#endif
extern WORD	MT_wdlg_delete( DIALOG *dialog, WORD *global );

extern WORD	MT_wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r, WORD *global );
extern WORD	MT_wdlg_get_edit( DIALOG *dialog, WORD *cursor, WORD *global );
extern void	*MT_wdlg_get_udata( DIALOG *dialog, WORD *global );
extern WORD	MT_wdlg_get_handle( DIALOG *dialog, WORD *global );

extern WORD	MT_wdlg_set_edit( DIALOG *dialog, WORD obj, WORD *global );
extern WORD	MT_wdlg_set_tree( DIALOG *dialog, OBJECT *tree, WORD *global );
extern WORD	MT_wdlg_set_size( DIALOG *dialog, GRECT *size, WORD *global );
extern WORD	MT_wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, WORD obj, WORD *global );
extern WORD	MT_wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, WORD *global );

extern WORD	MT_wdlg_evnt( DIALOG *dialog, EVNT *events, WORD *global );
extern void	MT_wdlg_redraw( DIALOG *dialog, GRECT *rect, WORD obj, WORD depth, WORD *global );

#define	wdlg_create( a, b, c, d, e, f ) \
			MT_wdlg_create( a, b, c, d, e, f, 0L )
#define	wdlg_open( a, b, c, d, e, f, g ) \
			MT_wdlg_open( a, b, c, d, e, f, g, 0L )
#define	wdlg_close( a ) \
			MT_wdlg_close( a, 0L )
#if 0
#define	wdlg_close( a, b, c ) \
			MT_wdlg_close( a, b, c, 0L )
#endif
#define	wdlg_delete( a ) \
			MT_wdlg_delete( a, 0L )
#define	wdlg_get_tree( a, b, c ) \
			MT_wdlg_get_tree( a, b, c, 0L )
#define	wdlg_get_edit( a, b ) \
			MT_wdlg_get_edit( a, b, 0L )
#define	wdlg_get_udata( a ) \
			MT_wdlg_get_udata( a, 0L )
#define	wdlg_get_handle( a ) \
			MT_wdlg_get_handle( a, 0L )
#define	wdlg_set_edit( a, b ) \
			MT_wdlg_set_edit( a, b, 0L )
#define	wdlg_set_tree( a, b ) \
			MT_wdlg_set_tree( a, b, 0L )
#define	wdlg_set_size( a, b ) \
			MT_wdlg_set_size( a, b, 0L )
#define	wdlg_set_iconify( a, b, c, d, e ) \
			MT_wdlg_set_iconify( a, b, c, d, e, 0L )
#define	wdlg_set_uniconify( a, b, c, d ) \
			MT_wdlg_set_uniconify( a, b, c, d, 0L )
#define	wdlg_evnt( a, b ) \
			MT_wdlg_evnt( a, b, 0L )
#define	wdlg_redraw( a, b, c, d ) \
			MT_wdlg_redraw( a, b, c, d, 0L )


/* Definitionen fÅr <flags> */
#define	WDLG_BKGD	1				/* Hintergrundbedienung zulassen */

/* Funktionsnummern fÅr <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1				/* Dialog initialisieren */
#define	HNDL_MESG	-2				/* Dialog initialisieren */
#define	HNDL_CLSD	-3				/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5				/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6				/* Zeichen fÅr ein Edit-Feld ÅberprÅfen */
#define	HNDL_EDDN	-7				/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8				/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9				/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10				/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11				/* Dialog-Fenster ist nicht aktiv */

/****** Listbox definitions ***********************************************/
typedef	void	*LIST_BOX;

typedef	void	(cdecl *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD obj_index, WORD last_state );
typedef	WORD	(cdecl *SET_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, WORD obj_index, void *user_data, GRECT *rect, WORD first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;			/* Zeiger auf den nÑchsten Eintrag in der Liste */
	WORD	selected;					/* gibt an, ob das Objekt selektiert ist */

	WORD	data1;					/* Daten fÅr das Programm... */
	void	*data2;
	void	*data3;

} LBOX_ITEM;

#define	LBOX_VERT	1				/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO	2				/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4			/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL	8				/* Real-Time-Slider */
#define	LBOX_SNGL	16				/* nur ein anwÑhlbarer Eintrag */
#define	LBOX_SHFT	32				/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE	64			/* Status eines Eintrags bei Selektion wechseln */
#define	LBOX_2SLDRS	128			/* Listbox hat einen hor. und einen vertikalen Slider */

																				/* #defines fÅr Listboxen mit nur einem Slider */
#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst
			
#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to
			
extern LIST_BOX *MT_lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
						  WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
						  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b, WORD *global );

extern void	MT_lbox_update( LIST_BOX *box, GRECT *rect, WORD *global );
extern WORD	MT_lbox_do( LIST_BOX *box, WORD obj, WORD *global );
extern WORD	MT_lbox_delete( LIST_BOX *box, WORD *global );

extern WORD	MT_lbox_cnt_items( LIST_BOX *box, WORD *global );
extern OBJECT	*MT_lbox_get_tree( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_avis( LIST_BOX *box, WORD *global );
extern void	*MT_lbox_get_udata( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_afirst( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_slct_idx( LIST_BOX *box, WORD *global );
extern LBOX_ITEM	*MT_lbox_get_items( LIST_BOX *box, WORD *global );
extern LBOX_ITEM	*MT_lbox_get_item( LIST_BOX *box, WORD n, WORD *global );
extern LBOX_ITEM *MT_lbox_get_slct_item( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, WORD *global );
extern WORD	MT_lbox_get_bvis( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_bentries( LIST_BOX *box, WORD *global );
extern WORD	MT_lbox_get_bfirst( LIST_BOX *box, WORD *global );

extern void	MT_lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect, WORD *global );
extern void	MT_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, WORD *global );
extern void	MT_lbox_free_items( LIST_BOX *box, WORD *global );
extern void	MT_lbox_free_list( LBOX_ITEM *items, WORD *global );
extern void	MT_lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect, WORD *global );
extern void	MT_lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect, WORD *global );
extern void	MT_lbox_set_bentries( LIST_BOX *box, WORD entries, WORD *global );
extern void	MT_lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect, WORD *global );


#define	lbox_create( a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p ) \
			MT_lbox_create( a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, 0L )
#define	lbox_update( a, b ) \
			MT_lbox_update( a, b, 0L )
#define	lbox_do( a, b ) \
			MT_lbox_do( a, b, 0L )
#define	lbox_delete( a ) \
			MT_lbox_delete( a, 0L )

#define	lbox_cnt_items( a ) \
			MT_lbox_cnt_items( a, 0L )
#define	lbox_get_tree( a ) \
			MT_lbox_get_tree( a, 0L )
#define	lbox_get_avis( a ) \
			MT_lbox_get_avis( a, 0L )
#define	lbox_get_udata( a ) \
			MT_lbox_get_udata( a, 0L )
#define	lbox_get_afirst( a ) \
			MT_lbox_get_afirst( a, 0L )
#define	lbox_get_slct_idx( a ) \
			MT_lbox_get_slct_idx( a, 0L )
#define	lbox_get_items( a ) \
			MT_lbox_get_items( a, 0L )
#define	lbox_get_item( a, b ) \
			MT_lbox_get_item( a, b, 0L )
#define	lbox_get_slct_item( a ) \
			MT_lbox_get_slct_item( a, 0L )
#define	lbox_get_idx( a, b ) \
			MT_lbox_get_idx( a, b, 0L )
#define	lbox_get_bvis( a ) \
			MT_lbox_get_bvis( a, 0L )
#define	lbox_get_bentries( a ) \
			MT_lbox_get_bentries( a, 0L )
#define	lbox_get_bfirst( a ) \
			MT_lbox_get_bfirst( a, 0L )

#define	lbox_set_asldr( a, b, c ) \
			MT_lbox_set_asldr( a, b, c, 0L )
#define	lbox_set_items( a, b ) \
			MT_lbox_set_items( a, b, 0L )
#define	lbox_free_items( a ) \
			MT_lbox_free_items( a, 0L )
#define	lbox_free_list( a ) \
			MT_lbox_free_list( a, 0L )
#define	lbox_ascroll_to( a, b, c, d ) \
			MT_lbox_ascroll_to( a, b, c, d, 0L )
#define	lbox_set_bsldr( a, b, c ) \
			MT_lbox_set_bsldr( a, b, c, 0L )
#define	lbox_set_bentries( a, b ) \
			MT_lbox_set_bentries( a, b, 0L )
#define	lbox_bscroll_to( a, b, c, d ) \
			MT_lbox_bscroll_to( a, b, c, d, 0L )

/****** font selector definitions ***********************************************/

typedef	void	*FNT_DIALOG;

typedef	void	(cdecl *UTXT_FN)( WORD x, WORD y, WORD *clip_rect, LONG id, LONG pt, LONG ratio, BYTE *string );

typedef struct _fnts_item
{
	struct	_fnts_item	*next;	/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;				/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	LONG		id;					/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	WORD		index;				/* Index des Fonts (falls VDI-Font) */
	BYTE		mono;				/* Flag fÅr Ñquidistante Fonts */
	BYTE		outline;				/* Flag fÅr Vektorfont */
	WORD		npts;				/* Anzahl der vordefinierten Punkthîhen */
	BYTE		*full_name;			/* Zeiger auf den vollstÑndigen Namen */
	BYTE		*family_name;			/* Zeiger auf den Familiennamen */
	BYTE		*style_name;			/* Zeiger auf den Stilnamen */
	BYTE		*pts;				/* Zeiger auf Feld mit Punkthîhen */
	LONG		reserved[4];			/* reserviert, mÅssen 0 sein */
} FNTS_ITEM;

/* Definitionen fÅr <font_flags> bei fnts_create() */

#define FNTS_BTMP		1				/* Bitmapfonts anzeigen */
#define FNTS_OUTL		2				/* Vektorfonts anzeigen */
#define FNTS_MONO		4				/* Ñquidistante Fonts anzeigen */
#define FNTS_PROP		8				/* proportionale Fonts anzeigen */

/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define FNTS_3D		1				/* 3D-Design benutzen */

/* Definitionen fÅr <button_flags> bei fnts_open() */
#define FNTS_SNAME		0x01		/* Checkbox fÅr die Namen selektieren */
#define FNTS_SSTYLE		0x02		/* Checkbox fÅr die Stile selektieren */
#define FNTS_SSIZE		0x04		/* Checkbox fÅr die Hîhe selektieren */
#define FNTS_SRATIO		0x08		/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */

#define FNTS_CHNAME		0x0100	/* Checkbox fÅr die Namen anzeigen */
#define FNTS_CHSTYLE	0x0200	/* Checkbox fÅr die Stile anzeigen */
#define FNTS_CHSIZE		0x0400	/* Checkbox fÅr die Hîhe anzeigen */
#define FNTS_CHRATIO	0x0800	/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define FNTS_RATIO		0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define FNTS_BSET		0x2000	/* Button "setzen" anwÑhlbar */
#define FNTS_BMARK		0x4000	/* Button "markieren" anwÑhlbar */

/* Definitionen fÅr <button> bei fnts_evnt() */

#define FNTS_CANCEL		1		/* "Abbruch" wurde angewÑhlt */
#define FNTS_OK		2		/* "OK" wurde gedrÅckt */
#define FNTS_SET		3		/* "setzen" wurde angewÑhlt */
#define FNTS_MARK		4		/* "markieren" wurde betÑtigt */
#define FNTS_OPT		5		/* der applikationseigene Button wurde ausgewÑhlt */

extern FNT_DIALOG	*MT_fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button, WORD *global );
extern WORD	MT_fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle, WORD *global );
extern WORD	MT_fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio, WORD *global );
extern WORD	MT_fnts_close( FNT_DIALOG *fnt_dialog, WORD *global );
#if 0
extern WORD	MT_fnts_close( FNT_DIALOG *fnt_dialog, WORD *x, WORD *y, WORD *global );
#endif

extern WORD	MT_fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id, WORD *global );
extern LONG	MT_fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index, WORD *global );
extern WORD	MT_fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name, WORD *global );
extern WORD	MT_fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline, WORD *global );

extern WORD	MT_fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts, WORD *global );
extern void	MT_fnts_remove( FNT_DIALOG *fnt_dialog, WORD *global );
extern WORD	MT_fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio, WORD *global );

extern WORD	MT_fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio, WORD *global );
extern WORD	MT_fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio, WORD *global );


#define	fnts_create( a, b, c, d, e, f ) \
			MT_fnts_create( a, b, c, d, e, f, 0L )
#define	fnts_delete( a, b ) \
			MT_fnts_delete( a, b, 0L )
#define	fnts_open( a, b, c, d, e, f, g ) \
			MT_fnts_open( a, b, c, d, e, f, g, 0L )
#define	fnts_close( a ) \
			MT_fnts_close( a, 0L )
#if 0
#define	fnts_close( a, b, c ) \
			MT_fnts_close( a, b, c, 0L )
#endif

#define	fnts_get_no_styles( a, b ) \
			MT_fnts_get_no_styles( a, b, 0L )
#define	fnts_get_style( a, b, c ) \
			MT_fnts_get_style( a, b, c, 0L )
#define	fnts_get_name( a, b, c, d, e ) \
			MT_fnts_get_name( a, b, c, d, e, 0L )
#define	fnts_get_info( a, b, c, d ) \
			MT_fnts_get_info( a, b, c, d, 0L )

#define	fnts_add( a, b ) \
			MT_fnts_add( a, b, 0L )
#define	fnts_remove( a ) \
			MT_fnts_remove( a, 0L )
#define	fnts_update( a, b, c, d, e ) \
			MT_fnts_update( a, b, c, d, e, 0L )

#define	fnts_evnt( a, b, c, d, e, f, g ) \
			MT_fnts_evnt( a, b, c, d, e, f, g, 0L )
#define	fnts_do( a, b, c, d, e, f, g, h, i ) \
			MT_fnts_do( a, b, c, d, e, f, g, h, i, 0L )

/****** file selector definitions ***********************************************/
/* Sortiermodi */

#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4

/* Flags fÅr Dateiauswahl */

#define DOSMODE	1
#define NFOLLOWSLKS	2
#define GETMULTI	8

/* fslx_set_flags */

#define SHOW8P3	1

#ifndef __TOS
#define XATTR void
#endif

typedef WORD (cdecl XFSL_FILTER)(char *path, char *name, XATTR *xa);

extern void * MT_fslx_open(
			char *title,
			WORD x, WORD y,
			WORD	*handle,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD sort_mode,
			WORD flags,
			WORD *global);

extern WORD MT_fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			WORD *button,
			WORD *nfiles,
			WORD *sort_mode,
			char **pattern, WORD *global );

extern void * MT_fslx_do(
			char *title,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD *sort_mode,
			WORD flags,
			WORD *button,
			WORD *nfiles,
			char **pattern, WORD *global );

extern WORD	MT_fslx_getnxtfile( void *fsd, char *fname, WORD *global );
extern WORD	MT_fslx_close( void *fsd, WORD *global );
extern WORD	MT_fslx_set_flags( WORD flags, WORD *oldval, WORD *global );


/************************************************************************/
#if ( WDLG_DIRECT_CALL == 0 )

typedef	void	*PDLG_SUB;
typedef	void	*DRV_INFO;

/* <page_flags> */
#define	PG_EVEN_PAGES	0x0001										/* nur Seiten mit gerader Seitennummer ausgeben */
#define	PG_ODD_PAGES	0x0002										/* nur Seiten mit ungerader Seitennummer ausgeben */

/* <first_page/last_page> */
#define	PG_MIN_PAGE		1
#define	PG_MAX_PAGE		9999

/* <orientation> */
#define	PG_UNKNOWN		0x0000										/* Ausrichtung unbekannt und nicht verstellbar */
#define	PG_PORTRAIT		0x0001										/* Seite im Hochformat ausgeben */
#define	PG_LANDSCAPE	0x0002										/* Seite im Querformat ausgeben */

typedef struct _prn_settings
{
	LONG	magic;															/* 'pset' */
	LONG	length;															/* StrukturlÑnge */
	LONG	format;															/* Strukturtyp */
	LONG	reserved;

	LONG	page_flags;														/* Flags, u.a. gerade Seiten, ungerade Seiten */
	WORD	first_page;														/* erste zu druckende Seite */
	WORD	last_page;														/* letzte zu druckende Seite */
	WORD	no_copies;														/* Anzahl der Kopien */
	WORD	orientation;													/* Drehung */
	LONG	scale;															/* Skalierung: 0x10000L entspricht 100% */

	WORD	driver_id;														/* VDI-GerÑtenummer */
	WORD	driver_type;													/* Typ des eingestellten Treibers */
	LONG	driver_mode;													/* Flags, u.a. fÅr Hintergrunddruck */
	LONG	reserved1;
	LONG	reserved2;
	
	LONG	printer_id;														/* Druckernummer */
	LONG	mode_id;															/* Modusnummer */
	WORD	mode_hdpi;														/* horizontale Auflîsung in dpi */
	WORD	mode_vdpi;														/* vertikale Auflîsung in dpi */
	LONG	quality_id;														/* Druckmodus (hardwÑremÑûige QualitÑt, z.B. Microweave oder Econofast) */

	LONG	color_mode;														/* Farbmodus */
	LONG	plane_flags;													/* Flags fÅr auszugebende Farbebenen (z.B. nur cyan) */
	LONG	dither_mode;													/* Rasterverfahren */
	LONG	dither_value;													/* Parameter fÅr das Rasterverfahren */

	LONG	size_id;															/* Papierformat */
	LONG	type_id;															/* Papiertyp (normal, glossy) */
	LONG	input_id;														/* Papiereinzug */
	LONG	output_id;														/* Papierauswurf */

	LONG	contrast;														/* Kontrast: 0x10000L entspricht Normaleinstellung */
	LONG	brightness;														/* Helligkeit: 0x1000L entspricht Normaleinstellung */
	LONG	reserved3;
	LONG	reserved4;

	LONG	reserved5;
	LONG	reserved6;
	LONG	reserved7;
	LONG	reserved8;

	BYTE	device[128];													/* Dateiname fÅr den Ausdruck */

#ifdef __PRINTING__
	TPrint	mac_settings;												/* Einstellung des Mac-Druckertreibers */
#else
	struct
	{
		UBYTE	inside[120];
	} mac_settings;
#endif

} PRN_SETTINGS;

typedef	void *PRN_DIALOG;

PRN_DIALOG	*MT_pdlg_create( WORD dialog_flags, WORD *global );
WORD	MT_pdlg_delete( PRN_DIALOG *prn_dialog, WORD *global );
WORD	MT_pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, BYTE *document_name, WORD option_flags, WORD x, WORD y, WORD *global );
WORD	MT_pdlg_close( PRN_DIALOG *prn_dialog, WORD *x, WORD *y, WORD *global );

LONG	MT_pdlg_get_setsize( WORD *global );

WORD	MT_pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, WORD *global );
WORD	MT_pdlg_remove_printers( PRN_DIALOG *prn_dialog, WORD *global );
WORD	MT_pdlg_update( PRN_DIALOG *prn_dialog, BYTE *document_name, WORD *global );
WORD	MT_pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs, WORD *global );
WORD	MT_pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog, WORD *global );
PRN_SETTINGS	*MT_pdlg_new_settings( PRN_DIALOG *prn_dialog, WORD *global );
WORD	MT_pdlg_free_settings( PRN_SETTINGS *settings, WORD *global );
WORD	MT_pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global );
WORD	MT_pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global );
WORD	MT_pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, WORD *global );

WORD	MT_pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, WORD *button, WORD *global );
WORD	MT_pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, BYTE *document_name, WORD option_flags, WORD *global );


#define	pdlg_create( a ) \
			MT_pdlg_create( a, 0L )
#define	pdlg_delete( a ) \
			MT_pdlg_delete( a, 0L )
#define	pdlg_open( a, b, c, d, e, f ) \
			MT_pdlg_open( a, b, c, d, e, f, 0L )
#define	pdlg_close( a, b, c ) \
			MT_pdlg_close( a, b, c, 0L )

#define	pdlg_get_setsize() \
			MT_pdlg_get_setsize( 0L )

#define	pdlg_add_printer( a, b ) \
			MT_pdlg_add_printers( a, b, 0L )
#define	pdlg_remove_printers( a ) \
			MT_pdlg_remove_printers( a, 0L )
#define	pdlg_update( a, b ) \
			MT_pdlg_update( a, b, 0L )
#define	pdlg_add_sub_dialogs( a, b ) \
			MT_pdlg_add_sub_dialogs( a, b, 0L )
#define	pdlg_remove_sub_dialogs( a ) \
			MT_pdlg_remove_sub_dialogs( a, 0L )
#define	pdlg_new_settings( a ) \
			MT_pdlg_new_settings( a, 0L )
#define	pdlg_free_settings( a ) \
			MT_pdlg_free_settings( a, 0L )
#define	pdlg_dflt_settings( a, b ) \
			MT_pdlg_dflt_settings( a, b, 0L )
#define	pdlg_validate_settings( a, b ) \
			MT_pdlg_validate_settings( a, b, 0L )
#define	pdlg_use_settings( a, b ) \
			MT_pdlg_use_settings( a, b, 0L )

#define	pdlg_evnt( a, b, c, d ) \
			MT_pdlg_evnt( a, b, c, d, 0L )
#define	pdlg_do( a, b, c, d ) \
			MT_pdlg_do( a, b, c, d, 0L )

/* <dialog_flags> fÅr pdlg_create() */
#define	PDLG_3D					0x0001

/* <option_flags> fÅr pdlg_open/do() */
#define	PDLG_PREFS				0x0000								/* Einstelldialog anzeigen */
#define	PDLG_PRINT				0x0001								/* Druckdialog anzeigen */

#define	PDLG_ALWAYS_COPIES	0x0010								/* immer Kopien anbieten */
#define	PDLG_ALWAYS_ORIENT	0x0020								/* immer Querformat anbieten */
#define	PDLG_ALWAYS_SCALE		0x0040								/* immer Skalierung anbieten */

#define	PDLG_EVENODD			0x0100								/* Option fÅr gerade und ungerade Seiten anbieten */

/* <button> fÅr pdlg_evnt()/pdlg_do */
#define	PDLG_CANCEL	1													/* "Abbruch" wurde angewÑhlt */
#define	PDLG_OK		2													/* "OK" wurde gedrÅckt */

#endif

#endif

/************************************************************************/
