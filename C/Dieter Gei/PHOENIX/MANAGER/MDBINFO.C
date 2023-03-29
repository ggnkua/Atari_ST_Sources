/*****************************************************************************
 *
 * Module : MDBINFO.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 22.08.93
 *
 *
 * Description: This module implements the db info dialog box.
 *
 * History:
 * 22.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "mdbinfo.h"

/****** DEFINES **************************************************************/

#define DATEFORMAT	"DD.MM.YYYY   HH:MI:SS"

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID click_dbinfo _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID set_dbinfo ()

{
  BASE_INFO base_info;
  LONG      size, used, rlsd;
  STRING    s;
  FULLNAME  dbname;
  BYTE      *p;
  INT       w, perc;
  FORMAT    format;

  if (db_baseinfo (actdb->base, &base_info))
  {
    p = FREETXT (FPERCENT);
    w = dbinfo [DIDBNAME].ob_width / gl_wbox;

    strcpy (dbname, base_info.basepath);
    strcat (dbname, base_info.basename);
    dbname [w] = EOS;
    set_str (dbinfo, DIDBNAME, dbname);
    set_str (dbinfo, DIUSER, base_info.username);

    build_format (TYPE_TIMESTAMP, DATEFORMAT, format);
    bin2str (TYPE_TIMESTAMP, &base_info.data_info.created, s);
    str2format (TYPE_TIMESTAMP, s, format);
    strcpy (get_str (dbinfo, DICREAT), s);

    bin2str (TYPE_TIMESTAMP, &base_info.data_info.lastuse, s);
    str2format (TYPE_TIMESTAMP, s, format);
    strcpy (get_str (dbinfo, DILASTUS), s);

    size = base_info.data_info.file_size / 1024;
    used = base_info.data_info.next_rec / 1024;
    rlsd = base_info.data_info.size_released / 1024;
    perc = (WORD)(used * 100 / size);

    sprintf (get_str (dbinfo, DIDATSIZ), p, size);
    sprintf (get_str (dbinfo, DIDATUSE), p, used);
    sprintf (get_str (dbinfo, DIDATUSP), "(%d%%)", perc);
    sprintf (get_str (dbinfo, DIDATFRE), p, size - used);
    sprintf (get_str (dbinfo, DIDATFRP), "(%d%%)", 100 - perc);
    sprintf (get_str (dbinfo, DIDATCAC), "%ld KB", base_info.data_info.cache_size / 1024L);
    sprintf (get_str (dbinfo, DIDATHIT), "%ld%%", (base_info.data_info.num_calls == 0) ? 0 :  base_info.data_info.num_hits * 100 / base_info.data_info.num_calls);
    set_str (dbinfo, DIDATFLU, FREETXT ((actdb->flags & DATA_FLUSH) ? FYES : FNO));
    sprintf (get_str (dbinfo, DIHOLES), p, rlsd);
    sprintf (get_str (dbinfo, DIHOLESP), "(%d%%)", (INT)(rlsd * 100 / size));
    set_str (dbinfo, DIDATMOD, FREETXT ((actdb->flags & BASE_MULUSER) ? FMULUSER : (actdb->flags & BASE_MULTASK) ? FMULTASK : FSINGLE));
    set_str (dbinfo, DIRDWR, FREETXT ((actdb->flags & BASE_RDONLY) ? FRDONLY : FRDWR));

    size = base_info.tree_info.num_pages / 2;
    used = base_info.tree_info.used_pages / 2;
    perc = (WORD)(used * 100 / size);

    sprintf (get_str (dbinfo, DIINDSIZ), p, size, 100);
    sprintf (get_str (dbinfo, DIINDUSE), p, used, perc);
    sprintf (get_str (dbinfo, DIINDUSP), "(%d%%)", perc);
    sprintf (get_str (dbinfo, DIINDFRE), p, size - used, 100 - perc);
    sprintf (get_str (dbinfo, DIINDFRP), "(%d%%)", 100 - perc);
    sprintf (get_str (dbinfo, DIINDCAC), "%ld KB", base_info.tree_info.num_vpages / 2);
    sprintf (get_str (dbinfo, DIINDHIT), "%ld%%", (base_info.tree_info.num_calls == 0) ? 0 :  base_info.tree_info.num_hits * 100 / base_info.tree_info.num_calls);
    set_str (dbinfo, DIINDFLU, FREETXT ((actdb->flags & TREE_FLUSH) ? FYES : FNO));
  } /* if */
} /* set_dbinfo */

/*****************************************************************************/

GLOBAL VOID check_dbinfo ()

{
  WINDOWP window;

  window = search_window (CLASS_DIALOG, SRCH_OPENED, DBINFO);

  if (window != NULL)
    if (actdb != NULL)
    {
      set_dbinfo ();
      set_redraw (window, &window->scroll);
    } /* if */
    else
      close_window (window);
} /* check_dbinfo */

/*****************************************************************************/

GLOBAL VOID mdbinfo ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DBINFO);

  if (window == NULL)
  {
    form_center (dbinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (dbinfo, NULL, DBINFO, FREETXT (FDBINFO), wi_modeless);

    if (window != NULL) window->click = click_dbinfo;
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0) set_dbinfo ();
    if (! open_dialog (DBINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mdbinfo */

/*****************************************************************************/

LOCAL VOID click_dbinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case DIOK   : break;
    case DIHELP : hndl_help (HDBINFO);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_dbinfo */

/*****************************************************************************/

