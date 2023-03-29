/*****************************************************************************/
/*                                                                           */
/* Modul: MLOCKSCR.C                                                         */
/* Datum: 13/08/91                                                           */
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
#include "mlockscr.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL DB       *lockdb;         /* database to lock */
LOCAL WORD     old_inx;         /* index into old password for edit_noecho */
LOCAL PASSWORD oldpass;         /* old password for lockscreen */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_lockscr  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_lockscr    _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mlockscreen (db)
DB *db;

{
  WINDOWP   window;
  BASE_INFO base_info;
  FULLNAME  dbname;
  WORD      w;

  lockdb = db;
  window = search_window (CLASS_DIALOG, SRCH_ANY, LOCKSCRN);

  if (window == NULL)
  {
    lockscrn->ob_x      = 0;
    lockscrn->ob_y      = 0;
    lockscrn->ob_width  = desk.w;
    lockscrn->ob_height = desk.h - gl_hattr;

    window = crt_dialog (lockscrn, NULL, LOCKSCRN, FREETXT (FLOCKSCR), WI_MODAL);

    if (window != NULL)
    {
      lockscrn [LOCKBOX].ob_x = (lockscrn->ob_width - lockscrn [LOCKBOX].ob_width) / 2;
      lockscrn [LOCKBOX].ob_y = (lockscrn->ob_height - lockscrn [LOCKBOX].ob_height) / 2;

      window->kind  = NAME;
      window->click = click_lockscr;
      window->key   = key_lockscr;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (lockscrn, ROOT, EDITABLE);
      window->edit_inx = NIL;
      old_inx          = 0;
      oldpass [0]      = EOS;
      w                = lockscrn [LOCKNAME].ob_width / gl_wbox;

      db_baseinfo (lockdb->base, &base_info);
      strcpy (dbname, base_info.basepath);
      strcat (dbname, base_info.basename);
      dbname [w] = EOS;
      strcpy (get_str (lockscrn, LOCKNAME), dbname);
      set_ptext (lockscrn, LOCKPASS, "");
      do_state (lockscrn, LOCKOK, DISABLED);
    } /* if */

    if (! open_dialog (LOCKSCRN)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mlockscreen */

/*****************************************************************************/

LOCAL VOID click_lockscr (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case LOCKPASS : old_inx = window->edit_inx;
                    break;
    case LOCKOK   : break;
    case LOCKHELP : hndl_help (HLOCKSCR);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_lockscr */

/*****************************************************************************/

LOCAL BOOLEAN key_lockscr (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->edit_obj)
  {
    case LOCKPASS : if (window->exit_obj == 0)  /* not clicked but edited */
                      edit_noecho (mk, old_inx, oldpass, MAX_PASSWORD);

                    db_convstr (lockdb->base, oldpass);
                    if ((strcmp (oldpass, lockdb->password) != 0) == ! is_state (lockscrn, LOCKOK, DISABLED))
                    {
                      flip_state (lockscrn, LOCKOK, DISABLED);
                      draw_object (window, LOCKOK);
                    } /* if */

                    old_inx = window->edit_inx;
                    break;
  } /* switch */

  return (FALSE);
} /* key_lockscrn */

