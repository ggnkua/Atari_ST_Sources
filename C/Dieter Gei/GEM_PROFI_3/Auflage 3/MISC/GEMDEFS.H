/************************************************************************/
/*   GEMDEFS.H: Common GEM definitions and miscellaneous structures.    */
/************************************************************************/

#ifndef __GEMDEFS__
#define __GEMDEFS__

/*******************************/
/*   EVENT Manager Definitions */
/*******************************/

#if GEM & XGEM
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
  WORD  *e_mepbuf;
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
  WORD  *e_smepbuf;
  ULONG e_xtra1;
  ULONG e_xtra2;
} MEVENT;
#endif /* XGEM */

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
#define WM_NEWTOP       29 /* for compatibility */
#define WM_UNTOPPED     30
#define WM_ONTOP        31
#define WM_OFFTOP       32
#define PR_FINISH       33

#define AC_OPEN         40
#define AC_CLOSE        41

#define CT_UPDATE       50
#define CT_MOVE         51
#define CT_NEWTOP       52
#define CT_SWITCH       53

#define SV_ONTOP       110
#define SV_OFFTOP      111

/****************************/
/* FORM Manager Definitions */
/****************************/

/* Form flags */

#define FMD_START        0
#define FMD_GROW         1
#define FMD_SHRINK       2
#define FMD_FINISH       3
#define FMD_ASTART       4
#define FMD_AFINISH      5

/********************************/
/* RESOURCE Manager Definitions */
/********************************/

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

/********************************/
/*   WINDOW Manager Definitions */
/********************************/

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
#define WF_TATTRB       18
#define WF_SIZTOP       19
#define WF_TOPAP        20

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

/**********************************/
/*   GRAPHICS Manager Definitions */
/**********************************/

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

/******************************/
/*   MISCELLANEOUS Structures */
/******************************/

/* Memory Form Definition Block */

typedef struct memform
{
  VOID FAR *mp;
  WORD fwp;
  WORD fh;
  WORD fww;
  WORD ff;
  WORD np;
  WORD r1;
  WORD r2;
  WORD r3;
} MFDB;

typedef struct fdbstr   /* for compatibility */
{
  VOID FAR *fd_addr;
  WORD fd_w;
  WORD fd_h;
  WORD fd_wdwidth;
  WORD fd_stand;
  WORD fd_nplanes;
  WORD fd_r1;
  WORD fd_r2;
  WORD fd_r3;
} FDB;

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
} MFORM ;

/* Fill Pattern */

typedef struct patarray
{
  WORD patword [16];
} FILLPAT;

#define SCRAP_CSV   0x0001
#define SCRAP_TXT   0x0002
#define SCRAP_GEM   0x0004
#define SCRAP_IMG   0x0008
#define SCRAP_DCA   0x0010
#define SCRAP_USR   0x0020

#define OW_FILE          0 /* output device type in the low-order byte */
#define OW_SERIAL        1
#define OW_PARALLEL      2
#define OW_DEVICE        3
#define OW_NOCHANGE    255

#define OW_LETTER1       0 /* page size index in the high-order byte */
#define OW_HALF          5
#define OW_B5           10
#define OW_LETTER2      20
#define OW_A4           30
#define OW_LEGAL        40
#define OW_DOUBLE       50
#define OW_BROAD        55
#define OW_INDIRECT    255 /* use work_in [101] and work_in [102] */

#define PM_DOT           1 /* polymarker types */
#define PM_PLUS          2
#define PM_ASTERISK      3
#define PM_SQUARE        4
#define PM_DIAGCROSS     5
#define PM_DIAMOND       6

#define TXT_NORMAL       0x0000 /* text effects */
#define TXT_THICKENED    0x0001
#define TXT_LIGHT        0x0002
#define TXT_SKEWED       0x0004
#define TXT_UNDERLINED   0x0008
#define TXT_OUTLINED     0x0010
#define TXT_SHADOWED     0x0020

#define ALI_LEFT         0 /* horizontal text alignment */
#define ALI_CENTER       1
#define ALI_RIGHT        2

#define ALI_BASE         0 /* vertical text alignment */
#define ALI_HALF         1
#define ALI_ASCENT       2
#define ALI_BOTTOM       3
#define ALI_DESCENT      4
#define ALI_TOP          5

#define DEV_LOCATOR      1 /* input device */
#define DEV_VALUATOR     2
#define DEV_CHOICE       3
#define DEV_STRING       4

#define MODE_REQUEST     1 /* input mode */
#define MODE_SAMPLE      2

#define O_B_BOLDFACE     '0' /* OUT-File definitions for v_alpha_text */
#define O_E_BOLDFACE     '1'
#define O_B_ITALICS      '2'
#define O_E_ITALICS      '3'
#define O_B_UNDERSCORE   '4'
#define O_E_UNDERSCORE   '5'
#define O_B_SUPERSCRIPT  '6'
#define O_E_SUPERSCRIPT  '7'
#define O_B_SUBSCRIPT    '8'
#define O_E_SUBSCRIPT    '9'
#define O_B_NLQ          'A'
#define O_E_NLQ          'B'
#define O_B_EXPANDED     'C'
#define O_E_EXPANDED     'D'
#define O_B_LIGHT        'E'
#define O_E_LIGHT        'F'
#define O_PICA           'W'
#define O_ELITE          'X'
#define O_CONDENSED      'Y'
#define O_PROPORTIONAL   'Z'

#define O_GRAPHICS       "\033\033GEM,%d,%d,%d,%d,%s"

#define MUTE_RETURN     -1 /* definitions for vs_mute */
#define MUTE_ENABLE      0
#define MUTE_DISABLE     1

#define OR_PORTRAIT      0 /* definitions for v_orient */
#define OR_LANDSCAPE     1

#define TRAY_MANUAL     -1 /* definitions fpr v_tray */
#define TRAY_DEFAULT     0
#define TRAY_FIRSTOPT    1

#define XBIT_FRACT       0 /* definitions for v_xbit_image */
#define XBIT_INTEGER     1

#define XBIT_LEFT        0
#define XBIT_CENTER      1
#define XBIT_RIGHT       2

#define XBIT_TOP         0
#define XBIT_MIDDLE      1
#define XBIT_BOTTOM      2

#endif /* __GEMDEFS__ */
