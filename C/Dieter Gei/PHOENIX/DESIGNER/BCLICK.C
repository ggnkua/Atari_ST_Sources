/*****************************************************************************
 *
 * Module : BCLICK.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 29.09.94
 *
 *
 * Description: This module implements the clicking inside a base window.
 *
 * History:
 * 29.09.94: Function draw_arrow modified to look like draw_lookups in BASE.C
 * 20.11.93: Old mselfont.h deleted
 * 08.09.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "clipbrd.h"
#include "desktop.h"
#include "dialog.h"
#include "bntable.h"
#include "bnfield.h"
#include "bnkey.h"
#include "brules.h"
#include "butil.h"
#include "mask.h"
#include "mclick.h"
#include "menu.h"
#include "mselect.h"

#include "export.h"
#include "bclick.h"

/****** DEFINES **************************************************************/

#define DRAG_IRULE  1   /* for dragging integrity rules */
#define DRAG_LOOKUP 2   /* for dragging lookup rules */

/****** TYPES ****************************************************************/

typedef struct

{
  WORD src_table;
  WORD src_obj;         /* key (integrity), field (lookup) */
  WORD dst_table;
  WORD dst_obj;         /* key (integrity), field (lookup) */
} RULE;                 /* integrity/lookup rule */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN put_rect      _((WINDOWP window, WORD table, RECT *rect));

LOCAL BOOLEAN hndl_table    _((WINDOWP src_window, WINDOWP dst_window, WORD obj, RECT *r, MKINFO *mk, RECT *r_table));
LOCAL BOOLEAN hndl_field    _((WINDOWP src_window, WINDOWP dst_window, WORD obj, RECT *r, MKINFO *mk));
LOCAL BOOLEAN hndl_key      _((WINDOWP src_window, WINDOWP dst_window, WORD obj, RECT *r, MKINFO *mk));
LOCAL VOID    hndl_objs     _((WINDOWP src_window, WINDOWP dst_window, WORD end, SET objs, WORD class, RECT *all, RECT *r, MKINFO *mk));

LOCAL WORD    find_rules    _((WINDOWP window, WORD src_table, WORD class, WORD src_obj, RECT *r, RULE *rule));
LOCAL BOOLEAN hndl_rules    _((WINDOWP window, WORD src_table, WORD class, WORD src_obj, RECT *r));
LOCAL VOID    do_rules      _((WINDOWP window, WORD class, MKINFO *mk));

LOCAL WORD    search_lookup _((BASE_SPEC *base_spec, WORD table, WORD column, WORD ref_table, WORD ref_column));
LOCAL BOOLEAN exist_lookup  _((BASE_SPEC *base_spec, WORD table, WORD column));
LOCAL WORD    find_lookups  _((WINDOWP window, WORD src_table, WORD src_obj, RECT *r, RULE *rule));
LOCAL BOOLEAN hndl_lookups  _((WINDOWP window, WORD src_table, WORD src_obj, RECT *r));
LOCAL VOID    do_lookups    _((WINDOWP window, WORD class, MKINFO *mk));

LOCAL VOID    drag_objs     _((WINDOWP window, WORD class, SET objs, MKINFO *mk));
LOCAL BOOLEAN drag_icon     _((WINDOWP window, WORD obj, WORD *x, WORD *y));
LOCAL VOID    drag_arrow    _((WINDOWP window, RECT *r, RECT *diff, RECT *bound, WORD src_table, WORD class, WORD src_obj, WORD mode));
LOCAL VOID    draw_line     _((WINDOWP window, RECT *r, RECT *diff, WORD src_table, WORD class, WORD src_obj, WORD mode));
LOCAL VOID    draw_arrow    _((WINDOWP window, WORD ref_table, WORD ref_index, WORD rel_table, WORD rel_index, WORD mode));
LOCAL VOID    fill_select   _((WINDOWP window, SET objs, RECT *area));
LOCAL VOID    invert_objs   _((WINDOWP window, WORD class, SET objs, WORD table));
LOCAL VOID    rubber_objs   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID b_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      table, field, key;
  WORD      old_table, old_class;
  WORD      obj, menu_height;
  WORD      old_tool;
  WORD      x, y;
  BOOLEAN   same;
  RECT      r;
  SET       new_objs;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  obj       = NIL;
  old_table = sel.table;
  old_class = sel.class;

  if (sel_window != window) unclick_window (sel_window);

  if (inside (mk->mox, mk->moy, &window->scroll))       /* inside scroll area */
  {
    if ((base_spec->tool == DBARROW) && (! mk->alt))
      sel = b_find_objs (window, mk);
    else
    {
      unclick_window (window);
      if (find_top () != window) return;

      sel = b_find_objs (window, mk);
      mk->alt = TRUE;

      if (base_spec->tool == DBARROW) set_mouse (THIN_CROSS, NULL);

      if ((mk->breturn == 1) && (mk->mobutton & 0x001)) /* drag operation */
        if (base_spec->show_rels)
          do_rules (window, sel.class, mk);
        else
          do_lookups (window, sel.class, mk);

      if (base_spec->tool == DBARROW) set_mouse (ARROW, NULL);

      return;
    } /* else */
  } /* if */
  else
    if (inside (mk->mox, mk->moy, &window->work))       /* handle icons */
    {
      old_tool = base_spec->tool;
      unclick_window (window);

      menu_height   = (window->menu != NULL) ? gl_hattr : 0;
      dbicons->ob_x = window->work.x;
      dbicons->ob_y = window->work.y + menu_height;

      obj = objc_find (dbicons, ROOT, MAX_DEPTH, mk->mox, mk->moy);
      if ((DBARROW <= obj) && (obj <= DBLINK))
      {
        base_spec->tool = obj;

        if (old_tool != base_spec->tool)
        {
          objc_offset (dbicons, old_tool, &x, &y);
          xywh2rect (x, y, dbicons [old_tool].ob_width, dbicons [old_tool].ob_height, &r);
          redraw_window (window, &r);

          objc_offset (dbicons, base_spec->tool, &x, &y);
          xywh2rect (x, y, dbicons [base_spec->tool].ob_width, dbicons [base_spec->tool].ob_height, &r);
          redraw_window (window, &r);
        } /* if */

        switch (base_spec->tool)
        {
          case DBARROW : window->mousenum = ARROW;      break;
          case DBLINK  : window->mousenum = THIN_CROSS; break;
          default      : window->mousenum = ARROW;      break;
        } /* switch */

        return;
      } /* if */

      obj = objc_find (dbicons, ROOT, MAX_DEPTH, mk->mox, mk->moy);

      if (mk->breturn == 1)
      {
        if (obj >= ITABLE) same = drag_icon (window, obj, &x, &y);
        if (! same || ! inside (x, y, &window->scroll)) obj = NIL;      /* same window? */
        table = sel.table;
      } /* if */

      switch (obj)
      {
        case ITABLE : if (mk->breturn == 2)
                      {
                        x = -1;
                        y = -1;
                      } /* if */

                      if (mnewtable (window, NULL, x, y, &table) == NTOK)
                      {
                        sel.class  = SEL_TABLE;
                        sel.table  = table;
                        sel_window = window;
                        setincl (sel_objs, table);
                      } /* if */
                      break;
        case IFIELD : if (mk->breturn == 2) table = old_table;
                      if (table == FAILURE)
                        hndl_alert (ERR_FIELDINTBL);
                      else
                        if (mnewfield (window, table, NULL, NULL, &field) == NFOK)
                        {
                          sel.class  = SEL_FIELD;
                          sel.table  = table;
                          sel.field  = field;
                          sel_window = window;
                          setincl (sel_objs, field);
                        } /* if */
                      break;
        case IKEY   : if (mk->breturn == 2) table = old_table;
                      if (table == FAILURE)
                        hndl_alert (ERR_KEYINTBL);
                      else
                        if (mnewkey (window, table, NULL, &key) == NKOK)
                        {
                          sel.class  = inx2obj (base_spec, table, key, &obj);
                          sel.table  = table;
                          sel.field  = FAILURE;
                          sel_window = window;
                          setincl (sel_objs, obj);
                        } /* if */
                      break;
        case IMASK  : if (mk->breturn == 2) table = old_table;
                      mselect (base_spec, table);
                      break;
      } /* switch */

      return;
    } /* if */

  switch (sel.class)
  {
    case SEL_NONE  : obj = NIL;       break;
    case SEL_TABLE : obj = sel.table; break;
    case SEL_FIELD : obj = sel.field; break;
    case SEL_KEY   : obj = sel.key;   break;
    default        : obj = NIL;       break;
  } /* switch */

  if ((mk->mobutton & 0x0003) &&                        /* no deselect if table was selected */
      (old_class == SEL_TABLE) &&
      (sel.class == SEL_NONE)) sel.class = SEL_TABLE;

  if ((old_class != sel.class) ||                       /* deselect old objects */
      (old_table != sel.table) && (sel.class != SEL_TABLE))
  {
    invert_objs (window, old_class, sel_objs, old_table);
    setclr (sel_objs);
  } /* if */

  if (obj != NIL)
  {
    if (base_spec->tool == DBLINK) mk->alt = TRUE;

    setclr (new_objs);
    setincl (new_objs, obj);                            /* actual object */

    if (mk->shift)
    {
      invert_objs (window, sel.class, new_objs, sel.table);
      setxor (sel_objs, new_objs);
      if (! setin (sel_objs, obj)) obj = NIL;           /* deselect */
    } /* if */
    else
    {
      if (! setin (sel_objs, obj))                      /* deselect old objects */
      {
        invert_objs (window, sel.class, sel_objs, old_table);
        setclr (sel_objs);
        invert_objs (window, sel.class, new_objs, sel.table);
      } /* if */

      setor (sel_objs, new_objs);
    } /* else */

    sel_window = setcmp (sel_objs, NULL) ? NULL : window;

    if ((sel_window != NULL) && (obj != NIL))
    {
      if ((mk->breturn == 1) && (mk->mobutton & 0x003)) /* drag operation */
        drag_objs (window, sel.class, sel_objs, mk);

      if (mk->breturn == 2)                             /* double clicking on object */
        if (window->objop != NULL)
            (*window->objop) (sel_window, sel_objs, OBJ_OPEN);
    } /* if */
  } /* if */
  else
    if (inside (mk->mox, mk->moy, &window->scroll))     /* inside scroll area */
    {
      if (! (mk->shift || mk->ctrl)) unclick_window (window); /* deselect */
      if ((mk->breturn == 1) && (mk->mobutton & 0x0001))      /* rubber band operation */
        rubber_objs (window, mk);
    } /* if, else */
} /* b_click */

/*****************************************************************************/

GLOBAL VOID b_unclick (window)
WINDOWP window;

{
  invert_objs (window, sel.class, sel_objs, sel.table);

  sel.class = SEL_NONE;
  sel.table = FAILURE;
  sel.field = FAILURE;
  sel.key   = FAILURE;
} /* b_unclick */

/*****************************************************************************/

GLOBAL VOID b_get_shadow (out_handle, wbox, factor, width, height)
WORD out_handle;
WORD wbox;
WORD factor;
WORD *width;
WORD *height;

{
  *width = *height = wbox / 2 * factor / 100;

  if (out_handle == vdi_handle)
    if (gl_hbox <= 8) *height /= 2;    /* low resolution on screen */
} /* b_get_shadow */

/*****************************************************************************/

GLOBAL VOID b_get_rect (window, class, obj, table, rect, frame, shadow)
WINDOWP window;
WORD    class;
WORD    obj;
WORD    table;
RECT    *rect;
BOOLEAN frame;
BOOLEAN shadow;

{
  WORD       wbox, hbox;
  WORD       width, height;
  WORD       box_ldist;
  TABLE_INFO table_info;
  BASE_SPEC  *base_spec;

  xywh2rect (0, 0, 0, 0, rect);

  if (table >= 0)
  {
    base_spec = (BASE_SPEC *)window->special;

    wbox = base_spec->wbox;
    hbox = base_spec->hbox;

    box_ldist = BOX_LDIST * base_spec->y_factor / 100;

    rect->x = base_spec->systattr [table].x * wbox - window->doc.x * window->xfac + window->scroll.x;
    rect->y = base_spec->systattr [table].y * hbox - window->doc.y * window->yfac + window->scroll.y;
    rect->w = base_spec->systattr [table].width * wbox;
    rect->h = base_spec->systattr [table].height * hbox;

    switch (class)
    {
      case SEL_TABLE : if (frame)
                       {
                         if (base_spec->systable [table].cols == 1) rect->h = 2 * hbox;

                         rect->x -= FRAME;
                         rect->y -= FRAME;
                         rect->w += 2 * FRAME;
                         rect->h += 2 * FRAME - box_ldist;      /* don't leave too much space at bottom */
                       } /* if */

                       if (shadow)
                       {
                         b_get_shadow (vdi_handle, base_spec->wbox, base_spec->x_factor, &width, &height);
                         rect->w += width;
                         rect->h += height;
                       } /* if */
                       break;
      case SEL_FIELD : if (obj >= 0)
                       {
                         rect->y += hbox * (obj);
                         rect->h  = hbox - box_ldist;
                       } /* if */
                       break;
      case SEL_KEY   : if (obj >= 0)
                       {
                         v_tableinfo (base_spec, table, &table_info);
                         rect->y += hbox * (obj + 1 + table_info.cols - 1);
                         rect->h  = hbox - box_ldist;
                       } /* if */
                       break;
    } /* switch */
  } /* if */
} /* b_get_rect */

/*****************************************************************************/

GLOBAL VOID b_get_doc (base_spec, xfac, yfac, docw, doch)
BASE_SPEC *base_spec;
WORD      xfac, yfac;
LONG      *docw, *doch;

{
  WORD     table;
  LONG     w, h;
  SYSTATTR *systattr;

  w = 0;
  h = 0;

  systattr = &base_spec->systattr [base_spec->first_table];

  for (table = base_spec->first_table; table < base_spec->num_tables; table++, systattr++)
  {
    w = max (w, systattr->x + systattr->width);
    h = max (h, systattr->y + systattr->height);
  } /* for */

  *docw = (base_spec->wbox * w + xfac - 1) / xfac;
  *doch = (base_spec->hbox * h + yfac - 1) / yfac;
} /* b_get_doc */

/*****************************************************************************/

GLOBAL VOID b_obj_clear (window, class, objs, r)
WINDOWP window;
WORD    class;
SET     objs;
RECT    *r;

{
  WORD       i, end;
  WORD       table, key;
  BOOLEAN    redraw;
  RECT       scroll, ob;
  LONGSTR    s;
  FIELD_INFO field_info;
  INDEX_INFO index_info;
  BASE_SPEC  *base_spec;
  SYSTABLE   *systable;
  SYSTATTR   *systattr;

  base_spec = (BASE_SPEC *)window->special;
  table     = sel.table;
  systable  = &base_spec->systable [table];
  redraw    = FALSE;

  if ((class == SEL_TABLE) && (! base_spec->new) && (systable->flags & MOD_FLAG))
    if (hndl_alert (ERR_DELTRASH) == 2) return; /* user clicked on "No" */

  switch (class)
  {
    case SEL_TABLE : end = base_spec->num_tables; break;
    case SEL_FIELD : end = systable->cols;        break;
    case SEL_KEY   : end = systable->indexes;     break;
    default        : end = NIL;                   break;
  } /* switch */

  systattr = &base_spec->systattr [table];

  if ((class == SEL_TABLE) || (! base_spec->show_rels) || (systable->children > 0) || (systable->parents > 0))
    scroll = window->scroll;
  else
    b_get_rect (window, SEL_TABLE, NIL, table, &scroll, TRUE, TRUE);

  for (i = end - 1; i >= 0; i--)
    if (setin (objs, i))
    {
      switch (class)
      {
        case SEL_TABLE : if (del_table (base_spec, i) == SUCCESS)
                           redraw = TRUE;
                         else
                           if (r != NULL)
                           {
                             b_get_rect (window, class, i, i, &ob, TRUE, FALSE);
                             graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
                           } /* if */
                           else
                           {
                             sprintf (s, alerts [ERR_DELTABLE], base_spec->basename, systable->name);
                             open_alert (s);
                           } /* else */
                         break;
        case SEL_FIELD : if (del_field (base_spec, table, i) == SUCCESS)
                           redraw    = TRUE;
                         else
                           if (r != NULL)
                           {
                             b_get_rect (window, class, i, table, &ob, TRUE, FALSE);
                             graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
                           } /* if */
                           else
                           {
                             v_fieldinfo (base_spec, table, i, &field_info);
                             sprintf (s, alerts [ERR_DELFIELD], systable->name, field_info.name);
                             open_alert (s);
                           } /* else */
                         break;
        case SEL_KEY   : key = find_multikey (base_spec, table, i);
                         if (del_key (base_spec, table, key) == SUCCESS)
                           redraw = TRUE;
                         else
                           if (r != NULL)
                           {
                             b_get_rect (window, class, i, table, &ob, TRUE, FALSE);
                             graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
                           } /* if */
                           else
                           {
                             v_indexinfo (base_spec, table, i, &index_info);
                             sprintf (s, alerts [ERR_DELKEY], systable->name, index_info.name);
                             open_alert (s);
                           } /* else */
                         break;
      } /* switch */
    } /* if, for */

  if (class != SEL_TABLE) get_tblwh (base_spec, table, &systattr->width, &systattr->height);

  if (redraw)
  {
    unclick_window (window);
    set_redraw (window, &scroll);
    systattr->flags |= UPD_FLAG;
  } /* if */
} /* b_obj_clear */

/*****************************************************************************/

GLOBAL SEL_SPEC b_find_objs (window, mk)
WINDOWP  window;
MKINFO   *mk;

{
  WORD       start;
  WORD       table;
  WORD       hbox;
  RECT       r;
  SEL_SPEC   sel;
  TABLE_INFO table_info;
  BASE_SPEC  *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  sel.class = SEL_NONE;
  sel.table = FAILURE;
  sel.field = FAILURE;
  sel.key   = FAILURE;

  start = base_spec->first_table;
  hbox  = base_spec->hbox;

  for (table = base_spec->num_tables - 1; (table >= start) && (sel.table < 0); table--)
  {
    b_get_rect (window, SEL_TABLE, NIL, table, &r, TRUE, FALSE);        /* use frame */
    if (inside (mk->mox, mk->moy, &r)) sel.table = table;

    b_get_rect (window, SEL_TABLE, NIL, table, &r, FALSE, FALSE);

    if (inside (mk->mox, mk->moy, &r))
    {
      v_tableinfo (base_spec, table, &table_info);
      if (mk->moy - r.y - hbox >= 0) sel.field = (mk->moy - r.y - hbox) / hbox + 1;

      if (sel.field >= table_info.cols)                 /* user has clicked on multikey area */
      {
        sel.key   = sel.field - table_info.cols;
        sel.field = FAILURE;
      } /* if */
    } /* if */
  } /* for */

  if (sel.field >= 0) sel.class = SEL_FIELD;
  else
    if (sel.key >= 0) sel.class = SEL_KEY;
    else
      if (sel.table >= 0) sel.class = SEL_TABLE;

  return (sel);
} /* b_find_objs */

/*****************************************************************************/

LOCAL BOOLEAN put_rect (window, table, rect)
WINDOWP window;
WORD    table;
RECT    *rect;

{
  WORD      wbox, hbox;
  WORD      x, y, x_diff, y_diff;
  SYSTATTR  *systattr;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  systattr  = &base_spec->systattr [table];

  wbox = base_spec->wbox;
  hbox = base_spec->hbox;

  x = systattr->x;
  y = systattr->y;

  x_diff = rect->w / wbox;
  y_diff = rect->h / hbox;

  if ((x_diff != 0) || (y_diff != 0))
  {
    x += x_diff;
    y += y_diff;

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    systattr->x = x;
    systattr->y = y;

    systattr->flags |= UPD_FLAG;

    return (TRUE);
  } /* if */
  else
    return (FALSE);
} /* put_rect */

/*****************************************************************************/

LOCAL BOOLEAN hndl_table (src_window, dst_window, obj, r, mk, r_table)
WINDOWP src_window;
WINDOWP dst_window;
WORD    obj;
RECT    *r;
MKINFO  *mk;
RECT    *r_table;

{
  BOOLEAN    copy;
  WORD       button;
  WORD       i, table, color, icon;
  WORD       cols, indexes;
  WORD       src_abs, dst_abs;
  WORD       x, y;
  RECT       old, new, scroll;
  SYSTABLE   systable;
  BASE_SPEC  *src_spec;
  BASE_SPEC  *dst_spec;
  SYSTABLE   *src_table;
  SYSTABLE   *dst_table;
  SYSCOLUMN  *src_column;
  SYSCOLUMN  *dst_column;
  SYSINDEX   *src_index;
  SYSINDEX   *dst_index;
  SYSTATTR   *src_tattr;
  SYSTATTR   *dst_tattr;

  src_spec  = (BASE_SPEC *)src_window->special;
  dst_spec  = (BASE_SPEC *)dst_window->special;
  copy      = mk->shift;

  if ((r->w / src_spec->wbox == 0) && (r->h / src_spec->hbox == 0)) return (TRUE);

  if ((src_window == dst_window) && ! copy)     /* move table coordinates */
  {
    src_spec->modified = TRUE;

    b_get_rect (src_window, SEL_TABLE, obj, obj, &old, TRUE, TRUE);     /* get old rect */

    if (put_rect (src_window, obj, r))                                  /* coordinates have been changed */
    {
      b_get_rect (src_window, SEL_TABLE, obj, obj, &new, TRUE, TRUE);   /* get new rect */

      if ((src_spec->show_rels && (src_spec->num_rels > 0)) ||
          (! src_spec->show_rels && (src_spec->num_lookups > 0)))
        set_redraw (src_window, &src_window->scroll);                   /* draw rel or lookup arrows too */
      else
      {
        set_redraw (src_window, &old);
        set_redraw (src_window, &new);
      } /* if */
    } /* if */
  } /* if */
  else                          /* src_window != dst_window or copy */
  {
    src_table = &src_spec->systable [obj];
    src_tattr = &src_spec->systattr [obj];
    cols      = src_table->cols - 1;    /* field "Address" handled by add_table */
    indexes   = src_table->indexes - 1;

    switch (check_all (dst_spec, 1, src_table->cols, src_table->indexes))
    {
      case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return (FALSE);
      case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return (FALSE);
      case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return (FALSE);
    } /* if */

    color = src_table->color;
    icon  = src_table->icon;

    if (is_tunique (dst_spec, src_table->name))
    {
      table = add_table (dst_spec, src_table->name, src_table->flags);
      icon  = 0;
    } /* if */
    else
    {
      systable.table = FAILURE;
      systable.color = src_table->color;
      systable.icon  = src_table->icon;
      systable.flags = src_table->flags;
      strcpy (systable.name, src_table->name);

      button = mnewtable (dst_window, &systable, r_table->x, r_table->y, &table);
      if (button == NTCANCEL) return (FALSE);

      dst_table = &dst_spec->systable [table];
      color     = dst_table->color;
      icon      = dst_table->icon;
    } /* else */

    dst_table = &dst_spec->systable [table];
    dst_tattr = &dst_spec->systattr [table];

    x = r_table->x + FRAME + r->w - dst_window->scroll.x + dst_window->doc.x * dst_window->xfac;
    y = r_table->y + FRAME + r->h - dst_window->scroll.y + dst_window->doc.y * dst_window->yfac;

    x /= dst_spec->wbox;
    y /= dst_spec->hbox;

    if (src_window == dst_window) dst_table->icon = src_table->icon;

    dst_table->recs     = 0;
    dst_table->color    = color;
    dst_table->icon     = icon;
    dst_table->children = 0;
    dst_table->parents  = 0;
    dst_table->flags    = (dst_table->flags & ~DESIGNER_FLAGS) | INS_FLAG;

    dst_tattr->x     = x;
    dst_tattr->y     = y;
    dst_tattr->width = src_tattr->width;
    dst_tattr->height= src_tattr->height;

    if (dst_tattr->x < 0) dst_tattr->x = 0;
    if (dst_tattr->y < 0) dst_tattr->y = 0;

    /* handle columns */

    src_abs    = abscol (src_spec, obj, 1);     /* field "Address" already copied */
    src_column = &src_spec->syscolumn [src_abs];
    dst_abs    = abscol (dst_spec, table, 1);
    dst_column = &dst_spec->syscolumn [dst_abs];

    mem_lmove (dst_column, src_column, (LONG)sizeof (SYSCOLUMN) * cols);

    for (i = 0; i < cols; i++, dst_column++)
    {
      dst_column->address  = 0;
      dst_column->table    = table;
      dst_column->flags    = (dst_column->flags & ~DESIGNER_FLAGS) | INS_FLAG;

      if (src_window != dst_window) dst_column->format = dst_column->type;      /* set to standard format */
    } /* for */

    /* handle indexes */

    src_abs   = absinx (src_spec, obj, 1);      /* field "Address" already copied */
    src_index = &src_spec->sysindex [src_abs];
    dst_abs   = absinx (dst_spec, table, 1);
    dst_index = &dst_spec->sysindex [dst_abs];

    mem_lmove (dst_index, src_index, (LONG)sizeof (SYSINDEX) * indexes);

    for (i = 0; i < indexes; i++, dst_index++)
    {
      dst_index->address   = 0;
      dst_index->table     = table;
      dst_index->root      = 0;
      dst_index->num_keys  = 0;
      dst_index->flags     = (dst_index->flags & ~DESIGNER_FLAGS) | INS_FLAG;
    } /* for */

    dst_spec->modified     = TRUE;
    dst_spec->num_columns += cols;
    dst_spec->num_indexes += indexes;
    dst_table->cols        = src_table->cols;
    dst_table->size        = src_table->size;
    dst_table->indexes     = src_table->indexes;

    get_tblwh (dst_spec, table, &dst_tattr->width, &dst_tattr->height);
    b_get_rect (dst_window, SEL_TABLE, NIL, table, &scroll, TRUE, TRUE);
    set_redraw (dst_window, &scroll);
  } /* else */

  return (TRUE);
} /* hndl_table */

/*****************************************************************************/

LOCAL BOOLEAN hndl_field (src_window, dst_window, obj, r, mk)
WINDOWP src_window;
WINDOWP dst_window;
WORD    obj;
RECT    *r;
MKINFO  *mk;

{
  BOOLEAN   move;
  WORD      field, keys;
  WORD      src_table, dst_table;
  WORD      src_field, src_key;
  WORD      abs_col, abs_inx;
  WORD      button;
  RECT      ob, scroll;
  SEL_SPEC  sel_spec;
  SYSCOLUMN syscolumn;
  SYSINDEX  sysindex;
  SYSTATTR  *systattr;
  SYSCOLUMN *src_column;
  SYSINDEX  *src_index;
  BASE_SPEC *src_spec;
  BASE_SPEC *dst_spec;

  src_spec = (BASE_SPEC *)src_window->special;
  dst_spec = (BASE_SPEC *)dst_window->special;
  move     = mk->ctrl;
  sel_spec = b_find_objs (dst_window, mk);

  src_table = sel.table;
  dst_table = sel_spec.table;

  if ((sel.table == sel_spec.table) &&          /* src = dst */
      (sel.field == sel_spec.field)) dst_table = FAILURE;

  if (move)
    if (! ((src_window == dst_window) && (src_table == dst_table))) dst_table = FAILURE;

  if (dst_table == FAILURE)     /* no destination table found */
  {
    b_get_rect (src_window, SEL_FIELD, obj, src_table, &ob, TRUE, FALSE);
    graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
    return (TRUE);
  } /* if */

  src_field   = obj;
  abs_col     = abscol (src_spec, src_table, src_field);
  src_column  = &syscolumn;
  *src_column = src_spec->syscolumn [abs_col];
  src_index   = NULL;
  keys        = 0;

  src_column->flags = (src_column->flags & ~DESIGNER_FLAGS) | INS_FLAG;

  if (src_column->flags & COL_ISINDEX)
  {
    keys       = 1;
    src_key    = find_index (src_spec, src_table, src_field);
    abs_inx    = absinx (src_spec, src_table, src_key);
    src_index  = &sysindex;
    *src_index = src_spec->sysindex [abs_inx];
    if (find_primary (dst_spec, dst_table) != FAILURE) src_index->flags &= ~ INX_PRIMARY;
  } /* if */

  if (! move)
    switch (check_all (dst_spec, 0, 1, keys))
    {
      case ERR_ADD_TBL : hndl_alert (ERR_NOTABLES); return (FALSE);
      case ERR_ADD_COL : hndl_alert (ERR_NOFIELDS); return (FALSE);
      case ERR_ADD_INX : hndl_alert (ERR_NOKEYS);   return (FALSE);
    } /* if */

  if ((src_window == dst_window) && (src_table == dst_table))
  {
    if (move)
    {
      if (! move_field (src_spec, sel.table, sel.field, sel_spec.field))
      {
        b_get_rect (src_window, SEL_FIELD, obj, src_table, &ob, TRUE, FALSE);
        graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
        return (TRUE);
      } /* if */
    } /* if */
    else
    {
      systattr = &src_spec->systattr [src_table];

      src_column->number = FAILURE;

      button = mnewfield (src_window, src_table, src_column, src_index, &field);
      if (button == NFCANCEL) return (FALSE);

      get_tblwh (src_spec, src_table, &systattr->width, &systattr->height);
      b_get_rect (src_window, SEL_TABLE, NIL, src_table, &scroll, TRUE, TRUE);
      set_redraw (src_window, &scroll);
      systattr->flags    |= UPD_FLAG;
      src_spec->modified  = TRUE;
    } /* else */
  } /* if* */
  else                          /* src_table != dst_table or src_window != dst_window */
  {
    if (src_window != dst_window) src_column->format = src_column->type;

    if (is_funique (dst_spec, dst_table, src_column->name))
      field = add_field (dst_spec, dst_table, src_column, src_index);
    else
    {
      src_column->number = FAILURE;

      button = mnewfield (dst_window, dst_table, src_column, src_index, &field);
      if (button == NFCANCEL) return (FALSE);
    } /* else */

    systattr = &dst_spec->systattr [dst_table];
    get_tblwh (dst_spec, dst_table, &systattr->width, &systattr->height);
    b_get_rect (dst_window, SEL_TABLE, NIL, dst_table, &scroll, TRUE, TRUE);
    set_redraw (dst_window, &scroll);
    dst_spec->modified = TRUE;
    systattr->flags   |= UPD_FLAG;
  } /* else */

  return (TRUE);
} /* hndl_field */

/*****************************************************************************/

LOCAL BOOLEAN hndl_key (src_window, dst_window, obj, r, mk)
WINDOWP src_window;
WINDOWP dst_window;
WORD    obj;
RECT    *r;
MKINFO  *mk;

{
  WORD     src_table, dst_table;
  RECT     ob;
  SEL_SPEC sel_spec;

  sel_spec  = b_find_objs (dst_window, mk);
  src_table = sel.table;
  dst_table = sel_spec.table;

  if ((sel.table == sel_spec.table) &&          /* src = dst */
      (sel.key   == sel_spec.key)) dst_table = FAILURE;

  if (dst_table == FAILURE)     /* no destination table found */
  {
    b_get_rect (src_window, SEL_KEY, obj, src_table, &ob, TRUE, FALSE);
    graf_mbox (ob.w, ob.h, ob.x + r->w, ob.y + r->h, ob.x, ob.y);
    return (TRUE);
  } /* if */

  return (FALSE);
} /* hndl_key */

/*****************************************************************************/

LOCAL VOID hndl_objs (src_window, dst_window, end, objs, class, all, r, mk)
WINDOWP src_window;
WINDOWP dst_window;
WORD    end;
SET     objs;
WORD    class;
RECT    *all;
RECT    *r;
MKINFO  *mk;

{
  WORD      i, obj;
  BOOLEAN   ok;
  BASE_SPEC *dst_spec;

  dst_spec = (BASE_SPEC *)dst_window->special;
  ok       = TRUE;
  obj      = 0;

  for (i = 0; ok && (i < end); i++)
    if (setin (objs, i))
    {
      switch (class)
      {
        case SEL_TABLE : ok = hndl_table (src_window, dst_window, i, r, mk, &all [obj]); break;
        case SEL_FIELD : ok = hndl_field (src_window, dst_window, i, r, mk);             break;
        case SEL_KEY   : ok = hndl_key (src_window, dst_window, i, r, mk);               break;
      } /* switch */

      obj++;
    } /* if, for */

  if (! dst_spec->show_full) set_redraw (dst_window, &dst_window->scroll);
} /* hndl_objs */

/*****************************************************************************/

LOCAL WORD find_rules (window, src_table, class, src_obj, r, rule)
WINDOWP window;
WORD    src_table;
WORD    class;
WORD    src_obj;
RECT    *r;
RULE    *rule;

{
  WORD      dst_table;
  WORD      src_key, dst_key, abs_inx;
  SEL_SPEC  sel_spec;
  MKINFO    mk;
  SYSINDEX  *refindex, *relindex;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  mk.mox = r->x;
  mk.moy = r->y;

  switch (class)
  {
    case SEL_FIELD : src_key = find_index (base_spec, src_table, src_obj);    break;
    case SEL_KEY   : src_key = find_multikey (base_spec, src_table, src_obj); break;
  } /* switch */

  rule->src_table = src_table;
  rule->src_obj   = src_key;
  rule->dst_table = NIL;
  rule->dst_obj   = NIL;

  sel_spec = b_find_objs (window, &mk);

  if ((sel.table == sel_spec.table) &&          /* src = dst */
      (class == sel_spec.class) &&
      (sel.field == sel_spec.field) &&
      (sel.key == sel_spec.key)) return (FAILURE);

  dst_table = sel_spec.table;

  if (dst_table == FAILURE) return (FAILURE);

  dst_key = find_primary (base_spec, dst_table);
  if (dst_key == FAILURE) return (ERR_NOPRIMARY);

  abs_inx  = absinx (base_spec, dst_table, dst_key);
  refindex = &base_spec->sysindex [abs_inx];
  abs_inx  = absinx (base_spec, src_table, src_key);
  relindex = &base_spec->sysindex [abs_inx];

  if (refindex->type != relindex->type) return (ERR_RELTYPE);

  if ((dst_table != src_table) || (dst_key != src_key))
  {
    rule->dst_table = dst_table;
    rule->dst_obj   = dst_key;

    return (SUCCESS);
  } /* if */

  return (FAILURE);
} /* find_rules */

/*****************************************************************************/

LOCAL BOOLEAN hndl_rules (window, src_table, class, src_obj, r)
WINDOWP window;
WORD    src_table;
WORD    class;
WORD    src_obj;
RECT    *r;

{
  WORD err;
  RULE rule;

  err = find_rules (window, src_table, class, src_obj, r, &rule);

  if (err == SUCCESS)
    b_rules (window, rule.dst_table, rule.dst_obj, rule.src_table, rule.src_obj);
  else
    switch (err)
    {
      case ERR_RELTYPE   : hndl_alert (ERR_RELTYPE);   break;
      case ERR_NOPRIMARY : hndl_alert (ERR_NOPRIMARY); break;
    } /* switch, else */

  return (err == SUCCESS);
} /* hndl_rules */

/*****************************************************************************/

LOCAL VOID do_rules (window, class, mk)
WINDOWP window;
WORD    class;
MKINFO  *mk;

{
  RECT      r, bound, diff;
  WORD      obj;
  WORD      table;
  SYSCOLUMN *syscolumn;
  BASE_SPEC *base_spec;

  if (class == SEL_TABLE) return;

  base_spec = (BASE_SPEC *)window->special;
  table     = sel.table;
  bound     = window->scroll;
  obj       = FAILURE;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  switch (class)
  {
    case SEL_FIELD : obj = sel.field; break;
    case SEL_KEY   : obj = sel.key;   break;
  } /* switch */

  if (class == SEL_FIELD)                       /* field must be index */
  {
    syscolumn = &base_spec->syscolumn [abscol (base_spec, table, obj)];
    if (! (syscolumn->flags & COL_ISINDEX)) obj = FAILURE;
  } /* if */

  if (obj != FAILURE)
  {
    sel_window = window;
    setincl (sel_objs, obj);

    invert_objs (window, sel.class, sel_objs, sel.table);
    drag_arrow (window, &r, &diff, &bound, sel.table, sel.class, obj, DRAG_IRULE);

    if (hndl_rules (window, table, class, obj, &diff))
    {
      sel.class  = SEL_NONE;
      sel.table  = FAILURE;
      sel.field  = FAILURE;
      sel.key    = FAILURE;
      sel_window = NULL;
      setclr (sel_objs);
    } /* if */
    else
      unclick_window (sel_window);
  } /* if */
} /* do_rules */

/*****************************************************************************/

LOCAL WORD find_lookups (window, src_table, src_obj, r, rule)
WINDOWP window;
WORD    src_table;
WORD    src_obj;
RECT    *r;
RULE    *rule;

{
  WORD      dst_table;
  WORD      dst_obj, abs_col;
  SEL_SPEC  sel_spec;
  MKINFO    mk;
  SYSCOLUMN *ref_col, *rel_col;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  mk.mox = r->x;
  mk.moy = r->y;

  rule->src_table = src_table;
  rule->src_obj   = src_obj;
  rule->dst_table = NIL;
  rule->dst_obj   = NIL;

  sel_spec = b_find_objs (window, &mk);

  if (src_table == sel_spec.table) return (FAILURE);

  dst_table = sel_spec.table;
  dst_obj   = sel_spec.field;

  if ((dst_table == FAILURE) || (dst_obj == FAILURE)) return (FAILURE);

  abs_col = abscol (base_spec, dst_table, dst_obj);
  ref_col = &base_spec->syscolumn [abs_col];
  abs_col = abscol (base_spec, src_table, src_obj);
  rel_col = &base_spec->syscolumn [abs_col];

  if (ref_col->type != rel_col->type) return (ERR_LOOKUPTYPE);
  if (exist_lookup (base_spec, src_table, src_obj)) return (ERR_LOOKUPEXIST);

  if ((dst_table != src_table) || (dst_obj != src_obj))
  {
    rule->dst_table = dst_table;
    rule->dst_obj   = dst_obj;

    return (SUCCESS);
  } /* if */

  return (FAILURE);
} /* find_lookups */

/*****************************************************************************/

LOCAL WORD search_lookup (base_spec, table, column, ref_table, ref_column)
BASE_SPEC *base_spec;
WORD      table, column;
WORD      ref_table, ref_column;

{
  WORD      i;
  SYSLOOKUP *syslookup;

  syslookup = base_spec->syslookup;

  for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
    if (syslookup->flags & MOD_FLAG)
    {
      if (! (syslookup->flags & DEL_FLAG)     &&
          (syslookup->table     == table)     &&
          (syslookup->column    == column)    &&
          (syslookup->reftable  == ref_table) &&
          (syslookup->refcolumn == ref_column)) return (i);
    } /* if */
    else
    {
      if ((syslookup->flags & INS_FLAG)       &&
          (syslookup->table     == table)     &&
          (syslookup->column    == column)    &&
          (syslookup->reftable  == ref_table) &&
        (syslookup->refcolumn == ref_column)) return (i);
    } /* else */

  return (FAILURE);
} /* search_lookup */

/*****************************************************************************/

LOCAL BOOLEAN exist_lookup (base_spec, table, column)
BASE_SPEC *base_spec;
WORD      table, column;

{
  WORD      i;
  SYSLOOKUP *syslookup;

  syslookup = base_spec->syslookup;

  for (i = 0; i < base_spec->num_lookups; i++, syslookup++)
    if (syslookup->flags & MOD_FLAG)
    {
      if (! (syslookup->flags & DEL_FLAG) &&
          (syslookup->table  == table)    &&
          (syslookup->column == column)) return (TRUE);
    } /* if */
    else
    {
      if ((syslookup->flags & INS_FLAG) &&
          (syslookup->table  == table)  &&
          (syslookup->column == column)) return (TRUE);
    } /* else */

  return (FALSE);
} /* exist_lookup */

/*****************************************************************************/

LOCAL BOOLEAN hndl_lookups (window, src_table, src_obj, r)
WINDOWP window;
WORD    src_table;
WORD    src_obj;
RECT    *r;

{
  WORD      err, lu_rule;
  RULE      rule;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  err = find_lookups (window, src_table, src_obj, r, &rule);

  if (err == SUCCESS)
  {
    lu_rule = search_lookup (base_spec, rule.src_table, rule.src_obj, rule.dst_table, rule.dst_obj);
    if (lu_rule != FAILURE) return (FALSE);     /* don't do anything */

    err = add_lookup (base_spec, rule.dst_table, rule.dst_obj, rule.src_table, rule.src_obj, 0);

    if (err == ERR_ADD_LUR)
      hndl_alert(ERR_NOLOOKUPS);
    else
    {
      err = SUCCESS;
      set_redraw (window, &window->scroll);
    } /* else */
  } /* if */
  else
    switch (err)
    {
      case ERR_LOOKUPTYPE  : hndl_alert (ERR_LOOKUPTYPE);  break;
      case ERR_LOOKUPEXIST : hndl_alert (ERR_LOOKUPEXIST); break;
    } /* switch, else */

  return (err == SUCCESS);
} /* hndl_lookups */

/*****************************************************************************/

LOCAL VOID do_lookups (window, class, mk)
WINDOWP window;
WORD    class;
MKINFO  *mk;

{
  RECT      r, bound, diff;
  WORD      obj;
  WORD      table;

  if (class != SEL_FIELD) return;

  table = sel.table;
  bound = window->scroll;
  obj   = sel.field;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  sel_window = window;
  setincl (sel_objs, obj);

  invert_objs (window, sel.class, sel_objs, sel.table);
  drag_arrow (window, &r, &diff, &bound, sel.table, sel.class, obj, DRAG_LOOKUP);

  if (hndl_lookups (window, table, obj, &diff))
  {
    sel.class  = SEL_NONE;
    sel.table  = FAILURE;
    sel.field  = FAILURE;
    sel.key    = FAILURE;
    sel_window = NULL;
    setclr (sel_objs);
  } /* if */
  else
    unclick_window (sel_window);
} /* do_lookups */

/*****************************************************************************/

LOCAL VOID drag_objs (window, class, objs, mk)
WINDOWP window;
WORD    class;
SET     objs;
MKINFO  *mk;

{
  RECT      r, bound, ob;
  WORD      i, result, num_objs;
  WORD      dest_obj;
  WORD      end, width, x;
  WORD      table;
  WORD      wchar, hchar;
  WORD      wbox, hbox;
  LONGSTR   s;
  WINDOWP   dest_window;
  SET       inv_objs;
  RECT      all [MAX_SELOBJ];
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  if (window != NULL)
  {
    base_spec = (BASE_SPEC *)window->special;
    table     = sel.table;
    systable  = &base_spec->systable [table];

    switch (class)
    {
      case SEL_TABLE : end = base_spec->num_tables; break;
      case SEL_FIELD : end = systable->cols;        break;
      case SEL_KEY   : end = systable->indexes;     break;
      default        : end = NIL;                   break;
    } /* switch */

    bound.x = -desk.w;
    bound.y = -desk.h;
    bound.w = 32767;
    bound.h = 32767;

    setclr (inv_objs);
    for (i = ITRASH; i < FKEYS; i++) setincl (inv_objs, i);

    for (i = 0, num_objs = 0; i < end; i++)
      if (setin (objs, i))
      {
        if (class == SEL_TABLE) table = i;
        b_get_rect (window, class, i, table, &all [num_objs++], TRUE, FALSE);
      } /* if, for */

    set_mouse (FLAT_HAND, NULL);
    drag_boxes (num_objs, all, find_desk (), inv_objs, &r, &bound, base_spec->wbox, base_spec->hbox);
    last_mouse ();
    graf_mkstate (&mk->mox, &mk->moy, &result, &result);

    result = drag_to_window (mk->mox, mk->moy, window, 0, &dest_window, &dest_obj);

    if ((result == DRAG_SWIND) ||       /* move or copy objects */
        (result == DRAG_SCLASS))
      hndl_objs (window, dest_window, end, objs, class, all, &r, mk);

    if (dest_window != NULL)
      if (dest_window->class == class_desk)
      {
        if (result == DRAG_OK)
          switch (dest_obj)
          {
            case ITRASH   : b_obj_clear (window, class, objs, &r);
                            break;
            case ICLIPBRD : if (copy2clipbrd (window, class, objs, (ccp_ext & DO_EXTERNAL) != 0))
                              if (! mk->shift) b_obj_clear (window, class, objs, &r);
                            break;
            default       : for (i = 0; i < end; i++)
                              if (setin (objs, i))
                              {
                                if (class == SEL_TABLE) table = i;
                                b_get_rect (window, class, i, table, &ob, TRUE, FALSE);
                                graf_mbox (ob.w, ob.h, ob.x + r.w, ob.y + r.h, ob.x, ob.y);
                              } /* if, for */
          } /* switch, if */
      } /* if */
      else
        if (dest_window->class == CLASS_MASK)   /* copy fields to mask window */
          if (result == DRAG_OK)
          {
            mask_spec = (MASK_SPEC *)dest_window->special;

            if (base_spec != mask_spec->base_spec)
            {
              hndl_alert (ERR_NOMATCH);
              return;
            } /* if */

            vst_font (vdi_handle, mask_spec->font);
            vst_point (vdi_handle, mask_spec->point, &wchar, &hchar, &wbox, &hbox);

            result = SUCCESS;
            ob.x   = all [0].x + r.w;         /* starting at upper left corner of boxes */
            ob.y   = all [0].y + r.h;
            ob.w   = 0;
            ob.h   = 0;
            x      = ob.x;
            width  = 0;

            switch (class)
            {
              case SEL_TABLE : end = systable->cols; break;
              case SEL_FIELD :                       break;
              case SEL_KEY   : end = NIL;            break;
              default        : end = NIL;            break;
            } /* switch */

            for (i = 1; i < end; i++)
              if (setin (objs, i) || (class == SEL_TABLE))
              {
                syscolumn = &base_spec->syscolumn [abscol (base_spec, table, i)];
                width = max (width, strlen (syscolumn->name));
              } /* if, for */

            for (i = 1; (result == SUCCESS) && (i < end); i++)
              if (setin (objs, i) || (class == SEL_TABLE))
              {
                syscolumn = &base_spec->syscolumn [abscol (base_spec, table, i)];
                if (mask_spec->font == FONT_SYSTEM) ob.x = x + (width - strlen (syscolumn->name)) * wbox;
                result = m_addfield (dest_window, base_spec, table, i, &ob);

                if (result != SUCCESS)
                  switch (result)
                  {
                    case ERR_OBJEXISTS  : syscolumn = &base_spec->syscolumn [abscol (base_spec, table, i)];
                                          sprintf (s, alerts [ERR_OBJEXISTS], systable->name, syscolumn->name);
                                          open_alert (s);
                                          break;
                    default             : hndl_alert (result);
                                          break;
                  } /* switch, if */
              } /* if, for */

            set_redraw (dest_window, &dest_window->scroll);
          } /* if */
  } /* if */
} /* drag_objs */

/*****************************************************************************/

LOCAL BOOLEAN drag_icon (window, obj, x, y)
WINDOWP window;
WORD    obj;
WORD    *x, *y;

{
  RECT       r, bound, border;
  WORD       mox, moy;
  WORD       result, num_objs;
  WORD       dest_obj;
  WINDOWP    dest_window;
  SET        objs;
  MKINFO     mk;

  if (window != NULL)
  {
    bound.x = -desk.w;
    bound.y = -desk.h;
    bound.w = 32767;
    bound.h = 32767;

    setclr (objs);              /* don't use desktop objects */
    num_objs = 1;
    objc_rect (dbicons, obj, &border, FALSE);

    set_mouse (FLAT_HAND, NULL);
    drag_boxes (num_objs, &border, find_desk (), objs, &r, &bound, 1, 1);
    last_mouse ();
    graf_mkstate (&mox, &moy, &result, &result);

    if (obj == ITABLE)          /* use object border */
    {
      *x = border.x + r.w + FRAME;
      *y = border.y + r.h + FRAME;
    } /* if */
    else                        /* use mouse position */
    {
      *x = r.x;
      *y = r.y;
    } /* else */

    result = drag_to_window (mox, moy, window, 0, &dest_window, &dest_obj);

    if (result == DRAG_SWIND)           /* move objects */
    {
      mk.mox = *x;
      mk.moy = *y;
      if (dest_window != NULL) sel = b_find_objs (dest_window, &mk);
    } /* if */
  } /* if */

  return (window == dest_window);
} /* drag_icon */

/*****************************************************************************/

LOCAL VOID drag_arrow (window, r, diff, bound, src_table, class, src_obj, mode)
WINDOWP window;
RECT    *r, *diff, *bound;
WORD    src_table, class, src_obj;
WORD    mode;

{
  WORD    event;
  WORD    x_offset, y_offset, x_last, y_last;
  WORD    i, delta;
  WORD    x_raster, y_raster;
  RECT    startbox, box;
  MKINFO  mk, start;

  set_clip (TRUE, &window->scroll);
  graf_mkstate (&start.mox, &start.moy, &start.mobutton, &start.kstate);
  mk = start;

  startbox = box = *r;

  diff->w  = diff->h  = 0;
  x_raster = y_raster = 1;

  if (bound == NULL) bound = &desk;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_ends (vdi_handle, SQUARED, ARROWED);
/*
  if (mode == DRAG_LOOKUP) vsl_type (vdi_handle, LONGDASH);
*/
  draw_line (window, r, diff, src_table, class, src_obj, mode);

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
                        &mk.mobutton, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

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
          draw_line (window, r, diff, src_table, class, src_obj, mode);

          diff->w = x_offset;
          diff->h = y_offset;

          draw_line (window, r, diff, src_table, class, src_obj, mode);
        } /* if */
      } /* if, if */
  } while (event != MU_BUTTON);

  draw_line (window, r, diff, src_table, class, src_obj, mode);

  diff->x = mk.mox;
  diff->y = mk.moy;
} /* drag_arrow */

/*****************************************************************************/

LOCAL VOID draw_line (window, r, diff, src_table, class, src_obj, mode)
WINDOWP window;
RECT    *r, *diff;
WORD    src_table, class, src_obj;
WORD    mode;

{
  WORD err;
  WORD xy [4];
  WORD x_corr;
  WORD y_corr;
  RECT dest;
  RULE rule;

  hide_mouse ();

  x_corr = (diff->w <= 0) ? 0 : 1;
  y_corr = (diff->h <= 0) ? 0 : 1;

  xy [0] = r->x + diff->w - x_corr;
  xy [1] = r->y + diff->h - y_corr;
  xy [2] = r->x;
  xy [3] = r->y;

  dest.x = xy [0];
  dest.y = xy [1];

  switch (mode)
  {
    case DRAG_IRULE  : err = find_rules (window, src_table, class, src_obj, &dest, &rule); break;
    case DRAG_LOOKUP : err = find_lookups (window, src_table, src_obj, &dest, &rule);      break;
    default          : err = FAILURE;
  } /* switch */

  if (err == SUCCESS)
    draw_arrow (window, rule.dst_table, rule.dst_obj, rule.src_table, rule.src_obj, mode);
  else
    v_pline (vdi_handle, 2, xy);

  show_mouse ();
} /* draw_line */

/*****************************************************************************/

LOCAL VOID draw_arrow (window, ref_table, ref_index, rel_table, rel_index, mode)
WINDOWP window;
WORD    ref_table, ref_index;
WORD    rel_table, rel_index;
WORD    mode;

{
  WORD      wbox, hbox;
  WORD      class, obj;
  WORD      xy [8];
  RECT      frame, ref_rect, rel_rect;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  wbox      = base_spec->wbox;
  hbox      = base_spec->hbox;

  if (mode == DRAG_IRULE)
  {
    b_get_rect (window, SEL_TABLE, NIL, ref_table, &frame, TRUE, FALSE);
    class = inx2obj (base_spec, ref_table, ref_index, &obj);
    b_get_rect (window, class, obj, ref_table, &ref_rect, TRUE, FALSE);
    ref_rect.x = frame.x;
    ref_rect.w = frame.w;

    b_get_rect (window, SEL_TABLE, NIL, rel_table, &frame, TRUE, FALSE);
    class = inx2obj (base_spec, rel_table, rel_index, &obj);
    b_get_rect (window, class, obj, rel_table, &rel_rect, TRUE, FALSE);
    rel_rect.x = frame.x;
    rel_rect.w = frame.w;
  } /* if */

  if (mode == DRAG_LOOKUP)
  {
    b_get_rect (window, SEL_TABLE, NIL, ref_table, &frame, TRUE, FALSE);
    b_get_rect (window, SEL_FIELD, ref_index, ref_table, &ref_rect, TRUE, FALSE);
    ref_rect.x = frame.x;
    ref_rect.w = frame.w;

    b_get_rect (window, SEL_TABLE, NIL, rel_table, &frame, TRUE, FALSE);
    b_get_rect (window, SEL_FIELD, rel_index, rel_table, &rel_rect, TRUE, FALSE);
    rel_rect.x = frame.x;
    rel_rect.w = frame.w;
  } /* if */

  if ((rel_rect.x + rel_rect.w + 4 * wbox <= ref_rect.x) || /* arrow <- */
      (rel_rect.x < ref_rect.x + ref_rect.w + 4 * wbox))
  {
    xy [0] = ref_rect.x - 1;
    xy [1] = ref_rect.y + hbox / 2;
    xy [2] = xy [0] - 2 * wbox + 1;
    xy [3] = xy [1];
    xy [4] = xy [2];
    xy [5] = rel_rect.y + hbox / 2;
    xy [6] = rel_rect.x + rel_rect.w + 1;
    xy [7] = xy [5];

    if (rel_rect.x > ref_rect.x)
      xy [6] = rel_rect.x - 1;
    else
      if (rel_rect.x + rel_rect.w + 4 * wbox > ref_rect.x)
      {
        xy [2] = rel_rect.x - 4 * wbox;
        xy [3] = xy [1];
        xy [4] = xy [2];
        xy [5] = rel_rect.y + hbox / 2;
        xy [6] = rel_rect.x - 1;
        xy [7] = xy [5];
      } /* else */
  } /* if */
  else
  {
    xy [0] = ref_rect.x + ref_rect.w;
    xy [1] = ref_rect.y + hbox / 2;
    xy [2] = xy [0] + 2 * wbox - 1;
    xy [3] = xy [1];
    xy [4] = xy [2];
    xy [5] = rel_rect.y + hbox / 2;
    xy [6] = rel_rect.x - 1;
    xy [7] = xy [5];

    if (rel_rect.x + rel_rect.w < ref_rect.x + ref_rect.w)
      xy [6] = rel_rect.x + rel_rect.w + 1;
  } /* if */

  v_pline (vdi_handle, 4, xy);
} /* draw_arrow */

/*****************************************************************************/

LOCAL VOID fill_select (window, objs, area)
WINDOWP window;
SET     objs;
RECT    *area;

{
  WORD      i, start;
  RECT      r;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  start     = base_spec->first_table;

  setclr (objs);

  for (i = start; i < base_spec->num_tables; i++)
  {
    b_get_rect (window, SEL_TABLE, i, i, &r, FALSE, FALSE);

    if (rc_intersect (area, &r))                                 /* Im Rechteck */
      if (rc_intersect (&window->scroll, &r)) setincl (objs, i); /* Im Scrollbereich */
  } /* for */
} /* fill_select */

/*****************************************************************************/

LOCAL VOID invert_objs (window, class, objs, table)
WINDOWP window;
WORD    class;
SET     objs;
WORD    table;

{
  WORD      i;
  WORD      end;
  RECT      r, frame;
  WORD      xy [10];
  SYSTABLE  *systable;
  BASE_SPEC *base_spec;

  if (class == SEL_NONE) return;
  base_spec = (BASE_SPEC *)window->special;

  if (class != SEL_TABLE)
  {
    if (table < 0) return;
    systable = &base_spec->systable [table];
  } /* if */

  switch (class)
  {
    case SEL_TABLE : end = base_spec->num_tables; break;
    case SEL_FIELD : end = systable->cols;        break;
    case SEL_KEY   : end = systable->indexes;     break;
    default        : end = NIL;                   break;
  } /* switch */

  wind_update (BEG_UPDATE);
  hide_mouse ();

  wind_get (window->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

  while ((r.w != 0) && (r.h != 0))
  {
    if (rc_intersect (&window->scroll, &r))
    {
      for (i = 0; i < end; i++)
        if (setin (objs, i))
        {
          if (class == SEL_TABLE) table = i;
          b_get_rect (window, class, i, table, &frame, TRUE, FALSE);

          if (rc_intersect (&r, &frame))
          {
            set_clip (TRUE, &frame);
            rect2array (&frame, xy);
            vswr_mode (vdi_handle, MD_XOR);
            vsf_interior (vdi_handle, FIS_SOLID);
            vsf_color (vdi_handle, BLACK);
            vr_recfl (vdi_handle, xy);
          } /* else, if */
        } /* if, for */
    } /* if */

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

  sel.class = SEL_TABLE;

  if (mk->shift)                                /* Auschliežlich odernd ausw„hlen */
  {
    fill_select (window, new_objs, &r);
    invert_objs (window, sel.class, new_objs, sel.table);
    setxor (sel_objs, new_objs);
  } /* if */
  else
    if (mk->ctrl)                               /* Zus„tzlich ausw„hlen */
    {
      fill_select (window, new_objs, &r);
      setnot (sel_objs);
      setand (new_objs, sel_objs);
      setnot (sel_objs);
      invert_objs (window, sel.class, new_objs, sel.table);
      setor (sel_objs, new_objs);
    } /* if */
    else                                        /* Ausw„hlen */
    {
      fill_select (window, sel_objs, &r);
      invert_objs (window, sel.class, sel_objs, sel.table);
    } /* else */

  sel_window = setcmp (sel_objs, NULL) ? NULL : window;
} /* rubber_objs */

