/*****************************************************************************
 *
 * Module : DELETE.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the delete/undelete processes.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 31.01.95; Using of variable warn_table added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "list.h"
#include "process.h"
#include "resource.h"

#include "export.h"
#include "impexp.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD exit_button;         /* exit button from dialog */

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN work_delete   _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_delete   _((PROC_INF *proc_inf));
LOCAL BOOLEAN open_delrecs  _((DB *db, WORD table, LONG recs));
LOCAL VOID    click_delrecs _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN work_undelete _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_undelete _((PROC_INF *proc_inf));

/*****************************************************************************/

GLOBAL BOOLEAN init_delete ()

{
  return (TRUE);
} /* init_delete */

/*****************************************************************************/

GLOBAL BOOLEAN term_delete ()

{
  return (TRUE);
} /* term_delete */

/*****************************************************************************/

GLOBAL BOOLEAN delete_list (db, table, inx, dir, minimize, ask)
DB      *db;
WORD    table, inx, dir;
BOOLEAN minimize, ask;

{
  WINDOWP  window;
  LONG     numkeys;
  PROC_INF proc_inf;
  BYTE     *title;

  numkeys = num_keys (db, table, inx);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return (FALSE);

  if (! (db_acc_table (db->base, rtable (table)) & GRANT_DELETE))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return (FALSE);
  } /* if */

  if (ask)
  {
    if (! open_delrecs (db, table, numkeys)) return (FALSE);
    if (exit_button == DELCANCE) return (FALSE);
  } /* if */

  proc_inf.db           = db;
  proc_inf.table        = table;
  proc_inf.inx          = inx;
  proc_inf.dir          = dir;
  proc_inf.cols         = 0;
  proc_inf.columns      = NULL;
  proc_inf.colwidth     = NULL;
  proc_inf.cursor       = db_newcursor (db->base);
  proc_inf.format       = 0;
  proc_inf.maxrecs      = numkeys;
  proc_inf.events_ps    = events_ps;
  proc_inf.recs_pe      = recs_pe;
  proc_inf.impexpcfg    = NULL;
  proc_inf.page_format  = NULL;
  proc_inf.prncfg       = NULL;
  proc_inf.to_printer   = FALSE;
  proc_inf.binary       = FALSE;
  proc_inf.tmp          = FALSE;
  proc_inf.special      = 0;
  proc_inf.filename [0] = EOS;
  proc_inf.file         = NULL;
  proc_inf.filelength   = 0;
  proc_inf.workfunc     = work_delete;
  proc_inf.stopfunc     = stop_delete;

  if (proc_inf.cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    return (FALSE);
  } /* if */

  if (! v_initcursor (db, table, inx, dir, proc_inf.cursor))
  {
    db_freecursor (db->base, proc_inf.cursor);
    return (FALSE);
  } /* if */

  title  = FREETXT (FPDELETE);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, 0L, wi_modeless);

  if (window != NULL)
	{
    start_process (window, minimize_process, TRUE);
	} /* if */

  return (TRUE);
} /* delete_list */

/*****************************************************************************/

GLOBAL BOOLEAN undelete_list (db, table, inx, dir, minimize)
DB      *db;
WORD    table, inx, dir;
BOOLEAN minimize;

{
  WINDOWP  window;
  LONG     numkeys;
  PROC_INF proc_inf;
  BYTE     *title;

  numkeys = num_keys (db, table, inx);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return (FALSE);

  proc_inf.db           = db;
  proc_inf.table        = table;
  proc_inf.inx          = inx;
  proc_inf.dir          = dir;
  proc_inf.cols         = 0;
  proc_inf.columns      = NULL;
  proc_inf.colwidth     = NULL;
  proc_inf.cursor       = db_newcursor (db->base);
  proc_inf.format       = 0;
  proc_inf.maxrecs      = numkeys;
  proc_inf.events_ps    = events_ps;
  proc_inf.recs_pe      = recs_pe;
  proc_inf.impexpcfg    = NULL;
  proc_inf.page_format  = NULL;
  proc_inf.prncfg       = NULL;
  proc_inf.to_printer   = FALSE;
  proc_inf.binary       = FALSE;
  proc_inf.tmp          = FALSE;
  proc_inf.special      = FAILURE;
  proc_inf.filename [0] = EOS;
  proc_inf.file         = NULL;
  proc_inf.filelength   = 0;
  proc_inf.workfunc     = work_undelete;
  proc_inf.stopfunc     = stop_undelete;

  if (proc_inf.cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    return (FALSE);
  } /* if */

  if (! v_initcursor (db, table, inx, dir, proc_inf.cursor))
  {
    db_freecursor (db->base, proc_inf.cursor);
    return (FALSE);
  } /* if */

  title  = FREETXT (FPINSERT);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, 0L, wi_modeless);

  if (window != NULL)
  {
    start_process (window, minimize_process, TRUE);
	} /* if */

  return (TRUE);
} /* undelete_list */

/*****************************************************************************/

LOCAL BOOLEAN work_delete (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;
  WORD    status;
  LONG    address;

  ok = FALSE;

  if (v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir))
    if ((address = v_readcursor (proc_inf->db, proc_inf->cursor, NULL)) != 0)
    {
      if (db_reclock (proc_inf->db->base, address))
        ok = db_delete (proc_inf->db->base, rtable (proc_inf->table), address, &status);

      if (VTBL (proc_inf->table))
      {
        check_vtable (proc_inf->table, address);
        if (proc_inf->dir == ASCENDING) proc_inf->cursor->pos--;
      } /* if */

      if (! ok) ok = integrity (proc_inf->db->base, proc_inf->table, status);
    } /* if, if */

  return (ok);
} /* work_delete */

/*****************************************************************************/

LOCAL BOOLEAN stop_delete (proc_inf)
PROC_INF *proc_inf;

{
  updt_lsall (proc_inf->db, proc_inf->table, FALSE, TRUE);

  return (TRUE);
} /* stop_delete */

/*****************************************************************************/

LOCAL BOOLEAN open_delrecs (db, table, recs)
DB   *db;
WORD table;
LONG recs;

{
  BOOLEAN   ok;
  WINDOWP   window;
  WORD      ret;
  BASE_INFO base_info;
  FULLNAME  dbname;
  TABLENAME tblname;
  WORD      w;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DELRECS);

  if (window == NULL)
  {
    form_center (delrecs, &ret, &ret, &ret, &ret);
    window = crt_dialog (delrecs, NULL, DELRECS, FREETXT (FDELRECS), WI_MODAL);

    if (window != NULL) window->click = click_delrecs;
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0)
    {
      exit_button = DELCANCE;

      if (db_baseinfo (db->base, &base_info))
      {
        w = delrecs [DELDBNAM].ob_width / gl_wbox;

        strcpy (dbname, base_info.basepath);
        strcat (dbname, base_info.basename);
        dbname [w] = EOS;
        strcpy (get_str (delrecs, DELDBNAM), dbname);
        strcpy (get_str (delrecs, DELTABLE), table_name (db, table, tblname));
        sprintf (get_str (delrecs, DELNUMRE), "%ld", recs);
      } /* if */
    } /* if */

    ok = open_dialog (DELRECS);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_delrecs */

/*****************************************************************************/

LOCAL VOID click_delrecs (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case DELOK    : 
    case DELCANCE : exit_button = window->exit_obj;
                    break;
    case DELHELP  : hndl_help (HDELRECS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_delrecs */

/*****************************************************************************/

LOCAL BOOLEAN work_undelete (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN    ok;
  WORD       status;
  SYSDELETED sysdeleted;

  ok = FALSE;

  if (v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir))
    if (v_read (proc_inf->db, proc_inf->table, &sysdeleted, proc_inf->cursor, 0L, FALSE))
    {
      ok = db_undelete (proc_inf->db->base, sysdeleted.del_addr, &status);

      if (! ok) ok = integrity (proc_inf->db->base, sysdeleted.table, status);

      if ((proc_inf->special != sysdeleted.table) && (proc_inf->special != FAILURE))
        updt_lsall (proc_inf->db, proc_inf->special, TRUE, TRUE);

      proc_inf->special = sysdeleted.table; /* save last used table */
    } /* if */

  return (ok);
} /* work_undelete */

/*****************************************************************************/

LOCAL BOOLEAN stop_undelete (proc_inf)
PROC_INF *proc_inf;

{
  if (proc_inf->special != FAILURE)
    updt_lsall (proc_inf->db, proc_inf->special, TRUE, TRUE);

  return (TRUE);
} /* stop_undelete */

