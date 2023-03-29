/*****************************************************************************/
/*                                                                           */
/* Modul: SELWIDTH.C                                                         */
/* Datum: 15/08/93                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "selwidth.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    diff;
  WORD    width;
  WORD    minwidth;
  WORD    maxwidth;
  LONG    reswidth;
  BOOLEAN show_reswidth;
} RESULT;

/****** VARIABLES ************************************************************/

LOCAL RESULT result;    /* result of selected width */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_selwidth _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_selwidth   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_selwidth ()

{
  return (TRUE);
} /* init_selwidth */

/*****************************************************************************/

GLOBAL BOOLEAN term_selwidth ()

{
  return (TRUE);
} /* term_selwidth */

/*****************************************************************************/

GLOBAL WORD selwidth (name, width, minwidth, maxwidth, reswidth, show_reswidth)
BYTE    *name;
WORD    width, minwidth, maxwidth;
LONG    reswidth;
BOOLEAN show_reswidth;

{
  WINDOWP window;
  WORD    ret;

  result.diff = 0;
  window      = search_window (CLASS_DIALOG, SRCH_ANY, NEWWIDTH);

  if (window == NULL)
  {
    form_center (newwidth, &ret, &ret, &ret, &ret);
    window = crt_dialog (newwidth, NULL, NEWWIDTH, FREETXT (FNEWWIDT), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_selwidth;
      window->key   = key_selwidth;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (newwidth, ROOT, EDITABLE);
      window->edit_inx = NIL;

      set_str (newwidth, NWCOLUMN, name);
      set_word (newwidth, NWWIDTH, width);
      set_word (newwidth, NWMIN, width + minwidth);
      set_word (newwidth, NWMAX, width + maxwidth);
      set_long (newwidth, NWRESULT, reswidth);

      if (show_reswidth)
        undo_state (newwidth, NWRESULT - 2, DISABLED);
      else
        do_state (newwidth, NWRESULT - 2, DISABLED);

      result.width         = width;
      result.minwidth      = width + minwidth;
      result.maxwidth      = width + maxwidth;
      result.reswidth      = reswidth;
      result.show_reswidth = show_reswidth;
      undo_state (newwidth, NWOK, DISABLED);
    } /* if */

    if (! open_dialog (NEWWIDTH)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (result.diff);
} /* selwidth */

/*****************************************************************************/

LOCAL VOID click_selwidth (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case NWOK   : result.diff = get_word (newwidth, NWWIDTH) - result.width;
                  break;
    case NWHELP : hndl_help (HNEWWIDT);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_selwidth */

/*****************************************************************************/

LOCAL BOOLEAN key_selwidth (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;
  WORD width;

  p     = get_str (newwidth, NWWIDTH);
  width = get_word (newwidth, NWWIDTH);

  if (width < 0) width = 0;

  if (result.show_reswidth)
  {
    set_long (newwidth, NWRESULT, result.reswidth + width - result.width);
    draw_object (window, NWRESULT);
  } /* if */

  if (((*p == EOS) || (width < result.minwidth) || (width > result.maxwidth)) == ! is_state (newwidth, NWOK, DISABLED))
  {
    flip_state (newwidth, NWOK, DISABLED);
    draw_object (window, NWOK);
  } /* if */

  return (FALSE);
} /* key_selwidth */
