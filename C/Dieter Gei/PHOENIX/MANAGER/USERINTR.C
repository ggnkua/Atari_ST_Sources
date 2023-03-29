/*****************************************************************************
 *
 * Module : USERINTR.C
 * Author : Dieter Geiž
 *
 * Creation date    : 03.10.93
 * Last modification: 03.03.97
 *
 *
 * Description: This module implements the user interface dialog box.
 *
 * History:
 * 03.03.97: Desktop window configuration added
 * 31.12.94: Additional paramter for ListBoxSetFont added
 * 12.10.94: Button shadow width and round corners capabilities added
 * 20.03.94: Button UIRESET resets dlg_round_borders to TRUE
 * 12.03.94: Round borders can be changed only if colors available
 * 12.02.94: Checkbox use_std_fs added
 * 13.11.93: Parameters in init_userinterface added
 * 02.11.93: No longer using large stack variables in callback
 * 30.10.93: Checkboxes, radio buttons and arrows have gray background in combobox
 * 17.10.93: Callback routine improved
 * 03.10.93: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "appl.h"

#include "utility.h"

#include "controls.h"
#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "userintr.h"

/****** DEFINES **************************************************************/

#ifndef CONFIG_DESKTOP_WINDOW
#define CONFIG_DESKTOP_WINDOW	1
#endif

#ifndef GRAY
#define GRAY			DWHITE
#endif

#ifndef DGRAY
#define DGRAY			DBLACK
#endif

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD    err_noopen;			/* error number for "no open" */
LOCAL BYTE    **color_str;			/* color name strings */
LOCAL BYTE    **index_str;			/* index name strings */
LOCAL BYTE    **check_str;			/* checkbox strings */
LOCAL BYTE    **radio_str;			/* radio button strings */
LOCAL BYTE    **arrow_str;			/* arrow strings */
LOCAL WORD    num_chars;			/* number of characters for combobox */
LOCAL WORD    syscolors [MAX_SYSCOLORS];	/* system colors */
LOCAL BOOLEAN changed;				/* any color changed */
LOCAL BYTE    *helpid;				/* help id */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_dialog     _((VOID));
LOCAL VOID    set_dialog     _((VOID));
LOCAL WORD    get_word       _((OBJECT *tree, WORD object));
LOCAL VOID    set_word       _((OBJECT *tree, WORD object, WORD value));

LOCAL LONG    col_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    pat_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    inx_callback   _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    check_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    arrow_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    click_dialog   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_dialog     _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_userinterface (WORD err_no_open, BYTE **color_strings, BYTE **index_strings, BYTE **check_strings, BYTE **radio_strings, BYTE **arrow_strings)
{
  err_noopen = err_no_open;
  color_str  = color_strings;
  index_str  = index_strings;
  check_str  = check_strings;
  radio_str  = radio_strings;
  arrow_str  = arrow_strings;

  num_chars = strlen (get_str (userintr, UISYSINX));

  ListBoxSetCallback (userintr, UICOLOR, col_callback);
  ListBoxSetStyle (userintr, UICOLOR, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UICOLOR, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UICOLOR, min (colors, 16), NULL);
  ListBoxSetCurSel (userintr, UICOLOR, color_desktop);
  ListBoxSetLeftOffset (userintr, UICOLOR, 0);

  ListBoxSetCallback (userintr, UIPAT, pat_callback);
  ListBoxSetStyle (userintr, UIPAT, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UIPAT, LBS_VSCROLL, FALSE);
  ListBoxSetItemHeight (userintr, UIPAT, max (gl_hbox, 10));
  ListBoxSetCount (userintr, UIPAT, 8, NULL);
  ListBoxSetCurSel (userintr, UIPAT, pattern_desktop);
  ListBoxSetLeftOffset (userintr, UIPAT, 0);

  ListBoxSetCallback (userintr, UISYSINX, inx_callback);
  ListBoxSetStyle (userintr, UISYSINX, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UISYSINX, MAX_SYSCOLORS, NULL);
  ListBoxSetCurSel (userintr, UISYSINX, 0);
  ListBoxSetLeftOffset (userintr, UISYSINX, gl_wbox / 2);
  strncpy (get_str (userintr, UISYSINX), index_str [0], num_chars);

  ListBoxSetCallback (userintr, UISYSCOL, col_callback);
  ListBoxSetStyle (userintr, UISYSCOL, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UISYSCOL, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UISYSCOL, 16, NULL);
  ListBoxSetCurSel (userintr, UISYSCOL, sys_colors [ListBoxGetCurSel (userintr, UISYSINX)]);
  ListBoxSetLeftOffset (userintr, UISYSCOL, 0);

  ListBoxSetCallback (userintr, UICHECK, check_callback);
  ListBoxSetFont (userintr, UICHECK, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
  ListBoxSetStyle (userintr, UICHECK, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UICHECK, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UICHECK, 2, NULL);
  ListBoxSetCurSel (userintr, UICHECK, dlg_checkbox);
  ListBoxSetLeftOffset (userintr, UICHECK, 0);

  ListBoxSetCallback (userintr, UIRADIO, check_callback);
  ListBoxSetFont (userintr, UIRADIO, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
  ListBoxSetStyle (userintr, UIRADIO, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UIRADIO, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UIRADIO, 2, NULL);
  ListBoxSetCurSel (userintr, UIRADIO, dlg_radiobutton);
  ListBoxSetLeftOffset (userintr, UIRADIO, 0);

  ListBoxSetCallback (userintr, UIARROW, arrow_callback);
  ListBoxSetFont (userintr, UIARROW, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
  ListBoxSetStyle (userintr, UIARROW, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (userintr, UIARROW, LBS_VSCROLL, FALSE);
  ListBoxSetCount (userintr, UIARROW, 2, NULL);
  ListBoxSetCurSel (userintr, UIARROW, dlg_arrow);
  ListBoxSetLeftOffset (userintr, UIARROW, 0);

  return (TRUE);
} /* init_userinterface */

/*****************************************************************************/

GLOBAL BOOLEAN term_userinterface (VOID)
{
  return (TRUE);
} /* term_userinterface */

/*****************************************************************************/

GLOBAL VOID userinterface_dialog (BYTE *title, BYTE *help_id)
{
  WINDOWP window;
  WORD    ret;

  helpid = help_id;
  window = search_window (CLASS_DIALOG, SRCH_ANY, USERINTR);

  ListBoxSetFont (userintr, UICHECK, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
  ListBoxSetFont (userintr, UIRADIO, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
  ListBoxSetFont (userintr, UIARROW, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);

  if (window == NULL)
  {
    form_center (userintr, &ret, &ret, &ret, &ret);
    window = crt_dialog (userintr, NULL, USERINTR, title, WI_MODELESS);

    if (window != NULL)
    {
      window->click = click_dialog;
      window->key   = key_dialog;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (userintr, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_dialog ();
    } /* if */

    if (! open_dialog (USERINTR)) hndl_alert (err_noopen);
  } /* if */
} /* userinterface_dialog */

/*****************************************************************************/

LOCAL VOID get_dialog (VOID)
{
  mem_move (sys_colors, syscolors, sizeof (sys_colors));

  use_3d                   = get_checkbox (userintr, UIUSE3D);
  dlg_round_borders        = get_checkbox (userintr, UIROUND);
  use_std_fs               = get_checkbox (userintr, UISTDFS);
  color_desktop            = ListBoxGetCurSel (userintr, UICOLOR);
  pattern_desktop          = ListBoxGetCurSel (userintr, UIPAT);
  dlg_checkbox             = ListBoxGetCurSel (userintr, UICHECK);
  dlg_radiobutton          = ListBoxGetCurSel (userintr, UIRADIO);
  dlg_arrow                = ListBoxGetCurSel (userintr, UIARROW);
  btn_round_borders        = get_checkbox (userintr, UIROUNDB);
  btn_shadow_width         = get_word (userintr, UISHADOW);
  dlg_colors               = use_3d ? colors : 2;

#if CONFIG_DESKTOP_WINDOW
  bUseDesktopWindow        = get_checkbox (userintr, UIUSEWND);
  bTopDesktopWindow        = get_checkbox (userintr, UITOP);
  bUseDesktopWindowSliders = get_checkbox (userintr, UISB);
#endif

  switch_trees_3d ();
} /* get_dialog */

/*****************************************************************************/

LOCAL VOID set_dialog (VOID)
{
  set_checkbox (userintr, UIUSE3D, use_3d);
  set_checkbox (userintr, UIROUND, dlg_round_borders);
  set_checkbox (userintr, UISTDFS, use_std_fs);
  ListBoxSetCurSel (userintr, UICOLOR, color_desktop);
  ListBoxSetCurSel (userintr, UIPAT, pattern_desktop);
  ListBoxSetStyle (userintr, UIPAT, LBS_DISABLED, ListBoxGetCurSel (userintr, UICOLOR) == WHITE);
  ListBoxSetCurSel (userintr, UISYSINX, 0);
  strncpy (get_str (userintr, UISYSINX), index_str [0], num_chars);
  ListBoxSetCurSel (userintr, UISYSCOL, sys_colors [ListBoxGetCurSel (userintr, UISYSINX)]);
  ListBoxSetCurSel (userintr, UICHECK, dlg_checkbox);
  ListBoxSetCurSel (userintr, UIRADIO, dlg_radiobutton);
  ListBoxSetCurSel (userintr, UIARROW, dlg_arrow);
  set_checkbox (userintr, UIROUNDB, btn_round_borders);
  set_word (userintr, UISHADOW, btn_shadow_width);

#if CONFIG_DESKTOP_WINDOW
  set_checkbox (userintr, UIUSEWND, bUseDesktopWindow);
  set_checkbox (userintr, UITOP, bTopDesktopWindow);
  set_checkbox (userintr, UISB, bUseDesktopWindowSliders);
#endif

  if (colors == 2)
  {
    do_state (userintr, UIUSE3D, DISABLED);
    do_state (userintr, UIROUND, DISABLED);
    do_state (userintr, UISYSCOL - 1, DISABLED);
    do_state (userintr, UISYSCOL, DISABLED);
    do_state (userintr, UISHADOW - 1, DISABLED);
    do_state (userintr, UISHADOW, DISABLED);
  } /* if */

  if (gl_hbox <= 8)
  {
    do_state (userintr, UICHECK - 1, DISABLED);
    do_state (userintr, UICHECK, DISABLED);
    do_state (userintr, UIRADIO - 1, DISABLED);
    do_state (userintr, UIRADIO, DISABLED);
  } /* if */

  mem_move (syscolors, sys_colors, sizeof (syscolors));
  changed = FALSE;
} /* set_dialog */

/*****************************************************************************/

LOCAL WORD get_word (OBJECT *tree, WORD object)
{
  WORD i;
  BYTE *p;

  i = 1;
  p = get_str (tree, object);
  sscanf (p, "%d", &i);

  return (i);
} /* get_word */

/*****************************************************************************/

LOCAL VOID set_word (OBJECT *tree, WORD object, WORD value)
{
  STRING s;

  sprintf (s, "%d", value);
  set_str (tree, object, s);
} /* set_word */

/*****************************************************************************/

LOCAL LONG col_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)color_str [index]);
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
} /* col_callback */

/*****************************************************************************/

LOCAL LONG pat_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : break;
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                            DrawOwnerDlgPattern (lb_ownerdraw, (WORD)ListBoxGetCurSel (tree, UICOLOR), (WORD)index);
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : return (index);
  } /* switch */

  return (0L);
} /* pat_callback */

/*****************************************************************************/

LOCAL LONG inx_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  LOCAL STRING s;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)index_str [index]);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strncpy (get_str (tree, obj), s, num_chars);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);

                          ListBoxSetCurSel (tree, UISYSCOL, syscolors [index]);
                          ListBoxSetStyle (tree, UISYSCOL, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, UISYSCOL);
                          ListBoxSetStyle (tree, UISYSCOL, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* inx_callback */

/*****************************************************************************/

LOCAL LONG check_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)((obj == UICHECK) ? check_str [index] : radio_str [index]));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 2 * gl_wbox;
                            DrawOwnerCheck (lb_ownerdraw, &r, obj == UIRADIO, (WORD)index, text, 2);
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
} /* check_callback */

/*****************************************************************************/

LOCAL LONG arrow_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)arrow_str [index]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 4 * gl_wbox;
                            DrawOwnerArrow (lb_ownerdraw, &r, (WORD)index, text, 2);
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
} /* arrow_callback */

/*****************************************************************************/

LOCAL VOID click_dialog (WINDOWP window, MKINFO *mk)
{
  WORD     i, num;
  LONG     item;
  WINDOWP  winds [MAX_GEMWIND];
  BOOLEAN  redraw_desk, redraw_all;

  switch (window->exit_obj)
  {
    case UICOLOR   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (colors, 16));
                     ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                     {
                       ListBoxSetStyle (window->object, UIPAT, LBS_DISABLED, item == WHITE);
                       draw_object (window, UIPAT);
                     } /* if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case UIPAT     : ListBoxSetComboRect (window->object, window->exit_obj, NULL, 8);
                     ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                     ListBoxComboClick (window->object, window->exit_obj, mk);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case UISYSINX  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, MAX_SYSCOLORS);
                     ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                     ListBoxComboClick (window->object, window->exit_obj, mk);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case UISYSCOL  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, 16);
                     ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                     {
                       syscolors [ListBoxGetCurSel (window->object, UISYSINX)]= (WORD)item;
                       changed = TRUE;
                     } /* if */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case UICHECK   : 
    case UIRADIO   : 
    case UIARROW   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, 2);
                     ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                     if ((item = ListBoxComboClick (window->object, window->exit_obj, mk)) != FAILURE)
                       changed = TRUE;
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
    case UIRESET   : syscolors [COLOR_HIGHLIGHT]     = DBLUE;
                     syscolors [COLOR_HIGHLIGHTTEXT] = WHITE;
                     syscolors [COLOR_DISABLED]      = DGRAY;
                     syscolors [COLOR_BTNFACE]       = GRAY;
                     syscolors [COLOR_BTNHIGHLIGHT]  = WHITE;
                     syscolors [COLOR_BTNSHADOW]     = DGRAY;
                     syscolors [COLOR_BTNTEXT]       = BLACK;
                     syscolors [COLOR_SCROLLBAR]     = DGRAY;
                     syscolors [COLOR_DIALOG]        = GRAY;

                     set_checkbox (userintr, UIUSE3D, TRUE);
                     set_checkbox (userintr, UIROUND, TRUE);
                     ListBoxSetCurSel (userintr, UICOLOR, (colors == 2) ? BLACK : DGREEN);
                     ListBoxSetCurSel (userintr, UIPAT, (colors == 2) ? 4 : 7);
                     ListBoxSetStyle (userintr, UIPAT, LBS_DISABLED, ListBoxGetCurSel (userintr, UICOLOR) == WHITE);
                     ListBoxSetCurSel (userintr, UISYSINX, 0);
                     strncpy (get_str (userintr, UISYSINX), index_str [0], num_chars);
                     ListBoxSetCurSel (userintr, UISYSCOL, syscolors [ListBoxGetCurSel (userintr, UISYSINX)]);
                     ListBoxSetCurSel (userintr, UICHECK, 0);
                     ListBoxSetCurSel (userintr, UIRADIO, 0);
                     ListBoxSetCurSel (userintr, UIARROW, 0);

#if CONFIG_DESKTOP_WINDOW
                     set_checkbox (userintr, UIUSEWND, FALSE);
                     set_checkbox (userintr, UITOP, FALSE);
                     set_checkbox (userintr, UISB, FALSE);
#endif

                     set_redraw (window, &window->scroll);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     changed = TRUE;
                     break;
    case UIOK      : redraw_all  = changed ||
                                   (use_3d != get_checkbox (userintr, UIUSE3D)) ||
                                   (dlg_round_borders != get_checkbox (userintr, UIROUND)) ||
                                   (btn_round_borders != get_checkbox (userintr, UIROUNDB)) ||
                                   (btn_shadow_width != get_word (userintr, UISHADOW));
                     redraw_desk = (color_desktop != ListBoxGetCurSel (userintr, UICOLOR)) || (pattern_desktop != ListBoxGetCurSel (userintr, UIPAT));
                     changed     = FALSE;

                     get_dialog ();

                     if (redraw_all)
                     {
                       ListBoxSetFont (userintr, UICHECK, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
                       ListBoxSetFont (userintr, UIRADIO, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);
                       ListBoxSetFont (userintr, UIARROW, FAILURE, FAILURE, FAILURE, FAILURE, sys_colors [COLOR_DIALOG]);

                       num = num_windows (NIL, SRCH_OPENED, winds);
                       for (i = 0; i < num; i++)
                         set_redraw (winds [i], &winds [i]->work);
                     } /* if */

                     num = num_windows (CLASS_DIALOG, SRCH_OPENED, winds);
                     for (i = 0; i < num; i++)
                       if (winds [i]->object->ob_spec != 0L)
                         winds [i]->object->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];

                     if (redraw_desk)
                     {
                       desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | (pattern_desktop << 4) | color_desktop;
                       if (! redraw_all)
                         draw_object (search_window (class_desk, SRCH_ANY, NIL), ROOT);
                     } /* if */
                     break;
    case UICANCEL  : set_dialog ();
                     break;
    case UIHELP    : call_helpfunc (helpid);
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                     break;
  } /* switch */

  if (is_state (window->object, UIUSE3D, SELECTED) && (colors >= 16) == is_state (window->object, UIROUND, DISABLED))
  {
    flip_state (window->object, UIROUND, DISABLED);
    draw_object (window, UIROUND);
  } /* if */
} /* click_dialog */

/*****************************************************************************/

LOCAL BOOLEAN key_dialog (WINDOWP window, MKINFO *mk)
{
  return (FALSE);
} /* key_dialog */

/*****************************************************************************/

