/*****************************************************************************
 *
 * Module : MFILE.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 16.06.95
 *
 *
 * Description: This module implements the file menu.
 *
 * History:
 * 16.06.96: Using strcmpi for comparing file names
 * 18.07.95: Closing AccDef windows if database is closed
 * 20.12.94: Datacache is made smaller if not enough memory available
 * 13.03.94: Reorganizer is called with appropiate parameter
 * 10.03.94: Autoquery list is labelled with (!)
 * 16.11.93: Using new file selector
 * 04.11.93: Using fontdesc
 * 07.10.93: Variables max_datacache and max_treecache used
 * 16.09.93: Data cache is set to 0 if opened with multiuser or multitasking option
 * 13.09.93: Component mpos renamed to pos
 * 20.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "batch.h"
#include "batexec.h"
#include "calc.h"
#include "desktop.h"
#include "dialog.h"
#include "list.h"
#include "mask.h"
#include "mdbinfo.h"
#include "minxinfo.h"
#include "mimpexp.h"
#include "mlsconf.h"
#include "mtblinfo.h"
#include "qbe.h"
#include "reorg.h"
#include "report.h"
#include "resource.h"
#include "sql.h"
#include "trash.h"

#include "export.h"
#include "mfile.h"

/****** DEFINES **************************************************************/

#define OPENMEM      128        /* estimated minimum memory to open a database */
#define MINCACHE      16        /* minimum suggested cache for keys */
#define INIT_CURSORS  80        /* number of cursors */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL FULLNAME filename;        /* full name for database to open */
LOCAL WORD     edit_inx;        /* index into password for edit_noecho */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_open _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_open   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_mfile ()

{
  BYTE *p;

  set_ptext (opendb, BUSER, "");
  get_opencfg ();

  strcpy (open_path, fs_path);
  p = strrchr (open_path, PATHSEP);
  if (p != NULL) p [1] = EOS;

  open_name [0] = EOS;

  return (TRUE);
} /* init_mfile */

/*****************************************************************************/

GLOBAL BOOLEAN term_mfile ()

{
  return (TRUE);
} /* term_mfile */

/*****************************************************************************/

GLOBAL VOID get_opencfg ()

{
  get_ptext (opendb, BUSER, opencfg.username);
  opencfg.treecache = get_long (opendb, BINDCACH);
  opencfg.datacache = get_long (opendb, BDATCACH);
  opencfg.treeflush = get_checkbox (opendb, BINDFLSH);
  opencfg.dataflush = get_checkbox (opendb, BDATFLSH);
  opencfg.cursors   = INIT_CURSORS;
  opencfg.rdonly    = get_checkbox (opendb, BRDONLY);
  opencfg.mode      = get_rbutton (opendb, BSINGLE);
} /* get_opencfg */

/*****************************************************************************/

GLOBAL VOID set_opencfg ()

{
  PASSWORD password;

  strcpy (password, opencfg.password);
  strset (password, '*');

  set_ptext (opendb, BUSER, opencfg.username);
  set_ptext (opendb, BPASS, password);
  set_long (opendb, BINDCACH, opencfg.treecache);
  set_long (opendb, BDATCACH, opencfg.datacache);
  set_checkbox (opendb, BINDFLSH, opencfg.treeflush);
  set_checkbox (opendb, BDATFLSH, opencfg.dataflush);
  set_checkbox (opendb, BRDONLY, opencfg.rdonly);
  set_rbutton (opendb, opencfg.mode, BSINGLE, BMULUSER);

  if ((is_state (opendb, BMULTASK, SELECTED) || (is_state (opendb, BMULUSER, SELECTED))) == ! is_state (opendb, BINDFLSH, DISABLED))
  {
    flip_state (opendb, BINDFLSH, DISABLED);
    flip_state (opendb, BDATFLSH, DISABLED);
  } /* if */
} /* set_opencfg */

/*****************************************************************************/

GLOBAL VOID mopendb (dbname, auto_cache)
BYTE    *dbname;
BOOLEAN auto_cache;

{
  WINDOWP  window;
  WORD     ret, w, i;
  BYTE     *p;
  LONG     maxmem;
  FILENAME basename;
  FULLNAME basepath;
  EXT      ext;

  strcpy (filename, (dbname != NULL) ? dbname : open_name);

  if ((dbname != NULL) || (get_open_filename (FOPENDB, NULL, 0L, FFILTER_IND, NULL, open_path, FINDSUFF, filename, open_name)))
  {
    file_split (filename, NULL, open_path, open_name, NULL);
    file_split (filename, NULL, basepath, basename, ext);

    for (i = 0; i < MAX_DB; i++)
      if (db [i].pos != FAILURE)
        if ((strcmpi (basename, db [i].base->basename) == 0) && (strcmpi (basepath, db [i].base->basepath) == 0))
        {
          file_error (ERR_SAMEBASE, filename);
          return;
        } /* if, if, for */

    window = search_window (CLASS_DIALOG, SRCH_ANY, OPENDB);

    if (window == NULL)
    {
      form_center (opendb, &ret, &ret, &ret, &ret);
      window = crt_dialog (opendb, NULL, OPENDB, FREETXT (FOPENDB), WI_MODAL);
    } /* if */

    if (window != NULL)
    {
      window->click = click_open;
      window->key   = key_open;
      strcpy (window->name, FREETXT (FOPENDB));

      if (window->opened == 0)
      {
        window->edit_obj     = find_flags (opendb, ROOT, EDITABLE);
        window->edit_inx     = NIL;
        edit_inx             = 0;
        opencfg.password [0] = EOS;

        p = get_str (opendb, BBASE);
        w = opendb [BBASE].ob_width / gl_wbox;
        strncpy (p, filename, w);
        p [w]  = EOS;
        p      = strrchr (p, SUFFSEP);
        if (p != NULL) *p = EOS;

        if (auto_cache)
        {
          strcpy (filename, basepath);
          strcat (filename, basename);
          strcat (filename, FREETXT (FINDSUFF) + 1);
          if (file_exist (filename)) opencfg.treecache = file_length (filename) / 1024;

          strcpy (filename, basepath);
          strcat (filename, basename);
          strcat (filename, FREETXT (FDATSUFF) + 1);
          if (file_exist (filename)) opencfg.datacache = file_length (filename) / 1024;

          maxmem            = mem_avail () / 1024 - OPENMEM;
          opencfg.treecache = min (opencfg.treecache, maxmem);
          opencfg.treecache = max (opencfg.treecache, MINCACHE);

          if (! is_null (TYPE_LONG, &max_datacache))
            opencfg.datacache = min (opencfg.datacache, max_datacache);

          if (! is_null (TYPE_LONG, &max_treecache))
            opencfg.treecache = min (opencfg.treecache, max_treecache);

          if (opencfg.treecache + opencfg.datacache > maxmem)
            opencfg.datacache = max (0, (maxmem - opencfg.treecache));

          if ((opencfg.mode == BMULUSER) || (opencfg.mode == BMULTASK))
          {
            opencfg.treecache = MINCACHE;
            opencfg.datacache = 0L;
          } /* if */
        } /* if */

        set_opencfg ();
        undo_state (opendb, BOK, DISABLED);
      } /* if */

      if (! open_dialog (OPENDB)) hndl_alert (ERR_NOOPEN);
    } /* if */
  } /* if */
} /* mopendb */

/*****************************************************************************/

GLOBAL VOID mclosedb ()

{
  WORD     result;
  BASENAME basename;

  if (! close_list (actdb)) return;
  if (! close_qbe (actdb)) return;
  if (! close_report (actdb)) return;
  if (! close_calc (actdb)) return;
  if (! close_batch (actdb)) return;
  if (! close_mask (actdb)) return;
  if (! AccDefClose (actdb)) return;
  if (! close_trash ()) return;

  busy_mouse ();
  strcpy (basename, actdb->base->basename);

  result = close_db ();

  if (result != SUCCESS) dberror (basename, result);

  crt_trash (NULL, NULL, ITRASH);
  check_dbinfo ();
  check_tblinfo ();
  check_inxinfo ();
  set_meminfo ();
  arrow_mouse ();
} /* mclosedb */

/*****************************************************************************/

GLOBAL VOID mopentbl (db, table, index, dir, device, fontdesc, size, filename, minimize, use_query)
DB       *db;
WORD     table, index, dir, device;
FONTDESC *fontdesc;
RECT     *size;
BYTE     *filename;
BOOLEAN   minimize, use_query;

{
  WORD       cols, *columns, *colwidth;
  TABLE_INFO tinf;
  SYSQUERY   *sysquery;
  CURSOR     cursor;
  BOOLEAN    found;
  SQL_RESULT sql_result;

  found = FALSE;

  if (use_query)
  {
    sysquery = mem_alloc (sizeof (SYSQUERY));

    if (sysquery != NULL)		/* enough memory to try special query */
    {
      strcpy (sysquery->name, db_tablename (db->base, rtable (table)));
      found = db_search (db->base, SYS_QUERY, 1, ASCENDING, &cursor, sysquery, 0L);

      if (found)
        if (db_read (db->base, SYS_QUERY, sysquery, &cursor, 0L, FALSE))
        {
          sql_exec (db, sysquery->query, sysquery->name, FALSE, &sql_result);
          found = sql_result.db != NULL;
        } /* if, if */

      mem_free (sysquery);
    } /* if */
  } /* if */
    
  if (found)                                                            /* sql result of sys_query found */
  {
    if (! print_list (sql_result.db, sql_result.table, sql_result.inx, sql_result.dir, sql_result.cols, sql_result.columns, sql_result.colwidth, device, fontdesc, size, "!", minimize))
    {
      if (VTBL (sql_result.table))
        free_vtable (sql_result.table);

      mem_free (sql_result.columns);
      set_meminfo ();
    } /* if */
  } /* if */
  else
    if (v_tableinfo (db, table, &tinf) == FAILURE)
      dbtest (db);
    else
    {
      columns = (WORD *)mem_alloc (2L * tinf.cols * sizeof (WORD));     /* mem_free in module list */

      if (columns == NULL)
        hndl_alert (ERR_NOMEMORY);
      else
      {
        set_meminfo ();
        colwidth = columns + tinf.cols;
        cols     = init_columns (db, rtable (table), tinf.cols, columns, colwidth);

        if (! print_list (db, table, index, dir, cols, columns, colwidth, device, fontdesc, size, filename, minimize))
        {
          mem_free (columns);
          set_meminfo ();
        } /* if */
      } /* else */
    } /* else, else */
} /* mopentbl */

/*****************************************************************************/

LOCAL VOID click_open (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  UWORD    flags;
  WORD     result, button;
  FULLNAME basepath;
  FILENAME basename;
  EXT      ext;
  LONGSTR  s;
  BOOLEAN  opened;
  DB_SPEC  dbs;

  switch (window->exit_obj)
  {
    case BPASS : edit_inx = window->edit_inx;
                 break;
    case BOK   : get_opencfg ();                /* get parameters from box */
                 file_split (filename, NULL, basepath, basename, ext);

                 if ((opencfg.mode == BMULUSER) || (opencfg.mode == BMULTASK))
                 {
                   opencfg.treecache = MINCACHE;
                   opencfg.datacache = 0L;
                 } /* if */

                 flags = (opencfg.mode == BMULUSER) ? BASE_MULUSER : (opencfg.mode == BMULTASK) ? BASE_MULTASK : 0;
                 if (opencfg.treeflush) flags |= TREE_FLUSH;
                 if (opencfg.dataflush) flags |= DATA_FLUSH;
                 if (opencfg.rdonly)    flags |= BASE_RDONLY;

                 result = open_db (filename, flags, opencfg.datacache, opencfg.treecache, opencfg.cursors, opencfg.username, opencfg.password, sort_by_name);

                 if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
                 {
                   opened = TRUE;

                   if ((result == DB_DNOTCLOSED) || (actdb->base->datainf->page0.reorg) || (actdb->base->datainf->page0.version < DB_VERSION))
                   {
                     sprintf (s, alerts [ERR_REORG], actdb->base->basename);

                     if ((result == DB_DNOTCLOSED) && (dberror (basename, result) == 1) || (result != DB_DNOTCLOSED) && (open_alert (s) == 1))
                     {
                       undo_state (opendb, BOK, SELECTED);
                       window->flags &= ~ WI_DLCLOSE;
                       close_window (window);
                       close_db ();
                       opened = FALSE;

                       strcpy (dbs.filename, filename);
                       strcpy (dbs.username, opencfg.username);
                       strcpy (dbs.password, opencfg.password);

                       dbs.flags        = flags;
                       dbs.treecache    = opencfg.treecache;
                       dbs.datacache    = opencfg.datacache;
                       dbs.num_cursors  = opencfg.cursors;
                       dbs.sort_by_name = sort_by_name;

                       reorganizer (&dbs);
                       set_opencfg ();
                       strcpy (s, filename); /* filename cleared by mopendb */
                       mopendb (s, FALSE);
                     } /* if */
                   } /* if */

                   if (opened)
                   {
                     close_trash ();
                     crt_trash (NULL, NULL, ITRASH);
                     check_dbinfo ();
                     check_tblinfo ();
                     check_inxinfo ();
                     set_meminfo ();

                     strcpy (exp_path, actdb->base->basepath);

                     strcpy (filename, actdb->base->basepath);
                     strcat (filename, actdb->base->basename);
                     strcat (filename, FREETXT (FINFSUFF) + 1);
                     if (file_exist (filename)) mload_config (filename, TRUE, FALSE);
                     exec_batch (actdb, NULL);
                   } /* if */
                 } /* if */
                 else
                 {
                   if (result == DB_CPASSWORD) set_cursor (window, BUSER, NIL);
                   if (result == ERR_NOMEMRETRY) set_cursor (window, BINDCACH, NIL);

                   if (result == ERR_SAMEBASE)
                     button = file_error (result, basename);
                   else
                     if (result != DB_DNOLOCK) button = dberror (basename, result);

                   if ((result == DB_CPASSWORD) && (button == 1) ||
                       (result == ERR_NOMEMRETRY) && (button == 1))
                   {
                     window->flags &= ~ WI_DLCLOSE;       /* don't close window */
                     undo_state (window->object, window->exit_obj, SELECTED);
                     draw_object (window, window->exit_obj);
                   } /* if */
                 } /* else */
                 break;
    case BHELP : hndl_help (HOPENDB);
                 undo_state (window->object, window->exit_obj, SELECTED);
                 draw_object (window, window->exit_obj);
                 break;
  } /* switch */

  if ((is_state (opendb, BMULTASK, SELECTED) || (is_state (opendb, BMULUSER, SELECTED))) == ! is_state (opendb, BINDFLSH, DISABLED))
  {
    flip_state (opendb, BINDFLSH, DISABLED);
    draw_object (window, BINDFLSH);
    flip_state (opendb, BDATFLSH, DISABLED);
    draw_object (window, BDATFLSH);
  } /* if */
} /* click_open */

/*****************************************************************************/

LOCAL BOOLEAN key_open (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p1, *p2;

  switch (window->edit_obj)
  {
    case BPASS    : if (window->exit_obj == 0)  /* not clicked but edited */
                      edit_noecho (mk, edit_inx, opencfg.password, MAX_PASSWORD);
                    edit_inx = window->edit_inx;
                    break;
    case BINDCACH :
    case BDATCACH : p1 = get_str (opendb, BINDCACH);
                    p2 = get_str (opendb, BDATCACH);

                    if (((*p1 == EOS) || (*p2 == EOS)) == ! is_state (opendb, BOK, DISABLED))
                    {
                      flip_state (opendb, BOK, DISABLED);
                      draw_object (window, BOK);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* key_open */

/*****************************************************************************/

