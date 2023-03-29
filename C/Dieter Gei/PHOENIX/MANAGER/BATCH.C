/*****************************************************************************
 *
 * Module : BATCH.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 24.07.95
 *
 *
 * Description: This module implements the batch definition window.
 *
 * History:
 * 24.07.95: HBSAVEAS added
 * 31.12.94: Using new function names of controls module
 * 02.05.94: ED_PASTE replaced by ED_PASTEBUF
 * 20.03.94: Parameter saveas added
 * 10.03.94: Always using monospaced font
 * 12.02.94: Function get_list added
 * 04.11.93: Using fontdesc
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 09.10.93: Sliders are draw correctly when text is imported
 * 08.10.93: Variable num_chars is calculated using strlen
 * 05.10.93: Lables of comboboxes are disabled if comboboxes are disabled
 * 02.10.93: Export and import of text added
 * 30.09.93: Comboboxes are owner drawn
 * 28.09.93: Windows snaps on even y coordinates
 * 25.09.93: Window name is correct now if dirty
 * 24.09.93: Parameter combobox added
 * 18.09.93: Clipping is set before cursor is repositioned after BATCH_EDIT
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 13.09.93: New combobox used
 * 10.09.93: Modifications for SEL_SPEC added
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 29.08.93: INITX and INITY changed
 * 28.08.93: Modifications for 3d look added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "batexec.h"
#include "commdlg.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "editobj.h"
#include "list.h"
#include "printer.h"
#include "resource.h"
#include "select.h"

#include "export.h"
#include "batch.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_MOUSE)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   gl_hbox                  /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fr Scrolling */
#define INITX  (20 * gl_wbox)           /* X-Anfangsposition */
#define INITY  ( 6 * gl_hbox + 7)       /* Y-Anfangsposition */
#define INITW  (58 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  (20 * gl_hbox)           /* Anfangsh”he in Pixel */
#define MILLI  0                        /* Millisekunden fr Zeitablauf */

#define VISIBLE        8                /* number of visible items in combobox */
#define MAX_PARMS     30                /* max number of parameters to reserve */

/****** TYPES ****************************************************************/

typedef struct
{
  DB       *db;                         /* database */
  WORD     table;                       /* table of database */
  FONTDESC fontdesc;                    /* font */
  WORD     cmdinx;                      /* command index */
  WORD     num_cmds;                    /* number of commands */
  CMD      *cmds;                       /* commands */
  WORD     parminx;                     /* parameter index */
  WORD     num_parms;                   /* number of parameters */
  LONGSTR  parms;                       /* parameters */
  BYTE     *parmp [MAX_PARMS];          /* parameter pointers */
  BOOLEAN  dirty;                       /* buffer changed */
  LONG     size;                        /* size of text buffer */
  SYSBATCH sysbatch;                    /* actual batch */
  EDOBJ    ed;                          /* editable object */
} BATCH_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD num_chars;                   /* number of characters for combobox */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    fix_iconbar   _((WINDOWP window));
LOCAL WORD    ed_init       _((WINDOWP window));
LOCAL VOID    set_name      _((WINDOWP window));
LOCAL BYTE    *get_list     _((WINDOWP window, DB **db, BYTE *name));
LOCAL VOID    do_popup      _((WINDOWP window, MKINFO *mk, WORD obj));
LOCAL VOID    do_insert     _((WINDOWP window, BYTE *s, BOOLEAN is_parm));
LOCAL VOID    do_cmd        _((WINDOWP window, MKINFO *mk));
LOCAL VOID    do_parm       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    cmd_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    parm_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));

LOCAL VOID    update_menu   _((WINDOWP window));
LOCAL VOID    handle_menu   _((WINDOWP window, WORD title, WORD item));
LOCAL BOOLEAN wi_test       _((WINDOWP window, WORD action));
LOCAL VOID    wi_open       _((WINDOWP window));
LOCAL VOID    wi_close      _((WINDOWP window));
LOCAL VOID    wi_delete     _((WINDOWP window));
LOCAL VOID    wi_draw       _((WINDOWP window));
LOCAL VOID    wi_arrow      _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap       _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop      _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag       _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick    _((WINDOWP window));
LOCAL BOOLEAN wi_key        _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer      _((WINDOWP window));
LOCAL VOID    wi_top        _((WINDOWP window));
LOCAL VOID    wi_untop      _((WINDOWP window));
LOCAL VOID    wi_edit       _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_batch ()

{
  baticon [ROOT].ob_width = baticon [1].ob_width = desk.w;
  baticon [BATCMD].ob_y   = baticon [BATPARM].ob_y = (baticon [ROOT].ob_height - baticon [BATCMD].ob_height) / 2;

  num_chars = strlen (get_str (baticon, BATCMD));

  ListBoxSetCallback (baticon, BATCMD, cmd_callback);
  ListBoxSetStyle (baticon, BATCMD, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (baticon, BATCMD, gl_wbox / 2);

  ListBoxSetCallback (baticon, BATPARM, parm_callback);
  ListBoxSetStyle (baticon, BATPARM, LBS_VSCROLL | LBS_VREALTIME, TRUE);
  ListBoxSetLeftOffset (baticon, BATPARM, gl_wbox / 2);

  return (TRUE);
} /* init_batch */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_batch ()

{
  return (TRUE);
} /* term_batch */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_batch (obj, menu, icon, db, batch, name, fontdesc)
OBJECT   *obj, *menu;
WORD     icon;
DB       *db;
BYTE     *batch, *name;
FONTDESC *fontdesc;

{
  WINDOWP    window;
  WORD       menu_height, inx, err;
  BATCH_SPEC *batchp;
  WORD       char_width, char_height, cell_width, cell_height;
  BYTE       *p;

  batchp = (BATCH_SPEC *)mem_alloc ((LONG)sizeof (BATCH_SPEC));
  if (batchp == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (batchp, 0, sizeof (BATCH_SPEC));

  batchp->db        = db;
  batchp->fontdesc  = *fontdesc;
  batchp->cmdinx    = 0;
  batchp->num_cmds  = get_numcmds ();
  batchp->cmds      = get_cmds ();
  batchp->size      = MAX_BATCH;
  batchp->parminx   = 0;
  batchp->num_parms = 0;

  get_parmnames (batchp->cmds [batchp->cmdinx].cmd, batchp->parms);

  for (p = strtok (batchp->parms, ","); p != NULL; p = strtok (NULL, ","))
    batchp->parmp [batchp->num_parms++] = p;

  strcpy (batchp->sysbatch.name, name);
  strcpy (batchp->sysbatch.batch, batch);

  if (! FontIsMonospaced (vdi_handle, batchp->fontdesc.font))
    batchp->fontdesc.font = FONT_SYSTEM;

  vst_font (vdi_handle, batchp->fontdesc.font);
  vst_point (vdi_handle, batchp->fontdesc.point, &char_width, &char_height, &cell_width, &cell_height);

  inx    = num_windows (CLASS_BATCH, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_BATCH);

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
    window->scroll.y  = INITY + inx * gl_hbox + baticon->ob_height + 1 + odd (menu_height);
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = min (INITH, (desk.y + desk.h - window->scroll.y - 6 * gl_hbox) / window->yfac * window->yfac);
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - baticon->ob_height - 1 - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + baticon->ob_height + 1 + menu_height;
    window->mousenum  = TEXT_CRSR;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)batchp;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = handle_menu;
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
    window->showinfo  = info_batch;
    window->showhelp  = help_batch;

    sprintf (window->name, FREETXT (FDEFBAT), db->base->basename);
    sprintf (window->info, " %s", name);

    err = ed_init (window);

    if (err == ED_NOMEMORY)
    {
      hndl_alert (ERR_NOMEMORY);
      delete_window (window);
      window = NULL;
    } /* if */
    else
      window->doc.h = batchp->ed.lines;
  } /* if */
  else
    mem_free (batchp);

  set_meminfo ();
  return (window);                                      /* Fenster zurckgeben */
} /* crt_batch */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_batch (icon, db, batch, name, fontdesc)
WORD     icon;
DB       *db;
BYTE     *batch, *name;
FONTDESC *fontdesc;

{
  BOOLEAN ok;
  WINDOWP window;

  window = crt_batch (NULL, NULL, icon, db, batch, name, fontdesc);
  ok     = window != NULL;

  if (ok)
  {
    ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_batch */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_batch (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR     s;
  BATCH_SPEC *batchp;

  if (icon != NIL)
    window = search_window (CLASS_BATCH, SRCH_ANY, icon);

  if (window != NULL)
  {
    batchp = (BATCH_SPEC *)window->special;

    sprintf (s, alerts [ERR_INFOEDIT], window->doc.h, batchp->ed.actsize); /* Zeilen, Bytes */
    open_alert (s);
  } /* if */

  return (window != NULL);
} /* info_batch */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_batch (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HBATCH));
} /* help_batch */

/*****************************************************************************/

GLOBAL VOID print_batch (window)
WINDOWP window;

{
  BATCH_SPEC *batchp;

  batchp = (BATCH_SPEC *)window->special;
  print_buffer (batchp->ed.text, batchp->ed.actsize);
} /* print_batch */

/*****************************************************************************/

GLOBAL BOOLEAN close_batch (db)
DB *db;

{
  WORD        num, i;
  BATCH_SPEC *batchp;
  WINDOWP     window;
  WINDOWP     windows [MAX_GEMWIND];

  num = num_windows (CLASS_BATCH, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window  = windows [i];
    batchp = (BATCH_SPEC *)window->special;

    if (batchp->db == db)
    {
      delete_window (window);
      if (search_window (CLASS_BATCH, SRCH_ANY, NIL) == window) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_batch */

/*****************************************************************************/

GLOBAL VOID batch_new ()

{
  open_batch (NIL, actdb, "", "", &fontdesc);
} /* batch_new */

/*****************************************************************************/

GLOBAL VOID batch_old (window)
WINDOWP window;

{
  BYTE      *p;
  DB        *db;
  FIELDNAME batch_name;

  if ((window != NULL) && (window->subclass == CLASS_BLIST))
  {
    p = get_list (window, &db, batch_name);

    if (p != NULL)
    {
      unclick_window (window);
      open_batch (NIL, db, p, batch_name, &fontdesc);
      mem_free (p);
      set_meminfo ();
    } /* if */
  } /* if */
} /* batch_old */

/*****************************************************************************/

GLOBAL BOOLEAN batch_save (window, saveas)
WINDOWP window;
BOOLEAN saveas;

{
  BOOLEAN    ok, found;
  BATCH_SPEC *batchp;
  SYSBATCH   *sysbatch;
  SEL_SPEC   sel_spec;
  TABLE_INFO t_info;
  WORD       result;
  WORD       num_batchs, num, status;
  BYTE       *itemlist, *p;
  CURSOR     cursor;
  LONG       address;
  MKINFO     mk;

  ok     = FALSE;
  batchp = (BATCH_SPEC *)window->special;
  result = check_batch (batchp->db, batchp->sysbatch.batch, &mk.mox, &mk.moy);

  if (result == BATCH_OK)
  {
    db_tableinfo (batchp->db->base, SYS_BATCH, &t_info);
    num_batchs = (WORD)t_info.recs;
    sysbatch   = batchp->db->buffer;

    if (! saveas)
      saveas = window->info [1] == EOS;		/* window not saved yet */

    if ((num_batchs == 0) || ! saveas)
      itemlist = NULL;
    else
    {
      itemlist = mem_alloc ((LONG)num_batchs * (sizeof (FIELDNAME)));

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

      db_initcursor (batchp->db->base, SYS_BATCH, 1, ASCENDING, &cursor);

      for (num = 0, ok = TRUE, p = itemlist; (num < num_batchs) && ok && db_movecursor (batchp->db->base, &cursor, 1L); num++, p += sizeof (FIELDNAME))
      {
        ok = db_read (batchp->db->base, SYS_BATCH, sysbatch, &cursor, 0L, FALSE);
        strcpy (p, sysbatch->name);
      } /* for */

      arrow_mouse ();

      sel_spec.title     = FREETXT (FBSAVEAS);
      sel_spec.itemlist  = itemlist;
      sel_spec.itemsize  = sizeof (FIELDNAME);
      sel_spec.num_items = num;
      sel_spec.boxtitle  = FREETXT (FBLIST);
      sel_spec.helpinx   = HBSAVEAS;
      strcpy (sel_spec.selection, window->info + 1);

      ok = selection (&sel_spec);
    } /* if */
    else
    {
      strcpy (sel_spec.selection, window->info + 1);
      ok = TRUE;
    } /* else */

    if (ok)
    {
      busy_mouse ();
      found = FALSE;
      strcpy (sysbatch->name, sel_spec.selection);
      strcpy (sysbatch->batch, batchp->sysbatch.batch);

      if (sysbatch->name [0] != EOS)
      {
        found = db_search (batchp->db->base, SYS_BATCH, 1, ASCENDING, &cursor, sysbatch, 0L);
        ok    = db_status (batchp->db->base) == SUCCESS;
      } /* if */

      if (ok)
        if (found)
        {
          address           = db_readcursor (batchp->db->base, &cursor, NULL);
          sysbatch->address = address;
          ok                = db_reclock (batchp->db->base, address) && db_update (batchp->db->base, SYS_BATCH, sysbatch, &status);
        } /* if */
        else
          ok = db_insert (batchp->db->base, SYS_BATCH, sysbatch, &status);

      dbtest (batchp->db);
      updt_lsall (batchp->db, SYS_BATCH, TRUE, FALSE);

      if (ok)
      {
        batchp->dirty = FALSE;
        set_name (window);
      } /* if */

      arrow_mouse ();
    } /* if */

    strcpy (batchp->sysbatch.name, sel_spec.selection);
    strcpy (window->info + 1, sel_spec.selection);
    wind_set (window->handle, WF_INFO, ADR (window->info), 0, 0);
    mem_free (itemlist);
    set_meminfo ();
  } /* if */
  else
    if (result == BATCH_EDIT)
    {
      set_clip (TRUE, &window->scroll);
      edit_obj (&batchp->ed, ED_SETCURSOR, 0, &mk);
    } /* if, else */

  return (ok);
} /* batch_save */

/*****************************************************************************/

GLOBAL VOID batch_execute (window)
WINDOWP window;

{
  BYTE       *p;
  BATCH_SPEC *batchp;
  DB         *db;
  FIELDNAME  batch_name;
  WORD       result;
  MKINFO     mk;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_BLIST))
  {
    p = get_list (sel_window, &db, batch_name);

    if (p != NULL)
    {
      result = check_batch (db, p, &mk.mox, &mk.moy);

      if (result == BATCH_OK)
        do_batch (db, p, batch_name);
      else
        if (result == BATCH_EDIT) batch_old (sel_window);

      unclick_window (sel_window);
      mem_free (p);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    batchp = (BATCH_SPEC *)window->special;

    batch_exec (window, batchp->db, batchp->sysbatch.batch);
  } /* else */
} /* batch_execute */

/*****************************************************************************/

GLOBAL BOOLEAN batch_exec (window, db, batch)
WINDOWP window;
DB     *db;
BYTE   *batch;

{
  BOOLEAN    ok;
  BATCH_SPEC *batchp;
  WORD       result;
  MKINFO     mk;

  ok = FALSE;

  if (window->class == CLASS_BATCH)
  {
    batchp = (BATCH_SPEC *)window->special;
    result = check_batch (batchp->db, batchp->sysbatch.batch, &mk.mox, &mk.moy);

    if (result == BATCH_OK)
    {
      ok = TRUE;
      do_batch (batchp->db, batchp->sysbatch.batch, batchp->sysbatch.name);
    } /* if */
    else
      if (result == BATCH_EDIT)
      {
        set_clip (TRUE, &window->scroll);
        edit_obj (&batchp->ed, ED_SETCURSOR, 0, &mk);
      } /* if, else */
  } /* if */

  return (ok);
} /* batch_exec */

/*****************************************************************************/

LOCAL VOID fix_iconbar (WINDOWP window)
{
  BATCH_SPEC *batchp;
  BYTE       *p;

  batchp = (BATCH_SPEC *)window->special;

  baticon->ob_x = window->work.x;
  baticon->ob_y = window->work.y;

  p = (batchp->num_cmds == 0) ? "" : batchp->cmds [batchp->cmdinx].cmd;
  strncpy (get_str (baticon, BATCMD), p, num_chars);

  p = (batchp->num_parms == 0) ? "" : batchp->parmp [batchp->parminx];
  strncpy (get_str (baticon, BATPARM), p, num_chars);

  if (batchp->num_parms == 0)
  {
    do_state (baticon, BATPARM - 1, DISABLED);
    do_state (baticon, BATPARM, DISABLED);
  } /* if */
  else
  {
    undo_state (baticon, BATPARM - 1, DISABLED);
    undo_state (baticon, BATPARM, DISABLED);
  } /* if */

  ListBoxSetCount (baticon, BATCMD, batchp->num_cmds, NULL);
  ListBoxSetCurSel (baticon, BATCMD, batchp->cmdinx);
  ListBoxSetSpec (baticon, BATCMD, (LONG)window);

  ListBoxSetCount (baticon, BATPARM, batchp->num_parms, NULL);
  ListBoxSetCurSel (baticon, BATPARM, batchp->parminx);
  ListBoxSetSpec (baticon, BATPARM, (LONG)window);
} /* fix_iconbar */

/*****************************************************************************/

LOCAL WORD ed_init (window)
WINDOWP window;

{
  WORD       err;
  BATCH_SPEC *batchp;
  RECT       frame;

  batchp = (BATCH_SPEC *)window->special;
  err    = SUCCESS;

  frame.x = 0;
  frame.y = 0;
  frame.w = window->doc.w * window->xfac;
  frame.h = 30720 / window->yfac * window->yfac;

  batchp->ed.window  = window;
  batchp->ed.pos     = frame;
  batchp->ed.text    = batchp->sysbatch.batch;
  batchp->ed.bufsize = batchp->size;
  batchp->ed.actsize = strlen (batchp->sysbatch.batch);
  batchp->ed.font    = batchp->fontdesc.font;
  batchp->ed.point   = batchp->fontdesc.point;
  batchp->ed.color   = batchp->fontdesc.color;
  batchp->ed.flags   = ED_ALILEFT | ED_CRACCEPT;

  err = edit_obj (&batchp->ed, ED_INIT, 0, NULL);

  return (err);
} /* ed_init */

/*****************************************************************************/

LOCAL VOID set_name (window)
WINDOWP window;

{
  BATCH_SPEC *batchp;
  STRING     name;

  batchp = (BATCH_SPEC *)window->special;

  sprintf (name, FREETXT (FDEFBAT), batchp->db->base->basename);
  sprintf (window->name, " %s%s", (batchp->dirty ? "*" : ""), name + 1);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* set_name */

/*****************************************************************************/

LOCAL BYTE *get_list (window, db, name)
WINDOWP window;
DB      **db;
BYTE    *name;

{
  BYTE      *p;
  SYSBATCH *sysbatch;
  LONG      addr;
  WORD      i, obj;
  ICON_INFO info;

  p        = NULL;
  sysbatch = mem_alloc ((LONG)sizeof (SYSBATCH));

  if (sysbatch == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    for (i = 0, obj = NIL; (i < SETMAX) && (obj == NIL); i++)
      if (setin (sel_objs, i)) obj = i;

    if (obj != NIL)
    {
      addr = list_addr (window, obj);
      get_listinfo (window, &info, name);

      if (v_read (info.db, SYS_BATCH, sysbatch, NULL, addr, FALSE))
      {
        *db = info.db;
        p   = mem_alloc ((LONG)sizeof (BATCHDEF));

        if (p == NULL)
          hndl_alert (ERR_NOMEMORY);
        else
        {
          strcpy (name, sysbatch->name);
          strcpy (p, sysbatch->batch);
        } /* else */
      } /* if */
    } /* if */
  } /* else */

  mem_free (sysbatch);
  set_meminfo ();
  return (p);
} /* get_list */

/*****************************************************************************/

LOCAL VOID do_popup (window, mk, obj)
WINDOWP window;
MKINFO  *mk;
WORD    obj;

{
  BATCH_SPEC *batchp;
  LONGSTR    cmd;

  batchp = (BATCH_SPEC *)window->special;

  switch (obj)
  {
    case BATCMD  : if (mk->breturn == 1)
                   {
                     do_state (baticon, obj, SELECTED);
                     draw_win_obj (window, baticon, obj);
                     do_cmd (window, mk);
                     undo_state (baticon, obj, SELECTED);
                     draw_win_obj (window, baticon, obj);
                   } /* if */
                   else
                     do_insert (window, get_cmd (batchp->cmdinx, cmd), FALSE);
                   break;
    case BATPARM : if (mk->breturn == 1)
                   {
                     do_state (baticon, obj, SELECTED);
                     draw_win_obj (window, baticon, obj);
                     do_parm (window, mk);
                     undo_state (baticon, obj, SELECTED);
                     draw_win_obj (window, baticon, obj);
                   } /* if */
                   else
                     do_insert (window, batchp->parmp [batchp->parminx], TRUE);
                   break;
  } /* switch */
} /* do_popup */

/*****************************************************************************/

LOCAL VOID do_insert (window, s, is_parm)
WINDOWP window;
BYTE    *s;
BOOLEAN is_parm;

{
  BATCH_SPEC *batchp;
  WORD       ret;
  LONGSTR    t;

  batchp   = (BATCH_SPEC *)window->special;

  strcpy (t, s);

  if (is_parm)
    chrcat (t, '=');

  set_clip (TRUE, &window->scroll);
  hide_mouse ();
  edit_obj (&batchp->ed, ED_HIDECURSOR, 0, NULL);
  ret = edit_obj (&batchp->ed, ED_PASTEBUF, TRUE, t);
  edit_obj (&batchp->ed, ED_SHOWCURSOR, 0, NULL);
  show_mouse ();

  if ((ret == ED_BUFFERCHANGED) && ! batchp->dirty)
  {
    batchp->dirty = TRUE;
    set_name (window);
  } /* if */
} /* do_insert */

/*****************************************************************************/

LOCAL VOID do_cmd (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BATCH_SPEC *batchp;
  WORD       i;
  LONGSTR    cmd;
  LONG       item;
  BYTE       *p;

  batchp = (BATCH_SPEC *)window->special;

  ListBoxSetComboRect (baticon, BATCMD, NULL, VISIBLE);

  if ((item = ListBoxComboClick (baticon, BATCMD, mk)) != FAILURE)
  {
    batchp->cmdinx = (WORD)item;
    do_insert (window, get_cmd (batchp->cmdinx, cmd), FALSE);

    i = strlen (cmd) - 1;

    if (cmd [i] == SP)
      cmd [i] = EOS;

    batchp->parminx   = 0;
    batchp->num_parms = 0;

    get_parmnames (cmd, batchp->parms);

    for (p = strtok (batchp->parms, ","); p != NULL; p = strtok (NULL, ","))
      batchp->parmp [batchp->num_parms++] = p;

    p = (batchp->num_parms == 0) ? "" : batchp->parmp [batchp->parminx];
    strncpy (get_str (baticon, BATPARM), p, num_chars);

    if (batchp->num_parms == 0)
    {
      do_state (baticon, BATPARM - 1, DISABLED);
      do_state (baticon, BATPARM, DISABLED);
    } /* if */
    else
    {
      undo_state (baticon, BATPARM - 1, DISABLED);
      undo_state (baticon, BATPARM, DISABLED);
    } /* if */

    draw_win_obj (window, baticon, BATPARM - 1);
    draw_win_obj (window, baticon, BATPARM);
  } /* if */
} /* do_cmd */

/*****************************************************************************/

LOCAL VOID do_parm (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BATCH_SPEC *batchp;
  LONG       item;

  batchp = (BATCH_SPEC *)window->special;

  ListBoxSetComboRect (baticon, BATPARM, NULL, VISIBLE);

  if ((item = ListBoxComboClick (baticon, BATPARM, mk)) != FAILURE)
  {
    batchp->parminx = (WORD)item;
    do_insert (window, batchp->parmp [item], TRUE);
  } /* if */
} /* do_parm */

/*****************************************************************************/

LOCAL LONG cmd_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BATCH_SPEC   *batchp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  batchp = (BATCH_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)batchp->cmds [index].cmd);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &toolbat_icon : NULL, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strncpy (get_str (tree, obj), s, num_chars);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* cmd_callback */

/*****************************************************************************/

LOCAL LONG parm_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BATCH_SPEC   *batchp;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  batchp = (BATCH_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)batchp->parmp [index]);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strncpy (get_str (tree, obj), s, num_chars);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* parm_callback */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  BATCH_SPEC *batchp;

  menu_normal (window, title, FALSE);       /* invert title */

  batchp = (BATCH_SPEC *)window->special;

  switch (title)
  {
    case MFILE : switch (item)
                 {
                   case MEXPORT : text_export (batchp->sysbatch.batch, strlen (batchp->sysbatch.batch));
                                  break;
                   case MIMPORT : if (text_import (batchp->sysbatch.batch, MAX_BATCH))
                                  {
                                    batchp->dirty = TRUE;
                                    set_name (window);
                                    edit_obj (&batchp->ed, ED_EXIT, 0, NULL);
                                    batchp->ed.actsize = strlen (batchp->sysbatch.batch);
                                    edit_obj (&batchp->ed, ED_INIT, 0, NULL);
                                    window->doc.h = batchp->ed.lines;
                                    set_sliders (window, VERTICAL, SLPOS | SLSIZE);
                                    set_redraw (window, &window->scroll);
                                  } /* if */
                                  break;
                 } /* switch */
                 break;
  } /* switch */

  menu_normal (window, title, TRUE);        /* normalize title */
} /* handle_menu */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN wi_test (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN     ret, ext;
  BATCH_SPEC *batchp;
  WORD        button;

  ret     = TRUE;
  ext     = (action & DO_EXTERNAL) != 0;
  ext     = ext;
  batchp = (BATCH_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! acc_close && batchp->dirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       ret    = (button == 1) ? batch_save (window, FALSE) : button <= 2;
                     } /* if */
                     break;
    case DO_DELETE : break;
  } /* switch */

  return (ret);
} /* wi_test */

/*****************************************************************************/
/* ™ffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieže Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  BATCH_SPEC *batchp;

  batchp = (BATCH_SPEC *)window->special;

  edit_obj (&batchp->ed, ED_EXIT, 0, NULL);
  mem_free (batchp);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  BATCH_SPEC *batchp;

  batchp = (BATCH_SPEC *)window->special;

  fix_iconbar (window);
  objc_draw (baticon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  edit_obj (&batchp->ed, ED_HIDECURSOR, 0, NULL);
  edit_obj (&batchp->ed, ED_DRAW, 0, NULL);
  edit_obj (&batchp->ed, ED_SHOWCURSOR, 0, NULL);
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
} /* wi_snap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BATCH_SPEC *batchp;
  WORD       obj;

  if (find_top () == window)
  {
    batchp = (BATCH_SPEC *)window->special;

    fix_iconbar (window);

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    set_clip (TRUE, &window->scroll);

    obj = objc_find (baticon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    if (obj != NIL)
      if (! is_state (baticon, obj, DISABLED))
        do_popup (window, mk, obj);

    if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
    {
      hide_mouse ();
      edit_obj (&batchp->ed, ED_HIDECURSOR, 0, NULL);
      edit_obj (&batchp->ed, ED_CLICK, 0, mk);
      edit_obj (&batchp->ed, ED_SHOWCURSOR, 0, NULL);
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
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BATCH_SPEC *batchp;
  WORD        ret, lines;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  set_period (mk);
  fix_iconbar (window);

  batchp = (BATCH_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);

  if (mk->ascii_code == ESC) return (TRUE);     /* nicht auswerten */

  if (mk->shift)
    if ((F13 <= mk->scan_code) && (mk->scan_code <= F14))
    {
      mk->momask   = 0x0001;
      mk->mobutton = 0x0000;
      mk->breturn  = 1;
      do_popup (window, mk, (mk->scan_code == F13) ? BATCMD : BATPARM);
      return (TRUE);
    } /* if, if */

  lines         = batchp->ed.lines;
  ret           = edit_obj (&batchp->ed, ED_KEY, 0, mk);
  window->doc.h = batchp->ed.lines;

  if (lines != batchp->ed.lines) set_sliders (window, VERTICAL, SLPOS | SLSIZE);

  if ((ret == ED_BUFFERCHANGED) && ! batchp->dirty)
  {
    batchp->dirty = TRUE;
    set_name (window);
  } /* if */

  if ((ret == ED_OK) || (ret == ED_BUFFERCHANGED)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

