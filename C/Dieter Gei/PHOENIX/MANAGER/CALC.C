/*****************************************************************************
 *
 * Module : CALC.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 31.12.94
 *
 *
 * Description: This module implements the calc definition window.
 *
 * History:
 * 31.12.94: Using new function names of controls module
 * 02.05.94: ED_PASTE replaced by ED_PASTEBUF
 * 20.03.94: Parameter saveas added
 * 10.03.94: Always using monospaced font
 * 12.02.94: Function get_list added
 * 04.11.93: Using fontdesc
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 14.10.93: Fields are taken from choosen table instead of standard table
 * 09.10.93: Sliders are draw correctly when text is imported
 * 08.10.93: Variable num_chars is calculated using strlen
 * 02.10.93: Export and import of text added
 * 01.10.93: Multikey bitmap added
 * 28.09.93: Windows snaps on even y coordinates
 * 24.09.93: Function fix_iconbar added
 * 18.09.93: Clipping is set before cursor is repositioned after CALC_EDIT
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

#include "calcexec.h"
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
#include "calc.h"

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

#define VISIBLE        8                /* number of visible items in popup */

#define CALC_OK        0                /* calc checking was ok */
#define CALC_EDIT      1                /* user wants to edit calc */
#define CALC_CANCEL    2                /* user doesn't want to edit calc */

#define MAX_ERRCHARS  37                /* max chars in error (40 - strlen (">>>")) */

/****** TYPES ****************************************************************/

typedef struct
{
  DB       *db;                         /* database */
  WORD     table;                       /* table of database */
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
  WORD     opinx;                       /* operator index */
  WORD     num_ops;                     /* number of operators */
  BYTE     **operators;                 /* operators */
  BOOLEAN  dirty;                       /* buffer changed */
  LONG     size;                        /* size of text buffer */
  SYSCALC  syscalc;                     /* actual calculation */
  EDOBJ    ed;                          /* editable object */
} CALC_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD      num_chars;              /* number of characters for combobox */
LOCAL CALC_SPEC *sortp;                 /* for sorting tables and columns */
LOCAL BYTE      *operators [] =
{
  "=",
  "+",
  "-",
  "*",
  "/",
  "(",
  ")",
  "==",
  "<>",
  ">",
  "<",
  ">=",
  "<=",
  "&",
  "|",
  "~",
  "!",
  ":",
  ",",
  ";",
  "IF",
  "THEN",
  "ELSE",
  "END",
  "WHILE",
  "DO",
  "REPEAT",
  "UNTIL",
  "VAR",
  "EXIT",

  "NULL",
  "COUNT",
  "SYSDATE",
  "SYSTIME",
  "SYSTIMESTAMP",
  "USER",
  "DATE()",
  "TIME()",
  "TIMESTAMP()",
  "CHAR()",
  "WORD()",
  "LONG()",
  "FLOAT()",
  "DAY()",
  "MONTH()",
  "YEAR()",
  "HOUR()",
  "MINUTE()",
  "SECOND()",
  "MICROSECOND()",

  "FIRST()",
  "LAST()",
  "REPLACE()",
  "CHR()",
  "LENGTH()",
  "POSITION()",
  "STRLOWER()",
  "STRUPPER()",
  "SUM()",
  "MIN()",
  "MAX()",
  "AVG()",
  "GET()",
  "PUT()",
  "KEYCOUNT()",
  "ALERT()",
  "SUBSTR()",
  "FIELD()",
  "SIN()",
  "COS()",
  "TAN()",
  "ASIN()",
  "ACOS()",
  "ATAN()",
  "ABS()",
  "EXP()",
  "LN()",
  "LOG()",
  "SQRT()",
  "POW()",
  "ROUND()",
  "TRUNC()",
  "SIGN()",
  "RANDOM()",
  "ERRNO"
};

/****** FUNCTIONS ************************************************************/

LOCAL VOID    fix_iconbar  _((WINDOWP window));
LOCAL WORD    ed_init      _((WINDOWP window));
LOCAL VOID    set_name     _((WINDOWP window));
LOCAL SYSCALC *get_list    _((WINDOWP window, DB **db, WORD *table));
LOCAL VOID    do_popup     _((WINDOWP window, MKINFO *mk, WORD obj));
LOCAL VOID    do_insert    _((WINDOWP window, BYTE *s));
LOCAL VOID    do_tbl       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    tbl_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    do_col       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    col_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    do_inx       _((WINDOWP window, MKINFO *mk));
LOCAL LONG    inx_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    do_op        _((WINDOWP window, MKINFO *mk));
LOCAL LONG    op_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    sort_tbls    _((CALC_SPEC *calcp));
LOCAL VOID    sort_cols    _((CALC_SPEC *calcp));
LOCAL VOID    sort_inxs    _((CALC_SPEC *calcp));
LOCAL INT     t_compare    _((WORD *arg1, WORD *arg2));
LOCAL INT     c_compare    _((WORD *arg1, WORD *arg2));
LOCAL INT     i_compare    _((WORD *arg1, WORD *arg2));
LOCAL WORD    comp_error   _((WORD error, BYTE *calc, WORD line, WORD col));

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

GLOBAL BOOLEAN init_calc ()

{
  calcicon [ROOT].ob_width = calcicon [1].ob_width = desk.w;

  num_chars = strlen (get_str (calcicon, CALTBL));

  ListBoxSetCallback (calcicon, CALTBL, tbl_callback);
  ListBoxSetStyle (calcicon, CALTBL, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (calcicon, CALTBL, gl_wbox / 2);

  ListBoxSetCallback (calcicon, CALCOL, col_callback);
  ListBoxSetStyle (calcicon, CALCOL, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (calcicon, CALCOL, gl_wbox / 2);

  ListBoxSetCallback (calcicon, CALINX, inx_callback);
  ListBoxSetStyle (calcicon, CALINX, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (calcicon, CALINX, gl_wbox / 2);

  ListBoxSetCallback (calcicon, CALOP, op_callback);
  ListBoxSetStyle (calcicon, CALOP, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (calcicon, CALOP, gl_wbox / 2);

  return (TRUE);
} /* init_calc */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_calc ()

{
  return (TRUE);
} /* term_calc */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_calc (obj, menu, icon, db, table, calc, name, fontdesc)
OBJECT   *obj, *menu;
WORD     icon;
DB       *db;
WORD     table;
BYTE     *calc, *name;
FONTDESC *fontdesc;

{
  WINDOWP    window;
  WORD       menu_height, inx, err;
  CALC_SPEC  *calcp;
  WORD       char_width, char_height, cell_width, cell_height;
  WORD       tables, cols, inxs, i;
  TABLE_INFO t_inf;

  calcp = (CALC_SPEC *)mem_alloc ((LONG)sizeof (CALC_SPEC));
  if (calcp == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (calcp, 0, sizeof (CALC_SPEC));
  db_tableinfo (db->base, SYS_TABLE, &t_inf);
  tables = (WORD)t_inf.recs;
  cols   = inxs = 0;

  for (i = 0; i < tables; i++)
  {
    db_tableinfo (db->base, i, &t_inf);
    cols = max (cols, (WORD)t_inf.cols);
    inxs = max (inxs, (WORD)t_inf.indexes);
  } /* for */

  calcp->tables = mem_alloc (((LONG)tables + (LONG)cols + (LONG)inxs) * sizeof (WORD));
  if (calcp->tables == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    mem_free (calcp);
    return (NULL);
  } /* if */

  calcp->columns   = calcp->tables + tables;
  calcp->indexes   = calcp->columns + cols;
  calcp->db        = db;
  calcp->table     = table;
  calcp->fontdesc  = *fontdesc;
  calcp->num_ops   = sizeof (operators) / sizeof (BYTE *);
  calcp->operators = operators;
  calcp->size      = MAX_TCALC;

  strcpy (calcp->syscalc.tablename, t_inf.name);
  strcpy (calcp->syscalc.name, name);
  strcpy (calcp->syscalc.text, calc);

  for (i = (db->table < NUM_SYSTABLES) ? SYS_TABLE : NUM_SYSTABLES; i < tables; i++)
    if (db_tableinfo (db->base, i, &t_inf) != FAILURE)
      if (t_inf.cols > 0)
        if (db_acc_table (db->base, i) & GRANT_SELECT) calcp->tables [calcp->num_tbls++] = i;

  sort_tbls (calcp);

  for (i = 0; i < calcp->num_tbls; i++)       /* find actual table */
    if (calcp->tables [i] == db->table) calcp->tblinx = i;

  db_tableinfo (db->base, db->table, &t_inf);
  for (i = 1; i < (WORD)t_inf.cols; i++)
    if (db_acc_column (db->base, db->table, i) & GRANT_SELECT) calcp->columns [calcp->num_cols++] = i;

  if (calcp->num_cols == 0) calcp->colinx = NIL;

  sort_cols (calcp);

  for (i = 0; i < (WORD)t_inf.indexes; i++)
    if (db_acc_index (db->base, db->table, i) & GRANT_SELECT) calcp->indexes [calcp->num_inxs++] = i;

  if (calcp->num_inxs == 0) calcp->inxinx = NIL;

  sort_inxs (calcp);

  if (! FontIsMonospaced (vdi_handle, calcp->fontdesc.font))
    calcp->fontdesc.font = FONT_SYSTEM;

  vst_font (vdi_handle, calcp->fontdesc.font);
  vst_point (vdi_handle, calcp->fontdesc.point, &char_width, &char_height, &cell_width, &cell_height);

  inx    = num_windows (CLASS_CALC, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_CALC);

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
    window->scroll.y  = INITY + inx * gl_hbox + calcicon->ob_height + 1 + odd (menu_height);
    window->scroll.w  = (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = min (INITH, (desk.y + desk.h - window->scroll.y - 6 * gl_hbox) / window->yfac * window->yfac);
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - calcicon->ob_height - 1 - menu_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + calcicon->ob_height + 1 + menu_height;
    window->mousenum  = TEXT_CRSR;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)calcp;
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
    window->showinfo  = info_calc;
    window->showhelp  = help_calc;

    dbtbl_name (db, table, window->name);
    sprintf (window->info, " %s", name);

    err = ed_init (window);

    if (err == ED_NOMEMORY)
    {
      hndl_alert (ERR_NOMEMORY);
      delete_window (window);
      window = NULL;
    } /* if */
    else
      window->doc.h = calcp->ed.lines;
  } /* if */
  else
  {
    mem_free (calcp->columns);
    mem_free (calcp);
  } /* else */

  set_meminfo ();
  return (window);                                      /* Fenster zurckgeben */
} /* crt_calc */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_calc (icon, db, table, calc, name, fontdesc)
WORD     icon;
DB       *db;
WORD     table;
BYTE     *calc, *name;
FONTDESC *fontdesc;

{
  BOOLEAN ok;
  WINDOWP window;

  window = crt_calc (NULL, NULL, icon, db, table, calc, name, fontdesc);
  ok     = window != NULL;

  if (ok)
  {
    ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_calc */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_calc (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR     s;
  CALC_SPEC *calcp;

  if (icon != NIL)
    window = search_window (CLASS_CALC, SRCH_ANY, icon);

  if (window != NULL)
  {
    calcp = (CALC_SPEC *)window->special;

    sprintf (s, alerts [ERR_INFOEDIT], window->doc.h, calcp->ed.actsize); /* Zeilen, Bytes */
    open_alert (s);
  } /* if */

  return (window != NULL);
} /* info_calc */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_calc (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HCALC));
} /* help_calc */

/*****************************************************************************/

GLOBAL VOID print_calc (window)
WINDOWP window;

{
  CALC_SPEC *calcp;

  calcp = (CALC_SPEC *)window->special;
  print_buffer (calcp->ed.text, calcp->ed.actsize);
} /* print_calc */

/*****************************************************************************/

GLOBAL BOOLEAN close_calc (db)
DB *db;

{
  WORD        num, i;
  CALC_SPEC *calcp;
  WINDOWP     window;
  WINDOWP     windows [MAX_GEMWIND];

  num = num_windows (CLASS_CALC, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window  = windows [i];
    calcp = (CALC_SPEC *)window->special;

    if (calcp->db == db)
    {
      delete_window (window);
      if (search_window (CLASS_CALC, SRCH_ANY, NIL) == window) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_calc */

/*****************************************************************************/

GLOBAL VOID calc_new ()

{
  open_calc (NIL, actdb, actdb->table, "", "", &fontdesc);
} /* calc_new */

/*****************************************************************************/

GLOBAL VOID calc_old (window)
WINDOWP window;

{
  SYSCALC *syscalc;
  DB      *db;
  WORD    table;

  if ((window != NULL) && (window->subclass == CLASS_CLIST))
  {
    syscalc = get_list (window, &db, &table);

    if (syscalc != NULL)
    {
      unclick_window (window);
      open_calc (NIL, db, table, syscalc->text, syscalc->name, &fontdesc);
      mem_free (syscalc);
      set_meminfo ();
    } /* if */
  } /* if */
} /* calc_old */

/*****************************************************************************/

GLOBAL BOOLEAN calc_save (window, saveas)
WINDOWP window;
BOOLEAN saveas;

{
  BOOLEAN    ok, found;
  CALC_SPEC  *calcp;
  SYSCALC    *syscalc;
  SEL_SPEC   sel_spec;
  TABLE_INFO t_info;
  WORD       result, error;
  WORD       num_calcs, num, status;
  BYTE       *itemlist, *p;
  CURSOR     cursor;
  LONG       address;
  MKINFO     mk;

  ok     = FALSE;
  calcp  = (CALC_SPEC *)window->special;
  error  = db_compile (calcp->db->base, calcp->table, &calcp->syscalc, &mk.moy, &mk.mox, calcp->db->format);
  result = comp_error (error, calcp->syscalc.text, mk.moy, mk.mox);

  if (result == CALC_OK)
  {
    db_tableinfo (calcp->db->base, SYS_CALC, &t_info);
    num_calcs = (WORD)t_info.recs;
    syscalc   = calcp->db->buffer;

    if (! saveas)
      saveas = window->info [1] == EOS;		/* window not saved yet */

    if ((num_calcs == 0) || ! saveas)
      itemlist = NULL;
    else
    {
      itemlist = mem_alloc ((LONG)num_calcs * (sizeof (FIELDNAME)));

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

      db_initcursor (calcp->db->base, SYS_CALC, 1, ASCENDING, &cursor);

      for (num = 0, ok = TRUE, p = itemlist; (num < num_calcs) && ok && db_movecursor (calcp->db->base, &cursor, 1L); num++, p += sizeof (FIELDNAME))
      {
        ok = db_read (calcp->db->base, SYS_CALC, syscalc, &cursor, 0L, FALSE);
        strcpy (p, syscalc->name);
      } /* for */

      arrow_mouse ();

      sel_spec.title      = FREETXT (FCSAVEAS);
      sel_spec.itemlist   = itemlist;
      sel_spec.itemsize   = sizeof (FIELDNAME);
      sel_spec.num_items  = num;
      sel_spec.boxtitle   = FREETXT (FCLIST);
      sel_spec.helpinx    = HCSAVEAS;
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
      db_tableinfo (calcp->db->base, calcp->table, &t_info);
      strcpy (syscalc->tablename, t_info.name);
      strcpy (syscalc->name, sel_spec.selection);
      strcpy (syscalc->text, calcp->syscalc.text);
      mem_move (&syscalc->code, &calcp->syscalc.code, (UWORD)sizeof (CALCCODE));

      if (syscalc->name [0] != EOS)
      {
        found = db_search (calcp->db->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L);
        ok    = db_status (calcp->db->base) == SUCCESS;
      } /* if */

      if (ok)
        if (found)
        {
          address          = db_readcursor (calcp->db->base, &cursor, NULL);
          syscalc->address = address;
          ok               = db_reclock (calcp->db->base, address) && db_update (calcp->db->base, SYS_CALC, syscalc, &status);
        } /* if */
        else
          ok = db_insert (calcp->db->base, SYS_CALC, syscalc, &status);

      dbtest (calcp->db);
      updt_lsall (calcp->db, SYS_CALC, TRUE, FALSE);

      if (ok)
      {
        calcp->dirty = FALSE;
        set_name (window);
      } /* if */

      arrow_mouse ();
    } /* if */

    strcpy (calcp->syscalc.name, sel_spec.selection);
    strcpy (window->info + 1, sel_spec.selection);
    wind_set (window->handle, WF_INFO, ADR (window->info), 0, 0);
    mem_free (itemlist);
    set_meminfo ();
  } /* if */
  else
    if (result == CALC_EDIT)
    {
      set_clip (TRUE, &window->scroll);
      edit_obj (&calcp->ed, ED_SETCURSOR, 0, &mk);
    } /* if, else */

  return (ok);
} /* calc_save */

/*****************************************************************************/

GLOBAL VOID calc_execute (window)
WINDOWP window;

{
  CALC_SPEC *calcp;
  SYSCALC   *syscalc;
  DB        *db;
  WORD      table;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_CLIST))
  {
    syscalc = get_list (sel_window, &db, &table);

    if (syscalc != NULL)
    {
      if ((actdb != db) || (actdb->table != rtable (table)))
        hndl_alert (ERR_CALCMISMATCH);
      else
      {
        unclick_window (sel_window);
        calc_list (actdb, actdb->table, actdb->t_info [tableinx (actdb, actdb->table)].index, sort_order, &syscalc->code, minimize);
      } /* else */

      mem_free (syscalc);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    calcp = (CALC_SPEC *)window->special;

    calc_exec (window, calcp->db, calcp->table, calcp->db->t_info [tableinx (calcp->db, calcp->table)].index, sort_order);
  } /* else */
} /* calc_execute */

/*****************************************************************************/

GLOBAL VOID calc_assign (window)
WINDOWP window;

{
  SYSCALC   *syscalc;
  DB        *db;
  WORD      table;
  CALC_SPEC *calcp;
  WORD      result, error, i;
  MKINFO    mk;

  if ((sel_window != NULL) && (sel_window->subclass == CLASS_CLIST))
  {
    syscalc = get_list (sel_window, &db, &table);

    if (syscalc != NULL)
    {
      unclick_window (sel_window);

      i = tableinx (db, table);
      strcpy (db->t_info [i].calcname, syscalc->name);
      mem_move (&db->t_info [i].calccode, &syscalc->code, (UWORD)sizeof (CALCCODE));
      updt_lsall (db, table, FALSE, FALSE);

      mem_free (syscalc);
      set_meminfo ();
    } /* if */
  } /* if */
  else
  {
    calcp  = (CALC_SPEC *)window->special;
    error  = db_compile (calcp->db->base, calcp->table, &calcp->syscalc, &mk.moy, &mk.mox, calcp->db->format);
    result = comp_error (error, calcp->syscalc.text, mk.moy, mk.mox);

    if (result == CALC_OK)
    {
      i = tableinx (calcp->db, calcp->table);
      strcpy (calcp->db->t_info [i].calcname, calcp->syscalc.name);
      mem_move (&calcp->db->t_info [i].calccode, &calcp->syscalc.code, (UWORD)sizeof (CALCCODE));
      updt_lsall (calcp->db, calcp->table, FALSE, FALSE);
    } /* if */
    else
      if (result == CALC_EDIT)
      {
        set_clip (TRUE, &window->scroll);
        edit_obj (&calcp->ed, ED_SETCURSOR, 0, &mk);
      } /* if, else */
  } /* else */
} /* calc_assign */

/*****************************************************************************/

GLOBAL VOID calc_remove (db, table)
DB   *db;
WORD table;

{
  WORD i;

  i = tableinx (db, table);
  db->t_info [i].calcname [0]  = EOS;
  db->t_info [i].calccode.size = 0;
  updt_lsall (db, table, FALSE, FALSE);
} /* calc_remove */

/*****************************************************************************/

GLOBAL BOOLEAN calc_exec (window, db, table, inx, dir)
WINDOWP window;
DB      *db;
WORD    table, inx, dir;

{
  BOOLEAN   ok;
  CALC_SPEC *calcp;
  WORD      result, error;
  MKINFO    mk;

  ok = FALSE;

  if (window->class == CLASS_CALC)
  {
    calcp = (CALC_SPEC *)window->special;

    if ((calcp->db != db) || (calcp->table != rtable (table)))
      hndl_alert (ERR_CALCMISMATCH);
    else
    {
      error  = db_compile (calcp->db->base, calcp->table, &calcp->syscalc, &mk.moy, &mk.mox, calcp->db->format);
      result = comp_error (error, calcp->syscalc.text, mk.moy, mk.mox);

      if (result == CALC_OK)
      {
        ok = TRUE;
        calc_list (db, table, inx, dir, &calcp->syscalc.code, minimize);
      } /* if */
      else
        if (result == CALC_EDIT)
        {
          set_clip (TRUE, &window->scroll);
          edit_obj (&calcp->ed, ED_SETCURSOR, 0, &mk);
        } /* if, else */
    } /* else */
  } /* if */

  return (ok);
} /* calc_exec */

/*****************************************************************************/

LOCAL VOID fix_iconbar (WINDOWP window)
{
  CALC_SPEC *calcp;
  BYTE      *p;

  calcp = (CALC_SPEC *)window->special;

  calcicon->ob_x = window->work.x;
  calcicon->ob_y = window->work.y;

  p = (calcp->num_tbls == 0) ? "" : db_tablename (calcp->db->base, calcp->tables [calcp->tblinx]);
  strncpy (get_str (calcicon, CALTBL), p, num_chars);

  p = (calcp->num_cols == 0) ? "" : db_fieldname (calcp->db->base, calcp->table, calcp->columns [calcp->colinx]);
  strncpy (get_str (calcicon, CALCOL), p, num_chars);

  p = (calcp->num_inxs == 0) ? "" : db_indexname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->indexes [calcp->inxinx]);
  strncpy (get_str (calcicon, CALINX), p, num_chars);

  p = (calcp->num_ops == 0) ? "" : calcp->operators [calcp->opinx];
  strncpy (get_str (calcicon, CALOP), p, num_chars);

  ListBoxSetCount (calcicon, CALTBL, calcp->num_tbls, NULL);
  ListBoxSetCurSel (calcicon, CALTBL, calcp->tblinx);
  ListBoxSetSpec (calcicon, CALTBL, (LONG)window);

  ListBoxSetCount (calcicon, CALCOL, calcp->num_cols, NULL);
  ListBoxSetCurSel (calcicon, CALCOL, calcp->colinx);
  ListBoxSetSpec (calcicon, CALCOL, (LONG)window);

  ListBoxSetCount (calcicon, CALINX, calcp->num_inxs, NULL);
  ListBoxSetCurSel (calcicon, CALINX, calcp->inxinx);
  ListBoxSetSpec (calcicon, CALINX, (LONG)window);

  ListBoxSetCount (calcicon, CALOP, calcp->num_ops, NULL);
  ListBoxSetCurSel (calcicon, CALOP, calcp->opinx);
  ListBoxSetSpec (calcicon, CALOP, (LONG)window);
} /* fix_iconbar */

/*****************************************************************************/

LOCAL WORD ed_init (window)
WINDOWP window;

{
  WORD      err;
  CALC_SPEC *calcp;
  RECT      frame;

  calcp = (CALC_SPEC *)window->special;
  err   = SUCCESS;

  frame.x = 0;
  frame.y = 0;
  frame.w = window->doc.w * window->xfac;
  frame.h = 30720 / window->yfac * window->yfac;

  calcp->ed.window  = window;
  calcp->ed.pos     = frame;
  calcp->ed.text    = calcp->syscalc.text;
  calcp->ed.bufsize = calcp->size;
  calcp->ed.actsize = strlen (calcp->syscalc.text);
  calcp->ed.font    = calcp->fontdesc.font;
  calcp->ed.point   = calcp->fontdesc.point;
  calcp->ed.color   = calcp->fontdesc.color;
  calcp->ed.flags   = ED_ALILEFT | ED_CRACCEPT;

  err = edit_obj (&calcp->ed, ED_INIT, 0, NULL);

  return (err);
} /* ed_init */

/*****************************************************************************/

LOCAL VOID set_name (window)
WINDOWP window;

{
  CALC_SPEC *calcp;
  STRING   name;

  calcp = (CALC_SPEC *)window->special;

  dbtbl_name (calcp->db, calcp->table, name);
  str_rmchar (name, SP);
  sprintf (window->name, " %s%s ", (calcp->dirty ? "*" : ""), name);
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* set_name */

/*****************************************************************************/

LOCAL SYSCALC *get_list (window, db, table)
WINDOWP window;
DB      **db;
WORD    *table;

{
  SYSCALC    *syscalc;
  LONG       addr;
  WORD       i, obj;
  ICON_INFO  info;
  TABLE_INFO t_inf;
  LONGSTR    s;

  syscalc = mem_alloc ((LONG)sizeof (SYSCALC));

  if (syscalc == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    for (i = 0, obj = NIL; (i < SETMAX) && (obj == NIL); i++)
      if (setin (sel_objs, i)) obj = i;

    if (obj != NIL)
    {
      addr = list_addr (window, obj);
      get_listinfo (window, &info, NULL);

      if (v_read (info.db, SYS_CALC, syscalc, NULL, addr, FALSE))
      {
        strcpy (t_inf.name, syscalc->tablename);

        *db    = info.db;
        *table = db_tableinfo (info.db->base, FAILURE, &t_inf);

        if (*table == FAILURE)  /* table doesn't exist anymore */
        {
          sprintf (s, alerts [ERR_MNOTABLE], syscalc->tablename);
          open_alert (s);
          mem_free (syscalc);
          syscalc = NULL;
        } /* if */
      } /* if */
    } /* if */
  } /* else */

  set_meminfo ();
  return (syscalc);
} /* get_list */

/*****************************************************************************/

LOCAL VOID do_popup (window, mk, obj)
WINDOWP window;
MKINFO  *mk;
WORD    obj;

{
  CALC_SPEC *calcp;

  calcp = (CALC_SPEC *)window->special;

  switch (obj)
  {
    case CALTBL : if (mk->breturn == 1)
                  {
                    do_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                    do_tbl (window, mk);
                    undo_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                  } /* if */
                  else
                    if (calcp->num_tbls > 0)
                      do_insert (window, db_tablename (calcp->db->base, calcp->tables [calcp->tblinx]));
                  break;
    case CALCOL : if (mk->breturn == 1)
                  {
                    do_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                    do_col (window, mk);
                    undo_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, CALCOL);
                  } /* if */
                  else
                    if (calcp->num_cols > 0)
                      do_insert (window, db_fieldname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->columns [calcp->colinx]));
                  break;
    case CALINX : if (mk->breturn == 1)
                  {
                    do_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                    do_inx (window, mk);
                    undo_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                  } /* if */
                  else
                    if (calcp->num_inxs > 0)
                      do_insert (window, db_indexname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->indexes [calcp->inxinx]));
                  break;
    case CALOP  : if (mk->breturn == 1)
                  {
                    do_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                    do_op (window, mk);
                    undo_state (calcicon, obj, SELECTED);
                    draw_win_obj (window, calcicon, obj);
                  } /* if */
                  else
                    if (calcp->num_ops > 0)
                      do_insert (window, calcp->operators [calcp->opinx]);
                  break;
  } /* switch */
} /* do_popup */

/*****************************************************************************/

LOCAL VOID do_insert (window, s)
WINDOWP window;
BYTE    *s;

{
  CALC_SPEC *calcp;
  WORD      ret;

  calcp   = (CALC_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);
  hide_mouse ();
  edit_obj (&calcp->ed, ED_HIDECURSOR, 0, NULL);
  ret = edit_obj (&calcp->ed, ED_PASTEBUF, TRUE, s);
  edit_obj (&calcp->ed, ED_SHOWCURSOR, 0, NULL);
  show_mouse ();

  if ((ret == ED_BUFFERCHANGED) && ! calcp->dirty)
  {
    calcp->dirty = TRUE;
    set_name (window);
  } /* if */
} /* do_insert */

/*****************************************************************************/

LOCAL VOID do_tbl (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  CALC_SPEC  *calcp;
  WORD       i;
  TABLE_INFO t_inf;
  BYTE       *p;
  LONG       item;

  calcp = (CALC_SPEC *)window->special;

  ListBoxSetComboRect (calcicon, CALTBL, NULL, VISIBLE);

  if ((item = ListBoxComboClick (calcicon, CALTBL, mk)) != FAILURE)
    if (calcp->tblinx != item)
    {
      calcp->tblinx = (WORD)item;

      db_tableinfo (calcp->db->base, calcp->tables [calcp->tblinx], &t_inf);

      for (i = 1, calcp->num_cols = calcp->colinx = 0; i < (WORD)t_inf.cols; i++)
        if (db_acc_column (calcp->db->base, calcp->tables [calcp->tblinx], i) & GRANT_SELECT)
          calcp->columns [calcp->num_cols++] = i;

      if (calcp->num_cols == 0)
        calcp->colinx = FAILURE;

      sort_cols (calcp);

      for (i = 0, calcp->num_inxs = calcp->inxinx = 0; i < (WORD)t_inf.indexes; i++)
        if (db_acc_index (calcp->db->base, calcp->tables [calcp->tblinx], i) & GRANT_SELECT)
          calcp->indexes [calcp->num_inxs++] = i;

      if (calcp->num_inxs == 0)
        calcp->inxinx = FAILURE;

      sort_inxs (calcp);

      p = (calcp->colinx == FAILURE) ? "" : db_fieldname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->columns [calcp->colinx]);
      strncpy (get_str (calcicon, CALCOL), p, num_chars);
      draw_win_obj (window, calcicon, CALCOL);

      p = (calcp->inxinx == FAILURE) ? "" : db_indexname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->indexes [calcp->inxinx]);
      strncpy (get_str (calcicon, CALINX), p, num_chars);
      draw_win_obj (window, calcicon, CALINX);
    } /* if, if */
} /* do_tbl */

/*****************************************************************************/

LOCAL LONG tbl_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  CALC_SPEC    *calcp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  calcp  = (CALC_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_tablename (calcp->db->base, calcp->tables [index]));
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
  CALC_SPEC *calcp;
  BYTE      *p;
  LONG      item;

  calcp = (CALC_SPEC *)window->special;

  ListBoxSetComboRect (calcicon, CALCOL, NULL, VISIBLE);

  if ((item = ListBoxComboClick (calcicon, CALCOL, mk)) != FAILURE)
  {
    calcp->colinx = (WORD)item;

    p = db_fieldname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->columns [calcp->colinx]);
    do_insert (window, p);
  } /* if */
} /* do_col */

/*****************************************************************************/

LOCAL LONG col_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  CALC_SPEC    *calcp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  calcp  = (CALC_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_fieldname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->columns [index]));
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
  CALC_SPEC *calcp;
  BYTE      *p;
  LONG      item;

  calcp = (CALC_SPEC *)window->special;

  ListBoxSetComboRect (calcicon, CALINX, NULL, VISIBLE);

  if ((item = ListBoxComboClick (calcicon, CALINX, mk)) != FAILURE)
  {
    calcp->inxinx = (WORD)item;

    p = db_indexname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->indexes [calcp->inxinx]);
    do_insert (window, p);
  } /* if */
} /* do_inx */

/*****************************************************************************/

LOCAL LONG inx_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP          window;
  CALC_SPEC        *calcp;
  BOOLEAN          visible_part;
  BYTE             *text;
  LB_OWNERDRAW     *lb_ownerdraw;
  RECT             r;
  LOCAL STRING     s;
  LOCAL INDEX_INFO index_info;
  WORD             num_cols;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  calcp  = (CALC_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)db_indexname (calcp->db->base, calcp->tables [calcp->tblinx], calcp->indexes [index]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            v_indexinfo (calcp->db, calcp->tables [calcp->tblinx], calcp->indexes [index], &index_info);
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

LOCAL VOID do_op (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  CALC_SPEC *calcp;
  BYTE      *p;
  LONG      item;

  calcp = (CALC_SPEC *)window->special;

  ListBoxSetComboRect (calcicon, CALOP, NULL, VISIBLE);

  if ((item = ListBoxComboClick (calcicon, CALOP, mk)) != FAILURE)
  {
    calcp->opinx = (WORD)item;

    p = calcp->operators [calcp->opinx];
    do_insert (window, p);
  } /* if */
} /* do_op */

/*****************************************************************************/

LOCAL LONG op_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  CALC_SPEC    *calcp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  calcp  = (CALC_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)calcp->operators [index]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? &toolcal_icon : NULL, text, 2);
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
} /* op_callback */

/*****************************************************************************/

LOCAL VOID sort_tbls (calcp)
CALC_SPEC *calcp;

{
  sortp = calcp;
  qsort ((VOID *)calcp->tables, (SIZE_T)calcp->num_tbls, sizeof (WORD), t_compare);
} /* sort_tbls */

/*****************************************************************************/

LOCAL VOID sort_cols (calcp)
CALC_SPEC *calcp;

{
  sortp = calcp;
  qsort ((VOID *)calcp->columns, (SIZE_T)calcp->num_cols, sizeof (WORD), c_compare);
} /* sort_cols */

/*****************************************************************************/

LOCAL VOID sort_inxs (calcp)
CALC_SPEC *calcp;

{
  sortp = calcp;
  qsort ((VOID *)calcp->indexes, (SIZE_T)calcp->num_inxs, sizeof (WORD), i_compare);
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

LOCAL WORD comp_error (error, calc, line, col)
WORD error;
BYTE *calc;
WORD line, col;

{
  WORD    result, i, inx;
  LONGSTR s;
  STRING  text;
  BYTE    *p;

  if (error == SUCCESS) return (CALC_OK);

  for (i = inx = 0; i < line; i++)
    while (calc [inx++] != LF);

  inx += col;

  strncpy (text, &calc [inx], MAX_ERRCHARS);
  text [MAX_ERRCHARS] = EOS;
  if ((p = strchr (text, CR)) != NULL) *p = EOS;
  if ((p = strchr (text, LF)) != NULL) *p = EOS;
  if ((p = strchr (text, SEP_OPEN)) != NULL) *p = EOS;

  sprintf (s, alerts [error], text, line + 1, col + 1);

  result = open_alert (s);

  return (result);
} /* comp_error */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  CALC_SPEC *calcp;

  menu_normal (window, title, FALSE);       /* invert title */

  calcp = (CALC_SPEC *)window->special;

  switch (title)
  {
    case MFILE : switch (item)
                 {
                   case MEXPORT : text_export (calcp->syscalc.text, strlen (calcp->syscalc.text));
                                  break;
                   case MIMPORT : if (text_import (calcp->syscalc.text, MAX_TCALC))
                                  {
                                    calcp->dirty = TRUE;
                                    set_name (window);
                                    edit_obj (&calcp->ed, ED_EXIT, 0, NULL);
                                    calcp->ed.actsize = strlen (calcp->syscalc.text);
                                    edit_obj (&calcp->ed, ED_INIT, 0, NULL);
                                    window->doc.h = calcp->ed.lines;
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
  CALC_SPEC *calcp;
  WORD        button;

  ret     = TRUE;
  ext     = (action & DO_EXTERNAL) != 0;
  ext     = ext;
  calcp = (CALC_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE; break;
    case DO_CUT    : ret = FALSE; break;
    case DO_COPY   : ret = FALSE; break;
    case DO_PASTE  : ret = FALSE; break;
    case DO_CLEAR  : ret = FALSE; break;
    case DO_SELALL : ret = FALSE; break;
    case DO_CLOSE  : if (! acc_close && calcp->dirty)
                     {
                       button = hndl_alert (ERR_SAVEMODIFIED);
                       ret    = (button == 1) ? calc_save (window, FALSE) : button <= 2;
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
  CALC_SPEC *calcp;

  calcp = (CALC_SPEC *)window->special;

  edit_obj (&calcp->ed, ED_EXIT, 0, NULL);
  mem_free (calcp->columns);
  mem_free (calcp);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  CALC_SPEC *calcp;

  calcp = (CALC_SPEC *)window->special;

  fix_iconbar (window);
  objc_draw (calcicon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  edit_obj (&calcp->ed, ED_HIDECURSOR, 0, NULL);
  edit_obj (&calcp->ed, ED_DRAW, 0, NULL);
  edit_obj (&calcp->ed, ED_SHOWCURSOR, 0, NULL);
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
  CALC_SPEC *calcp;
  WORD      obj;

  if (find_top () == window)
  {
    calcp = (CALC_SPEC *)window->special;

    fix_iconbar (window);

    if (sel_window != window) unclick_window (sel_window); /* deselect */

    set_clip (TRUE, &window->scroll);

    obj = objc_find (calcicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    if (obj != NIL) do_popup (window, mk, obj);

    if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
    {
      hide_mouse ();
      edit_obj (&calcp->ed, ED_HIDECURSOR, 0, NULL);
      edit_obj (&calcp->ed, ED_CLICK, 0, mk);
      edit_obj (&calcp->ed, ED_SHOWCURSOR, 0, NULL);
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
  CALC_SPEC *calcp;
  WORD        ret, lines;

  if (menu_key (window, mk)) return (TRUE);
  if (find_top () != window) return (FALSE);

  set_period (mk);
  fix_iconbar (window);

  calcp = (CALC_SPEC *)window->special;

  set_clip (TRUE, &window->scroll);

  if (mk->ascii_code == ESC) return (TRUE);     /* nicht auswerten */

  if (mk->shift)
    if ((F13 <= mk->scan_code) && (mk->scan_code <= F16))
    {
      mk->momask   = 0x0001;
      mk->mobutton = 0x0000;
      mk->breturn  = 1;
      do_popup (window, mk, (mk->scan_code == F13) ? CALTBL : (mk->scan_code == F14) ? CALCOL : (mk->scan_code == F15) ? CALINX : CALOP);
      return (TRUE);
    } /* if, if */

  lines         = calcp->ed.lines;
  ret           = edit_obj (&calcp->ed, ED_KEY, 0, mk);
  window->doc.h = calcp->ed.lines;

  if (lines != calcp->ed.lines) set_sliders (window, VERTICAL, SLPOS | SLSIZE);

  if ((ret == ED_BUFFERCHANGED) && ! calcp->dirty)
  {
    calcp->dirty = TRUE;
    set_name (window);
  } /* if */

  if ((ret == ED_OK) || (ret == ED_BUFFERCHANGED)) return (TRUE);

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

