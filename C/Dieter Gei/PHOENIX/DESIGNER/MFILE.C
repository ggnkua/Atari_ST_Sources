/*****************************************************************************
 *
 * Module : MFILE.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 24.07.91
 * Last modification: 16.06.96
 *
 *
 * Description: This module implements the file menu handling.
 *
 * History:
 * 16.06.96: stricmp used in msave_as
 * 28.09.95: Im/Exporting of BLOBS added to im/export_table
 * 22.03.94: Separators '@` removed from export_ascii
 * 16.03.94: Don't export password in export_ascii
 * 28.02.94: mascexp added
 * 24.11.93: New file selector box used
 * 13.10.93: get/set_opencfg changed
 * 08.09.93: set_ptext -> set_str
 * 06.09.93: Modifications in init_message, show_message made
 * 23.08.93: Moddifications for new resource layout
 * 24.07.91: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"
#include "root.h"

#include "base.h"
#include "bload.h"
#include "desktop.h"
#include "dialog.h"
#include "moptions.h"
#include "resource.h"

#include "export.h"
#include "mfile.h"

/****** DEFINES **************************************************************/

#define MAX_CACHESIZE	16					/* max kb's for chache on opening db */
#define INIT_CURSORS	80					/* number of cursors */
#define VERSION		"PHOENIX ASCII EXPORT Version 1.0"	/* version number of ASCII export file */
#define INXCOLS		7					/* special handling of field #7 in SYS_INDEX */
#define PASS		2					/* special handling of field #2 in SYS_USER */
#define ACCESS		5					/* special handling of field #5 in SYS_USER */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL FULLNAME filename;        /* full name for database to open */
LOCAL WORD     edit_inx;        /* index into password for edit_noecho */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_open        _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_open          _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN export_table      _((FHANDLE f, BASE *base, WORD table, VOID *buffer));
LOCAL BOOLEAN import_table      _((FHANDLE f, BASE *base, WORD table, VOID *buffer, LONG recs));
LOCAL BOOLEAN export_binary     _((FHANDLE f, BASE *base, WORD table, VOID *buffer));
LOCAL BOOLEAN import_binary     _((FHANDLE f, BASE *base, WORD table, VOID *buffer));
LOCAL BOOLEAN export_asc_table  _((FILE *f, BASE *base, WORD table, VOID *buffer));
LOCAL BOOLEAN export_ascii      _((FILE *f, BASE *base, WORD table, VOID *buffer));
LOCAL LONG    pack              _((BASE *base, WORD table, VOID *buffer, VOID *packbuf));
LOCAL LONG    unpack            _((BASE *base, WORD table, VOID *buffer, VOID *packbuf, LONG packsize));

/*****************************************************************************/

GLOBAL BOOLEAN init_mfile ()

{
  set_ptext (opendb, BUSER, "");
  get_opencfg ();

  *filename = EOS;

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
  opencfg.mode      = BSINGLE;
} /* get_opencfg */

/*****************************************************************************/

GLOBAL VOID set_opencfg ()

{
  set_str (opendb, BUSER, opencfg.username);
  set_str (opendb, BPASS, "");
  set_long (opendb, BINDCACH, opencfg.treecache);
  set_long (opendb, BDATCACH, opencfg.datacache);
  set_checkbox (opendb, BINDFLSH, opencfg.treeflush);
  set_checkbox (opendb, BDATFLSH, opencfg.dataflush);
  set_checkbox (opendb, BRDONLY, opencfg.rdonly);
  set_rbutton (opendb, opencfg.mode, BSINGLE, BMULTI);
} /* set_opencfg */

/*****************************************************************************/

GLOBAL VOID mnewdb ()

{
  FULLNAME basename;

  strcpy (basename, "");

  open_base (NIL, basename, NULL);
} /* mnewdb */

/*****************************************************************************/

GLOBAL VOID mopendb (dbname, auto_cache)
BYTE    *dbname;
BOOLEAN auto_cache;

{
  WINDOWP   window;
  WORD      ret, w, button;
  WORD      inx, i;
  BYTE      *p;
  EXT       suffix;
  FULLNAME  path;
  FULLNAME  tmpname;
  FILENAME  name;
  LONGSTR   s;
  WINDOWP   winds [MAX_GEMWIND];
  BASE_SPEC *base_spec;

  strcpy (path, db_path);
  strcpy (filename, dbname);

  if ((filename [0] != EOS) || (get_open_filename (FOPENDB, NULL, 0L, FFILTER_DAT, NULL, path, FDATSUFF, filename, db_name)))
  {
    file_split (filename, NULL, db_path, db_name, suffix);
    file_split (filename, NULL, tmpname, name, suffix);

    strcat (db_name, FREETXT (FDATSUFF) + 1);
    strcpy (filename, db_path);
    strcat (filename, db_name);
    strcat (tmpname, name);

    inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

    for (i = 0; i < inx; i++)                   /* test if db already open */
    {
      base_spec = (BASE_SPEC *)winds [i]->special;

      strcpy (path, base_spec->basepath);
      strcat (path, base_spec->basename);

      if (strcmp (tmpname, path) == 0)
      {
        hndl_alert (ERR_SAMEBASE);              /* db already open */
        return;
      } /* if */
    } /* for */

    if (! file_exist (filename))
    {
      sprintf (s, alerts [ERR_NODB], tmpname);
      button = open_alert (s);
      if (button == 1) open_base (NIL, filename, NULL);
      return;
    } /* if */

    window = search_window (CLASS_DIALOG, SRCH_ANY, OPENDB);

    if (window == NULL)
    {
      form_center (opendb, &ret, &ret, &ret, &ret);
      window = crt_dialog (opendb, NULL, OPENDB, FREETXT (FOPENDB), WI_MODAL);

      if (window != NULL)
      {
        window->click = click_open;
        window->key   = key_open;
      } /* if */
    } /* if */

    if (window != NULL)
    {
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
          file_split (filename, NULL, path, name, suffix);

          strcpy (filename, path);
          strcat (filename, name);
          strcat (filename, FREETXT (FINDSUFF) + 1);
          if (file_exist (filename)) opencfg.treecache = file_length (filename) / 1024;

          strcpy (filename, path);
          strcat (filename, name);
          strcat (filename, FREETXT (FDATSUFF) + 1);
          if (file_exist (filename)) opencfg.datacache = file_length (filename) / 1024;

          opencfg.treecache = min (opencfg.treecache, MAX_CACHESIZE);
          opencfg.datacache = min (opencfg.datacache, MAX_CACHESIZE);
        } /* if */

        set_opencfg ();
        undo_state (opendb, BOK, DISABLED);
      } /* if */

      if (! open_dialog (OPENDB)) hndl_alert (ERR_NOOPEN);
    } /* if */
  } /* if */
} /* mopendb */

/*****************************************************************************/

GLOBAL BOOLEAN msave_as (window)
WINDOWP window;

{
  WORD      inx, i, button;
  EXT       suffix;
  FULLNAME  fullname, path;
  FULLNAME  tmpname;
  FILENAME  name;
  LONGSTR   s;
  WINDOWP   winds [MAX_GEMWIND];
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  strcpy (path, db_path);
  sprintf (filename, "%s.%s", base_spec->basename, DATA_SUFF);
  strcpy (fullname, path);
  strcat (fullname, filename);

  if (get_save_filename (FSAVEAS, NULL, 0L, FFILTER_DAT, NULL, path, FDATSUFF, fullname, filename))
  {
    file_split (fullname, NULL, db_path, db_name, suffix);
    file_split (fullname, NULL, tmpname, name, suffix);

    strcat (db_name, FREETXT (FDATSUFF) + 1);
    strcat (tmpname, name);

    if (file_exist (fullname))
    {
      sprintf (s, alerts [ERR_OVERWRITE], db_path, name);
      button = open_alert (s);
      if (button == 2) return (FALSE);  /* user clicked on "No" */
    } /* if */

    inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

    for (i = 0; i < inx; i++)                   /* test if db already open */
    {
      base_spec = (BASE_SPEC *)winds [i]->special;

      strcpy (path, base_spec->basepath);
      strcat (path, base_spec->basename);

      if ((stricmp (tmpname, path) == 0) && (winds [i] != window))
      {
        hndl_alert (ERR_SAMEBASE);              /* db already open */
        return (FALSE);
      } /* if */
    } /* for */

    base_spec = (BASE_SPEC *)window->special;
    strcpy (base_spec->basepath, db_path);
    strcpy (base_spec->basename, name);
    base_spec->modified = FALSE;
    b_wi_title (window);
    base_spec->modified = TRUE;                 /* force writing */

    return (TRUE);
  } /* if */

  return (FALSE);
} /* msave_as */

/*****************************************************************************/

GLOBAL VOID mexport (base_spec, expname)
BASE_SPEC *base_spec;
BYTE      *expname;

{
  BOOLEAN   ok, mode;
  WORD      i, button;
  WORD      start_table;
  WORD      start_column;
  WORD      start_index;
  UWORD     flags;
  LONG      bufsize;
  LONG      recs [NUM_SYSTABLES];
  FHANDLE   f;
  FULLNAME  filename;
  EXT       suffix;
  LONGSTR   s;
  RECT      r;
  MFDB      screen, buf;
  VOID      *buffer;
  BASE      *base;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;

  if (base_spec->base == NULL) return;

  base    = base_spec->base;
  ok      = TRUE;
  bufsize = 0;

  if (expname == NULL)
  {
    strcpy (s, base_spec->basename);
    strcat (s, FREETXT (FDBSSUFF) + 1);
    strcpy (filename, exp_path);
    strcat (filename, s);

    if (! get_save_filename (FEXPSTR, NULL, 0L, FFILTER_DBS, NULL, exp_path, FDBSSUFF, filename, s)) return;
  } /* if */
  else
    strcpy (filename, expname);

  if (file_exist (filename))
  {
    button = file_error (ERR_FILEEXISTS, filename);
    if (button == 2) return;
  } /* if */

  file_split (filename, NULL, exp_path, exp_name, suffix);
  sprintf (filename, "%s%s%s", exp_path, exp_name, FREETXT (FDBSSUFF) + 1);
  file_split (filename, NULL, exp_path, exp_name, NULL);

  start_table  = NUM_SYSTABLES;
  start_column = base_spec->sysptr [NUM_SYSTABLES - 1].column;
  start_index  = base_spec->sysptr [NUM_SYSTABLES - 1].index;

  systable  = &base_spec->systable [start_table];
  syscolumn = &base_spec->syscolumn [start_column];
  sysindex  = &base_spec->sysindex [start_index];

  recs [SYS_TABLE]   = base_spec->num_tables  - start_table;
  recs [SYS_COLUMN]  = base_spec->num_columns - start_column;
  recs [SYS_INDEX]   = base_spec->num_indexes - start_index;
  recs [SYS_REL]     = base_spec->num_rels;
  recs [SYS_USER]    = base_spec->num_users;
  recs [SYS_DELETED] = 0;
  recs [SYS_ICON]    = base_spec->num_icons;
  recs [SYS_TATTR]   = base_spec->num_tattrs;
  recs [SYS_FORMAT]  = base_spec->num_formats;
  recs [SYS_LOOKUP]  = base_spec->num_lookups;

  for (i = SYS_CALC; i < NUM_SYSTABLES; i++)
  {
    recs [i] = base_spec->systable [i].recs;
    bufsize  = max (bufsize, base_spec->systable [i].size);
  } /* for */

  buffer = mem_alloc (bufsize);
  if (buffer == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  f = file_create (filename);
  if (f < 0)
  {
    file_error (ERR_FILECREATE, filename);
    return;
  } /* if */

  mode = set_alert (TRUE);              /* alert boxes as dialog boxes */

  strcpy (s, FREETXT (FEXPSTR));
  init_message (MFILE, &r, &screen, &buf, s);

  busy_mouse ();

  flags = base->datainf->page0.flags | base->treeinf->page0.flags;
  ok = file_write (f, (LONG)sizeof (UWORD), &flags) == sizeof (UWORD);
  ok = file_write (f, (LONG)sizeof (recs), recs) == sizeof (recs);

  if (! ok) file_error (ERR_FILEWRITE, filename);

  show_message ((WORD)recs [SYS_TABLE], FWRITE, FTABLES);
  for (i = start_table; ok && (i < base_spec->num_tables); i++, systable++)
  {
    flags            = systable->flags;
    systable->recs   = 0;
    systable->flags &= ~ DESIGNER_FLAGS;
    ok               = export_binary (f, base, SYS_TABLE, systable);
    systable->flags  = flags;

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  show_message ((WORD)recs [SYS_COLUMN], FWRITE, FCOLUMNS);
  for (i = start_column; ok && (i < base_spec->num_columns); i++, syscolumn++)
  {
    flags             = syscolumn->flags;
    syscolumn->flags &= ~ DESIGNER_FLAGS;
    ok                = export_binary (f, base, SYS_COLUMN, syscolumn);
    syscolumn->flags  = flags;

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  show_message ((WORD)recs [SYS_INDEX], FWRITE, FINDEXES);
  for (i = start_index; ok && (i < base_spec->num_indexes); i++, sysindex++)
  {
    flags               = sysindex->flags;
    sysindex->root      = 0;
    sysindex->num_keys  = 0;
    sysindex->flags    &= ~ DESIGNER_FLAGS;
    ok                  = export_binary (f, base, SYS_INDEX, sysindex);
    sysindex->flags     = flags;

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  for (i = SYS_REL; ok && (i < NUM_SYSTABLES); i++)
  {
    show_message ((WORD)recs [i], FWRITE, FTABLES + i);
    if (recs [i] > 0) ok = ok && export_table (f, base, i, buffer);
    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  file_close (f);
  mem_free (buffer);
  arrow_mouse ();
  exit_message (&r, &screen, &buf);
  set_alert (mode);                     /* restore old mode */
} /* mexport */

/*****************************************************************************/

GLOBAL VOID mimport ()

{
  BOOLEAN   ok, mode;
  WORD      i, inx, button;
  UWORD     flags;
  LONG      bufsize;
  LONG      recs [NUM_SYSTABLES];
  FHANDLE   f;
  FULLNAME  filename, fullname, tmpname;
  FULLNAME  basepath, path;
  FILENAME  basename;
  EXT       suffix;
  LONGSTR   s, str;
  RECT      r;
  MFDB      screen, buf;
  WINDOWP   winds [MAX_GEMWIND];
  VOID      *buffer;
  BASE      *base;
  SYSTABLE  *systable;
  BASE_SPEC *base_spec;

  strcpy (filename, exp_path);
  strcat (filename, exp_name);

  if (! get_open_filename (FIMPSTR, NULL, 0L, FFILTER_DBS, NULL, exp_path, FDBSSUFF, filename, exp_name)) return;
  file_split (filename, NULL, basepath, basename, suffix);
  sprintf (filename, "%s%s%s", basepath, basename, FREETXT (FDBSSUFF) + 1);
  file_split (filename, NULL, exp_path, exp_name, NULL);
  strcat (basename, FREETXT (FDATSUFF) + 1);

  strcpy (fullname, basepath);
  strcat (fullname, basename);

  if (! get_save_filename (FSAVEAS, NULL, 0L, FFILTER_DAT, NULL, basepath, FDATSUFF, fullname, basename)) return;
  file_split (fullname, NULL, basepath, basename, suffix);
  strcpy (tmpname, basepath);
  strcat (tmpname, basename);

  sprintf (fullname, "%s%s%s", basepath, basename, FREETXT (FDATSUFF) + 1);

  inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

  for (i = 0; i < inx; i++)                     /* test if db already open */
  {
    base_spec = (BASE_SPEC *)winds [i]->special;

    strcpy (path, base_spec->basepath);
    strcat (path, base_spec->basename);

    if (strcmp (tmpname, path) == 0)
    {
      hndl_alert (ERR_SAMEBASE);                /* db already open */
      return;
    } /* if */
  } /* for */

  if (file_exist (fullname))
  {
    sprintf (s, alerts [ERR_OVERWRITE], basepath, basename);
    button = open_alert (s);
    if (button == 2) return;                    /* user clicked on "No" */
  } /* if */

  f = file_open (filename, O_RDONLY);
  if (f < 0)
  {
    file_error (ERR_FILEOPEN, filename);
    return;
  } /* if */

  busy_mouse ();
  ok = file_read (f, (LONG)sizeof (UWORD), &flags) == sizeof (UWORD);
  ok = file_read (f, (LONG)sizeof (recs), recs) == sizeof (recs);

  if (! ok) file_error (ERR_FILEREAD, filename);

  sprintf (str, "%s%s", basepath, basename);
  sprintf (s, FREETXT (FCREATE), str);
  init_message (MFILE, &r, &screen, &buf, s);

  base = db_create (basename, basepath, flags | BASE_SUPER, 16L, 16L);
  arrow_mouse ();
  if (base == NULL)
  {
    exit_message (&r, &screen, &buf);
    hndl_alert (ERR_DBCREATE);
    return;
  } /* if */

  bufsize  = 0;
  systable = base->systable;

  for (i = 0; i < NUM_SYSTABLES; i++, systable++)
    bufsize = max (bufsize, systable->size);

  buffer = mem_alloc (bufsize);
  if (buffer == NULL)
  {
    exit_message (&r, &screen, &buf);
    db_close (base);
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  mode = set_alert (TRUE);              /* alert boxes as dialog boxes */
  busy_mouse ();

  for (i = 0; ok && (i < NUM_SYSTABLES); i++)
  {
    show_message ((WORD)recs [i], FREAD, FTABLES + i);
    ok = import_table (f, base, i, buffer, recs [i]);
    if (! ok) file_error (ERR_FILEREAD, filename);
  } /* for */

  set_alert (mode);                     /* restore old mode */
  file_close (f);
  mem_free (buffer);
  db_close (base);
  arrow_mouse ();
  exit_message (&r, &screen, &buf);

  if (ok) mopendb (fullname, TRUE);
} /* mimport */

/*****************************************************************************/

GLOBAL VOID mascexp (base_spec, expname)
BASE_SPEC *base_spec;
BYTE      *expname;

{
  BOOLEAN   ok, mode;
  WORD      i, button;
  WORD      start_table;
  WORD      start_column;
  WORD      start_index;
  UWORD     flags;
  LONG      bufsize;
  LONG      recs [NUM_SYSTABLES];
  FULLNAME  filename;
  EXT       suffix;
  LONGSTR   s;
  RECT      r;
  MFDB      screen, buf;
  FILE      *file;
  VOID      *buffer;
  BASE      *base;
  SYSTABLE  *systable;
  SYSCOLUMN *syscolumn;
  SYSINDEX  *sysindex;

  if (base_spec->base == NULL) return;

  base    = base_spec->base;
  ok      = TRUE;
  bufsize = 0;

  if (expname == NULL)
  {
    strcpy (s, base_spec->basename);
    strcat (s, FREETXT (FASCSUFF) + 1);
    strcpy (filename, exp_path);
    strcat (filename, s);

    if (! get_save_filename (FASCEXP, NULL, 0L, FFILTER_ASC, NULL, exp_path, FASCSUFF, filename, s)) return;
  } /* if */
  else
    strcpy (filename, expname);

  if (file_exist (filename))
  {
    button = file_error (ERR_FILEEXISTS, filename);
    if (button == 2) return;
  } /* if */

  file_split (filename, NULL, exp_path, exp_name, suffix);
  sprintf (filename, "%s%s%s", exp_path, exp_name, FREETXT (FASCSUFF) + 1);
  file_split (filename, NULL, exp_path, exp_name, NULL);

  start_table  = NUM_SYSTABLES;
  start_column = base_spec->sysptr [NUM_SYSTABLES - 1].column;
  start_index  = base_spec->sysptr [NUM_SYSTABLES - 1].index;

  systable  = &base_spec->systable [start_table];
  syscolumn = &base_spec->syscolumn [start_column];
  sysindex  = &base_spec->sysindex [start_index];

  recs [SYS_TABLE]   = base_spec->num_tables  - start_table;
  recs [SYS_COLUMN]  = base_spec->num_columns - start_column;
  recs [SYS_INDEX]   = base_spec->num_indexes - start_index;
  recs [SYS_REL]     = base_spec->num_rels;
  recs [SYS_USER]    = base_spec->num_users;
  recs [SYS_DELETED] = 0;
  recs [SYS_ICON]    = 0;			/* don't export sysicon for intel machines */
  recs [SYS_TATTR]   = base_spec->num_tattrs;
  recs [SYS_FORMAT]  = base_spec->num_formats;
  recs [SYS_LOOKUP]  = base_spec->num_lookups;

  for (i = SYS_CALC; i < NUM_SYSTABLES; i++)
  {
    if ((i == SYS_MASK) || (i == SYS_BLOB) || (i == SYS_ACCOUNT))	/* don't export these tables for intel machines */
      recs [i] = 0;
    else
      recs [i] = base_spec->systable [i].recs;

    bufsize  = max (bufsize, base_spec->systable [i].size);
  } /* for */

  buffer = mem_alloc (bufsize);
  if (buffer == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  file = fopen (filename, WRITE_TXT);
  if (file  == NULL)
  {
    file_error (ERR_FILECREATE, filename);
    return;
  } /* if */

  mode = set_alert (TRUE);              /* alert boxes as dialog boxes */

  strcpy (s, FREETXT (FASCEXP));
  init_message (MFILE, &r, &screen, &buf, s);

  busy_mouse ();

  flags = base->datainf->page0.flags | base->treeinf->page0.flags;

  fprintf (file, "%s\n", VERSION);
  fprintf (file, "%04x (DATABASE FLAGS)\n\n", flags);

  for (i = SYS_TABLE; ok && (i < NUM_SYSTABLES); i++)
    fprintf (file, "%ld (%s)\n", recs [i], db_tablename (base_spec->base, i));

  fprintf (file, "\nSYS_TABLE\n");

  show_message ((WORD)recs [SYS_TABLE], FWRITE, FTABLES);
  for (i = start_table; ok && (i < base_spec->num_tables); i++, systable++)
  {
    flags            = systable->flags;
    systable->recs   = 0;
    systable->flags &= ~ DESIGNER_FLAGS;
    ok               = export_ascii (file, base, SYS_TABLE, systable);
    systable->flags  = flags;
    fprintf (file, "\n");

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  fprintf (file, "SYS_COLUMN\n");

  show_message ((WORD)recs [SYS_COLUMN], FWRITE, FCOLUMNS);
  for (i = start_column; ok && (i < base_spec->num_columns); i++, syscolumn++)
  {
    flags             = syscolumn->flags;
    syscolumn->flags &= ~ DESIGNER_FLAGS;
    ok                = export_ascii (file, base, SYS_COLUMN, syscolumn);
    syscolumn->flags  = flags;
    fprintf (file, "\n");

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  fprintf (file, "SYS_INDEX\n");

  show_message ((WORD)recs [SYS_INDEX], FWRITE, FINDEXES);
  for (i = start_index; ok && (i < base_spec->num_indexes); i++, sysindex++)
  {
    flags               = sysindex->flags;
    sysindex->root      = 0;
    sysindex->num_keys  = 0;
    sysindex->flags    &= ~ DESIGNER_FLAGS;
    ok                  = export_ascii (file, base, SYS_INDEX, sysindex);
    sysindex->flags     = flags;
    fprintf (file, "\n");

    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  for (i = SYS_REL; ok && (i < NUM_SYSTABLES); i++)
  {
    show_message ((WORD)recs [i], FWRITE, FTABLES + i);
    if (recs [i] > 0) ok = ok && export_asc_table (file, base, i, buffer);
    if (! ok) file_error (ERR_FILEWRITE, filename);
  } /* for */

  fclose (file);
  mem_free (buffer);
  arrow_mouse ();
  exit_message (&r, &screen, &buf);
  set_alert (mode);                     /* restore old mode */
} /* mascexp */

/*****************************************************************************/

LOCAL VOID click_open (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  UWORD     flags;
  WORD      result, button;
  FULLNAME  path;
  FILENAME  name;
  EXT       suffix;
  LONGSTR   s;
  BASE_INFO base_info;
  BASE_SPEC base_spec;

  switch (window->exit_obj)
  {
    case BPASS : edit_inx = window->edit_inx;
                 break;
    case BOK   : get_opencfg ();                /* get parameters from box */

                 mem_set (&base_spec, 0, sizeof (BASE_SPEC));
                 flags = 0;
                 if (opencfg.treeflush) flags |= TREE_FLUSH;
                 if (opencfg.dataflush) flags |= DATA_FLUSH;
                 if (opencfg.rdonly)    flags |= BASE_RDONLY;
                 file_split (filename, NULL, path, name, suffix);

                 base_spec.base = open_db (filename, flags, opencfg.datacache, opencfg.treecache, opencfg.cursors, opencfg.username, opencfg.password, &result);

                 if ((result == SUCCESS) || (result == DB_DNOTCLOSED) || (result == DB_DNOOPEN))
                 {
                   if (result == DB_DNOTCLOSED) dberror (result, name);

                   mem_set (&base_info, 0, sizeof (BASE_INFO));

                   if (base_spec.base == NULL)
                   {
                     sprintf (filename, "%s%s", path, name);
                     sprintf (s, alerts [ERR_NODB], filename);
                     button = open_alert (s);
                     if (button == 1) open_base (NIL, filename, NULL);
                   } /* if */
                   else
                   {
                     if (base_spec.base->datainf->page0.reorg)
                     {
                       sprintf (s, alerts [ERR_REORG], name);
                       open_alert (s);
                     } /* if */

                     db_baseinfo (base_spec.base, &base_info);

                     base_spec.new        = TRUE;       /* indicates here open existing one */
                     base_spec.untitled   = FALSE;
                     base_spec.oflags     = flags;
                     base_spec.datasize   = base_info.data_info.file_size / 1024;
                     base_spec.treesize   = base_info.tree_info.num_pages / 2;
                     base_spec.datacache  = opencfg.datacache;
                     base_spec.treecache  = opencfg.treecache;
                     base_spec.cursors    = opencfg.cursors;
                     base_spec.rdonly     = opencfg.rdonly;
                     base_spec.show_short = TRUE;
                     base_spec.font       = g_font;
                     base_spec.point      = g_point;
                     strcpy (base_spec.username, opencfg.username);
                     strcpy (base_spec.password, opencfg.password);

                     open_base (NIL, filename, &base_spec);
                   } /* if */
                 } /* if */
                 else
                 {
                   if (result == DB_CPASSWORD) set_cursor (window, BUSER, NIL);
                   if (result == ERR_NOMEMRETRY) set_cursor (window, BINDCACH, NIL);

                   if (result != DB_DNOLOCK) button = dberror (result, name);

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

LOCAL BOOLEAN export_table (f, base, table, buffer)
FHANDLE f;
BASE    *base;
WORD    table;
VOID    *buffer;

{
  BOOLEAN    bOk;
  WORD       inx, i;
  LONG       steps, l;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  HPBLOB     hpBlob;
  SYSBLOB    *pSysBlob;
  CURSOR     *cursor;

  bOk    = TRUE;
  inx    = ((table == SYS_USER) || (table == SYS_MASK)) ? 0 : 1;        /* keep sequential order */
  steps  = 1;
  cursor = db_newcursor (base);
  dbtest (base);

  if (cursor != NULL)
  {
    if (db_initcursor (base, table, inx, ASCENDING, cursor))
      while (db_movecursor (base, cursor, steps) && bOk)
      {
        if (db_read (base, table, buffer, cursor, 0L, FALSE))
        {
#if GEMDOS
          if (table == SYS_ICON)
          {
            SYSICON *sysicon;

            sysicon              = (SYSICON *)buffer;
            sysicon->bitmap.size = 0;			/* bitmap has not been appended but inserted before flags */
            sysicon->flags       = 0x0000;
          } /* if */
#endif
          bOk = export_binary (f, base, table, buffer);

          db_tableinfo (base, table, &table_info);

          for (i = 1; (i < table_info.cols) && bOk; i++)	/* export BLOBs */
          {
            db_fieldinfo (base, table, i, &field_info);

            if (field_info.type == TYPE_BLOB)
            {
              hpBlob = (HPBLOB)((HPCHAR)buffer + field_info.addr);

              if (hpBlob->address == 0)			/* empty blob, can't read from disk */
              {
                l   = 0;			/* null record size */
                bOk = file_write (f, sizeof (LONG), &l) == sizeof (LONG);
              } /* if */
              else
              {
                pSysBlob = db_readblob (base, NULL, NULL, hpBlob->address, FALSE);
                bOk      = pSysBlob != NULL;

                if (! bOk)
                  dbtest (base);
                else
                  bOk = export_binary (f, base, SYS_BLOB, (VOID *)pSysBlob);

                mem_free (pSysBlob);
              } /* else */
            } /* if */
          } /* for */
        } /* if */

        dbtest (base);
      } /* while */

    db_freecursor (base, cursor);

    return (bOk);
  } /* if */
  else
    return (FALSE);
} /* export_table */

/*****************************************************************************/

LOCAL BOOLEAN import_table (f, base, table, buffer, recs)
FHANDLE f;
BASE    *base;
WORD    table;
VOID    *buffer;
LONG    recs;

{
  BOOLEAN    bOk;
  WORD       status, i;
  LONG       rec, lBlobSize;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  HPBLOB     hpBlob;
  SYSBLOB    *pSysBlob;

  bOk = TRUE;

  for (rec = 0; bOk && (rec < recs); rec++)
  {
    bOk = import_binary (f, base, table, buffer);

    db_tableinfo (base, table, &table_info);

    for (i = 1; (i < table_info.cols) && bOk; i++)	/* import BLOBs */
    {
      db_fieldinfo (base, table, i, &field_info);

      if (field_info.type == TYPE_BLOB)
      {
        hpBlob = (HPBLOB)((HPCHAR)buffer + field_info.addr);
        bOk    = file_read (f, sizeof (lBlobSize), &lBlobSize) == (LONG)sizeof (lBlobSize);

        if (bOk)
        {
          if (lBlobSize == 0)			/* was an empty blob */
            hpBlob->address = 0;
          else
          {
            pSysBlob = mem_alloc (lBlobSize + sizeof (LONG));
            bOk      = pSysBlob != NULL;

            if (! bOk)
              hndl_alert (ERR_NOMEMORY);
            else
            {
              bOk = file_read (f, lBlobSize, &pSysBlob->size) == lBlobSize;

              if (bOk)
              {
                bOk = db_insert (base, SYS_BLOB, pSysBlob, &status);

                if (bOk)
                  hpBlob->address = pSysBlob->address;
                else
                  dbtest (base);
              } /* if */

              mem_free (pSysBlob);
            } /* else */
          } /* else */
        } /* if */
      } /* if */
    } /* for */

    if (bOk) bOk = db_insert (base, table, buffer, &status);

    dbtest (base);
  } /* for */

  return (bOk);
} /* import_table */

/*****************************************************************************/

LOCAL BOOLEAN export_binary (f, base, table, buffer)
FHANDLE f;
BASE    *base;
WORD    table;
VOID    *buffer;

{
  BOOLEAN ok;
  LONG    size, *longp;
  BYTE    *packbuf;

  size    = pack (base, table, buffer, NULL) + sizeof (LONG);
  packbuf = mem_alloc (size);
  ok      = packbuf != NULL;

  if (! ok)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    size    = pack (base, table, buffer, packbuf + sizeof (LONG));
    longp   = (LONG *)packbuf;
    *longp  = size;
    size   += sizeof (LONG);
    ok      = file_write (f, size, packbuf) == size;

    mem_free (packbuf);
  } /* else */

  return (ok);
} /* export_binary */

/*****************************************************************************/

LOCAL BOOLEAN import_binary (f, base, table, buffer)
FHANDLE f;
BASE    *base;
WORD    table;
VOID    *buffer;

{
  BOOLEAN ok;
  LONG    packsize;
  BYTE    *packbuf;

  ok = file_read (f, sizeof (packsize), &packsize) == sizeof (packsize);

  if (! ok) return (FALSE);

  packbuf = mem_alloc (packsize);
  ok      = packbuf != NULL;

  if (! ok)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    ok = file_read (f, packsize, packbuf) == packsize;
    if (ok) unpack (base, table, buffer, packbuf, packsize);
    mem_free (packbuf);
  } /* else */

  return (ok);
} /* import_binary */

/*****************************************************************************/

LOCAL BOOLEAN export_asc_table (FILE *f, BASE *base, WORD table, VOID *buffer)
{
  BOOLEAN    ok;
  WORD       inx;
  LONG       steps;
  TABLE_INFO table_info;
  CURSOR     *cursor;

  ok     = TRUE;
  inx    = ((table == SYS_USER) || (table == SYS_MASK)) ? 0 : 1;        /* keep sequential order */
  steps  = 1;
  cursor = db_newcursor (base);
  dbtest (base);

  if (cursor != NULL)
  {
    db_tableinfo (base, table, &table_info);
    fprintf (f, "%s\n", table_info.name);

    if (db_initcursor (base, table, inx, ASCENDING, cursor))
      while (db_movecursor (base, cursor, steps) && ok)
      {
        if (db_read (base, table, buffer, cursor, 0L, FALSE))
        {
#if GEMDOS
          if (table == SYS_ICON)
          {
            SYSICON *sysicon;

            sysicon              = (SYSICON *)buffer;
            sysicon->bitmap.size = 0;			/* bitmap has not been appended but inserted before flags */
            sysicon->flags       = 0x0000;
          } /* if */
#endif
          ok = export_ascii (f, base, table, buffer);
          fprintf (f, "\n");
        } /* if */
        dbtest (base);
      } /* while */

    db_freecursor (base, cursor);
    return (ok);
  } /* if */
  else
    return (FALSE);
} /* export_asc_table */

/*****************************************************************************/

LOCAL BOOLEAN export_ascii (FILE *f, BASE *base, WORD table, VOID *buffer)
{
  SHORT      field, i, cols, rights;
  LONGSTR    s, t;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *p;
  SYSINDEX   *sysindex;
  SYSUSER    *sysuser;

  db_tableinfo (base, table, &table_info);

  for (field = 1; field < table_info.cols; field++)
  {
    db_fieldinfo (base, table, field, &field_info);

    if (HASWILD (field_info.type))
      p = (BYTE *)buffer + field_info.addr;
    else
    {
      p = s;
      if (! bin2str (field_info.type, (BYTE *)buffer + field_info.addr, p))
        strcpy (p, "");

      if ((table == SYS_INDEX) || (table == SYS_USER))
        switch (table)
        {
          case SYS_INDEX : if (field == INXCOLS)
                           {
                             sysindex = (SYSINDEX *)buffer;
                             cols     = sysindex->inxcols.size / sizeof (INXCOL);
                             sprintf (s, "%d: ", cols);

                             for (i = 0; i < cols; i++)
                             {
                               sprintf (t, "%d, %d, ", sysindex->inxcols.cols [i].col, sysindex->inxcols.cols [i].len);
                               strcat (s, t);
                             } /* for */
                           } /* if */
                           break;
          case SYS_USER  : if (field == ACCESS)
                           {
                             sysuser = (SYSUSER *)buffer;
                             rights  = sysuser->access.size / sizeof (SHORT);
                             sprintf (s, "%d: ", rights);

                             for (i = 0; i < rights; i++)
                             {
                               sprintf (t, "%d, ", sysuser->access.list [i]);
                               strcat (s, t);
                             } /* for */
                           } /* if */
                           break;
        } /* switch, if */
    } /* else */

    if ((table == SYS_USER) && (field == PASS)) *p = EOS;	/* don't export password */

    for (i = 0; i < strlen (p); i++)
      if ((p [i] == '\r') || (p [i] == '\n'))
        p [i] = '~';

    fprintf (f, "%s\n", p);
  } /* for */

  return (TRUE);
} /* export_ascii */

/*****************************************************************************/

LOCAL LONG pack (base, table, buffer, packbuf)
BASE *base;
WORD table;
VOID *buffer;
VOID *packbuf;

{
  LONG      size, msize;
  WORD      i, abscol;
  SYSTABLE  *tablep;
  SYSCOLUMN *colp;
  BYTE      *srcp, *dstp;

  abscol = base->sysptr [table].column + 1;     /* don't use col zero */
  size   = 0;
  tablep = &base->systable [table];
  colp   = &base->syscolumn [abscol];
  dstp   = (BYTE *)packbuf;

  if (table == SYS_BLOB)		/* unpacked variable size */
    size = db_pack (base, table, buffer, packbuf);
  else
    for (i = 1; i < tablep->cols; i++, colp++)
    {
      srcp  = (BYTE *)buffer + colp->addr;
      msize = typesize (colp->type, srcp);
      if (dstp != NULL) mem_lmove (dstp, srcp, msize);

      size += msize;
      if (dstp != NULL) dstp += msize;
    } /* for, else */

  return (size);
} /* pack */

/*****************************************************************************/

LOCAL LONG unpack (base, table, buffer, packbuf, packsize)
BASE *base;
WORD table;
VOID *buffer;
VOID *packbuf;
LONG packsize;

{
  LONG      msize, size, tblsize;
  WORD      i, abscol;
  SYSTABLE  *tablep;
  SYSCOLUMN *colp;
  BYTE      *srcp, *dstp;

  abscol  = base->sysptr [table].column + 1;     /* don't use col zero */
  tablep  = &base->systable [table];
  colp    = &base->syscolumn [abscol];
  tblsize = tablep->size;
  srcp    = (BYTE *)packbuf;

  if (table == SYS_BLOB)                       /* unpacked variable size */
    tblsize = db_unpack (base, table, buffer, packbuf, packsize);
  else
    for (i = 1; i < tablep->cols; i++, colp++)
    {
      dstp  = (HPCHAR)buffer + colp->addr;
      msize = (packsize <= 0) ? 0L : typesize (colp->type, srcp);
      size  = msize;

      if (VARLEN (colp->type))                 /* any string type */
        if (size > colp->size)                 /* string has been made shorter */
        {
          size        = colp->size;            /* don't move too many bytes */
	  dstp [size] = EOS;                   /* terminate string */
        } /* if, if */

      if (packsize > 0)                        /* valid buffer */
        mem_lmove (dstp, srcp, size);
      else                                     /* more fields than there are in buffer */
        set_null (colp->type, dstp);

      srcp     += msize;
      packsize -= msize;
    } /* for, else */

  return (tblsize);
} /* unpack */

