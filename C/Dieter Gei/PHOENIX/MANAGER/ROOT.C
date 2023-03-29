/*****************************************************************************
 *
 * Module : ROOT.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the root definitions.
 *
 * History:
 * 18.01.04: user_help added
 * 25.12.02: Abfrage nach DEBUG in der system_inf entfernt da jetzt es global
 *					 ermittelt wird.
 * 04.11.02: Erzeugung des temporÑen Dateinamen etwas geÑndert.
 * 08.08.02: Hilfeseite an ST Guide wird im globalen Speicher Åbergeben
 * 27.03.97: Debug output for ST Guide added
 * 23.02.97: ST Guide used as help database
 * 27.12.96: type_width uses MAX_BLOBNAME for TYPE_BLOB
 * 20.06.96: Database name in toolbox is no longer set because it's drawn dynamically
 * 16.06.96: Call to str_upper removed
 * 09.08.95: Initialization of variables show_raster and use_raster added
 * 24.07.95: Function printable accepts BLOBs
 * 23.07.95: Definitions for SYS_ACCOUNT added
 * 04.07.95; Parameter retval added in v_execute
 * 31.01.95; Initialization of variable warn_table added
 * 31.12.94: Using new function names of controls module
 * 26.07.94: Global variables fs_path and fs_sel set in get_open_filename and get_save_filename
 * 09.07.94: Visible table capabilities added
 * 21.06.94: Leading blanks removed in col_to_str
 * 10.05.94: Setting EOS in text_import to fix problem with importing short text into long text
 * 19.03.94: Flag TBL_HIDDEN used in open_db to not show certain tables
 * 12.03.94: Initialization of variable show_info added
 * 05.03.94: Initialization of variable show_pattern added
 * 23.02.94: Initialization of variables show_top and show_left added
 * 18.11.93: Help id for get_open_filename and get_save_filename added
 * 03.11.93: Functions load_fonts and unload_fonts removed
 * 28.10.93: Call to build_icon checked
 * 08.10.93: Standard name is SCRAP.TXT in text_import and text_export
 * 07.10.93: Initialization of max_datacache and max_treecache added
 * 03.10.93: Initialization of variable use_3d removed
 * 02.10.93: Functions text_export and text_import added
 * 01.10.93: Bitmap initializations for multikeys added
 * 30.09.93: Initialization of variables color_desktop and pattern_desktop moved to global.c
 * 27.09.93: Bitmap initializations for db's tables, cols, and indices added
 * 13.09.93: New combobox used
 * 09.09.93: New 3d listbox added
 * 27.08.93: Variable hide_iconbar added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"

#include "commdlg.h"
#include "controls.h"
#include "dialog.h"
#include "help.h"
#include "resource.h"

#include "export.h"
#include "root.h"

/****** DEFINES **************************************************************/

#define FONT_SWAPSIZE      3072         /* 3072 * 16 = 48 KByte font swapping */

#define DEC_PERIOD         0x71         /* scan code of decimal period */

#define LEAP_YEAR(year)    ((year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0)))

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

#include "tooldb.h"
#include "tooldbm.h"
#include "tooltbl.h"
#include "tooltblm.h"
#include "toolcol.h"
#include "toolcolm.h"
#include "toolinx.h"
#include "toolinxm.h"
#include "toolmul.h"
#include "toolmulm.h"
#include "toolcal.h"
#include "toolcalm.h"
#include "toolbat.h"
#include "toolbatm.h"

LOCAL BOOLEAN  alpha;                   /* for alphanumeric sorting */
LOCAL FULLNAME tmpname;                 /* temporary file name */
LOCAL WORD     tmpnum = 0;              /* temporary number */
LOCAL WORD     monthwidth;              /* width of longest month name */
LOCAL BYTE     *month_short [12];       /* short month names */
LOCAL BYTE     *month_long [12];        /* long month names */
LOCAL WORD     std_width [NUM_TYPES] = {0, 6, 11, 14, 14, 8, 12, 20, 11, 11, 11, 11, 0, 11, -1, -1, -1, -1, -1, -1};
LOCAL WORD     sumdays [2] [13] =       /* cumulated sum of days of month */
{
  {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365},
  {0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366}
};

/****** FUNCTIONS ************************************************************/

LOCAL INT CALLBACK lockfunc _((BOOL lock));

LOCAL INT     t_compare  _((T_INFO *arg1, T_INFO *arg2));
LOCAL INT     i_compare  _((I_INFO *arg1, I_INFO *arg2));
LOCAL WORD    type_width _((DB *db, WORD type, WORD format));
LOCAL VOID    check_func _((VOID));
LOCAL VOID    show_table _((OBJECT *tree, WORD obj, WORD table));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_root ()

{
  BOOLEAN ok;
  WORD    i, len;
  BYTE    *p;
  DB      *dbp;

  set_helpfunc (appl_help);
  db_init (lockfunc);
  mem_set (db, 0, sizeof (db));
  mem_set (vtables, 0, sizeof (vtables));
  mem_set (vindexes, 0, sizeof (vindexes));

  ok               = TRUE;
  actdb            = NULL;
  num_opendb       = 0;
  sort_order       = ASCENDING;
  sort_by_name     = is_state (popups, MSORTNAM, CHECKED);
  show_raster      = TRUE;
  use_raster       = TRUE;
  lockable         = FALSE;
  autosave         = TRUE;
  use_fonts        = TRUE;
  hide_func        = FALSE;
  hide_iconbar     = FALSE;
  show_queried     = FALSE;
  show_grid        = TRUE;
  show_info        = TRUE;
  show_top         = TRUE;
  show_left        = TRUE;
  show_pattern     = TRUE;
  use_calc         = FALSE;
  minimize         = FALSE;
  warn_table       = TRUE;
  max_datacache    = MAX_DATACACHE;
  max_treecache    = MAX_TREECACHE;
  max_records      = MAX_RECORDS;
  events_ps        = EVENTS_PS;
  recs_pe          = RECS_PE;
  fontdesc.font    = FONT_SYSTEM;
  fontdesc.point   = gl_point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = BLACK;
  desktop->ob_spec = (desktop->ob_spec & 0xFFFFFF80L) | color_desktop | (pattern_desktop << 4);

#if MSDOS
#if MS_C
  wi_modeless  = WI_MODAL;      /* sorry no memory, use overlays */
#else
  wi_modeless  = WI_MODELESS;
#endif
#else
  wi_modeless  = WI_MODELESS;
#endif

  for (i = 1, monthwidth = 0; i <= 12; i++)
  {
    month_short [i - 1] = get_str (months, MOSHORT + i);
    month_long [i - 1]  = get_str (months, MOLONG + i);

    len = strlen (month_long [i - 1]);
    if (len > monthwidth) monthwidth = len;
  } /* for */

  p = FREETXT (FSEP);

  init_conv (month_short, month_long, p [0], p [1]);

  for (i = 0, dbp = db; i < MAX_DB; i++, dbp++)
    dbp->pos = FAILURE;

  ListBoxSetStyle (desktop, DBASE, LBS_DISABLED, TRUE);
  ListBoxSetCount (desktop, DBASE, 0, NULL);
  ListBoxSetCurSel (desktop, DBASE, FAILURE);
  ListBoxSetTopIndex (desktop, DBASE, 0);
  ListBoxSetCount (desktop, DTBLLIST, 0, NULL);
  ListBoxSetCurSel (desktop, DTBLLIST, FAILURE);
  ListBoxSetTopIndex (desktop, DTBLLIST, 0);
  ListBoxSetCount (desktop, DINXLIST, 0, NULL);
  ListBoxSetCurSel (desktop, DINXLIST, FAILURE);
  ListBoxSetTopIndex (desktop, DINXLIST, 0);

  if ((colors >= 16) && (gl_hbox > 8))
  {
    ok &= BuildIcon (&tooldb_icon,  tooldbm,  tooldb);
    ok &= BuildIcon (&tooltbl_icon, tooltblm, tooltbl);
    ok &= BuildIcon (&toolcol_icon, toolcolm, toolcol);
    ok &= BuildIcon (&toolinx_icon, toolinxm, toolinx);
    ok &= BuildIcon (&toolmul_icon, toolmulm, toolmul);
    ok &= BuildIcon (&toolcal_icon, toolcalm, toolcal);
    ok &= BuildIcon (&toolbat_icon, toolbatm, toolbat);

    if (! ok) hndl_alert (ERR_NOMEMORY);
  } /* if */

  return (ok);
} /* init_root */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_root ()

{
  UnloadFonts (vdi_handle);

  if ((colors >= 16) && (gl_hbox > 8))
  {
    FreeIcon (&tooldb_icon);
    FreeIcon (&tooltbl_icon);
    FreeIcon (&toolcol_icon);
    FreeIcon (&toolinx_icon);
    FreeIcon (&toolmul_icon);
    FreeIcon (&toolcal_icon);
    FreeIcon (&toolbat_icon);
  } /* if */

  return (TRUE);
} /* term_root */

/*****************************************************************************/

GLOBAL WORD open_db (filename, flags, datacache, treecache, num_cursors, username, password, sort_by_name)
FULLNAME filename;
UWORD    flags;
LONG     datacache, treecache;
WORD     num_cursors;
BYTE     *username;
BYTE     *password;
BOOLEAN  sort_by_name;

{
  WORD       result;
  BOOLEAN    ok;
  FILENAME   basename;
  FULLNAME   basepath;
  EXT        ext;
  WINDOWP    deskwin;
  DB         *dbp;
  TABLE_INFO tinf;
  INDEX_INFO iinf;
  T_INFO     *t_info;
  I_INFO     *i_info;
  LONG       size, bufsize;
  WORD       tables, indexes, first_table;
  WORD       num_icons, num_lookups, num_formats;
  WORD       i, j;
  BYTE       *mem, *name;
  CURSOR     cursor;
  MKINFO     mk;
  SYSICON    *sysicon;
  SYSFORMAT  sysformat;
  SYSCALC    *syscalc;
  FORMAT     *formatp;
  FORMATSTR  *formatstrp;
  WORD       width, height;
  WORD       *pmask, *pdata;
  RECT       r;

  result = SUCCESS;

  if (num_opendb == MAX_DB) return (ERR_MAXDB);

  for (dbp = db; dbp->pos != FAILURE; dbp++);

  file_split (filename, NULL, basepath, basename, ext);

  for (i = 0; i < MAX_DB; i++)
    if (db [i].pos != FAILURE)
      if ((strcmpi (basename, db [i].base->basename) == 0) && (strcmpi (basepath, db [i].base->basepath) == 0))
        return (ERR_SAMEBASE);

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
  busy_mouse ();

  i    = loaddb [LOADNAME].ob_width / gl_wbox;
  name = get_str (loaddb, LOADNAME);
  strncpy (name, basepath, i);
  name [i] = EOS;
  strncat (name, basename, i);
  name [i] = EOS;

  opendial (loaddb, FALSE, NULL, NULL, NULL);
  form_center (loaddb, &r.x, &r.y, &r.w, &r.h);
  objc_draw (loaddb, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h);

  dbp->base = db_open_cache (basename, basepath, flags | BASE_SUPER, datacache, treecache, num_cursors, username, password);
  ok        = (dbp->base != NULL);
  result    = db_status (dbp->base);

  if (! ok)
  {
    if (result == DB_NOMEMORY) result = ERR_NOMEMRETRY;
  } /* if */
  else
  {
    db_tableinfo (dbp->base, SYS_ICON, &tinf);
    num_icons = (WORD)tinf.recs;

    db_tableinfo (dbp->base, SYS_LOOKUP, &tinf);
    num_lookups = (WORD)tinf.recs;

    db_tableinfo (dbp->base, SYS_FORMAT, &tinf);
    num_formats = (WORD)tinf.recs;

    db_tableinfo (dbp->base, SYS_TABLE, &tinf);
    strcpy (dbp->password, password);
    db_convstr (dbp->base, dbp->password);

    deskwin             = search_window (class_desk, SRCH_ANY, NIL);
    tables              = (WORD)tinf.recs;
    dbp->flags          = flags;
    dbp->tables         = 0;
    dbp->t_inx          = 0;
    dbp->num_vis_tables = 0;
    dbp->sort_by_name   = sort_by_name;
#ifdef PHOENIX
    first_table         = (mk.kstate & K_ALT) ? SYS_TABLE : NUM_SYSTABLES;
#else
    first_table         = NUM_SYSTABLES;
#endif

    db_tableinfo (dbp->base, SYS_DELETED, &tinf); /* read at least one record of "trash can" */
    bufsize = tinf.size;
    db_tableinfo (dbp->base, SYS_CALC, &tinf);    /* read at least one record of SYS_CALC */
    bufsize = max (bufsize, tinf.size);
    db_tableinfo (dbp->base, SYS_QUERY, &tinf);   /* read at least one record of SYS_QUERY */
    bufsize = max (bufsize, tinf.size);
    db_tableinfo (dbp->base, SYS_REPORT, &tinf);  /* read at least one record of SYS_REPORT */
    bufsize = max (bufsize, tinf.size);
    db_tableinfo (dbp->base, SYS_BATCH, &tinf);   /* read at least one record of SYS_BATCH */
    bufsize = max (bufsize, tinf.size);
    db_tableinfo (dbp->base, SYS_ACCOUNT, &tinf); /* read at least one record of SYS_ACCOUNT */
    bufsize = max (bufsize, tinf.size);
    size    = 0;

    for (i = first_table; i < tables; i++)
      if ((db_acc_table (dbp->base, i) & (GRANT_INSERT | GRANT_SELECT)) &&
          (db_tableinfo (dbp->base, i, &tinf) != FAILURE) && (tinf.cols > 0))
      {
        if (! (tinf.flags & TBL_HIDDEN))
        {
          dbp->num_vis_tables++;
          size += sizeof (WORD);
        } /* if */
 
        dbp->tables++;                                  /* increase number of user tables */
        size += sizeof (T_INFO);
 
        bufsize  = max (bufsize, tinf.size);
        size    += typesize (TYPE_CHAR, tinf.name);
        size    += odd (size);                          /* even addresses */
        size    += tinf.indexes * sizeof (I_INFO);

        for (j = 0; j < tinf.indexes; j++)              /* index information */
          if ((db_acc_index (dbp->base, i, j) & GRANT_SELECT) &&
              (db_indexinfo (dbp->base, i, j, &iinf) != FAILURE))
          {
            name  = (iinf.name [0] == EOS) ? iinf.indexname : iinf.name;
            size += typesize (TYPE_CHAR, name);
            size += odd (size);                         /* even addresses */
          } /* if, for */
      } /* if, for */

    size += bufsize;                                    /* largest of 'em buffers */
    size += num_icons * sizeof (SYSICON);               /* memory for the icons */
    size += num_lookups * sizeof (SYSLOOKUP);           /* memory for the lookups */
    size += num_formats * (sizeof (FORMATSTR) + sizeof (FORMAT)); /* memory for the formats */

    dbp->mem = mem_alloc (size);

    ok = dbp->mem != NULL;

    if (! ok)
    {
      db_close (dbp->base);
      result = ERR_NOMEMRETRY;
    } /* if */
    else
    {
      db_beg_trans (dbp->base, FALSE);

      mem              = dbp->mem;
      dbp->t_info      = (T_INFO *)mem;
      mem             += dbp->tables * sizeof (T_INFO);

      dbp->vis_tables  = (WORD *)mem;
      mem             += dbp->num_vis_tables * sizeof (WORD);

      dbp->buffer      = (VOID *)mem;
      mem             += bufsize;

      syscalc = dbp->buffer;    /* use buffer for calculation */
      t_info  = dbp->t_info;

      for (i = first_table, dbp->num_vis_tables = 0; i < tables; i++)
        if ((db_acc_table (dbp->base, i) & (GRANT_INSERT | GRANT_SELECT)) &&
            (db_tableinfo (dbp->base, i, &tinf) != FAILURE) && (tinf.cols > 0))
        {
          if (! (tinf.flags & TBL_HIDDEN))
            dbp->vis_tables [dbp->num_vis_tables++] = i;

          strcpy (mem, tinf.name);
          t_info->tablename     = mem;
          t_info->tablenum      = i;
          t_info->indexes       = tinf.indexes;
          t_info->i_inx         = 0;
          t_info->first         = 0;
          t_info->calcname [0]  = EOS;
          t_info->calccode.size = 0;
          mem                  += typesize (TYPE_CHAR, tinf.name);
          mem                  += odd ((LONG)mem);

          strcpy (syscalc->tablename, tinf.name);
          strcpy (syscalc->name, tinf.name);

          if (db_search (dbp->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L))
            if (db_read (dbp->base, SYS_CALC, syscalc, &cursor, 0L, FALSE))
            {
              strcpy (t_info->calcname, syscalc->name);
              mem_move (&t_info->calccode, &syscalc->code, (UWORD)sizeof (CALCCODE));
            } /* if, if */

          t_info++;
        } /* if, for */

      t_info = dbp->t_info;

      for (i = first_table; i < tables; i++)
        if ((db_acc_table (dbp->base, i) & (GRANT_INSERT | GRANT_SELECT)) &&
            (db_tableinfo (dbp->base, i, &tinf) != FAILURE) && (tinf.cols > 0))
        {
          t_info->i_info  = (I_INFO *)mem;
          mem            += tinf.indexes * sizeof (I_INFO);
          i_info          = t_info->i_info;
          indexes         = 0;

          for (j = 0; j < tinf.indexes; j++)            /* index information */
            if ((db_acc_index (dbp->base, i, j) & GRANT_SELECT) &&
                (db_indexinfo (dbp->base, i, j, &iinf) != FAILURE))
            {
              indexes++;
              name = (iinf.name [0] == EOS) ? iinf.indexname : iinf.name;
              strcpy (mem, name);
              i_info->indexname  = mem;
              i_info->indexnum   = j;
              mem                += typesize (TYPE_CHAR, name);
              mem                += odd ((LONG)mem);
              i_info++;
            } /* if, for */

          t_info->indexes = indexes;
          t_info++;
        } /* if, for */

      if ((num_icons == 0) || ! v_initcursor (dbp, SYS_ICON, 1, ASCENDING, &cursor))
        dbp->sysicon = NULL;
      else
      {
        show_table (loaddb, LOADNAME, SYS_ICON);
        dbp->sysicon = (SYSICON *)mem;

        while (v_movecursor (dbp, &cursor, 1L))
          if (v_read (dbp, SYS_ICON, mem, &cursor, 0L, FALSE))
          {
            sysicon = (SYSICON *)mem;
            width   = sysicon->width;
            height  = sysicon->height;
            pmask   = &sysicon->icon.icondef [0];
            pdata   = &sysicon->icon.icondef [(width + 15) / 16 * height];

            set_idata (icons, ISCRATCH, pmask, pdata, width, height);
            trans_gimage (icons, ISCRATCH);

            mem += sizeof (SYSICON);
          } /* if, while */
      } /* else */

      if ((num_lookups == 0) || ! v_initcursor (dbp, SYS_LOOKUP, 1, ASCENDING, &cursor))
        dbp->syslookup = NULL;
      else
      {
        show_table (loaddb, LOADNAME, SYS_LOOKUP);
        dbp->syslookup = (SYSLOOKUP *)mem;

        while (v_movecursor (dbp, &cursor, 1L))
          if (v_read (dbp, SYS_LOOKUP, mem, &cursor, 0L, FALSE)) mem += sizeof (SYSLOOKUP);
      } /* else */

      if ((num_formats == 0) || ! v_initcursor (dbp, SYS_FORMAT, 1, ASCENDING, &cursor))
      {
        dbp->formatstr = NULL;
        dbp->format    = NULL;
      } /* if */
      else
      {
        show_table (loaddb, LOADNAME, SYS_FORMAT);
        dbp->formatstr = formatstrp = (FORMATSTR *)mem;
        dbp->format    = formatp    = (FORMAT *)dbp->formatstr [num_formats];

        while (v_movecursor (dbp, &cursor, 1L))
          if (v_read (dbp, SYS_FORMAT, &sysformat, &cursor, 0L, FALSE))
          {
            strcpy (*formatstrp, sysformat.format);
            build_format (sysformat.type, *formatstrp++, *formatp++);
            mem += sizeof (FORMATSTR) + sizeof (FORMAT);
          } /* if, while */
      } /* else */

      db_end_trans (dbp->base);
      sort_tables (dbp, sort_by_name);

      dbp->t_inx = dbp->vis_tables [0];         /* the first visible table */
      dbp->table = tablenum (dbp, dbp->t_inx);  /* now I know the number */

      for (i = 0, t_info = dbp->t_info; i < dbp->tables; i++, t_info++)
      {
        t_info->index = (t_info->indexes > 1) ? 1 : 0;
        if (! (db_acc_index (dbp->base, t_info->tablenum, t_info->index) & GRANT_SELECT))
          t_info->index = 0;
        t_info->i_inx = indexinx (dbp, t_info->tablenum, t_info->index);
      } /* for */

      ListBoxSetCount (desktop, DTBLLIST, dbp->num_vis_tables, NULL);
      ListBoxSetCurSel (desktop, DTBLLIST, sel_from_inx (dbp, dbp->t_inx));
      ListBoxSetTopIndex (desktop, DTBLLIST, sel_from_inx (dbp, dbp->t_inx));

      t_info = &dbp->t_info [dbp->t_inx];

      ListBoxSetCount (desktop, DINXLIST, (dbp->tables == 0) ? 0 : t_info->indexes, NULL);
      ListBoxSetCurSel (desktop, DINXLIST, (dbp->tables == 0) ? FAILURE : t_info->i_inx);
      ListBoxSetTopIndex (desktop, DINXLIST, (dbp->tables == 0) ? 0 : t_info->i_inx);

      num_opendb++;
      actdb    = dbp;
      dbp->pos = num_opendb - 1;

      db_tableinfo (actdb->base, SYS_USER, &tinf);
      lockable = tinf.recs != 0;                        /* there are any users */

      ListBoxSetStyle (desktop, DBASE, LBS_DISABLED, FALSE);
      ListBoxSetCount (desktop, DBASE, num_opendb, NULL);
      ListBoxSetCurSel (desktop, DBASE, actdb->pos);
      ListBoxSetTopIndex (desktop, DBASE, actdb->pos);

      draw_object (deskwin, DTABLES);
      check_func ();
    } /* else */
  } /* else */

  closedial (loaddb, FALSE, NULL, NULL, NULL);
  arrow_mouse ();

  return (result);
} /* open_db */

/*****************************************************************************/

GLOBAL WORD close_db ()

{
  WORD    result;
  WORD    pos, i;
  DB      *dbp;
  WINDOWP deskwin;

  busy_mouse ();

  result = SUCCESS;
  if (! db_close (actdb->base)) result = db_status (NULL);

  num_opendb--;
  mem_free (actdb->mem);

  for (i = 0, dbp = db; i < MAX_DB; i++, dbp++) /* move to the top */
    if (dbp->pos > actdb->pos)
      dbp->pos--;

  pos        = actdb->pos;
  actdb->pos = FAILURE;

  if (num_opendb == 0)
  {
    deskwin  = search_window (class_desk, SRCH_ANY, NIL);
    actdb    = NULL;
    dbp      = db;
    lockable = FALSE;

    ListBoxSetStyle (desktop, DBASE, LBS_DISABLED, TRUE);
    ListBoxSetCount (desktop, DBASE, 0, NULL);
    ListBoxSetCurSel (desktop, DBASE, FAILURE);
    ListBoxSetTopIndex (desktop, DBASE, 0);

    ListBoxSetCount (desktop, DTBLLIST, 0, NULL);
    ListBoxSetCurSel (desktop, DTBLLIST, FAILURE);
    ListBoxSetTopIndex (desktop, DTBLLIST, 0);

    if (deskwin->opened > 0)
      ListBoxRedraw (desktop, DTBLLIST);

    ListBoxSetCount (desktop, DINXLIST, 0, NULL);
    ListBoxSetCurSel (desktop, DINXLIST, FAILURE);
    ListBoxSetTopIndex (desktop, DINXLIST, 0);

    if (deskwin->opened > 0)
      ListBoxRedraw (desktop, DINXLIST);

    draw_object (deskwin, DBASE);
    check_func ();
  } /* if */
  else
  {
    pos   = min (pos, num_opendb - 1);
    actdb = &db [pos];

    switch_base (pos);
  } /* else */

  arrow_mouse ();

  return (result);
} /* close_db */

/*****************************************************************************/

GLOBAL VOID switch_base (pos)
WORD pos;

{
  WORD       i, inx;
  WINDOWP    deskwin;
  TABLE_INFO tinf;
  T_INFO     *t_info;

  for (i = 0; i < MAX_DB; i++)
    if (db [i].pos == pos)
      inx = i;

  actdb = &db [inx];
  db_tableinfo (actdb->base, SYS_USER, &tinf);
  lockable = tinf.recs != 0;                    /* there are any users */
  deskwin  = search_window (class_desk, SRCH_ANY, NIL);

  ListBoxSetCount (desktop, DTBLLIST, actdb->num_vis_tables, NULL);
  ListBoxSetCurSel (desktop, DTBLLIST, sel_from_inx (actdb, actdb->t_inx));
  ListBoxSetTopIndex (desktop, DTBLLIST, sel_from_inx (actdb, actdb->t_inx));

  t_info = &actdb->t_info [actdb->t_inx];

  ListBoxSetCount (desktop, DINXLIST, (actdb->tables == 0) ? 0 : t_info->indexes, NULL);
  ListBoxSetCurSel (desktop, DINXLIST, (actdb->tables == 0) ? FAILURE : t_info->i_inx);
  ListBoxSetTopIndex (desktop, DINXLIST, (actdb->tables == 0) ? 0 : t_info->first);

  ListBoxSetCount (desktop, DBASE, num_opendb, NULL);
  ListBoxSetCurSel (desktop, DBASE, actdb->pos);
  ListBoxSetTopIndex (desktop, DBASE, actdb->pos);

  draw_object (deskwin, DBASE);
  draw_object (deskwin, DTBLLIST);
  draw_object (deskwin, DINXLIST);
  check_func ();
} /* switch_base */

/*****************************************************************************/

GLOBAL VOID switch_table (db, table)
DB   *db;
WORD table;

{
  T_INFO *t_info;

  if (db->table != table)
  {
    db->table = table;
    db->t_inx = tableinx (db, table);

    if (actdb == db)
    {
      t_info = &actdb->t_info [actdb->t_inx];
      ListBoxSetCount (desktop, DINXLIST, (actdb->tables == 0) ? 0 : t_info->indexes, NULL);
      ListBoxSetCurSel (desktop, DINXLIST, (actdb->tables == 0) ? FAILURE : t_info->i_inx);
      ListBoxSetTopIndex (desktop, DINXLIST, (actdb->tables == 0) ? 0 : t_info->first);
      ListBoxRedraw (desktop, DINXLIST);
      check_func ();
    } /* if */
  } /* if */
} /* switch_table */

/*****************************************************************************/

GLOBAL WORD tablenum (db, t_inx)
DB   *db;
WORD t_inx;

{
  return ((db->tables > 0) ? db->t_info [t_inx].tablenum : FAILURE);
} /* tablenum */

/*****************************************************************************/

GLOBAL WORD indexnum (db, t_inx, i_inx)
DB   *db;
WORD t_inx, i_inx;

{
  return ((db->tables > 0) ? db->t_info [t_inx].i_info [i_inx].indexnum : FAILURE);
} /* indexnum */

/*****************************************************************************/

GLOBAL WORD tableinx (db, table)
DB   *db;
WORD table;

{
  REG WORD   i;
  REG T_INFO *t_info;

  t_info = db->t_info;

  for (i = 0; i < db->tables; i++, t_info++)
    if (t_info->tablenum == table)
      return (i);

  return (FAILURE);
} /* tableinx */

/*****************************************************************************/

GLOBAL WORD indexinx (db, table, index)
DB   *db;
WORD table, index;

{
  REG WORD   i, indexes, t_inx;
  REG I_INFO *i_info;

  t_inx   = tableinx (db, table);
  indexes = db->t_info [t_inx].indexes;
  i_info  = db->t_info [t_inx].i_info;

  for (i = 0; i < indexes; i++, i_info++)
    if (i_info->indexnum == index)
      return (i);

  return (FAILURE);
} /* indexinx */

/*****************************************************************************/

GLOBAL WORD sel_from_inx (db, t_inx)
DB   *db;
WORD t_inx;

{
  WORD i;

  for (i = 0; i < db->num_vis_tables; i++)
    if (db->vis_tables [i] == t_inx)
      return (i);

  return (FAILURE);
} /* sel_from_inx */

/*****************************************************************************/

GLOBAL WORD rtable (vtable)
WORD vtable;

{
  return (VTBL (vtable) ? vtables [-vtable].table : vtable);
} /* rtable */

/*****************************************************************************/

GLOBAL WORD new_vtable (db, table, maxrecs, cols)
DB   *db;
WORD table;
LONG maxrecs;
WORD cols;

{
  REG WORD   vtable;
  REG VTABLE *vtablep;
  REG LONG   *memory;

  for (vtable = 2, vtablep = &vtables [vtable]; vtable < MAX_VTABLE; vtable++, vtablep++)
    if (vtablep->used == 0)
    {
      memory = mem_alloc (maxrecs * sizeof (LONG));

      if (memory == NULL)
      {
        hndl_alert (ERR_NOMEMORY);
        free_vtable (-vtable);
        return (FAILURE);
      } /* if */

      vtablep->db      = db;
      vtablep->table   = table;
      vtablep->maxrecs = maxrecs;
      vtablep->cols    = cols;
      vtablep->used    = 1;
      vtablep->recaddr = memory;

      return (-vtable);
    } /* if, for */

  hndl_alert (ERR_NOVTABLE);

  return (FAILURE);
} /* new_vtable */

/*****************************************************************************/

GLOBAL VOID free_vtable (vtable)
WORD vtable;

{
  REG VTABLE *vtablep;

  vtablep = VTABLEP (vtable);

  vtablep->used--;

  if (vtablep->used <= 0)
  {
    mem_free (vtablep->recaddr);
    mem_set (vtablep, 0, sizeof (VTABLE));
  } /* if */
} /* free_vtable */

/*****************************************************************************/

GLOBAL VOID del_vtable (vtable, index)
WORD vtable;
LONG index;

{
  REG VTABLE *vtablep;

  vtablep = VTABLEP (vtable);

  vtablep->recs--;
  mem_lmove (&vtablep->recaddr [index], &vtablep->recaddr [index + 1], (vtablep->recs - index) * sizeof (LONG));
} /* del_vtable */

/*****************************************************************************/

GLOBAL LONG in_vtable (vtablep, addr)
VTABLE *vtablep;
LONG   addr;

{
  REG LONG i;

  for (i = 0; i < vtablep->recs; i++)
    if (vtablep->recaddr [i] == addr) return (i);

  return (FAILURE);
} /* in_vtable */

/*****************************************************************************/

GLOBAL VOID check_vtable (vtable, addr)
WORD vtable;
LONG addr;

{
  REG WORD   i;
  REG VTABLE *vtablep;
  REG LONG   index;

  for (i = 2, vtablep = &vtables [i]; i < MAX_VTABLE; i++, vtablep++)
    if (vtablep->table == rtable (vtable))
      if ((index = in_vtable (vtablep, addr)) != FAILURE) del_vtable (-i, index);
} /* check_vtable */

/*****************************************************************************/

GLOBAL WORD new_vindex (db, vtable, inxcols)
DB      *db;
WORD    vtable;
INXCOLS *inxcols;	

{
  REG WORD   vindex;
  REG VINDEX *vindexp;

  for (vindex = 2, vindexp = &vindexes [vindex]; vindex < MAX_VINDEX; vindex++, vindexp++)
    if (vindexp->used == 0)
    {
      vindexp->db      = db;
      vindexp->vtable  = vtable;
      vindexp->used    = 1;
      vindexp->inxcols = *inxcols;

      return (-vindex);
    } /* if, for */

  hndl_alert (ERR_NOVINDEX);

  return (FAILURE);
} /* new_vindex */

/*****************************************************************************/

GLOBAL VOID free_vindex (vindex)
WORD vindex;

{
  REG VINDEX *vindexp;

  vindexp = VINDEXP (vindex);

  vindexp->used--;

  if (vindexp->used <= 0) mem_set (vindexp, 0, sizeof (VINDEX));
} /* free_vindex */

/*****************************************************************************/

GLOBAL WORD v_tableinfo (db, vtable, table_info)
DB         *db;
WORD       vtable;
TABLE_INFO *table_info;

{
  WORD   table;
  VTABLE *vtablep;

  table = db_tableinfo (db->base, rtable (vtable), table_info);

  if (VTBL (vtable))
  {
    vtablep          = VTABLEP (vtable);
    table_info->recs = vtablep->recs;
  } /* if */

  if (table == FAILURE) mem_set (table_info, 0, sizeof (TABLE_INFO));

  return (table);
} /* v_tableinfo */

/*****************************************************************************/

GLOBAL WORD v_indexinfo (db, vtable, vindex, index_info)
DB         *db;
WORD       vtable, vindex;
INDEX_INFO *index_info;

{
  VTABLE    *vtablep;
  VINDEX    *vindexp;
  INXCOL    *inxcolp;
  BYTE      *p;
  WORD      num_cols, i;
  FIELDNAME name;

  if (VINX (vindex))
  {
    vindexp = VINDEXP (vindex);
    mem_set (index_info, 0, sizeof (INDEX_INFO));
    index_info->inxcols = vindexp->inxcols;

    num_cols = index_info->inxcols.size / sizeof (INXCOL);
    inxcolp  = index_info->inxcols.cols;
    p        = index_info->indexname;

    for (i = 0; i < num_cols; i++, inxcolp++)
    {
      column_name (db, vtable, inxcolp->col & ~ DESC_ORDER, name);

      if (strlen (p) + strlen (name) + 1 <= MAX_INDEXNAME)
      {
        strcat (p, name);
        if (i < num_cols - 1) strcat (p, ",");
      } /* if */
    } /* for */
  } /* if */
  else
    vindex = db_indexinfo (db->base, rtable (vtable), vindex, index_info);

  if (vindex == FAILURE) mem_set (index_info, 0, sizeof (INDEX_INFO));

  if (VTBL (vtable))
  {
    vtablep              = VTABLEP (vtable);
    index_info->num_keys = vtablep->recs;
  } /* if */

  return (vindex);
} /* v_indexinfo */

/*****************************************************************************/

GLOBAL BOOLEAN v_initcursor (db, vtable, inx, dir, cursor)
DB      *db;
WORD    vtable;
WORD    inx;
WORD    dir;
CURSOR *cursor;

{
  BOOLEAN ok;
  WORD    table;
  VTABLE  *vtablep;

  table = rtable (vtable);

  if (VTBL (vtable))
  {
    vtablep     = VTABLEP (vtable);
    cursor->inx = vtable;
    cursor->pos = (dir == ASCENDING) ? -1 : vtablep->recs;
    ok          = TRUE;
  } /* if */
  else
  {
    ok = db_initcursor (db->base, table, inx, dir, cursor);
    dbtest (db);
  } /* else */

  return (ok);
} /* v_initcursor */

/*****************************************************************************/

GLOBAL BOOLEAN v_movecursor (db, cursor, steps)
DB     *db;
CURSOR *cursor;
LONG   steps;

{
  BOOLEAN ok;
  VTABLE  *vtablep;

  if (VTBL (cursor->inx))
  {
    vtablep      = VTABLEP (cursor->inx);
    cursor->pos += steps;

    ok = (0 <= cursor->pos) && (cursor->pos < vtablep->recs);

    if (! ok)
    {
      cursor->pos = max (0, cursor->pos);
      cursor->pos = min (vtablep->recs - 1, cursor->pos);
    } /* if */
  } /* if */
  else
  {
    ok = db_movecursor (db->base, cursor, steps);
    dbtest (db);
  } /* else */

  return (ok);
} /* v_movecursor */

/*****************************************************************************/

GLOBAL LONG v_readcursor (db, cursor, keyval)
DB     *db;
CURSOR *cursor;
VOID   *keyval;

{
  LONG    addr;
  BOOLEAN ok;
  VTABLE  *vtablep;

  if (VTBL (cursor->inx))
  {
    vtablep = VTABLEP (cursor->inx);
    ok      = v_movecursor (db, cursor, 0L);
    addr    = ok ? vtablep->recaddr [cursor->pos] : 0L;
  } /* if */
  else
  {
    addr = db_readcursor (db->base, cursor, keyval);
    dbtest (db);
  } /* else */

  return (addr);
} /* v_readcursor */

/*****************************************************************************/

GLOBAL BOOLEAN v_isfirst (db, cursor)
DB     *db;
CURSOR *cursor;

{
  BOOLEAN ok;

  if (VTBL (cursor->inx))
    ok = cursor->pos <= 0;
  else
  {
    ok = db_isfirst (db->base, cursor);
    dbtest (db);
  } /* else */

  return (ok);
} /* v_isfirst */

/*****************************************************************************/

GLOBAL BOOLEAN v_islast (db, cursor)
DB     *db;
CURSOR *cursor;

{
  BOOLEAN ok;
  VTABLE  *vtablep;

  if (VTBL (cursor->inx))
  {
    vtablep = VTABLEP (cursor->inx);
    ok      = cursor->pos >= vtablep->recs - 1;
  } /* if */
  else
  {
    ok = db_islast (db->base, cursor);
    dbtest (db);
  } /* else */

  return (ok);
} /* v_islast */

/*****************************************************************************/

GLOBAL BOOLEAN v_read (db, vtable, buffer, cursor, address, modify)
DB      *db;
WORD    vtable;
VOID    *buffer;
CURSOR  *cursor;
LONG    address;
BOOLEAN modify;

{
  BOOLEAN ok;
  WORD    table, ret;

  ok    = TRUE;
  table = rtable (vtable);

  if (VTBL (vtable))
  {
    if (address == 0) address = v_readcursor (db, cursor, NULL);
    ok = address != 0;
  } /* if */

  if (ok)
  {
    db_fillnull (db->base, table, buffer);

    ok  = db_read (db->base, table, buffer, cursor, address, modify);
    ret = dbtest (db);
    if (db_status (db->base) == DB_CDELETED) ok = ret == 1;     /* Ignore */
  } /* if */

  return (ok);
} /* v_read */

/*****************************************************************************/

GLOBAL WORD v_execute (db, vtable, calccode, buffer, count, retval)
DB          *db;
WORD        vtable;
CALCCODE    *calccode;
VOID        *buffer;
LONG        count;
LPVALUEDESC retval;

{
  WORD err, table, i;

  err   = SUCCESS;
  table = rtable (vtable);
  i     = tableinx (db, table);

  if (i != FAILURE)
  {
    if (calccode == NULL) calccode = &db->t_info [i].calccode;
    if (calccode->size != 0) err = db_execute (db->base, table, calccode, buffer, count, db->format, retval);
  } /* if */

  return (err);
} /* v_execute */

/*****************************************************************************/

GLOBAL LONG num_keys (db, vtable, inx)
DB   *db;
WORD vtable, inx;

{
  INDEX_INFO index_info;

  mem_set (&index_info, 0, sizeof (INDEX_INFO));
  v_indexinfo (db, vtable, inx, &index_info);

  return (index_info.num_keys);
} /* num_keys */

/*****************************************************************************/

GLOBAL BYTE *dbtbl_name (db, vtable, name)
DB   *db;
WORD vtable;
BYTE *name;

{
  STRING s;

  sprintf (name, " %s.%s ", db->base->basename, table_name (db, vtable, s));

  return (name);
} /* dbtbl_name */

/*****************************************************************************/

GLOBAL BYTE *table_name (db, vtable, name)
DB   *db;
WORD vtable;
BYTE *name;

{
  if (vtable == FAILURE)
    name [0] = EOS;
  else
  {
    strcpy (name, db_tablename (db->base, rtable (vtable)));

    switch (rtable (vtable))
    {
      case SYS_DELETED : strcpy (name, FREETXT (FTRASHNA));
                         str_rmchar (name, SP);
                         break;
      case SYS_CALC    : strcpy (name, FREETXT (FCALC));
                         break;
      case SYS_QUERY   : strcpy (name, FREETXT (FQUERY));
                         break;
      case SYS_REPORT  : strcpy (name, FREETXT (FREPORT));
                         break;
      case SYS_BATCH   : strcpy (name, FREETXT (FBATCH));
                         break;
      case SYS_ACCOUNT : strcpy (name, FREETXT (FACCOUNT));
                         break;
    } /* switch */
  } /* switch */

  return (name);
} /* table_name */

/*****************************************************************************/

GLOBAL BYTE *column_name (db, vtable, col, name)
DB   *db;
WORD vtable, col;
BYTE *name;

{
  if ((vtable == FAILURE) || (col == FAILURE))
  {
    name [0] = EOS;
    return (name);
  } /* if */
  else
    return (strcpy (name, db_fieldname (db->base, rtable (vtable), col)));
} /* column_name */

/*****************************************************************************/

GLOBAL BYTE *index_name (db, vtable, inx, name)
DB   *db;
WORD vtable, inx;
BYTE *name;

{
  INDEX_INFO index_info;

  v_indexinfo (db, vtable, inx, &index_info);
  strcpy (name, (index_info.name [0] == EOS) ? index_info.indexname : index_info.name);

  return (name);
} /* index_name */

/*****************************************************************************/

GLOBAL BYTE *sort_name (db, vtable, inx, dir, name)
DB   *db;
WORD vtable, inx, dir;
BYTE *name;

{
  FIELDNAME  colname;
  BYTE       sort [4];
  WORD       coldir;
  INDEX_INFO index_info;
  INXCOL     *inxcolp;
  WORD       num_cols, i;

  strcpy (name, " ");

  if (inx != FAILURE)           /* no virtual table without index */
  {
    v_indexinfo (db, vtable, inx, &index_info);
    strcpy (sort, "(+)");

    num_cols = index_info.inxcols.size / sizeof (INXCOL);
    inxcolp  = index_info.inxcols.cols;

    for (i = 0; i < num_cols; i++, inxcolp++)
    {
      if (num_cols == 1)
        index_name (db, vtable, inx, colname);
      else
        column_name (db, vtable, inxcolp->col & ~ DESC_ORDER, colname);

      if (strlen (name) + strlen (colname) + sizeof (sort) <= MAX_INDEXNAME)
      {
        strcat (name, colname);
        coldir   = (inxcolp->col & DESC_ORDER) ? DESCENDING : ASCENDING;
        sort [1] = coldir == dir ? '+' : '-';
        strcat (name, sort);
        if (i < num_cols - 1) strcat (name, ",");
      } /* if */
    } /* for */
  } /* if */
  else
    if (dir != 0) sprintf (name, " (%c)", (dir == ASCENDING) ? '+' : '-');

  return (name);
} /* sort_name */

/*****************************************************************************/

GLOBAL BYTE *temp_name (s)
BYTE *s;

{
  BYTE     *p;
  FILENAME filename;

  p = (s == NULL) ? tmpname : s;

  do
  {
    tmpnum = (tmpnum + 1) & 0x0FFF;

    sprintf (filename, "APP%02X%03X.TMP", gl_apid, tmpnum);
    strcpy (p, tmpdir);
    strcat (p, filename);
  } while (file_exist (p));

  return (p);
} /* temp_name */

/*****************************************************************************/

GLOBAL WORD init_columns (db, table, tblcols, columns, colwidth)
DB   *db;
WORD table, tblcols, *columns, *colwidth;

{
  WORD i, cols;

  for (i = 1, cols = 0; i < tblcols; i++)
    if (db_acc_column (db->base, table, i) & GRANT_SELECT)
    {
      columns [cols]    = i;
      colwidth [cols++] = def_width (db, table, i);
    } /* if, for */

  return (cols);
} /* init_columns */

/*****************************************************************************/

GLOBAL WORD def_width (db, table, col)
DB   *db;
WORD table, col;

{
  WORD       width;
  LONG       w;
  FIELD_INFO f_inf;

  width = 0;

  if (db_fieldinfo (db->base, table, col, &f_inf))
  {
    width = type_width (db, f_inf.type, f_inf.format);

    if (width == 0)                   /* variable char size */
    {
      w = f_inf.size;                 /* get real size including zero */
      if (w > LONGSTRLEN) w = LONGSTRLEN; /* large lists not allowed */
      width = (WORD)w;                /* width is size */
    } /* if */
    else
      width++;                        /* append blank */

    if (width < (WORD)(strlen (f_inf.name) + 1)) width = strlen (f_inf.name) + 1; /* strlen is unsigned */
    if (width > LONGSTRLEN) width = LONGSTRLEN;

    if (HASWILD (f_inf.type) || (f_inf.type == TYPE_BLOB)) width = -width;
  } /* if */

  return (width);
} /* def_width */

/*****************************************************************************/

GLOBAL LONG get_width (cols, colwidth)
WORD cols, *colwidth;

{
  REG LONG width;
  REG WORD i;

  for (i = width = 0; i < cols; i++) width += abs (colwidth [i]);

  return (width);
} /* get_width */

/*****************************************************************************/

GLOBAL VOID build_colheader (db, vtable, cols, columns, colwidth, max_cols, header)
DB   *db;
WORD vtable, cols, *columns, *colwidth;
LONG max_cols;
BYTE *header;

{
  WORD    len, i, sl, col;
  STRING  s;

  len = 0;

  for (i = 0; i < cols; i++)
  {
    col = columns [i];

    column_name (db, vtable, col, s);

    chrcat (s, COLUMNSEP);
    sl = (SHORT)strlen (s);

    if ((LONG)(len + sl) <= max_cols) mem_move (header + len, s, sl);

    len += sl;
  } /* for */

  if ((LONG)len < max_cols) header [len] = EOS;
  header [max_cols] = EOS;
} /* build_colheader */

/*****************************************************************************/

GLOBAL VOID rec_to_line (db, vtable, buffer, cols, columns, colwidth, max_cols, line)
DB   *db;
WORD vtable;
VOID *buffer;
WORD cols, *columns, *colwidth;
LONG max_cols;
BYTE *line;

{
  WORD    i, table, width;
  LONG    l, len, diff;
  LONGSTR s;

  *line = EOS;
  table = rtable (vtable);

  for (i = len = 0; (i < cols) && (len < max_cols); i++)
  {
    if ((width = colwidth [i]) > 0)
      width--;
    else
      width++;

    col_to_str (db, table, buffer, columns [i], 0, s);

    strcat (s, " ");
    l = strlen (s);

    diff = max_cols - len;
    if (l > diff) s [diff] = EOS;       /* not enough room for whole string */
    l = strlen (s);
    s [l - 1] = COLUMNSEP;

    len += l;
    strcat (line, s);
  } /* for, if */

  len = strlen (line);
  mem_lset (line + strlen (line), 0, max_cols - strlen (line) + 1); /* fill rest with zero */
} /* rec_to_line */

/*****************************************************************************/

GLOBAL VOID col_to_str (db, table, buffer, col, colwidth, s)
DB   *db;
WORD table;
VOID *buffer;
WORD col, colwidth;
BYTE *s;

{
  WORD       type;
  FIELD_INFO f_inf;
  LONGSTR    strval;
  BYTE       *mem, *p;

  db_fieldinfo (db->base, table, col, &f_inf);
  type = f_inf.type;
  mem  = (BYTE *)buffer + f_inf.addr;

  if (type == TYPE_CHAR)                        /* prevent from overflow of long text lines */
  {
    strncpy (strval, mem, LONGSTRLEN - 1);
    strval [LONGSTRLEN - 1] = EOS;
  } /* if */
  else
    bin2str (type, mem, strval);

  if (db->format != NULL) str2format (type, strval, db->format [f_inf.format]);

  if (colwidth == 0)
  {
    p = strval;

    if ((TYPE_WORD <= type) && (type <= TYPE_CFLOAT) ||		/* no leading blanks */
        (TYPE_VARBYTE <= type) && (type <= TYPE_DBADDRESS))
      while (*p == SP) p++;

    strncpy (s, p, LONGSTRLEN);
    s [LONGSTRLEN] = EOS;
  } /* if */
  else
    if (colwidth > 0)
    {
      p = strval;
      while (*p == SP) p++;             /* no leading blanks please, will be added with sprintf */
      sprintf (s, "%*.*s", colwidth, colwidth, p);
    } /* if */
    else
      sprintf (s, "%-*.*s", abs (colwidth), abs (colwidth), strval);

  if (! printable (type))
    if (! is_null (type, mem)) mem_set (s, '*', strlen (s));

  while ((p = strchr (s, '\r')) != NULL) *p = SP;       /* replace cr */
  while ((p = strchr (s, '\n')) != NULL) *p = SP;       /* replace lf */
} /* col_to_str */

/*****************************************************************************/

GLOBAL VOID get_colheader (db, vtable, cols, columns, colwidth, max_cols, header)
DB   *db;
WORD vtable, cols, *columns, *colwidth;
LONG max_cols;
BYTE *header;

{
  WORD    len, i, w, sl, col;
  BOOLEAN right;
  STRING  s;

  mem_lset (header, ' ', max_cols);
  header [max_cols] = EOS;

  len = 0;

  for (i = 0; i < cols; i++)
  {
    col = columns [i];
    w   = colwidth [i];

    column_name (db, vtable, col, s);

    right = w > 0;
    w     = abs (w) - 1;                /* 1 blank */

    if (strlen (s) > w) s [w] = EOS;

    sl = strlen (s);

    if (right)                          /* right aligned */
    {
      len += w - sl;
      w    = sl;
    } /* if */

    if (sl > max_cols - len) sl = max_cols - len; /* right edge of column name */
    if (sl < 0) sl = 0;
    if (len + sl <= max_cols) mem_move (header + len, s, sl); /* sl <= l */

    len += w + 1;                       /* 1 blank */
  } /* for */
} /* get_colheader */

/*****************************************************************************/

GLOBAL VOID rec2line (db, vtable, buffer, cols, columns, colwidth, max_cols, line)
DB   *db;
WORD vtable;
VOID *buffer;
WORD cols, *columns, *colwidth;
LONG max_cols;
BYTE *line;

{
  WORD    i, table, width;
  LONG    l, len, diff;
  LONGSTR s;

  *line = EOS;
  table = rtable (vtable);

  for (i = len = 0; (i < cols) && (len < max_cols); i++)
  {
    if ((width = colwidth [i]) > 0)
      width--;
    else
      width++;

    col2str (db, table, buffer, columns [i], width, s);

    strcat (s, " ");
    l = strlen (s);

    diff = max_cols - len;
    if (l > diff) s [diff] = EOS;       /* not enough room for whole string */

    len += strlen (s);
    strcat (line, s);
  } /* for, if */

  mem_lset (line + strlen (line), 0, max_cols - strlen (line) + 1); /* fill rest with zero */
} /* rec2line */

/*****************************************************************************/

GLOBAL VOID col2str (db, table, buffer, col, colwidth, s)
DB   *db;
WORD table;
VOID *buffer;
WORD col, colwidth;
BYTE *s;

{
  WORD       type;
  FIELD_INFO f_inf;
  LONGSTR    strval;
  BYTE       *mem, *p;

  db_fieldinfo (db->base, table, col, &f_inf);
  type = f_inf.type;
  mem  = (BYTE *)buffer + f_inf.addr;

  if (type == TYPE_CHAR)                        /* prevent from overflow of long text lines */
  {
    strncpy (strval, mem, LONGSTRLEN - 1);
    strval [LONGSTRLEN - 1] = EOS;
  } /* if */
  else
    bin2str (type, mem, strval);

  if (db->format != NULL) str2format (type, strval, db->format [f_inf.format]);

  if (colwidth == 0)
  {
    strncpy (s, strval, LONGSTRLEN);
    s [LONGSTRLEN] = EOS;
  } /* if */
  else
    if (colwidth > 0)
    {
      p = strval;
      while (*p == SP) p++;             /* no leading blanks please, will be added with sprintf */
      sprintf (s, "%*.*s", colwidth, colwidth, p);
    } /* if */
    else
      sprintf (s, "%-*.*s", abs (colwidth), abs (colwidth), strval);

  if (! printable (type))
    if (! is_null (type, mem)) mem_set (s, '*', strlen (s));

  while ((p = strchr (s, '\r')) != NULL) *p = SP;       /* replace cr */
  while ((p = strchr (s, '\n')) != NULL) *p = SP;       /* replace lf */
} /* col2str */

/*****************************************************************************/

GLOBAL BOOLEAN str2col (db, table, buffer, col, s)
DB   *db;
WORD table;
VOID *buffer;
WORD col;
BYTE *s;

{
  BOOLEAN    ok;
  WORD       type;
  FIELD_INFO f_inf;
  BYTE       *mem;

  db_fieldinfo (db->base, table, col, &f_inf);
  ok   = TRUE;
  type = f_inf.type;
  mem  = (BYTE *)buffer + f_inf.addr;

  if (printable (type))
  {
    if (db->format != NULL) ok = format2str (type, s, db->format [f_inf.format]);
    str2bin (type, s, mem);
  } /* if */

  return (ok);
} /* str2col */

/*****************************************************************************/

GLOBAL BOOLEAN printable (type)
WORD type;

{
  return (type <= TYPE_BLOB);
} /* printable */

/*****************************************************************************/

GLOBAL VOID build_keystr (db, table, inx, buffer, keystr)
DB   *db;
WORD table;
WORD inx;
VOID *buffer;
BYTE *keystr;

{
  INDEX_INFO i_inf;
  FIELD_INFO f_inf;
  WORD       col, type, num_cols, i;
  LONG       addr;
  INXCOL     *inxcolp;
  BYTE       *bufp;
  LONGSTR    s, t;

  v_indexinfo (db, table, inx, &i_inf);

  bufp       = (BYTE *)buffer;
  num_cols   = i_inf.inxcols.size / sizeof (INXCOL);
  inxcolp    = i_inf.inxcols.cols;
  col        = inxcolp->col;
  keystr [0] = EOS;

  for (i = 0; i < num_cols; i++, inxcolp++)
  {
    col = inxcolp->col;
    db_fieldinfo (db->base, table, col, &f_inf);

    addr  = f_inf.addr;
    type  = f_inf.type;
    s [0] = EOS;

    if (HASWILD (type))         /* make ascii string before building key */
    {
      strcpy (t, bufp + addr);
      db_convstr (db->base, t);
      build_str (type, inxcolp->len, t, s);
    } /* if */
    else
    {
      build_str (type, inxcolp->len, bufp + addr, s);

      switch (type)
      {
        case TYPE_WORD      :
        case TYPE_LONG      :
        case TYPE_DBADDRESS :
        case TYPE_FLOAT     : 
        case TYPE_CFLOAT    : s [0] = (s [0] == '+') ? ' ' : '-'; break;
      } /* switch */
    } /* else */

    if (strlen (keystr) + strlen (s) < LONGSTRLEN) strcat (keystr, s);
  } /* for */
} /* build_keystr */

/*****************************************************************************/

GLOBAL BOOLEAN str2ucsd (s, u)
BYTE *s, *u;

{
  REG BOOLEAN ok;
  REG WORD    i, j, ch, len;
  WORD        hex;

  for (i = j = 0, ok = TRUE, len = strlen (s); (i < len) && ok; i++)
  {
    ch = s [i];

    if (ch == SP) continue;

    if ((ch == '\'') || (ch == '"'))
    {
      for (i++; (s [i] != ch) && (s [i] != EOS); i++) u [++j] = s [i];
      ok = (s [i] == ch);
      i++;                              /* trailing delimiter */
    } /* if */
    else
    {
      if (isdigit (ch) || (ch == '+') || (ch == '-'))
      {
        ok = TRUE;
        u [++j] = atoi (&s [i]);        /* get ascii code */
      } /* if */
      else
        if (ch == '$')
        {
          ok = sscanf (&s [i + 1], "%x", &hex) == 1;
          u [++j] = hex;
        } /* if */
        else
          ok = FALSE;

      while ((s [i] != ',') && (s [i] != EOS)) i++;
    } /* else */
  } /* for */

  u [0] = j;

  if ((s [0] != EOS) && (j == 0)) ok = FALSE; /* double quotes */

  return (ok);
} /* str2ucsd */

/*****************************************************************************/

GLOBAL BOOLEAN same_ucsd (u1, u2)
BYTE *u1, *u2;

{
  REG WORD l1, l2, i;

  l1 = LEN (u1);
  l2 = LEN (u2);

  if (l1 != l2) return (FALSE);

  for (i = 1; i <= l1; i++)
    if (u1 [i] != u2 [i]) return (FALSE);

  return (TRUE);
} /* same_ucsd */

/*****************************************************************************/

GLOBAL LONG date2days (date)
DATE *date;

{
  REG LONG days;

  days = date->day;

  if (date->month > 0) days += sumdays [LEAP_YEAR (date->year)] [date->month - 1];

  days += date->year * 365L;
  if (date->year > 0) days += (date->year - 1) / 4;

  return (days);
} /* date2days */

/*****************************************************************************/

GLOBAL VOID days2date (days, date)
LONG  days;
DATE *date;

{
  REG WORD    month, year;
  REG LONG    d;
  REG BOOLEAN leap;

  date->day   = 0;
  date->month = 0;
  date->year  = 0;

  year = days / 366;            /* 365.25 would be the right value */
  if (year > 0)
  {
    date->day    = 31;
    date->month  = 12;
    date->year   = year - 1;
    days        -= date2days (date);
  } /* if */

  if (days > 0)
  {
    while (days >= 365)                 /* 1 <= days <= 440 (15-03-9996) */
    {
      d     = days;
      days -= 365;
      if (LEAP_YEAR (year)) days--;     /* 366 days in leap years */
      if (days > 0) year++;
    } /* while */

    if (days <= 0) days = d;            /* reset days */

    leap  = LEAP_YEAR (year);
    month = 1;
    while (days > sumdays [leap] [month]) month++; /* search for month */
    days -= sumdays [leap] [month - 1];

    date->day   = days;
    date->month = month;
    date->year  = year;
  } /* if */
} /* days2date */

/*****************************************************************************/

GLOBAL LONG time2secs (time)
TIME *time;

{
  REG LONG seconds;

  seconds  = (LONG)time->second; 
  seconds += (LONG)time->minute * 60;
  seconds += (LONG)time->hour * 3600;

  return (seconds);
} /* time2secs */

/*****************************************************************************/

GLOBAL VOID secs2time (seconds, time)
LONG seconds;
TIME *time;

{
  while (seconds < 0) seconds += 86400L;        /* 86400 seconds per day */

  time->hour   = (seconds / 3600) % 24;
  seconds      = seconds % 3600;
  time->minute = seconds / 60;
  time->second = seconds % 60;
} /* secs2time */

/*****************************************************************************/

GLOBAL WORD get_word (tree, object)
OBJECT *tree;
WORD   object;

{
  WORD   i;
  BYTE   *p;

  p = get_str (tree, object);
  str2bin (TYPE_WORD, p, &i);

  return (i);
} /* get_word */

/*****************************************************************************/

GLOBAL LONG get_long (tree, object)
OBJECT *tree;
WORD   object;

{
  LONG   l;
  BYTE   *p;

  p = get_str (tree, object);
  str2bin (TYPE_LONG, p, &l);

  return (l);
} /* get_long */

/*****************************************************************************/

GLOBAL VOID set_word (tree, object, value)
OBJECT *tree;
WORD   object;
WORD   value;

{
  STRING s;

  bin2str (TYPE_WORD, &value, s);
  set_str (tree, object, s);
} /* set_word */

/*****************************************************************************/

GLOBAL VOID set_long (tree, object, value)
OBJECT *tree;
WORD   object;
LONG   value;

{
  STRING s;

  bin2str (TYPE_LONG, &value, s);
  set_str (tree, object, s);
} /* set_long */

/*****************************************************************************/

GLOBAL BOOLEAN hndl_help (helpindex)
WORD helpindex;

{
  return (appl_help (get_str (helpinx, helpindex)));
} /* hndl_help */

/*****************************************************************************/

GLOBAL BOOLEAN appl_help (helpmsg)
BYTE *helpmsg;

{
  WORD     msg [8];
  LONGSTR  sz;

  sprintf (global_mem1, "%s%s%s %s", app_path, FREETXT (FHELPBAS), ".hyp", helpmsg);

  if (bShowDebugInfo)
  {
    sprintf (sz, "[0][Hilfe-Debug-Ausgabe||Pfad: '%s'|Datei: '%s.hyp'|Index: '%s'][~OK][0|1|1|0][]", app_path, FREETXT (FHELPBAS), helpmsg);
    open_alert (sz);
  } /* if */

  if (st_guide_apid >= 0)
  {
    msg [0] = VA_START;
    msg [1] = gl_apid;
    msg [2] = 0;
    msg [3] = (UWORD)((LONG)global_mem1 >> 16);
    msg [4] = (UWORD)((LONG)global_mem1 & 0xFFFFL);
    msg [5] = 0;
    msg [6] = 0;
    msg [7] = 0;

    appl_write (st_guide_apid, sizeof (msg), msg);

    return (TRUE);
  } /* if */
  else
    return (open_help (FREETXT (FHELPBAS), app_path, helpmsg));
} /* appl_help */


/*****************************************************************************/
/* [GS] 5.1d new function 																									 */
/* helpmsg: EnthÑlt den Namen und das Kapitel welche geîffnet werden soll		 */
/*					Name des Hyperttext;Index																				 */
/*					z.B. tos_hyp;n.aes																							 */


GLOBAL BOOLEAN user_help (helpmsg)
BYTE *helpmsg;

{
  BYTE     *p, *q;
  WORD     msg [8];
  LONGSTR  s, text, sz;

  strcpy (s, helpmsg);
  q = s;
  p = strchr (q, ';' );

  if (p != NULL)
  {
    *p = EOS;
    p++;
    strcpy (text, p);
  } /* if */
  else
    text [0] = EOS;


  sprintf (global_mem1, "%s%s%s %s", app_path, s, ".hyp", text);

  if (bShowDebugInfo)
  {
    sprintf (sz, "[0][UserHelp-Debug|Pfad: %s|Datei: %s.hyp|Index: %s][~OK][0|1|1|0][]", app_path, s, text);
    open_alert (sz);
  } /* if */

  if (st_guide_apid >= 0)
  {
    msg [0] = VA_START;
    msg [1] = gl_apid;
    msg [2] = 0;
    msg [3] = (UWORD)((LONG)global_mem1 >> 16);
    msg [4] = (UWORD)((LONG)global_mem1 & 0xFFFFL);
    msg [5] = 0;
    msg [6] = 0;
    msg [7] = 0;

    appl_write (st_guide_apid, sizeof (msg), msg);

    return (TRUE);
  } /* if */
  else
    return (open_help (FREETXT (FHELPBAS), app_path, helpmsg));
} /* user_help */

/*****************************************************************************/

GLOBAL WORD dbtest (db)
DB *db;

{
  WORD ret, result;

  ret    = 0;
  result = db_status (db->base);

  if (result != SUCCESS) ret = dberror (db->base->basename, result);

  return (ret);
} /* dbtest */

/*****************************************************************************/

GLOBAL WORD dberror (basename, errornum)
BYTE *basename;
WORD errornum;

{
  STRING  name;
  LONGSTR s;

  if (errornum == DB_CLOCK_ERR) errornum = DB_CRECLOCKED;

  sprintf (name, FREETXT (FDATABAS), basename);
  sprintf (s, alerts [errornum], name);
  return (open_alert (s));
} /* dberror */

/*****************************************************************************/

GLOBAL BOOLEAN integrity (base, table, status)
BASE *base;
WORD table, status;

{
  BOOLEAN    ok;
  WORD       error;
  BYTE       *p;
  LONGSTR    s, name;
  FIELD_INFO field_info;
  INDEX_INFO index_info;

  ok    = TRUE;
  table = rtable (table);
  error = db_status (base);

  sprintf (name, FREETXT (FDATABAS), base->basename);

  switch (error)
  {
    case DB_CNOTUNIQUE :
    case DB_CNOINSERT  :
    case DB_CNODELETE  :
    case DB_CNOUPDATE  : switch (error)
                         {
                           case DB_CNOTUNIQUE : p = alerts [ERR_IMPINXNOTUNIQUE]; break;
                           case DB_CNOINSERT  : p = alerts [ERR_IMPNOINSERT];     break;
                           case DB_CNODELETE  : p = alerts [ERR_IMPNODELETE];     break;
                           case DB_CNOUPDATE  : p = alerts [ERR_IMPNOUPDATE];     break;
                         } /* switch */
                         db_indexinfo (base, table, status, &index_info);
                         sprintf (s, p, name, (*index_info.name != EOS) ? index_info.name : index_info.indexname);
                         ok = open_alert (s) == 1;
                         break;
    case DB_CNULLCOL   : db_fieldinfo (base, table, status, &field_info);
                         sprintf (s, alerts [ERR_IMPCOLNULL], name, field_info.name);
                         ok = open_alert (s) == 1;
                         break;
    default            : dberror (base->basename, error);
                         ok = FALSE;
                         break;
  } /* switch */

  return (ok);
} /* integrity */

/*****************************************************************************/

GLOBAL WORD file_error (errornum, filename)
WORD errornum;
BYTE *filename;

{
  LONGSTR s;

  sprintf (s, alerts [errornum], filename);

  return (open_alert (s));
} /* file_error */

/*****************************************************************************/

GLOBAL VOID sort_tables (db, alphanum)
DB      *db;
BOOLEAN alphanum;

{
  WORD       i;
  T_INFO     *t_info;
  TABLE_INFO t_inf;

  alpha = alphanum;

  if (db->tables > 0)
  {
    qsort ((VOID *)db->t_info, (SIZE_T)db->tables, sizeof (T_INFO), t_compare);

    for (i = db->num_vis_tables = 0; i < db->tables; i++)
    {
      db_tableinfo (db->base, tablenum (db, i), &t_inf);

      if (! (t_inf.flags & TBL_HIDDEN))
        db->vis_tables [db->num_vis_tables++] = i;
    } /* for */
  } /* if */

  for (i = 0, t_info = db->t_info; i < db->tables; i++, t_info++) /* don't sort index 0 */
    if (t_info->indexes > 1)
      qsort ((VOID *)&t_info->i_info [1], (SIZE_T)(t_info->indexes - 1), sizeof (I_INFO), i_compare);
} /* sort_tables */

/*****************************************************************************/

GLOBAL WORD find_rel (db, src_table, src_index, dst_table)
DB   *db;
WORD src_table, src_index, dst_table;

{
  SYSREL     *sysrelp;
  WORD       num, i;
  TABLE_INFO t_inf;

  db_tableinfo (db->base, SYS_REL, &t_inf);
  sysrelp = db->base->sysrel;
  num     = (WORD)t_inf.recs;

  for (i = 0; i < num; i++, sysrelp++)
    if ((src_table == sysrelp->reftable) &&
        (src_index == sysrelp->refindex) &&
        (dst_table == sysrelp->reltable))
      return (sysrelp->relindex);

  return (FAILURE);
} /* find_rel */

/*****************************************************************************/

GLOBAL BOOLEAN sel_file (name, path, suffix, label, filename)
BYTE *name, *path;
WORD suffix, label;
BYTE *filename;

{
  fs_button = 0; /* in case there's no more memory for fsel_input */

  do
  {
    select_file (name, path, FREETXT (suffix), FREETXT (label), filename);
  } while ((fs_button != 0) && (*fs_sel == EOS));

 return (fs_button != 0);
} /* sel_file */

/*****************************************************************************/

GLOBAL BOOLEAN get_open_filename (WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  BOOLEAN  ok;
  FILENAME filename;
  FULLNAME path;

  if (pszHelpID == NULL)
    pszHelpID = get_str (helpinx, HSELFILE);

  if (use_std_fs)
  {
    file_split (pszFullName, NULL, path, filename, NULL);

    if (pszInitialDir != NULL)
      strcpy (path, pszInitialDir);

    ok = sel_file (filename, path, (wDefExt == FAILURE) ? FALLSUFF : wDefExt, wTitle, pszFullName);
  } /* if */
  else
    ok = GetOpenFileNameDialog (FREETXT (wTitle), pszHelpID, ulFlags, FREETXT (wFilter), plFilterIndex, pszInitialDir, (wDefExt == FAILURE) ? NULL : FREETXT (wDefExt) + 2, pszFullName, pszFileName);

  if (ok)
  {
    file_split (pszFullName, NULL, fs_path, fs_sel, NULL);
    file_split (pszFullName, NULL, path, pszFileName, NULL);

    if (pszInitialDir != NULL)
      strcpy (pszInitialDir, path);
  } /* if */

  return (ok);
} /* get_open_filename */

/*****************************************************************************/

GLOBAL BOOLEAN get_save_filename (WORD wTitle, BYTE *pszHelpID, ULONG ulFlags, WORD wFilter, LONG *plFilterIndex, BYTE *pszInitialDir, WORD wDefExt, BYTE *pszFullName, BYTE *pszFileName)
{
  BOOLEAN  ok;
  FILENAME filename;
  FULLNAME path;

  if (pszHelpID == NULL)
    pszHelpID = get_str (helpinx, HSELFILE);

  if (use_std_fs)
  {
    file_split (pszFullName, NULL, path, filename, NULL);

    if (pszInitialDir != NULL)
      strcpy (path, pszInitialDir);

    ok = sel_file (filename, path, (wDefExt == FAILURE) ? FALLSUFF : wDefExt, wTitle, pszFullName);
  } /* if */
  else
    ok = GetSaveFileNameDialog (FREETXT (wTitle), pszHelpID, ulFlags, FREETXT (wFilter), plFilterIndex, pszInitialDir, (wDefExt == FAILURE) ? NULL : FREETXT (wDefExt) + 2, pszFullName, pszFileName);

  if (ok)
  {
    file_split (pszFullName, NULL, fs_path, fs_sel, NULL);
    file_split (pszFullName, NULL, path, pszFileName, NULL);

    if (pszInitialDir != NULL)
      strcpy (pszInitialDir, path);
  } /* if */

  return (ok);
} /* get_save_filename */

/*****************************************************************************/

GLOBAL VOID set_idata (tree, object, mask, data, width, height)
OBJECT *tree;
WORD   object;
WORD   *mask;
WORD   *data;
WORD   width;
WORD   height;

{
  ICONBLK *piconblk;

  piconblk = (ICONBLK *)tree [object].ob_spec;

  piconblk->ib_pmask = mask;
  piconblk->ib_pdata = data;
  piconblk->ib_xicon = (piconblk->ib_wtext - width) / 2;
  piconblk->ib_yicon = piconblk->ib_ytext - height;
  piconblk->ib_wicon = (width + 15) & 0xFFF0;
  piconblk->ib_hicon = height;
} /* set_idata */

/*****************************************************************************/

GLOBAL VOID set_greyline ()

{
  line_default (vdi_handle);

  if (colors >= 16)
    vsl_color (vdi_handle, DWHITE);             /* grey line */
  else
  {
    vsl_type (vdi_handle, USERLINE);            /* dotted line */
    vsl_udsty (vdi_handle, 0xAAAA);
  } /* else */
} /* set_greyline */

/*****************************************************************************/

GLOBAL BOOLEAN esc_pressed ()

{
  BOOLEAN  esc;
  WORD     ret, event, ascii_code, scan_code;
  UWORD    kret;

  esc   = FALSE;
  event = evnt_multi (MU_KEYBD | MU_TIMER,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      NULL, 0, 0, &ret, &ret, &ret, &ret, &kret, &ret);

  if (event & MU_KEYBD)
  {
    ascii_code = kret & 0x00FF;
    scan_code  = kret >> 8;
    esc        = (ascii_code == ESC) || (scan_code == UNDO);
  } /* if */

  return (esc);
} /* esc_pressed */

/*****************************************************************************/

GLOBAL BOOLEAN check_close ()

{
  BOOLEAN more;
  WORD    num, i, class;
  WINDOWP window, winds [100];

  more = TRUE;
  num  = num_windows (NIL, SRCH_OPENED, winds);

  for (i = 0; more && (i < num); i++)
  {
    window = winds [i];
    class  = window->class;

    if (window->class != class_desk)    /* Muss offen bleiben bis zum Schluû */
    {
      close_window (window);
      more = (search_window (class, SRCH_OPENED, NIL) != window);
    } /* if */
  } /* for */

  return (more);
} /* check_close */

/*****************************************************************************/

GLOBAL VOID set_period (mk)
MKINFO *mk;

{
  BYTE *p;

  if (mk->scan_code == DEC_PERIOD)
  {
    p              = FREETXT (FSEP);
    mk->ascii_code = p [0];
  } /* if */
} /* set_period */

/*****************************************************************************/

GLOBAL VOID scan_header (db, vtable, inx, dir, pagenr, src, dst)
DB   *db;
WORD vtable, inx, dir, pagenr;
BYTE *src, *dst;

{
  BYTE    *sp, *dp;
  LONGSTR s, t;
  DATE    date;
  TIME    time;

  sp = src;
  dp = dst;

  while (*sp != EOS)
  {
    if (*sp == '$')
    {
      sp++;

      switch (*sp)
      {
        case 'B' : sprintf (s, "%s", db->base->basename);
                   strcpy (dp, s);
                   dp += strlen (s);
                   break;
        case 'D' : get_date (&date);
                   if (db->format == NULL)
                     sprintf (s, "%02d.%02d.%04d", date.day, date.month, date.year);
                   else
                   {
                     bin2str (TYPE_DATE, &date, s);
                     str2format (TYPE_DATE, s, db->format [TYPE_DATE]);
                   } /* else */
                   strcpy (dp, s);
                   dp += strlen (s);
                   break;
        case 'P' : sprintf (s, "%d", pagenr);
                   strcpy (dp, s);
                   dp += strlen (s);
                   break;
        case 'S' : sprintf (s, "%s.", table_name (db, vtable, t));
                   sort_name (db, vtable, inx, dir, t);
                   strcat (s, t + 1);
                   strcpy (dp, s);
                   dp += strlen (s);
                   break;
        case 'T' : get_time (&time);
                   if (db->format == NULL)
                     sprintf (s, "%02d:%02d:%02d", time.hour, time.minute, time.second);
                   else
                   {
                     bin2str (TYPE_TIME, &time, s);
                     str2format (TYPE_TIME, s, db->format [TYPE_TIME]);
                   } /* else */
                   strcpy (dp, s);
                   dp += strlen (s);
                   break;
        default  : *dp++ = *sp;
                   break;
      } /* switch */
    } /* if */
    else
      *dp++ = *sp;

    sp++;
  } /* for */

  *dp = EOS;
} /* scan_header */

/*****************************************************************************/

GLOBAL BOOLEAN text_export (BYTE *text, LONG size)
{
  HFILE    f;
  FULLNAME filename;

  strcpy (filename, scrapdir);
  strcat (filename, "Scrap.txt");

  if (! get_save_filename (FEXPTEXT, NULL, 0L, FFILTER_TXT, NULL, NULL, FAILURE, filename, NULL))
    return (FALSE);

  f = file_create (filename);
  if (f >= 0)
  {
    if (file_write (f, size, text) != size)
      file_error (ERR_FILEWRITE, filename);

    file_close (f);
  } /* if */
  else
  {
    file_error (ERR_FILECREATE, filename);
    return (FALSE);
  } /* else */

  return (TRUE);
} /* text_export */

/*****************************************************************************/

GLOBAL BOOLEAN text_import (BYTE *text, LONG size)
{
  HFILE    f;
  FULLNAME filename;

  strcpy (filename, scrapdir);
  strcat (filename, "Scrap.txt");

  if (! get_open_filename (FIMPTEXT, NULL, 0L, FFILTER_TXT, NULL, NULL, FAILURE, filename, NULL))
    return (FALSE);

  size = min (size, file_length (filename));

  f = file_open (filename, O_RDONLY);
  if (f >= 0)
  {
    if (file_read (f, size, text) != size)
      file_error (ERR_FILEREAD, filename);

    file_close (f);
  } /* if */
  else
  {
    file_error (ERR_FILEOPEN, filename);
    return (FALSE);
  } /* else */

  text [size] = EOS;

  return (TRUE);
} /* text_import */

/*****************************************************************************/

LOCAL INT CALLBACK lockfunc (lock)
BOOL lock;

{
  return (hndl_alert (lock ? DB_DNOLOCK : DB_DNOUNLOCK));
} /* lockfunc */

/*****************************************************************************/

LOCAL INT t_compare (arg1, arg2)
T_INFO *arg1, *arg2;

{
  if (alpha)
    return (strcmp (arg1->tablename, arg2->tablename));
  else
    return (arg1->tablenum - arg2->tablenum);
} /* t_compare */

/*****************************************************************************/

LOCAL INT i_compare (arg1, arg2)
I_INFO *arg1, *arg2;

{
  if (alpha)
    return (strcmp (arg1->indexname, arg2->indexname));
  else
    return (arg1->indexnum - arg2->indexnum);
} /* t_compare */

/*****************************************************************************/

LOCAL WORD type_width (db, type, format)
DB   *db;
WORD type, format;

{
  WORD width;
  FORM *f;

  if ((db->format == NULL) || (strlen (db->formatstr [format]) == 0))
    width = std_width [type];
  else
  {
    width = strlen (db->formatstr [format]);

    if ((type == TYPE_DATE) || (type == TYPE_TIME) || (type == TYPE_TIMESTAMP)) /* long month special case */
      for (f = db->format [format]; f->letter != EOS; f++)
        if (f->id == ID_MONTH_LONG) width += (monthwidth - strlen (FORM_MONTH_LONG));
  } /* else */

  if (! printable (type)) width = -1;   /* force width set to width of column name */

  if (type == TYPE_BLOB)
    width = MAX_BLOBNAME;

  return (width);
} /* type_width */

/*****************************************************************************/

LOCAL VOID check_func ()

{
  WINDOWP window;
  RECT    rf, rt;

  window = search_window (class_desk, SRCH_ANY, NIL);

  if (window->opened > 0)
  {
    objc_rect (desktop, FKEYS, &rf, FALSE);
    objc_rect (desktop, DTABLES, &rt, FALSE);

    if (rc_intersect (&rf, &rt)) draw_object (window, FKEYS);
  } /* if */
} /* check_func */

/*****************************************************************************/

LOCAL VOID show_table (tree, obj, table)
OBJECT *tree;
WORD obj, table;

{
  RECT    r;
  LONGSTR s;

  objc_rect (tree, obj, &r, FALSE);
  sprintf (s, FREETXT (FLOAD), FREETXT (FLOAD_TABLE + table));
  set_str (tree, obj, s);
  objc_draw (tree, obj, MAX_DEPTH, r.x, r.y, r.w, r.h);
} /* show_table */

/*****************************************************************************/

