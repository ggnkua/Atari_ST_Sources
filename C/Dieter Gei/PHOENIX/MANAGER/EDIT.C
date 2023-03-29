/*****************************************************************************
 *
 * Module : EDIT.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 29.03.94
 *
 *
 * Description: This module implements the editor window.
 *
 * History:
 * 29.03.94: STR128 replaced by FULLNAME
 * 10.03.94: Always using monospaced font
 * 14.11.93: Using fontdesc
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "commdlg.h"
#include "desktop.h"
#include "dialog.h"
#include "editobj.h"
#include "printer.h"

#include "export.h"
#include "edit.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_MOUSE)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   gl_hbox                  /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fÅr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fÅr Scrolling */
#define INITX  (2 * gl_wbox)            /* X-Anfangsposition */
#define INITY  (6 * gl_hbox)            /* Y-Anfangsposition */
#define INITW  (58 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  (12 * gl_hbox)           /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define ADD_BUFFER 16384                /* 16 KB more buffer */

/****** TYPES ****************************************************************/

typedef struct
{
  FULLNAME filename;                    /* Name der Datei zum Editieren */
  LONG     size;                        /* aktuelle Textgrî·e */
  FONTDESC fontdesc;                    /* Zeichensatz */
  BOOLEAN  buf_dirty;                   /* Puffer wurde verÑndert */
  BYTE     *text;                       /* zeigt auf aktuellen Textpuffer */
  EDOBJ    ed;                          /* editierbares Objekt */
} EDIT_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    mtextinfo   _((WINDOWP window));
LOCAL BOOLEAN read_edit   _((EDIT_SPEC *editp));
LOCAL BOOLEAN write_edit  _((EDIT_SPEC *editp));
LOCAL WORD    ed_init     _((WINDOWP window));
LOCAL VOID    set_name    _((WINDOWP window));

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
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
/* Info-MenÅ                                                                 */
/*****************************************************************************/

LOCAL VOID mtextinfo (window)
WINDOWP window;

{
  LONGSTR   s;
  EDIT_SPEC *editp;

  editp = (EDIT_SPEC *)window->special;

  sprintf (s, alerts [ERR_INFOEDIT], window->doc.h, editp->ed.actsize); /* Zeilen, Bytes */
  open_alert (s);
} /* mtextinfo */

/*****************************************************************************/

LOCAL BOOLEAN read_edit (editp)
EDIT_SPEC *editp;

{
  BOOLEAN ok;
  FHANDLE f;
  LONG    file_size;

  busy_mouse ();

  ok = TRUE;

  if (editp->filename [0] != EOS)
  {
    f = file_open (editp->filename, O_RDONLY);
    if (f < 0)
    {
      file_error (ERR_FILEOPEN, editp->filename);
      ok = FALSE;
    } /* if */
  } /* if */
  else
    f = FAILURE;

  if (ok)
  {
    file_size   = (f < 0) ? 0 : file_seek (f, 0L, SEEK_END);
    editp->text = (BYTE *)mem_alloc (file_size + ADD_BUFFER);

    if (editp->text == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      ok = FALSE;
    } /* if */
    else
    {
      editp->size = file_size;

      if (f >= 0)
      {
        file_seek (f, 0L, SEEK_SET);
        file_size = file_read (f, file_size, editp->text);

        if (file_size < editp->size)
        {
          editp->size = file_size;
          file_error (ERR_FILEREAD, editp->filename);
        } /* if */

        file_close (f);
      } /* if */

      editp->text [file_size] = EOS;
      editp->size += ADD_BUFFER;
    } /* else */
  } /* if */

  arrow_mouse ();
  return (ok);
} /* read_edit */

/*****************************************************************************/

LOCAL BOOLEAN write_edit (editp)
EDIT_SPEC *editp;

{
  BOOLEAN ok;
  FHANDLE f;
  LONG    file_size;

  busy_mouse ();

  ok = TRUE;
  f  = file_create (editp->filename);
  ok = f >= 0;

  if (! ok)
    file_error (ERR_FILECREATE, editp->filename);
  else
  {
    file_size = file_write (f, editp->ed.actsize, editp->text);

    if (file_size < editp->ed.actsize)
    {
      ok = FALSE;
      file_error (ERR_FILEWRITE, editp->filename);
    } /* if */
    else
      editp->buf_dirty = FALSE;

    file_close (f);
  } /* else */

  arrow_mouse ();
  return (ok);
} /* write_edit */

/*****************************************************************************/

LOCAL WORD ed_init (window)
WINDOWP window;

{
  WORD      err;
  EDIT_SPEC *editp;
  RECT      frame;

  editp = (EDIT_SPEC *)window->special;
  err   = SUCCESS;

  frame.x = 0;
  frame.y = 0;
  frame.w = window->doc.w * window->xfac;
  frame.h = 30720 / window->yfac * window->yfac;

  editp->ed.window  = window;
  editp->ed.pos     = frame;
  editp->ed.text    = editp->text;
  editp->ed.bufsize = editp->size;
  editp->ed.actsize = strlen (editp->text);
  editp->ed.font    = editp->fontdesc.font;
  editp->ed.point   = editp->fontdesc.point;
  editp->ed.color   = editp->fontdesc.color;
  editp->ed.flags   = ED_ALILEFT | ED_CRACCEPT;

  err = edit_obj (&editp->ed, ED_INIT, 0, NULL);

  return (err);
} /* ed_init */

/*****************************************************************************/

LOCAL VOID set_name (window)
WINDOWP window;

{
  EDIT_SPEC *editp;

  editp = (EDIT_SPEC *)window->special;

  sprintf (window->name, " %s%s ", (editp->buf_dirty ? "*" : ""), editp->filename);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* set_name */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN wi_test (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN   ret, ext;
  EDIT_SPEC *editp;
  WORD      button;

  ret   = TRUE;
  ext   = (action & DO_EXTERNAL) != 0;
  ext   = ext;
  editp = (EDIT_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! done && ! acc_close && editp->buf_dirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       if (button == 1)
                       {
                         write_edit (editp);
                         set_name (window);
                       } /* if */

                       ret = button <= 2;
                     } /* if */
                     break;
    case DO_DELETE : break;
  } /* switch */

  return (ret);
} /* wi_test */

/*****************************************************************************/
/* ôffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieûe Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* Lîsche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  EDIT_SPEC *editp;

  editp = (EDIT_SPEC *)window->special;

  edit_obj (&editp->ed, ED_EXIT, 0, NULL);
  mem_free (editp->text);
  mem_free (editp);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  EDIT_SPEC *editp;

  editp = (EDIT_SPEC *)window->special;

  edit_obj (&editp->ed, ED_HIDECURSOR, 0, NULL);
  clr_scroll (window);
  edit_obj (&editp->ed, ED_DRAW, 0, NULL);
  edit_obj (&editp->ed, ED_SHOWCURSOR, 0, NULL);
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

  if (dir & HORIZONTAL)             /* Horizontale Pfeile und Schieber */
  {
    if (delta != 0)                                    /* Scrolling nîtig */
    {
      window->doc.x = newpos;                          /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);         /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                              /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                                    /* Scrolling nîtig */
    {
      window->doc.y = newpos;                          /* Neue Position */

      set_sliders (window, VERTICAL, SLPOS);           /* Schieber setzen */
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
  diff.y = (new->y - r.y) & 0xFFFE;
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
} /* wi_snap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  EDIT_SPEC *editp;

  if (find_top () == window)
  {
    editp = (EDIT_SPEC *)window->special;

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    set_clip (TRUE, &window->scroll);

    if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
    {
      hide_mouse ();
      edit_obj (&editp->ed, ED_HIDECURSOR, 0, NULL);
      edit_obj (&editp->ed, ED_CLICK, 0, mk);
      edit_obj (&editp->ed, ED_SHOWCURSOR, 0, NULL);
      show_mouse ();
    } /* if */
  } /* if */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
} /* wi_unclick */

/*****************************************************************************/
/* Taste fÅr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  EDIT_SPEC *editp;
  WORD      ret, lines;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  editp = (EDIT_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);

  if (mk->ascii_code == ESC) return (TRUE);     /* nicht auswerten */

  lines         = editp->ed.lines;
  ret           = edit_obj (&editp->ed, ED_KEY, 0, mk);
  window->doc.h = editp->ed.lines;

  if (lines != editp->ed.lines) set_sliders (window, VERTICAL, SLPOS | SLSIZE);

  if ((ret == ED_BUFFERCHANGED) && ! editp->buf_dirty)
  {
    editp->buf_dirty = TRUE;
    set_name (window);
  } /* if */

  if ((ret == ED_OK) || (ret == ED_BUFFERCHANGED)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

GLOBAL VOID print_edit (window)
WINDOWP window;

{
  EDIT_SPEC *editp;

  editp = (EDIT_SPEC *)window->special;
  print_buffer (editp->ed.text, editp->ed.actsize);
} /* print_edit */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_edit (obj, menu, icon, filename, fontdesc)
OBJECT   *obj, *menu;
WORD     icon;
BYTE     *filename;
FONTDESC *fontdesc;

{
  WINDOWP   window;
  WORD      menu_height, inx, err;
  FULLNAME  s;
  EDIT_SPEC *editp;
  WORD      char_width, char_height, cell_width, cell_height;

  editp = (EDIT_SPEC *)mem_alloc ((LONG)sizeof (EDIT_SPEC));
  if (editp == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (editp, 0, sizeof (EDIT_SPEC));
  strcpy (editp->filename, filename);

  editp->fontdesc = *fontdesc;

  if (! read_edit (editp))
  {
    mem_free (editp);
    return (NULL);
  } /* if */

  if (! FontIsMonospaced (vdi_handle, editp->fontdesc.font))
    editp->fontdesc.font = FONT_SYSTEM;

  vst_font (vdi_handle, fontdesc->font);
  vst_point (vdi_handle, fontdesc->point, &char_width, &char_height, &cell_width, &cell_height);

  inx    = num_windows (CLASS_EDIT, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_EDIT);

  if (window != NULL)
  {
    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = LONGSTRLEN;
    window->doc.h     = 0;
    window->xfac      = cell_width;
    window->yfac      = cell_height;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = INITX + inx * gl_wbox;
    window->scroll.y  = INITY + inx * gl_hbox + odd (menu_height);
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = (desk.y + desk.h - window->scroll.y - 6 * gl_hbox) / window->yfac * window->yfac;
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + menu_height;
    window->mousenum  = TEXT_CRSR;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)editp;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = NULL;
    window->updt_menu = NULL;
    window->test      = wi_test;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = wi_delete;
    window->draw      = wi_draw;
    window->arrow     = wi_arrow;
    window->snap      = wi_snap;
    window->objop     = NULL;
    window->drag      = NULL;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_edit;
    window->showhelp  = help_edit;

    if ((strchr (filename, DRIVESEP) == NULL) && (strchr (filename, PATHSEP) == NULL))
      strcpy (s, act_path);
    else
      s [0] = EOS;

    strcat (s, filename);
    sprintf (window->name, " %s ", s);

    err = ed_init (window);

    if ((err == ED_OK) || (err == ED_SHOWLINES))
    {
      if (err == ED_SHOWLINES) hndl_alert (ERR_SHOWLINES);
      window->doc.h = editp->ed.lines;
    } /* if */
    else
    {
      switch (err)
      {
        case ED_NOMEMORY   : hndl_alert (ERR_NOMEMORY);   break;
        case ED_2MANYLINES : hndl_alert (ERR_2MANYLINES); break;
      } /* switch */

      delete_window (window);
      window = NULL;
    } /* else */
  } /* if */
  else
  {
    mem_free (editp->text);
    mem_free (editp);
  } /* else */

  set_meminfo ();
  return (window);                                      /* Fenster zurÅckgeben */
} /* crt_edit */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_edit (icon, filename, fontdesc)
WORD     icon;
BYTE     *filename;
FONTDESC *fontdesc;

{
  BOOLEAN ok;
  WINDOWP window;

  if ((icon != NIL) && (window = search_window (CLASS_EDIT, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_EDIT, SRCH_CLOSED, icon)) == NULL)
      window = crt_edit (NULL, NULL, icon, filename, fontdesc);

    ok = window != NULL;

    if (ok) ok = open_window (window);
  } /* else */

  return (ok);
} /* open_edit */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_edit (window, icon)
WINDOWP window;
WORD    icon;

{
  if (icon != NIL)
    window = search_window (CLASS_EDIT, SRCH_ANY, icon);

  if (window != NULL) mtextinfo (window);
  return (window != NULL);
} /* info_edit */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_edit (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HEDIT));
} /* help_edit */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_edit ()

{
  return (TRUE);
} /* init_edit */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_edit ()

{
  return (TRUE);
} /* term_edit */

