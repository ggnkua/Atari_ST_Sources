/*      AES.H

        GEM AES Definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __AES__ )
#define __AES__

/****** GEMparams *******************************************************/

typedef struct
{
    int    contrl[15];
    int    global[15];
    int    intin[132];
    int    intout[140];
    void   *addrin[16];
    void   *addrout[16];
} GEMPARBLK;

extern  GEMPARBLK _GemParBlk;
extern  int       _app;

typedef struct
{
    int    *contrl;
    int    *global;
    int    *intin;
    int    *intout;
    int    *addrin;
    int    *addrout;
} AESPB;


int  vq_aes( void );
void _crystal( AESPB *aespb );


/****** Application definitions *****************************************/

int appl_init( void );
int appl_read( int ap_rid, int ap_rlength, void *ap_rpbuff );
int appl_write( int ap_wid, int ap_wlength, void *ap_wpbuff );
int appl_find( const char *ap_fpname );
int appl_tplay( void *ap_tpmem, int ap_tpnum, int ap_tpscale );
int appl_trecord( void *ap_trmem, int ap_trcount );
int appl_exit( void );
int appl_search( int ap_smode, char *ap_sname, int *ap_stype,
                 int *ap_sid );
int appl_getinfo( int ap_gtype, int *ap_gout1, int *ap_gout2,
                  int *ap_gout3, int *ap_gout4 );

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
#define CH_EXIT         80



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
int evnt_button( int ev_bclicks, int ev_bmask, int ev_bstate,
                 int *ev_bmx, int *ev_bmy, int *ev_bbutton,
                 int *ev_bkstate );
int evnt_mouse( int ev_moflags, int ev_mox, int ev_moy,
                int ev_mowidth, int ev_moheight, int *ev_momx,
                int *ev_momy, int *ev_mobutton,
                int *ev_mokstate );
int evnt_mesag( int *ev_mgpbuff );
int evnt_timer( int ev_tlocount, int ev_thicount );
int evnt_multi( int ev_mflags, int ev_mbclicks, int ev_mbmask,
                int ev_mbstate, int ev_mm1flags, int ev_mm1x,
                int ev_mm1y, int ev_mm1width, int ev_mm1height,
                int ev_mm2flags, int ev_mm2x, int ev_mm2y,
                int ev_mm2width, int ev_mm2height,
                int *ev_mmgpbuff, int ev_mtlocount,
                int ev_mthicount, int *ev_mmox, int *ev_mmoy,
                int *ev_mmbutton, int *ev_mmokstate,
                int *ev_mkreturn, int *ev_mbreturn );
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

#define G_BOX           20
#define G_TEXT          21
#define G_BOXTEXT       22
#define G_IMAGE         23
#define G_USERDEF       24
#define G_IBOX          25
#define G_BUTTON        26
#define G_BOXCHAR       27
#define G_STRING        28
#define G_FTEXT         29
#define G_FBOXTEXT      30
#define G_ICON          31
#define G_TITLE         32
#define G_CICON         33


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


typedef struct
{
        int     g_x;
        int     g_y;
        int     g_w;
        int     g_h;
} GRECT;


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


typedef struct cicon_data
{
        int                num_planes;
        int                *col_data;
        int                *col_mask;
        int                *sel_data;
        int                *sel_mask;
        struct cicon_data  *next_res;
} CICON;


typedef struct cicon_blk
{
        ICONBLK            monoblk;
        CICON              *mainlist;
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
        int		mn_keystate;
} MENU;


typedef struct
{
        long   Display;
        long   Drag;
        long   Delay;
        long   Speed;
        int    Height;
} MN_SET;


/****** Menu definitions ************************************************/

int menu_bar( OBJECT *me_btree, int me_bshow );
int menu_icheck( OBJECT *me_ctree, int me_citem, int me_ccheck );
int menu_ienable( OBJECT *me_etree, int me_eitem,
                  int me_eenable );
int menu_tnormal( OBJECT *me_ntree, int me_ntitle,
                  int me_nnormal );
int menu_text( OBJECT *me_ttree, int me_titem,
               const char *me_ttext );
int menu_register( int me_rapid, const char *me_rpstring );
int menu_popup( MENU *me_menu, int me_xpos, int me_ypos,
                MENU *me_mdata );
int menu_attach( int me_flag, OBJECT *me_tree, int me_item,
                 MENU *me_mdata );
int menu_istart( int me_flag, OBJECT *me_tree, int me_imenu,
                 int me_item );
int menu_settings( int me_flag, MN_SET *me_values );


/* Object prototypes */

int objc_add( OBJECT *ob_atree, int ob_aparent, int ob_achild );
int objc_delete( OBJECT *ob_dltree, int ob_dlobject );
int objc_draw( OBJECT *ob_drtree, int ob_drstartob,
               int ob_drdepth, int ob_drxclip, int ob_dryclip,
               int ob_drwclip, int ob_drhclip );
int objc_find( OBJECT *ob_ftree, int ob_fstartob, int ob_fdepth,
               int ob_fmx, int ob_fmy );
int objc_offset( OBJECT *ob_oftree, int ob_ofobject,
                 int *ob_ofxoff, int *ob_ofyoff );
int objc_order( OBJECT *ob_ortree, int ob_orobject,
                int ob_ornewpos );
int objc_edit( OBJECT *ob_edtree, int ob_edobject,
               int ob_edchar, int *ob_edidx, int ob_edkind );
int objc_change( OBJECT *ob_ctree, int ob_cobject,
                 int ob_cresvd, int ob_cxclip, int ob_cyclip,
                 int ob_cwclip, int ob_chclip,
                 int ob_cnewstate, int ob_credraw );


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
int form_center( OBJECT *fo_ctree, int *fo_cx, int *fo_cy,
                 int *fo_cw, int *fo_ch );
int form_keybd( OBJECT *fo_ktree, int fo_kobject, int fo_kobnext,
                int fo_kchar, int *fo_knxtobject, int *fo_knxtchar );
int form_button( OBJECT *fo_btree, int fo_bobject, int fo_bclicks,
                int *fo_bnxtobj );


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
int graf_dragbox( int gr_dwidth, int gr_dheight,
                  int gr_dstartx, int gr_dstarty,
                  int gr_dboundx, int gr_dboundy,
                  int gr_dboundw, int gr_dboundh,
                  int *gr_dfinishx, int *gr_dfinishy );
int graf_movebox( int gr_mwidth, int gr_mheight,
                  int gr_msourcex, int gr_msourcey,
                  int gr_mdestx, int gr_mdesty );
int graf_mbox( int gr_mwidth, int gr_mheight,
                  int gr_msourcex, int gr_msourcey,
                  int gr_mdestx, int gr_mdesty );
int graf_growbox( int gr_gstx, int gr_gsty,
                  int gr_gstwidth, int gr_gstheight,
                  int gr_gfinx, int gr_gfiny,
                  int gr_gfinwidth, int gr_gfinheight );
int graf_shrinkbox( int gr_sfinx, int gr_sfiny,
                    int gr_sfinwidth, int gr_sfinheight,
                    int gr_sstx, int gr_ssty,
                    int gr_sstwidth, int gr_sstheight );
int graf_watchbox( OBJECT *gr_wptree, int gr_wobject,
                   int gr_winstate, int gr_woutstate );
int graf_slidebox( OBJECT *gr_slptree, int gr_slparent,
                   int gr_slobject, int gr_slvh );
int graf_handle( int *gr_hwchar, int *gr_hhchar,
                 int *gr_hwbox, int *gr_hhbox );
int graf_mouse( int gr_monumber, MFORM *gr_mofaddr );
int graf_mkstate( int *gr_mkmx, int *gr_mkmy,
                  int *gr_mkmstate, int *gr_mkkstate );


/****** Scrap definitions ***********************************************/

int scrp_read( char *sc_rpscrap );
int scrp_write( char *sc_wpscrap );


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


int wind_create( int wi_crkind, int wi_crwx, int wi_crwy,
                 int wi_crww, int wi_crwh );
int wind_open( int wi_ohandle, int wi_owx, int wi_owy,
               int wi_oww, int wi_owh );
int wind_close( int wi_clhandle );
int wind_delete( int wi_dhandle );
int wind_get( int wi_ghandle, int wi_gfield, ... );
int wind_set( int wi_shandle, int wi_sfield, ... );
int wind_find( int wi_fmx, int wi_fmy );
int wind_update( int wi_ubegend );
int wind_calc( int wi_ctype, int wi_ckind, int wi_cinx,
               int wi_ciny, int wi_cinw, int wi_cinh,
               int *coutx, int *couty, int *coutw,
               int *couth );
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

int rsrc_load( const char *re_lpfname );
int rsrc_free( void );
int rsrc_gaddr( int re_gtype, int re_gindex, void *gaddr );
int rsrc_saddr( int re_stype, int re_sindex, void *saddr );
int rsrc_obfix( OBJECT *re_otree, int re_oobject );
int rsrc_rcfix( RSHDR *rc_header );


/****** Shell definitions ***********************************************/
int shel_read( char *sh_rpcmd, char *sh_rptail );
int shel_write( int sh_wdoex, int sh_wisgr, int sh_wiscr,
                char *sh_wpcmd, char *sh_wptail );
int shel_get( char *sh_gaddr, int sh_glen );
int shel_put( char *sh_paddr, int sh_plen );
int shel_find( char *sh_fpbuff );
int shel_envrn( char **sh_epvalue, char *sh_eparm );


#endif

/************************************************************************/
