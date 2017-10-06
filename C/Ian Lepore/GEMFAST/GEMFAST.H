/* tab expansion/compression should be set to 4 */
/**************************************************************************
 * GEMFAST.H - Header file for GEM programming.
 *
 *  This header file contains items compatible with both GEMDEFS and OBDEFS
 *  from the Alcyon system.  Note that there are no 'extern' definitions
 *  for the GEM functions, because they all return a signed int and work
 *  fine as autodefined functions.
 *
 * Maintenance:
 *  02/29/92 - v1.8
 *             > Added new options for new utility functions.
 *             > Added extern declarations for all global vars.
 *             > Added macro to map frm_dsdial() to frm_dsdialog() with
 *               parms in the new order.
 *             > Added macros mapping appl_init/exit to apl_xinit/xexit,
 *               so that all aps automatically get new extended init that
 *               fills in the new global vars.  New utils REQUIRE that
 *               these vars be init'd; think twice before changing this!
 *             > Changed FDADDR datatype from char* to void*.
 *  05/26/90 - v1.4
 *             > Added RSHDR structure for imbedded resource support.
 *             > Fixed all structures which defined pointers as 'long'...
 *               - ICONBLK ib_pmask, ib_pdata, ib_ptext
 *               - BITBLK  bi_pdata
 *               - USERBLK ub_code
 *               - PARMBLK pb_tree
 *               All of these structure elements now define the proper ptr.
 *             > Added AESUTIL_A, AESFAST_A and VDIFAST_A symbols.  This
 *               allows specific indication of the presence or abscence of
 *               the bindings libraries, allowing a programmer to use the
 *               GEMFAST.H header without using the rest of GemFast.  This
 *               also allows conditional compilation code to be more
 *               specific:  it can now test for the presence of the header
 *               file (and handle the differences in the structure defs),
 *               and it can separately test for the presence of the libs,
 *               and the extended functions available therein.
 *  12/03/89 - v1.3
 *             > Renamed a lot of functions, a name compatibility block was
 *               added at the end of this file to smooth the transition.
 *             > Added NO_OBJECT, MU_MENTRY, MU_MEXIT to defines.
 *             > Added XMULTI struct, even though it really belongs to v2.0
 *************************************************************************/

#pragma idempotent              /* sozobon: prevent multiple inclusion */

#ifndef GEMFAST_H               /* Prevent multiple inclusion */

#define GEMFAST_H       1       /* Tell the world GEMFAST header is used */
#define GEMF_VERSION    0x0180  /* Tell the world we are v1.80           */

#define AESUTIL_A       1       /* Tell the world AESFAST utils  available */
#define AESFAST_A       1       /* Tell the world AESFAST lib is available */
#define VDIFAST_A       1       /* Tell the world VDIFAST lib is available */

                                /* VDI inside fill styles  */
#define IS_HOLLOW   0
#define IS_SOLID    1
#define IS_PATTERN  2
#define IS_HATCH    3
#define IS_UDPTRN   4
                                /* VDI inside fill patterns  */
#define IP_HOLLOW   0
#define IP_1PTRN    1
#define IP_2PTRN    2
#define IP_3PTRN    3
#define IP_4PTRN    4
#define IP_5PTRN    5
#define IP_6PTRN    6
#define IP_SOLID    7
                               /* VDI normal graphics drawing modes */
#define MD_REPLACE  1
#define MD_TRANS    2
#define MD_XOR      3
#define MD_ERASE    4
                               /* VDI bit blt rules */
#define ALL_WHITE   0
#define S_AND_D     1
#define S_AND_NOTD  2
#define S_ONLY      3
#define NOTS_AND_D  4
#define D_ONLY      5
#define S_XOR_D     6
#define S_OR_D      7
#define NOT_SORD    8
#define NOT_SXORD   9
#define D_INVERT    10
#define NOT_D       10
#define S_OR_NOTD   11
#define NOT_S       12
#define NOTS_OR_D   13
#define NOT_SANDD   14
#define ALL_BLACK   15
                                    /* font types */
#define IBM         3
#define SMALL       5
                                    /* evnt_multi options */
#define MU_KEYBD    0x0001
#define MU_BUTTON   0x0002
#define MU_M1       0x0004
#define MU_M2       0x0008
#define MU_MESAG    0x0010
#define MU_TIMER    0x0020
                                    /* evnt_mouse options */
#define MU_MENTRY   0x0000
#define MU_MEXIT    0x0001
                                    /* keyboard states */
#define K_RSHIFT    0x0001
#define K_LSHIFT    0x0002
#define K_CTRL      0x0004
#define K_ALT       0x0008
                                    /* event message values */
#define MN_SELECTED 10
#define WM_REDRAW   20
#define WM_TOPPED   21
#define WM_CLOSED   22
#define WM_FULLED   23
#define WM_ARROWED  24
#define WM_HSLID    25
#define WM_VSLID    26
#define WM_SIZED    27
#define WM_MOVED    28
#define WM_NEWTOP   29
#define AC_OPEN     40
#define AC_CLOSE    41
                                    /* form_dial opcodes */
#define FMD_START   0
#define FMD_GROW    1
#define FMD_SHRINK  2
#define FMD_FINISH  3
                                    /* rsrc_gaddr structure types */
#define ROOT        0               /* this name used by MWC */
#define R_TREE      0
#define R_OBJECT    1
#define R_TEDINFO   2
#define R_ICONBLK   3
#define R_BITBLK    4
#define R_STRING    5
#define R_IMAGEDATA 6
#define R_OBSPEC    7
#define R_TEPTEXT   8
#define R_TEPTMPLT  9
#define R_TEPVALID  10
#define R_IBPMASK   11
#define R_IBPDATA   12
#define R_IBPTEXT   13
#define R_BIPDATA   14
#define R_FRSTR     15
#define R_FRIMG     16
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
                                    /* wind_calc options */
#define WC_BORDER   0
#define WC_WORK     1
                                    /* wind_get options */
#define WF_KIND     1
#define WF_NAME     2
#define WF_INFO     3
#define WF_WORKXYWH 4
#define WF_CURRXYWH 5
#define WF_PREVXYWH 6
#define WF_FULLXYWH 7
#define WF_HSLIDE   8
#define WF_VSLIDE   9
#define WF_TOP      10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH 12
#define WF_RESVD    13
#define WF_NEWDESK  14
#define WF_HSLSIZE  15
#define WF_VSLSIZE  16
#define WF_SCREEN   17
                                    /* wind_update options */
#define END_UPDATE  0
#define BEG_UPDATE  1
#define END_MCTRL   2
#define BEG_MCTRL   3
                                    /* graf_mouse mouse types*/
#define ARROW           0
#define TEXT_CRSR       1
#define HOURGLASS       2           /* this name used by MWC */
#define BUSYBEE         2           /* because I always forget the underbar */
#define BUSY_BEE        2
#define BEE             2
#define POINT_HAND      3
#define FLAT_HAND       4
#define THIN_CROSS      5
#define THICK_CROSS     6
#define OUTLN_CROSS     7
#define USER_DEF        255
#define M_OFF           256
#define M_ON            257
                                /* max depth of search or draw  */
#define MAX_DEPTH   8
                                /* value returned by objc_find(), et. al. */
#define NO_OBJECT   -1
                                /* object types */
#define G_BOX       20
#define G_TEXT      21
#define G_BOXTEXT   22
#define G_IMAGE     23
#define G_USERDEF   24
#define G_PROGDEF   24
#define G_IBOX      25
#define G_BUTTON    26
#define G_BOXCHAR   27
#define G_STRING    28
#define G_FTEXT     29
#define G_FBOXTEXT  30
#define G_ICON      31
#define G_TITLE     32
                                /* object options */
#define NONE        0x0000
#define SELECTABLE  0x0001
#define DEFAULT     0x0002
#define EXIT        0x0004
#define EDITABLE    0x0008
#define RBUTTON     0x0010
#define LASTOB      0x0020
#define TOUCHEXIT   0x0040
#define HIDETREE    0x0080
#define INDIRECT    0x0100
                                /* Object states */
#define NORMAL      0x0000
#define SELECTED    0x0001
#define CROSSED     0x0002
#define CHECKED     0x0004
#define DISABLED    0x0008
#define OUTLINED    0x0010
#define SHADOWED    0x0020
                                /* Object colors    */
#define WHITE       0
#define BLACK       1
#define RED         2
#define GREEN       3
#define BLUE        4
#define CYAN        5
#define YELLOW      6
#define MAGENTA     7
#define LWHITE      8
#define LBLACK      9
#define LRED        10
#define LGREEN      11
#define LBLUE       12
#define LCYAN       13
#define LYELLOW     14
#define LMAGENTA    15
                                /* editable text field definitions */
#define EDSTART     0
#define EDINIT      1
#define EDCHAR      2
#define EDEND       3
                                /* editable text justification */
#define TE_LEFT     0
#define TE_RIGHT    1
#define TE_CNTR     2

/*-------------------------------------------------------------------------
 * a few miscellanious GemFast-defined constants...
 *-----------------------------------------------------------------------*/

#define GRF_MSALTARROW    200   /* alternate value of ARROW for grf_mouse() */
#define GRF_MSINQUIRE    (-1)   /* inquire current shape for grf_mouse()    */
#define OBJ_BMINQUIRE    (-1)   /* get w/o change from obj_bmbuttons()      */
#define FRM_GETDEFAULTS (-1L)   /* get w/o change from frm_defaults()       */
#define FRM_MOVER      0x4000   /* special ob_flags value for moveable forms*/

#define G_THERMO          200   /* ob_type for a thermometer display object */

#define OBJ_NODRAW          0   /* obj_XXchange(): no draw after change     */
#define OBJ_WITHDRAW        1   /* obj_XXchange(): do draw after change     */
#define OBJ_CLIPDRAW        2   /* obj_XXchange(): draw with optional clip  */

#define OBJ_TINQUIRE  (-32000)  /* inquire current G_THERMO position        */
#define OBJ_TINCREMENT    (-1)  /* increment current G_THERMO position by 1 */

#define FRM_DSMAXBUTTONS    5   /* max dynamic button strings               */
#define FRM_DSMAXSTRINGS   20   /* max dynamic dialog display strings       */

/*-------------------------------------------------------------------------
 * options for apl_whatever() functions...
 *-----------------------------------------------------------------------*/

#define APL_RTRANSIENT      0x0001  /* cleanup transient resources */
#define APL_RPERMENANT      0x0002  /* cleanup permenant resources */

/*-------------------------------------------------------------------------
 * actions for frm_desktop()...
 *-----------------------------------------------------------------------*/

#define FRM_DTINSTALL   0x00000000L  /* install form as system desktop      */
#define FRM_DTREMOVE    0x10000000L  /* remove form, revert to sys desktop  */

/*-------------------------------------------------------------------------
 * actions for frm_dialog()...
 *-----------------------------------------------------------------------*/

#define FRM_DSTART      0x10000000L  /* do FMD_START                        */
#define FRM_DDRAW       0x20000000L  /* do objc_draw()                      */
#define FRM_DDO         0x40000000L  /* do form_do()                        */
#define FRM_DFINISH     0x80000000L  /* do FMD_FINISH                       */
#define FRM_DCOMPLETE   0xF0000000L  /* do all the steps above in one call  */

/*-------------------------------------------------------------------------
 * actions for frm_progress()...
 *-----------------------------------------------------------------------*/

#define FRM_PSTART      0x10000000L  /* set up and display progress dialog  */
#define FRM_PUPDATE     0x40000000L  /* update progress thermometer         */
#define FRM_PFINISH     0x80000000L  /* close and cleanup progress dialog   */

/*-------------------------------------------------------------------------
 * options for all frm_whatever() functions...
 *   0xauddbbbb
 *     ||| |______ Basic options for all dialog handling.
 *     |||________ Dynamic dialog options.
 *     ||_________ User options; never touched by GemFast.
 *     |__________ Actions.
 *-----------------------------------------------------------------------*/

#define FRM_NORMAL          0x00000000L /* placeholder when you want none   */
#define FRM_EXPLODE         0x00000001L /* exploding box graphics in dialog */
#define FRM_CENTER          0x00000002L /* center dialog in screen          */
#define FRM_NEARMOUSE       0x00000004L /* center dialog over mouse         */
#define FRM_MOUSEARROW      0x00000008L /* force mouse ARROW during dialog  */
#define FRM_USEBLIT         0x00000010L /* use blits instead of redraw msgs */
#define FRM_MOVEABLE        0x00000020L /* dialog is moveable               */
#define FRM_NODEFAULTS      0x00008000L /* these options override defaults  */ 

#define FRM_DMUSTSELECT     0x00010000L /* dsdialog/dsmenu: no default exit */
#define FRM_DSHADOWED       0x00020000L /* dsdialog/dsmenu: shadowed parent */

#define FRM_DSL1TITLE       0x00100000L /* 1st line is title, higher y pos  */

#define FRM_MEXITPARENT     0x00100000L /* exit if mouse leaves parent      */
#define FRM_MEXITVICINITY   0x00200000L /* exit if mouse leaves vicinity    */

#define FRM_OPTIONBITS      0x0FFFFFFFL /* mask for dialog options          */
#define FRM_BOPTIONBITS     0x0000FFFFL /* mask for basic options           */
#define FRM_DOPTIONBITS     0x00FF0000L /* mask for dynamic options         */
#define FRM_UOPTIONBITS     0x0F000000L /* mask for user options            */
#define FRM_ACTIONBITS      0xF0000000L /* mask for dialog actions          */

/*-------------------------------------------------------------------------
 * option for fsl_dialog()...
 *-----------------------------------------------------------------------*/

#define FSL_NORMAL          0x0000
#define FSL_FNOPTIONAL      0x0001
#define FSL_PATHONLY        0x0002

/*-------------------------------------------------------------------------
 * options for grf_blit() and grf_memblit()...
 *-----------------------------------------------------------------------*/

#define GRF_NORMAL         0x0000  /* a placeholder value                */
#define GRF_BFROMSCREEN    0x1000  /* blit from screen to buffer         */
#define GRF_BTOSCREEN      0x2000  /* blit from buffer to screen         */
#define GRF_BMEMCALC       0x4000  /* calc mem requirements, don't blit  */
#define GRF_BOBJTREE       0x0001  /* rectparm OBJECT* instead of GRECT* */

/**************************************************************************
 * data structures and types...
 *************************************************************************/

/*-------------------------------------------------------------------------
 * FDB/MFDB structure (describes memory area for VDI blit)...
 *-----------------------------------------------------------------------*/

#ifndef FDADDR                  /* v1.3:  this define has been added to  */
  #define FDADDR void*          /* help provide compatibility between    */
#endif                          /* bindings systems.                     */

typedef struct fdbstr {
    FDADDR  fd_addr;
    int     fd_w;
    int     fd_h;
    int     fd_wdwidth;
    int     fd_stand;
    int     fd_nplanes;
    int     fd_r1;
    int     fd_r2;
    int     fd_r3;
    } FDB, MFDB;

/*-------------------------------------------------------------------------
 * MFORM structure (describes mouse cursor data)...
 *-----------------------------------------------------------------------*/

typedef struct mfstr {
    int mf_xhot;
    int mf_yhot;
    int mf_nplanes;
    int mf_fg;
    int mf_bg;
    int mf_mask[16];
    int mf_data[16];
    } MFORM ;

/*-------------------------------------------------------------------------
 * OBJECT structure...
 *-----------------------------------------------------------------------*/

typedef struct object {
    int             ob_next;        /* -> object's next sibling     */
    int             ob_head;        /* -> head of object's children */
    int             ob_tail;        /* -> tail of object's children */
    unsigned int    ob_type;        /* type of object               */
    unsigned int    ob_flags;       /* options                        */
    unsigned int    ob_state;       /* state                        */
    long            ob_spec;        /* whatever...                  */
    int             ob_x;           /* upper left corner of object  */
    int             ob_y;           /* upper left corner of object  */
    int             ob_width;       /* width of obj                 */
    int             ob_height;      /* height of obj                */
    } OBJECT;

/*-------------------------------------------------------------------------
 * GRECT structure (an AES-style rectangle, describes via width/height)...
 *-----------------------------------------------------------------------*/

typedef struct grect {
    int g_x;
    int g_y;
    int g_w;
    int g_h;
    } GRECT;

/*-------------------------------------------------------------------------
 * VRECT structure (a VDI-style rectangle, describes opposite corners)...
 *-----------------------------------------------------------------------*/

typedef struct vrect {
    int v_x1;
    int v_y1;
    int v_x2;
    int v_y2;
    } VRECT;

/*-------------------------------------------------------------------------
 * TEDINFO structure...
 *-----------------------------------------------------------------------*/

typedef struct text_edinfo {
    char *te_ptext;             /* ptr to text               */
    char *te_ptmplt;            /* ptr to template           */
    char *te_pvalid;            /* ptr to validation chrs.   */
    int  te_font;               /* font                      */
    int  te_junk1;              /* junk word                 */
    int  te_just;               /* justification             */
    int  te_color;              /* color information word    */
    int  te_junk2;              /* junk word                 */
    int  te_thickness;          /* border thickness          */
    int  te_txtlen;             /* length of text string     */
    int  te_tmplen;             /* length of template string */
    } TEDINFO;

/*-------------------------------------------------------------------------
 * ICONBLK structure...
 *-----------------------------------------------------------------------*/

typedef struct icon_block {
    int  *ib_pmask;
    int  *ib_pdata;
    char *ib_ptext;
    int  ib_char;
    int  ib_xchar;
    int  ib_ychar;
    int  ib_xicon;
    int  ib_yicon;
    int  ib_wicon;
    int  ib_hicon;
    int  ib_xtext;
    int  ib_ytext;
    int  ib_wtext;
    int  ib_htext;
    } ICONBLK;

/*-------------------------------------------------------------------------
 * BITBLK structure...
 *-----------------------------------------------------------------------*/

typedef struct bit_block {
    int  *bi_pdata;                 /* ptr to bit forms data  */
    int  bi_wb;                     /* width of form in bytes */
    int  bi_hl;                     /* height in lines        */
    int  bi_x;                      /* source x in bit form   */
    int  bi_y;                      /* source y in bit form   */
    int  bi_color;                  /* fg color of blt        */
    } BITBLK;

/*-------------------------------------------------------------------------
 * USERBLK/APPLBLK structure (defines a userdraw object)...
 *-----------------------------------------------------------------------*/

typedef struct user_blk {
    long (*ub_code)();  /* -> drawfunc, func should return 0             */
    long ub_parm;       /* anything  drawfunc/application wants to store */
    } USERBLK, APPLBLK;

#define appl_blk user_blk

/*-------------------------------------------------------------------------
 * XUSERBLK (our internal extension to a standard USERBLK)...
 *-----------------------------------------------------------------------*/

typedef struct xuser_blk {
    long            (*ub_code)(); /* the 1st two fields are USERBLK std, */
    struct xuser_blk *ub_self;    /* but ub_parm always points to self.  */
    void             *reserved;   /* this will be used in v1.9           */
    long              ub_size;    /* size of this XUSERBLK structure     */
    long              ob_spec;    /* ob_spec and ob_type are from the    */
    short             ob_type;    /* original object before we xformed   */
} XUSERBLK;

/*-------------------------------------------------------------------------
 * PARMBLK structure (passed to a userdraw func when drawing an object)...
 *-----------------------------------------------------------------------*/

typedef struct parm_blk {
    OBJECT  *pb_tree;
    int     pb_obj;
    int     pb_prevstate;
    int     pb_currstate;
    int     pb_x,  pb_y,  pb_w,  pb_h;
    int     pb_xc, pb_yc, pb_wc, pb_hc;
    long    pb_parm;
    } PARMBLK;

/*-------------------------------------------------------------------------
 * XPARMBLK structure (our renaming of a standard PARMBLK)...
 *-----------------------------------------------------------------------*/

typedef struct xparm_blk {
    OBJECT   *ptree;
    int       obj;
    int       prevstate;
    int       currstate;
    GRECT     drawrect;
    GRECT     cliprect;
    XUSERBLK *pub;
    } XPARMBLK;

/*-------------------------------------------------------------------------
 * RSHDR structure...
 *-----------------------------------------------------------------------*/

typedef struct rshdr {
        int             rsh_vrsn;       /* Resource structure version # */
        unsigned int    rsh_object;     /* Offset to first object       */
        unsigned int    rsh_tedinfo;    /* Offset to first tedinfo      */
        unsigned int    rsh_iconblk;    /* Offset to first iconblk      */
        unsigned int    rsh_bitblk;     /* Offset to first bitblk       */
        unsigned int    rsh_frstr;      /* Offset to free string index  */
        unsigned int    rsh_string;     /* Offset to string data        */
        unsigned int    rsh_imdata;     /* Offset to image data         */
        unsigned int    rsh_frimg;      /* Offset to free image index   */
        unsigned int    rsh_trindex;    /* Offset to tree index         */
        unsigned int    rsh_nobs;       /* Number of objects            */
        unsigned int    rsh_ntree;      /* Number object trees          */
        unsigned int    rsh_nted;       /* Number of tedinfo structs    */
        unsigned int    rsh_nib;        /* Number of iconblk structs    */
        unsigned int    rsh_nbb;        /* Number of bitblk structs     */
        unsigned int    rsh_nstring;    /* Number of free strings       */
        unsigned int    rsh_nimages;    /* Number of free images        */
        unsigned int    rsh_rssize;     /* total bytes in resource      */
    } RSHDR;

#define RSHDR_DEFINED 1 /* signal to other header files that RSHDR is done */

/*-------------------------------------------------------------------------
 * XMOUSE structure...
 *-----------------------------------------------------------------------*/

typedef struct xmouse {
    int retval;
    int bclicks;
    int mask;
    int state;
    int status;
    int mousex;
    int mousey;
    int mouseb;
    int keystate;
    } XMOUSE;

/*-------------------------------------------------------------------------
 * XMULTI structure...
 *-----------------------------------------------------------------------*/

typedef struct xmulti {
    int     msgbuf[8];
    int     mflags,
            mbclicks,
            mbmask,
            mbstate,
            mm1flags;
    GRECT   mm1rect;
    int     mm2flags;
    GRECT   mm2rect;
    int     mtlocount,
            mthicount;
    int     mwhich,
            mmox,
            mmoy,
            mmobutton,
            mmokstate,
            mkreturn,
            mbreturn;
} XMULTI;

/**************************************************************************
 * declarations for functions that return something other than an int...
 *************************************************************************/

extern void  *apl_malloc();
extern long   frm_defaults();
extern void  *grf_memblit();
extern long   grf_blit();
extern char **obj_ppstring();
extern GRECT *rc_gadjust();
extern VRECT *rc_vadjust();
extern void  *rc_copy();
extern GRECT *rc_vtog();
extern VRECT *rc_gtov();
extern GRECT *rc_union();
extern GRECT *rc_confine();
extern GRECT *rc_scale();

extern void  *frm_dovector();   /* these are under construction... */
extern void  *frm_init();       /* don't use them yet.             */

/**************************************************************************
 * declarations of all global vars defined by gemfast...
 *************************************************************************/

/*
 * these are valid after appl_init()
 */

extern void   *aespb[6];        /* the AES parmblk, an array of 6 ptrs    */
extern int     aescontrol[5];   /* the AES control structure, 5 ints      */
extern int     global[];        /* global[] is aliased by following names */
extern int     gl_apversion;    /* the AES version number                 */
extern int     gl_apcount;      /* max # of concurrent AES applications   */
extern int     gl_apid;         /* id of the current application          */
extern long    gl_apprivate;    /* anything the applicaton wants to store */
extern void   *gl_apptree;      /* pointer to array of object tree ptrs   */
extern long    gl_ap1resv;      /* old name for pointer to rsc data       */
extern RSHDR  *gl_aprshdr;      /* pointer to head of rsc data            */
extern int     gl_ap2resv[6];   /* unused entries in global array         */

/*
 * these are valid after apl_xinit()
 */

extern int     gl_grfhandle;   /* global physical VDI handle (graf_handle)*/
extern int     gl_wchar;       /* width of a character                    */
extern int     gl_hchar;       /* height of a character                   */
extern int     gl_wbox;        /* width of a boxchar                      */
extern int     gl_hbox;        /* height of a boxchar                     */
extern GRECT   gl_rwdesk;      /* coordinates of work area of the desktop */
extern GRECT   gl_rfscrn;      /* coordinates of the full screen          */

/*
 * these are valid after apl_vopen()
 */

extern int     gl_vwout[57];   /* work_out from v_opnvwk()                */
extern int     gl_vxout[57];   /* work_out from vq_extnd(,1,)             */

/**************************************************************************
 * automatically use extended binding routines....
 *   if you undo these macros, all the builtin utilities will break!
 *   the normal low-level bindings will still work, though.
 *************************************************************************/

#define appl_init   apl_xinit   /* extended init fills in new gl_ vars    */
#define appl_exit   apl_xexit   /* extended exit closes shared vdi, etc   */
#define wind_update wnd_update  /* stack-like wind_update routine         */
#define graf_mouse  grf_mouse   /* use save/restore mouse shape system    */
#define objc_xywh   obj_xywh    /* this one's just plain faster           */

#define menu_bar(a,b)   mnu_bar((a),(b),0L) /* popable menu system        */

/**************************************************************************
 * Name compatibility stuff.
 *
 *  02/29/92 - v1.8
 *              Added mapping of frm_dsdial to frm_dsdialog.
 *  05/26/90 - v1.4
 *              Added mapping of find_exttype to obj_xtfind.
 *  08/28/89 - v1.3
 *              In v1.3, a big push has been made to make a consistant
 *              naming standard for the AES utilities.  To avoid breaking
 *              a lot of existing code, the following block will direct
 *              the old names to the new routines.
 *************************************************************************/

#define objclg_adjust           rc_gadjust
#define objclv_adjust           rc_vadjust
#define objcl_calc              obj_clcalc

#define objrb_which(a,b)        obj_rbfind((a),(b),SELECTED)
#define obj_rbwhich(a,b)        obj_rbfind((a),(b),SELECTED)
#define objxrb_which            obj_rbfind

#define find_exttype            obj_xtfind

#define objst_change            obj_stchange
#define objfl_change            obj_flchange

#define graqon_mouse            gra_qonmouse
#define graqof_mouse            gra_qofmouse
#define graq_mstate             gra_qmstate

#define frm_dsdial(str,btn, options) frm_dsdialog((options)|FRM_DSL1TITLE,(btn),(str))
#define frm_sizes(tree, rect)      obj_clcalc((tree), ROOT, (rect), NULL)

#endif

/*  end of GEMFAST.H */

