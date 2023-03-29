/*****************************************************************************
 *
 * Module : LIST.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 01.01.97
 *
 *
 * Description: This module implements the list window.
 *
 * History:
 * 01.01.97: Account definition can be printed directly by dragging to printer
 * 03.12.95: AccDefExec called in action_list
 * 16.09.95: Function text_extent moved to GLOBAL.C
 * 28.08.95: Calling of AccDefExec added
 * 17.07.95: Extra parameter added in calling v_execute
 * 09.07.95: Calling of AccDef functions added
 * 31.12.94: Using new function names of controls module
 * 27.07.94: SYSLIST_COLS increased
 * 08.07.94: Using listp->max_columns instead of window->doc.w when calling rec_to_line
 * 19.05.94: Problem with full text search in virtual tables fixed
 * 18.05.94: Function search_dialog made global
 * 10.05.94: Problem with full text search and only a few record fixed
 * 29.03.94: Calling v_text instead of v_gtext
 * 25.03.94: Variables show_info, show_top, and show_left are handled in wi_draw for immediately reaction
 * 23.03.94: Parameter cont in funtion list_search added
 * 20.03.94: Window is always redrawn completely in mlistsearch instead of scrolling
 * 17.03.94: Full text search capabilitied added
 * 14.03.94: Left header is redraw in mlistreverse
 * 12.03.94: Info line is shown only if show_info is TRUE
 * 10.03.94: Function list_newfont added
 * 06.03.94: Proportional fonts added
 * 10.02.94: Problem witgh deleting virtual table in descending order after scrolling fixed
 * 09.02.94: Function open_syslist added
 * 19.12.93: Number of records of original table is shown in info_table
 * 22.11.93: List window is opening larger without function keys
 * 04.11.93: Using fontdesc
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 20.10.93: Function new_index improved
 * 07.10.93: Background of dialog box is set according to sys_colors
 * 02.10.93: Multikey bitmap added
 * 30.09.93: Overflow in crt_list fixed (width is LONG)
 * 28.09.93: Comboboxes are owner drawn
 * 24.09.93: Function fix_iconbar added
 * 20.09.93: New combobox used
 * 11.09.93: MAX_LINES and MAX_COLUMNS removed
 * 09.09.93: Bug in displaying index combobox with system tables fixed
 * 05.09.93: Iconbar functionality added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "batch.h"
#include "calc.h"
#include "commdlg.h"
#include "controls.h"
#include "delete.h"
#include "desktop.h"
#include "dialog.h"
#include "impexp.h"
#include "lprint.h"
#include "mask.h"
#include "menu.h"
#include "mimpexp.h"
#include "qbe.h"
#include "report.h"
#include "resource.h"
#include "selwidth.h"
#include "trash.h"

#include "export.h"
#include "list.h"

/****** DEFINES **************************************************************/

/* [GS] 5.1e Start not ready
#define KIND        (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|ICONIFIER)
*/
/* Ende; alt:*/
#define KIND        (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
/* */
#define FLAGS       (WI_CURSKEYS)
#define XFAC        gl_wbox             /* X-Faktor */
#define YFAC        gl_hbox             /* Y-Faktor */
#define XUNITS      1                   /* X-Einheiten fr Scrolling */
#define YUNITS      1                   /* Y-Einheiten fr Scrolling */
#define XOFFSET     (2 * gl_wbox)       /* X-Offset Work/Scrollbereich */
#define YOFFSET     window->yfac        /* Y-Offset Work/Scrollbereich */
#define INITX       (20 * gl_wbox)      /* X-Anfangsposition */
#define INITY       ( 6 * gl_hbox + 10) /* Y-Anfangsposition */
#define INITW       (58 * gl_wbox)      /* Anfangsbreite in Pixel */
#define INITH       (12 * gl_hbox)      /* Anfangsh”he in Pixel */
#define MILLI       0                   /* Millisekunden fr Zeitablauf */

#define SYSLIST_LINES  8                /* maximum lines for syslist window */
#define SYSLIST_COLS  50                /* maximum cols for syslist window */

#define MAX_MOVE    1000                /* maximum lines to move when updating window */
#define MAX_OBJS     100                /* maximum number of objects to select */

#define VISIBLE        6                /* number of visible indexes */

#define ADD_LINES      4                /* additional lines per record */

#define OP_NOP         0                /* no operation */
#define OP_DELCOL      1                /* operation delete column */
#define OP_INSCOL      2                /* operation insert column */
#define OP_SIZECOL     3                /* operation size column */
#define OP_MOVECOL     4                /* operation move column */
#define OP_DELREC      5                /* operation delete record */
#define OP_INSREC      6                /* operation insert record */

#define LINX(window, listp, i)  ((listp->first_line + (i)) % listp->max_lines)
#define CINX(window, listp, i)  (LINX (window, listp, i) * (listp->max_columns + 1))

/****** TYPES ****************************************************************/

typedef struct
{
  DB       *db;                         /* database */
  WORD     table;                       /* table of database */
  WORD     inx;                         /* index of list */
  WORD     dir;                         /* direction of list */
  CURSOR   *cursor;                     /* cursor for access */
  WORD     max_lines;                   /* maximum number of lines in text buffer */
  LONG     max_columns;                 /* maximum number of columns in text buffer */
  WORD     first_line;                  /* number of first absolute valid line in text buffer */
  WORD     valid_line;                  /* number of first relative valid line in window */
  WORD     lines;                       /* number of lines in text buffer */
  WORD     cols;                        /* number of actual cols */
  WORD     *columns;                    /* column order */
  WORD     *colwidth;                   /* column width */
  LONG     *recaddr;                    /* addresses of records in buffer */
  BYTE     *text;                       /* text of lines */
  BYTE     *colheader;                  /* column header */
  FONTDESC fontdesc;                    /* actual font */
  WORD     iconheight;                  /* height of iconbar */
  WORD     operation;                   /* last operation on window */
  WORD     oldpos;                      /* old position for undo */
  WORD     oldcol;                      /* old column for undo */
  WORD     oldwidth;                    /* old width for undo */
  LONG     oldaddr;                     /* last address deleted */
  STRING   queryname;                   /* name of query */
  BOOLEAN  close_as_icon;               /* close window as icon */
} LIST_SPEC;

/****** VARIABLES ************************************************************/

LOCAL BOOLEAN result;                   /* result of do_search */
LOCAL WINDOWP win;                      /* list window for remsel */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    fill_rect     _((WINDOWP window, RECT *rc, WORD color, BOOLEAN show_pattern));
LOCAL VOID    draw_3d_rect  _((WINDOWP window, RECT *rc, WORD color_highlight, WORD color_shadow));
LOCAL VOID    draw_border   _((WINDOWP window, RECT *rc));

LOCAL VOID    fix_iconbar   _((WINDOWP window));
LOCAL VOID    new_index     _((WINDOWP window, MKINFO *mk));
LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    set_info      _((WINDOWP window));

LOCAL VOID    objop         _((WINDOWP window, SET objs, WORD action, WINDOWP actwin));
LOCAL VOID    correct       _((WINDOWP window, LONG more));
LOCAL BOOLEAN edit_list     _((DB *db, WORD table, WORD inx, WORD dir));

LOCAL VOID    get_rect      _((WINDOWP window, WORD obj, RECT *rect));
LOCAL VOID    drag_objs     _((WINDOWP window, WORD obj, SET objs));
LOCAL VOID    drag_column   _((WINDOWP window, WORD col, RECT *rect, MKINFO *mk));
LOCAL VOID    drag_colsep   _((WINDOWP window, WORD col, RECT *rect, BOOLEAN with_hand));
LOCAL WORD    calc_col      _((WINDOWP window, WORD mox, RECT *r, BOOLEAN *sep));
LOCAL VOID    drag_line     _((RECT *r, RECT *diff, RECT *bound, WORD x_raster, WORD y_raster, WORD width, LONG reswidth));
LOCAL VOID    draw_line     _((RECT *r, RECT *diff));
LOCAL VOID    move_col      _((LIST_SPEC *listp, WORD src, WORD dst));
LOCAL VOID    update_col    _((WINDOWP window, BOOLEAN fill_buffer));
LOCAL VOID    invert_col    _((WINDOWP window, RECT *inv));
LOCAL VOID    fill_select   _((WINDOWP window, SET objs, RECT *area));
LOCAL VOID    invert_objs   _((WINDOWP window, SET objs));
LOCAL VOID    rubber_objs   _((WINDOWP window, MKINFO *mk));
LOCAL VOID    do_fill       _((WINDOWP window, SET objs));
LOCAL VOID    do_addicon    _((WINDOWP window, SET objs, WORD icon));
LOCAL VOID    do_addwind    _((WINDOWP window, SET objs, WINDOWP dest_window));

LOCAL VOID    click_search  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_search    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    check_search  _((WINDOWP window));

LOCAL VOID    click_remsel  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_remsel    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    update_menu   _((WINDOWP window));
LOCAL VOID    handle_menu   _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow));
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

GLOBAL BOOLEAN init_list ()

{
  WORD obj;

  obj = ROOT;

  do
  {
    if (is_type (listicon, obj, G_BUTTON))
      listicon [obj].ob_y = 4;
  } while (! is_flags (listicon, obj++, LASTOB));

  listicon [ROOT].ob_width   = listicon [LCINFO].ob_width = listicon [LCBOX].ob_width = desk.w;
  listicon [LCBOX].ob_height = listicon [LCASC].ob_y + listicon [LCASC].ob_height + 4;
  listicon [LCINFO].ob_height++;
  listicon [LCBOX].ob_y      = listicon [LCINFO].ob_height;
  listicon [ROOT].ob_height  = listicon [LCINFO].ob_height + listicon [LCBOX].ob_height;
  listicon [LCINDEX].ob_y    = (listicon [LCBOX].ob_height - listicon [LCINDEX].ob_height) / 2;
  listicon [LCORDER].ob_y    = (listicon [LCINFO].ob_height - listicon [LCORDER].ob_height) / 2;

  ListBoxSetCallback (listicon, LCINDEX, callback);
  ListBoxSetStyle (listicon, LCINDEX, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (listicon, LCINDEX, gl_wbox / 2);

  set_str (listsrch, LISEARCH, "");

  return (TRUE);
} /* init_list */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_list ()

{
  return (TRUE);
} /* term_list */

/*****************************************************************************/
/* Iconbehandlung                                                            */
/*****************************************************************************/

GLOBAL BOOLEAN icons_list (src_obj, dest_obj)
WORD src_obj, dest_obj;

{
  VTABLE    *vtablep;
  LONG      more;
  WINDOWP   window;
  LIST_SPEC *listp;

  if ((ITABLE <= dest_obj) && (dest_obj < IPROCESS))
  {
    vtablep = VTABLEP (icon_info [src_obj - ITABLE].table);
    more    = add_virtual (icon_info [dest_obj - ITABLE].table, vtablep->recs, vtablep->recaddr);

    if (more > 0)
    {
      window         = icon_info [dest_obj - ITABLE].window;
      window->doc.h += more;            /* correct document height */
      listp          = (LIST_SPEC *)window->special;
      if (listp->dir == DESCENDING) correct (window, more);
    } /* if */

    return (TRUE);
  } /* if */

  if ((IPROCESS <= dest_obj) && (dest_obj < ITRASH)) return (FALSE);

  switch (dest_obj)
  {
    case ITRASH   : action_list (OBJ_DEL, &icon_info [src_obj - ITABLE], NULL);
                    break;
    case IPRINTER : action_list (OBJ_PRINT, &icon_info [src_obj - ITABLE], NULL);
                    break;
    case IDISK    : action_list (OBJ_DISK, &icon_info [src_obj - ITABLE], NULL);
                    break;
    case ICLIPBRD : action_list (OBJ_CLIP, &icon_info [src_obj - ITABLE], NULL);
                    break;
  } /* switch */

  return (TRUE);
} /* icons_list */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_list (obj, menu, icon, db, table, inx, dir, cols, columns, colwidth, fontdesc, size, name)
OBJECT   *obj, *menu;
WORD     icon;
DB       *db;
WORD     table, inx, dir, cols, *columns, *colwidth;
FONTDESC *fontdesc;
RECT     *size;
BYTE     *name;

{
  WINDOWP   window;
  WORD      num, diff, max_lines, func_height, i;
  LONG      maxcols, width;
  WORD      char_width, char_height, cell_width, cell_height;
  LIST_SPEC *listp;
  BYTE      *memory;
  RECT      r;
  STRING    s;

  listp = mem_alloc ((LONG)sizeof (LIST_SPEC));
  if (listp == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    mem_free (columns);
    set_meminfo ();
    return (NULL);
  } /* if */

  mem_set (listp, 0, sizeof (LIST_SPEC));

  listp->cursor = db_newcursor (db->base);

  if (listp->cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    mem_free (columns);
    mem_free (listp);
    set_meminfo ();
    return (NULL);
  } /* if */

  v_initcursor (db, table, inx, dir, listp->cursor);
  text_default (vdi_handle);
  vst_font (vdi_handle, fontdesc->font);
  vst_point (vdi_handle, fontdesc->point, &char_width, &char_height, &cell_width, &cell_height);
  vst_effects (vdi_handle, (fontdesc->effects | TXT_THICKENED) & ~ TXT_SKEWED);

  text_extent (vdi_handle, "x", FALSE, &cell_width, &cell_height);

  if (fontdesc->effects & TXT_SKEWED)
    cell_width++;

  for (i = 0, maxcols = 0; i < cols; i++)
  {
    width = def_width (db, rtable (table), columns [i]);
    if ((rtable (table) == SYS_DELETED) && (columns [i] == 2)) width = - (MAX_TABLENAME + 1);
    maxcols += abs (width);
  } /* for */

  func_height = hide_func ? desktop [FKEYS].ob_height : 0;
  max_lines   = desk.h / (cell_height + ADD_LINES);
  memory      = mem_alloc (max_lines * sizeof (LONG) + 
                          (maxcols + 1) * max_lines +
                          (maxcols + 1));

  if (memory == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    db_freecursor (db->base, listp->cursor);
    mem_free (columns);
    mem_free (listp);
    set_meminfo ();
    return (NULL);
  } /* if */

  listp->db           = db;
  listp->table        = table;
  listp->inx          = inx;
  listp->dir          = dir;
  listp->max_lines    = max_lines;
  listp->max_columns  = maxcols;
  listp->first_line   = 0;
  listp->valid_line   = max_lines;
  listp->cols         = cols;
  listp->columns      = columns;
  listp->colwidth     = colwidth;
  listp->recaddr      = (LONG *)memory;
  memory             += max_lines * sizeof (LONG);
  listp->text         = memory;
  memory             += (maxcols + 1) * max_lines;
  listp->colheader    = memory;
  listp->fontdesc     = *fontdesc;
  listp->iconheight   = listicon [LCBOX].ob_height + (show_info ? listicon [LCINFO].ob_height : 0) + 1;

  build_colheader (db, table, cols, columns, colwidth, maxcols, listp->colheader);

  num    = num_windows (CLASS_LIST, SRCH_ANY, NULL);
  window = create_window (KIND, CLASS_LIST);

  if (window != NULL)
  {
    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = get_width (cols, colwidth);
    window->doc.h     = num_keys (db, table, inx);
    window->xfac      = cell_width;
    window->yfac      = cell_height + ADD_LINES;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->xscroll   = show_left ? window->xfac / 2 - 1 + ((INT)strlen (ltoa (window->doc.h, s, 10)) + 1) * window->xfac : 0;
    window->yscroll   = show_top ? window->yfac : 0;
    window->scroll.x  = (size != NULL) ? size->x * gl_wbox : INITX + num * window->xfac + window->xscroll;
    window->scroll.y  = (size != NULL) ? size->y * gl_hbox : INITY + num * window->yfac - (gl_hbox - cell_height) + listp->iconheight;
    window->scroll.w  = (size != NULL) ? size->w * window->xfac : (desk.x + desk.w - window->scroll.x - 4 * gl_wbox) / window->xfac * window->xfac;
    window->scroll.h  = (size != NULL) ? size->h * window->yfac : (desk.y + desk.h - window->scroll.y - 5 * gl_hbox + func_height) / window->yfac * window->yfac;
    window->work.x    = window->scroll.x - window->xscroll;
    window->work.y    = window->scroll.y - window->yscroll - listp->iconheight;
    window->work.w    = window->scroll.w + window->xscroll;
    window->work.h    = window->scroll.h + window->yscroll + listp->iconheight;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)listp;
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
    window->objop     = wi_objop;
    window->drag      = wi_drag;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = wi_edit;
    window->showinfo  = info_list;
    window->showhelp  = help_list;

    if (window->scroll.h == 0)                  /* there must be at leat one line of scrolling area */
    {
      window->scroll.h += window->yfac;
      window->work.h   += window->yfac;
    } /* if */

    diff = window->work.y - (desk.y + 3 * gl_hbox - 4);
    if (diff < 0)                     /* window y position to small */
    {
      window->scroll.y -= diff;       /* increase y position */
      window->work.y   -= diff;
    } /* if */

    diff = listp->max_lines - window->scroll.h / window->yfac;
    if (diff < 0)                                       /* too many lines */
    {
      window->scroll.h += diff * window->yfac;          /* make window smaller */
      window->work.h   += diff * window->yfac;
    } /* if */

    wind_calc (WC_BORDER, window->kind,
             window->work.x, window->work.y, window->work.w, window->work.h,
             &r.x, &r.y, &r.w, &r.h);

    diff = desk.y - r.y;
    if (diff > 0)
    {
      window->scroll.y += (diff + 1) & 0xFFFE;
      window->work.y   += (diff + 1) & 0xFFFE;
    } /* if */

    dbtbl_name (db, table, window->name);

    if ((name != NULL) && (*name != EOS))
    {
      strcpy (listp->queryname, name);
      sprintf (s, "(%s) ", name);
      strcat (window->name, s);

      if (strcmp (name, "!") == 0)	/* autoquery */
        listp->queryname [0] = EOS;
    } /* if */

    set_info (window);
    set_meminfo ();
  } /* if */

  return (window);
} /* crt_list */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_list (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;

  if ((window = search_window (CLASS_LIST, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    window = search_window (CLASS_LIST, SRCH_CLOSED, icon);
    ok     = window != NULL;

    if (ok)
    {
      ok = open_window (window);

      if (ok)
      {
        window->flags &= ~ WI_RESIDENT; /* open window will be destroyed on close */
        window->icon   = NIL;
      } /* if */
    } /* if */
  } /* else */

  return (ok);
} /* open_list */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_list (window, icon)
WINDOWP window;
WORD    icon;

{
  LIST_SPEC *listp;
  LONGSTR   s;
  STRING    name, recs;

  if (icon != NIL)
    window = search_window (CLASS_LIST, SRCH_ANY, icon);

  if (window != NULL)
  {
    listp = (LIST_SPEC *)window->special;

    table_name (listp->db, listp->table, name);

    if (VTBL (listp->table))
      sprintf (recs, "%ld/%ld", window->doc.h, num_keys (listp->db, rtable (listp->table), 0));
    else
      sprintf (recs, "%ld", window->doc.h);

    sprintf (s, alerts [ERR_INFOTABLE], listp->db->base->basename, name, recs, window->doc.y);
    open_alert (s);
  } /* if */

  return (window != NULL);
} /* info_list */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_list (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HLIST));
} /* help_list */

/*****************************************************************************/

GLOBAL BOOLEAN print_list (db, table, inx, dir, cols, columns, colwidth, device, fontdesc, size, filename, minimize)
DB       *db;
WORD     table, inx, dir, cols, *columns, *colwidth, device;
FONTDESC *fontdesc;
RECT     *size;
BYTE     *filename;
BOOLEAN  minimize;

{
  return (l_print (db, table, inx, dir, cols, columns, colwidth, device, fontdesc, size, filename, minimize));
} /* print_list */

/*****************************************************************************/

GLOBAL BOOLEAN close_list (db)
DB *db;

{
  WORD      num, i;
  LIST_SPEC *listp;
  RECT      r;
  WINDOWP   window;
  WINDOWP   windows [MAX_TBLICONS + MAX_GEMWIND];

  num = num_windows (CLASS_LIST, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window = windows [i];

    listp = (LIST_SPEC *)window->special;

    if (listp->db == db)
    {
      if (window->icon != NIL)
      {
        objc_rect (desktop, window->icon, &r, TRUE);
        do_flags (desktop, window->icon, HIDETREE);
        undo_state (desktop, window->icon, SELECTED);
        redraw_window (find_desk (), &r);

        if (sel_window == find_desk ())         /* deleted icon is no longer in selected set */
        {
          setexcl (sel_objs, window->icon);
          if (setcmp (sel_objs, NULL)) sel_window = NULL;
        } /* if */
      } /* if */

      delete_window (window);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_list */

/*****************************************************************************/

GLOBAL BOOLEAN open_syslist (DB *db, WORD table, FONTDESC *fontdesc, RECT *size, BOOLEAN minimize)
{
  BOOLEAN    ok;
  WINDOWP    window, deskwin;
  LIST_SPEC  *listp;
  RECT       r;
  WORD       num, i;
  WINDOWP    windows [256];
  WORD       cols, *columns, *colwidth;
  WORD       diff;
  TABLE_INFO tinf;

  num = num_windows (CLASS_LIST, SRCH_ANY | SRCH_SUB, windows);

  for (i = 0, window = NULL; (i < num) && (window == NULL); i++)
  {
    listp = (LIST_SPEC *)windows [i]->special;
    if ((listp->db == db) && (listp->table == table))
      window = windows [i];
  } /* if, for */

  if (window != NULL)
  {
    ok = TRUE;

    if (window->opened > 0)
      if (minimize)
        miconify (window);
      else
      {
        window->flags &= ~ WI_LOCKED;   /* in case I've been called from modeless dialog box */
        top_window (window);
      } /* else */
    else
      if (! minimize)
        ok = open_window (window);
  } /* if */
  else
  {
    if ((window == NULL) && (db != NULL))
    {
      db_tableinfo (db->base, table, &tinf);
      cols    = tinf.cols;
      columns = (WORD *)mem_alloc (2L * cols * sizeof (WORD));  /* mem_free in module list */

      if (columns == NULL)
      {
        hndl_alert (ERR_NOMEMORY);
        return (FALSE);
      } /* if */

      set_meminfo ();

      colwidth = columns + cols;
      cols     = init_columns (db, table, cols, columns, colwidth);
      window   = crt_list (NULL, NULL, NIL, db, table, 1, ASCENDING, cols, columns, colwidth, fontdesc, size, NULL);

      if (window != NULL)
      {
        switch (table)
        {
          case SYS_CALC    : window->subclass = CLASS_CLIST; break;
          case SYS_QUERY   : window->subclass = CLASS_QLIST; break;
          case SYS_REPORT  : window->subclass = CLASS_RLIST; break;
          case SYS_BATCH   : window->subclass = CLASS_BLIST; break;
          case SYS_ACCOUNT : window->subclass = CLASS_ALIST; break;
        } /* switch */

        if (size == NULL)
        {
          diff = SYSLIST_COLS - window->scroll.w / window->xfac;
          if (diff < 0)
          {
            window->scroll.w += diff * window->xfac;          /* resize window */
            window->work.w   += diff * window->xfac;
          } /* if */

          diff = SYSLIST_LINES - window->scroll.h / window->yfac;
          if (diff < 0)                                       /* too many lines */
          {
            window->scroll.h += diff * window->yfac;          /* make window smaller */
            window->work.h   += diff * window->yfac;
          } /* if */
        } /* if */

      } /* if */
    } /* if */

    ok = window != NULL;

    if (ok)
    {
      if (minimize)
        miconify (window);
      else
      {
        ok = open_window (window);

        if (ok)
        {
          if (window->icon != NIL)
          {
            deskwin = find_desk ();

            if (deskwin != NULL)
            {
              get_border (deskwin, window->icon, &r);
              do_flags (desktop, window->icon, HIDETREE);
              redraw_window (deskwin, &r);

              if (sel_window == deskwin)
                if (setin (sel_objs, window->icon))
                {
                  flip_state (desktop, window->icon, SELECTED);
                  setexcl (sel_objs, window->icon); /* opened icon is no longer in selected set */
                  if (setcmp (sel_objs, NULL)) sel_window = NULL;
                } /* if, if */
            } /* if */
          } /* if */

          window->flags &= ~ WI_RESIDENT; /* open window will be destroyed on close */
          window->icon   = NIL;
        } /* if */
      } /* else */
    } /* if */
  } /* else */

  return (ok);
} /* open_syslist */

/*****************************************************************************/

GLOBAL VOID updt_lsall (db, table, only_real, updt_trash)
DB      *db;
WORD    table;
BOOLEAN only_real, updt_trash;

{
  WORD      num, i;
  LIST_SPEC *listp;
  WINDOWP   window;
  WINDOWP   windows [MAX_TBLICONS + MAX_GEMWIND];

  busy_mouse ();

  num = num_windows (CLASS_LIST, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window = windows [i];

    listp = (LIST_SPEC *)window->special;

    if ((listp->db == db) &&
        (rtable (listp->table) == rtable (table)) &&
        (! only_real || ! VTBL (listp->table))) updt_lswin (window);
  } /* for */

  if (updt_trash && (db == actdb))
    if ((window = search_window (CLASS_TRASH, SRCH_ANY, ITRASH)) != NULL)
      updt_lswin (window);

  arrow_mouse ();
} /* updt_lsall */

/*****************************************************************************/

GLOBAL VOID updt_lswin (window)
WINDOWP window;

{
  LIST_SPEC *listp;
  LONG      numkeys, y, maxpos, forw, back;
  WORD      h;

  if (window != NULL)
  {
    listp   = (LIST_SPEC *)window->special;
    y       = window->doc.y;
    h       = window->scroll.h / window->yfac;
    numkeys = num_keys (listp->db, listp->table, listp->inx);
    maxpos  = numkeys - h;

    if (y > maxpos) y = maxpos;
    if (y < 0) y = 0;

    forw = y;
    back = numkeys - y + 1;

    if ((forw < MAX_MOVE) || (back < MAX_MOVE)) /* doesn't cost a lot of time */
      if (forw < back)
      {
        v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);
        if (forw != 0) v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * forw);
      } /* if */
      else
      {
        v_initcursor (listp->db, listp->table, listp->inx, - listp->dir, listp->cursor);
        if (back != 0) v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- back));
      } /* else */
    else
      v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- listp->lines));

    listp->lines  = 0;
    window->doc.y = y;
    window->doc.h = numkeys;

    if (window->opened)
    {
      set_sliders (window, VERTICAL, SLPOS + SLSIZE);
      set_redraw (window, &window->work);
    } /* if */
  } /* if */
} /* updt_lswin */

/*****************************************************************************/

GLOBAL VOID get_listinfo (window, iconinfo, name)
WINDOWP   window;
ICON_INFO *iconinfo;
BYTE      *name;

{
  LIST_SPEC *listp;

  listp            = (LIST_SPEC *)window->special;
  iconinfo->db     = listp->db;
  iconinfo->table  = listp->table;
  iconinfo->window = window;

  if (name != NULL)
    if (listp->queryname [0] != EOS)
      strcpy (name, listp->queryname);
    else
      table_name (listp->db, listp->table, name);
} /* get_listinfo */

/*****************************************************************************/

GLOBAL VOID set_qname (window, name)
WINDOWP window;
BYTE    *name;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  strcpy (listp->queryname, name);
  listp->close_as_icon = TRUE;          /* set_qname is only called by fill_virtual */
} /* set_qname */

/*****************************************************************************/

GLOBAL VOID get_qname (window, name)
WINDOWP window;
BYTE    *name;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  strcpy (name, listp->queryname);
  listp->close_as_icon = TRUE;          /* get_qname is only called by miconify */
} /* get_qname */

/*****************************************************************************/

GLOBAL LONG list_addr (window, obj)
WINDOWP window;
WORD    obj;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  return (listp->recaddr [LINX (window, listp, obj)]);
} /* list_addr */

/*****************************************************************************/

GLOBAL VOID action_list (action, iconinfo, actwin)
WORD      action;
ICON_INFO *iconinfo;
WINDOWP   actwin;

{
  WINDOWP   window;
  LIST_SPEC *listp;
  WORD      *columns, *colwidth;
  BOOLEAN   ok, needcols;
  FULLNAME  filename;
  WORD      saveformat;

  window   = iconinfo->window;
  listp    = (LIST_SPEC *)window->special;
  needcols = (action != OBJ_DEL) && (action != OBJ_UNDEL) && (action != OBJ_EDIT) && (action != OBJ_REP) && (action != OBJ_CALC) && (action != OBJ_ACC);
  columns  = needcols ? (WORD *)mem_alloc (2L * listp->cols * sizeof (WORD)) : NULL;  /* mem_free in module process */

  if (needcols && (columns == NULL))
    hndl_alert (ERR_NOMEMORY);
  else
  {
    set_meminfo ();

    if (needcols)
    {
      colwidth = columns + listp->cols;
      mem_move (columns, listp->columns, listp->cols * sizeof (WORD));
      mem_move (colwidth, listp->colwidth, listp->cols * sizeof (WORD));
    } /* if */

    switch (action)
    {
      case OBJ_DISK  : ok = print_list (listp->db, listp->table, listp->inx, listp->dir, listp->cols, columns, colwidth, DEV_DISK, &fontdesc, NULL, NULL, minimize);
                       break;
      case OBJ_PRINT : ok = print_list (listp->db, listp->table, listp->inx, listp->dir, listp->cols, columns, colwidth, DEV_PRINTER, &fontdesc, NULL, NULL, minimize);
                       break;
      case OBJ_EXP   : ok = exp_list (listp->db, listp->table, listp->inx, listp->dir, listp->cols, columns, colwidth, NULL, minimize);
                       break;
      case OBJ_IMP   : ok = imp_list (listp->db, rtable (listp->table), listp->cols, columns, colwidth, NULL, minimize);
                       break;
      case OBJ_DEL   : ok = delete_list (listp->db, listp->table, listp->inx, listp->dir, minimize, TRUE);
                       break;
      case OBJ_EDIT  : ok = edit_list (listp->db, listp->table, listp->inx, listp->dir);
                       break;
      case OBJ_REP   : if (actwin == NULL) actwin = find_top ();
                       ok = rep_exec (actwin, listp->db, listp->table, listp->inx, listp->dir);
                       break;
      case OBJ_CLIP  : strcpy (filename, scrapdir);
                       strcat (filename, "SCRAP.TXT");
                       saveformat            = impexpcfg.asciiformat;
                       impexpcfg.asciiformat = EXASCII;
                       ok                    = exp_list (listp->db, listp->table, listp->inx, listp->dir, listp->cols, columns, colwidth, filename, minimize);
                       impexpcfg.asciiformat = saveformat;
                       break;
      case OBJ_CALC  : if (actwin == NULL) actwin = find_top ();
                       ok = calc_exec (actwin, listp->db, listp->table, listp->inx, listp->dir);
                       break;
      case OBJ_ACC   : if (actwin == NULL) actwin = find_top ();
                       ok = AccDefExec (actwin, listp->db, listp->table, listp->inx, listp->dir);
                       break;
    } /* switch */

    if (! ok)
    {
      mem_free (columns);
      set_meminfo ();
    } /* if */
  } /* else */
} /* action_list */

/*****************************************************************************/

GLOBAL VOID list_newfont (WINDOWP window)
{
  LIST_SPEC *listp;
  WORD      char_width, char_height, cell_width, cell_height;
  STRING    s;

  listp = (LIST_SPEC *)window->special;

  if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HFONT), 0L, vdi_handle, &listp->fontdesc))
  {
    text_default (vdi_handle);
    vst_font (vdi_handle, listp->fontdesc.font);
    vst_point (vdi_handle, listp->fontdesc.point, &char_width, &char_height, &cell_width, &cell_height);
    vst_effects (vdi_handle, (listp->fontdesc.effects | TXT_THICKENED) & ~ TXT_SKEWED);
    text_extent (vdi_handle, "x", FALSE, &cell_width, &cell_height);
    ltoa (window->doc.h, s, 10);

    if (listp->fontdesc.effects & TXT_SKEWED)
      cell_width++;

    window->xfac     = cell_width;
    window->yfac     = cell_height + ADD_LINES;
    window->xscroll  = (window->xscroll > 0) ? window->xfac / 2 - 1 + ((INT)strlen (s) + 1) * window->xfac : 0;
    window->yscroll  = (window->yscroll > 0) ? window->yfac : 0;
    window->scroll.x = window->work.x + window->xscroll;
    window->scroll.y = window->work.y + window->yscroll + listp->iconheight;
    window->scroll.w = window->work.w - window->xscroll;
    window->scroll.h = window->work.h - window->yscroll - listp->iconheight;

    set_redraw (window, &window->work);
    set_sliders (window, HORIZONTAL | VERTICAL, SLPOS | SLSIZE);
    update_col (window, FALSE);
  } /* if */
} /* list_newfont */

/*****************************************************************************/

GLOBAL VOID list_reverse (window)
WINDOWP window;

{
  LIST_SPEC *listp;
  RECT      r;

  listp = (LIST_SPEC *)window->special;

  v_initcursor (listp->db, listp->table, listp->inx, - listp->dir, listp->cursor);

  if (sel_window == window) unclick_window (window);
  window->doc.y = 0;                            /* go to beginning */
  listp->dir    = -listp->dir;
  listp->lines  = 0;                            /* invalidate text buffer */

  listicon->ob_x = window->work.x;
  listicon->ob_y = window->work.y;

  set_rbutton (listicon, (listp->dir == ASCENDING) ? LCASC : LCDESC, LCASC, LCDESC);
  draw_win_obj (window, listicon, LCASC);
  draw_win_obj (window, listicon, LCDESC);

  r    = window->scroll;
  r.x -= window->xscroll;				/* need to redraw header also */
  r.w += window->xscroll;

  set_info (window);
  set_sliders (window, VERTICAL, SLPOS);
  set_redraw (window, &r);
} /* list_reverse */

/*****************************************************************************/

GLOBAL VOID list_search (window, cont)
WINDOWP window;
BOOLEAN cont;

{
  LIST_SPEC  *listp;
  BYTE       *p;
  STRING     s, col;
  KEY        key, keyval;
  TABLE_INFO t_inf;
  FIELD_INFO f_inf;
  INDEX_INFO i_inf;
  WORD       num_cols, i, selected;
  LONG       newpos, maxpos, moved;
  CURSOR     cursor;
  LONG       addr;
  BOOLEAN    found, ready, asc;

  get_ptext (listsrch, LISEARCH, s);

  if ((s [0] == EOS) || ! get_checkbox (listsrch, LITEXT))	/* no search criterion or no full text search: continue searching not allowed */
    cont = FALSE;

  listp    = (LIST_SPEC *)window->special;
  selected = FAILURE;

  if (window == sel_window)
  {
    for (i = 0; i < MAX_OBJS; i++)
      if (setin (sel_objs, i))
      {
        selected = i;
        break;
      } /* if, for */

    unclick_window (window);
  } /* if */

  if (cont || search_dialog (listp->db, listp->table, listp->inx))
  {
    get_ptext (listsrch, LISEARCH, s);

    if (get_checkbox (listsrch, LITEXT))		/* full text search */
    {
      busy_mouse ();

      asc   = get_rbutton (listsrch, LIASC) == LIASC;
      addr  = list_addr (window, (selected != FAILURE) ? selected : asc ? 0 : min (listp->lines, window->scroll.h / window->yfac) - 1);

      if (VTBL (listp->table))
      {
        for (i = listp->lines - 1, moved = 0; (i >= 0) && (addr != listp->recaddr [LINX (window, listp, i)]); i--)
        {
          if (listp->dir == ASCENDING)
            moved--;
          else
            moved++;

          v_movecursor (listp->db, listp->cursor, - listp->dir);
        } /* for */

        moved -= listp->dir;
      } /* if */
      else
        moved = db_locateaddr (listp->db->base, listp->cursor, - listp->dir, addr) - listp->dir;

      if (! v_movecursor (listp->db, listp->cursor, - listp->dir * (asc ? 1 : -1)))
        v_initcursor (listp->db, listp->table, listp->inx, listp->dir * (asc ? 1 : -1), listp->cursor);

      window->doc.y += listp->lines + moved * listp->dir;
      listp->lines   = 0;
      found          = FALSE;
      ready          = FALSE;

      if (asc)
        window->doc.y--;				/* doc.y will be corrected after next v_movecursor */
      else
        window->doc.y++;				/* doc.y will be corrected after next v_movecursor */

      v_tableinfo (listp->db, listp->table, &t_inf);

      while (! ready && ! found)
      {
        ready = ! v_movecursor (listp->db, listp->cursor, asc ? listp->dir : - listp->dir);

        if (! ready)
          if (asc)
            window->doc.y++;
          else
            window->doc.y--;

        if (! ready)
          if (window->doc.y % 100 == 0)
            if (esc_pressed ())
              ready = TRUE;

        if (! ready)
          ready = ! v_read (listp->db, listp->table, listp->db->buffer, listp->cursor, 0L, FALSE);

        if (selected != FAILURE)				/* skip first try */
          selected = FAILURE;
        else
          if (! ready)
            for (i = 1; (i < t_inf.cols) && ! found; i++)
            {
              get_ptext (listsrch, LISEARCH, s);
              db_fieldinfo (listp->db->base, rtable (listp->table), i, &f_inf);

              if (HASWILD (f_inf.type))
                p = (BYTE *)listp->db->buffer + f_inf.addr;
              else
              {
                if (listp->db->format != NULL)
                  if ((f_inf.type == TYPE_DATE) || (f_inf.type == TYPE_TIME) || (f_inf.type == TYPE_TIMESTAMP))
                    if (! format2str (f_inf.type, s, listp->db->format [f_inf.format]))
                      get_ptext (listsrch, LISEARCH, s);

                p = col;
                bin2str (f_inf.type, (BYTE *)listp->db->buffer + f_inf.addr, col);
              } /* else */

              if (HASWILD (f_inf.type))
                if (! get_checkbox (listsrch, LICASE))
                {
                  str_upper (s);
                  str_upper (p);
                } /* if, if */

              if (str_match (s, p) == 0)
                found = TRUE;
            } /* for, if, else */
      } /* while */

      if (! v_movecursor (listp->db, listp->cursor, - listp->dir))
        v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);

      if (! found)
      {
        beep ();
        set_rbutton (listsrch, asc ? LIDESC : LIASC, LIASC, LIDESC);
      } /* if */
      else
      {
        maxpos     = window->doc.h - window->scroll.h / window->yfac;
        sel_window = window;

        if (window->doc.y <= maxpos)
          setincl (sel_objs, 0);
        else
          setincl (sel_objs, (WORD)window->doc.y - ((maxpos >= 0) ? maxpos : 0));
      } /* else */

      updt_lswin (window);
      arrow_mouse ();
    } /* if */
    else						/* key search */
      if (s [0] == '#')					/* jump search */
      {
        str2bin (TYPE_LONG, s + 1, &newpos);

        if ((s [1] == '+') || (s [1] == '-'))
          newpos += window->doc.y;
        else
          newpos--;

        maxpos = window->doc.h - window->scroll.h / window->yfac;

        if (newpos > maxpos) newpos = maxpos;
        if (newpos < 0) newpos = 0;
        window->flags |= WI_NOSCROLL;			/* so search dialog box doesn't scroll with window */
        if (window->arrow != NULL) (*window->arrow) (window, VERTICAL, window->doc.y, newpos);
        window->flags &= ~ WI_NOSCROLL;
      } /* if */
      else
        if (listp->inx > 0)
        {
          busy_mouse ();

          v_indexinfo (listp->db, listp->table, listp->inx, &i_inf);
          num_cols = i_inf.inxcols.size / sizeof (INXCOL);
          if (HASWILD (i_inf.type)) db_convstr (listp->db->base, s);

          if (num_cols == 1)
          {
            db_fieldinfo (listp->db->base, listp->table, i_inf.inxcols.cols [0].col, &f_inf);

            if (listp->db->format != NULL)
              format2str (i_inf.type, s, listp->db->format [f_inf.format]);
          } /* if */

          str2bin (i_inf.type, s, key);

          moved = 0;
          db_readcursor (listp->db->base, listp->cursor, keyval);
          found = db_keysearch (listp->db->base, listp->table, listp->inx, listp->dir, &cursor, key, 0L);
          addr  = db_readcursor (listp->db->base, &cursor, NULL);

          if (listp->dir == ASCENDING)
            if (cmp_vals (i_inf.type, key, keyval) > 0)
              moved = db_locateaddr (listp->db->base, listp->cursor, ASCENDING, addr) - 1;
            else
              moved = db_locateaddr (listp->db->base, listp->cursor, DESCENDING, addr) - 1;
          else
            if (cmp_vals (i_inf.type, key, keyval) < 0)
              moved = - db_locateaddr (listp->db->base, listp->cursor, DESCENDING, addr) - 1;
            else
              moved = - db_locateaddr (listp->db->base, listp->cursor, ASCENDING, addr) - 1;

          moved         += listp->lines;
          listp->lines   = 0;
          window->doc.y += moved;

          if (! db_movecursor (listp->db->base, listp->cursor, - listp->dir))
            v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);

          if (found)
          {
            maxpos     = window->doc.h - window->scroll.h / window->yfac;
            sel_window = window;

            if (window->doc.y <= maxpos)
              setincl (sel_objs, 0);
            else
              setincl (sel_objs, (WORD)window->doc.y - ((maxpos >= 0) ? maxpos : 0));
          } /* if */

          updt_lswin (window);
          arrow_mouse ();
        } /* if, else, else */
  } /* if */
} /* list_search */

/*****************************************************************************/

GLOBAL VOID list_remove (window)
WINDOWP window;

{
  LIST_SPEC *listp;
  WORD      i, j;
  LONG      indexes [MAX_OBJS];

  listp = (LIST_SPEC *)window->special;

  if (listp->dir == ASCENDING)
  {
    for (i = j = 0; i < MAX_OBJS; i++)
      if (setin (sel_objs, i))
        indexes [j++] = window->doc.y + i;
  } /* if */
  else
  {
    for (i = MAX_OBJS, j = 0; i >= 0; i--)
      if (setin (sel_objs, i))
        indexes [j++] = window->doc.h - window->doc.y - i - 1;
  } /* else */

  for (i = j - 1; i >= 0; i--)
    del_vtable (listp->table, indexes [i]);

  sel_window = NULL;
  setclr (sel_objs);
  updt_lswin (window);
} /* list_remove */

/*****************************************************************************/

GLOBAL VOID list_remsel (lwindow)
WINDOWP lwindow;

{
  WINDOWP    window;
  WORD       ret;
  BASE_INFO  base_info;
  TABLE_INFO table_info;
  FULLNAME   dbname;
  WORD       w;
  LIST_SPEC  *listp;
  LONG       to;

  win   = lwindow;
  listp = (LIST_SPEC *)lwindow->special;

  window = search_window (CLASS_DIALOG, SRCH_ANY, REMSEL);

  if (window == NULL)
  {
    form_center (remsel, &ret, &ret, &ret, &ret);
    window = crt_dialog (remsel, NULL, REMSEL, FREETXT (FREMSEL), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_remsel;
      window->key   = key_remsel;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (remsel, ROOT, EDITABLE);
      window->edit_inx = NIL;

      db_baseinfo (listp->db->base, &base_info);

      w = remsel [RMDBNAME].ob_width / gl_wbox;

      strcpy (dbname, base_info.basepath);
      strcat (dbname, base_info.basename);
      dbname [w] = EOS;
      set_str (remsel, RMDBNAME, dbname);

      v_tableinfo (listp->db, listp->table, &table_info);
      set_str (remsel, RMTABLE, table_info.name);

      to = lwindow->doc.y + lwindow->scroll.h / lwindow->yfac - 1;
      to = min (to, lwindow->doc.h - 1); /* there is at least one record */

      set_long (remsel, RMFROM, lwindow->doc.y);
      set_long (remsel, RMTO, to);
      undo_state (remsel, RMOK, DISABLED);
    } /* if */

    if (! open_dialog (REMSEL)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* list_remsel */

/*****************************************************************************/

GLOBAL BOOLEAN search_dialog (db, table, inx)
DB   *db;
WORD table, inx;

{
  WINDOWP    window;
  WORD       ret;
  BOOLEAN    ok;
  BASE_INFO  base_info;
  TABLE_INFO table_info;
  INDEX_INFO index_info;
  FULLNAME   dbname;
  WORD       w;

  result = FALSE;
  window = search_window (CLASS_DIALOG, SRCH_ANY, LISTSRCH);

  if (window == NULL)
  {
    form_center (listsrch, &ret, &ret, &ret, &ret);
    window = crt_dialog (listsrch, NULL, LISTSRCH, FREETXT (FLSTSRCH), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_search;
      window->key   = key_search;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (listsrch, ROOT, EDITABLE);
      window->edit_inx = NIL;

      db_baseinfo (db->base, &base_info);

      w = listsrch [LIDBNAME].ob_width / gl_wbox;

      strcpy (dbname, base_info.basepath);
      strcat (dbname, base_info.basename);
      dbname [w] = EOS;
      set_str (listsrch, LIDBNAME, dbname);

      db_tableinfo (db->base, rtable (table), &table_info);
      set_str (listsrch, LITABLE, table_info.name);

      if (VTBL (table) || (inx < 0))
      {
        set_str (listsrch, LIINDEX, "");
        set_checkbox (listsrch, LITEXT, TRUE);
        do_state (listsrch, LITEXT, DISABLED);
      } /* if */
      else
      {
        db_indexinfo (db->base, rtable (table), inx, &index_info);

        w = inxinfo [LIINDEX].ob_width / gl_wbox;
        index_info.indexname [w] = EOS;
        set_str (listsrch, LIINDEX, index_info.indexname);

        undo_state (listsrch, LITEXT, DISABLED);
      } /* else */

      check_search (window);
    } /* if */

    if (! open_dialog (LISTSRCH))
    {
      delete_window (window);
      undo_state (listsrch, LIINDEXL, DISABLED);
      undo_state (listsrch, LIINDEX, DISABLED);
      undo_state (listsrch, LICASE, DISABLED);
      undo_state (listsrch, LIDIR, DISABLED);
      undo_state (listsrch, LIASC, DISABLED);
      undo_state (listsrch, LIDESC, DISABLED);
      undo_state (listsrch, LIOK, DISABLED);
      do_state (listsrch, LIHELP, DISABLED);
      listsrch->ob_spec = (dlg_colors < 16) ? 0x00021100L : 0x00011170L | sys_colors [COLOR_DIALOG];
      result = hndl_dial (listsrch, 0, FALSE, TRUE, NULL, &ok) == LIOK;
      listsrch->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
      undo_state (listsrch, LIHELP, DISABLED);
    } /* if */
  } /* if */

  return (result);
} /* search_dialog */

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

LOCAL VOID fix_iconbar (WINDOWP window)
{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  listicon->ob_x              = window->work.x;
  listicon->ob_y              = window->work.y;
  listicon [LCORDER].ob_width = window->work.w - 2 * gl_wbox + 2;

  strcpy (get_str (listicon, LCORDER), window->info);

  if (VTBL (listp->table) || (listp->table < NUM_SYSTABLES))
  {
    do_state (listicon, LCINDEX, DISABLED);

    ListBoxSetCount (listicon, LCINDEX, 0, NULL);
    ListBoxSetCurSel (listicon, LCINDEX, FAILURE);
  } /* if */
  else
  {
    undo_state (listicon, LCINDEX, DISABLED);

    ListBoxSetCount (listicon, LCINDEX, listp->db->t_info [tableinx (listp->db, listp->table)].indexes, NULL);
    ListBoxSetCurSel (listicon, LCINDEX, indexinx (listp->db, listp->table, listp->inx));
  } /* else */

  ListBoxSetSpec (listicon, LCINDEX, (LONG)window);

  set_rbutton (listicon, (listp->dir == ASCENDING) ? LCASC : LCDESC, LCASC, LCDESC);

  if (show_info)
  {
    undo_flags (listicon, LCINFO, HIDETREE);
    undo_flags (listicon, LCORDER, HIDETREE);

    listicon [LCBOX].ob_y     = listicon [LCINFO].ob_height;
    listicon [ROOT].ob_height = listicon [LCINFO].ob_height + listicon [LCBOX].ob_height;
  } /* if */
  else
  {
    do_flags (listicon, LCINFO, HIDETREE);
    do_flags (listicon, LCORDER, HIDETREE);

    listicon [LCBOX].ob_y     = 0;
    listicon [ROOT].ob_height = listicon [LCBOX].ob_height;
  } /* if */
} /* fix_iconbar */

/*****************************************************************************/

LOCAL VOID new_index (window, mk)
WINDOWP window;
MKINFO *mk;

{
  LIST_SPEC *listp;
  WORD      inx, x, y;
  LONG      item;
  RECT      r;

  listp = (LIST_SPEC *)window->special;

  if (VTBL (listp->table) || (rtable (listp->table) < NUM_SYSTABLES)) return;

  objc_offset (listicon, LCINDEX, &x, &y);

  r.x = x;
  r.y = y + OB_HEIGHT (listicon, LCINDEX) - 3;
  r.w = OB_WIDTH (listicon, LCINDEX) - 4;
  r.h = VISIBLE * ListBoxGetItemHeight (listicon, LCINDEX);

  ListBoxSetComboRect (listicon, LCINDEX, &r, window->work.y - 1);

  if ((item = ListBoxComboClick (listicon, LCINDEX, mk)) != FAILURE)
  {
    inx = indexnum (listp->db, tableinx (listp->db, listp->table), (WORD)item);

    if (listp->inx != inx)
    {
      if (window == sel_window) unclick_window (sel_window);

      listp->inx    = inx;
      window->doc.y = 0;

      updt_lswin (window);
    } /* if */
  } /* if */
} /* new_index */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  LIST_SPEC    *listp;
  BOOLEAN      visible_part;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  WORD         inx;
  INDEX_INFO   index_info;
  WORD         num_cols;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);
  listp  = (LIST_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)listp->db->t_info [tableinx (listp->db, listp->table)].i_info [index].indexname);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            v_indexinfo (listp->db, listp->table, listp->db->t_info [tableinx (listp->db, listp->table)].i_info [index].indexnum, &index_info);
                            num_cols = index_info.inxcols.size / sizeof (INXCOL);
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? (num_cols == 1) ? &toolinx_icon : &toolmul_icon : NULL, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : inx = indexnum (listp->db, tableinx (listp->db, listp->table), (WORD)index);
                          sort_name (listp->db, listp->table, inx, listp->dir, window->info);
                          strcpy (get_str (tree, LCORDER), window->info);
                          draw_win_obj (window, tree, LCORDER);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID set_info (window)
WINDOWP window;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  sort_name (listp->db, listp->table, listp->inx, listp->dir, window->info);

  if (window->opened > 0)
  {
    strcpy (get_str (listicon, LCORDER), window->info);
    draw_win_obj (window, listicon, LCORDER);
  } /* if */
} /* set_info */

/*****************************************************************************/

LOCAL VOID objop (window, objs, action, actwin)
WINDOWP window;
SET     objs;
WORD    action;
WINDOWP actwin;

{
  BOOLEAN    ok, needcols;
  LONG       recs, addr;
  LIST_SPEC  *listp;
  WORD       *columns, *colwidth;
  WORD       vtable, i, j;
  VTABLE     *vtablep;
  SYSDELETED sysdeleted;
  FULLNAME   filename;
  WORD       saveformat;
  KEY        keyval;

  ok       = FALSE;
  listp    = (LIST_SPEC *)window->special;
  needcols = (action != OBJ_DEL) && (action != OBJ_UNDEL) && (action != OBJ_EDIT) && (action != OBJ_REP) && (action != OBJ_CALC) && (action != OBJ_ACC);
  columns  = needcols ? (WORD *)mem_alloc (2L * listp->cols * sizeof (WORD)) : NULL;  /* mem_free in module process */

  if (needcols && (columns == NULL))
    hndl_alert (ERR_NOMEMORY);
  else
  {
    if (needcols) colwidth = columns + listp->cols;

    recs   = setcard (objs);
    vtable = new_vtable (listp->db, rtable (listp->table), recs, needcols ? listp->cols : 0);

    if (vtable == FAILURE)
      mem_free (columns);
    else
    {
      set_meminfo ();

      vtablep = VTABLEP (vtable);

      for (i = j = 0; i < listp->max_lines; i++)
        if (setin (objs, i)) vtablep->recaddr [j++] = listp->recaddr [LINX (window, listp, i)];

      vtablep->recs = recs;

      if ((window->class == CLASS_TRASH) && (action == OBJ_EDIT))
      {
        addr = vtablep->recaddr [0];
        free_vtable (vtable);
        if (! v_read (listp->db, listp->table, &sysdeleted, NULL, addr, FALSE)) return;

        vtable  = new_vtable (listp->db, sysdeleted.table, 1L, 0);
        vtablep = VTABLEP (vtable);
        vtablep->recaddr [vtablep->recs++] = sysdeleted.del_addr;
      } /* if */

      if (needcols)
      {
        mem_move (columns, listp->columns, listp->cols * sizeof (WORD));
        mem_move (colwidth, listp->colwidth, listp->cols * sizeof (WORD));
      } /* if */

      switch (action)
      {
        case OBJ_DISK  : ok = print_list (listp->db, vtable, listp->inx, ASCENDING, listp->cols, columns, colwidth, DEV_DISK, &fontdesc, NULL, NULL, minimize);
                         break;
        case OBJ_PRINT : if (sel_window->subclass == CLASS_ALIST)
                           AccDefPrint (sel_window);
                         else
                           ok = print_list (listp->db, vtable, listp->inx, ASCENDING, listp->cols, columns, colwidth, DEV_PRINTER, &fontdesc, NULL, NULL, minimize);
                         break;
        case OBJ_EXP   : ok = exp_list (listp->db, vtable, listp->inx, ASCENDING, listp->cols, columns, colwidth, NULL, minimize);
                         break;
        case OBJ_IMP   : ok = imp_list (listp->db, rtable (vtable), listp->cols, columns, colwidth, NULL, minimize);
                         break;
        case OBJ_DEL   : ok = delete_list (listp->db, vtable, listp->inx, ASCENDING, minimize, TRUE);
                         if (ok)
                         {
                           if ((recs > 0) && (window->class == CLASS_LIST))
                           {
                             listp->operation = OP_DELREC;
                             listp->oldaddr   = vtablep->recaddr [recs - 1];
                           } /* if */

                           if (sel_window == window) unclick_window (sel_window);
                         } /* if */
                         break;
        case OBJ_UNDEL : ok = undelete_list (listp->db, vtable, listp->inx, ASCENDING, minimize);
                         if (ok)
                         {
                           if ((recs > 0) && (window->class == CLASS_LIST))
                           {
                             listp->operation = OP_INSREC;
                             listp->oldaddr   = vtablep->recaddr [recs - 1];
                           } /* if */

                           if (sel_window == window) unclick_window (sel_window);
                         } /* if */
                         break;
        case OBJ_EDIT  : if (! VTBL (listp->table) && (recs == 1) && (window->class != CLASS_TRASH))
                         {
                           addr = vtablep->recaddr [0];
                           if (v_read (listp->db, listp->table, listp->db->buffer, NULL, addr, FALSE))
                           {
                             db_buildkey (listp->db->base, listp->table, listp->inx, listp->db->buffer, keyval);
                             ok = open_mask (NIL, listp->db, listp->table, listp->inx, listp->dir, "", keyval, addr, NULL, NULL, FALSE);
                           } /* if */
                         } /* if */
                         else
                           ok = edit_list (listp->db, vtable, listp->inx, ASCENDING);

                         if (window == sel_window) unclick_window (window);
                         break;
        case OBJ_REP   : if (actwin == NULL) actwin = find_top ();
                         ok = rep_exec (actwin, listp->db, vtable, listp->inx, ASCENDING);
                         break;
        case OBJ_CLIP  : strcpy (filename, scrapdir);
                         strcat (filename, "SCRAP.TXT");
                         saveformat            = impexpcfg.asciiformat;
                         impexpcfg.asciiformat = EXASCII;
                         ok                    = exp_list (listp->db, vtable, listp->inx, ASCENDING, listp->cols, columns, colwidth, filename, minimize);
                         impexpcfg.asciiformat = saveformat;
                         break;
        case OBJ_CALC  : if (actwin == NULL) actwin = find_top ();
                         ok = calc_exec (actwin, listp->db, vtable, listp->inx, ASCENDING);
                         break;
        case OBJ_ACC   : if (actwin == NULL) actwin = find_top ();
                         ok = AccDefExec (actwin, listp->db, vtable, listp->inx, ASCENDING);
                         break;
      } /* switch */

      if (! ok) mem_free (columns);
      free_vtable (vtable);
      set_meminfo ();
    } /* else */
  } /* else */

  set_meminfo ();
} /* objop */

/*****************************************************************************/

LOCAL VOID correct (window, more)
WINDOWP window;
LONG    more;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  if (listp->lines < window->scroll.h / window->yfac)
  {
    if (v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor))
      listp->lines = 0;                         /* invalidate text buffer */
  } /* if */
  else
    window->doc.y += more;
} /* correct */

/*****************************************************************************/

LOCAL BOOLEAN edit_list (db, table, inx, dir)
DB   *db;
WORD table, inx, dir;

{
  return (open_mask (NIL, db, table, inx, dir, "", NULL, 0L, NULL, NULL, FALSE));
} /* edit_list */

/*****************************************************************************/

LOCAL VOID get_rect (window, obj, rect)
WINDOWP window;
WORD    obj;
RECT    *rect;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  xywh2rect (0, 0, 0, 0, rect);

  if ((0 <= obj) && (obj < listp->lines))
  {
    rect->x = window->scroll.x;
    rect->y = window->scroll.y + obj * window->yfac + 1;
    rect->w = (WORD)(min (window->scroll.w, (window->doc.w - window->doc.x) * window->xfac));
    rect->h = window->yfac - 3;
  } /* if */
} /* get_rect */

/*****************************************************************************/

LOCAL VOID drag_objs (window, obj, objs)
WINDOWP window;
WORD    obj;
SET     objs;

{
  RECT      r, bound;
  WORD      mox, moy;
  WORD      i, result, num_objs;
  WORD      dest_obj;
  WINDOWP   dest_window;
  SET       inv_objs;
  RECT      all [MAX_OBJS];
  LIST_SPEC *listp;

  if (window != NULL)
  {
    bound = desk;
    listp = (LIST_SPEC *)window->special;

    get_invobjs (listp->db, listp->table, inv_objs);
    for (i = ITRASH; i < FKEYS; i++) setincl (inv_objs, i);

    if (! (db_acc_table (listp->db->base, rtable (listp->table)) & GRANT_DELETE) || (listp->db->flags & BASE_RDONLY)) setexcl (inv_objs, ITRASH);

    for (i = 0, num_objs = 0; i < MAX_OBJS; i++)
      if (setin (objs, i)) get_rect (window, i, &all [num_objs++]);

    set_mouse (FLAT_HAND, NULL);
    drag_boxes (num_objs, all, find_desk (), inv_objs, &r, &bound, 1, 1);
    last_mouse ();
    graf_mkstate (&mox, &moy, &result, &result);

    result = drag_to_window (mox, moy, window, 0, &dest_window, &dest_obj);

    if (dest_window != NULL)
      if (dest_window->class == class_desk)
      {
        if ((result == DRAG_OK) && (setin (inv_objs, dest_obj) || (dest_obj == ROOT)))
        {
          if ((ITABLE <= dest_obj) && (dest_obj < IPROCESS)) do_addicon (window, objs, dest_obj);

          switch (dest_obj)
          {
            case ROOT     : if (window->subclass == CLASS_LIST) do_fill (window, objs);
                            break;
            case ITRASH   : if (VTBL (listp->table))
                              list_remove (window);
                            else
                              objop (window, objs, OBJ_DEL, NULL);
                            break;
            case IPRINTER : objop (window, objs, OBJ_PRINT, NULL);
                            break;
            case IDISK    : objop (window, objs, OBJ_DISK, NULL);
                            break;
            case ICLIPBRD : objop (window, objs, OBJ_CLIP, NULL);
                            break;
          } /* switch */
        } /* if */
      } /* if */
      else
        switch (dest_window->class)
        {
          case CLASS_LIST   : if (result == DRAG_SCLASS) do_addwind (window, objs, dest_window);
                              break;
          case CLASS_MASK   : for (i = 0; i < listp->max_lines; i++)
                                if (setin (sel_objs, i))
                                {
                                  mset_buffer (dest_window, listp->db, listp->table, listp->recaddr [LINX (window, listp, i)]);
                                  break;
                                } /* if, for */
                              break;
          case CLASS_TRASH  : if (result == DRAG_OK)
                                if (VTBL (listp->table))
                                  list_remove (window);
                                else
                                  objop (window, objs, OBJ_DEL, NULL);
                              break;
          case CLASS_REPORT : objop (window, objs, OBJ_REP, dest_window);
                              break;
          case CLASS_CALC   : objop (window, objs, OBJ_CALC, dest_window);
                              break;
          case CLASS_ACCDEF : objop (window, objs, OBJ_ACC, dest_window);
                              break;
        } /* switch, else, if */
  } /* if */
} /* drag_objs */

/*****************************************************************************/

LOCAL VOID drag_column (window, col, rect, mk)
WINDOWP window;
WORD    col;
RECT    *rect;
MKINFO  *mk;

{
  RECT      r, bound;
  WORD      mox, moy;
  WORD      result;
  WORD      dest_obj;
  WINDOWP   dest_window;
  SET       inv_objs;
  LIST_SPEC *listp;
  BOOLEAN   del, move, sep;
  WORD      dst;

  listp = (LIST_SPEC *)window->special;
  del   = move = FALSE;

  xywh2rect (window->scroll.x, window->work.y, window->scroll.w, window->work.h, &bound);
  rc_intersect (&bound, rect);
  bound = desk;

  setclr (inv_objs);
  setincl (inv_objs, ITRASH);

  if (mk->mobutton & 0x0001)
  {
    invert_col (window, rect);
    set_mouse (FLAT_HAND, NULL);
    drag_boxes (1, rect, find_desk (), inv_objs, &r, &bound, 1, 1);
    last_mouse ();
    graf_mkstate (&mox, &moy, &result, &result);
    invert_col (window, rect);

    result = drag_to_window (mox, moy, window, 0, &dest_window, &dest_obj);

    if (dest_window != NULL)
      if (dest_window->class == class_desk)
      {
        if (dest_obj == ITRASH) del = TRUE;
      } /* if */
      else
        if (result == DRAG_SWIND)
        {
          dst  = calc_col (window, mox, &r, &sep);
          move = (dst != FAILURE) && (dst != col);
        } /* if */
        else
          if (dest_window->class == CLASS_TRASH)
            if (result == DRAG_OK) del = TRUE;
  } /* if */
  else
    if (mk->alt || (mk->momask & 0x0002))
    {
      invert_col (window, rect);
      del = TRUE;
      invert_col (window, rect);
    } /* if, else */

  if (del)                                      /* delete column */
    if (listp->cols == 1)
      hndl_alert (ERR_NOCOLUMNS);
    else
    {
      listp->operation = OP_DELCOL;
      listp->oldpos    = col;
      listp->oldcol    = listp->columns [col];
      listp->oldwidth  = listp->colwidth [col];
      listp->cols--;

      mem_move (&listp->columns [col], &listp->columns [col + 1], (listp->cols - col) * sizeof (WORD));
      mem_move (&listp->colwidth [col], &listp->colwidth [col + 1], (listp->cols - col) * sizeof (WORD));
    } /* else, if */

  if (move)                                     /* move column */
  {
    listp->operation = OP_MOVECOL;
    listp->oldpos    = col;
    listp->oldcol    = dst;

    move_col (listp, col, dst);
  } /* if */

  if (del || move) update_col (window, TRUE);
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
  WORD      maxwidth, minwidth;
  LIST_SPEC *listp;
  WORD      xy [4];
  FIELDNAME name;

  listp = (LIST_SPEC *)window->special;
  r.x   = rect->x;
  r.y   = window->work.y + listp->iconheight;
  r.w   = 1;
  r.h   = (WORD)min (window->work.h - listp->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac);

  width    = abs (listp->colwidth [col]);
  sign     = SIGN (listp->colwidth [col]);
  maxwidth = LONGSTRLEN - width;
  minwidth = 2 - width;

  if (with_hand)
  {
    xy [0] = r.x + minwidth * window->xfac;
    xy [1] = window->work.y + listp->iconheight;
    xy [2] = r.x + maxwidth * window->xfac;
    xy [3] = window->work.y + listp->iconheight + ((WORD)min (window->work.h - listp->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac)) - 1;

    array2rect (xy, &bound);
    rc_intersect (&window->scroll, &bound);

    listwidt->ob_x = window->scroll.x + (window->scroll.w - listwidt->ob_width) / 2;
    listwidt->ob_y = window->scroll.y + (window->scroll.h - listwidt->ob_height) / 2;

    listwidt->ob_x = min (listwidt->ob_x, desk.x + desk.w - listwidt->ob_width);
    listwidt->ob_y = min (listwidt->ob_y, desk.y + desk.h - listwidt->ob_height);

    set_clip (TRUE, &desk);
    set_mouse (FLAT_HAND, NULL);
    drag_line (&r, &diff, &bound, window->xfac, 0, width, window->doc.w);
    last_mouse ();

    wdiff = diff.w / window->xfac;
  } /* if */
  else
    wdiff = selwidth (column_name (listp->db, listp->table, listp->columns [col], name), width, minwidth, maxwidth, window->doc.w, TRUE);

  if (wdiff != 0)
  {
    wdiff = (wdiff > 0) ? min (wdiff, maxwidth) : max (wdiff, minwidth);

    if (wdiff != 0)
    {
      listp->operation       = OP_SIZECOL;
      listp->oldpos          = col;
      listp->oldwidth        = listp->colwidth [col];
      width                 += wdiff;
      listp->colwidth [col]  = sign * width;

      update_col (window, FALSE);
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
  LONG      x;
  WORD      i, w;
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;
  x     = window->scroll.x - window->doc.x * window->xfac + window->xfac / 2;

  for (i = 0; i < listp->cols; i++)
  {
    w  = abs (listp->colwidth [i]) * window->xfac;
    x += w;

    if (mox < x)                                /* position found */
      if (mox < x - window->xfac)
      {
        r->x = (WORD)x - w - window->xfac / 2;
        r->y = window->work.y + listp->iconheight;
        r->w = w - 1;
        r->h = (WORD)min (window->work.h - listp->iconheight, window->yscroll + (window->doc.h - window->doc.y) * window->yfac);
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

LOCAL VOID drag_line (r, diff, bound, x_raster, y_raster, width, reswidth)
RECT *r, *diff, *bound;
WORD x_raster, y_raster, width;
LONG reswidth;

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
          sprintf (s, "%5ld", reswidth + x_offset / x_raster);
          set_str (listwidt, LIRESULT, s);

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
  vsl_color (vdi_handle, RED);
  v_pline (vdi_handle, 2, xy);
  show_mouse ();
} /* draw_line */

/*****************************************************************************/

LOCAL VOID move_col (listp, src, dst)
LIST_SPEC *listp;
WORD      src, dst;

{
  WORD save_col, save_width;

  save_col   = listp->columns [src];
  save_width = listp->colwidth [src];

  if (dst < src)
  {
    mem_move (&listp->columns [dst + 1], &listp->columns [dst], (src - dst) * sizeof (WORD));
    mem_move (&listp->colwidth [dst + 1], &listp->colwidth [dst], (src - dst) * sizeof (WORD));
  } /* if */
  else
  {
    mem_move (&listp->columns [src], &listp->columns [src + 1], (dst - src) * sizeof (WORD));
    mem_move (&listp->colwidth [src], &listp->colwidth [src + 1], (dst - src) * sizeof (WORD));
  } /* else */

  listp->columns [dst]  = save_col;
  listp->colwidth [dst] = save_width;
} /* move_col */

/*****************************************************************************/

LOCAL VOID update_col (window, fill_buffer)
WINDOWP window;
BOOLEAN fill_buffer;

{
  LIST_SPEC *listp;
  LONG      max_xdoc;
  RECT      r;

  listp = (LIST_SPEC *)window->special;

  window->doc.w = get_width (listp->cols, listp->colwidth);
  max_xdoc      = window->doc.w - window->scroll.w / window->xfac;

  if (max_xdoc < 0) max_xdoc = 0;
  if (window->doc.x > max_xdoc) window->doc.x = max_xdoc;

  if (fill_buffer)
  {
    build_colheader (listp->db, listp->table, listp->cols, listp->columns, listp->colwidth, listp->max_columns, listp->colheader);

    if (window->doc.y == 0)
      v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);
    else
      v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- listp->lines));

    listp->lines = 0;
  } /* if */

  r    = window->scroll;
  r.y -= window->yscroll;				/* need to redraw header also */
  r.h += window->yscroll;

  set_sliders (window, HORIZONTAL, SLPOS + SLSIZE);
  set_redraw (window, &r);
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

LOCAL VOID fill_select (window, objs, area)
WINDOWP window;
SET     objs;
RECT    *area;

{
  REG WORD i;
      RECT r;

  setclr (objs);

  for (i = 0; i < MAX_OBJS; i++)
  {
    get_rect (window, i, &r);

    if (rc_intersect (area, &r))                                 /* in rectangle */
      if (rc_intersect (&window->scroll, &r)) setincl (objs, i); /* in scrolling area */
  } /* for */
} /* fill_select */

/*****************************************************************************/

LOCAL VOID invert_objs (window, objs)
WINDOWP window;
SET     objs;

{
  REG WORD i;
      RECT r, inv;
      WORD xy [4];

  wind_update (BEG_UPDATE);
  hide_mouse ();

  vswr_mode (vdi_handle, MD_XOR);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_color (vdi_handle, BLACK);

  wind_get (window->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

  while ((r.w != 0) && (r.h != 0))
  {
    if (rc_intersect (&window->scroll, &r))
      for (i = 0; i < MAX_OBJS; i++)
        if (setin (objs, i))
        {
          get_rect (window, i, &inv);

          if (rc_intersect (&r, &inv))
          {
            set_clip (TRUE, &inv);            /* visible area */
            rect2array (&inv, xy);
            vr_recfl (vdi_handle, xy);
          } /* if */
        } /* if, for, if */

    wind_get (window->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
  } /* while */

  show_mouse ();
  wind_update (END_UPDATE);
} /* invert_objs */

/*****************************************************************************/

LOCAL VOID rubber_objs (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  RECT r;
  SET  new_objs;

  r.x = mk->mox;
  r.y = mk->moy;

  set_mouse (POINT_HAND, NULL);
  graf_rubbox (r.x, r.y, -r.x, -r.y, &r.w, &r.h);
  last_mouse ();

  if (r.w < 0)
  {
    r.x += r.w;
    r.w  = - r.w;
  } /* if */

  if (r.h < 0)
  {
    r.y += r.h;
    r.h  = - r.h;
  } /* if */

  if (mk->shift)                                /* select exclusive */
  {
    fill_select (window, new_objs, &r);
    invert_objs (window, new_objs);
    setxor (sel_objs, new_objs);
  } /* if */
  else
    if (mk->ctrl)                               /* select additional */
    {
      fill_select (window, new_objs, &r);
      setnot (sel_objs);
      setand (new_objs, sel_objs);
      setnot (sel_objs);
      invert_objs (window, new_objs);
      setor (sel_objs, new_objs);
    } /* if */
    else                                        /* select */
    {
      fill_select (window, sel_objs, &r);
      invert_objs (window, sel_objs);
    } /* else */

  sel_window = setcmp (sel_objs, NULL) ? NULL : window;
} /* rubber_objs */

/*****************************************************************************/

LOCAL VOID do_fill (window, objs)
WINDOWP window;
SET     objs;

{
  REG LIST_SPEC *listp;
  REG WORD      i;
  REG LONG      recs;
      LONG      recaddr [MAX_OBJS];

  listp = (LIST_SPEC *)window->special;

  for (i = recs = 0; i < MAX_OBJS; i++)
    if (setin (objs, i))
      recaddr [recs++] = listp->recaddr [LINX (window, listp, i)];

  fill_virtual (listp->db, rtable (listp->table), (listp->dir == DESCENDING) ? FAILURE : listp->inx, recs, recaddr, listp->cols, listp->columns, listp->colwidth);
} /* do_fill */

/*****************************************************************************/

LOCAL VOID do_addicon (window, objs, icon)
WINDOWP window;
SET     objs;
WORD    icon;

{
  REG LIST_SPEC *listp, *dlistp;
  REG WORD      i, vtable;
  REG LONG      recs;
      LONG      more;
      LONG      recaddr [MAX_OBJS];
      WINDOWP   dest_window;

  vtable = icon_info [icon - ITABLE].table;
  listp  = (LIST_SPEC *)window->special;

  for (i = recs = 0; i < MAX_OBJS; i++)
    if (setin (objs, i))
      recaddr [recs++] = listp->recaddr [LINX (window, listp, i)];

  more = add_virtual (vtable, recs, recaddr);

  if (more > 0)
  {
    dest_window         = icon_info [icon - ITABLE].window;
    dest_window->doc.h += more;           /* correct document height */
    dlistp              = (LIST_SPEC *)dest_window->special;
    if (dlistp->dir == DESCENDING) correct (dest_window, more);
  } /* if */
} /* do_addicon */

/*****************************************************************************/

LOCAL VOID do_addwind (window, objs, dest_window)
WINDOWP window;
SET     objs;
WINDOWP dest_window;

{
  REG LIST_SPEC *listp, *dlistp;
  REG WORD      i, vtable;
  REG LONG      recs;
      LONG      more;
      LONG      recaddr [MAX_OBJS];

  listp  = (LIST_SPEC *)window->special;
  dlistp = (LIST_SPEC *)dest_window->special;
  vtable = dlistp->table;

  if (VTBL (vtable) && (listp->db == dlistp->db) && (rtable (listp->table) == rtable (dlistp->table)))
  {
    for (i = recs = 0; i < MAX_OBJS; i++)
      if (setin (objs, i))
        recaddr [recs++] = listp->recaddr [LINX (window, listp, i)];

    more = add_virtual (vtable, recs, recaddr);

    if (more > 0)
    {
      dest_window->doc.h += more;       /* correct document height */
      if (dlistp->dir == DESCENDING) correct (dest_window, more);
      set_sliders (dest_window, VERTICAL, SLPOS + SLSIZE);
      redraw_window (dest_window, &dest_window->work);
    } /* if */
  } /* if */
} /* do_addwind */

/*****************************************************************************/

LOCAL VOID click_search (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case LIOK   : result = TRUE;
                  break;
    case LIHELP : hndl_help (HLSTSRCH);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */

  check_search (window);
} /* click_search */

/*****************************************************************************/

LOCAL BOOLEAN key_search (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  check_search (window);

  return (FALSE);
} /* key_search */

/*****************************************************************************/

LOCAL VOID check_search (window)
WINDOWP window;

{
  BYTE *p;

  if (get_checkbox (listsrch, LITEXT) == is_state (listsrch, LIDIR, DISABLED))
  {
    flip_state (listsrch, LICASE, DISABLED);
    draw_object (window, LICASE);
    flip_state (listsrch, LIDIR, DISABLED);
    draw_object (window, LIDIR);
    flip_state (listsrch, LIASC, DISABLED);
    draw_object (window, LIASC);
    flip_state (listsrch, LIDESC, DISABLED);
    draw_object (window, LIDESC);
  } /* if */

  if (get_checkbox (listsrch, LITEXT) == ! is_state (listsrch, LIINDEX, DISABLED))
  {
    flip_state (listsrch, LIINDEXL, DISABLED);
    draw_object (window, LIINDEXL);
    flip_state (listsrch, LIINDEX, DISABLED);
    draw_object (window, LIINDEX);
  } /* if */

  p = get_str (listsrch, LISEARCH);

  if ((*p == EOS) == ! is_state (listsrch, LIOK, DISABLED))
  {
    flip_state (listsrch, LIOK, DISABLED);
    draw_object (window, LIOK);
  } /* if */
} /* check_search */

/*****************************************************************************/

LOCAL VOID click_remsel (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONG      from, to, save;
  LIST_SPEC *listp;
  VTABLE    *vtablep;

  switch (window->exit_obj)
  {
    case RMOK   : from    = get_long (remsel, RMFROM);
                  to      = get_long (remsel, RMTO);
                  listp   = (LIST_SPEC *)win->special;
                  vtablep = VTABLEP (listp->table);

                  if (listp->dir == DESCENDING)
                  {
                    from = vtablep->recs - from - 1;
                    to   = vtablep->recs - to - 1;
                    save = from;
                    from = to;
                    to   = save;
                  } /* else */

                  vtablep->recs -= to - from + 1;
                  mem_lmove (&vtablep->recaddr [from], &vtablep->recaddr [to + 1], (vtablep->recs - from) * sizeof (LONG));

                  if (sel_window == win)
                  {
                    sel_window = NULL;
                    setclr (sel_objs);
                  } /* if */

                  updt_lswin (win);
                  break;
    case RMHELP : hndl_help (HREMSEL);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_remsel */

/*****************************************************************************/

LOCAL BOOLEAN key_remsel (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p1, *p2;
  LONG from, to;

  p1   = get_str (remsel, RMFROM);
  p2   = get_str (remsel, RMTO);
  from = get_long (remsel, RMFROM);
  to   = get_long (remsel, RMTO);

  if (((*p1 == EOS) || (*p2 == EOS) || (from > to) || (to >= win->doc.h)) == ! is_state (remsel, RMOK, DISABLED))
  {
    flip_state (remsel, RMOK, DISABLED);
    draw_object (window, RMOK);
  } /* if */

  return (FALSE);
} /* key_remsel */

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
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN wi_test (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN   ret, ext;
  MKINFO    mk;
  LIST_SPEC *listp;

  ret   = TRUE;
  ext   = (action & DO_EXTERNAL) != 0;
  ext   = ext; /* no warning please */
  listp = (LIST_SPEC *)window->special;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = listp->operation != OP_NOP;
                     break;
    case DO_CUT    : ret = FALSE;
                     break;
    case DO_COPY   : ret = FALSE;
                     break;
    case DO_PASTE  : ret = (listp->operation == OP_DELREC) || (window == sel_window) && (window->class == CLASS_TRASH);
                     break;
    case DO_CLEAR  : ret = (window == sel_window) && (db_acc_table (listp->db->base, rtable (listp->table)) & GRANT_DELETE);
                     break;
    case DO_SELALL : ret = window->doc.h > 0;
                     break;
    case DO_CLOSE  : graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
                     if (! done && ! acc_close && ! (window->flags & WI_RESIDENT) && ((mk.kstate & K_ALT) || (mk.mobutton & 2) || listp->close_as_icon))
                     {
                       if (icon_avail ())
                         miconify (window);
                       else
                         hndl_alert (ERR_NOICON);

                       ret = FALSE;
                     } /* if */
                     break;
    case DO_DELETE : ret = TRUE;
                     break;
  } /* switch */

  return (ret);
} /* wi_test */

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
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  LIST_SPEC *listp;

  listp = (LIST_SPEC *)window->special;

  if (VTBL (listp->table)) free_vtable (listp->table);
  if (VINX (listp->inx)) free_vindex (listp->inx);

  db_freecursor (listp->db->base, listp->cursor);
  mem_free (listp->columns);
  mem_free (listp->recaddr);
  mem_free (listp);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD      i, j, ret, table;
  WORD      xfac, yfac, y, w, h;
  WORD      text_x, text_y, text_width, text_height;
  WORD      xy [4];
  LONG      x;
  LIST_SPEC *listp;
  BOOLEAN   mode, more;
  RECT      rc, save;
  BYTE      *p, *q;
  WORD      width;
  LONGSTR   s;

  xfac  = window->xfac;
  yfac  = window->yfac;
  listp = (LIST_SPEC *)window->special;

  ltoa (window->doc.h, s, 10);

  listp->iconheight = listicon [LCBOX].ob_height + (show_info ? listicon [LCINFO].ob_height : 0) + 1;
  window->xscroll   = show_left ? window->xfac / 2 - 1 + ((INT)strlen (s) + 1) * window->xfac : 0;
  window->yscroll   = show_top ? window->yfac : 0;
  window->scroll.x  = window->work.x + window->xscroll;
  window->scroll.y  = window->work.y + window->yscroll + listp->iconheight;
  window->scroll.w  = window->work.w - window->xscroll;
  window->scroll.h  = window->work.h - window->yscroll - listp->iconheight;

  clr_work (window);

  if (listp->iconheight > 0)
  {
    fix_iconbar (window);
    objc_draw (listicon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  } /* if */

  line_default (vdi_handle);
  text_default (vdi_handle);
  vst_font (vdi_handle, listp->fontdesc.font);
  vst_point (vdi_handle, listp->fontdesc.point, &ret, &ret, &ret, &ret);
  vst_effects (vdi_handle, listp->fontdesc.effects | TXT_THICKENED);
  vst_color (vdi_handle, listp->fontdesc.color);

  if (window->yscroll > 0)
  {
    if (window->xscroll > 0)
    {
      xywh2rect (0, listp->iconheight, window->xscroll, window->yscroll, &rc);
      fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
      draw_3d_rect (window, &rc, WHITE, BLACK);

      strcpy (s, "#");
      text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

      text_x = window->work.x + window->xscroll - text_width - xfac / 2;
      text_y = window->work.y + listp->iconheight + 2;
      vswr_mode (vdi_handle, MD_TRANS);
      v_text (vdi_handle, text_x, text_y, s);
      vswr_mode (vdi_handle, MD_REPLACE);
    } /* if */

    p = listp->colheader;
    x = window->xscroll - window->doc.x * xfac;

    for (j = 0; j < listp->cols; j++, x += w)			/* paint header */
    {
      width = listp->colwidth [j];
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

        xywh2rect ((WORD)x, listp->iconheight, w, window->yscroll, &rc);
        fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (window, &rc, WHITE, BLACK);

        text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

        text_x = window->work.x + (WORD)x + xfac / 2 + 1;
        text_y = window->work.y + listp->iconheight + 2;
        vswr_mode (vdi_handle, MD_TRANS);

        if (text_width > w - xfac)				/* use clipping */
        {
          xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
          rc_intersect (&clip, &rc);
          set_clip (TRUE, &rc);
          v_text (vdi_handle, text_x, text_y, s);
        } /* if */
        else
        {
          if (width > 0)
            text_x = window->work.x + (WORD)x + w - text_width - xfac / 2 - 1;	/* right aligned */

          v_text (vdi_handle, text_x, text_y, s);
        } /* else */

        vswr_mode (vdi_handle, MD_REPLACE);
        set_clip (TRUE, &save);
      } /* if */
    } /* for */
  } /* if */

  x = window->xscroll + (window->doc.w - window->doc.x) * xfac;

#if 0
  if (window->work.x + x <= clip.x + clip.w)		/* right edge of table */
  {
    xywh2rect ((WORD)x, listp->iconheight, window->work.w - x, yfac + window->scroll.h, &rc);
    fill_rect (window, &rc, WHITE, FALSE);
  } /* if */
#endif

  mode = set_alert (TRUE);                      /* alert boxes as dialog boxes */

  db_beg_trans (listp->db->base, FALSE);

  y    = window->yscroll;
  h    = (window->scroll.h + yfac - 1) / yfac;
  more = TRUE;

  for (i = 0; (i < h) && more; i++)			/* paint the data lines */
  {
    x    = window->xscroll - window->doc.x * xfac;
    p    = &listp->text [CINX (window, listp, i)];
    more = i < listp->lines;				/* more lines in buffer */

    if (! more)						/* fetch new records */
      if (v_movecursor (listp->db, listp->cursor, (LONG)listp->dir)) /* move to new records */
      {
        more = TRUE;

        listp->recaddr [LINX (window, listp, i)] = v_readcursor (listp->db, listp->cursor, NULL);

        if (listp->lines < listp->valid_line)   /* only for backward scrolling */
        {
          if (! v_read (listp->db, listp->table, listp->db->buffer, listp->cursor, 0L, FALSE))
            db_fillnull (listp->db->base, rtable (listp->table), listp->db->buffer);
          else
            if (use_calc) v_execute (listp->db, listp->table, NULL, listp->db->buffer, window->doc.y + i + 1, NULL);

          rec_to_line (listp->db, listp->table, listp->db->buffer,
                       listp->cols, listp->columns, listp->colwidth,
                       listp->max_columns, p);
        } /* if */

        listp->lines++;
      } /* if, if */

    if (more)
    {
      if ((window->work.x + window->xscroll > clip.x) && (window->work.x <= clip.x + clip.w) &&
          (window->work.y + listp->iconheight + y + yfac > clip.y) && (window->work.y + listp->iconheight + y < clip.y + clip.h))
      {
        xywh2rect (0, listp->iconheight + y, window->xscroll, yfac, &rc);
        fill_rect (window, &rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (window, &rc, WHITE, BLACK);

        vswr_mode (vdi_handle, MD_TRANS);
        vst_effects (vdi_handle, listp->fontdesc.effects | TXT_THICKENED);
        ltoa (window->doc.y + i + 1, s, 10);
        text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

        text_x = window->work.x + window->xscroll - text_width - xfac / 2;
        text_y = window->work.y + listp->iconheight + y + 2;
        v_text (vdi_handle, text_x, text_y, s);
        vswr_mode (vdi_handle, MD_REPLACE);
      } /* if */

      for (j = 0; j < listp->cols; j++, x += w)			/* get every single column */
      {
        width = listp->colwidth [j];
        w     = abs (width) * window->xfac;

        q = s;
        while (*p != COLUMNSEP) *q++ = *p++;
        *q = EOS;
        p++;

        if (rtable (listp->table) == SYS_DELETED)
        {
          table = (WORD)atoi (s);
          if (listp->columns [j] == 2) table_name (listp->db, table, s);
        } /* if */

        if ((window->work.x + x + w > clip.x) && (window->work.x + x <= clip.x + clip.w) &&
            (window->work.y + listp->iconheight + y + yfac > clip.y) && (window->work.y + listp->iconheight + y < clip.y + clip.h))
        {
          save = clip;
          xywh2rect (window->scroll.x, window->work.y, window->work.w - (window->scroll.x - window->work.x), window->work.h, &rc);
          rc_intersect (&rc, &clip);		        	/* don't paint over left column */
          set_clip (TRUE, &clip);

          if (show_grid)
          {
            xywh2rect ((WORD)x, listp->iconheight + y, w, yfac, &rc);
            draw_border (window, &rc);
          } /* if */

          vswr_mode (vdi_handle, MD_TRANS);
          vst_effects (vdi_handle, listp->fontdesc.effects);
          text_extent (vdi_handle, s, TRUE, &text_width, &text_height);

          text_x = window->work.x + (WORD)x + xfac / 2 + 1;
          text_y = window->work.y + listp->iconheight + y + 2;

          if (text_width > w - xfac)				/* use clipping */
          {
            xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
            rc_intersect (&clip, &rc);
            set_clip (TRUE, &rc);
            v_text (vdi_handle, text_x, text_y, s);
          } /* if */
          else
          {
            if (width > 0)
              text_x = window->work.x + (WORD)x + w - text_width - xfac / 2 - 1;	/* right aligned */

            v_text (vdi_handle, text_x, text_y, s);
          } /* else */

          vswr_mode (vdi_handle, MD_REPLACE);
          set_clip (TRUE, &save);
        } /* if */
      } /* for */

      if ((window == sel_window) && (setin (sel_objs, i)))
      {
        vswr_mode (vdi_handle, MD_XOR);
        vsf_interior (vdi_handle, FIS_SOLID);
        vsf_color (vdi_handle, BLACK);
        get_rect (window, i, &rc);
        rect2array (&rc, xy);
        vr_recfl (vdi_handle, xy);
        vswr_mode (vdi_handle, MD_REPLACE);
      } /* if */

      y += window->yfac;
    } /* if */
  } /* for */

#if 0
  if (window->work.y + listp->iconheight <= clip.y + clip.h)		/* bottom edge of table */
  {
    xywh2rect (0, listp->iconheight + y, window->work.w, window->work.h - listp->iconheight - y, &rc);
    fill_rect (window, &rc, WHITE, FALSE);
  } /* if */
#endif

  db_end_trans (listp->db->base);

  listp->valid_line = listp->max_lines;
  set_alert (mode);                             /* restore old mode */
} /* wi_draw */

/*****************************************************************************/
/* Reagiere auf Pfeile                                                       */
/*****************************************************************************/

LOCAL VOID wi_arrow (window, dir, oldpos, newpos)
WINDOWP window;
WORD    dir;
LONG    oldpos, newpos;

{
  LONG      delta, lines, back, forw;
  LIST_SPEC *listp;

  delta = newpos - oldpos;
  listp = (LIST_SPEC *)window->special;

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
      if (window == sel_window) unclick_window (window);

      if (delta > 0)                            /* scroll up */
      {
        lines = listp->lines - delta;           /* lines remaining in buffer */

        if (lines < 0)                          /* buffer is now empty */
        {
          back = window->doc.h - newpos + 1;
          forw = - lines;

          busy_mouse ();

          if (forw < back)                      /* forward scrolling */
            v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * forw);
          else                                  /* backward scrolling */
          {
            v_initcursor (listp->db, listp->table, listp->inx, - listp->dir, listp->cursor);
            v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- back));
          } /* else */

          arrow_mouse ();

          listp->first_line = 0;
          listp->lines      = 0;
        } /* if */
        else
        {
          listp->first_line = LINX (window, listp, (WORD)delta);
          listp->lines      = (WORD)lines;
        } /* else */
      } /* if */
      else                                      /* scroll down */
      {
        lines = - delta;
        forw  = newpos;
        back  = listp->lines + lines;

        if (lines > 1) busy_mouse ();

        if (back < forw)                        /* backward scrolling is faster */
          v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- back));
        else                                    /* forward scrolling */
        {
          v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);
          if (forw > 0) v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * forw);
        } /* else */

        if (lines > 1) arrow_mouse ();

        if (lines > listp->max_lines)           /* scrolled too many lines */
        {
          listp->first_line = 0;
          listp->valid_line = listp->max_lines;
        } /* if */
        else                                    /* up to max_lines scrolled */
        {
          listp->first_line -= (WORD)lines;
          listp->valid_line  = (WORD)lines;
          if (listp->first_line < 0) listp->first_line += listp->max_lines;
        } /* else */

        listp->lines = 0;
      } /* else */

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
  RECT      r, diff;
  WORD      wbox, hbox, enlarge;
  LONG      max_xdoc, max_ydoc, lines, back;
  LIST_SPEC *listp;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / 2 * 2;		/* Differenz berechnen */
  diff.w = (new->w - r.w) / 2 * 2;
  diff.h = (new->h - r.h) / 2 * 2;

  if (wbox == 8)
    diff.x = (new->x - r.x) / 8 * 8;		/* Schnelle Position */

  listp   = (LIST_SPEC *)window->special;
  enlarge = listp->max_lines * hbox - window->scroll.h;    /* max pixels to enlarge */
  if (diff.h > enlarge) diff.h = enlarge;                  /* max line size */

  new->x = r.x + diff.x;			/* Arbeitsbereich einrasten */
  new->w = r.w + diff.w;
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
      if (window == sel_window) unclick_window (window);

      lines = window->doc.y - max_ydoc;
      back  = listp->lines + lines;

      if (max_ydoc == 0)
        v_initcursor (listp->db, listp->table, listp->inx, listp->dir, listp->cursor);
      else
        v_movecursor (listp->db, listp->cursor, (LONG)listp->dir * (- back));

      listp->first_line -= (WORD)lines;
      listp->valid_line  = (WORD)lines;
      if (listp->first_line < 0) listp->first_line += listp->max_lines;

      listp->lines  = 0;
      window->doc.y = max_ydoc;
    } /* if */

    if (diff.w != 0)				/* Wegen SS_INSIDE */
    {
      r   = window->work;
      r.h = listicon [LCINFO].ob_height;
      set_redraw (window, &r);
    } /* if */
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Objektoperationen von Fenster                                             */
/*****************************************************************************/

LOCAL VOID wi_objop (window, objs, action)
WINDOWP window;
SET     objs;
WORD    action;

{
  BOOLEAN ok;

  switch (action)
  {
    case OBJ_OPEN  : switch (window->subclass)
                     {
                       case CLASS_QLIST : qbe_old (window);                     break;
                       case CLASS_RLIST : report_old (window);                  break;
                       case CLASS_CLIST : calc_old (window);                    break;
                       case CLASS_BLIST : batch_old (window);                   break;
                       case CLASS_ALIST : AccDefLoad (window);                 break;
                       default          : objop (window, objs, OBJ_EDIT, NULL); break;
                     } /* switch */

                     if (window == sel_window) unclick_window (window);
                     break;
    case OBJ_INFO  : ok = info_list (window, NIL);
                     if (! ok) hndl_alert (ERR_NOINFO);
                     break;
    case OBJ_HELP  : ok = help_list (window, NIL);
                     if (! ok) hndl_alert (ERR_NOHELP);
                     break;
    case OBJ_DISK  :
    case OBJ_PRINT :
    case OBJ_EXP   :
    case OBJ_IMP   :
    case OBJ_DEL   :
    case OBJ_EDIT  :
    case OBJ_REP   :
    case OBJ_CLIP  :
    case OBJ_CALC  :
    case OBJ_ACC   : objop (window, objs, action, NULL);
                     break;
  } /* switch */
} /* wi_objop */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  WORD      action;
  LONG      more;
  WINDOWP   window;
  LIST_SPEC *listp, *dlistp;
  VTABLE    *vtablep;

  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  action = DRAG_NOACTN;

  if ((src_window->handle == class_desk) && (ITABLE <= src_obj) && (src_obj < IPROCESS))
  {
    window = search_window (CLASS_LIST, SRCH_CLOSED, src_obj);
    listp  = (LIST_SPEC *)window->special;
    dlistp = (LIST_SPEC *)dest_window->special;

    if (VTBL (listp->table) && VTBL (dlistp->table) && (rtable (listp->table) == rtable (dlistp->table)))
    {
      vtablep = VTABLEP (icon_info [src_obj - ITABLE].table);
      more    = add_virtual (dlistp->table, vtablep->recs, vtablep->recaddr);

      if (more > 0)
      {
        dest_window->doc.h += more;     /* correct document height */
        if (dlistp->dir == DESCENDING) correct (dest_window, more);
        set_sliders (dest_window, VERTICAL, SLPOS + SLSIZE);
        redraw_window (dest_window, &dest_window->work);
      } /* if */

      action = DRAG_OK;
    } /* if */
  } /* if */

  return (action);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      obj, col;
  SET       new_objs;
  RECT      r;
  LIST_SPEC *listp;
  BOOLEAN   sep;

  if (sel_window != window) unclick_window (sel_window); /* deselect */

  listp = (LIST_SPEC *)window->special;
  obj   = NIL;

  fix_iconbar (window);

  if (inside (mk->mox, mk->moy, &window->scroll))        /* in scrolling area ? */
  {
    obj = (mk->moy - window->scroll.y) / window->yfac;

    get_rect (window, obj, &r);
    if (! inside (mk->mox, mk->moy, &r) || (obj >= listp->lines)) obj = NIL;
  } /* if */

  if (obj != NIL)
  {
    setclr (new_objs);
    setincl (new_objs, obj);                    /* actual object */

    if (mk->shift)
    {
      invert_objs (window, new_objs);
      setxor (sel_objs, new_objs);
      if (! setin (sel_objs, obj)) obj = NIL;   /* deselect again */
    } /* if */
    else
    {
      if (! setin (sel_objs, obj))
      {
        unclick_window (window);                /* deselect old objects */
        invert_objs (window, new_objs);
      } /* if */

      setor (sel_objs, new_objs);
    } /* else */

    sel_window = setcmp (sel_objs, NULL) ? NULL : window;

    if ((sel_window != NULL) && (obj != NIL))
    {
      if ((mk->breturn == 1) && (mk->mobutton & 0x0003) && (window->class == CLASS_LIST)) /* drag operation, not for CLASS_TRASH */
        drag_objs (window, obj, sel_objs);

      if (mk->breturn == 2)                 /* double click on object */
        if ((mk->momask & 0x0002 || mk->alt) && ((window->subclass == CLASS_QLIST) || (window->subclass == CLASS_RLIST) || (window->subclass == CLASS_CLIST) || (window->subclass == CLASS_BLIST) || (window->subclass == CLASS_ALIST)))
          switch (window->subclass)
          {
            case CLASS_QLIST : qbe_execute (NULL);    break;
            case CLASS_RLIST : report_execute (NULL); break;
            case CLASS_CLIST : calc_execute (NULL);   break;
            case CLASS_BLIST : batch_execute (NULL);  break;
            case CLASS_ALIST : AccDefExecute (NULL);  break;
          } /* switch, if */
        else
          if (window->objop != NULL)
            (*window->objop) (sel_window, sel_objs, OBJ_OPEN);
    } /* if */
  } /* if */
  else
    if (inside (mk->mox, mk->moy, &window->work))       /* in working area ? */
      if (mk->moy < window->work.y + listp->iconheight)
      {
        obj = objc_find (listicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

        if (! is_state (listicon, obj, DISABLED))
          switch (obj)
          {
            case LCINDEX  : do_state (listicon, obj, SELECTED);
                            draw_win_obj (window, listicon, obj);
                            new_index (window, mk);
                            undo_state (listicon, obj, SELECTED);
                            draw_win_obj (window, listicon, obj);
                            break;
            case LCASC    :
            case LCDESC   : window_button (window, listicon, obj, mk->breturn);
                            if (is_state (listicon, LCASC, SELECTED) && (listp->dir != ASCENDING) ||
                                is_state (listicon, LCDESC, SELECTED) && (listp->dir != DESCENDING))
                              list_reverse (window);
                            break;
            case LCSEARCH :
            case LCMASK   : window_button (window, listicon, obj, mk->breturn);
                            if (is_state (listicon, obj, SELECTED))
                            {
                              undo_state (listicon, obj, SELECTED);	/* there could be more than one window using the iconbar */
                              draw_win_obj (window, listicon, obj);

                              switch (obj)
                              {
                                case LCSEARCH : list_search (window, FALSE);
                                                break;
                                case LCMASK   : if (sel_window == window)
                                                  (*sel_window->objop) (sel_window, sel_objs, OBJ_EDIT);
                                                else
                                                  edit_list (listp->db, listp->table, listp->inx, listp->dir);
                                                break;
                              } /* switch */
                            } /* if */
                          break;
          } /* switch, if */
      } /* if */
      else
      {
        if ((window->scroll.x < mk->mox) && (mk->moy < window->scroll.y)) /* in column header */
        {
          unclick_window (window);                      /* deselect rows */

          col = calc_col (window, mk->mox, &r, &sep);

          if (col != FAILURE)
            if (! sep && (mk->breturn == 1))
              drag_column (window, col, &r, mk);
            else
              if (sep && (mk->mobutton & 0x0001) || (mk->breturn == 2)) drag_colsep (window, col, &r, sep && (mk->mobutton & 0x0001));
        } /* if */
        else
        {
          if (! (mk->shift || mk->ctrl)) unclick_window (window); /* deselect */
          if ((mk->breturn == 1) && (mk->mobutton & 0x0001))      /* rubberband operation */
            rubber_objs (window, mk);
        } /* else */
      } /* else, if, else */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
  if (sel_window != NULL) invert_objs (window, sel_objs);
} /* wi_unclick */

/*****************************************************************************/
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      i;
  LONG      pos;
  LIST_SPEC *listp;

  if (menu_key (window, mk)) return (TRUE);

  if (mk->ascii_code == ESC) updt_lswin (window);

  if (mk->scan_code == TAB)
  {
    listp = (LIST_SPEC *)window->special;

    if (mk->shift)                      /* tab left */
    {
      for (i = pos = 0; (i < listp->cols) && (pos < window->doc.x); i++)
        pos += abs (listp->colwidth [i]);

      if (pos != 0)                     /* not at left margin */
      {
        pos -= abs (listp->colwidth [i - 1]);
        arrow_window (window, WA_LFLINE, (WORD)(window->doc.x - pos));
      } /* if */
    } /* if */
    else                                /* tab right */
    {
      for (i = pos = 0; (i < listp->cols) && (pos <= window->doc.x); i++)
        pos += abs (listp->colwidth [i]);

      arrow_window (window, WA_RTLINE, (WORD)(pos - window->doc.x));
    } /* else */

    return (TRUE);
  } /* if */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/
/* Cut/Copy/Paste fr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN   ext;
  WORD      h, i, pos, col, width, status;
  LIST_SPEC *listp;

  ext   = (action & DO_EXTERNAL) != 0;
  listp = (LIST_SPEC *)window->special;
  ext   = ext; /* no warning please */

  switch (action & 0x00FF)
  {
    case DO_UNDO   : pos   = listp->oldpos;
                     col   = listp->oldcol;
                     width = listp->oldwidth;

                     switch (listp->operation)
                     {
                       case OP_DELCOL  : listp->operation = OP_INSCOL;
                                         mem_move (&listp->columns [pos + 1], &listp->columns [pos], (listp->cols - pos) * sizeof (WORD));
                                         mem_move (&listp->colwidth [pos + 1], &listp->colwidth [pos], (listp->cols - pos) * sizeof (WORD));

                                         listp->cols++;
                                         listp->columns [pos]  = col;
                                         listp->colwidth [pos] = width;
                                         break;
                       case OP_INSCOL  : listp->operation = OP_DELCOL;
                                         listp->oldcol    = listp->columns [pos];
                                         listp->oldwidth  = listp->colwidth [pos];
                                         listp->cols--;

                                         mem_move (&listp->columns [pos], &listp->columns [pos + 1], (listp->cols - pos) * sizeof (WORD));
                                         mem_move (&listp->colwidth [pos], &listp->colwidth [pos + 1], (listp->cols - pos) * sizeof (WORD));
                                         break;
                       case OP_SIZECOL : listp->oldwidth       = listp->colwidth [pos];
                                         listp->colwidth [pos] = width;
                                         break;
                       case OP_MOVECOL : listp->oldpos = col;
                                         listp->oldcol = pos;
                                         move_col (listp, col, pos);
                                         break;
                       case OP_DELREC  : if (db_undelete (listp->db->base, listp->oldaddr, &status))
                                           listp->operation = OP_INSREC;
                                         dbtest (listp->db);
                                         updt_lsall (listp->db, listp->table, FALSE, TRUE);
                                         break;
                       case OP_INSREC  : if (db_delete (listp->db->base, rtable (listp->table), listp->oldaddr, &status))
                                           listp->operation = OP_DELREC;
                                         dbtest (listp->db);
                                         if (VTBL (listp->table)) check_vtable (listp->table, listp->oldaddr);
                                         updt_lsall (listp->db, listp->table, TRUE, TRUE);
                                         break;
                     } /* switch */

                     if ((listp->operation != OP_DELREC) && (listp->operation != OP_INSREC)) update_col (window, TRUE);
                     break;
    case DO_CUT    : break;
    case DO_COPY   : break;
    case DO_PASTE  : if (listp->operation == OP_DELREC)
                       wi_edit (window, DO_UNDO);
                     else
                       objop (window, sel_objs, OBJ_UNDEL, NULL); /* trash window */
                     break;
    case DO_CLEAR  : objop (window, sel_objs, OBJ_DEL, NULL);
                     break;
    case DO_SELALL : unclick_window (sel_window);
                     sel_window = window;
                     h          = min (window->scroll.h / window->yfac, listp->lines);
                     for (i = 0; i < h; i++) setincl (sel_objs, i);
                     invert_objs (window, sel_objs);
                     break;
  } /* switch */
} /* wi_edit */

/*****************************************************************************/

