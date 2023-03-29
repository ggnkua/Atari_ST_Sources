/*****************************************************************************/
/*                                                                           */
/* Modul: MINXINFO.C                                                         */
/* Datum: 30/12/90                                                           */
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
#include "minxinfo.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID click_inxinfo _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID set_inxinfo ()

{
  BASE_INFO  base_info;
  TABLE_INFO table_info;
  INDEX_INFO index_info;
  FULLNAME   dbname;
  WORD       w;

  if (db_baseinfo (actdb->base, &base_info))
  {
    w = inxinfo [IIDBNAME].ob_width / gl_wbox;

    strcpy (dbname, base_info.basepath);
    strcat (dbname, base_info.basename);
    dbname [w] = EOS;
    set_str (inxinfo, IIDBNAME, dbname);

    if (db_tableinfo (actdb->base, actdb->table, &table_info) != FAILURE)
    {
      set_str (inxinfo, IITABLE, table_info.name);

      if (db_indexinfo (actdb->base, actdb->table, actdb->t_info [actdb->t_inx].index, &index_info) != FAILURE)
      {
        w = inxinfo [IIINDEX].ob_width / gl_wbox;
        index_info.indexname [w] = EOS;
        set_str (inxinfo, IINAME, index_info.name);
        set_str (inxinfo, IIINDEX, index_info.indexname);
        str_type (index_info.type, get_str (inxinfo, IITYPE));
        set_long (inxinfo, IIROOT, index_info.root);
        set_long (inxinfo, IINUMKEY, index_info.num_keys);
        set_str (inxinfo, IIPRIMAR, FREETXT ((index_info.flags & INX_PRIMARY) ? FYES : FNO));
        set_str (inxinfo, IIUNIQUE, FREETXT ((index_info.flags & INX_UNIQUE) ? FYES : FNO));
        set_str (inxinfo, IIFOREIG, FREETXT ((index_info.flags & INX_FOREIGN) ? FYES : FNO));
      } /* if */
    } /* if */
  } /* if */
} /* set_inxinfo */

/*****************************************************************************/

GLOBAL VOID check_inxinfo ()

{
  WINDOWP window;

  window = search_window (CLASS_DIALOG, SRCH_OPENED, INXINFO);

  if (window != NULL)
    if (actdb != NULL)
    {
      set_inxinfo ();
      set_redraw (window, &window->scroll);
    } /* if */
    else
      close_window (window);
} /* check_inxinfo */

/*****************************************************************************/

GLOBAL VOID minxinfo ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, INXINFO);

  if (window == NULL)
  {
    form_center (inxinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (inxinfo, NULL, INXINFO, FREETXT (FINXINFO), wi_modeless);

    if (window != NULL) window->click = click_inxinfo;
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0) set_inxinfo ();
    if (! open_dialog (INXINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* minxinfo */

/*****************************************************************************/

LOCAL VOID click_inxinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case IIOK   : break;
    case IIHELP : hndl_help (HINXINFO);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_inxinfo */

