/*****************************************************************************
 *
 * Module : LPRINT.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the list printing process.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 17.07.95: Extra parameter added in calling v_execute
 * 31.01.95; Using of variable warn_table added
 * 28.07.94: Using line buffer in stop_list
 * 16.11.93: Using new file selector
 * 20.08.93: Component sum changed in PAGE_FORMAT
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "list.h"
#include "mpagefrm.h"
#include "printer.h"
#include "process.h"

#include "export.h"
#include "lprint.h"

/****** DEFINES **************************************************************/

#define MAX_PRNCOLS 1000                /* maximum cols for output on a printer */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    lines;                        /* line number for list */
  WORD    pagenr;                       /* page number for list */
  LONG    maxcols;                      /* number of columns in each line */
  WORD    device;                       /* printer or disk */
  WORD    type;                         /* type of index */
  LONGSTR oldkey;                       /* oldkey */
  LONGSTR newkey;                       /* newkey */
  BYTE    *linebuf;                     /* buffer for one line */
  BYTE    *headbuf;                     /* buffer for column header */
  BYTE    *sum_total;                   /* pointer to buffer containing totals */
  BYTE    *sum_sub;                     /* pointer to buffer containing subtotals */
} WORK_INF;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN work_list   _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_list   _((PROC_INF *proc_inf));
LOCAL BOOLEAN print_line  _((PROC_INF *proc_inf, BYTE *linebuf));
LOCAL BOOLEAN send_out    _((PROC_INF *proc_inf, BYTE *linebuf));
LOCAL VOID    add_values  _((PROC_INF *proc_inf, BYTE *sumbuffer));
LOCAL VOID    zero_values _((DB *db, WORD vtable, BYTE *buffer));
LOCAL VOID    get_header  _((DB *db, WORD vtable, WORD inx, WORD dir, WORD pagenr, BOOLEAN header, PAGE_FORMAT *pfp, BYTE *line));
LOCAL VOID    build_del   _((BYTE *linebuf, WORD del, LONG maxcols, WORD cols, WORD *colwidth));

/*****************************************************************************/

GLOBAL BOOLEAN l_print (db, table, inx, dir, cols, columns, colwidth, device, fontdesc, size, filename, minimize)
DB       *db;
WORD     table, inx, dir, cols, *columns, *colwidth, device;
FONTDESC *fontdesc;
RECT     *size;
BYTE     *filename;
BOOLEAN  minimize;

{
  WINDOWP    window;
  LONG       numkeys, bytes, maxcols;
  PROC_INF   proc_inf, *procp;
  BYTE       *title, *p;
  STRING     name;
  TABLE_INFO t_inf;
  INDEX_INFO i_inf;
  WORK_INF   *workp;
  BOOLEAN    to_printer, spool, save_spool, wait;
  WORD       result;

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

  switch (device)
  {
    case DEV_SCREEN  : window = crt_list (NULL, NULL, NIL, db, table, inx, dir, cols, columns, colwidth, fontdesc, size, filename);
                       if (window != NULL)
                         if (minimize)
                           miconify (window);
                         else
                           if (! open_window (window)) hndl_alert (ERR_NOOPEN);
                       break;
    case DEV_DISK    :
    case DEV_PRINTER : to_printer = FALSE;
                       spool      = FALSE;
                       wait       = FALSE;

                       if ((filename != NULL) && (*filename != EOS))
                         strcpy (proc_inf.filename, filename);
                       else
                         if (device == DEV_DISK)
                         {
                           p = FREETXT (FLSTSUFF);

                           table_name (db, table, name);
                           name [MAX_FILENAME - strlen (p + 1)] = EOS;
                           strcat (name, p + 1);
                           strcpy (proc_inf.filename, name);

                           if (! get_save_filename (FOPENLST, NULL, 0L, FFILTER_LST, NULL, NULL, FLSTSUFF, proc_inf.filename, NULL))
                             return (FALSE);

                           if (! chk_filenames (proc_inf.filename))
                             return (FALSE);
                         } /* if */
                         else
                         {
                           if (prncfg.port == PFILE)
                             if (! chk_filenames (prncfg.filename))
                               return (FALSE);

                           to_printer = (prncfg.port >= PPORT1) && ! prncfg.spool;

                           if (to_printer)
                             if (prn_occupied ())
                             {
                               result = hndl_alert (ERR_PRINTERUSED);

                               switch (result)
                               {
                                 case 1 : spool      = TRUE;    /* printing by spooling */
                                          to_printer = FALSE;   /* not directly to printer */
                                          break;
                                 case 2 : wait = TRUE;
                                          break;
                                 case 3 : return (FALSE);
                               } /* switch */
                             } /* if */
                             else
                               if (! prn_check (prncfg.port - PPORT1)) return (FALSE);
                         } /* else */

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
                       proc_inf.impexpcfg   = NULL;
                       proc_inf.page_format = &page_format;
                       proc_inf.prncfg      = (device == DEV_PRINTER) ? &prncfg : NULL;
                       proc_inf.to_printer  = to_printer;
                       proc_inf.binary      = FALSE;
                       proc_inf.tmp         = FALSE;
                       proc_inf.special     = device;
                       proc_inf.filelength  = 0;
                       proc_inf.workfunc    = work_list;
                       proc_inf.stopfunc    = stop_list;

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

                       if (device == DEV_PRINTER)
                       {
                         save_spool = prncfg.spool;             /* save spooling flag */
                         if (spool) proc_inf.prncfg->spool = TRUE; /* set the spooling flag to get the right name */
                         get_prname (proc_inf.prncfg, proc_inf.filename);
                         prncfg.spool = save_spool;             /* restore spooling fag */
                       } /* if */

                       if (wait)
                         proc_inf.file = NULL;  /* don't create file now */
                       else
                       {
                         proc_inf.file = to_printer ? fopen_prn (proc_inf.filename) : (device == DEV_PRINTER) ? fopen (proc_inf.filename, WRITE_BIN) : fopen (proc_inf.filename, WRITE_TXT);

                         if (proc_inf.file == NULL)
                         {
                           db_freecursor (db->base, proc_inf.cursor);
                           file_error (ERR_FILECREATE, proc_inf.filename);
                           return (FALSE);
                         } /* if */
                       } /* else */

                       bytes    = sizeof (WORK_INF);
                       maxcols  = min (page_format.width, get_width (cols, colwidth)) + 1;
                       bytes   += maxcols;

                       if (page_format.colheader) bytes += maxcols;

                       if (odd (bytes)) bytes++;        /* db buffers on even address */

                       if (page_format.sum)             /* need more memory */
                       {
                         v_tableinfo (db, table, &t_inf);
                         bytes += t_inf.size;

                         if (page_format.group > 0) bytes += t_inf.size;
                       } /* if */

                       title  = FREETXT ((device == DEV_DISK) ? FPDISK : FPPRINT);
                       window = crt_process (NULL, NULL, NIL, title, &proc_inf, bytes, wi_modeless);

                       if (window != NULL)
                       {
                         procp = (PROC_INF *)window->special;

                         if (spool) procp->prncfg->spool = TRUE; /* set the spooling flag */

                         if (procp->prncfg != NULL)              /* print on printer device */
                         {
                           if (procp->prncfg->port == PFILE) procp->prncfg->spool = FALSE;

                           if (procp->file != NULL)              /* in case I'm waiting */
                             if (! code_to_prn (procp->prncfg, procp->file, procp->to_printer, TRUE))
                               file_error (ERR_FILEWRITE, procp->filename);
                         } /* if */

                         if (wait)
                         {
                           procp->pausing = TRUE;
                           procp->blocked = TRUE;
                         } /* if */

                         workp = (WORK_INF *)procp->memory;
                         mem_lset (workp, 0, bytes);

                         workp->maxcols  = maxcols - 1; /* chars not bytes */
                         workp->device   = device;
                         p               = procp->memory + sizeof (WORK_INF);
                         workp->linebuf  = p;
                         p              += maxcols;

                         if (page_format.colheader) /* need a column header */
                         {
                           workp->headbuf  = p;
                           p              += maxcols;
                           get_colheader (db, table, cols, columns, colwidth, workp->maxcols, workp->headbuf);
                         } /* if */

                         if (page_format.sum)  /* need a buffer for totals */
                         {
                           if (odd ((LONG)p)) p++; /* db buffers on even address */

                           workp->sum_total  = p;
                           p                += t_inf.size;

                           zero_values (db, table, workp->sum_total);

                           if (page_format.group > 0)
                           {
                             workp->sum_sub = p;
                             zero_values (db, table, workp->sum_sub);
                           } /* if */
                         } /* if */

                         if (inx != FAILURE)
                         {
                           v_indexinfo (db, table, inx, &i_inf);
                           workp->type = i_inf.type;
                         } /* if */

											   start_process (window, minimize_process, TRUE);
                       } /* if */
                       break;
  } /* switch */

  return (TRUE);
} /* l_print */

/*****************************************************************************/

LOCAL BOOLEAN work_list (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN     ok;
  WORD        table;
  PAGE_FORMAT *pfp;
  WORK_INF    *workp;

  ok = FALSE;

  if (v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir))
    if (v_read (proc_inf->db, proc_inf->table, proc_inf->db->buffer, proc_inf->cursor, 0L, FALSE))
    {
      ok    = TRUE;
      table = rtable (proc_inf->table);
      pfp   = proc_inf->page_format;
      workp = (WORK_INF *)proc_inf->memory;

      if (proc_inf->use_calc) v_execute (proc_inf->db, proc_inf->table, proc_inf->calccode, proc_inf->db->buffer, proc_inf->actrec + 1, NULL);

      if ((proc_inf->inx != FAILURE) && (pfp->group > 0))
      {
        strcpy (workp->oldkey, workp->newkey);
        build_keystr (proc_inf->db, table, proc_inf->inx, proc_inf->db->buffer, workp->newkey);

        workp->newkey [pfp->group] = EOS;

        if ((strcmp (workp->oldkey, workp->newkey) != 0) && (proc_inf->actrec > 0))
        {
          if (pfp->sum)                 /* print subtotals */
          {
            build_del (workp->linebuf, '-', workp->maxcols, proc_inf->cols, proc_inf->colwidth);
            ok = print_line (proc_inf, workp->linebuf);

            rec2line (proc_inf->db, table, workp->sum_sub, proc_inf->cols, proc_inf->columns, proc_inf->colwidth, workp->maxcols, workp->linebuf);
            ok = print_line (proc_inf, workp->linebuf);

            zero_values (proc_inf->db, proc_inf->table, workp->sum_sub);
          } /* if */

          if (workp->lines > 0)
          {
            workp->linebuf [0] = EOS;     /* one empty line */
            ok = print_line (proc_inf, workp->linebuf);
          } /* if */
        } /* if */
      } /* if */

      if (pfp->sum)
      {
        add_values (proc_inf, workp->sum_total);
        if (pfp->group > 0) add_values (proc_inf, workp->sum_sub);
      } /* if */

      rec2line (proc_inf->db, table, proc_inf->db->buffer, proc_inf->cols, proc_inf->columns, proc_inf->colwidth, workp->maxcols, workp->linebuf);
      ok = print_line (proc_inf, workp->linebuf);
    } /* if, if */

  return (ok);
} /* work_list */

/*****************************************************************************/

LOCAL BOOLEAN stop_list (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN     ok;
  WORD        table, i;
  PAGE_FORMAT *pfp;
  WORK_INF    *workp;
  BYTE        line [MAX_PRNCOLS];

  ok    = TRUE;
  table = rtable (proc_inf->table);
  pfp   = proc_inf->page_format;
  workp = (WORK_INF *)proc_inf->memory;

  if (pfp->sum)
  {
    if ((proc_inf->inx != FAILURE) && (pfp->group > 0))
    {
      build_del (workp->linebuf, '-', workp->maxcols, proc_inf->cols, proc_inf->colwidth);
      ok = print_line (proc_inf, workp->linebuf);

      rec2line (proc_inf->db, table, workp->sum_sub, proc_inf->cols, proc_inf->columns, proc_inf->colwidth, workp->maxcols, workp->linebuf);
      ok = print_line (proc_inf, workp->linebuf);

      if (workp->lines > 0)
      {
        workp->linebuf [0] = EOS;       /* one empty line */
        ok = print_line (proc_inf, workp->linebuf);
      } /* if */
    } /* if */

    build_del (workp->linebuf, '=', workp->maxcols, proc_inf->cols, proc_inf->colwidth);
    ok = print_line (proc_inf, workp->linebuf);

    rec2line (proc_inf->db, table, workp->sum_total, proc_inf->cols, proc_inf->columns, proc_inf->colwidth, workp->maxcols, workp->linebuf);
    ok = print_line (proc_inf, workp->linebuf);
  } /* if */

  if (workp->lines != 0)
  {
    for (i = 0; i < pfp->result - workp->lines; i++) ok = send_out (proc_inf, "");

    if (pfp->mfooter > 0)
    {
      for (i = 1; i < pfp->mfooter; i++) ok = send_out (proc_inf, "");
      get_header (proc_inf->db, proc_inf->table, proc_inf->inx, proc_inf->dir, workp->pagenr, FALSE, pfp, line);
      ok = send_out (proc_inf, line);
    } /* if */

    if (pfp->mbottom > 0)
      if (pfp->formadvance && (workp->device == DEV_PRINTER))
        ok = send_out (proc_inf, "\f");
      else
        for (i = 0; i < pfp->mbottom; i++) ok = send_out (proc_inf, "");
  } /* if */

  if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);

  return (ok);
} /* stop_list */

/*****************************************************************************/

LOCAL BOOLEAN print_line (proc_inf, linebuf)
PROC_INF *proc_inf;
BYTE     *linebuf;

{
  BOOLEAN     ok;
  PAGE_FORMAT *pfp;
  WORK_INF    *workp;
  WORD        i;
  BYTE        line [MAX_PRNCOLS];

  ok    = TRUE;
  pfp   = proc_inf->page_format;
  workp = (WORK_INF *)proc_inf->memory;

  if (workp->lines == 0)
  {
    workp->pagenr++;

    for (i = 0; i < pfp->mtop; i++) ok = send_out (proc_inf, "");

    if (pfp->mheader > 0)
    {
      get_header (proc_inf->db, proc_inf->table, proc_inf->inx, proc_inf->dir, workp->pagenr, TRUE, pfp, line);
      send_out (proc_inf, line);
      for (i = 1; i < pfp->mheader; i++) ok = send_out (proc_inf, "");
    } /* if */

    if (pfp->colheader)
    {
      mem_set (line, '-', MAX_PRNCOLS);
      line [workp->maxcols] = EOS;
      ok = send_out (proc_inf, workp->headbuf);
      ok = send_out (proc_inf, line);
    } /* if */
  } /* if */

  ok = send_out (proc_inf, linebuf);
  workp->lines++;

  if (workp->lines >= pfp->result)
  {
    if (pfp->mfooter > 0)
    {
      for (i = 1; i < pfp->mfooter; i++) ok = send_out (proc_inf, "");
      get_header (proc_inf->db, proc_inf->table, proc_inf->inx, proc_inf->dir, workp->pagenr, FALSE, pfp, line);
      ok = send_out (proc_inf, line);
    } /* if */

    if (pfp->mbottom > 0)
      if (pfp->formadvance && (workp->device == DEV_PRINTER))
        ok = send_out (proc_inf, "\f");
      else
        for (i = 0; i < pfp->mbottom; i++) ok = send_out (proc_inf, "");

    workp->lines = 0;
  } /* if */

  if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);

  return (ok);
} /* print_line */

/*****************************************************************************/

LOCAL BOOLEAN send_out (proc_inf, linebuf)
PROC_INF *proc_inf;
BYTE     *linebuf;

{
  BOOLEAN     ok;
  LONGSTR     s;
  PAGE_FORMAT *pfp;

  pfp = proc_inf->page_format;

  mem_set (s, ' ', sizeof (LONGSTR));
  s [pfp->mleft] = EOS;

  switch (proc_inf->special)
  {
    case DEV_DISK    : if (linebuf [0] != EOS) ok = text_write (proc_inf->file, s);
                       ok = text_wrln (proc_inf->file, linebuf);
                       break;
    case DEV_PRINTER : if (linebuf [0] != EOS) ok = str_to_prn (s, proc_inf->file, proc_inf->to_printer);
                       ok = str_to_prn (linebuf, proc_inf->file, proc_inf->to_printer);
                       if (linebuf [0] != '\f') ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);
                       break;
  } /* switch */

  return (ok);
} /* send_out */

/*****************************************************************************/

LOCAL VOID add_values (proc_inf, sumbuffer)
PROC_INF *proc_inf;
BYTE     *sumbuffer;

{
  FIELD_INFO f_inf;
  CALC_TYPE  res, sum;
  DOUBLE     dbl_res, dbl_sum;
  WORD       i, table, col;
  BOOLEAN    calc;

  table = rtable (proc_inf->table);

  for (i = 0; i < proc_inf->cols; i++)
  {
    col = proc_inf->columns [i];
    db_fieldinfo (proc_inf->db->base, table, col, &f_inf);

    switch (f_inf.type)
    {
      case TYPE_WORD   :
      case TYPE_LONG   :
      case TYPE_FLOAT  :
      case TYPE_CFLOAT : calc = TRUE;  break;
      default          : calc = FALSE; break;
    } /* switch */

    if (calc && ! is_null (f_inf.type, (BYTE *)proc_inf->db->buffer + f_inf.addr))
    {
      db_getfield (proc_inf->db->base, table, col, proc_inf->db->buffer, &sum);
      db_getfield (proc_inf->db->base, table, col, sumbuffer, &res);

      switch (f_inf.type)
      {
        case TYPE_WORD   : res.c_word += sum.c_word;
                           break;
        case TYPE_LONG   : res.c_long += sum.c_long;
                           break;
        case TYPE_CFLOAT : str2bin (TYPE_FLOAT, sum.c_cfloat, &dbl_sum);
                           str2bin (TYPE_FLOAT, res.c_cfloat, &dbl_res);
                           dbl_res += dbl_sum;
                           bin2str (TYPE_FLOAT, &dbl_res, res.c_cfloat);
                           res.c_cfloat [f_inf.size] = EOS;
                           break;
        case TYPE_FLOAT  : res.c_float += sum.c_float;
                           break;
      } /* switch */

      db_setfield (proc_inf->db->base, table, col, sumbuffer, &res);
    } /* if */
  } /* for */
} /* add_values */

/*****************************************************************************/

LOCAL VOID zero_values (db, vtable, buffer)
DB   *db;
WORD vtable;
BYTE *buffer;

{
  TABLE_INFO t_inf;
  FIELD_INFO f_inf;
  WORD       i;

  v_tableinfo (db, vtable, &t_inf);

  mem_lset (buffer, 0, t_inf.size);

  for (i = 1; i < t_inf.cols; i++)
  {
    db_fieldinfo (db->base, rtable (vtable), i, &f_inf);

    switch (f_inf.type)         /* all fields which cannot be added */
    {
      case TYPE_CHAR      :
      case TYPE_DATE      :
      case TYPE_TIME      :
      case TYPE_TIMESTAMP :
      case TYPE_VARBYTE   :
      case TYPE_VARWORD   :
      case TYPE_VARLONG   :
      case TYPE_PICTURE   :
      case TYPE_EXTERN    :
      case TYPE_DBADDRESS : set_null (f_inf.type, buffer + f_inf.addr); break;
    } /* switch */
  } /* for */
} /* zero_values */

/*****************************************************************************/

LOCAL VOID get_header (db, vtable, inx, dir, pagenr, header, pfp, line)
DB          *db;
WORD        vtable, inx, dir, pagenr;
BOOLEAN     header;
PAGE_FORMAT *pfp;
BYTE        *line;

{
  LONGSTR s;
  BYTE    *left, *center, *right;

  mem_set (line, ' ', pfp->width);

  if (header)
  {
    left   = pfp->lheader;
    center = pfp->cheader;
    right  = pfp->rheader;
  } /* if */
  else
  {
    left   = pfp->lfooter;
    center = pfp->cfooter;
    right  = pfp->rfooter;
  } /* else */

  scan_header (db, vtable, inx, dir, pagenr, left, s);
  mem_move (&line [0], s, strlen (s));
  scan_header (db, vtable, inx, dir, pagenr, center, s);
  mem_move (&line [(pfp->width - strlen (s)) / 2], s, strlen (s));
  scan_header (db, vtable, inx, dir, pagenr, right, s);
  mem_move (&line [pfp->width - strlen (s)], s, strlen (s)); 

  line [pfp->width] = EOS;
} /* get_header */

/*****************************************************************************/

LOCAL VOID build_del (linebuf, del, maxcols, cols, colwidth)
BYTE *linebuf;
WORD del;
LONG maxcols;
WORD cols, *colwidth;

{
  REG WORD i;
  REG LONG count;

  mem_lset (linebuf, del, maxcols);
  linebuf [maxcols] = EOS;

  for (i = 0, count = 0; (i < cols) && (count < maxcols); i++)
  {
    count += abs (colwidth [i]);
    if (count < maxcols) linebuf [count - 1] = SP;
  } /* for */
} /* build_del */

