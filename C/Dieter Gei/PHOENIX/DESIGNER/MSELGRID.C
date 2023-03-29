/*****************************************************************************/
/*                                                                           */
/* Modul: MSELGRID.C                                                         */
/* Datum: 05/01/91                                                           */
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
#include "mselgrid.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD     x_grid;  /* will be set on dialog exit */
LOCAL WORD     y_grid;  /* will be set on dialog exit */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_grid      _((VOID));
LOCAL VOID    set_grid      _((VOID));
LOCAL VOID    click_grid    _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_grid      _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL VOID mselgrid (grid_x, grid_y)
WORD *grid_x;
WORD *grid_y;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELGRID);

  if (window == NULL)
  {
    form_center (selgrid, &ret, &ret, &ret, &ret);
    window = crt_dialog (selgrid, NULL, SELGRID, FREETXT (FSELGRID), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_grid;
      window->key   = key_grid;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (selgrid, ROOT, EDITABLE);
      window->edit_inx = NIL;

      x_grid = *grid_x;
      y_grid = *grid_y;
      set_grid ();
    } /* if */

    if (! open_dialog (SELGRID))
      hndl_alert (ERR_NOOPEN);
    else
    {
      *grid_x = g_xgrid = x_grid;
      *grid_y = g_ygrid = y_grid;
    } /* else */
  } /* if */
} /* mselgrid */

/*****************************************************************************/

LOCAL VOID get_grid ()

{
  x_grid = get_word (selgrid, MGRIDX);
  y_grid = get_word (selgrid, MGRIDY);
} /* get_grid */

/*****************************************************************************/

LOCAL VOID set_grid ()

{
  set_word (selgrid, MGRIDX, x_grid);
  set_word (selgrid, MGRIDY, y_grid);
} /* set_grid */

/*****************************************************************************/

LOCAL VOID click_grid (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case MGOK   : get_grid ();
                  break;
    case MGHELP : hndl_help (HSELGRID);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_grid */

/*****************************************************************************/

LOCAL BOOLEAN key_grid (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD x, y;
  BYTE *p1, *p2;

  switch (window->edit_obj)
  {
    case MGRIDX :
    case MGRIDY : p1 = get_str (selgrid, MGRIDX);
                  p2 = get_str (selgrid, MGRIDY);
                  x  = get_word (selgrid, MGRIDX);
                  y  = get_word (selgrid, MGRIDY);

                  if (((*p1 == EOS) || (*p2 == EOS) ||
                       (x == 0) || (y == 0)) == ! is_state (selgrid, MGOK, DISABLED))
                  {
                    flip_state (selgrid, MGOK, DISABLED);
                    draw_object (window, MGOK);
                  } /* if */
  } /* switch */

  return (FALSE);
} /* key_grid */

