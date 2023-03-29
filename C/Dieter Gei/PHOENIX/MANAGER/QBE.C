/*****************************************************************************
 *
 * Module : QBE.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 11.10.95
 *
 *
 * Description: This module implements the qbe definition window.
 *
 * History:
 * 11.10.95: DrawCheckRadio uses default background color
 * 27.07.94: Always using CHICAGO font
 * 26.07.94: Parameter vdi_handle added in call to DrawCheckRadio
 * 20.03.94: Parameter saveas added in qbe_save
 * 12.03.94: Function DrawCheckRadio used
 * 10.03.94: Proportional fonts added
 * 12.02.94: Function get_list added
 * 25.10.93: Initial height is only 6 lines
 * 02.10.93: Export and import of text added
 * 30.09.93: Overflow in wi_draw fixed (width is LONG)
 * 28.09.93: Windows snaps on even y coordinates
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 10.09.93: Modifications for SEL_SPEC added
 * 04.09.93: Call of form_button replaced by window_button
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 01.09.93: Iconbar functionality added
 * 29.08.93: INITX and INITY changed
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

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
#include "list.h"
#include "order.h"
#include "resource.h"
#include "select.h"
#include "selwidth.h"
#include "sql.h"

#include "export.h"
#include "qbe.h"

/****** DEFINES **************************************************************/

#define KIND           (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS          (WI_NONE)
#define XFAC           gl_wbox          /* X-Faktor */
#define YFAC           gl_hbox          /* Y-Faktor */
#define XUNITS         1                /* X-Einheiten fÅr Scrolling */
#define YUNITS         1                /* Y-Einheiten fÅr Scrolling */
#define INITX          (20 * gl_wbox)   /* X-Anfangsposition */
#define INITY          ( 7 * gl_hbox + 11) /* Y-Anfangsposition */
#define INITW          (58 * gl_wbox)   /* Anfangsbreite in Pixel */
#define INITH          (6 * window->yfac)/* Anfangshîhe in Pixel */
#define MILLI          0                /* Millisekunden fÅr Zeitablauf */

#define MAX_OBJS      100               /* maximum number of objects to select */

#define ADD_LINES       4               /* additional lines per record */

#define OP_NOP          0               /* no operation */
#define OP_DELCOL       1               /* operation delete column */
#define OP_INSCOL       2               /* operation insert column */
#define OP_SIZECOL      3               /* operation size column */
#define OP_MOVECOL      4               /* operation move column */
#define OP_DELCOND      5               /* operation delete condition */
#define OP_INSCOND      6               /* operation insert condition */

/****** TYPES ****************************************************************/

typedef struct
{
  DB        *db;                        /* database */
  WORD      table;                      /* table of database */
  WORD      cols;                       /* number of actual cols */
  WORD      *columns;                   /* column order */
  WORD      *colwidth;                  /* column width */
  BYTE      *colheader;                 /* column header */
  UBYTE     *colflags;                  /* column present ? */
  WORD      numsort;                    /* number of columns sorted */
  WORD      colsort [MAX_SORT];         /* column sort order */
  BYTE      *sqlstr;                    /* sql string */
  BYTE      *text;                      /* text of qbe */
  WORD      max_text;                   /* max text of qbe */
  DATE      date;                       /* actual date */
  TIME      time;                       /* actual time */
  TIMESTAMP timestamp;                  /* actual timestamp */
  LONG      max_columns;                /* maximum number of columns */
  WORD      point;                      /* actual point size of system font */
  WORD      iconheight;                 /* height of iconbar */
  WORD      operation;                  /* last operation on window */
  WORD      oldpos;                     /* old position for undo */
  WORD      oldcol;                     /* old column for undo */
  WORD      oldwidth;                   /* old width for undo */
  WORD      editrow;                    /* actual row of cursor */
  WORD      editcol;                    /* actual column of cursor */
  EDOBJ     ed;                         /* edit object */
  LONGSTR   edbuf;                      /* buffer for one object */
  BOOLEAN   dirty;                      /* buffer changed */
} QBE_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    text_extent  _((WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height));
LOCAL VOID    fill_rect    _((WINDOWP window, RECT *rc, WORD color, BOOLEAN show_pattern));
LOCAL VOID    draw_3d_rect _((WINDOWP window, RECT *rc, WORD color_highlight, WORD color_shadow));
LOCAL VOID    draw_border  _((WINDOWP window, RECT *rc));

LOCAL BOOLEAN qbe2sql      _((QBE_SPEC *qbep));
LOCAL BOOLEAN sql2qbe      _((QBE_SPEC *qbep, BOOLEAN checkonly, BOOLEAN qbemode));

LOCAL VOID    drag_column  _((WINDOWP window, WORD col, RECT *rect, MKINFO *mk));
LOCAL VOID    drag_colsep  _((WINDOWP window, WORD col, RECT *rect, BOOLEAN with_hand));
LOCAL WORD    calc_col     _((WINDOWP window, WORD mox, RECT *r, BOOLEAN *sep));
LOCAL VOID    drag_line    _((RECT *r, RECT *diff, RECT *bound, WORD x_raster, WORD y_raster, WORD width, LONG reswidth, BOOLEAN show_reswidth));
LOCAL VOID    draw_line    _((RECT *r, RECT *diff));
LOCAL VOID    move_col     _((QBE_SPEC *qbep, WORD src, WORD dst));
LOCAL VOID    update_col   _((WINDOWP window));
LOCAL VOID    invert_col   _((WINDOWP window, RECT *inv));
LOCAL VOID    revert_flag  _((WINDOWP window, WORD col, RECT *rect));
LOCAL VOID    set_sort     _((WINDOWP window));
LOCAL VOID    get_rect     _((WINDOWP window, WORD row, WORD col, RECT *rect));
LOCAL WORD    ed_next      _((WINDOWP window, WORD row, WORD col, MKINFO *mk));
LOCAL VOID    set_name     _((WINDOWP window));
LOCAL BYTE    *get_list    _((WINDOWP window, DB **db, BYTE *name));

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

GLOBAL BOOLEAN init_qbe ()

{
  WORD obj;

  obj = ROOT;

  do
  {
    if (is_type (qbeicon, obj, G_BUTTON))
      qbeicon [obj].ob_y = 4;
  } while (! is_flags (qbeicon, obj++, LASTOB));

  qbeicon [ROOT].ob_width  = qbeicon [1].ob_width  = desk.w;
  qbeicon [ROOT].ob_height = qbeicon [1].ob_height = qbeicon [QISORT].ob_y + qbeicon [QICOMP].ob_height + 4;

  return (TRUE);
} /* init_qbe */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_qbe ()

{
  return (TRUE);
} /* term_qbe */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_qbe (obj, menu, icon, db, table, sql, sql_name)
OBJECT *obj, *menu;
WORD   icon;
DB     *db;
WORD   table;
BYTE   *sql, *sql_name;

{
  WINDOWP    window;
  WORD       num, col, row, i;
  WORD       cols, *columns, *colwidth;
  LONG       bytes, maxcols;
  QBE_SPEC   *qbep;
  BYTE       *memory;
  BYTE       *p;
  TABLE_INFO t_info;
  STRING     s;

  if (table == FAILURE)
  {
    p = strstr (sql, "FROM");   /* look for table after id FROM */

    if (p != NULL)
    {
      for (p += 4; isspace (*p); p++);
      strncpy (t_info.name, p, MAX_TABLENAME);
      t_info.name [MAX_TABLENAME] = EOS;
      for (p = t_info.name; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
      *p    = EOS;
      table = v_tableinfo (db, FAILURE, &t_info);
    } /* if */
  } /* if */
  else
    table = v_tableinfo (db, table, &t_info);

  bytes  = sizeof (QBE_SPEC) + 2L * t_info.cols * sizeof (WORD);
  memory = mem_alloc (bytes);

  if (memory == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  table = v_tableinfo (db, table, &t_info);

  for (i = 1, maxcols = 0, cols = 0; i < t_info.cols; i++)
    if (db_acc_column (db->base, table, i) & GRANT_SELECT)
    {
      maxcols += abs (def_width (db, rtable (table), i));
      cols++;
    } /* if, for */

  qbep      = (QBE_SPEC *)memory;
  memory   += sizeof (QBE_SPEC);
  columns   = (WORD *)memory;
  memory   += cols * sizeof (WORD);
  colwidth  = (WORD *)memory;
  cols      = init_columns (db, table, t_info.cols, columns, colwidth);
  bytes     = (maxcols + 1) + t_info.cols + sizeof (QUERYDEF) + t_info.cols * MAX_OR + MAX_TEXT;
  memory    = mem_alloc (bytes);

  if (memory == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    mem_free (qbep);
    return (NULL);
  } /* if */

  mem_set (qbep, 0, sizeof (QBE_SPEC));

  qbep->db           = db;
  qbep->table        = table;
  qbep->cols         = cols;
  qbep->columns      = columns;
  qbep->colwidth     = colwidth;
  qbep->colheader    = memory;
  memory            += maxcols + 1;
  qbep->colflags     = (UBYTE *)memory;
  memory            += t_info.cols;
  qbep->sqlstr       = memory;
  memory            += sizeof (QUERYDEF);
  qbep->text         = memory;
  qbep->max_text     = t_info.cols * MAX_OR + MAX_TEXT;
  qbep->max_columns  = maxcols;
  qbep->point        = gl_point;
  qbep->iconheight   = qbeicon->ob_height + 1;
  qbep->editrow      = FAILURE;
  qbep->editcol      = FAILURE;

  strcpy (qbep->sqlstr, sql);

  if (sql [0] == EOS)
  {
    for (col = 0; col < cols; col++)    /* initialize colflags */
      qbep->colflags [columns [col]] = COL_PRESENT;

    mem_set (qbep->text, FS, t_info.cols * MAX_OR);
    for (row = 0; row < MAX_OR; row++) qbep->text [(row + 1) * t_info.cols - 1] = RS;
    qbep->text [t_info.cols * MAX_OR - 1] = EOS;
  } /* if */
  else
    if (! sql2qbe (qbep, FALSE, TRUE))  /* fill colflags etc. from SQL-String */
    {
      mem_free (qbep->colheader);
      mem_free (qbep);
      return (NULL);
    } /* else */

  build_colheader (qbep->db, qbep->table, qbep->cols, qbep->columns, qbep->colwidth, maxcols, qbep->colheader);

  num    = num_windows (CLASS_QBE, SRCH_OPENED, NULL);
  window = create_window (KIND, CLASS_QBE);

  if (window != NULL)
  {
    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = get_width (cols, colwidth);
    window->doc.h     = MAX_OR;
    window->xfac      = gl_wbox;
    window->yfac      = gl_hbox + ADD_LINES;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->xscroll   = window->xfac / 2 - 1 + ((INT)strlen (ltoa (window->doc.h, s, 10)) + 1) * window->xfac;
    window->yscroll   = 2 * window->yfac;
    window->scroll.x  = INITX + num * window->xfac + window->xscroll;
    window->scroll.y  = INITY + (num + 1) * window->yfac + qbep->iconheight;
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = INITH;
    window->work.x    = window->scroll.x - window->xscroll;
    window->work.y    = window->scroll.y - window->yscroll - qbep->iconheight;
    window->work.w    = window->scroll.w + window->xscroll;
    window->work.h    = window->scroll.h + window->yscroll + qbep->iconheight;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)qbep;
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
    window->drag      = wi_drag;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = wi_edit;
    window->showinfo  = info_qbe;
    window->showhelp  = help_qbe;

    dbtbl_name (db, table, window->name);
    sprintf (window->info, " %s", sql_name);
    ed_next (window, 0, 0, NULL);
    set_meminfo ();
  } /* if */

  return (window);                      /* Fenster zurÅckgeben */
} /* crt_qbe */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_qbe (icon, db, table, sql, sql_name)
WORD icon;
DB   *db;
WORD table;
BYTE *sql, *sql_name;

{
  BOOLEAN ok;
  WINDOWP window;

  window = crt_qbe (NULL, NULL, icon, db, table, sql, sql_name);
  ok     = window != NULL;

  if (ok)
  {
    ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_qbe */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_qbe (window, icon)
WINDOWP window;
WORD    icon;

{
  QBE_SPEC *qbep;
  LONGSTR  s;
  STRING   name;
  WORD     used, avail;

  if (icon != NIL)
    window = search_window (CLASS_QBE, SRCH_ANY, icon);

  if (window != NULL)
  {
    qbep = (QBE_SPEC *)window->special;

    table_name (qbep->db, qbep->table, name);

    used   = strlen (qbep->text) + 1;
    avail  = qbep->max_text - used;
    used  -= (qbep->max_text - MAX_TEXT);

    sprintf (s, alerts [ERR_INFOQBE], qbep->db->base->basename, name, used, avail);
    open_alert (s);
  } /* if */

  return (window != NULL);
} /* info_qbe */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_qbe (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HQBE));
} /* help_qbe */

/*****************************************************************************/

GLOBAL BOOLEAN close_qbe (db)
DB *db;

{
  WORD     num, i;
  QBE_SPEC *qbep;
  WINDOWP  window;
  WINDOWP  windows [MAX_GEMWIND];

  num = num_windows (CLASS_QBE, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window = windows [i];
    qbep   = (QBE_SPEC *)window->special;

    if (qbep->db == db)
    {
      delete_window (window);
      if (search_window (CLASS_QBE, SRCH_ANY, NIL) == window) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_qbe */

/*****************************************************************************/

GLOBAL BYTE *get_qbe (window, db, sql_name)
WINDOWP window;
DB      **db;
BYTE    *sql_name;

{
  BYTE     *p;
  QBE_SPEC *qbep;

  qbep = (QBE_SPEC *)window->special;
  *db  = qbep->db;
  p    = mem_alloc ((LONG)sizeof (QUERYDEF));

  if (p == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
    if (qbe2sql (qbep))
    {
      strcpy (p, qbep->sqlstr);
      strcpy (sql_name, window->info + 1);      /* 1 blank */
    } /* if */
    else
    {
      mem_free (p);
      p = NULL;
    } /* else, else */

  set_meminfo ();

  return (p);
} /* get_qbe */

/*****************************************************************************/

GLOBAL VOID qbe_new ()

{
  open_qbe (NIL, actdb, actdb->table, "", "");
} /* qbe_new */

/*****************************************************************************/

GLOBAL VOID qbe_old (window)
WINDOWP window;

{
  BYTE      *p;
  DB        *db;
  FIELDNAME sql_name;

  if ((window != NULL) && (window->subclass == CLASS_QLIST))
  {
    p = get_list (window, &db, sql_name);

    if (p != NULL)
    {
      unclick_window (window);
      open_qbe (NIL, db, FAILURE, p, sql_name);
      mem_free (p);
      set_meminfo ();
    } /* if */
  } /* if */
} /* qbe_old */

/*****************************************************************************/

GLOBAL BOOLEAN qbe_save (window, saveas)
WINDOWP window;
BOOLEAN saveas;

{
  BOOLEAN    ok, found;
  QBE_SPEC   *qbep;
  SYSQUERY   *sysquery;
  SEL_SPEC   sel_spec;
  TABLE_INFO t_info;
  WORD       num_queries, num, status;
  BYTE       *itemlist, *p;
  CURSOR     cursor;
  LONG       address;

  ok   = FALSE;
  qbep = (QBE_SPEC *)window->special;

  if (qbe2sql (qbep))
    if (sql2qbe (qbep, TRUE, FALSE))
    {
      db_tableinfo (qbep->db->base, SYS_QUERY, &t_info);
      num_queries = (WORD)t_info.recs;
      sysquery    = qbep->db->buffer;

      if (! saveas)
        saveas = window->info [1] == EOS;	/* window not saved yet */

      if ((num_queries == 0) || ! saveas)
        itemlist = NULL;
      else
      {
        itemlist = mem_alloc ((LONG)num_queries * (sizeof (FIELDNAME)));

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

        db_initcursor (qbep->db->base, SYS_QUERY, 1, ASCENDING, &cursor);

        for (num = 0, ok = TRUE, p = itemlist; (num < num_queries) && ok && db_movecursor (qbep->db->base, &cursor, 1L); num++, p += sizeof (FIELDNAME))
        {
          ok = db_read (qbep->db->base, SYS_QUERY, sysquery, &cursor, 0L, FALSE);
          strcpy (p, sysquery->name);
        } /* while */

        arrow_mouse ();

        sel_spec.title      = FREETXT (FQSAVEAS);
        sel_spec.itemlist   = itemlist;
        sel_spec.itemsize   = sizeof (FIELDNAME);
        sel_spec.num_items  = num;
        sel_spec.boxtitle   = FREETXT (FQLIST);
        sel_spec.helpinx    = HQSAVEAS;
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
        strcpy (sysquery->name, sel_spec.selection);
        strcpy (sysquery->query, qbep->sqlstr);

        if (sysquery->name [0] != EOS)
        {
          found = db_search (qbep->db->base, SYS_QUERY, 1, ASCENDING, &cursor, sysquery, 0L);
          ok    = db_status (qbep->db->base) == SUCCESS;
        } /* if */

        if (ok)
          if (found)
          {
            address           = db_readcursor (qbep->db->base, &cursor, NULL);
            sysquery->address = address;
            ok                = db_reclock (qbep->db->base, address) && db_update (qbep->db->base, SYS_QUERY, sysquery, &status);
          } /* if */
          else
            ok = db_insert (qbep->db->base, SYS_QUERY, sysquery, &status);

        dbtest (qbep->db);
        updt_lsall (qbep->db, SYS_QUERY, TRUE, FALSE);

        if (ok)
        {
          qbep->dirty = FALSE;
          set_name (window);
        } /* if */

        arrow_mouse ();
      } /* if */

      strcpy (window->info + 1, sel_spec.selection);
      wind_set (window->handle, WF_INFO, ADR (window->info), 0, 0);
      mem_free (itemlist);
      set_meminfo ();
    } /* if, if */

  return (ok);
} /* qbe_save */

/*****************************************************************************/

GLOBAL VOID qbe_execute (window)
WINDOWP window;

{
  BYTE      *p;
  DB        *db;
  FIELDNAME sql_name;

  p = (sel_window != NULL) && (sel_window->subclass == CLASS_QLIST) ? get_list (sel_window, &db, sql_name) : get_qbe (window, &db, sql_name);

  if (p != NULL)
  {
    if ((sel_window != NULL) && (sel_window->subclass == CLASS_QLIST)) unclick_window (sel_window);
    sql_exec (db, p, sql_name, TRUE, NULL);
    mem_free (p);
    set_meminfo ();
  } /* if */
} /* qbe_execute */

/*****************************************************************************/

GLOBAL VOID qbe_complement (window)
WINDOWP window;

{
  QBE_SPEC *qbep;
  WORD     i;
  RECT     r;

  qbep = (QBE_SPEC *)window->special;

  for (i = 0; i < qbep->cols; i++) qbep->colflags [qbep->columns [i]] ^= COL_PRESENT;

  r    = window->work;
  r.y += qbep->iconheight + window->yfac;
  r.h  = window->yfac;
  set_redraw (window, &r);

  if (! qbep->dirty)
  {
    qbep->dirty = TRUE;
    set_name (window);
  } /* if */
} /* qbe_complement */

/*****************************************************************************/

GLOBAL VOID qbe_sort (window)
WINDOWP window;

{
  set_sort (window);
} /* qbe_sort */

/*****************************************************************************/

LOCAL VOID text_extent (WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height)
{
  WORD minimum, maximum, w;
  WORD extent [8], distances [5], effects [3];

  vqt_extent (vdi_handle, text, extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &w, effects);

  if (width != NULL)
    *width  = extent [2] - extent [0] + (incl_effects ? effects [2] : 0);

  if (height != NULL)
    *height = extent [5] - extent [3];
} /* text_extent */

/*****************************************************************************/

LOCAL VOID fill_rect (WINDOWP window, RECT *rc, WORD color, BOOLEAN show_pattern)
{
  RECT r;
  WORD xy [8];

  r    = *rc;
  r.x += window->work.x;
  r.y += window->work.y;

  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (dlg_colors < 16) ? WHITE : color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);

  if (show_pattern)
    if ((color == sys_colors [COLOR_BTNFACE]) && (dlg_colors < 16))
    {
      vsf_color (vdi_handle, BLACK);
      vsf_interior (vdi_handle, FIS_PATTERN);
      vsf_style (vdi_handle, 1);
    } /* if, if */

  vr_recfl (vdi_handle, xy);			/* fill the interior */
} /* fill_rect */

/*****************************************************************************/

LOCAL VOID draw_3d_rect (WINDOWP window, RECT *rc, WORD color_highlight, WORD color_shadow)
{
  WORD xy [6];

  xy [0] = window->work.x + rc->x;
  xy [1] = window->work.y + rc->y + rc->h - 1;
  xy [2] = xy [0];
  xy [3] = window->work.y + rc->y;
  xy [4] = window->work.x + rc->x + rc->w - 1;
  xy [5] = xy [3];

  vswr_mode (vdi_handle, MD_REPLACE);
  vsl_type (vdi_handle, SOLID);
  vsl_color (vdi_handle, color_highlight);

  if (dlg_colors >= 16)
    v_pline (vdi_handle, 3, xy);

  xy [0] = window->work.x + rc->x + rc->w - 1;
  xy [1] = window->work.y + rc->y;
  xy [2] = xy [0];
  xy [3] = window->work.y + rc->y + rc->h - 1;
  xy [4] = window->work.x + rc->x;
  xy [5] = xy [3];

  vsl_color (vdi_handle, color_shadow);
  v_pline (vdi_handle, 3, xy);
} /* draw_3d_rect */

/*****************************************************************************/

LOCAL VOID draw_border (WINDOWP window, RECT *rc)
{
  WORD xy [6];

  vswr_mode (vdi_handle, MD_REPLACE);

  if (colors >= 16)
    vsl_color (vdi_handle, DWHITE);             /* grey line */
  else
  {
    vsl_color (vdi_handle, BLACK);
    vsl_type (vdi_handle, USERLINE);            /* dotted line */
    vsl_udsty (vdi_handle, 0xAAAA);
  } /* else */

  xy [0] = window->work.x + rc->x + rc->w - 1;
  xy [1] = window->work.y + rc->y;
  xy [2] = xy [0];
  xy [3] = window->work.y + rc->y + rc->h - 1;
  xy [4] = window->work.x + rc->x;
  xy [5] = xy [3];

  v_pline (vdi_handle, 3, xy);
} /* draw_border */

/*****************************************************************************/

LOCAL BOOLEAN qbe2sql (qbep)
QBE_SPEC *qbep;

{
  BOOLEAN ok;

  busy_mouse ();

  del_cond (qbep->text, qbep->editrow, qbep->columns [qbep->editcol]);
  set_cond (qbep->text, qbep->editrow, qbep->columns [qbep->editcol], qbep->edbuf, qbep->max_text);

  ok = get_sql ((SQL_SPEC *)qbep);

  arrow_mouse ();

  return (ok);
} /* qbe2sql */

/*****************************************************************************/

LOCAL BOOLEAN sql2qbe (qbep, checkonly, qbemode)
QBE_SPEC *qbep;
BOOLEAN  checkonly, qbemode;

{
  BOOLEAN ok;

  busy_mouse ();

  ok = set_sql ((SQL_SPEC *)qbep, checkonly, qbemode);

  arrow_mouse ();

  return (ok);
} /* sql2qbe */

/*****************************************************************************/

LOCAL VOID drag_column (window, col, rect, mk)
WINDOWP window;
WORD    col;
RECT    *rect;
MKINFO  *mk;

{
  RECT     r, bound;
  WORD     mox, moy;
  WORD     result;
  WORD     dest_obj;
  WINDOWP  dest_window;
  SET      inv_objs;
  QBE_SPEC *qbep;
  BOOLEAN  move, sep;
  WORD     dst;

  qbep = (QBE_SPEC *)window->special;
  move = FALSE;

  xywh2rect (window->scroll.x, window->work.y, window->scroll.w, window->work.h, &bound);
  rc_intersect (&bound, rect);
  bound = desk;

  setclr (inv_objs);

  if (mk->mobutton & 0x0001)
  {
    invert_col (window, rect);
    set_mouse (FLAT_HAND, NULL);
    drag_boxes (1, rect, NULL, inv_objs, &r, &bound, 1, 1);
    last_mouse ();
    graf_mkstate (&mox, &moy, &result, &result);
    invert_col (window, rect);

    result = drag_to_window (mox, moy, window, 0, &dest_window, &dest_obj);

    if (result == DRAG_SWIND)
    {
      dst  = calc_col (window, mox, &r, &sep);
      move = (dst != FAILURE) && (dst != col);
    } /* if */
  } /* if */

  if (move)                                     /* move column */
  {
    qbep->operation = OP_MOVECOL;
    qbep->oldpos    = col;
    qbep->oldcol    = dst;

    move_col (qbep, col, dst);
    update_col (window);

    if (! qbep->dirty)
    {
      qbep->dirty = TRUE;
      set_name (window);
    } /* if */
  } /* if */
} /* drag_column */

/*****************************************************************************/

LOCAL VOID drag_colsep (window, col, rect, with_hand)
WINDOWP window;
WORD    col;
RECT    *rect;
BOOLEAN with_hand;

{
  RECT      r, diff, bound;
  WORD      wdiff, width, sign;
  WORD      i, maxwidth, minwidth;
  QBE_SPEC  *qbep;
  WORD      xy [4];
  LONG      reswidth;
  FIELDNAME name;

  qbep = (QBE_SPEC *)window->special;
  r.x  = rect->x;
  r.y  = window->work.y + qbep->iconheight;
  r.w  = 1;
  r.h  = (WORD)min (window->work.h - qbep->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac);

  width    = abs (qbep->colwidth [col]);
  sign     = SIGN (qbep->colwidth [col]);
  maxwidth = LONGSTRLEN - width;
  minwidth = 2 - width;

  for (i = reswidth = 0; i < qbep->cols; i++)
    if (qbep->colflags [qbep->columns [i]] & COL_PRESENT)
      reswidth += abs (qbep->colwidth [i]);

  if (with_hand)
  {
    xy [0] = r.x + minwidth * window->xfac;
    xy [1] = window->work.y + qbep->iconheight;
    xy [2] = r.x + maxwidth * window->xfac;
    xy [3] = window->work.y + qbep->iconheight + ((WORD)min (window->work.h - qbep->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac)) - 1;

    array2rect (xy, &bound);
    rc_intersect (&window->scroll, &bound);

    listwidt->ob_x = window->scroll.x + (window->scroll.w - listwidt->ob_width) / 2;
    listwidt->ob_y = window->scroll.y + (window->scroll.h - listwidt->ob_height) / 2;

    listwidt->ob_x = min (listwidt->ob_x, desk.x + desk.w - listwidt->ob_width);
    listwidt->ob_y = min (listwidt->ob_y, desk.y + desk.h - listwidt->ob_height);

    set_clip (TRUE, &desk);
    set_mouse (FLAT_HAND, NULL);
    drag_line (&r, &diff, &bound, window->xfac, 0, width, reswidth, (qbep->colflags [qbep->columns [col]] & COL_PRESENT) != 0);
    last_mouse ();

    wdiff = diff.w / window->xfac;
  } /* if */
  else
    wdiff = selwidth (column_name (qbep->db, qbep->table, qbep->columns [col], name), width, minwidth, maxwidth, reswidth, (qbep->colflags [qbep->columns [col]] & COL_PRESENT) != 0);

  if (wdiff != 0)
  {
    wdiff = (wdiff > 0) ? min (wdiff, maxwidth) : max (wdiff, minwidth);

    if (wdiff != 0)
    {
      qbep->operation       = OP_SIZECOL;
      qbep->oldpos          = col;
      qbep->oldwidth        = qbep->colwidth [col];
      width                += wdiff;
      qbep->colwidth [col]  = sign * width;

      update_col (window);

      if (! qbep->dirty)
      {
        qbep->dirty = TRUE;
        set_name (window);
      } /* if */
    } /* if */
  } /* if */
} /* drag_colsep */

/*****************************************************************************/

LOCAL WORD calc_col (window, mox, r, sep)
WINDOWP window;
WORD    mox;
RECT    *r;
BOOLEAN *sep;

{
  LONG     x;
  WORD     i, w;
  QBE_SPEC *qbep;

  qbep = (QBE_SPEC *)window->special;
  x    = window->scroll.x - window->doc.x * window->xfac + window->xfac / 2;

  for (i = 0; i < qbep->cols; i++)
  {
    w  = abs (qbep->colwidth [i]) * window->xfac;
    x += w;

    if (mox < x)                                /* position found */
      if (mox < x - window->xfac)
      {
        r->x = (WORD)x - w - window->xfac / 2;
        r->y = window->work.y + qbep->iconheight;
        r->w = w - 1;
        r->h = (WORD)min (window->work.h - qbep->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac);
        *sep = FALSE;
        return (i);
      } /* if */
      else
      {
        r->x = x - window->xfac / 2 - 1;
        *sep = TRUE;
        return (i);
      } /* else, if */
  } /* for */

  return (FAILURE);
} /* calc_col */

/*****************************************************************************/

LOCAL VOID drag_line (r, diff, bound, x_raster, y_raster, width, reswidth, show_reswidth)
RECT    *r, *diff, *bound;
WORD    x_raster, y_raster, width;
LONG    reswidth;
BOOLEAN show_reswidth;

{
  WORD   event;
  WORD   x_offset, y_offset, x_last, y_last;
  WORD   i, delta, ret;
  RECT   startbox, box;
  MKINFO mk, start;
  MFDB   screen, buffer;
  STRING s;

  graf_mkstate (&start.mox, &start.moy, &start.mobutton, &start.kstate);
  mk      = start;
  box     = startbox = *r;
  diff->w = diff->h = 0;

  if (bound == NULL) bound = &desk;

  sprintf (s, "%5d", width);
  set_str (listwidt, LIWIDTH, s);
  sprintf (s, "%5ld", reswidth);
  set_str (listwidt, LIRESULT, s);

  if (show_reswidth)
    undo_state (listwidt, LIRESULT - 1, DISABLED);
  else
    do_state (listwidt, LIRESULT - 1, DISABLED);

  background (listwidt, ROOT, TRUE, &screen, &buffer);
  objc_draw (listwidt, ROOT, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);
  draw_line (r, diff);

  x_last = start.mox;
  y_last = start.moy;

  do
  {
    event = evnt_multi (MU_BUTTON | MU_M1,
                        1, 0x01, 0x00,
                        TRUE, mk.mox, mk.moy, 1, 1,
                        0, 0, 0, 0, 0,
                        NULL,
                        0, 0,
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

    if (event & MU_M1)
      if ((x_raster != 0) && ((abs (mk.mox - x_last)) >= x_raster) ||
          (y_raster != 0) && ((abs (mk.moy - y_last)) >= y_raster))
      {
        x_last = mk.mox;
        y_last = mk.moy;

        x_offset = mk.mox - start.mox;
        y_offset = mk.moy - start.moy;

        if (x_raster != 0) x_offset = x_offset / x_raster * x_raster;
        if (y_raster != 0) y_offset = y_offset / y_raster * y_raster;

        box.x = startbox.x + x_offset;
        box.y = startbox.y + y_offset;

        delta = 0;
        i     = bound->x - box.x;
        if (i > 0) delta = i;                   /* left edge */

        i = bound->x + bound->w - (box.x + box.w + delta);
        if (i < 0) delta += i;                  /* right edge */

        x_offset += delta;

        delta = 0;
        i     = bound->y - box.y;
        if (i > 0) delta = i;                   /* upper edge */

        i = bound->y + bound->h - (box.y + box.h + delta);
        if (i < 0) delta += i;                  /* lower edge */

        y_offset += delta;

        if ((diff->w != x_offset) || (diff->h != y_offset)) /* anything changed */
        {
          draw_line (r, diff);

          diff->w = x_offset;
          diff->h = y_offset;

          sprintf (s, "%5d", width + x_offset / x_raster);
          set_str (listwidt, LIWIDTH, s);

          if (show_reswidth)
          {
            sprintf (s, "%5ld", reswidth + x_offset / x_raster);
            set_str (listwidt, LIRESULT, s);
          } /* if */

          objc_draw (listwidt, LIWIDTH, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);
          objc_draw (listwidt, LIRESULT, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);
          draw_line (r, diff);
        } /* if */
      } /* if, if */
  } while (! (event & MU_BUTTON));

  draw_line (r, diff);
  background (listwidt, ROOT, FALSE, &screen, &buffer);

  diff->x = mk.mox;
  diff->y = mk.moy;
} /* drag_line */

/*****************************************************************************/

LOCAL VOID draw_line (r, diff)
RECT *r, *diff;

{
  WORD xy [4];

  xy [0] = r->x + diff->w;
  xy [1] = r->y + diff->h;
  xy [2] = xy [0];
  xy [3] = xy [1] + r->h - 1;

  hide_mouse ();
  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);               /* Modi einstellen */
  v_pline (vdi_handle, 2, xy);
  show_mouse ();
} /* draw_line */

/*****************************************************************************/

LOCAL VOID move_col (qbep, src, dst)
QBE_SPEC *qbep;
WORD     src, dst;

{
  WORD save_col, save_width;

  save_col   = qbep->columns [src];
  save_width = qbep->colwidth [src];

  if (dst < src)
  {
    mem_move (&qbep->columns [dst + 1], &qbep->columns [dst], (src - dst) * sizeof (WORD));
    mem_move (&qbep->colwidth [dst + 1], &qbep->colwidth [dst], (src - dst) * sizeof (WORD));

    if (qbep->editcol == src)
      qbep->editcol = dst;
    else
      if ((dst <= qbep->editcol) && (qbep->editcol < src)) qbep->editcol++;
  } /* if */
  else
  {
    mem_move (&qbep->columns [src], &qbep->columns [src + 1], (dst - src) * sizeof (WORD));
    mem_move (&qbep->colwidth [src], &qbep->colwidth [src + 1], (dst - src) * sizeof (WORD));

    if (qbep->editcol == src)
      qbep->editcol = dst;
    else
      if ((src < qbep->editcol) && (qbep->editcol <= dst)) qbep->editcol--;
  } /* else */

  qbep->columns [dst]  = save_col;
  qbep->colwidth [dst] = save_width;
} /* move_col */

/*****************************************************************************/

LOCAL VOID update_col (window)
WINDOWP window;

{
  QBE_SPEC *qbep;
  LONG     max_xdoc;

  qbep = (QBE_SPEC *)window->special;

  window->doc.w = get_width (qbep->cols, qbep->colwidth);
  max_xdoc      = window->doc.w - window->scroll.w / window->xfac;

  if (max_xdoc < 0) max_xdoc = 0;
  if (window->doc.x > max_xdoc) window->doc.x = max_xdoc;

  build_colheader (qbep->db, qbep->table, qbep->cols, qbep->columns, qbep->colwidth, (LONG)qbep->max_columns, qbep->colheader);
  get_rect (window, qbep->editrow, qbep->editcol, &qbep->ed.pos);

  set_sliders (window, HORIZONTAL, SLPOS + SLSIZE);
  redraw_window (window, &window->work);
} /* update_col */

/*****************************************************************************/

LOCAL VOID invert_col (window, inv)
WINDOWP window;
RECT    *inv;

{
  RECT r;
  WORD xy [4];

  wind_update (BEG_UPDATE);
  hide_mouse ();

  vswr_mode (vdi_handle, MD_XOR);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_color (vdi_handle, BLACK);

  wind_get (window->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

  while ((r.w != 0) && (r.h != 0))
  {
    if (rc_intersect (inv, &r))
    {
      set_clip (TRUE, &r);
      rect2array (&r, xy);
      vr_recfl (vdi_handle, xy);
    } /* if */

    wind_get (window->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
  } /* while */

  show_mouse ();
  wind_update (END_UPDATE);
} /* invert_col */

/*****************************************************************************/

LOCAL VOID revert_flag (window, col, rect)
WINDOWP window;
WORD    col;
RECT    *rect;

{
  QBE_SPEC *qbep;
  RECT     r;

  qbep         = (QBE_SPEC *)window->special;
  qbep->oldpos = col;
  col          = qbep->columns [col];

  qbep->colflags [col] ^= COL_PRESENT;
  qbep->operation       = (qbep->colflags [col] & COL_PRESENT) ? OP_INSCOL : OP_DELCOL;

  r.x = rect->x + 1;
  r.y = rect->y + window->yfac;
  r.w = rect->w - 2;
  r.h = window->yfac;

  hide_mouse ();
  DrawCheckRadio (vdi_handle, &r, rect, NULL, 0, qbep->colflags [col] & COL_PRESENT ? SELECTED : NORMAL, FAILURE, NULL, FALSE);
  show_mouse ();

  if (! qbep->dirty)
  {
    qbep->dirty = TRUE;
    set_name (window);
  } /* if */
} /* revert_flag */

/*****************************************************************************/

GLOBAL VOID set_sort (window)
WINDOWP window;

{
  QBE_SPEC *qbep;
  RECT     r;

  qbep = (QBE_SPEC *)window->special;

  if (hndl_order (qbep->db, qbep->table, &qbep->numsort, qbep->colsort))
  {
    r    = window->work;
    r.y += qbep->iconheight;
    r.h  = window->yscroll;
    set_redraw (window, &r);

    if (! qbep->dirty)
    {
      qbep->dirty = TRUE;
      set_name (window);
    } /* if */
  } /* if */
} /* set_sort */

/*****************************************************************************/

LOCAL VOID get_rect (window, row, col, rect)
WINDOWP window;
WORD    row, col;
RECT    *rect;

{
  WORD     i;
  QBE_SPEC *qbep;

  qbep = (QBE_SPEC *)window->special;

  for (i = rect->x = 0; i < col; i++)
    rect->x += abs (qbep->colwidth [i]);

  rect->x *= window->xfac;
  rect->y  = row * window->yfac + 1;
  rect->w  = (abs (qbep->colwidth [col]) - 1) * gl_wbox;
  rect->h  = gl_hbox;
} /* get_rect */

/*****************************************************************************/

GLOBAL WORD ed_next (window, row, col, mk)
WINDOWP window;
WORD    row, col;
MKINFO  *mk;

{
  WORD     err;
  QBE_SPEC *qbep;
  RECT     frame;

  qbep = (QBE_SPEC *)window->special;
  err  = SUCCESS;

  if (qbep->editcol != FAILURE)
  {
    if ((qbep->ed.doc.x > 0) || (qbep->ed.doc.y > 0))   /* has been scrolled */
    {
      qbep->ed.doc.x = qbep->ed.doc.y = 0;
      edit_obj (&qbep->ed, ED_DRAW, 0, NULL);
    } /* if */

    edit_obj (&qbep->ed, ED_EXIT, 0, NULL);
    del_cond (qbep->text, qbep->editrow, qbep->columns [qbep->editcol]);
    set_cond (qbep->text, qbep->editrow, qbep->columns [qbep->editcol], qbep->edbuf, qbep->max_text);
  } /* if */

  qbep->editrow = row;
  qbep->editcol = col;

  if (qbep->editcol != FAILURE)
  {
    get_cond (qbep->text, row, qbep->columns [col], qbep->edbuf);
    get_rect (window, row, col, &frame);

    qbep->ed.window  = window;
    qbep->ed.pos     = frame;
    qbep->ed.text    = qbep->edbuf;
    qbep->ed.bufsize = LONGSTRLEN;
    qbep->ed.actsize = strlen (qbep->edbuf);
    qbep->ed.font    = FONT_CHICAGO;
    qbep->ed.point   = qbep->point;
    qbep->ed.color   = BLACK;
    qbep->ed.flags   = ED_ALILEFT | ED_AUTOHSCROLL;

    err = edit_obj (&qbep->ed, ED_INIT, 0, mk);
  } /* if */

  return (err);
} /* ed_next */

/*****************************************************************************/

GLOBAL VOID set_name (window)
WINDOWP window;

{
  QBE_SPEC *qbep;
  STRING   name;

  qbep = (QBE_SPEC *)window->special;

  dbtbl_name (qbep->db, qbep->table, name);
  str_rmchar (name, SP);
  sprintf (window->name, " %s%s ", (qbep->dirty ? "*" : ""), name);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* set_name */

/*****************************************************************************/

LOCAL BYTE *get_list (window, db, name)
WINDOWP window;
DB      **db;
BYTE    *name;

{
  BYTE      *p;
  SYSQUERY  *sysquery;
  LONG      addr;
  WORD      i, obj;
  ICON_INFO info;

  p        = NULL;
  sysquery = mem_alloc ((LONG)sizeof (SYSQUERY));

  if (sysquery == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
    {
    for (i = 0, obj = NIL; (i < SETMAX) && (obj == NIL); i++)
      if (setin (sel_objs, i)) obj = i;

    if (obj != NIL)
    {
      addr = list_addr (window, obj);
      get_listinfo (window, &info, name);

      if (v_read (info.db, SYS_QUERY, sysquery, NULL, addr, FALSE))
      {
        *db = info.db;
        p   = mem_alloc ((LONG)sizeof (QUERYDEF));

        if (p == NULL)
          hndl_alert (ERR_NOMEMORY);
        else
        {
          strcpy (name, sysquery->name);
          strcpy (p, sysquery->query);
        } /* else */
      } /* if */
    } /* if */
  } /* else */

  mem_free (sysquery);
  set_meminfo ();
  return (p);
} /* get_list */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  QBE_SPEC *qbep;

  menu_normal (window, title, FALSE);       /* invert title */

  qbep = (QBE_SPEC *)window->special;

  switch (title)
  {
    case MFILE : switch (item)
                 {
                   case MEXPORT : if (qbe2sql (qbep))
                                    text_export (qbep->sqlstr, strlen (qbep->sqlstr));
                                  break;
                   case MIMPORT : if (text_import (qbep->sqlstr, MAX_QUERY))
                                    if (sql2qbe (qbep, FALSE, TRUE))
                                    {
                                      qbep->dirty = TRUE;
                                      set_name (window);
                                      edit_obj (&qbep->ed, ED_CLEAR, 0, NULL);
                                      qbep->editrow = 0;
                                      qbep->editcol = 0;
                                      update_col (window);
                                    } /* if, if */
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
  BOOLEAN  ret;
  QBE_SPEC *qbep;
  WORD     button;

  ret  = TRUE;
  qbep = (QBE_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = qbep->operation != OP_NOP;
                     break;
    case DO_CUT    : ret = FALSE;
                     break;
    case DO_COPY   : ret = FALSE;
                     break;
    case DO_PASTE  : ret = qbep->operation == OP_DELCOND;
                     break;
    case DO_CLEAR  : ret = FALSE;
                     break;
    case DO_SELALL : ret = FALSE;
                     break;
    case DO_CLOSE  : if (! acc_close && qbep->dirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       ret    = (button == 1) ? qbe_save (window, FALSE) : button <= 2;
                     } /* if */
                     break;
    case DO_DELETE : ret = TRUE;
                     break;
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
  QBE_SPEC *qbep;

  qbep = (QBE_SPEC *)window->special;

  edit_obj (&qbep->ed, ED_EXIT, 0, NULL);
  mem_free (qbep->colheader);
  mem_free (qbep);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD     i, j, ret, xfac, yfac, x, y, w, h;
  WORD     text_x, text_y, text_width, text_height;
  LONG     width;
  QBE_SPEC *qbep;
  LONGSTR  line;
  BYTE     *p, *q;
  RECT     rc, rect, save;
  WORD     row, col, num, len;
  BOOLEAN  desc;
  STRING   s;

  xfac = window->xfac;
  yfac = window->yfac;
  qbep = (QBE_SPEC *)window->special;

  edit_obj (&qbep->ed, ED_HIDECURSOR, 0, NULL);
  clr_work (window);

  qbeicon->ob_x = window->work.x;
  qbeicon->ob_y = window->work.y;

  objc_draw (qbeicon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  line_default (vdi_handle);
  text_default (vdi_handle);
  vst_font (vdi_handle, FONT_SYSTEM);
  vst_point (vdi_handle, qbep->point, &ret, &ret, &ret, &ret);
  vst_effects (vdi_handle, TXT_THICKENED);

  if (window->yscroll > 0)
  {
    if (window->xscroll > 0)
    {
      xywh2rect (0, qbep->iconheight, window->xscroll, window->yscroll / 2, &rc);
      fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
      draw_3d_rect (window, &rc, WHITE, BLACK);

      strcpy (s, "#");
      text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

      text_x = window->work.x + window->xscroll - text_width - xfac / 2;
      text_y = window->work.y + qbep->iconheight + 2;
      vswr_mode (vdi_handle, MD_TRANS);
      v_gtext (vdi_handle, text_x, text_y, s);
      vswr_mode (vdi_handle, MD_REPLACE);

      xywh2rect (0, qbep->iconheight + window->yfac, window->xscroll, window->yscroll / 2, &rc);
      fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
      draw_3d_rect (window, &rc, WHITE, BLACK);
    } /* if */

    p = qbep->colheader;
    x = window->xscroll - window->doc.x * xfac;

    for (j = 0; j < qbep->cols; j++, x += w)			/* paint header */
    {
      width = qbep->colwidth [j];
      w     = abs (width) * xfac;

      q = s;
      while (*p != COLUMNSEP) *q++ = *p++;
      *q = EOS;
      p++;

      if ((window->work.x + x + w > clip.x) && (window->work.x + x <= clip.x + clip.w))
      {
        save = clip;
        xywh2rect (window->scroll.x, window->work.y, window->work.w - (window->scroll.x - window->work.x), window->work.h, &rc);
        rc_intersect (&rc, &clip);		        	/* don't paint over left column */
        set_clip (TRUE, &clip);

        xywh2rect ((WORD)x, qbep->iconheight, w, window->yscroll / 2, &rc);
        fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (window, &rc, WHITE, BLACK);

        vst_effects (vdi_handle, TXT_THICKENED);
        vswr_mode (vdi_handle, MD_TRANS);
        text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

        text_x = window->work.x + (WORD)x + xfac / 2;
        text_y = window->work.y + qbep->iconheight + 2;

        if (text_width > w - xfac)				/* use clipping */
        {
          rect = clip;
          xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
          rc_intersect (&clip, &rc);
          set_clip (TRUE, &rc);
          v_gtext (vdi_handle, text_x, text_y, s);
          set_clip (TRUE, &rect);
        } /* if */
        else
        {
          if (width > 0)
            text_x = window->work.x + (WORD)x + w - text_width - xfac / 2 - 1;	/* right aligned */

          v_gtext (vdi_handle, text_x, text_y, s);
        } /* else */

        xywh2rect ((WORD)x, qbep->iconheight + window->yfac, w, window->yscroll / 2, &rc);
        fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (window, &rc, WHITE, BLACK);

        col    = qbep->columns [j];
        rect.x = window->work.x + rc.x + 1;
        rect.y = window->work.y + qbep->iconheight + window->yfac;
        rect.w = w;
        rect.h = window->yfac;

        DrawCheckRadio (vdi_handle, &rect, &clip, NULL, 0, qbep->colflags [col] & COL_PRESENT ? SELECTED : NORMAL, FAILURE, NULL, FALSE);

        num = get_order ((SQL_SPEC *)qbep, col);    /* draw sort order */

        if (num != 0)
        {
          desc  = (num & DESC_ORDER) != 0;
          num  &= ~ DESC_ORDER;
          sprintf (line, "%d%c", num, desc ? '-' : '+');

          len        = max (0, abs (qbep->colwidth [j]) - 1 - 2);   /* 2 chars right, see below */
          line [len] = EOS;

          vswr_mode (vdi_handle, MD_TRANS);
          vst_effects (vdi_handle, TXT_NORMAL);
          v_gtext (vdi_handle, window->work.x + rc.x + 2 * gl_wbox, window->work.y + qbep->iconheight + yfac + 2, line);
        } /* if */

        vswr_mode (vdi_handle, MD_REPLACE);
        set_clip (TRUE, &save);
      } /* if */
    } /* for */
  } /* if */

  y = window->yscroll;
  h = (window->scroll.h + yfac - 1) / yfac;

  for (i = 0; (i < h) && (window->doc.y + i < window->doc.h); i++)	/* paint the data lines */
  {
    x = window->xscroll - window->doc.x * xfac;

    if ((window->work.x + window->xscroll > clip.x) && (window->work.x <= clip.x + clip.w) &&
        (window->work.y + qbep->iconheight + y + yfac > clip.y) && (window->work.y + qbep->iconheight + y < clip.y + clip.h))
    {
      xywh2rect (0, qbep->iconheight + y, window->xscroll, yfac, &rc);
      fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
      draw_3d_rect (window, &rc, WHITE, BLACK);

      vswr_mode (vdi_handle, MD_TRANS);
      vst_effects (vdi_handle, TXT_THICKENED);
      ltoa (window->doc.y + i + 1, s, 10);
      text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

      text_x = window->work.x + window->xscroll - text_width - xfac / 2;
      text_y = window->work.y + qbep->iconheight + y + 2;
      v_gtext (vdi_handle, text_x, text_y, s);
      vswr_mode (vdi_handle, MD_REPLACE);
    } /* if */

    for (j = 0; j < qbep->cols; j++, x += w)		/* get every single column */
    {
      width = qbep->colwidth [j];
      w     = abs (width) * window->xfac;
      row   = (WORD)(window->doc.y + i);
      col   = qbep->columns [j];

      if ((window->work.x + x + w > clip.x) && (window->work.x + x <= clip.x + clip.w) &&
          (window->work.y + qbep->iconheight + y + yfac > clip.y) && (window->work.y + qbep->iconheight + y < clip.y + clip.h))
      {
        get_cond (qbep->text, row, col, line);
        save = clip;
        xywh2rect (window->scroll.x, window->work.y, window->work.w - (window->scroll.x - window->work.x), window->work.h, &rc);
        rc_intersect (&rc, &clip);		        	/* don't paint over left column */
        set_clip (TRUE, &clip);

        xywh2rect ((WORD)x, qbep->iconheight + y, w, yfac, &rc);
        draw_border (window, &rc);

        vswr_mode (vdi_handle, MD_TRANS);
        vst_font (vdi_handle, FONT_CHICAGO);
        vst_effects (vdi_handle, TXT_NORMAL);
        text_extent (vdi_handle, line, TRUE, &text_width, &text_height);

        text_x = window->work.x + (WORD)x;
        text_y = window->work.y + qbep->iconheight + y + 1;

        if ((row == qbep->editrow) && (j == qbep->editcol))
          edit_obj (&qbep->ed, ED_DRAW, 0, NULL);
        else
        {
          if (text_width > w - xfac)				/* use clipping */
          {
            xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
            rc_intersect (&clip, &rc);
            set_clip (TRUE, &rc);
          } /* if */

          v_gtext (vdi_handle, text_x, text_y, line);
        } /* else */

        vswr_mode (vdi_handle, MD_REPLACE);
        set_clip (TRUE, &save);
      } /* if */
    } /* for */

    y += window->yfac;
  } /* for */

  edit_obj (&qbep->ed, ED_SHOWCURSOR, 0, NULL);
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
    if (delta != 0)                             /* Scrolling nîtig */
    {
      window->doc.x = newpos;                   /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);  /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                          /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling nîtig */
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
  WORD wbox, hbox, enlarge;
  LONG max_xdoc, max_ydoc;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / wbox * wbox;        /* Differenz berechnen */
  diff.y = (new->y - r.y) / 2 * 2;
  diff.w = (new->w - r.w) / wbox * wbox;
  diff.h = (new->h - r.h) / hbox * hbox;

  enlarge = MAX_OR * hbox - window->scroll.h;              /* max pixels to enlarge */
  if (diff.h > enlarge) diff.h = enlarge;                  /* max line size */

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
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  return (DRAG_NOACTN);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  QBE_SPEC *qbep;
  WORD     row, col, obj;
  RECT     r;
  BOOLEAN  sep;

  if (find_top () == window)
  {
    qbep          = (QBE_SPEC *)window->special;
    qbeicon->ob_x = window->work.x;
    qbeicon->ob_y = window->work.y;

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    set_clip (TRUE, &window->scroll);

    if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
    {
      row = window->doc.y + (mk->moy - window->scroll.y) / window->yfac;
      col = calc_col (window, mk->mox, &r, &sep);

      if (col != FAILURE)
      {
        hide_mouse ();
        edit_obj (&qbep->ed, ED_HIDECURSOR, 0, NULL);
        if ((row != qbep->editrow) || (col != qbep->editcol)) ed_next (window, row, col, mk);
        edit_obj (&qbep->ed, ED_CLICK, 0, mk);
        edit_obj (&qbep->ed, ED_SHOWCURSOR, 0, NULL);
        show_mouse ();
      } /* if */
    } /* if */
    else
      if (inside (mk->mox, mk->moy, &window->work))       /* in working area ? */
        if (mk->moy < window->work.y + qbep->iconheight)
        {
          obj = objc_find (qbeicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

          switch (obj)
          {
            case QISORT : 
            case QICOMP : window_button (window, qbeicon, obj, mk->breturn);
                          if (is_state (qbeicon, obj, SELECTED))
                          {
                            undo_state (qbeicon, obj, SELECTED);        /* there could be more than one window using the iconbar */
                            objc_draw (qbeicon, obj, MAX_DEPTH, window->work.x, window->work.y, window->work.w, window->work.h);

                            switch (obj)
                            {
                              case QISORT : qbe_sort (window);       break;
                              case QICOMP : qbe_complement (window); break;
                            } /* switch */
                          } /* if */
                          break;
          } /* switch */
        } /* if */
        else
          if ((window->scroll.x < mk->mox) && (mk->moy < window->scroll.y)) /* in column header */
          {
            unclick_window (window);                      /* deselect rows */

            col = calc_col (window, mk->mox, &r, &sep);

            if (col != FAILURE)
              if (! sep)
                if (mk->breturn == 2)
                  if (mk->momask & 0x0001)
                    drag_colsep (window, col, &r, FALSE);
                  else
                    set_sort (window);
                else
                  if (mk->mobutton & 0x0001)
                    drag_column (window, col, &r, mk);
                  else
                  {
                    if (is_top (window)) revert_flag (window, col, &r);
                  } /* else */
              else
                if ((mk->breturn == 2) || (mk->mobutton & 0x0001)) drag_colsep (window, col, &r, (mk->mobutton & 0x0001) != 0);
          } /* if, if, else, else */
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
  QBE_SPEC *qbep;
  WORD     ret;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  set_period (mk);

  qbep = (QBE_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);

  if (mk->scan_code == TAB)
  {
    edit_obj (&qbep->ed, ED_HIDECURSOR, 0, NULL);

    if (mk->shift)
    {
      if (qbep->editcol > 0) ed_next (window, qbep->editrow, qbep->editcol - 1, NULL);
    } /* if */
    else
    {
      if (qbep->editcol < qbep->cols - 1) ed_next (window, qbep->editrow, qbep->editcol + 1, NULL);
    } /* else */

    edit_obj (&qbep->ed, ED_SHOWCURSOR, 0, NULL);

    return (TRUE);
  } /* if */

  if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
  {
    edit_obj (&qbep->ed, ED_HIDECURSOR, 0, NULL);

    if (mk->scan_code == UP)
    {
      if (qbep->editrow > 0) ed_next (window, mk->shift ? 0 : qbep->editrow - 1, qbep->editcol, NULL);
    } /* if */
    else
    {
      if (qbep->editrow < MAX_OR - 1) ed_next (window, mk->shift ? MAX_OR - 1 : qbep->editrow + 1, qbep->editcol, NULL);
    } /* else */

    edit_obj (&qbep->ed, ED_SHOWCURSOR, 0, NULL);

    return (TRUE);
  } /* if */

  ret = edit_obj (&qbep->ed, ED_KEY, 0, mk);

  if ((ret == ED_BUFFERCHANGED) && ! qbep->dirty)
  {
    qbep->dirty = TRUE;
    set_name (window);
  } /* if */

  if ((ret == ED_OK) || (ret == ED_BUFFERCHANGED)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/
/* Cut/Copy/Paste fÅr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  WORD     pos, col, width;
  QBE_SPEC *qbep;

  qbep = (QBE_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : pos   = qbep->oldpos;
                     col   = qbep->oldcol;
                     width = qbep->oldwidth;

                     switch (qbep->operation)
                     {
                       case OP_DELCOL  : qbep->operation = OP_INSCOL;
                                         qbep->colflags [qbep->columns [pos]] ^= COL_PRESENT;
                                         break;
                       case OP_INSCOL  : qbep->operation = OP_DELCOL;
                                         qbep->colflags [qbep->columns [pos]] ^= COL_PRESENT;
                                         break;
                       case OP_SIZECOL : qbep->oldwidth       = qbep->colwidth [pos];
                                         qbep->colwidth [pos] = width;
                                         break;
                       case OP_MOVECOL : qbep->oldpos = col;
                                         qbep->oldcol = pos;
                                         move_col (qbep, col, pos);
                                         break;
                       case OP_DELCOND : qbep->operation = OP_INSCOND;
                                         break;
                       case OP_INSCOND : qbep->operation = OP_DELCOND;
                                         break;
                     } /* switch */

                     if ((qbep->operation != OP_DELCOND) && (qbep->operation != OP_INSCOND)) update_col (window);
                     break;
    case DO_CUT    : break;
    case DO_COPY   : break;
    case DO_PASTE  : if (qbep->operation == OP_DELCOND) wi_edit (window, DO_UNDO);
                     break;
    case DO_CLEAR  : break;
    case DO_SELALL : break;
  } /* switch */
} /* wi_edit */

/*****************************************************************************/
