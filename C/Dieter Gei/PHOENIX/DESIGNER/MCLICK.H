/*****************************************************************************
 *
 * Module : MCLICK.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 
 *
 *
 * Description: This module defines the clicking inside a mask window.
 *
 * History:
 * 18.01.04: MB_USERHELPST added
 * 16.03.97: GetPicFilename added
 * 10.03.97: m_updpicfile added
 * 06.03.97: MB_ACCOUNT added
 * 25.10.95: MB_MULTIBUTTON, MBF_HIDDEN added
 * 16.08.95: MTF_* added
 * 23.09.94: MSM_SYSTEMFONT added
 * 20.09.94: Definitions for sub masks (MSUBMASK) added
 * 14.04.94: MF_TRANSPARENT added
 * 10.11.93: Variable fontspec used in interface to set_objfont
 * 23.10.93: IndexFromColor32 & Color32FromIndex added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MCLICK__
#define __MCLICK__

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
#define MB_MBFIRST         10
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

#define MSM_SYSTEMFONT 0x0001   /* mask submask flags, SYSTEMFONT also used in text and button obj */
#define MSM_SHOW_TABLE 0x0002   /* mask submask flags */
#define MSM_SHOW_MASK  0x0004   /* show submask as mask */

#define MG_DRAWFRAME   0x0001   /* mask grafics flags */

#define M_XUNITS            8   /* coordinates are stored in units of x * gl_wbox/8 */
#define M_YUNITS            8   /* coordinates are stored in units of y * gl_hbox/8 */

#define EDIT_FRAME          2   /* leave this amount of space around edit fields */

#define IS_EDOBJ(type)      ((type == MT_NEUTRAL)    || \
                             (type == MT_OUTLINED)   || \
                             (type == MT_UNDERLINED) || \
                             (type == MT_POPUP))

#define IS_CHECKBOX(type)   ((type == MT_LCHECKBOX) || \
                             (type == MT_RCHECKBOX))

#define IS_RBUTTON(type)    (type == MT_RADIOBUTTON)

#define IS_BLOB(type)       ((type == TYPE_VARBYTE) || (type == TYPE_VARWORD) || (type == TYPE_VARLONG))
#define IS_PICTURE(type)    (type == TYPE_PICTURE)

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
  WORD  type;
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

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID  m_click          _((WINDOWP window, MKINFO *mk));
GLOBAL VOID  m_unclick        _((WINDOWP window));
GLOBAL WORD  m_get_rect       _((WINDOWP window, WORD out_handle, WORD class, MOBJECT *mobject, RECT *rect, FATTR *fattr));
GLOBAL VOID  m_get_doc        _((WINDOWP window, LONG *docw, LONG *doch));
GLOBAL VOID  m_obj_clear      _((WINDOWP window, WORD class, SET objs));
GLOBAL VOID  m_snap_obj       _((MASK_SPEC *mask_spec, MOBJECT *mobject, WORD grid_x, WORD grid_y));
GLOBAL WORD  m_addfield       _((WINDOWP window, BASE_SPEC *base_spec, WORD table, WORD field, RECT *r));
GLOBAL WORD  m_name2picobj    _((MASK_SPEC *mask_spec, BYTE *filename));
GLOBAL VOID  m_updpicfile     _((MASK_SPEC *mask_spec, WORD picobj));

GLOBAL VOID  obj2pos          _((MASK_SPEC *mask_spec, WORD obj, RECT *r));
GLOBAL VOID  pos2obj          _((MASK_SPEC *mask_spec, WORD obj, RECT *r));
GLOBAL VOID  set_objfont      _((WINDOWP window, FONTDESC *fontdesc));
GLOBAL VOID  set_objfill      _((WINDOWP window, WORD style, WORD index));
GLOBAL VOID  set_objcolor     _((WINDOWP window, WORD color));
GLOBAL VOID  set_objline      _((WINDOWP window, WORD type, WORD width, WORD bstyle, WORD estyle));
GLOBAL WORD  add_str          _((MASK_SPEC *mask_spec, BYTE *s));
GLOBAL VOID  del_str          _((MASK_SPEC *mask_spec, WORD index));
GLOBAL VOID  add_picture      _((MASK_SPEC *mask_spec, MGRAF *mgraf, BYTE *filename));
GLOBAL WORD  add_mobject      _((MASK_SPEC *mask_spec, MOBJECT *mobject, BYTE *s1, BYTE *s2, BYTE *s3, BYTE *s4, WORD *obj));
GLOBAL VOID  del_mobject      _((MASK_SPEC *mask_spec, WORD obj));
GLOBAL VOID  GetPicFilename   _((MASK_SPEC *mask_spec, BYTE *pPicFilename, BYTE *pFilename));
GLOBAL SHORT IndexFromColor32 _((LONG lColor));
GLOBAL LONG  Color32FromIndex _((SHORT sIndex));
#endif /* __MCLICK__ */

