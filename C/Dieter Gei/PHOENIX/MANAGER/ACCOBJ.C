/*****************************************************************************
 *
 * Module : ACCOBJ.C
 * Author : Dieter Geiž
 *
 * Creation date    : 17.09.95
 * Last modification: 08.04.97
 *
 *
 * Description: This module implements the account object operations.
 *
 * History:
 * 08.04.97: Objects are loaded to even adresses only
 * 05.04.97: 2 colored checkboxes/radio buttons are being drawn transparently
 * 25.02.97: Components pLinkOrder and szPrinter added
 * 16.02.97: Component pLinkCondition added
 * 15.02.97: Check box borders are rounded up
 * 14.02.97: Subaccount has no border
 * 12.01.97: CHECK_SPACE is used proportional to point size
 * 09.01.97: Setting number of objects to zero in AccFreeRegion
 * 02.01.97: Text objects can grow and shrink too
 * 31.12.96: AccObjCalcUnitHeight returns zero for empty strings
 * 29.12.96: Checkboxes and radio button width is measured in mm
 * 27.12.96: ACC_PROP_ACC_PAGE_FORMAT and ACC_PROP_ACC_PAGE_ORIENTATION added
 * 22.12.96: Bug in GetBorderWidth fixed
 * 18.12.96: Borders are at least one pixel wide
 * 23.11.96: AccObjCalcUnitHeight added
 * 19.10.96: AccCopyRegion and AccCopyObject added
 * 03.12.95: Functions AccCopy and AccFree added
 * 27.11.95: ACC_PROP_ACC_IS_TABLE definition used
 * 26.11.95: ACC_PROP_REG_... definitions used
 * 25.11.95: ACC_PROP_ACC_... definitions used
 * 22.11.95: AccObjGetPropertyStr improved
 * 01.11.95: AccObjSetPropertyStr added
 * 21.10.95: Using os independent values for background mode and alignment
 * 19.10.95: AccObjGetPropertyStr added
 * 15.10.95: ACC_PROP_FONT_FACENAME added
 * 17.09.95: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"

#include "database.h"

#include "controls.h"

#include "export.h"
#include "accobj.h"

/****** DEFINES **************************************************************/

#define CHECK_SPACE	480L		/* space for checkboxes and radio buttons */

#define UNITS_FROM_PIXELS(pixels, fac)	(LONG)(((pixels) * 100000L + (fac) / 2) / (fac))
#define PIXELS_FROM_UNITS(units, fac)	(SHORT)(((units) * (fac) + 100000L / 2) / 100000L)

/****** TYPES ****************************************************************/

typedef struct
{
  SHORT  sType;					/* the type of the property */
  CHAR   *pValues;				/* the discrete values, separated by tabs or NULL */
  LONG   lFlag;					/* the flag if property is a boolean value or 0 if not */
  SIZE_T lOffset;				/* the offset of the variable */
} PROPERTY;

/****** VARIABLES ************************************************************/

SET setClassProperties [OBJ_NUM_CLASSES];	/* the set of properties for each class */

PROPERTY aProperties [] = 			/* the properties */
{
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sClass)},            /* ACC_PROP_CLASS */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_FLAGS */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pText)},             /* ACC_PROP_TEXT */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pColumn)},           /* ACC_PROP_COLUMN */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pTable)},            /* ACC_PROP_TABLE */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pFormat)},           /* ACC_PROP_FORMAT */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pValue)},            /* ACC_PROP_VALUE */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pFileName)},         /* ACC_PROP_FILENAME */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pAccountName)},      /* ACC_PROP_ACCOUNTNAME */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pLinkMasterFields)}, /* ACC_PROP_LINK_MASTER_FIELDS */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pLinkChildFields)},  /* ACC_PROP_LINK_CHILD_FIELDS */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pLinkCondition)},    /* ACC_PROP_LINK_CONDITION */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pLinkOrder)},        /* ACC_PROP_LINK_ORDER */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sSum)},              /* ACC_PROP_SUM */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, rcPos.x)},           /* ACC_PROP_X */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, rcPos.y)},           /* ACC_PROP_Y */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, rcPos.w)},           /* ACC_PROP_W */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, rcPos.h)},           /* ACC_PROP_H */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sBkMode)},           /* ACC_PROP_BK_MODE */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sBkColor)},          /* ACC_PROP_BK_COLOR */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sEffect)},           /* ACC_PROP_EFFECT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sBorderMode)},       /* ACC_PROP_BORDER_MODE */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sBorderColor)},      /* ACC_PROP_BORDER_COLOR */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, lBorderWidth)},      /* ACC_PROP_BORDER_WIDTH */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sBorderStyle)},      /* ACC_PROP_BORDER_STYLE */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, pFaceName)},         /* ACC_PROP_FONT_FACENAME */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, Font.font)},         /* ACC_PROP_FONT_FONT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, Font.point)},        /* ACC_PROP_FONT_POINT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, Font.color)},        /* ACC_PROP_FONT_COLOR */
  {TYPE_WORD, NULL, TXT_THICKENED,        OFFSET (ACC_OBJECT, Font.effects)},      /* ACC_PROP_FONT_BOLD */
  {TYPE_WORD, NULL, TXT_SKEWED,           OFFSET (ACC_OBJECT, Font.effects)},      /* ACC_PROP_FONT_ITALIC */
  {TYPE_WORD, NULL, TXT_UNDERLINED,       OFFSET (ACC_OBJECT, Font.effects)},      /* ACC_PROP_FONT_UNDERLINED */
  {TYPE_WORD, NULL, TXT_OUTLINED,         OFFSET (ACC_OBJECT, Font.effects)},      /* ACC_PROP_FONT_OUTLINED */
  {TYPE_WORD, NULL, TXT_LIGHT,            OFFSET (ACC_OBJECT, Font.effects)},      /* ACC_PROP_FONT_LIGHT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sHorzAlignment)},    /* ACC_PROP_HORZ_ALIGNMENT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sVertAlignment)},    /* ACC_PROP_VERT_ALIGNMENT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_OBJECT, sRotation)},         /* ACC_PROP_ROTATION */
  {TYPE_LONG, NULL, OBJ_IS_VISIBLE,       OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_IS_VISIBLE */
  {TYPE_LONG, NULL, OBJ_IS_SELECTED,      OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_IS_SELECTED */
  {TYPE_LONG, NULL, OBJ_CAN_GROW,         OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_CAN_GROW */
  {TYPE_LONG, NULL, OBJ_CAN_SHRINK,       OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_CAN_SHRINK */
  {TYPE_LONG, NULL, OBJ_HIDE_DUPLICATES,  OFFSET (ACC_OBJECT, lFlags)},            /* ACC_PROP_HIDE_DUPLICATES */

  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACCOUNT,    szTableOrQuery)},    /* ACC_PROP_ACC_TABLE_OR_QUERY */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    bTable)},            /* ACC_PROP_ACC_IS_TABLE */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    sPageHeaderProp)},   /* ACC_PROP_ACC_PAGEHEADER */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    sPageFooterProp)},   /* ACC_PROP_ACC_PAGEFOOTER */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lRasterX)},          /* ACC_PROP_ACC_RASTER_X */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lRasterY)},          /* ACC_PROP_ACC_RASTER_Y */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lWidth)},            /* ACC_PROP_ACC_WIDTH */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lMarginLeft)},       /* ACC_PROP_ACC_MARGIN_LEFT */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lMarginRight)},      /* ACC_PROP_ACC_MARGIN_RIGHT */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lMarginTop)},        /* ACC_PROP_ACC_MARGIN_TOP */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lMarginBottom)},     /* ACC_PROP_ACC_MARGIN_BOTTOM */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    sNumCols)},          /* ACC_PROP_ACC_NUM_COLUMNS */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACCOUNT,    lColGap)},           /* ACC_PROP_ACC_COLUMN_GAP */
  {TYPE_CHAR, NULL, 0x00000000L,          OFFSET (ACCOUNT,    szPrinter)},         /* ACC_PROP_ACC_PRINTER */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    sPageFormat)},       /* ACC_PROP_ACC_PAGE_FORMAT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACCOUNT,    sPageOrientation)},  /* ACC_PROP_ACC_PAGE_ORIENTATION */

  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_REGION, sNewPageProp)},      /* ACC_PROP_REG_NEW_PAGE */
  {TYPE_LONG, NULL, 0x00000000L,          OFFSET (ACC_REGION, lHeight)},           /* ACC_PROP_REG_HEIGHT */
  {TYPE_WORD, NULL, 0x00000000L,          OFFSET (ACC_REGION, sBkColor)},          /* ACC_PROP_REG_BK_COLOR */
  {TYPE_LONG, NULL, REGION_VISIBLE,       OFFSET (ACC_REGION, lFlags)},            /* ACC_PROP_REG_VISIBLE */
  {TYPE_LONG, NULL, REGION_KEEP_TOGETHER, OFFSET (ACC_REGION, lFlags)},            /* ACC_PROP_REG_KEEP_TOGETHER */
  {TYPE_LONG, NULL, REGION_CAN_GROW,      OFFSET (ACC_REGION, lFlags)},            /* ACC_PROP_REG_CAN_GROW */
  {TYPE_LONG, NULL, REGION_CAN_SHRINK,    OFFSET (ACC_REGION, lFlags)}             /* ACC_PROP_REG_CAN_SHRINK */
}; /* aProperties */

SHORT aTextProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H, ACC_PROP_BK_MODE, ACC_PROP_BK_COLOR,
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_FONT_FACENAME, ACC_PROP_FONT_FONT, ACC_PROP_FONT_POINT, ACC_PROP_FONT_COLOR, ACC_PROP_FONT_BOLD, ACC_PROP_FONT_ITALIC, ACC_PROP_FONT_UNDERLINED, ACC_PROP_FONT_OUTLINED, ACC_PROP_FONT_LIGHT, ACC_PROP_TEXT,
  ACC_PROP_HORZ_ALIGNMENT, ACC_PROP_VERT_ALIGNMENT, ACC_PROP_ROTATION,
  ACC_PROP_IS_VISIBLE, ACC_PROP_CAN_GROW, ACC_PROP_CAN_SHRINK,
  FAILURE
}; /* aTextProperties */

SHORT aColumnProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H, ACC_PROP_BK_MODE, ACC_PROP_BK_COLOR,
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_TABLE, ACC_PROP_COLUMN, ACC_PROP_SUM,
  ACC_PROP_FONT_FACENAME, ACC_PROP_FONT_FONT, ACC_PROP_FONT_POINT, ACC_PROP_FONT_COLOR, ACC_PROP_FONT_BOLD, ACC_PROP_FONT_ITALIC, ACC_PROP_FONT_UNDERLINED, ACC_PROP_FONT_OUTLINED, ACC_PROP_FONT_LIGHT,
  ACC_PROP_HORZ_ALIGNMENT, ACC_PROP_VERT_ALIGNMENT, ACC_PROP_ROTATION,
  ACC_PROP_FORMAT,
  ACC_PROP_IS_VISIBLE, ACC_PROP_CAN_GROW, ACC_PROP_CAN_SHRINK, ACC_PROP_HIDE_DUPLICATES,
  FAILURE
}; /* aColumnProperties */

SHORT aLineProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H, 
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_IS_VISIBLE,
  FAILURE
}; /* aLineProperties */

SHORT aBoxProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H, ACC_PROP_BK_MODE, ACC_PROP_BK_COLOR,
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_IS_VISIBLE,
  FAILURE
}; /* aBoxProperties */

SHORT aGroupboxProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H,
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_TABLE, ACC_PROP_COLUMN,
  ACC_PROP_FONT_FACENAME, ACC_PROP_FONT_FONT, ACC_PROP_FONT_POINT, ACC_PROP_FONT_COLOR, ACC_PROP_FONT_BOLD, ACC_PROP_FONT_ITALIC, ACC_PROP_FONT_UNDERLINED, ACC_PROP_FONT_OUTLINED, ACC_PROP_FONT_LIGHT, ACC_PROP_TEXT,
  ACC_PROP_HORZ_ALIGNMENT,
  ACC_PROP_IS_VISIBLE, ACC_PROP_HIDE_DUPLICATES,
  FAILURE
}; /* aGroupboxProperties */

SHORT aCheckboxProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H,
  ACC_PROP_EFFECT,
  ACC_PROP_TABLE, ACC_PROP_COLUMN, ACC_PROP_VALUE,
  ACC_PROP_FONT_FACENAME, ACC_PROP_FONT_FONT, ACC_PROP_FONT_POINT, ACC_PROP_FONT_COLOR, ACC_PROP_FONT_BOLD, ACC_PROP_FONT_ITALIC, ACC_PROP_FONT_UNDERLINED, ACC_PROP_FONT_OUTLINED, ACC_PROP_FONT_LIGHT, ACC_PROP_TEXT,
  ACC_PROP_IS_VISIBLE, ACC_PROP_HIDE_DUPLICATES,
  FAILURE
}; /* aCheckboxProperties */

SHORT aRadiobuttonProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H,
  ACC_PROP_EFFECT,
  ACC_PROP_TABLE, ACC_PROP_COLUMN, ACC_PROP_VALUE,
  ACC_PROP_FONT_FACENAME, ACC_PROP_FONT_FONT, ACC_PROP_FONT_POINT, ACC_PROP_FONT_COLOR, ACC_PROP_FONT_BOLD, ACC_PROP_FONT_ITALIC, ACC_PROP_FONT_UNDERLINED, ACC_PROP_FONT_OUTLINED, ACC_PROP_FONT_LIGHT, ACC_PROP_TEXT,
  ACC_PROP_IS_VISIBLE, ACC_PROP_HIDE_DUPLICATES,
  FAILURE
}; /* aRadiobuttonProperties */

SHORT aGraphicProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H, ACC_PROP_BK_MODE, ACC_PROP_BK_COLOR,
  ACC_PROP_EFFECT, ACC_PROP_BORDER_MODE, ACC_PROP_BORDER_COLOR, ACC_PROP_BORDER_WIDTH, ACC_PROP_BORDER_STYLE,
  ACC_PROP_TABLE, ACC_PROP_COLUMN,
  ACC_PROP_FILENAME,
  ACC_PROP_IS_VISIBLE,
  FAILURE
}; /* aGraphicProperties */

SHORT aSubaccountProperties [] =
{
  ACC_PROP_CLASS, ACC_PROP_FLAGS, ACC_PROP_X, ACC_PROP_Y, ACC_PROP_W, ACC_PROP_H,
  ACC_PROP_ACCOUNTNAME, ACC_PROP_LINK_MASTER_FIELDS, ACC_PROP_LINK_CHILD_FIELDS, ACC_PROP_LINK_CONDITION, ACC_PROP_LINK_ORDER,
  ACC_PROP_IS_VISIBLE,
  FAILURE
}; /* aSubaccountProperties */

SHORT aAccountProperties [] =
{
  ACC_PROP_ACC_TABLE_OR_QUERY, ACC_PROP_ACC_IS_TABLE,
  ACC_PROP_ACC_PAGEHEADER, ACC_PROP_ACC_PAGEFOOTER,
  ACC_PROP_ACC_RASTER_X, ACC_PROP_ACC_RASTER_Y,
  ACC_PROP_ACC_WIDTH,
  ACC_PROP_ACC_MARGIN_LEFT, ACC_PROP_ACC_MARGIN_RIGHT, ACC_PROP_ACC_MARGIN_TOP, ACC_PROP_ACC_MARGIN_BOTTOM,
  ACC_PROP_ACC_NUM_COLUMNS, ACC_PROP_ACC_COLUMN_GAP,
  ACC_PROP_ACC_PRINTER, ACC_PROP_ACC_PAGE_FORMAT, ACC_PROP_ACC_PAGE_ORIENTATION,
  FAILURE
}; /* aAccountProperties */

SHORT aRegionProperties [] =
{
  ACC_PROP_REG_NEW_PAGE, ACC_PROP_REG_HEIGHT, ACC_PROP_REG_BK_COLOR,
  ACC_PROP_REG_VISIBLE, ACC_PROP_REG_KEEP_TOGETHER, ACC_PROP_REG_CAN_GROW, ACC_PROP_REG_CAN_SHRINK,
  FAILURE
}; /* aRegionProperties */

SHORT asPageFormat [] =
{
  PAGE_DEFAULT, PAGE_A3, PAGE_A4, PAGE_A5, PAGE_B5, PAGE_LETTER, PAGE_HALF, PAGE_LEGAL, PAGE_DOUBLE, PAGE_BROAD
}; /* asPageFormat */

/****** FUNCTIONS ************************************************************/

LOCAL LONG  CalcStringSize    (ACC_REGION *pRegion);
LOCAL LONG  CalcObjStringSize (ACC_OBJECT *pObject);
LOCAL CHAR  *SaveObjects      (CHAR *p, ACC_REGION *pRegion);
LOCAL CHAR  *SaveObject       (CHAR *p, ACC_OBJECT *pObject);
LOCAL CHAR  *LoadObjects      (CHAR *p, ACC_REGION *pRegion, CHAR *pVersion);
LOCAL CHAR  *LoadObject       (CHAR *p, ACC_OBJECT *pObject, CHAR *pVersion);

LOCAL VOID  DrawBackground    (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc);
LOCAL VOID  DrawBorder        (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc, CHAR *pText, LONG lPixelsPerMeter);
LOCAL VOID  DrawText          (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc, CHAR *pText, SHORT stype, LONG lPixelsPerMeter);
LOCAL VOID  DrawCheckbox      (SHORT sVdiHandle, RECT *rc, RECT *rcClip, BOOL bChecked, BOOL bRadio);

LOCAL VOID  CalcTextSize      (SHORT sVdiHandle, CHAR *pText, SHORT sMaxWidth, SHORT *pWidth, SHORT *pHeight);
LOCAL CHAR  *GetLine          (SHORT sVdiHandle, CHAR *pText, CHAR *pLine, SHORT sMaxWidth);

LOCAL SHORT GetBorderWidth    (ACC_OBJECT *pObject, LONG lPixelsPerMeter);
LOCAL VOID  RemTrailSP        (CHAR *pString);

LOCAL VOID SortObjects        (SHORT sNumObjects, ACC_OBJECT *pObj);
LOCAL INT  CompareObjects     (ACC_OBJECT *pObj1, ACC_OBJECT *pObj2);

/*****************************************************************************/

GLOBAL BOOL AccObjInit (VOID)
{
  SHORT i;

  for (i = 0; aTextProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_TEXT], aTextProperties [i]);

  for (i = 0; aColumnProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_COLUMN], aColumnProperties [i]);

  for (i = 0; aLineProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_LINE], aLineProperties [i]);

  for (i = 0; aBoxProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_BOX], aBoxProperties [i]);

  for (i = 0; aGroupboxProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_GROUPBOX], aGroupboxProperties [i]);

  for (i = 0; aCheckboxProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_CHECKBOX], aCheckboxProperties [i]);

  for (i = 0; aRadiobuttonProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_RADIOBUTTON], aRadiobuttonProperties [i]);

  for (i = 0; aGraphicProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_GRAPHIC], aGraphicProperties [i]);

  for (i = 0; aSubaccountProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_SUBACCOUNT], aSubaccountProperties [i]);

  for (i = 0; aAccountProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_ACCOUNT], aAccountProperties [i]);

  for (i = 0; aRegionProperties [i] != FAILURE; i++)
    setincl (setClassProperties [OBJ_REGION], aRegionProperties [i]);

  return (TRUE);
} /* AccObjInit */

/*****************************************************************************/

GLOBAL BOOL AccObjTerm (VOID)
{
  return (TRUE);
} /* AccObjTerm */

/*****************************************************************************/

GLOBAL BOOL AccObjHasProperty (SHORT sClass, SHORT sProperty)
{
  return (setin (setClassProperties [sClass], sProperty));
} /* AccObjHasProperty */

/*****************************************************************************/

GLOBAL BOOL AccObjGetProperties (SHORT sClass, SET setProperties)
{
  BOOL bOk;

  bOk = (0 <= sClass) && (sClass < OBJ_NUM_CLASSES);

  if (bOk)
    setcpy (setProperties, setClassProperties [sClass]);
  else
    setclr (setProperties);

  return (bOk);
} /* AccObjGetProperties */

/*****************************************************************************/

GLOBAL BOOL AccObjGetPropertyType (SHORT sProperty, SHORT *psType)
{
  BOOL bOk;

  bOk     = (sProperty >= 0) && (sProperty < ACC_NUM_PROPERTIES);
  *psType = bOk ? aProperties [sProperty].sType : FAILURE;

  return (bOk);
} /* AccObjGetPropertyType */

/*****************************************************************************/

GLOBAL BOOL AccObjGetPropertyValues (SHORT sProperty, CHAR **ppValues)
{
  BOOL bOk;

  bOk = (sProperty >= 0) && (sProperty < ACC_NUM_PROPERTIES);

  if (bOk)
    *ppValues = aProperties [sProperty].pValues;
  else
    *ppValues = NULL;

  return (bOk);
} /* AccObjGetPropertyValues */

/*****************************************************************************/

GLOBAL BOOL AccObjSetPropertyValues (SHORT sProperty, CHAR *pValues)
{
  BOOL bOk;

  bOk = (sProperty >= 0) && (sProperty < ACC_NUM_PROPERTIES);

  if (bOk)
    aProperties [sProperty].pValues = pValues;
  else
    aProperties [sProperty].pValues = NULL;

  return (bOk);
} /* AccObjSetPropertyValues */

/*****************************************************************************/

GLOBAL BOOL AccGetPropertyStr (VOID *pAnyObject, SHORT sClass, SHORT sProperty, CHAR *pFormat, CHAR **ppStr)
{
  BOOL    bOk;
  CHAR    *p, *pValue, *pValues;
  LONGSTR sz;
  FORMAT  format;
  SHORT   s, sValue;
  LONG    l, lValue;
  DOUBLE  d;

  bOk    = AccObjHasProperty (sClass, sProperty);
  *ppStr = NULL;

  if (bOk)
  {
    p = (CHAR *)pAnyObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : if (aProperties [sProperty].lFlag == 0)
                         bin2str (TYPE_WORD, p, sz);
                       else
                         if ((*(SHORT *)p & aProperties [sProperty].lFlag) != 0)
                           strcpy (sz, "1");
                         else
                           strcpy (sz, "0");

                       if (pFormat != NULL)
                       {
                         build_format (TYPE_LONG, pFormat, format);
                         str2format (TYPE_LONG, sz, format);
                         RemLeadSP (sz);
                       } /* if */
                       else
                         if (aProperties [sProperty].pValues != NULL)
                         {
                           pValues = strdup (aProperties [sProperty].pValues);
                           str2bin (TYPE_WORD, sz, &sValue);
                           for (s = 0, pValue = strtok (pValues, ";"); s < sValue; s++, pValue = strtok (NULL, ";"));
                           strcpy (sz, pValue);
                           free (pValues);
                         } /* if, else */

                       *ppStr = strdup (sz);
                       break;
      case TYPE_LONG : if (aProperties [sProperty].lFlag == 0)
                         bin2str (TYPE_LONG, p, sz);
                       else
                         if ((*(LONG *)p & aProperties [sProperty].lFlag) != 0)
                           strcpy (sz, "1");
                         else
                           strcpy (sz, "0");

                       if (pFormat != NULL)
                       {
                         str2bin (TYPE_FLOAT, sz, &d);
                         d /= 1000;				/* 1/1000 cm */
                         bin2str (TYPE_FLOAT, &d, sz);
                         build_format (TYPE_FLOAT, pFormat, format);
                         str2format (TYPE_FLOAT, sz, format);
                         RemLeadSP (sz);
                       } /* if */
                       else
                         if (aProperties [sProperty].pValues != NULL)
                         {
                           pValues = strdup (aProperties [sProperty].pValues);
                           str2bin (TYPE_LONG, sz, &lValue);
                           for (l = 0, pValue = strtok (pValues, ";"); l < lValue; l++, pValue = strtok (NULL, ";"));
                           strcpy (sz, pValue);
                           free (pValues);
                         } /* if, else */

                       *ppStr = strdup (sz);
                       break;
      case TYPE_CHAR : pValue = p;
                       *ppStr = strdup ((pValue == NULL) ? "" : pValue);
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccGetPropertyStr */

/*****************************************************************************/

GLOBAL BOOL AccSetPropertyStr (VOID *pAnyObject, SHORT sClass, SHORT sProperty, CHAR *pFormat, CHAR *pStr)
{
  BOOL    bOk;
  CHAR    *p, *pValue, *pValues;
  LONGSTR sz;
  FORMAT  format;
  SHORT   s, sValue;
  LONG    l, lValue;
  DOUBLE  d;

  bOk = AccObjHasProperty (sClass, sProperty);

  if (bOk)
  {
    p = (CHAR *)pAnyObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : strcpy (sz, pStr);
                       RemLeadSP (sz);

                       if (pFormat != NULL)
                       {
                         build_format (TYPE_LONG, pFormat, format);
                         format2str (TYPE_LONG, sz, format);
                       } /* if */
                       else
                         if (aProperties [sProperty].pValues != NULL)
                         {
                           pValues = strdup (aProperties [sProperty].pValues);

                           for (s = 0, pValue = strtok (pValues, ";"); pValue != NULL; s++, pValue = strtok (NULL, ";"))
                             if (strcmpi (pValue, sz) == 0)
                             {
                               itoa (s, sz, 10);
                               break;
                             } /* if, for */

                           free (pValues);
                         } /* if, else */

                       str2bin (TYPE_WORD, sz, &sValue);

                       if (aProperties [sProperty].lFlag == 0)
                         *(SHORT *)p = sValue;
                       else
                         *(SHORT *)p = sValue ? (*(SHORT *)p | aProperties [sProperty].lFlag) : (*(SHORT *)p & ~aProperties [sProperty].lFlag);
                       break;
      case TYPE_LONG : strcpy (sz, pStr);
                       RemLeadSP (sz);

                       if (pFormat != NULL)
                       {
                         build_format (TYPE_FLOAT, pFormat, format);
                         format2str (TYPE_FLOAT, sz, format);
                         str2bin (TYPE_FLOAT, sz, &d);
                         d *= 1000;				/* 1/1000 cm */
                         bin2str (TYPE_FLOAT, &d, sz);
                       } /* if */
                       else
                         if (aProperties [sProperty].pValues != NULL)
                         {
                           pValues = strdup (aProperties [sProperty].pValues);

                           for (l = 0, pValue = strtok (pValues, ";"); pValue != NULL; l++, pValue = strtok (NULL, ";"))
                             if (strcmpi (pValue, sz) == 0)
                             {
                               ltoa (l, sz, 10);
                               break;
                             } /* if, for */

                           free (pValues);
                         } /* if, else */

                       str2bin (TYPE_LONG, sz, &lValue);

                       if (aProperties [sProperty].lFlag == 0)
                         *(LONG *)p = lValue;
                       else
                         *(LONG *)p = lValue ? (*(LONG *)p | aProperties [sProperty].lFlag) : (*(LONG *)p & ~aProperties [sProperty].lFlag);
                       break;
      case TYPE_CHAR : strcpy (p, pStr);
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccSetPropertyStr */

/*****************************************************************************/

GLOBAL SHORT AccMapPageFormat (SHORT sPageFormat)
{
  return (asPageFormat [sPageFormat]);
} /* AccMapPageFormat */

/*****************************************************************************/

GLOBAL VOID AccSortObjects (ACCOUNT *pAccount)
{
  SHORT i;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    SortObjects (pAccount->arAccountHeader.sNumObjects, pAccount->arAccountHeader.pObjects);

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    SortObjects (pAccount->arPageHeader.sNumObjects, pAccount->arPageHeader.pObjects);

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
      SortObjects (pAccount->agGroups [i].arHeader.sNumObjects, pAccount->agGroups [i].arHeader.pObjects);

  SortObjects (pAccount->arDetails.sNumObjects, pAccount->arDetails.pObjects);

  for (i = pAccount->sNumGroups - 1; i >= 0; i--)
    if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
      SortObjects (pAccount->agGroups [i].arFooter.sNumObjects, pAccount->agGroups [i].arFooter.pObjects);

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    SortObjects (pAccount->arPageFooter.sNumObjects, pAccount->arPageFooter.pObjects);

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    SortObjects (pAccount->arAccountFooter.sNumObjects, pAccount->arAccountFooter.pObjects);
} /* AccSortObjects */

/*****************************************************************************/

GLOBAL ACCOUNT *AccCopy (ACCOUNT *pAccount)
{
  ACCOUNT *pNewAccount;
  SHORT   i;
  BOOL    bOk;

  pNewAccount = mem_alloc (sizeof (ACCOUNT));

  if (pNewAccount != NULL)
  {
    mem_lmove (pNewAccount, pAccount, sizeof (ACCOUNT));

    bOk = TRUE;

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      bOk = AccCopyRegion (&pNewAccount->arAccountHeader, &pAccount->arAccountHeader) && bOk;

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      bOk = AccCopyRegion (&pNewAccount->arPageHeader, &pAccount->arPageHeader) && bOk;

    for (i = 0; i < pAccount->sNumGroups; i++)
      if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
        bOk = AccCopyRegion (&pNewAccount->agGroups [i].arHeader, &pAccount->agGroups [i].arHeader) && bOk;

    bOk = AccCopyRegion (&pNewAccount->arDetails, &pAccount->arDetails) && bOk;

    for (i = pAccount->sNumGroups - 1; i >= 0; i--)
      if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
        bOk = AccCopyRegion (&pNewAccount->agGroups [i].arFooter, &pAccount->agGroups [i].arFooter) && bOk;

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      bOk = AccCopyRegion (&pNewAccount->arPageFooter, &pAccount->arPageFooter) && bOk;

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      bOk = AccCopyRegion (&pNewAccount->arAccountFooter, &pAccount->arAccountFooter) && bOk;

    if (! bOk)
    {
      AccFree (pNewAccount);
      pNewAccount = NULL;
    } /* if */
  } /* if */

  return (pNewAccount);
} /* AccCopy */

/*****************************************************************************/

GLOBAL BOOL AccCopyRegion (ACC_REGION *pRegionDst, ACC_REGION *pRegionSrc)
{
  BOOL  bOk;
  SHORT i;

  bOk = TRUE;

  mem_lmove (pRegionDst, pRegionSrc, sizeof (ACC_REGION));

  if (pRegionSrc->pObjects != 0)
  {
    pRegionDst->pObjects = mem_alloc (pRegionSrc->sNumObjects * sizeof (ACC_OBJECT));

    if (pRegionDst->pObjects == NULL)
    {
      pRegionSrc->sNumObjects = 0;
      bOk                     = FALSE;
    } /* if */
    else
      for (i = 0; i < pRegionSrc->sNumObjects; i++)
        bOk = AccCopyObject (&pRegionDst->pObjects [i], &pRegionSrc->pObjects [i]) && bOk;
  } /* if */

  return (bOk);
} /* AccCopyRegion */

/*****************************************************************************/

GLOBAL BOOL AccCopyObject (ACC_OBJECT *pObjectDst, ACC_OBJECT *pObjectSrc)
{
  BOOL  bOk;
  SET   setProperties;
  SHORT sProperty, sType;
  CHAR  *pCharSrc, *pCharDst;

  bOk = TRUE;

  mem_lmove (pObjectDst, pObjectSrc, sizeof (ACC_OBJECT));
  AccObjGetProperties (pObjectSrc->sClass, setProperties);

  for (sProperty = ACC_PROP_CLASS; sProperty < ACC_NUM_PROPERTIES; sProperty++)
    if (setin (setProperties, sProperty))
    {
      AccObjGetPropertyType (sProperty, &sType);

      if (sType == TYPE_CHAR)
      {
        AccObjGetProperty (pObjectSrc, sProperty, &pCharSrc);

        if (pCharSrc != NULL)
        {
          pCharDst = mem_alloc (strlen (pCharSrc) + 1);

          if (pCharDst == NULL)
            bOk = FALSE;
          else
          {
            strcpy (pCharDst, pCharSrc);
            AccObjSetProperty (pObjectDst, sProperty, &pCharDst);
          } /* else */
        } /* if */
      } /* if */
    } /* if, for */

  return (bOk);
} /* AccCopyObject */

/*****************************************************************************/

GLOBAL VOID AccFree (ACCOUNT *pAccount)
{
  SHORT i;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    AccFreeRegion (&pAccount->arAccountHeader);

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    AccFreeRegion (&pAccount->arPageHeader);

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
      AccFreeRegion (&pAccount->agGroups [i].arHeader);

  AccFreeRegion (&pAccount->arDetails);

  for (i = pAccount->sNumGroups - 1; i >= 0; i--)
    if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
      AccFreeRegion (&pAccount->agGroups [i].arFooter);

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
    AccFreeRegion (&pAccount->arPageFooter);

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
    AccFreeRegion (&pAccount->arAccountFooter);
} /* AccFree */

/*****************************************************************************/

GLOBAL VOID AccFreeRegion (ACC_REGION *pRegion)
{
  SHORT i;

  for (i = 0; i < pRegion->sNumObjects; i++)
    AccFreeObject (&pRegion->pObjects [i]);

  if (pRegion->pObjects != NULL)
    mem_free (pRegion->pObjects);

  pRegion->sNumObjects = 0;
  pRegion->pObjects    = NULL;
} /* AccFreeRegion */

/*****************************************************************************/

GLOBAL VOID AccFreeObject (ACC_OBJECT *pObject)
{
  SET   setProperties;
  SHORT sProperty, sType;
  CHAR  *pChar;

  AccObjGetProperties (pObject->sClass, setProperties);

  for (sProperty = ACC_PROP_CLASS; sProperty < ACC_NUM_PROPERTIES; sProperty++)
    if (setin (setProperties, sProperty))
    {
      AccObjGetPropertyType (sProperty, &sType);

      if (sType == TYPE_CHAR)
      {
        AccObjGetProperty (pObject, sProperty, &pChar);

        if (pChar != NULL)
          mem_free (pChar);
      } /* if */
    } /* if, for */
} /* AccFreeObject */

/*****************************************************************************/

GLOBAL BOOL AccObjGetProperty (ACC_OBJECT *pObject, SHORT sProperty, VOID *pValue)
{
  BOOL bOk;
  CHAR *p;

  bOk = AccObjHasProperty (pObject->sClass, sProperty);

  if (bOk)
  {
    p = (CHAR *)pObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : if (aProperties [sProperty].lFlag == 0)
                         *(SHORT *)pValue = *(SHORT *)p;
                       else
                         *(SHORT *)pValue = (*(SHORT *)p & aProperties [sProperty].lFlag) != 0;
                       break;
      case TYPE_LONG : if (aProperties [sProperty].lFlag == 0)
                         *(LONG *)pValue = *(LONG *)p;
                       else
                         *(LONG *)pValue = (*(LONG *)p & aProperties [sProperty].lFlag) != 0;
                       break;
      case TYPE_CHAR : *(CHAR **)pValue = *(CHAR **)p;
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccObjGetProperty */

/*****************************************************************************/

GLOBAL BOOL AccObjSetProperty (ACC_OBJECT *pObject, SHORT sProperty, VOID *pValue)
{
  BOOL bOk;
  CHAR *p;

  bOk = AccObjHasProperty (pObject->sClass, sProperty);

  if (bOk)
  {
    p = (CHAR *)pObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : if (aProperties [sProperty].lFlag == 0)
                         *(SHORT *)p = *(SHORT *)pValue;
                       else
                         *(SHORT *)p = *(SHORT *)pValue ? (*(SHORT *)p | aProperties [sProperty].lFlag) : (*(SHORT *)p & ~aProperties [sProperty].lFlag);
                       break;
      case TYPE_LONG : if (aProperties [sProperty].lFlag == 0)
                         *(LONG *)p = *(LONG *)pValue;
                       else
                         *(LONG *)p = *(LONG *)pValue ? (*(LONG *)p | aProperties [sProperty].lFlag) : (*(LONG *)p & ~aProperties [sProperty].lFlag);
                       break;
      case TYPE_CHAR : *(CHAR **)p = *(CHAR **)pValue;
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccObjSetProperty */

/*****************************************************************************/

GLOBAL BOOL AccObjGetPropertyStr (ACC_OBJECT *pObject, SHORT sProperty, CHAR *pFormat, CHAR **ppStr)
{
  BOOL bOk;
  CHAR *p, *pValue;

  bOk    = AccObjHasProperty (pObject->sClass, sProperty);
  *ppStr = NULL;

  if (bOk)
  {
    p = (CHAR *)pObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : /* fall through */
      case TYPE_LONG : bOk = AccGetPropertyStr (pObject, pObject->sClass, sProperty, pFormat, ppStr);
                       break;
      case TYPE_CHAR : pValue = *(CHAR **)p;
                       *ppStr = strdup ((pValue == NULL) ? "" : pValue);
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccObjGetPropertyStr */

/*****************************************************************************/

GLOBAL BOOL AccObjSetPropertyStr (ACC_OBJECT *pObject, SHORT sProperty, CHAR *pFormat, CHAR *pStr)
{
  BOOL bOk;
  CHAR *p;

  bOk = AccObjHasProperty (pObject->sClass, sProperty);

  if (bOk)
  {
    p = (CHAR *)pObject + aProperties [sProperty].lOffset;

    switch (aProperties [sProperty].sType)
    {
      case TYPE_WORD : /* fall through */
      case TYPE_LONG : bOk = AccSetPropertyStr (pObject, pObject->sClass, sProperty, pFormat, pStr);
                       break;
      case TYPE_CHAR : *(CHAR **)p = pStr;
                       break;
    } /* switch */
  } /* if */

  return (bOk);
} /* AccObjSetPropertyStr */

/*****************************************************************************/

GLOBAL VOID AccObjDraw (ACC_OBJECT *pObject, SHORT sVdiHandle, RECT rc, CHAR *pText, SHORT sType, LONG lFontScaleFactor, LONG lPixelsPerMeter)
{
  SHORT ret;

  text_default (sVdiHandle);
  line_default (sVdiHandle);

  if (AccObjHasProperty (pObject->sClass, ACC_PROP_FONT_FONT))	/* seetings needed for groupbox calculations */
  {
    vst_font (sVdiHandle, pObject->Font.font);
    vst_arbpoint (sVdiHandle, (SHORT)((pObject->Font.point * lFontScaleFactor + 500) / 1000), &ret, &ret, &ret, &ret);
    vst_effects (sVdiHandle, pObject->Font.effects);
    vst_color (sVdiHandle, pObject->Font.color);
  } /* if */

  if (AccObjHasProperty (pObject->sClass, ACC_PROP_BK_MODE))
    DrawBackground (sVdiHandle, pObject, rc);

  if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_MODE))
    DrawBorder (sVdiHandle, pObject, rc, pText, lPixelsPerMeter);

  if (pText == NULL)
    if (AccObjHasProperty (pObject->sClass, ACC_PROP_TEXT))
      pText = pObject->pText;

  if (pText != NULL)
    DrawText (sVdiHandle, pObject, rc, pText, sType, lPixelsPerMeter);
} /* AccObjDraw */

/*****************************************************************************/

GLOBAL LONG AccObjCalcUnitHeight (ACC_OBJECT *pObject, SHORT sVdiHandle, CHAR *pText, LONG lPixelsPerMeter)
{
  LONG    lHeight, lResHeight, lMaxWidth;
  SHORT   sRet, sRotation, sWidth, sHeight, sResWidth, sResHeight, sMaxWidth;
  CHAR    *p;
  LONGSTR s;

  lHeight    = pObject->rcPos.h;
  lResHeight = 0;
  sRotation  = 0;

  text_default (sVdiHandle);
  line_default (sVdiHandle);

  if (AccObjHasProperty (pObject->sClass, ACC_PROP_FONT_FONT))	/* seetings needed for calculations */
  {
    vst_font (sVdiHandle, pObject->Font.font);
    vst_arbpoint (sVdiHandle, pObject->Font.point, &sRet, &sRet, &sRet, &sRet);
    vst_effects (sVdiHandle, pObject->Font.effects);
    vst_color (sVdiHandle, pObject->Font.color);
  } /* if */

  if (pText == NULL)
    if (AccObjHasProperty (pObject->sClass, ACC_PROP_TEXT))
      pText = pObject->pText;

  if (AccObjHasProperty (pObject->sClass, ACC_PROP_ROTATION))
    sRotation = pObject->sRotation / 90 * 90;			/* only multiple of 90 degrees for now */

  if ((pText != NULL) && (*pText != EOS) && (sRotation == 0))	/* only rotation of 0 degrees allowed */
  {
    sResWidth = sResHeight = 0;
    lMaxWidth = pObject->rcPos.w;

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_WIDTH))
      if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_MODE))
        if (pObject->sBorderMode == MODE_OPAQUE)
          lMaxWidth -= 2 * pObject->lBorderWidth;

    if ((pObject->sClass == OBJ_CHECKBOX) || (pObject->sClass == OBJ_RADIOBUTTON))
      lMaxWidth -= CHECK_SPACE * pObject->Font.point / 10;

    sMaxWidth = PIXELS_FROM_UNITS (lMaxWidth, lPixelsPerMeter);

    text_extent (sVdiHandle, pText, TRUE, NULL, &sHeight);	/* get height for each line */

    p = pText;

    while ((p = GetLine (sVdiHandle, p, s, sMaxWidth)) != NULL)
    {
      text_extent (sVdiHandle, s, TRUE, &sWidth, NULL);

      sResHeight += sHeight;

      if (sWidth > sResWidth)
        sResWidth = sWidth;
    } /* while */

    lResHeight = UNITS_FROM_PIXELS (sResHeight, lPixelsPerMeter);

    if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_WIDTH))
      if (AccObjHasProperty (pObject->sClass, ACC_PROP_BORDER_MODE))
        if (pObject->sBorderMode == MODE_OPAQUE)
          lResHeight += 2 * pObject->lBorderWidth;
  } /* if */

  if (pObject->lFlags & OBJ_CAN_GROW)
    if (lResHeight > lHeight)
      lHeight = lResHeight;

  if (pObject->lFlags & OBJ_CAN_SHRINK)
    if (lResHeight < lHeight)
      lHeight = lResHeight;

  return (lHeight);
} /* AccObjCalcUnitHeight */

/*****************************************************************************/

GLOBAL BOOL AccSysFromMem (BASE *base, SYSACCOUNT *pSysAccount, ACCOUNT *pAccount, BOOL bUpdate)
{
  BOOL    bOk;
  SHORT   sNumObjects, sStatus, i;
  LONG    lStringSize, lSize;
  SYSBLOB *pSysBlob;
  BLOB    *pBlob;
  CHAR    *p;

  bOk         = TRUE;
  sNumObjects = 0;
  lStringSize = 0;
  pBlob       = &pSysAccount->account;

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
  {
    sNumObjects += pAccount->arAccountHeader.sNumObjects;
    lStringSize += CalcStringSize (&pAccount->arAccountHeader);
  } /* if */

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
  {
    sNumObjects += pAccount->arPageHeader.sNumObjects;
    lStringSize += CalcStringSize (&pAccount->arPageHeader);
  } /* if */

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
    {
      sNumObjects += pAccount->agGroups [i].arHeader.sNumObjects;
      lStringSize += CalcStringSize (&pAccount->agGroups [i].arHeader);
    } /* if, for */

  sNumObjects += pAccount->arDetails.sNumObjects;
  lStringSize += CalcStringSize (&pAccount->arDetails);

  for (i = 0; i < pAccount->sNumGroups; i++)
    if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
    {
      sNumObjects += pAccount->agGroups [i].arFooter.sNumObjects;
      lStringSize += CalcStringSize (&pAccount->agGroups [i].arFooter);
    } /* if */

  if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
  {
    sNumObjects += pAccount->arPageFooter.sNumObjects;
    lStringSize += CalcStringSize (&pAccount->arPageFooter);
  } /* if */

  if (pAccount->lFlags & ACC_HAS_HEADFOOT)
  {
    sNumObjects += pAccount->arAccountFooter.sNumObjects;
    lStringSize += CalcStringSize (&pAccount->arAccountFooter);
  } /* if */

  lSize    = sizeof (ACCOUNT) + sNumObjects * sizeof (ACC_OBJECT) + lStringSize;
  pSysBlob = mem_alloc (sizeof (SYSBLOB) + lSize);

  if (pSysBlob == NULL)
    bOk = FALSE;
  else
  {
    pSysBlob->address = pBlob->address;
    pSysBlob->size    = lSize;
    pSysBlob->flags   = 0;

    strcpy (pSysBlob->ext,  pBlob->ext);
    strcpy (pSysBlob->name, pBlob->name);

    p = (CHAR *)pSysBlob->blob;

    mem_lmove (p, pAccount, sizeof (ACCOUNT));
    p += sizeof (ACCOUNT);

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      p = SaveObjects (p, &pAccount->arAccountHeader);

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      p = SaveObjects (p, &pAccount->arPageHeader);

    for (i = 0; i < pAccount->sNumGroups; i++)
      if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
        p = SaveObjects (p, &pAccount->agGroups [i].arHeader);

    p = SaveObjects (p, &pAccount->arDetails);

    for (i = 0; i < pAccount->sNumGroups; i++)
      if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
        p = SaveObjects (p, &pAccount->agGroups [i].arFooter);

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      p = SaveObjects (p, &pAccount->arPageFooter);

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      p = SaveObjects (p, &pAccount->arAccountFooter);

    if (bUpdate && (pSysBlob->address == 0))
      bUpdate = FALSE;

    if (bUpdate)
      bOk = db_update (base, SYS_BLOB, pSysBlob, &sStatus);
    else
      bOk = db_insert (base, SYS_BLOB, pSysBlob, &sStatus);

    pBlob->address = bOk ? pSysBlob->address : 0;
    pBlob->size    = pSysBlob->size;

    mem_free (pSysBlob);
  } /* else */

  return (bOk);
} /* AccSysFromMem */

/*****************************************************************************/

GLOBAL BOOL AccMemFromSys (BASE *base, ACCOUNT *pAccount, SYSACCOUNT *pSysAccount)
{
  BOOL    bOk;
  SHORT   i;
  SYSBLOB *pSysBlob;
  CHAR    *p, *pVersion;

  pSysBlob = db_readblob (base, NULL, NULL, pSysAccount->account.address, FALSE);
  bOk      = pSysBlob != NULL;

  if (bOk)
  {
    p        = (CHAR *)pSysBlob->blob;
    pVersion = strrchr (pSysAccount->account.name, ' ') + 1;

    if (strcmp (pVersion, "1.0") == 0)
    {
      mem_lmove (pAccount, p, OFFSET (ACCOUNT, sPageFormat));
      p += OFFSET (ACCOUNT, sPageFormat);

      pAccount->sPageFormat      = PAGE_DEFAULT;
      pAccount->sPageOrientation = OR_PORTRAIT;
    } /* if */
    else if (strcmp (pVersion, "1.2") <= 0)
    {
      mem_lmove (pAccount, p, OFFSET (ACCOUNT, szPrinter));
      p += OFFSET (ACCOUNT, szPrinter);

      pAccount->szPrinter [0] = EOS;
    } /* if */
    else
    {
      mem_lmove (pAccount, p, sizeof (ACCOUNT));
      p += sizeof (ACCOUNT);
    } /* else */

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      p = LoadObjects (p, &pAccount->arAccountHeader, pVersion);

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      p = LoadObjects (p, &pAccount->arPageHeader, pVersion);

    for (i = 0; i < pAccount->sNumGroups; i++)
      if (pAccount->agGroups [i].lFlags & GROUP_HEADER)
        p = LoadObjects (p, &pAccount->agGroups [i].arHeader, pVersion);

    p = LoadObjects (p, &pAccount->arDetails, pVersion);

    for (i = 0; i < pAccount->sNumGroups; i++)
      if (pAccount->agGroups [i].lFlags & GROUP_FOOTER)
        p = LoadObjects (p, &pAccount->agGroups [i].arFooter, pVersion);

    if (pAccount->lFlags & ACC_HAS_PAGE_HEADFOOT)
      p = LoadObjects (p, &pAccount->arPageFooter, pVersion);

    if (pAccount->lFlags & ACC_HAS_HEADFOOT)
      p = LoadObjects (p, &pAccount->arAccountFooter, pVersion);

    mem_free (pSysBlob);

    bOk = p != NULL;
  } /* if */

  if (bOk)
    strcpy (pAccount->szName, pSysAccount->name);

  return (bOk);
} /* AccMemFromSys */

/*****************************************************************************/

GLOBAL CHAR *AccStrDup (CHAR *pStr)
{
  CHAR *p;

  if (pStr == NULL)
    p = NULL;
  else
  {
    p = mem_alloc (strlen (pStr) + 1);

    if (p != NULL)
      strcpy (p, pStr);
  } /* else */

  return (p);
} /* AccStrDup */

/*****************************************************************************/

LOCAL LONG CalcStringSize (ACC_REGION *pRegion)
{
  LONG  lSize;
  SHORT i;

  for (i = 0, lSize = 0; i < pRegion->sNumObjects; i++)
    lSize += CalcObjStringSize (&pRegion->pObjects [i]);

  return (lSize);
} /* CalcStringSize */

/*****************************************************************************/

LOCAL LONG CalcObjStringSize (ACC_OBJECT *pObject)
{
  LONG  lSize;
  SET   setProperties;
  SHORT sProperty, sType;
  CHAR  *pChar;

  lSize = 0;

  AccObjGetProperties (pObject->sClass, setProperties);

  for (sProperty = ACC_PROP_CLASS; sProperty < ACC_NUM_PROPERTIES; sProperty++)
    if (setin (setProperties, sProperty))
    {
      AccObjGetPropertyType (sProperty, &sType);

      if (sType == TYPE_CHAR)
      {
        AccObjGetProperty (pObject, sProperty, &pChar);

        if (pChar != NULL)
          lSize += strlen (pChar) + 1;

        if (odd (lSize))
          lSize++;
      } /* if */
    } /* if, for */

  return (lSize);
} /* CalcObjStringSize */

/*****************************************************************************/

LOCAL CHAR *SaveObjects (CHAR *p, ACC_REGION *pRegion)
{
  SHORT i;

  for (i = 0; i < pRegion->sNumObjects; i++)
    p = SaveObject (p, &pRegion->pObjects [i]);

  return (p);
} /* SaveObjects */

/*****************************************************************************/

LOCAL CHAR *SaveObject (CHAR *p, ACC_OBJECT *pObject)
{
  ACC_OBJECT *pSavedObject;
  SET        setProperties;
  SHORT      sProperty, sType;
  CHAR       *pChar;
  LONG       lSize;

  pSavedObject = (ACC_OBJECT *)p;

  mem_lmove (p, pObject, sizeof (ACC_OBJECT));

  pSavedObject->lFlags &= ~OBJ_SELECTED;
  p                    += sizeof (ACC_OBJECT);

  AccObjGetProperties (pObject->sClass, setProperties);

  for (sProperty = ACC_PROP_CLASS; sProperty < ACC_NUM_PROPERTIES; sProperty++)
    if (setin (setProperties, sProperty))
    {
      AccObjGetPropertyType (sProperty, &sType);

      if (sType == TYPE_CHAR)
      {
        AccObjGetProperty (pObject, sProperty, &pChar);

        if (pChar != NULL)
        {
          mem_lmove (p, pChar, strlen (pChar) + 1);
          lSize  = strlen (pChar) + 1;
          p     += lSize;

          if (odd (lSize))				/* go to even adress for 68000 */
            *p++ = EOS;					/* fill with zero */
        } /* if */
      } /* if */
    } /* if, for */

  return (p);
} /* SaveObject */

/*****************************************************************************/

LOCAL CHAR *LoadObjects (CHAR *p, ACC_REGION *pRegion, CHAR *pVersion)
{
  SHORT i;

  if (p != NULL)				/* there has been an error */
  {
    if (pRegion->sNumObjects != 0)
      if ((pRegion->pObjects = mem_alloc (pRegion->sNumObjects * sizeof (ACC_OBJECT))) == NULL)
        p = NULL;

    if (p != NULL)
      for (i = 0; i < pRegion->sNumObjects; i++)
        p = LoadObject (p, &pRegion->pObjects [i], pVersion);
  } /* if */

  return (p);
} /* LoadObjects */

/*****************************************************************************/

LOCAL CHAR *LoadObject (CHAR *p, ACC_OBJECT *pObject, CHAR *pVersion)
{
  SET   setProperties;
  SHORT sProperty, sType;
  CHAR  *pChar;
  LONG  lSize;

  mem_lset (pObject, 0, sizeof (ACC_OBJECT));

  if (strcmp (pVersion, "1.1") == 0)
  {
    mem_lmove (pObject, p, OFFSET (ACC_OBJECT, pLinkCondition));
    p += OFFSET (ACC_OBJECT, pLinkCondition);
  } /* if */
  else if (strcmp (pVersion, "1.2") == 0)
  {
    mem_lmove (pObject, p, OFFSET (ACC_OBJECT, pLinkOrder));
    p += OFFSET (ACC_OBJECT, pLinkOrder);
  } /* if */
  else
  {
    mem_lmove (pObject, p, sizeof (ACC_OBJECT));
    p += sizeof (ACC_OBJECT);
  } /* else */

  AccObjGetProperties (pObject->sClass, setProperties);

  for (sProperty = ACC_PROP_CLASS; sProperty < ACC_NUM_PROPERTIES; sProperty++)
    if (setin (setProperties, sProperty))
    {
      AccObjGetPropertyType (sProperty, &sType);

      if (sType == TYPE_CHAR)
      {
        AccObjGetProperty (pObject, sProperty, &pChar);

        if (pChar != NULL)
        {
          pChar = AccStrDup (p);
          AccObjSetProperty (pObject, sProperty, &pChar);
          lSize  = strlen (p) + 1;
          p     += lSize;

          if (strcmp (pVersion, "1.3") > 0)
            if (odd (lSize))				/* go to even adress for 68000 */
              p++;
        } /* if */
      } /* if */
    } /* if, for */

  return (p);
} /* LoadObject */

/*****************************************************************************/

LOCAL VOID DrawBackground (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc)
{
  SHORT xy [4];

  if (pObject->sBkMode != MODE_TRANSPARENT)		/* clear background */
  {
    rect2array (&rc, xy);
    vswr_mode (sVdiHandle, MD_REPLACE);
    vsf_color (sVdiHandle, pObject->sBkColor);
    vsf_interior (sVdiHandle, FIS_SOLID);
    vsf_perimeter (sVdiHandle, FALSE);
    v_bar (sVdiHandle, xy);
  } /* if */
} /* DrawBackground */

/*****************************************************************************/

LOCAL VOID DrawBorder (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc, CHAR *pText, LONG lPixelsPerMeter)
{
  SHORT xy [12], w, h, sWidth, sBorderWidth, i, sLeft, sRight;
  BOOL  bHorz;

  sBorderWidth = GetBorderWidth (pObject, lPixelsPerMeter);

  if ((sBorderWidth != 0) && (pObject->sBorderMode == MODE_OPAQUE))	/* draw border */
  {
    vswr_mode (sVdiHandle, (pObject->sBorderMode == MODE_OPAQUE) ? MD_REPLACE : MD_TRANS);
    vsl_color (sVdiHandle, pObject->sBorderColor);
    vsl_type (sVdiHandle, pObject->sBorderStyle + 1);	/* GEM value starts with 1 */

    if (pObject->sClass == OBJ_LINE)			/* no double border */
    {
      if (sBorderWidth > rc.w)
        sBorderWidth = rc.w;

      if (sBorderWidth > rc.h)
        sBorderWidth = rc.h;
    } /* if */
    else						/* double border */
    {
      if (sBorderWidth > rc.w / 2)
        sBorderWidth = rc.w / 2;

      if (sBorderWidth > rc.h / 2)
        sBorderWidth = rc.h / 2;
    } /* else */

    if (sBorderWidth == 0)
      sBorderWidth = 1;

    if (pObject->sClass == OBJ_GROUPBOX)
    {
      text_extent (sVdiHandle, "x", FALSE, &sWidth, NULL);
      text_extent (sVdiHandle, pText, TRUE, &w, &h);

      sLeft  = (pObject->sHorzAlignment == ALI_HSTANDARD) || (pObject->sHorzAlignment == ALI_HLEFT) ? sWidth : (pObject->sHorzAlignment == ALI_HCENTER) ? (rc.w - w) / 2 - sWidth : rc.w - w - 3 * sWidth;
      sRight = (pObject->sHorzAlignment == ALI_HSTANDARD) || (pObject->sHorzAlignment == ALI_HLEFT) ? w + 3 * sWidth : (pObject->sHorzAlignment == ALI_HCENTER) ? (rc.w + w) / 2 + sWidth : rc.w - sWidth;

      xy [ 0] = rc.x + sLeft;
      xy [ 1] = rc.y + h / 2;
      xy [ 2] = rc.x;
      xy [ 3] = xy [1];
      xy [ 4] = xy [2];
      xy [ 5] = rc.y + rc.h - 1;
      xy [ 6] = rc.x + rc.w - 1;
      xy [ 7] = xy [5];
      xy [ 8] = xy [6];
      xy [ 9] = xy [1];
      xy [10] = rc.x + sRight;
      xy [11] = xy [1];

      if ((pText == NULL) || (pText [0] == EOS))	/* empty box, set border to top edge again */
      {
        xy [ 1] -= h / 2;
        xy [ 3]  = xy [1];
        xy [ 9]  = xy [1];
        xy [10]  = xy [0];
        xy [11]  = xy [1];
      } /* if */

      if (pObject->sEffect == EFFECT_NORMAL)
      {
        for (i = 0; i < sBorderWidth; i++)
        {
          v_pline (sVdiHandle, 6, xy);

          xy [ 1]++;
          xy [ 2]++;
          xy [ 3]++;
          xy [ 4]++;
          xy [ 5]--;
          xy [ 6]--;
          xy [ 7]--;
          xy [ 8]--;
          xy [ 9]++;
          xy [11]++;
        } /* for */
      } /* if */
      else
      {
        xy [5]--;
        xy [6]--;
        xy [7] = xy [5];
        xy [8] = xy [6];

        vsl_color (sVdiHandle, (pObject->sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNHIGHLIGHT] : sys_colors [COLOR_BTNSHADOW]);
        v_pline (sVdiHandle, 6, xy);

        xy [ 1]++;
        xy [ 2]++;
        xy [ 3]++;
        xy [ 4]++;
        xy [ 5]++;
        xy [ 6]++;
        xy [ 7] = xy [5];
        xy [ 8] = xy [6];
        xy [ 9]++;
        xy [11]++;

        vsl_color (sVdiHandle, (pObject->sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNSHADOW] : sys_colors [COLOR_BTNHIGHLIGHT]);
        v_pline (sVdiHandle, 6, xy);
      } /* else */
    } /* if */
    else if (pObject->sClass == OBJ_LINE)
    {
      bHorz = rc.w >= rc.h;

      if (pObject->sEffect == EFFECT_NORMAL)
      {
        for (i = 0; i < sBorderWidth; i++)
        {
          if (bHorz)
          {
            xy [0] = rc.x;
            xy [1] = rc.y + i;
            xy [2] = rc.x + rc.w - 1;
            xy [3] = xy [1];
          } /* if */
          else
          {
            xy [0] = rc.x + i;
            xy [1] = rc.y;
            xy [2] = xy [0];
            xy [3] = rc.y + rc.h - 1;
          } /* else */

          v_pline (sVdiHandle, 2, xy);
        } /* for */
      } /* if */
      else
      {
        if (bHorz)
        {
          xy [0] = rc.x;
          xy [1] = rc.y;
          xy [2] = rc.x + rc.w - 1;
          xy [3] = xy [1];
        } /* if */
        else
        {
          xy [0] = rc.x;
          xy [1] = rc.y;
          xy [2] = xy [0];
          xy [3] = rc.y + rc.h - 1;
        } /* else */

        vsl_color (sVdiHandle, (pObject->sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNHIGHLIGHT] : sys_colors [COLOR_BTNSHADOW]);
        v_pline (sVdiHandle, 2, xy);

        if (bHorz)
        {
          xy [1]++;
          xy [3]++;
        } /* if */
        else
        {
          xy [0]++;
          xy [2]++;;
        } /* else */

        vsl_color (sVdiHandle, (pObject->sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNSHADOW] : sys_colors [COLOR_BTNHIGHLIGHT]);
        v_pline (sVdiHandle, 2, xy);
      } /* else */
    } /* else */
    else
      if (pObject->sEffect == EFFECT_NORMAL)
      {
        for (i = 0; i < sBorderWidth; i++)
        {
          xy [0] = rc.x + i;
          xy [1] = rc.y + rc.h - 1 - i;
          xy [2] = xy [0];
          xy [3] = rc.y + i;
          xy [4] = rc.x + rc.w - 1 - i;
          xy [5] = xy [3];
          xy [6] = xy [4];
          xy [7] = xy [1];
          xy [8] = xy [0];
          xy [9] = xy [1];

          v_pline (sVdiHandle, 5, xy);
        } /* for */
      } /* if */
      else
      {
        if (pObject->sEffect == EFFECT_RAISED)
        {
          if (sBorderWidth == 1)
            draw_3d (sVdiHandle, rc.x + 1, rc.y + 1, 1, rc.w - 2, rc.h - 2, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], FALSE);
          else
          {
            draw_3d (sVdiHandle, rc.x + 1, rc.y + 1, 1, rc.w - 2, rc.h - 2, sys_colors [COLOR_BTNFACE], BLACK, sys_colors [COLOR_BTNSHADOW], FALSE);
            draw_3d (sVdiHandle, rc.x + 2, rc.y + 2, 1, rc.w - 4, rc.h - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], FALSE);
          } /* else */
        } /* if */
        else
        {
          draw_3d (sVdiHandle, rc.x + 1, rc.y + 1, 1, rc.w - 2, rc.h - 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);

          if (sBorderWidth > 1)
            draw_3d (sVdiHandle, rc.x + 2, rc.y + 2, 1, rc.w - 4, rc.h - 4, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
        } /* else */
      } /* if, else */
  } /* if */
} /* DrawBorder */

/*****************************************************************************/

LOCAL VOID DrawText (SHORT sVdiHandle, ACC_OBJECT *pObject, RECT rc, CHAR *pText, SHORT sType, LONG lPixelsPerMeter)
{
  SHORT   sBorderWidth, sLeft, sWidth, sMaxWidth, sLineHeight, sHorzOffset, sVertOffset, sSaveColors, sCheckSpace;
  SHORT   sHorzAlignment, sVertAlignment, sRotation;
  SHORT   x, y, w, h;
  BOOL    bCheckRadio;
  RECT    rcSave, r;
  CHAR    *p;
  LONGSTR s;

  if ((pText != NULL) && (pText [0] != EOS))
  {
    sBorderWidth = GetBorderWidth (pObject, lPixelsPerMeter);

    vswr_mode (sVdiHandle, MD_TRANS);

    if (pObject->sClass == OBJ_GROUPBOX)
    {
      text_extent (sVdiHandle, "x", FALSE, &sWidth, NULL);
      text_extent (sVdiHandle, pText, TRUE, &w, &h);

      sLeft = (pObject->sHorzAlignment == ALI_HSTANDARD) || (pObject->sHorzAlignment == ALI_HLEFT) ? sWidth : (pObject->sHorzAlignment == ALI_HCENTER) ? (rc.w - w) / 2 - sWidth : rc.w - w - 3 * sWidth;
      x     = rc.x + sLeft + sWidth;
      y     = rc.y;

      v_text (sVdiHandle, x, y, pText);
    } /* if */
    else
    {
      rcSave = clip;
      rc_inflate (&rc, - sBorderWidth, - sBorderWidth);
      rc_intersect (&rc, &clip);

      x = rc.x;
      y = rc.y;

      bCheckRadio    = (pObject->sClass == OBJ_CHECKBOX) || (pObject->sClass == OBJ_RADIOBUTTON);
      sHorzAlignment = ALI_HLEFT;
      sVertAlignment = ALI_VTOP;
      sRotation      = 0;

      if (bCheckRadio)
        sCheckSpace = PIXELS_FROM_UNITS (CHECK_SPACE * pObject->Font.point / 10, lPixelsPerMeter);

      if (AccObjHasProperty (pObject->sClass, ACC_PROP_HORZ_ALIGNMENT))
        sHorzAlignment = pObject->sHorzAlignment;

      if (AccObjHasProperty (pObject->sClass, ACC_PROP_VERT_ALIGNMENT))
        sVertAlignment = pObject->sVertAlignment;

      if (AccObjHasProperty (pObject->sClass, ACC_PROP_ROTATION))
        sRotation = pObject->sRotation / 90 * 90;			/* only multiple of 90 degrees for now */

      if (sHorzAlignment == ALI_HSTANDARD)
        if (bCheckRadio)
          sHorzAlignment = ALI_HLEFT;
        else
          switch (sType)
          {
            case TYPE_WORD      : /* fall through */
            case TYPE_LONG      : /* fall through */
            case TYPE_FLOAT     : /* fall through */
            case TYPE_CFLOAT    : /* fall through */
            case TYPE_DBADDRESS : sHorzAlignment = ALI_HRIGHT;
                                  break;
            default             : sHorzAlignment = ALI_HLEFT;
                                  break;
          } /* switch, else, if */

      if (sVertAlignment == ALI_VSTANDARD)
        sVertAlignment = ALI_VTOP;

      set_clip (TRUE, &clip);
      text_extent (sVdiHandle, pText, TRUE, NULL, &sLineHeight);	/* get height for each line */

      if ((sRotation == 0) || (sRotation == 180))
      {
        if (bCheckRadio)
        {
          sMaxWidth = rc.w - sCheckSpace;

          if (sMaxWidth < 0)
            sMaxWidth = 0;
        } /* if */
        else
          sMaxWidth = rc.w;

        CalcTextSize (sVdiHandle, pText, sMaxWidth, &w, &h);
      } /* if */
      else
      {
        sMaxWidth = rc.h;
        CalcTextSize (sVdiHandle, pText, sMaxWidth, &h, &w);
      } /* else */

      switch (sRotation)
      {
        case  90 : y += rc.h - 1;
                   break;
        case 180 : x += rc.w - 1;
                   y += rc.h - 1;
                   break;
        case 270 : x += rc.w - 1;
                   break;
      } /* switch */

      p = pText;

      while ((p = GetLine (sVdiHandle, p, s, sMaxWidth)) != NULL)
      {
        RemTrailSP (s);
        text_extent (sVdiHandle, s, TRUE, &sWidth, NULL);

        if ((sRotation == 0) || (sRotation == 180))
        {
          switch (sHorzAlignment)
          {
            case ALI_HLEFT   : sHorzOffset = 0;                   break;
            case ALI_HCENTER : sHorzOffset = (rc.w - sWidth) / 2; break;
            case ALI_HRIGHT  : sHorzOffset = rc.w - sWidth;       break;
          } /* switch */

          switch (sVertAlignment)
          {
            case ALI_VTOP    : sVertOffset = 0;              break;
            case ALI_VCENTER : sVertOffset = (rc.h - h) / 2; break;
            case ALI_VBOTTOM : sVertOffset = rc.h - h;       break;
          } /* switch */
        } /* if */
        else					/* meaning of horizontal and vertical alignment swapped */
        {
          switch (sHorzAlignment)
          {
            case ALI_HLEFT   : sVertOffset = 0;                   break;
            case ALI_HCENTER : sVertOffset = (rc.h - sWidth) / 2; break;
            case ALI_HRIGHT  : sVertOffset = rc.h - sWidth;       break;
          } /* switch */

          switch (sVertAlignment)
          {
            case ALI_VTOP    : sHorzOffset = 0;              break;
            case ALI_VCENTER : sHorzOffset = (rc.w - w) / 2; break;
            case ALI_VBOTTOM : sHorzOffset = rc.w - w;       break;
          } /* switch */
        } /* else */

        if (bCheckRadio)
          sHorzOffset = sCheckSpace;

        if ((sRotation == 90) || (sRotation == 180))
          sVertOffset = - sVertOffset;

        if ((sRotation == 180) || (sRotation == 270))
          sHorzOffset = - sHorzOffset;

        vst_rotation (sVdiHandle, 10 * sRotation);
        v_text (sVdiHandle, x + sHorzOffset, y + sVertOffset, s);
        vst_rotation (sVdiHandle, 0);			/* don't use rotation for GetLine */

        switch (sRotation)
        {
          case   0 : y += sLineHeight;
                     break;
          case  90 : x += sLineHeight;
                     break;
          case 180 : y -= sLineHeight;
                     break;
          case 270 : x -= sLineHeight;
                     break;
        } /* switch */
      } /* while */

      if (bCheckRadio)
      {
        r   = rc;
        r.w = sCheckSpace * 8 / 10;
        r.h = sLineHeight;

        if ((16 <= sLineHeight) && (sLineHeight <= 20) || (pObject->sEffect != EFFECT_NORMAL))
        {
          sSaveColors = dlg_colors;
          dlg_colors  = (pObject->sEffect == EFFECT_NORMAL) ? 2 : colors;

          DrawCheckRadio (sVdiHandle, &r, &clip, NULL, FAILURE, (pObject->lFlags & OBJ_IS_SELECTED) ? SELECTED : NORMAL, FAILURE - 1, &pObject->Font, pObject->sClass == OBJ_RADIOBUTTON);
          vswr_mode (sVdiHandle, MD_TRANS);	/* has been set to MD_REPLACE by DrawCheckRadio */

          dlg_colors = sSaveColors;
        } /* if */
        else
        {
          r.x++;				/* so light grey line is not being drawn over checkbox */
          DrawCheckbox (sVdiHandle, &r, &clip, (pObject->lFlags & OBJ_IS_SELECTED) != 0, pObject->sClass == OBJ_RADIOBUTTON);
        } /* else */
      } /* if */
     
      set_clip (TRUE, &rcSave);
    } /* else */
  } /* if */
} /* DrawText */

/*****************************************************************************/

LOCAL VOID DrawCheckbox (SHORT sVdiHandle, RECT *rc, RECT *rcClip, BOOL bChecked, BOOL bRadio)
{
  SHORT sWidth, i, xy [4];
  RECT  r;

  r     = *rc;
  rc->w = min (rc->w, rc->h);			/* symmetric */
  rc->h = min (rc->w, rc->h);

  r.y += (r.h - rc->h) / 2;			/* center from original size */
  r.w  = (rc->w * 8 + 5) / 10;			/* checkbox/radio button should fill 80% of the whole rectangle */
  r.h  = (rc->h * 8 + 5) / 10;
  r.y += (rc->h - r.h + 1) / 2;			/* center (round up) from new size */

  if (! odd (r.w))
    r.w++;

  if (! odd (r.h))
    r.h++;

  sWidth = (rc->w + 8) / 16;

  if (sWidth == 0)
    sWidth = 1;

  rect2array (&r, xy);
  vswr_mode (sVdiHandle, MD_TRANS);
  vsf_perimeter (sVdiHandle, TRUE);
  vsf_color (sVdiHandle, BLACK);
  vsf_interior (sVdiHandle, FIS_HOLLOW);

  if (bRadio)
  {
    for (i = 0; i < sWidth; i++)
      v_circle (sVdiHandle, r.x + r.w / 2, r.y + r.w / 2, r.w / 2 - i);

    if (bChecked)
    {
      vswr_mode (sVdiHandle, MD_REPLACE);
      vsf_interior (sVdiHandle, FIS_SOLID);
      v_circle (sVdiHandle, r.x + r.w / 2, r.y + r.w / 2, r.w / 4);
    } /* if */
  } /* else */
  else
  {
    for (i = 0; i < sWidth; i++)
    {
      v_bar (sVdiHandle, xy);
      xy [0]++;
      xy [1]++;
      xy [2]--;
      xy [3]--;
    } /* for */

    if (bChecked)
    {
      line_default (sVdiHandle);

      for (i = 0; i < sWidth / 2 + 1; i++)
      {
        xy [0] = r.x + i;
        xy [1] = r.y;
        xy [2] = r.x + r.w - 1;
        xy [3] = r.y + r.h - 1 - i;
        v_pline (sVdiHandle, 2, xy);

        xy [0] = r.x;
        xy [1] = r.y + i;
        xy [2] = r.x + r.w - 1 - i;
        xy [3] = r.y + r.h - 1;
        v_pline (sVdiHandle, 2, xy);

        xy [0] = r.x + r.w - 1 - i;
        xy [1] = r.y;
        xy [2] = r.x;
        xy [3] = r.y + r.h - 1 - i;
        v_pline (sVdiHandle, 2, xy);

        xy [0] = r.x + r.w - 1;
        xy [1] = r.y + i;
        xy [2] = r.x + i;
        xy [3] = r.y + r.h - 1;
        v_pline (sVdiHandle, 2, xy);
      } /* for */
    } /* if */
  } /* else */

  vswr_mode (sVdiHandle, MD_TRANS);
} /* DrawCheckbox */

/*****************************************************************************/

LOCAL VOID CalcTextSize (SHORT sVdiHandle, CHAR *pText, SHORT sMaxWidth, SHORT *pWidth, SHORT *pHeight)
{
  SHORT   sWidth, sHeight, sResWidth, sResHeight;
  CHAR    *p;
  LONGSTR s;

  sResWidth = sResHeight = 0;

  if (pText != NULL)
  {
    text_extent (sVdiHandle, pText, TRUE, NULL, &sHeight);		/* get height for each line */

    p = pText;

    while ((p = GetLine (sVdiHandle, p, s, sMaxWidth)) != NULL)
    {
      text_extent (sVdiHandle, s, TRUE, &sWidth, NULL);

      sResHeight += sHeight;

      if (sWidth > sResWidth)
        sResWidth = sWidth;
    } /* while */
  } /* if */    

  *pWidth  = sResWidth;
  *pHeight = sResHeight;
} /* CalcTextSize */

/*****************************************************************************/

LOCAL CHAR *GetLine (SHORT sVdiHandle, CHAR *pText, CHAR *pLine, SHORT sMaxWidth)
{
  SHORT sWidth, i, iSave;
  CHAR  *pSave, c;

  *pLine = EOS;

  if ((pText == NULL) || (*pText == EOS))
    pText = NULL;
  else
  {
    sWidth = i = 0;
    pSave  = NULL;

    while ((*pText != EOS) && (*pText != '\n') && (sWidth <= sMaxWidth))
    {
      c = *pText++;

      if (c != '\r')
      {
        if (c == '\t')
        {
          while ((i < LONGSTRLEN) && (i % 8 != 7)) pLine [i++] = SP;
          c = SP;
        } /* if */

        pLine [i++] = c;
        pLine [i]   = EOS;

        if (isspace (c))
        {
          pSave = pText;				/* save pointer and position behind space */
          iSave = i;
        } /* if */

        text_extent (sVdiHandle, pLine, TRUE, &sWidth, NULL);
      } /* if */
    } /* while */

    if (sWidth > sMaxWidth)
      if (pSave != NULL)				/* at least one space */
      {
        pText         = pSave;				/* go behind space */
        pLine [iSave] = EOS;
      } /* if */
      else
        if (i > 1)					/* use at least one letter */
        {
          pText--;					/* could also be '\n'... */
          pLine [i - 1] = EOS;
        } /* if, else, if */

    if (*pText == '\n')					/* ... so this test has to be the last */
      pText++;
  } /* else */

  return (pText);
} /* GetLine */

/*****************************************************************************/

LOCAL SHORT GetBorderWidth (ACC_OBJECT *pObject, LONG lPixelsPerMeter)
{
  SHORT sBorderWidth = 0;

  if (pObject->sBorderMode != MODE_TRANSPARENT)
  {
    sBorderWidth = PIXELS_FROM_UNITS (pObject->lBorderWidth, lPixelsPerMeter);

    if ((sBorderWidth == 0) && (pObject->lBorderWidth != 0))	/* use at least one pixel */
      sBorderWidth = 1;
  } /* if */

  return (sBorderWidth);
} /* GetBorderWidth */

/*****************************************************************************/

LOCAL VOID RemTrailSP (CHAR *pString)
{
  REG CHAR *p;
  REG LONG l;

  for (p = pString, l = 0; *p != EOS; p++, l++);
  l--;
  while ((l >= 0) && isspace (pString [l])) l--;
  pString [l + 1] = EOS;
} /* RemTrailSP */

/*****************************************************************************/

LOCAL VOID SortObjects (SHORT sNumObjects, ACC_OBJECT *pObj)
{
  qsort ((VOID *)pObj, (SIZE_T)sNumObjects, sizeof (ACC_OBJECT), CompareObjects);
} /* SortObjects */

/*****************************************************************************/

LOCAL INT CompareObjects (ACC_OBJECT *pObj1, ACC_OBJECT *pObj2)
{
  return ((pObj1->rcPos.y == pObj2->rcPos.y) ? (pObj1->rcPos.x - pObj2->rcPos.x < 0) ? -1 : 1 : (pObj1->rcPos.y - pObj2->rcPos.y) < 0 ? -1 : 1);
} /* CompareObjects */

/*****************************************************************************/

