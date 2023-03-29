/*****************************************************************************
 *
 * Module : REPMAKE.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the report definition window.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 17.07.95: Extra parameter added in calling v_execute
 * 22.04.95: Filename will not be asked for if parameter prn is EOS in do_report
 * 31.01.95; Using of variable warn_table added
 * 19.03.94: Multiple repetition possiblity added
 * 17.12.93: Empty control lines ok now
 * 16.11.93: Using new file selector
 * 14.11.93: Using fontdesc
 * 06.10.93: No testing of formadvance after every record in work_report
 * 10.09.93: Form feed used after writing footer
 * 09.09.93: Left margin initialized to zero only once in work_report
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "edit.h"
#include "mpagefrm.h"
#include "printer.h"
#include "process.h"
#include "resource.h"
#include "sql.h"

#include "export.h"
#include "repmake.h"

/****** DEFINES **************************************************************/

#define SYM_EOF           0     /* parser symbols */
#define SYM_BEGIN         1
#define SYM_END           2
#define SYM_FORMAT        3
#define SYM_FORMATSPEC    4
#define SYM_FORMATEXT     5
#define SYM_NUMBEGIN      6
#define SYM_NUMEND        7
#define SYM_NULL          8
#define SYM_CALC          9
#define SYM_TBLSEP       10
#define SYM_VARIABLE     11
#define SYM_EQU          12
#define SYM_BRANCH       13
#define SYM_RETURN       14
#define SYM_WPHYPHEN     15
#define SYM_WPVARSPACE   16
#define SYM_WPFORMATLINE 17
#define SYM_IDENTIFIER   18
#define SYM_NUMBER       19

#define CHR_EOF          EOS    /* parser characters */
#define CHR_BEGIN        '{'
#define CHR_END          '}'
#define CHR_FORMAT       ':'
#define CHR_FORMATSPEC   '"'
#define CHR_NUMBEGIN     '['
#define CHR_NUMEND       ']'
#define CHR_FORMATEXT    ','
#define CHR_NULL         '%'
#define CHR_CALC         '+'
#define CHR_TBLSEP       '.'
#define CHR_VARIABLE     '$'
#define CHR_EQU          '='
#define CHR_BRANCH       '>'
#define CHR_RETURN       '<'
#define CHR_STRDEL       '\''
#define CHR_WPHYPHEN     0x19
#define CHR_WPVARSPACE   0x1E
#define CHR_WPFORMATLINE 0x1F

#define SYM_SYSDATE       (-2)  /* symbolic values */
#define SYM_SYSTIME       (-3)
#define SYM_SYSTIMESTAMP  (-4)
#define SYM_COUNT         (-5)
#define SYM_WIDTH         (-6)  /* variables */
#define SYM_LENGTH        (-7)
#define SYM_TOP           (-8)
#define SYM_BOT           (-9)
#define SYM_HEAD         (-10)
#define SYM_FOOT         (-11)
#define SYM_HEADL        (-12)
#define SYM_HEADM        (-13)
#define SYM_HEADR        (-14)
#define SYM_FOOTL        (-15)
#define SYM_FOOTM        (-16)
#define SYM_FOOTR        (-17)
#define SYM_TABLE        (-18)
#define SYM_ASCII        (-19)
#define SYM_POS          (-20)
#define SYM_LEFT         (-21)
#define SYM_LIST         (-22)
#define SYM_VPOS         (-23)
#define SYM_SQL          (-24)
#define SYM_PROP         (-25)
#define SYM_SUPER        (-26)
#define SYM_SUB          (-27)
#define SYM_ITALIC       (-28)
#define SYM_BOLD         (-29)
#define SYM_UNDER        (-30)
#define SYM_PICA         (-31)
#define SYM_ELITE        (-32)
#define SYM_NLQ          (-33)
#define SYM_COND         (-34)
#define SYM_EXPAND       (-35)

#define STR_SYSDATE      "SYSDATE"
#define STR_SYSTIME      "SYSTIME"
#define STR_SYSTIMESTAMP "SYSTIMESTAMP"
#define STR_COUNT        "COUNT"

#define MAX_STACK        64     /* max tables to join */
#define MAX_ERRCHARS     37     /* max chars in error (40 - strlen (">>>")) */
#define MAX_CHARS      1024     /* max chars in linebuffer + 1 */
#define MAX_HEADER     1024     /* max chars in header */
#define MAX_IDSTRLEN   1023     /* max id string length */

#define FORMAT_LEFT     'l'     /* left aligned text */
#define FORMAT_CENTER   'c'     /* center aligned text */
#define FORMAT_RIGHT    'r'     /* right aligned text */

/****** TYPES ****************************************************************/

typedef CHAR IDSTR [MAX_IDSTRLEN + 1];

typedef struct
{
  WORD    id;                   /* the id */
  WORD    number;               /* number (format) */
  IDSTR   s;                    /* table, column, or format string, header or footer */
} ID;

typedef struct
{
  WORD id;                      /* the ID */
  BYTE chr;                     /* the char */
} REP_CHR;

typedef struct                  /* entry on stack */
{
  WORD table;                   /* table number */
  BYTE *buffer;                 /* pointer to buffer */
} ENTRY;

typedef BYTE HEADER [MAX_HEADER];

typedef struct
{
  DB      *db;                  /* actual database */
  BYTE    *report;              /* pointer to report definition */
  WORD    starttable;           /* start table of report */
  ENTRY   stack [MAX_STACK];    /* stack for tables in report */
  WORD    stackp;               /* stack pointer */
  BOOLEAN calc;                 /* TRUE, if calcsymbol has occured */
  WORD    numerrs;              /* number of report errors */
  WORD    cx;                   /* cursor x-pos when error occurs */
  WORD    cy;                   /* cursor y-pos when error occurs */
} PARSE_SPEC;

typedef struct
{
  WINDOWP    window;            /* window of process */
  LONG       count;             /* count of records */
  LONG       copies;            /* number of copies of whole report */
  WORD       lines;             /* line number for report */
  WORD       cols;              /* col number for report */
  WORD       addcols;           /* added cols for printer control codes */
  WORD       pagenr;            /* page number for report */
  WORD       maxlines;          /* max number of lines */
  WORD       maxcols;           /* max number of columns in each line */
  WORD       top;               /* number of empty lines on top */
  WORD       bottom;            /* number of empty lines on bottom */
  WORD       head;              /* number of empty lines below header */
  WORD       foot;              /* number of empty lines before footer */
  WORD       next;              /* next index in report */
  WORD       left;              /* left margin */
  BOOLEAN    wordplus;          /* wordplus format */
  BOOLEAN    cr;                /* use cr and lf as line delimiter */
  BOOLEAN    list;              /* used as list */
  BYTE       *linebuf;          /* buffer for one line */
  BYTE       *sum_total;        /* pointer to buffer containing totals */
  PARSE_SPEC parse;             /* specification for parsing */
  WORD       header_lines;      /* number of header lines */
  WORD       footer_lines;      /* number of footer lines */
  HEADER     header;            /* header itself */
  HEADER     footer;            /* footer itself */
  BOOLEAN    header_written;    /* header already written after branching */
} WORK_INF;

/****** VARIABLES ************************************************************/

LOCAL REP_CHR rep_chr [] =
{
  {SYM_EOF,          CHR_EOF},
  {SYM_BEGIN,        CHR_BEGIN},
  {SYM_END,          CHR_END},
  {SYM_FORMAT,       CHR_FORMAT},
  {SYM_FORMATSPEC,   CHR_FORMATSPEC},
  {SYM_FORMATEXT,    CHR_FORMATEXT},
  {SYM_NUMBEGIN,     CHR_NUMBEGIN},
  {SYM_NUMEND,       CHR_NUMEND},
  {SYM_NULL,         CHR_NULL},
  {SYM_CALC,         CHR_CALC},
  {SYM_TBLSEP,       CHR_TBLSEP},
  {SYM_VARIABLE,     CHR_VARIABLE},
  {SYM_EQU,          CHR_EQU},
  {SYM_BRANCH,       CHR_BRANCH},
  {SYM_RETURN,       CHR_RETURN},
  {SYM_WPHYPHEN,     CHR_WPHYPHEN},
  {SYM_WPVARSPACE,   CHR_WPVARSPACE},
  {SYM_WPFORMATLINE, CHR_WPFORMATLINE}
};

LOCAL LONG numcopies;		/* number of copies */
LOCAL WORD device;		/* output device */

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN parse_report  _((PARSE_SPEC *parsep));
LOCAL BOOLEAN parse_error   _((PARSE_SPEC *parsep, WORD inx, WORD line, WORD col, WORD error, WORD *result));
LOCAL WORD    get_id        _((BYTE *report, WORD inx, WORD *col, WORD *oldcol, ID *id));
LOCAL WORD    find_table    _((BYTE *name, PARSE_SPEC *parsep));
LOCAL WORD    find_column   _((BYTE *name, PARSE_SPEC *parsep, WORD *sp));
LOCAL WORD    find_index    _((BYTE *name, PARSE_SPEC *parsep, WORD table));
LOCAL WORD    find_var      _((BYTE *name));
LOCAL BOOLEAN send_out      _((PROC_INF *proc_inf, BYTE *s));
LOCAL BOOLEAN write_header  _((PROC_INF *proc_inf, BOOL header));
LOCAL VOID    add_values    _((DB *db, WORD vtable, BYTE *buffer, BYTE *sumbuffer));
LOCAL VOID    zero_values   _((DB *db, WORD vtable, BYTE *buffer));
LOCAL WORD    calc_lines    _((BYTE *report));
LOCAL BOOLEAN work_report   _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_report   _((PROC_INF *proc_inf));
LOCAL BOOLEAN post_report   _((PROC_INF *proc_inf));
LOCAL BOOLEAN rec2rep       _((PROC_INF *proc_inf, WORD table, VOID *buffer, BYTE *report, LONG count, BOOLEAN output, WORD *next, BOOLEAN *calc));
LOCAL VOID    field2str     _((DB *db, WORD table, VOID *buffer, WORD col, WORD colwidth, WORD num, LONG count, BYTE *formatstr, BYTE *s));
LOCAL VOID    get_line      _((BYTE *text, WORD width, WORD num, BYTE *line));
LOCAL INT     ChangeSql     _((PARSE_SPEC *pSpec, CHAR *pSQL, BOOL bReplace, LONG lCount, SHORT *pDstTable));
LOCAL LONG    copies_dialog _((WORD *pdevice));
LOCAL VOID    click_copies  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_copies    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    check_copies  _((WINDOWP window));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_repmake ()

{
  return (TRUE);
} /* init_repmake */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_repmake ()

{
  return (TRUE);
} /* term_repmake */

/*****************************************************************************/

GLOBAL WORD check_report (db, table, report, cx, cy, starttable)
DB   *db;
WORD table;
BYTE *report;
WORD *cx, *cy, *starttable;

{
  WORD       result;
  PARSE_SPEC parse;
  WORD       act_number;
  MFORM      *act_form;

  act_number = mousenumber; /* actual mouseform in REPORT window could be TEXT_CRSR */
  act_form   = mouseform;
  set_mouse (BUSY_BEE, NULL);

  parse.db              = db;
  parse.report          = report;
  parse.starttable      = FAILURE;
  parse.stack [0].table = table;
  parse.stackp          = 0;
  parse.calc            = FALSE;
  parse.numerrs         = 0;

  result = parse_report (&parse);

  if (result == REP_EDIT)
  {
    *cx = parse.cx;
    *cy = parse.cy;
  } /* if */

  if (parse.starttable == FAILURE) parse.starttable = table;

  *starttable = parse.starttable;

  set_mouse (act_number, act_form);

  return (result);
} /* check_report */

/*****************************************************************************/

GLOBAL VOID do_report (db, table, inx, dir, report, filename, device, minimize, copies, prn)
DB      *db;
WORD    table, inx, dir;
BYTE    *report, *filename;
WORD    device;
BOOLEAN minimize;
LONG    copies;
BYTE    *prn;

{
  WINDOWP    window;
  LONG       numkeys, bytes;
  PROC_INF   proc_inf, *procp;
  BYTE       *title, *p;
  STRING     name;
  TABLE_INFO t_inf;
  WORK_INF   *workp;
  BOOLEAN    to_printer, spool, save_spool, wait;
  WORD       result, i, c;
  PRNCFG     *pPrnCfg;
  PRNCFG     lprncfg;

  pPrnCfg = NULL;

  if ((filename != NULL) && (*filename != EOS))
  {
    strcpy (proc_inf.filename, filename);
    device = DEV_DISK;
  } /* if */
  else
  {
    proc_inf.filename [0] = EOS;

    if (device == FAILURE)
    {
      copies = copies_dialog (&device);

      if (device == FAILURE)
        return;
    } /* if */
  } /* else */

  numkeys = num_keys (db, table, inx);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2)
        return;

  if (! (db_acc_table (db->base, rtable (table)) & GRANT_SELECT))
  {
    dberror (db->base->basename, DB_CNOACCESS);
    return;
  } /* if */

  to_printer = FALSE;
  spool      = FALSE;
  wait       = FALSE;

  switch (device)
  {
    case DEV_SCREEN  : strcpy (proc_inf.filename, temp_name (NULL));
                       break;
    case DEV_DISK    : if (proc_inf.filename [0] == EOS)
                       {
                         p = FREETXT (FRPTSUFF);

                         table_name (db, table, name);
                         name [MAX_FILENAME - strlen (p + 1)] = EOS;
                         strcat (name, p + 1);
                         strcpy (proc_inf.filename, name);

                         if (! get_save_filename (FOPENRPT, NULL, 0L, FFILTER_RPT, NULL, NULL, FRPTSUFF, proc_inf.filename, NULL))
                           return;

                         if (! chk_filenames (proc_inf.filename))
                           return;
                       } /* if */
                       break;
    case DEV_PRINTER : if ((prn == NULL) || (*prn == EOS))
                         pPrnCfg = &prncfg;
                       else
                         pPrnCfg = load_prncfg (NULL, prn, &lprncfg, FALSE) ? &lprncfg : &prncfg;

                       if (pPrnCfg->port == PFILE)
                         if (! chk_filenames (pPrnCfg->filename))
                           return;

                       to_printer = (pPrnCfg->port >= PPORT1) && ! pPrnCfg->spool;

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
                             case 3 : return;
                           } /* switch */
                         } /* if */
                         else
                           if (! prn_check (pPrnCfg->port - PPORT1))
                             return;
                       break;
  } /* switch */

  proc_inf.db          = db;
  proc_inf.table       = table;
  proc_inf.inx         = inx;
  proc_inf.dir         = dir;
  proc_inf.cols        = 0;
  proc_inf.columns     = NULL;
  proc_inf.colwidth    = NULL;
  proc_inf.cursor      = db_newcursor (db->base);
  proc_inf.format      = 0;
  proc_inf.maxrecs     = numkeys * copies;
  proc_inf.events_ps   = events_ps;
  proc_inf.recs_pe     = recs_pe;
  proc_inf.impexpcfg   = NULL;
  proc_inf.page_format = &page_format;
  proc_inf.prncfg      = pPrnCfg;
  proc_inf.to_printer  = to_printer;
  proc_inf.binary      = FALSE;
  proc_inf.tmp         = device == DEV_SCREEN;
  proc_inf.special     = device;
  proc_inf.filelength  = 0;
  proc_inf.workfunc    = work_report;
  proc_inf.stopfunc    = stop_report;

  if (proc_inf.cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    return;
  } /* if */

  if (! v_initcursor (db, table, inx, dir, proc_inf.cursor))
  {
    db_freecursor (db->base, proc_inf.cursor);
    return;
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
    proc_inf.file = to_printer ? fopen_prn (proc_inf.filename) : (device == DEV_PRINTER) ? fopen (proc_inf.filename, WRITE_BIN) : fopen (proc_inf.filename, WRITE_BIN);

    if (proc_inf.file == NULL)
    {
      db_freecursor (db->base, proc_inf.cursor);
      file_error (ERR_FILECREATE, proc_inf.filename);
      return;
    } /* if */
  } /* else */

  bytes  = sizeof (WORK_INF);
  bytes += strlen (report) + 1;
  bytes += MAX_CHARS;

  if (odd (bytes)) bytes++;     /* db buffers on even address */

  v_tableinfo (db, table, &t_inf);
  bytes += t_inf.size;          /* add for sum_total buffer */

  title  = FREETXT (FPREPORT);
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

    workp->window        = window;
    workp->copies        = copies;
    workp->lines         = 0;
    workp->pagenr        = 1;
    workp->maxlines      = page_format.length;
    workp->maxcols       = page_format.width;
    workp->cr            = strchr (report, '\r') != NULL;       /* use cr (and lf) as line delimiter */
    p                    = procp->memory + sizeof (WORK_INF);
    workp->parse.report  = p;
    p                   += strlen (report) + 1;
    workp->linebuf       = p;
    p                   += MAX_CHARS;

    if (odd ((LONG)p)) p++; /* db buffers on even address */

    workp->sum_total        = p;
    workp->parse.db         = db;
    workp->parse.starttable = FAILURE;
    workp->parse.stackp     = -1;

    strcpy (workp->parse.report, report);
    zero_values (db, table, workp->sum_total);

    i = 0;

    while (((c = report [i]) != EOS) && (c == CHR_WPFORMATLINE) && (report [i + 1] != 'F')) /* Wordplus format */
    {
      workp->wordplus = TRUE;

      if (c != EOS)
      {
        if (i == 0)                             /* first line */
          workp->maxlines = calc_lines (report + 2) -
                            calc_lines (report + 4) -
                            calc_lines (report + 6) -
                            calc_lines (report + 8) -
                            calc_lines (report + 10);

        while (report [i++] != '\n');
      } /* if */
    } /* while */

    if (c == CHR_WPFORMATLINE)                  /* format line */
      while (report [i++] != '\n');

    if ((i != 0) && (device == DEV_DISK))
      if (fwrite (report, i, 1, procp->file) != 1)
        file_error (ERR_FILEWRITE, procp->filename);

    workp->parse.report += i;           /* format only once */

    start_process (window, minimize_process, TRUE);
  } /* if */
} /* do_report */

/*****************************************************************************/

LOCAL WORD parse_report (parsep)
PARSE_SPEC *parsep;

{
  WORD       result;
  WORD       table, src_table, sp, line, var;
  WORD       inx, oldinx, src_inx;
  WORD       col, oldcol, src_col;
  WORD       src_column, src_index, dst_index;
  BYTE       *rep;
  ID         id;
  INDEX_INFO src_inf, dst_inf;
  INT        iError;

  result = REP_OK;
  table  = parsep->stack [0].table;
  rep    = parsep->report;
  line   = col = oldcol = 1;
  inx    = oldinx = 0;

  while (rep [inx] != EOS)
  {
    while ((rep [inx] != LF) && (rep [inx] != EOS))
    {
      if (rep [inx] != CHR_BEGIN)       /* regular char */
      {
        col++;
        inx++;
      } /* if */
      else
      {
        inx = get_id (rep, oldinx = inx, &col, &oldcol, &id); /* CHR_BEGIN */
        inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

        if (id.id == SYM_VARIABLE)
        {
          var = find_var (id.s);

          if (var == FAILURE)
            if (parse_error (parsep, oldinx, line, oldcol, ERR_VAREXP, &result)) return (result);

          if (var != SYM_LIST)
          {
            inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

            if (id.id != SYM_EQU)
              if (parse_error (parsep, oldinx, line, oldcol, ERR_EQUEXP, &result)) return (result);

            inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
          } /* if */

          switch (var)
          {
            case SYM_TABLE : if (id.id != SYM_IDENTIFIER)
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_IDEXP, &result)) return (result);

                             src_table = table;
                             table     = find_table (id.s, parsep);

                             if (table == FAILURE)
                             {
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_TBLEXP, &result)) return (result);
                               table = src_table;
                             } /* if */

                             if (parsep->starttable == FAILURE) parsep->starttable = parsep->stack [parsep->stackp].table = table;
                             break;
            case SYM_HEADL :
            case SYM_HEADM :
            case SYM_HEADR :
            case SYM_FOOTL :
            case SYM_FOOTM :
            case SYM_FOOTR : if (id.id != SYM_FORMATSPEC)
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_FORMATEXP, &result)) return (result);
                             break;
            case SYM_LIST  : break;
            case SYM_SQL   : if (id.id != SYM_FORMATSPEC)
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_FORMATEXP, &result)) return (result);

                             src_table = table;
                             
                             if ((iError = ChangeSql (parsep, id.s, FALSE, 0L, &table)) != SUCCESS)
                             {
                               table = src_table;
                               if (parse_error (parsep, oldinx, line, oldcol, iError, &result)) return (result);
                             } /* if */
                             else
                               if (parsep->stackp < MAX_STACK - 1)
                                 parsep->stack [++parsep->stackp].table = table;
                               else
                                 if (parse_error (parsep, oldinx, line, oldcol, ERR_TOOMANYBRANCHES, &result)) return (result);
                             break;
            default        : if (id.id != SYM_NUMBER)
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_NUMBEREXP, &result)) return (result);

                             if (id.number < 0)
                               if (parse_error (parsep, oldinx, line, oldcol, ERR_LESSZERO, &result)) return (result);
          } /* switch */

          inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
        } /* if */
        else
        {
          if ((id.id == SYM_IDENTIFIER) || (id.id == SYM_NULL) || (id.id == SYM_RETURN) || (id.id == SYM_CALC))
          {
            if ((id.id == SYM_IDENTIFIER) || (id.id == SYM_NULL))
            {
              if (id.id == SYM_NULL) inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

              src_inx    = oldinx;      /* save old values */
              src_col    = oldcol;
              src_column = find_column (id.s, parsep, &sp);
              src_index  = find_index (id.s, parsep, table);

              if ((src_column == FAILURE) && (src_index == FAILURE))
                if (parse_error (parsep, oldinx, line, oldcol, ERR_COLEXP, &result)) return (result);

              inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

              if ((id.id == SYM_FORMAT) || (id.id == SYM_FORMATEXT))
              {
                if ((src_column == FAILURE) && (src_index != FAILURE)) /* format with index */
                  if (parse_error (parsep, src_inx, line, src_col, ERR_COLEXP, &result)) return (result);

                if (id.id == SYM_FORMAT)
                {
                  inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                  if ((id.id != SYM_NUMBER) && (id.id != SYM_FORMATSPEC))
                    if (parse_error (parsep, oldinx, line, oldcol, ERR_FORMATEXP, &result)) return (result);

                  inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
                } /* if */

                if (id.id == SYM_FORMATEXT)
                {
                  inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                  if (id.id != SYM_FORMATSPEC)
                    if (parse_error (parsep, oldinx, line, oldcol, ERR_FORMATEXP, &result)) return (result);

                  inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
                } /* if */
                else
                  if (id.id == SYM_FORMAT)
                  {
                    inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                    if (id.id != SYM_NUMBEGIN)
                      if (parse_error (parsep, oldinx, line, oldcol, ERR_FORMATEXP, &result)) return (result);

                    inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
                  } /* if, else */
              } /* if */
              else
                if (id.id == SYM_BRANCH)
                {
                  if ((src_column != FAILURE) && (src_index == FAILURE)) /* branch with column */
                    if (parse_error (parsep, src_inx, line, src_col, ERR_INXEXP, &result)) return (result);

                  if (parsep->calc)
                    if (parse_error (parsep, oldinx, line, oldcol, ERR_BRANCHNOTALLOWED, &result)) return (result);

                  inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                  if (id.id == SYM_IDENTIFIER)
                  {
                    src_inx   = oldinx; /* save old values */
                    src_col   = oldcol;
                    src_table = table;
                    table     = find_table (id.s, parsep);
                    inx       = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                    if (table != FAILURE)
                    {
                      if (parsep->stackp < MAX_STACK - 1)
                        parsep->stack [++parsep->stackp].table = table;
                      else
                        if (parse_error (parsep, oldinx, line, oldcol, ERR_TOOMANYBRANCHES, &result)) return (result);

                      if (id.id == SYM_TBLSEP)
                      {
                        inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);

                        if (id.id == SYM_IDENTIFIER)
                        {
                          dst_index = find_index (id.s, parsep, table);

                          if (dst_index != FAILURE)
                          {
                            if (src_index != FAILURE)
                            {
                              db_indexinfo (parsep->db->base, src_table, src_index, &src_inf);
                              db_indexinfo (parsep->db->base, table, dst_index, &dst_inf);

                              if (src_inf.type != dst_inf.type)
                                if (parse_error (parsep, oldinx, line, oldcol, ERR_TYPEMISMATCH, &result)) return (result);
                            } /* if */
                          } /* if */
                          else
                            if (parse_error (parsep, oldinx, line, oldcol, ERR_INXEXP, &result)) return (result);

                          inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
                        } /* if */
                        else
                          if (parse_error (parsep, oldinx, line, oldcol, ERR_INXEXP, &result)) return (result);
                      } /* if */
                      else      /* no table separator, use integrity rules */
                        if (find_rel (parsep->db, src_table, src_index, table) == FAILURE)
                          if (parse_error (parsep, src_inx, line, src_col, ERR_BRANCHNOTALLOWED, &result)) return (result);
                    } /* if */
                    else
                    {
                      table = src_table;
                      if (parse_error (parsep, src_inx, line, src_col, ERR_TBLEXP, &result)) return (result);
                    } /* else */
                  } /* if */
                  else
                    if (parse_error (parsep, oldinx, line, oldcol, ERR_TBLEXP, &result)) return (result);
                } /* if, else */
            } /* if */
            else                        /* SYM_RETURN  or SYM_CALC */
              if (id.id == SYM_RETURN)
              {
                parsep->calc = FALSE;

                if (parsep->stackp > 0)
                  table = parsep->stack [--parsep->stackp].table;
                else
                  if (parse_error (parsep, oldinx, line, oldcol, ERR_RETURNNOTALLOWED, &result)) return (result);

                inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
              } /* if */
              else                      /* SYM_CALC */
              {
                if (parsep->calc)
                  if (parse_error (parsep, oldinx, line, oldcol, ERR_CALCNOTALLOWED, &result)) return (result);

                parsep->calc = TRUE;

                inx = get_id (rep, oldinx = inx, &col, &oldcol, &id);
              } /* else, else */
          } /* if */
          else
            if (parse_error (parsep, oldinx, line, oldcol, ERR_COLEXP, &result)) return (result);

          if (id.id != SYM_END)
            if (parse_error (parsep, oldinx, line, oldcol, ERR_ENDEXP, &result)) return (result);
        } /* else */
      } /* else */
    } /* while */

    if (rep [inx] == LF)
    {
      col = oldcol = 1;
      line++;
      inx++;
    } /* if */
  } /* while */

  if (parsep->stackp > 0) parse_error (parsep, inx, line, oldcol, ERR_TOOFEWRETURNS, &result);
  if (parsep->numerrs > 0) result = REP_CANCEL;

  return (result);
} /* parse_report */

/*****************************************************************************/

LOCAL BOOLEAN parse_error (parsep, inx, line, col, error, result)
PARSE_SPEC *parsep;
WORD       inx, line, col, error, *result;

{
  LONGSTR s;
  STRING  rep;
  BYTE    *p;

  while (isspace (parsep->report [inx]) && (parsep->report [inx] != LF)) inx++;

  strncpy (rep, &parsep->report [inx], MAX_ERRCHARS);
  rep [MAX_ERRCHARS] = EOS;
  if ((p = strchr (rep, CR)) != NULL) *p = EOS;
  if ((p = strchr (rep, LF)) != NULL) *p = EOS;

  sprintf (s, alerts [error], rep, line, col);

  *result = open_alert (s) - 1;

  parsep->numerrs++;
  parsep->cx = col - 1;
  parsep->cy = line - 1;

  return ((*result == REP_EDIT) || (*result == REP_CANCEL));
} /* parse_error */

/*****************************************************************************/

LOCAL WORD get_id (report, inx, col, oldcol, id)
BYTE *report;
WORD inx, *col, *oldcol;
ID   *id;

{
  WORD i, old;

  old     = inx;
  id->id  = FAILURE;

  while (isspace (report [inx]) && (report [inx] != LF)) inx++;

  if ((col != NULL) && (oldcol != NULL)) *oldcol = *col + inx - old;

  for (i = 0; (i < SYM_IDENTIFIER) && (id->id == FAILURE); i++)
    if (report [inx] == rep_chr [i].chr)
    {
      id->id = rep_chr [i].id;
      if (id->id != CHR_EOF) inx++;

      if ((rep_chr [i].chr == CHR_CALC) && isdigit (report [inx])) /* positive number */
      {
        inx--;
        id->id = FAILURE;
      } /* if */
      break;
    } /* if */

  if (id->id == SYM_VARIABLE)
  {
    id->s [0] = CHR_VARIABLE;
    i         = 1;

    if (isalpha (ch_ascii (report [inx])))   /* identifier */
      while (isalnum (ch_ascii (report [inx])) || (report [inx] == '_'))
        id->s [i++] = report [inx++];

    id->s [i] = EOS;
  } /* if */

  if (id->id == SYM_FORMATSPEC) /* read format string */
  {
    i = 0;

    while ((i < LONGSTRLEN) && (report [inx] != CHR_FORMATSPEC) && (report [inx] != CHR_EOF) && (report [inx] != LF))
      id->s [i++] = report [inx++];

    id->s [i] = EOS;

    if (report [inx] == CHR_FORMATSPEC)
      inx++;
    else
      id->id = FAILURE;
  } /* if */

  if (id->id == SYM_NUMBEGIN)   /* read line number */
  {
    i = 0;

    while ((i < LONGSTRLEN) && (report [inx] != CHR_NUMEND) && (report [inx] != CHR_EOF) && (report [inx] != LF))
      id->s [i++] = report [inx++];

    id->s [i] = EOS;

    if (report [inx] == CHR_NUMEND)
    {
      id->number = atoi (id->s);
      inx++;
    } /* if */
    else
      id->id = FAILURE;
  } /* if */

  if (id->id == FAILURE)        /* no single char identifier */
  {
    if (isalpha (ch_ascii (report [inx])))   /* identifier */
    {
      id->id = SYM_IDENTIFIER;
      i      = 0;

      while (isalnum (ch_ascii (report [inx])) || (report [inx] == '_'))
        id->s [i++] = report [inx++];

      id->s [i] = EOS;
    } /* if */
    else
      if (isdigit (report [inx]) || (report [inx] == '+') || (report [inx] == '-')) /* number */
        if (isdigit (report [inx]) || isdigit (report [inx + 1])) /* signed number */
        {
          id->id = SYM_NUMBER;
          i      = 0;

          while (isdigit (ch_ascii (report [inx])) || (report [inx] == '+')  || (report [inx] == '-'))
            id->s [i++] = report [inx++];

          id->s [i]  = EOS;
          id->number = atoi (id->s);
        } /* if, if, else */
  } /* if */

  if (col != NULL) *col += (inx - old);

  return (inx);
} /* get_id */

/*****************************************************************************/

LOCAL WORD find_table (name, parsep)
BYTE       *name;
PARSE_SPEC *parsep;

{
  WORD       table;
  TABLE_INFO t_inf;

  strcpy (t_inf.name, name);
  table = db_tableinfo (parsep->db->base, FAILURE, &t_inf);

  if (table != FAILURE)
    if (! (db_acc_table (parsep->db->base, table) & GRANT_SELECT)) table = FAILURE;

  return (table);
} /* find_table */

/*****************************************************************************/

LOCAL WORD find_column (name, parsep, sp)
BYTE       *name;
PARSE_SPEC *parsep;
WORD       *sp;

{
  WORD       column, stk, table;
  FIELD_INFO f_inf;

  column = FAILURE;
  stk    = *sp = parsep->stackp;

  while ((stk >= 0) && (column == FAILURE))
  {
    table = rtable (parsep->stack [stk].table);
    strcpy (f_inf.name, name);

    if ((column = db_fieldinfo (parsep->db->base, table, column, &f_inf)) != FAILURE)
      if (db_acc_column (parsep->db->base, table, column) & GRANT_SELECT)
        *sp = stk;
      else
        column = FAILURE;

    if (column == FAILURE) stk--;
  } /* while */

  if (column == FAILURE)
  {
    str_upper (name);
    if (strcmp (name, STR_SYSDATE     ) == 0) column = SYM_SYSDATE;
    if (strcmp (name, STR_SYSTIME     ) == 0) column = SYM_SYSTIME;
    if (strcmp (name, STR_SYSTIMESTAMP) == 0) column = SYM_SYSTIMESTAMP;
    if (strcmp (name, STR_COUNT       ) == 0) column = SYM_COUNT;
  } /* if */

  return (column);
} /* find_column */

/*****************************************************************************/

LOCAL WORD find_index (name, parsep, table)
BYTE       *name;
PARSE_SPEC *parsep;
WORD       table;

{
  WORD       index;
  INDEX_INFO i_inf;

  index = FAILURE;
  table = rtable (table);

  strcpy (i_inf.name, name);
  index = db_indexinfo (parsep->db->base, table, FAILURE, &i_inf);

  if (index != FAILURE)
    if (! (db_acc_index (parsep->db->base, table, index) & GRANT_SELECT)) index = FAILURE;

  return (index);
} /* find_index */

/*****************************************************************************/

LOCAL WORD find_var (name)
BYTE *name;

{
  WORD var, i;

  var = FAILURE;

  str_upper (name);

  for (i = REPWIDTH; (i <= REPEXPANDED) && (var == FAILURE); i++)
    if (strcmp (name, FREETXT (i)) == 0) var = REPWIDTH - i + SYM_WIDTH;

  return (var);
} /* find_var */

/*****************************************************************************/

LOCAL BOOLEAN send_out (proc_inf, s)
PROC_INF *proc_inf;
BYTE     *s;

{
  BOOLEAN  ok, lf, cr, format;
  WORD     cols, i;
  WORK_INF *workp;
  LONGSTR  spaces;
  BYTE     nl [2];

  workp = (WORK_INF *)proc_inf->memory;
  ok    = TRUE;
  cols  = strlen (s);

  if (cols > 0)
  {
    format = s [0] == CHR_WPFORMATLINE;         /* wordplus format line */
    lf     = s [cols - 1] == '\n';
    cr     = (cols > 1) && (s [cols - 2] == '\r');

    if (cr)
    {
      s [cols - 2] = '\n';
      s [cols - 1] = EOS;
      cols--;
    } /* if */

    if (workp->cr)
    {
      nl [0] = '\r';
      nl [1] = EOS;
    } /* if */
    else
      nl [0] = EOS;
    
    if (s [0] == '\f') workp->lines = 0;        /* new page */
    if (! format)
      if (lf) workp->lines++;                   /* new line */

    if (lf)
    {
      cols--;                                   /* delete lf char */
      s [cols] = EOS;
    } /* if */

    if (! format)
      if (cols > workp->maxcols - workp->cols + workp->addcols) cols = workp->maxcols - workp->cols + workp->addcols;

    s [cols] = EOS;

    if (! format && (workp->cols == 0))                                 /* first col in a line */
    {
      i = min (workp->left, LONGSTRLEN);
      mem_set (spaces, SP, i);
      spaces [i] = EOS;
    } /* if */
    else
      spaces [0] = EOS;

    workp->cols += cols;
    if (lf) workp->cols = workp->addcols = 0;

    switch (proc_inf->special)
    {
      case DEV_SCREEN  : if (format) break;
                         for (i = 0; s [i]; i++)
                           if (s [i] == CHR_WPVARSPACE)
                             s [i] = ' ';
                           else
                             if (s [i] == CHR_WPHYPHEN) s [i] = '-';
      case DEV_DISK    : if ((workp->lines <= 1) && ! workp->header_written) /* first line of page */
                         {
                           for (i = 0; i < workp->top; i++)
                             ok = text_wrln (proc_inf->file, nl);

                           ok = write_header (proc_inf, TRUE);

                           for (i = 0; i < workp->head; i++)
                             ok = text_wrln (proc_inf->file, nl);

                           workp->lines += workp->top + workp->header_lines + workp->head;
                         } /* if */

                         ok = text_write (proc_inf->file, spaces);
                         ok = text_write (proc_inf->file, s);
                         if (cr) ok = text_write (proc_inf->file, "\r");
                         if (lf) ok = text_wrln (proc_inf->file, "");

                         if (workp->lines >= workp->maxlines - workp->foot - workp->footer_lines - workp->bottom)       /* until last line of page */
                         {
                           for (i = 0; i < workp->foot; i++)
                             ok = text_wrln (proc_inf->file, nl);

                           ok = write_header (proc_inf, FALSE);

                           for (i = 0; i < workp->bottom; i++)
                             ok = text_wrln (proc_inf->file, nl);

                           workp->lines += workp->foot + workp->footer_lines + workp->bottom;
                         } /* if */
                         break;
      case DEV_PRINTER : if (! format)
                         {
                           if ((workp->lines <= 1) && ! workp->header_written) /* first line of page */
                           {
                             for (i = 0; i < workp->top; i++)
                               ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             ok = write_header (proc_inf, TRUE);

                             for (i = 0; i < workp->head; i++)
                               ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             workp->lines += workp->top + workp->header_lines + workp->head;
                           } /* if */

                           ok = str_to_prn (spaces, proc_inf->file, proc_inf->to_printer);
                           ok = str_to_prn (s, proc_inf->file, proc_inf->to_printer);
                           if (lf) ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                           if (workp->lines >= workp->maxlines - workp->foot - workp->footer_lines - workp->bottom)     /* until last line of page */
                           {
                             for (i = 0; i < workp->foot; i++)
                               ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             ok = write_header (proc_inf, FALSE);

                             if (proc_inf->page_format->formadvance)
                               ok = str_to_prn ("\f", proc_inf->file, proc_inf->to_printer);
                             else
                               for (i = 0; i < workp->bottom; i++)
                                 ok = str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             workp->lines += workp->foot + workp->footer_lines + workp->bottom;
                           } /* if */
                         } /* if */
                         break;
    } /* switch */

    if (workp->lines >= workp->maxlines)
    {
      workp->lines = 0;
      workp->pagenr++;
    } /* if */

    if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
  } /* if */

  return (ok);
} /* send_out */

/*****************************************************************************/

LOCAL BOOLEAN write_header (proc_inf, header)
PROC_INF *proc_inf;
BOOL     header;

{
  BOOLEAN  ok;
  WORK_INF *workp;
  HEADER   s, t, u;
  BYTE     *p, format;
  WORD     i, len, diff, left;

  ok    = TRUE;
  workp = (WORK_INF *)proc_inf->memory;

  scan_header (proc_inf->db, proc_inf->table, proc_inf->inx, proc_inf->dir, workp->pagenr, header ? workp->header : workp->footer, s);

  for (p = s; *p != EOS; p++)
  {
    for (i = 0; *p != LF; t [i++] = *p++);
    t [i++] = *p;
    t [i]   = EOS;

    format = tolower (t [0]);
    strcpy (t, &t [1]);

    len  = strlen (t) - 2;                               /* 2 because of \r\n */
    diff = len - workp->maxcols;

    if (diff > 0)                                        /* string to large */
    {
      strcpy (&t [len - diff], &t [len]);
      len = workp->maxcols;
    } /* if */

    mem_set (u, ' ', sizeof (u));

    left = min (workp->left, LONGSTRLEN);
    
    switch (format)
    {
      case FORMAT_LEFT   : u [left] = EOS;                              break;
      case FORMAT_CENTER : u [left + (workp->maxcols - len) / 2] = EOS; break;
      case FORMAT_RIGHT  : u [left + workp->maxcols - len] = EOS;       break;
      default            : u [left] = EOS;                              break;
    } /* switch */

    switch (proc_inf->special)
    {
      case DEV_SCREEN  :
      case DEV_DISK    : ok = text_write (proc_inf->file, u);
                         ok = text_write (proc_inf->file, t);
                         break;
      case DEV_PRINTER : ok = str_to_prn (u, proc_inf->file, proc_inf->to_printer);
                         ok = str_to_prn (t, proc_inf->file, proc_inf->to_printer);
                         break;
    } /* switch */
  } /* for */

  if (header) workp->header_written = TRUE;

  return (ok);
} /* write_header */

/*****************************************************************************/

LOCAL VOID add_values (db, vtable, buffer, sumbuffer)
DB   *db;
WORD vtable;
BYTE *buffer, *sumbuffer;

{
  TABLE_INFO t_inf;
  FIELD_INFO f_inf;
  CALC_TYPE  res, sum;
  DOUBLE     dbl_res, dbl_sum;
  WORD       i, table;
  BOOLEAN    calc;

  table = rtable (vtable);

  v_tableinfo (db, vtable, &t_inf);

  for (i = 1; i < t_inf.cols; i++)
  {
    db_fieldinfo (db->base, table, i, &f_inf);

    switch (f_inf.type)
    {
      case TYPE_WORD   :
      case TYPE_LONG   :
      case TYPE_FLOAT  :
      case TYPE_CFLOAT : calc = TRUE;  break;
      default          : calc = FALSE; break;
    } /* switch */

    if (calc && ! is_null (f_inf.type, buffer + f_inf.addr))
    {
      db_getfield (db->base, table, i, buffer, &sum);
      db_getfield (db->base, table, i, sumbuffer, &res);

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

      db_setfield (db->base, table, i, sumbuffer, &res);
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

LOCAL WORD calc_lines (report)
BYTE *report;

{
  return (10 * (report [0] - '0') + (report [1] - '0'));
} /* calc_lines */

/*****************************************************************************/

LOCAL BOOLEAN work_report (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN  ok, more;
  WORK_INF *workp;
  WORD     i;
  BOOLEAN  calc;
  BYTE     nl [2];

  ok    = calc = FALSE;
  workp = (WORK_INF *)proc_inf->memory;
  more  = v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir);

  if (! more)
    if (--workp->copies > 0)
    {
      post_report (proc_inf);

      more = v_initcursor (proc_inf->db, proc_inf->table, proc_inf->inx, (LONG)proc_inf->dir, proc_inf->cursor);

      if (more)
        more = v_movecursor (proc_inf->db, proc_inf->cursor, (LONG)proc_inf->dir);

      workp->count  = 0;
      workp->lines  = 0;
      workp->pagenr = 1;
      zero_values (proc_inf->db, proc_inf->table, workp->sum_total);
    } /* if, if */

  if (more)
    if (v_read (proc_inf->db, proc_inf->table, proc_inf->db->buffer, proc_inf->cursor, 0L, FALSE))
    {
      if (proc_inf->use_calc) v_execute (proc_inf->db, proc_inf->table, proc_inf->calccode, proc_inf->db->buffer, proc_inf->actrec + 1, NULL);
      add_values (proc_inf->db, proc_inf->table, proc_inf->db->buffer, workp->sum_total);

      if (! workp->list)
      {
        workp->lines  = 0;
        workp->pagenr = 1;
      } /* if */

      workp->next         = 0;
      workp->header_lines = 0;
      workp->footer_lines = 0;
      workp->header [0]   = EOS;	/* start with fresh header and footer on each document */
      workp->footer [0]   = EOS;
      workp->left         = 0;
      ok                  = rec2rep (proc_inf, proc_inf->table, proc_inf->db->buffer, workp->parse.report, ++workp->count, TRUE, &workp->next, &calc);

      if (calc) workp->parse.calc = TRUE;

      if (ok && (workp->lines != 0) && ! workp->list)
      {
        if (workp->cr)
        {
          nl [0] = '\r';
          nl [1] = EOS;
        } /* if */
        else
          nl [0] = EOS;
    
        switch (proc_inf->special)
        {
          case DEV_SCREEN  :
          case DEV_DISK    : if (workp->wordplus)
                               ok &= text_write (proc_inf->file, "\f");
                             else
                             {
                               for (i = 0; i < workp->maxlines - workp->lines - workp->foot - workp->footer_lines - workp->bottom; i++)
                                 ok &= text_wrln (proc_inf->file, nl);

                               for (i = 0; i < workp->foot; i++)
                                 ok &= text_wrln (proc_inf->file, nl);

                               ok &= write_header (proc_inf, FALSE);

                               for (i = 0; i < workp->bottom; i++)
                                 ok = text_wrln (proc_inf->file, nl);
                             } /* else */
                             break;
          case DEV_PRINTER : for (i = 0; i < workp->maxlines - workp->lines - workp->foot - workp->footer_lines - workp->bottom; i++)
                               ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             for (i = 0; i < workp->foot; i++)
                               ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                             ok &= write_header (proc_inf, FALSE);

                             if (proc_inf->page_format->formadvance)
                               ok &= str_to_prn ("\f", proc_inf->file, proc_inf->to_printer);
                             else
                               for (i = 0; i < workp->bottom; i++)
                                 ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);
                             break;
        } /* switch */

        if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
      } /* if */
    } /* if, if */

  return (ok);
} /* work_report */

/*****************************************************************************/

LOCAL BOOLEAN stop_report (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;

  ok = post_report (proc_inf);

  if (proc_inf->special == DEV_SCREEN)
  {
    fclose (proc_inf->file);
    proc_inf->file = NULL;

    ok = open_edit (NIL, proc_inf->filename, &fontdesc);
  } /* if */

  return (ok);
} /* stop_report */

/*****************************************************************************/

LOCAL BOOLEAN post_report (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok, calc;
  WORK_INF *workp;
  WORD     i;
  BYTE     nl [2];

  ok    = TRUE;
  workp = (WORK_INF *)proc_inf->memory;

  if (workp->parse.calc)
    ok = rec2rep (proc_inf, proc_inf->table, workp->sum_total, workp->parse.report, workp->count, workp->count != 0, &workp->next, &calc);

  if (ok && (workp->lines != 0) && workp->list)
  {
    if (workp->cr)
    {
      nl [0] = '\r';
      nl [1] = EOS;
    } /* if */
    else
      nl [0] = EOS;
    
    switch (proc_inf->special)
    {
      case DEV_SCREEN  :
      case DEV_DISK    : if (workp->wordplus)
                           ok &= text_write (proc_inf->file, "\f");
                         else
                         {
                           for (i = 0; i < workp->maxlines - workp->lines - workp->foot - workp->footer_lines - workp->bottom; i++)
                             ok &= text_wrln (proc_inf->file, nl);

                           for (i = 0; i < workp->foot; i++)
                             ok &= text_wrln (proc_inf->file, nl);

                           ok &= write_header (proc_inf, FALSE);

                           for (i = 0; i < workp->bottom; i++)
                             ok = text_wrln (proc_inf->file, nl);
                         } /* else */
                         break;
      case DEV_PRINTER : for (i = 0; i < workp->maxlines - workp->lines - workp->foot - workp->footer_lines - workp->bottom; i++)
                           ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                         for (i = 0; i < workp->foot; i++)
                           ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);

                         ok &= write_header (proc_inf, FALSE);

                         if (proc_inf->page_format->formadvance)
                           ok &= str_to_prn ("\f", proc_inf->file, proc_inf->to_printer);
                         else
                           for (i = 0; i < workp->bottom; i++)
                             ok &= str_to_prn ("\r\n", proc_inf->file, proc_inf->to_printer);
                         break;
    } /* switch */

    if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
  } /* if */

  return (ok);
} /* post_report */

/*****************************************************************************/

LOCAL BOOLEAN rec2rep (proc_inf, table, buffer, report, count, output, next, calc)
PROC_INF *proc_inf;
WORD     table;
VOID     *buffer;
BYTE     *report;
LONG     count;
BOOLEAN  output;
WORD     *next;
BOOLEAN  *calc;

{
  BOOLEAN    ok, done, ready, null, nulltest;
  WORK_INF   *workp;
  PARSE_SPEC *parsep;
  WORD       rcol, pcol, sp, var, cols, width;
  WORD       src_table, src_column, src_index;
  WORD       dst_table, dst_index;
  WORD       dst_next;
  VOID       *dst_buffer;
  LONG       dst_count;
  BOOLEAN    dst_calc, format;
  BYTE       *r, *p, ch, *sum_total;
  ID         id;
  LONGSTR    colstr;
  TABLE_INFO t_inf;
  FIELD_INFO f_inf;
  CURSOR     cursor;
  KEY        keyval;
  SQL_RESULT sql_result;
  STRING     code;

  ok        = TRUE;
  done      = FALSE;
  workp     = (WORK_INF *)proc_inf->memory;
  parsep    = &workp->parse;
  rcol      = *next;
  *calc     = FALSE;
  r         = report;
  p         = workp->linebuf;
  src_table = rtable (table);

  parsep->stackp++;
  parsep->stack [parsep->stackp].table  = src_table;
  parsep->stack [parsep->stackp].buffer = buffer;

  while (ok && ! done)
  {
    pcol  = 0;
    ready = null = FALSE;

    while (ok && ! ready)
    {
      if (r [rcol] == CHR_WPFORMATLINE)                 /* Wordplus format */
      {
        while ((p [pcol++] = r [rcol++]) != '\n');      /* copy format line */
        ready = TRUE;
      } /* if */
      else
      {
        while (((ch = r [rcol]) != CHR_BEGIN) && (ch != '\n') && (ch != EOS))
          p [pcol++] = r [rcol++];

        if (ch == EOS)
        {
          if (pcol > 0)
          {
            p [pcol++] = '\r';
            p [pcol++] = '\n';
          } /* if */

          ready = done = TRUE;                          /* end of document */
        } /* if */
        else
          if (ch == '\n')
          {
            p [pcol++] = r [rcol++];                    /* '\n' */
            ready = TRUE;                               /* end of line */
          } /* if */
          else
          {
            rcol = get_id (r, rcol, NULL, NULL, &id); /* CHR_BEGIN */
            rcol = get_id (r, rcol, NULL, NULL, &id);

            if ((id.id == SYM_IDENTIFIER) || (id.id == SYM_NULL))
            {
              nulltest = id.id == SYM_NULL;

              if (nulltest) rcol = get_id (r, rcol, NULL, NULL, &id);

              src_column = find_column (id.s, parsep, &sp);
              src_index  = find_index (id.s, parsep, src_table);
              rcol       = get_id (r, rcol, NULL, NULL, &id);

              if (src_column >= 0) db_fieldinfo (proc_inf->db->base, parsep->stack [sp].table, src_column, &f_inf);

              if ((id.id == SYM_FORMAT) || (id.id == SYM_FORMATEXT))
              {
                if (nulltest && (src_column >= 0)) null = is_null (f_inf.type, parsep->stack [sp].buffer + f_inf.addr);
                format = FALSE;

                if (id.id == SYM_FORMAT)								/* ':' */
                {
                  format = TRUE;
                  rcol   = get_id (r, rcol, NULL, NULL, &id);
                  width  = id.number;

                  switch (id.id)
                  {
                    case SYM_NUMBER     : field2str (proc_inf->db,
                                                     parsep->stack [sp].table,
                                                     parsep->stack [sp].buffer,
                                                     src_column,
                                                     width,
                                                     FAILURE,
                                                     count,
                                                     NULL,
                                                     colstr);
                                          break;
                    case SYM_FORMATSPEC : field2str (proc_inf->db,
                                                     parsep->stack [sp].table,
                                                     parsep->stack [sp].buffer,
                                                     src_column,
                                                     0,
                                                     FAILURE,
                                                     count,
                                                     id.s,
                                                     colstr);
                                          break;
                  } /* switch */

                  mem_move (p + pcol, colstr, strlen (colstr));
                  pcol += strlen (colstr);
                  rcol  = get_id (r, rcol, NULL, NULL, &id);
                } /* if */

                if (id.id == SYM_FORMATEXT)
                {
                  if (! format)         /* extended format only */
                  {
                    field2str (proc_inf->db,
                               parsep->stack [sp].table,
                               parsep->stack [sp].buffer,
                               src_column,
                               0,
                               FAILURE,
                               count,
                               NULL,
                               colstr);

                    mem_move (p + pcol, colstr, strlen (colstr));
                    pcol += strlen (colstr);
                  } /* if */

                  rcol = get_id (r, rcol, NULL, NULL, &id);

                  if ((src_column < FAILURE) || ! is_null (f_inf.type, parsep->stack [sp].buffer + f_inf.addr))
                  {
                    mem_move (p + pcol, id.s, strlen (id.s));
                    pcol += strlen (id.s);
                  } /* if */

                  rcol = get_id (r, rcol, NULL, NULL, &id);
                } /* if */
                else
                  if (id.id == SYM_FORMAT)
                  {
                    rcol  = get_id (r, rcol, NULL, NULL, &id);
                    pcol -= strlen (colstr); /* don't use whole line */

                    field2str (proc_inf->db,
                               parsep->stack [sp].table,
                               parsep->stack [sp].buffer,
                               src_column,
                               width,
                               id.number - 1, /* line #1 is the first line */
                               count,
                               NULL,
                               colstr);

                    if (nulltest)
                      if (strspn (colstr, " ") == strlen (colstr))
                        null = TRUE;            /* every empty line counts as a null line */

                    mem_move (p + pcol, colstr, strlen (colstr));
                    pcol += strlen (colstr);

                    rcol = get_id (r, rcol, NULL, NULL, &id);
                  } /* if, else */
              } /* if */
              else
                if (id.id != SYM_BRANCH)        /* no format given */
                {
                  if (nulltest && (src_column >= 0)) null = is_null (f_inf.type, parsep->stack [sp].buffer + f_inf.addr);
                  field2str (proc_inf->db,
                             parsep->stack [sp].table,
                             parsep->stack [sp].buffer,
                             src_column,
                             0,
                             FAILURE,
                             count,
                             NULL,
                             colstr);

                  mem_move (p + pcol, colstr, strlen (colstr));
                  pcol += strlen (colstr);
                } /* if */
                else                            /* SYM_BRANCH */
                {
                  p [pcol] = EOS;               /* print beginning of line */
                  if (output) ok = send_out (proc_inf, p);

                  if (ok)
                  {
                    pcol       = 0;
                    rcol       = get_id (r, rcol, NULL, NULL, &id);
                    dst_table  = find_table (id.s, parsep);
                    dst_index  = FAILURE;
                    dst_count  = 0;
                    rcol       = get_id (r, rcol, NULL, NULL, &id);
                    ok         = dst_table != FAILURE;
                    dst_buffer = NULL;
                    sum_total  = NULL;

                    if (ok)
                    {
                      if (id.id == SYM_TBLSEP)
                      {
                        rcol      = get_id (r, rcol, NULL, NULL, &id);
                        dst_index = find_index (id.s, parsep, dst_table);
                        rcol      = get_id (r, rcol, NULL, NULL, &id);
                      } /* if */
                      else
                        dst_index = find_rel (proc_inf->db, src_table, src_index, dst_table);

                      ok = dst_index != FAILURE;

                      if (ok)
                      {
                        db_tableinfo (proc_inf->db->base, dst_table, &t_inf);
                        dst_buffer = mem_alloc (t_inf.size);
                        sum_total  = mem_alloc (t_inf.size);
                        ok         = (dst_buffer != NULL) && (sum_total != NULL);
                      } /* if */
                    } /* if */

                    if (! ok)
                    {
                      if ((dst_table == FAILURE) || (dst_index == FAILURE))
                        dberror (db->base->basename, DB_CNOACCESS);
                      else
                        hndl_alert (ERR_NOMEMORY);
                    } /* if */
                    else
                    {
                      dst_count = 0;
                      dst_next  = rcol;
                      zero_values (proc_inf->db, dst_table, sum_total);
                      db_buildkey (proc_inf->db->base, src_table, src_index, buffer, keyval);

                      if (! (output && db_keysearch (proc_inf->db->base, dst_table, dst_index, ASCENDING, &cursor, keyval, 0L)))
                      {
                        db_fillnull (proc_inf->db->base, dst_table, dst_buffer); /* don't leave buffer undefined */
                        ok = rec2rep (proc_inf, dst_table, dst_buffer, workp->parse.report, dst_count, FALSE, &dst_next, &dst_calc);
                      } /* if */
                      else
                      {
                        busy_mouse ();

                        do
                        {
                          if (v_read (proc_inf->db, dst_table, dst_buffer, &cursor, 0L, FALSE))
                          {
                            if (proc_inf->use_calc) v_execute (proc_inf->db, dst_table, &db->t_info [tableinx (proc_inf->db, dst_table)].calccode, dst_buffer, dst_count + 1, NULL);
                            add_values (proc_inf->db, dst_table, dst_buffer, sum_total);
                            dst_next = rcol;            /* start at same position with every record */
                            ok       = rec2rep (proc_inf, dst_table, dst_buffer, workp->parse.report, ++dst_count, TRUE, &dst_next, &dst_calc);
                          } /* if */
                        } while (ok && db_testcursor (proc_inf->db->base, &cursor, ASCENDING, keyval));

                        arrow_mouse ();
                      } /* else */
                    } /* else */

                    if (ok)
                      if (dst_calc)
                        ok = rec2rep (proc_inf, dst_table, sum_total, workp->parse.report, dst_count, dst_count != 0, &dst_next, &dst_calc);

                    rcol = dst_next;
                    mem_free (dst_buffer);
                    mem_free (sum_total);
                  } /* if */
                } /* else, else */
            } /* if */
            else
              if (id.id == SYM_VARIABLE)
              {
                var = find_var (id.s);

                if (var != SYM_LIST)
                {
                  rcol = get_id (r, rcol, NULL, NULL, &id);
                  rcol = get_id (r, rcol, NULL, NULL, &id);
                } /* if */

                switch (var)
                {
                  case SYM_WIDTH  : workp->maxcols = id.number;
                                    break;
                  case SYM_LENGTH : workp->maxlines = id.number;
                                    break;
                  case SYM_TOP    : workp->top = id.number;
                                    break;
                  case SYM_BOT    : workp->bottom = id.number;
                                    break;
                  case SYM_HEAD   : workp->head = id.number;
                                    break;
                  case SYM_FOOT   : workp->foot = id.number;
                                    break;
                  case SYM_HEADL  : chrcat (workp->header, FORMAT_LEFT);
                                    strcat (workp->header, id.s);
                                    strcat (workp->header, "\r\n");
                                    workp->header_lines++;
                                    break;
                  case SYM_HEADM  : chrcat (workp->header, FORMAT_CENTER);
                                    strcat (workp->header, id.s);
                                    strcat (workp->header, "\r\n");
                                    workp->header_lines++;
                                    break;
                  case SYM_HEADR  : chrcat (workp->header, FORMAT_RIGHT);
                                    strcat (workp->header, id.s);
                                    strcat (workp->header, "\r\n");
                                    workp->header_lines++;
                                    break;
                  case SYM_FOOTL  : chrcat (workp->footer, FORMAT_LEFT);
                                    strcat (workp->footer, id.s);
                                    strcat (workp->footer, "\r\n");
                                    workp->footer_lines++;
                                    break;
                  case SYM_FOOTM  : chrcat (workp->footer, FORMAT_CENTER);
                                    strcat (workp->footer, id.s);
                                    strcat (workp->footer, "\r\n");
                                    workp->footer_lines++;
                                    break;
                  case SYM_FOOTR  : chrcat (workp->footer, FORMAT_RIGHT);
                                    strcat (workp->footer, id.s);
                                    strcat (workp->footer, "\r\n");
                                    workp->footer_lines++;
                                    break;
                  case SYM_TABLE  : if (parsep->starttable == FAILURE) parsep->starttable = parsep->stack [parsep->stackp].table = src_table = find_table (id.s, parsep);
                                    break;
                  case SYM_ASCII  : p [pcol++] = id.number & 0xFF;
                                    break;
                  case SYM_POS    : cols      = pcol - workp->addcols;
                                    id.number = min (id.number, MAX_CHARS - sizeof (LONGSTR));
                                    while (--id.number > cols) p [pcol++] = SP;
                                    break;
                  case SYM_LEFT   : workp->left = id.number;
                                    break;
                  case SYM_LIST   : workp->list = TRUE;
                                    break;
                  case SYM_VPOS   : p [pcol] = EOS;                             /* print beginning of line */
                                    if (output) ok = send_out (proc_inf, p);
                                    pcol      = 0;
                                    id.number = min (id.number, workp->maxlines - workp->top - workp->header_lines - workp->head);
                                    while (ok && output && (workp->lines - workp->top - workp->header_lines - workp->head < id.number - 1))
                                    {
                                      strcpy (p, "\r\n");
                                      ok = send_out (proc_inf, p);
                                    } /* while */
                                    break;
                  case SYM_SQL    : if (ChangeSql (parsep, id.s, TRUE, count, &dst_table) != SUCCESS)
                                      ok = FALSE;
                                    else
                                    {
                                      rcol = get_id (r, rcol, NULL, NULL, &id);

                                      proc_inf->pausing = TRUE;
                                      sql_exec (parsep->db, id.s, "", FALSE, &sql_result);
                                      proc_inf->pausing = FALSE;
                                      set_timer ();

                                      if (sql_result.db == NULL)
                                        ok = FALSE;
                                      else
                                      {
                                        p [pcol] = EOS;                 /* print beginning of line */
                                        if (output) ok = send_out (proc_inf, p);

                                        pcol      = 0;
                                        dst_table = sql_result.table;
                                        dst_index = sql_result.inx;

                                        v_tableinfo (proc_inf->db, dst_table, &t_inf);
                                        dst_buffer = mem_alloc (t_inf.size);
                                        sum_total  = mem_alloc (t_inf.size);
                                        ok         = (dst_buffer != NULL) && (sum_total != NULL);

                                        if (! ok)
                                          hndl_alert (ERR_NOMEMORY);
                                        else
                                        {
                                          dst_count = 0;
                                          dst_next  = rcol;
                                          zero_values (proc_inf->db, rtable (dst_table), sum_total);

                                          if (! output || t_inf.recs == 0)
                                          {
                                            db_fillnull (proc_inf->db->base, rtable (dst_table), dst_buffer); /* don't leave buffer undefined */
                                            ok = rec2rep (proc_inf, dst_table, dst_buffer, workp->parse.report, dst_count, FALSE, &dst_next, &dst_calc);
                                          } /* if */
                                          else
                                          {
                                            busy_mouse ();

                                            if (v_initcursor (proc_inf->db, dst_table, dst_index, sql_result.dir, &cursor))
                                              while (ok && v_movecursor (proc_inf->db, &cursor, sql_result.dir))
                                                if (v_read (proc_inf->db, dst_table, dst_buffer, &cursor, 0L, FALSE))
                                                {
                                                  if (proc_inf->use_calc) v_execute (proc_inf->db, dst_table, &db->t_info [tableinx (proc_inf->db, rtable (dst_table))].calccode, dst_buffer, dst_count + 1, NULL);
                                                  add_values (proc_inf->db, rtable (dst_table), dst_buffer, sum_total);
                                                  dst_next = rcol;            /* start at same position with every record */
                                                  ok       = rec2rep (proc_inf, dst_table, dst_buffer, workp->parse.report, ++dst_count, TRUE, &dst_next, &dst_calc);
                                                } /* if, while, if */

                                            arrow_mouse ();
                                          } /* else */
                                        } /* else */

                                        if (ok)
                                          if (dst_calc)
                                            ok = rec2rep (proc_inf, dst_table, sum_total, workp->parse.report, dst_count, dst_count != 0, &dst_next, &dst_calc);

                                        rcol = dst_next;
                                        mem_free (dst_buffer);
                                        mem_free (sum_total);
                                        mem_free (sql_result.columns);

                                        if (VTBL (sql_result.table))
                                          free_vtable (sql_result.table);

                                        if (VINX (sql_result.inx))
                                          free_vindex (sql_result.inx);
                                      } /* else */
                                    } /* else */
                                    break;
                  case SYM_PROP   : get_ctrlcode ((id.number != 0) ? PROP_ON : PROP_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_SUPER  : get_ctrlcode ((id.number != 0) ? SUPER_ON : SUPER_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_SUB    : get_ctrlcode ((id.number != 0) ? SUB_ON : SUB_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_ITALIC : get_ctrlcode ((id.number != 0) ? ITALIC_ON : ITALIC_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_BOLD   : get_ctrlcode ((id.number != 0) ? BOLD_ON : BOLD_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_UNDER  : get_ctrlcode ((id.number != 0) ? UNDER_ON : UNDER_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_PICA   : get_ctrlcode ((id.number != 0) ? PICA_ON : PICA_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_ELITE  : get_ctrlcode ((id.number != 0) ? ELITE_ON : ELITE_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_NLQ    : get_ctrlcode ((id.number != 0) ? NLQ_ON : NLQ_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_COND   : get_ctrlcode ((id.number != 0) ? CONDENSED_ON : CONDENSED_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                  case SYM_EXPAND : get_ctrlcode ((id.number != 0) ? EXPANDED_ON : EXPANDED_OFF, code);
                                    if ((proc_inf->special == DEV_PRINTER) && (code [0] != EOS))
                                    {
                                      strcpy (p + pcol, code);
                                      pcol           += strlen (code);
                                      workp->addcols += strlen (code);
                                    } /* if */
                                    break;
                } /* switch */

                if (var != SYM_SQL)
                  rcol = get_id (r, rcol, NULL, NULL, &id);

                if ((pcol == workp->addcols) && ((r [rcol] == '\r') || (r [rcol] == '\n')))  /* ignore rest of line */
                {
                  if (r [rcol] == '\r') rcol++;
                  rcol++;
                  ready = TRUE;
                } /* if */
              } /* if */
              else              /* SYM_RETURN or SYM_CALC */
              {
                *calc = id.id == SYM_CALC;
                rcol  = get_id (r, rcol, NULL, NULL, &id);
                ready = done = TRUE;
              } /* else, else */
          } /* else, else */
      } /* else */
    } /* while */

    p [pcol] = EOS;

    if (ok && output && ! null)
    {
      ok = send_out (proc_inf, p);
      workp->header_written = FALSE;            /* prepare for new header */
    } /* if */
  } /* while */

  *next = rcol;
  parsep->stackp--;

  return (ok);
} /* rec2rep */

/*****************************************************************************/

LOCAL VOID field2str (db, table, buffer, col, colwidth, num, count, formatstr, s)
DB   *db;
WORD table;
VOID *buffer;
WORD col, colwidth, num;
LONG count;
BYTE *formatstr, *s;

{
  WORD       type, fval;
  FIELD_INFO f_inf;
  LONGSTR    strval;
  BYTE       *mem, *p;
  FORMAT     format;
  DATE       date;
  TIME       time;
  TIMESTAMP  tstamp;

  if (col >= 0)
  {
    db_fieldinfo (db->base, table, col, &f_inf);
    type = f_inf.type;
    fval = f_inf.format;
    mem  = (BYTE *)buffer + f_inf.addr;

    if (type == TYPE_CHAR)                      /* prevent from overflow of long text lines */
      if (num != FAILURE)
        get_line (mem, abs (colwidth), num, strval);
      else
      {
        strncpy (strval, mem, LONGSTRLEN - 1);
        strval [LONGSTRLEN - 1] = EOS;
      } /* else, if */
    else
      bin2str (type, mem, strval);
  } /* if */
  else
  {
    switch (col)
    {
      case SYM_SYSDATE      : type = fval = TYPE_DATE;
                              mem  = (BYTE *)&date;
                              get_date (&date);
                              break;
      case SYM_SYSTIME      : type = fval = TYPE_TIME;
                              mem  = (BYTE *)&time;
                              get_time (&time);
                              break;
      case SYM_SYSTIMESTAMP : type = fval = TYPE_TIMESTAMP;
                              mem  = (BYTE *)&tstamp;
                              get_tstamp (&tstamp);
                              break;
      case SYM_COUNT        : type = fval = TYPE_LONG;
                              mem  = (BYTE *)&count;
                              break;
    } /* switch */

    bin2str (type, mem, strval);
  } /* else */

  if (formatstr != NULL)
  {
    build_format (type, formatstr, format);
    str2format (type, strval, format);
  } /* if */
  else
    if ((fval != TYPE_WORD) && (fval != TYPE_LONG)) /* words and longs will not be standard formatted */
      if (db->format != NULL) str2format (type, strval, db->format [fval]);

  if (colwidth == 0)                    /* don't use padding chars */
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

  while ((p = strchr (s, '\r')) != NULL) *p = SP;       /* delete cr */
  while ((p = strchr (s, '\n')) != NULL) *p = SP;       /* delete lf */
} /* field2str */

/*****************************************************************************/

LOCAL VOID get_line (text, width, num, line)
BYTE *text;
WORD width, num;
BYTE *line;

{
  WORD i, j, nosp;

  for (i = 0; i <= num; i++)
  {
    j = nosp = 0;

    while (((j < width) || (width == 0)) && (*text != EOS) && (*text != '\r') && (*text != '\n'))
    {
      nosp++;
      if (*text == SP) nosp = 0;
      if (j < LONGSTRLEN) line [j] = *text;
      j++;
      text++;
    } /* while */

    line [min (j, LONGSTRLEN)] = EOS;

    if ((width != 0) && (j == width) && (*text != EOS) && (*text != '\r') && (*text != '\n'))
      if (nosp < strlen (line))
      {
        text -= nosp;
        line [strlen (line) - nosp] = EOS;
      } /* if, if */

    if (*text == '\r') text++;  /* don't use cr for next line */
    if (*text == '\n') text++;  /* don't use lf for next line */
  } /* for */

  line [LONGSTRLEN] = EOS;
} /* get_line */

/*****************************************************************************/

LOCAL INT ChangeSql (pSpec, pSql, bReplace, lCount, pDstTable)
PARSE_SPEC *pSpec;
CHAR       *pSql;
BOOL       bReplace;
LONG       lCount;
SHORT      *pDstTable;

{
  INT        iError;
  SHORT      table, column, stk, i, j;
  FIELD_INFO fi;
  STRING     szTable, szColumn;
  CHAR       *p, *q, *r;
  LONGSTR    colstr;
  IDSTR      sz;

  iError = SUCCESS;
  p      = strstr (pSql, "FROM");	/* look for table after id FROM */
  table  = FAILURE;

  if (p != NULL)
  {
    for (p += 4; isspace (*p); p++);
    strncpy (szTable, p, MAX_TABLENAME);
    szTable [MAX_TABLENAME] = EOS;
    for (p = szTable; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
    *p    = EOS;
    table = find_table (szTable, pSpec);
  } /* if */

  if (table == FAILURE)
    iError = ERR_TBLEXP;

  if (pDstTable != NULL)
    *pDstTable = table;
  
  for (stk = pSpec->stackp; (stk >= 0) && (iError == SUCCESS); stk--)
  {
    table = rtable (pSpec->stack [stk].table);
    sprintf (szTable, "%s.", db_tablename (pSpec->db->base, table));
    p = q = strstr (pSql, szTable);

    while ((p != NULL) && (iError == SUCCESS))	/* search for column name */
    {
      p = strchr (p, '.');

      if (! bReplace)				/* test only once, don't replace */
        *p = '@';

      p++;					/* behind '.' */
      i = 0;

      while (isalnum (ch_ascii (*p)) || (*p =='_'))	/* get column name */
        szColumn [i++] = *p++;

      szColumn [i]             = EOS;
      szColumn [MAX_FIELDNAME] = EOS;

      strcpy (fi.name, szColumn);

      if ((column = db_fieldinfo (pSpec->db->base, table, FAILURE, &fi)) != FAILURE)
        if (! (db_acc_column (pSpec->db->base, table, column) & GRANT_SELECT))
          column = FAILURE;

      if (column == FAILURE)
        iError = ERR_COLEXP;
      else
        if (bReplace)
        {
          for (i = 0, r = pSql; (r != q) && (i < MAX_IDSTRLEN); i++)
            sz [i] = *r++;

          field2str (pSpec->db, pSpec->stack [stk].table, pSpec->stack [stk].buffer, column, 0, FAILURE, lCount, NULL, colstr);

          if (HASWILD (fi.type) && (i < MAX_IDSTRLEN)) sz [i++] = CHR_STRDEL;

          for (j = 0; (colstr [j] != EOS) && (i < MAX_IDSTRLEN); j++)
            sz [i++] = colstr [j];

          if (HASWILD (fi.type) && (i < MAX_IDSTRLEN)) sz [i++] = CHR_STRDEL;

          sz [i] = EOS;

          if (strlen (sz) + strlen (p) < MAX_IDSTRLEN)
            strcat (sz, p);

          strcpy (pSql, sz);
        } /* if, else */

      p = q = strstr (pSql, szTable);
    } /* while */
  } /* for */

  return (iError);
} /* ChangeSql */

/*****************************************************************************/

LOCAL LONG copies_dialog (WORD *pdevice)
{
  WINDOWP window;
  WORD    ret;
  BOOLEAN ok;

  numcopies = 1;
  device    = FAILURE;
  window    = search_window (CLASS_DIALOG, SRCH_ANY, COPIES);

  if (window == NULL)
  {
    form_center (copies, &ret, &ret, &ret, &ret);
    window = crt_dialog (copies, NULL, COPIES, FREETXT (FCOPIES), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_copies;
      window->key   = key_copies;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (copies, ROOT, EDITABLE);
      window->edit_inx = NIL;

      set_long (copies, CPNUM, numcopies);
      check_copies (window);
    } /* if */

    if (! open_dialog (COPIES))
    {
      delete_window (window);
      do_state (copies, CPHELP, DISABLED);
      copies->ob_spec = (dlg_colors < 16) ? 0x00021100L : 0x00011170L | sys_colors [COLOR_DIALOG];
      device          = hndl_dial (copies, 0, FALSE, TRUE, NULL, &ok) - CPSCREEN;
      numcopies       = get_long (copies, CPNUM);
      copies->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
      undo_state (copies, CPHELP, DISABLED);
    } /* if */
  } /* if */

  *pdevice  = (device > DEV_PRINTER) ? FAILURE : device;

  return (numcopies);
} /* copies_dialog */

/*****************************************************************************/

LOCAL VOID click_copies (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case CPSCREEN : device    = DEV_SCREEN;
                    numcopies = get_long (window->object, CPNUM);
                    break;
    case CPDISK   : device    = DEV_DISK;
                    numcopies = get_long (window->object, CPNUM);
                    break;
    case CPPRINT  : device    = DEV_PRINTER;
                    numcopies = get_long (window->object, CPNUM);
                    break;
    case CPHELP   : hndl_help (HCOPIES);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  check_copies (window);
} /* click_copies */

/*****************************************************************************/

LOCAL BOOLEAN key_copies (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  check_copies (window);

  return (FALSE);
} /* key_copies */

/*****************************************************************************/

LOCAL VOID check_copies (window)
WINDOWP window;

{
  BYTE *p;
  LONG l;

  p = get_str (copies, CPNUM);
  l = get_long (copies, CPNUM);

  if (((*p == EOS) || (l <= 0)) == ! is_state (copies, CPSCREEN, DISABLED))
  {
    flip_state (copies, CPSCREEN, DISABLED);
    draw_object (window, CPSCREEN);
    flip_state (copies, CPDISK, DISABLED);
    draw_object (window, CPDISK);
    flip_state (copies, CPPRINT, DISABLED);
    draw_object (window, CPPRINT);
  } /* if */
} /* check_copies */

/*****************************************************************************/

