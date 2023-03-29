/*****************************************************************************
 *
 * Module : CALCEXEC.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the calculation process.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 17.07.95: Extra parameter added in calling v_execute
 * 31.01.95: Using of variable warn_table added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "dialog.h"
#include "list.h"
#include "process.h"

#include "export.h"
#include "calcexec.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN work_calc _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_calc _((PROC_INF *proc_inf));

/*****************************************************************************/

GLOBAL BOOLEAN calc_list (db, table, inx, dir, calccode, minimize)
DB       *db;
WORD     table, inx, dir;
CALCCODE *calccode;
BOOLEAN  minimize;

{
  WINDOWP  window;
  LONG     numkeys;
  PROC_INF proc_inf, *procp;
  BYTE     *title;

  numkeys = num_keys (db, table, inx);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return (FALSE);

  if (! (db_acc_table (db->base, rtable (table)) & GRANT_UPDATE))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return (FALSE);
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
  proc_inf.workfunc     = work_calc;
  proc_inf.stopfunc     = stop_calc;

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

  title  = FREETXT (FPCALC);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, calccode->size + sizeof (LONG), wi_modeless);

  if (window != NULL)
  {
    procp = (PROC_INF *)window->special;

    mem_lmove (procp->memory, calccode, calccode->size + sizeof (LONG));

    start_process (window, minimize_process, TRUE);
  } /* if */

  return (TRUE);
} /* calc_list */

/*****************************************************************************/

LOCAL BOOLEAN work_calc (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;
  WORD    status;

  ok = FALSE;

  if (v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir))
    if (v_read (proc_inf->db, proc_inf->table, proc_inf->db->buffer, proc_inf->cursor, 0L, TRUE))
    {
      v_execute (proc_inf->db, proc_inf->table, (CALCCODE *)proc_inf->memory, proc_inf->db->buffer, proc_inf->actrec + 1, NULL);
      ok = db_update (proc_inf->db->base, rtable (proc_inf->table), proc_inf->db->buffer, &status);

      if (! ok) ok = dbtest (proc_inf->db) != 1;
    } /* if, if */

  return (ok);
} /* work_calc */

/*****************************************************************************/

LOCAL BOOLEAN stop_calc (proc_inf)
PROC_INF *proc_inf;

{
  updt_lsall (proc_inf->db, proc_inf->table, FALSE, FALSE);

  return (TRUE);
} /* stop_calc */

