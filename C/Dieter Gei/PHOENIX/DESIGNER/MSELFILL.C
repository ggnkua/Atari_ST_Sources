/*****************************************************************************
 *
 * Module : MSELFILL.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.07.95
 *
 *
 * Description: This module implements the clicking inside a mask window.
 *
 * History:
 * 20.07.95: OK button set correctly in set_line
 * 04.01.95: Using new function names of controls module
 * 03.11.93: Initial color set correctly in set_fill
 * 23.10.93: New color selection added
 * 12.09.93: draw_fill -> update_object in click_fill
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
#include "dialog.h"

#include "export.h"
#include "mselfill.h"

/****** DEFINES **************************************************************/

#define MAX_PATTERNS     24
#define MAX_HATCH        12
#define MAX_LINES        12
#define MAX_COLS          3

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD exit_obj;            /* will be set on dialog exit */
LOCAL WORD sel_color;           /* will be set on dialog exit */
LOCAL WORD sel_style;           /* will be set on dialog exit */
LOCAL WORD sel_index;           /* will be set on dialog exit */
LOCAL WORD sel_pattern;

LOCAL WORD sel_type;
LOCAL WORD sel_width;
LOCAL WORD sel_bstyle;
LOCAL WORD sel_estyle;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));

LOCAL VOID    set_fill      _((VOID));
LOCAL VOID    click_fill    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    draw_fill     _((WINDOWP window));
LOCAL VOID    draw_select   _((VOID));
LOCAL VOID    draw_patterns _((VOID));
LOCAL VOID    update_object _((WINDOWP window, WORD obj));

LOCAL VOID    set_line      _((VOID));
LOCAL VOID    click_line    _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_line      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    draw_line     _((WINDOWP window));
LOCAL VOID    draw_lselect  _((WINDOWP window));
LOCAL VOID    draw_lstyles  _((WINDOWP window));
LOCAL VOID    draw_style    _((WINDOWP window, WORD obj, WORD type, WORD width, WORD bstyle, WORD estyle));

/*****************************************************************************/

GLOBAL BOOLEAN mselfill (color, style, index)
WORD *color;
WORD *style;
WORD *index;

{
  WINDOWP window;
  WORD    ret;

  exit_obj = SICANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, SELFILL);

  if (window == NULL)
  {
    form_center (selfill, &ret, &ret, &ret, &ret);
    window = crt_dialog (selfill, NULL, SELFILL, FREETXT (FSELFILL), WI_MODAL);

    if (window != NULL)
    {
      window->draw  = draw_fill;
      window->click = click_fill;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (selfill, ROOT, EDITABLE);
      window->edit_inx = NIL;

      sel_color = *color;
      sel_style = *style;
      sel_index = *index;

      set_fill ();
    } /* if */

    if (! open_dialog (SELFILL))
      hndl_alert (ERR_NOOPEN);
    else
    {
      if (exit_obj == SIOK)
      {
        *color = sel_color;
        *style = sel_style;
        *index = sel_index;
      } /* if */
    } /* else */
  } /* if */

  return (exit_obj == SIOK);
} /* mselfill */

/*****************************************************************************/

GLOBAL BOOLEAN mselline (type, width, bstyle, estyle)
WORD *type;
WORD *width;
WORD *bstyle;
WORD *estyle;

{
  WINDOWP window;
  WORD    ret;

  exit_obj = SLCANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, SELLINE);

  if (window == NULL)
  {
    form_center (selline, &ret, &ret, &ret, &ret);
    window = crt_dialog (selline, NULL, SELLINE, FREETXT (FSELLINE), WI_MODAL);

    if (window != NULL)
    {
      window->draw  = draw_line;
      window->click = click_line;
      window->key   = key_line;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (selline, ROOT, EDITABLE);
      window->edit_inx = NIL;

      sel_type   = *type;
      sel_width  = *width;
      sel_bstyle = *bstyle;
      sel_estyle = *estyle;

      set_line ();
    } /* if */

    if (! open_dialog (SELLINE))
      hndl_alert (ERR_NOOPEN);
    else
    {
      if (exit_obj == SLOK)
      {
        *type   = sel_type;
        *width  = sel_width;
        *bstyle = sel_bstyle;
        *estyle = sel_estyle;

      } /* if */
    } /* else */
  } /* if */

  return (exit_obj == SLOK);
} /* mselline */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
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
} /* callback */

/*****************************************************************************/

LOCAL VOID set_fill ()

{
  WORD style;

  sel_pattern = 1;

  switch (sel_style)
  {
    case FIS_HOLLOW  : style = SIHOLLOW; break;
    case FIS_SOLID   : style = SIWHITE;  break;
    case FIS_PATTERN :
    case FIS_HATCH   : style = SITABLE;  break;
  } /* switch */

  set_rbutton (selfill, style, SIHOLLOW, SITABLE);
  line_default (vdi_handle);
  do_flags (selfill, SISELECT, HIDETREE);

  if (sel_style == FIS_PATTERN)
    sel_pattern = sel_index;
  else
    if (sel_style == FIS_HATCH)
      sel_pattern = sel_index + MAX_PATTERNS;

  if (style == SITABLE)
    undo_state (selfill, SITNAME, DISABLED);
  else
    do_state (selfill, SITNAME, DISABLED);

  ListBoxSetCallback (selfill, SICOLOR, callback);
  ListBoxSetStyle (selfill, SICOLOR, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (selfill, SICOLOR, LBS_VSCROLL, FALSE);
  ListBoxSetCount (selfill, SICOLOR, min (colors, 16), NULL);
  ListBoxSetCurSel (selfill, SICOLOR, sel_color);
  ListBoxSetLeftOffset (selfill, SICOLOR, 0);
} /* set_fill */

/*****************************************************************************/

LOCAL VOID click_fill (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD style, item;
  WORD old_color, old_style, old_index;
  WORD x, y, w, h;

  switch (window->exit_obj)
  {
    case SICOLOR  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (colors, 16));
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                    {
                      old_color = sel_color;
                      sel_color = item;
                      if (sel_color != old_color) update_object (window, SISELECT);
                    } /* if */
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SIHOLLOW :
    case SIWHITE  :
    case SITABLE  : old_style = sel_style;
                    old_index = sel_index;
                    style     = get_rbutton (selfill, SIHOLLOW);

                    switch (style)
                    {
                      case SIHOLLOW    : sel_style = FIS_HOLLOW;
                                         break;
                      case SIWHITE     : sel_style = FIS_SOLID;
                                         break;
                      case SITABLE     : if (sel_pattern <= MAX_PATTERNS)
                                         {
                                           sel_style = FIS_PATTERN;
                                           sel_index = sel_pattern;
                                         } /* if */
                                         else
                                         {
                                           sel_style = FIS_HATCH;
                                           sel_index = sel_pattern - MAX_PATTERNS;
                                         } /* else */
                    } /* switch */

                    if ((style != SITABLE) == ! is_state (selfill, SITNAME, DISABLED))
                    {
                      flip_state (selfill, SITNAME, DISABLED);
                      draw_object (window, SITNAME);
                    } /* if */

                    if ((sel_style != old_style) || (sel_index != old_index)) update_object (window, SISELECT);
                    break;
    case SIPATTER : if ((sel_style == FIS_PATTERN) || (sel_style == FIS_HATCH))
                    {
                      old_style = sel_style;
                      old_index = sel_index;
                      objc_offset (selfill, SIPATTER, &x, &y);
                      w = selfill [SIPATTER].ob_width / MAX_COLS;
                      h = selfill [SIPATTER].ob_height / MAX_LINES;

                      x = mk->mox - x;
                      y = mk->moy - y;
                      x = x / w;
                      y = y / h;

                      sel_pattern = x * MAX_LINES + y + 1;

                      if (sel_pattern <= MAX_PATTERNS)
                      {
                        sel_style = FIS_PATTERN;
                        sel_index = sel_pattern;
                      } /* if */
                      else
                      {
                        sel_style = FIS_HATCH;
                        sel_index = sel_pattern - MAX_PATTERNS;
                      } /* else */

                      if ((sel_style != old_style) || (sel_index != old_index)) update_object (window, SISELECT);
                    } /* if */
                    break;
    case SIOK     : break;
    case SIHELP   : hndl_help (HSELFILL);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  if (mk->breturn == 2) /* double clicking */
  {
    window->exit_obj  = SIOK;
    window->flags    |= WI_DLCLOSE;
  } /* if */

  exit_obj = window->exit_obj;
} /* click_fill */

/*****************************************************************************/

LOCAL VOID draw_fill (window)
WINDOWP window;

{
  draw_select ();
  draw_patterns ();
} /* draw_fill */

/*****************************************************************************/

LOCAL VOID draw_select ()

{
  WORD style;
  WORD x, y, w, h;
  WORD xy [10];

  objc_offset (selfill, SISELECT, &x, &y);
  xywh2array (x, y, selfill [SISELECT].ob_width, selfill [SISELECT].ob_height, xy);
  array2xywh (xy, &x, &y, &w, &h);

  if (sel_style == FIS_SOLID)
    style = FIS_HOLLOW;
  else
    style = sel_style;

  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_interior (vdi_handle, style);
  vsf_style (vdi_handle, sel_index);
  vsf_color (vdi_handle, sel_color);
  vsl_color (vdi_handle, sel_color);

  vr_recfl (vdi_handle, xy);

  xy [0] = x;
  xy [1] = y;
  xy [2] = x + w - 1;
  xy [3] = y;
  xy [4] = xy [2];
  xy [5] = y + h - 1;
  xy [6] = x;
  xy [7] = xy [5];
  xy [8] = x;
  xy [9] = y;

  v_pline (vdi_handle, 5, xy);
} /* draw_select */

/*****************************************************************************/

LOCAL VOID draw_patterns ()

{
  WORD x, y, w, h;
  WORD xy [4];
  WORD i;

  objc_offset (selfill, SIPATTER, &x, &y);
  w = selfill [SIPATTER].ob_width / MAX_COLS;
  h = selfill [SIPATTER].ob_height / MAX_LINES;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_color (vdi_handle, BLACK);

  for (i = 0; i < MAX_LINES; i++)
  {
    xywh2array (x - 1, y + i * h - 1, w + 2, h + 2, xy);
    vsf_interior (vdi_handle, FIS_PATTERN);
    vsf_style (vdi_handle, i + 1);
    v_bar (vdi_handle, xy);

    xywh2array (x + w - 1, y + i * h - 1, w + 2, h + 2, xy);
    vsf_style (vdi_handle, i + 13);
    v_bar (vdi_handle, xy);

    xywh2array (x + 2 * w - 1, y + i * h - 1, w + 2, h + 2, xy);
    vsf_interior (vdi_handle, FIS_HATCH);
    vsf_style (vdi_handle, i + 1);
    v_bar (vdi_handle, xy);
  } /* for */
} /* draw_patterns */

/*****************************************************************************/

LOCAL VOID update_object (window, obj)
WINDOWP window;
WORD    obj;

{
  WORD x, y;
  RECT r;

  objc_offset (window->object, obj, &x, &y);
  xywh2rect (x, y, window->object [obj].ob_width, window->object [obj].ob_height, &r);
  set_redraw (window, &r);
} /* update_select */

/*****************************************************************************/

LOCAL VOID set_line ()

{
  BOOLEAN invalid;
  WORD    obj;

  obj = SLT1 + (sel_type - SOLID) * 2;
  set_rbutton (selline, obj, SLT1, SLT6);

  obj = SLBS1 + (sel_bstyle - SQUARED) * 2;
  set_rbutton (selline, obj, SLBS1, SLBS3);

  obj = SLES1 + (sel_estyle - SQUARED) * 2;
  set_rbutton (selline, obj, SLES1, SLES3);

  set_word (selline, SLWIDTH, sel_width);

  invalid = is_null (TYPE_WORD, &sel_width) || ! odd (sel_width);

  if (invalid == ! is_state (selline, SLOK, DISABLED))
    flip_state (selline, SLOK, DISABLED);

  line_default (vdi_handle);
} /* set_line */

/*****************************************************************************/

LOCAL VOID click_line (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD width;
  WORD old_type;
  WORD old_bstyle, old_estyle;

  switch (window->exit_obj)
  {
    case SLBS1  :
    case SLBS2  :
    case SLBS3  : old_bstyle = sel_bstyle;
                  sel_bstyle = (window->exit_obj - SLBS1) / 2 + SQUARED;
                  if (sel_bstyle != old_bstyle) draw_lselect (window);
                  break;
    case SLES1  :
    case SLES2  :
    case SLES3  : old_estyle = sel_estyle;
                  sel_estyle = (window->exit_obj - SLES1) / 2 + SQUARED;
                  if (sel_estyle != old_estyle) draw_lselect (window);
                  break;
    case SLT1   :
    case SLT2   :
    case SLT3   :
    case SLT4   :
    case SLT5   :
    case SLT6   : old_type = sel_type;
                  sel_type = (window->exit_obj - SLT1) / 2 + SOLID;
                  if (sel_type != old_type) draw_lselect (window);
                  break;
    case SLOK   : break;
    case SLHELP : hndl_help (HSELLINE);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */

  width = get_word (selline, SLWIDTH);
  if ((width != sel_width) && odd (width))
  {
    sel_width = width;
    draw_lselect (window);
  } /* if */

  if (mk->breturn == 2) /* double clicking */
  {
    window->exit_obj  = SLOK;
    window->flags    |= WI_DLCLOSE;
  } /* if */

  exit_obj = window->exit_obj;
} /* click_line */

/*****************************************************************************/

LOCAL BOOLEAN key_line (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN invalid;
  WORD    width;

  switch (window->edit_obj)
  {
    case SLWIDTH  : width   = get_word (selline, SLWIDTH);
                    invalid = is_null (TYPE_WORD, &width) || ! odd (width);

                    if (invalid == ! is_state (selline, SLOK, DISABLED))
                    {
                      flip_state (selline, SLOK, DISABLED);
                      draw_object (window, SLOK);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_line */

/*****************************************************************************/

LOCAL VOID draw_line (window)
WINDOWP window;

{
  draw_lstyles (window);
  draw_lselect (window);
} /* draw_line */

/*****************************************************************************/

LOCAL VOID draw_lselect (window)
WINDOWP window;

{
  WORD x, y, w, h;
  WORD xy [4];
  RECT r, old_clip;

  objc_offset (selline, SLSELECT, &x, &y);
  w = selline [SLSELECT].ob_width;
  h = selline [SLSELECT].ob_height;
  xywh2rect (x, y, w, h, &r);

  if (find_top () == window) set_clip (TRUE, &r);

  if (rc_intersect (&clip, &r))
  {
    hide_mouse ();
    old_clip = clip;
    set_clip (TRUE, &r);
    clr_area (&r);

    line_default (vdi_handle);

    vsl_type (vdi_handle, sel_type);
    vsl_width (vdi_handle, sel_width);
    vsl_ends (vdi_handle, sel_bstyle, sel_estyle);

    xy [0] = x + gl_wbox;
    xy [1] = y + h / 2;
    xy [2] = x + w - 1 - gl_wbox;
    xy [3] = xy [1];

    v_pline (vdi_handle, 2, xy);
    set_clip (TRUE, &old_clip);
    show_mouse ();
  } /* if */
} /* draw_lselect */

/*****************************************************************************/

LOCAL VOID draw_lstyles (window)
WINDOWP window;

{
  WORD i, width;

  for (i = SQUARED; i <= ROUNDED; i++)
  {
    width = (i == ROUNDED) ? 7 : 5;
    draw_style (window, SLBS1 + 1 + i * 2, SOLID, width, SQUARED + i, SQUARED);
    draw_style (window, SLES1 + 1 + i * 2, SOLID, width, SQUARED, SQUARED + i);
  } /* for */

  for (i = 0; i < DASH2DOT - SOLID + 1; i++)
    draw_style (window, SLT1 + 1 + i * 2, i + SOLID, 1, SQUARED, SQUARED);
} /* draw_lstyles */

/*****************************************************************************/

LOCAL VOID draw_style (window, obj, type, width, bstyle, estyle)
WINDOWP window;
WORD    obj;
WORD    type;
WORD    width;
WORD    bstyle;
WORD    estyle;

{
  WORD x, y, w, h;
  WORD xy [4];
  RECT r, old_clip;

  objc_offset (selline, obj, &x, &y);
  w = selline [obj].ob_width;
  h = selline [obj].ob_height;
  xywh2rect (x, y, w, h, &r);

  if (find_top () == window) set_clip (TRUE, &r);

  if (rc_intersect (&clip, &r))
  {
    old_clip = clip;
    set_clip (TRUE, &r);

    line_default (vdi_handle);

    vsl_type (vdi_handle, type);
    vsl_width (vdi_handle, width);
    vsl_ends (vdi_handle, bstyle, estyle);

    xy [0] = x + gl_wbox;
    xy [1] = y + h / 2;
    xy [2] = x + w - 1 - gl_wbox;
    xy [3] = xy [1];

    v_pline (vdi_handle, 2, xy);
    set_clip (TRUE, &old_clip);
  } /* if */
} /* draw_style */

