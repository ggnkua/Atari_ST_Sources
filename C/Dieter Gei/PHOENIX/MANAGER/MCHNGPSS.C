/*****************************************************************************/
/*                                                                           */
/* Modul: MCHNGPSS.C                                                         */
/* Datum: 14/11/91                                                           */
/*                                                                           */
/*****************************************************************************/

#include "redefs.h"

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "mchngpss.h"

/****** DEFINES **************************************************************/

#define INX_NAME    1           /* index of username in SYS_USER */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD     old_inx;         /* index into old password for edit_noecho */
LOCAL WORD     new_inx;         /* index into new password for edit_noecho */
LOCAL WORD     ver_inx;         /* index into verify password for edit_noecho */
LOCAL PASSWORD oldpass;         /* old password for changepass */
LOCAL PASSWORD newpass;         /* new password for changepass */
LOCAL PASSWORD verpass;         /* verify password for changepass */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_chngpass _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_chngpass   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mchangepass ()

{
  WINDOWP   window;
  WORD      ret, w;
  BASE_INFO base_info;
  FULLNAME  dbname;

  window = search_window (CLASS_DIALOG, SRCH_ANY, CHNGPASS);

  if (window == NULL)
  {
    form_center (chngpass, &ret, &ret, &ret, &ret);

    window = crt_dialog (chngpass, NULL, CHNGPASS, FREETXT (FCHNGPSS), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_chngpass;
      window->key   = key_chngpass;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      if (actdb->password [0] == EOS)
      {
        undo_flags (chngpass, CHOLDPSS, EDITABLE);
        do_state (chngpass, CHOLDPSS - 1, DISABLED);
        undo_state (chngpass, CHOK, DISABLED);
      } /* if */
      else
      {
        do_flags (chngpass, CHOLDPSS, EDITABLE);
        undo_state (chngpass, CHOLDPSS - 1, DISABLED);
        do_state (chngpass, CHOK, DISABLED);
      } /* else */

      window->edit_obj = find_flags (chngpass, ROOT, EDITABLE);
      window->edit_inx = NIL;
      old_inx          = new_inx = ver_inx = 0;
      oldpass [0]      = newpass [0] = verpass [0] = EOS;
      w                = chngpass [CHNAME].ob_width / gl_wbox;

      db_baseinfo (actdb->base, &base_info);
      strcpy (dbname, base_info.basepath);
      strcat (dbname, base_info.basename);
      dbname [w] = EOS;
      strcpy (get_str (chngpass, CHNAME), dbname);
      strcpy (get_str (chngpass, CHUSER), base_info.username);
      set_ptext (chngpass, CHOLDPSS, "");
      set_ptext (chngpass, CHNEWPSS, "");
      set_ptext (chngpass, CHVERIFY, "");
    } /* if */

    if (! open_dialog (CHNGPASS)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mchangepass */

/*****************************************************************************/

LOCAL VOID click_chngpass (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  CURSOR  cursor;
  SYSUSER sys_user;
  WORD    status;

  switch (window->exit_obj)
  {
    case CHOLDPSS : old_inx = window->edit_inx;
                    break;
    case CHNEWPSS : new_inx = window->edit_inx;
                    break;
    case CHVERIFY : ver_inx = window->edit_inx;
                    break;
    case CHOK     : strcpy (sys_user.name, actdb->base->username);
                    busy_mouse ();

                    if (db_search (actdb->base, SYS_USER, INX_NAME, ASCENDING, &cursor, &sys_user, 0L))
                      if (db_read (actdb->base, SYS_USER, &sys_user, &cursor, 0L, TRUE))
                      {
                        build_pass (newpass, sys_user.pass);
                        if (db_update (actdb->base, SYS_USER, &sys_user, &status))
                          strcpy (actdb->password, newpass);
                      } /* if, if */

                    arrow_mouse ();
                    dbtest (actdb);
                    break;
    case CHHELP   : hndl_help (HCHNGPSS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_chngpass */

/*****************************************************************************/

LOCAL BOOLEAN key_chngpass (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  mk->ascii_code = ch_upper (mk->ascii_code);   /* passwords are upper case only */

  switch (window->edit_obj)
  {
    case CHOLDPSS : if (window->exit_obj == 0)  /* not clicked but edited */
                      edit_noecho (mk, old_inx, oldpass, MAX_PASSWORD);

                    db_convstr (actdb->base, oldpass);
                    old_inx = window->edit_inx;
                    break;
    case CHNEWPSS : if (window->exit_obj == 0)  /* not clicked but edited */
                      edit_noecho (mk, new_inx, newpass, MAX_PASSWORD);

                    db_convstr (actdb->base, newpass);
                    new_inx = window->edit_inx;
                    break;
    case CHVERIFY : if (window->exit_obj == 0)  /* not clicked but edited */
                      edit_noecho (mk, ver_inx, verpass, MAX_PASSWORD);

                    db_convstr (actdb->base, verpass);
                    ver_inx = window->edit_inx;
                    break;
  } /* switch */

  if (((strcmp (oldpass, actdb->password) != 0) || (strcmp (newpass, verpass) != 0)) == ! is_state (chngpass, CHOK, DISABLED))
  {
    flip_state (chngpass, CHOK, DISABLED);
    draw_object (window, CHOK);
  } /* if */

  return (FALSE);
} /* key_chngpass */

