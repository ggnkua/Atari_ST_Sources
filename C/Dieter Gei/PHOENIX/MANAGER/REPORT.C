/*****************************************************************************
 *
 * Module : REPORT.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 31.12.94
 *
 *
 * Description: This module implements the report definition window.
 *
 * History:
 * 31.12.94: Using new function names of controls module
 * 28.07.94: Additional parameter in call to do_report added
 * 02.05.94: ED_PASTE replaced by ED_PASTEBUF
 * 20.03.94: Parameter saveas added
 * 19.03.94: Number of copies in call to do_report added
 * 10.03.94: Always using monospaced font
 * 12.02.94: Function get_list added
 * 04.11.93: Using fontdesc
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 09.10.93: Sliders are draw correctly when text is imported
 * 08.10.93: Variable num_chars is calculated using strlen
 * 02.10.93: Export and import of text added
 * 01.10.93: Multikey bitmap added
 * 28.09.93: Windows snaps on even y coordinates
 * 24.09.93: Function fix_iconbar added
 * 18.09.93: Clipping is set before cursor is repositioned after REP_EDIT
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 13.09.93: New combobox used
 * 10.09.93: Modifications for SEL_SPEC added
 * 04.09.93: Call of form_button replaced by window_button
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 31.08.93: INITX and INITY changed
 * 28.08.93: Modifications for 3d look added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "commdlg.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "editobj.h"
#include "list.h"
#include "mpagefrm.h"
#include "printer.h"
#include "repmake.h"
#include "resource.h"
#include "select.h"

#include "export.h"
#include "report.h"

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

#if MSDOS
#define ADD_BUFFER  4196                /* 4 KB more buffer */
#else
#define ADD_BUFFER 16384                /* 16 KB more buffer */
#endif
#define VISIBLE        8                /* number of visible items in popup */

/****** TYPES ****************************************************************/

typedef struct
{
  DB       *db;                         /* database */
  FONTDESC fontdesc;                    /* font */
  WORD     tblinx;                      /* table index */
  WORD     num_tbls;                    /* number of tables */
  WORD     *tables;                     /* table numbers */
  WORD     colinx;                      /* column index */
  WORD     num_cols;                    /* number of columns */
  WORD     *columns;                    /* column numbers */
  WORD     inxinx;                      /* index index */
  WORD     num_inxs;                    /* number of indexes */
  WORD     *indexes;                    /* index numbers */
  BOOLEAN  dirty;                       /* buffer changed */
  LONG     size;                        /* size of text buffer */
  BYTE     *text;                       /* points to actual text */
  EDOBJ    ed;                          /* editable object */
} REPORT_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD        num_chars;            /* number of characters for combobox */
LOCAL REPORT_SPEC *sortp;               /* for sorting tables and columns */
LOCAL BYTE        *button_cmd [] =
{
  "{SYSDATE}", "{SYSTIME}", "{SYSTIMESTAMP}", "{COUNT}", ">", "{<}", "{+}"
};

/****** FUNCTIONS ************************************************************/

LOCAL VOID    fix_iconbar  _((WINDOWP window));
LOCAL WORD    ed_init      _((WINDOWP window));
LOCAL VOID    set_name     _((WINDOWP window));
LOCAL BYTE    *get_list    _((WINDOWP window, DB **db, BYTE *name));
LOCAL VOID    do_popup     _((WINDOWP window, MKINFO *mk, WORD obj));
LOCAL VOID    do_insert    _((WINDOWP window, BYTE *s, BOOLEAN incl_brace));
LOCAL VOID    do_tbl       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    tbl_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    do_col       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    col_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    do_inx       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    inx_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    sort_tbls    _((REPORT_SPEC *reportp));
LOCAL VOID    sort_cols    _((REPORT_SPEC *reportp));
LOCAL VOID    sort_inxs    _((REPORT_SPEC *reportp));
LOCAL INT     t_compare    _((WORD *arg1, WORD *arg2));
LOCAL INT     c_compare    _((WORD *arg1, WORD *arg2));
LOCAL INT     i_compare    _((WORD *arg1, WORD *arg2));

LOCAL VOID    update_menu  _((WINDOWP window));
LOCAL VOID    handle_menu  _((WINDOWP window, WORD title, WORD item));
LOCAL BOOLEAN wi_test      _((WINDOWP window, WORD action));
LOCAL VOID    wi_open      _((WINDOWP window));
LOCAL VOID    wi_close     _((WINDOWP window));
LOCAL VOID    wi_delete    _((WINDOWP window));
LOCAL VOID    wi_draw      _((WINDOWP window));
LOCAL VOID    wi_arrow     _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap      _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop     _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag      _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click     _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick   _((WINDOWP window));
LOCAL BOOLEAN wi_key       _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer     _((WINDOWP window));
LOCAL VOID    wi_top       _((WINDOWP window));
LOCAL VOID    wi_untop     _((WINDOWP window));
LOCAL VOID    wi_edit      _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_report ()

{
  rprticon [ROOT].ob_width  = rprticon [1].ob_width  = desk.w;
  rprticon [ROOT].ob_height = rprticon [1].ob_height = rprticon [RIDATE].ob_y + rprticon [RIDATE].ob_height + 4;

  num_chars = strlen (get_str (rprticon, REPTBL));

  ListBoxSetCallback (rprticon, REPTBL, tbl_callback);
  ListBoxSetStyle (rprticon, REPTBL, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (rprticon, REPTBL, gl_wbox / 2);

  ListBoxSetCallback (rprticon, REPCOL, col_callback);
  ListBoxSetStyle (rprticon, REPCOL, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (rprticon, REPCOL, gl_wbox / 2);

  ListBoxSetCallback (rprticon, REPINX, inx_callback);
  ListBoxSetStyle (rprticon, REPINX, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (rprticon, REPINX, gl_wbox / 2);

  return (TRUE);
} /* init_report */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_report ()

{
  return (TRUE);
} /* term_report */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_report (obj, menu, icon, db, report, name, fontdesc)
OBJECT   *obj, *menu;
WORD     icon;
DB       *db;
BYTE     *report, *name;
FONTDESC *fontdesc;

{
  WINDOWP     window;
  WORD        menu_height, inx, err;
  REPORT_SPEC *reportp;
  WORD        char_width, char_height, cell_width, cell_height;
  WORD        tables, cols, inxs, i;
  TABLE_INFO  t_inf;

  reportp = (REPORT_SPEC *)mem_alloc ((LONG)sizeof (REPORT_SPEC));
  if (reportp == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (reportp, 0, sizeof (REPORT_SPEC));

  reportp->size = strlen (report) + ADD_BUFFER;
  reportp->text = mem_alloc (reportp->size);
  if (reportp->text == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    mem_free (reportp);
    return (NULL);
  } /* if */

  db_tableinfo (db->base, SYS_TABLE, &t_inf);
  tables = (WORD)t_inf.recs;
  cols   = inxs = 0;

  for (i = 0; i < tables; i++)
  {
    db_tableinfo (db->base, i, &t_inf);
    cols = max (cols, (WORD)t_inf.cols);
    inxs = max (inxs, (WORD)t_inf.indexes);
  } /* for */

  reportp->tables = mem_alloc (((LONG)tables + (LONG)cols + (LONG)inxs) * sizeof (WORD));
  if (reportp->tables == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    mem_free (reportp->text);
    mem_free (reportp);
    return (NULL);
  } /* if */

  reportp->columns  = reportp->tables + tables;
  reportp->indexes  = reportp->columns + cols;
  reportp->db       = db;
  reportp->fontdesc = *fontdesc;
  strcpy (reportp->text, report);

  if (reportp->text [0] == EOS)                   /* new report */
  {
    db_tableinfo (db->base, db->table, &t_inf);
    sprintf (reportp->text, "{%s = %d}{%s = %d}{%s = %s}\r\n", FREETXT (REPWIDTH), page_format.width, FREETXT (REPLENGT), page_format.length, FREETXT (REPTABLE), t_inf.name);
  } /* if */

  for (i = (db->table < NUM_SYSTABLES) ? SYS_TABLE : NUM_SYSTABLES; i < tables; i++)
    if (db_tableinfo (db->base, i, &t_inf) != FAILURE)
      if (t_inf.cols > 0)
        if (db_acc_table (db->base, i) & GRANT_SELECT) reportp->tables [reportp->num_tbls++] = i;

  sort_tbls (reportp);

  for (i = 0; i < reportp->num_tbls; i++)       /* find actual table */
    if (reportp->tables [i] == db->table) reportp->tblinx = i;

  db_tableinfo (db->base, db->table, &t_inf);
  for (i = 1; i < (WORD)t_inf.cols; i++)
    if (db_acc_column (db->base, db->table, i) & GRANT_SELECT) reportp->columns [reportp->num_cols++] = i;

  if (reportp->num_cols == 0) reportp->colinx = NIL;

  sort_cols (reportp);

  for (i = 0; i < (WORD)t_inf.indexes; i++)
    if (db_acc_index (db->base, db->table, i) & GRANT_SELECT) reportp->indexes [reportp->num_inxs++] = i;

  if (reportp->num_inxs == 0) reportp->inxinx = NIL;

  sort_inxs (reportp);

  if (! FontIsMonospaced (vdi_handle, reportp->fontdesc.font))
    reportp->fontdesc.font = FONT_SYSTEM;

  vst_font (vdi_handle, reportp->fontdesc.font);
  vst_point (vdi_handle, reportp->fontdesc.point, &char_width, &char_height, &cell_width, &cell_height);

  inx    = num_windows (CLASS_REPORT, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_REPORT);

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
    window->scroll.y  = INITY + inx * gl_hbox + rprticon->ob_height + 1 + odd (menu_height);
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = min (INITH, (desk.y + desk.h - window->scroll.y - 6 * gl_hbox) / window->yfac * window->yfac);
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - rprticon->ob_height - 1 - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + rprticon->ob_height + 1 + menu_height;
    window->mousenum  = TEXT_CRSR;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)reportp;
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
    window->showinfo  = info_report;
    window->showhelp  = help_report;

    sprintf (window->name, FREETXT (FDEFREP), db->base->basename);
    sprintf (window->info, " %s", name);

    err = ed_init (window);

    if (err == ED_NOMEMORY)
    {
      hndl_alert (ERR_NOMEMORY);
      delete_window (window);
      window = NULL;
    } /* if */
    else
    {
      window->doc.h = reportp->ed.lines;

      if (report [0] == EOS)    /* position cursor at second line */
      {
        reportp->ed.act_line++;
        reportp->ed.cy       += cell_height;
        reportp->ed.bufindex += strlen (reportp->ed.text);
      } /* if */
    } /* else */
  } /* if */
  else
  {
    mem_free (reportp->tables);
    mem_free (reportp->text);
    mem_free (reportp);
  } /* else */

  set_meminfo ();
  return (window);                                      /* Fenster zurckgeben */
} /* crt_report */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_report (icon, db, report, name, fontdesc)
WORD     icon;
DB       *db;
BYTE     *report, *name;
FONTDESC *fontdesc;

{
  BOOLEAN ok;
  WINDOWP window;

  window = crt_report (NULL, NULL, icon, db, report, name, fontdesc);
  ok     = window != NULL;

  if (ok)
  {
    ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_report */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_report (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR     s;
  REPORT_SPEC *reportp;

  if (icon != NIL)
    window = search_window (CLASS_REPORT, SRCH_ANY, icon);

  if (window != NULL)
  {
    reportp = (REPORT_SPEC *)window->special;

    sprintf (s, alerts [ERR_INFOEDIT], window->doc.h, reportp->ed.actsize); /* Zeilen, Bytes */
    open_alert (s);
  } /* if */

  return (window != NULL);
} /* info_report */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_report (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HREPORT));
} /* help_report */

/*****************************************************************************/

GLOBAL VOID print_report (window)
WINDOWP window;

{
  REPORT_SPEC *reportp;

  reportp = (REPORT_SPEC *)window->special;
  print_buffer (reportp->ed.text, reportp->ed.actsize);
} /* print_report */

/*****************************************************************************/

GLOBAL BOOLEAN close_report (db)
DB *db;

{
  WORD        num, i;
  REPORT_SPEC *reportp;
  WINDOWP     window;
  WINDOWP     windows [MAX_GEMWIND];

  num = num_windows (CLASS_REPORT, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window  = windows [i];
    reportp = (REPORT_SPEC *)window->special;

    if (reportp->db == db)
    {
      delete_window (window);
      if (search_window (CLASS_REPORT, SRCH_ANY, NIL) == window) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_report */

/*****************************************************************************/

GLOBAL VOID report_new ()

{
  open_report (NIL, actdb, "", "", &fontdesc);
} /* report_new */

/*****************************************************************************/

GLOBAL VOID report_old (window)
WINDOWP window;

{
  BYTE      *p;
  DB        *db;
  FIELDNAME report_name;

  if ((window != NULL) && (window->subclass == CLASS_RLIST))
  {
    p = get_list (window, &db, report_name);

    if (p != NULL)
    {
      unclick_window (window);
      open_report (NIL, db, p, report_name, &fontdesc);
      mem_free (p);
      set_meminfo ();
    } /* if */
  } /* if */
} /* report_old */

/*****************************************************************************/

GLOBAL BOOLEAN report_save (window, saveas)
WINDOWP window;
BOOLEAN saveas;

{
  BOOLEAN     ok, found;
  REPORT_SPEC *reportp;
  SYSREPORT   *sysreport;
  SEL_SPEC    sel_spec;
  TABLE_INFO  t_info;
  WORD        result, starttable;
  WORD        num_reports, num, status;
  BYTE        *itemlist, *p;
  CURSOR      cursor;
  LONG        address;
  MKINFO      mk;

  ok      = FALSE;
  reportp = (REPORT_SPEC *)window->special;
  result  = check_report (reportp->db, reportp->db->table, reportp->text, &mk.mox, &mk.moy, &starttable);

  if (result == REP_OK)
  {
    db_tableinfo (reportp->db->base, SYS_REPORT, &t_info);
    num_reports = (WORD)t_info.recs;
    sysreport   = reportp->db->buffer;

    if (! saveas)
      saveas = window->info [1] == EOS;		/* window not saved yet */

    if ((num_reports == 0) || ! saveas)
      itemlist = NULL;
    else
    {
      itemlist = mem_alloc ((LONG)num_reports * (sizeof (FIELDNAME)));

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

      db_initcursor (reportp->db->base, SYS_REPORT, 1, ASCENDING, &cursor);

      for (num = 0, ok = TRUE, p = itemlist; (num < num_reports) && ok && db_movecursor (reportp->db->base, &cursor, 1L); num++, p += sizeof (FIELDNAME))
      {
        ok = db_read (reportp->db->base, SYS_REPORT, sysreport, &cursor, 0L, FALSE);
        strcpy (p, sysreport->name);
      } /* for */

      arrow_mouse ();

      sel_spec.title      = FREETXT (FRSAVEAS);
      sel_spec.itemlist   = itemlist;
      sel_spec.itemsize   = sizeof (FIELDNAME);
      sel_spec.num_items  = num;
      sel_spec.boxtitle   = FREETXT (FRLIST);
      sel_spec.helpinx    = HRSAVEAS;
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
      strcpy (sysreport->name, sel_spec.selection);
      strcpy (sysreport->report, reportp->text);

      if (sysreport->name [0] != EOS)
      {
        found = db_search (reportp->db->base, SYS_REPORT, 1, ASCENDING, &cursor, sysreport, 0L);
        ok    = db_status (reportp->db->base) == SUCCESS;
      } /* if */

      if (ok)
        if (found)
        {
          address            = db_readcursor (reportp->db->base, &cursor, NULL);
          sysreport->address = address;
          ok                 = db_reclock (reportp->db->base, address) && db_update (reportp->db->base, SYS_REPORT, sysreport, &status);
        } /* if */
        else
          ok = db_insert (reportp->db->base, SYS_REPORT, sysreport, &status);

      dbtest (reportp->db);
      updt_lsall (reportp->db, SYS_REPORT, TRUE, FALSE);

      if (ok)
      {
        reportp->dirty = FALSE;
        set_name (window);
      } /* if */

      arrow_mouse ();
    } /* if */

    strcpy (window->info + 1, sel_spec.selection);
    wind_set (window->handle, WF_INFO, ADR (window->info), 0, 0);
    mem_free (itemlist);
    set_meminfo ();
  } /* if */
  else
    if (result == REP_EDIT)
    {
      set_clip (TRUE, &window->scroll);
      edit_obj (&reportp->ed, ED_SETCURSOR, 0, &mk);
    } /* if, else */

  return (ok);
} /* report_save */

/*****************************************************************************/

GLOBAL VOID report_execute (window)
WINDOWP window;

{
  BYTE        *p;
  DB          *db;
  FIELDNAME   report_name;
  REPORT_SPEC *reportp;
  WORD        result, starttable;
  MKINFO      mk;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_RLIST))
  {
    p = get_list (sel_window, &db, report_name);

    if (p != NULL)
    {
      result = check_report (db, FAILURE, p, &mk.mox, &mk.moy, &starttable);

      if (result == REP_OK)
        do_report (db, starttable, db->t_info [tableinx (db, starttable)].index, sort_order, p, NULL, FAILURE, minimize, 1, NULL);
      else
        if (result == REP_EDIT) report_old (sel_window);

      unclick_window (sel_window);
      mem_free (p);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    reportp = (REPORT_SPEC *)window->special;
    result  = check_report (reportp->db, reportp->db->table, reportp->text, &mk.mox, &mk.moy, &starttable);

    if (result == REP_OK)
      do_report (reportp->db, starttable, reportp->db->t_info [tableinx (reportp->db, starttable)].index, sort_order, reportp->text, NULL, FAILURE, minimize, 1, NULL);
    else
      if (result == REP_EDIT)
      {
        set_clip (TRUE, &window->scroll);
        edit_obj (&reportp->ed, ED_SETCURSOR, 0, &mk);
      } /* if, else */
  } /* else */
} /* report_execute */

/*****************************************************************************/

GLOBAL BOOLEAN rep_exec (window, db, table, inx, dir)
WINDOWP window;
DB      *db;
WORD    table, inx, dir;

{
  BOOLEAN     ok;
  REPORT_SPEC *reportp;
  WORD        result, starttable;
  MKINFO      mk;

  ok = FALSE;

  if (window->class == CLASS_REPORT)
  {
    reportp = (REPORT_SPEC *)window->special;

    if (reportp->db != db)
      hndl_alert (ERR_REPMISMATCH);
    else
    {
      result = check_report (db, rtable (table), reportp->text, &mk.mox, &mk.moy, &starttable);

      if (rtable (table) != starttable)
        hndl_alert (ERR_REPMISMATCH);
      else
        if (result == REP_OK)
        {
          ok = TRUE;
          do_report (db, table, inx, dir, reportp->text, NULL, FAILURE, minimize, 1, NULL);
        } /* if */
        else
          if (result == REP_EDIT)
          {
            set_clip (TRUE, &window->scroll);
            edit_obj (&reportp->ed, ED_SETCURSOR, 0, &mk);
          } /* if, else, else */
    } /* else */
  } /* if */

  return (ok);
} /* rep_exec */

/*****************************************************************************/

LOCAL VOID fix_iconbar (WINDOWP window)
{
  REPORT_SPEC *reportp;
  BYTE        *p;

  reportp = (REPORT_SPEC *)window->special;

  rprticon->ob_x = window->work.x;
  rprticon->ob_y = window->work.y;

  p = (reportp->num_tbls == 0) ? "" : db_tablename (reportp->db->base, reportp->tables [reportp->tblinx]);
  strncpy (get_str (rprticon, REPTBL), p, num_chars);

  p = (reportp->num_cols == 0) ? "" : db_fieldname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->columns [reportp->colinx]);
  strncpy (get_str (rprticon, REPCOL), p, num_chars);

  p = (reportp->num_inxs == 0) ? "" : db_indexname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->indexes [reportp->inxinx]);
  strncpy (get_str (rprticon, REPINX), p, num_chars);

  ListBoxSetCount (rprticon, REPTBL, reportp->num_tbls, NULL);
  ListBoxSetCurSel (rprticon, REPTBL, reportp->tblinx);
  ListBoxSetSpec (rprticon, REPTBL, (LONG)window);

  ListBoxSetCount (rprticon, REPCOL, reportp->num_cols, NULL);
  ListBoxSetCurSel (rprticon, REPCOL, reportp->colinx);
  ListBoxSetSpec (rprticon, REPCOL, (LONG)window);

  ListBoxSetCount (rprticon, REPINX, reportp->num_inxs, NULL);
  ListBoxSetCurSel (rprticon, REPINX, reportp->inxinx);
  ListBoxSetSpec (rprticon, REPINX, (LONG)window);
} /* fix_iconbar */

/*****************************************************************************/

LOCAL WORD ed_init (window)
WINDOWP window;

{
  WORD        err;
  REPORT_SPEC *reportp;
  RECT        frame;

  reportp = (REPORT_SPEC *)window->special;
  err     = SUCCESS;

  frame.x = 0;
  frame.y = 0;
  frame.w = window->doc.w * window->xfac;
  frame.h = 30720 / window->yfac * window->yfac;

  reportp->ed.window  = window;
  reportp->ed.pos     = frame;
  reportp->ed.text    = reportp->text;
  reportp->ed.bufsize = reportp->size;
  reportp->ed.actsize = strlen (reportp->text);
  reportp->ed.font    = reportp->fontdesc.font;
  reportp->ed.point   = reportp->fontdesc.point;
  reportp->ed.color   = reportp->fontdesc.color;
  reportp->ed.flags   = ED_ALILEFT | ED_CRACCEPT;

  err = edit_obj (&reportp->ed, ED_INIT, 0, NULL);

  return (err);
} /* ed_init */

/*****************************************************************************/

LOCAL VOID set_name (window)
WINDOWP window;

{
  REPORT_SPEC *reportp;
  STRING      name;

  reportp = (REPORT_SPEC *)window->special;

  sprintf (name, FREETXT (FDEFREP), reportp->db->base->basename);
  sprintf (window->name, " %s%s", (reportp->dirty ? "*" : ""), name + 1);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* set_name */

/*****************************************************************************/

GLOBAL BYTE *get_list (window, db, name)
WINDOWP window;
DB      **db;
BYTE    *name;

{
  BYTE      *p;
  SYSREPORT *sysreport;
  LONG      addr;
  WORD      i, obj;
  ICON_INFO info;

  p         = NULL;
  sysreport = mem_alloc ((LONG)sizeof (SYSREPORT));

  if (sysreport == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    for (i = 0, obj = NIL; (i < SETMAX) && (obj == NIL); i++)
      if (setin (sel_objs, i)) obj = i;

    if (obj != NIL)
    {
      addr = list_addr (window, obj);
      get_listinfo (window, &info, name);

      if (v_read (info.db, SYS_REPORT, sysreport, NULL, addr, FALSE))
      {
        *db = info.db;
        p   = mem_alloc ((LONG)sizeof (REPORTDEF));

        if (p == NULL)
          hndl_alert (ERR_NOMEMORY);
        else
        {
          strcpy (name, sysreport->name);
          strcpy (p, sysreport->report);
        } /* else */
      } /* if */
    } /* if */
  } /* else */

  mem_free (sysreport);
  set_meminfo ();
  return (p);
} /* get_list */

/*****************************************************************************/

LOCAL VOID do_popup (window, mk, obj)
WINDOWP window;
MKINFO  *mk;
WORD    obj;

{
  REPORT_SPEC *reportp;

  reportp = (REPORT_SPEC *)window->special;

  switch (obj)
  {
    case REPTBL : if (mk->breturn == 1)
                  {
                    do_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                    do_tbl (window, mk);
                    undo_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                  } /* if */
                  else
                    if (reportp->num_tbls > 0)
                      do_insert (window, db_tablename (reportp->db->base, reportp->tables [reportp->tblinx]), FALSE);
                  break;
    case REPCOL : if (mk->breturn == 1)
                  {
                    do_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                    do_col (window, mk);
                    undo_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                  } /* if */
                  else
                    if (reportp->num_cols > 0)
                      do_insert (window, db_fieldname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->columns [reportp->colinx]), TRUE);
                  break;
    case REPINX : if (mk->breturn == 1)
                  {
                    do_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                    do_inx (window, mk);
                    undo_state (rprticon, obj, SELECTED);
                    draw_win_obj (window, rprticon, obj);
                  } /* if */
                  else
                    if (reportp->num_inxs > 0)
                      do_insert (window, db_indexname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->indexes [reportp->inxinx]), FALSE);
                  break;
  } /* switch */
} /* do_popup */

/*****************************************************************************/

LOCAL VOID do_insert (window, s, incl_brace)
WINDOWP window;
BYTE    *s;
BOOLEAN incl_brace;

{
  REPORT_SPEC *reportp;
  STRING      str;
  WORD        len, ret;

  reportp = (REPORT_SPEC *)window->special;
  str [0] = EOS;

  if (incl_brace)
  {
    str [0] = REP_CMDBEGIN;
    str [1] = EOS;
  } /* if */

  strcat (str, s);

  if (incl_brace)
  {
    len           = strlen (str);
    str [len]     = REP_CMDEND;
    str [len + 1] = EOS;
  } /* if */

  set_clip (TRUE, &window->scroll);
  hide_mouse ();
  edit_obj (&reportp->ed, ED_HIDECURSOR, 0, NULL);
  ret = edit_obj (&reportp->ed, ED_PASTEBUF, TRUE, str);
  edit_obj (&reportp->ed, ED_SHOWCURSOR, 0, NULL);
  show_mouse ();

  if ((ret == ED_BUFFERCHANGED) && ! reportp->dirty)
  {
    reportp->dirty = TRUE;
    set_name (window);
  } /* if */
} /* do_insert */

/*****************************************************************************/

LOCAL VOID do_tbl (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  REPORT_SPEC *reportp;
  WORD        i;
  TABLE_INFO  t_inf;
  BYTE        *p;
  LONG        item;

  reportp = (REPORT_SPEC *)window->special;

  ListBoxSetComboRect (rprticon, REPTBL, NULL, VISIBLE);

  if ((item = ListBoxComboClick (rprticon, REPTBL, mk)) != FAILURE)
    if (reportp->tblinx != item)
    {
      reportp->tblinx = (WORD)item;

      db_tableinfo (reportp->db->base, reportp->tables [reportp->tblinx], &t_inf);

      for (i = 1, reportp->num_cols = reportp->colinx = 0; i < (WORD)t_inf.cols; i++)
        if (db_acc_column (reportp->db->base, reportp->tables [reportp->tblinx], i) & GRANT_SELECT)
          reportp->columns [reportp->num_cols++] = i;

      if (reportp->num_cols == 0)
        reportp->colinx = FAILURE;

      sort_cols (reportp);

      for (i = 0, reportp->num_inxs = reportp->inxinx = 0; i < (WORD)t_inf.indexes; i++)
        if (db_acc_index (reportp->db->base, reportp->tables [reportp->tblinx], i) & GRANT_SELECT)
          reportp->indexes [reportp->num_inxs++] = i;

      if (reportp->num_inxs == 0)
        reportp->inxinx = FAILURE;

      sort_inxs (reportp);

      p = (reportp->colinx == FAILURE) ? "" : db_fieldname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->columns [reportp->colinx]);
      strncpy (get_str (rprticon, REPCOL), p, num_chars);
      draw_win_obj (window, rprticon, REPCOL);

      p = (reportp->inxinx == FAILURE) ? "" : db_indexname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->indexes [reportp->inxinx]);
      strncpy (get_str (rprticon, REPINX), p, num_chars);
      draw_win_obj (window, rprticon, REPINX);
    } /* if, if */
} /* do_tbl */

/*****************************************************************************/

LOCAL LONG tbl_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  REPORT_SPEC  *reportp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window   = (WINDOWP)ListBoxGetSpec (tree, obj);
  reportp  = (REPORT_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_tablename (reportp->db->base, reportp->tables [index]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &tooltbl_icon : NULL, text, 2);
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
} /* tbl_callback */

/*****************************************************************************/

LOCAL VOID do_col (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  REPORT_SPEC *reportp;
  BYTE        *p;
  LONG        item;

  reportp = (REPORT_SPEC *)window->special;

  ListBoxSetComboRect (rprticon, REPCOL, NULL, VISIBLE);

  if ((item = ListBoxComboClick (rprticon, REPCOL, mk)) != FAILURE)
  {
    reportp->colinx = (WORD)item;

    p = db_fieldname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->columns [reportp->colinx]);
    do_insert (window, p, TRUE);
  } /* if */
} /* do_col */

/*****************************************************************************/

LOCAL LONG col_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  REPORT_SPEC  *reportp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window   = (WINDOWP)ListBoxGetSpec (tree, obj);
  reportp  = (REPORT_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_fieldname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->columns [index]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &toolcol_icon : NULL, text, 2);
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
} /* col_callback */

/*****************************************************************************/

LOCAL VOID do_inx (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  REPORT_SPEC *reportp;
  BYTE        *p;
  LONG        item;

  reportp = (REPORT_SPEC *)window->special;

  ListBoxSetComboRect (rprticon, REPINX, NULL, VISIBLE);

  if ((item = ListBoxComboClick (rprticon, REPINX, mk)) != FAILURE)
  {
    reportp->inxinx = (WORD)item;

    p = db_indexname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->indexes [reportp->inxinx]);
    do_insert (window, p, FALSE);
  } /* if */
} /* do_inx */

/*****************************************************************************/

LOCAL LONG inx_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP          window;
  REPORT_SPEC      *reportp;
  BOOLEAN          visible_part;
  BYTE             *text;
  LB_OWNERDRAW     *lb_ownerdraw;
  RECT             r;
  LOCAL STRING     s;
  LOCAL INDEX_INFO index_info;
  WORD             num_cols;

  window   = (WINDOWP)ListBoxGetSpec (tree, obj);
  reportp  = (REPORT_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_indexname (reportp->db->base, reportp->tables [reportp->tblinx], reportp->indexes [index]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            v_indexinfo (reportp->db, reportp->tables [reportp->tblinx], reportp->indexes [index], &index_info);
                            num_cols = index_info.inxcols.size / sizeof (INXCOL);
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? (num_cols == 1) ? &toolinx_icon : &toolmul_icon : NULL, text, 2);
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
} /* inx_callback */

/*****************************************************************************/

LOCAL VOID sort_tbls (reportp)
REPORT_SPEC *reportp;

{
  sortp = reportp;
  qsort ((VOID *)reportp->tables, (SIZE_T)reportp->num_tbls, sizeof (WORD), t_compare);
} /* sort_tbls */

/*****************************************************************************/

LOCAL VOID sort_cols (reportp)
REPORT_SPEC *reportp;

{
  sortp = reportp;
  qsort ((VOID *)reportp->columns, (SIZE_T)reportp->num_cols, sizeof (WORD), c_compare);
} /* sort_cols */

/*****************************************************************************/

LOCAL VOID sort_inxs (reportp)
REPORT_SPEC *reportp;

{
  sortp = reportp;
  qsort ((VOID *)reportp->indexes, (SIZE_T)reportp->num_inxs, sizeof (WORD), i_compare);
} /* sort_inxs */

/*****************************************************************************/

LOCAL INT t_compare (arg1, arg2)
WORD *arg1, *arg2;

{
  return (strcmp (db_tablename (sortp->db->base, *arg1), db_tablename (sortp->db->base, *arg2)));
} /* t_compare */

/*****************************************************************************/

LOCAL INT c_compare (arg1, arg2)
WORD *arg1, *arg2;

{
  return (strcmp (db_fieldname (sortp->db->base, sortp->tables [sortp->tblinx], *arg1), db_fieldname (sortp->db->base, sortp->tables [sortp->tblinx], *arg2)));
} /* c_compare */

/*****************************************************************************/

LOCAL INT i_compare (arg1, arg2)
WORD *arg1, *arg2;

{
  return (strcmp (db_indexname (sortp->db->base, sortp->tables [sortp->tblinx], *arg1), db_indexname (sortp->db->base, sortp->tables [sortp->tblinx], *arg2)));
} /* i_compare */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  REPORT_SPEC *reportp;

  menu_normal (window, title, FALSE);       /* invert title */

  reportp = (REPORT_SPEC *)window->special;

  switch (title)
  {
    case MFILE : switch (item)
                 {
                   case MEXPORT : text_export (reportp->ed.text, strlen (reportp->ed.text));
                                  break;
                   case MIMPORT : if (text_import (reportp->ed.text, MAX_REPORT))
                                  {
                                    reportp->dirty = TRUE;
                                    set_name (window);
                                    edit_obj (&reportp->ed, ED_EXIT, 0, NULL);
                                    reportp->ed.actsize = strlen (reportp->ed.text);
                                    edit_obj (&reportp->ed, ED_INIT, 0, NULL);
                                    window->doc.h = reportp->ed.lines;
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
  REPORT_SPEC *reportp;
  WORD        button;

  ret     = TRUE;
  ext     = (action & DO_EXTERNAL) != 0;
  ext     = ext;
  reportp = (REPORT_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! acc_close && reportp->dirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       ret    = (button == 1) ? report_save (window, FALSE) : button <= 2;
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
  REPORT_SPEC *reportp;

  reportp = (REPORT_SPEC *)window->special;

  edit_obj (&reportp->ed, ED_EXIT, 0, NULL);
  mem_free (reportp->tables);
  mem_free (reportp->text);
  mem_free (reportp);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  REPORT_SPEC *reportp;

  reportp = (REPORT_SPEC *)window->special;

  fix_iconbar (window);
  objc_draw (rprticon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  edit_obj (&reportp->ed, ED_HIDECURSOR, 0, NULL);
  edit_obj (&reportp->ed, ED_DRAW, 0, NULL);
  edit_obj (&reportp->ed, ED_SHOWCURSOR, 0, NULL);
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
  REPORT_SPEC *reportp;
  WORD        obj;

  if (find_top () == window)
  {
    reportp = (REPORT_SPEC *)window->special;

    fix_iconbar (window);

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    set_clip (TRUE, &window->scroll);

    obj = objc_find (rprticon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    switch (obj)
    {
      case RIDATE   :
      case RITIME   :
      case RITSTAMP :
      case RICOUNT  :
      case RIBRANCH :
      case RIRETURN :
      case RIADD    : window_button (window, rprticon, obj, mk->breturn);
                      if (is_state (rprticon, obj, SELECTED))
                      {
                        undo_state (rprticon, obj, SELECTED);
                        objc_draw (rprticon, obj, MAX_DEPTH, window->work.x, window->work.y, window->work.w, window->work.h);
                        do_insert (window, button_cmd [obj - RIDATE], FALSE);
                      } /* if */
                      break;
       default      : do_popup (window, mk, obj);
                      break;
    } /* switch */

    if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
    {
      hide_mouse ();
      edit_obj (&reportp->ed, ED_HIDECURSOR, 0, NULL);
      edit_obj (&reportp->ed, ED_CLICK, 0, mk);
      edit_obj (&reportp->ed, ED_SHOWCURSOR, 0, NULL);
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
  REPORT_SPEC *reportp;
  WORD        ret, lines;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  set_period (mk);
  fix_iconbar (window);

  reportp = (REPORT_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);

  if (mk->ascii_code == ESC) return (TRUE);     /* nicht auswerten */

  if (mk->shift)
    if ((F13 <= mk->scan_code) && (mk->scan_code <= F15))
    {
      mk->momask   = 0x0001;
      mk->mobutton = 0x0000;
      mk->breturn  = 1;
      do_popup (window, mk, (mk->scan_code == F13) ? REPTBL : (mk->scan_code == F14) ? REPCOL : REPINX);
      return (TRUE);
    } /* if, if */

  lines         = reportp->ed.lines;
  ret           = edit_obj (&reportp->ed, ED_KEY, 0, mk);
  window->doc.h = reportp->ed.lines;

  if (lines != reportp->ed.lines) set_sliders (window, VERTICAL, SLPOS | SLSIZE);

  if ((ret == ED_BUFFERCHANGED) && ! reportp->dirty)
  {
    reportp->dirty = TRUE;
    set_name (window);
  } /* if */

  if ((ret == ED_OK) || (ret == ED_BUFFERCHANGED)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

