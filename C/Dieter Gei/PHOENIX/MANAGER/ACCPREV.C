/*****************************************************************************
 *
 * Module : ACCPREV.C
 * Author : Dieter Geiž
 *
 * Creation date    : 26.11.96
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the account preview window.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 05.04.97: 2 colored checkboxes/radio buttons are being drawn transparently
 * 27.02.97: Additional parameter "filename" for open_work_ex used
 * 25.02.97: Actual window is no longer unclicked
 * 23.02.97: Preview window is large enough to be seen completely on a resolution with 768 pixels of height
 * 15.02.97: Check box borders are rounded up
 * 14.02.97: B/W button added
 * 12.01.97: CHECK_SPACE is used proportional to point size
 * 10.01.97: Number of colors of vdi workstation are determined after opening workstation
 * 02.01.97: VDI workstation won't remain open during preview
 * 01.01.97: Trying to correct rounding problems
 * 31.12.96: Border width of lines is drawn correctly
 * 26.11.96: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "process.h"
#include "resource.h"

#include "export.h"
#include "accprev.h"

/****** DEFINES **************************************************************/

#define KIND		(NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS		(WI_CURSKEYS)
#define DOCW		300		/* 300 mm */
#define DOCH		600		/* 600 mm */
#define XFAC		4		/* X-Faktor (Pixel / mm) */
#define YFAC		4		/* Y-Faktor (Pixel / mm) */
#define XUNITS		10		/* X-Einheiten fr Scrolling */
#define YUNITS		10		/* Y-Einheiten fr Scrolling */
#define XSCROLL		0		/* Nicht-Scrollbarer linker Bereich */
#define YSCROLL		0		/* Nicht-Scrollbarer oberer Bereich */
#define INITX		(20 * gl_wbox)  /* X-Anfangsposition */
#define INITY		( 5 * gl_hbox + 7) /* Y-Anfangsposition */
#define INITW		((210 + 2 * PAGE_MARGIN) * window->xfac) /* Anfangsbreite in Pixel */
#define INITH		(40 * gl_hbox)  /* Anfangsh”he in Pixel */
#define MILLI		0               /* Millisekunden fr Zeitablauf */

#define PAGE_MARGIN	3		/* left and top margins from window to page */
#define CHECK_SPACE	480L		/* space for checkboxes and radio buttons */

#define UNITS_PER_METER	100000L
#define UNITS_FROM_PIXELS(pixels, fac)	(LONG)(((pixels) * UNITS_PER_METER + (fac) / 2) / (fac))
#define PIXELS_FROM_UNITS(units, fac)	(SHORT)(((units) * (fac) + UNITS_PER_METER / 2) / UNITS_PER_METER)
#define FRACT_FROM_UNITS(units, fac)	((units) * (fac) % UNITS_PER_METER)

#define P_PROC_INF(window)		((PROC_INF *)window->special)
#define P_WORK(pProcInf)		((WORK *)pProcInf->memory)

enum ACC_PREVIEW_TYPE
{
  TYPE_BACKGROUND,			/* background */
  TYPE_RECTANGLE,			/* rectangle */
  TYPE_LINE,				/* line */
  TYPE_GROUPBOX,			/* groupbox */
  TYPE_CHECKBOX,			/* checkbox */
  TYPE_RADIOBUTTON,			/* radio button */
  TYPE_TEXT,				/* text */
  TYPE_GRAPHIC				/* picture */
}; /* ACC_PREVIEW_TYPE */

enum ACC_PREVIEW_MODE
{
  MODE_OPAQUE,				/* opaque */
  MODE_TRANSPARENT			/* transparent */
}; /* ACC_PREVIEW_MODE */

enum ACC_PREVIEW_BORDERSTYLE
{
  BORDER_SOLID,				/* ______ */
  BORDER_LONGDASH,			/* ------ */
  BORDER_DOT,				/* ...... */
  BORDER_DASHDOT,			/* _._._. */
  BORDER_DASH,				/* ______ */
  BORDER_DASH2DOT			/* _.._.. */
}; /* ACC_PREVIEW_BORDERSTYLE */

enum ACC_PREVIEW_EFFECT
{
  EFFECT_NORMAL,			/* normal border */
  EFFECT_RAISED,			/* raised border */
  EFFECT_CARVED				/* carved border */
}; /* ACC_PREVIEW_EFFECT */

enum ACC_PREVIEW_HORIZONTAL_ALIGNMENT
{
  ALI_HSTANDARD,			/* align standard */
  ALI_HLEFT,				/* align left */
  ALI_HCENTER,				/* align center */
  ALI_HRIGHT				/* align right */
}; /* ACC_PREVIEW_HORIZONTAL_ALIGNMENT */

enum ACC_PREVIEW_VERTICAL_ALIGNMENT
{
  ALI_VSTANDARD,			/* align standard */
  ALI_VTOP,				/* align on top */
  ALI_VCENTER,				/* align center */
  ALI_VBOTTOM				/* align on bottom */
}; /* ACC_PREVIEW_VERTICAL_ALIGNMENT */

/****** TYPES ****************************************************************/

typedef struct
{
  SHORT    sIconHeight;			/* height of icon bar */
  HFILE    hFile;			/* preview file */
  FULLNAME szFileName;			/* name of preview file */
  BOOL     bRemoveTmpFile;		/* remove temporary file on close */
  STRING   szName;			/* name of object to print */
  LONG     lFontScaleFactor;		/* font scaling factor in 1/1000 (for wysiwyg) */
  LONG     lZoomInx;			/* index of zoom factor */
  SHORT    sOutHandle;			/* vdi handle of output device */
  SHORT    sColors;			/* colors of vdi workstation */
  SHORT    sScreenColors;		/* colors of screen vdi workstation */
  BOOL     bOutAvailable;		/* output device available? */
  DEVINFO  devinfo;			/* device info */
  LONG     lPixelsPerMeter;		/* pixels per meter on device */
  LONG     lScreenPixelsPerMeter;	/* pixels per meter on screen */
  LONG     lPageSize;			/* size of actual page */
  UCHAR    *pPageBuffer;		/* buffer for one page */
  LONG     lPageTable;			/* address of page table in file */
  LONG     lPageNr;			/* actual page */
  LONG     lNumPages;			/* number of pages */
  LONG     lWidth;			/* width of account in 1/1000 cm */
  LONG     lMarginLeft;			/* left margin of page in 1/1000 cm */
  LONG     lMarginRight;		/* right margin of page in 1/1000 cm */
  LONG     lMarginTop;			/* top margin of page in 1/1000 cm */
  LONG     lMarginBottom;		/* bottom margin of page in 1/1000 cm */
  SHORT    sPageFormat;			/* page format */
  SHORT    sPageOrientation;		/* page orientation */
  LONG     lPhysPageWidth;		/* physical page width in 1/1000 cm */
  LONG     lPhysPageHeight;		/* physical page height in 1/1000 cm */
  LONG     lRealPageWidth;		/* printable page width in 1/1000 cm */
  LONG     lRealPageHeight;		/* printable page height in 1/1000 cm */
  LONG     lXOffset;			/* x offset of printable margin */
  LONG     lYOffset;			/* y offset of printable margin */
  LONG     alPageTable [MAX_PAGES];	/* table of page addresses inside the object file */
} SPEC;

typedef enum ACC_PREVIEW_TYPE ACC_PREVIEW_TYPE;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
} OBJ_GENERIC;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  SHORT            sColor;		/* color of background (index) */
} OBJ_BACKGROUND;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  SHORT            sEffect;		/* special effect of border or field */
  SHORT            sMode;		/* border mode */
  SHORT            sColor;		/* color of border */
  LONG             lWidth;		/* width of border in 1/1000 cm */
  SHORT            sStyle;		/* style of border */
} OBJ_RECTLINE;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  SHORT            sEffect;		/* special effect of border or field */
  SHORT            sMode;		/* border mode */
  SHORT            sColor;		/* color of border */
  LONG             lWidth;		/* width of border in 1/1000 cm */
  SHORT            sStyle;		/* style of border */
  FONTDESC         Font;		/* font of text */
  SHORT            sHorzAlignment;	/* horizontal aligment of text */
  LONG             lTextLength;		/* actual text length */
  CHAR             pText [0];		/* the text itself (used dynamically) */
} OBJ_GROUPBOX;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  SHORT            sEffect;		/* special effect of border or field */
  FONTDESC         Font;		/* font of text */
  BOOL             bChecked;		/* button is checked */
  LONG             lTextLength;		/* actual text length */
  CHAR             pText [0];		/* the text itself (used dynamically) */
} OBJ_CHECKRADIO;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  LONG             lWidth;		/* width of border in 1/1000 cm */
  FONTDESC         Font;		/* font of text */
  SHORT            sHorzAlignment;	/* horizontal aligment of text */
  SHORT            sVertAlignment;	/* vertical alignment of text */
  SHORT            sRotation;		/* rotation of text in degrees */
  LONG             lTextLength;		/* actual text length */
  CHAR             pText [0];		/* the text itself (used dynamically) */
} OBJ_TEXT;

typedef struct
{
  ACC_PREVIEW_TYPE Type;		/* type of object */
  LRECT            lRect;		/* position of object */
  LONG             lWidth;		/* width of border in 1/1000 cm */
  LONG             lFileNameLength;	/* actual filename length */
  CHAR             pFileName [0];	/* the filename itself (used dynamically) */
} OBJ_GRAPHIC;

typedef struct
{
  WORD     wOutDevice;			/* output device number */
  SHORT    sOutHandle;			/* vdi handle of output device */
  SHORT    sColors;			/* colors of vdi workstation */
  DEVINFO  devinfo;			/* device info */
  FULLNAME szFileName;			/* name of object file */
  HFILE    hFile;			/* object file */
  LONG     lPageTable;			/* address of page table in file */
  LONG     lPageNr;			/* actual page */
  LONG     lNumPages;			/* number of pages */
  LONG     lWidth;			/* width of account in 1/1000 cm */
  LONG     lMarginLeft;			/* left margin of page in 1/1000 cm */
  LONG     lMarginRight;		/* right margin of page in 1/1000 cm */
  LONG     lMarginTop;			/* top margin of page in 1/1000 cm */
  LONG     lMarginBottom;		/* bottom margin of page in 1/1000 cm */
  SHORT    sPageFormat;			/* page format */
  SHORT    sPageOrientation;		/* page orientation */
  LONG     alPageTable [MAX_PAGES];	/* table of page addresses inside the object file */
} WORK;

/****** VARIABLES ************************************************************/

LOCAL CHAR *apszZoomStr [] = {" 25%", " 50%", " 75%", "100%", "200%", "250%", "500%"};

LOCAL SHORT asBackgroundPatterns [] =
{
  0, /* WHITE */
  8, /* BLACK */
  2, /* RED */
  2, /* GREEN */
  3, /* BLUE */
  1, /* CYAN */
  1, /* YELLOW */
  1, /* MAGENTA */
  4, /* DWHITE */
  7, /* DBLACK */
  6, /* DRED */
  6, /* DGREEN */
  7, /* DBLUE */
  5, /* DCYAN */
  5, /* DYELLOW */
  5  /* DMAGENTA */
};

LOCAL SHORT asTextColors [] =
{
  WHITE, /* WHITE */
  BLACK, /* BLACK */
  WHITE, /* RED */
  WHITE, /* GREEN */
  WHITE, /* BLUE */
  WHITE, /* CYAN */
  WHITE, /* YELLOW */
  WHITE, /* MAGENTA */
  WHITE, /* DWHITE */
  BLACK, /* DBLACK */
  BLACK, /* DRED */
  BLACK, /* DGREEN */
  BLACK, /* DBLUE */
  BLACK, /* DCYAN */
  BLACK, /* DYELLOW */
  BLACK  /* DMAGENTA */
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
LOCAL VOID  SetZoomInx         (WINDOWP window, LONG lZoomInx);
LOCAL LONG  ZoomCallback       (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL VOID  HandlePopup        (WINDOWP window, MKINFO *mk, SHORT obj);

LOCAL BOOL  ReadPage           (WINDOWP window, LONG lPageNr);

LOCAL VOID  DrawPage           (SHORT sVdiHandle, RECT *rcPage, RECT *rcClip, UCHAR *pPageBuffer, LONG lPageSize, LONG lPixelsPerMeter, LONG lFontScaleFactor, LONG lXOffset, LONG lYOffset, SHORT sColors);
LOCAL VOID  DrawTypeBackground (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, OBJ_BACKGROUND *pBackground);
LOCAL VOID  DrawTypeRectLine   (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_RECTLINE *pRectLine);
LOCAL VOID  DrawTypeGroupbox   (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_GROUPBOX *pGroupbox);
LOCAL VOID  DrawTypeCheckRadio (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, BOOL bChecked, OBJ_CHECKRADIO *pCheckRadio, SHORT sCheckSpace);
LOCAL VOID  DrawTypeText       (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_TEXT *pText);
LOCAL VOID  DrawTypeGraphic    (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_GRAPHIC *pGraphic);

LOCAL VOID  DrawBorder         (SHORT sVdiHandle, SHORT sColors, RECT rc, RECT rcClip, SHORT sBorderWidth, INT iType, SHORT sEffect, SHORT sMode, SHORT sColor, SHORT sStyle, CHAR *pText, SHORT sHorzAlignment);
LOCAL VOID  DrawText           (SHORT sVdiHandle, SHORT sColors, RECT rc, RECT rcClip, SHORT sBorderWidth, INT iType, SHORT sEffect, CHAR *pText, FONTDESC *font, SHORT sHorzAlignment, SHORT sVertAlignment, SHORT sRotation, BOOL bChecked, SHORT sCheckSpace);
LOCAL CHAR  *GetLine           (SHORT sVdiHandle, CHAR *pText, CHAR *pLine, SHORT sMaxWidth);
LOCAL VOID  SetFont            (SHORT sVdiHandle, SHORT sColors, FONTDESC *pFont, LONG lFontScaleFactor);
LOCAL VOID  PrintCheckRadio    (SHORT sVdiHandle, RECT *rc, RECT *rcClip, BOOL bChecked, BOOL bRadio);

LOCAL BOOL  WorkPrint          (PROC_INF *pProcInf);
LOCAL BOOL  StopPrint          (PROC_INF *pProcInf);

/*****************************************************************************/

GLOBAL BOOL AccPrevInit (VOID)
{
  WORD obj;

  obj = ROOT;

  do
  {
    if (is_type (previcon, obj, G_BUTTON))
      previcon [obj].ob_y = 4;
  } while (! is_flags (previcon, obj++, LASTOB));

  previcon [ROOT].ob_width  = previcon [PIBOX].ob_width = desk.w;
  previcon [ROOT].ob_height = previcon [PIBOX].ob_height = previcon [PIFIRST].ob_y + previcon [PIFIRST].ob_height + 4 + 1;

  ListBoxSetFont (previcon, PIZOOM, FONT_SYSTEM, gl_point, TXT_NORMAL, BLACK, WHITE);
  ListBoxSetCallback (previcon, PIZOOM, ZoomCallback);
  ListBoxSetStyle (previcon, PIZOOM, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (previcon, PIZOOM, LBS_VSCROLL | LBS_VREALTIME, FALSE);
  ListBoxSetLeftOffset (previcon, PIZOOM, gl_wbox / 2);
  ListBoxSetCount (previcon, PIZOOM, sizeof (apszZoomStr) / sizeof (CHAR *), NULL);

  return (TRUE);
} /* AccPrevInit */

/*****************************************************************************/

GLOBAL BOOL AccPrevTerm (VOID)
{
  return (TRUE);
} /* AccPrevTerm */

/*****************************************************************************/

GLOBAL WINDOWP AccPrevCreate (OBJECT *obj, OBJECT *menu, WORD icon, CHAR *pFileName, CHAR *pAccountName)
{
  WINDOWP window;
  SHORT   menu_height, inx, work_out [57];
  WORD    wDevice;
  SPEC    *pSpec;

  menu_height = (menu != NULL) ? gl_hattr : 0;

  if ((pSpec = (SPEC *)mem_alloc ((LONG)sizeof (SPEC))) == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (pSpec, 0, sizeof (SPEC));
  strcpy (pSpec->szFileName, pFileName);
  strcpy (pSpec->szName, pAccountName);

  pSpec->hFile = file_open (pFileName, O_RDONLY);

  if (pSpec->hFile < 0)
  {
    file_error (ERR_FILEOPEN, pFileName);
    mem_free (pSpec);
    return (NULL);
  } /* if */

  pSpec->sIconHeight    = previcon->ob_height + 1 + menu_height;
  pSpec->lZoomInx       = 1;				/* 50% */
  pSpec->lPageNr        = 0;				/* so ReadPage will read in a page */
  pSpec->bRemoveTmpFile = TRUE;

  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lPageTable);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lNumPages);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lWidth);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lMarginLeft);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lMarginRight);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lMarginTop);
  file_read (pSpec->hFile, sizeof (LONG), &pSpec->lMarginBottom);
  file_read (pSpec->hFile, sizeof (WORD), &wDevice);
  file_read (pSpec->hFile, sizeof (SHORT), &pSpec->sPageFormat);
  file_read (pSpec->hFile, sizeof (SHORT), &pSpec->sPageOrientation);
  file_seek (pSpec->hFile, pSpec->lPageTable, SEEK_SET);
  file_read (pSpec->hFile, (pSpec->lNumPages + 1) * sizeof (LONG), pSpec->alPageTable);

  inx    = num_windows (CLASS_ACCPREV, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_ACCPREV);

  if (window != NULL)
  {
    window->xfac = (SHORT)(XFAC * atol (apszZoomStr [pSpec->lZoomInx]) / 100L);
    window->yfac = (SHORT)(YFAC * atol (apszZoomStr [pSpec->lZoomInx]) / 100L);

    wind_calc (WC_WORK, KIND, desk.x + desk.w - INITW, INITY, INITW, INITH,
               &window->scroll.x, &window->scroll.y, &window->scroll.w, &window->scroll.h);

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = DOCW;
    window->doc.h     = DOCH;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->xscroll   = XSCROLL;
    window->yscroll   = YSCROLL;
    window->scroll.x  = INITX + inx * gl_wbox + window->xscroll;
    window->scroll.y  = INITY + inx * gl_hbox + window->yscroll + pSpec->sIconHeight + odd (menu_height);
    window->scroll.w  = INITW / window->xfac * window->xfac;
    window->scroll.h  = min (INITH, (desk.y + desk.h - window->scroll.y - 2 * gl_hbox) / window->yfac * window->yfac);
    window->work.x    = window->scroll.x - window->xscroll;
    window->work.y    = window->scroll.y - window->yscroll - pSpec->sIconHeight;
    window->work.w    = window->scroll.w + window->xscroll;
    window->work.h    = window->scroll.h + window->yscroll + pSpec->sIconHeight;
    window->bg_color  = FAILURE;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)pSpec;
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
    window->objop     = NULL;
    window->drag      = NULL;
    window->click     = WindowClick;
    window->unclick   = WindowUnclick;
    window->key       = WindowKey;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = AccPrevInfo;
    window->showhelp  = AccPrevHelp;

    sprintf (window->name, " %s ",  (pAccountName [0] == EOS) ? FREETXT (FNOTITLE) : pAccountName);

    pSpec->sOutHandle    = open_work_ex (wDevice, &pSpec->devinfo, pSpec->sPageFormat, pSpec->sPageOrientation, NULL);
    pSpec->bOutAvailable = pSpec->sOutHandle != 0;
 
    if (! pSpec->bOutAvailable)				/* no output device defined, use screen handle */
    {
      pSpec->sOutHandle = vdi_handle;
      pSpec->devinfo    = screen_info;
    } /* if */
    else
      vst_ex_load_fonts (pSpec->sOutHandle, 0, 3072, 0);

    vq_extnd (pSpec->sOutHandle, FALSE, work_out);
    pSpec->sColors       = work_out [13];
    pSpec->sScreenColors = colors;

    pSpec->lFontScaleFactor      = YFAC * (LONG)screen_info.pix_h;
    pSpec->lScreenPixelsPerMeter = YFAC * 1000;
    pSpec->lPixelsPerMeter       = pSpec->devinfo.lPixelsPerMeter;
    pSpec->lRealPageWidth        = pSpec->devinfo.lRealPageWidth / 10;
    pSpec->lRealPageHeight       = pSpec->devinfo.lRealPageHeight / 10;
    pSpec->lXOffset              = pSpec->devinfo.lXOffset / 10;
    pSpec->lYOffset              = pSpec->devinfo.lYOffset / 10;
    pSpec->lPhysPageWidth        = pSpec->devinfo.lPhysPageWidth / 10;
    pSpec->lPhysPageHeight       = pSpec->devinfo.lPhysPageHeight / 10;

    window->doc.w = pSpec->lPhysPageWidth  / 100 + 2 * PAGE_MARGIN;
    window->doc.h = pSpec->lPhysPageHeight / 100 + 2 * PAGE_MARGIN;

    if (pSpec->bOutAvailable)
    {
      vst_unload_fonts (pSpec->sOutHandle, 0);
      close_work (wDevice, pSpec->sOutHandle);
      pSpec->sOutHandle = 0;
    } /* if */

    if (! ReadPage (window, 1))
    {
      delete_window (window);
      window = NULL;
    } /* if */
  } /* if */
  else
  {
    file_close (pSpec->hFile);
    file_remove (pSpec->szFileName);
    mem_free (pSpec->pPageBuffer);
    mem_free (pSpec);
  } /* else */

  set_meminfo ();

  return (window);
} /* AccPrevCreate */

/*****************************************************************************/

GLOBAL BOOL AccPrevOpen (WORD icon, CHAR *pFileName, CHAR *pAccountName)
{
  BOOL    bOk;
  WINDOWP window;

  window = AccPrevCreate (NULL, NULL, icon, pFileName, pAccountName);
  bOk    = window != NULL;

  if (bOk)
  {
    bOk = open_window (window);

    if (! bOk)
      hndl_alert (ERR_NOOPEN);
  } /* if */

  return (bOk);
} /* AccPrevOpen */

/*****************************************************************************/

GLOBAL BOOL AccPrevInfo (WINDOWP window, WORD icon)
{
  return (TRUE);
} /* AccPrevInfo */

/*****************************************************************************/

GLOBAL BOOL AccPrevHelp (WINDOWP window, WORD icon)
{
  return (hndl_help (HPREVIEW));
} /* AccPrevHelp */

/*****************************************************************************/

GLOBAL VOID AccPrevPrint (WINDOWP window)
{
  SPEC      *pSpec = (SPEC *)window->special;
  FULLNAME  szFileName;
  FIELDNAME szName;

  pSpec->bRemoveTmpFile = FALSE;		/* will be deleted after printing */

  strcpy (szFileName, pSpec->szFileName);
  strcpy (szName, pSpec->szName);
  delete_window (window);
  AccPrevPrintFile (szFileName, szName);
} /* AccPrevPrint */

/*****************************************************************************/

GLOBAL VOID AccPrevPrintFile (CHAR *pFileName, CHAR *pAccountName)
{
  PROC_INF ProcInf, *pProcInf;
  WINDOWP  window;
  WORK     *pWork;
  LONG     lBytes;
  HFILE    hFile;
  SHORT    work_out [57];
  WORD     wDevice, wDevGroup;
  CHAR     *pszFileName;
  FULLNAME szFileName;

  hFile = file_open (pFileName, O_RDONLY);

  if (hFile < 0)
  {
    file_error (ERR_FILEOPEN, pFileName);
    return;
  } /* if */

  ProcInf.db           = NULL;
  ProcInf.table        = FAILURE;
  ProcInf.inx          = FAILURE;
  ProcInf.dir          = FAILURE;
  ProcInf.cols         = 0;
  ProcInf.columns      = NULL;
  ProcInf.colwidth     = NULL;
  ProcInf.cursor       = NULL;
  ProcInf.format       = 2;
  ProcInf.maxrecs      = 0;
  ProcInf.events_ps    = events_ps;
  ProcInf.recs_pe      = recs_pe;
  ProcInf.impexpcfg    = NULL;
  ProcInf.page_format  = NULL;
  ProcInf.prncfg       = NULL;
  ProcInf.to_printer   = FALSE;
  ProcInf.binary       = FALSE;
  ProcInf.tmp          = FALSE;
  ProcInf.special      = DEV_PRINTER;
  ProcInf.filename [0] = EOS;
  ProcInf.file         = NULL;
  ProcInf.filelength   = 0;
  ProcInf.workfunc     = WorkPrint;
  ProcInf.stopfunc     = StopPrint;

  lBytes = sizeof (WORK);

  if (odd (lBytes)) lBytes++;					/* db buffers should be on even address */

  window = crt_process (NULL, NULL, NIL, FREETXT (FPREPORT), &ProcInf, lBytes, wi_modeless);

  if (window != NULL)
  {
    pProcInf = P_PROC_INF (window);
    pWork    = P_WORK (pProcInf);

    mem_lset (pWork, 0, lBytes);

    pWork->hFile   = hFile;
    pWork->lPageNr = 1;

    file_read (pWork->hFile, sizeof (LONG), &pWork->lPageTable);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lNumPages);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lWidth);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lMarginLeft);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lMarginRight);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lMarginTop);
    file_read (pWork->hFile, sizeof (LONG), &pWork->lMarginBottom);
    file_read (pWork->hFile, sizeof (WORD), &wDevice);
    file_read (pWork->hFile, sizeof (SHORT), &pWork->sPageFormat);
    file_read (pWork->hFile, sizeof (SHORT), &pWork->sPageOrientation);
    file_seek (pWork->hFile, pWork->lPageTable, SEEK_SET);
    file_read (pWork->hFile, (pWork->lNumPages + 1) * sizeof (LONG), pWork->alPageTable);

    wDevGroup = (wDevice - 1) / 10 * 10 + 1;

    switch (wDevGroup)
    {
      case METAFILE : pszFileName = szFileName;
                      strcpy (szFileName, pAccountName);
                      strcat (szFileName, FREETXT (FGEMSUFF) + 1);
                      if (! get_open_filename (FSAVEFIL, NULL, 0L, FFILTER_GEM, NULL, NULL, FAILURE, szFileName, NULL))
                      {
                        file_close (pWork->hFile);
                        file_remove (pWork->szFileName);
                        delete_window (window);
                        return;
                      } /* if */
                      break;
      case IMG_SYS  : pszFileName = szFileName;
                      strcpy (szFileName, "PAGE0001.IMG");
                      if (! get_open_filename (FSAVEFIL, NULL, 0L, FFILTER_IMG, NULL, NULL, FAILURE, szFileName, NULL))
                      {
                        file_close (pWork->hFile);
                        file_remove (pWork->szFileName);
                        delete_window (window);
                        return;
                      } /* if */
                      break;
      default       : pszFileName = NULL;
                      break;
    } /* switch */

    pProcInf->maxrecs = pWork->lNumPages;
    pWork->sOutHandle = open_work_ex (wDevice, &pWork->devinfo, pWork->sPageFormat, pWork->sPageOrientation, pszFileName);

    if (pWork->sOutHandle != 0)
    {
      if (wDevGroup == METAFILE)
        vm_filename (pWork->sOutHandle, pszFileName);

      vst_ex_load_fonts (pWork->sOutHandle, 0, 3072, 0);
      vq_extnd (pWork->sOutHandle, FALSE, work_out);
      pWork->sColors    = work_out [13];
      pWork->wOutDevice = wDevice;

      strcpy (pWork->szFileName, pFileName);
      strcpy (pProcInf->filestr, pAccountName);

    start_process (window, minimize_process, TRUE);
    } /* if */
    else
    {
      file_close (pWork->hFile);
      file_remove (pWork->szFileName);
      delete_window (window);
    } /* else */
  } /* if */
} /* AccPrevPrintFile */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteBackground (HFILE hFile, LRECT *rc, SHORT sColor)
{
  BOOL           bOk = TRUE;
  OBJ_BACKGROUND obj;

  obj.Type   = TYPE_BACKGROUND;
  obj.lRect  = *rc;
  obj.sColor = sColor;
  bOk        = file_write (hFile, sizeof (OBJ_BACKGROUND), &obj) == sizeof (OBJ_BACKGROUND);

  return (bOk);
} /* AccPrevWriteBackground */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteRectangle (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle)
{
  BOOL         bOk = TRUE;
  OBJ_RECTLINE obj;

  obj.Type    = TYPE_RECTANGLE;
  obj.lRect   = *rc;
  obj.sEffect = sEffect;
  obj.sMode   = sMode;
  obj.sColor  = sColor;
  obj.lWidth  = lWidth;
  obj.sStyle  = sStyle;
  bOk         = file_write (hFile, sizeof (OBJ_RECTLINE), &obj) == sizeof (OBJ_RECTLINE);

  return (bOk);
} /* AccPrevWriteRectangle */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteLine (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle)
{
  BOOL         bOk = TRUE;
  OBJ_RECTLINE obj;

  obj.Type    = TYPE_LINE;
  obj.lRect   = *rc;
  obj.sEffect = sEffect;
  obj.sMode   = sMode;
  obj.sColor  = sColor;
  obj.lWidth  = lWidth;
  obj.sStyle  = sStyle;
  bOk         = file_write (hFile, sizeof (OBJ_RECTLINE), &obj) == sizeof (OBJ_RECTLINE);

  return (bOk);
} /* AccPrevWriteLine */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteGroupBox (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle, FONTDESC *pFont, SHORT sHorzAlignment, CHAR *pText)
{
  BOOL         bOk   = TRUE;
  CHAR         chEOS = EOS;
  OBJ_GROUPBOX obj;

  obj.Type           = TYPE_GROUPBOX;
  obj.lRect          = *rc;
  obj.sEffect        = sEffect;
  obj.sMode          = sMode;
  obj.sColor         = sColor;
  obj.lWidth         = lWidth;
  obj.sStyle         = sStyle;
  obj.Font           = *pFont;
  obj.sHorzAlignment = sHorzAlignment;
  obj.lTextLength    = (pText == NULL) ? 0 : strlen (pText);
  bOk                = bOk && (file_write (hFile, sizeof (OBJ_GROUPBOX), &obj) == sizeof (OBJ_GROUPBOX));
  bOk                = bOk && (file_write (hFile, obj.lTextLength, pText) == obj.lTextLength);
  bOk                = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  if (odd (obj.lTextLength + 1))					/* use even adresses only */
    bOk = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  return (bOk);
} /* AccPrevWriteGroupBox */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteCheckRadio (HFILE hFile, LRECT *rc, SHORT sEffect, FONTDESC *pFont, CHAR *pText, BOOL bChecked, BOOL bRadio)
{
  BOOL           bOk   = TRUE;
  CHAR           chEOS = EOS;
  OBJ_CHECKRADIO obj;

  obj.Type           = bRadio ? TYPE_RADIOBUTTON : TYPE_CHECKBOX;
  obj.lRect          = *rc;
  obj.sEffect        = sEffect;
  obj.Font           = *pFont;
  obj.bChecked       = bChecked;
  obj.lTextLength    = (pText == NULL) ? 0 : strlen (pText);
  bOk                = bOk && (file_write (hFile, sizeof (OBJ_CHECKRADIO), &obj) == sizeof (OBJ_CHECKRADIO));
  bOk                = bOk && (file_write (hFile, obj.lTextLength, pText) == obj.lTextLength);
  bOk                = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  if (odd (obj.lTextLength + 1))					/* use even adresses only */
    bOk = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  return (bOk);
} /* AccPrevWriteCheckRadio */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteText (HFILE hFile, LRECT *rc, LONG lWidth, FONTDESC *pFont, SHORT sHorzAlignment, SHORT sVertAlignment, SHORT sRotation, CHAR *pText)
{
  BOOL     bOk   = TRUE;
  CHAR     chEOS = EOS;
  OBJ_TEXT obj;

  obj.Type           = TYPE_TEXT;
  obj.lRect          = *rc;
  obj.lWidth         = lWidth;
  obj.Font           = *pFont;
  obj.sHorzAlignment = sHorzAlignment;
  obj.sVertAlignment = sVertAlignment;
  obj.sRotation      = sRotation;
  obj.lTextLength    = (pText == NULL) ? 0 : strlen (pText);
  bOk                = bOk && (file_write (hFile, sizeof (OBJ_TEXT), &obj) == sizeof (OBJ_TEXT));
  bOk                = bOk && (file_write (hFile, obj.lTextLength, pText) == obj.lTextLength);
  bOk                = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  if (odd (obj.lTextLength + 1))					/* use even adresses only */
    bOk = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  return (bOk);
} /* AccPrevWriteText */

/*****************************************************************************/

GLOBAL BOOL AccPrevWriteGraphic (HFILE hFile, LRECT *rc, LONG lWidth, CHAR *pFileName)
{
  BOOL        bOk   = TRUE;
  CHAR        chEOS = EOS;
  OBJ_GRAPHIC obj;

  obj.Type            = TYPE_GRAPHIC;
  obj.lRect           = *rc;
  obj.lFileNameLength = (pFileName == NULL) ? 0 : strlen (pFileName);
  bOk                 = file_write (hFile, sizeof (OBJ_GRAPHIC), &obj) == sizeof (OBJ_GRAPHIC);
  bOk                 = bOk && (file_write (hFile, obj.lFileNameLength, pFileName) == obj.lFileNameLength);
  bOk                 = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  if (odd (obj.lFileNameLength + 1))					/* use even adresses only */
    bOk = bOk && (file_write (hFile, sizeof (CHAR), &chEOS) == sizeof (CHAR));

  return (bOk);
} /* AccPrevWriteGraphic */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN WindowTest (WINDOWP window, SHORT action)
{
  BOOL ret, ext;

  ret = TRUE;
  ext = (action & DO_EXTERNAL) != 0;
  ext = ext;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! acc_close)
                       ret = TRUE;
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
} /* WindowClose */

/*****************************************************************************/
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID WindowDelete (WINDOWP window)
{
  SPEC *pSpec = (SPEC *)window->special;

  file_close (pSpec->hFile);

  if (pSpec->bRemoveTmpFile)
    file_remove (pSpec->szFileName);

  if (pSpec->pPageBuffer != NULL)
    mem_free (pSpec->pPageBuffer);

  mem_free (pSpec);
  set_meminfo ();
} /* WindowDelete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID WindowDraw (WINDOWP window)
{
  SPEC  *pSpec = (SPEC *)window->special;
  SHORT xy [8], i, sBorderWidth;
  RECT  rc, rcPage, rc_clip, save;

  FixIconBar (window);
  objc_draw (previcon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  rc_clip = window->scroll;
  save    = clip;

  if (rc_intersect (&rc_clip, &clip))
  {
    set_clip (TRUE, &clip);

    text_default (vdi_handle);
    line_default (vdi_handle);

    vsf_perimeter (vdi_handle, FALSE);
    vsf_color (vdi_handle, (dlg_colors >= 16) ? DWHITE : BLACK);
    vsf_interior (vdi_handle, FIS_PATTERN);
    vsf_style (vdi_handle, (dlg_colors >= 16) ? 8 : 4);
    rect2array (&window->scroll, xy);
    vr_recfl (vdi_handle, xy);

    rc.x = window->scroll.x - (SHORT)window->doc.x * window->xfac;
    rc.y = window->scroll.y - (SHORT)window->doc.y * window->yfac;
    rc.w = (SHORT)(window->doc.w * window->xfac);
    rc.h = (SHORT)(window->doc.h * window->yfac);

    rcPage = rc;
    rc_inflate (&rcPage, - PAGE_MARGIN * window->xfac, - PAGE_MARGIN * window->yfac);

    rect2array (&rcPage, xy);
    vsf_perimeter (vdi_handle, FALSE);
    vsf_color (vdi_handle, WHITE);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_style (vdi_handle, 0);
    vr_recfl (vdi_handle, xy);					/* draw white page */

    sBorderWidth = window->xfac;

    vswr_mode (vdi_handle, MD_TRANS);
    vsf_perimeter (vdi_handle, TRUE);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_HOLLOW);
    vsf_style (vdi_handle, 0);

    for (i = 0, rc = rcPage; i < sBorderWidth; i++)
    {
      rc_inflate (&rc, 1, 1);
      rect2array (&rc, xy);
      v_bar (vdi_handle, xy);					/* draw border around page */
    } /* if */

    for (i = 0; i < sBorderWidth; i++)
    {
      xy [0] = rcPage.x + rcPage.w + sBorderWidth + i;
      xy [1] = rcPage.y;
      xy [2] = xy [0];
      xy [3] = rcPage.y + rcPage.h + sBorderWidth + i;
      xy [4] = rcPage.x;
      xy [5] = xy [3];
      v_pline (vdi_handle, 3, xy);				/* draw shadow */
    } /* if */

    if (pSpec->pPageBuffer != NULL)
      DrawPage (vdi_handle, &rcPage, &clip, pSpec->pPageBuffer, pSpec->lPageSize, pSpec->lScreenPixelsPerMeter * window->xfac / XFAC, pSpec->lFontScaleFactor * window->yfac / YFAC, 0, 0, pSpec->sScreenColors);

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
  } /* if */
} /* WindowSnap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID WindowClick (WINDOWP window, MKINFO *mk)
{
  SPEC  *pSpec = (SPEC *)window->special;
  SHORT obj;

  if (find_top () == window)
  {
    FixIconBar (window);

    set_clip (TRUE, &window->scroll);

    obj = objc_find (previcon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    if (obj != NIL)
      switch (obj)
      {
        case PIZOOM  : HandlePopup (window, mk, obj);
                       break;
        case PIBW    : window_button (window, previcon, obj, mk->breturn);
                       if (is_state (previcon, obj, SELECTED) && (pSpec->sScreenColors != 2))
                       {
                         pSpec->sScreenColors = 2;
                         set_redraw (window, &window->scroll);
                       } /* if */
 
                       if (! is_state (previcon, obj, SELECTED) && (pSpec->sScreenColors == 2))
                       {
                         pSpec->sScreenColors = colors;
                         set_redraw (window, &window->scroll);
                       } /* if */
                       break;
        default      : window_button (window, previcon, obj, mk->breturn);
                       if (is_state (previcon, obj, SELECTED))
                       {
                         switch (obj)
                         {
                           case PIFIRST : ReadPage (window, 1);                  break;
                           case PIPREV  : ReadPage (window, pSpec->lPageNr - 1); break;
                           case PINEXT  : ReadPage (window, pSpec->lPageNr + 1); break;
                           case PILAST  : ReadPage (window, pSpec->lNumPages);   break;
                         } /* switch */

                         undo_state (previcon, obj, SELECTED);
                         draw_win_obj (window, previcon, obj);
                       } /* if */
                       break;
      } /* switch, if */

    if (inside (mk->mox, mk->moy, &window->scroll))		/* in scrolling area ? */
    {
      if (mk->momask & 0x0001)
        SetZoomInx (window, pSpec->lZoomInx + 1);
      else
        SetZoomInx (window, pSpec->lZoomInx - 1);
    } /* if */
  } /* if */
} /* WindowClick */

/*****************************************************************************/

LOCAL VOID WindowUnclick (WINDOWP window)
{
} /* WindowUnclick */

/*****************************************************************************/
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN WindowKey (WINDOWP window, MKINFO *mk)
{
  SPEC *pSpec = (SPEC *)window->special;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  switch (mk->ascii_code)
  {
    case '+' : SetZoomInx (window, pSpec->lZoomInx + 1);
               return (TRUE);
    case '-' : SetZoomInx (window, pSpec->lZoomInx - 1);
               return (TRUE);
  } /* switch */

  return (FALSE);
} /* WindowKey */

/*****************************************************************************/

LOCAL VOID FixIconBar (WINDOWP window)
{
  SPEC   *pSpec = (SPEC *)window->special;
  STRING sz;

  previcon->ob_x = window->work.x;
  previcon->ob_y = window->work.y;

  ListBoxSetCurSel (previcon, PIZOOM, pSpec->lZoomInx);
  ListBoxSetSpec (previcon, PIZOOM, (LONG)window);

  sprintf (sz, FREETXT (FPAGE), pSpec->lPageNr, pSpec->lNumPages);
  set_str (previcon, PIPAGENR, sz);

  if (pSpec->sScreenColors == 2)
    do_state (previcon, PIBW, SELECTED);
  else
    undo_state (previcon, PIBW, SELECTED);

  if (pSpec->lPageNr > 1)
  {
    undo_state (previcon, PIFIRST, DISABLED);
    undo_state (previcon, PIPREV,  DISABLED);
  } /* if */
  else
  {
    do_state (previcon, PIFIRST, DISABLED);
    do_state (previcon, PIPREV,  DISABLED);
  } /* else */

  if (pSpec->lPageNr < pSpec->lNumPages)
  {
    undo_state (previcon, PINEXT, DISABLED);
    undo_state (previcon, PILAST, DISABLED);
  } /* if */
  else
  {
    do_state (previcon, PINEXT, DISABLED);
    do_state (previcon, PILAST, DISABLED);
  } /* else */
} /* FixIconBar */

/*****************************************************************************/

LOCAL VOID SetZoomInx (WINDOWP window, LONG lZoomInx)
{
  SPEC *pSpec = (SPEC *)window->special;

  if (lZoomInx < 0)
    lZoomInx = 0;

  if (lZoomInx >= sizeof (apszZoomStr) / sizeof (CHAR *))
    lZoomInx = sizeof (apszZoomStr) / sizeof (CHAR *) - 1;

  if (pSpec->lZoomInx != lZoomInx)
  {
    pSpec->lZoomInx = lZoomInx;
    window->xfac    = (SHORT)(XFAC * atol (apszZoomStr [lZoomInx]) / 100L);
    window->yfac    = (SHORT)(YFAC * atol (apszZoomStr [lZoomInx]) / 100L);

    set_sliders (window, HORIZONTAL | VERTICAL, SLPOS | SLSIZE);
    set_redraw (window, &window->work);
    snap_window (window, NULL, SIZED);
  } /* if */
} /* SetZoomInx */

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
  LONG lItem;

  if (mk->breturn == 1)
  {
    do_state (previcon, obj, SELECTED);
    draw_win_obj (window, previcon, obj);

    switch (obj)
    {
      case PIZOOM  : ListBoxSetComboRect (previcon, obj, NULL, (SHORT)(sizeof (apszZoomStr) / sizeof (CHAR *)));
                     if ((lItem = ListBoxComboClick (previcon, obj, mk)) != FAILURE)
                       SetZoomInx (window, lItem);
                     break;
    } /* switch */

    undo_state (previcon, obj, SELECTED);
    draw_win_obj (window, previcon, obj);
  } /* if */
} /* HandlePopup */

/*****************************************************************************/

LOCAL BOOL ReadPage (WINDOWP window, LONG lPageNr)
{
  SPEC  *pSpec = (SPEC *)window->special;
  BOOL  bOk    = TRUE;
  UCHAR *pPageBuffer;
  LONG  lPageSize;

  if (lPageNr < 1)
    lPageNr = 1;

  if (lPageNr > pSpec->lNumPages)
    lPageNr = pSpec->lNumPages;

  if (lPageNr != pSpec->lPageNr)
  {
    lPageSize   = pSpec->alPageTable [lPageNr] - pSpec->alPageTable [lPageNr - 1];
    pPageBuffer = mem_alloc (lPageSize);

    if (pPageBuffer == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      bOk = FALSE;
    } /* if */
    else
    {
      file_seek (pSpec->hFile, pSpec->alPageTable [lPageNr - 1], SEEK_SET);
      file_read (pSpec->hFile, lPageSize, pPageBuffer);

      if (pSpec->pPageBuffer != NULL)
        mem_free (pSpec->pPageBuffer);

      pSpec->lPageNr     = lPageNr;
      pSpec->lPageSize   = lPageSize;
      pSpec->pPageBuffer = pPageBuffer;

      window->doc.x = window->doc.y = 0;
      set_sliders (window, HORIZONTAL | VERTICAL, SLPOS | SLSIZE);
      set_redraw (window, &window->work);
      set_meminfo ();
    } /* else */
  } /* if */

  return (bOk);
} /* ReadPage */

/*****************************************************************************/

LOCAL VOID DrawPage (SHORT sVdiHandle, RECT *rcPage, RECT *rcClip, UCHAR *pPageBuffer, LONG lPageSize, LONG lPixelsPerMeter, LONG lFontScaleFactor, LONG lXOffset, LONG lYOffset, SHORT sColors)
{
  UCHAR            *pSaveBuffer;
  SHORT            sBorderWidth, work_out [57], xy [4];
  RECT             rc, rcClipRes;
  ACC_PREVIEW_TYPE type;
  OBJ_GENERIC      *pGeneric;
  OBJ_BACKGROUND   *pBackground;
  OBJ_RECTLINE     *pRectLine;
  OBJ_GROUPBOX     *pGroupbox;
  OBJ_CHECKRADIO   *pCheckRadio;
  OBJ_TEXT         *pText;
  OBJ_GRAPHIC      *pGraphic;

  if (sColors == 0)
  {  
    vq_extnd (sVdiHandle, FALSE, work_out);
    sColors = work_out [13];
  } /* if */

  pSaveBuffer = pPageBuffer;

  while (pPageBuffer < pSaveBuffer + lPageSize)
  {
    type     = *(ACC_PREVIEW_TYPE *)pPageBuffer;
    pGeneric = (VOID *)pPageBuffer;

    switch (type)
    {
      case TYPE_BACKGROUND  : pBackground  = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_BACKGROUND);
                              break;
      case TYPE_RECTANGLE   : /* fall through */
      case TYPE_LINE        : pRectLine    = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_RECTLINE);
                              break;
      case TYPE_GROUPBOX    : pGroupbox    = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_GROUPBOX);
                              pPageBuffer += pGroupbox->lTextLength + 1 + odd (pGroupbox->lTextLength + 1);
                              break;
      case TYPE_CHECKBOX    : /* fall through */
      case TYPE_RADIOBUTTON : pCheckRadio  = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_CHECKRADIO);
                              pPageBuffer += pCheckRadio->lTextLength + 1 + odd (pCheckRadio->lTextLength + 1);
                              break;
      case TYPE_TEXT        : pText        = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_TEXT);
                              pPageBuffer += pText->lTextLength + 1 + odd (pText->lTextLength + 1);
                              break;
      case TYPE_GRAPHIC     : pGraphic     = (VOID *)pPageBuffer;
                              pPageBuffer += sizeof (OBJ_GRAPHIC);
                              pPageBuffer += pGraphic->lFileNameLength + 1 + odd (pGraphic->lFileNameLength + 1);
                              break;
    } /* switch */

    rc.x = rcPage->x + PIXELS_FROM_UNITS (pGeneric->lRect.x - lXOffset, lPixelsPerMeter);
    rc.y = rcPage->y + PIXELS_FROM_UNITS (pGeneric->lRect.y - lYOffset, lPixelsPerMeter);
    rc.w = PIXELS_FROM_UNITS (pGeneric->lRect.w, lPixelsPerMeter);
    rc.h = PIXELS_FROM_UNITS (pGeneric->lRect.h, lPixelsPerMeter);

#ifdef CORRECT_ROUNDING_PROBLEMS
    {
      LRECT rcFract;

      rcFract.x = FRACT_FROM_UNITS (pGeneric->lRect.x - lXOffset, lPixelsPerMeter);	/* correct rounding problems */
      rcFract.y = FRACT_FROM_UNITS (pGeneric->lRect.y - lYOffset, lPixelsPerMeter);
      rcFract.w = FRACT_FROM_UNITS (pGeneric->lRect.w, lPixelsPerMeter);
      rcFract.h = FRACT_FROM_UNITS (pGeneric->lRect.h, lPixelsPerMeter);

      if ((rcFract.x >= UNITS_PER_METER / 2) && (rcFract.w >= UNITS_PER_METER / 2))
        rc.x--, rc.w++;

      if ((rcFract.y >= UNITS_PER_METER / 2) && (rcFract.h >= UNITS_PER_METER / 2))
        rc.y--, rc.h++;

      if ((rcFract.x < UNITS_PER_METER / 2) && (rcFract.w < UNITS_PER_METER / 2) && (rcFract.x + rcFract.w >= UNITS_PER_METER / 2))
        rc.w++;

      if ((rcFract.y < UNITS_PER_METER / 2) && (rcFract.h < UNITS_PER_METER / 2) && (rcFract.y + rcFract.h >= UNITS_PER_METER / 2))
        rc.h++;
    } /* CORRECT_ROUNDING_PROBLEMS */
#endif

    rcClipRes = *rcClip;

    if (rc_intersect (&rc, &rcClipRes))
    {
      rect2array (&rcClipRes, xy);
      vs_clip (sVdiHandle, TRUE, xy);

      switch (type)
      {
        case TYPE_BACKGROUND  : DrawTypeBackground (sVdiHandle, sColors, &rc, &rcClipRes, pBackground);
                                break;
        case TYPE_RECTANGLE   : /* fall through */
        case TYPE_LINE        : sBorderWidth = PIXELS_FROM_UNITS (pRectLine->lWidth, lPixelsPerMeter);
                                if ((sBorderWidth == 0) && (pRectLine->lWidth != 0))	/* use at least one pixel */
                                  sBorderWidth = 1;
                                DrawTypeRectLine (sVdiHandle, sColors, &rc, &rcClipRes, sBorderWidth, pRectLine);
                                break;
        case TYPE_GROUPBOX    : sBorderWidth = PIXELS_FROM_UNITS (pGroupbox->lWidth, lPixelsPerMeter);
                                if ((sBorderWidth == 0) && (pGroupbox->lWidth != 0))	/* use at least one pixel */
                                  sBorderWidth = 1;
                                SetFont (sVdiHandle, sColors, &pGroupbox->Font, lFontScaleFactor);
                                DrawTypeGroupbox (sVdiHandle, sColors, &rc, &rcClipRes, sBorderWidth, pGroupbox);
                                break;
        case TYPE_CHECKBOX    : /* fall through */
        case TYPE_RADIOBUTTON : SetFont (sVdiHandle, sColors, &pCheckRadio->Font, lFontScaleFactor);
                                DrawTypeCheckRadio (sVdiHandle, sColors, &rc, &rcClipRes, pCheckRadio->bChecked, pCheckRadio, PIXELS_FROM_UNITS (CHECK_SPACE * pCheckRadio->Font.point / 10, lPixelsPerMeter));
                                break;
        case TYPE_TEXT        : sBorderWidth = PIXELS_FROM_UNITS (pText->lWidth, lPixelsPerMeter);
                                if ((sBorderWidth == 0) && (pText->lWidth != 0))	/* use at least one pixel */
                                  sBorderWidth = 1;
                                SetFont (sVdiHandle, sColors, &pText->Font, lFontScaleFactor);
                                DrawTypeText (sVdiHandle, sColors, &rc, &rcClipRes, sBorderWidth, pText);
                                break;
        case TYPE_GRAPHIC     : sBorderWidth = PIXELS_FROM_UNITS (pGraphic->lWidth, lPixelsPerMeter);
                                if ((sBorderWidth == 0) && (pGraphic->lWidth != 0))	/* use at least one pixel */
                                  sBorderWidth = 1;
                                DrawTypeGraphic (sVdiHandle, sColors, &rc, &rcClipRes, sBorderWidth, pGraphic);
                                break;
      } /* switch */
    } /* if */
  } /* while */
} /* DrawPage */

/*****************************************************************************/

LOCAL VOID DrawTypeBackground (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, OBJ_BACKGROUND *pBackground)
{
  SHORT xy [4];

  rect2array (rc, xy);
  vswr_mode (sVdiHandle, MD_REPLACE);
  vsf_perimeter (sVdiHandle, FALSE);

  if ((sColors == 2) && (pBackground->sColor > BLACK))
  {
    vsf_color (sVdiHandle, BLACK);
    vsf_interior (sVdiHandle, FIS_PATTERN);
    vsf_style (sVdiHandle, asBackgroundPatterns [pBackground->sColor]);
  } /* if */
  else
  {
    vsf_color (sVdiHandle, pBackground->sColor);
    vsf_interior (sVdiHandle, FIS_SOLID);
  } /* else */

  v_bar (sVdiHandle, xy);
} /* DrawTypeBackground */

/*****************************************************************************/

LOCAL VOID DrawTypeRectLine (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_RECTLINE *pRectLine)
{
  DrawBorder (sVdiHandle, sColors, *rc, *rcClip, sBorderWidth, pRectLine->Type, pRectLine->sEffect, pRectLine->sMode, pRectLine->sColor, pRectLine->sStyle, NULL, ALI_HSTANDARD);
} /* DrawTypeRectLine */

/*****************************************************************************/

LOCAL VOID DrawTypeGroupbox (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_GROUPBOX *pGroupbox)
{
  DrawBorder (sVdiHandle, sColors, *rc, *rcClip, sBorderWidth, pGroupbox->Type, pGroupbox->sEffect, pGroupbox->sMode, pGroupbox->sColor, pGroupbox->sStyle, pGroupbox->pText, pGroupbox->sHorzAlignment);
  DrawText (sVdiHandle, sColors, *rc, *rcClip, sBorderWidth, pGroupbox->Type, pGroupbox->sEffect, pGroupbox->pText, &pGroupbox->Font, pGroupbox->sHorzAlignment, ALI_VTOP, 0, FALSE, 0);
} /* DrawTypeGroupbox */

/*****************************************************************************/

LOCAL VOID DrawTypeCheckRadio (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, BOOL bChecked, OBJ_CHECKRADIO *pCheckRadio, SHORT sCheckSpace)
{
  DrawText (sVdiHandle, sColors, *rc, *rcClip, 0, pCheckRadio->Type, pCheckRadio->sEffect, pCheckRadio->pText, &pCheckRadio->Font, ALI_HLEFT, ALI_VTOP, 0, bChecked, sCheckSpace);
} /* DrawTypeCheckRadio */

/*****************************************************************************/

LOCAL VOID DrawTypeText (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_TEXT *pText)
{
  DrawText (sVdiHandle, sColors, *rc, *rcClip, sBorderWidth, pText->Type, EFFECT_NORMAL, pText->pText, &pText->Font, pText->sHorzAlignment, pText->sVertAlignment, pText->sRotation, FALSE, 0);
} /* DrawTypeText */

/*****************************************************************************/

LOCAL VOID DrawTypeGraphic (SHORT sVdiHandle, SHORT sColors, RECT *rc, RECT *rcClip, SHORT sBorderWidth, OBJ_GRAPHIC *pGraphic)
{
  SHORT xy [4];
  RECT  r;

  r = *rc;
  rc_inflate (&r, - sBorderWidth, - sBorderWidth);
  rect2array (&r, xy);

  if (sVdiHandle != vdi_handle)				/* won't work on screen */
    if (pGraphic->lFileNameLength != 0)
      v_bit_image (sVdiHandle, pGraphic->pFileName, 1, 0, 0, 0, 0, xy);
} /* DrawTypeGraphic */

/*****************************************************************************/

LOCAL VOID DrawBorder (SHORT sVdiHandle, SHORT sColors, RECT rc, RECT rcClip, SHORT sBorderWidth, INT iType, SHORT sEffect, SHORT sMode, SHORT sColor, SHORT sStyle, CHAR *pText, SHORT sHorzAlignment)
{
  SHORT xy [12], w, h, sWidth, i, sLeft, sRight;
  BOOL  bHorz;

  if ((sBorderWidth != 0) && (sMode == MODE_OPAQUE))	/* draw border */
  {
    vswr_mode (sVdiHandle, (sMode == MODE_OPAQUE) ? MD_REPLACE : MD_TRANS);
    vsl_color (sVdiHandle, (sColors == 2) ? asTextColors [sColor] : sColor);
    vsl_type (sVdiHandle, sStyle + 1);			/* GEM value starts with 1 */

    if (iType == TYPE_LINE)				/* no double border */
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

    if (iType == TYPE_GROUPBOX)
    {
      text_extent (sVdiHandle, "x", FALSE, &sWidth, NULL);
      text_extent (sVdiHandle, pText, TRUE, &w, &h);

      sLeft  = (sHorzAlignment == ALI_HSTANDARD) || (sHorzAlignment == ALI_HLEFT) ? sWidth : (sHorzAlignment == ALI_HCENTER) ? (rc.w - w) / 2 - sWidth : rc.w - w - 3 * sWidth;
      sRight = (sHorzAlignment == ALI_HSTANDARD) || (sHorzAlignment == ALI_HLEFT) ? w + 3 * sWidth : (sHorzAlignment == ALI_HCENTER) ? (rc.w + w) / 2 + sWidth : rc.w - sWidth;

      if (sLeft > rc.w - 2)
        sLeft = rc.w - 2;

      if (sRight > rc.w - 2)
        sRight = rc.w - 2;

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

      if (sEffect == EFFECT_NORMAL)
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

        vsl_color (sVdiHandle, (sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNHIGHLIGHT] : sys_colors [COLOR_BTNSHADOW]);
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

        vsl_color (sVdiHandle, (sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNSHADOW] : sys_colors [COLOR_BTNHIGHLIGHT]);
        v_pline (sVdiHandle, 6, xy);
      } /* else */
    } /* if */
    else if (iType == TYPE_LINE)
    {
      bHorz = rc.w >= rc.h;

      if (sEffect == EFFECT_NORMAL)
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

        vsl_color (sVdiHandle, (sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNHIGHLIGHT] : sys_colors [COLOR_BTNSHADOW]);
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

        vsl_color (sVdiHandle, (sEffect == EFFECT_RAISED) ? sys_colors [COLOR_BTNSHADOW] : sys_colors [COLOR_BTNHIGHLIGHT]);
        v_pline (sVdiHandle, 2, xy);
      } /* else */
    } /* else */
    else
      if (sEffect == EFFECT_NORMAL)
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
        if (sEffect == EFFECT_RAISED)
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

LOCAL VOID DrawText (SHORT sVdiHandle, SHORT sColors, RECT rc, RECT rcClip, SHORT sBorderWidth, INT iType, SHORT sEffect, CHAR *pText, FONTDESC *font, SHORT sHorzAlignment, SHORT sVertAlignment, SHORT sRotation, BOOL bChecked, SHORT sCheckSpace)
{
  SHORT   sLeft, sWidth, sMaxWidth, sLineHeight, sHorzOffset, sVertOffset, sSaveColors;
  SHORT   x, y, w, h, xy [4];
  BOOL    bCheckRadio;
  RECT    rcSave, r;
  CHAR    *p;
  LONGSTR s;

  if ((pText != NULL) && (pText [0] != EOS))
  {
    vswr_mode (sVdiHandle, MD_TRANS);

    if (iType == TYPE_GROUPBOX)
    {
      text_extent (sVdiHandle, "x", FALSE, &sWidth, NULL);
      text_extent (sVdiHandle, pText, TRUE, &w, &h);

      sLeft = (sHorzAlignment == ALI_HSTANDARD) || (sHorzAlignment == ALI_HLEFT) ? sWidth : (sHorzAlignment == ALI_HCENTER) ? (rc.w - w) / 2 - sWidth : rc.w - w - 3 * sWidth;
      x     = rc.x + sLeft + sWidth;
      y     = rc.y;

      v_text (sVdiHandle, x, y, pText);
    } /* if */
    else
    {
      rcSave = rcClip;
      rc_inflate (&rc, - sBorderWidth, - sBorderWidth);
      rc_intersect (&rc, &rcClip);
      rect2array (&rcClip, xy);
      vs_clip (sVdiHandle, TRUE, xy);

      x = rc.x;
      y = rc.y;
      w = rc.w;
      h = rc.h;

      bCheckRadio = (iType == TYPE_CHECKBOX) || (iType == TYPE_RADIOBUTTON);
      sRotation   = sRotation / 90 * 90;				/* only multiple of 90 degrees for now */

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
      } /* if */
      else
        sMaxWidth = rc.h;

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
        r    = rc;
        r.w  = sCheckSpace * 8 / 10;
        r.h  = sLineHeight;

        if ((sVdiHandle == vdi_handle) && (colors == sColors) && (16 <= sLineHeight) && (sLineHeight <= 20) || (sEffect != EFFECT_NORMAL))	/* screen with original colors */
        {
          sSaveColors = dlg_colors;
          dlg_colors  = (sEffect == EFFECT_NORMAL) ? 2 : sColors;

          DrawCheckRadio (sVdiHandle, &r, &clip, NULL, FAILURE, bChecked ? SELECTED : NORMAL, FAILURE - 1, font, iType == TYPE_RADIOBUTTON);
          vswr_mode (sVdiHandle, MD_TRANS);	/* has been set to MD_REPLACE by DrawCheckRadio */

          dlg_colors = sSaveColors;
        } /* if */
        else
        {
          r.x++;				/* to be compatible with accobj.c */
          PrintCheckRadio (sVdiHandle, &r, &rcClip, bChecked, iType == TYPE_RADIOBUTTON);
        } /* else */
      } /* if */
     
      rect2array (&rcSave, xy);
      vs_clip (sVdiHandle, TRUE, xy);
    } /* else */
  } /* if */
} /* DrawText */

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

LOCAL VOID SetFont (SHORT sVdiHandle, SHORT sColors, FONTDESC *pFont, LONG lFontScaleFactor)
{
  SHORT ret;

  vst_font (sVdiHandle, pFont->font);
  vst_arbpoint (sVdiHandle, (SHORT)((pFont->point * lFontScaleFactor + 500) / 1000), &ret, &ret, &ret, &ret);
  vst_effects (sVdiHandle, pFont->effects);
  vst_color (sVdiHandle, (sColors == 2) ? asTextColors [pFont->color] : pFont->color);
} /* SetFont */

/*****************************************************************************/

LOCAL VOID PrintCheckRadio (SHORT sVdiHandle, RECT *rc, RECT *rcClip, BOOL bChecked, BOOL bRadio)
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
} /* PrintCheckRadio */

/*****************************************************************************/

LOCAL BOOL WorkPrint (PROC_INF *pProcInf)
{
  WORK  *pWork = P_WORK (pProcInf);
  BOOL  bOk;
  UCHAR *pPageBuffer;
  LONG  lPageSize;
  RECT  rcPage;

  bOk = pWork->lPageNr <= pWork->lNumPages;

  if (bOk)
  {
    busy_mouse ();
    xywh2rect (0, 0, (WORD)pWork->devinfo.dev_w, (WORD)pWork->devinfo.dev_h, &rcPage);

    if (pWork->wOutDevice == METAFILE)
    {
      if (rcPage.w == (WORD)(UWORD)0x8000L)			/* clipping rectangle would be negative */
        rcPage.w = 32767;

      if (rcPage.h == (WORD)(UWORD)0x8000L)			/* clipping rectangle would be negative */
        rcPage.h = 32767;
    } /* if */

    text_default (pWork->sOutHandle);
    line_default (pWork->sOutHandle);

    lPageSize   = pWork->alPageTable [pWork->lPageNr] - pWork->alPageTable [pWork->lPageNr - 1];
    pPageBuffer = mem_alloc (lPageSize);

    if (pPageBuffer == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      bOk = FALSE;
    } /* if */
    else
    {
      file_seek (pWork->hFile, pWork->alPageTable [pWork->lPageNr - 1], SEEK_SET);
      file_read (pWork->hFile, lPageSize, pPageBuffer);
      DrawPage (pWork->sOutHandle, &rcPage, &rcPage, pPageBuffer, lPageSize, pWork->devinfo.lPixelsPerMeter, 1000L, pWork->devinfo.lXOffset / 10, pWork->devinfo.lYOffset / 10, pWork->sColors);
      v_updwk (pWork->sOutHandle);
      v_clrwk (pWork->sOutHandle);
      mem_free (pPageBuffer);
    } /* else */

    pWork->lPageNr++;

    arrow_mouse ();
  } /* if */

  return (bOk);
} /* WorkPrint */

/*****************************************************************************/

LOCAL BOOL StopPrint (PROC_INF *pProcInf)
{
  WORK *pWork = P_WORK (pProcInf);
  BOOL bOk    = TRUE;
  WORD w, h;

  if (pWork->sOutHandle != 0)
  {
    if (pWork->wOutDevice == METAFILE)
    {
      w = (WORD)(pWork->devinfo.lPhysPageWidth / 100);
      h = (WORD)(pWork->devinfo.lPhysPageHeight / 100);
      v_meta_extents (pWork->sOutHandle, 0, 0, w, h);
      vm_pagesize (pWork->sOutHandle, w, h);
      vm_coords (pWork->sOutHandle, 0, h, w, 0);
    } /* if */

    vst_unload_fonts (pWork->sOutHandle, 0);
    close_work (pWork->wOutDevice, pWork->sOutHandle);
  } /* if */

  file_close (pWork->hFile);
  file_remove (pWork->szFileName);

  return (bOk);
} /* StopPrint */

/*****************************************************************************/

