/*****************************************************************************
 *
 * Module : PROPERTY.C
 * Author : Dieter Geiž
 *
 * Creation date    : 09.10.95
 * Last modification:
 *
 *
 * Description: This module implements the property window.
 *
 * History:
 * 22.01.04: Psotion und Gr”že des Fensters werden gesichert
 * 20.01.04: KIND um SIZER erweitert
 * 03.03.97: Help handling added
 * 02.12.95: Sizing of window added
 * 28.11.95: Doubleclick on listbox added
 * 09.10.95: Creation of body
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
#include "editobj.h"
#include "resource.h"

#include "export.h"
#include "property.h"

/****** DEFINES **************************************************************/

/* [GS] 5.1d Start: */
#define KIND		(NAME|CLOSER|FULLER|MOVER|SIZER)
/* Ende; alt:
#define KIND		(NAME|CLOSER|FULLER|MOVER)
*/
#define FLAGS		(WI_RESIDENT)
#define DOCW		100		/* Dokumentbreite */
#define DOCH		50		/* Dokumenth”he */
#define XFAC		gl_wbox		/* X-Faktor */
#define YFAC		(gl_hbox + 1)	/* Y-Faktor */
#define XUNITS		1		/* X-Einheiten fr Scrolling */
#define YUNITS		1		/* Y-Einheiten fr Scrolling */
#define XSCROLL		0		/* Nicht-Scrollbarer linker Bereich */
#define YSCROLL		0		/* Nicht-Scrollbarer oberer Bereich */
#define INITX		(desk.x + desk.w - 40 * gl_wbox)  /* X-Anfangsposition */
#define INITY		(desk.y)                          /* Y-Anfangsposition */
#define INITW		(desk.w / 3 / gl_wbox * gl_wbox)  /* Anfangsbreite in Pixel */
#define INITH		(desk.h)                          /* Anfangsh”he in Pixel */
#define MILLI		0               /* Millisekunden fr Zeitablauf */

#define VISIBLE		16              /* number of visible items in popup */

#define PROP_VAL_OFFSET	(22 * gl_wbox)	/* horizontal offset of property value in listbox */

#define ADDMEM		4096		/* additional memory for edit field */

/****** TYPES ****************************************************************/

typedef struct
{
  BOOL     bDirty;			/* buffer changed */
  SHORT    sIconHeight;			/* height of icon bar */
  FONTDESC fontdesc;			/* font descriptor */
  WINDOWP  pSrcWnd;			/* source window */
  PROPFUNC propfunc;			/* property callback function */
  HLB      hlb;				/* handle of listbox */
  LONG     lActItem;			/* actual item being edited */
  EDOBJ    ed;				/* editable object */
  LONG     lSizeText;			/* size of text in edit field */
  CHAR     *pszText;			/* text in edit field */
} PROP_SPEC;

/****** VARIABLES ************************************************************/

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

LOCAL WORD  EdInit             (WINDOWP window);
LOCAL VOID  CalcImageButton    (WINDOWP window, RECT *rc);
LOCAL VOID  CalcEditField      (WINDOWP window, RECT *rc);
LOCAL LONG  PropertiesCallback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);

/*****************************************************************************/

GLOBAL BOOL PropertyInit (VOID)
{
  return (TRUE);
} /* PropertyInit */

/*****************************************************************************/

GLOBAL BOOL PropertyTerm (VOID)
{
  return (TRUE);
} /* PropertyTerm */

/*****************************************************************************/

GLOBAL WINDOWP PropertyCreate (OBJECT *obj, OBJECT *menu, WORD icon)
{
  WINDOWP   window;
  SHORT     menu_height, inx, err;
  PROP_SPEC *pSpec;
  RECT      rc;

  menu_height = (menu != NULL) ? gl_hattr : 0;

  pSpec = (PROP_SPEC *)mem_alloc ((LONG)sizeof (PROP_SPEC));
  if (pSpec == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (pSpec, 0, sizeof (PROP_SPEC));

  pSpec->bDirty      = FALSE;
  pSpec->sIconHeight = gl_hbox + 4 + 4 + menu_height;
  pSpec->fontdesc    = fontdesc;
  pSpec->pSrcWnd     = NULL;
  pSpec->hlb         = ListBox_Create (LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW | LBS_SELECTABLE | LBS_MANDATORY, NULL, 0L);
  pSpec->lActItem    = 0;

  inx    = num_windows (CLASS_PROPERTY, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_PROPERTY);

  if (window != NULL)
  {
/* [GS] 5.1d Start */
  	if ( PropertyPos.x != -10000 )													/* Gespeicherte Werte vorhanden		*/
  	{
	    wind_calc (WC_WORK, KIND, PropertyPos.x, PropertyPos.y, PropertyPos.w, PropertyPos.h,
  	             &window->scroll.x, &window->scroll.y, &window->scroll.w, &window->scroll.h);
  	}
  	else
  	{
/* Ende */
    	wind_calc (WC_WORK, KIND, desk.x + desk.w - INITW, INITY, INITW, INITH,
      	         &window->scroll.x, &window->scroll.y, &window->scroll.w, &window->scroll.h);
/* [GS] 5.1d Start */
		}
/* Ende */

    window->scroll.x &= 0xFFF8;
    window->scroll.y += odd (window->scroll.y);
    window->scroll.w  = (window->scroll.w - 8) / XFAC * XFAC + 8;
    window->scroll.h  = (window->scroll.h - 6 - pSpec->sIconHeight) / YFAC * YFAC + 6 + pSpec->sIconHeight;

    window->scroll.x += inx * gl_wbox + XSCROLL;
    window->scroll.y += inx * gl_hbox + YSCROLL;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = DOCW;
    window->doc.h     = DOCH;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->xscroll   = XSCROLL;
    window->yscroll   = YSCROLL;
    window->work.x    = window->scroll.x - window->xscroll;
    window->work.y    = window->scroll.y - window->yscroll;
    window->work.w    = window->scroll.w + window->xscroll;
    window->work.h    = window->scroll.h + window->yscroll;
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
    window->arrow     = NULL;
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
    window->showinfo  = PropertyInfo;
    window->showhelp  = PropertyHelp;

    sprintf (window->name, FREETXT (FPROPERTIES));

    rc    = window->work;
    rc.x += 2;
    rc.y += pSpec->sIconHeight;
    rc.w -= 4;
    rc.h -= pSpec->sIconHeight + 2;

    ListBox_SetRect (pSpec->hlb, &rc, FALSE);
    ListBox_SetItemHeight (pSpec->hlb, ListBox_GetItemHeight (pSpec->hlb) + 1);
    ListBox_SetCallback (pSpec->hlb, PropertiesCallback);
    ListBox_SetSpec (pSpec->hlb, (LONG)window);

    err = EdInit (window);

    if (err == ED_NOMEMORY)
    {
      hndl_alert (ERR_NOMEMORY);
      delete_window (window);
      window = NULL;
    } /* if */
  } /* if */
  else
  {
    ListBox_Delete (pSpec->hlb);
    mem_free (pSpec);
  } /* else */

  set_meminfo ();

  return (window);                                      /* Fenster zurckgeben */
} /* PropertyCreate */

/*****************************************************************************/

GLOBAL BOOL PropertyOpen (WORD icon)
{
  BOOL    ok;
  WINDOWP window;

  if ((window = search_window (CLASS_PROPERTY, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_PROPERTY, SRCH_CLOSED, icon)) == NULL)
      window = PropertyCreate (NULL, NULL, icon);

    ok = window != NULL;

    if (ok) ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* else */

  return (ok);
} /* PropertyOpen */

/*****************************************************************************/

GLOBAL BOOL PropertyInfo (WINDOWP window, WORD icon)
{
  return (TRUE);
} /* PropertyInfo */

/*****************************************************************************/

GLOBAL BOOL PropertyHelp (WINDOWP window, WORD icon)
{
  PROP_SPEC *pSpec;
  CHAR      *pText;
  LONG      lItem;
  LONGSTR   szHelp;

  pSpec = (PROP_SPEC *)window->special;
  lItem = ListBox_GetCurSel (pSpec->hlb);
  pText = (CHAR *)pSpec->propfunc (PN_GETNAME, pSpec->pSrcWnd, lItem, NULL);

  sprintf (szHelp, FREETXT (FPROPERTY), pText);

  return (appl_help (szHelp));
} /* PropertyHelp */

/*****************************************************************************/

GLOBAL VOID PropertySetProps (WINDOWP window, WINDOWP pSrcWnd, LONG lCount, PROPFUNC propfunc)
{
  PROP_SPEC *pSpec;

  pSpec           = (PROP_SPEC *)window->special;
  pSpec->pSrcWnd  = pSrcWnd;
  pSpec->propfunc = propfunc;

  ListBox_SetCount (pSpec->hlb, lCount, NULL);
  ListBox_SetCurSel (pSpec->hlb, 0);
  ListBox_SetTopIndex (pSpec->hlb, 0);
  ListBox_SetLeftOffset (pSpec->hlb, 0);
  ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, 0L, NULL);	/* simulate change to first item in list box */

  set_redraw (window, &window->work);
} /* PropertySetProps */

/*****************************************************************************/

GLOBAL VOID PropertyCloseAssocWindow (WINDOWP window)
{
  PROP_SPEC *pSpec;
  WINDOWP   pPropWnd;

  if ((pPropWnd = search_window (CLASS_PROPERTY, SRCH_OPENED, NIL)) != NULL)
  {
    pSpec = (PROP_SPEC *)pPropWnd->special;

    if (window == pSpec->pSrcWnd)
      close_window (pPropWnd);
  } /* if */
} /* PropertyCloseAssocWindow */

/*****************************************************************************/

GLOBAL WINDOWP PropertyGetAssocWindow (VOID)
{
  PROP_SPEC *pSpec;
  WINDOWP   pPropWnd;

  if ((pPropWnd = search_window (CLASS_PROPERTY, SRCH_OPENED, NIL)) != NULL)
  {
    pSpec = (PROP_SPEC *)pPropWnd->special;

    return (pSpec->pSrcWnd);
  } /* if */

  return (NULL);
} /* PropertyGetAssocWindow */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN WindowTest (WINDOWP window, SHORT action)
{
  BOOL      ret, ext;
  PROP_SPEC *pSpec;

  ret   = TRUE;
  ext   = (action & DO_EXTERNAL) != 0;
  ext   = ext;
  pSpec = (PROP_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! acc_close && pSpec->bDirty)
                     {
                       pSpec->propfunc (PN_SETVALUE, pSpec->pSrcWnd, pSpec->lActItem, pSpec->pszText);
                       pSpec->bDirty = FALSE;
                       ret           = TRUE;
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

} /* WindowClose */

/*****************************************************************************/
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID WindowDelete (WINDOWP window)
{
  PROP_SPEC *pSpec;


  pSpec = (PROP_SPEC *)window->special;

  ListBox_Delete (pSpec->hlb);
  edit_obj (&pSpec->ed, ED_EXIT, 0, NULL);
  mem_free (pSpec->pszText);
  mem_free (pSpec);
  set_meminfo ();
} /* WindowDelete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID WindowDraw (WINDOWP window)
{
  PROP_SPEC *pSpec;
  SHORT     xy [4];
  RECT      rc;

  pSpec = (PROP_SPEC *)window->special;

  text_default (vdi_handle);
  line_default (vdi_handle);

  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_color (vdi_handle, (dlg_colors >= 16) ? DWHITE : WHITE);
  rect2array (&window->work, xy);
  vr_recfl (vdi_handle, xy);

  edit_obj (&pSpec->ed, ED_HIDECURSOR, 0, NULL);
  edit_obj (&pSpec->ed, ED_DRAW, 0, NULL);
  edit_obj (&pSpec->ed, ED_SHOWCURSOR, 0, NULL);

  CalcEditField (window, &rc);

  if (dlg_colors >= 16)
  {
    draw_3d (vdi_handle, rc.x - 1, rc.y - 1, 1, rc.w + 2, rc.h + 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
    draw_3d (vdi_handle, rc.x, rc.y, 1, rc.w, rc.h, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
  } /* if */
  else
    draw_3d (vdi_handle, rc.x, rc.y, 0, rc.w, rc.h, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], TRUE);

  CalcImageButton (window, &rc);

  switch (pSpec->propfunc (PN_SYMBOL, pSpec->pSrcWnd, pSpec->lActItem, NULL))
  {
    case PROPSYS_NOSYMBOL : break;
    case PROPSYM_ARROW    : if (pSpec->propfunc (PN_GETVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL) == 0L)
                              DrawImageButton (vdi_handle, &rc, &clip, IBS_DISABLED, DIB_DOWNARROW);
                            else
                              DrawImageButton (vdi_handle, &rc, &clip, NORMAL, DIB_DOWNARROW);
                            pSpec->propfunc (PN_RELVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL);
                            break;
    case PROPSYS_ELLISPIS : DrawImageButton (vdi_handle, &rc, &clip, NORMAL, DIB_DOTS);
                            break;
  } /* switch */

  ListBox_Draw (pSpec->hlb, &clip);
} /* WindowDraw */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID WindowSnap (WINDOWP window, RECT *new, SHORT mode)
{
  RECT      r, diff, rc;
  SHORT     wbox, hbox;
  LONG      max_xdoc, max_ydoc;
  PROP_SPEC *pSpec;
  MKINFO    mk;

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

  pSpec = (PROP_SPEC *)window->special;

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

    if (diff.w != 0)				/* Wegen Anpassung der Combobox-Gr”že */
    {
      r   = window->work;
      r.h = pSpec->sIconHeight;
      set_redraw (window, &r);

      mk.mox           = pSpec->ed.act_col;
      mk.moy           = 0;
      pSpec->ed.pos.w += diff.w;
      edit_obj (&pSpec->ed, ED_EXIT, 0, NULL);
      edit_obj (&pSpec->ed, ED_INIT, 0, NULL);
      edit_obj (&pSpec->ed, ED_SETCURSOR, 0, &mk);
    } /* if */

    if ((diff.w != 0) || (diff.h != 0))		/* Wegen Listbox */
      set_redraw (window, &window->scroll);
  } /* if */

  ListBox_GetRect (pSpec->hlb, &rc);
  rc.x += diff.x;
  rc.y += diff.y;
  rc.w += diff.w;
  rc.h += diff.h;
  ListBox_SetRect (pSpec->hlb, &rc, FALSE);

/* [GS] 5.1d Start: */
		PropertyPos = *new;
/* Ende */
} /* WindowSnap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID WindowClick (WINDOWP window, MKINFO *mk)
{
  PROP_SPEC *pSpec;
  RECT      rc, rcButton, rcDiff;
  HLB       hlb;
  LONG      lIndex, lRet;
  CHAR      *pValues, *pValue, *pValuesDyn, *p, **ppValues;
  SHORT     sCount, i, sHandle;
  LONGSTR   sz;

  if (find_top () == window)
  {
    pSpec = (PROP_SPEC *)window->special;

    wind_calc (WC_BORDER, KIND, window->work.x, window->work.y, window->work.w, window->work.h, &rc.x, &rc.y, &rc.w, &rc.h);
    rc_inflate (&rc, -5, -5);

    if (inside (mk->mox, mk->moy, &window->work) && ! inside (mk->mox, mk->moy, &rc))
    {
      if (mk->mox < rc.x)
        sHandle = (mk->moy < rc.y) ? HANDLE_TL : (mk->moy >= rc.y + rc.h) ? HANDLE_BL : HANDLE_ML;
      else
        if (mk->mox >= rc.x + rc.w)
          sHandle = (mk->moy < rc.y) ? HANDLE_TR : (mk->moy >= rc.y + rc.h) ? HANDLE_BR : HANDLE_MR;
        else
          sHandle = (mk->moy < rc.y) ? HANDLE_TM : (mk->moy >= rc.y + rc.h) ? HANDLE_BM : FAILURE;

      if (sHandle != FAILURE)
      {
        rc_inflate (&rc, 5, 5);
        set_clip (FALSE, &desk);
        SizeBox (&rc, &rcDiff, NULL, 4 * gl_wattr, 5 * gl_hattr, 1, 1, window, NULL, (SIZEFUNC)NULL, sHandle);

        if ((rcDiff.x != 0) || (rcDiff.y != 0) || (rcDiff.w != 0) || (rcDiff.h != 0))
        {
          rc.x += rcDiff.x;
          rc.y += rcDiff.y;
          rc.w += rcDiff.w;
          rc.h += rcDiff.h;

          window->kind |= SIZER;		/* otherwise size_window will not work */

          size_window (window, &rc);

          window->kind &= ~SIZER;
        } /* if */
      } /* if */

      return;
    } /* if */

    set_clip (TRUE, &window->scroll);
    CalcEditField (window, &rc);

    if (inside (mk->mox, mk->moy, &rc))				/* inside edit field */
    {
      hide_mouse ();
      edit_obj (&pSpec->ed, ED_HIDECURSOR, 0, NULL);
      edit_obj (&pSpec->ed, ED_CLICK, 0, mk);
      edit_obj (&pSpec->ed, ED_SHOWCURSOR, 0, NULL);
      show_mouse ();
    } /* if */
    else
    {
      CalcImageButton (window, &rcButton);

      if (inside (mk->mox, mk->moy, &rcButton))			/* inside button */
      {
        switch (pSpec->propfunc (PN_SYMBOL, pSpec->pSrcWnd, pSpec->lActItem, NULL))
        {
          case PROPSYS_NOSYMBOL : break;
          case PROPSYM_ARROW    : pValues = (CHAR *)pSpec->propfunc (PN_GETVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL);

                                  if (pValues != NULL)
                                  {
                                    hide_mouse ();
                                    DrawImageButton (vdi_handle, &rcButton, &clip, IBS_SELECTED, DIB_DOWNARROW);
                                    show_mouse ();

                                    for (sCount = 1, pValue = pValues; (pValue = strchr (pValue, ';')) != NULL; sCount++, pValue++);

                                    pValuesDyn = strdup (pValues);
                                    ppValues   = mem_alloc (sCount * sizeof (CHAR *));

                                    for (p = strtok (pValuesDyn, ";"), i = 0; p != NULL; p = strtok (NULL, ";"))
                                      ppValues [i++] = p;

                                    rc.x = window->work.x + 2;
                                    rc.y = window->work.y + 2;
                                    rc.w = window->work.w - 8;
                                    rc.h = gl_hbox + 4;

                                    hlb = ListBox_Create (LBS_VREALTIME | LBS_SELECTABLE, &rc, 0L);
                                    ListBox_SetSpec (hlb, (LONG)window);
                                    ListBox_SetLeftOffset (hlb, 0);
                                    ListBox_SetCount (hlb, sCount, ppValues);
                                    ListBox_SetCurSel (hlb, ListBox_FindStringExact (hlb, 0L, pSpec->pszText));

                                    rc.y += rc.h - 2;
                                    rc.h  = min (sCount, VISIBLE) * ListBox_GetItemHeight (hlb);

                                    if (dlg_colors < 16)
                                      rc.y--;

                                    ListBox_SetComboRect (hlb, &rc, rc.y + 1);

                                    if ((lIndex = ListBox_ComboClick (hlb, mk)) != FAILURE)
                                    {
                                      ListBox_GetText (hlb, lIndex, sz);

                                      edit_obj (&pSpec->ed, ED_CLEAR, 0, 0L);

                                      if (edit_obj (&pSpec->ed, ED_PASTEBUF, TRUE, sz) == ED_BUFFERCHANGED)
                                      {
                                        pSpec->bDirty = TRUE;
                                        ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, pSpec->lActItem, NULL);	/* to change edit field */
                                      } /* if */
                                    } /* if */

                                    ListBox_Delete (hlb);

                                    set_clip (TRUE, &window->scroll);			/* might have been changed by edit object messages */
                                    hide_mouse ();
                                    DrawImageButton (vdi_handle, &rcButton, &clip, NORMAL, DIB_DOWNARROW);
                                    show_mouse ();

                                    mem_free (ppValues);
                                    free (pValuesDyn);
                                    pSpec->propfunc (PN_RELVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL);
                                  } /* if */
                                  break;
          case PROPSYS_ELLISPIS : if ((lRet = pSpec->propfunc (PN_ELLIPSIS, pSpec->pSrcWnd, pSpec->lActItem, pSpec->pszText)) > 0)
                                  {
                                    pSpec->bDirty = TRUE;
                                    ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, pSpec->lActItem, NULL);	/* to change edit field */

                                    if (lRet > 1)								/* more than one field changed simultaneously */
                                      set_redraw (window, &window->scroll);
                                  } /* if */
                                  break;
        } /* switch */
      } /* if */
      else
        if (inside (mk->mox, mk->moy, &window->scroll))		/* inside list box */
          ListBox_Click (pSpec->hlb, mk);
    } /* else */
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
  PROP_SPEC *pSpec;

  pSpec = (PROP_SPEC *)window->special;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  set_clip (TRUE, &window->scroll);

  if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
    ListBox_Key (pSpec->hlb, mk);
  else
    if (mk->ascii_code == CR)
    {
      if (pSpec->bDirty)
        ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, pSpec->lActItem, NULL);	/* to change edit field */
    } /* if */
    else
      if (edit_obj (&pSpec->ed, ED_KEY, 0, mk) == ED_BUFFERCHANGED)
        pSpec->bDirty = TRUE;

  return (FALSE);
} /* WindowKey */

/*****************************************************************************/

LOCAL WORD EdInit (WINDOWP window)
{
  WORD      err;
  PROP_SPEC *pSpec;
  RECT      frame;

  pSpec  = (PROP_SPEC *)window->special;
  err    = SUCCESS;

  CalcEditField (window, &frame);

  frame.x -= window->work.x;		/* relativ to window */
  frame.y -= window->work.y;

  pSpec->lSizeText   = 10;
  pSpec->pszText     = mem_alloc (1);
  pSpec->pszText [0] = EOS;

  pSpec->ed.window  = window;
  pSpec->ed.pos     = frame;
  pSpec->ed.text    = pSpec->pszText;
  pSpec->ed.bufsize = pSpec->lSizeText - 1;
  pSpec->ed.actsize = strlen (pSpec->pszText);
  pSpec->ed.font    = font_btntext;
  pSpec->ed.point   = point_btntext;
  pSpec->ed.color   = sys_colors [COLOR_BTNTEXT];
  pSpec->ed.flags   = ED_AUTOHSCROLL | ED_ALILEFT;

  err = edit_obj (&pSpec->ed, ED_INIT, 0, NULL);

  return (err);
} /* EdInit */

/*****************************************************************************/

LOCAL VOID CalcImageButton (WINDOWP window, RECT *rc)
{
  PROP_SPEC *pSpec;

  pSpec  = (PROP_SPEC *)window->special;

  rc->x = window->work.x + window->work.w - gl_wattr - 3;
  rc->y = window->work.y + (pSpec->sIconHeight - (gl_hbox + 4)) / 2;
  rc->w = gl_wattr;
  rc->h = gl_hbox + 4;

  if (dlg_colors < 16)
  {
    rc->y++;
    rc->h -= 2;
  } /* if */
} /* CalcImageButton */

/*****************************************************************************/

LOCAL VOID CalcEditField (WINDOWP window, RECT *rc)
{
  rc->x = window->work.x + 4;
  rc->y = window->work.y + 4;
  rc->w = window->work.w - gl_wattr - 3 - 8;
  rc->h = gl_hbox;
} /* CalcEditField */

/*****************************************************************************/

LOCAL LONG PropertiesCallback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  HLB          hlb;
  WINDOWP      window;
  PROP_SPEC    *pSpec;
  CHAR         *pText;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r, save;
  SHORT        xy [8];
  MKINFO       mk;
  LONG         lBefore, lAfter, lRet;
  CHAR         *pValues, *pValue, *pValuesDyn, **ppValues;
  SHORT        sCount, i;
  BOOL         bFound;

  hlb    = (HLB)tree;
  window = (WINDOWP)ListBox_GetSpec (hlb);
  pSpec  = (PROP_SPEC *)window->special;
  save   = clip;					/* edit field operation will change clipping */

  switch (msg)
  {
    case LBN_GETITEM    : break;
    case LBN_DRAWITEM   : lb_ownerdraw = p;

                          if (item != FAILURE)
                          {
                            vswr_mode (vdi_handle, MD_TRANS);
                            vsf_interior (vdi_handle, FIS_SOLID);
                            vsf_perimeter (vdi_handle, FALSE);
                            vsf_style (vdi_handle, 0);
                            vst_effects (vdi_handle, effects_btntext | (((lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL));
                            rect2array (&lb_ownerdraw->rc_item, xy);

                            if (lb_ownerdraw->selected)
                            {
                              vsf_color (vdi_handle, (dlg_colors < 16) ? BLACK : sys_colors [COLOR_HIGHLIGHT]);
                              v_bar (vdi_handle, xy);

                              if (dlg_colors < 16)
                                vst_color (vdi_handle, WHITE);
                              else
                                vst_color (vdi_handle, (lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_HIGHLIGHTTEXT]);
                            } /* if */
                            else
                            {
                              vsf_color (vdi_handle, (dlg_colors < 16) || (lb_ownerdraw->bk_color == FAILURE) ? WHITE : lb_ownerdraw->bk_color);
                              v_bar (vdi_handle, xy);

                              if (dlg_colors < 16)
                                vst_color (vdi_handle, BLACK);
                              else
                                vst_color (vdi_handle, (lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : (lb_ownerdraw->color == FAILURE) ? sys_colors [COLOR_BTNTEXT] : lb_ownerdraw->color);
                            } /* else */

                            r     = lb_ownerdraw->rc_item;
                            pText = (CHAR *)pSpec->propfunc (PN_GETNAME, pSpec->pSrcWnd, item, NULL);
                            v_text (vdi_handle, r.x + 2, r.y, pText);

                            pText = (CHAR *)pSpec->propfunc (PN_GETVALUE, pSpec->pSrcWnd, item, NULL);
                            v_text (vdi_handle, r.x + 2 + PROP_VAL_OFFSET, r.y, pText);

                            line_default (vdi_handle);

                            if (dlg_colors >= 16)
                              vsl_color (vdi_handle, (lb_ownerdraw->bk_color == DBLACK) ? BLACK : (lb_ownerdraw->bk_color == DWHITE) ? DBLACK : DWHITE);
                            else
                            {
                              vsl_color (vdi_handle, BLACK);
                              vsl_type (vdi_handle, USERLINE);			/* dotted line */
                              vsl_udsty (vdi_handle, 0xAAAA);
                            } /* else */

                            xy [0] = r.x;
                            xy [1] = r.y + r.h - 1;
                            xy [2] = r.x + r.w - 1;
                            xy [3] = xy [1];
                            v_pline (vdi_handle, 2, xy);

                            xy [0] = r.x + PROP_VAL_OFFSET;
                            xy [1] = r.y;
                            xy [2] = xy [0];
                            xy [3] = r.y + r.h - 1;
                            v_pline (vdi_handle, 2, xy);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : if (pSpec->bDirty)
                          {
                            pSpec->propfunc (PN_SETVALUE, pSpec->pSrcWnd, pSpec->lActItem, pSpec->pszText);
                            pSpec->bDirty = FALSE;
                            ListBox_GetRect (pSpec->hlb, &r);
                            r.x += PROP_VAL_OFFSET;
                            r.y += (pSpec->lActItem - ListBox_GetTopIndex (pSpec->hlb)) * ListBox_GetItemHeight (pSpec->hlb) + 2;
                            r.h  = ListBox_GetItemHeight (pSpec->hlb);
                            set_redraw (window, &r);
                          } /* if */

                          edit_obj (&pSpec->ed, ED_EXIT, 0, NULL);
                          mem_free (pSpec->pszText);

                          lBefore          = pSpec->propfunc (PN_SYMBOL, pSpec->pSrcWnd, pSpec->lActItem, NULL);
                          lAfter           = pSpec->propfunc (PN_SYMBOL, pSpec->pSrcWnd, item, NULL);
                          pText            = (CHAR *)pSpec->propfunc (PN_GETVALUE, pSpec->pSrcWnd, item, NULL);
                          pSpec->lSizeText = strlen (pText) + ADDMEM;
                          pSpec->pszText   = mem_alloc (pSpec->lSizeText);

                          strcpy (pSpec->pszText, pText);

                          pSpec->ed.text     = pSpec->pszText;
                          pSpec->ed.bufsize  = pSpec->lSizeText - 1;
                          pSpec->ed.actsize  = strlen (pSpec->pszText);

                          if (pSpec->propfunc (PN_READONLY, pSpec->pSrcWnd, item, NULL))
                            pSpec->ed.flags |= ED_OUTPUT;
                          else
                            pSpec->ed.flags &= ~ED_OUTPUT;

                          mk.mox = pSpec->ed.actsize;
                          mk.moy = 0;

                          edit_obj (&pSpec->ed, ED_INIT, 0, NULL);
                          edit_obj (&pSpec->ed, ED_SETCURSOR, 0, &mk);

                          CalcImageButton (window, &r);

                          if (lBefore != lAfter)			/* something has changed */
                            set_redraw (window, &r);
                          else
                          {
                            lBefore = pSpec->propfunc (PN_GETVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL) == 0;
                            lAfter  = pSpec->propfunc (PN_GETVALS, pSpec->pSrcWnd, item, NULL) == 0;

                            if (lBefore != lAfter)			/* state has changed */
                              set_redraw (window, &r);

                            pSpec->propfunc (PN_RELVALS, pSpec->pSrcWnd, pSpec->lActItem, NULL);
                            pSpec->propfunc (PN_RELVALS, pSpec->pSrcWnd, item, NULL);
                          } /* else */

                          CalcEditField (window, &r);
                          redraw_window (window, &r);
                          pSpec->lActItem = item;
                          break;
    case LBN_DBLCLK     : switch (pSpec->propfunc (PN_SYMBOL, pSpec->pSrcWnd, item, NULL))
                          {
                            case PROPSYS_NOSYMBOL : break;
                            case PROPSYM_ARROW    : pValues = (CHAR *)pSpec->propfunc (PN_GETVALS, pSpec->pSrcWnd, item, NULL);

                                                    if (pValues != NULL)
                                                    {
                                                      for (sCount = 1, pValue = pValues; (pValue = strchr (pValue, ';')) != NULL; sCount++, pValue++);

                                                      pValuesDyn = strdup (pValues);
                                                      ppValues   = mem_alloc (sCount * sizeof (CHAR *));

                                                      for (pValue = strtok (pValuesDyn, ";"), i = 0; pValue != NULL; pValue = strtok (NULL, ";"))
                                                        ppValues [i++] = pValue;

                                                      for (i = 0, bFound = FALSE; i < sCount && ! bFound; i++)
                                                        if (strcmpi (ppValues [i], (CHAR *)pSpec->propfunc (PN_GETVALUE, pSpec->pSrcWnd, item, NULL)) == 0)
                                                          bFound = TRUE;

                                                      i = i % sCount;

                                                      edit_obj (&pSpec->ed, ED_CLEAR, 0, 0L);

                                                      if (edit_obj (&pSpec->ed, ED_PASTEBUF, TRUE, ppValues [i]) == ED_BUFFERCHANGED)
                                                      {
                                                        pSpec->bDirty = TRUE;
                                                        ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, item, NULL);	/* to change edit field */
                                                      } /* if */

                                                      mem_free (ppValues);
                                                      free (pValuesDyn);
                                                      pSpec->propfunc (PN_RELVALS, pSpec->pSrcWnd, item, NULL);
                                                    } /* if */
                                                    break;
                            case PROPSYS_ELLISPIS : if ((lRet = pSpec->propfunc (PN_ELLIPSIS, pSpec->pSrcWnd, pSpec->lActItem, pSpec->pszText)) > 0)
                                                    {
                                                      pSpec->bDirty = TRUE;
                                                      ListBox_SendMessage (pSpec->hlb, LBN_SELCHANGE, pSpec->lActItem, NULL);	/* to change edit field */

                                                      if (lRet > 1)								/* more than one field changed simultaneously */
                                                        set_redraw (window, &window->scroll);
                                                    } /* if */
                                                    break;
                          } /* switch */
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  set_clip (TRUE, &save);

  return (0L);
} /* PropertiesCallback */

/*****************************************************************************/

