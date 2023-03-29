/*****************************************************************************
 *
 * Module : MASKOBJ.H
 * Author : Jrgen Geiž
 *
 * Creation date    : 20.11.94
 * Last modification:
 *
 *
 * Description: This header defines the mask objects.
 *
 * History:
 * 18.01.04: MB_USERHELPST added
 * 13.03.97: Variable szFilename added to EDFIELD
 * 06.03.97: MB_ACCOUNT added
 * 03.11.95: MB_MULTIBUTTON, MBF_HIDDEN added
 * 16.08.95: MTF_* added
 * 08.05.95: SM_SHOW_3D added
 * 24.04.95: Variable db_adr added to MASK_SPEC
 * 21.04.95: Macro IS_EDITAABLE removed, implemented as function in mclick
 * 07.03.95: Variable pSubmask added to MASK_SPEC
 * 26.02.95: Variable any_dirty added to MASK_SPEC
 * 22.02.95: Variable has_submasks changed to num_submasks in MASK_SPEC
 * 12.02.95: Variable last_obj added to MASK_SPEC
 * 08.02.95: Variable sub added to EDFIELD
 * 01.02.95: Macro IS_EDITAABLE added
 * 27.01.95: Variable has_submasks added to MASK_SPEC
 * 26.01.95: Variable flags added to SUBMASK
 * 09.01.95: Variables index, frame added to SUBMASK
 * 15.12.94: Variable hsb added to SUBMASK
 * 12.12.94: Variable sel_obj added to SUBMASK
 * 08.12.94: Variable obj added to SUBMASK
 * 21.11.94: ADD_LINES moved from MASKUTIL.C, act_line added in SUBMASK
 * 20.11.94: Creation of body
 *****************************************************************************/

#ifndef __MASKOBJ__
#define __MASKOBJ__

/****** DEFINES **************************************************************/

#define M_NONE              0   /* mask object classes */
#define M_FIELD             1
#define M_LINE              2
#define M_BOX               3
#define M_RBOX              4
#define M_TEXT              5
#define M_GRAF              6
#define M_BUTTON            7
#define M_SUBMASK           8

#define MF_SYSTEMFONT  0x0001   /* mask field flags, SYSTEMFONT also used in text and button obj */
#define MF_UNUSED      0x0002
#define MF_STDLABEL    0x0004
#define MF_HSLIDER     0x0008
#define MF_VSLIDER     0x0010
#define MF_WORDBREAK   0x0020
#define MF_USEBOUNDS   0x0040
#define MF_NOCLEAR     0x0080   /* don't clear field after insert */
#define MF_UNITWH      0x0100   /* use width and height in units, not in chars */
#define MF_TRANSPARENT 0x0200   /* draw label with transparent writing modus */

#define MT_NEUTRAL          0   /* mask field types */
#define MT_OUTLINED         1
#define MT_UNDERLINED       2
#define MT_LCHECKBOX        3
#define MT_RCHECKBOX        4
#define MT_RADIOBUTTON      5
#define MT_POPUP            6

#define MB_INFO             0   /* mask button commands */
#define MB_SAVE             1
#define MB_INSERT           2
#define MB_UPDATE           3
#define MB_SEARCH           4
#define MB_DELETE           5
#define MB_CALC             6
#define MB_CLEAR            7
#define MB_PREV             8
#define MB_NEXT             9
#define MB_FIRST           10
#define MB_LAST            11
#define MB_IMPORT          12
#define MB_EXPORT          13
#define MB_OPEN            14
#define MB_FILENAME        15
#define MB_CHANGE          16
#define MB_JOIN_MASK       17   /* result as mask */
#define MB_JOIN_TABLE      18   /* result as table */
#define MB_JOIN_NEW        19   /* same as above but fill mask with keys */
#define MB_POPUP           20
#define MB_REPORT          21
#define MB_PRINT           22
#define MB_USERHELP        23
#define MB_WINFULL         24
#define MB_WINCLOSE        25
#define MB_QUERY_MASK      26
#define MB_QUERY_TABLE     27
#define MB_BATCH           28
#define MB_MULTIBUTTON     29
#define MB_ACCOUNT         30
/* [GS] 5.1d Start: */
#define MB_USERHELPST      31

#define MB_COMMANDS        32   /* number of mask button commands */
/* Ende; alt:
#define MB_COMMANDS        31   /* number of mask button commands */
*/

#define MTF_FLAGS      0x0001   /* mask text flags */
#define MTF_RIGHT      0x4000
#define MTF_CENTER     0x2000
#define MTF_INSIDE     0x1000
#define MTF_OUTSIDE    0x0800

#define MBF_SYSTEMFONT 0x0001   /* mask button flags */
#define MBF_SELECTED   0x0002
#define MBF_ROUNDED    0x0004
#define MBF_RECTANGLE  0x0008
#define MBF_HIDDEN     0x0010

#define ALT_CHAR        '~'     /* char for activating buttons with alt key in keyboard interface */

#define MSM_SYSTEMFONT 0x0001   /* mask submask flags, SYSTEMFONT also used in text and button obj */
#define MSM_SHOW_TABLE 0x0002   /* mask submask flags */
#define MSM_SHOW_MASK  0x0004   /* show submask as mask */

#define COL_HIDDEN     0x8000   /* set if columns has GRANT_NOTHING */

#define MG_DRAWFRAME   0x0001   /* mask grafics flags */

#define M_XUNITS            8   /* coordinates are stored in units of x * gl_wbox/8 */
#define M_YUNITS            8   /* coordinates are stored in units of y * gl_hbox/8 */

#define EDIT_FRAME          2   /* leave this amount of space around edit fields */

#define MASK_SCREEN        'S'  /* used for mask specification */
#define MASK_PRINTER       'P'
#define MASK_VERSION        1   /* version number of a mask created with this phoenix version */

#define MO_UNKNOWN          0   /* mask edit object messages */
#define MO_INIT             1
#define MO_EXIT             2
#define MO_CLEAR            3
#define MO_DRAW             4
#define MO_SHOWCURSOR       5
#define MO_HIDECURSOR       6
#define MO_KEY              7
#define MO_CLICK            8
#define MO_CUT              9
#define MO_COPY            10
#define MO_PASTE           11

#define MO_OK               0
#define MO_WRONGMESSAGE    -1
#define MO_GENERAL         -2
#define MO_BUFFERCHANGED   -3
#define MO_CHARNOTUSED     -4
#define MO_NOMEMORY        -5

#define PIC_INVALID      0x01   /* dynamic picture is invalid and must be initialized */

#define IS_EDOBJ(mfield)    ((mfield->type == MT_NEUTRAL)    || \
                             (mfield->type == MT_OUTLINED)   || \
                             (mfield->type == MT_UNDERLINED) || \
                             (mfield->type == MT_POPUP))

#define IS_CHECKBOX(mfield) ((mfield->type == MT_LCHECKBOX) || \
                             (mfield->type == MT_RCHECKBOX))

#define IS_RBUTTON(mfield)  (mfield->type == MT_RADIOBUTTON)

#define IS_BLOB(type)       ((type == TYPE_VARBYTE) || (type == TYPE_VARWORD) || (type == TYPE_VARLONG))

#define MAX_LUS            64   /* max number of concurrent lookups */
#define MAX_SUBMASKS        8   /* max number of submasks per mask */
#define MAX_ADR            64   /* max number of record adresses (lines in submask) to remember */

#define ADD_LINES           4   /* additional lines per record in submask, also see list.c */

#define BLOB_UNKNOWN        0   /* datatypes for blobs, unknown */
#define BLOB_SOUND          1   /* sampled sound */
#define BLOB_MIDI           2   /* midi data */

#define M_SET_NOTNULL       0   /* don't set fields in db_buffer to NULL */
#define M_SET_NULL          1   /* set fields in db_buffer to NULL */
#define M_USE_MFFLAG        2   /* use flag MF_NOCLEAR to determine setting of NULL */

#define SM_SHOW_ICONS  0x0001   /* flag in SYSMASK, show icon bar in mask window */
#define SM_SHOW_INFO   0x0002   /* flag in SYSMASK, show info line in mask window */
#define SM_SHOW_MENU   0x0004   /* flag in SYSMASK, show menu line in mask window */
#define SM_SHOW_3D     0x0008   /* flag in SYSMASK, show controls with 3d effect */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD  class;                  /* object class, must be first */
  WORD  x, y, w, h;             /* dimension must be second */
  WORD  table_name;             /* index into string table */
  WORD  field_name;
  WORD  label_name;
  WORD  font;
  WORD  point;
  WORD  color;
  LONG  lower;                  /* lower bound, if datatype is numeric */
  LONG  upper;                  /* upper bound, if datatype is numeric */
  WORD  type;                   /* see MT_... above */
  WORD  extra;                  /* extra space for misc purpose */
  UWORD flags;
} MFIELD;

typedef struct
{
  WORD class;                   /* object class, must be first */
  WORD x1, y1, x2, y2;          /* dimension must be second */
  WORD color;
  WORD type;
  WORD width;
  WORD bstyle;
  WORD estyle;
} MLINE;

typedef struct
{
  WORD class;                   /* object class, must be first */
  WORD x, y, w, h;              /* dimension must be second */
  WORD color;
  WORD style;                   /* hollow, solid, pattern hatch */
  WORD index;                   /* style index */
} MBOX;

typedef struct
{
  WORD  class;                  /* object class, must be first */
  WORD  x, y, w, h;             /* dimension must be second */
  WORD  text;                   /* index into string table */
  WORD  font;
  WORD  point;
  WORD  color;
  WORD  effects;
  WORD  wrmode;
  UWORD flags;
} MTEXT;

typedef struct
{
  WORD class;                   /* object class, must be first */
  WORD x, y, w, h;              /* dimension must be second */
  WORD filename;                /* index into string table */
  WORD type;                    /* graphics type see conv.h */
  WORD flags;
} MGRAF;

typedef struct
{
  WORD  class;                  /* object class, must be first */
  WORD  x, y, w, h;             /* dimension must be second */
  WORD  text;                   /* index into string table */
  WORD  param;                  /* index into string table */
  WORD  font;
  WORD  point;
  WORD  color;
  WORD  command;
  UWORD flags;
} MBUTTON;

typedef struct
{
  WORD  class;                  /* object class, must be first */
  WORD  x, y, w, h;             /* dimension must be second */
  WORD  SourceObject;           /* index into string table, must be mask name */
  WORD  LinkMaster;             /* index into string table, tablename.field name(s) of master tablename.field1;field2;...fieldn */
  WORD  LinkChild;              /* index into string table, tablename.field name(s) of child to link to */
  WORD  font;
  WORD  point;
  WORD  color;
  UWORD flags;			/* show submask as table or mask */
} MSUBMASK;

typedef union
{
  MFIELD   mfield;
  MLINE    mline;
  MBOX     mbox;
  MTEXT    mtext;
  MGRAF    mgraf;
  MBUTTON  mbutton;
  MSUBMASK msubmask;
} MOBJECT;

typedef struct
{
  WORD w_shadow;
  WORD h_shadow;
  WORD w_attr;
  WORD h_attr;
} FATTR;

typedef struct mask_spec *PMASK_SPEC;

typedef struct
{
  MFIELD   *mfield;
  WORD     obj;                 /* object number in mask buffer */
  WORD     sub;                 /* index to Submask in MASK_SPEC if edit field is a sub mask */
  WORD     table;               /* table number */
  WORD     field;               /* column number */
  WORD     lu_table;            /* lookup table number */
  WORD     lu_field;            /* lookup column number */
  WORD     type;                /* data type of field */
  WORD     pic;                 /* number of dynamic picture */
  FULLNAME szFilename;          /* file name if OLGA_LINK active */
  UWORD    flags;               /* flags of field */
} EDFIELD;

typedef struct
{
  WORD  obj;                    /* object number in mask buffer */
  UWORD alt_char;               /* char for keyboard interface */
} BUTTON;

typedef union
{
  GEMOBJ gem;                   /* for handling of gem metafiles */
  IMGOBJ img;                   /* for handling of bit images */
} PICS;

typedef struct
{
  WORD    type;                 /* picture type (see conv.h) */
  LONGSTR filename;             /* filename of picture */
  UWORD   flags;                /* flags PIC_DIRTY... */
  PICS    pic;                  /* picture descriptor */
} PICOBJ;

typedef struct
{
  WORD     obj;                 /* object number in mask buffer */
  CALCCODE code;                /* buffer for calc text & code */
} CALCOBJ;

typedef struct
{
  PMASK_SPEC pMaskSpec;         /* every submask gets its own mask spec */
  WORD       obj;               /* object number in mask buffer */
  WORD       index;             /* submask number in submask array */
  WORD       cols;              /* number of actual cols */
  WORD       *columns;          /* column order */
  WORD       *colwidth;         /* column width */
  LONGSTR    colheader;         /* column header */
  LRECT      doc;               /* document position in submask, doc.y holds number of records */
  LONG       recaddr [MAX_ADR]; /* max number of record adresses (lines in submask) to remember */
  LONG       act_rec;           /* actual record which was read by vread */
  WORD       xfac;              /* see windows.h */
  WORD       yfac;              /* see windows.h */
  WORD       xscroll;           /* see windows.h */
  WORD       yscroll;           /* see windows.h */
  WORD       sel_obj;           /* selected object only for double click */
  RECT       frame;             /* position on screen */
  HSB        hsb;		/* handle to scroll bar */
  UWORD      flags;		/* show submask as table or mask */
} SUBMASK;

typedef struct mask_spec
{
  WINDOWP    window;		/* mask window */
  DB         *db;		/* database */
  WORD       table;		/* table of database */
  WORD       inx;		/* actual index */
  WORD       dir;		/* actual direction */
  FIELDNAME  maskname;		/* name of mask */
  WORD       objs;		/* number of objects in mask */
  WORD       act_obj;		/* actual edit object number */
  WORD       act_sub;		/* actual submask index */
  WORD       last_obj;		/* last edit object number when entering a submask */
  EDOBJ      ed;		/* used for actual edit object */
  CBOBJ      cb;		/* used for actual check box */
  RBOBJ      rb;		/* used for actual radio button */
  EMPTYOBJ   eo;		/* used for actual pictures/blobs */
  WORD       edobjs;		/* number of editable objects */
  WORD       buttons;		/* number of button objects */
  WORD       spicobjs;		/* number of static pictures in mask */
  WORD       dpicobjs;		/* number of dynamic pictures in mask */
  WORD       calcobjs;		/* number of calculation buttons */
  LONGSTR    text;		/* text buffer for numeric edit objs */
  BOOLEAN    clear_buffered;	/* true if mask is buffered before clear command */
  BOOLEAN    buf_dirty;		/* buffer was changed */
  BOOLEAN    any_dirty;		/* set if mask or any submask has dirty data */
  BOOLEAN    asterisk;		/* show asterisk, if buffer dirty */
  BOOLEAN    modify;		/* true if record can be modified (multiuser only) */
  WORD       num_submasks;	/* number of submasks on this mask */
  USHORT     sm_flags;		/* flags of sysmask */
  LONG       db_adr;		/* database address after insert (for restoring record after undo) */
  SYSMASK    *mask;		/* pointer to mask record */
  EDFIELD    *ed_field;		/* all editable fields */
  BUTTON     *button;		/* all buttons objects */
  PICOBJ     *spicobj;		/* static pictures in mask */
  PICOBJ     *dpicobj;		/* dynamic pictures in mask */
  CALCOBJ    *calcobj;		/* calculation buttons in mask */
  CURSOR     *cursor;		/* cursor for access */
  VOID       *buffer;		/* table buffer */
  CALCCODE   *pCalcEntry;	/* buffer for calc entry code */
  CALCCODE   *pCalcExit;	/* buffer for calc exit code */
  PMASK_SPEC pParentSpec;	/* parent mask spec if submask else NULL */
  SUBMASK    Submask [MAX_SUBMASKS];	/* array for submasks in masks */
  SUBMASK    *pSubmask;		/* if pParentSpec != NULL points to actual submask */
} MASK_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

#endif /* __MASKOBJ__ */

