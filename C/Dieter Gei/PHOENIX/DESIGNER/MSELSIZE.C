/*****************************************************************************/
/*                                                                           */
/* Modul: MSELSIZE.C                                                         */
/* Datum: 24/01/91                                                           */
/*                                                                           */
/*****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"

#include "export.h"
#include "mselsize.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL LONG x_size;      /* will be set on dialog exit */
LOCAL LONG y_size;      /* will be set on dialog exit */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_size   _((VOID));
LOCAL VOID    set_size   _((VOID));
LOCAL VOID    click_size _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_size   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL VOID mselsize (size_x, size_y)
LONG *size_x;
LONG *size_y;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELSIZE);

  if (window == NULL)
  {
    form_center (selsize, &ret, &ret, &ret, &ret);
    window = crt_dialog (selsize, NULL, SELSIZE, FREETXT (FSELSIZE), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_size;
      window->key   = key_size;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (selsize, ROOT, EDITABLE);
      window->edit_inx = NIL;

      x_size = *size_x;
      y_size = *size_y;
      set_size ();
    } /* if */

    if (! open_dialog (SELSIZE))
      hndl_alert (ERR_NOOPEN);
    else
    {
      *size_x = x_size;
      *size_y = y_size;
    } /* else */
  } /* if */
} /* mselsize */

/*****************************************************************************/

LOCAL VOID get_size ()

{
  x_size = get_long (selsize, MSIZEX);
  y_size = get_long (selsize, MSIZEY);
} /* get_size */

/*****************************************************************************/

LOCAL VOID set_size ()

{
  set_long (selsize, MSIZEX, x_size);
  set_long (selsize, MSIZEY, y_size);
} /* set_size */

/*****************************************************************************/

LOCAL VOID click_size (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case MSOK   : get_size ();
                  break;
    case MSHELP : hndl_help (HSELSIZE);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_size */

/*****************************************************************************/

LOCAL BOOLEAN key_size (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONG x, y;
  BYTE *p1, *p2;

  switch (window->edit_obj)
  {
    case MSIZEX :
    case MSIZEY : p1 = get_str (selsize, MSIZEX);
                  p2 = get_str (selsize, MSIZEY);
                  x  = get_long (selsize, MSIZEX);
                  y  = get_long (selsize, MSIZEY);

                  if (((*p1 == EOS) || (*p2 == EOS) ||
                       (x == 0) || (y == 0)) == ! is_state (selsize, MSOK, DISABLED))
                  {
                    flip_state (selsize, MSOK, DISABLED);
                    draw_object (window, MSOK);
                  } /* if */
  } /* switch */

  return (FALSE);
} /* key_size */

