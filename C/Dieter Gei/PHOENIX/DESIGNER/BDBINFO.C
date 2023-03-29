/*****************************************************************************
 *
 * Module : BDBINFO.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.11.93
 *
 *
 * Description: This module implements the base database info dialog box.
 *
 * History:
 * 04.11.93: Modifications for user defined buttons added
 * 08.09.93: set_ptext -> set_str
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"

#include "export.h"
#include "bdbinfo.h"

/****** DEFINES **************************************************************/

#define DATEFORMAT	"DD.MM.YYYY   HH:MI:SS"

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID set_dbinfo   _((BASE_SPEC *base_spec));
LOCAL VOID click_dbinfo _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mdbinfo (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DBINFO);

  if (window == NULL)
  {
    form_center (dbinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (dbinfo, NULL, DBINFO, FREETXT (FDBINFO), WI_MODELESS);

    if (window != NULL) window->click = click_dbinfo;
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = 0;
    window->edit_inx = NIL;

    set_dbinfo (base_spec);

    if (! open_dialog (DBINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mdbinfo */

/*****************************************************************************/

LOCAL VOID set_dbinfo (base_spec)
BASE_SPEC *base_spec;

{
  WORD      w, perc;
  LONG      size, used, rlsd;
  STRING    s;
  FULLNAME  dbname;
  FORMAT    format;
  BYTE      *p;
  BASE_INFO *base_info;

  base_info = base_spec->new ? NULL : &base_spec->base_info;

  if (base_info != NULL)
  {
    p = FREETXT (FPERCENT);
    w = dbinfo [DIDBNAME].ob_width / gl_wbox;

    strcpy (dbname, base_info->basepath);
    strcat (dbname, base_info->basename);
    dbname [w] = EOS;
    set_str (dbinfo, DIDBNAME, dbname);
    set_str (dbinfo, DIUSER, base_info->username);

    build_format (TYPE_TIMESTAMP, DATEFORMAT, format);
    bin2str (TYPE_TIMESTAMP, &base_info->data_info.created, s);
    str2format (TYPE_TIMESTAMP, s, format);
    strcpy (get_str (dbinfo, DICREAT), s);

    bin2str (TYPE_TIMESTAMP, &base_info->data_info.lastuse, s);
    str2format (TYPE_TIMESTAMP, s, format);
    strcpy (get_str (dbinfo, DILASTUS), s);

    size = base_info->data_info.file_size / 1024;
    used = base_info->data_info.next_rec / 1024;
    rlsd = base_info->data_info.size_released / 1024;
    perc = (WORD)(used * 100 / size);

    sprintf (get_str (dbinfo, DIDATSIZ), p, size);
    sprintf (get_str (dbinfo, DIDATUSE), p, used);
    sprintf (get_str (dbinfo, DIDATUSP), "(%d%%)", perc);
    sprintf (get_str (dbinfo, DIDATFRE), p, size - used);
    sprintf (get_str (dbinfo, DIDATFRP), "(%d%%)", 100 - perc);
    sprintf (get_str (dbinfo, DIDATCAC), "%ld KB", base_info->data_info.cache_size / 1024L);
    sprintf (get_str (dbinfo, DIDATHIT), "%ld%%", (base_info->data_info.num_calls == 0) ? 0 :  base_info->data_info.num_hits * 100 / base_info->data_info.num_calls);
    set_str (dbinfo, DIDATFLU, FREETXT ((base_spec->oflags & DATA_FLUSH) ? FYES : FNO));
    sprintf (get_str (dbinfo, DIHOLES), p, rlsd);
    sprintf (get_str (dbinfo, DIHOLESP), "(%d%%)", (INT)(rlsd * 100 / size));
    set_str (dbinfo, DIDATMOD, FREETXT ((base_spec->oflags & BASE_MULUSER) ? FMULUSER : (base_spec->oflags & BASE_MULTASK) ? FMULTASK : FSINGLE));
    set_str (dbinfo, DIRDWR, FREETXT ((base_spec->oflags & BASE_RDONLY) ? FRDONLY : FRDWR));

    size = base_info->tree_info.num_pages / 2;
    used = base_info->tree_info.used_pages / 2;
    perc = (WORD)(used * 100 / size);

    sprintf (get_str (dbinfo, DIINDSIZ), p, size, 100);
    sprintf (get_str (dbinfo, DIINDUSE), p, used, perc);
    sprintf (get_str (dbinfo, DIINDUSP), "(%d%%)", perc);
    sprintf (get_str (dbinfo, DIINDFRE), p, size - used, 100 - perc);
    sprintf (get_str (dbinfo, DIINDFRP), "(%d%%)", 100 - perc);
    sprintf (get_str (dbinfo, DIINDCAC), "%ld KB", base_info->tree_info.num_vpages / 2);
    sprintf (get_str (dbinfo, DIINDHIT), "%ld%%", (base_info->tree_info.num_calls == 0) ? 0 :  base_info->tree_info.num_hits * 100 / base_info->tree_info.num_calls);
    set_str (dbinfo, DIINDFLU, FREETXT ((base_spec->oflags & TREE_FLUSH) ? FYES : FNO));
  } /* if */
} /* set_dbinfo */

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
