/*****************************************************************************/
/*   AES.H: Common AES definitions and structures.                           */
/*****************************************************************************/
/*                                                                           */
/*   Authors: Dieter & Juergen Geiss                                         */
/*                                                                           */
/*****************************************************************************/

#ifndef __AES__
#define __AES__

/****** GEMparams ************************************************************/

#if GEMDOS
#if TURBO_C

typedef struct
{
  WORD contrl [15];
  WORD global [15];
  WORD intin [132];
  WORD intout [140];
  VOID FAR *addrin [16];
  VOID FAR *addrout [16];
} GEMPARBLK;

extern GEMPARBLK _GemParBlk;

typedef struct
{
    WORD *contrl;
    WORD *global;
    WORD *intin;
    WORD *intout;
    WORD *addrin;
    WORD *addrout;
} AESPB;

WORD vq_aes   (VOID);
VOID _crystal (AESPB *aespb);

#endif /* TURBO_C */
#endif /* GEMDOS */

/****** Application library **************************************************/

WORD  appl_init       _((VOID));
WORD  appl_read       _((WORD rwid, WORD length, VOID FAR *pbuff));
WORD  appl_write      _((WORD rwid, WORD length, VOID FAR *pbuff));
WORD  appl_find       _((BYTE FAR *pname));
WORD  appl_tplay      _((VOID FAR *tbuffer, WORD tlenght, WORD tscale));
WORD  appl_trecord    _((VOID FAR *tbuffer, WORD tlength));

#if GEM & (GEM2 | GEM3 | XGEM)
WORD  appl_bvset      _((UWORD bvdisk, UWORD bvhard));
VOID  appl_yield      _((VOID));
#endif /* GEM2 | GEM3 | XGEM */

WORD  appl_exit       _((VOID));
WORD  appl_search     _((WORD ap_smode, BYTE *ap_sname, WORD *ap_stype, WORD *ap_sid));
WORD  appl_getinfo    _((WORD ap_gtype, WORD *ap_gout1, WORD *ap_gout2, WORD *ap_gout3, WORD *ap_gout4));

/****** Event library ********************************************************/

typedef struct orect
{
  struct orect FAR *o_link;
  WORD         o_x;
  WORD         o_y;
  WORD         o_w;
  WORD         o_h;
} ORECT;

typedef struct grect
{
  WORD g_x;
  WORD g_y;
  WORD g_w;
  WORD g_h;
} GRECT;

typedef struct mevent
{
  UWORD e_flags;
  UWORD e_bclk;
  UWORD e_bmsk;
  UWORD e_bst;
  UWORD e_m1flags;
  GRECT e_m1;
  UWORD e_m2flags;
  GRECT e_m2;
  WORD FAR *e_mepbuf;
  ULONG e_time;
  WORD  e_mx;       
  WORD  e_my;
  UWORD e_mb;
  UWORD e_ks;
  UWORD e_kr;
  UWORD e_br;
  UWORD e_m3flags;
  GRECT e_m3;
  WORD  e_xtra0;
  WORD FAR *e_smepbuf;
  ULONG e_xtra1;
  ULONG e_xtra2;
} MEVENT;

/* multi flags */

#define MU_KEYBD    0x0001   
#define MU_BUTTON   0x0002
#define MU_M1       0x0004
#define MU_M2       0x0008
#define MU_MESAG    0x0010
#define MU_TIMER    0x0020
#define MU_M3       0x0040
#define MU_SYSMESAG 0x0080
#define MU_POSTEV   0x1000

/* keyboard states */

#define K_RSHIFT    0x0001
#define K_LSHIFT    0x0002
#define K_CTRL      0x0004
#define K_ALT       0x0008

/* message values */

#define SCR_MGR     0x0001 /* process id of the screen manager */

#define AP_MSG           0

#define MN_SELECTED      10
#define WM_REDRAW        20
#define WM_TOPPED        21
#define WM_CLOSED        22
#define WM_FULLED        23
#define WM_ARROWED       24
#define WM_HSLID         25
#define WM_VSLID         26
#define WM_SIZED         27
#define WM_MOVED         28
#define WM_NEWTOP        29 /* for compatibility */
#define WM_UNTOPPED      30
#define WM_ONTOP         31
#define WM_OFFTOP        32
#define WM_BOTTOMED      33
#define PR_FINISH        33
/* [GS] 5.1e Start */
#define WM_ICONIFY		   34
#define WM_UNICONIFY		 35
#define WM_ALLICONIFY		 36
/* Ende */

#define AC_OPEN          40
#define AC_CLOSE         41

#define CT_UPDATE        50
#define CT_MOVE          51
#define CT_NEWTOP        52
#define CT_SWITCH        53

#define AP_TERM          50
#define AP_TFAIL         51
#define AP_RESCHG        57
#define SHUT_COMPLETED   60
#define RESCHG_COMPLETED 61
#define AP_DRAGDROP      63
#define CH_EXIT          80

#define WM_BACKDROP     100

#define SV_ONTOP        110
#define SV_OFFTOP       111

#define WM_SHADED     22360
#define WM_UNSHADED   22361

typedef struct
{
  WORD m_out;
  WORD m_x;
  WORD m_y;
  WORD m_w;
  WORD m_h;
} MOBLK;

UWORD evnt_keybd      _((VOID));
WORD  evnt_button     _((WORD clicks, UWORD mask, UWORD state,
                         WORD FAR *pmx, WORD FAR *pmy,
                         WORD FAR *pmb, WORD FAR *pks));
WORD  evnt_mouse      _((WORD flags, WORD x, WORD y, WORD width, WORD height,
                         WORD FAR *pmx, WORD FAR *pmy,
                         WORD FAR *pmb, WORD FAR *pks));
WORD  evnt_mesag      _((WORD FAR *pbuff));
WORD  evnt_timer      _((UWORD locnt, UWORD hicnt));
WORD  evnt_multi      _((UWORD flags, UWORD bclk, UWORD bmsk, UWORD bst,
                         UWORD m1flags,
                         UWORD m1x, UWORD m1y, UWORD m1w, UWORD m1h,
                         UWORD m2flags,
                         UWORD m2x, UWORD m2y, UWORD m2w, UWORD m2h,
                         WORD FAR *mepbuff, UWORD tlc, UWORD thc,
                         WORD FAR *pmx, WORD FAR *pmy, WORD FAR *pmb,
                         WORD FAR *pks, UWORD FAR *pkr, WORD FAR *pbr));
#if GEM & (GEM3 | XGEM)
WORD  evnt_event      _((MEVENT *pmevent));
#endif /* GEM3 | XGEM */
WORD  evnt_dclick     _((WORD rate, WORD setit));

#if GEMDOS
#if TURBO_C

typedef struct  /* special type for EventMulti */
{
  WORD ev_mflags, ev_mbclicks, ev_bmask, ev_mbstate, ev_mm1flags,
       ev_mm1x, ev_mm1y, ev_mm1width, ev_mm1height, ev_mm2flags,
       ev_mm2x, ev_mm2y, ev_mm2width, ev_mm2height, ev_mtlocount, ev_mthicount;
  WORD ev_mwich, ev_mmox, ev_mmoy, ev_mmobutton, ev_mmokstate, ev_mkreturn, ev_mbreturn;
  WORD ev_mmgpbuf [8];
} EVENT;

WORD EvntMulti (EVENT *evnt_struct);

#endif /* TURBO_C */
#endif /* GEMDOS */

/****** Object library *******************************************************/

#define OB_NEXT(tree, id)    tree [id].ob_next
#define OB_HEAD(tree, id)    tree [id].ob_head
#define OB_TAIL(tree, id)    tree [id].ob_tail
#define OB_TYPE(tree, id)    (tree [id].ob_type & 0xff)
#define OB_EXTYPE(tree, id)  (tree [id].ob_type >> 8)
#define OB_FLAGS(tree, id)   tree [id].ob_flags
#define OB_STATE(tree, id)   tree [id].ob_state
#define OB_SPEC(tree, id)    tree [id].ob_spec
#define OB_X(tree, id)       tree [id].ob_x
#define OB_Y(tree, id)       tree [id].ob_y
#define OB_WIDTH(tree, id)   tree [id].ob_width
#define OB_HEIGHT(tree, id)  tree [id].ob_height

#define ROOT             0
#define NIL             -1 /* nil object index */
#define MAX_LEN         81 /* max string length */
#define MAX_DEPTH        8 /* max depth of search or draw for objects */

#define IP_HOLLOW        0 /* inside patterns */
#define IP_1PATT         1
#define IP_2PATT         2
#define IP_3PATT         3
#define IP_4PATT         4
#define IP_5PATT         5
#define IP_6PATT         6
#define IP_SOLID         7
                           /* system foreground and */
                           /*   background rules    */
#define SYS_FG      0x1100 /*   but transparent     */

#define WTS_FG      0x11a1 /* window title selected */
                           /*   using pattern 2 &   */
                           /*   replace mode text   */
#define WTN_FG      0x1100 /* window title normal   */

#define IBM              3 /* font types */
#define SMALL            5

#define G_BOX           20 /* graphic types of obs */
#define G_TEXT          21
#define G_BOXTEXT       22
#define G_IMAGE         23
#define G_USERDEF       24
#define G_PROGDEF       24 /* for compatibility */
#define G_IBOX          25
#define G_BUTTON        26
#define G_BOXCHAR       27
#define G_STRING        28
#define G_FTEXT         29
#define G_FBOXTEXT      30
#define G_ICON          31
#define G_TITLE         32
#define G_CICON         33

#define NONE        0x0000 /* Object flags */
#define SELECTABLE  0x0001
#define DEFAULT     0x0002
#define EXIT        0x0004
#define EDITABLE    0x0008
#define RBUTTON     0x0010
#define LASTOB      0x0020
#define TOUCHEXIT   0x0040
#define HIDETREE    0x0080
#define INDIRECT    0x0100

#define NORMAL      0x0000 /* Object states */
#define SELECTED    0x0001
#define CROSSED     0x0002
#define CHECKED     0x0004
#define DISABLED    0x0008
#define OUTLINED    0x0010
#define SHADOWED    0x0020
#define WHITEBAK    0x0040
#define DRAW3D      0x0080

#ifndef WHITE
#define WHITE            0 /* Object colors */
#define BLACK            1
#define RED              2
#define GREEN            3
#define BLUE             4
#define CYAN             5
#define YELLOW           6
#define MAGENTA          7
#define DWHITE           8
#define DBLACK           9
#define DRED            10
#define DGREEN          11
#define DBLUE           12
#define DCYAN           13
#define DYELLOW         14
#define DMAGENTA        15
#endif

#define EDSTART          0 /* editable text field definitions */
#define EDINIT           1
#define EDCHAR           2
#define EDEND            3

#define ED_START         0 /* for compatibility */
#define ED_INIT          1
#define ED_CHAR          2
#define ED_END           3

#define TE_LEFT          0 /* editable text justification */
#define TE_RIGHT         1
#define TE_CNTR          2

typedef struct text_edinfo
{
  BYTE  FAR *te_ptext;     /* ptr to text (must be 1st)     */
  BYTE  FAR *te_ptmplt;    /* ptr to template               */
  BYTE  FAR *te_pvalid;    /* ptr to validation chrs.       */
  WORD  te_font;           /* font                          */
  WORD  te_junk1;          /* junk word                     */
  WORD  te_just;           /* justification- left, right... */
  UWORD te_color;          /* color information word        */
  WORD  te_junk2;          /* junk word                     */
  WORD  te_thickness;      /* border thickness              */
  WORD  te_txtlen;         /* length of text string         */
  WORD  te_tmplen;         /* length of template string     */
} TEDINFO;

typedef struct icon_block
{
  WORD  FAR *ib_pmask;  /* ptr to mask of icon                */
  WORD  FAR *ib_pdata;  /* ptr to data of icon                */
  BYTE  FAR *ib_ptext;  /* ptr to text of icon                */
  UWORD ib_char;        /* character in icon                  */
  WORD  ib_xchar;       /* x-coordinate of ib_char            */
  WORD  ib_ychar;       /* y-coordinate of ib_char            */
  WORD  ib_xicon;       /* x-coordinate of icon               */
  WORD  ib_yicon;       /* y-coordinate of icon               */
  WORD  ib_wicon;       /* width of icon in pixels            */
  WORD  ib_hicon;       /* height of icon in pixels           */
  WORD  ib_xtext;       /* x-coordinate of the icon's text    */
  WORD  ib_ytext;       /* y-coordinate of the icon's text    */
  WORD  ib_wtext;       /* width of rectangle for icon's text */
  WORD  ib_htext;       /* height of icon's text in pixels    */
} ICONBLK;

typedef struct cicon_data
{
  WORD              num_planes;
  WORD              *col_data;
  WORD              *col_mask;
  WORD              *sel_data;
  WORD              *sel_mask;
  struct cicon_data *next_res;
} CICON;

typedef struct cicon_blk
{
  ICONBLK monoblk;
  CICON   *mainlist;
} CICONBLK;

typedef struct bit_block
{
  WORD FAR *bi_pdata;   /* ptr to bit forms data  */
  WORD bi_wb;           /* width of form in bytes */
  WORD bi_hl;           /* height in scan lines   */
  WORD bi_x;            /* source x in bit form   */
  WORD bi_y;            /* source y in bit form   */
  WORD bi_color;        /* fg color of blt        */
} BITBLK;

#ifndef __STDC__

typedef struct user_blk
{
#if MSDOS
#if HIGH_C
  FAR WORD (*ub_code) _((VOID));                      /* pointer to drawing function */
#else
  WORD (FAR *ub_code) _((VOID));                      /* pointer to drawing function */
#endif
#else
  WORD CDECL (FAR *ub_code) _((struct parm_blk *pb)); /* pointer to drawing function */
#endif
  LONG ub_parm;                                       /* parm for drawing function   */
} USERBLK;

typedef struct appl_blk /* for compatibility */
{
#if MSDOS
#if HIGH_C
  FAR WORD (*ab_code) _((VOID));                      /* pointer to drawing function */
#else
  WORD (FAR *ab_code) _((VOID));                      /* pointer to drawing function */
#endif
#else
  WORD CDECL (FAR *ab_code) _((struct parm_blk *pb)); /* pointer to drawing function */
#endif
  LONG ab_parm;                                       /* parm for drawing function   */
} APPLBLK;

#endif

typedef struct
{
  unsigned character   : 8;
  signed   framesize   : 8;
  unsigned framecol    : 4;
  unsigned textcol     : 4;
  unsigned textmode    : 1;
  unsigned fillpattern : 3;
  unsigned interiorcol : 4;
} bfobspec;

typedef union obspecptr
{
  long            index;
  union obspecptr *indirect;
  bfobspec        obspec;
  TEDINFO         *tedinfo;
  ICONBLK         *iconblk;
  CICONBLK        *ciconblk;
  BITBLK          *bitblk;
  char            *free_string;
#ifndef __STDC__
  USERBLK         *userblk;
#endif
} OBSPEC;

typedef struct object
{
  WORD   ob_next;   /* -> object's next sibling       */
  WORD   ob_head;   /* -> head of object's children   */
  WORD   ob_tail;   /* -> tail of object's children   */
  UWORD  ob_type;   /* type of object- BOX, CHAR, ... */
  UWORD  ob_flags;  /* flags                          */
  UWORD  ob_state;  /* state- SELECTED, CROSSED, ...  */
#ifdef NEW_OBJECT
  OBSPEC ob_spec;   /* "out"- -> anything else        */
#else
  LONG   ob_spec;   /* "out"- -> anything else        */
#endif
  WORD   ob_x;      /* upper left corner of object    */
  WORD   ob_y;      /* upper left corner of object    */
  WORD   ob_width;  /* width of object                */
  WORD   ob_height; /* height of object               */
} OBJECT;

typedef struct parm_blk
{
  OBJECT FAR *pb_tree;               /* ptr to obj tree for user defined obj */
  WORD   pb_obj;                     /* index of user defined object         */
  WORD   pb_prevstate;               /* old state to be changed              */
  WORD   pb_currstate;               /* changed (new) state of object        */
  WORD   pb_x, pb_y, pb_w, pb_h;     /* location of object on screen         */
  WORD   pb_xc, pb_yc, pb_wc, pb_hc; /* current clipping rectangle on screen */
  LONG   pb_parm;                    /* same as ub_parm in USERBLK struct    */
} PARMBLK;

WORD  objc_add        _((OBJECT FAR *tree, WORD parent, WORD child));
WORD  objc_delete     _((OBJECT FAR *tree, WORD delob));
WORD  objc_draw       _((OBJECT FAR *tree, WORD drawob, WORD depth,
                         WORD xc, WORD yc, WORD wc, WORD hc));
WORD  objc_find       _((OBJECT FAR *tree, WORD startob, WORD depth,
                         WORD mx, WORD my));
WORD  objc_offset     _((OBJECT FAR *tree, WORD obj, WORD FAR *poffx,
                         WORD FAR *poffy));
WORD  objc_order      _((OBJECT FAR *tree, WORD mov_obj, WORD newpos));
WORD  objc_edit       _((OBJECT FAR *tree, WORD obj, WORD inchar,
                         WORD FAR *idx, WORD kind));
WORD  objc_change     _((OBJECT FAR *tree, WORD drawob, WORD depth,
                         WORD xc, WORD yc, WORD wc, WORD hc,
                         WORD nestate, WORD redraw));

/****** Menu library *********************************************************/

typedef struct
{
  OBJECT *mn_tree;
  WORD   mn_menu;
  WORD   mn_item;
  WORD   mn_scroll;
  WORD   mn_keystate;
} MENU;

typedef struct
{
 LONG Display;
 LONG Drag;
 LONG Delay;
 LONG Speed;
 WORD Height;
} MN_SET;

WORD  menu_bar        _((OBJECT FAR *tree, WORD showit));
WORD  menu_icheck     _((OBJECT FAR *tree, WORD itemnum, WORD checkit));
WORD  menu_ienable    _((OBJECT FAR *tree, WORD itemnum, WORD enableit));
WORD  menu_tnormal    _((OBJECT FAR *tree, WORD titlenum, WORD normalit));
WORD  menu_text       _((OBJECT FAR *tree, WORD inum, BYTE FAR *ptext));
WORD  menu_register   _((WORD pid, BYTE FAR *pstr));

#if GEM & (GEM2 | GEM3 | XGEM)
WORD  menu_unregister _((WORD mid));
#endif /* GEM2 | GEM3 | XGEM */

#if GEM & (GEM3 | XGEM)
WORD  menu_click      _((WORD click, WORD setit));
#endif /* GEM3 | XGEM */

#if GEM & GEM1
WORD menu_popup       _((MENU *me_menu, WORD me_xpos, WORD me_ypos, MENU *me_mdata));
WORD menu_attach      _((WORD me_flag, OBJECT *me_tree, WORD me_item, MENU *me_mdata));
WORD menu_istart      _((WORD me_flag, OBJECT *me_tree, WORD me_imenu, WORD me_item));
WORD menu_settings    _((WORD me_flag, MN_SET *me_values));
#endif /* GEM1 */

/****** Form library *********************************************************/

/* Form flags */

#define FMD_START        0
#define FMD_GROW         1
#define FMD_SHRINK       2
#define FMD_FINISH       3
#define FMD_ASTART       4
#define FMD_AFINISH      5

WORD  form_do         _((OBJECT FAR *form, WORD start));
WORD  form_dial       _((WORD dtype, WORD ix, WORD iy, WORD iw, WORD ih,
                         WORD x, WORD y, WORD w, WORD h));
WORD  form_alert      _((WORD defbut, BYTE FAR *astring));
WORD  form_error      _((WORD errnum));
WORD  form_center     _((OBJECT FAR *tree, WORD FAR *pcx, WORD FAR *pcy,
                         WORD FAR *pcw, WORD FAR *pch));
WORD  form_keybd      _((OBJECT FAR *form, WORD obj, WORD nxt_obj,
                         UWORD thechar, WORD FAR *pnxt_obj, UWORD FAR *pchar));
WORD  form_button     _((OBJECT FAR *form, WORD obj, WORD clks, 
                         WORD FAR *pnxt_obj));

/****** Graphics library ******************************************************/

/* Mouse Forms */

#define ARROW            0
#define TEXT_CRSR        1
#define HOURGLASS        2
#define BUSY_BEE         2 /* for compatibility */
#define POINT_HAND       3
#define FLAT_HAND        4
#define THIN_CROSS       5
#define THICK_CROSS      6
#define OUTLN_CROSS      7
#define M_PUSH         100
#define M_POP          101
#define USER_DEF       255
#define M_OFF          256
#define M_ON           257

/* Mouse Form Definition Block */

typedef struct mfstr
{
  WORD mf_xhot;
  WORD mf_yhot;
  WORD mf_nplanes;
  WORD mf_fg;
  WORD mf_bg;
  WORD mf_mask [16];
  WORD mf_data [16];
} MFORM;

WORD  graf_rubbox     _((WORD xorigin, WORD yorigin, WORD wmin, WORD hmin,
                         WORD FAR *pwend, WORD FAR *phend));
WORD  graf_dragbox    _((WORD w, WORD h, WORD sx, WORD sy, WORD xc, WORD yc,
                         WORD wc, WORD hc, WORD FAR *pdx, WORD FAR *pdy));
WORD  graf_mbox       _((WORD w, WORD h, WORD srcx, WORD srcy,
                         WORD dstx, WORD dsty));
VOID  graf_growbox    _((WORD stx, WORD sty, WORD stw, WORD sth,
                         WORD finx, WORD finy, WORD finw, WORD finh));
VOID  graf_shrinkbox  _((WORD finx, WORD finy, WORD finw, WORD finh,
                         WORD stx, WORD sty, WORD stw, WORD sth));
WORD  graf_watchbox   _((OBJECT FAR *tree, WORD obj, WORD instate,
                         WORD outstate));
WORD  graf_slidebox   _((OBJECT FAR *tree, WORD parent, WORD obj,
                         WORD isvert));
WORD  graf_handle     _((WORD FAR *pwchar, WORD FAR *phchar,
                         WORD FAR *pwbox, WORD FAR *phbox));
WORD  graf_mouse      _((WORD m_number, MFORM FAR *m_addr));
VOID  graf_mkstate    _((WORD FAR *pmx, WORD FAR *gpmy,
                         WORD FAR *pmstate, WORD FAR *pkstate));

/****** Scrap library ********************************************************/

#define SCRAP_CSV   0x0001
#define SCRAP_TXT   0x0002
#define SCRAP_GEM   0x0004
#define SCRAP_IMG   0x0008
#define SCRAP_DCA   0x0010
#define SCRAP_USR   0x8000

WORD  scrp_read       _((BYTE FAR *pscrap));
WORD  scrp_write      _((BYTE FAR *pscrap));

#if GEM & (GEM2 | GEM3 | XGEM)
WORD  scrp_clear      _((VOID));
#endif /* GEM2 | GEM3 | XGEM*/

/****** File selector library ************************************************/

WORD  fsel_input      _((BYTE FAR *pipath, BYTE FAR *pisel,
                         WORD FAR *pbutton));

#if GEM & GEM1
WORD  fsel_exinput    _((BYTE FAR *pipath, BYTE FAR *pisel, WORD FAR *pbutton,
                         BYTE *plabel));
#endif /* GEM1 */

/****** Window library *******************************************************/

/* Window Attributes */

#define NAME        0x0001
#define CLOSER      0x0002
#define FULLER      0x0004
#define MOVER       0x0008
#define INFO        0x0010
#define SIZER       0x0020
#define UPARROW     0x0040
#define DNARROW     0x0080
#define VSLIDE      0x0100
#define LFARROW     0x0200
#define RTARROW     0x0400
#define HSLIDE      0x0800
#define HOTCLOSEBOX 0x1000 /* for compatibility */
#define HOTCLOSE    0x1000
/* [GS] 5.1e Start */
#define ICONIFIER		0x4000
/* Ende */

/* wind_calc flags */

#define WC_BORDER        0
#define WC_WORK          1

/* wind_get/wind_set flags */

#define WF_KIND          1
#define WF_NAME          2
#define WF_INFO          3
#define WF_WXYWH         4
#define WF_WORKXYWH      4 /* for compatibility */
#define WF_CXYWH         5
#define WF_CURRXYWH      5 /* for compatibility */
#define WF_PXYWH         6
#define WF_PREVXYWH      6 /* for compatibility */
#define WF_FXYWH         7
#define WF_FULLXYWH      7 /* for compatibility */
#define WF_HSLIDE        8
#define WF_VSLIDE        9
#define WF_TOP          10
#define WF_FIRSTXYWH    11
#define WF_NEXTXYWH     12
#define WF_IGNORE       13
#define WF_NEWDESK      14
#define WF_HSLSIZE      15
#define WF_VSLSIZE      16
#define WF_SCREEN       17
#define WF_TATTRB       18 /* only for XGEM */
#define WF_SIZTOP       19 /* only for XGEM */
#define WF_TOPAP        20 /* only for XGEM */
#define WF_COLOR        18
#define WF_DCOLOR       19
#define WF_OWNER        20
#define WF_BEVENT       24
#define WF_BOTTOM       25
/* [GS] 5.1e Start */
#define WF_ICONIFY			26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH 28
/* Ende */

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

/* update flags */

#define END_UPDATE       0
#define BEG_UPDATE       1
#define END_MCTRL        2
#define BEG_MCTRL        3
#define BEG_EMERG        4
#define END_EMERG        5

/* arrow message */

#define WA_SUBWIN        1
#define WA_KEEPWIN       2

#define WA_UPPAGE        0 /* Window Arrow Up Page    */
#define WA_DNPAGE        1 /* Window Arrow Down Page  */
#define WA_UPLINE        2 /* Window Arrow Up Line    */
#define WA_DNLINE        3 /* Window Arrow Down Line  */
#define WA_LFPAGE        4 /* Window Arrow Left Page  */
#define WA_RTPAGE        5 /* Window Arrow Right Page */
#define WA_LFLINE        6 /* Window Arrow Left Line  */
#define WA_RTLINE        7 /* Window Arrow Right Line */

WORD  wind_create     _((UWORD kind, WORD wx, WORD wy, WORD ww, WORD wh));
WORD  wind_open       _((WORD handle, WORD wx, WORD wy, WORD ww, WORD wh));
WORD  wind_close      _((WORD handle));
WORD  wind_delete     _((WORD handle));
#if GEMDOS
WORD  wind_get        _((WORD w_handle, WORD wfield, ...));
WORD  wind_set        _((WORD w_handle, WORD wfield, ...));
#else
WORD  wind_get        _((WORD w_handle, WORD wfield,
                         WORD FAR *pw1, WORD FAR *pw2,
                         WORD FAR *pw3, WORD FAR *pw4));
WORD  wind_set        _((WORD w_handle, WORD wfield,
                         WORD w1, WORD w2, WORD w3, WORD w4));
#endif
WORD  wind_find       _((WORD mx, WORD my));
WORD  wind_update     _((WORD beg_update));
WORD  wind_calc       _((WORD wctype, UWORD kind,
                         WORD x, WORD y, WORD w, WORD h,
                         WORD FAR *px, WORD FAR *py,
                         WORD FAR *pw, WORD FAR *ph));

#if GEM & GEM1
VOID  wind_new        _((VOID));
#endif /* GEM1 */

#if GEM & XGEM
WORD  wind_apfind     _((WORD mx, WORD my));
#endif /* XGEM */

/****** Resource library *****************************************************/

/* data structure types */

#define R_TREE           0
#define R_OBJECT         1
#define R_TEDINFO        2
#define R_ICONBLK        3
#define R_BITBLK         4
#define R_STRING         5 /* gets pointer to free strings     */
#define R_IMAGEDATA      6 /* gets pointer to free images      */
#define R_OBSPEC         7
#define R_TEPTEXT        8 /* sub ptrs in TEDINFO              */
#define R_TEPTMPLT       9
#define R_TEPVALID      10
#define R_IBPMASK       11 /* sub ptrs in ICONBLK              */
#define R_IBPDATA       12
#define R_IBPTEXT       13
#define R_BIPDATA       14 /* sub ptrs in BITBLK               */
#define R_FRSTR         15 /* gets addr of ptr to free strings */
#define R_FRIMG         16 /* gets addr of ptr to free images  */

/* used in RSCREATE.C */

typedef struct rshdr
{
  UWORD rsh_vrsn;
  UWORD rsh_object;
  UWORD rsh_tedinfo;
  UWORD rsh_iconblk;       /* list of ICONBLKS          */
  UWORD rsh_bitblk;
  UWORD rsh_frstr;
  UWORD rsh_string;
  UWORD rsh_imdata;        /* image data                */
  UWORD rsh_frimg;
  UWORD rsh_trindex;
  UWORD rsh_nobs;          /* counts of various structs */
  UWORD rsh_ntree;
  UWORD rsh_nted;
  UWORD rsh_nib;
  UWORD rsh_nbb;
  UWORD rsh_nstring;
  UWORD rsh_nimages;
  UWORD rsh_rssize;        /* total bytes in resource   */
} RSHDR;

#define F_ATTR 0           /* file attr for dos_create  */

WORD  rsrc_load       _((BYTE FAR *rsname));
WORD  rsrc_free       _((VOID));
WORD  rsrc_gaddr      _((WORD rstype, WORD rsid, VOID FAR *paddr));
WORD  rsrc_saddr      _((WORD rstype, WORD rsid, VOID FAR *lngval));
WORD  rsrc_obfix      _((OBJECT FAR *tree, WORD obj));

#if GEM & GEM1
WORD  rsrc_rcfix      _((RSHDR *rc_header));
#endif /* GEM1 */

/****** Shell library ********************************************************/

#define SHW_SHUTDOWN     4
#define SHW_RESCHNG      5
#define SHW_INFRECGN     9
#define SHW_AESSEND     10

WORD  shel_read       _((BYTE FAR *pcmd, BYTE FAR *ptail));
WORD  shel_write      _((WORD doex, WORD isgr, WORD isover, BYTE FAR *pcmd,
                         BYTE FAR *ptail));
WORD  shel_get        _((BYTE FAR *addr, WORD len));
WORD  shel_put        _((BYTE FAR *addr, WORD len));
WORD  shel_find       _((BYTE FAR *ppath));
WORD  shel_envrn      _((BYTE FAR * FAR *ppath, BYTE FAR *psrch));

#if GEM & (GEM2 | GEM3)
WORD  shel_rdef       _((BYTE FAR *lpcmd, BYTE FAR *lpdir));
WORD  shel_wdef       _((BYTE FAR *lpcmd, BYTE FAR *lpdir));
#endif /* GEM2 | GEM3 */

/****** Extended graphics library ********************************************/

#if GEM & (GEM2 | GEM3 | XGEM)
WORD  xgrf_stepcalc   _((WORD orgw, WORD orgh, WORD xc, WORD yc,
                         WORD w, WORD h, WORD FAR *pcx, WORD FAR *pcy,
                         WORD FAR *pcnt, WORD FAR *pxstep, WORD FAR *pystep));
WORD  xgrf_2box       _((WORD xc, WORD yc, WORD w, WORD h, WORD corners,
                         WORD cnt, WORD xstep, WORD ystep, WORD doubled));
#endif /* GEM2 | GEM3 | XGEM */

/*****************************************************************************/

#endif /* __AES__ */
