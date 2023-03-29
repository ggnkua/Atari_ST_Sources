/*****************************************************************************
 *
 * Module : REORG.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 03.11.96
 *
 *
 * Description: This module implements the reorg process.
 *
 * History:
 * 03.11.96: Handling of SYS_PICTURE added
 * 21.06.96: Long filenames supported in reorg dialog boxes
 * 16.06.96: Call to str_upper removed
 * 03.10.95: BLOB handling added
 * 20.12.94: Datacache is made smaller if not enough memory available
 * 24.10.94: Tables are now shown correctly in do_reorg (table = FAILURE)
 * 13.03.94: Parameter use_opencfg in reorganizer added
 * 10.12.93: Problem fixed with SYS_ICON and old databases in do_read
 * 16.11.93: Using new file selector
 * 07.10.93: Variables max_datacache and max_treecache used
 * 03.10.93: Background of dialog box is set according to sys_colors
 * 28.09.93: Macro STEPS added
 * 13.09.93: Component mpos renamed to pos
 * 27.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "redefs.h"     /* for direct manipulation of data files */

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "help.h"
#include "mfile.h"
#include "resource.h"

#include "export.h"
#include "reorg.h"

/****** DEFINES **************************************************************/

#define OPENMEM      128        /* estimated minimum memory to open a database */
#define MINCACHE      16        /* minimum suggested cache for keys */
#define DATASIZE       8L       /* kb's to create datafile */
#define TREESIZE       8L       /* kb's to create treefile */

#define STEPS        100	/* number of steps for display */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL FULLNAME filename;        /* full name for database to open */
LOCAL WORD     edit_inx;        /* index into password for edit_noecho */
LOCAL WORD     askret;          /* return value of ask_mode */
LOCAL WORD     askmode;         /* mode of ask_mode */
LOCAL BOOLEAN  askencode;       /* encode database */

LOCAL LONG     all_recs;        /* all records to reorganize */
LOCAL LONG     lost_recs;       /* lost records */
LOCAL LONG     del_recs;        /* deleted records */
LOCAL LONG     size_before;     /* size before reorganizing */
LOCAL LONG     size_after;      /* size after reorganizing */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_open    _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_open      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    reorg_base    _((BASE *base, BYTE *basename, BYTE *basepath, BOOLEAN encode));
LOCAL BOOLEAN reorg_ind     _((BASE *base));
LOCAL BOOLEAN reorg_dat     _((BYTE *basename, BYTE *basepath, BOOLEAN encode));
LOCAL BOOLEAN do_reorg      _((BASE *base, DATAINF *data, BYTE *basename, BYTE *basepath, BYTE *tmpname, LONG length));
LOCAL BOOLEAN do_read       _((BASE *base, DATAINF *data, WORD table, LONG address, VOID *buffer, LONG size));
LOCAL BOOL    insert_blobs  _((BASE *base, DATAINF *data, WORD table, HPVOID buffer));
LOCAL WORD    ask_mode      _((BYTE *basename, WORD def_mode, BOOLEAN flags_enabled, BOOLEAN ind_enabled, BOOLEAN encode_on, WORD *mode, BOOLEAN *encode));
LOCAL VOID    click_askmode _((WINDOWP window, MKINFO *mk));
LOCAL VOID    draw_number   _((LONG number, WORD obj));
LOCAL VOID    draw_string   _((BYTE *s, WORD obj));

/*****************************************************************************/

GLOBAL BOOLEAN init_reorg ()

{
  return (TRUE);
} /* init_reorg */

/*****************************************************************************/

GLOBAL BOOLEAN term_reorg ()

{
  return (TRUE);
} /* term_reorg */

/*****************************************************************************/

GLOBAL VOID reorganizer (dbs)
DB_SPEC *dbs;

{
  WINDOWP  window;
  WORD     ret, w, i;
  BYTE     *p;
  LONG     maxmem;
  FILENAME basename;
  FULLNAME basepath;
  EXT      ext;

  strcpy (filename, (dbs != NULL) ? dbs->filename : open_name);

  if ((dbs != NULL) || (get_open_filename (FREORGDB, NULL, 0L, FFILTER_DAT, NULL, open_path, FDATSUFF, filename, open_name)))
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
      window = crt_dialog (opendb, NULL, OPENDB, FREETXT (FREORGDB), WI_MODAL);
    } /* if */

    if (window != NULL)
    {
      window->click = click_open;
      window->key   = key_open;
      strcpy (window->name, FREETXT (FREORGDB));

      if (window->opened == 0)
      {
        window->edit_obj     = find_flags (opendb, ROOT, EDITABLE);
        window->edit_inx     = NIL;
        edit_inx             = 0;

        if (dbs != NULL)
        {
          strcpy (opencfg.username, dbs->username);
          strcpy (opencfg.password, dbs->password);
          opencfg.treecache = dbs->treecache;
          opencfg.datacache = dbs->datacache;
          opencfg.cursors   = dbs->num_cursors;
        } /* if */
        else
        {
          opencfg.password [0] = EOS;

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
        } /* else */

        opencfg.rdonly    = FALSE;
        opencfg.mode      = BSINGLE;
        opencfg.treeflush = FALSE;
        opencfg.dataflush = FALSE;

        do_state (opendb, BRDONLY, DISABLED);
        do_state (opendb, BMULTASK, DISABLED);
        do_state (opendb, BMULUSER, DISABLED);

        p = get_str (opendb, BBASE);
        w = opendb [BBASE].ob_width / gl_wbox;
        strncpy (p, filename, w);
        p [w]  = EOS;
        p      = strrchr (p, SUFFSEP);
        if (p != NULL) *p = EOS;

        set_opencfg ();
        undo_state (opendb, BOK, DISABLED);
      } /* if */

      if (! open_dialog (OPENDB)) hndl_alert (ERR_NOOPEN);

      undo_state (opendb, BRDONLY, DISABLED);
      undo_state (opendb, BMULTASK, DISABLED);
      undo_state (opendb, BMULUSER, DISABLED);
    } /* if */
  } /* if */
} /* reorganizer */

/*****************************************************************************/

LOCAL VOID click_open (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  UWORD    flags;
  WORD     result, button, ret, mode;
  BOOLEAN  encode;
  FULLNAME basepath;
  FILENAME basename;
  EXT      ext;
  BASE     *base;
  RECT     r;
  BYTE     *name;

  switch (window->exit_obj)
  {
    case BPASS : edit_inx = window->edit_inx;
                 break;
    case BOK   : get_opencfg ();                /* get parameters from box */
                 file_split (filename, NULL, basepath, basename, ext);

                 busy_mouse ();

                 ret  = loaddb [LOADNAME].ob_width / gl_wbox;
                 name = get_str (loaddb, LOADNAME);
                 strncpy (name, basepath, ret);
                 name [ret] = EOS;
                 strncat (name, basename, ret);
                 name [ret] = EOS;

                 opendial (loaddb, FALSE, NULL, NULL, NULL);
                 form_center (loaddb, &r.x, &r.y, &r.w, &r.h);
                 objc_draw (loaddb, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h);

                 flags   = (opencfg.treeflush) ? TREE_FLUSH : 0;
                 flags  |= (opencfg.dataflush) ? DATA_FLUSH : 0;
                 base    = db_open_cache (basename, basepath, flags | BASE_SUPER, opencfg.datacache, opencfg.treecache, opencfg.cursors, opencfg.username, opencfg.password);
                 result  = db_status (base);

                 closedial (loaddb, FALSE, NULL, NULL, NULL);
                 arrow_mouse ();
                 set_meminfo ();

                 if (result == DB_NOMEMORY) result = ERR_NOMEMRETRY;

                 if (result == SUCCESS)
                 {
                   ret = ask_mode (basename, (base->datainf->page0.reorg) ? REORGIND : REORGDAT, FALSE, base->datainf->page0.reorg, base->datainf->page0.flags & DATA_ENCODE, &mode, &encode);

                   if (ret == REORGCAN)
                     db_close (base);
                   else
                     if (mode == REORGIND)
                     {
                       close_window (window);
                       reorg_base (base, basename, basepath, encode);
                       db_close (base);
                     } /* if */
                     else       /* REORGDAT */
                     {
                       db_close (base);
                       close_window (window);
                       reorg_base (NULL, basename, basepath, encode);
                     } /* else, else */

                   set_meminfo ();
                 } /* if */
                 else
                 {
                   if ((result == DB_DNOTCLOSED) || (result == DB_TNOOPEN) || (result == DB_TRDPAGE))
                   {
                     ret = ask_mode (basename, REORGDAT, (result == DB_DNOTCLOSED), FALSE, (base != NULL) && (base->datainf->page0.flags & DATA_ENCODE), &mode, &encode);

                     if (ret == REORGOK)
                       if (mode == REORGFLG)
                       {
                         if (hndl_alert (ERR_RESETFLAGS) == 1)
                         {
                           base->datainf->page0.locking      = 0;
                           base->datainf->page0.opened       = 1;       /* will be zero'd on close */
                           base->datainf->page0.multi_locked = 0;
                         } /* if */
                       } /* if */
                       else
                       {
                         if (base != NULL) db_close (base);
                         close_window (window);
                         reorg_base (NULL, basename, basepath, encode);
                         base = NULL;
                       } /* else, if */

                     if (base != NULL) db_close (base);
                     set_meminfo ();
                   } /* if */
                   else
                     if ((result == DB_CPASSWORD) || (result == ERR_NOMEMRETRY))
                     {
                       if (result == DB_CPASSWORD) set_cursor (window, BUSER, NIL);
                       if (result == ERR_NOMEMRETRY) set_cursor (window, BINDCACH, NIL);
                       button = dberror (basename, result);

                       if (button == 1)
                       {
                         window->flags &= ~ WI_DLCLOSE;         /* don't close window */
                         undo_state (window->object, window->exit_obj, SELECTED);
                         draw_object (window, window->exit_obj);
                       } /* if */
                     } /* if */
                     else
                       dberror (basename, (result == DB_DNOLOCK) ? result : ERR_WRONGDB);
                 } /* else */
                 break;
    case BHELP : hndl_help (HREORGDB);
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

LOCAL VOID reorg_base (base, basename, basepath, encode)
BASE    *base;
BYTE    *basename, *basepath;
BOOLEAN encode;

{
  BOOLEAN  mode, ok;
  RECT     r;
  MFDB     screen, buffer;
  WINDOWP  window;
  WORD     ret;
  FILENAME base_filename;

  busy_mouse ();

  mode = set_alert (TRUE);

  strcpy (base_filename, base_filename);
  text_default (vdi_handle);
  form_center (sorting, &r.x, &r.y, &r.w, &r.h);
  set_ob_spec (sorting, SORTDB, (LONG)base_filename);
  do_flags (sorting, SORTNAME, HIDETREE);

  set_word (sorting, SORTPASS, 1);
  strcpy (get_str (sorting, SORTTBL), "");
  strcpy (get_str (sorting, SORTREC), "");
  strcpy (get_str (sorting, SORTRECS), "");

  opendial (sorting, TRUE, NULL, &screen, &buffer);
  objc_draw (sorting, ROOT, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);

  ok = (base != NULL) ? reorg_ind (base) : reorg_dat (basename, basepath, encode);

  closedial (sorting, TRUE, NULL, &screen, &buffer);
  undo_flags (sorting, SORTNAME, HIDETREE);
  set_alert (mode);
  arrow_mouse ();

  if (ok && (base == NULL))     /* show statistics */
  {
    window = search_window (CLASS_DIALOG, SRCH_ANY, STATIST);

    if (window == NULL)
    {
      form_center (statist, &ret, &ret, &ret, &ret);
      window = crt_dialog (statist, NULL, STATIST, FREETXT (FREORGST), WI_MODAL);
    } /* if */

    set_ob_spec (statist, STATNAME, (LONG)basename);
    set_long (statist, STATALL, all_recs);
    set_long (statist, STATLOST, lost_recs);
    set_long (statist, STATDEL, del_recs);
    sprintf (get_str (statist, STATBEFO), "%5ld KB", size_before / 1024);
    sprintf (get_str (statist, STATAFTE), "%5ld KB", size_after / 1024);
    sprintf (get_str (statist, STATGAIN), "%5ld KB", size_before / 1024 - size_after / 1024);
    sprintf (get_str (statist, STATPERC), "(%d%%)", (INT)((size_before - size_after) * 100 / size_before));

    if (window != NULL)
      if (! open_dialog (STATIST))
      {
        delete_window (window);
        statist->ob_spec = (dlg_colors < 16) ? 0x00021100L : 0x00011170L | sys_colors [COLOR_DIALOG];
        hndl_dial (statist, 0, FALSE, TRUE, NULL, &ok);
        statist->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
      } /* if, if */
  } /* if */
} /* reorg_base */

/*****************************************************************************/

LOCAL BOOLEAN reorg_ind (base)
BASE *base;

{
  BOOLEAN  ok;
  WORD     table, tbl, inx;
  LONG     rec;
  SYSTABLE *systable;
  SYSINDEX *sysindex;
  VOID     *buffer;
  CURSOR   cursor;

  ok = TRUE;

  for (tbl = 0, systable = base->systable, sysindex = base->sysindex; tbl < base->systbls; tbl++, systable++)
    for (inx = 0; inx < systable->indexes; inx++, sysindex++)
      if ((systable->recs > 0) && (sysindex->num_keys == 0)) sysindex->flags |= INX_REORG;

  for (tbl = 0, systable = base->systable, sysindex = base->sysindex; ok && (tbl < base->systbls); tbl++, systable++)
  {
    for (inx = 0, table = FAILURE; ok && (inx < systable->indexes); inx++, sysindex++)
      if (sysindex->flags & INX_REORG) table = tbl;

    if (esc_pressed ())
      ok = FALSE;
    else
      if (table != FAILURE)
      {
        rec = 0;
        draw_string (systable->name, SORTTBL);
        draw_number (rec, SORTREC);
        draw_number (systable->recs, SORTRECS);

        buffer = mem_alloc (systable->size);
        ok     = buffer != NULL;

        if (! ok)
          hndl_alert (ERR_NOMEMORY);
        else
        {
          ok = db_initcursor (base, table, 0, ASCENDING, &cursor);

          if (! ok)
            dberror (base->basename, db_status (base));
          else
            while (ok && db_movecursor (base, &cursor, 1L))
            {
              if (++rec % STEPS == 0)
                draw_number (rec, SORTREC);

              ok = db_read (base, table, buffer, &cursor, 0L, FALSE);

              if (! ok)
                dberror (base->basename, db_status (base));
              else
              {
                ok = db_reorgtree (base, table, buffer);
                if (! ok) dberror (base->basename, db_status (base));
              } /* else */
            } /* while, else */

          draw_number (rec, SORTREC);

          mem_free (buffer);
        } /* else */
      } /* if, else */
  } /* for */

  for (inx = 0, sysindex = base->sysindex; inx < base->sysinxs; inx++, sysindex++)
    sysindex->flags &= ~ INX_REORG;

  if (ok) base->datainf->page0.reorg = FALSE;

  return (ok);
} /* reorg_ind */

/*****************************************************************************/

LOCAL BOOLEAN reorg_dat (basename, basepath, encode)
BYTE    *basename, *basepath;
BOOLEAN encode;

{
  BOOLEAN  ok;
  DATAINF  *data;
  BASE     *base;
  FULLNAME datname, indname, tmpdat, tmpind, save, path;
  FILENAME tmpname;
  EXT      ext;
  UWORD    flags;

  strcpy (datname, basepath);
  strcat (datname, basename);
  strcpy (indname, datname);
  strcat (datname, FREETXT (FDATSUFF) + 1);
  strcat (indname, FREETXT (FINDSUFF) + 1);
  draw_string (basename, SORTDB);

  data = open_data (datname, 0, 0L);
  ok   = data != NULL;

  if (! ok)
    dberror (basename, db_status (NULL));
  else
  {
    strcpy (save, tmpdir);      /* save old temp directory */
    strcpy (tmpdir, basepath);  /* make a temporary file on basepath */
    file_split (temp_name (NULL), NULL, path, tmpname, ext);
    strcpy (tmpdir, save);      /* restore old temp directory */

    flags = data->page0.flags & ~ BASE_ENCODE;
    if (encode) flags |= BASE_ENCODE;

    base  = db_create (tmpname, basepath, flags | BASE_SUPER, DATASIZE, TREESIZE);
    ok    = base != NULL;

    if (! ok)
      dberror (tmpname, db_status (base));
    else
    {
      db_close (base);
      flags  = (opencfg.treeflush) ? TREE_FLUSH : 0;
      flags |= (opencfg.dataflush) ? DATA_FLUSH : 0;
      base   = db_open_cache (tmpname, basepath, flags | BASE_SUPER, opencfg.datacache, opencfg.treecache, opencfg.cursors, opencfg.username, opencfg.password);
      ok     = base != NULL;

      if (! ok)
        dberror (tmpname, db_status (base));
      else
      {
        ok = do_reorg (base, data, basename, basepath, tmpname, file_length (datname));
      } /* else */
    } /* else */

    close_data (data);

    strcpy (tmpind, basepath);
    strcat (tmpind, tmpname);
    strcpy (tmpdat, tmpind);
    strcat (tmpind, FREETXT (FINDSUFF) + 1);
    strcat (tmpdat, FREETXT (FDATSUFF) + 1);

    if (ok)
    {
      file_remove (datname);
      file_remove (indname);

      file_rename (tmpind, indname);
      file_rename (tmpdat, datname);
    } /* if */
    else
    {
      file_remove (tmpdat);
      file_remove (tmpind);
    } /* else */
  } /* else */

  return (ok);
} /* reorg_dat */

/*****************************************************************************/

LOCAL BOOLEAN do_reorg (base, data, basename, basepath, tmpname, length)
BASE    *base;
DATAINF *data;
BYTE    *basename, *basepath, *tmpname;
LONG    length;

{
  BOOLEAN    ok, ready, user, superuser, deleted, moved;
  WORD       table, i, prev, status;
  WORD       tbl, col, inx, rel, form;
  WORD       error, x, y;
  UWORD      flags;
  LONG       address, size, inc, rec, recs, maxrecs, relrecs;
  SYSTABLE   systable [SYS_FORMAT + 1];
  SYSTABLE   *tblp;
  SYSCOLUMN  *colp;
  SYSINDEX   *inxp;
  SYSREL     *relp;
  SYSUSER    sysuser;
  SYSDELETED sysdeleted;
  SYSFORMAT  *formp;
  FORMAT     *formatp;
  VOID       *buffer;

  address                      = FIRST_REC;
  base->datainf->page0.created = data->page0.created;
  base->datainf->page0.lastuse = data->page0.lastuse;

  mem_move (base->datainf->page0.tbl_ascii, data->page0.tbl_ascii, (UWORD)sizeof (data->page0.tbl_ascii));
  mem_set (&sysuser, 0, sizeof (SYSUSER));      /* delete username and password */

  rec  = 0;
  recs = SYS_FORMAT + 1;

  if (esc_pressed ()) return (FALSE);
  draw_number (2L, SORTPASS);
  draw_number (rec, SORTREC);
  draw_number (recs, SORTRECS);

  for (i = SYS_TABLE, ok = TRUE; (i <= SYS_FORMAT) && ok; i++)
  {
    size = read_data (data, address, NULL, &table, &inc, NULL, NULL, NULL);
    ok   = size != 0;

    draw_string (base->systable [table].name, SORTTBL);
    draw_number (++rec, SORTREC);

    if (ok)
    {
      systable [i].address = address;

      ok       = do_read (base, data, table, address, &systable [i], size);
      address += inc;
    } /* if */
  } /* for */

  if (! ok)
    dberror (basename, get_dberror ());
  else
  {
    tblp    = mem_alloc (systable [SYS_TABLE].recs * sizeof (SYSTABLE));
    colp    = mem_alloc (systable [SYS_COLUMN].recs * sizeof (SYSCOLUMN));
    inxp    = mem_alloc (systable [SYS_INDEX].recs * sizeof (SYSINDEX));
    relp    = mem_alloc (systable [SYS_REL].recs * sizeof (SYSREL));
    formp   = mem_alloc (systable [SYS_FORMAT].recs * sizeof (SYSFORMAT));
    formatp = mem_alloc (systable [SYS_FORMAT].recs * sizeof (FORMAT));
    ok    = (tblp != NULL) && (colp != NULL) && (inxp != NULL) && (relp != NULL) && (formp != NULL) && (formatp != NULL);

    if (! ok)
      hndl_alert (ERR_NOMEMORY);
    else
    {
      address = FIRST_REC;
      tbl     = col = inx = rel = form = 0;
      ready   = superuser = FALSE;
      table   = FAILURE;
      user    = systable [SYS_USER].recs == 0;
      rec     = 0;
      recs    = systable [SYS_TABLE].recs +
                systable [SYS_COLUMN].recs +
                systable [SYS_INDEX].recs +
                systable [SYS_REL].recs +
                systable [SYS_FORMAT].recs + (user ? 0 : 1);

      if (esc_pressed ()) ok = FALSE;

      draw_number (3L, SORTPASS);
      draw_string ("", SORTTBL);
      draw_number (rec, SORTREC);
      draw_number (recs, SORTRECS);

      while (ok && ! ready) /* read important part of data dictionary */
      {
        prev = table;
        size = read_data (data, address, NULL, &table, &inc, NULL, &deleted, &moved);
        ok   = size != 0;

        if (! ok)
        {
          if (get_dberror () == SUCCESS)  /* only zero's read */
            ok = ready = TRUE;
        } /* if */
        else
        {
          if (prev != table)
            if (table < NUM_SYSTABLES)
              draw_string (base->systable [table].name, SORTTBL);
            else
              draw_string (tblp [table].name, SORTTBL);

          if (! (deleted || moved))
            switch (table)
            {
              case SYS_TABLE  : draw_number (++rec, SORTREC);
                                ok = do_read (base, data, table, address, &tblp [tbl++], size);
                                break;
              case SYS_COLUMN : draw_number (++rec, SORTREC);
                                ok = do_read (base, data, table, address, &colp [col++], size);
                                break;
              case SYS_INDEX  : draw_number (++rec, SORTREC);
                                ok = do_read (base, data, table, address, &inxp [inx++], size);
                                break;
              case SYS_REL    : draw_number (++rec, SORTREC);
                                ok = do_read (base, data, table, address, &relp [rel++], size);
                                break;
              case SYS_USER   : if (! user)
                                {
                                  draw_number (++rec, SORTREC);

                                  user = superuser = TRUE;
                                  ok   = do_read (base, data, table, address, &sysuser, size);
                                } /* if */
                                break;
              case SYS_FORMAT : draw_number (++rec, SORTREC);
                                ok = do_read (base, data, table, address, &formp [form], size);
                                build_format (formp [form].type, formp [form].format, formatp [form]);
                                form++;
                                break;
            } /* switch, if */

          address += inc;

          if ((address >= length) || (rec == recs)) ready = TRUE;
        } /* else */
      } /* while */

      if (! ok)
      {
        if (get_dberror () != SUCCESS) dberror (basename, get_dberror ()); /* ERR_SUPERUSER => SUCCESS == TRUE */
      } /* if */
      else
      {
        rec      = 0;
        recs     = systable [SYS_TABLE ].recs - base->systable [SYS_TABLE ].recs +
                   systable [SYS_COLUMN].recs - base->systable [SYS_COLUMN].recs +
                   systable [SYS_INDEX ].recs - base->systable [SYS_INDEX ].recs +
                   systable [SYS_REL   ].recs - base->systable [SYS_REL   ].recs + (superuser ? 1 : 0);
        all_recs = recs;

        if (esc_pressed ()) ok = FALSE;

        draw_number (4L, SORTPASS);
        draw_string (tblp [SYS_TABLE].name, SORTTBL);
        draw_number (rec, SORTREC);
        draw_number (recs, SORTRECS);

        for (i = SYS_USER, maxrecs = 0; i < systable [SYS_TABLE].recs; i++)
          if ((i != SYS_DELETED) && (i != SYS_BLOB))
            maxrecs += tblp [i].recs;

        if (superuser) maxrecs--;

        for (i = 0; ok && (i < systable [SYS_TABLE].recs); i++)
          if (tblp [i].table >= NUM_SYSTABLES) /* insert user tables only */
          {
            draw_number (++rec, SORTREC);
            tblp [i].recs   = 0;
            tblp [i].flags |= GRANT_ALL;       /* compensate former error */
            ok = db_insert (base, SYS_TABLE, &tblp [i], &status);
          } /* if, for */

        if (ok) draw_string (tblp [SYS_COLUMN].name, SORTTBL);

        for (i = 0; ok && (i < systable [SYS_COLUMN].recs); i++)
          if (colp [i].table >= NUM_SYSTABLES) /* insert user columns only */
          {
            if (colp [i].number == 0) strcpy (colp [i].name, "DbAddress");      	 /* former "Address" field */
            draw_number (++rec, SORTREC);
            ok = db_insert (base, SYS_COLUMN, &colp [i], &status);
          } /* if, for */

        if (ok) draw_string (tblp [SYS_INDEX].name, SORTTBL);

        for (i = 0; ok && (i < systable [SYS_INDEX].recs); i++)
          if (inxp [i].table >= NUM_SYSTABLES) /* insert user indexes only */
          {
            draw_number (++rec, SORTREC);
            inxp [i].root     = 0;
            inxp [i].num_keys = 0;
            ok = db_insert (base, SYS_INDEX, &inxp [i], &status);
          } /* if, for */

        if (ok) draw_string (tblp [SYS_REL].name, SORTTBL);

        for (i = (WORD)base->systable [SYS_REL].recs; ok && (i < systable [SYS_REL].recs); i++)
        {
          draw_number (++rec, SORTREC);
          ok = db_insert (base, SYS_REL, &relp [i], &status);
        } /* for */

        if (ok) draw_string (tblp [SYS_USER].name, SORTTBL);

        if (superuser)
        {
          draw_number (++rec, SORTREC);
          ok = db_insert (base, SYS_USER, &sysuser, &status);
        } /* for */

        if (! ok)
        {
          if (db_status (base) != SUCCESS) dberror (base->basename, db_status (base));
        } /* if */
        else
        {
          mem_free (tblp);      /* don't need it anymore */
          mem_free (colp);
          mem_free (inxp);
          mem_free (relp);

          tblp      = NULL;
          colp      = NULL;
          inxp      = NULL;
          relp      = NULL;
          address   = FIRST_REC;
          ready     = FALSE;
          table     = FAILURE;
          lost_recs = del_recs = 0;
          rec       = 0;
          recs      = maxrecs;

          draw_number (5L, SORTPASS);
          draw_string ("", SORTTBL);
          draw_number (rec, SORTREC);
          draw_number (recs, SORTRECS);

          db_close (base);
          build_pass (sysuser.pass, sysuser.pass);
          flags  = (opencfg.treeflush) ? TREE_FLUSH : 0;
          flags |= (opencfg.dataflush) ? DATA_FLUSH : 0;
          base   = db_open_cache (tmpname, basepath, flags | BASE_SUPER, opencfg.datacache, opencfg.treecache, opencfg.cursors, sysuser.name, sysuser.pass);
          ok     = base != NULL;

          if (! ok)
            dberror (tmpname, db_status (base));
          else
          {
            if (esc_pressed ()) ok = FALSE;

            relrecs = base->systable [SYS_REL].recs;
            base->systable [SYS_REL].recs = 0; /* no insert rules please */

            while (ok && ! ready)
            {
              prev = table;
              size = read_data (data, address, NULL, &table, &inc, NULL, &deleted, &moved);
              ok   = size != 0;

              if (! ok)
              {
                if (get_dberror () == SUCCESS)  /* only zero's read */
                  ready = TRUE;
                else
                  lost_recs++;

                ok = TRUE;      /* please continue */
              } /* if */
              else
              {
                if (prev != table)
                  draw_string (base->systable [table].name, SORTTBL);

                if (table == SYS_DELETED)
                  if (do_read (base, data, table, address, &sysdeleted, size))
                    if ((sysdeleted.table >= NUM_SYSTABLES) || (sysdeleted.table == SYS_CALC) || (sysdeleted.table == SYS_QUERY) || (sysdeleted.table == SYS_REPORT) || (sysdeleted.table == SYS_BATCH) || (sysdeleted.table == SYS_ACCOUNT) || (sysdeleted.table == SYS_PICTURE))
                      del_recs++;

                if (! (deleted || moved) && (table > SYS_REL) && (table != SYS_DELETED) && ((table != SYS_USER) || ! superuser) && (table != SYS_BLOB))
                {
                  if (++rec % 10 == 0)
                    draw_number (rec, SORTREC);

                  buffer = mem_alloc (base->systable [table].size);
                  ok     = buffer != NULL;

                  if (! ok)
                    hndl_alert (ERR_NOMEMORY);
                  else
                  {
                    ok = do_read (base, data, table, address, buffer, size);

                    if (! ok)
                      if (get_dberror () == DB_NOMEMORY)
                        dberror (basename, get_dberror ());
                      else
                      {
                        lost_recs++;
                        ok = TRUE;      /* please continue */
                      } /* else, if */
                    else
                    {
                      if (table == SYS_CALC)
                      {
                        SYSCALC    *syscalc;
                        TABLE_INFO ti;
                        WORD       calc_table;

                        syscalc = (SYSCALC *)buffer;
                        strcpy (ti.name, syscalc->tablename);
                        calc_table = db_tableinfo (base, FAILURE, &ti);

                        if (calc_table == FAILURE)
                          error = DB_CNOTABLE;
                        else
                          error = db_compile (base, calc_table , buffer, &y, &x, formatp);

                        if (error != SUCCESS)
                        {
                        } /* if */
                      } /* if */

                      if (table == SYS_MASK)                            /* sorry, we have something to patch */
                      {
                        SYSMASK *sysmask = (SYSMASK *)buffer;
                        
                        if (data->page0.version <= 0x0100)              /* from version 1.0 to 1.1 */
                          sysmask->flags |= 0x0001; /* = SM_STDBUTTONS */
                      } /* if */

#if GEMDOS
                      if (table == SYS_ICON)                            /* sorry, we have something to patch */
                      {
                        SYSICON *sysicon = (SYSICON *)buffer;

                        sysicon->bitmap.size = 0;                       /* bitmap has not been appended but inserted before flags */
                        sysicon->flags       = 0x0000;
                      } /* if */
#endif

                      all_recs++;
                      ok = insert_blobs (base, data, table, buffer);

                      if (ok) ok = db_insert (base, table, buffer, &status);

                      if (! ok) ok = integrity (base, table, status);
                    } /* else */

                    mem_free (buffer);
                  } /* else */
                } /* if */

                if ((table == SYS_USER) && ! deleted)
                  superuser = FALSE;                                    /* superuser has already been inserted */
              } /* else */

              address += inc;
              if (address >= length) ready = TRUE;

              if (rec % 100 == 0)
                if (esc_pressed ())
                  ok = FALSE;
            } /* while */

            draw_number (rec, SORTREC);

            base->systable [SYS_REL].recs = relrecs;
            size_before  = address;
            size_after   = base->datainf->page0.next_rec;
            lost_recs   += recs - rec;
          } /* else */
        } /* else */
      } /* else */
    } /* else */

    mem_free (tblp);
    mem_free (colp);
    mem_free (inxp);
    mem_free (relp);
    mem_free (formp);
    mem_free (formatp);
  } /* else */

  if (base != NULL) db_close (base);
  return (ok);
} /* do_reorg */

/*****************************************************************************/

LOCAL BOOLEAN do_read (base, data, table, address, buffer, size)
BASE    *base;
DATAINF *data;
WORD    table;
LONG    address;
VOID    *buffer;
LONG    size;

{
  BOOLEAN ok;
  VOID    *packbuf;

  packbuf = mem_alloc (size);
  ok      = packbuf != NULL;

  if (! ok)
    set_dberror (DB_NOMEMORY); /* force caller to think it's a db error */
  else
  {
    size = read_data (data, address, packbuf, NULL, NULL, NULL, NULL, NULL);
    ok   = size != 0;

    if ((data->page0.version < 0x0200) && (table == SYS_ICON))	/* bitmap is inserted before flags */
      size -= sizeof (WORD);

    if (ok) db_unpack (base, table, buffer, packbuf, size);

    mem_free (packbuf);
  } /* else */

  return (ok);
} /* do_read */

/*****************************************************************************/

LOCAL BOOL insert_blobs  (BASE *base, DATAINF *data, WORD table, HPVOID buffer)
{
  BOOL       bOk;
  SHORT      i, sStatus;
  TABLE_INFO ti;
  FIELD_INFO fi;
  HPBLOB     hpBlob;
  SYSBLOB    *pSysBlob;
  LONG       lSize;

  db_tableinfo (base, table, &ti);

  for (i = 0, bOk = TRUE; (i < ti.cols) && bOk; i++)
  {
    db_fieldinfo (base, table, i, &fi);

    if (fi.type == TYPE_BLOB)
    {
      hpBlob = (HPBLOB)((HPCHAR)buffer + fi.addr);

      if (hpBlob->address != 0)		/* blob assigned at least once */
      {
        lSize  = read_data (data, hpBlob->address, NULL, NULL, NULL, NULL, NULL, NULL);
        bOk    = lSize != 0;

        if (bOk)
        {
	  pSysBlob = (SYSBLOB *)mem_alloc (lSize + sizeof (LONG));	/* LONG for the address */
          bOk      = pSysBlob != NULL;

          if (! bOk)
            set_dberror (DB_NOMEMORY);
          else
          {
	    lSize = read_data (data, hpBlob->address, &pSysBlob->size, NULL, NULL, NULL, NULL, NULL);
            bOk   = lSize != 0;

            if (bOk) bOk = db_insert (base, SYS_BLOB, pSysBlob, &sStatus);

            hpBlob->address = bOk ? pSysBlob->address : 0;

            mem_free (pSysBlob);
          } /* else */
        } /* if */
      } /* if */
    } /* if */
  } /* for */

  return (bOk);
} /* insert_blobs */

/*****************************************************************************/

LOCAL WORD ask_mode (basename, def_mode, flags_enabled, ind_enabled, encode_on, mode, encode)
BYTE    *basename;
WORD    def_mode;
BOOLEAN flags_enabled, ind_enabled, encode_on;
WORD    *mode;
BOOLEAN *encode;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, REORGPAR);

  if (window == NULL)
  {
    form_center (reorgpar, &ret, &ret, &ret, &ret);
    window = crt_dialog (reorgpar, NULL, REORGPAR, FREETXT (FREORGPA), WI_MODAL);

    if (window != NULL) window->click = click_askmode;
  } /* if */

  if (window != NULL)
  {
    set_ob_spec (reorgpar, REORGDB, (LONG)basename);
    set_rbutton (reorgpar, def_mode, REORGFLG, REORGDAT);

    if (! flags_enabled)
      do_state (reorgpar, REORGFLG, DISABLED);

    if (! ind_enabled)
      do_state (reorgpar, REORGIND, DISABLED);

    set_checkbox (reorgpar, REORGCRY, encode_on);

    if (is_state (reorgpar, REORGDAT, SELECTED))
      undo_state (reorgpar, REORGCRY, DISABLED);
    else
      do_state (reorgpar, REORGCRY, DISABLED);

    if (! open_dialog (REORGPAR)) hndl_alert (ERR_NOOPEN);

    undo_state (reorgpar, REORGFLG, DISABLED);
    undo_state (reorgpar, REORGIND, DISABLED);
  } /* if */

  *mode   = askmode;
  *encode = askencode;

  return (askret);
} /* ask_mode */

/*****************************************************************************/

LOCAL VOID click_askmode (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if ((REORGFLG <= window->exit_obj) && (window->exit_obj < REORGOK))
    if (mk->breturn == 2)
    {
      window->exit_obj  = REORGOK;
      window->flags    |= WI_DLCLOSE;
    } /* if, if */

  askret = window->exit_obj;

  switch (window->exit_obj)
  {
    case REORGOK  : askmode   = get_rbutton (reorgpar, REORGFLG);
                    askencode = get_checkbox (reorgpar, REORGCRY);
                    break;
    case REORGCAN : askmode = NIL;
                    break;
    case REORGHLP : hndl_help (HREORGPA);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  if ((get_rbutton (reorgpar, REORGFLG) == REORGDAT) == is_state (reorgpar, REORGCRY, DISABLED))
  {
    flip_state (reorgpar, REORGCRY, DISABLED);
    draw_object (window, REORGCRY);
  } /* if */
} /* click_askmode */

/*****************************************************************************/

LOCAL VOID draw_number (number, obj)
LONG number;
WORD obj;

{
  STRING s;
  RECT   r;

  sprintf (s, "%ld", number);
  objc_rect (sorting, obj, &r, FALSE);
  set_str (sorting, obj, s);
  objc_draw (sorting, obj, MAX_DEPTH, r.x, r.y, r.w, r.h);
} /* draw_number */

/*****************************************************************************/

LOCAL VOID draw_string (s, obj)
BYTE *s;
WORD obj;

{
  RECT r;

  objc_rect (sorting, obj, &r, FALSE);
  set_str (sorting, obj, s);
  objc_draw (sorting, obj, MAX_DEPTH, r.x, r.y, r.w, r.h);
} /* draw_string */

/*****************************************************************************/

