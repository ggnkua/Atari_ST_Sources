/* tab expansion/compression should be set to 4 */
/**************************************************************************
 *
 * GEMFAST.H - Header file for common VDI and AES symbols.  
 *
 *  This header file contains items compatible with both GEMDEFS and OBDEFS
 *  from the Alcyon system.  Note that there are no 'extern' definitions
 *  for the GEM functions, because they all return a signed int and work
 *  fine as autodefined functions.
 *
 *  If you have a lot of source already coded for #include <gemdefs.h>,
 *  you can create a dummy (empty) obdefs.h file, and code a new gemdefs.h
 *  file which contains only #include <gemfast.h>.  YOU CAN NO LONGER USE
 *  GEMDEFS AND OBDEFS WITH THE GEMFAST BINDINGS!  For the bindings libs
 *  to work correctly, this header file must be used.  
 *
 * Credits dept:
 *   This file bears an amazing similarity to the original Alcyon GEMDEFS
 *   and OBDEFS header files, which are copyrighted by Atari.  What can I
 *   say?  Copyrighted or not, these are the names and values that every-
 *   body uses, so OF COURSE the files look *awful* similar...
 *
 * Maintenance:
 *  12/03/89 - v1.3
 *             > Renamed a lot of functions, a name compatibility block was
 *               added at the end of this file to smooth the transition.
 *             > Added NO_OBJECT, MU_MENTRY, MU_MEXIT to defines.
 *             > Added XMULTI struct, even though it really belongs to v2.0
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
 *************************************************************************/

#ifndef GEMFAST_H               /* Prevent multiple inclusion */

#define GEMFAST_H       1       /* Tell the world GEMFAST header is used */
#define GEMF_VERSION    0x0160  /* Tell the world we are v1.60           */

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
                                    /* evnt_multi flags */
#define MU_KEYBD    0x0001
#define MU_BUTTON   0x0002
#define MU_M1       0x0004
#define MU_M2       0x0008
#define MU_MESAG    0x0010
#define MU_TIMER    0x0020
                                    /* evnt_mouse flags */
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
                                    /* wind_calc flags */
#define WC_BORDER   0
#define WC_WORK     1
                                    /* wind_get flags */
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
                                    /* wind_update flags */
#define END_UPDATE  0
#define BEG_UPDATE  1
#define END_MCTRL   2
#define BEG_MCTRL   3
                                    /* graf_mouse mouse types*/
#define ARROW       0
#define TEXT_CRSR   1
#define HOURGLASS   2               /* this name used by MWC (why?) */
#define BUSY_BEE    2
#define BEE         2
#define POINT_HAND  3
#define FLAT_HAND   4
#define THIN_CROSS  5
#define THICK_CROSS 6
#define OUTLN_CROSS 7
#define USER_DEF    255
#define M_OFF       256
#define M_ON        257
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
                                /* object flags */
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

                                /* VDI Memory Form Definition Block */
                             
#ifndef FDADDR                  /* v1.3:  this typedef has been added to */
typedef char *FDADDR;           /* help provide compatibility between    */
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
    } FDB;    

#define MFDB    FDB                 /* MFDB added for Laser compatibily */

                                    /* Mouse Form Definition Block */
typedef struct mfstr {
    int mf_xhot;
    int mf_yhot;
    int mf_nplanes;
    int mf_fg;
    int mf_bg;
    int mf_mask[16];
    int mf_data[16];
    } MFORM ;

typedef struct object {
    int             ob_next;        /* -> object's next sibling     */
    int             ob_head;        /* -> head of object's children */
    int             ob_tail;        /* -> tail of object's children */
    unsigned int    ob_type;        /* type of object               */
    unsigned int    ob_flags;       /* flags                        */
    unsigned int    ob_state;       /* state                        */
    long            ob_spec;        /* whatever...                  */
    int             ob_x;           /* upper left corner of object  */
    int             ob_y;           /* upper left corner of object  */
    int             ob_width;       /* width of obj                 */
    int             ob_height;      /* height of obj                */
    } OBJECT;

typedef struct grect {
    int g_x;
    int g_y;
    int g_w;
    int g_h;
    } GRECT;

typedef struct vrect {
    int v_x1;
    int v_y1;
    int v_x2;
    int v_y2;
    } VRECT;

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

typedef struct bit_block {
    int  *bi_pdata;                 /* ptr to bit forms data  */
    int  bi_wb;                     /* width of form in bytes */
    int  bi_hl;                     /* height in lines        */
    int  bi_x;                      /* source x in bit form   */
    int  bi_y;                      /* source y in bit form   */
    int  bi_color;                  /* fg color of blt        */
    } BITBLK;

typedef struct user_blk {
    long (*ub_code)();
    long ub_parm;
    } USERBLK;

#define appl_blk user_blk
#define APPLBLK  USERBLK

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
 *
 * Name compatibility stuff.
 *
 *  05/26/90 - v1.4
 *              Added mapping of find_exttype to obj_xtfind.
 *  08/28/89 - v1.3
 *              In v1.3, a big push has been made to make a consistant
 *              naming standard for the AES utilities.  To avoid breaking
 *              a lot of existing code, the following block will direct
 *              the old names to the new routines.
 *
 *************************************************************************/

#define objclg_adjust           rc_gadjust
#define objclv_adjust           rc_vadjust

#define objrb_which(a,b)        obj_rbfind((a),(b),SELECTED)
#define obj_rbwhich(a,b)        obj_rbfind((a),(b),SELECTED)
#define objxrb_which            obj_rbfind

#define objc_xywh               obj_xywh

#define find_exttype            obj_xtfind

#define objst_change            obj_stchange
#define objfl_change            obj_flchange

#define graqon_mouse            gra_qonmouse
#define graqof_mouse            gra_qofmouse
#define graq_mstate             gra_qmstate

#endif

/*  end of GEMFAST.H */

