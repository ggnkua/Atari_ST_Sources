/*****************************************************************************
 *
 * Module : SELECT.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 02.11.93
 *
 *
 * Description: This module implements the selection dialog box.
 *
 * History:
 * 02.11.93: Superflous listbox variable removed
 * 10.09.93: New 3d listbox added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "select.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BOOLEAN exit_status;      /* status of exit button */
LOCAL BYTE    *itemlist;        /* list of items */
LOCAL SIZE_T  itemsize;         /* size of one item */

/****** FUNCTIONS ************************************************************/

LOCAL LONG callback     _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID click_select _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_select ()

{
  return (TRUE);
} /* init_select */

/*****************************************************************************/

GLOBAL BOOLEAN term_select ()

{
  return (TRUE);
} /* term_select */

/*****************************************************************************/

GLOBAL BOOLEAN selection (sel_spec)
SEL_SPEC *sel_spec;

{
  WINDOWP window;
  WORD    ret;
  LONG    index;

  exit_status = FALSE;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, SELBOX);

  if (window == NULL)
  {
    form_center (selbox, &ret, &ret, &ret, &ret);
    window = crt_dialog (selbox, NULL, SELBOX, sel_spec->title, WI_MODAL);

    if (window != NULL) window->click = click_select;
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      strcpy (window->name, sel_spec->title);

      window->special  = (LONG)sel_spec;
      window->edit_obj = find_flags (selbox, ROOT, EDITABLE);
      window->edit_inx = NIL;

      strcpy (get_str (selbox, SELSTR), sel_spec->selection);
      strcpy (get_str (selbox, SELTITLE), sel_spec->boxtitle);

      itemlist = sel_spec->itemlist;
      itemsize = sel_spec->itemsize;

      ListBoxSetCallback (selbox, SELLIST, callback);
      ListBoxSetStyle (selbox, SELLIST, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE |  LBS_MANDATORY, TRUE);
      ListBoxSetCount (selbox, SELLIST, sel_spec->num_items, NULL);
      ListBoxSetCurSel (selbox, SELLIST, index = ListBoxFindStringExact (selbox, SELLIST, 0, sel_spec->selection));
      ListBoxSetTopIndex (selbox, SELLIST, index);

      if (sel_spec->selection [0] == EOS)
        do_state (selbox, SELOK, DISABLED);
      else
        undo_state (selbox, SELOK, DISABLED);
    } /* if */

    if (! open_dialog (SELBOX)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_status);
} /* selection */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP  window;
  SEL_SPEC *sel_spec;
  STRING   s;

  switch (msg)
  {
    case LBN_GETITEM   : return ((LONG)&itemlist [index * itemsize]);
    case LBN_DRAWITEM  : break;
    case LBN_SELCHANGE : window   = find_window (wh);
                         sel_spec = (SEL_SPEC *)window->special;
                         ListBoxGetText (tree, obj, index, s);
                         strcpy (get_str (selbox, SELSTR), s);
                         draw_object (window, SELSTR);
                         set_cursor (window, SELSTR, NIL);
                         break;
    case LBN_DBLCLK    : window         = find_window (wh);
                         sel_spec       = (SEL_SPEC *)window->special;
                         exit_status    = TRUE;
                         window->flags |= WI_DLCLOSE;
                         ListBoxGetText (tree, obj, index, s);
                         strcpy (get_str (selbox, SELSTR), s);
                         draw_object (window, SELSTR);
                         set_cursor (window, SELSTR, NIL);
                         strcpy (sel_spec->selection, s);
                         break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID click_select (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  SEL_SPEC *sel_spec;
  BYTE     *p;

  sel_spec    = (SEL_SPEC *)window->special;
  exit_status = window->exit_obj == SELOK;

  if (window->exit_obj == SELLIST)
  {
     ListBoxSetWindowHandle (window->object, window->exit_obj, window->handle);	/* window handle is valid now */
     ListBoxClick (window->object, window->exit_obj, mk);
  } /* if */

  switch (window->exit_obj)
  {
    case SELOK   : get_ptext (selbox, SELSTR, sel_spec->selection);
                   break;
    case SELHELP : hndl_help (sel_spec->helpinx);
                   undo_state (window->object, window->exit_obj, SELECTED);
                   draw_object (window, window->exit_obj);
                   break;
  } /* switch */

  p = get_str (selbox, SELSTR);

  if ((*p == EOS) == ! is_state (selbox, SELOK, DISABLED))
  {
    flip_state (selbox, SELOK, DISABLED);
    draw_object (window, SELOK);
  } /* if */
} /* click_select */

/*****************************************************************************/
