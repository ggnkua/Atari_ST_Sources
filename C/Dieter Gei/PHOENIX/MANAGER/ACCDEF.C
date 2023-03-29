/*****************************************************************************
 *
 * Module : ACCDEF.C
 * Author : Dieter Geiž
 *
 * Creation date    : 08.07.95
 * Last modification: 08.04.97
 *
 *
 * Description: This module implements the account definition window.
 *
 * History:
 * 08.04.97: Version increased to 1.4
 * 03.03.97: Help message is forwarded to open property window
 * 02.03.97: Objects can be copied using a shift key
 * 28.02.97: Graphics icon disabled
 * 25.02.97: Components pLinkOrder and szPrinter added
 * 24.02.97: Page header and footer don't have "new page" property
 * 23.02.97: Subaccounts are being shown in property window
 * 16.02.97: Loading and saving of accounts moved to accobj.c
 * 15.02.97: Link master and child swapped
 * 09.01.97: Bugs with selected objects in AccDefFlipAccHeader and AccDefFlipPageHeader fixed
 * 01.01.97: AccDefPrint added
 * 27.12.96: Version increased to 1.0, reading of version 1.0 added
 * 26.12.96: Whole width of windows is being redrawn if background color of region has been changed
 * 23.12.96: 75% zoom possibility added
 * 18.12.96: Page header/footer and account header/footer swapped
 * 30.10.96: Account name is set in MemAccFromSysAcc
 * 21.10.96: Details region uses REGION_CAN_GROW as default
 * 20.10.96: Functions AccDefExec and AccDefExecute improved
 * 02.12.95: Functions DragLine, SizeBox, and DrawHandles moved to WINDOWS.C
 * 27.11.95: Region properties added
 * 25.11.95: Account properties added
 * 23.11.95: Ellipsis button functionality added
 * 13.11.95: Changing of properties of objects possible
 * 28.10.95: Receiving new value from property window
 * 23.10.95: Initialiting property window when sel_objs changed
 * 15.10.95: Call to PropertyOpen added
 * 10.10.95: AccDefToForeground and AccDefToBackground added
 * 08.07.95: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accobj.h"
#include "account.h"
#include "commdlg.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "editobj.h"
#include "list.h"
#include "printer.h"
#include "property.h"
#include "resource.h"
#include "select.h"
#include "trash.h"

#include "export.h"
#include "accdef.h"

/****** DEFINES **************************************************************/

#define KIND		(NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS		(WI_MOUSE|WI_CURSKEYS)
#define DOCW		300		/* 300 mm */
#define DOCH		600		/* 600 mm */
#define XFAC		4		/* X-Faktor */
#define YFAC		4		/* Y-Faktor */
#define XUNITS		10		/* X-Einheiten fr Scrolling */
#define YUNITS		10		/* Y-Einheiten fr Scrolling */
#define XSCROLL		((24 + XFAC - 1) / XFAC * XFAC)	/* Nicht-Scrollbarer linker Bereich */
#define YSCROLL		((24 + YFAC - 1) / YFAC * YFAC)	/* Nicht-Scrollbarer oberer Bereich */
#define INITX		(20 * gl_wbox)  /* X-Anfangsposition */
#define INITY		( 5 * gl_hbox + 7) /* Y-Anfangsposition */
#define INITW		(58 * gl_wbox)  /* Anfangsbreite in Pixel */
#define INITH		(22 * gl_hbox)  /* Anfangsh”he in Pixel */
#define MILLI		0               /* Millisekunden fr Zeitablauf */

#define ACCOUNT_VERSION	"PhoenixGraphicalReport 1.4"

#define UNITS_FROM_PIXELS(pixels, fac)	(LONG)((pixels) * 1000L / 10L / (fac))
#define PIXELS_FROM_UNITS(units, fac)	(SHORT)((units) * 10L * (fac) / 1000L)

#define VISIBLE		8		/* number of visible items in popup */

#define RASTER_X	100		/* default x raster */
#define RASTER_Y	100		/* default y raster */
#define A4_WIDTH	21000L		/* width of an A4 page in 1/1000 cm */
#define A4_HEIGHT	29700L		/* height of an A4 page in 1/1000 cm */
#define HEADER_HEIGHT	1000L		/* default width of an account or page header or footer */
#define DETAIL_HEIGHT	4000L		/* default detail height in 1/1000 cm */
#define MARGIN_LEFT	1500L		/* default left margin */
#define MARGIN_RIGHT	1500L		/* default right margin */
#define MARGIN_TOP	1500L		/* default top margin */
#define MARGIN_BOTTOM	1500L		/* default bottom margin */

#define RULER_MM	3		/* for mm */
#define RULER_5MM	6		/* for 1/2 cm */
#define RULER_CM	12		/* for cm */

#define LEFT_OFFSET	500		/* label is 0.5 cm left of column */

#define GROUPSEPHEIGHT	((gl_hbox + 4 + YFAC - 1) / YFAC * YFAC)	/* group separator height */

#define DRAW_OBJECT	0x0001		/* draw the object */
#define DRAW_HANDLES	0x0002		/* draw the handles of object */

enum OPERATIONS
{
  OP_NONE,				/* no operation */
  OP_SIZE_ACCOUNT,			/* account has been resized */
  OP_SIZE_REGION,			/* region has been resized */
  OP_MOVE_OBJECTS,			/* objects has been moved */
  OP_SIZE_OBJECT			/* object has been resized */
}; /* OPERATIONS */

enum SHOWPROP_MODE
{
  SP_OBJECTS,				/* init acount objects */
  SP_ACCOUNT,				/* init account itself */
  SP_REGION				/* init an account region */
}; /* INITPROP_MESSAGES */

/****** TYPES ****************************************************************/

typedef struct
{
  SHORT sProperty;			/* the property value */
  CHAR  *pszValue;			/* the actual property value of all selected objects */
  CHAR  *pszFormat;			/* the actual used format */
} PROPDESC;

typedef struct
{
  DB         *db;			/* database */
  SHORT      sTable;			/* number of table or table of query */
  SHORT      sTableSort;		/* the table to sort the columns for */
  ACCOUNT    account;			/* the account definition */
  LONG       lColInx;			/* column index */
  LONG       lNumCols;			/* number of columns */
  SHORT      *pColumns;			/* column numbers */
  BOOL       bDirty;			/* buffer changed */
  SHORT      sIconHeight;		/* height of icon bar */
  SHORT      sMode;			/* mode */
  BOOL       bLock;			/* lock mode */
  LONG       lFontScaleFactor;		/* font scaling factor in 1/1000 (for wysiwyg) */
  LONG       lZoomInx;			/* index of zoom factor */
  INT        iOperation;		/* last operation */
  LONG       lOldSize;			/* original size */
  RECT       rcDiff;			/* difference to original size/position */
  SHORT      sNumRegions;		/* number of active regions */
  ACC_REGION *pRegions [ACC_MAX_GROUPS + 5];	/* all active regions (5 = account header/footer, page header/footer, details) */
  SHORT      sPropDescMode;		/* mode of shown properties */
  ACC_REGION *pRegionProp;		/* region of shown properties */
  SHORT      sNumPropDesc;		/* number of property descriptions */
  PROPDESC   *pPropDesc;		/* description of properties shown in property window */
} ACCOUNT_SPEC;

/****** VARIABLES ************************************************************/

LOCAL ACCOUNT_SPEC *pSort;		/* for sorting columns */
LOCAL CHAR         *apszZoomStr [] = {" 25%", " 50%", " 75%", "100%", "200%", "250%", "500%"};

SHORT asPropertyName [] =		/* the property names */
{
  ACCOUNT_PROP_CLASS,
  ACCOUNT_PROP_FLAGS,
  ACCOUNT_PROP_TEXT,
  ACCOUNT_PROP_COLUMN,
  ACCOUNT_PROP_TABLE,
  ACCOUNT_PROP_FORMAT,
  ACCOUNT_PROP_VALUE,
  ACCOUNT_PROP_FILENAME,
  ACCOUNT_PROP_ACCOUNTNAME,
  ACCOUNT_PROP_LINK_MASTER_FIELDS,
  ACCOUNT_PROP_LINK_CHILD_FIELDS,
  ACCOUNT_PROP_LINK_CONDITION,
  ACCOUNT_PROP_LINK_ORDER,
  ACCOUNT_PROP_SUM,
  ACCOUNT_PROP_X,
  ACCOUNT_PROP_Y,
  ACCOUNT_PROP_W,
  ACCOUNT_PROP_H,
  ACCOUNT_PROP_BK_MODE,
  ACCOUNT_PROP_BK_COLOR,
  ACCOUNT_PROP_EFFECT,
  ACCOUNT_PROP_BORDER_MODE,
  ACCOUNT_PROP_BORDER_COLOR,
  ACCOUNT_PROP_BORDER_WIDTH,
  ACCOUNT_PROP_BORDER_STYLE,
  ACCOUNT_PROP_FONT_FACENAME,
  ACCOUNT_PROP_FONT_FONT,
  ACCOUNT_PROP_FONT_POINT,
  ACCOUNT_PROP_FONT_COLOR,
  ACCOUNT_PROP_FONT_BOLD,
  ACCOUNT_PROP_FONT_ITALIC,
  ACCOUNT_PROP_FONT_UNDERLINED,
  ACCOUNT_PROP_FONT_OUTLINED,
  ACCOUNT_PROP_FONT_LIGHT,
  ACCOUNT_PROP_HORZ_ALIGNMENT,
  ACCOUNT_PROP_VERT_ALIGNMENT,
  ACCOUNT_PROP_ROTATION,
  ACCOUNT_PROP_IS_VISIBLE,
  ACCOUNT_PROP_IS_SELECTED,
  ACCOUNT_PROP_CAN_GROW,
  ACCOUNT_PROP_CAN_SHRINK,
  ACCOUNT_PROP_HIDE_DUPLICATES,
  ACCOUNT_PROP_ACC_TABLE_OR_QUERY,
  ACCOUNT_PROP_ACC_IS_TABLE,
  ACCOUNT_PROP_ACC_PAGEHEADER,
  ACCOUNT_PROP_ACC_PAGEFOOTER,
  ACCOUNT_PROP_ACC_RASTER_X,
  ACCOUNT_PROP_ACC_RASTER_Y,
  ACCOUNT_PROP_ACC_WIDTH,
  ACCOUNT_PROP_ACC_MARGIN_LEFT,
  ACCOUNT_PROP_ACC_MARGIN_RIGHT,
  ACCOUNT_PROP_ACC_MARGIN_TOP,
  ACCOUNT_PROP_ACC_MARGIN_BOTTOM,
  ACCOUNT_PROP_ACC_NUM_COLUMNS,
  ACCOUNT_PROP_ACC_COLUMN_GAP,
  ACCOUNT_PROP_ACC_PRINTER,
  ACCOUNT_PROP_ACC_PAGE_FORMAT,
  ACCOUNT_PROP_ACC_PAGE_ORIENTATION,
  ACCOUNT_PROP_REG_NEW_PAGE,
  ACCOUNT_PROP_REG_HEIGHT,
  ACCOUNT_PROP_REG_BK_COLOR,
  ACCOUNT_PROP_REG_VISIBLE,
  ACCOUNT_PROP_REG_KEEP_TOGETHER,
  ACCOUNT_PROP_REG_CAN_GROW,
  ACCOUNT_PROP_REG_CAN_SHRINK
};

/****** FUNCTIONS ************************************************************/

LOCAL VOID  WindowUpdateMenu   (WINDOWP window);
LOCAL VOID  WindowHandleMenu   (WINDOWP window, WORD title, WORD item);
LOCAL BOOL  WindowTest         (WINDOWP window, WORD action);
LOCAL VOID  WindowOpen         (WINDOWP window);
LOCAL VOID  WindowClose        (WINDOWP window);
LOCAL VOID  WindowDelete       (WINDOWP window);
LOCAL VOID  WindowDraw         (WINDOWP window);
LOCAL VOID  WindowArrow        (WINDOWP window, WORD dir, LONG oldpos, LONG newpos);
LOCAL VOID  WindowSnap         (WINDOWP window, RECT *new, WORD mode);
LOCAL VOID  WindowObjOp        (WINDOWP window, SET objs, WORD action);
LOCAL WORD  WindowDrag         (WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj);
LOCAL VOID  WindowClick        (WINDOWP window, MKINFO *mk);
LOCAL VOID  WindowUnclick      (WINDOWP window);
LOCAL BOOL  WindowKey          (WINDOWP window, MKINFO *mk);
LOCAL VOID  WindowTimer        (WINDOWP window);
LOCAL VOID  WindowTop          (WINDOWP window);
LOCAL VOID  WindowUntop        (WINDOWP window);
LOCAL VOID  WindowEdit         (WINDOWP window, WORD action);

LOCAL VOID  FixIconBar         (WINDOWP window);
LOCAL VOID  SetDirty           (WINDOWP window, BOOL bDirty, BOOL bUpdateProperties);
LOCAL LONG  ColumnCallback     (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL LONG  ZoomCallback       (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL VOID  HandlePopup        (WINDOWP window, MKINFO *mk, SHORT obj);
LOCAL VOID  *GetSysRec         (WINDOWP window, SHORT sTable, LONG lSize, DB **db);
LOCAL VOID  ObjOp              (WINDOWP window, SET objs, WORD action, WINDOWP actwin);
LOCAL VOID  FreeRegion         (ACC_REGION *pRegion);
LOCAL VOID  FreePropDesc       (ACCOUNT_SPEC *pAccSpec);
LOCAL VOID  FreeAccountSpec    (ACCOUNT_SPEC *pAccSpec);
LOCAL SHORT FillNumRegions     (ACCOUNT_SPEC *pAccSpec);
LOCAL VOID  SortTables         (ACCOUNT_SPEC *pAccSpec, SHORT *pTables, SHORT sTables);
LOCAL INT   CompareTables      (SHORT *arg1, SHORT *arg2);
LOCAL VOID  SortColumns        (ACCOUNT_SPEC *pAccSpec, SHORT *pColumns, SHORT sColumns, SHORT sTable);
LOCAL INT   CompareColumns     (SHORT *arg1, SHORT *arg2);
LOCAL VOID  SortCols           (ACCOUNT_SPEC *pAccSpec);
LOCAL INT   CompareCols        (SHORT *arg1, SHORT *arg2);
LOCAL LONG  CalcRegionsHeight  (ACCOUNT *pAccount);
LOCAL VOID  SetAccountDefault  (ACCOUNT *pAccount);
LOCAL VOID  SetRegionDefault   (ACC_REGION *pRegion, BOOL bIsPageHeaderFooter, LONG lHeight);
LOCAL VOID  SetGroupDefault    (ACC_GROUP *pGroup, CHAR *pszColumn, SHORT sDir);
LOCAL VOID  SetObjectDefault   (ACC_OBJECT *pObject, SHORT sClass, CHAR *pText, CHAR *pTable, CHAR *pColumn);

LOCAL BOOL  SysAccFromMemAcc   (DB *db, SYSACCOUNT *pSysAccount, ACCOUNT *pAccount, BOOL bUpdate);
LOCAL BOOL  MemAccFromSysAcc   (DB *db, ACCOUNT *pAccount, SYSACCOUNT *pSysAccount);

LOCAL VOID  FillRect           (WINDOWP window, RECT rc, SHORT color);
LOCAL VOID  DrawHorzRuler      (WINDOWP window, RECT rc, SHORT x_offset);
LOCAL VOID  DrawVertRuler      (WINDOWP window, RECT rc, SHORT y_offset);
LOCAL VOID  Draw3DRect         (WINDOWP window, RECT rc);
LOCAL VOID  Draw3DLines        (WINDOWP window, RECT rc, BOOL horz, BOOL top_black);
LOCAL VOID  DrawHorzLines      (WINDOWP window, RECT rc, SHORT y_offset, SHORT sBkColor);
LOCAL VOID  DrawVertLines      (WINDOWP window, RECT rc, SHORT x_offset, SHORT sBkColor);
LOCAL VOID  DrawGroupSep       (WINDOWP window, RECT rc, CHAR *pText, BOOL top_black);
LOCAL SHORT DrawRegion         (WINDOWP window, ACC_REGION *pRegion, CHAR *pRegionName, SHORT y, BOOL bFirstRegion, BOOL bLastRegion);
LOCAL VOID  DrawObjects        (WINDOWP window, ACC_REGION *pRegion, SHORT sMode);
LOCAL VOID  DrawObject         (WINDOWP window, ACC_OBJECT *pObject, SHORT sBkColor, RECT rcRegion, SHORT sMode);

LOCAL BOOL  InAccountSizer     (WINDOWP window, MKINFO *mk);
LOCAL BOOL  InRegionSizer      (WINDOWP window, MKINFO *mk, SHORT *pStartY, ACC_REGION **ppRegion);
LOCAL SHORT ObjectFromPoint    (WINDOWP window, SHORT x, SHORT y, ACC_OBJECT **pObject);
LOCAL SHORT HandleFromPoint    (WINDOWP window, SHORT x, SHORT y, SHORT *psHandleObj);
LOCAL BOOL  RegionFromPoint    (WINDOWP window, SHORT x, SHORT y, BOOL bInclGroupSep, ACC_REGION **ppRegion);

LOCAL VOID  DragAccountSizer   (WINDOWP window, SHORT x);
LOCAL VOID  DragRegionSizer    (WINDOWP window, SHORT x, SHORT y, ACC_REGION *pRegion);
LOCAL VOID  DragObjects        (WINDOWP window, SHORT obj, SET objs, ACC_REGION *pRegion);
LOCAL VOID  SizeObject         (WINDOWP window, SHORT sHandleObj, SHORT sHandlePos, ACC_REGION *pRegion);

LOCAL VOID  DragFunc           (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p);
LOCAL VOID  SizeFunc           (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p);
LOCAL BOOL  FixAccountWidth    (ACCOUNT_SPEC *pAccSpec);
LOCAL BOOL  FixRegionHeight    (ACC_REGION *pRegion);

LOCAL VOID  SetSelObjs         (WINDOWP window);
LOCAL VOID  CalcSelObjs        (WINDOWP window, SET objs, CONST RECT *rc);
LOCAL VOID  InvertObjs         (WINDOWP window, SET objs, BOOL bSetFlag);
LOCAL VOID  RubberBand         (WINDOWP window, ACC_REGION *pRegion, MKINFO *mk, RECT *rc, SHORT sClass);
LOCAL VOID  GetRegionRect      (WINDOWP window, ACC_REGION *pRegion, RECT *rc);
LOCAL VOID  GetObjectRect      (WINDOWP window, ACC_REGION *pRegion, SHORT obj, RECT *rc);
LOCAL BOOL  FixSize            (WINDOWP window, ACC_REGION *pRegion, ACC_OBJECT *pObject);

LOCAL BOOL  NewObject          (WINDOWP window, ACC_REGION *pRegion, SHORT sClass, RECT rc, CHAR *pText, CHAR *pTable, CHAR *pColumn, BOOL bDraw);
LOCAL BOOL  AddObject          (WINDOWP window, ACC_REGION *pRegion, ACC_OBJECT *pObject, BOOL bDraw);
LOCAL BOOL  DelObject          (WINDOWP window, ACC_REGION *pRegion, SHORT sObj, BOOL bDraw, BOOL bFree);
LOCAL VOID  MoveObjects        (WINDOWP src_window, WINDOWP dst_window, ACC_REGION *pRegionSrc, ACC_REGION *pRegionDst, SET objs, SHORT w, SHORT h);
LOCAL VOID  FreeObject         (ACC_OBJECT *pObject);

LOCAL BOOL  GetPropertyName    (SHORT sProperty, CHAR *pName);
LOCAL BOOL  UpdateProperties   (WINDOWP window, BOOL bTopIt, ACC_REGION *pRegion);
LOCAL BOOL  InitProperties     (WINDOWP window, SHORT sMode, ACC_REGION *pRegion);
LOCAL VOID  SetPropertyWindow  (WINDOWP window, WINDOWP pPropWnd);
LOCAL LONG  ObjPropFunc        (INT msg, WINDOWP window, LONG item, CHAR *p);
LOCAL LONG  AccPropFunc        (INT msg, WINDOWP window, LONG item, CHAR *p);
LOCAL LONG  RegPropFunc        (INT msg, WINDOWP window, LONG item, CHAR *p);
LOCAL BOOL  TableNameFromQuery (ACCOUNT_SPEC *pAccSpec, CHAR *pTableName);

/*****************************************************************************/

GLOBAL BOOL AccDefInit (VOID)
{
  WORD obj;

  obj = ROOT;

  do
  {
    if (is_type (accicon, obj, G_BUTTON))
      accicon [obj].ob_y = 4;
  } while (! is_flags (accicon, obj++, LASTOB));

  accicon [ROOT].ob_width      = accicon [ACCINFBX].ob_width = accicon [ACCTOOLS].ob_width = desk.w;
  accicon [ACCTOOLS].ob_height = accicon [ACCARROW].ob_y + accicon [ACCARROW].ob_height + 4;
  accicon [ACCINFBX].ob_height++;
  accicon [ACCTOOLS].ob_y      = accicon [ACCINFBX].ob_height;
  accicon [ROOT].ob_height     = accicon [ACCINFBX].ob_height + accicon [ACCTOOLS].ob_height;
  accicon [ACCARROW].ob_y      = (accicon [ACCTOOLS].ob_height - accicon [ACCARROW].ob_height) / 2;
  accicon [ACCINFO].ob_y       = (accicon [ACCINFBX].ob_height - accicon [ACCINFO].ob_height) / 2;

  do_state (accicon, ACCGRAF, DISABLED);			/* !!! not yet */

  set_str (accicon, ACCINFO, "");

  ListBoxSetCallback (accicon, ACCCOLUM, ColumnCallback);
  ListBoxSetStyle (accicon, ACCCOLUM, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (accicon, ACCCOLUM, gl_wbox / 2);

  ListBoxSetFont (accicon, ACCZOOM, FONT_SYSTEM, gl_point, TXT_NORMAL, BLACK, WHITE);
  ListBoxSetCallback (accicon, ACCZOOM, ZoomCallback);
  ListBoxSetStyle (accicon, ACCZOOM, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (accicon, ACCZOOM, LBS_VSCROLL | LBS_VREALTIME, FALSE);
  ListBoxSetLeftOffset (accicon, ACCZOOM, gl_wbox / 2);
  ListBoxSetCount (accicon, ACCZOOM, sizeof (apszZoomStr) / sizeof (CHAR *), NULL);

  AccObjSetPropertyValues (ACC_PROP_SUM,                  FREETXT (ACCOUNT_PROP_VAL_SUM));
  AccObjSetPropertyValues (ACC_PROP_BK_MODE,              FREETXT (ACCOUNT_PROP_VAL_MODE));
  AccObjSetPropertyValues (ACC_PROP_BK_COLOR,             FREETXT (ACCOUNT_PROP_VAL_COLOR));
  AccObjSetPropertyValues (ACC_PROP_EFFECT,               FREETXT (ACCOUNT_PROP_VAL_EFFECT));
  AccObjSetPropertyValues (ACC_PROP_BORDER_MODE,          FREETXT (ACCOUNT_PROP_VAL_MODE));
  AccObjSetPropertyValues (ACC_PROP_BORDER_COLOR,         FREETXT (ACCOUNT_PROP_VAL_COLOR));
  AccObjSetPropertyValues (ACC_PROP_BORDER_STYLE,         FREETXT (ACCOUNT_PROP_VAL_STYLE));
  AccObjSetPropertyValues (ACC_PROP_FONT_COLOR,           FREETXT (ACCOUNT_PROP_VAL_COLOR));
  AccObjSetPropertyValues (ACC_PROP_FONT_BOLD,            FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_FONT_ITALIC,          FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_FONT_UNDERLINED,      FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_FONT_OUTLINED,        FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_FONT_LIGHT,           FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_HORZ_ALIGNMENT,       FREETXT (ACCOUNT_PROP_VAL_HORZ_ALIGNMENT));
  AccObjSetPropertyValues (ACC_PROP_VERT_ALIGNMENT,       FREETXT (ACCOUNT_PROP_VAL_VERT_ALIGNMENT));
  AccObjSetPropertyValues (ACC_PROP_IS_VISIBLE,           FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_IS_SELECTED,          FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_CAN_GROW,             FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_CAN_SHRINK,           FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_HIDE_DUPLICATES,      FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_ACC_IS_TABLE,         FREETXT (ACCOUNT_PROP_VAL_FROM_TABLE));
  AccObjSetPropertyValues (ACC_PROP_ACC_PAGEHEADER,       FREETXT (ACCOUNT_PROP_VAL_PAGEHEADER));
  AccObjSetPropertyValues (ACC_PROP_ACC_PAGEFOOTER,       FREETXT (ACCOUNT_PROP_VAL_PAGEHEADER));
  AccObjSetPropertyValues (ACC_PROP_ACC_PAGE_FORMAT,      FREETXT (ACCOUNT_PROP_VAL_PAGE_FORMAT));  
  AccObjSetPropertyValues (ACC_PROP_ACC_PAGE_ORIENTATION, FREETXT (ACCOUNT_PROP_VAL_PAGE_ORIENTATION));  
  AccObjSetPropertyValues (ACC_PROP_REG_NEW_PAGE,         FREETXT (ACCOUNT_PROP_VAL_NEW_PAGE));
  AccObjSetPropertyValues (ACC_PROP_REG_BK_COLOR,         FREETXT (ACCOUNT_PROP_VAL_COLOR));
  AccObjSetPropertyValues (ACC_PROP_REG_VISIBLE,          FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_REG_KEEP_TOGETHER,    FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_REG_CAN_GROW,         FREETXT (ACCOUNT_PROP_VAL_BOOL));
  AccObjSetPropertyValues (ACC_PROP_REG_CAN_SHRINK,       FREETXT (ACCOUNT_PROP_VAL_BOOL));

  return (TRUE);
} /* AccDefInit */

/*****************************************************************************/

GLOBAL BOOL AccDefTerm (VOID)
{
  return (TRUE);
} /* AccDefTerm */

/*****************************************************************************/

GLOBAL WINDOWP AccDefCreate (OBJECT *obj, OBJECT *menu, WORD icon, DB *db, SYSACCOUNT *sysaccount)
{
  WINDOWP      window;
  SHORT        menu_height, inx;
  ACCOUNT_SPEC *pAccSpec;
  SHORT        cols, i;
  TABLE_INFO   t_inf;

  menu_height = (menu != NULL) ? gl_hattr : 0;

  pAccSpec = (ACCOUNT_SPEC *)mem_alloc ((LONG)sizeof (ACCOUNT_SPEC));
  if (pAccSpec == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (pAccSpec, 0, sizeof (ACCOUNT_SPEC));

  pAccSpec->db    = db;
  pAccSpec->sMode = ACCARROW;

  if (sysaccount == NULL)				/* new account */
  {
    pAccSpec->sTable = db->table;
    SetAccountDefault (&pAccSpec->account);
    pAccSpec->account.bTable = TRUE;
    db_tableinfo (db->base, db->table, &t_inf);
    strcpy (pAccSpec->account.szTableOrQuery, t_inf.name);
  } /* if */
  else
    if (! MemAccFromSysAcc (db, &pAccSpec->account, sysaccount))
    {
      hndl_alert (ERR_NOMEMORY);
      mem_free (pAccSpec);
      return (NULL);
    } /* if */
    else
    {
      TableNameFromQuery (pAccSpec, t_inf.name);
      pAccSpec->sTable = db_tableinfo (db->base, FAILURE, &t_inf);
    } /* else, else */

  FillNumRegions (pAccSpec);

  pAccSpec->sTable = db_tableinfo (db->base, pAccSpec->sTable, &t_inf);
  cols = (pAccSpec->sTable == FAILURE) ? 0 : t_inf.cols;

  if (cols != 0)
  {
    pAccSpec->pColumns = mem_alloc ((LONG)cols * sizeof (SHORT));

    if (pAccSpec->pColumns == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      FreeAccountSpec (pAccSpec);
      return (NULL);
    } /* if */
  } /* if */

  for (i = 1; i < cols; i++)
    if (db_acc_column (db->base, pAccSpec->sTable, i) & GRANT_SELECT)
      pAccSpec->pColumns [pAccSpec->lNumCols++] = i;

  if (pAccSpec->lNumCols == 0)
    pAccSpec->lColInx = FAILURE;

  SortCols (pAccSpec);

  pAccSpec->sIconHeight      = accicon->ob_height + 1 + menu_height;
  pAccSpec->lFontScaleFactor = YFAC * (LONG)screen_info.pix_h;
  pAccSpec->lZoomInx         = 3;				/* 100% */

  inx    = num_windows (CLASS_ACCDEF, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_ACCDEF);

  if (window != NULL)
  {
    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = DOCW;
    window->doc.h     = DOCH + pAccSpec->sNumRegions * GROUPSEPHEIGHT / YFAC;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->xscroll   = XSCROLL;
    window->yscroll   = YSCROLL;
    window->scroll.x  = INITX + inx * gl_wbox + window->xscroll;
    window->scroll.y  = INITY + inx * gl_hbox + window->yscroll + pAccSpec->sIconHeight + odd (menu_height);
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = min (INITH, (desk.y + desk.h - window->scroll.y - 6 * gl_hbox) / window->yfac * window->yfac);
    window->work.x    = window->scroll.x - window->xscroll;
    window->work.y    = window->scroll.y - window->yscroll - pAccSpec->sIconHeight;
    window->work.w    = window->scroll.w + window->xscroll;
    window->work.h    = window->scroll.h + window->yscroll + pAccSpec->sIconHeight;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)pAccSpec;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = NULL;
    window->updt_menu = NULL;
    window->test      = WindowTest;
    window->open      = WindowOpen;
    window->close     = WindowClose;
    window->delete    = WindowDelete;
    window->draw      = WindowDraw;
    window->arrow     = WindowArrow;
    window->snap      = WindowSnap;
    window->objop     = WindowObjOp;
    window->drag      = WindowDrag;
    window->click     = WindowClick;
    window->unclick   = WindowUnclick;
    window->key       = WindowKey;
    window->timer     = NULL;
    window->top       = WindowTop;
    window->untop     = NULL;
    window->edit      = WindowEdit;
    window->showinfo  = AccDefInfo;
    window->showhelp  = AccDefHelp;

    sprintf (window->name, FREETXT (FDEFACCOUNT), "", (pAccSpec->account.szName [0] == EOS) ? FREETXT (FNOTITLE) : pAccSpec->account.szName);
  } /* if */
  else
    FreeAccountSpec (pAccSpec);

  set_meminfo ();

  return (window);                                      /* Fenster zurckgeben */
} /* AccDefCreate */

/*****************************************************************************/

GLOBAL BOOL AccDefOpen (WORD icon, DB *db, SYSACCOUNT *sysaccount)
{
  BOOL    bOk;
  WINDOWP window;

  window = AccDefCreate (NULL, NULL, icon, db, sysaccount);
  bOk    = window != NULL;

  if (bOk)
  {
    bOk = open_window (window);

    if (! bOk)
      hndl_alert (ERR_NOOPEN);
    else
      UpdateProperties (window, FALSE, NULL);
  } /* if */

  return (bOk);
} /* AccDefOpen */

/*****************************************************************************/

GLOBAL BOOL AccDefInfo (WINDOWP window, WORD icon)
{
  return (UpdateProperties (window, TRUE, NULL));
} /* AccDefInfo */

/*****************************************************************************/

GLOBAL BOOL AccDefHelp (WINDOWP window, WORD icon)
{
  return (hndl_help (HACCOUNT));
} /* AccDefHelp */

/*****************************************************************************/

GLOBAL VOID AccDefPrint (WINDOWP window)
{
  SYSACCOUNT   *pSysAccount;
  DB           *db;
  ACCOUNT_SPEC *pAccSpec;
  ACCOUNT      account;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_ALIST))
  {
    pSysAccount = GetSysRec (sel_window, SYS_ACCOUNT, sizeof (SYSACCOUNT), &db);

    if (pSysAccount != NULL)
    {
      if (MemAccFromSysAcc (db, &account, pSysAccount))
        AccountExec (&account, db, FAILURE, FAILURE, ASCENDING, DEV_PRINTER, minimize, 1);

      unclick_window (sel_window);
      AccFree (&account);
      mem_free (pSysAccount);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;
    AccountExec (&pAccSpec->account, pAccSpec->db, FAILURE, FAILURE, ASCENDING, DEV_PRINTER, minimize, 1);
  } /* else */
} /* AccDefPrint */

/*****************************************************************************/

GLOBAL BOOL AccDefClose (DB *db)
{
  WORD         num, i;
  ACCOUNT_SPEC *pAccSpec;
  WINDOWP      window;
  WINDOWP      windows [MAX_GEMWIND];

  num = num_windows (CLASS_ACCDEF, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window   = windows [i];
    pAccSpec = (ACCOUNT_SPEC *)window->special;

    if (pAccSpec->db == db)
    {
      delete_window (window);

      if (search_window (CLASS_ACCDEF, SRCH_ANY, NIL) == window)
        return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* AccDefClose */

/*****************************************************************************/

GLOBAL VOID AccDefNew (VOID)
{
  AccDefOpen (NIL, actdb, NULL);
} /* AccDefNew */

/*****************************************************************************/

GLOBAL VOID AccDefLoad (WINDOWP window)
{
  SYSACCOUNT *pSysAccount;
  DB         *db;

  if ((window != NULL) && (window->subclass == CLASS_ALIST))
  {
    pSysAccount = GetSysRec (window, SYS_ACCOUNT, sizeof (SYSACCOUNT), &db);

    if (pSysAccount != NULL)
    {
      unclick_window (window);
      AccDefOpen (NIL, db, pSysAccount);
      mem_free (pSysAccount);
      set_meminfo ();
    } /* if */
  } /* if */
} /* AccDefLoad */

/*****************************************************************************/

GLOBAL BOOL AccDefSave (WINDOWP window, BOOL saveas)
{
  BOOL         ok, found;
  ACCOUNT_SPEC *pAccSpec;
  SYSACCOUNT   *sysaccount;
  SEL_SPEC     sel_spec;
  TABLE_INFO   t_info;
  WORD         num_docs, num, status;
  BYTE         *itemlist, *p;
  CURSOR       cursor;
  LONG         address;

  ok       = FALSE;
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  db_tableinfo (pAccSpec->db->base, SYS_ACCOUNT, &t_info);
  num_docs   = (WORD)t_info.recs;
  sysaccount = pAccSpec->db->buffer;

  if (! saveas)
    saveas = pAccSpec->account.szName [0] == EOS;		/* window not saved yet */

  if ((num_docs == 0) || ! saveas)
    itemlist = NULL;
  else
  {
    itemlist = mem_alloc ((LONG)num_docs * (sizeof (FIELDNAME)));

    if (itemlist == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      return (FALSE);
    } /* if */
  } /* else */

  if (saveas)
  {
    set_meminfo ();
    busy_mouse ();

    db_initcursor (pAccSpec->db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor);

    for (num = 0, ok = TRUE, p = itemlist; (num < num_docs) && ok && db_movecursor (pAccSpec->db->base, &cursor, 1L); num++, p += sizeof (FIELDNAME))
    {
      ok = db_read (pAccSpec->db->base, SYS_ACCOUNT, sysaccount, &cursor, 0L, FALSE);
      strcpy (p, sysaccount->name);
    } /* for */

    arrow_mouse ();

    sel_spec.title      = FREETXT (FASAVEAS);
    sel_spec.itemlist   = itemlist;
    sel_spec.itemsize   = sizeof (FIELDNAME);
    sel_spec.num_items  = num;
    sel_spec.boxtitle   = FREETXT (FALIST);
    sel_spec.helpinx    = HASAVEAS;
    strcpy (sel_spec.selection, pAccSpec->account.szName);

    ok = selection (&sel_spec);
  } /* if */
  else
  {
    strcpy (sel_spec.selection, pAccSpec->account.szName);
    ok = TRUE;
  } /* else */

  if (ok)
  {
    busy_mouse ();
    found = FALSE;
    strcpy (pAccSpec->account.szName, sel_spec.selection);
    strcpy (sysaccount->name, sel_spec.selection);
    sysaccount->account.address = 0L;
    sysaccount->account.size    = 0L;
    sysaccount->account.ext [0] = EOS;

    if (sysaccount->name [0] != EOS)
    {
      found = db_search (pAccSpec->db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor, sysaccount, 0L);
      ok    = db_status (pAccSpec->db->base) == SUCCESS;

      if (ok && found)
        ok = db_read (pAccSpec->db->base, SYS_ACCOUNT, sysaccount, &cursor, 0L, FALSE);
    } /* if */

    strcpy (sysaccount->account.name, ACCOUNT_VERSION);		/* was overwritten by db_read above */

    if (ok)
      ok = SysAccFromMemAcc (pAccSpec->db, sysaccount, &pAccSpec->account, found);

    if (ok)
      if (found)
      {
        address             = db_readcursor (pAccSpec->db->base, &cursor, NULL);
        sysaccount->address = address;
        ok                  = db_reclock (pAccSpec->db->base, address) && db_update (pAccSpec->db->base, SYS_ACCOUNT, sysaccount, &status);
      } /* if */
      else
        ok = db_insert (pAccSpec->db->base, SYS_ACCOUNT, sysaccount, &status);

    dbtest (pAccSpec->db);
    updt_lsall (pAccSpec->db, SYS_ACCOUNT, TRUE, FALSE);

    if (ok)
      SetDirty (window, FALSE, FALSE);

    arrow_mouse ();
  } /* if */

  mem_free (itemlist);
  set_meminfo ();

  return (ok);
} /* AccDefSave */

/*****************************************************************************/

GLOBAL BOOL AccDefExec (WINDOWP window, DB *db, SHORT table, SHORT inx, SHORT dir)
{
  BOOL         bOk;
  ACCOUNT_SPEC *pAccSpec;
  TABLE_INFO   table_info;
  SHORT        sTable;

  bOk = FALSE;

  if (window->class == CLASS_ACCDEF)
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;

    if (pAccSpec->db != db)
      hndl_alert (ERR_REPMISMATCH);
    else
    {
      TableNameFromQuery (pAccSpec, table_info.name);
      sTable = db_tableinfo (db->base, FAILURE, &table_info);

      if (sTable != rtable (table))
        hndl_alert (ERR_REPMISMATCH);
      else
      {
        bOk = TRUE;
        AccountExec (&pAccSpec->account, db, table, inx, dir, FAILURE, minimize, 1);
      } /* else */
    } /* else */
  } /* if */

  return (bOk);
} /* AccDefExec */

/*****************************************************************************/

GLOBAL VOID AccDefExecute (WINDOWP window)
{
  SYSACCOUNT   *pSysAccount;
  DB           *db;
  ACCOUNT_SPEC *pAccSpec;
  ACCOUNT      account;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_ALIST))
  {
    pSysAccount = GetSysRec (sel_window, SYS_ACCOUNT, sizeof (SYSACCOUNT), &db);

    if (pSysAccount != NULL)
    {
      if (MemAccFromSysAcc (db, &account, pSysAccount))
        AccountExec (&account, db, FAILURE, FAILURE, ASCENDING, FAILURE, minimize, 1);

      unclick_window (sel_window);
      AccFree (&account);
      mem_free (pSysAccount);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;
    AccountExec (&pAccSpec->account, pAccSpec->db, FAILURE, FAILURE, ASCENDING, FAILURE, minimize, 1);
  } /* else */
} /* AccDefExecute */

/*****************************************************************************/

GLOBAL BOOL AccDefHasAccHeader (WINDOWP window)
{
  BOOL         bHasHeader;
  ACCOUNT_SPEC *pAccSpec;

  bHasHeader = FALSE;

  if (window->class == CLASS_ACCDEF)
  {
    pAccSpec   = (ACCOUNT_SPEC *)window->special;
    bHasHeader = (pAccSpec->account.lFlags & ACC_HAS_HEADFOOT) != 0;
  } /* if */

  return (bHasHeader);
} /* AccDefHasAccHeader */

/*****************************************************************************/

GLOBAL BOOL AccDefHasPageHeader (WINDOWP window)
{
  BOOL         bHasHeader;
  ACCOUNT_SPEC *pAccSpec;

  bHasHeader = FALSE;

  if (window->class == CLASS_ACCDEF)
  {
    pAccSpec   = (ACCOUNT_SPEC *)window->special;
    bHasHeader = (pAccSpec->account.lFlags & ACC_HAS_PAGE_HEADFOOT) != 0;
  } /* if */

  return (bHasHeader);
} /* AccDefHasPageHeader */

/*****************************************************************************/

GLOBAL VOID AccDefFlipAccHeader (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT         rc;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  pAccSpec->account.lFlags ^= ACC_HAS_HEADFOOT;
  window->doc.h             = DOCH + FillNumRegions (pAccSpec) * GROUPSEPHEIGHT / YFAC;

  if (pAccSpec->account.lFlags & ACC_HAS_HEADFOOT)
  {
    SetRegionDefault (&pAccSpec->account.arAccountHeader, FALSE, HEADER_HEIGHT);
    SetRegionDefault (&pAccSpec->account.arAccountFooter, FALSE, HEADER_HEIGHT);
  } /* if */
  else
  {
    FreeRegion (&pAccSpec->account.arAccountHeader);
    FreeRegion (&pAccSpec->account.arAccountFooter);
    SetSelObjs (window);
  } /* else */

  xywh2rect (window->work.x, window->scroll.y, window->work.w, window->scroll.h, &rc);
  set_sliders (window, VERTICAL, SLPOS | SLSIZE);
  set_redraw (window, &rc);
  snap_window (window, NULL, SIZED);
  SetDirty (window, TRUE, TRUE);
} /* AccDefFlipAccHeader */

/*****************************************************************************/

GLOBAL VOID AccDefFlipPageHeader (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT         rc;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  pAccSpec->account.lFlags ^= ACC_HAS_PAGE_HEADFOOT;
  window->doc.h             = DOCH + FillNumRegions (pAccSpec) * GROUPSEPHEIGHT / YFAC;

  if (pAccSpec->account.lFlags & ACC_HAS_PAGE_HEADFOOT)
  {
    SetRegionDefault (&pAccSpec->account.arPageHeader, TRUE, HEADER_HEIGHT);
    SetRegionDefault (&pAccSpec->account.arPageFooter, TRUE, HEADER_HEIGHT);
  } /* if */
  else
  {
    FreeRegion (&pAccSpec->account.arPageHeader);
    FreeRegion (&pAccSpec->account.arPageFooter);
    SetSelObjs (window);
  } /* else */

  xywh2rect (window->work.x, window->scroll.y, window->work.w, window->scroll.h, &rc);
  set_sliders (window, VERTICAL, SLPOS | SLSIZE);
  set_redraw (window, &rc);
  snap_window (window, NULL, SIZED);
  SetDirty (window, TRUE, TRUE);
} /* AccDefFlipPageHeader */

/*****************************************************************************/

GLOBAL VOID AccDefFlipRaster (VOID)
{
  WORD    num, i;
  WINDOWP window;
  WINDOWP windows [MAX_GEMWIND];

  num = num_windows (CLASS_ACCDEF, SRCH_OPENED, windows);

  for (i = 0; i < num; i++)
  {
    window = windows [i];
    redraw_window (window, &window->scroll);
  } /* for */
} /* AccDefShowRaster */

/*****************************************************************************/

GLOBAL VOID AccDefToForeground (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  ACC_OBJECT   *pObjects;
  SHORT        i, j, k;
  RECT         rcObject;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  for (i = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    if (pRegion->sNumObjects > 0)
    {
      pObjects = mem_alloc (pRegion->sNumObjects * sizeof (ACC_OBJECT));

      if (pObjects == NULL)
        hndl_alert (ERR_NOMEMORY);
      else
      {
        k = 0;

        for (j = 0; j < pRegion->sNumObjects; j++)
          if (! (pRegion->pObjects [j].lFlags & OBJ_SELECTED))
            pObjects [k++] = pRegion->pObjects [j];

        for (j = 0; j < pRegion->sNumObjects; j++)
          if (pRegion->pObjects [j].lFlags & OBJ_SELECTED)
          {
            GetObjectRect (window, pRegion, j, &rcObject);
            set_redraw (window, &rcObject);
            pObjects [k++] = pRegion->pObjects [j];
          } /* if, for */

        mem_lmove (pRegion->pObjects, pObjects, pRegion->sNumObjects * sizeof (ACC_OBJECT));
        mem_free (pObjects);
      } /* else */
    } /* if */
  } /* for */

  SetDirty (window, TRUE, FALSE);
  SetSelObjs (window);

  pAccSpec->iOperation = OP_NONE;				/* too difficult for now */
} /* AccDefToForeground */

/*****************************************************************************/

GLOBAL VOID AccDefToBackground (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  ACC_OBJECT   *pObjects;
  SHORT        i, j, k;
  RECT         rcObject;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  for (i = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    if (pRegion->sNumObjects > 0)
    {
      pObjects = mem_alloc (pRegion->sNumObjects * sizeof (ACC_OBJECT));

      if (pObjects == NULL)
        hndl_alert (ERR_NOMEMORY);
      else
      {
        k = 0;

        for (j = 0; j < pRegion->sNumObjects; j++)
          if (pRegion->pObjects [j].lFlags & OBJ_SELECTED)
          {
            GetObjectRect (window, pRegion, j, &rcObject);
            set_redraw (window, &rcObject);
            pObjects [k++] = pRegion->pObjects [j];
          } /* if, for */

        for (j = 0; j < pRegion->sNumObjects; j++)
          if (! (pRegion->pObjects [j].lFlags & OBJ_SELECTED))
            pObjects [k++] = pRegion->pObjects [j];

        mem_lmove (pRegion->pObjects, pObjects, pRegion->sNumObjects * sizeof (ACC_OBJECT));
        mem_free (pObjects);
      } /* else */
    } /* if */
  } /* for */

  SetDirty (window, TRUE, FALSE);
  SetSelObjs (window);

  pAccSpec->iOperation = OP_NONE;				/* too difficult for now */
} /* AccDefToBackground */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOL WindowTest (WINDOWP window, SHORT action)
{
  BOOL         ret, ext;
  ACCOUNT_SPEC *pAccSpec;
  SHORT        button, i, num_objs;

  ret      = TRUE;
  ext      = (action & DO_EXTERNAL) != 0;
  ext      = ext;
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = (window == sel_window);
                     break;
    case DO_SELALL : for (i = num_objs = 0; i < pAccSpec->sNumRegions; i++)
                       num_objs += pAccSpec->pRegions [i]->sNumObjects;
                     ret = num_objs > 0;
                     break;
    case DO_CLOSE  : if (! acc_close && pAccSpec->bDirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       ret    = (button == 1) ? AccDefSave (window, FALSE) : button <= 2;
                     } /* if */
                     break;
    case DO_DELETE : break;
  } /* switch */

  return (ret);
} /* WindowTest */

/*****************************************************************************/
/* ™ffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID WindowOpen (WINDOWP window)
{
  draw_growbox (window, TRUE);
} /* WindowOpen */

/*****************************************************************************/
/* Schlieže Fenster                                                          */
/*****************************************************************************/

LOCAL VOID WindowClose (WINDOWP window)
{
  draw_growbox (window, FALSE);
  PropertyCloseAssocWindow (window);
} /* WindowClose */

/*****************************************************************************/
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID WindowDelete (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  FreeAccountSpec (pAccSpec);

  set_meminfo ();
} /* WindowDelete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID WindowDraw (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT         rc, rc_clip, save;
  SHORT        y, i, num, max_num;
  LONGSTR      s;
  SHORT        xy [4];

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  FixIconBar (window);
  objc_draw (accicon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  line_default (vdi_handle);
  text_default (vdi_handle);

  xywh2rect (window->work.x, window->work.y + pAccSpec->sIconHeight, window->xscroll, window->yscroll, &rc);	/* upper left rectangle */
  FillRect (window, rc, sys_colors [COLOR_BTNFACE]);

  if (dlg_colors >= 16)
    draw_3d (vdi_handle, rc.x + 1, rc.y + 1, 1, rc.w - 2, rc.h - 2, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNHIGHLIGHT], FALSE);

  xy [0] = window->work.x;
  xy [1] = window->scroll.y - 1;
  xy [2] = xy [0] + window->xscroll - 1;
  xy [3] = xy [1];

  vsl_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);
  v_pline (vdi_handle, 2, xy);

  xywh2rect (window->scroll.x, window->work.y + pAccSpec->sIconHeight, window->scroll.w, window->yscroll, &rc);
  DrawHorzRuler (window, rc, - (SHORT)window->doc.x * window->xfac);

  rc_clip    = window->scroll;
  rc_clip.x -= window->xscroll;
  rc_clip.w += window->xscroll;

  save = clip;

  if (rc_intersect (&rc_clip, &clip))
  {
    set_clip (TRUE, &clip);

    y       = (SHORT)(window->scroll.y - window->doc.y * window->yfac);
    num     = 0;
    max_num = pAccSpec->sNumRegions;

    if (pAccSpec->account.lFlags & ACC_HAS_PAGE_HEADFOOT)
      y = DrawRegion (window, &pAccSpec->account.arPageHeader, FREETXT (ACCOUNT_PAGE_HEADER), y, num == 1, ++num == max_num);

    if (pAccSpec->account.lFlags & ACC_HAS_HEADFOOT)
      y = DrawRegion (window, &pAccSpec->account.arAccountHeader, FREETXT (ACCOUNT_ACC_HEADER), y, num == 1, ++num == max_num);

    for (i = 0; i < pAccSpec->account.sNumGroups; i++)
      if (pAccSpec->account.agGroups [i].lFlags & GROUP_HEADER)
      {
        sprintf (s, FREETXT (ACCOUNT_GROUP_HEADER), pAccSpec->account.agGroups [i].szColumn);
        y = DrawRegion (window, &pAccSpec->account.agGroups [i].arHeader, s, y, num == 1, ++num == max_num);
      } /* if, for */

    y = DrawRegion (window, &pAccSpec->account.arDetails, FREETXT (ACCOUNT_DETAILS), y, num == 1, ++num == max_num);

    for (i = pAccSpec->account.sNumGroups - 1; i >= 0; i--)
      if (pAccSpec->account.agGroups [i].lFlags & GROUP_FOOTER)
      {
        sprintf (s, FREETXT (ACCOUNT_GROUP_FOOTER), pAccSpec->account.agGroups [i].szColumn);
        y = DrawRegion (window, &pAccSpec->account.agGroups [i].arFooter, s, y, num == 1, ++num == max_num);
      } /* if, for */

    if (pAccSpec->account.lFlags & ACC_HAS_HEADFOOT)
      y = DrawRegion (window, &pAccSpec->account.arAccountFooter, FREETXT (ACCOUNT_ACC_FOOTER), y, num == 1, ++num == max_num);

    if (pAccSpec->account.lFlags & ACC_HAS_PAGE_HEADFOOT)
      y = DrawRegion (window, &pAccSpec->account.arPageFooter, FREETXT (ACCOUNT_PAGE_FOOTER), y, num == 1, ++num == max_num);

    set_clip (TRUE, &save);
  } /* if */
} /* WindowDraw */

/*****************************************************************************/
/* Reagiere auf Pfeile                                                       */
/*****************************************************************************/

LOCAL VOID WindowArrow (WINDOWP window, SHORT dir, LONG oldpos, LONG newpos)
{
  LONG delta;

  delta = newpos - oldpos;

  if (dir & HORIZONTAL)             /* Horizontale Pfeile und Schieber */
  {
    if (delta != 0)                                    /* Scrolling n”tig */
    {
      window->doc.x = newpos;                          /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);         /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                              /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                                    /* Scrolling n”tig */
    {
      window->doc.y = newpos;                          /* Neue Position */

      set_sliders (window, VERTICAL, SLPOS);           /* Schieber setzen */
      scroll_window (window, VERTICAL, delta * window->yfac);
    } /* if */
  } /* else */
} /* WindowArrow */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID WindowSnap (WINDOWP window, RECT *new, SHORT mode)
{
  RECT  r, diff;
  SHORT wbox, hbox;
  LONG  max_xdoc, max_ydoc;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / wbox * wbox;        /* Differenz berechnen */
  diff.y = (new->y - r.y) / 2 * 2;
  diff.w = (new->w - r.w) / wbox * wbox;
  diff.h = (new->h - r.h) / hbox * hbox;

  if (wbox == 8) new->x = r.x + diff.x;         /* Schnelle Position */
  new->y = r.y + diff.y;                        /* Y immer gerade */
  new->w = r.w + diff.w;                        /* Arbeitsbereich einrasten */
  new->h = r.h + diff.h;

  if (mode & SIZED)
  {
    r.w      = (window->scroll.w + diff.w) / wbox; /* Neuer Scrollbereich */
    max_xdoc = window->doc.w - r.w;
    r.h      = (window->scroll.h + diff.h) / hbox;
    max_ydoc = window->doc.h - r.h;

    if (max_xdoc < 0) max_xdoc = 0;
    if (max_ydoc < 0) max_ydoc = 0;

    if (window->doc.x > max_xdoc)               /* Jenseits rechter Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.x = max_xdoc;
    } /* if */

    if (window->doc.y > max_ydoc)               /* Jenseits unterer Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.y = max_ydoc;
    } /* if */

    if (diff.w != 0)				/* Wegen SS_INSIDE */
    {
      r   = window->work;
      r.h = accicon [ACCINFBX].ob_height;
      set_redraw (window, &r);
    } /* if */
  } /* if */
} /* WindowSnap */

/*****************************************************************************/
/* Objektoperationen von Fenster                                             */
/*****************************************************************************/

LOCAL VOID WindowObjOp (WINDOWP window, SET objs, WORD action)
{
  BOOL    ok;
  WINDOWP top;

  switch (action)
  {
    case OBJ_OPEN  : ObjOp (window, objs, OBJ_EDIT, NULL);
                     break;
    case OBJ_INFO  : ok = AccDefInfo (window, NIL);
                     if (! ok) hndl_alert (ERR_NOINFO);
                     break;
    case OBJ_HELP  : top = find_top ();
                     ok  = (top->class == CLASS_PROPERTY) ? PropertyHelp (top, NIL) : AccDefHelp (window, NIL);
                     if (! ok) hndl_alert (ERR_NOHELP);
                     break;
    case OBJ_DISK  :
    case OBJ_PRINT :
    case OBJ_EXP   :
    case OBJ_IMP   :
    case OBJ_DEL   :
    case OBJ_EDIT  :
    case OBJ_REP   :
    case OBJ_CLIP  :
    case OBJ_CALC  :
    case OBJ_ACC   : ObjOp (window, objs, action, NULL);
                     break;
  } /* switch */
} /* wi_objop */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD WindowDrag (WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj)
{
  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  return (DRAG_NOACTN);
} /* WindowDrag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID WindowClick (WINDOWP window, MKINFO *mk)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        obj, y, w, ret, sClass, sHandlePos, sHandleObj, sRasterX;
  RECT         rc, rcText;
  SET          new_objs, old_objs;
  CHAR         *pTable, *pColumn;
  FONTDESC     *pFont;
  STRING       sz;

  if (find_top () == window)
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;

    FixIconBar (window);

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    setcpy (old_objs, sel_objs);
    set_clip (TRUE, &window->scroll);

    obj = objc_find (accicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    if (obj != NIL)
      switch (obj)
      {
        case ACCCOLUM : /* fall through */
        case ACCZOOM  : HandlePopup (window, mk, obj);
                        break;
        default       : window_button (window, accicon, obj, mk->breturn);
                        if (! (OB_STATE (accicon, obj) & DISABLED))
                          if (OB_FLAGS (accicon, obj) & RBUTTON)	/* new mode */
                            pAccSpec->sMode = obj;
                        pAccSpec->bLock  = get_checkbox (accicon, ACCLOCK);
                        window->mousenum = (pAccSpec->sMode == ACCARROW) ? ARROW : THIN_CROSS;
                        break;
      } /* switch, if */

    if (inside (mk->mox, mk->moy, &window->scroll))		/* in scrolling area ? */
    {
      sHandleObj = FAILURE;
      obj        = (pAccSpec->sMode == ACCARROW) ? ObjectFromPoint (window, mk->mox, mk->moy, NULL) : FAILURE;
      sHandlePos = (pAccSpec->sMode == ACCARROW) ? HandleFromPoint (window, mk->mox, mk->moy, &sHandleObj) : FAILURE;

      if (sHandleObj != FAILURE)
        if ((obj != sHandleObj)	|| (obj == FAILURE))		/* handle is inside other object || part of handle is outside object border */
          obj = sHandleObj;

      if (obj != FAILURE)
      {
        pAccSpec->iOperation = OP_NONE;				/* reset operation */

        setclr (new_objs);
        setincl (new_objs, obj);				/* actual object */

        if (mk->shift)
        {
          InvertObjs (window, new_objs, TRUE);
          setxor (sel_objs, new_objs);

          if (! setin (sel_objs, obj))
            obj = FAILURE;					/* deselect again */
        } /* if */
        else
        {
          if (! setin (sel_objs, obj))
          {
            unclick_window (window);				/* deselect old objects */
            InvertObjs (window, new_objs, TRUE);
          } /* if */

          setor (sel_objs, new_objs);
        } /* else */

        sel_window = setcmp (sel_objs, NULL) ? NULL : window;

        if (! setcmp (old_objs, sel_objs))
          UpdateProperties (window, FALSE, NULL);

        if ((sel_window != NULL) && (obj != FAILURE))
          if (RegionFromPoint (window, mk->mox, mk->moy, FALSE, &pRegion))
          {
            if ((mk->breturn == 1) && (mk->mobutton & 0x0003))	/* drag operation */
              if (sHandlePos != FAILURE)
                SizeObject (window, sHandleObj, sHandlePos, pRegion);
              else
                DragObjects (window, obj, sel_objs, pRegion);

            if (mk->breturn == 2)				/* double click on object */
              if (window->objop != NULL)
                (*window->objop) (sel_window, sel_objs, OBJ_OPEN);
          } /* if, if */
      } /* if */
      else
        if (InAccountSizer (window, mk))
        {
          if (mk->mobutton & 0x0001)
            DragAccountSizer (window, mk->mox);
        } /* if */
        else
          if (InRegionSizer (window, mk, &y, &pRegion))
          {
            if (mk->mobutton & 0x0001)
              DragRegionSizer (window, mk->mox, y, pRegion);
          } /* if */
          else
          {
            if (! (mk->shift || mk->ctrl) || (pAccSpec->sMode != ACCARROW))
              unclick_window (window);				/* deselect */

            if ((mk->breturn == 1) && (mk->mobutton & 0x0001))	/* rubberband operation */
            {
              if (RegionFromPoint (window, mk->mox, mk->moy, FALSE, &pRegion))
              {
                pAccSpec->iOperation = OP_NONE;			/* reset operation */

                switch (pAccSpec->sMode)
                {
                  case ACCTEXT  : sClass = OBJ_TEXT;        break;
                  case ACCCOL   : sClass = OBJ_COLUMN;      break;
                  case ACCGROUP : sClass = OBJ_GROUPBOX;    break;
                  case ACCRBUTT : sClass = OBJ_RADIOBUTTON; break;
                  case ACCCHECK : sClass = OBJ_CHECKBOX;    break;
                  case ACCLINE  : sClass = OBJ_LINE;        break;
                  case ACCBOX   : sClass = OBJ_BOX;         break;
                  case ACCGRAF  : sClass = OBJ_GRAPHIC;     break;
                  case ACCSUB   : sClass = OBJ_SUBACCOUNT;  break;
                } /* switch */

                RubberBand (window, pRegion, mk, &rc, sClass);

                if ((pAccSpec->sMode != ACCARROW) && (rc.w > 0) && (rc.h > 0))
                {
                  pTable  = db_tablename (pAccSpec->db->base, pAccSpec->sTable);
                  pColumn = (CHAR *)ListBoxSendMessage (accicon, ACCCOLUM, LBN_GETITEM, FAILURE, NULL);

                  if (! NewObject (window, pRegion, sClass, rc, NULL, pTable, pColumn, TRUE))
                    hndl_alert (ERR_NOMEMORY);

                  if (sClass == OBJ_COLUMN)		/* create column descriptor also */
                  {
                    pFont = &fontdesc;

                    sprintf (sz, "%s:", pColumn);
                    text_default (vdi_handle);
                    vst_font (vdi_handle, pFont->font);
                    vst_arbpoint (vdi_handle, (SHORT)((pFont->point * pAccSpec->lFontScaleFactor + 500) / 1000), &ret, &ret, &ret, &ret);
                    vst_effects (vdi_handle, pFont->effects);
                    text_extent (vdi_handle, sz, TRUE, &w, NULL);

                    sRasterX  = use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterX, window->xfac) : 1;
                    w         = (w / sRasterX + 1) * sRasterX;
                    rcText    = rc;
                    rcText.x -= w + PIXELS_FROM_UNITS (LEFT_OFFSET, window->xfac);	/* 0.5 cm to the left */
                    rcText.w  = w;

                    DrawHandles (&rc);			/* reset handles of column object in case they overlap new object */

                    if (! NewObject (window, pRegion, OBJ_TEXT, rcText, sz, NULL, NULL, TRUE))
                      hndl_alert (ERR_NOMEMORY);

                    DrawHandles (&rc);			/* draw handles of column object again */
                  } /* if */

                  if (! pAccSpec->bLock)		/* switch back to arrow */
                  {
                    set_rbutton (accicon, ACCARROW, ACCARROW, ACCSUB);
                    draw_win_obj (window, accicon, pAccSpec->sMode);
                    draw_win_obj (window, accicon, pAccSpec->sMode = ACCARROW);
                    window->mousenum = ARROW;
                    set_mouse (ARROW, NULL);
                  } /* if */
                } /* if */
              } /* if */
            } /* if */

            RegionFromPoint (window, mk->mox, mk->moy, TRUE, &pRegion);

            if ((! setcmp (old_objs, sel_objs)) || (pAccSpec->pRegionProp != pRegion) || (mk->breturn == 2))	/* object or region changed (don't flicker when clicking on region already shown) */
              UpdateProperties (window, mk->breturn == 2, pRegion);
          } /* else, else, else */
    } /* if */
    else
    {
      rc    = window->scroll;
      rc.x -= window->xscroll;
      rc.w += window->xscroll;
      rc.y -= window->yscroll;
      rc.h += window->yscroll;

      if (inside (mk->mox, mk->moy, &rc))		/* in ruler area ? */
      {
        unclick_window (window);			/* deselect */

        if ((! setcmp (old_objs, sel_objs)) || (pAccSpec->pRegionProp != NULL) || (mk->breturn == 2))	/* object or region changed (don't flicker when clicking on region already shown) */
          UpdateProperties (window, mk->breturn == 2, NULL);
      } /* if */
    } /* else */
  } /* if */
} /* WindowClick */

/*****************************************************************************/

LOCAL VOID WindowUnclick (WINDOWP window)
{
  if (sel_window != NULL)
  {
    InvertObjs (window, sel_objs, TRUE);
    sel_window = NULL;
    UpdateProperties (window, FALSE, NULL);
  } /* if */
} /* WindowUnclick */

/*****************************************************************************/
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOL WindowKey (WINDOWP window, MKINFO *mk)
{
  return (FALSE);
} /* WindowKey */

/*****************************************************************************/
/* Fenster wurde nach oben gebracht                                          */
/*****************************************************************************/

LOCAL VOID WindowTop (WINDOWP window)
{
  if (PropertyGetAssocWindow () != window)
    UpdateProperties (window, FALSE, NULL);
} /* WindowTop */

/*****************************************************************************/
/* Cut/Copy/Paste fr Fenster                                                */
/*****************************************************************************/

LOCAL VOID WindowEdit (WINDOWP window, WORD action)
{
  BOOL         ext;
  SHORT        i, j, obj;
  ACCOUNT_SPEC *pAccSpec;
  SET          setOldObjs;

  ext      = (action & DO_EXTERNAL) != 0;
  pAccSpec = (ACCOUNT_SPEC *)window->special;
  ext      = ext; /* no warning please */

  switch (action & 0x00FF)
  {
    case DO_UNDO   : break;
    case DO_CUT    : break;
    case DO_COPY   : break;
    case DO_PASTE  : break;
    case DO_CLEAR  : ObjOp (window, sel_objs, OBJ_DEL, NULL);
                     break;
    case DO_SELALL : setcpy (setOldObjs, sel_objs);
                     unclick_window (sel_window);
                     sel_window = window;
                     for (i = obj = 0; i < pAccSpec->sNumRegions; i++)
                       for (j = 0; j < pAccSpec->pRegions [i]->sNumObjects; j++, obj++)
                         setincl (sel_objs, obj);

                     InvertObjs (window, sel_objs, TRUE);

                     if (! setcmp (setOldObjs, sel_objs))
                       UpdateProperties (window, FALSE, NULL);
                     break;
  } /* switch */
} /* WindowEdit */

/*****************************************************************************/

LOCAL VOID FixIconBar (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  accicon->ob_x              = window->work.x;
  accicon->ob_y              = window->work.y;
  accicon [ACCINFO].ob_width = window->work.w - 2 * gl_wbox + 2;

  set_checkbox (accicon, ACCLOCK, pAccSpec->bLock);
  set_rbutton (accicon, pAccSpec->sMode, ACCARROW, ACCSUB);

  ListBoxSetCount (accicon, ACCCOLUM, pAccSpec->lNumCols, NULL);
  ListBoxSetCurSel (accicon, ACCCOLUM, pAccSpec->lColInx);
  ListBoxSetSpec (accicon, ACCCOLUM, (LONG)window);

  ListBoxSetCurSel (accicon, ACCZOOM, pAccSpec->lZoomInx);
  ListBoxSetSpec (accicon, ACCZOOM, (LONG)window);
} /* FixIconBar */

/*****************************************************************************/

LOCAL VOID SetDirty (WINDOWP window, BOOL bDirty, BOOL bUpdateProperties)
{
  ACCOUNT_SPEC *pAccSpec;

  pAccSpec         = (ACCOUNT_SPEC *)window->special;
  pAccSpec->bDirty = bDirty;

  sprintf (window->name, FREETXT (FDEFACCOUNT), bDirty ? "*" : "", (pAccSpec->account.szName [0] == EOS) ? FREETXT (FNOTITLE) : pAccSpec->account.szName);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);

  if (bUpdateProperties)
    UpdateProperties (window, FALSE, pAccSpec->pRegionProp);
} /* SetDirty */

/*****************************************************************************/

LOCAL LONG ColumnCallback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  WINDOWP      window;
  ACCOUNT_SPEC *pAccSpec;
  BOOL         visible_part;
  CHAR         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;

  window   = (WINDOWP)ListBoxGetSpec (tree, obj);
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : if (item == FAILURE)
                            item = ListBoxGetCurSel (tree, obj);
                          return ((LONG)db_fieldname (pAccSpec->db->base, pAccSpec->sTable, pAccSpec->pColumns [item]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = item == FAILURE;

                          if (visible_part)
                            item = ListBoxGetCurSel (tree, obj);

                          if (item != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, item, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &toolcol_icon : NULL, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* ColumnCallback */

/*****************************************************************************/

LOCAL LONG ZoomCallback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  WINDOWP      window;
  BOOL         visible_part;
  CHAR         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : if (item == FAILURE)
                            item = ListBoxGetCurSel (tree, obj);
                          return ((LONG)apszZoomStr [item]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = item == FAILURE;

                          if (visible_part)
                            item = ListBoxGetCurSel (tree, obj);

                          if (item != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, item, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, NULL, text, 0);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* ZoomCallback */

/*****************************************************************************/

LOCAL VOID HandlePopup (WINDOWP window, MKINFO *mk, SHORT obj)
{
  ACCOUNT_SPEC *pAccSpec;
  LONG         lItem;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  if (mk->breturn == 1)
  {
    do_state (accicon, obj, SELECTED);
    draw_win_obj (window, accicon, obj);

    switch (obj)
    {
      case ACCCOLUM : ListBoxSetComboRect (accicon, obj, NULL, VISIBLE);
                      if ((lItem = ListBoxComboClick (accicon, obj, mk)) != FAILURE)
                        pAccSpec->lColInx = lItem;
                      break;
      case ACCZOOM  : ListBoxSetComboRect (accicon, obj, NULL, (SHORT)(sizeof (apszZoomStr) / sizeof (CHAR *)));
                      if ((lItem = ListBoxComboClick (accicon, obj, mk)) != FAILURE)
                        if (pAccSpec->lZoomInx != lItem)
                        {
                          pAccSpec->lZoomInx         = lItem;
                          window->xfac               = (SHORT)(XFAC * atol (apszZoomStr [lItem]) / 100L);
                          window->yfac               = (SHORT)(YFAC * atol (apszZoomStr [lItem]) / 100L);
                          pAccSpec->lFontScaleFactor = window->yfac * (LONG)screen_info.pix_h;
                          set_sliders (window, HORIZONTAL | VERTICAL, SLPOS | SLSIZE);
                          set_redraw (window, &window->work);
                          snap_window (window, NULL, SIZED);
                        } /* if, if */
                      break;
    } /* switch */

    undo_state (accicon, obj, SELECTED);
    draw_win_obj (window, accicon, obj);
  } /* if */
} /* HandlePopup */

/*****************************************************************************/

LOCAL VOID *GetSysRec (WINDOWP window, SHORT sTable, LONG lSize, DB **db)
{
  CHAR      *p;
  LONG      addr;
  WORD      i, obj;
  ICON_INFO info;
  TABLENAME name;

  p = mem_alloc (lSize);

  if (p == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    for (i = 0, obj = NIL; (i < SETMAX) && (obj == NIL); i++)
      if (setin (sel_objs, i)) obj = i;

    if (obj != NIL)
    {
      addr = list_addr (window, obj);
      get_listinfo (window, &info, name);

      if (v_read (info.db, sTable, p, NULL, addr, FALSE))
        *db = info.db;
    } /* if */
  } /* else */

  set_meminfo ();

  return (p);
} /* GetSysRec */

/*****************************************************************************/

LOCAL VOID ObjOp (WINDOWP window, SET objs, WORD action, WINDOWP actwin)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        i, j;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  switch (action)
  {
    case OBJ_DISK  : break;
    case OBJ_PRINT : break;
    case OBJ_EXP   : break;
    case OBJ_IMP   : break;
    case OBJ_DEL   : for (i = 0; i < pAccSpec->sNumRegions; i++)
                     {
                       pRegion = pAccSpec->pRegions [i];

                       for (j = pRegion->sNumObjects - 1; j >= 0; j--)
                         if (pRegion->pObjects [j].lFlags & OBJ_SELECTED)
                           DelObject (window, pRegion, j, TRUE, FALSE);
                     } /* for */
                     SetSelObjs (window);
                     SetDirty (window, TRUE, TRUE);
                     pAccSpec->iOperation = OP_NONE;				/* too difficult for now */
                     break;
    case OBJ_UNDEL : break;
    case OBJ_EDIT  : AccDefInfo (window, NIL);
                     break;
    case OBJ_REP   : break;
    case OBJ_CLIP  : break;
    case OBJ_CALC  : break;
    case OBJ_ACC   : break;
  } /* switch */

  set_meminfo ();
} /* ObjOp */

/*****************************************************************************/

LOCAL VOID FreeRegion (ACC_REGION *pRegion)
{
  AccFreeRegion (pRegion);
} /* FreeRegion */

/*****************************************************************************/

LOCAL VOID FreePropDesc (ACCOUNT_SPEC *pAccSpec)
{
  SHORT i;

  if (pAccSpec->pPropDesc != NULL)
  {
    for (i = 0; i < pAccSpec->sNumPropDesc; i++)
    {
      if (pAccSpec->pPropDesc [i].pszValue != NULL)
        free (pAccSpec->pPropDesc [i].pszValue);

      if (pAccSpec->pPropDesc [i].pszFormat != NULL)
        free (pAccSpec->pPropDesc [i].pszFormat);
    } /* for */

    mem_free (pAccSpec->pPropDesc);

    pAccSpec->pRegionProp  = NULL;
    pAccSpec->sNumPropDesc = 0;
    pAccSpec->pPropDesc    = NULL;
  } /* if */
} /* FreePropDesc */

/*****************************************************************************/

LOCAL VOID FreeAccountSpec (ACCOUNT_SPEC *pAccSpec)
{
  SHORT i;

  for (i = 0; i < pAccSpec->sNumRegions; i++)
    FreeRegion (pAccSpec->pRegions [i]);

  FreePropDesc (pAccSpec);

  if (pAccSpec->pColumns != NULL)
    mem_free (pAccSpec->pColumns);

  mem_free (pAccSpec);
} /* FreeAccountSpec */

/*****************************************************************************/

LOCAL SHORT FillNumRegions (ACCOUNT_SPEC *pAccSpec)
{
  ACCOUNT *pAccount;
  SHORT   i;

  pAccount              = &pAccSpec->account;
  pAccSpec->sNumRegions = 0;

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->arPageHeader;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->arAccountHeader;

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
      pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->agGroups [i].arHeader;

  pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->arDetails;

  for (i = pAccount->sNumGroups - 1; i >= 0; i--)
    if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
      pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->agGroups [i].arFooter;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->arAccountFooter;

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    pAccSpec->pRegions [pAccSpec->sNumRegions++] = &pAccount->arPageFooter;

  return (pAccSpec->sNumRegions);
} /* FillNumRegions */

/*****************************************************************************/

LOCAL VOID SortTables (ACCOUNT_SPEC *pAccSpec, SHORT *pTables, SHORT sTables)
{
  pSort = pAccSpec;
  qsort ((VOID *)pTables, (SIZE_T)sTables, sizeof (SHORT), CompareTables);
} /* SortTables */

/*****************************************************************************/

LOCAL INT CompareTables (SHORT *arg1, SHORT *arg2)
{
  return (strcmp (db_tablename (pSort->db->base, *arg1), db_tablename (pSort->db->base, *arg2)));
} /* CompareTables */

/*****************************************************************************/

LOCAL VOID SortColumns (ACCOUNT_SPEC *pAccSpec, SHORT *pColumns, SHORT sColumns, SHORT sTable)
{
  pSort             = pAccSpec;
  pSort->sTableSort = sTable;
  qsort ((VOID *)pColumns, (SIZE_T)sColumns, sizeof (SHORT), CompareColumns);
} /* SortColumns */

/*****************************************************************************/

LOCAL INT CompareColumns (SHORT *arg1, SHORT *arg2)
{
  return (strcmp (db_fieldname (pSort->db->base, pSort->sTableSort, *arg1), db_fieldname (pSort->db->base, pSort->sTableSort, *arg2)));
} /* CompareColumns */

/*****************************************************************************/

LOCAL VOID SortCols (ACCOUNT_SPEC *pAccSpec)
{
  pSort = pAccSpec;
  qsort ((VOID *)pAccSpec->pColumns, (SIZE_T)pAccSpec->lNumCols, sizeof (SHORT), CompareCols);
} /* SortCols */

/*****************************************************************************/

LOCAL INT CompareCols (SHORT *arg1, SHORT *arg2)
{
  return (strcmp (db_fieldname (pSort->db->base, pSort->sTable, *arg1), db_fieldname (pSort->db->base, pSort->sTable, *arg2)));
} /* CompareCols */

/*****************************************************************************/

LOCAL LONG CalcRegionsHeight (ACCOUNT *pAccount)
{
  LONG lHeightRegions, i;

  lHeightRegions = 0;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    lHeightRegions += pAccount->arAccountHeader.lHeight;

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    lHeightRegions += pAccount->arPageHeader.lHeight;

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
      lHeightRegions += pAccount->agGroups [i].arHeader.lHeight;

  lHeightRegions += pAccount->arDetails.lHeight;		/* the details */

  for (i = pAccount->sNumGroups - 1; i >= 0; i--)
    if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
      lHeightRegions += pAccount->agGroups [i].arFooter.lHeight;

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    lHeightRegions += pAccount->arPageFooter.lHeight;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    lHeightRegions += pAccount->arAccountFooter.lHeight;

  return (lHeightRegions);
} /* CalcRegionsHeight */

/*****************************************************************************/

LOCAL VOID SetAccountDefault (ACCOUNT *pAccount)
{
  pAccount->lFlags                   = ACC_HAS_HEADFOOT | ACC_HAS_PAGE_HEADFOOT;
  pAccount->sPageHeaderProp          = APHP_ALL;
  pAccount->sPageFooterProp          = APHP_ALL;
  pAccount->lRasterX                 = RASTER_X;
  pAccount->lRasterY                 = RASTER_Y;
  pAccount->lWidth                   = A4_WIDTH - MARGIN_LEFT - MARGIN_RIGHT;
  pAccount->lMarginLeft              = MARGIN_LEFT;
  pAccount->lMarginRight             = MARGIN_RIGHT;
  pAccount->lMarginTop               = MARGIN_TOP;
  pAccount->lMarginBottom            = MARGIN_BOTTOM;
  pAccount->sNumCols                 = 1;
  pAccount->lColGap                  = 0;
  pAccount->sNumGroups               = 0;

  NameFromDevice (pAccount->szPrinter, PRINTER);

  SetRegionDefault (&pAccount->arAccountHeader, FALSE, HEADER_HEIGHT);
  SetRegionDefault (&pAccount->arAccountFooter, FALSE, HEADER_HEIGHT);
  SetRegionDefault (&pAccount->arPageHeader, TRUE, HEADER_HEIGHT);
  SetRegionDefault (&pAccount->arPageFooter, TRUE, HEADER_HEIGHT);
  SetRegionDefault (&pAccount->arDetails, FALSE, DETAIL_HEIGHT);

  pAccount->arDetails.lFlags |= REGION_CAN_GROW;			/* use a list like report as default */

#if 0
  SetGroupDefault (&pAccount->agGroups [0], "Band", ASCENDING);		/* test values !!! */
#endif
} /* SetAccountDefault */

/*****************************************************************************/

LOCAL VOID SetRegionDefault (ACC_REGION *pRegion, BOOL bIsPageHeaderFooter, LONG lHeight)
{
  pRegion->lFlags              = REGION_VISIBLE;
  pRegion->sNewPageProp        = RNP_NONE;
  pRegion->bIsPageHeaderFooter = bIsPageHeaderFooter;
  pRegion->lHeight             = lHeight;
  pRegion->sBkColor            = WHITE;
  pRegion->sNumObjects         = 0;
  pRegion->pObjects            = NULL;
} /* SetRegionDefault */

/*****************************************************************************/

LOCAL VOID SetGroupDefault (ACC_GROUP *pGroup, CHAR *pszColumn, SHORT sDir)
{
  pGroup->lFlags    = GROUP_HEADER | GROUP_FOOTER;
  pGroup->sDir      = sDir;
  pGroup->lGroupOn  = 0;
  pGroup->lInterval = 1;

  strcpy (pGroup->szColumn, pszColumn);

  SetRegionDefault (&pGroup->arHeader, FALSE, HEADER_HEIGHT);
  SetRegionDefault (&pGroup->arFooter, FALSE, HEADER_HEIGHT);
} /* SetGroupDefault */

/*****************************************************************************/

LOCAL VOID SetObjectDefault (ACC_OBJECT *pObject, SHORT sClass, CHAR *pText, CHAR *pTable, CHAR *pColumn)
{
  FONTNAME fontname;

  mem_set (pObject, 0, (USHORT)sizeof (ACC_OBJECT));

  pObject->sClass = sClass;
  pObject->lFlags = OBJ_IS_VISIBLE;

  if (AccObjHasProperty (sClass, ACC_PROP_BK_MODE))
  {
    pObject->sBkMode  = ((sClass == OBJ_GROUPBOX) || (sClass == OBJ_LINE)) ? MODE_TRANSPARENT : MODE_OPAQUE;
    pObject->sBkColor = WHITE;
  } /* if */

  if (AccObjHasProperty (sClass, ACC_PROP_BORDER_MODE))
  {
    pObject->sEffect       = EFFECT_NORMAL;
    pObject->sBorderMode   = ((sClass == OBJ_LINE) || (sClass == OBJ_BOX) || (sClass == OBJ_GROUPBOX) || (sClass == OBJ_GRAPHIC) || (sClass == OBJ_SUBACCOUNT)) ? MODE_OPAQUE : MODE_TRANSPARENT;
    pObject->sBorderColor  = BLACK;
    pObject->lBorderWidth  = 25;			/* 25/1000 cm */
    pObject->sBorderStyle  = BORDER_SOLID;
  } /* if */

  if (AccObjHasProperty (sClass, ACC_PROP_TEXT))
  {
    pObject->pText          = AccStrDup (pText);
    pObject->sHorzAlignment = ALI_HSTANDARD;
    pObject->sVertAlignment = ALI_VSTANDARD;
    pObject->sRotation      = 0;
  } /* if */

  if (AccObjHasProperty (sClass, ACC_PROP_FONT_FONT))
  {
    FontNameFromNumber (fontname, fontdesc.font);
    pObject->pFaceName = AccStrDup (fontname);
    pObject->Font      = fontdesc;
  } /* if */

  if (AccObjHasProperty (sClass, ACC_PROP_TABLE))
    pObject->pTable = AccStrDup (pTable);

  if (AccObjHasProperty (sClass, ACC_PROP_COLUMN))
  {
    pObject->pColumn        = AccStrDup (pColumn);
    pObject->sHorzAlignment = ALI_HSTANDARD;
    pObject->sVertAlignment = ALI_VSTANDARD;
    pObject->sRotation      = 0;
  } /* if */
} /* SetObjectDefault */

/*****************************************************************************/

LOCAL BOOL SysAccFromMemAcc (DB *db, SYSACCOUNT *pSysAccount, ACCOUNT *pAccount, BOOL bUpdate)
{
  BOOL bOk;

  bOk = AccSysFromMem (db->base, pSysAccount, pAccount, bUpdate);

  if (! bOk)
    hndl_alert (ERR_NOMEMORY);

  return (bOk);
} /* SysAccFromMemAcc */

/*****************************************************************************/

LOCAL BOOL MemAccFromSysAcc (DB *db, ACCOUNT *pAccount, SYSACCOUNT *pSysAccount)
{
  BOOL bOk;

  bOk = AccMemFromSys (db->base, pAccount, pSysAccount);

  if (! bOk)
    dbtest (db);

  return (bOk);
} /* MemAccFromSysAcc */

/*****************************************************************************/

LOCAL VOID FillRect (WINDOWP window, RECT rc, SHORT color)
{
  SHORT xy [8];

  rect2array (&rc, xy);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (dlg_colors < 16) ? WHITE : color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);
  vr_recfl (vdi_handle, xy);			/* fill the interior */
} /* FillRect */

/*****************************************************************************/

LOCAL VOID DrawHorzRuler (WINDOWP window, RECT rc, SHORT x_offset)
{
  SHORT  mm, x, wbox, hbox, ret, xy [4];
  RECT   r, save;
  STRING s;

  if (rc.w > 0)
  {
    FillRect (window, rc, sys_colors [COLOR_BTNFACE]);
    Draw3DLines (window, rc, TRUE, FALSE);

    x  = window->scroll.x + x_offset;
    mm = 0;

    save = clip;
    rc_intersect (&rc, &clip);					/* don't paint over leftmost column */
    set_clip (TRUE, &clip);

    wbox = gl_wbox;
    hbox = gl_hbox;

    text_default (vdi_handle);
    vswr_mode (vdi_handle, MD_TRANS);
    vst_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);

    if (window->xfac < 4)
      vst_point (vdi_handle, 8, &ret, &ret, &wbox, &hbox);

    while (x < rc.x + rc.w)
    {
      if (x + 2 * wbox >= rc.x)					/* anything is visible */
      {
        xy [0] = x;
        xy [1] = rc.y + rc.h - 3;
        xy [2] = xy [0];
        xy [3] = xy [1] - ((mm % 10 == 0) ? RULER_CM : (mm % 5 == 0) ? RULER_5MM : RULER_MM) + 1;

        if (dlg_colors < 16)
        {
          xy [1]++;
          xy [3]++;
        } /* if */

        array2rect (xy, &r);

        if (rc_intersect (&clip, &r))
        {
          vsl_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);

          if ((window->xfac >= 4) || (mm % 10 == 0) || (mm % 5 == 0))
            v_pline (vdi_handle, 2, xy);
        } /* if */

        xy [0] = x + 1;
        xy [2] = xy [0];

        array2rect (xy, &r);

        if (rc_intersect (&clip, &r))
        {
          vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);

          if ((window->xfac >= 4) || (mm % 10 == 0) || (mm % 5 == 0))
            v_pline (vdi_handle, 2, xy);
        } /* if */

        if (mm % 10 == 0)
        {
          r.x = x + (window->xfac < 4 ? 0 : 3);
          r.y = rc.y + (window->xfac < 4 ? 3 : 0);
          r.w = 2 * wbox;
          r.h = hbox;

          if (rc_intersect (&clip, &r))
          {
            itoa (mm / 10, s, 10);

            if ((window->xfac >= 2) || (mm % 20 == 0))
              v_gtext (vdi_handle, x + (window->xfac < 4 ? 0 : 3), rc.y + (window->xfac < 4 ? 3 : 0), s);
          } /* if */
        } /* if */
      } /* if */

      x += window->xfac;
      mm++;
    } /* while */

    set_clip (TRUE, &save);
  } /* if */
} /* DrawHorzRuler */

/*****************************************************************************/

LOCAL VOID DrawVertRuler (WINDOWP window, RECT rc, SHORT y_offset)
{
  SHORT  mm, y, wbox, hbox, ret, xy [4];
  RECT   r, save;
  STRING s;

  if (rc.h > 0)
  {
    FillRect (window, rc, sys_colors [COLOR_BTNFACE]);
    Draw3DLines (window, rc, FALSE, FALSE);

    y  = y_offset;
    mm = 0;

    save = clip;
    rc_intersect (&rc, &clip);					/* don't paint over topmost column */
    set_clip (TRUE, &clip);

    wbox = gl_wbox;
    hbox = gl_hbox;

    text_default (vdi_handle);
    vswr_mode (vdi_handle, MD_TRANS);
    vst_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);

    if (window->yfac < 4)
      vst_point (vdi_handle, 8, &ret, &ret, &wbox, &hbox);

    while (y < rc.y + rc.h)
    {
      if (y + hbox >= rc.y)					/* anything is visible */
      {
        xy [0] = rc.x + rc.w - 3;
        xy [1] = y;
        xy [2] = xy [0] - ((mm % 10 == 0) ? RULER_CM : (mm % 5 == 0) ? RULER_5MM : RULER_MM) + 1;
        xy [3] = xy [1];

        if (dlg_colors < 16)
        {
          xy [0]++;
          xy [2]++;
        } /* if */

        array2rect (xy, &r);

        if (rc_intersect (&clip, &r))
        {
          vsl_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);

          if ((window->yfac >= 4) || (mm % 10 == 0) || (mm % 5 == 0))
            v_pline (vdi_handle, 2, xy);
        } /* if */

        xy [1] = y + 1;
        xy [3] = xy [1];

        array2rect (xy, &r);

        if (rc_intersect (&clip, &r))
        {
          vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);

          if ((window->yfac >= 4) || (mm % 10 == 0) || (mm % 5 == 0))
            v_pline (vdi_handle, 2, xy);
        } /* if */

        if (mm % 10 == 0)
        {
          r.x = rc.x + (window->xfac < 4 ? 1 : 2);
          r.y = y + (window->xfac < 4 ? 2 : 1);
          r.w = 2 * wbox;
          r.h = hbox;

          if (rc_intersect (&clip, &r))
          {
            ltoa (mm / 10, s, 10);

            if ((window->xfac >= 2) || (mm % 20 == 0))
              v_gtext (vdi_handle, rc.x + (window->xfac < 4 ? 1 : 2), y + (window->xfac < 4 ? 2 : 1), s);
          } /* if */
        } /* if */
      } /* if */

      y += window->yfac;
      mm++;
    } /* while */

    set_clip (TRUE, &save);
  } /* if */
} /* DrawVertRuler */

/*****************************************************************************/

LOCAL VOID Draw3DRect (WINDOWP window, RECT rc)
{
  if (dlg_colors >= 16)
    draw_3d (vdi_handle, rc.x + 1, rc.y + 1, 1, rc.w - 3, rc.h - 3, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
  else
    draw_3d (vdi_handle, rc.x + 1, rc.y + 1, 1, rc.w - 3, rc.h - 3, WHITE, WHITE, WHITE, TRUE);
} /* Draw3DRect */

/*****************************************************************************/

LOCAL VOID Draw3DLines (WINDOWP window, RECT rc, BOOL horz, BOOL top_black)
{
  SHORT xy [4];

  line_default (vdi_handle);

  if (top_black)
  {
    if (horz)
    {
      xy [0] = rc.x;
      xy [1] = rc.y;
      xy [2] = xy [0] + rc.w - 1;
      xy [3] = xy [1];
    } /* if */
    else
    {
      xy [0] = rc.x;
      xy [1] = rc.y;
      xy [2] = xy [0];
      xy [3] = xy [1] + rc.h - 1;
    } /* else */

    vsl_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);
    v_pline (vdi_handle, 2, xy);
  } /* if */

  if (dlg_colors >= 16)
  {
    if (horz)
    {
      xy [0] = rc.x;
      xy [1] = rc.y + (top_black ? 1 : 0);
      xy [2] = xy [0] + rc.w - 1;
      xy [3] = xy [1];
    } /* if */
    else
    {
      xy [0] = rc.x + (top_black ? 1 : 0);
      xy [1] = rc.y;
      xy [2] = xy [0];
      xy [3] = xy [1] + rc.h - 1;
    } /* else */

    vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);
    v_pline (vdi_handle, 2, xy);

    if (horz)
    {
      xy [0] = rc.x;
      xy [1] = rc.y + rc.h - 2;
      xy [2] = xy [0] + rc.w - 1;
      xy [3] = xy [1];
    } /* if */
    else
    {
      xy [0] = rc.x + rc.w - 2;
      xy [1] = rc.y;
      xy [2] = xy [0];
      xy [3] = xy [1] + rc.h - 1;
    } /* else */

    vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);
    v_pline (vdi_handle, 2, xy);
  } /* if */

  if (horz)
  {
    xy [0] = rc.x;
    xy [1] = rc.y + rc.h - 1;
    xy [2] = xy [0] + rc.w - 1;
    xy [3] = xy [1];
  } /* if */
  else
  {
    xy [0] = rc.x + rc.w - 1;
    xy [1] = rc.y;
    xy [2] = xy [0];
    xy [3] = xy [1] + rc.h - 1;
  } /* else */

  vsl_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);
  v_pline (vdi_handle, 2, xy);
} /* Draw3DLines */

/*****************************************************************************/

LOCAL VOID DrawHorzLines (WINDOWP window, RECT rc, SHORT y_offset, SHORT sBkColor)
{
  SHORT  mm, y;
  RECT   r;

  if (rc.w > 0)
  {
    y  = y_offset;
    mm = 0;

    while (y < rc.y + rc.h)
    {
      if ((mm %10 == 0) && (mm != 0))
        if (y >= rc.y)					/* anything is visible */
        {
          r.x = rc.x;
          r.y = y;
          r.w = rc.w;
          r.h = 1;

          DrawGreyLine (&r, sBkColor);
        } /* if, if */

      y += window->yfac;
      mm++;
    } /* while */
  } /* if */
} /* DrawHorzLines */

/*****************************************************************************/

LOCAL VOID DrawVertLines (WINDOWP window, RECT rc, SHORT x_offset, SHORT sBkColor)
{
  SHORT  mm, x;
  RECT   r;

  if (rc.w > 0)
  {
    x  = x_offset;
    mm = 0;

    while (x < rc.x + rc.w)
    {
      if ((mm %10 == 0) && (mm != 0))
        if (x >= rc.x)					/* anything is visible */
        {
          r.x = x;
          r.y = rc.y;
          r.w = 1;
          r.h = rc.h;

          DrawGreyLine (&r, sBkColor);
        } /* if, if */

      x += window->xfac;
      mm++;
    } /* while */
  } /* if */
} /* DrawVertLines */

/*****************************************************************************/

LOCAL VOID DrawGroupSep (WINDOWP window, RECT rc, CHAR *pText, BOOL top_black)
{
  SHORT ret;
  RECT  save, rc_clip;

  FillRect (window, rc, sys_colors [COLOR_BTNFACE]);
  Draw3DLines (window, rc, TRUE, top_black);

  text_default (vdi_handle);
  vswr_mode (vdi_handle, MD_TRANS);
  vst_font (vdi_handle, font_btntext);
  vst_point (vdi_handle, point_btntext, &ret, &ret, &ret, &ret);
  vst_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);

  save    = clip;
  rc_clip = window->scroll;

  if (rc_intersect (&clip, &rc_clip))
  {
    set_clip (TRUE, &rc_clip);				/* don't paint over leftmost column */
    v_gtext (vdi_handle, rc.x + window->xscroll - (INT)(window->doc.x * window->xfac), rc.y + 2, pText);
    set_clip (TRUE, &save);
  } /* if */
} /* DrawGroupSep */

/*****************************************************************************/

LOCAL SHORT DrawRegion (WINDOWP window, ACC_REGION *pRegion, CHAR *pRegionName, SHORT y, BOOL bFirstRegion, BOOL bLastRegion)
{
  LOCAL SHORT  sLastHeight = 0;
  ACCOUNT_SPEC *pAccSpec;
  RECT         rc;
  SHORT        x, w, h, xy [4], sBkColor;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  h = GROUPSEPHEIGHT;

  if ((y + h >= window->scroll.y) && (y < window->scroll.y + window->scroll.h))
  {
    xywh2rect (window->work.x, y, window->work.w, h, &rc);
    DrawGroupSep (window, rc, pRegionName, ! bFirstRegion && (sLastHeight != 0));
  } /* if */

  y += h;

  w  = PIXELS_FROM_UNITS (pAccSpec->account.lWidth, window->xfac);
  w -= (SHORT)(window->doc.x * window->xfac);
  h  = PIXELS_FROM_UNITS (pRegion->lHeight, window->yfac);

  if ((y + h >= window->scroll.y) && (y < window->scroll.y + window->scroll.h) || bLastRegion)
  {
    xywh2rect (window->work.x, y, window->xscroll, bLastRegion ? (SHORT)(window->doc.h * window->yfac) : h, &rc);
    DrawVertRuler (window, rc, y);

    if (h >= 0)
    {
      if (w >= 0)
      {
        sBkColor = (colors >= pRegion->sBkColor) ? pRegion->sBkColor : WHITE;
        xywh2rect (window->scroll.x, y, w, h, &rc);
        vswr_mode (vdi_handle, MD_REPLACE);
        vsf_perimeter (vdi_handle, FALSE);
        vsf_color (vdi_handle, sBkColor);
        vsf_interior (vdi_handle, FIS_SOLID);
        vsf_style (vdi_handle, 0);
        rect2array (&rc, xy);

        if ((rc.w > 0) && (rc.h > 0))
          v_bar (vdi_handle, xy);			/* draw background */

        if (show_raster)
        {
          DrawHorzLines (window, rc, y, sBkColor);
          DrawVertLines (window, rc, window->scroll.x - (SHORT)(window->doc.x * window->xfac), sBkColor);
        } /* if */

        vswr_mode (vdi_handle, MD_TRANS);
        vsf_perimeter (vdi_handle, TRUE);
        vsf_color (vdi_handle, BLACK);
        vsf_interior (vdi_handle, FIS_HOLLOW);
        rc_inflate (&rc, 1, 1);
        rect2array (&rc, xy);

        if ((rc.w > 0) && (rc.h > 0))
          v_bar (vdi_handle, xy);			/* draw outlined border */
      } /* if */

      x = window->scroll.x + w + 1;			/* 1 because of outlined border */
      xywh2rect (x, y, window->scroll.w - w - 1, h + (bLastRegion ? 1 : 0), &rc);
      vswr_mode (vdi_handle, MD_REPLACE);
      vsf_perimeter (vdi_handle, FALSE);
      vsf_color (vdi_handle, (dlg_colors >= 16) ? (pRegion->sBkColor == DWHITE) ? DBLACK : DWHITE : BLACK);
      vsf_interior (vdi_handle, FIS_PATTERN);
      vsf_style (vdi_handle, (dlg_colors >= 16) ? 8 : 4);
      rect2array (&rc, xy);

      if ((x <= window->work.x + window->work.w) && (rc.w > 0) && (rc.h > 0))
        v_bar (vdi_handle, xy);			/* draw right area */
    } /* if */

    if (bLastRegion)				/* draw bottom area below last region */
    {
      x = window->scroll.x;
      xywh2rect (x, y + h + 1, window->scroll.w, (SHORT)(window->doc.h * window->yfac - (y - window->scroll.y + window->doc.y * window->yfac)), &rc);
      rect2array (&rc, xy);

      if ((y + h + 1 <= window->work.y + window->work.h) && (rc.w > 0) && (rc.h > 0))
        v_bar (vdi_handle, xy);
    } /* if */

    DrawObjects (window, pRegion, DRAW_OBJECT);
    DrawObjects (window, pRegion, DRAW_HANDLES);
  } /* if */

  y           += h;
  sLastHeight  = h;

  if (bLastRegion)
    sLastHeight = 0;

  return (y);
} /* DrawRegion */

/*****************************************************************************/

LOCAL VOID DrawObjects (WINDOWP window, ACC_REGION *pRegion, SHORT sMode)
{
  SHORT i;
  RECT  rc;

  GetRegionRect (window, pRegion, &rc);

  for (i = 0; i < pRegion->sNumObjects; i++)
    DrawObject (window, &pRegion->pObjects [i], pRegion->sBkColor, rc, sMode);
} /* DrawObjects */

/*****************************************************************************/

LOCAL VOID DrawObject (WINDOWP window, ACC_OBJECT *pObject, SHORT sBkColor, RECT rcRegion, SHORT sMode)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT         rc, r, save;
  SHORT        xy [4], sBorderWidth;
  CHAR         *pText;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  rc.x     = rcRegion.x + PIXELS_FROM_UNITS (pObject->rcPos.x, window->xfac);
  rc.y     = rcRegion.y + PIXELS_FROM_UNITS (pObject->rcPos.y, window->yfac);
  rc.w     = PIXELS_FROM_UNITS (pObject->rcPos.w, window->xfac);
  rc.h     = PIXELS_FROM_UNITS (pObject->rcPos.h, window->yfac);

  if ((rc.w > 0) && (rc.h > 0))
  {
    hide_mouse ();

    save = clip;
    r    = rc;

    if (sMode & DRAW_OBJECT)
      if (rc_intersect (&window->scroll, &r))
        if (rc_intersect (&clip, &r))
          if (rc_intersect (&rcRegion, &r))
          {
            set_clip (TRUE, &r);
            rect2array (&rc, xy);

            pText = NULL;

            if (AccObjHasProperty (pObject->sClass, ACC_PROP_TEXT))
              pText = pObject->pText;

            if ((pText == NULL) || (*pText == EOS))
              if (AccObjHasProperty (pObject->sClass, ACC_PROP_FILENAME))
                pText = pObject->pFileName;

            if ((pText == NULL) || (*pText == EOS))
              if (AccObjHasProperty (pObject->sClass, ACC_PROP_ACCOUNTNAME))
                pText = pObject->pAccountName;

            if ((pText == NULL) || (*pText == EOS))
              if (AccObjHasProperty (pObject->sClass, ACC_PROP_COLUMN))
                pText = pObject->pColumn;

            pObject->lFlags |= OBJ_IS_SELECTED;			/* draw checkbox and radio button as selected */

            AccObjDraw (pObject, vdi_handle, rc, pText, TYPE_CHAR, pAccSpec->lFontScaleFactor, 1000L * window->xfac);

            pObject->lFlags &= ~OBJ_IS_SELECTED;
            sBorderWidth     = 0;

            if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_MODE))
              if (pObject->sBorderMode != MODE_TRANSPARENT)
              {
                sBorderWidth = PIXELS_FROM_UNITS (pObject->lBorderWidth, window->xfac);

               if ((sBorderWidth == 0) && (pObject->lBorderWidth != 0))		/* use at least one pixel */
                 sBorderWidth = 1;
              } /* if, if */

            if ((sBorderWidth == 0) || (pObject->sBorderColor == sBkColor))	/* draw standard border */
            {
              vswr_mode (vdi_handle, MD_TRANS);
              vsf_color (vdi_handle, (sBkColor == DBLACK) ? BLACK : (sBkColor == DWHITE) ? DBLACK : DWHITE);
              vsf_interior (vdi_handle, FIS_HOLLOW);
              vsf_perimeter (vdi_handle, TRUE);
              v_bar (vdi_handle, xy);
            } /* if */
          } /* if, if, if, if */

    r = rc;
    rc_inflate (&r, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
    set_clip (TRUE, &save);

    if (sMode & DRAW_HANDLES)
      if (pObject->lFlags & OBJ_SELECTED)
        if (rc_intersect (&window->scroll, &r))
          if (rc_intersect (&clip, &r))
            if (rc_intersect (&rcRegion, &r))
            {
              set_clip (TRUE, &r);
              DrawHandles (&rc);
            } /* if, if, if, if, if */

    set_clip (TRUE, &save);
    show_mouse ();
  } /* if */
} /* DrawObject */

/*****************************************************************************/

LOCAL BOOL InAccountSizer (WINDOWP window, MKINFO *mk)
{
  BOOL         bInSizer;
  ACCOUNT_SPEC *pAccSpec;
  SHORT        w, h;
  RECT         rc;

  bInSizer = FALSE;
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  w = (SHORT)(PIXELS_FROM_UNITS (pAccSpec->account.lWidth, window->xfac) - window->doc.x * window->xfac);
  h = (SHORT)(pAccSpec->sNumRegions * GROUPSEPHEIGHT + PIXELS_FROM_UNITS (CalcRegionsHeight (&pAccSpec->account), window->yfac) - window->doc.y * window->yfac + 1);	/* 1 because of outlined */

  if ((w >= 0) && (h > 0))
  {
    xywh2rect (window->scroll.x + w - gl_wbox / 2, window->scroll.y, gl_wbox, h, &rc);
    bInSizer = inside (mk->mox, mk->moy, &rc);
  } /* if */

  return (bInSizer);
} /* InAccountSizer */

/*****************************************************************************/

LOCAL BOOL InRegionSizer (WINDOWP window, MKINFO *mk, SHORT *pStartY, ACC_REGION **ppRegion)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        y, i;
  RECT         rc;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  y        = (SHORT)window->scroll.y - window->doc.y * window->yfac;

  for (i = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion   = *ppRegion = pAccSpec->pRegions [i];
    *pStartY  = y + GROUPSEPHEIGHT;
    y        += GROUPSEPHEIGHT + PIXELS_FROM_UNITS (pRegion->lHeight, window->yfac);

    xywh2rect (window->work.x, y - gl_hbox / 4 , window->work.w, gl_hbox / 2, &rc);

    if (inside (mk->mox, mk->moy, &rc))
      return (TRUE);
  } /* if */

  *pStartY  = 0;
  *ppRegion = NULL;

  return (FALSE);
} /* InRegionSizer */

/*****************************************************************************/

LOCAL SHORT ObjectFromPoint (WINDOWP window, SHORT x, SHORT y, ACC_OBJECT **pObject)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        ret, obj, i, j;
  RECT         r;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  ret      = FAILURE;

  if (pObject != NULL)
    *pObject = NULL;

  for (i = obj = 0; (i < pAccSpec->sNumRegions) && (ret == FAILURE); i++)
  {
    pRegion = pAccSpec->pRegions [i];

    for (j = 0; j < pRegion->sNumObjects; j++, obj++)
    {
      GetObjectRect (window, pRegion, j, &r);

      if (inside (x, y, &r))			/* in rectangle */
      {
        ret = obj;

        if (pObject != NULL)
          *pObject = &pRegion->pObjects [j];
      } /* if */
    } /* for */
  } /* for */

  return (ret);
} /* ObjectFromPoint */

/*****************************************************************************/

LOCAL SHORT HandleFromPoint (WINDOWP window, SHORT x, SHORT y, SHORT *psHandleObj)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        ret, obj, i, j, k;
  RECT         r, rcHandle;

  ret      = *psHandleObj = FAILURE;
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  for (i = obj = 0; (i < pAccSpec->sNumRegions) && (ret == FAILURE); i++)
  {
    pRegion = pAccSpec->pRegions [i];

    for (j = 0; j < pRegion->sNumObjects; j++, obj++)
      if (setin (sel_objs, obj))			/* only for selected objects */
      {
        GetObjectRect (window, pRegion, j, &r);

        for (k = HANDLE_TL; k <= HANDLE_BR; k++)
          if (GetHandleSize (&r, k, &rcHandle))
            if (inside (x, y, &rcHandle))
            {
              *psHandleObj = obj;
              ret          = k;
            } /* if, if, for */
      } /* if, for */
  } /* for */

  return (ret);
} /* HandleFromPoint */

/*****************************************************************************/

LOCAL BOOL RegionFromPoint (WINDOWP window, SHORT x, SHORT y, BOOL bInclGroupSep, ACC_REGION **ppRegion)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pReg;
  SHORT        i;
  RECT         rc;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  for (i = 0; i < pAccSpec->sNumRegions; i++)
  {
    pReg = *ppRegion = pAccSpec->pRegions [i];

    GetRegionRect (window, pReg, &rc);

    if (bInclGroupSep)
    {
      rc.y -= GROUPSEPHEIGHT;
      rc.h += GROUPSEPHEIGHT;
    } /* if */

    if (inside (x, y, &rc))
      return (TRUE);
  } /* if */

  *ppRegion = NULL;

  return (FALSE);
} /* RegionFromPoint */

/*****************************************************************************/

LOCAL VOID DragAccountSizer (WINDOWP window, SHORT x)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT          r, rcDiff;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  r.x      = window->scroll.x + (SHORT)(PIXELS_FROM_UNITS (pAccSpec->account.lWidth, window->xfac) - window->doc.x * window->xfac);
  r.y      = window->scroll.y;
  r.w      = 1;
  r.h      = window->scroll.h;

  set_clip (TRUE, &desk);
  set_mouse (FLAT_HAND, NULL);
  DragLine (&r, &rcDiff, &window->scroll, use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterX, window->xfac) : 1, 0, window, &pAccSpec->account, DragFunc);
  last_mouse ();

  if (rcDiff.w != 0)
  {
    pAccSpec->iOperation      = OP_SIZE_ACCOUNT;
    pAccSpec->lOldSize        = pAccSpec->account.lWidth;
    pAccSpec->account.lWidth += UNITS_FROM_PIXELS (rcDiff.w, window->xfac);

    FixAccountWidth (pAccSpec);
    set_redraw (window, &window->work);
    SetDirty (window, TRUE, TRUE);
  } /* if */
} /* DragAccountSizer */

/*****************************************************************************/

LOCAL VOID DragRegionSizer (WINDOWP window, SHORT x, SHORT y, ACC_REGION *pRegion)
{
  ACCOUNT_SPEC *pAccSpec;
  RECT          r, rcBox, rcDiff;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  r.x      = window->scroll.x;
  r.y      = y + (SHORT)(PIXELS_FROM_UNITS (pRegion->lHeight, window->yfac));
  r.w      = window->scroll.w;
  r.h      = 1;

  rcBox.x = window->work.x;
  rcBox.y = max (window->scroll.y, y);
  rcBox.w = window->work.w;
  rcBox.h = window->scroll.h - ((y < window->scroll.y) ? 0 : y - window->scroll.y);

  set_clip (TRUE, &desk);
  set_mouse (FLAT_HAND, NULL);
  DragLine (&r, &rcDiff, &rcBox, 0, use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterY, window->yfac) : 1, window, pRegion, DragFunc);
  last_mouse ();

  if (rcDiff.h != 0)
  {
    pAccSpec->iOperation  = OP_SIZE_REGION;
    pAccSpec->lOldSize    = pRegion->lHeight;
    pRegion->lHeight     += UNITS_FROM_PIXELS (rcDiff.h, window->yfac);

    FixRegionHeight (pRegion);
    set_redraw (window, &window->work);
    SetDirty (window, TRUE, TRUE);
  } /* if */
} /* DragRegionSizer */

/*****************************************************************************/

LOCAL VOID DragObjects (WINDOWP window, SHORT obj, SET objs, ACC_REGION *pRegion)
{
  RECT         r, bound, rcRegion;
  SHORT        mox, moy, x, y, h;
  SHORT        i, j, result, num_objs, ob;
  SHORT        dest_obj;
  WINDOWP      dest_window;
  SET          inv_objs;
  RECT         *all;
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pReg;
  BOOL         bDifferent;

  if (window != NULL)
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;
    all      = mem_alloc (setcard (objs) * sizeof (RECT));	/* this shouldn't fail */

    xywh2rect (-16384, -16384, 32767, 32767, &bound);

    setclr (inv_objs);
    setincl (inv_objs, ITRASH);
    setincl (inv_objs, ICLIPBRD);

    for (i = ob = num_objs = 0, bDifferent = FALSE; i < pAccSpec->sNumRegions; i++)
    {
      pReg = pAccSpec->pRegions [i];

      GetRegionRect (window, pReg, &rcRegion);

#ifdef ALLOW_ONLY_REGIONS
      rc_union (&rcRegion, &bound);
#endif

      for (j = 0; j < pReg->sNumObjects; j++, ob++)
        if (setin (objs, ob))
        {
          if (pReg != pRegion)				/* at least two different regions involved */
            bDifferent = TRUE;

          GetObjectRect (window, pReg, j, &all [num_objs++]);
        } /* if, for */
    } /* for */

    if (bDifferent)
    {
      for (i = h = 0, y = all [0].y; i < num_objs; i++)
      {
        y = min (y, all [i].y);
        h = max (h, all [i].y + all [i].h);
      } /* for */

      GetRegionRect (window, pRegion, &bound);
      xywh2rect (bound.x, y, bound.w, h - y, &bound);
    } /* if */

    set_mouse (FLAT_HAND, NULL);
    drag_boxes (num_objs, all, find_desk (), inv_objs, &r, &bound, use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterX, window->xfac) : 1, use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterY, window->yfac) : 1);
    last_mouse ();
    graf_mkstate (&mox, &moy, &result, &result);

    result = drag_to_window (mox, moy, window, 0, &dest_window, &dest_obj);

    if (dest_window != NULL)
      if (dest_window->class == class_desk)
      {
        if ((result == DRAG_OK) && (setin (inv_objs, dest_obj)))
          switch (dest_obj)
          {
            case ITRASH   : ObjOp (window, objs, OBJ_DEL, NULL);
                            break;
            case ICLIPBRD : ObjOp (window, objs, OBJ_CLIP, NULL);
                            break;
          } /* switch, if */
      } /* if */
      else
        switch (dest_window->class)
        {
          case CLASS_TRASH  : if (result == DRAG_OK)
                                ObjOp (window, objs, OBJ_DEL, NULL);
                              break;
          case CLASS_ACCDEF : if (result == DRAG_SWIND)
                              {
                                if ((r.w != 0) || (r.h != 0))
                                  if (bDifferent)		/* move inside same region */
                                    MoveObjects (window, window, pRegion, pRegion, objs, r.w, r.h);
                                  else				/* move to possibly different region */
                                    if (RegionFromPoint (window, mox, moy, FALSE, &pReg))
                                    {
                                      for (i = 0, x = all [0].x, y = all [0].y; i < num_objs; i++)
                                      {
                                        x = min (x, all [i].x);
                                        y = min (y, all [i].y);
                                      } /* for */

                                      GetRegionRect (window, pReg, &rcRegion);

                                      if (x + r.w < rcRegion.x)		/* force to be completely inside region */
                                        r.w = rcRegion.x - x;

                                      if (y + r.h < rcRegion.y)		/* force to be completely inside region */
                                        r.h = rcRegion.y - y;

                                      MoveObjects (window, window, pRegion, pReg, objs, r.w, r.h);
                                    } /* if, else */
                              } /* if */
                              else
                                if (result == DRAG_SCLASS)
                                  if (RegionFromPoint (dest_window, mox, moy, FALSE, &pReg))
                                  {
                                    for (i = 0, x = all [0].x, y = all [0].y; i < num_objs; i++)
                                    {
                                      x = min (x, all [i].x);
                                      y = min (y, all [i].y);
                                    } /* for */

                                    GetRegionRect (dest_window, pReg, &rcRegion);

                                    if (x + r.w < rcRegion.x)		/* force to be completely inside region */
                                      r.w = rcRegion.x - x;

                                    if (y + r.h < rcRegion.y)		/* force to be completely inside region */
                                      r.h = rcRegion.y - y;

                                    MoveObjects (window, dest_window, pRegion, pReg, objs, r.w, r.h);
                                  } /* if, else */
                              break;
        } /* switch, else, if */

    mem_free (all);
  } /* if */
} /* DragObjects */

/*****************************************************************************/

LOCAL VOID SizeObject (WINDOWP window, SHORT sHandleObj, SHORT sHandlePos, ACC_REGION *pRegion)
{
  RECT         rcObject, rcDiff, rcBound, rcRegion;
  ACCOUNT_SPEC *pAccSpec;
  SHORT        i, sObj, sRasterX, sRasterY, sPixelsPerLine, ret;
  ACC_OBJECT   *pObject;
  FONTDESC     *pFont;

  if (window != NULL)
  {
    pAccSpec = (ACCOUNT_SPEC *)window->special;

    for (i = 0, sObj = sHandleObj; i < pAccSpec->sNumRegions; i++)	/* calculate object relative to region */
      if (sObj >= pAccSpec->pRegions [i]->sNumObjects)
        sObj -= pAccSpec->pRegions [i]->sNumObjects;
      else
        break;

    pObject = &pRegion->pObjects [sObj];

    GetObjectRect (window, pRegion, sObj, &rcObject);
    GetRegionRect (window, pRegion, &rcBound);
    xywh2rect (rcBound.x, rcBound.y, desk.w - rcBound.x , desk.h - rcBound.y, &rcBound);

    sRasterX = use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterX, window->xfac) : 1;
    sRasterY = use_raster ? PIXELS_FROM_UNITS (pAccSpec->account.lRasterY, window->yfac) : 1;

    sPixelsPerLine = 0;

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_FONT_FONT))
    {
      pFont = &pObject->Font;

      text_default (vdi_handle);
      vst_font (vdi_handle, pFont->font);
      vst_arbpoint (vdi_handle, (SHORT)((pFont->point * pAccSpec->lFontScaleFactor + 500) / 1000), &ret, &ret, &ret, &ret);
      vst_effects (vdi_handle, pFont->effects);
      text_extent (vdi_handle, "x", TRUE, NULL, &sPixelsPerLine);
    } /* if */

    set_mouse (THIN_CROSS, NULL);
    SizeBox (&rcObject, &rcDiff, &rcBound, sRasterX, sRasterY, sRasterX, sRasterY, window, &sPixelsPerLine, SizeFunc, sHandlePos);
    last_mouse ();

    if ((rcDiff.x != 0) || (rcDiff.y != 0) || (rcDiff.w != 0) || (rcDiff.h != 0))
    {
      pAccSpec->iOperation = OP_SIZE_OBJECT;
      pAccSpec->rcDiff     = rcDiff;

      GetRegionRect (window, pRegion, &rcRegion);
      rc_inflate (&rcObject, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
      set_redraw (window, &rcObject);
      rc_inflate (&rcObject, - HANDLE_SIZE / 2, - HANDLE_SIZE / 2);

      pObject->rcPos.x = UNITS_FROM_PIXELS (rcObject.x + rcDiff.x - rcRegion.x, window->xfac);
      pObject->rcPos.y = UNITS_FROM_PIXELS (rcObject.y + rcDiff.y - rcRegion.y, window->yfac);
      pObject->rcPos.w = UNITS_FROM_PIXELS (rcObject.w + rcDiff.w, window->xfac);
      pObject->rcPos.h = UNITS_FROM_PIXELS (rcObject.h + rcDiff.h, window->yfac);

      GetObjectRect (window, pRegion, sObj, &rcObject);
      rc_inflate (&rcObject, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
      set_redraw (window, &rcObject);

      FixSize (window, pRegion, pObject);
      SetDirty (window, TRUE, TRUE);
    } /* if */
  } /* if */
} /* SizeObject */

/*****************************************************************************/

LOCAL VOID DragFunc (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p)
{
  STRING     s, Str;
  DOUBLE     d;
  ACCOUNT    *pAccount;
  ACC_REGION *pRegion;
  CHAR       *pPeriod, *pPos, *pInfo;

  switch (msg)
  {
    case DM_START  : /* fall through */
    case DM_CHANGE : if (x_raster != 0)		/* horizontal dragging */
                     {
                       pAccount = p;
                       d        = (pAccount->lWidth + UNITS_FROM_PIXELS (diff->w, window->xfac)) / 1000.0;
                     } /* if */
                     else			/* vertical dragging */
                     {
                       pRegion = p;
                       d       = (pRegion->lHeight + UNITS_FROM_PIXELS (diff->h, window->yfac)) / 1000.0;
                     } /* else */

                     bin2str (TYPE_FLOAT, &d, Str);
                     pPeriod = FREETXT (FSEP);

                     if ((pPos = strchr (Str, '.')) != NULL)
                       *pPos = pPeriod [0];

                     sprintf (s, FREETXT ((x_raster != 0) ? ACCOUNT_WIDTH : ACCOUNT_HEIGHT), Str);
                     pInfo = s;
                     break;
    case DM_FINISH : pInfo = "";
                     break;
  } /* switch */

  set_str (accicon, ACCINFO, pInfo);
  draw_win_obj (window, accicon, ACCINFO);
} /* DragFunc */

/*****************************************************************************/

LOCAL VOID SizeFunc (INT msg, CONST RECT *r, RECT *diff, RECT *bound, SHORT x_raster, SHORT y_raster, WINDOWP window, VOID *p)
{
  STRING s, StrX, StrY, StrWidth, StrHeight;
  DOUBLE dX, dY, dWidth, dHeight;
  CHAR   *pPeriod, *pPos, *pInfo;
  SHORT  *psPixelsPerLine;

  switch (msg)
  {
    case SM_START  : /* fall through */
    case SM_CHANGE : dX      = UNITS_FROM_PIXELS (r->x + diff->x - bound->x, window->xfac) / 1000.0;
                     dY      = UNITS_FROM_PIXELS (r->y + diff->y - bound->y, window->xfac) / 1000.0;
                     dWidth  = UNITS_FROM_PIXELS (r->w + diff->w, window->xfac) / 1000.0;
                     dHeight = UNITS_FROM_PIXELS (r->h + diff->h, window->xfac) / 1000.0;
                     pPeriod = FREETXT (FSEP);

                     psPixelsPerLine = p;

                     bin2str (TYPE_FLOAT, &dX, StrX);

                     if ((pPos = strchr (StrX, '.')) != NULL)
                       *pPos = pPeriod [0];

                     bin2str (TYPE_FLOAT, &dY, StrY);

                     if ((pPos = strchr (StrY, '.')) != NULL)
                       *pPos = pPeriod [0];

                     bin2str (TYPE_FLOAT, &dWidth, StrWidth);

                     if ((pPos = strchr (StrWidth, '.')) != NULL)
                       *pPos = pPeriod [0];

                     bin2str (TYPE_FLOAT, &dHeight, StrHeight);

                     if ((pPos = strchr (StrHeight, '.')) != NULL)
                       *pPos = pPeriod [0];

                     if ((psPixelsPerLine != NULL) && (*psPixelsPerLine != 0))
                       sprintf (s, FREETXT (ACCOUNT_SIZE_LINES), StrX, StrY, StrWidth, StrHeight, (r->h + diff->h) / *psPixelsPerLine);
                     else
                       sprintf (s, FREETXT (ACCOUNT_SIZE), StrX, StrY, StrWidth, StrHeight);
                     pInfo = s;
                     break;
    case SM_FINISH : pInfo = "";
                     break;
  } /* switch */

  set_str (accicon, ACCINFO, pInfo);
  draw_win_obj (window, accicon, ACCINFO);
} /* SizeFunc */

/*****************************************************************************/

LOCAL BOOL FixAccountWidth (ACCOUNT_SPEC *pAccSpec)
{
  ACC_REGION *pRegion;
  SHORT      i, j;
  LONG       lWidth, lOldWidth;

  for (i = 0, lWidth = pAccSpec->account.lWidth; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    for (j = 0; j < pRegion->sNumObjects; j++)
      lWidth = max (lWidth, pRegion->pObjects [j].rcPos.x + pRegion->pObjects [j].rcPos.w);
  } /* for */

  lOldWidth                = pAccSpec->account.lWidth;
  pAccSpec->account.lWidth = lWidth;

  return (lOldWidth != lWidth);
} /* FixAccountWidth */

/*****************************************************************************/

LOCAL BOOL FixRegionHeight (ACC_REGION *pRegion)
{
  SHORT i;
  LONG  lHeight, lOldHeight;

  for (i = 0, lHeight = pRegion->lHeight; i < pRegion->sNumObjects; i++)
    lHeight = max (lHeight, pRegion->pObjects [i].rcPos.y + pRegion->pObjects [i].rcPos.h);

  lOldHeight       = pRegion->lHeight;
  pRegion->lHeight = lHeight;

  return (lOldHeight != lHeight);
} /* FixRegionHeight */

/*****************************************************************************/

LOCAL VOID SetSelObjs (WINDOWP window)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        i, j, obj;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  setclr (sel_objs);

  for (i = obj = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    for (j = 0; j < pRegion->sNumObjects; j++, obj++)
      if (pRegion->pObjects [j].lFlags & OBJ_SELECTED)
        setincl (sel_objs, obj);
  } /* for */

  sel_window = setcmp (sel_objs, NULL) ? NULL : window;
} /* SetSelObjs */

/*****************************************************************************/

LOCAL VOID CalcSelObjs (WINDOWP window, SET objs, CONST RECT *rc)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        i, j, obj;
  RECT         r;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  setclr (objs);

  for (i = obj = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    for (j = 0; j < pRegion->sNumObjects; j++, obj++)
    {
      GetObjectRect (window, pRegion, j, &r);

      if (rc_intersect (rc, &r))			/* in rectangle */
        if (rc_intersect (&window->scroll, &r))		/* in scrolling area */
          setincl (objs, obj);
    } /* for */
  } /* for */
} /* CalcSelObjs */

/*****************************************************************************/

LOCAL VOID InvertObjs (WINDOWP window, SET objs, BOOL bSetFlag)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pRegion;
  SHORT        i, j, obj;
  RECT         r, inv, save, rcObject, rcRegion;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  save     = clip;

  wind_update (BEG_UPDATE);
  hide_mouse ();

  for (i = obj = 0; i < pAccSpec->sNumRegions; i++)
  {
    pRegion = pAccSpec->pRegions [i];

    GetRegionRect (window, pRegion, &rcRegion);

    for (j = 0; j < pRegion->sNumObjects; j++, obj++)
      if (setin (objs, obj))
      {
        if (bSetFlag)
          pRegion->pObjects [j].lFlags ^= OBJ_SELECTED;

        GetObjectRect (window, pRegion, j, &rcObject);

        inv = rcObject;
        rc_inflate (&inv, HANDLE_SIZE / 2, HANDLE_SIZE / 2);

        wind_get (window->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

        while ((r.w != 0) && (r.h != 0))
        {
          if (rc_intersect (&window->scroll, &r))
            if (rc_intersect (&rcRegion, &r))
              if (rc_intersect (&r, &inv))
              {
                set_clip (TRUE, &inv);			/* visible area */
                DrawHandles (&rcObject);
              } /* if, if, if */

          wind_get (window->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
        } /* while */
      } /* if, for */
  } /* for */

  show_mouse ();
  wind_update (END_UPDATE);
  set_clip (TRUE, &save);
} /* InvertObjs */

/*****************************************************************************/

LOCAL VOID RubberBand (WINDOWP window, ACC_REGION *pRegion, MKINFO *mk, RECT *rc, SHORT sClass)
{
  ACCOUNT_SPEC *pAccSpec;
  SHORT        sRasterX, sRasterY, sPixelsPerLine, ret;
  SET          new_objs;
  RECT         rcRegion, rcBound, rcDiff;
  FONTDESC     *pFont;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  rc->x    = mk->mox;
  rc->y    = mk->moy;
  rc->w    = rc->h    = 0;
  sRasterX = sRasterY = 1;

  GetRegionRect (window, pRegion, &rcRegion);

  if (pAccSpec->sMode != ACCARROW)			/* raster x/y position */
  {
    if (use_raster && (pAccSpec->account.lRasterX != 0))
    {
      sRasterX = PIXELS_FROM_UNITS (pAccSpec->account.lRasterX, window->xfac);

      if (sRasterX != 0)
        rc->x = (rc->x - rcRegion.x) / sRasterX * sRasterX + rcRegion.x;
    } /* if */

    if (use_raster && (pAccSpec->account.lRasterY != 0))
    {
      sRasterY = PIXELS_FROM_UNITS (pAccSpec->account.lRasterY, window->yfac);

      if (sRasterY != 0)
        rc->y = (rc->y - rcRegion.y) / sRasterY * sRasterY + rcRegion.y;
    } /* if */
  } /* if */

  rcBound = rcRegion;
  xywh2rect (rcBound.x, rcBound.y, desk.w - rcBound.x , desk.h - rcBound.y, &rcBound);

  set_mouse ((pAccSpec->sMode == ACCARROW) ? POINT_HAND : THIN_CROSS, NULL);

  if (pAccSpec->sMode != ACCARROW)
  {
    sPixelsPerLine = 0;

    if (AccObjHasProperty (sClass, ACC_PROP_FONT_FONT))
    {
      pFont = &fontdesc;

      text_default (vdi_handle);
      vst_font (vdi_handle, pFont->font);
      vst_arbpoint (vdi_handle, (SHORT)((pFont->point * pAccSpec->lFontScaleFactor + 500) / 1000), &ret, &ret, &ret, &ret);
      vst_effects (vdi_handle, pFont->effects);
      text_extent (vdi_handle, "x", TRUE, NULL, &sPixelsPerLine);
    } /* if */

    SizeBox (rc, &rcDiff, &rcBound, 0, 0, sRasterX, sRasterY, window, &sPixelsPerLine, SizeFunc, HANDLE_BR);

    rc->w += rcDiff.w;
    rc->h += rcDiff.h;
  } /* if */
  else
  {
    graf_rubbox (rc->x, rc->y, -rc->x, -rc->y, &rc->w, &rc->h);

    if (rc->w < 0)
    {
      rc->x += rc->w;
      rc->w  = - rc->w;
    } /* if */

    if (rc->h < 0)
    {
      rc->y += rc->h;
      rc->h  = - rc->h;
    } /* if */
  } /* else */

  last_mouse ();

  if (pAccSpec->sMode == ACCARROW)			/* normal rubber band operation */
  {
    if (mk->shift)					/* select exclusive */
    {
      CalcSelObjs (window, new_objs, rc);
      InvertObjs (window, new_objs, TRUE);
      setxor (sel_objs, new_objs);
    } /* if */
    else
      if (mk->ctrl)					/* select additional */
      {
        CalcSelObjs (window, new_objs, rc);
        setnot (sel_objs);
        setand (new_objs, sel_objs);
        setnot (sel_objs);
        InvertObjs (window, new_objs, TRUE);
        setor (sel_objs, new_objs);
      } /* if */
      else						/* select */
      {
        CalcSelObjs (window, sel_objs, rc);
        InvertObjs (window, sel_objs, TRUE);
      } /* else */

    sel_window = setcmp (sel_objs, NULL) ? NULL : window;
  } /* if */
} /* RubberBand */

/*****************************************************************************/

LOCAL VOID GetRegionRect (WINDOWP window, ACC_REGION *pRegion, RECT *rc)
{
  ACCOUNT_SPEC *pAccSpec;
  ACC_REGION   *pReg;
  SHORT        x, y, i;

  pAccSpec = (ACCOUNT_SPEC *)window->special;
  x        = (SHORT)(window->scroll.x - window->doc.x * window->xfac);
  y        = (SHORT)(window->scroll.y - window->doc.y * window->yfac);

  xywh2rect (0, 0, 0, 0, rc);

  for (i = 0; i < pAccSpec->sNumRegions; i++)
  {
    pReg  = pAccSpec->pRegions [i];
    y    += GROUPSEPHEIGHT;

    if (pRegion == pReg)
    {
      rc->x = x;
      rc->y = y;
      rc->w = PIXELS_FROM_UNITS (pAccSpec->account.lWidth, window->xfac);
      rc->h = PIXELS_FROM_UNITS (pReg->lHeight, window->yfac);

      return;
    } /* if */

    y += PIXELS_FROM_UNITS (pReg->lHeight, window->yfac);
  } /* if */
} /* GetRegionRect */

/*****************************************************************************/

LOCAL VOID GetObjectRect (WINDOWP window, ACC_REGION *pRegion, SHORT obj, RECT *rc)
{
  ACC_OBJECT *pObject;
  RECT       r;

  xywh2rect (0, 0, 0, 0, rc);

  if ((0 <= obj) && (obj < pRegion->sNumObjects))
  {
    GetRegionRect (window, pRegion, &r);

    pObject = &pRegion->pObjects [obj];
    rc->x   = r.x + PIXELS_FROM_UNITS (pObject->rcPos.x, window->xfac);
    rc->y   = r.y + PIXELS_FROM_UNITS (pObject->rcPos.y, window->yfac);
    rc->w   = PIXELS_FROM_UNITS (pObject->rcPos.w, window->xfac);
    rc->h   = PIXELS_FROM_UNITS (pObject->rcPos.h, window->yfac);
  } /* if */
} /* GetObjectRect */

/*****************************************************************************/

LOCAL BOOL FixSize (WINDOWP window, ACC_REGION *pRegion, ACC_OBJECT *pObject)
{
  BOOL         bFixed    = FALSE;
  ACCOUNT_SPEC *pAccSpec = (ACCOUNT_SPEC *)window->special;

  if (pObject->rcPos.y + pObject->rcPos.h > pRegion->lHeight)		/* object is larger */
  {
    bFixed           = TRUE;
    pRegion->lHeight = pObject->rcPos.y + pObject->rcPos.h;

    set_redraw (window, &window->work);
  } /* if */

  if (pObject->rcPos.x + pObject->rcPos.w > pAccSpec->account.lWidth)	/* object is larger */
  {
    bFixed                   = TRUE;
    pAccSpec->account.lWidth = pObject->rcPos.x + pObject->rcPos.w;

    set_redraw (window, &window->work);
  } /* if */

  return (bFixed);
} /* FixSize */

/*****************************************************************************/

LOCAL BOOL NewObject (WINDOWP window, ACC_REGION *pRegion, SHORT sClass, RECT rc, CHAR *pText, CHAR *pTable, CHAR *pColumn, BOOL bDraw)
{
  BOOL       bOk;
  RECT       rcRegion;
  ACC_OBJECT *pObject;

  bOk = TRUE;

  if (pRegion->pObjects == NULL)
    pRegion->pObjects = mem_alloc (sizeof (ACC_OBJECT));
  else
    pRegion->pObjects = mem_realloc (pRegion->pObjects, (pRegion->sNumObjects + 1) * sizeof (ACC_OBJECT));

  bOk = pRegion->pObjects != NULL;

  if (bOk)
  {
    pObject = &pRegion->pObjects [pRegion->sNumObjects++];

    GetRegionRect (window, pRegion, &rcRegion);
    SetObjectDefault (pObject, sClass, pText, pTable, pColumn);

    if (rc.x < rcRegion.x)			/* left edge */
      rc.x = rcRegion.x;

    if (rc.y < rcRegion.y)			/* top edge */
      rc.y = rcRegion.y;

    pObject->lFlags  |= OBJ_SELECTED;
    pObject->rcPos.x  = UNITS_FROM_PIXELS (rc.x - rcRegion.x, window->xfac);
    pObject->rcPos.y  = UNITS_FROM_PIXELS (rc.y - rcRegion.y, window->yfac);
    pObject->rcPos.w  = UNITS_FROM_PIXELS (rc.w, window->xfac);
    pObject->rcPos.h  = UNITS_FROM_PIXELS (rc.h, window->yfac);

    if (FixSize (window, pRegion, pObject))
      bDraw = FALSE;								/* whole area is drawn, no need to draw object */

    GetRegionRect (window, pRegion, &rcRegion);
    SetSelObjs (window);

    if (bDraw)
      DrawObject (window, pObject, pRegion->sBkColor, rcRegion, DRAW_OBJECT | DRAW_HANDLES);

    SetDirty (window, TRUE, TRUE);
  } /* if */

  return (bOk);
} /* NewObject */

/*****************************************************************************/

LOCAL BOOL AddObject (WINDOWP window, ACC_REGION *pRegion, ACC_OBJECT *pObject, BOOL bDraw)
{
  BOOL       bOk;
  RECT       rcRegion;
  ACC_OBJECT *pNewObject;

  bOk = TRUE;

  if (pRegion->pObjects == NULL)
    pRegion->pObjects = mem_alloc (sizeof (ACC_OBJECT));
  else
    pRegion->pObjects = mem_realloc (pRegion->pObjects, (pRegion->sNumObjects + 1) * sizeof (ACC_OBJECT));

  bOk = pRegion->pObjects != NULL;

  if (bOk)
  {
    pNewObject  = &pRegion->pObjects [pRegion->sNumObjects++];
    *pNewObject = *pObject;

    if (FixSize (window, pRegion, pNewObject))
      bDraw = FALSE;								/* whole area is drawn, no need to draw object */

    GetRegionRect (window, pRegion, &rcRegion);

    if (bDraw)
      DrawObject (window, pNewObject, pRegion->sBkColor, rcRegion, DRAW_OBJECT | DRAW_HANDLES);

    SetDirty (window, TRUE, TRUE);
  } /* if */

  return (bOk);
} /* AddObject */

/*****************************************************************************/

LOCAL BOOL DelObject (WINDOWP window, ACC_REGION *pRegion, SHORT sObj, BOOL bDraw, BOOL bFree)
{
  RECT       rcObject;
  ACC_OBJECT *pObject;

  pObject = &pRegion->pObjects [sObj];

  GetObjectRect (window, pRegion, sObj, &rcObject);
  rc_inflate (&rcObject, HANDLE_SIZE / 2, HANDLE_SIZE / 2);

  if (bFree)
    FreeObject (pObject);

  if (--pRegion->sNumObjects == 0)
  {
    mem_free (pRegion->pObjects);
    pRegion->pObjects = NULL;
  } /* if */
  else
    mem_lmove (&pRegion->pObjects [sObj], &pRegion->pObjects [sObj + 1], (pRegion->sNumObjects - sObj) * sizeof (ACC_OBJECT));

  if (bDraw)
    set_redraw (window, &rcObject);

  return (TRUE);
} /* DelObject */

/*****************************************************************************/

LOCAL VOID MoveObjects (WINDOWP src_window, WINDOWP dst_window, ACC_REGION *pRegionSrc, ACC_REGION *pRegionDst, SET objs, SHORT w, SHORT h)
{
  ACCOUNT_SPEC *pAccSpecSrc, *pAccSpecDst;
  SHORT        i, j, obj, x, y, sNumObjects;
  RECT         rcObjectOld, rcObjectNew, rcRegionSrc, rcRegionDst;
  LONG         lWidth, lHeight;
  ACC_REGION   *pRegion;
  ACC_OBJECT   *pObject, DstObject;
  MKINFO       mk;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
  mk.shift = (mk.kstate & (K_RSHIFT | K_LSHIFT)) != 0;
  mk.ctrl  = (mk.kstate & K_CTRL) != 0;
  mk.alt   = (mk.kstate & K_ALT) != 0;

  if (src_window != dst_window)					/* different windows, so copy always */
    mk.shift = TRUE;

  pAccSpecSrc = (ACCOUNT_SPEC *)src_window->special;
  pAccSpecDst = (ACCOUNT_SPEC *)dst_window->special;
  lWidth      = UNITS_FROM_PIXELS (w, src_window->xfac);
  lHeight     = UNITS_FROM_PIXELS (h, src_window->xfac);

  if ((pRegionSrc == pRegionDst) && ! mk.shift)
  {
    pAccSpecSrc->iOperation = OP_MOVE_OBJECTS;
    pAccSpecSrc->rcDiff.w   = w;
    pAccSpecSrc->rcDiff.h   = h;

    for (i = obj = 0; i < pAccSpecSrc->sNumRegions; i++)
    {
      pRegion = pAccSpecSrc->pRegions [i];

      for (j = 0; j < pRegion->sNumObjects; j++, obj++)
        if (setin (objs, obj))
        {
          GetObjectRect (src_window, pRegion, j, &rcObjectOld);
          rc_inflate (&rcObjectOld, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
          set_redraw (src_window, &rcObjectOld);

          pObject           = &pRegion->pObjects [j];
          pObject->rcPos.x += lWidth;
          pObject->rcPos.y += lHeight;

          GetObjectRect (src_window, pRegion, j, &rcObjectNew);
          rc_inflate (&rcObjectNew, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
          set_redraw (src_window, &rcObjectNew);
        } /* if, for */
    } /* for */
  } /* if */
  else							/* to different region */
  {
    pAccSpecSrc->iOperation = OP_NONE;			/* too difficult for now */

    GetRegionRect (src_window, pRegionSrc, &rcRegionSrc);
    GetRegionRect (dst_window, pRegionDst, &rcRegionDst);

    sNumObjects = pRegionSrc->sNumObjects;		/* number of objects will change because of add operation */

    for (j = 0; j < sNumObjects; j++)
    {
      pObject = &pRegionSrc->pObjects [j];

      if (pObject->lFlags & OBJ_SELECTED)		/* move to destination */
      {
        GetObjectRect (src_window, pRegionSrc, j, &rcObjectOld);
        rc_inflate (&rcObjectOld, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
        set_redraw (src_window, &rcObjectOld);

        x = PIXELS_FROM_UNITS (pObject->rcPos.x, src_window->xfac) + w - (rcRegionDst.x - rcRegionSrc.x);
        y = PIXELS_FROM_UNITS (pObject->rcPos.y, src_window->yfac) + h - (rcRegionDst.y - rcRegionSrc.y);

        if (mk.shift)
        {
          AccCopyObject (&DstObject, pObject);

          DstObject.rcPos.x = UNITS_FROM_PIXELS (x, dst_window->xfac);
          DstObject.rcPos.y = UNITS_FROM_PIXELS (y, dst_window->yfac);

          AddObject (dst_window, pRegionDst, &DstObject, FALSE);
        } /* if */
        else
        {
          pObject->rcPos.x = UNITS_FROM_PIXELS (x, dst_window->xfac);
          pObject->rcPos.y = UNITS_FROM_PIXELS (y, dst_window->yfac);

          AddObject (dst_window, pRegionDst, pObject, FALSE);	/* add this object, will be removed later */
        } /* else */

        GetObjectRect (dst_window, pRegionDst, pRegionDst->sNumObjects - 1, &rcObjectOld);
        rc_inflate (&rcObjectOld, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
        set_redraw (dst_window, &rcObjectOld);
      } /* if */
    } /* for */

    if (mk.shift)						/* deselect original objects */
      for (j = 0; j < sNumObjects; j++)
      {
        pObject = &pRegionSrc->pObjects [j];

        if (pObject->lFlags & OBJ_SELECTED)
        {
          pObject->lFlags &= ~OBJ_SELECTED;

          GetObjectRect (src_window, pRegionSrc, j, &rcObjectNew);
          rc_inflate (&rcObjectNew, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
          set_redraw (src_window, &rcObjectNew);
        } /* if */
      } /* for, if */
    else
      for (j = sNumObjects - 1; j >= 0; j--)
      {
        pObject = &pRegionSrc->pObjects [j];

        if (pObject->lFlags & OBJ_SELECTED)
          DelObject (src_window, pRegionSrc, j, FALSE, FALSE);
      } /* for, else */
  } /* else */

  if (FixAccountWidth (pAccSpecDst))
    set_redraw (dst_window, &dst_window->work);

  if (FixRegionHeight (pRegionDst))
    set_redraw (dst_window, &dst_window->work);

  SetSelObjs (dst_window);
  SetDirty (dst_window, TRUE, TRUE);
} /* MoveObjects */

/*****************************************************************************/

LOCAL VOID FreeObject (ACC_OBJECT *pObject)
{
  AccFreeObject (pObject);
} /* FreeObject */

/*****************************************************************************/

LOCAL BOOL GetPropertyName (SHORT sProperty, CHAR *pName)
{
  BOOL bOk;

  bOk = (sProperty >= 0) && (sProperty < ACC_NUM_PROPERTIES);

  if (bOk)
    strcpy (pName, FREETXT (asPropertyName [sProperty]));
  else
    *pName = EOS;

  return (bOk);
} /* GetPropertyName */

/*****************************************************************************/

LOCAL BOOL UpdateProperties (WINDOWP window, BOOL bTopIt, ACC_REGION *pRegion)
{
  BOOL    bOk;
  WINDOWP pPropWnd;

  if (bTopIt)					/* top existing or open new window */
    bOk = TRUE;
  else						/* modify existing window only */
    bOk = search_window (CLASS_PROPERTY, SRCH_OPENED, NIL) != NULL;

  if (bOk)
  {
    if (sel_window == window)			/* selected objects of account window */
      bOk = InitProperties (window, SP_OBJECTS, NULL);
    else					/* the account itself or a region */
      if (pRegion == NULL)			/* the account */
        bOk = InitProperties (window, SP_ACCOUNT, NULL);
      else					/* a region */
        bOk = InitProperties (window, SP_REGION, pRegion);

    if (bOk)
    {
      if (bTopIt)
        bOk = PropertyOpen (NIL);

      pPropWnd = search_window (CLASS_PROPERTY, SRCH_OPENED, NIL);

      if (bOk && (pPropWnd != NULL))
        SetPropertyWindow (window, pPropWnd);
    } /* if */
  } /* if */

  return (bOk);
} /* UpdateProperties */

/*****************************************************************************/

LOCAL BOOL InitProperties (WINDOWP window, SHORT sMode, ACC_REGION *pRegion)
{
  BOOL         bOk;
  ACCOUNT_SPEC *pAccSpec;
  ACC_OBJECT   *pObject;
  PROPDESC     *pPropDesc, *pPropDescs;
  SHORT        i, j, k, sNumPropDesc;
  SET          setProps, setObjProps;
  CHAR         *p;

  bOk      = TRUE;
  pAccSpec = (ACCOUNT_SPEC *)window->special;

  switch (sMode)
  {
    case SP_OBJECTS : setall (setProps);

                      for (i = 0; i < pAccSpec->sNumRegions; i++)		/* calculate set of common properties */
                      {
                        pRegion = pAccSpec->pRegions [i];

                        for (j = 0, pObject = pRegion->pObjects; j < pRegion->sNumObjects; j++, pObject++)
                          if (pObject->lFlags & OBJ_SELECTED)
                          {
                            AccObjGetProperties (pObject->sClass, setObjProps);
                            setand (setProps, setObjProps);
                          } /* if, for */
                      } /* for */

                      setexcl (setProps, ACC_PROP_CLASS);			/* user must not see these properties */
                      setexcl (setProps, ACC_PROP_FLAGS);
                      setexcl (setProps, ACC_PROP_FONT_FONT);

                      sNumPropDesc = setcard (setProps);
                      pPropDescs   = mem_alloc (sNumPropDesc * sizeof (PROPDESC));	/* these few bytes shouldn't fail to alloc */

                      for (k = 0, pPropDesc = pPropDescs; k < ACC_NUM_PROPERTIES; k++)
                        if (setin (setProps, k))
                        {
                          pPropDesc->sProperty = k;
                          pPropDesc->pszValue  = NULL;
                          pPropDesc->pszFormat = (ACC_PROP_X <= k) && (k <= ACC_PROP_H) || (k == ACC_PROP_BORDER_WIDTH) ? strdup ("990,000 cm") : NULL;

                          for (i = 0; i < pAccSpec->sNumRegions; i++)
                          {
                            pRegion = pAccSpec->pRegions [i];

                            for (j = 0, pObject = pRegion->pObjects; j < pRegion->sNumObjects; j++, pObject++)
                              if (pObject->lFlags & OBJ_SELECTED)
                                if (pPropDesc->pszValue == NULL)	/* copy as formatted string */
                                {
                                  AccObjGetPropertyStr (pObject, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);

                                  if (pPropDesc->pszValue == NULL)
                                  {
                                    hndl_alert (ERR_NOMEMORY);
                                    bOk = FALSE;
                                  } /* if */
                                } /* if */
                                else					/* compare with actual value */
                                {
                                  AccObjGetPropertyStr (pObject, pPropDesc->sProperty, pPropDesc->pszFormat, &p);

                                  if (p == NULL)
                                  {
                                    hndl_alert (ERR_NOMEMORY);
                                    bOk = FALSE;
                                  } /* if */
                                  else
                                    if (strcmp (p, pPropDesc->pszValue) == 0)	/* use old value */
                                      free (p);
                                    else
                                    {
                                      free (p);
                                      free (pPropDesc->pszValue);
                                      pPropDesc->pszValue = strdup ("");	/* use empty value */
                                    } /* else, else */
                                } /* else, if, for */
                          } /* for */

                          pPropDesc++;
                        } /* if, for */

                      pRegion = NULL;
                      break;
    case SP_ACCOUNT : AccObjGetProperties (OBJ_ACCOUNT, setProps);

                      sNumPropDesc = setcard (setProps);
                      pPropDescs   = mem_alloc (sNumPropDesc * sizeof (PROPDESC));	/* these few bytes shouldn't fail to alloc */

                      for (k = 0, pPropDesc = pPropDescs; k < ACC_NUM_PROPERTIES; k++)
                        if (setin (setProps, k))
                        {
                          pPropDesc->sProperty = k;
                          pPropDesc->pszValue  = NULL;
                          pPropDesc->pszFormat = (ACC_PROP_ACC_RASTER_X <= k) && (k <= ACC_PROP_ACC_MARGIN_BOTTOM) || (k == ACC_PROP_ACC_COLUMN_GAP) ? strdup ("990,000 cm") : NULL;

                          AccGetPropertyStr (&pAccSpec->account, OBJ_ACCOUNT, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);

                          pPropDesc++;
                        } /* if, for */

                      pRegion = NULL;
                      break;
    case SP_REGION  : AccObjGetProperties (OBJ_REGION, setProps);

                      sNumPropDesc = setcard (setProps);
                      pPropDescs   = mem_alloc (sNumPropDesc * sizeof (PROPDESC));	/* these few bytes shouldn't fail to alloc */

                      if (pRegion->bIsPageHeaderFooter)
                      {
                        setexcl (setProps, ACC_PROP_REG_NEW_PAGE);
                        sNumPropDesc--;
                      } /* if */

                      for (k = 0, pPropDesc = pPropDescs; k < ACC_NUM_PROPERTIES; k++)
                        if (setin (setProps, k))
                        {
                          pPropDesc->sProperty = k;
                          pPropDesc->pszValue  = NULL;
                          pPropDesc->pszFormat = (k == ACC_PROP_REG_HEIGHT) ? strdup ("990,000 cm") : NULL;

                          AccGetPropertyStr (pRegion, OBJ_REGION, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);

                          pPropDesc++;
                        } /* if, for */
                      break;
  } /* switch */

  if (bOk)
  {
    FreePropDesc (pAccSpec);			/* give up old values */

    pAccSpec->sPropDescMode = sMode;
    pAccSpec->pRegionProp   = pRegion;
    pAccSpec->sNumPropDesc  = sNumPropDesc;
    pAccSpec->pPropDesc     = pPropDescs;
  } /* if */

  set_meminfo ();

  return (bOk);
} /* InitProperties */

/*****************************************************************************/

LOCAL VOID SetPropertyWindow (WINDOWP window, WINDOWP pPropWnd)
{
  ACCOUNT_SPEC *pAccSpec;

  pAccSpec = (ACCOUNT_SPEC *)window->special;

  switch (pAccSpec->sPropDescMode)
  {
    case SP_OBJECTS : PropertySetProps (pPropWnd, window, pAccSpec->sNumPropDesc, ObjPropFunc); break;
    case SP_ACCOUNT : PropertySetProps (pPropWnd, window, pAccSpec->sNumPropDesc, AccPropFunc); break;
    case SP_REGION  : PropertySetProps (pPropWnd, window, pAccSpec->sNumPropDesc, RegPropFunc); break;
  } /* switch */
} /* SetPropertyWindow */

/*****************************************************************************/

LOCAL LONG ObjPropFunc (INT msg, WINDOWP window, LONG item, CHAR *p)
{
  ACCOUNT_SPEC  *pAccSpec;
  ACC_REGION    *pRegion;
  ACC_OBJECT    *pObject;
  BOOL          bOk;
  CHAR          *pStr, *pValue, *pValues, *pName;
  PROPDESC      *pPropDesc;
  SHORT         i, j, sType, sTable, s;
  SHORT         sNumTables, sTables, sNumColumns, sColumns, sNumAccounts;
  SHORT         *pTables, *pColumns;
  LONG          lNamesSize, lFilterIndex;
  RECT          rcObject;
  TABLE_INFO    table_info;
  FONTDESC      fontdesc;
  SYSACCOUNT    *pSysAccount;
  CURSOR        cursor;
  LOCAL LONGSTR szPropName;
  LOCAL CHAR    *pNames;

  pAccSpec  = (ACCOUNT_SPEC *)window->special;
  pPropDesc = &pAccSpec->pPropDesc [item];

  switch (msg)
  {
    case PN_GETNAME  : GetPropertyName (pPropDesc->sProperty, szPropName);
                       return ((LONG)szPropName);
    case PN_GETVALUE : return ((LONG)pPropDesc->pszValue);
    case PN_SETVALUE : free (pPropDesc->pszValue);
                       pPropDesc->pszValue = NULL;				/* will be set later for first object only */

                       AccObjGetPropertyType (pPropDesc->sProperty, &sType);

                       for (i = 0; i < pAccSpec->sNumRegions; i++)
                       {
                         pRegion = pAccSpec->pRegions [i];

                         for (j = 0, pObject = pRegion->pObjects; j < pRegion->sNumObjects; j++, pObject++)
                           if (pObject->lFlags & OBJ_SELECTED)
                           {
                             GetObjectRect (window, pRegion, j, &rcObject);
                             rc_inflate (&rcObject, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
                             set_redraw (window, &rcObject);

                             if (sType == TYPE_CHAR)
                             {
                               AccObjGetProperty (pObject, pPropDesc->sProperty, &pStr);
                               mem_free (pStr);					/* release old memory */
                               pStr = AccStrDup (p);
                             } /* if */
                             else
                               pStr = p;

                             AccObjSetPropertyStr (pObject, pPropDesc->sProperty, pPropDesc->pszFormat, pStr);

                             if (pPropDesc->pszValue == NULL)			/* only for first object, get new property string (other objects have same string) */
                               AccObjGetPropertyStr (pObject, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);

                             if (pPropDesc->sProperty == ACC_PROP_FONT_FACENAME)
                               pObject->Font.font = FontNumberFromName (pPropDesc->pszValue);

                             GetObjectRect (window, pRegion, j, &rcObject);			/* property size could have been changed */
                             rc_inflate (&rcObject, HANDLE_SIZE / 2, HANDLE_SIZE / 2);
                             set_redraw (window, &rcObject);

                             FixSize (window, pRegion, pObject);
                             SetDirty (window, TRUE, FALSE);
                           } /* for, if */
                       } /* for */
                       break;
    case PN_READONLY : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_COLUMN        : /* fall through */	/* will be enumerated later */
                         case ACC_PROP_TABLE         : /* fall through */
                         case ACC_PROP_ACCOUNTNAME   : /* fall through */
                         case ACC_PROP_FONT_FACENAME : return (TRUE);
                         default                     : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                       return (pValues != NULL);
                       } /* switch */
    case PN_GETVALS  : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_COLUMN        : for (i = 0, pName = NULL; (i < pAccSpec->sNumPropDesc) && (pName == NULL); i++)	/* look for tablename */
                                                         if (pAccSpec->pPropDesc [i].sProperty == ACC_PROP_TABLE)
                                                           pName = pAccSpec->pPropDesc [i].pszValue;

                                                       if ((pName == NULL) || (*pName == EOS))
                                                         return (0L);				/* no table found or no common table */
                                                       else
                                                       {
                                                         strcpy (table_info.name, pName);

                                                         if ((sTable = db_tableinfo (pAccSpec->db->base, FAILURE, &table_info)) == FAILURE)
                                                           return (0L);
                                                         else
                                                         {
                                                           db_tableinfo (pAccSpec->db->base, sTable, &table_info);
                                                           sNumColumns = table_info.cols;
                                                           pColumns    = mem_alloc (sNumColumns * sizeof (SHORT));

                                                           for (i = 1, sColumns = 0; i < sNumColumns; i++)
                                                             if (db_acc_column (pAccSpec->db->base, sTable, i) & GRANT_SELECT)
                                                               pColumns [sColumns++] = i;

                                                           SortColumns (pAccSpec, pColumns, sColumns, sTable);

                                                           for (i = 0, lNamesSize = 0; i < sColumns; i++)
                                                           {
                                                             pName       = db_fieldname (pAccSpec->db->base, sTable, pColumns [i]);
                                                             lNamesSize += strlen (pName) + 2;
                                                           } /* for */

                                                           pNames = mem_alloc (lNamesSize);

                                                           for (i = 0, pNames [0] = EOS; i < sColumns; i++)
                                                           {
                                                             pName = db_fieldname (pAccSpec->db->base, sTable, pColumns [i]);
                                                             strcat (pNames, pName);
                                                             strcat (pNames, ";");
                                                           } /* for */

                                                           mem_free (pColumns);

                                                           if (strlen (pNames) > 0)
                                                             pNames [strlen (pNames) - 1] = EOS;

                                                           return ((LONG)pNames);
                                                         } /* else */
                                                       } /* else */
                         case ACC_PROP_TABLE         : db_tableinfo (pAccSpec->db->base, SYS_TABLE, &table_info);
                                                       sNumTables = (WORD)table_info.recs;
                                                       pTables    = mem_alloc (sNumTables * sizeof (SHORT));

                                                       for (i = NUM_SYSTABLES, sTables = 0; i < sNumTables; i++)
                                                         if (db_tableinfo (pAccSpec->db->base, i, &table_info) != FAILURE)
                                                           if (table_info.cols > 0)
                                                             if (db_acc_table (pAccSpec->db->base, i) & GRANT_SELECT)
                                                               pTables [sTables++] = i;

                                                       SortTables (pAccSpec, pTables, sTables);

                                                       for (i = 0, lNamesSize = 0; i < sTables; i++)
                                                       {
                                                         pName       = db_tablename (pAccSpec->db->base, pTables [i]);
                                                         lNamesSize += strlen (pName) + 2;
                                                       } /* for */

                                                       pNames = mem_alloc (lNamesSize);

                                                       for (i = 0, pNames [0] = EOS; i < sTables; i++)
                                                       {
                                                         pName = db_tablename (pAccSpec->db->base, pTables [i]);
                                                         strcat (pNames, pName);
                                                         strcat (pNames, ";");
                                                       } /* for */

                                                       mem_free (pTables);

                                                       if (strlen (pNames) > 0)
                                                         pNames [strlen (pNames) - 1] = EOS;

                                                       return ((LONG)pNames);
                         case ACC_PROP_ACCOUNTNAME   : db_tableinfo (pAccSpec->db->base, SYS_ACCOUNT, &table_info);
                                                       sNumAccounts = (WORD)table_info.recs;
                                                       pSysAccount  = pAccSpec->db->buffer;
                                                       pNames       = (sNumAccounts == 0) ? NULL : mem_alloc ((LONG)sNumAccounts * (sizeof (FIELDNAME) + 1) + 1);

                                                       busy_mouse ();

                                                       db_initcursor (pAccSpec->db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor);

                                                       for (i = 0, pNames [0] = EOS, bOk = TRUE; (i < sNumAccounts) && bOk && db_movecursor (pAccSpec->db->base, &cursor, 1L); i++)
                                                       {
                                                         bOk = db_read (pAccSpec->db->base, SYS_ACCOUNT, pSysAccount, &cursor, 0L, FALSE);
                                                         strcat (pNames, pSysAccount->name);
                                                         strcat (pNames, ";");
                                                       } /* while */

                                                       arrow_mouse ();

                                                       if (strlen (pNames) > 0)
                                                         pNames [strlen (pNames) - 1] = EOS;

                                                       return ((LONG)pNames);
                         case ACC_PROP_FONT_FACENAME : break;
                         default                     : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                       return ((LONG)pValues);
                       } /* switch */
                       break;
    case PN_RELVALS  : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_COLUMN        : /* fall through */
                         case ACC_PROP_TABLE         : /* fall through */
                         case ACC_PROP_ACCOUNTNAME   : mem_free (pNames);
                                                       break;
                         case ACC_PROP_FONT_FACENAME : break;
                         default                     : break;
                       } /* switch */
                       break;
    case PN_SYMBOL   : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_COLUMN        : /* fall through */
                         case ACC_PROP_TABLE         : /* fall through */
                         case ACC_PROP_ACCOUNTNAME   : return (PROPSYM_ARROW);
                         case ACC_PROP_FONT_FACENAME : return (PROPSYS_ELLISPIS);
                         case ACC_PROP_FILENAME      : return (PROPSYS_ELLISPIS);
                         default                     : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                       return (pValues != NULL) ? PROPSYM_ARROW : PROPSYS_NOSYMBOL;
                       } /* switch */
    case PN_ELLIPSIS : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_FONT_FACENAME : fontdesc.font    = FontNumberFromName (p);
                                                       fontdesc.point   = atoi (pAccSpec->pPropDesc [item + 1].pszValue);
                                                       fontdesc.effects = 0;
                                                       fontdesc.color   = BLACK;

                                                       pValues = strdup (FREETXT (ACCOUNT_PROP_VAL_COLOR));

                                                       for (s = 0, pValue = strtok (pValues, ";"); pValue != NULL; s++, pValue = strtok (NULL, ";"))
                                                         if (strcmpi (pValue, pAccSpec->pPropDesc [item + 2].pszValue) == 0)
                                                         {
                                                           fontdesc.color = s;
                                                           break;
                                                         } /* if, for */

                                                       free (pValues);

                                                       if (strcmpi (pAccSpec->pPropDesc [item + 3].pszValue, FREETXT (FYES)) == 0)
                                                         fontdesc.effects |= TXT_THICKENED;

                                                       if (strcmpi (pAccSpec->pPropDesc [item + 4].pszValue, FREETXT (FYES)) == 0)
                                                         fontdesc.effects |= TXT_SKEWED;

                                                       if (strcmpi (pAccSpec->pPropDesc [item + 5].pszValue, FREETXT (FYES)) == 0)
                                                         fontdesc.effects |= TXT_UNDERLINED;

                                                       if (strcmpi (pAccSpec->pPropDesc [item + 6].pszValue, FREETXT (FYES)) == 0)
                                                         fontdesc.effects |= TXT_OUTLINED;

                                                       if (strcmpi (pAccSpec->pPropDesc [item + 7].pszValue, FREETXT (FYES)) == 0)
                                                         fontdesc.effects |= TXT_LIGHT;

                                                       if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HFONT), 0L, vdi_handle, &fontdesc))
                                                       {
                                                         FontNameFromNumber (p, fontdesc.font);

                                                         for (i = 0; i < pAccSpec->sNumRegions; i++)
                                                         {
                                                           pRegion = pAccSpec->pRegions [i];

                                                           for (j = 0, pObject = pRegion->pObjects; j < pRegion->sNumObjects; j++, pObject++)
                                                             if (pObject->lFlags & OBJ_SELECTED)
                                                               pObject->Font = fontdesc;
                                                         } /* for */

                                                         InitProperties (window, SP_OBJECTS, NULL);	/* so the other values (size, color...) are initialized and painted properly */
                                                         return (2);
                                                       } /* if */
                                                       else
                                                         return (FALSE);
                         case ACC_PROP_FILENAME      : lFilterIndex = 4;
                                                       return (get_open_filename (FOPENFIL, NULL, 0L, FFILTER_IND_IMG_GEM_TXT, &lFilterIndex, NULL, FAILURE, p, NULL));
                         default                     : return (FALSE);
                       } /* switch */
  } /* switch */

  return (0L);
} /* ObjPropFunc */

/*****************************************************************************/

LOCAL LONG AccPropFunc (INT msg, WINDOWP window, LONG item, CHAR *p)
{
  ACCOUNT_SPEC  *pAccSpec;
  CHAR          *pValues, *pName;
  PROPDESC      *pPropDesc;
  SHORT         i, sNumTables, sTables, sNumQueries, cols;
  SHORT         *pTables;
  WORD          wDevice;
  BOOL          bOk;
  INT           iNumCols;
  LONG          lNamesSize;
  RECT          rcColumn;
  TABLE_INFO    table_info;
  SYSQUERY      *pSysQuery;
  CURSOR        cursor;
  LONGSTR       szDeviceName;
  LOCAL LONGSTR szPropName;
  LOCAL CHAR    *pNames;

  pAccSpec  = (ACCOUNT_SPEC *)window->special;
  pPropDesc = &pAccSpec->pPropDesc [item];

  switch (msg)
  {
    case PN_GETNAME  : GetPropertyName (pPropDesc->sProperty, szPropName);
                       return ((LONG)szPropName);
    case PN_GETVALUE : return ((LONG)pPropDesc->pszValue);
    case PN_SETVALUE : free (pPropDesc->pszValue);

                       switch (pPropDesc->sProperty)				/* range checkings */
                       {
                         case ACC_PROP_ACC_NUM_COLUMNS : iNumCols = atoi (p);
                                                         iNumCols = max ( 1, iNumCols);
                                                         iNumCols = min (32, iNumCols);
                                                         itoa (iNumCols, p, 10);
                                                         break;
                         default                       : break;
                       } /* switch */

                       AccSetPropertyStr (&pAccSpec->account, OBJ_ACCOUNT, pPropDesc->sProperty, pPropDesc->pszFormat, p);

                       switch (pPropDesc->sProperty)				/* redraw checkings */
                       {
                         case ACC_PROP_ACC_TABLE_OR_QUERY : /* fall through */
                         case ACC_PROP_ACC_IS_TABLE       : TableNameFromQuery (pAccSpec, table_info.name);
                                                            pAccSpec->sTable = db_tableinfo (pAccSpec->db->base, FAILURE, &table_info);
                                                            cols             = (pAccSpec->sTable == FAILURE) ? 0 : table_info.cols;

                                                            if (pAccSpec->pColumns != NULL)
                                                              mem_free (pAccSpec->pColumns);

                                                            if (cols != 0)
                                                              pAccSpec->pColumns = mem_alloc ((LONG)cols * sizeof (SHORT));

                                                            for (i = 1, pAccSpec->lNumCols = 0; i < cols; i++)
                                                              if (db_acc_column (pAccSpec->db->base, pAccSpec->sTable, i) & GRANT_SELECT)
                                                                pAccSpec->pColumns [pAccSpec->lNumCols++] = i;

                                                            pAccSpec->lColInx = (pAccSpec->lNumCols == 0) ? FAILURE : 0;

                                                            SortCols (pAccSpec);
                                                            ListBoxSetCount (accicon, ACCCOLUM, pAccSpec->lNumCols, NULL);
                                                            ListBoxSetCurSel (accicon, ACCCOLUM, pAccSpec->lColInx);
                                                            objc_rect (accicon, ACCCOLUM, &rcColumn, FALSE);
                                                            set_redraw (window, &rcColumn);
                                                            break;
                         case ACC_PROP_ACC_WIDTH          : FixAccountWidth (pAccSpec);
                                                            set_redraw (window, &window->scroll);
                                                            break;
                         default                          : break;
                       } /* switch */

                       AccGetPropertyStr (&pAccSpec->account, OBJ_ACCOUNT, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);
                       SetDirty (window, TRUE, FALSE);
                       break;
    case PN_READONLY : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_ACC_TABLE_OR_QUERY : /* fall through */
                         case ACC_PROP_ACC_PRINTER        : return (TRUE);	/* will be enumerated later */
                         default                          : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                            return (pValues != NULL);
                       } /* switch */
    case PN_GETVALS  : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_ACC_TABLE_OR_QUERY : if (pAccSpec->account.bTable)
                                                            {
                                                              db_tableinfo (pAccSpec->db->base, SYS_TABLE, &table_info);
                                                              sNumTables = (WORD)table_info.recs;
                                                              pTables    = mem_alloc (sNumTables * sizeof (SHORT));

                                                              for (i = NUM_SYSTABLES, sTables = 0; i < sNumTables; i++)
                                                                if (db_tableinfo (pAccSpec->db->base, i, &table_info) != FAILURE)
                                                                  if (table_info.cols > 0)
                                                                    if (db_acc_table (pAccSpec->db->base, i) & GRANT_SELECT)
                                                                      pTables [sTables++] = i;

                                                              SortTables (pAccSpec, pTables, sTables);

                                                              for (i = 0, lNamesSize = 0; i < sTables; i++)
                                                              {
                                                                pName       = db_tablename (pAccSpec->db->base, pTables [i]);
                                                                lNamesSize += strlen (pName) + 2;
                                                              } /* for */

                                                              pNames = mem_alloc (lNamesSize);

                                                              for (i = 0, pNames [0] = EOS; i < sTables; i++)
                                                              {
                                                                pName = db_tablename (pAccSpec->db->base, pTables [i]);
                                                                strcat (pNames, pName);
                                                                strcat (pNames, ";");
                                                              } /* for */

                                                              mem_free (pTables);
                                                            } /* if */
                                                            else
                                                            {
                                                              db_tableinfo (pAccSpec->db->base, SYS_QUERY, &table_info);
                                                              sNumQueries = (WORD)table_info.recs;
                                                              pSysQuery   = pAccSpec->db->buffer;
                                                              pNames      = (sNumQueries == 0) ? NULL : mem_alloc ((LONG)sNumQueries * (sizeof (FIELDNAME) + 1) + 1);

                                                              busy_mouse ();

                                                              db_initcursor (pAccSpec->db->base, SYS_QUERY, 1, ASCENDING, &cursor);

                                                              for (i = 0, pNames [0] = EOS, bOk = TRUE; (i < sNumQueries) && bOk && db_movecursor (pAccSpec->db->base, &cursor, 1L); i++)
                                                              {
                                                                bOk = db_read (pAccSpec->db->base, SYS_QUERY, pSysQuery, &cursor, 0L, FALSE);
                                                                strcat (pNames, pSysQuery->name);
                                                                strcat (pNames, ";");
                                                              } /* while */

                                                              arrow_mouse ();
                                                            } /* else */

                                                            if (strlen (pNames) > 0)
                                                              pNames [strlen (pNames) - 1] = EOS;

                                                            return ((LONG)pNames);
                         case ACC_PROP_ACC_PRINTER        : for (wDevice = PLOTTER, lNamesSize = 0; wDevice < 100; wDevice++)
                                                            {
                                                              NameFromDevice (szDeviceName, wDevice);
  
                                                              if (szDeviceName [0] != EOS)
                                                                lNamesSize += strlen (szDeviceName) + 2;
                                                            } /* for */

                                                            pNames = mem_alloc (lNamesSize);

                                                            for (wDevice = PLOTTER, pNames [0] = EOS; wDevice < 100; wDevice++)
                                                            {
                                                              NameFromDevice (szDeviceName, wDevice);

                                                              if (szDeviceName [0] != EOS)
                                                              {
                                                                strcat (pNames, szDeviceName);
                                                                strcat (pNames, ";");
                                                              } /* if */
                                                            } /* for */

                                                            if (strlen (pNames) > 0)
                                                              pNames [strlen (pNames) - 1] = EOS;

                                                            return ((LONG)pNames);
                         default                          : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                            return ((LONG)pValues);
                       } /* switch */
    case PN_RELVALS  : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_ACC_TABLE_OR_QUERY : /* fall through */
                         case ACC_PROP_ACC_PRINTER        : mem_free (pNames);
                                                            break;
                         default                          : break;
                       } /* switch */
                       break;
    case PN_SYMBOL   : switch (pPropDesc->sProperty)
                       {
                         case ACC_PROP_ACC_TABLE_OR_QUERY : /* fall through */
                         case ACC_PROP_ACC_PRINTER        : return (PROPSYM_ARROW);
                         default                          : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                                                            return (pValues != NULL) ? PROPSYM_ARROW : PROPSYS_NOSYMBOL;
                       } /* switch */
    case PN_ELLIPSIS : break;
  } /* switch */

  return (0L);
} /* AccPropFunc */

/*****************************************************************************/

LOCAL LONG RegPropFunc (INT msg, WINDOWP window, LONG item, CHAR *p)
{
  ACCOUNT_SPEC  *pAccSpec;
  PROPDESC      *pPropDesc;
  CHAR          *pValues;
  RECT          rcRegion;
  LOCAL LONGSTR szPropName;

  pAccSpec  = (ACCOUNT_SPEC *)window->special;
  pPropDesc = &pAccSpec->pPropDesc [item];

  switch (msg)
  {
    case PN_GETNAME  : GetPropertyName (pPropDesc->sProperty, szPropName);
                       return ((LONG)szPropName);
    case PN_GETVALUE : return ((LONG)pPropDesc->pszValue);
    case PN_SETVALUE : free (pPropDesc->pszValue);
                       AccSetPropertyStr (pAccSpec->pRegionProp, OBJ_REGION, pPropDesc->sProperty, pPropDesc->pszFormat, p);

                       switch (pPropDesc->sProperty)				/* redraw checkings */
                       {
                         case ACC_PROP_REG_HEIGHT   : FixRegionHeight (pAccSpec->pRegionProp);
                                                      set_redraw (window, &window->work);
                                                      break;
                         case ACC_PROP_REG_BK_COLOR : GetRegionRect (window, pAccSpec->pRegionProp, &rcRegion);
                                                      rcRegion.w = window->scroll.w;
                                                      set_redraw (window, &rcRegion);
                         default                    : break;
                       } /* switch */

                       AccGetPropertyStr (pAccSpec->pRegionProp, OBJ_REGION, pPropDesc->sProperty, pPropDesc->pszFormat, &pPropDesc->pszValue);
                       SetDirty (window, TRUE, FALSE);
                       break;
    case PN_READONLY : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                       return (pValues != NULL);
    case PN_GETVALS  : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                       return ((LONG)pValues);
    case PN_RELVALS  : break;
    case PN_SYMBOL   : AccObjGetPropertyValues (pPropDesc->sProperty, &pValues);
                       return (pValues != NULL) ? PROPSYM_ARROW : PROPSYS_NOSYMBOL;
    case PN_ELLIPSIS : break;
  } /* switch */

  return (0L);
} /* RegPropFunc */

/*****************************************************************************/

LOCAL BOOL TableNameFromQuery (ACCOUNT_SPEC *pAccSpec, CHAR *pTableName)
{
  BOOL     bOk;
  CHAR     *p;
  SYSQUERY *pSysQuery;
  CURSOR   cursor;

  bOk         = TRUE;
  *pTableName = EOS;

  if (pAccSpec->account.bTable)
    strcpy (pTableName, pAccSpec->account.szTableOrQuery);
  else
  {
    *pTableName = EOS;
    pSysQuery   = pAccSpec->db->buffer;

    strcpy (pSysQuery->name, pAccSpec->account.szTableOrQuery);
    bOk = db_search (pAccSpec->db->base, SYS_QUERY, 1, ASCENDING, &cursor, pSysQuery, 0L);

    if (bOk)
      bOk = db_read (pAccSpec->db->base, SYS_QUERY, pSysQuery, &cursor, 0L, FALSE);

    if (bOk)
    {
      p = strstr (pSysQuery->query, "FROM");		/* look for table name behind id FROM */

      if (p != NULL)
      {
        for (p += 4; isspace (*p); p++);
        strncpy (pTableName, p, MAX_TABLENAME);
        pTableName [MAX_TABLENAME] = EOS;
        for (p = pTableName; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
        *p = EOS;
      } /* if */
    } /* if */
  } /* else */

  return (bOk);
} /* TableNameFromQuery */

/*****************************************************************************/

