/*****************************************************************************/
/*                                                                           */
/* Modul: TRASH.C                                                            */
/* Datum: 28/02/89                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "dbase.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "help.h"
#include "base.h"

#include "export.h"
#include "trash.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_RESIDENT)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   gl_hbox                  /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fr Scrolling */
#define INITX  ( 2 * gl_wbox)           /* X-Anfangsposition */
#define INITY  ( 6 * gl_hbox)           /* Y-Anfangsposition */
#define INITW  (36 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  ( 8 * gl_hbox)           /* Anfangsh”he in Pixel */
#define MILLI  0                        /* Millisekunden fr Zeitablauf */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box         _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test     _((WINDOWP window, WORD action));
LOCAL VOID    wi_open     _((WINDOWP window));
LOCAL VOID    wi_close    _((WINDOWP window));
LOCAL VOID    wi_delete   _((WINDOWP window));
LOCAL VOID    wi_draw     _((WINDOWP window));
LOCAL VOID    wi_arrow    _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap     _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop    _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag     _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick  _((WINDOWP window));
LOCAL BOOLEAN wi_key      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer    _((WINDOWP window));
LOCAL VOID    wi_top      _((WINDOWP window));
LOCAL VOID    wi_untop    _((WINDOWP window));
LOCAL VOID    wi_edit     _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Box zeichnen                                                              */
/*****************************************************************************/

LOCAL VOID box (window, grow)
WINDOWP window;
BOOLEAN grow;

{
  RECT l, b;

  get_dxywh (window->icon, &l);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/
/* ™ffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  box (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieže Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  box (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  clr_scroll (window);
} /* wi_draw */

/*****************************************************************************/
/* Reagiere auf Pfeile                                                       */
/*****************************************************************************/

LOCAL VOID wi_arrow (window, dir, oldpos, newpos)
WINDOWP window;
WORD    dir;
LONG    oldpos, newpos;

{
  LONG delta;

  delta = newpos - oldpos;

  if (dir & HORIZONTAL)         /* Horizontale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling n”tig */
    {
      window->doc.x = newpos;                   /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);  /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                          /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling n”tig */
    {
      window->doc.y = newpos;                   /* Neue Position */

      set_sliders (window, VERTICAL, SLPOS);    /* Schieber setzen */
      scroll_window (window, VERTICAL, delta * window->yfac);
    } /* if */
  } /* else */
} /* wi_arrow */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID wi_snap (window, new, mode)
WINDOWP window;
RECT    *new;
WORD    mode;

{
  RECT r, diff;
  WORD wbox, hbox;
  LONG max_xdoc, max_ydoc;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / wbox * wbox;        /* Differenz berechnen */
  diff.w = (new->w - r.w) / wbox * wbox;
  diff.h = (new->h - r.h) / hbox * hbox;

  if (wbox == 8) new->x = r.x + diff.x;         /* Schnelle Position */
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
      window->doc.x = max_xdoc;

    if (window->doc.y > max_ydoc)               /* Jenseits unterer Bereich */
      window->doc.y = max_ydoc;
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  WORD action;

  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  action = DRAG_NOACTN;

  if (src_window->class == class_desk)          /* Objekte von Desktop */
  {
    action = DRAG_OK;

    switch (src_obj)
    {
      case ITRASH   : action = DRAG_NOACTN; break;
      case ICLIPBRD : action = DRAG_NOACTN; break;
    } /* switch */
  } /* if */

  if (src_window->class == CLASS_BASE) action = DRAG_OK;

  return (action);
} /* wi_drag */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_trash (obj, menu, icon)
OBJECT *obj, *menu;
WORD   icon;

{
  WINDOWP window;
  WORD    inx;

  inx    = num_windows (CLASS_TRASH, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_TRASH);

  if (window != NULL)
  {
    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = 0;
    window->doc.h     = 0;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = INITX + inx * gl_wbox;
    window->scroll.y  = INITY + inx * gl_hbox;
    window->scroll.w  = INITW;
    window->scroll.h  = INITH;
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = 0;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = NULL;
    window->updt_menu = NULL;
    window->test      = NULL;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = NULL;
    window->draw      = wi_draw;
    window->arrow     = wi_arrow;
    window->snap      = wi_snap;
    window->objop     = NULL;
    window->drag      = wi_drag;
    window->click     = NULL;
    window->unclick   = NULL;
    window->key       = NULL;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_trash;
    window->showhelp  = help_trash;

    strcpy (window->name, (BYTE *)freetext [FTRASHNA].ob_spec);
    sprintf (window->info, (BYTE *)freetext [FTRASHIN].ob_spec, 0);
  } /* if */

  return (window);                      /* Fenster zurckgeben */
} /* crt_trash */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_trash (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;

  if ((window = search_window (CLASS_TRASH, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_TRASH, SRCH_CLOSED, icon)) == NULL)
      window = crt_trash (NULL, NULL, icon);

    ok = window != NULL;

    if (ok) ok = open_window (window);
  } /* else */

  return (ok);
} /* open_trash */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_trash (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR s, d;

  if (icon != NIL)
    window = search_window (CLASS_TRASH, SRCH_ANY, icon);

  if (window != NULL)
  {
    strcpy (s, alerts [ERR_INFOTRASH]);
    sprintf (d, s, (INT)window->special); /* Anzahl Objekte */
    open_alert (d);
  } /* if */

  return (window != NULL);
} /* info_trash */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_trash (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HTRASH));
} /* help_trash */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_trash ()

{
  return (crt_trash (NULL, NULL, ITRASH) != NULL);
} /* init_trash */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_trash ()

{
  return (TRUE);
} /* term_trash */

