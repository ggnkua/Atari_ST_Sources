/*****************************************************************************
 *
 * Module : BNTABLE.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 17.06.96
 *
 *
 * Description: This module implements the base new table dialog box.
 *
 * History:
 * 17.06.96: Tabel names are no longer uppercase only
 * 04.01.95: Using new function names of controls module
 * 14.12.94: New scroll bar control used
 * 14.04.94: Functionality of hidden table added
 * 28.10.93: Init color setting correct now in set_ntable
 * 21.10.93: New color selection added
 * 11.09.93: set_itext -> set_str, set_text removed
 * 08.09.93: set_ptext -> set_str
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "controls.h"
#include "event.h"
#include "dialog.h"
#include "bclick.h"
#include "bicons.h"
#include "butil.h"

#include "export.h"
#include "bntable.h"

/****** DEFINES **************************************************************/

#define MAX_ITEXT   12  /* length of text below icon */

/****** TYPES ****************************************************************/

typedef struct
{
  SYSTABLE *tablep;
  WINDOWP  base_window;
  WORD     x;
  WORD     y;
  WORD     icon;
} NT_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj; /* will be set for modal dialogue boxes */
LOCAL WORD    new_table;
LOCAL NT_SPEC nt_spec;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    cb_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    sb_callback  _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box          _((WINDOWP window, BOOLEAN grow, WINDOWP base_window, WORD class, WORD obj, WORD table));

LOCAL VOID    set_ntable   _((NT_SPEC *nt_spec));
LOCAL VOID    open_ntable  _((WINDOWP window));
LOCAL VOID    close_ntable _((WINDOWP window));
LOCAL VOID    click_ntable _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_ntable   _((WINDOWP window, MKINFO *mk));

LOCAL WORD    get_icolor   _((OBJECT *tree, WORD object));
LOCAL VOID    set_icolor   _((OBJECT *tree, WORD object, WORD color));

/*****************************************************************************/

GLOBAL WORD mnewtable (base_window, tablep, x, y, ret_table)
WINDOWP  base_window;
SYSTABLE *tablep;
WORD     x, y;
WORD     *ret_table;

{
  WINDOWP   window;
  WORD      table;
  WORD      ret;
  WORD      object;
  WORD      wbox, hbox;
  STRING    name;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)base_window->special;

  if (tablep == NULL)
    table = -1;
  else
    table = tablep->table;

  if (table < 0)                        /* new table */
  {
    wbox = base_spec->wbox;
    hbox = base_spec->hbox;

    object = FNEWTBL;

    if ((x < 0) || (y < 0))
    {
      x = (base_window->doc.x * base_window->xfac + base_window->scroll.w / 2) / wbox;
      y = (base_window->doc.y * base_window->yfac + base_window->scroll.h / 2) / hbox;
    } /* if */
    else
    {
      x = (x + base_window->doc.x * base_window->xfac - base_window->scroll.x) / wbox;
      y = (y + base_window->doc.y * base_window->yfac - base_window->scroll.y) / hbox;
    }
  } /* if */
  else
  {
    object = FCHGTBL;

    x = base_spec->systattr [table].x;
    y = base_spec->systattr [table].y;
  } /* else */

  strcpy (name, FREETXT (object));
  exit_obj  = NIL;
  new_table = NIL;

  window = search_window (CLASS_DIALOG, SRCH_ANY, NEWTABLE);

  if (window == NULL)
  {
    form_center (newtable, &ret, &ret, &ret, &ret);
    window = crt_dialog (newtable, NULL, NEWTABLE, name, WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_ntable;
      window->close   = close_ntable;
      window->click   = click_ntable;
      window->key     = key_ntable;
      window->special = (LONG)&nt_spec;
    } /* if */
  } /* if */
  else
    strcpy (window->name, name);

  if (window != NULL)
  {
    if ((table < 0) || (table >= NUM_SYSTABLES))
    {
      undo_state (newtable, NTNAME, DISABLED);
      undo_state (newtable, NTOK,   DISABLED);
      do_flags (newtable, NTTABLE, EDITABLE);
      window->edit_obj = find_flags (newtable, ROOT, EDITABLE);
    } /* if */
    else
    {
      do_state (newtable, NTNAME, DISABLED);
      do_state (newtable, NTOK,   DISABLED);
      undo_flags (newtable, NTTABLE, EDITABLE);
      window->edit_obj = NIL;
    } /* else */

    window->edit_inx = NIL;

    nt_spec.tablep      = tablep;
    nt_spec.base_window = base_window;
    nt_spec.x           = x;
    nt_spec.y           = y;
    nt_spec.icon        = 0;

    set_ntable (&nt_spec);

    if (! open_dialog (NEWTABLE)) hndl_alert (ERR_NOOPEN);
  } /* if */

  *ret_table = new_table;

  return (exit_obj);
} /* mnewtable */

/*****************************************************************************/

LOCAL LONG cb_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)(get_str (popups, COWHITE + (WORD)index) + 1));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.x++;
                            r.y++;
                            r.w  = 2 * gl_wbox;
                            r.h -= 2;

                            r.x++;
                            if (visible_part) r.y++;
                            r.w -= 2;
                            if (visible_part) r.h -= 2;
                            DrawOwnerColor (lb_ownerdraw, &r, (WORD)index, text, 2);
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
} /* cb_callback */

/*****************************************************************************/

LOCAL LONG sb_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  WINDOWP      window;
  LOCAL STRING s;
  WORD         width, height;
  WORD         *pmask, *pdata;
  SYSICON      *sysicon;
  NT_SPEC      *nt_spec;
  BASE_SPEC    *base_spec;

  window    = (WINDOWP)ScrollBarGetSpec (tree, obj);
  nt_spec   = (NT_SPEC *)window->special;
  base_spec = (BASE_SPEC *)nt_spec->base_window->special;

  switch (msg)
  {
    case SBN_CHANGED : sprintf (s, "%ld", item);
                       set_str (tree, NTINUM, s);
                       draw_object (window, NTINUM);

                       sysicon = &base_spec->sysicon [item];
                       width   = sysicon->width;
                       height  = sysicon->height;
                       pmask   = &sysicon->icon.icondef [0];
                       pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

                       set_idata (newtable, NTICON, pmask, pdata, width, height);
                       trans_gimage (newtable, NTICON);
                       draw_object (window, NTICNBOX);

                       nt_spec->icon = item;
                       break;
  } /* switch */

  return (0L);
} /* sb_callback */

/*****************************************************************************/

LOCAL VOID box (window, grow, base_window, class, obj, table)
WINDOWP window;
BOOLEAN grow;
WINDOWP base_window;
WORD    class;
WORD    obj;
WORD    table;

{
  RECT l, b;

  b_get_rect (base_window, class, obj, table, &l, TRUE, FALSE);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID set_ntable (nt_spec)
NT_SPEC *nt_spec;

{
  WORD      icon, color;
  FULLNAME  dbname;
  STRING    s;
  WORD      w;
  WORD      width, height;
  WORD      *pmask, *pdata;
  SYSICON   *sysicon;
  SYSTABLE  *tablep;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)nt_spec->base_window->special;
  tablep    = nt_spec->tablep;

  w = newtable [NTDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy (get_str (newtable, NTDBNAME), dbname);

  if (tablep == NULL)                                 /* it's a new table */
  {
    color = BLACK;
    icon  = 0;

    do_state (newtable, NTOK, DISABLED);
    set_str (newtable, NTTABLE, "");
    set_checkbox (newtable, NTHIDE, FALSE);
    set_checkbox (newtable, NTMTON, FALSE);
    set_str (newtable, NTICON, FREETXT (FTABLE));
  } /* if */
  else
  {
    if (tablep->icon >= base_spec->num_icons) tablep->icon = 0;

    color = tablep->color;
    icon  = tablep->icon;

    strncpy (s, tablep->name, MAX_ITEXT);
    s [MAX_ITEXT] = EOS;

    set_str (newtable, NTTABLE, tablep->name);
    set_checkbox (newtable, NTHIDE, tablep->flags & TBL_HIDDEN);
    set_checkbox (newtable, NTMTON, tablep->flags & TBL_MTONREL);
    set_str (newtable, NTICON, s);
  } /* else */

  sysicon = &base_spec->sysicon [icon];
  width   = sysicon->width;
  height  = sysicon->height;
  pmask   = &sysicon->icon.icondef [0];
  pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

  set_icolor (newtable, NTICON, color);
  set_idata (newtable, NTICON, pmask, pdata, width, height);
  trans_gimage (newtable, NTICON);

  nt_spec->icon = icon;

  sprintf (s, "%d", icon);
  set_str (newtable, NTINUM, s);

  ListBoxSetCallback (newtable, NTCOLOR, cb_callback);
  ListBoxSetStyle (newtable, NTCOLOR, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (newtable, NTCOLOR, LBS_VSCROLL, FALSE);
  ListBoxSetCount (newtable, NTCOLOR, min (colors, 16), NULL);
  ListBoxSetCurSel (newtable, NTCOLOR, color);
  ListBoxSetLeftOffset (newtable, NTCOLOR, 0);

  ScrollBarSetCount (newtable, NTSB, base_spec->num_icons, FALSE);
  ScrollBarSetPageSize (newtable, NTSB, 1L, FALSE);
  ScrollBarSetPos (newtable, NTSB, icon, FALSE);
  ScrollBarSetCallback (newtable, NTSB, sb_callback);
} /* set_ntable */

/*****************************************************************************/

LOCAL VOID open_ntable (window)
WINDOWP window;

{
  WORD    table;
  NT_SPEC *nt_spec;

  nt_spec = (NT_SPEC *)window->special;

  if (nt_spec->tablep == NULL)
    table = -1;
  else
    table = nt_spec->tablep->table;

  box (window, TRUE, nt_spec->base_window, SEL_TABLE, table, table);
} /* open_ntable */

/*****************************************************************************/

LOCAL VOID close_ntable (window)
WINDOWP window;

{
  WORD    table;
  NT_SPEC *nt_spec;

  nt_spec = (NT_SPEC *)window->special;

  if (nt_spec->tablep == NULL)
    table = -1;
  else
    table = nt_spec->tablep->table;

  box (window, FALSE, nt_spec->base_window, SEL_TABLE, table, table);
} /* close_ntable */

/*****************************************************************************/

LOCAL VOID click_ntable (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD       w, h, item;
  WORD       table, found, icon;
  UWORD      flags;
  TABLENAME  name;
  BOOLEAN    table_unique;
  LONGSTR    s;
  BYTE       *p;
  WORD       mask [128];
  WORD       data [128];
  WORD       width, height;
  TABLE_INFO table_info;
  SYSTABLE   *systable, *tablep;
  SYSTATTR   *systattr;
  NT_SPEC    *nt_spec;
  BASE_SPEC  *base_spec;

  nt_spec   = (NT_SPEC *)window->special;
  base_spec = (BASE_SPEC *)nt_spec->base_window->special;
  tablep    = nt_spec->tablep;
  table     = FAILURE;

  if (tablep != NULL) table = tablep->table;

  switch (window->exit_obj)
  {
    case NTOK     : get_ptext (newtable, NTTABLE, name);
                    flags  = get_checkbox (newtable, NTHIDE) ? TBL_HIDDEN  : 0;
                    flags |= get_checkbox (newtable, NTMTON) ? TBL_MTONREL : 0;
                    make_id (name);

                    p = get_str (newtable, NTTABLE);
                    if (strcmpi (name, p) != 0)
                    {
                      sprintf (s, alerts [ERR_IDTABLE], name);
                      open_alert (s);
                    } /* if */

                    strcpy (table_info.name, name);
                    found = v_tableinfo (base_spec, FAILURE, &table_info);
                    table_unique = (found == FAILURE) || (found == table);

                    if (! table_unique)
                    {
                      sprintf (s, alerts [ERR_NOTUNIQUE], name);
                      open_alert (s);                   /* table name was already used */
                      window->flags &= ~ WI_DLCLOSE;    /* don't close window */
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                      return;
                    } /* if */

                    if (table == FAILURE)               /* build new table */
                    {
                      switch (check_all (base_spec, 1, 1, 1))
                      {
                        case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return;
                        case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return;
                        case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return;
                      } /* if */

                      table = add_table (base_spec, name, flags);
                    } /* if */
                    else                                /* change name of table */
                    {
                      if (table >= NUM_SYSTABLES) strcpy (tablep->name, name);
                      systattr  = &base_spec->systattr [table];
                      flags    |= tablep->flags & ~ (TBL_MTONREL | TBL_HIDDEN);

                      tablep->flags    = flags | UPD_FLAG;
                      systattr->flags |= UPD_FLAG;
                    } /* else */

                    get_tblwh (base_spec, table, &w, &h);
                    systable = &base_spec->systable [table];
                    systattr = &base_spec->systattr [table];

                    systable->color  = get_icolor (newtable, NTICON);
                    systable->icon   = nt_spec->icon;
                    systattr->x      = nt_spec->x;
                    systattr->y      = nt_spec->y;
                    systattr->width  = w;
                    systattr->height = h;

                    set_redraw (nt_spec->base_window, &nt_spec->base_window->scroll);
                    base_spec->modified = TRUE;
                    break;
    case NTHELP   : hndl_help (HNEWTBL);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NTCOLOR  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (colors, 16));
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                    {
                      set_icolor (window->object, NTICON, item);
                      draw_object (window, NTICON);
                    } /* if */
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case NTSB     : ScrollBarSetSpec (window->object, window->exit_obj, (LONG)window);
                    item = ScrollBarClick (window->object, window->exit_obj, mk);

                    nt_spec->icon = item;
                    break;
    case NTILOAD  : if (! check_icon (base_spec, 1))
                      hndl_alert (ERR_NOICONS);
                    else
                      if (load_icon (mask, data, &width, &height, FLOADICN))
                      {
                        icon = add_icon (base_spec, mask, data, width, height);

                        sprintf (s, "%d", icon);
                        set_str (newtable, NTINUM, s);

                        set_idata (newtable, NTICON, mask, data, width, height);
                        trans_gimage (newtable, NTICON);

                        nt_spec->icon       = icon;
                        base_spec->modified = TRUE;

                        ScrollBarSetCount (newtable, NTSB, base_spec->num_icons, FALSE);
                        ScrollBarSetPos (newtable, NTSB, icon, TRUE);
                      } /* if */

                    set_redraw (window, &window->scroll);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    break;
  } /* switch */

  new_table = table;
  exit_obj  = window->exit_obj;
} /* click_ntable */

/*****************************************************************************/

LOCAL BOOLEAN key_ntable (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  TABLENAME name;

  switch (window->edit_obj)
  {
    case NTTABLE : get_ptext (newtable, NTTABLE, name);
                   make_id (name);

                   if ((*name == EOS) == ! is_state (newtable, NTOK, DISABLED))
                   {
                     flip_state (newtable, NTOK, DISABLED);
                     draw_object (window, NTOK);
                   } /* if */
                   break;
  } /* switch */

  return (FALSE);
} /* key_ntable */

/*****************************************************************************/

LOCAL WORD get_icolor (tree, object)
OBJECT *tree;
WORD   object;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;

  return ((UWORD)piconblk->ib_char >> 12);
} /* get_icolor */

/*****************************************************************************/

LOCAL VOID set_icolor (tree, object, color)
OBJECT *tree;
WORD   object;
WORD   color;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;
  piconblk->ib_char = (color << 12) | (piconblk->ib_char & 0xFFF);      /* set color of icon data */
} /* set_icolor */

/*****************************************************************************/

