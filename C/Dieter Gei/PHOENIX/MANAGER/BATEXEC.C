/*****************************************************************************
 *
 * Module : BATEXEC.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the batch process.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 24.02.97: CMD_ACCOUNT added
 * 03.01.97: Table SYS_ACCOUNT can be handled
 * 19.03.94: Parameter copies for reports added
 * 14.03.94: Parameter color added
 * 08.02.94: Function open_syslist used
 * 13.11.93: Parameter facename added
 * 04.11.93: Using fontdesc
 * 23.09.93: Function get_parmnames added
 * 11.09.93: Using of variable max_lines removed
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "accobj.h"
#include "account.h"
#include "batch.h"
#include "calc.h"
#include "calcexec.h"
#include "commdlg.h"
#include "delete.h"
#include "desktop.h"
#include "dialog.h"
#include "impexp.h"
#include "list.h"
#include "mask.h"
#include "mfile.h"
#include "mimpexp.h"
#include "mlockscr.h"
#include "mpagefrm.h"
#include "printer.h"
#include "process.h"
#include "qbe.h"
#include "repmake.h"
#include "report.h"
#include "resource.h"
#include "sql.h"

#include "export.h"
#include "batexec.h"

/****** DEFINES **************************************************************/

#define FLAG_NULL       0x00000000L     /* no parameters */
#define FLAG_TABLE      0x00000001L     /* name of table */
#define FLAG_INDEX      0x00000002L     /* name of index */
#define FLAG_DIR        0x00000004L     /* direction */
#define FLAG_QUERY      0x00000008L     /* name of query */
#define FLAG_SQL        0x00000010L     /* SQL command */
#define FLAG_EXCLUSIVE  0x00000020L     /* mode of process */
#define FLAG_MINIMIZE   0x00000040L     /* minimize mode of process */
#define FLAG_FILE       0x00000080L     /* filename */
#define FLAG_NAME       0x00000100L     /* name of object */
#define FLAG_DEVICE     0x00000200L     /* device */
#define FLAG_FACENAME   0x00000400L     /* facename */
#define FLAG_FONTSIZE   0x00000800L     /* fontsize */
#define FLAG_COLOR      0x00001000L     /* color of font */
#define FLAG_SIZE       0x00002000L     /* size of window */
#define FLAG_IMP        0x00004000L     /* import parameters */
#define FLAG_LAY        0x00008000L     /* page layout */
#define FLAG_PRN        0x00010000L     /* printer parameters */
#define FLAG_PRT        0x00020000L     /* printer driver */
#define FLAG_COPIES     0x00040000L     /* copies of report */

#define CMD_NULL        (-2)            /* no command */
#define CMD_SEP         LF              /* separates two commands */
#define PARM_SEP        '='             /* separates parameters */
#define STR_SEP         '"'             /* separates strings */
#define SIZE_SEP        ','             /* separates to size values */
#define COMMENT         ';'             /* comment operator */
#define MAX_ERRCHARS    37              /* max chars in error (40 - strlen (">>>")) */
#define MIN_POS         4               /* min number of positions for x/y-coordinates */

#define DEFAULT_BATCH   "AUTOEXEC"      /* default batch name */

/****** TYPES ****************************************************************/

enum CMDS                               /* the commands */
{
  CMD_ACCOUNT,
  CMD_CALCULATE,
  CMD_CLOSE,
  CMD_DEFBATCH,
  CMD_DEFCALC,
  CMD_DEFQUERY,
  CMD_DEFREPORT,
  CMD_DEFACCOUNT,
  CMD_DELETE,
  CMD_DISK,
  CMD_EDIT,
  CMD_EXPORT,
  CMD_FLUSHKEYS,
  CMD_IMPORT,
  CMD_LIST,
  CMD_LOCKSCREEN,
  CMD_MAXIMIZE,
  CMD_MINIMIZE,
  CMD_PRINT,
  CMD_REMOVE,
  CMD_REPORT,
  CMD_SET,
  CMD_UNDELETE
}; /* CMDS */

enum PARMS                              /* the parameters */
{
  PARM_NULL,
  PARM_TABLE,
  PARM_INDEX,
  PARM_DIR,
  PARM_QUERY,
  PARM_SQL,
  PARM_EXCLUSIVE,
  PARM_MINIMIZE,
  PARM_FILE,
  PARM_NAME,
  PARM_DEVICE,
  PARM_FACENAME,
  PARM_FONTSIZE,
  PARM_COLOR,
  PARM_SIZE,
  PARM_IMP,
  PARM_LAY,
  PARM_PRN,
  PARM_PRT,
  PARM_COPIES
}; /* PARMS */

enum CLASSES                            /* the parameter classes */
{
  CLASS_NULL,
  CLASS_TABLE,
  CLASS_INDEX,
  CLASS_DIR,
  CLASS_STRING,
  CLASS_FILE,
  CLASS_NUMBER,
  CLASS_BOOL,
  CLASS_DEVICE,
  CLASS_SIZE
}; /* CLASSES */

typedef struct
{
  BYTE  *parm;                          /* name of parameter */
  ULONG flag;                           /* flag of parameter */
  WORD  class;                          /* class of parameter */
} PARM;

enum IDS                                /* ids for parameters */
{
  ID_ASCENDING,
  ID_DESCENDING,
  ID_SCREEN,
  ID_DISK,
  ID_PRINTER,
  ID_FALSE,
  ID_TRUE
}; /* IDS */

typedef struct
{
  WORD      errno;                      /* last error */
  WORD      cmd;                        /* the command itself */
  DB        *db;                        /* actual database */
  WORD      table;                      /* table number */
  WORD      index;                      /* index number */
  WORD      dir;                        /* direction */
  FIELDNAME query;                      /* query name */
  BYTE      *sql;                       /* sql string */
  BOOLEAN   exclusive;                  /* exclusive process? */
  BOOLEAN   minimize;                   /* minimize process? */
  FULLNAME  filename;                   /* filename */
  FIELDNAME name;                       /* object name */
  WORD      device;                     /* device to output */
  LONG      copies;                     /* number of copies of whole report */
  FONTDESC  fontdesc;                   /* font description */
  RECT      size;                       /* size of window */
  FULLNAME  imp;                        /* import/export parameters */
  FULLNAME  lay;                        /* layout parameters */
  FULLNAME  prn;                        /* printer parameters */
  FULLNAME  prt;                        /* printer driver */
} PARM_SPEC;

typedef struct
{
  DB   *db;                             /* actual database */
  BYTE *batch;                          /* pointer to batch definition */
  WORD table;                           /* start table of batch */
  WORD index;                           /* start index number of batch */
  WORD dir;                             /* start direction of batch */
  WORD numerrs;                         /* number of batch errors */
  WORD cx;                              /* cursor x-pos when error occurs */
  WORD cy;                              /* cursor y-pos when error occurs */
} PARSE_SPEC;

typedef struct
{
  WORD       table;                     /* last table number */
  WORD       index;                     /* last index number */
  WORD       dir;                       /* direction */
  FONTDESC   fontdesc;                  /* font description */
  WORD       inx;                       /* next index in parse.batch */
  BOOLEAN    minimize;                  /* minimize process? */
  PARSE_SPEC parse;                     /* specification for parsing */
  PARM_SPEC  parm;                      /* specification for parameters */
} WORK_INF;

/****** VARIABLES ************************************************************/

LOCAL CMD cmds [] =
{
  "ACCOUNT",    FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_DEVICE | FLAG_NAME | FLAG_COPIES,
  "CALCULATE",  FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_NAME,
  "CLOSE",      FLAG_NULL,
  "DEFBATCH",   FLAG_FACENAME | FLAG_FONTSIZE | FLAG_COLOR | FLAG_NAME,
  "DEFCALC",    FLAG_TABLE | FLAG_FACENAME | FLAG_FONTSIZE | FLAG_COLOR | FLAG_NAME,
  "DEFQUERY",   FLAG_TABLE | FLAG_NAME,
  "DEFREPORT",  FLAG_TABLE | FLAG_FACENAME | FLAG_FONTSIZE | FLAG_COLOR | FLAG_NAME,
  "DEFACCOUNT", FLAG_NAME,
  "DELETE",     FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE,
  "DISK",       FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_FILE | FLAG_LAY,
  "EDIT",       FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_NAME | FLAG_SIZE,
  "EXPORT",     FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_FILE | FLAG_IMP,
  "FLUSHKEYS",  FLAG_NULL,
  "IMPORT",     FLAG_TABLE | FLAG_QUERY | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_FILE | FLAG_IMP,
  "LIST",       FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_MINIMIZE | FLAG_FACENAME | FLAG_FONTSIZE | FLAG_COLOR | FLAG_SIZE,
  "LOCKSCREEN", FLAG_NULL,
  "MAXIMIZE",   FLAG_NULL,
  "MINIMIZE",   FLAG_NULL,
  "PRINT",      FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_PRN | FLAG_PRT | FLAG_LAY,
  "REMOVE",     FLAG_FILE,
  "REPORT",     FLAG_TABLE | FLAG_QUERY | FLAG_INDEX | FLAG_DIR | FLAG_EXCLUSIVE | FLAG_MINIMIZE | FLAG_DEVICE | FLAG_FILE | FLAG_PRN | FLAG_PRT | FLAG_NAME | FLAG_COPIES,
  "SET",        FLAG_TABLE | FLAG_INDEX | FLAG_DIR | FLAG_FACENAME | FLAG_FONTSIZE | FLAG_COLOR,
  "UNDELETE",   FLAG_EXCLUSIVE
};

LOCAL PARM parms [] =
{
  "",           FLAG_NULL,       CLASS_NULL,
  "TABLE",      FLAG_TABLE,      CLASS_TABLE,
  "INDEX",      FLAG_INDEX,      CLASS_INDEX,
  "DIR",        FLAG_DIR,        CLASS_DIR,
  "QUERY",      FLAG_QUERY,      CLASS_STRING,
  "SQL",        FLAG_SQL,        CLASS_STRING,
  "EXCLUSIVE",  FLAG_EXCLUSIVE,  CLASS_BOOL,
  "MINIMIZE",   FLAG_MINIMIZE,   CLASS_BOOL,
  "FILE",       FLAG_FILE,       CLASS_FILE,
  "NAME",       FLAG_NAME,       CLASS_STRING,
  "DEVICE",     FLAG_DEVICE,     CLASS_DEVICE,
  "FACENAME",   FLAG_FACENAME,   CLASS_STRING,
  "FONTSIZE",   FLAG_FONTSIZE,   CLASS_NUMBER,
  "COLOR",      FLAG_COLOR,      CLASS_NUMBER,
  "SIZE",       FLAG_SIZE,       CLASS_SIZE,
  "IMP",        FLAG_IMP,        CLASS_FILE,
  "LAY",        FLAG_LAY,        CLASS_FILE,
  "PRN",        FLAG_PRN,        CLASS_FILE,
  "PRT",        FLAG_PRT,        CLASS_FILE,
  "COPIES",     FLAG_COPIES,     CLASS_NUMBER
};

LOCAL BYTE *ids [] =
{
  "ASC",
  "DESC",
  "SCREEN",
  "DISK",
  "PRINTER",
  "FALSE",
  "TRUE"
};

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN    work_batch   _((PROC_INF *proc_inf));
LOCAL BOOLEAN    stop_batch   _((PROC_INF *proc_inf));
LOCAL BOOLEAN    parse_batch  _((PARSE_SPEC *parsep));
LOCAL BOOLEAN    parse_error  _((PARSE_SPEC *parsep, WORD line, WORD col, WORD error, WORD *result));
LOCAL WORD       scan_cmd     _((BYTE *bat, WORD inx, WORD *col, WORD *oldcol, PARM_SPEC *parmp));
LOCAL WORD       scan_parms   _((BYTE *bat, WORD inx, WORD *col, WORD *oldcol, PARM_SPEC *parmp));
LOCAL WORD       find_cmd     _((BYTE *name));
LOCAL WORD       find_parm    _((BYTE *name));
LOCAL WORD       find_parmval _((BYTE *bat, WORD inx, WORD parm, PARM_SPEC *parmp));
LOCAL WORD       get_id       _((BYTE *bat, WORD inx, BYTE *id));
LOCAL WORD       get_string   _((BYTE *bat, WORD inx, BYTE *s));
LOCAL WORD       get_number   _((BYTE *bat, WORD inx, BYTE *s));
LOCAL WORD       get_size     _((BYTE *bat, WORD inx, PARM_SPEC *parmp));
LOCAL WORD       check_id     _((WORD low, WORD high, BYTE *id));
LOCAL SYSQUERY   *get_query   _((DB *db, BYTE *query_name));
LOCAL SYSCALC    *get_calc    _((DB *db, WORD table, BYTE *calc_name));
LOCAL SYSREPORT  *get_report  _((DB *db, BYTE *report_name));
LOCAL SYSBATCH   *get_batch   _((DB *db, BYTE *batch_name));
LOCAL SYSACCOUNT *get_account _((DB *db, BYTE *account_name));

/*****************************************************************************/

GLOBAL WORD check_batch (db, batch, cx, cy)
DB   *db;
BYTE *batch;
WORD *cx, *cy;

{
  WORD       result;
  PARSE_SPEC parse;
  WORD       act_number;
  MFORM      *act_form;

  act_number = mousenumber; /* actual mouseform in BATCH window could be TEXT_CRSR */
  act_form   = mouseform;
  set_mouse (BUSY_BEE, NULL);

  parse.db      = db;
  parse.batch   = batch;
  parse.table   = NUM_SYSTABLES;        /* use first user table */
  parse.index   = 0;                    /* use first index */
  parse.dir     = ASCENDING;            /* use ascending order */
  parse.numerrs = 0;

  result = parse_batch (&parse);

  if (result == BATCH_EDIT)
  {
    *cx = parse.cx;
    *cy = parse.cy;
  } /* if */

  set_mouse (act_number, act_form);

  return (result);
} /* check_batch */

/*****************************************************************************/

GLOBAL VOID do_batch (db, batch, batch_name)
DB   *db;
BYTE *batch, *batch_name;

{
  WINDOWP  window;
  LONG     numcmds, bytes;
  PROC_INF proc_inf, *procp;
  BYTE     *title, *p;
  WORK_INF *workp;

  for (p = batch, numcmds = 1; *p != EOS; p++)
    if (*p == CMD_SEP) numcmds++;

  proc_inf.db           = db;
  proc_inf.table        = FAILURE;
  proc_inf.inx          = FAILURE;
  proc_inf.dir          = 0;
  proc_inf.cols         = 0;
  proc_inf.columns      = NULL;
  proc_inf.colwidth     = NULL;
  proc_inf.cursor       = NULL;
  proc_inf.format       = 0;
  proc_inf.maxrecs      = numcmds;
  proc_inf.events_ps    = events_ps;
  proc_inf.recs_pe      = recs_pe;
  proc_inf.impexpcfg    = &impexpcfg;
  proc_inf.page_format  = &page_format;
  proc_inf.prncfg       = &prncfg;
  proc_inf.to_printer   = FALSE;
  proc_inf.binary       = FALSE;
  proc_inf.tmp          = FALSE;
  proc_inf.special      = 0;
  proc_inf.file         = NULL;
  proc_inf.filelength   = 0;
  proc_inf.workfunc     = work_batch;
  proc_inf.stopfunc     = stop_batch;

  bytes   = sizeof (WORK_INF);
  bytes  += strlen (batch) + 1;
  title   = FREETXT (FPBATCH);
  window  = crt_process (NULL, NULL, NIL, title, &proc_inf, bytes, wi_modeless);

  if (window != NULL)
  {
    procp = (PROC_INF *)window->special;
    workp = (WORK_INF *)procp->memory;
    mem_lset (workp, 0, bytes);

    workp->table            = NUM_SYSTABLES;    /* use first user table */
    workp->index            = 0;                /* use first index */
    workp->dir              = ASCENDING;        /* use ascending order */
    workp->fontdesc.font    = FONT_SYSTEM;
    workp->fontdesc.point   = gl_point;
    workp->fontdesc.effects = TXT_NORMAL;
    workp->fontdesc.color   = BLACK;
    workp->fontdesc         = fontdesc;
    workp->inx              = 0;
    workp->minimize         = minimize;
    workp->parse.db         = db;
    workp->parse.batch      = procp->memory + sizeof (WORK_INF);
    workp->parse.numerrs    = 0;

    strcpy (workp->parse.batch, batch);
    strcpy (procp->filename, batch_name);
    p = strchr (procp->dbstr, '.');             /* no table name */
    if (p != NULL) *p = EOS;

    start_process (window, strcmp (batch_name, DEFAULT_BATCH) == 0 ? TRUE : minimize_process, TRUE);
  } /* if */
} /* do_batch */

/*****************************************************************************/

GLOBAL VOID exec_batch (db, batch_name)
DB   *db;
BYTE *batch_name;

{
  SYSBATCH *sysbatch;
  CURSOR   cursor;
  MKINFO   mk;

  if (batch_name == NULL)
  {
    graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
    if (mk.kstate & (K_RSHIFT | K_LSHIFT)) return;		/* don't execute autoexec batch if shift key is being holded down */
    batch_name = DEFAULT_BATCH;
  } /* if */

  sysbatch = mem_alloc ((LONG)sizeof (SYSBATCH));

  if (sysbatch == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sysbatch->name, batch_name);

    if (db_search (db->base, SYS_BATCH, 1, ASCENDING, &cursor, sysbatch, 0L))
      if (db_read (db->base, SYS_BATCH, sysbatch, &cursor, 0L, FALSE))
        do_batch (db, sysbatch->batch, sysbatch->name);

    mem_free (sysbatch);
    set_meminfo ();
  } /* else */
} /* exec_batch */

/*****************************************************************************/

GLOBAL VOID flush_db (db)
DB *db;

{
  MFDB    screen, buffer;
  RECT    r;
  BYTE    *p;
  BOOLEAN ret;
  WORD    w;

  busy_mouse ();
  w = flushkey [FLUSHNAM].ob_width / gl_wbox;
  p = get_str (flushkey, FLUSHNAM);
  strncpy (p, db->base->basepath, w);
  p [w] = EOS;
  strncat (p, db->base->basename, w);
  p [w] = EOS;
  opendial (flushkey, FALSE, NULL, &screen, &buffer);
  form_center (flushkey, &r.x, &r.y, &r.w, &r.h);
  objc_draw (flushkey, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h);
  draw_3d_dlg (flushkey);
  ret = db_flush (db->base, TRUE, TRUE);
  closedial (flushkey, FALSE, NULL, &screen, &buffer);
  arrow_mouse ();
  if (! ret) dbtest (db);
} /* flush_db */

/*****************************************************************************/

GLOBAL WORD get_numcmds ()

{
  return ((WORD)(sizeof (cmds) / sizeof (CMD)));
} /* get_numcmds */

/*****************************************************************************/

GLOBAL CMD *get_cmds ()

{
  return (cmds);
} /* get_cmds */

/*****************************************************************************/

GLOBAL BYTE *get_cmd (which, cmd)
WORD which;
BYTE *cmd;

{
  strcpy (cmd, cmds [which].cmd);
  if (cmds [which].parms != FLAG_NULL) strcat (cmd, " ");

  return (cmd);
} /* get_cmd */

/*****************************************************************************/

GLOBAL BYTE *get_parmnames (cmd, names)
BYTE *cmd;
BYTE *names;

{
  WORD  iCmd, i;
  ULONG ul;

  *names = EOS;
  iCmd   = find_cmd (cmd);

  if (iCmd != FAILURE)
    for (i = PARM_TABLE, ul = 1; i <= 31; i++, ul <<= 1)
      if (cmds [iCmd].parms & ul)
      {
        strcat (names, parms [i].parm);
        chrcat (names, ',');
      } /* if, for, if */

  return (names);
} /* get_parmnames */

/*****************************************************************************/

LOCAL BOOLEAN work_batch (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN     ok, keep, use_sql;
  WORK_INF    *workp;
  BYTE        *bat;
  WORD        inx;
  PARM_SPEC   *parmp;
  WINDOWP     top;
  UWORD       save_modeless;
  SQL_RESULT  sql_res;
  SYSQUERY    *sysquery;
  SYSCALC     *syscalc;
  SYSREPORT   *sysreport;
  SYSBATCH    *sysbatch;
  SYSACCOUNT  *sysaccount;
  IMPEXPCFG   limpexpcfg, simpexpcfg;
  PAGE_FORMAT lpage_format, spage_format;
  PRNCFG      lprncfg, sprncfg;

  ok    = keep = TRUE;
  workp = (WORK_INF *)proc_inf->memory;
  bat   = workp->parse.batch;
  inx   = workp->inx;
  parmp = &workp->parm;
  top   = find_top ();

  mem_set (parmp, 0, (UWORD)sizeof (PARM_SPEC));
  parmp->db       = proc_inf->db;
  parmp->table    = FAILURE;
  parmp->index    = workp->index;
  parmp->dir      = workp->dir;
  parmp->minimize = workp->minimize;
  parmp->fontdesc = workp->fontdesc;
  parmp->device   = FAILURE;
  parmp->copies   = 1;

  if (bat [inx] == EOS) return (FALSE);
  if (bat [inx] == CMD_SEP) inx++;

  inx = scan_cmd (bat, inx, NULL, NULL, parmp);

  if ((parmp->errno == SUCCESS) && (parmp->cmd != CMD_NULL))
  {
    inx = scan_parms (bat, inx, NULL, NULL, parmp);

    if (parmp->errno == SUCCESS)
      if ((cmds [parmp->cmd].parms & FLAG_EXCLUSIVE) || (parmp->query [0] != EOS) || (parmp->cmd == CMD_LOCKSCREEN))
        if ((num_processes == MAX_PROCESS) || (wi_modeless == WI_MODAL))
        {
          inx          = workp->inx;            /* try again later */
          parmp->errno = FAILURE;
        } /* if */

    if (parmp->errno == SUCCESS)
    {
      save_modeless = wi_modeless;
      if (parmp->exclusive || (parmp->cmd == CMD_LOCKSCREEN)) wi_modeless = WI_MODAL;

      use_sql = FALSE;                  /* don't use queries as default */

      if (parmp->query [0] != EOS)
        if ((sysquery = get_query (parmp->db, parmp->query)) != NULL)
        {
          UWORD save_modeless = wi_modeless;

          wi_modeless = WI_MODAL;       /* batcher will loop in next timer event */
          sql_exec (parmp->db, sysquery->query, parmp->query, FALSE, &sql_res);
          use_sql     = sql_res.db != NULL;
          wi_modeless = save_modeless;

          mem_free (sysquery);
        } /* if */
        else
          parmp->cmd = FAILURE;         /* don't execute the command */

      simpexpcfg   = impexpcfg;         /* save original settings */
      spage_format = page_format;
      sprncfg      = prncfg;

      limpexpcfg   = *proc_inf->impexpcfg;      /* use original values */
      lpage_format = *proc_inf->page_format;
      lprncfg      = *proc_inf->prncfg;

      if (parmp->imp [0] != EOS)
        if (! load_impexp (NULL, parmp->imp, &limpexpcfg, FALSE)) parmp->cmd = FAILURE;
                                                            
      if (parmp->lay [0] != EOS)
        if (! load_pageformat (NULL, parmp->lay, &lpage_format, FALSE)) parmp->cmd = FAILURE;

      if (parmp->prn [0] != EOS)
        if (! load_prncfg (NULL, parmp->prn, &lprncfg, FALSE)) parmp->cmd = FAILURE;

      if (parmp->prt [0] != EOS)
        if (! load_driver (parmp->prt)) parmp->cmd = FAILURE;

      impexpcfg   = limpexpcfg;         /* use new settings */
      page_format = lpage_format;
      prncfg      = lprncfg;

      if (parmp->table == FAILURE)
        if (parmp->cmd != CMD_ACCOUNT)
          parmp->table = workp->table;

      switch (parmp->cmd)
      {
        case CMD_ACCOUNT    : if (use_sql)
                                AccountNameExec (parmp->name, sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, parmp->device, parmp->minimize, parmp->copies);
                              else
                                AccountNameExec (parmp->name, parmp->db, parmp->table, parmp->index, parmp->dir, parmp->device, parmp->minimize, parmp->copies);
                              break;
        case CMD_CALCULATE  : if (use_sql) parmp->table = sql_res.table;                                /* use the table of the query */
                              if ((syscalc = get_calc (parmp->db, parmp->table, parmp->name)) != NULL)
                              {
                                if (use_sql)
                                  calc_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, &syscalc->code, parmp->minimize);
                                else
                                  calc_list (parmp->db, parmp->table, parmp->index, parmp->dir, &syscalc->code, parmp->minimize);

                                mem_free (syscalc);
                              } /* if */
                              break;
        case CMD_CLOSE      : if (any_open (FALSE, TRUE, FALSE)) close_top ();
                              break;
        case CMD_DEFBATCH   : sysbatch = (parmp->name [0] == EOS) ? NULL : get_batch (parmp->db, parmp->name);
                              open_batch (NIL, parmp->db, (sysbatch == NULL) ? "" : sysbatch->batch, (sysbatch == NULL) ? "" : sysbatch->name, &parmp->fontdesc);
                              if (sysbatch != NULL) mem_free (sysbatch);
                              break;
        case CMD_DEFCALC    : syscalc = (parmp->name [0] == EOS) ? NULL : get_calc (parmp->db, parmp->table, parmp->name);
                              open_calc (NIL, parmp->db, parmp->table, (syscalc == NULL) ? "" : syscalc->text, (syscalc == NULL) ? "" : syscalc->name, &parmp->fontdesc);
                              if (syscalc != NULL) mem_free (syscalc);
                              break;
        case CMD_DEFQUERY   : sysquery = (parmp->name [0] == EOS) ? NULL : get_query (parmp->db, parmp->name);
                              open_qbe (NIL, parmp->db, parmp->table, (sysquery == NULL) ? "" : sysquery->query, (sysquery == NULL) ? "" : sysquery->name);
                              if (sysquery != NULL) mem_free (sysquery);
                              break;
        case CMD_DEFREPORT  : sysreport = (parmp->name [0] == EOS) ? NULL : get_report (parmp->db, parmp->name);
                              open_report (NIL, parmp->db, (sysreport == NULL) ? "" : sysreport->report, (sysreport == NULL) ? "" : sysreport->name, &parmp->fontdesc);
                              if (sysreport != NULL) mem_free (sysreport);
                              break;
        case CMD_DEFACCOUNT : sysaccount = (parmp->name [0] == EOS) ? NULL : get_account (parmp->db, parmp->name);
                              AccDefOpen (NIL, parmp->db, sysaccount);
                              if (sysaccount != NULL) mem_free (sysaccount);
                              break;
        case CMD_DELETE     : if (use_sql)
                                delete_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, parmp->minimize, FALSE);
                              else
                                delete_list (parmp->db, parmp->table, parmp->index, parmp->dir, parmp->minimize, FALSE);
                              break;
        case CMD_DISK       : if (use_sql)
                                keep = print_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, sql_res.cols, sql_res.columns, sql_res.colwidth, DEV_DISK, &parmp->fontdesc, NULL, parmp->filename, parmp->minimize);
                              else
                                mopentbl (parmp->db, parmp->table, parmp->index, parmp->dir, DEV_DISK, &parmp->fontdesc, NULL, parmp->filename, parmp->minimize, FALSE);
                              break;
        case CMD_EDIT       : if (use_sql)
                                open_mask (NIL, sql_res.db,  sql_res.table,  sql_res.inx,  sql_res.dir, parmp->name, NULL, 0L, NULL, (parmp->size.w != 0) ? &parmp->size : NULL, FALSE);
                              else
                                open_mask (NIL, parmp->db, parmp->table, parmp->index, parmp->dir, parmp->name, NULL, 0L, NULL, (parmp->size.w != 0) ? &parmp->size : NULL, FALSE);
                              break;
        case CMD_EXPORT     : if (use_sql)
                                keep = exp_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, sql_res.cols, sql_res.columns, sql_res.colwidth, parmp->filename, parmp->minimize);
                              else
                                mexport (parmp->db, parmp->table, parmp->index, parmp->dir, parmp->filename, parmp->minimize);
                              break;
        case CMD_FLUSHKEYS  : flush_db (parmp->db);
                              break;
        case CMD_IMPORT     : if (use_sql)
                                keep = imp_list (sql_res.db, sql_res.table, sql_res.cols, sql_res.columns, sql_res.colwidth, parmp->filename, parmp->minimize);
                              else
                                mimport (parmp->db, parmp->table, parmp->filename, parmp->minimize);
                              break;
        case CMD_LIST       : if (use_sql)
                                keep = print_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, sql_res.cols, sql_res.columns, sql_res.colwidth, DEV_SCREEN, &parmp->fontdesc, (parmp->size.w != 0) ? &parmp->size : NULL, parmp->query, parmp->minimize);
                              else
                                switch (parmp->table)
                                {
                                  case SYS_CALC    : 
                                  case SYS_QUERY   : 
                                  case SYS_REPORT  : 
                                  case SYS_BATCH   :
                                  case SYS_ACCOUNT : open_syslist (parmp->db, parmp->table, &parmp->fontdesc, (parmp->size.w != 0) ? &parmp->size : NULL, parmp->minimize);
                                                     break;
                                  default          : mopentbl (parmp->db, parmp->table, parmp->index, parmp->dir, DEV_SCREEN, &parmp->fontdesc, (parmp->size.w != 0) ? &parmp->size : NULL, parmp->query, parmp->minimize, FALSE);
                                                     break;
                                } /* switch, else */
                              break;
        case CMD_LOCKSCREEN : if (parmp->db->password [0] != EOS) mlockscreen (parmp->db);
                              break;
        case CMD_MAXIMIZE   : full_window (top);
                              break;
        case CMD_MINIMIZE   : if (top != NULL) miconify (top);
                              break;
        case CMD_PRINT      : if (use_sql)
                                keep = print_list (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, sql_res.cols, sql_res.columns, sql_res.colwidth, DEV_PRINTER, &parmp->fontdesc, NULL, NULL, parmp->minimize);
                              else
                                mopentbl (parmp->db, parmp->table, parmp->index, parmp->dir, DEV_PRINTER, &parmp->fontdesc, NULL, NULL, parmp->minimize, FALSE);
                              break;
        case CMD_REMOVE     : file_remove (parmp->filename);
                              break;
        case CMD_REPORT     : if ((sysreport = get_report (parmp->db, parmp->name)) != NULL)
                              {
                                if (use_sql)
                                  do_report (sql_res.db, sql_res.table, sql_res.inx, sql_res.dir, sysreport->report, parmp->filename, parmp->device, parmp->minimize, parmp->copies, parmp->prn);
                                else
                                  do_report (parmp->db, parmp->table, parmp->index, parmp->dir, sysreport->report, parmp->filename, parmp->device, parmp->minimize, parmp->copies, parmp->prn);
                                mem_free (sysreport);
                              } /* if */
                              break;
        case CMD_SET        : workp->table    = parmp->table;
                              workp->index    = parmp->index;
                              workp->dir      = parmp->dir;
                              workp->fontdesc = parmp->fontdesc;
                              break;
        case CMD_UNDELETE   : undelete_list (parmp->db, SYS_DELETED, 0, ASCENDING, parmp->minimize);
                              break;
      } /* switch */

      impexpcfg   = simpexpcfg;         /* restore original settings */
      page_format = spage_format;
      prncfg      = sprncfg;
      wi_modeless = save_modeless;

      if (! keep)
      {
        mem_free (sql_res.columns);
        set_meminfo ();
      } /* if */

      if (use_sql)
        if (parmp->cmd != CMD_LIST)
        {
          if (VTBL (sql_res.table))
            free_vtable (sql_res.table);

          if (VINX (sql_res.inx))
            free_vindex (sql_res.inx);
        } /* if, if */
    } /* if */
  } /* if */

  if (workp->inx == inx) proc_inf->actrec--; /* use same command one more time */

  workp->inx = inx;

  return (ok);
} /* work_batch */

/*****************************************************************************/

LOCAL BOOLEAN stop_batch (proc_inf)
PROC_INF *proc_inf;

{
  proc_inf->prncfg = NULL;      /* prevent process from being spooled */

  return (TRUE);
} /* stop_batch */

/*****************************************************************************/

LOCAL WORD parse_batch (parsep)
PARSE_SPEC *parsep;

{
  WORD      result;
  WORD      line;
  WORD      inx;
  WORD      col, oldcol;
  BYTE      *bat;
  PARM_SPEC parm;

  result = BATCH_OK;
  bat    = parsep->batch;
  line   = col = oldcol = 1;
  inx    = 0;

  while (bat [inx] != EOS)
  {
    mem_set (&parm, 0, (UWORD)sizeof (PARM_SPEC));

    parm.db    = parsep->db;
    parm.table = parsep->table;
    inx        = scan_cmd (bat, inx, &col, &oldcol, &parm);

    if ((parm.errno == SUCCESS) && (parm.cmd != CMD_NULL))
    {
      inx = scan_parms (bat, inx, &col, &oldcol, &parm);

      if (parm.errno == SUCCESS)
        if (parm.cmd == CMD_SET) parsep->table = parm.table;    /* next default table */
    } /* if */

    if (parm.errno != SUCCESS)
      if (parse_error (parsep, line, oldcol, parm.errno, &result)) return (result);

    if (bat [inx] == CMD_SEP)
    {
      inx++;
      line++;
      col = oldcol = 1;
    } /* if */
  } /* while */

  if (parsep->numerrs > 0) result = BATCH_CANCEL;

  return (result);
} /* parse_batch */

/*****************************************************************************/

LOCAL BOOLEAN parse_error (parsep, line, col, error, result)
PARSE_SPEC *parsep;
WORD       line, col, error, *result;

{
  WORD    i, inx;
  LONGSTR s;
  STRING  bat;
  BYTE    *p;

  for (i = 1, inx = 0; i < line; i++)
    while (parsep->batch [inx++] != LF);

  inx += col - 1;

  while (isspace (parsep->batch [inx])) inx++;

  strncpy (bat, &parsep->batch [inx], MAX_ERRCHARS);
  bat [MAX_ERRCHARS] = EOS;
  if ((p = strchr (bat, CR)) != NULL) *p = EOS;
  if ((p = strchr (bat, LF)) != NULL) *p = EOS;

  sprintf (s, alerts [error], bat, line, col);

  *result = open_alert (s) - 1;

  parsep->numerrs++;
  parsep->cx = col - 1;
  parsep->cy = line - 1;

  return ((*result == BATCH_EDIT) || (*result == BATCH_CANCEL));
} /* parse_error */

/*****************************************************************************/

LOCAL WORD scan_cmd (bat, inx, col, oldcol, parmp)
BYTE      *bat;
WORD      inx, *col, *oldcol;
PARM_SPEC *parmp;

{
  WORD    old;
  LONGSTR s;

  old        = inx;
  parmp->cmd = FAILURE;

  while (isspace (bat [inx]) && (bat [inx] != CMD_SEP)) inx++;

  if ((col != NULL) && (oldcol != NULL)) *oldcol = *col + inx - old;

  if ((bat [inx] == CMD_SEP) || (bat [inx] == COMMENT) || (bat [inx] == EOS))
  {
    parmp->cmd = CMD_NULL;

    if (bat [inx] == COMMENT)
      while ((bat [inx] != CMD_SEP) && (bat [inx] != EOS)) inx++;
  } /* if */
  else
    if (isalpha (ch_ascii (bat [inx])))         /* identifier */
    {
      inx        = get_id (bat, inx, s);
      parmp->cmd = find_cmd (s);
    } /* if, else */

  if (parmp->cmd == FAILURE) parmp->errno = ERR_BAT_NOCMD;

  if (col != NULL) *col += (inx - old);

  return (inx);
} /* scan_cmd */

/*****************************************************************************/

LOCAL WORD scan_parms (bat, inx, col, oldcol, parmp)
BYTE      *bat;
WORD      inx, *col, *oldcol;
PARM_SPEC *parmp;

{
  BOOLEAN done;
  WORD    i, old;
  WORD    parm_inx;
  LONG    parm;
  LONGSTR s;

  old  = inx;
  done = FALSE;

  while (! done && (parmp->errno == SUCCESS))
  {
    while (isspace (bat [inx]) && (bat [inx] != CMD_SEP)) inx++;

    if ((col != NULL) && (oldcol != NULL)) *oldcol = *col + inx - old;

    if ((bat [inx] == CMD_SEP) || (bat [inx] == EOS))
      done = TRUE;
    else
      if (isalpha (ch_ascii (bat [inx])))       /* parameter identifier */
      {
        i = 0;

        while ((bat [inx] != PARM_SEP) && isalpha (ch_ascii (bat [inx])))
          s [i++] = bat [inx++];

        s [i] = EOS;

        parm_inx = find_parm (s);

        if (parm_inx == FAILURE)
          parmp->errno = ERR_BAT_NOPARM;
        else
        {
          while (isspace (bat [inx]) && (bat [inx] != CMD_SEP)) inx++;
          parm = parms [parm_inx].flag;

          if (! (parm & cmds [parmp->cmd].parms))
            parmp->errno = ERR_BAT_WRONGPARM;
          else
            if (bat [inx] != PARM_SEP)
              parmp->errno = ERR_BAT_NOEQU;
            else
            {
              inx++;	                /* eat PARM_SEP */
              if ((col != NULL) && (oldcol != NULL)) *oldcol = *col + inx - old;
              inx = find_parmval (bat, inx, parm_inx, parmp);
            } /* else, else */
        } /* else */
      } /* if */
      else
        parmp->errno = ERR_BAT_NOCMDSEP;
  } /* while */

  if (col != NULL) *col += (inx - old);

  return (inx);
} /* scan_parms */

/*****************************************************************************/

LOCAL WORD find_cmd (name)
BYTE *name;

{
  WORD i;

  str_upper (name);

  for (i = 0; i < sizeof (cmds) / sizeof (CMD); i++)
    if (strcmp (name, cmds [i].cmd) == 0) return (i);

  return (FAILURE);
} /* find_cmd */

/*****************************************************************************/

LOCAL WORD find_parm (name)
BYTE *name;

{
  WORD i;

  str_upper (name);

  for (i = 0; i < sizeof (parms) / sizeof (PARM); i++)
    if (strcmp (name, parms [i].parm) == 0) return (i);

  return (FAILURE);
} /* find_parm */

/*****************************************************************************/

LOCAL WORD find_parmval (bat, inx, parm, parmp)
BYTE      *bat;
WORD      inx, parm;
PARM_SPEC *parmp;

{
  WORD       table, index, id;
  LONGSTR    s;
  TABLE_INFO t_inf;
  INDEX_INFO i_inf;
  FULLNAME   filename;

  while (isspace (bat [inx]) && (bat [inx] != CMD_SEP)) inx++;

  switch (parms [parm].class)
  {
    case CLASS_NULL   : break;
    case CLASS_TABLE  : if (isdigit (bat [inx]))
                        {
                          inx    = get_number (bat, inx, s);
                          table  = atoi (s);
#ifndef PHOENIX
                          if ((table != SYS_CALC) && (table != SYS_QUERY) && (table != SYS_REPORT) && (table != SYS_BATCH) && (table != SYS_ACCOUNT))
                            table += NUM_SYSTABLES;       /* regular users can't see system tables */
#endif
                          table  = v_tableinfo (parmp->db, table, &t_inf);
                        } /* if */
                        else
                        {
                          inx               = get_id (bat, inx, s);
                          s [MAX_FIELDNAME] = EOS;
                          strcpy (t_inf.name, s);
                          table = v_tableinfo (parmp->db, FAILURE, &t_inf);
#ifndef PHOENIX
                          if ((table != SYS_CALC) && (table != SYS_QUERY) && (table != SYS_REPORT) && (table != SYS_BATCH) && (table != SYS_ACCOUNT))
                            if (table < NUM_SYSTABLES) table = FAILURE;
#endif
                        } /* else */

                        if (table == FAILURE)  /* don't change parmp->table */
                          parmp->errno = ERR_BAT_NOTABLE;
                        else
                        {
                          parmp->table = table;
                          parmp->index = 0;     /* reset index */
                        } /* else */
                        break;
    case CLASS_INDEX  : if (isdigit (bat [inx]))
                        {
                          inx   = get_number (bat, inx, s);
                          index = atoi (s);
                          index = v_indexinfo (parmp->db, parmp->table, index, &i_inf);
                        } /* if */
                        else
                        {
                          inx               = get_id (bat, inx, s);
                          s [MAX_FIELDNAME] = EOS;
                          strcpy (i_inf.name, s);
                          index = v_indexinfo (parmp->db, parmp->table, FAILURE, &i_inf);
                        } /* else */

                        if (index == FAILURE)   /* don't change parmp->index */
                          parmp->errno = ERR_BAT_NOINDEX;
                        else
                          parmp->index = index;
                        break;
    case CLASS_DIR    : inx = get_id (bat, inx, s);

                        switch (check_id (ID_ASCENDING, ID_DESCENDING, s))
                        {
                          case ID_ASCENDING  : parmp->dir   = ASCENDING;     break;
                          case ID_DESCENDING : parmp->dir   = DESCENDING;    break;
                          default            : parmp->errno = ERR_BAT_NODIR; break;
                        } /* switch */
                        break;
    case CLASS_STRING : if (bat [inx] != STR_SEP)
                          parmp->errno = ERR_BAT_NOSTRSEP;
                        else
                        {
                          inx = get_string (bat, ++inx, s);

                          switch (parm)
                          {
                            case PARM_QUERY    : strcpy (parmp->query, s);
                                                 break;
                            case PARM_SQL      : /* not yet */
                                                 break;
                            case PARM_NAME     : strcpy (parmp->name, s);
                                                 break;
                            case PARM_FACENAME : parmp->fontdesc.font = FontNumberFromName (s);
                                                 if (parmp->fontdesc.font == FAILURE)
                                                   parmp->fontdesc.font = FONT_SYSTEM;
                                                 break;
                          } /* switch */

                          if (bat [inx] != STR_SEP)
                            parmp->errno = ERR_BAT_NOSTRSEP;
                          else
                            inx++;
                        } /* else */
                        break;
    case CLASS_FILE   : if (bat [inx] != STR_SEP)
                          parmp->errno = ERR_BAT_NOSTRSEP;
                        else
                        {
                          inx = get_string (bat, ++inx, s);

#if GEMDOS | MSDOS
                          str_upper (s);
#endif
                          if ((strchr (s, DRIVESEP) == NULL) && (strchr (s, PATHSEP) == NULL))
                          {
                            strcpy (filename, parmp->db->base->basepath);
                            strcat (filename, s);
                            strcpy (s, filename);
                          } /* if */                          

                          switch (parm)
                          {
                            case PARM_FILE : strcpy (parmp->filename, s); break;
                            case PARM_IMP  : strcpy (parmp->imp, s);      break;
                            case PARM_LAY  : strcpy (parmp->lay, s);      break;
                            case PARM_PRN  : strcpy (parmp->prn, s);      break;
                            case PARM_PRT  : strcpy (parmp->prt, s);      break;
                          } /* switch */

                          if (bat [inx] != STR_SEP)
                            parmp->errno = ERR_BAT_NOSTRSEP;
                          else
                            inx++;
                        } /* else */
                        break;
    case CLASS_NUMBER : inx = get_number (bat, inx, s);
                        if (s [0] == EOS)
                          parmp->errno = ERR_BAT_NONUMBER;
                        else
                          switch (parm)
                          {
                            case PARM_FONTSIZE : parmp->fontdesc.point = atoi (s); break;
                            case PARM_COLOR    : parmp->fontdesc.color = atoi (s); break;
                            case PARM_COPIES   : parmp->copies         = atol (s); break;
                          } /* switch, else */
                        break;
    case CLASS_BOOL   : inx = get_id (bat, inx, s);
                        id  = check_id (ID_FALSE, ID_TRUE, s);

                        if (id == FAILURE)
                          parmp->errno = ERR_BAT_NOBOOL;
                        else
                          switch (parm)
                          {
                            case PARM_EXCLUSIVE : parmp->exclusive = id == ID_TRUE; break;
                            case PARM_MINIMIZE  : parmp->minimize  = id == ID_TRUE; break;
                          } /* switch, else */
                        break;
    case CLASS_DEVICE : inx = get_id (bat, inx, s);

                        switch (check_id (ID_SCREEN, ID_PRINTER, s))
                        {
                          case ID_SCREEN  : parmp->device = DEV_SCREEN;       break;
                          case ID_DISK    : parmp->device = DEV_DISK;         break;
                          case ID_PRINTER : parmp->device = DEV_PRINTER;      break;
                          default         : parmp->errno  = ERR_BAT_NODEVICE; break;
                        } /* switch */
                        break;
    case CLASS_SIZE   : inx = get_size (bat, inx, parmp);
                        break;
  } /* switch */

  return (inx);
} /* find_parmval */

/*****************************************************************************/

LOCAL WORD get_id (bat, inx, id)
BYTE *bat;
WORD inx;
BYTE *id;

{
  WORD i;

  i = 0;

  while (isalnum (ch_ascii (bat [inx])) || (bat [inx] == '_'))
    id [i++] = bat [inx++];

  id [i] = EOS;

  return (inx);
} /* get_id */

/*****************************************************************************/

LOCAL WORD get_string (bat, inx, s)
BYTE *bat;
WORD inx;
BYTE *s;

{
  WORD i;

  i = 0;

  while ((bat [inx] != STR_SEP) && (bat [inx] != CMD_SEP) && (bat [inx] != EOS))
    s [i++] = bat [inx++];

  s [i] = EOS;

  return (inx);
} /* get_string */

/*****************************************************************************/

LOCAL WORD get_number (bat, inx, s)
BYTE *bat;
WORD inx;
BYTE *s;

{
  WORD i;

  i = 0;

  while (isspace (bat [inx]) && (bat [inx] != CMD_SEP)) inx++;
  while (isdigit (bat [inx]))
    s [i++] = bat [inx++];

  s [i] = EOS;

  return (inx);
} /* get_number */

/*****************************************************************************/

LOCAL WORD get_size (bat, inx, parmp)
BYTE      *bat;
WORD      inx;
PARM_SPEC *parmp;

{
  STRING s;

  inx = get_number (bat, inx, s);
  if (s [0] == EOS)
    parmp->errno = ERR_BAT_NONUMBER;
  else
  {
    parmp->size.x = atoi (s);
    parmp->size.x = min (parmp->size.x, (desk.x + desk.w) / gl_wbox - MIN_POS);

    if (bat [inx++] != SIZE_SEP)
      parmp->errno = ERR_BAT_NOSIZESEP;
    else
    {
      inx = get_number (bat, inx, s);
      if (s [0] == EOS)
        parmp->errno = ERR_BAT_NONUMBER;
      else
      {
        parmp->size.y = atoi (s);
        parmp->size.y = min (parmp->size.y, (desk.y + desk.h) / gl_hbox - MIN_POS);

        if (bat [inx++] != SIZE_SEP)
          parmp->errno = ERR_BAT_NOSIZESEP;
        else
        {
          inx = get_number (bat, inx, s);
          if (s [0] == EOS)
            parmp->errno = ERR_BAT_NONUMBER;
          else
          {
            parmp->size.w = atoi (s);
            parmp->size.w = min (parmp->size.w, LONGSTRLEN);

            if (bat [inx++] != SIZE_SEP)
              parmp->errno = ERR_BAT_NOSIZESEP;
            else
            {
              inx = get_number (bat, inx, s);
              if (s [0] == EOS)
                parmp->errno = ERR_BAT_NONUMBER;
              else
                parmp->size.h = atoi (s);
            } /* else */
          } /* else */
        } /* else */
      } /* else */
    } /* else */
  } /* else */

  return (inx);
} /* get_size */

/*****************************************************************************/

LOCAL WORD check_id (low, high, id)
WORD low, high;
BYTE *id;

{
  WORD i;

  str_upper (id);

  for (i = low; i <= high; i++)
    if (strcmp (id, ids [i]) == 0) return (i);

  return (FAILURE);
} /* check_id */

/*****************************************************************************/

LOCAL SYSQUERY *get_query (db, query_name)
DB   *db;
BYTE *query_name;

{
  SYSQUERY *sysquery;
  BOOLEAN  ok;
  CURSOR   cursor;
  LONGSTR  s;

  sysquery = mem_alloc ((LONG)sizeof (SYSQUERY));

  if (sysquery == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sysquery->name, query_name);

    ok = FALSE;

    if (db_search (db->base, SYS_QUERY, 1, ASCENDING, &cursor, sysquery, 0L))
      if (db_read (db->base, SYS_QUERY, sysquery, &cursor, 0L, FALSE))
        ok = TRUE;

    if (! ok)
    {
      sprintf (s, alerts [ERR_BAT_NOQUERY], query_name);
      open_alert (s);
      mem_free (sysquery);
      sysquery = NULL;
      set_meminfo ();
    } /* if */
  } /* else */

  return (sysquery);
} /* get_query */

/*****************************************************************************/

LOCAL SYSCALC *get_calc (db, table, calc_name)
DB       *db;
WORD     table;
BYTE     *calc_name;

{
  SYSCALC    *syscalc;
  BOOLEAN    ok;
  CURSOR     cursor;
  TABLE_INFO t_inf;
  LONGSTR    s;

  syscalc = mem_alloc ((LONG)sizeof (SYSCALC));

  if (syscalc == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    v_tableinfo (db, table, &t_inf);
    strcpy (syscalc->tablename, t_inf.name);
    strcpy (syscalc->name, calc_name);

    ok = FALSE;

    if (db_search (db->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L))
      if (db_read (db->base, SYS_CALC, syscalc, &cursor, 0L, FALSE))
        ok = TRUE;

    if (! ok)
    {
      sprintf (s, alerts [ERR_BAT_NOCALC], calc_name);
      open_alert (s);
      mem_free (syscalc);
      syscalc = NULL;
      set_meminfo ();
    } /* if */
  } /* else */

  return (syscalc);
} /* get_calc */

/*****************************************************************************/

LOCAL SYSREPORT *get_report (db, report_name)
DB   *db;
BYTE *report_name;

{
  SYSREPORT *sysreport;
  BOOLEAN   ok;
  CURSOR    cursor;
  LONGSTR   s;

  sysreport = mem_alloc ((LONG)sizeof (SYSREPORT));

  if (sysreport == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sysreport->name, report_name);

    ok = FALSE;

    if (db_search (db->base, SYS_REPORT, 1, ASCENDING, &cursor, sysreport, 0L))
      if (db_read (db->base, SYS_REPORT, sysreport, &cursor, 0L, FALSE))
        ok = TRUE;

    if (! ok)
    {
      sprintf (s, alerts [ERR_BAT_NOREPORT], report_name);
      open_alert (s);
      mem_free (sysreport);
      sysreport = NULL;
      set_meminfo ();
    } /* if */
  } /* else */

  return (sysreport);
} /* get_report */

/*****************************************************************************/

LOCAL SYSBATCH *get_batch (db, batch_name)
DB   *db;
BYTE *batch_name;

{
  SYSBATCH *sysbatch;
  BOOLEAN  ok;
  CURSOR   cursor;
  LONGSTR  s;

  sysbatch = mem_alloc ((LONG)sizeof (SYSBATCH));

  if (sysbatch == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sysbatch->name, batch_name);

    ok = FALSE;

    if (db_search (db->base, SYS_BATCH, 1, ASCENDING, &cursor, sysbatch, 0L))
      if (db_read (db->base, SYS_BATCH, sysbatch, &cursor, 0L, FALSE))
        ok = TRUE;

    if (! ok)
    {
      sprintf (s, alerts [ERR_BAT_NOBATCH], batch_name);
      open_alert (s);
      mem_free (sysbatch);
      sysbatch = NULL;
      set_meminfo ();
    } /* if */
  } /* else */

  return (sysbatch);
} /* get_batch */

/*****************************************************************************/

LOCAL SYSACCOUNT *get_account (db, account_name)
DB   *db;
BYTE *account_name;

{
  SYSACCOUNT *sysaccount;
  BOOLEAN    ok;
  CURSOR     cursor;
  LONGSTR    s;

  sysaccount = mem_alloc ((LONG)sizeof (SYSACCOUNT));

  if (sysaccount == NULL)
    hndl_alert (ERR_NOMEMORY);
  else
  {
    strcpy (sysaccount->name, account_name);

    ok = FALSE;

    if (db_search (db->base, SYS_ACCOUNT, 1, ASCENDING, &cursor, sysaccount, 0L))
      if (db_read (db->base, SYS_ACCOUNT, sysaccount, &cursor, 0L, FALSE))
        ok = TRUE;

    if (! ok)
    {
      sprintf (s, alerts [ERR_BAT_NOACCOUNT], account_name);
      open_alert (s);
      mem_free (sysaccount);
      sysaccount = NULL;
      set_meminfo ();
    } /* if */
  } /* else */

  return (sysaccount);
} /* get_account */

/*****************************************************************************/

