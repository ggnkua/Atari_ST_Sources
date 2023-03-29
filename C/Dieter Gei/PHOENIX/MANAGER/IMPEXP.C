/*****************************************************************************
 *
 * Module : IMPEXP.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the import/export proxess.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 08.10.95: Import and export of BLOBs added
 * 17.07.95: Extra parameter added in calling v_execute
 * 31.01.95; Using of variable warn_table added
 * 16.11.93: Using new file selector
 * 28.09.93: Import/Export problem with date/time format fixed
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
#include "mimpexp.h"
#include "process.h"
#include "resource.h"

#include "export.h"
#include "impexp.h"

/****** DEFINES **************************************************************/

#define DAYOFFSET       693975L         /* days since 01.01.1900 */
#define MAX_BUFFER	4096		/* buffer for reading from file */
#define REPLACE_CHAR	'~'		/* replace character for cr/lf */
#define MAX_RDIGITS	20		/* max number of blanks to fill in floating point number */

/****** TYPES ****************************************************************/

typedef struct
{
  LONG  lInx;				/* index into buffer */
  LONG  lSize;				/* number of valid chars in buffer */
  CHAR  achBuffer [MAX_BUFFER];		/* buffer of chars from file */
  LONG  lRecSize;			/* size of one record */
} WORK_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN work_import    _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_import    _((PROC_INF *proc_inf));
LOCAL BOOLEAN import_ascii   _((PROC_INF *proc_inf));
LOCAL BOOLEAN import_binary  _((PROC_INF *proc_inf));
LOCAL WORD    read_field     _((PROC_INF *proc_inf, BYTE *colsep, BYTE *txtsep, WORD type, LONG size, BYTE *s));
LOCAL WORD    read_bytes     _((PROC_INF *proc_inf, BYTE *colsep, WORD type, LONG size, BYTE *buffer));

LOCAL BOOLEAN work_export    _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_export    _((PROC_INF *proc_inf));
LOCAL BOOLEAN export_ascii   _((PROC_INF *proc_inf));
LOCAL BOOLEAN export_binary  _((PROC_INF *proc_inf, WORD table, BYTE *buffer));

LOCAL LONG    pack           _((BASE *base, WORD table, VOID *buffer, VOID *packbuf, WORD cols, WORD *columns));
LOCAL LONG    unpack         _((BASE *base, WORD table, VOID *buffer, VOID *packbuf, LONG packsize, WORD cols, WORD *columns));

LOCAL BOOLEAN read_byte      _((PROC_INF *proc_inf, BYTE *pBuffer));

/*****************************************************************************/

GLOBAL BOOLEAN init_impexp ()

{
  return (TRUE);
} /* init_impexp */

/*****************************************************************************/

GLOBAL BOOLEAN term_impexp ()

{
  return (TRUE);
} /* term_impexp */

/*****************************************************************************/

GLOBAL BOOLEAN imp_list (db, table, cols, columns, colwidth, filename, minimize)
DB      *db;
WORD    table, cols, *columns, *colwidth;
BYTE    *filename;
BOOLEAN minimize;

{
  WINDOWP    window;
  PROC_INF   proc_inf, *procp;
  BYTE       *title, *p;
  STRING     name;
  LONG       length;
  WORD       i;
  TABLE_INFO ti;
  FIELD_INFO fi;
  INDEX_INFO ii;
  WORD       asciiformat;
  EXT        ext;
  WORK_SPEC  *pWork;
  LONG       filter_index;

  table = rtable (table);       /* use physical tables only */

  if (! (db_acc_table (db->base, table) & GRANT_INSERT))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return (FALSE);
  } /* if */

  asciiformat       = (table < NUM_SYSTABLES) ? EXBINARY : impexpcfg.asciiformat;
  impexpcfg.primary = FAILURE;

  v_tableinfo (db, table, &ti);

  if (impexpcfg.mode == EXUPDATE)
  {
    for (i = 0; i < ti.indexes; i++)            /* calculate primary key */
    {
      v_indexinfo (db, table, i, &ii);
      if (ii.flags & INX_PRIMARY) impexpcfg.primary = i;
    } /* for */

    if (impexpcfg.primary == FAILURE)
      if (hndl_alert (ERR_NOPRIMARY) == 2) return (FALSE);
  } /* if */

  if ((filename != NULL) && (*filename != EOS))
    strcpy (proc_inf.filename, filename);
  else
  {
    p = FREETXT ((asciiformat == EXASCII) ? FASCSUFF : FBINSUFF);
    table_name (db, table, name);
    name [MAX_FILENAME - strlen (p + 1)] = EOS;
    strcat (name, p + 1);
    strcpy (proc_inf.filename, name);

    filter_index = (asciiformat == EXASCII) ? 0 : 1;

    if (! get_open_filename (FOPENIMP, NULL, 0L, FFILTER_ASC_BIN, &filter_index, exp_path, (asciiformat == EXASCII) ? FASCSUFF : FBINSUFF, proc_inf.filename, NULL))
      return (FALSE);
  } /* else */

  if (! chk_filenames (proc_inf.filename)) return (FALSE);

  if (table < NUM_SYSTABLES)
  {
    file_split (proc_inf.filename, NULL, NULL, NULL, ext);
    if (strcmp (ext, FREETXT (FASCSUFF) + 2) == 0) asciiformat = EXASCII;
  } /* if */

  if (asciiformat == EXASCII)
    for (i = 0; (i < cols); i++)				/* search for a BLOB */
    {
      db_fieldinfo (db->base, rtable (table), columns [i], &fi);

      if (fi.type == TYPE_BLOB)
      {
        hndl_alert (ERR_IMPEXPBLOB);
        asciiformat = EXBINARY;
        break;
      } /* if */
    } /* for, if */

  proc_inf.file = fopen (proc_inf.filename, READ_BIN);

  if (proc_inf.file == NULL)
  {
    file_error (ERR_FILEOPEN, proc_inf.filename);
    return (FALSE);
  } /* if */

  length = file_length (proc_inf.filename);

  proc_inf.db          = db;
  proc_inf.table       = table;
  proc_inf.inx         = FAILURE;
  proc_inf.dir         = 0;
  proc_inf.cols        = cols;
  proc_inf.columns     = columns;
  proc_inf.colwidth    = colwidth;
  proc_inf.cursor      = NULL;
  proc_inf.format      = 0;
  proc_inf.maxrecs     = 1;
  proc_inf.events_ps   = events_ps;
  proc_inf.recs_pe     = recs_pe;
  proc_inf.impexpcfg   = &impexpcfg;
  proc_inf.page_format = NULL;
  proc_inf.prncfg      = NULL;
  proc_inf.to_printer  = FALSE;
  proc_inf.binary      = FALSE;
  proc_inf.tmp         = FALSE;
  proc_inf.special     = 0;
  proc_inf.filelength  = length;
  proc_inf.workfunc    = work_import;
  proc_inf.stopfunc    = stop_import;

  title  = FREETXT (FPIMPORT);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, sizeof (WORK_SPEC), wi_modeless);

  if (window != NULL)
  {
    procp = (PROC_INF *)window->special;
    pWork = (WORK_SPEC *)procp->memory;

    pWork->lInx     = 0L;
    pWork->lSize    = 0L;
    pWork->lRecSize = ti.size;

    procp->impexpcfg->asciiformat = asciiformat;

    str2ucsd (impexpcfg.recsep, procp->impexpcfg->recsep);
    str2ucsd (impexpcfg.colsep, procp->impexpcfg->colsep);
    str2ucsd (impexpcfg.txtsep, procp->impexpcfg->txtsep);
    build_format (TYPE_DATE, get_str (imexparm, procp->impexpcfg->dateformat), procp->impexpcfg->format);

    start_process (window, minimize_process, TRUE);
  } /* if */

  return (TRUE);
} /* imp_list */

/*****************************************************************************/

GLOBAL BOOLEAN exp_list (db, table, inx, dir, cols, columns, colwidth, filename, minimize)
DB      *db;
WORD    table, inx, dir, cols, *columns, *colwidth;
BYTE    *filename;
BOOLEAN minimize;

{
  WINDOWP    window;
  LONG       numkeys;
  PROC_INF   proc_inf, *procp;
  BYTE       *title, *p;
  STRING     name;
  WORD       asciiformat, i;
  FIELD_INFO fi;
  EXT        ext;
  LONG       filter_index;

  numkeys = num_keys (db, table, inx);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return (FALSE);

  if (! (db_acc_table (db->base, rtable (table)) & GRANT_SELECT))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return (FALSE);
  } /* if */

  asciiformat = (rtable (table) < NUM_SYSTABLES) ? EXBINARY : impexpcfg.asciiformat;

  if ((filename != NULL) && (*filename != EOS))
    strcpy (proc_inf.filename, filename);
  else
  {
    p = FREETXT ((asciiformat == EXASCII) ? FASCSUFF : FBINSUFF);
    table_name (db, table, name);
    name [MAX_FILENAME - strlen (p + 1)] = EOS;
    strcat (name, p + 1);
    strcpy (proc_inf.filename, name);

    filter_index = (asciiformat == EXASCII) ? 0 : 1;

    if (! get_save_filename (FOPENEXP, NULL, 0L, FFILTER_ASC_BIN, &filter_index, exp_path, (asciiformat == EXASCII) ? FASCSUFF : FBINSUFF, proc_inf.filename, NULL))
      return (FALSE);
  } /* else */

  if (! chk_filenames (proc_inf.filename)) return (FALSE);

  if (rtable (table) < NUM_SYSTABLES)
  {
    file_split (proc_inf.filename, NULL, NULL, NULL, ext);
    if (strcmp (ext, FREETXT (FASCSUFF) + 2) == 0) asciiformat = EXASCII;
  } /* if */

  if (asciiformat == EXASCII)
    for (i = 0; (i < cols); i++)				/* search for a BLOB */
    {
      db_fieldinfo (db->base, rtable (table), columns [i], &fi);

      if (fi.type == TYPE_BLOB)
      {
        hndl_alert (ERR_IMPEXPBLOB);
        asciiformat = EXBINARY;
        break;
      } /* if */
    } /* for, if */

  proc_inf.db          = db;
  proc_inf.table       = table;
  proc_inf.inx         = inx;
  proc_inf.dir         = dir;
  proc_inf.cols        = cols;
  proc_inf.columns     = columns;
  proc_inf.colwidth    = colwidth;
  proc_inf.cursor      = db_newcursor (db->base);
  proc_inf.format      = 0;
  proc_inf.maxrecs     = numkeys;
  proc_inf.events_ps   = events_ps;
  proc_inf.recs_pe     = recs_pe;
  proc_inf.impexpcfg   = &impexpcfg;
  proc_inf.page_format = NULL;
  proc_inf.prncfg      = NULL;
  proc_inf.to_printer  = FALSE;
  proc_inf.binary      = FALSE;
  proc_inf.tmp         = FALSE;
  proc_inf.special     = 0;
  proc_inf.filelength  = 0;
  proc_inf.workfunc    = work_export;
  proc_inf.stopfunc    = stop_export;

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

  proc_inf.file = fopen (proc_inf.filename, WRITE_BIN);

  if (proc_inf.file == NULL)
  {
    db_freecursor (db->base, proc_inf.cursor);
    file_error (ERR_FILECREATE, proc_inf.filename);
    return (FALSE);
  } /* if */

  title  = FREETXT (FPEXPORT);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, 0L, wi_modeless);

  if (window != NULL)
  {
    procp = (PROC_INF *)window->special;

    procp->impexpcfg->asciiformat = asciiformat;

    str2ucsd (impexpcfg.recsep, procp->impexpcfg->recsep);
    str2ucsd (impexpcfg.colsep, procp->impexpcfg->colsep);
    str2ucsd (impexpcfg.txtsep, procp->impexpcfg->txtsep);
    build_format (TYPE_DATE, get_str (imexparm, procp->impexpcfg->dateformat), procp->impexpcfg->format);

    start_process (window, minimize_process, TRUE);
  } /* if */

  return (TRUE);
} /* exp_list */

/*****************************************************************************/

LOCAL BOOLEAN work_import (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN    ok, found;
  WORD       status, result, i;
  LONG       actpos, address, *longp;
  DOUBLE     rel;
  CURSOR     cursor;
  WORK_SPEC  *pWork;
  CHAR       *pOldBuffer;
  FIELD_INFO fi;
  HPBLOB     hpBlob;
  SYSBLOB    *pSysBlob;
  LONG       lBlobSize;

  db_fillnull (proc_inf->db->base, proc_inf->table, proc_inf->db->buffer);

  if (proc_inf->impexpcfg->asciiformat == EXASCII)
    ok = import_ascii (proc_inf);
  else
    ok = import_binary (proc_inf);

  for (i = 0; (i < proc_inf->cols) && ok; i++)		/* import BLOBs */
  {
    db_fieldinfo (proc_inf->db->base, rtable (proc_inf->table), proc_inf->columns [i], &fi);

    if (fi.type == TYPE_BLOB)
    {
      hpBlob = (HPBLOB)((HPCHAR)proc_inf->db->buffer + fi.addr);
      ok     = fread (&lBlobSize, 1, sizeof (lBlobSize), proc_inf->file) == (SIZE_T)sizeof (lBlobSize);

      if (! ok)
      {
        if (! feof (proc_inf->file)) file_error (ERR_FILEREAD, proc_inf->filename);
      } /* if */
      else
      {
        if (lBlobSize == 0)			/* was an empty blob */
          hpBlob->address = 0;
        else
        {
          pSysBlob = mem_alloc (lBlobSize + sizeof (LONG));
          ok       = pSysBlob != NULL;

          if (! ok)
            hndl_alert (ERR_NOMEMORY);
          else
          {
            ok = fread (&pSysBlob->size, 1, lBlobSize, proc_inf->file) == (SIZE_T)lBlobSize;

            if (ok)
            {
              ok = db_insert (proc_inf->db->base, SYS_BLOB, pSysBlob, &status);

              if (ok)
                hpBlob->address = pSysBlob->address;
              else
                dbtest (proc_inf->db);
            } /* if */
            else
              file_error (ERR_FILEREAD, proc_inf->filename);

            mem_free (pSysBlob);
          } /* else */
        } /* else */
      } /* else */
    } /* if */
  } /* for */

  if (ok)
  {
    pWork             = (WORK_SPEC *)proc_inf->memory;
    actpos            = ftell (proc_inf->file) - pWork->lSize + pWork->lInx;
    rel               = (DOUBLE)proc_inf->filelength / (DOUBLE)actpos;
    proc_inf->maxrecs = (proc_inf->actrec + 1) * rel;

    if (proc_inf->use_calc) v_execute (proc_inf->db, proc_inf->table, proc_inf->calccode, proc_inf->db->buffer, proc_inf->actrec + 1, NULL);

    if (proc_inf->impexpcfg->primary == FAILURE)
      ok = db_insert (proc_inf->db->base, proc_inf->table, proc_inf->db->buffer, &status);
    else
    {
      found  = db_search (proc_inf->db->base, proc_inf->table, proc_inf->impexpcfg->primary, ASCENDING, &cursor, proc_inf->db->buffer, 0L);
      result = db_status (proc_inf->db->base);
      ok     = result == SUCCESS;

      if (ok)
        if (found)              /* update record only */
        {
          pOldBuffer = mem_alloc (pWork->lRecSize);

          if (pOldBuffer == NULL)
          {
            address = db_readcursor (proc_inf->db->base, &cursor, NULL);
            longp   = (LONG *)proc_inf->db->buffer;
            *longp  = address;
            ok      = db_reclock (proc_inf->db->base, address) && db_update (proc_inf->db->base, proc_inf->table, proc_inf->db->buffer, &status);
          } /* if */
          else
          {
            ok = db_read (proc_inf->db->base, proc_inf->table, pOldBuffer, &cursor, 0L, TRUE);
            
            if (ok)
            {
              for (i = 0; i < proc_inf->cols; i++)
              {
                db_fieldinfo (proc_inf->db->base, proc_inf->table, proc_inf->columns [i], &fi);
                mem_lmove (pOldBuffer + fi.addr, (CHAR *)proc_inf->db->buffer + fi.addr, fi.size);
              } /* for */  

              ok = db_update (proc_inf->db->base, proc_inf->table, pOldBuffer, &status);
            } /* if */
            
            mem_free (pOldBuffer);
          } /* else */
        } /* if */
        else
          ok = db_insert (proc_inf->db->base, proc_inf->table, proc_inf->db->buffer, &status);
    } /* else */

    if (! ok) ok = integrity (proc_inf->db->base, proc_inf->table, status);
  } /* if */

  return (ok);
} /* work_import */

/*****************************************************************************/

LOCAL BOOLEAN stop_import (proc_inf)
PROC_INF *proc_inf;

{
  updt_lsall (proc_inf->db, proc_inf->table, TRUE, FALSE);

  return (TRUE);
} /* stop_import */

/*****************************************************************************/

LOCAL BOOLEAN import_ascii (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN    ok;
  WORD       i, j, k, col, len, err;
  LONGSTR    s;
  IMPEXPCFG  *cfg;
  BYTE       *period, *space, *sep, *p, c;
  DATE       date;
  FIELD_INFO fi;
  INT        hour, minute, second;
  LONG       micro, days;
  BYTE       timestr [13];
  SIZE_T     size;

  ok  = TRUE;
  cfg = proc_inf->impexpcfg;

  if (cfg->colname && (proc_inf->actrec == 0))          /* read column names */
    for (i = 0; (i < proc_inf->cols) && ok; i++)
    {
      col = proc_inf->columns [i];

      db_fieldinfo (proc_inf->db->base, rtable (proc_inf->table), col, &fi);

      sep  = (i == proc_inf->cols - 1) ? cfg->recsep : cfg->colsep;
      size = strlen (fi.name);
      ok   = fread (s, 1, size, proc_inf->file) == size;

      if (ok)
       if (i == proc_inf->cols - 1)
         ok = fread (s, 1, LEN (cfg->recsep), proc_inf->file) == LEN (cfg->recsep);
       else
         ok = fread (s, 1, LEN (cfg->colsep), proc_inf->file) == LEN (cfg->colsep);

      if (! ok) file_error (ERR_FILEREAD, proc_inf->filename);
    } /* for, if */

  for (i = 0; (i < proc_inf->cols) && ok; i++)
  {
    col = proc_inf->columns [i];

    db_fieldinfo (proc_inf->db->base, proc_inf->table, col, &fi);

    sep = (i == proc_inf->cols - 1) ? cfg->recsep : cfg->colsep;
    p   = VARBYTES (fi.type) ? (BYTE *)proc_inf->db->buffer + fi.addr : s;
    err = read_field (proc_inf, sep, cfg->txtsep, fi.type, fi.size, p);
    ok  = err == SUCCESS;

    if (! ok)
    {
      if (err == ERR_IMPSEP)
        hndl_alert (err);
      else
        if (! feof (proc_inf->file)) file_error (err, proc_inf->filename);
    } /* if */
    else
      if (PRINTABLE (fi.type) && (p [0] != EOS))
      {
        switch (fi.type)
        {
          case TYPE_FLOAT     :
          case TYPE_CFLOAT    : period = strchr (s, cfg->decimal [0]);
                                if (period != NULL) *period = '.';
                                break;
          case TYPE_DATE      : switch (cfg->dateformat)
                                {
                                  case EXDDMMYY :
                                  case EXMMDDYY :
                                  case EXYYMMDD : if (strcmp (s, "00/00/00") == 0) /* special case for other db programs */
                                                    s [0] = EOS;                   /* use NULL value */
                                                  else
                                                    format2str (TYPE_DATE, s, cfg->format);
                                                  break;
                                  case EXNUMBER : sscanf (s, "%ld", &days);
                                                  days += DAYOFFSET;
                                                  days2date (days, &date);
                                                  bin2str (TYPE_DATE, &date, s);
                                                  break;
                                } /* switch */
                                break;
          case TYPE_TIME      : if (proc_inf->db->format != NULL) /* use user defined format */
                                  format2str (TYPE_TIME, s, proc_inf->db->format [fi.format]);
                                else
                                {
                                  for (j = k = 0; s [j] != EOS; j++)
                                    if (isdigit (s [j])) timestr [k++] = s [j];

                                  timestr [k] = EOS;
                                  strcpy (s, timestr);
                                } /* else */
                                break;
          case TYPE_TIMESTAMP : hour  = minute = second = micro = 0;
                                space = strchr (s, SP);
                                if (space != NULL) sscanf (space, "%02d%c%02d%c%02d%c%06ld", &hour, &c, &minute, &c, &second, &c, &micro);

                                switch (cfg->dateformat)
                                {
                                  case EXDDMMYY :
                                  case EXMMDDYY :
                                  case EXYYMMDD : format2str (TYPE_DATE, s, cfg->format);
                                                  str2bin (TYPE_DATE, s, &date);
                                                  break;
                                  case EXNUMBER : sscanf (s, "%ld", &days);
                                                  days += DAYOFFSET;
                                                  days2date (days, &date);
                                                  break;
                                } /* switch */

                                sprintf (s, "%02d%02d%04d%02d%02d%02d%06ld", date.day, date.month, date.year, hour, minute, second, micro);
                                break;
        } /* switch */

        len = 0;

#if GEMDOS
        while (p [len] != EOS)
        {
          if (p [len] == (BYTE) 21) p [len] = 221; /* change  from IBM to ATARI ST font */
          if (p [len] == (BYTE)225) p [len] = 158; /* change á from IBM to ATARI ST font */
          len++;
        } /* while */
#endif

#if MSDOS | FLEXOS
        while (p [len] != EOS)
        {
          if (p [len] == (BYTE)221) p [len] =  21; /* change  from ATARI ST to IBM font */
          if (p [len] == (BYTE)158) p [len] = 225; /* change á from ATARI ST to IBM font */
          len++;
        } /* if */
#endif

        if (! HASWILD (fi.type)) str_rmchar (s, ' '); /* no leading and trailing blanks */
        if (! VARBYTES (fi.type)) str2bin (fi.type, p, (BYTE *)proc_inf->db->buffer + fi.addr);
      } /* if, else */
  } /* for */

  return (ok);
} /* import_ascii */

/*****************************************************************************/

LOCAL BOOLEAN import_binary (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;
  LONG    size, packsize;
  BYTE    *packbuf;
  SIZE_T  rsize, i;

  ok = fread (&size, 1, sizeof (size), proc_inf->file) == sizeof (size);

  if (! ok)
  {
    if (! feof (proc_inf->file)) file_error (ERR_FILEREAD, proc_inf->filename);
  } /* if */
  else
  {
    packbuf = mem_alloc (size);
    ok      = packbuf != NULL;

    if (! ok)
      hndl_alert (ERR_NOMEMORY);
    else
    {
      packsize = size;
      i        = 0;

      while (ok && (size > 0))
      {
        rsize = (SIZE_T)min (size, 0xFFFE);
        ok    = fread (&packbuf [i], 1, rsize, proc_inf->file) == rsize;
        size -= rsize;
        i    += rsize;
      } /* while */

      if (ok) unpack (proc_inf->db->base, proc_inf->table, proc_inf->db->buffer, packbuf, packsize, proc_inf->cols, proc_inf->columns);
      mem_free (packbuf);

      if (! ok) file_error (ERR_FILEREAD, proc_inf->filename);
    } /* else */
  } /* else */

  return (ok);
} /* import_binary */

/*****************************************************************************/

LOCAL BOOLEAN read_field (proc_inf, colsep, txtsep, type, size, s)
PROC_INF *proc_inf;
BYTE     *colsep, *txtsep;
WORD     type;
LONG     size;
BYTE     *s;

{
  BOOLEAN ok, ready;
  BYTE    c;
  LONG    i, j;

  if (! PRINTABLE (type)) return (read_bytes (proc_inf, colsep, type, size, s));

  s [0] = EOS;
  ready = FALSE;
  i     = j = 0;
  c     = EOS;
  ok    = read_byte (proc_inf, &c);

  if (ok)
  {
    if (LEN (txtsep) != 0)
      if (HASWILD (type))
      {
        for (i = 0; (i < LEN (txtsep) - 1) && ok; i++)
          ok = read_byte (proc_inf, &c);

        ok = read_field (proc_inf, txtsep, "", type, size, s);
        i  = strlen (s);
        ok = read_byte (proc_inf, &c);
      } /* if, if */

    while (! ready && ok)
    {
      if ((type != TYPE_CHAR) && (i >= LONGSTRLEN - 1))
        return (ERR_IMPSEP);
      else
      {
        if ((type != TYPE_CHAR) || (i < size)) s [i] = c;
        i++;
      } /* else */

      if (c != colsep [++j])
      {
        j = 0;                          /* at least one char is not equal */
        if (c == colsep [1]) j = 1;     /* char is first char of colsep */
      } /* if */

      ready = j == LEN (colsep);

      if (! ready)
        ok = read_byte (proc_inf, &c);
    } /* while */

    i -= LEN (colsep);                          /* length of colsep */
    if ((type != TYPE_CHAR) || (i < size)) s [i] = EOS;
    if (HASWILD (type)) s [size - 1] = EOS;     /* string could have been too long */
  } /* if */

  if ((type == TYPE_WORD) || (type == TYPE_LONG))       /* could have been money format */
  {
    str_rmchar (s, '.');
    str_rmchar (s, ',');
  } /* if */

  return (ok ? SUCCESS : ERR_FILEREAD);
} /* read_field */

/*****************************************************************************/

LOCAL BOOLEAN read_bytes (proc_inf, colsep, type, size, buffer)
PROC_INF *proc_inf;
BYTE     *colsep;
WORD     type;
LONG     size;
BYTE     *buffer;

{
  BOOLEAN ok;
  LONG    bufsize;
  WORD    i, len;
  UBYTE   *b;
  UWORD   *w;
  ULONG   *l;
  ULONG   lval;
  STRING  s;

  for (i = 0, ok = TRUE; (i < 8) && ok; i++)    /* read size */
    ok = read_byte (proc_inf, &s [i]);

  s [8] = EOS;                                  /* 8 nibbles per long word */

  if (ok)
  {
    sscanf (s, "%lx", &bufsize);                /* get size of buffer */

    *(LONG *)buffer  = bufsize;
    size            -= sizeof (LONG);
    b                = (UBYTE *)(buffer + sizeof (LONG));
    w                = (UWORD *)b;
    l                = (ULONG *)b;

    len = (type == TYPE_VARBYTE) || (type == TYPE_PICTURE) ? sizeof (UBYTE) : (type == TYPE_VARWORD) ? sizeof (UWORD) : sizeof (ULONG);

    while ((bufsize > 0) && ok)                 /* read the words */
    {
      for (i = 0; (i < 2 * len) && ok; i++)
        ok = read_byte (proc_inf, &s [i]);

      s [2 * len] = EOS;

      sscanf (s, "%lx", &lval);

      if (size > 0)                             /* fits into buffer */
        switch (type)
        {
          case TYPE_VARBYTE :
          case TYPE_PICTURE : *b++ = (UBYTE)lval; break;
          case TYPE_VARWORD : *w++ = (UWORD)lval; break;
          case TYPE_VARLONG : *l++ = (ULONG)lval; break;
        } /* switch, if */

      bufsize -= len;
      size    -= len;
    } /* while */

    if (size < 0) *(LONG *)buffer += size;      /* buffer was too small */

    if (ok)                                     /* read separator */
      for (i = 0; (i < LEN (colsep)) && ok; i++)
        ok = read_byte (proc_inf, &s [0]);
  } /* if */

  return (ok ? SUCCESS : ERR_FILEREAD);
} /* read_bytes */

/*****************************************************************************/

LOCAL BOOLEAN work_export (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN    ok;
  WORD       i;
  FIELD_INFO fi;
  HPBLOB     hpBlob;
  SYSBLOB    *pSysBlob;
  LONG       l;

  ok = FALSE;

  if (v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir))
    if (v_read (proc_inf->db, proc_inf->table, proc_inf->db->buffer, proc_inf->cursor, 0L, FALSE))
    {
      if (proc_inf->use_calc) v_execute (proc_inf->db, proc_inf->table, proc_inf->calccode, proc_inf->db->buffer, proc_inf->actrec + 1, NULL);

      if (proc_inf->impexpcfg->asciiformat == EXASCII)
        ok = export_ascii (proc_inf);
      else
        ok = export_binary (proc_inf, rtable (proc_inf->table), proc_inf->db->buffer);

      for (i = 0; (i < proc_inf->cols) && ok; i++)	/* export BLOBs */
      {
        db_fieldinfo (proc_inf->db->base, rtable (proc_inf->table), proc_inf->columns [i], &fi);

        if (fi.type == TYPE_BLOB)
        {
          hpBlob = (HPBLOB)((HPCHAR)proc_inf->db->buffer + fi.addr);

          if (hpBlob->address == 0)	/* empty blob, can't read from disk */
          {
            l  = 0;			/* null record size */
            ok = fwrite (&l, 1, sizeof (LONG), proc_inf->file) == (SIZE_T)sizeof (LONG);
            if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
          } /* if */
          else
          {
            pSysBlob = db_readblob (proc_inf->db->base, NULL, NULL, hpBlob->address, FALSE);
            ok       = pSysBlob != NULL;

            if (! ok)
              dbtest (proc_inf->db);
            else
              ok = export_binary (proc_inf, SYS_BLOB, (HPCHAR)pSysBlob);

            mem_free (pSysBlob);
          } /* else */
        } /* if */
      } /* for */
    } /* if, if */

  return (ok);
} /* work_export */

/*****************************************************************************/

LOCAL BOOLEAN stop_export (proc_inf)
PROC_INF *proc_inf;

{
  WORD     scrap_id;
  WORD     msgbuf [8];
  FULLNAME path;

  file_split (proc_inf->filename, NULL, path, NULL, NULL);

  if (strcmp (path, scrapdir) == 0)
  {
    scrap_id = appl_find (CLIPBRD);

    if (scrap_id != FAILURE)
    {
      msgbuf [0] = SCRP_UPDT;
      msgbuf [1] = gl_apid;
      msgbuf [2] = 0;

      appl_write (scrap_id, sizeof (msgbuf), msgbuf);
    } /* if */
  } /* if */

  return (TRUE);
} /* stop_export */

/*****************************************************************************/

LOCAL BOOLEAN export_ascii (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN    ok;
  WORD       i, col;
  UBYTE      *b;
  UWORD      *w;
  ULONG      *l;
  LONG       size;
  LONGSTR    s;
  IMPEXPCFG  *cfg;
  BYTE       *period, *p;
  DATE       date;
  TIMESTAMP  stamp;
  FIELD_INFO fi;
  SIZE_T     wsize;

  ok  = TRUE;
  cfg = proc_inf->impexpcfg;

  if (cfg->colname && (proc_inf->actrec == 0))          /* write column names */
    for (i = 0; (i < proc_inf->cols) && ok; i++)
    {
      col = proc_inf->columns [i];

      db_fieldinfo (proc_inf->db->base, rtable (proc_inf->table), col, &fi);

      wsize = strlen (fi.name);
      ok    = fwrite (fi.name, 1, wsize, proc_inf->file) == wsize;

      if (ok)
       if (i == proc_inf->cols - 1)
         ok = fwrite (cfg->recsep + 1, 1, LEN (cfg->recsep), proc_inf->file) == LEN (cfg->recsep);
       else
         ok = fwrite (cfg->colsep + 1, 1, LEN (cfg->colsep), proc_inf->file) == LEN (cfg->colsep);

      if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
    } /* for, if */

  for (i = 0; (i < proc_inf->cols) && ok; i++)
  {
    col = proc_inf->columns [i];

    db_fieldinfo (proc_inf->db->base, rtable (proc_inf->table), col, &fi);

    p = (BYTE *)proc_inf->db->buffer + fi.addr;

    if (! PRINTABLE (fi.type))
    {
      size = *(LONG *)p;

      fprintf (proc_inf->file, "%08lx", size);

      switch (fi.type)
      {
        case TYPE_VARBYTE :
        case TYPE_PICTURE : b = (UBYTE *)(p + sizeof (LONG));
                            while (size > 0)
                            {
                              fprintf (proc_inf->file, "%02x", *b++);
                              size -= sizeof (UBYTE);
                            } /* while */
                            break;
        case TYPE_VARWORD : w = (UWORD *)(p + sizeof (LONG));
                            while (size > 0)
                            {
                              fprintf (proc_inf->file, "%04x", *w++);
                              size -= sizeof (UWORD);
                            } /* while */
                            break;
        case TYPE_VARLONG : l = (ULONG *)(p + sizeof (LONG));
                            while (size > 0)
                            {
                              fprintf (proc_inf->file, "%08lx", *l++);
                              size -= sizeof (ULONG);
                            } /* while */
                            break;
      } /* switch */
    } /* if */
    else
    {
      if (fi.type != TYPE_CHAR)         /* not a long text field */
      {
        bin2str (fi.type, p, s);
        p = s;
      } /* if */

      switch (fi.type)
      {
        case TYPE_CHAR      :
        case TYPE_EXTERN    : if (LEN (cfg->txtsep) != 0) ok = fwrite (cfg->txtsep + 1, 1, LEN (cfg->txtsep), proc_inf->file) == LEN (cfg->txtsep);
                              break;
        case TYPE_FLOAT     :
        case TYPE_CFLOAT    : period = strchr (s, '.');
                              if (period != NULL) *period = cfg->decimal [0];
                              break;
        case TYPE_DATE      : if (s [0] != EOS)
                              {
                                mem_move (&date, (BYTE *)proc_inf->db->buffer + fi.addr, sizeof (DATE));
                                switch (cfg->dateformat)
                                {
                                  case EXDDMMYY :
                                  case EXMMDDYY :
                                  case EXYYMMDD : str2format (TYPE_DATE, s, cfg->format);
                                                  break;
                                  case EXNUMBER : if (date.year >= 1900) date.year -= 1900;
                                                  sprintf (s, "%ld", date2days (&date));
                                                  break;
                                } /* switch */
                              } /* if */
                              break;
        case TYPE_TIME      : if (s [0] != EOS)
                                if (proc_inf->db->format != NULL)
                                  str2format (TYPE_TIME, s, proc_inf->db->format [fi.format]);
                              break;
        case TYPE_TIMESTAMP : if (s [0] != EOS)
                              {
                                mem_move (&stamp, (BYTE *)proc_inf->db->buffer + fi.addr, sizeof (TIMESTAMP));
                                switch (cfg->dateformat)
                                {
                                  case EXDDMMYY :
                                  case EXMMDDYY :
                                  case EXYYMMDD : str2format (TYPE_DATE, s, cfg->format);
                                                  strcat (s, " ");
                                                  sprintf (s + strlen (s), "%02d:%02d:%02d.%06ld", stamp.time.hour, stamp.time.minute, stamp.time.second, stamp.time.micro);
                                                  break;
                                  case EXNUMBER : if (stamp.date.year >= 1900) stamp.date.year -= 1900;
                                                  sprintf (s, "%ld %02d:%02d:%02d.%06ld", date2days (&stamp.date), stamp.time.hour, stamp.time.minute, stamp.time.second, stamp.time.micro);
                                                  break;
                                } /* switch */
                              } /* if */
                              break;
      } /* switch */

      size = strlen (p);

      while (ok && (size > 0))
      {
        wsize = (SIZE_T)min (size, 0xFFFE);
        ok    = fwrite (p, 1, wsize, proc_inf->file) == wsize;
        size -= wsize;
        p    += wsize;
      } /* while */

      switch (fi.type)
      {
        case TYPE_CHAR   :
        case TYPE_EXTERN : if (LEN (cfg->txtsep) != 0)
                             if (ok) ok = fwrite (cfg->txtsep + 1, 1, LEN (cfg->txtsep), proc_inf->file) == LEN (cfg->txtsep);
                           break;
      } /* switch */
    } /* else */

    if (ok)
     if (i == proc_inf->cols - 1)
       ok = fwrite (cfg->recsep + 1, 1, LEN (cfg->recsep), proc_inf->file) == LEN (cfg->recsep);
     else
       ok = fwrite (cfg->colsep + 1, 1, LEN (cfg->colsep), proc_inf->file) == LEN (cfg->colsep);

    if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
  } /* for */

  return (ok);
} /* export_ascii */

/*****************************************************************************/

LOCAL BOOLEAN export_binary (proc_inf, table, buffer)
PROC_INF *proc_inf;
WORD     table;
BYTE     *buffer;

{
  BOOLEAN ok;
  LONG    size, *longp;
  BYTE    *packbuf;
  SIZE_T  wsize, i;

  packbuf = mem_alloc (pack (proc_inf->db->base, table, buffer, NULL, proc_inf->cols, proc_inf->columns) + sizeof (LONG));
  ok      = packbuf != NULL;

  if (! ok)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    size    = pack (proc_inf->db->base, table, buffer, packbuf + sizeof (LONG), proc_inf->cols, proc_inf->columns);
    longp   = (LONG *)packbuf;
    *longp  = size;
    size   += sizeof (LONG);
    i       = 0;

    while (ok && (size > 0))
    {
      wsize = (SIZE_T)min (size, 0xFFFE);
      ok    = fwrite (&packbuf [i], 1, wsize, proc_inf->file) == wsize;
      size -= wsize;
      i    += wsize;
    } /* while */

    mem_free (packbuf);

    if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
  } /* else */

  return (ok);
} /* export_binary */

/*****************************************************************************/

LOCAL LONG pack (base, table, buffer, packbuf, cols, columns)
BASE *base;
WORD table;
VOID *buffer;
VOID *packbuf;
WORD cols, *columns;

{
  LONG       size, msize;
  WORD       i;
  BYTE       *srcp, *dstp;
  FIELD_INFO fi;

  size = 0;
  dstp = (BYTE *)packbuf;

  if (table == SYS_BLOB)		/* unpacked variable size */
    size = db_pack (base, table, buffer, packbuf);
  else
    for (i = 0; i < cols; i++)
    {
      db_fieldinfo (base, table, columns [i], &fi);

      srcp  = (BYTE *)buffer + fi.addr;
      msize = typesize (fi.type, srcp);
      if (dstp != NULL) mem_lmove (dstp, srcp, msize);

      size += msize;
      if (dstp != NULL) dstp += msize;
    } /* else, for */

  return (size);
} /* pack */

/*****************************************************************************/

LOCAL LONG unpack (base, table, buffer, packbuf, packsize, cols, columns)
BASE *base;
WORD table;
VOID *buffer;
VOID *packbuf;
LONG packsize;
WORD cols, *columns;

{
  LONG       msize, size, tblsize;
  WORD       i;
  BYTE       *srcp, *dstp;
  FIELD_INFO fi;

  tblsize = 0;
  srcp    = (BYTE *)packbuf;

  if (table == SYS_BLOB)		/* unpacked variable size */
    tblsize = db_unpack (base, table, buffer, packbuf, packsize);
  else
    for (i = 0; i < cols; i++)
    {
      db_fieldinfo (base, table, columns [i], &fi);

      dstp  = (BYTE *)buffer + fi.addr;
      msize = (packsize <= 0) ? 0L : typesize (fi.type, srcp);
      size  = msize;

      if (VARLEN (fi.type))             /* any string type */
        if (size > fi.size)             /* string has been made shorter */
        {
          size        = fi.size;        /* don't move too many bytes */
          dstp [size] = EOS;            /* terminate string */
        } /* if, if */

      if (packsize > 0)                 /* valid buffer */
        mem_lmove (dstp, srcp, size);
      else                              /* more fields than there are in buffer */
        set_null (fi.type, dstp);

      srcp     += msize;
      packsize -= msize;
      tblsize  += fi.size;
    } /* else, for */

  return (tblsize);
} /* unpack */

/*****************************************************************************/

LOCAL BOOLEAN read_byte (PROC_INF *proc_inf, BYTE *pBuffer)
{
  BOOLEAN   bOk;
  WORK_SPEC *pWork;
  LONG      lSize;

  bOk      = TRUE;
  pWork    = (WORK_SPEC *)proc_inf->memory;
  *pBuffer = EOS;

  if (pWork->lInx >= pWork->lSize)
  {
    lSize        = fread (pWork->achBuffer, 1, MAX_BUFFER, proc_inf->file);
    pWork->lInx  = 0;
    pWork->lSize = lSize;
  } /* if */

  if (pWork->lInx >= pWork->lSize)
    bOk = FALSE;
  else
    *pBuffer = pWork->achBuffer [pWork->lInx++];

  return (bOk);
} /* read_byte */

/*****************************************************************************/

