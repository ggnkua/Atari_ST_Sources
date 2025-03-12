/************************************************************************/
/*   OBDEFS.H: Common OBJECT definitions and structures.                */
/************************************************************************/

#ifndef __OBDEFS__
#define __OBDEFS__

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

#define MD_REPLACE       1 /* gsx modes */
#define MD_TRANS         2
#define MD_XOR           3
#define MD_ERASE         4

#define FIS_HOLLOW       0 /* gsx styles */
#define FIS_SOLID        1
#define FIS_PATTERN      2
#define FIS_HATCH        3
#define FIS_USER         4

#define ALL_WHITE        0 /* bit blt rules */
#define S_AND_D          1
#define S_AND_NOTD       2
#define S_ONLY           3
#define NOTS_AND_D       4
#define D_ONLY           5
#define S_XOR_D          6
#define S_OR_D           7
#define NOT_SORD         8
#define NOT_SXORD        9
#define D_INVERT        10
#define S_OR_NOTD       11
#define NOT_D           12
#define NOTS_OR_D       13
#define NOT_SANDD       14
#define ALL_BLACK       15

#define SOLID            1 /* line types */
#define LONGDASH         2
#define DOT              3
#define DASHDOT          4
#define DASH             5
#define DASH2DOT         6
#define USERLINE         7

#define SQUARED          0 /* line ends */
#define ARROWED          1
#define ROUNDED          2

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

#define EDSTART          0 /* editable text field definitions */
#define EDINIT           1
#define EDCHAR           2
#define EDEND            3

#define TE_LEFT          0 /* editable text justification */
#define TE_RIGHT         1
#define TE_CNTR          2

/*************************/
/* Structure Definitions */
/*************************/

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

typedef struct object
{
  WORD  ob_next;   /* -> object's next sibling       */
  WORD  ob_head;   /* -> head of object's children   */
  WORD  ob_tail;   /* -> tail of object's children   */
  UWORD ob_type;   /* type of object- BOX, CHAR, ... */
  UWORD ob_flags;  /* flags                          */
  UWORD ob_state;  /* state- SELECTED, CROSSED, ...  */
  LONG  ob_spec;   /* "out"- -> anything else        */
  WORD  ob_x;      /* upper left corner of object    */
  WORD  ob_y;      /* upper left corner of object    */
  WORD  ob_width;  /* width of object                */
  WORD  ob_height; /* height of object               */
} OBJECT;

typedef struct text_edinfo
{
  BYTE FAR *te_ptext;   /* ptr to text (must be 1st)     */
  BYTE FAR *te_ptmplt;  /* ptr to template               */
  BYTE FAR *te_pvalid;  /* ptr to validation chrs.       */
  WORD te_font;         /* font                          */
  WORD te_junk1;        /* junk word                     */
  WORD te_just;         /* justification- left, right... */
  WORD te_color;        /* color information word        */
  WORD te_junk2;        /* junk word                     */
  WORD te_thickness;    /* border thickness              */
  WORD te_txtlen;       /* length of text string         */
  WORD te_tmplen;       /* length of template string     */
} TEDINFO;

typedef struct icon_block
{
  WORD FAR *ib_pmask;   /* ptr to mask of icon                */
  WORD FAR *ib_pdata;   /* ptr to data of icon                */
  BYTE FAR *ib_ptext;   /* ptr to text of icon                */
  WORD ib_char;         /* character in icon                  */
  WORD ib_xchar;        /* x-coordinate of ib_char            */
  WORD ib_ychar;        /* y-coordinate of ib_char            */
  WORD ib_xicon;        /* x-coordinate of icon               */
  WORD ib_yicon;        /* y-coordinate of icon               */
  WORD ib_wicon;        /* width of icon in pixels            */
  WORD ib_hicon;        /* height of icon in pixels           */
  WORD ib_xtext;        /* x-coordinate of the icon's text    */
  WORD ib_ytext;        /* y-coordinate of the icon's text    */
  WORD ib_wtext;        /* width of rectangle for icon's text */
  WORD ib_htext;        /* height of icon's text in pixels    */
} ICONBLK;

typedef struct bit_block
{
  WORD FAR *bi_pdata;   /* ptr to bit forms data  */
  WORD bi_wb;           /* width of form in bytes */
  WORD bi_hl;           /* height in scan lines   */
  WORD bi_x;            /* source x in bit form   */
  WORD bi_y;            /* source y in bit form   */
  WORD bi_color;        /* fg color of blt        */
} BITBLK;

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

typedef struct user_blk
{
#if MSDOS
  WORD (FAR *ub_code) ();                     /* pointer to drawing function */
#else
  WORD (FAR *ub_code) _((PARMBLK *pb));       /* pointer to drawing function */
#endif
  LONG ub_parm;                               /* parm for drawing function   */
} USERBLK;

typedef struct appl_blk /* for compatibility */
{
#if MSDOS
  WORD (FAR *ab_code) ();                     /* pointer to drawing function */
#else
  WORD (FAR *ab_code) _((PARMBLK *pb));       /* pointer to drawing function */
#endif
  LONG ab_parm;                               /* parm for drawing function   */
} APPLBLK;

#endif /* __OBDEFS__ */
