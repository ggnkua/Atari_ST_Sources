/*****************************************************************************
 *
 * Module : ACCOBJ.H
 * Author : Dieter Geiž
 *
 * Creation date    : 07.07.95
 * Last modification: 25.02.97
 *
 *
 * Description: This module defines the account object operations.
 *
 * History:
 * 25.02.97: Components pLinkOrder and szPrinter added
 * 16.02.97: Component pLinkCondition added
 * 15.02.97: Link master and child swapped
 * 27.12.96: ACC_PROP_ACC_PAGE_FORMAT and ACC_PROP_ACC_PAGE_ORIENTATION added
 * 23.12.96: RNP_BOTH added
 * 23.11.96: AccObjCalcUnitHeight added
 * 03.11.96: AccSortObjects added
 * 19.10.96: AccCopyRegion and AccCopyObject added
 * 03.12.95: Functions AccCopy and AccFree... added
 * 27.11.95: ACC_PROP_ACC_IS_TABLE definition added
 * 26.11.95: ACC_PROP_REG_... definitions added
 * 25.11.95: ACC_PROP_ACC_... definitions added
 * 21.10.95: Using os independent values for background mode and alignment
 * 19.10.95: AccObjGetPropertyStr and AccObjSetPropertyStr added
 * 14.10.95: ACC_PROP_FONT_FACENAME added
 * 07.07.95: Creation of body
 *****************************************************************************/

#ifndef __ACCOBJ__
#define __ACCOBJ__

/****** DEFINES **************************************************************/

enum ACC_PAGE_HEADER_PROP
{
  APHP_ALL,					/* page header/footer on all pages */
  APHP_NOT_ON_ACC_HEADER,			/* page header/footer not on account header */
  APHP_NOT_ON_ACC_FOOTER,			/* page header/footer not on account footer */
  APHP_ON_NEITHER				/* page header/footer not on account header or footer */
}; /* ACC_PAGE_HEADER_PROP */

#define ACC_HAS_HEADFOOT	0x00000001L	/* account has header/footer */
#define ACC_HAS_PAGE_HEADFOOT	0x00000002L	/* page has header/footer */

#define ACC_MAX_GROUPS		4		/* max number of group definitions */

enum REGION_NEWPAGE_PROP
{
  RNP_NONE,					/* no new page */
  RNP_BEFORE,					/* new page before region */
  RNP_AFTER,					/* new page after region */
  RNP_BOTH					/* new page before and after region */
}; /* REGION_NEWPAGE_PROP */

#define REGION_VISIBLE		0x00000001L	/* region is visible */
#define REGION_KEEP_TOGETHER	0x00000002L	/* keep region together */
#define REGION_CAN_GROW		0x00000004L	/* region can grow */
#define REGION_CAN_SHRINK	0x00000008L	/* region can shrink */

#define GROUP_HEADER		0x00000001L	/* group has header */
#define GROUP_FOOTER		0x00000002L	/* group has footer */
#define GROUP_KEEP_TOGETHER	0x00000004L	/* keep group together */
#define GROUP_FIRST_DETAIL	0x00000008L	/* keep together with first detail record */

enum ACC_OBJECT_CLASS
{
  OBJ_TEXT,					/* plain text */
  OBJ_COLUMN,					/* database column */
  OBJ_LINE,					/* line */
  OBJ_BOX,					/* box */
  OBJ_GROUPBOX,					/* group box */
  OBJ_CHECKBOX,					/* checkbox or radio button */
  OBJ_RADIOBUTTON,				/* radio button */
  OBJ_GRAPHIC,					/* picture */
  OBJ_SUBACCOUNT,				/* sub account */
  OBJ_ACCOUNT,					/* the account itself */
  OBJ_REGION,					/* a region of an account */
  OBJ_NUM_CLASSES				/* number of classes (always last) */
}; /* ACC_OBJECT_CLASS */

enum ACC_OBJECT_MODE
{
  MODE_OPAQUE,					/* opaque */
  MODE_TRANSPARENT				/* transparent */
}; /* ACC_OBJECT_MODE */

enum ACC_OBJECT_BORDERSTYLE
{
  BORDER_SOLID,					/* ______ */
  BORDER_LONGDASH,				/* ------ */
  BORDER_DOT,					/* ...... */
  BORDER_DASHDOT,				/* _._._. */
  BORDER_DASH,					/* ______ */
  BORDER_DASH2DOT				/* _.._.. */
}; /* ACC_OBJECT_BORDERSTYLE */

enum ACC_OBJECT_EFFECT
{
  EFFECT_NORMAL,				/* normal border */
  EFFECT_RAISED,				/* raised border */
  EFFECT_CARVED					/* carved border */
}; /* ACC_OBJECT_EFFECT */

enum ACC_OBJECT_SUM
{
  SUM_NONE,					/* no sum */
  SUM_GROUP,					/* running sum over group */
  SUM_ALL					/* running sum over all records */
}; /* ACC_OBJECT_SUM */

enum ACC_OBJECT_HORIZONTAL_ALIGNMENT
{
  ALI_HSTANDARD,				/* align standard */
  ALI_HLEFT,					/* align left */
  ALI_HCENTER,					/* align center */
  ALI_HRIGHT					/* align right */
}; /* ACC_OBJECT_HORIZONTAL_ALIGNMENT */

enum ACC_OBJECT_VERTICAL_ALIGNMENT
{
  ALI_VSTANDARD,				/* align standard */
  ALI_VTOP,					/* align on top */
  ALI_VCENTER,					/* align center */
  ALI_VBOTTOM					/* align on bottom */
}; /* ACC_OBJECT_VERTICAL_ALIGNMENT */

#define OBJ_IS_VISIBLE		0x00000001L	/* object is visible */
#define OBJ_IS_SELECTED		0x00000002L	/* object is selected (applies to checkboxes and radio buttons) */
#define OBJ_CAN_GROW		0x00000004L	/* object can grow */
#define OBJ_CAN_SHRINK		0x00000008L	/* object can shrink */
#define OBJ_HIDE_DUPLICATES	0x00000010L	/* duplicates are hidden */

enum ACCOUNT_PROPERTIES
{
  ACC_PROP_CLASS,				/* object properties */
  ACC_PROP_FLAGS,
  ACC_PROP_TEXT,
  ACC_PROP_COLUMN,
  ACC_PROP_TABLE,
  ACC_PROP_FORMAT,
  ACC_PROP_VALUE,
  ACC_PROP_FILENAME,
  ACC_PROP_ACCOUNTNAME,
  ACC_PROP_LINK_MASTER_FIELDS,
  ACC_PROP_LINK_CHILD_FIELDS,
  ACC_PROP_LINK_CONDITION,
  ACC_PROP_LINK_ORDER,
  ACC_PROP_SUM,
  ACC_PROP_X,
  ACC_PROP_Y,
  ACC_PROP_W,
  ACC_PROP_H,
  ACC_PROP_BK_MODE,
  ACC_PROP_BK_COLOR,
  ACC_PROP_EFFECT,
  ACC_PROP_BORDER_MODE,
  ACC_PROP_BORDER_COLOR,
  ACC_PROP_BORDER_WIDTH,
  ACC_PROP_BORDER_STYLE,
  ACC_PROP_FONT_FACENAME,
  ACC_PROP_FONT_FONT,
  ACC_PROP_FONT_POINT,
  ACC_PROP_FONT_COLOR,
  ACC_PROP_FONT_BOLD,
  ACC_PROP_FONT_ITALIC,
  ACC_PROP_FONT_UNDERLINED,
  ACC_PROP_FONT_OUTLINED,
  ACC_PROP_FONT_LIGHT,
  ACC_PROP_HORZ_ALIGNMENT,
  ACC_PROP_VERT_ALIGNMENT,
  ACC_PROP_ROTATION,
  ACC_PROP_IS_VISIBLE,
  ACC_PROP_IS_SELECTED,
  ACC_PROP_CAN_GROW,
  ACC_PROP_CAN_SHRINK,
  ACC_PROP_HIDE_DUPLICATES,
  ACC_PROP_ACC_TABLE_OR_QUERY,			/* account properties */
  ACC_PROP_ACC_IS_TABLE,
  ACC_PROP_ACC_PAGEHEADER,
  ACC_PROP_ACC_PAGEFOOTER,
  ACC_PROP_ACC_RASTER_X,
  ACC_PROP_ACC_RASTER_Y,
  ACC_PROP_ACC_WIDTH,
  ACC_PROP_ACC_MARGIN_LEFT,
  ACC_PROP_ACC_MARGIN_RIGHT,
  ACC_PROP_ACC_MARGIN_TOP,
  ACC_PROP_ACC_MARGIN_BOTTOM,
  ACC_PROP_ACC_NUM_COLUMNS,
  ACC_PROP_ACC_COLUMN_GAP,
  ACC_PROP_ACC_PRINTER,
  ACC_PROP_ACC_PAGE_FORMAT,
  ACC_PROP_ACC_PAGE_ORIENTATION,
  ACC_PROP_REG_NEW_PAGE,			/* region properties */
  ACC_PROP_REG_HEIGHT,
  ACC_PROP_REG_BK_COLOR,
  ACC_PROP_REG_VISIBLE,
  ACC_PROP_REG_KEEP_TOGETHER,
  ACC_PROP_REG_CAN_GROW,
  ACC_PROP_REG_CAN_SHRINK,
  ACC_NUM_PROPERTIES
}; /* ACCOUNT_PROPERTIES */

#define OBJ_SELECTED		0x80000000L	/* object is selected in editor */

/****** TYPES ****************************************************************/

typedef struct
{
  SHORT    sClass;				/* class of object */
  LONG     lFlags;				/* flags */
  LRECT    rcPos;				/* position of object */
  SHORT    sBkMode;				/* background mode */
  SHORT    sBkColor;				/* color of background (index) */
  SHORT    sEffect;				/* special effect of border or field */
  SHORT    sBorderMode;				/* border mode */
  SHORT    sBorderColor;			/* color of border */
  LONG     lBorderWidth;			/* width of border in 1/1000 cm */
  SHORT    sBorderStyle;			/* style of border */
  CHAR     *pTable;				/* table of column */
  CHAR     *pColumn;				/* column */
  SHORT    sSum;				/* running sum */
  CHAR     *pFaceName;				/* facename of font */
  FONTDESC Font;				/* font of text */
  CHAR     *pText;				/* the text itself */
  SHORT    sHorzAlignment;			/* horizontal aligment of text */
  SHORT    sVertAlignment;			/* vertical aligment of text */
  SHORT    sRotation;				/* rotation of text in degrees */
  CHAR     *pFormat;				/* format of column */
  CHAR     *pValue;				/* value instead of table/column */
  CHAR     *pFileName;				/* name of file */
  CHAR     *pAccountName;			/* name of sub account */
  CHAR     *pLinkMasterFields;			/* name of master links fields */
  CHAR     *pLinkChildFields;			/* name of child links fields */
  CHAR     *pLinkCondition;			/* additional link condition */
  CHAR     *pLinkOrder;				/* additional link order */
} ACC_OBJECT;

typedef struct
{
  LONG       lFlags;				/* flags of region */
  SHORT      sNewPageProp;			/* property for new page */
  BOOL       bIsPageHeaderFooter;		/* TRUE => page header or footer region, FALSE => account, group or detail region */
  LONG       lHeight;				/* height of region in 1/1000 cm */
  SHORT      sBkColor;				/* color of background (index) */
  SHORT      sNumObjects;			/* number of objects in region */
  ACC_OBJECT *pObjects;				/* the objects */
} ACC_REGION;					/* region objects in memory */

typedef struct
{
  LONG       lFlags;				/* flags of group */
  FIELDNAME  szColumn;				/* order column */
  SHORT      sDir;				/* direction of order */
  LONG       lGroupOn;				/* group value */
  LONG       lInterval;				/* interval of value */
  ACC_REGION arHeader;				/* header of group */
  ACC_REGION arFooter;				/* footer of group */
} ACC_GROUP;					/* group object in memory */

typedef struct
{
  LONG       lFlags;				/* flags of account */
  FIELDNAME  szName;				/* name of account */
  SHORT      bTable;				/* TRUE => table, FALSE => query */
  TABLENAME  szTableOrQuery;			/* name of table or query */
  SHORT      sPageHeaderProp;			/* page header property */
  SHORT      sPageFooterProp;			/* page footer property */
  LONG       lRasterX;				/* width of raster in 1/1000 cm */
  LONG       lRasterY;				/* height of raster in 1/1000 cm */
  LONG       lWidth;				/* width of account in 1/1000 cm */
  LONG       lMarginLeft;			/* left margin of page in 1/1000 cm */
  LONG       lMarginRight;			/* right margin of page in 1/1000 cm */
  LONG       lMarginTop;			/* top margin of page in 1/1000 cm */
  LONG       lMarginBottom;			/* bottom margin of page in 1/1000 cm */
  SHORT      sNumCols;				/* number of columns */
  LONG       lColGap;				/* gap between two adjacent columns in 1/1000 cm */
  ACC_REGION arAccountHeader;			/* header of account */
  ACC_REGION arAccountFooter;			/* footer of account */
  ACC_REGION arPageHeader;			/* page header of every page */
  ACC_REGION arPageFooter;			/* page footer of every page */
  ACC_REGION arDetails;				/* details of account */
  SHORT      sNumGroups;			/* actual number of groups */
  ACC_GROUP  agGroups [ACC_MAX_GROUPS];		/* group definitions */
  SHORT      sPageFormat;			/* page format (A4, A5...) */
  SHORT      sPageOrientation;			/* page orientation */
  LONGSTR    szPrinter;				/* printer name */
} ACCOUNT;					/* account object in memory */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOL    AccObjInit              (VOID);
GLOBAL BOOL    AccObjTerm              (VOID);

GLOBAL BOOL    AccObjHasProperty       (SHORT sClass, SHORT sProperty);
GLOBAL BOOL    AccObjGetProperties     (SHORT sClass, SET setProperties);

GLOBAL BOOL    AccObjGetPropertyType   (SHORT sProperty, SHORT *psType);
GLOBAL BOOL    AccObjGetPropertyValues (SHORT sProperty, CHAR **ppValues);
GLOBAL BOOL    AccObjSetPropertyValues (SHORT sProperty, CHAR *pValues);

GLOBAL BOOL    AccGetPropertyStr       (VOID *pAnyObject, SHORT sClass, SHORT sProperty, CHAR *pFormat, CHAR **ppStr);
GLOBAL BOOL    AccSetPropertyStr       (VOID *pAnyObject, SHORT sClass, SHORT sProperty, CHAR *pFormat, CHAR *pStr);

GLOBAL SHORT   AccMapPageFormat        (SHORT sPageFormat);

GLOBAL VOID    AccSortObjects          (ACCOUNT *pAccount);
GLOBAL ACCOUNT *AccCopy                (ACCOUNT *pAccount);
GLOBAL BOOL    AccCopyRegion           (ACC_REGION *pRegionDst, ACC_REGION *pRegionSrc);
GLOBAL BOOL    AccCopyObject           (ACC_OBJECT *pObjectDst, ACC_OBJECT *pObjectSrc);
GLOBAL VOID    AccFree                 (ACCOUNT *pAccount);
GLOBAL VOID    AccFreeRegion           (ACC_REGION *pRegion);
GLOBAL VOID    AccFreeObject           (ACC_OBJECT *pObject);

GLOBAL BOOL    AccObjGetProperty       (ACC_OBJECT *pObject, SHORT sProperty, VOID *pValue);
GLOBAL BOOL    AccObjSetProperty       (ACC_OBJECT *pObject, SHORT sProperty, VOID *pValue);
GLOBAL BOOL    AccObjGetPropertyStr    (ACC_OBJECT *pObject, SHORT sProperty, CHAR *pFormat, CHAR **ppStr);
GLOBAL BOOL    AccObjSetPropertyStr    (ACC_OBJECT *pObject, SHORT sProperty, CHAR *pFormat, CHAR *pStr);

GLOBAL VOID    AccObjDraw              (ACC_OBJECT *pObject, SHORT sVdiHandle, RECT rc, CHAR *pText, SHORT sType, LONG lFontScaleFactor, LONG lPixelsPerMeter);
GLOBAL LONG    AccObjCalcUnitHeight    (ACC_OBJECT *pObject, SHORT sVdiHandle, CHAR *pText, LONG lPixelsPerMeter);

GLOBAL BOOL    AccSysFromMem           (BASE *base, SYSACCOUNT *pSysAccount, ACCOUNT *pAccount, BOOL bUpdate);
GLOBAL BOOL    AccMemFromSys           (BASE *base, ACCOUNT *pAccount, SYSACCOUNT *pSysAccount);

GLOBAL CHAR    *AccStrDup              (CHAR *pStr);

#endif /* __ACCOBJ__ */

