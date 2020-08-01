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

extern  int       _app;

int  vq_aes( void );

typedef struct
{
	WORD	*contrl;
	WORD *global;
	WORD *intin;
	WORD *intout;
	void **addrin;
	void **addrout;
} AESPB;

typedef struct
{
	WORD contrl[5];
	WORD intin[16];
	WORD intout[16];
	void *addrin[16];
	void	*addrout[16];
} PARMDATA;

typedef struct {
	WORD x;
	WORD y;
	WORD bstate;
	WORD kstate;
} EVNTDATA;

typedef struct
{
        int     g_x;
        int     g_y;
        int     g_w;
        int     g_h;
} GRECT;

extern void _crystal( AESPB *aespb );


/****** Application definitions *****************************************/

/* extended appl_write structure */

typedef struct {
     int  dst_apid;
     int  unique_flg;
     void *attached_mem;
     int  *msgbuf;
     } XAESMSG;

extern WORD MT_appl_init( WORD *global );
int appl_read( int ap_rid, int ap_rlength, void *ap_rpbuff );
int appl_write( int ap_wid, int ap_wlength, void *ap_wpbuff );
int appl_find( char *ap_fpname );
int appl_tplay( void *ap_tpmem, int ap_tpnum, int ap_tpscale );
int appl_trecord( void *ap_trmem, int ap_trcount );
int appl_exit( void );
int appl_search( int ap_smode, char *ap_sname, int *ap_stype, int *ap_sid );
int appl_getinfo( int ap_gtype, int *ap_gout1, int *ap_gout2,
                  int *ap_gout3, int *ap_gout4 );
void appl_yield     ( void );                               /* GEM 2.x     */


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
#define WM_UNTOPPED     30
#define WM_ONTOP        31
#define AC_OPEN         40
#define AC_CLOSE        41
#define CT_UPDATE       50
#define CT_MOVE         51
#define CT_NEWTOP       52
#define AP_TERM         50
#define AP_TFAIL        51
#define AP_RESCHG       57
#define SHUT_COMPLETED  60
#define RESCHG_COMPLETED  61
#define AP_DRAGDROP	    63
#define CH_EXIT         90

#define WM_UNTOPPED      30                                 /* GEM  2.x    */
#define WM_ONTOP         31                                 /* AES 4.0     */
#define WM_BOTTOMED      33                                 /* AES 4.1     */
#define WM_ICONIFY       34                                 /* AES 4.1     */
#define WM_UNICONIFY     35                                 /* AES 4.1     */
#define WM_ALLICONIFY    36                                 /* AES 4.1     */
#define AP_TERM          50                                 /* AES 4.0     */
#define AP_TFAIL         51                                 /* AES 4.0     */
#define AP_RESCHG        57                                 /* AES 4.0     */
#define SHUT_COMPLETED   60                                 /* AES 4.0     */
#define RESCH_COMPLETED  61                                 /* AES 4.0     */
#define AP_DRAGDROP      63                                 /* AES 4.0     */
#define SH_WDRAW         72                                 /* MultiTOS    */
#define THR_EXIT		88							/* MagiC 4.5	*/
#define PA_EXIT          89                                 /* MagiC 3     */
#define CH_EXIT          90                                 /* MultiTOS    */
#define SC_CHANGED       91                                 /* */
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


typedef struct
{
        int     m_out;
        int     m_x;
        int     m_y;
        int     m_w;
        int	m_h;
} MOBLK;

int evnt_keybd( void );
int evnt_button( int nclicks, int bmask, int bstate,
                 EVNTDATA *ev );
WORD evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev );
int evnt_mesag( int *ev_mgpbuff );
extern WORD evnt_timer( ULONG ms );
extern WORD evnt_multi(
			WORD evtypes,
			WORD nclicks, WORD bmask, WORD bstate,
			WORD flg1_leave, GRECT *g1,
			WORD flg2_leave, GRECT *g2,
			WORD *msgbuf,
			ULONG ms,
			EVNTDATA *ev,
			WORD *keycode,
			WORD *nbclicks
			);
int evnt_dclick( int ev_dnew, int ev_dgetset );


/* this is our special invention to increase evnt_multi performance */

typedef struct /* Special type for EventMulti */
{
        /* input parameters */
        int     ev_mflags, ev_mbclicks, ev_bmask, ev_mbstate, ev_mm1flags,
                ev_mm1x, ev_mm1y, ev_mm1width, ev_mm1height, ev_mm2flags,
                ev_mm2x, ev_mm2y, ev_mm2width, ev_mm2height, ev_mtlocount,
                ev_mthicount;
        /* output parameters */
        int     ev_mwich, ev_mmox, ev_mmoy, ev_mmobutton, ev_mmokstate,
                ev_mkreturn, ev_mbreturn;
        /* message buffer */
        int     ev_mmgpbuf[8];
} EVENT;

int EvntMulti( EVENT *evnt_struct );


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

#define NONE            0x0000
#define SELECTABLE      0x0001
#define DEFAULT         0x0002
#define EXIT            0x0004
#define EDITABLE        0x0008
#define RBUTTON         0x0010
#define LASTOB          0x0020
#define TOUCHEXIT       0x0040
#define HIDETREE        0x0080
#define INDIRECT        0x0100


/* Object states */

#define NORMAL          0x00
#define SELECTED        0x01
#define CROSSED         0x02
#define CHECKED         0x04
#define DISABLED        0x08
#define OUTLINED        0x10
#define SHADOWED        0x20

/* ob_flags */

#ifndef FL3DMASK
#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200	/* 3D Indicator			  AES 4.0		*/
#define FL3DBAK      0x0400	/* 3D Background			  AES 4.0		*/
#define FL3DACT      0x0600	/* 3D Activator			  AES 4.0		*/
#endif

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

/* Object states */

#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

/* form_xdo definitions */

typedef struct {
     char scancode;
     char nclicks;
     int  objnr;
     } SCANX;

typedef struct {
     SCANX *unsh;
     SCANX *shift;
     SCANX *ctrl;
     SCANX *alt;
     void  *resvd;
     } XDO_INF;

/* scrollable textedit objects */

typedef struct _xted {
	char		*xte_ptmplt;
	char		*xte_pvalid;
	WORD		xte_vislen;
	WORD		xte_scroll;
} XTED;

/* AES function prototypes */

void _appl_yield    ( void );                               /* TOS         */
int  vq_aes         ( void );                               /* TOS         */
void appl_bvset     ( int  disks,  int harddisks );         /* GEM 2.x     */
int  xgrf_stepcalc  (                                       /* GEM 2.x     */
                      int orgw, int orgh,
                      int xc, int yc, int w, int h,
                      int *cx, int *cy,
                      int *stepcnt, int *xstep, int *ystep
                    );
int  xgrf_2box      (                                       /* GEM 2.x     */
                      int xc, int yc, int w, int h,
                      int corners, int stepcnt,
                      int xstep, int ystep, int doubled
                    );


/* Object colors */
#if !defined(__COLORS)
#define __COLORS        /*
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


#define ED_START        0               /* editable text field definitions */
#define ED_INIT         1
#define ED_CHAR         2
#define ED_END          3

#define TE_LEFT         0               /* editable text justification */
#define TE_RIGHT        1
#define TE_CNTR         2


typedef struct orect
{
        struct  orect   *o_link;
        int     o_x;
        int     o_y;
        int     o_w;
        int     o_h;
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

int menu_bar( OBJECT *me_btree, int me_bshow );
int menu_icheck( OBJECT *me_ctree, int me_citem, int me_ccheck );
int menu_ienable( OBJECT *me_etree, int me_eitem,
                  int me_eenable );
int menu_tnormal( OBJECT *me_ntree, int me_ntitle,
                  int me_nnormal );
extern WORD menu_text( OBJECT *tree, WORD objnr, const char *text );
extern WORD menu_register( WORD apid, const char *text );
int menu_popup( MENU *me_menu, int me_xpos, int me_ypos,
                MENU *me_mdata );
int menu_attach( int me_flag, OBJECT *me_tree, int me_item,
                 MENU *me_mdata );
int menu_istart( int me_flag, OBJECT *me_tree, int me_imenu,
                 int me_item );
extern WORD menu_settings( WORD flag, MN_SET *values );
extern WORD menu_unregister( WORD menuid );
int  menu_click     ( int val, int setit );                 /* GEM 3.x     */


/* Object prototypes */

/* objc_edit definition */

#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */

int objc_add( OBJECT *ob_atree, int ob_aparent, int ob_achild );
int objc_delete( OBJECT *ob_dltree, int ob_dlobject );
WORD objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g );
int objc_find( OBJECT *ob_ftree, int ob_fstartob, int ob_fdepth,
               int ob_fmx, int ob_fmy );
int objc_offset( OBJECT *ob_oftree, int ob_ofobject,
                 int *ob_ofxoff, int *ob_ofyoff );
int objc_order( OBJECT *ob_ortree, int ob_orobject,
                int ob_ornewpos );
int objc_edit( OBJECT *ob_edtree, int ob_edobject,
               int ob_edchar, int *ob_edidx, int ob_edkind );
WORD objc_change( OBJECT *tree, WORD objnr, WORD resvd,
				GRECT *g, WORD newstate, WORD redraw );
int objc_sysvar     ( int mode, int which,                  /* AES 4.0     */
                      int ival1, int ival2,
                      int *oval1, int *oval2
                     );


/****** Form definitions ************************************************/

#define FMD_START       0
#define FMD_GROW        1
#define FMD_SHRINK      2
#define FMD_FINISH      3

int form_do( OBJECT *fo_dotree, int fo_dostartob );
int form_dial( int fo_diflag, int fo_dilittlx,
               int fo_dilittly, int fo_dilittlw,
               int fo_dilittlh, int fo_dibigx,
               int fo_dibigy, int fo_dibigw, int fo_dibigh );
int form_alert( int fo_adefbttn, const char *fo_astring );
int form_error( int fo_enum );
WORD form_center( OBJECT *tree, GRECT *g );
int form_keybd( OBJECT *fo_ktree, int fo_kobject, int fo_kobnext,
                int fo_kchar, int *fo_knxtobject, int *fo_knxtchar );
int form_button( OBJECT *fo_btree, int fo_bobject, int fo_bclicks,
                int *fo_bnxtobj );
int  form_popup     ( OBJECT *tree, int x, int y );         /* MAG!X       */
int  form_xerr      ( long errcode, char *errfile );        /* MAG!X       */
int  form_xdo       (                                       /* MAG!X       */
                      OBJECT *tree, int startob,
                      int *lastcrsr, XDO_INF *tabs,
                      void *flydial
                    );
WORD form_xdial( WORD subfn,
				GRECT *lg, GRECT *bg,
				void **flyinf );



/****** Graph definitions ************************************************/


/* Mouse forms */

#define ARROW             0
#define TEXT_CRSR         1
#define HOURGLASS         2
#define BUSYBEE           2
#define POINT_HAND        3
#define FLAT_HAND         4
#define THIN_CROSS        5
#define THICK_CROSS       6
#define OUTLN_CROSS       7
#define USER_DEF        255
#define M_OFF           256
#define M_ON            257


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


int graf_rubberbox( int gr_rx, int gr_ry, int gr_minwidth,
                    int gr_minheight, int *gr_rlastwidth,
                    int *gr_rlastheight );
int graf_rubbox( int gr_rx, int gr_ry, int gr_minwidth,
                    int gr_minheight, int *gr_rlastwidth,
                    int *gr_rlastheight );
WORD graf_dragbox( WORD w, WORD h, WORD begx, WORD begy,
				GRECT *g, WORD *endx, WORD *endy );
int graf_movebox( int gr_mwidth, int gr_mheight,
                  int gr_msourcex, int gr_msourcey,
                  int gr_mdestx, int gr_mdesty );
int graf_mbox( int gr_mwidth, int gr_mheight,
                  int gr_msourcex, int gr_msourcey,
                  int gr_mdestx, int gr_mdesty );
WORD graf_growbox( GRECT *startg, GRECT *endg );
WORD graf_shrinkbox( GRECT *endg, GRECT *startg );
WORD graf_watchbox( OBJECT *tree, WORD obj, WORD instate,
				WORD outstate );
int graf_slidebox( OBJECT *gr_slptree, int gr_slparent,
                   int gr_slobject, int gr_slvh );
int graf_handle( int *gr_hwchar, int *gr_hhchar,
                 int *gr_hwbox, int *gr_hhbox );
int graf_xhandle    (                                       /* KAOS 1.4    */
                      int *wchar, int *hchar,
                      int *wbox, int *hbox, int *dev
                    );
int graf_mouse( int gr_monumber, MFORM *gr_mofaddr );
WORD graf_mkstate( EVNTDATA *ev );


/****** Scrap definitions ***********************************************/

int scrp_read( char *sc_rpscrap );
int scrp_write( char *sc_wpscrap );
int  scrp_clear( void );                               /* GEM 2.x     */


/****** File selector definitions ***************************************/

int fsel_input( char *fs_iinpath, char *fs_iinsel,
                int *fs_iexbutton );
int fsel_exinput( char *fs_einpath, char *fs_einsel,
                int *fs_eexbutton, char *fs_elabel );


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

/* AES wind_s/get()- Modes */

#define WF_ICONIFY       26                                 /* AES 4.1     */
#define WF_UNICONIFY     27                                 /* AES 4.1     */
#define WF_UNICONIFYXYWH 28                                 /* AES 4.1     */
#define WF_M_BACKDROP    100                                /* KAOS 1.4    */
#define WF_M_OWNER       101                                /* KAOS 1.4    */
#define WF_M_WINDLIST    102                                /* KAOS 1.4    */

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


WORD wind_create( WORD kind, GRECT *maxsize );
WORD wind_open( WORD whdl, GRECT *g );
WORD wind_close( WORD whdl );
WORD wind_delete( WORD whdl );
WORD wind_get( WORD whdl, WORD subfn,
			WORD *g1, WORD *g2, WORD *g3, WORD *g4 );
WORD wind_get_grect( WORD whdl, WORD subfn, GRECT *g );
WORD wind_set( WORD whdl, WORD subfn,
			WORD g1, WORD g2, WORD g3, WORD g4 );
WORD wind_set_grect( WORD whdl, WORD subfn, GRECT *g );
int wind_find( int wi_fmx, int wi_fmy );
int wind_update( int wi_ubegend );
WORD wind_calc( WORD subfn, WORD kind,
			GRECT *ing, GRECT *outg );
void wind_new( void );


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
#define R_IPBTEXT       13
#define R_BIPDATA       14              /* sub ptrs in BITBLK */
#define R_FRSTR         15              /* gets addr of ptr to free strings */
#define R_FRIMG         16              /* gets addr of ptr to free images  */

typedef struct rshdr
{
        unsigned     rsh_vrsn;
        unsigned     rsh_object;
        unsigned     rsh_tedinfo;
        unsigned     rsh_iconblk;    /* list of ICONBLKS */
        unsigned     rsh_bitblk;
        unsigned     rsh_frstr;
        unsigned     rsh_string;
        unsigned     rsh_imdata;     /* image data */
        unsigned     rsh_frimg;
        unsigned     rsh_trindex;
        unsigned     rsh_nobs;       /* counts of various structs */
        unsigned     rsh_ntree;
        unsigned     rsh_nted;
        unsigned     rsh_nib;
        unsigned     rsh_nbb;
        unsigned     rsh_nstring;
        unsigned     rsh_nimages;
        unsigned     rsh_rssize;     /* total bytes in resource */
} RSHDR;

extern WORD MT_rsrc_load( char *filename, WORD *global );
extern WORD MT_rsrc_free( WORD *global );
extern WORD MT_rsrc_gaddr( WORD type, WORD index, void *addr,
				WORD *global );
extern WORD MT_rsrc_saddr( WORD type, WORD index, void *o,
		WORD *global );
int rsrc_obfix( OBJECT *re_otree, int re_oobject );
extern WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global );


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

int shel_read( char *sh_rpcmd, char *sh_rptail );
int shel_write( int sh_wdoex, int sh_wisgr, int sh_wiscr,
                char *sh_wpcmd, char *sh_wptail );
int shel_get( char *sh_gaddr, int sh_glen );
int shel_put( char *sh_paddr, int sh_plen );
int shel_find( char *sh_fpbuff );
int shel_envrn( char **sh_epvalue, char *sh_eparm );
void shel_rdef      ( char *cmd, char *dir );               /* GEM 2.x     */
void shel_wdef      ( char *cmd, char *dir );               /* GEM 2.x     */


/****** Listbox definitions ***********************************************/
typedef	void	(cdecl *SLCT_ITEM)( void *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD obj_index, WORD last_state );
typedef	WORD	(cdecl *SET_ITEM)( void *box, OBJECT *tree, struct _lbox_item *item, WORD obj_index, void *user_data, GRECT *rect, WORD first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;	/* Zeiger auf den nÑchsten Eintrag in der Liste */
	WORD	selected;				/* gibt an, ob das Objekt selektiert ist */

	WORD	data1;					/* Daten fÅr das Programm... */
	void	*data2;
	void	*data3;

} LBOX_ITEM;

#define	LBOX_VERT	1			/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO	2			/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4		/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL	8			/* Real-Time-Slider */
#define	LBOX_SNGL	16			/* nur ein anwÑhlbarer Eintrag */
#define	LBOX_SHFT	32			/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE	64			/* Status eines Eintrags bei Selektion wechseln */
#define	LBOX_2SLDRS	128		/* Listbox hat einen hor. und einen vertikalen Slider */

#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst
			
#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to
			
extern void	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
								  WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
								  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b );

extern void	lbox_update( void *box, GRECT *rect );
extern WORD	lbox_do( void *box, WORD obj );
extern WORD	lbox_delete( void *box );

extern WORD	lbox_cnt_items( void *box );
extern OBJECT	*lbox_get_tree( void *box );
extern WORD	lbox_get_avis( void *box );
extern void	*lbox_get_udata( void *box );
extern WORD	lbox_get_afirst( void *box );
extern WORD	lbox_get_slct_idx( void *box );
extern LBOX_ITEM	*lbox_get_items( void *box );
extern LBOX_ITEM	*lbox_get_item( void *box, WORD n );
extern LBOX_ITEM *lbox_get_slct_item( void *box );
extern WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
extern WORD	lbox_get_bvis( void *box );
extern WORD	lbox_get_bentries( void *box );
extern WORD	lbox_get_bfirst( void *box );

extern void	lbox_set_asldr( void *box, WORD first, GRECT *rect );
extern void	lbox_set_items( void *box, LBOX_ITEM *items );
extern void	lbox_free_items( void *box );
extern void	lbox_free_list( LBOX_ITEM *items );
extern void	lbox_ascroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
extern void	lbox_set_bsldr( void *box, WORD first, GRECT *rect );
extern void	lbox_set_bentries( void *box, WORD entries );
extern void	lbox_bscroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );


/****** Wdialog definitions ***********************************************/
typedef struct
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
						
typedef	WORD	(cdecl *HNDL_OBJ)( void *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

extern	void	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );
extern	WORD	wdlg_open( void *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data );
extern	WORD	wdlg_close( void *dialog );
extern	WORD	wdlg_delete( void *dialog );

extern	WORD	wdlg_get_tree( void *dialog, OBJECT **tree, GRECT *r );
extern	WORD	wdlg_get_edit( void *dialog, WORD *cursor );
extern	void	*wdlg_get_udata( void *dialog );
extern	WORD	wdlg_get_handle( void *dialog );

extern	WORD	wdlg_set_edit( void *dialog, WORD obj );
extern	WORD	wdlg_set_tree( void *dialog, OBJECT *tree );
extern	WORD	wdlg_set_size( void *dialog, GRECT *size );
extern	WORD	wdlg_set_iconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree, WORD obj );
extern	WORD	wdlg_set_uniconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree );

extern	WORD	wdlg_evnt( void *dialog, EVNT *events );
extern	void	wdlg_redraw( void *dialog, GRECT *rect, WORD obj, WORD depth );

/* Definitionen fÅr <flags> */
#define	WDLG_BKGD	1													/* Hintergrundbedienung zulassen */

/* Funktionsnummern fÅr <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1													/* Dialog initialisieren */
#define	HNDL_MESG	-2													/* Dialog initialisieren */
#define	HNDL_CLSD	-3													/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5													/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6													/* Zeichen fÅr ein Edit-Feld ÅberprÅfen */
#define	HNDL_EDDN	-7													/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8													/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9													/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10												/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11												/* Dialog-Fenster ist nicht aktiv */


/****** font selector definitions ***********************************************/

typedef	void	(cdecl *UTXT_FN)( WORD x, WORD y, WORD *clip_rect, LONG id, LONG pt, LONG ratio, BYTE *string );

typedef struct _fnts_item
{
	struct	_fnts_item	*next;										/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;														/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	LONG		id;															/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	WORD		index;														/* Index des Fonts (falls VDI-Font) */
	BYTE		mono;															/* Flag fÅr Ñquidistante Fonts */
	BYTE		outline;														/* Flag fÅr Vektorfont */
	WORD		npts;															/* Anzahl der vordefinierten Punkthîhen */
	BYTE		*full_name;													/* Zeiger auf den vollstÑndigen Namen */
	BYTE		*family_name;												/* Zeiger auf den Familiennamen */
	BYTE		*style_name;												/* Zeiger auf den Stilnamen */
	BYTE		*pts;															/* Zeiger auf Feld mit Punkthîhen */
	LONG		reserved[4];												/* reserviert, mÅssen 0 sein */
} FNTS_ITEM;

/* Definitionen fÅr <font_flags> bei fnts_create() */

#define	FNTS_BTMP	1													/* Bitmapfonts anzeigen */
#define	FNTS_OUTL	2													/* Vektorfonts anzeigen */
#define	FNTS_MONO	4													/* Ñquidistante Fonts anzeigen */
#define	FNTS_PROP	8													/* proportionale Fonts anzeigen */

/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define	FNTS_3D		1													/* 3D-Design benutzen */

/* Definitionen fÅr <button_flags> bei fnts_open() */
#define	FNTS_SNAME		0x01											/* Checkbox fÅr die Namen selektieren */
#define	FNTS_SSTYLE		0x02											/* Checkbox fÅr die Stile selektieren */
#define	FNTS_SSIZE		0x04											/* Checkbox fÅr die Hîhe selektieren */
#define	FNTS_SRATIO		0x08											/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */

#define	FNTS_CHNAME		0x0100										/* Checkbox fÅr die Namen anzeigen */
#define	FNTS_CHSTYLE	0x0200										/* Checkbox fÅr die Stile anzeigen */
#define	FNTS_CHSIZE		0x0400										/* Checkbox fÅr die Hîhe anzeigen */
#define	FNTS_CHRATIO	0x0800										/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define	FNTS_RATIO		0x1000										/* VerhÑltnis Breite/Hîhe einstellbar */
#define	FNTS_BSET		0x2000										/* Button "setzen" anwÑhlbar */
#define	FNTS_BMARK		0x4000										/* Button "markieren" anwÑhlbar */

/* Definitionen fÅr <button> bei fnts_evnt() */

#define	FNTS_CANCEL	1													/* "Abbruch" wurde angewÑhlt */
#define	FNTS_OK		2													/* "OK" wurde gedrÅckt */
#define	FNTS_SET		3													/* "setzen" wurde angewÑhlt */
#define	FNTS_MARK	4													/* "markieren" wurde betÑtigt */
#define	FNTS_OPT		5													/* der applikationseigene Button wurde ausgewÑhlt */

extern void	*fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button );
extern WORD	fnts_delete( void *fnt_dialog, WORD vdi_handle );
extern WORD	fnts_open( void *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio );
extern WORD	fnts_close( void *fnt_dialog );

extern WORD	fnts_get_no_styles( void *fnt_dialog, LONG id );
extern LONG	fnts_get_style( void *fnt_dialog, LONG id, WORD index );
extern WORD	fnts_get_name( void *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name );
extern WORD	fnts_get_info( void *fnt_dialog, LONG id, WORD *mono, WORD *outline );

extern WORD	fnts_add( void *fnt_dialog, FNTS_ITEM *user_fonts );
extern void	fnts_remove( void *fnt_dialog );

extern WORD	fnts_evnt( void *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );
extern WORD	fnts_do( void *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, 
							WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );

/*
*
* exportierte Dateiauswahl-Funktionen
*
* Formatierung:	Tabulatorbreite 5
*
*
* Andreas Kromke, 20.11.95
*/

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


extern void * fslx_open(
			char *title,
			WORD x, WORD y,
			WORD	*handle,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD sort_mode,
			WORD flags);

extern WORD fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			WORD *button,
			WORD *nfiles,
			WORD *sort_mode,
			char **pattern );

extern void * fslx_do(
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
			char **pattern );

extern WORD fslx_getnxtfile(
			void *fsd,
			char *fname );

extern WORD fslx_close( void *fsd );

extern WORD fslx_set_flags(
			WORD flags,
			WORD *oldval );

#endif

/************************************************************************/
