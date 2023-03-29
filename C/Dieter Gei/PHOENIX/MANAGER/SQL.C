/*****************************************************************************
 *
 * Module : SQL.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the sql process.
 *
 * History:
 * 21.12.02: start_process mit neuem šbergabeparameter
 * 23.02.97: Background processes are no longer interruptable
 * 21.06.96: Long filenames supported in sorting dialog box
 * 31.01.95; Using of variable warn_table added
 * 07.01.95: " accepted as alternate delimiter in SQL statement
 * 29.12.94: Call to m_varsql2sql added
 * 27.02.94: Bug in which_inx fixed
 * 04.11.93: Using fontdesc
 * 15.09.93: RECS_PE changed to 10
 * 27.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "redefs.h"
#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "list.h"
#include "mask.h"
#include "process.h"
#include "resource.h"

#include "export.h"
#include "sql.h"

/****** DEFINES **************************************************************/

#define RECS_PER_EVENT 10       /* number of records per event */

#define MAX_SQLSTR     18
#define MAX_SQLCHR     17

#define SQL_AND         0       /* SQL-Identifiers */
#define SQL_ASC         1
#define SQL_BETWEEN     2
#define SQL_BY          3
#define SQL_DESC        4
#define SQL_DISTINCT    5
#define SQL_FROM        6
#define SQL_IN          7
#define SQL_ISNULL      8
#define SQL_LIKE        9
#define SQL_NOT        10
#define SQL_OR         11
#define SQL_ORDER      12
#define SQL_SELECT     13
#define SQL_SYSDATE    14
#define SQL_SYSTIME    15
#define SQL_SYSSTAMP   16
#define SQL_WHERE      17

#define SQL_ALL        18       /* SQL-Relations and 'all columns' */
#define SQL_EQU        19
#define SQL_NEQ        20
#define SQL_GRT        21
#define SQL_GEQ        22
#define SQL_LES        23
#define SQL_LEQ        24

#define SQL_DEL        25       /* misc SQL-IDs */
#define SQL_STRDEL     26
#define SQL_ALTSTRDEL  27
#define SQL_FORMDEL    28
#define SQL_MINUS      29
#define SQL_LEFTPAR    30
#define SQL_RIGHTPAR   31
#define SQL_LEFTBRACK  32
#define SQL_RIGHTBRACK 33
#define SQL_LEFTBRACE  34
#define SQL_RIGHTBRACE 35
#define SQL_END        36

#define SQL_TABLE      37       /* meta IDs */
#define SQL_COLUMN     38
#define SQL_FORMAT     39
#define SQL_NUMBER     40

#define STR_AND        "AND"    /* string constants */
#define STR_ASC        "ASC"
#define STR_BETWEEN    "BETWEEN"
#define STR_BY         "BY"
#define STR_DESC       "DESC"
#define STR_DISTINCT   "DISTINCT"
#define STR_FROM       "FROM"
#define STR_IN         "IN"
#define STR_ISNULL     "ISNULL"
#define STR_LIKE       "LIKE"
#define STR_NOT        "NOT"
#define STR_OR         "OR"
#define STR_ORDER      "ORDER"
#define STR_SELECT     "SELECT"
#define STR_SYSDATE    "SYSDATE"
#define STR_SYSTIME    "SYSTIME"
#define STR_SYSSTAMP   "SYSTIMESTAMP"
#define STR_WHERE      "WHERE"

#define CHR_ALL        '*'      /* char constants */
#define CHR_EQU        '='
#define CHR_NEQ        '!'
#define CHR_GRT        '>'
#define CHR_LES        '<'
#define CHR_DEL        ','
#define CHR_STRDEL     '\''
#define CHR_ALTSTRDEL  '"'
#define CHR_FORMDEL    ':'
#define CHR_MINUS      '-'
#define CHR_LEFTPAR    '('
#define CHR_RIGHTPAR   ')'
#define CHR_LEFTBRACK  '['
#define CHR_RIGHTBRACK ']'
#define CHR_LEFTBRACE  '{'
#define CHR_RIGHTBRACE '}'
#define CHR_END        ';'

#define MAX_KEYLEN     41       /* max number of chars for sorting */
#define OPEN_CACHE     8L       /* kb's of cache to open tree */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD id;                      /* the ID */
  BYTE *str;                    /* the string */
} SQL_STR;

typedef struct
{
  WORD id;                      /* the ID */
  BYTE chr;                     /* the char */
} SQL_CHR;

typedef struct
{
  WORD id;                      /* the ID */
  WORD value;                   /* table or column number, format value */
} ID;

typedef struct
{
  SQL_SPEC  *sqlp;              /* sql specification */
  BYTE      *buffer;            /* buffer for db operations */
  WORD      vtable;             /* virtual table */
  WORD      vinx;               /* virtual index */
  LONG      numrecs;            /* number of records found */
  WORD      numsort;            /* number of columns actually sorted */
  WORD      colsort [MAX_SORT]; /* actual column sort order */
  WORD      dir;                /* direction to output */
  WORD      fastinx;            /* number of fast index */
  WORD      fastcol;            /* number of fast column */
  WORD      fastrow;            /* row of condition of fast index */
  WORD      type;               /* type of fast index */
  WORD      rel;                /* relation of fast index */
  KEY       lower;              /* lower keyvalue of fast index */
  KEY       upper;              /* upper keyvalue of fast index */
  BOOLEAN   occupied;           /* fast row is occupied by other conditions */
  BOOLEAN   empty;              /* conditions are empty */
  BOOLEAN   sorted;             /* virtual table is sorted after the search */
  BOOLEAN   background;         /* query is in the background */
  FIELDNAME sql_name;           /* sql name */
  FULLNAME  treename;           /* name of tree file */
  TREEINF   *treeinf;           /* pointer to tree information */
  KEY_DFN   key_dfn;            /* key definition for first key */
  WORD      key_addr [MAX_SORT];/* adresses of key values */
  WORD      key_size [MAX_SORT];/* size of key values */
  WORD      key_type [MAX_SORT];/* type of key values */
  WORD      key_len;            /* size of all key values */
  FULLNAME  key_name;           /* name of key file */
  FILE      *key_file;          /* file of all keys */
  LONG      buf_addr [MAX_SORT];/* adresses of key values in buffer */
  LONG      same_keys;          /* max overall number of same keys */
  LONG      same_key;           /* max number of same key */
  KEY       last;               /* last key value */
  BYTE      *sortbuf;           /* buffer of keys to be sorted */
  WORD      sorttype;           /* actual sort type for quicksort */
  WORD      sortaddr;           /* actual sort address for quicksort */
  BOOLEAN   sortdir;            /* actual sort direction for quicksort */
} WORK_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORK_SPEC  *sworkp;       /* sorting work pointer */
LOCAL WORD       sql_errors;    /* number of sql-errors occured */
LOCAL SQL_RESULT *sql_res;      /* result of last sql query */

LOCAL SQL_STR    sql_str [MAX_SQLSTR] =
{
  {SQL_AND,       STR_AND},
  {SQL_ASC,       STR_ASC},
  {SQL_BETWEEN,   STR_BETWEEN},
  {SQL_BY,        STR_BY},
  {SQL_DESC,      STR_DESC},
  {SQL_DISTINCT,  STR_DISTINCT},
  {SQL_FROM,      STR_FROM},
  {SQL_IN,        STR_IN},
  {SQL_ISNULL,    STR_ISNULL},
  {SQL_LIKE,      STR_LIKE},
  {SQL_NOT,       STR_NOT},
  {SQL_OR,        STR_OR},
  {SQL_ORDER,     STR_ORDER},
  {SQL_SELECT,    STR_SELECT},
  {SQL_SYSDATE,   STR_SYSDATE},
  {SQL_SYSTIME,   STR_SYSTIME},
  {SQL_SYSSTAMP,  STR_SYSSTAMP},
  {SQL_WHERE,     STR_WHERE}
};

LOCAL SQL_CHR    sql_chr [MAX_SQLCHR] =
{
  {SQL_ALL,        CHR_ALL},
  {SQL_EQU,        CHR_EQU},
  {SQL_NEQ,        CHR_NEQ},
  {SQL_GRT,        CHR_GRT},
  {SQL_LES,        CHR_LES},
  {SQL_DEL,        CHR_DEL},
  {SQL_STRDEL,     CHR_STRDEL},
  {SQL_ALTSTRDEL,  CHR_ALTSTRDEL},
  {SQL_FORMDEL,    CHR_FORMDEL},
  {SQL_MINUS,      CHR_MINUS},
  {SQL_LEFTPAR,    CHR_LEFTPAR},
  {SQL_RIGHTPAR,   CHR_RIGHTPAR},
  {SQL_LEFTBRACK,  CHR_LEFTBRACK},
  {SQL_RIGHTBRACK, CHR_RIGHTBRACK},
  {SQL_LEFTBRACE,  CHR_LEFTBRACE},
  {SQL_RIGHTBRACE, CHR_RIGHTBRACE},
  {SQL_END,        CHR_END}
};

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN which_inx    _((SQL_SPEC *sqlp, WORD *inx, WORD *dir));
LOCAL BOOLEAN show_list    _((SQL_SPEC *sqlp, WORD table, WORD inx, WORD dir, BYTE *sql_name));
LOCAL BOOLEAN search_recs  _((SQL_SPEC *sqlp, WORD inx, WORD dir, BOOLEAN empty, BYTE *sql_name, BOOLEAN background));
LOCAL BOOLEAN test_fast    _((SQL_SPEC *sqlp, WORK_SPEC *workp));
LOCAL VOID    cond2qbe     _((SQL_SPEC *sqlp, BYTE *cond));
LOCAL VOID    qbe2cond     _((SQL_SPEC *sqlp, BYTE *cond, WORD type));
LOCAL BOOLEAN row_occupied _((BYTE *text, WORD row));

LOCAL BOOLEAN work_sql     _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_sql     _((PROC_INF *proc_inf));

LOCAL VOID    sort         _((SQL_SPEC *sqlp, WORK_SPEC *workp, RECT *r));
LOCAL VOID    quicksort    _((SQL_SPEC *sqlp, WORK_SPEC *workp, LONG l, LONG r, WORD col));
LOCAL INT     compare      _((LONG *arg1, LONG *arg2));
LOCAL VOID    draw_number  _((LONG number, WORD obj));
LOCAL BOOLEAN check_record _((SQL_SPEC *sqlp, WORK_SPEC *workp));

LOCAL WORD    get_values   _((SQL_SPEC *sqlp, WORD type, WORD format, BYTE *s, VOID *lower, VOID *upper));
LOCAL WORD    get_value    _((SQL_SPEC *sqlp, WORD type, WORD format, WORD inx, BYTE *s, VOID *value));
LOCAL WORD    get_id       _((SQL_SPEC *sqlp, BYTE *s, WORD inx, BOOLEAN tbl, BOOLEAN col, ID *id));
LOCAL WORD    get_format   _((BYTE *s, WORD inx, ID *id));
LOCAL VOID    scan_str     _((BYTE *s, ID *id));
LOCAL WORD    scan_char    _((BYTE *s, WORD inx, ID *id));
LOCAL WORD    scan         _((BYTE *s, WORD inx, BOOLEAN between));
LOCAL WORD    sql_error    _((WORD errornum, BYTE *sqlstr));
LOCAL BOOLEAN col_present  _((WORD *columns, WORD col, WORD cols));
LOCAL VOID    strlcpy      _((BYTE *dst, BYTE *src, WORD len));
LOCAL VOID    strlcat      _((BYTE *dst, BYTE *src, WORD len));

/*****************************************************************************/

GLOBAL BOOLEAN init_sql ()

{
  return (TRUE);
} /* init_sql */

/*****************************************************************************/

GLOBAL BOOLEAN term_sql ()

{
  return (TRUE);
} /* term_sql */

/*****************************************************************************/

GLOBAL VOID sql_exec (db, sql, sql_name, background, sql_result)
DB         *db;
BYTE       *sql, *sql_name;
BOOLEAN    background;
SQL_RESULT *sql_result;

{
  WORD       table, inx, dir;
  BYTE       *p, *memory;
  SQL_SPEC   *sqlp;
  TABLE_INFO t_info;
  LONG       bytes;
  BOOLEAN    found, empty, ok;

  sql_res = sql_result;
  if (sql_res != NULL)
  {
    mem_set (sql_res, 0, sizeof (SQL_RESULT));
    background = FALSE;                         /* wait for result */
  } /* if */

  if (strchr (sql, CHR_LEFTBRACE) != NULL)
  {
    memory = mem_alloc (sizeof (QUERYDEF));

    if (memory == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      return;
    } /* if */
    else
    {
      ok = m_varsql2sql (NULL, db, sql, memory);

      if (ok)
        strcpy (sql, memory);
      
      mem_free (memory);

      if (! ok) return;			/* user canceled parameter query */
    } /* if */
  } /* if */

  p = strstr (sql, sql_str [SQL_FROM].str);

  if (p != NULL)                        /* look for table */
  {
    for (p += 4; isspace (*p); p++);
    strncpy (t_info.name, p, MAX_TABLENAME);
    t_info.name [MAX_TABLENAME] = EOS;
    for (p = t_info.name; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
    *p    = EOS;
    table = v_tableinfo (db, FAILURE, &t_info);

    bytes  = sizeof (SQL_SPEC) + 2L * t_info.cols * sizeof (WORD) + t_info.cols + sizeof (QUERYDEF) + t_info.cols * MAX_OR + MAX_TEXT;
    memory = mem_alloc (bytes);

    if (memory == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      return;
    } /* if */

    sqlp             = (SQL_SPEC *)memory;
    memory          += sizeof (SQL_SPEC);
    sqlp->db         = db;
    sqlp->table      = table;
    sqlp->cols       = t_info.cols;
    sqlp->columns    = (WORD *)memory;
    memory          += t_info.cols * sizeof (WORD);
    sqlp->colwidth   = (WORD *)memory;
    memory          += t_info.cols * sizeof (WORD);
    sqlp->colheader  = NULL;
    sqlp->colflags   = (UBYTE *)memory;
    memory          += t_info.cols;
    sqlp->sqlstr     = memory;
    memory          += sizeof (QUERYDEF);
    sqlp->text       = memory;
    sqlp->max_text   = t_info.cols * MAX_OR + MAX_TEXT;

    strcpy (sqlp->sqlstr, sql);

    if (set_sql (sqlp, FALSE, FALSE))
    {
      found = which_inx (sqlp, &inx, &dir);
      empty = strlen (sqlp->text) == t_info.cols * MAX_OR - 1;

      if (empty && (found || (sqlp->numsort == 0)))
      {
        show_list (sqlp, sqlp->table, inx, dir, sql_name); /* no where condition, order by an existing index, or no order at all */
        mem_free (sqlp);
      } /* if */
      else
        if (! search_recs (sqlp, inx, dir, empty, sql_name, background))
          mem_free (sqlp); /* mem_free in stop_sql if TRUE */
    } /* if */
    else
      mem_free (sqlp);
  } /* if */

  set_meminfo ();
} /* sql_exec */

/*****************************************************************************/

GLOBAL BOOLEAN set_sql (sqlp, checkonly, qbemode)
SQL_SPEC *sqlp;
BOOLEAN  checkonly, qbemode;

{
  BYTE       *str, *p;
  TABLE_INFO t_info;
  FIELD_INFO f_info;
  ID         id;
  WORD       inx, old, cols, col;
  WORD       i, row, relpos;
  BOOLEAN    more, access;
  LONGSTR    cond;

  get_date (&sqlp->date);
  get_time (&sqlp->time);
  get_tstamp (&sqlp->timestamp);

  sql_errors = 0;
  str        = sqlp->sqlstr;
  p          = strstr (str, sql_str [SQL_FROM].str);

  if (p != NULL)                        /* look for table */
  {
    for (p += 4; isspace (*p); p++);
    strncpy (t_info.name, p, MAX_TABLENAME);
    t_info.name [MAX_TABLENAME] = EOS;
    for (p = t_info.name; isalnum (ch_ascii (*p)) || (*p == '_'); p++);
    *p          = EOS;
    sqlp->table = v_tableinfo (sqlp->db, FAILURE, &t_info);

    if (sqlp->table == FAILURE)
      if (sql_error (ERR_NOTABLE, t_info.name) == 2) return (FALSE);
  } /* if */

  inx = get_id (sqlp, str, old = 0, FALSE, FALSE, &id);

  if (id.id != SQL_SELECT)
    if (sql_error (ERR_NOSELECT, str + old) == 2) return (FALSE);

  v_tableinfo (sqlp->db, sqlp->table, &t_info);

  if (! checkonly)
  {
    sqlp->numsort = 0;
    mem_set (sqlp->colsort, 0, sizeof (sqlp->colsort));
    mem_set (sqlp->colflags, 0, t_info.cols);
    mem_set (sqlp->text, FS, t_info.cols * MAX_OR);
    for (row = 0; row < MAX_OR; row++) sqlp->text [(row + 1) * t_info.cols - 1] = RS;
    sqlp->text [t_info.cols * MAX_OR - 1] = EOS;
    sqlp->max_text = t_info.cols * MAX_OR + MAX_TEXT;
  } /* if */

  inx  = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
  more = TRUE;
  cols = 0;

  while (more)                          /* get columns */
  {
    if (id.id == SQL_ALL)               /* init all columns */
    {
      cols = init_columns (sqlp->db, sqlp->table, t_info.cols, sqlp->columns, sqlp->colwidth);

      if (! checkonly)
        for (i = 0; i < cols; i++)      /* initialize colflags */
          sqlp->colflags [sqlp->columns [i]] = COL_PRESENT;

      col  = cols;
      more = FALSE;
      inx  = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
    } /* if */
    else
      if (id.id == SQL_COLUMN)          /* one single column */
      {
        access = (db_acc_column (sqlp->db->base, sqlp->table, id.value) & GRANT_SELECT) != 0;

        if (access && ! checkonly)
        {
          sqlp->columns [cols]      = id.value;
          sqlp->colwidth [cols]     = def_width (sqlp->db, sqlp->table, id.value);
          sqlp->colflags [id.value] = COL_PRESENT;
        } /* if */

        inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

        if (id.id == SQL_DEL)           /* get more columns */
          inx = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
        else
          if (id.id == SQL_FORMDEL)     /* format the column */
          {
            inx = get_format (str, old = inx, &id);

            if (id.id == SQL_FORMAT)    /* get the format width */
            {
              if (id.value > LONGSTRLEN)
                id.value = LONGSTRLEN;
              else
                if (id.value < -LONGSTRLEN) id.value = -LONGSTRLEN;

              if (access && ! checkonly) sqlp->colwidth [cols] = id.value;
              inx  = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
              more = id.id == SQL_DEL;          /* get more columns? */
              if (more) inx = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
            } /* if */
            else
              if (sql_error (ERR_NONUMBER, str + old) == 2) return (FALSE);
          } /* if */
          else
            more = FALSE;

        if (access) cols++;             /* one more column */
      } /* if */
      else
      {
        more = FALSE;
        if (sql_error (ERR_NOCOLUMN, str + old) == 2) return (FALSE);
      } /* else, else */
  } /* while */

  if (! checkonly)
  {
    if (cols < t_info.cols)             /* initialize columns not in query */
      for (i = 1, col = cols; i < t_info.cols; i++)
        if (db_acc_column (sqlp->db->base, sqlp->table, i) & GRANT_SELECT)
          if (! col_present (sqlp->columns, i, cols))
          {
            sqlp->columns [col]    = i;
            sqlp->colwidth [col++] = def_width (sqlp->db, sqlp->table, i);
          } /* if, if, for, if */

    sqlp->cols = col;
  } /* if */

  if (id.id == SQL_FROM)
    inx = get_id (sqlp, str, old = inx, TRUE, FALSE, &id);
  else
    if (sql_error (ERR_NOFROM, str + old) == 2) return (FALSE);

  if (id.id == SQL_TABLE)               /* table found */
  {
    sqlp->table = id.value;
    inx         = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
  } /* if */
  else
    if (sql_error (ERR_NOTABLE, str + old) == 2) return (FALSE);

  if (id.id == SQL_WHERE)               /* "where" condition */
  {
    inx  = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
    more = TRUE;
    row  = 0;

    while (more)
    {
      if (id.id == SQL_COLUMN)
      {
        col = id.value;
        db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);

        while (isspace (str [inx])) inx++;     /* eat spaces */

        inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

        if ((SQL_EQU <= id.id) && (id.id <= SQL_LEQ) || id.id == SQL_BETWEEN)
          relpos = old;
        else
          if (sql_error (ERR_NOREL, str + old) == 2) return (FALSE);

        if (id.id == SQL_BETWEEN)
        {
          inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
          if ((id.id != SQL_NUMBER) && (id.id != SQL_STRDEL) && (id.id != SQL_ALTSTRDEL) && (id.id != SQL_LEFTBRACE) && ((id.id != SQL_SYSDATE) || (f_info.type != TYPE_DATE)) && ((id.id != SQL_SYSTIME) || (f_info.type != TYPE_TIME)) && ((id.id != SQL_SYSSTAMP) || (f_info.type != TYPE_TIMESTAMP)))
            if (sql_error (ERR_NOEXPRESSION, str + old) == 2) return (FALSE);

          inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
          if (id.id != SQL_AND)
            if (sql_error (ERR_NOAND, str + old) == 2) return (FALSE);

          inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
          if ((id.id != SQL_NUMBER) && (id.id != SQL_STRDEL) && (id.id != SQL_ALTSTRDEL) && (id.id != SQL_LEFTBRACE) && ((id.id != SQL_SYSDATE) || (f_info.type != TYPE_DATE)) && ((id.id != SQL_SYSTIME) || (f_info.type != TYPE_TIME)) && ((id.id != SQL_SYSSTAMP) || (f_info.type != TYPE_TIMESTAMP)))
            if (sql_error (ERR_NOEXPRESSION, str + old) == 2) return (FALSE);
        } /* if */
        else
        {
          inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

          if ((id.id != SQL_NUMBER) && (id.id != SQL_STRDEL) && (id.id != SQL_ALTSTRDEL) && (id.id != SQL_LEFTBRACE) && ((id.id != SQL_SYSDATE) || (f_info.type != TYPE_DATE)) && ((id.id != SQL_SYSTIME) || (f_info.type != TYPE_TIME)) && ((id.id != SQL_SYSSTAMP) || (f_info.type != TYPE_TIMESTAMP)))
            if (sql_error (ERR_NOEXPRESSION, str + old) == 2) return (FALSE);
        } /* else */

        for (i = 0; relpos < inx; relpos++)             /* get condition string */
          cond [i++] = str [relpos];

        cond [i] = EOS;

        if (! checkonly)
        {
          if (qbemode) cond2qbe (sqlp, cond);
          if (! set_cond (sqlp->text, row, col, cond, sqlp->max_text))
            if (sql_error (ERR_TOOMANYCONDS, str + old) == 2) return (FALSE);
        } /* if */

        inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

        if ((id.id == SQL_AND) || (id.id == SQL_OR))    /* get more columns */
        {
          if (id.id == SQL_OR)
            if (row < MAX_OR - 1)
              row++;
            else
              if (sql_error (ERR_TOOMANYORS, str + old) == 2) return (FALSE);

          inx = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
        } /* if */
        else
          more = FALSE;
      } /* if */
      else
        if (sql_error (ERR_NOCOLUMN, str + old) == 2) return (FALSE);
    } /* while */
  } /* if */

  if (id.id == SQL_ORDER)               /* "order by" specification */
  {
    inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

    if (id.id == SQL_BY)
    {
      inx  = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
      more = TRUE;

      while (more)
        if (id.id == SQL_COLUMN)
        {
          if (! checkonly) sqlp->colsort [sqlp->numsort] = id.value;
          inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);

          if ((id.id == SQL_ASC) || (id.id == SQL_DESC))
          {
            if (! checkonly)
              if (id.id == SQL_DESC) sqlp->colsort [sqlp->numsort] |= DESC_ORDER;
            inx = get_id (sqlp, str, old = inx, FALSE, FALSE, &id);
          } /* if */

          if (! checkonly) sqlp->numsort++;     /* one more column to sort */

          if (id.id == SQL_DEL)           /* get more columns */
            inx = get_id (sqlp, str, old = inx, FALSE, TRUE, &id);
          else
            more = FALSE;
        } /* if */
        else
          if (sql_error (ERR_NOCOLUMN, str + old) == 2) return (FALSE);
    } /* if */
    else
      if (sql_error (ERR_NOBY, str + old) == 2) return (FALSE);
  } /* if */

  if (id.id != SQL_END)
    if (sql_error (ERR_NOSEMICOLON, str + old) == 2) return (FALSE);

  return (sql_errors == 0);
} /* set_sql */

/*****************************************************************************/

GLOBAL BOOLEAN get_sql (sqlp)
SQL_SPEC *sqlp;

{
  WORD       i, row, inx, col, width, oldcol;
  BOOLEAN    desc, first, firstrow, firstcol, def, present, order;
  TABLE_INFO t_info;
  FIELD_INFO f_info;
  BYTE       *str;
  LONGSTR    s;

  if (v_tableinfo (sqlp->db, sqlp->table, &t_info) == FAILURE) return (FALSE);

  str = sqlp->sqlstr;

  strcpy (str, sql_str [SQL_SELECT].str);
  inx = strlen (str);

  for (i = 0, first = present = def = order = TRUE, col = FAILURE; i < sqlp->cols; i++)
  {
    oldcol = col;
    col    = sqlp->columns [i];

    if (col < oldcol) order = FALSE;    /* at least one column has been rearranged */

    if (sqlp->colflags [col] & COL_PRESENT)
    {
      db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);
      if (! first) chrcat (str, CHR_DEL);
      chrcat (str, SP);
      strcat (str, f_info.name);

      width = sqlp->colwidth [i];

      if (width != def_width (sqlp->db, sqlp->table, col))
      {
        def = FALSE;                    /* at least one column has not the default width */
        chrcat (str, CHR_FORMDEL);
        sprintf (s, "%d", width);
        strcat (str, s);
      } /* if */

      first = FALSE;
    } /* if */
    else
      present = FALSE;                  /* at least one column is not present */
  } /* for */

  if (present && def && order)
  {
    str [inx] = EOS;                    /* cut off all columns */
    chrcat (str, SP);
    chrcat (str, CHR_ALL);
  } /* if */

  chrcat (str, SP);
  strcat (str, sql_str [SQL_FROM].str);

  chrcat (str, SP);
  strcat (str, t_info.name);

  if (strlen (sqlp->text) != MAX_OR * t_info.cols - 1)  /* WHERE clause */
  {
    chrcat (str, SP);
    strcat (str, sql_str [SQL_WHERE].str);

    for (row = 0, firstrow = TRUE; row < MAX_OR; row++)
    {
      for (i = 0, firstcol = TRUE; i < sqlp->cols; i++)
      {
        col = sqlp->columns [i];
        get_cond (sqlp->text, row, col, s);

        if (s [0] != EOS)
        {
          if (! firstcol)
          {
            chrcat (str, SP);
            strcat (str, sql_str [SQL_AND].str);
          } /* if */
          else
            if (! firstrow)
            {
              chrcat (str, SP);
              strcat (str, sql_str [SQL_OR].str);
            } /* if */

          db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);

          chrcat (str, SP);
          strcat (str, f_info.name);
          chrcat (str, SP);
          qbe2cond (sqlp, s, f_info.type);
          strcat (str, s);                      /* concatenate condition */

          firstcol = FALSE;
        } /* if */
      } /* for */

      if (! firstcol) firstrow = FALSE;         /* at least one column in a row */
    } /* for */
  } /* if */

  if (sqlp->numsort > 0)
  {
    chrcat (str, SP);
    strcat (str, sql_str [SQL_ORDER].str);
    chrcat (str, SP);
    strcat (str, sql_str [SQL_BY].str);

    for (i = 0, first = TRUE; i < sqlp->numsort; i++)
    {
      col   = sqlp->colsort [i];
      desc  = (col & DESC_ORDER) != 0;
      col  &= ~ DESC_ORDER;

      db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);
      if (! first) chrcat (str, CHR_DEL);
      chrcat (str, SP);
      strcat (str, f_info.name);

      if (desc)
      {
        chrcat (str, SP);
        strcat (str, sql_str [SQL_DESC].str);
      } /* if */

      first = FALSE;
    } /* for */
  } /* if */

  chrcat (str, CHR_END);

  return (TRUE);
} /* get_sql */

/*****************************************************************************/

GLOBAL WORD get_order (sqlp, col)
SQL_SPEC *sqlp;
WORD     col;

{
  WORD result, i, sortcol, desc;

  result = 0;

  for (i = 0; i < sqlp->numsort; i++)
  {
    sortcol  = sqlp->colsort [i];
    desc     = sortcol & DESC_ORDER;
    sortcol &= ~ DESC_ORDER;

    if (sortcol == col) return ((i + 1) | desc);
  } /* for */

  return (result);
} /* get_order */

/*****************************************************************************/

GLOBAL VOID get_cond (text, row, col, cond)
BYTE *text;
WORD row, col;
BYTE *cond;

{
  text += get_pos (text, row, col);

  while ((*text != FS) && (*text != RS) && (*text != EOS)) *cond++ = *text++;

  *cond = EOS;
} /* get_cond */

/*****************************************************************************/

GLOBAL BOOLEAN set_cond (text, row, col, cond, max_text)
BYTE *text;
WORD row, col;
BYTE *cond;
WORD max_text;

{
  BOOLEAN ok;
  WORD    textlen, condlen, pos;

  textlen = strlen (text) + 1;
  condlen = strlen (cond);
  ok      = textlen + condlen <= max_text;

  if (ok)
  {
    pos = get_pos (text, row, col);
    mem_move (text + pos + condlen, text + pos, textlen - pos);
    mem_move (text + pos, cond, condlen);
  } /* if */

  return (ok);
} /* set_cond */

/*****************************************************************************/

GLOBAL VOID del_cond (text, row, col)
BYTE *text;
WORD row, col;

{
  WORD textlen, condlen, pos;
  BYTE *p;

  textlen = strlen (text) + 1;
  pos     = get_pos (text, row, col);

  for (condlen = 0, p = text + pos; (*p != FS) && (*p != RS) && (*p != EOS); condlen++, p++);

  mem_move (text + pos, text + pos + condlen, textlen - pos - condlen);
} /* del_cond */

/*****************************************************************************/

GLOBAL WORD get_pos (text, row, col)
BYTE *text;
WORD row, col;

{
  REG WORD pos, i;

  for (i = pos = 0; i < row; i++)
    while (text [pos++] != RS);

  for (i = 0; i < col; i++)
    while (text [pos++] != FS);

  return (pos);
} /* get_pos */

/*****************************************************************************/

LOCAL BOOLEAN which_inx (sqlp, inx, dir)
SQL_SPEC *sqlp;
WORD     *inx, *dir;

{
  BOOLEAN    found, desc, prev, first;
  WORD       i, j, num_cols, col1, col2;
  TABLE_INFO t_info;
  INDEX_INFO i_info;

  found = FALSE;
  *inx  = 0;
  *dir  = ASCENDING;

  if (sqlp->numsort > 0)
  {
    v_tableinfo (sqlp->db, sqlp->table, &t_info);

    for (i = 0; i < t_info.indexes; i++)
    {
      v_indexinfo (sqlp->db, sqlp->table, i, &i_info);
      num_cols = i_info.inxcols.size / sizeof (INXCOL);
      found    = FALSE;

      if (i_info.inxcols.cols [0].col == (sqlp->colsort [0] & ~ DESC_ORDER))
        if (*inx == 0)
        {
          *inx = i;					/* at least the first key is the same */

          for (j = 0, first = (sqlp->colsort [0] & DESC_ORDER) != 0; j< min (num_cols, sqlp->numsort); j++)
          {
            col1  = i_info.inxcols.cols [j].col;
            col2  = sqlp->colsort [j];
            desc  = (col2 & DESC_ORDER) != 0;
            col2 &= ~ DESC_ORDER;

            if ((col1 != col2) || (first != desc))	/* one column not the same or not all columns in same sort order */
            {
              *inx = 0;					/* try next index */
              break;
            } /* if */
          } /* for */
        } /* if, if */

      if (num_cols == sqlp->numsort)
        for (j = 0, found = TRUE, desc = FALSE; (j < sqlp->numsort) && found; j++)
        {
          col1  = i_info.inxcols.cols [j].col;
          col2  = sqlp->colsort [j];
          prev  = desc;
          desc  = (col2 & DESC_ORDER) != 0;
          col2 &= ~ DESC_ORDER;

          if (j == 0) prev = desc;

          if ((col1 != col2) || (prev != desc)) found = FALSE;
        } /* for, if */

      if (found)
      {
        *inx = i;
        *dir = desc ? DESCENDING : ASCENDING;
        break;
      } /* if */
    } /* for */
  } /* if */

  return (found);
} /* which_inx */

/*****************************************************************************/

LOCAL BOOLEAN show_list (sqlp, table, inx, dir, sql_name)
SQL_SPEC *sqlp;
WORD     table, inx, dir;
BYTE     *sql_name;

{
  WORD    i, cols, *columns, *colwidth;
  WINDOWP top;

  for (i = cols = 0; i < sqlp->cols; i++)
    if (sqlp->colflags [sqlp->columns [i]] & COL_PRESENT) cols++;

  if (cols == 0)
  {
    hndl_alert (ERR_NOCOLUMNS);
    return (FALSE);
  } /* if */

  columns = (WORD *)mem_alloc (2L * cols * sizeof (WORD)); /* mem_free in module list */

  if (columns == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (FALSE);
  } /* if */

  set_meminfo ();
  colwidth = columns + cols;

  for (i = cols = 0; i < sqlp->cols; i++)
    if (sqlp->colflags [sqlp->columns [i]] & COL_PRESENT)
    {
      columns [cols]    = sqlp->columns [i];
      colwidth [cols++] = sqlp->colwidth [i];
    } /* if, for */

  if (sql_res != NULL)
  {
    sql_res->db       = sqlp->db;
    sql_res->table    = table;
    sql_res->inx      = inx;
    sql_res->dir      = dir;
    sql_res->cols     = cols;
    sql_res->columns  = columns;
    sql_res->colwidth = colwidth;
    strcpy (sql_res->sql_name, sql_name);
  } /* if */
  else
  {
    top = find_top ();

    if (! print_list (sqlp->db, table, inx, dir, cols, columns, colwidth, DEV_SCREEN, &fontdesc, NULL, sql_name, minimize))
    {
      mem_free (columns);
      set_meminfo ();
      return (FALSE);
    } /* if */

    if (top != NULL)
      if (top->flags & WI_MODAL) top_window (top);
  } /* else */

  return (TRUE);
} /* show_list */

/*****************************************************************************/

LOCAL BOOLEAN search_recs (sqlp, inx, dir, empty, sql_name, background)
SQL_SPEC *sqlp;
WORD     inx, dir;
BOOLEAN  empty;
BYTE     *sql_name;
BOOLEAN  background;

{
  WINDOWP    window;
  LONG       numkeys, bytes;
  PROC_INF   proc_inf, *procp;
  WORK_SPEC  *workp;
  BYTE       *title;
  WORD       i;
  STRING     s;
  TABLE_INFO t_info;
  FIELD_INFO f_info;
  INDEX_INFO i_info;
  INXCOLS    inxcols;
  BOOLEAN    ok;

  numkeys = num_keys (sqlp->db, sqlp->table, 0);

  if (warn_table)
    if (numkeys == 0)
      if (hndl_alert (ERR_NOKEYS) == 2) return (FALSE);

  if (! (db_acc_table (sqlp->db->base, sqlp->table) & GRANT_SELECT))
  {
    dberror (sqlp->db->base->basename, DB_CNOACCESS);
    return (FALSE);
  } /* if */

  proc_inf.db          = sqlp->db;
  proc_inf.table       = sqlp->table;
  proc_inf.inx         = inx;
  proc_inf.dir         = dir;
  proc_inf.cols        = 0;
  proc_inf.columns     = NULL;
  proc_inf.colwidth    = NULL;
  proc_inf.cursor      = db_newcursor (sqlp->db->base);
  proc_inf.format      = 0;
  proc_inf.maxrecs     = numkeys;
  proc_inf.events_ps   = events_ps;
  proc_inf.recs_pe     = RECS_PER_EVENT;
  proc_inf.impexpcfg   = NULL;
  proc_inf.page_format = NULL;
  proc_inf.prncfg      = NULL;
  proc_inf.to_printer  = FALSE;
  proc_inf.binary      = FALSE;
  proc_inf.tmp         = TRUE;
  proc_inf.special     = 0;
  proc_inf.filelength  = 0;
  proc_inf.workfunc    = work_sql;
  proc_inf.stopfunc    = stop_sql;

  strcpy (proc_inf.filename, temp_name (NULL));

  if (proc_inf.cursor == NULL)
  {
    hndl_alert (ERR_NOCURSOR);
    return (FALSE);
  } /* if */

  proc_inf.file = fopen (proc_inf.filename, WRITE_BIN);

  if (proc_inf.file == NULL)
  {
    db_freecursor (sqlp->db->base, proc_inf.cursor);
    file_error (ERR_FILECREATE, proc_inf.filename);
    return (FALSE);
  } /* if */

  v_tableinfo (sqlp->db, sqlp->table, &t_info);

  bytes  = sizeof (WORK_SPEC) + t_info.size;
  title  = FREETXT (FPSEARCH);
  window = crt_process (NULL, NULL, NIL, title, &proc_inf, bytes, background ? wi_modeless : WI_MODAL);

  if (window != NULL)
  {
    procp = (PROC_INF *)window->special;
    workp = (WORK_SPEC *)procp->memory;

    mem_lset (workp, 0, bytes);

    workp->sqlp       = sqlp;
    workp->buffer     = procp->memory + sizeof (WORK_SPEC);
    workp->vtable     = FAILURE;
    workp->dir        = ASCENDING;
    workp->empty      = empty;
    workp->sorted     = TRUE;
    workp->background = background;

    strcpy (workp->sql_name, sql_name);

    if (sqlp->numsort > 0)
      if (sqlp->colsort [0] & DESC_ORDER)
      {
        workp->dir = DESCENDING;        /* output descending order */

        for (i = 0; i < sqlp->numsort; i++)
          sqlp->colsort [i] ^= DESC_ORDER; /* revert all order flags */
      } /* if */ 

    if (test_fast (sqlp, workp))        /* look for fast query */
    {
      procp->inx = workp->fastinx;
      procp->dir = ASCENDING;

      sort_name (procp->db, procp->table, procp->inx, procp->dir, s);
      strcpy (procp->inxstr, s + 1);    /* 1 blank */
    } /* if */

    if (procp->inx != 0)                /* set actual sort order */
    {
      v_indexinfo (sqlp->db, sqlp->table, procp->inx, &i_info);

      workp->type = i_info.type;
      set_null (workp->type, workp->last);

      workp->numsort = i_info.inxcols.size / sizeof (INXCOL);

      for (i = 0; i < workp->numsort; i++)
        workp->colsort [i] = i_info.inxcols.cols [i].col;
    } /* if */

    workp->vinx = procp->inx;

    if (sqlp->numsort > 0)      /* look for already sorted order */
    {
      workp->sorted = workp->numsort >= sqlp->numsort; /* could be sorted by more criterias as demanded */

      if (workp->sorted)
        for (i = 0; i < sqlp->numsort; i++)
          if (sqlp->colsort [i] != workp->colsort [i]) workp->sorted = FALSE;

      if (! workp->sorted || (workp->numsort > sqlp->numsort)) /* second condition is for correct info line */
      {
        mem_set (&inxcols, 0, sizeof (INXCOLS));
        inxcols.size = sqlp->numsort * sizeof (INXCOL);

        for (i = 0, workp->key_len = sizeof (LONG); i < sqlp->numsort; i++)
        {
          db_fieldinfo (sqlp->db->base, sqlp->table, sqlp->colsort [i] & ~ DESC_ORDER, &f_info);

          inxcols.cols [i].col = sqlp->colsort [i];
          inxcols.cols [i].len = HASWILD (f_info.type) ? min (MAX_KEYLEN, f_info.size - 1) : keysize (f_info.type, NULL);

          workp->buf_addr [i]  = f_info.addr;
          workp->key_addr [i]  = workp->key_len;
          workp->key_size [i]  = inxcols.cols [i].len;
          workp->key_type [i]  = f_info.type;
          if (HASWILD (f_info.type)) workp->key_size [i]++;
          workp->key_size [i] += odd (workp->key_size [i]);
          workp->key_len      += workp->key_size [i];
        } /* for */

        workp->vinx = new_vindex (sqlp->db, workp->vtable, &inxcols);
      } /* if */

      if ((workp->numsort == 0) || (workp->colsort [0] != sqlp->colsort [0])) /* not sorted by the right column */
      {
        busy_mouse ();
        strcpy (workp->treename, temp_name (NULL));
        workp->treeinf = create_tree (workp->treename, 0, 1L);
        ok = workp->treeinf != NULL;

        if (! ok)
          dberror (workp->treename, get_dberror ());
        else
        {
          close_tree (workp->treeinf);
          workp->treeinf = open_tree (workp->treename, 0, OPEN_CACHE, 1);

          ok = workp->treeinf != NULL;

          if (! ok)
            dberror (workp->treename, get_dberror ());
          else
          {
            db_fieldinfo (sqlp->db->base, sqlp->table, sqlp->colsort [0], &f_info);
            set_null (f_info.type, workp->last);
            workp->key_dfn.type = f_info.type;
            workp->numsort      = 1;    /* sorted by one column */
            workp->colsort [0]  = sqlp->colsort [0];
            if (workp->numsort == sqlp->numsort) workp->sorted = TRUE;
          } /* else */
        } /* else */

        arrow_mouse ();

        if (! ok)
        {
          file_remove (workp->treename);
          if (VINX (workp->vinx)) free_vindex (workp->vinx);
          procp->stopfunc = NULL;       /* don't call stop function */
          delete_window (window);
          return (FALSE);
        } /* if */
      } /* if */

      if (! workp->sorted)
      {
        strcpy (workp->key_name, temp_name (NULL));
        workp->key_file = fopen (workp->key_name, RDWR_NEW_BIN);

        if (workp->key_file == NULL)
        {
          file_error (ERR_FILECREATE, workp->key_name);
          if (workp->treeinf != NULL) close_tree (workp->treeinf);
          file_remove (workp->treename);
          if (VINX (workp->vinx)) free_vindex (workp->vinx);
          procp->stopfunc = NULL;       /* don't call stop function */
          delete_window (window);
          return (FALSE);
        } /* if */
      } /* if */

      set_meminfo ();
    } /* if */

    procp->uninteruptable = ! background;

    start_process (window, minimize_process, background);
  } /* if */

  return (TRUE);
} /* search_recs */

/*****************************************************************************/

LOCAL BOOLEAN test_fast (sqlp, workp)
SQL_SPEC  *sqlp;
WORK_SPEC *workp;

{
  WORD       i, col;
  TABLE_INFO t_info;
  FIELD_INFO f_info;
  INDEX_INFO i_info;
  LONGSTR    cond;
  BOOLEAN    found;
  ID         id;

  workp->fastinx = workp->fastcol = workp->fastrow = FAILURE;

  for (i = 0; i < MAX_OR; i++)
    if (row_occupied (sqlp->text, i))
      if (workp->fastrow == FAILURE)
        workp->fastrow = i;
      else
      {
        workp->fastrow = FAILURE;       /* there must be exactly one row of conditions */
        break;
      } /* else, if, for */

  if (workp->fastrow != FAILURE)        /* check for equality on an index field */
  {
    v_tableinfo (sqlp->db, sqlp->table, &t_info);

    for (i = 0, found = FALSE; (i < t_info.indexes) && ! found; i++)
    {
      v_indexinfo (sqlp->db, sqlp->table, i, &i_info);

      if (i_info.inxcols.size / sizeof (INXCOL) == 1)   /* one column */
      {
        col = i_info.inxcols.cols [0].col;
        get_cond (sqlp->text, workp->fastrow, col, cond);

        if (cond [0] != EOS)                            /* any condition */
        {
          get_id (sqlp, cond, 0, FALSE, FALSE, &id);

          if ((id.id == SQL_EQU) || (id.id == SQL_BETWEEN))
          {
            db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);
            if ((f_info.type == TYPE_DATE) || (f_info.type == TYPE_TIMESTAMP))
              if (strchr (cond, WILD_CHAR) != NULL) continue; /* wild chars in date or timestamp */

            found          = TRUE;
            workp->fastinx = i;
            workp->fastcol = col;
            workp->type    = i_info.type;
            workp->rel     = get_values (sqlp, workp->type, f_info.format, cond, workp->lower, workp->upper);

            del_cond (sqlp->text, workp->fastrow, col); /* condition is stored in workp->lower/upper */
            workp->occupied = row_occupied (sqlp->text, workp->fastrow);

            if (HASWILD (workp->type))
            {
              db_convstr (sqlp->db->base, workp->lower);
              db_convstr (sqlp->db->base, workp->upper);

              workp->lower [i_info.inxcols.cols [0].len] = EOS;
              workp->upper [i_info.inxcols.cols [0].len] = EOS;
            } /* if */
          } /* if */
        } /* if */
      } /* if */
    } /* for */

    if (! found) workp->fastrow = FAILURE;      /* sorry, no SQL_EQU or SQL_BETWEEN found for any index */
  } /* if */

  return (workp->fastrow != FAILURE);
} /* test_fast */

/*****************************************************************************/

LOCAL VOID cond2qbe (sqlp, cond)
SQL_SPEC *sqlp;
BYTE     *cond;

{
  WORD    inx, old;
  BOOLEAN between;
  ID      id;
  LONGSTR s;

  s [0]   = EOS;
  inx     = get_id (sqlp, cond, old = 0, FALSE, FALSE, &id);
  between = FALSE;

  switch (id.id)
  {
    case SQL_EQU     : break;
    case SQL_IN      : break;
    case SQL_BETWEEN : chrcat (s, CHR_LEFTBRACK);
                       between = TRUE;
                       break;
    default          : strlcat (s, &cond [old], inx - old);
                       chrcat (s, SP);
                       break;
  } /* else */

  while (isspace (cond [inx])) inx++;           /* eat spaces */

  inx = get_id (sqlp, cond, old = inx, FALSE, FALSE, &id);

  if ((cond [old] == CHR_STRDEL) && (cond [inx - 2] != SP) && (inx - old - 2 > 0) && (strchr (cond, CHR_MINUS) == NULL))
    strlcat (s, &cond [old + 1], inx - old - 2);
  else
    strlcat (s, &cond [old], inx - old);        /* save trailing spaces */

  if (between)
  {
    while (isspace (cond [inx])) inx++;         /* eat spaces */
    inx = get_id (sqlp, cond, old = inx, FALSE, FALSE, &id);

    while (isspace (cond [inx])) inx++;         /* eat spaces */
    inx = get_id (sqlp, cond, old = inx, FALSE, FALSE, &id);

    chrcat (s, SP);
    chrcat (s, CHR_MINUS);
    chrcat (s, SP);

    if ((cond [old] == CHR_STRDEL) && (cond [inx - 2] != SP) && (inx - old - 2 > 0) && (strchr (cond, CHR_MINUS) == NULL))
      strlcat (s, &cond [old + 1], inx - old - 2);
    else
      strlcat (s, &cond [old], inx - old);      /* save trailing spaces */

    chrcat (s, CHR_RIGHTBRACK);
  } /* if */

  strcpy (cond, s);
} /* cond2qbe */

/*****************************************************************************/

LOCAL VOID qbe2cond (sqlp, cond, type)
SQL_SPEC *sqlp;
BYTE     *cond;
WORD     type;

{
  WORD    inx, old, i;
  BOOLEAN between;
  ID      id;
  LONGSTR s;

  s [0]   = EOS;
  inx     = 0;
  between = FALSE;

  while (isspace (cond [inx])) inx++;           /* eat spaces */

  inx = get_id (sqlp, cond, old = inx, FALSE, FALSE, &id); /* operator */

  if (id.id == SQL_BETWEEN)
    strcpy (s, &cond [old]);
  else
  {
    if (cond [old] == CHR_LEFTBRACK)
    {
      between = TRUE;
      strcat (s, sql_str [SQL_BETWEEN].str);
      inx = old + 1;
    } /* if */
    else
      if ((SQL_EQU <= id.id) && (id.id <= SQL_LEQ))
        strlcat (s, &cond [old], inx - old);
      else
      {
        chrcat (s, CHR_EQU);            /* concat missing '=' */
        inx = old;
      } /* else */

    chrcat (s, SP);
    while (isspace (cond [inx])) inx++;         /* eat spaces */
    old = inx;

    if (between && ! HASWILD (type) && (cond [old] == CHR_MINUS)) inx++; /* use minus sign */

    inx = scan (cond, inx, between);

    if (HASWILD (type) && (cond [old] != CHR_STRDEL) && (cond [old] != CHR_ALTSTRDEL) && (cond [old] != CHR_LEFTBRACE)) chrcat (s, CHR_STRDEL);
    strlcat (s, &cond [old], inx - old);

    for (i = strlen (s) - 1; (i >= 0) && (s [i] == SP); i--);   /* delete trailing blanks */
    s [i + 1] = EOS;

    if (HASWILD (type) && (cond [old] != CHR_STRDEL) && (cond [old] != CHR_ALTSTRDEL) && (cond [old] != CHR_LEFTBRACE)) chrcat (s, CHR_STRDEL);

    if (between)
    {
      while (isspace (cond [inx])) inx++;       /* eat spaces */
      inx++;                                    /* no '-' */

      chrcat (s, SP);
      strcat (s, sql_str [SQL_AND].str);
      chrcat (s, SP);

      while (isspace (cond [inx])) inx++;       /* eat spaces */
      old = inx;

      if (between && ! HASWILD (type) && (cond [old] == CHR_MINUS)) inx++; /* use minus sign */

      inx = scan (cond, inx, between);

      if (HASWILD (type) && (cond [old] != CHR_STRDEL) && (cond [old] != CHR_ALTSTRDEL) && (cond [old] != CHR_LEFTBRACE)) chrcat (s, CHR_STRDEL);
      strlcat (s, &cond [old], inx - old);

      for (i = strlen (s) - 1; (i >= 0) && (s [i] == SP); i--);   /* delete trailing blanks */
      s [i + 1] = EOS;

      if (HASWILD (type) && (cond [old] != CHR_STRDEL) && (cond [old] != CHR_ALTSTRDEL) && (cond [old] != CHR_LEFTBRACE)) chrcat (s, CHR_STRDEL);
    } /* if */
  } /* else */

  strcpy (cond, s);
} /* qbe2cond */

/*****************************************************************************/

LOCAL BOOLEAN row_occupied (text, row)
BYTE *text;
WORD row;

{
  text += get_pos (text, row, 0);

  while ((*text != RS) && (*text != EOS))
    if (*text++ != FS) return (TRUE);

  return (FALSE);
} /* row_occupied */

/*****************************************************************************/

LOCAL BOOLEAN work_sql (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN   ok, ins;
  WORK_SPEC *workp;
  SQL_SPEC  *sqlp;
  LONG      address;
  WORD      i;
  KEY       value;
  BYTE      *p;

  workp = (WORK_SPEC *)proc_inf->memory;
  sqlp  = workp->sqlp;
  ok    = TRUE;
  ins   = TRUE;

  if (proc_inf->actrec == 0)
    if (workp->fastinx == FAILURE)
      ok = v_initcursor (sqlp->db, sqlp->table, proc_inf->inx, ASCENDING, proc_inf->cursor);
    else
    {
      db_setfield (sqlp->db->base, sqlp->table, workp->fastcol, workp->buffer, workp->lower);
      ok = db_search (sqlp->db->base, sqlp->table, workp->fastinx, ASCENDING, proc_inf->cursor, workp->buffer, 0L);

      if (workp->rel == SQL_BETWEEN) ok = TRUE;                 /* not found, but can be greater */
    } /* else, if */

  if (ok)
  {
    if (workp->fastinx == FAILURE)      /* regular check */
    {
      ok = v_movecursor (sqlp->db, proc_inf->cursor, 1L);
      if (ok) ok = v_read (sqlp->db, sqlp->table, workp->buffer, proc_inf->cursor, 0L, FALSE);

      if (ok)
      {
        if (! workp->sorted && (proc_inf->inx != 0) && (workp->treeinf == NULL))
        {
          db_buildkey (sqlp->db->base, rtable (sqlp->table), proc_inf->inx, workp->buffer, value);

          if (cmp_vals (workp->type, value, workp->last) != 0)  /* not the same key */
          {
            workp->same_key = 0;
            mem_move (workp->last, value, keysize (workp->type, value));
          } /* if */

          workp->same_key++;
          workp->same_keys = max (workp->same_keys, workp->same_key);
        } /* if */

        address = *(LONG *)workp->buffer;
        ins     = workp->empty || check_record (sqlp, workp);
      } /* if */
    } /* if */
    else                                /* fast check */
    {
      switch (workp->rel)
      {
        case SQL_BETWEEN : if (proc_inf->actrec > 0)  /* I got the first record via db_search */
                             ok = v_movecursor (sqlp->db, proc_inf->cursor, 1L);

                           if (ok)
                           {
                             address = v_readcursor (sqlp->db, proc_inf->cursor, value);
                             ok      = (cmp_vals (workp->type | USE_WILDCARD, workp->lower, value) <= 0) &&
                                       (cmp_vals (workp->type | USE_WILDCARD, workp->upper, value) >= 0);
                           } /* if */
                           break;
        case SQL_EQU     : if (proc_inf->actrec > 0)  /* I got the first record via db_search */
                             ok = db_testcursor (sqlp->db->base, proc_inf->cursor, ASCENDING, workp->lower);
                           break;
      } /* switch */

      if (ok)
      {
        address = v_readcursor (sqlp->db, proc_inf->cursor, value);

        if (workp->occupied || (workp->treeinf != NULL) || (workp->key_file != NULL)) /* second and third conditions are because of needing buffer */
        {
          ok = v_read (sqlp->db, sqlp->table, workp->buffer, proc_inf->cursor, 0L, FALSE);

          if (ok) ins = workp->empty || ! workp->occupied || check_record (sqlp, workp);
        } /* if */

        if (! workp->sorted && (proc_inf->inx != 0) && (workp->treeinf == NULL))
        {
          if (cmp_vals (workp->type, value, workp->last) != 0)  /* not the same key */
          {
            workp->same_key = 0;
            mem_move (workp->last, value, keysize (workp->type, value));
          } /* if */

          workp->same_key++;
          workp->same_keys = max (workp->same_keys, workp->same_key);
        } /* if */
      } /* if */
    } /* else */

    if (ok && ins)
    {
      if (workp->key_file != NULL)
      {
        ok = fwrite (&address, sizeof (LONG), 1, workp->key_file) == 1;

        for (i = 0; (i < sqlp->numsort) && ok; i++)
        {
          if (workp->key_type [i] == TYPE_CHAR) db_convstr (sqlp->db->base, (BYTE *)workp->buffer + workp->buf_addr [i]);
          ok = fwrite ((BYTE *)workp->buffer + workp->buf_addr [i], workp->key_size [i], 1, workp->key_file) == 1;
        } /* for */

        if (! ok) file_error (ERR_FILEWRITE, workp->key_name);

        address = workp->numrecs;       /* use address as index into file */
      } /* if */

      if (workp->treeinf != NULL)
      {
        p = (BYTE *)workp->buffer + workp->buf_addr [0];

        if (HASWILD (workp->key_dfn.type))      /* don't copy to many chars */
        {
          strncpy (value, p, MAX_KEYSIZE - 1);
          value [MAX_KEYSIZE - 1] = EOS;
          if (workp->key_dfn.type == TYPE_CHAR) db_convstr (sqlp->db->base, value);
        } /* if */
        else
          mem_move (value, p, keysize (workp->key_dfn.type, p));

        ok = insert_key (workp->treeinf, value, address, &workp->key_dfn);
        if (! ok) dberror (workp->treename, get_dberror ());
      } /* if */
      else
      {
        ok = fwrite (&address, sizeof (LONG), 1, proc_inf->file) == 1;
        if (! ok) file_error (ERR_FILEWRITE, proc_inf->filename);
      } /* else */

      if (ok) workp->numrecs++;
    } /* if */
  } /* if */

  return (ok);
} /* work_sql */

/*****************************************************************************/

LOCAL BOOLEAN stop_sql (proc_inf)
PROC_INF *proc_inf;

{
  WORK_SPEC *workp;
  SQL_SPEC  *sqlp;
  VTABLE    *vtablep;
  VINDEX    *vindexp;
  FHANDLE   f;
  BOOLEAN   ok;
  CURSOR    cursor;
  LONG      i, pass;
  BASE_INFO base_info;
  MFDB      screen, buffer;
  TABLENAME tblname;
  RECT      r;
  KEY       value;
  LONGSTR   s;

  workp = (WORK_SPEC *)proc_inf->memory;
  sqlp  = workp->sqlp;
  pass  = 1;

  workp->vtable = new_vtable (sqlp->db, sqlp->table, workp->numrecs + max_records, sqlp->cols);
  ok            = workp->vtable != FAILURE;

  if (ok)
  {
    busy_mouse ();

    vtablep = VTABLEP (workp->vtable);

    if (VINX (workp->vinx))             /* vtable is known now */
    {
      vindexp         = VINDEXP (workp->vinx);
      vindexp->vtable = workp->vtable;  /* originally initialized with FAILURE */
    } /* if */

    text_default (vdi_handle);
    form_center (sorting, &r.x, &r.y, &r.w, &r.h);
    do_flags (sorting, REORGNAM, HIDETREE);

    if (db_baseinfo (sqlp->db->base, &base_info))
    {
      set_ob_spec (sorting, SORTDB, (LONG)base_info.basename);
      strcpy (get_str (sorting, SORTTBL), table_name (sqlp->db, sqlp->table, tblname));
      sprintf (get_str (sorting, SORTRECS), "%ld", workp->numrecs);
    } /* if */

    if (workp->treeinf == NULL) /* record adresses are stored in temporary file */
    {
      fclose (proc_inf->file);
      proc_inf->file = NULL;
      f              = file_open (proc_inf->filename, O_RDONLY);
      vtablep->recs  = file_read (f, workp->numrecs * sizeof (LONG), vtablep->recaddr) / sizeof (LONG);
      file_close (f);
    } /* if */
    else                        /* record adresses are stored in treefile */
    {
      if (workp->background)
      {
        opendial (sorting, TRUE, NULL, &screen, &buffer);
        objc_draw (sorting, ROOT, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);
        draw_number (pass++, SORTPASS);
      } /* if */

      vtablep->recs = 0;
      init_cursor (workp->treeinf, ASCENDING, &workp->key_dfn, &cursor);

      while (move_cursor (&cursor, 1L))         /* read adresses or indexes */
      {
        if (workp->background)
          if (vtablep->recs % 100 == 0) draw_number (vtablep->recs, SORTREC);

        vtablep->recaddr [vtablep->recs++] = read_cursor (&cursor, value);

        if (! workp->sorted)
        {
          if (cmp_vals (workp->key_dfn.type, value, workp->last) != 0)  /* not the same key */
          {
            workp->same_key = 0;
            mem_move (workp->last, value, keysize (workp->key_dfn.type, value));
          } /* if */

          workp->same_key++;
          workp->same_keys = max (workp->same_keys, workp->same_key);
        } /* if */
      } /* if */

      if (workp->background)
      {
        draw_number (vtablep->recs, SORTREC);
        closedial (sorting, TRUE, NULL, &screen, &buffer);
      } /* if */
    } /* if */

    if (! workp->sorted)
    {
      rewind (workp->key_file);

      if (workp->background)
      {
        opendial (sorting, TRUE, NULL, &screen, &buffer);
        objc_draw (sorting, ROOT, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);
        draw_number (pass++, SORTPASS);
      } /* if */

      sort (sqlp, workp, &r);

      if (workp->background)
        draw_number (pass++, SORTPASS);

      for (i = 0; i < vtablep->recs; i++)
      {
        if (workp->background)
          if (i % 10 == 0) draw_number (i, SORTREC);

        fseek (workp->key_file, vtablep->recaddr [i] * workp->key_len, SEEK_SET);
        fread (&vtablep->recaddr [i], sizeof (LONG), 1, workp->key_file);
      } /* for */

      if (workp->background)
      {
        draw_number (vtablep->recs, SORTREC);
        closedial (sorting, TRUE, NULL, &screen, &buffer);
      } /* if */
    } /* if */

    undo_flags (sorting, REORGNAM, HIDETREE);
    arrow_mouse ();

    if (workp->background)
      if (show_queried)
      {
        sprintf (s, alerts [ERR_INFORECORDS], vtablep->recs, base_info.basename, tblname, workp->sql_name);
        open_alert (s);
      } /* if, if */

    ok = show_list (sqlp, workp->vtable, workp->vinx, workp->dir, workp->sql_name);

    if (! ok)
      free_vtable (workp->vtable);
  } /* if */

  if (workp->treeinf != NULL)
  {
    close_tree (workp->treeinf);
    file_remove (workp->treename);
  } /* if */

  if (workp->key_file != NULL)
  {
    fclose (workp->key_file);
    file_remove (workp->key_name);
  } /* if */

  if (! ok)
    if (VINX (workp->vinx))
      free_vindex (workp->vinx);

  mem_free (workp->sqlp);

  return (TRUE);
} /* stop_sql */

/*****************************************************************************/

LOCAL VOID sort (sqlp, workp, r)
SQL_SPEC  *sqlp;
WORK_SPEC *workp;
RECT      *r;

{
  LONG       n, i, same_key, offset, save;
  BOOLEAN    mode;
  VTABLE     *vtablep;
  VINDEX     *vindexp;
  FIELD_INFO f_info;
  KEY        last;
  BYTE       *valp;
  LONG       *longp;

  if (workp->same_keys > 0)
  {
    mode           = set_alert (TRUE);  /* alert boxes as dialog boxes */
    vtablep        = VTABLEP (workp->vtable);
    workp->sortbuf = mem_alloc ((workp->same_keys + 1) * workp->key_len);

    if (workp->sortbuf == NULL)
    {
      hndl_alert (ERR_NOMEMORY);
      vindexp               = VINDEXP (workp->vinx);
      vindexp->inxcols.size = workp->numsort * sizeof (INXCOL);
    } /* if */
    else
    {
      sworkp = workp;

      set_meminfo ();
      db_fieldinfo (sqlp->db->base, sqlp->table, sqlp->colsort [0], &f_info);
      set_null (f_info.type, last);

      for (n = same_key = 0; n < vtablep->recs; n++)
      {
        if (workp->background)
          if (n % 10 == 0) draw_number (n, SORTREC);

        offset = same_key * workp->key_len;
        fseek (workp->key_file, vtablep->recaddr [n] * workp->key_len, SEEK_SET);
        fread (&workp->sortbuf [offset], (SIZE_T)workp->key_len, 1, workp->key_file);

        valp                 = &workp->sortbuf [offset + workp->key_addr [0]];
        longp                = (LONG *)&workp->sortbuf [offset];
        *longp               = save = vtablep->recaddr [n];
        vtablep->recaddr [n] = same_key;

        if (cmp_vals (f_info.type, valp, last) != 0)
        {
          if (workp->background)
            draw_number (n, SORTREC);

          if (n > 0)                    /* don't sort first element */
          {
            quicksort (sqlp, workp, n - same_key, n - 1, 1);

            for (i = 0; i < same_key; i++)      /* restore record addresses */
            {
              longp = (LONG *)&workp->sortbuf [vtablep->recaddr [n - same_key + i] * workp->key_len];
              vtablep->recaddr [n - same_key + i] = *longp;
            } /* for */

            mem_move (&workp->sortbuf [0], &workp->sortbuf [offset], workp->key_len);
            longp                = (LONG *)&workp->sortbuf [0];
            *longp               = save;
            vtablep->recaddr [n] = 0;
          } /* if */

          same_key = 0;
          mem_move (last, valp, keysize (f_info.type, valp));
        } /* if */

        same_key++;
      } /* for */

      if (workp->background)
        draw_number (vtablep->recs, SORTREC);

      quicksort (sqlp, workp, vtablep->recs - same_key, vtablep->recs - 1, 1);

      for (i = 0; i < same_key; i++)            /* restore record addresses */
      {
        longp = (LONG *)&workp->sortbuf [vtablep->recaddr [vtablep->recs - same_key + i] * workp->key_len];
        vtablep->recaddr [vtablep->recs - same_key + i] = *longp;
      } /* for */

      mem_free (workp->sortbuf);
      set_meminfo ();
    } /* else */

    set_alert (mode);                           /* restore old mode */
  } /* if */
} /* sort */

/*****************************************************************************/

LOCAL VOID quicksort (sqlp, workp, l, r, col)
SQL_SPEC  *sqlp;
WORK_SPEC *workp;
LONG      l, r;
WORD      col;

{
  VTABLE     *vtablep;
  FIELD_INFO f_info;
  LONG       n, same_key, offset;
  KEY        last;
  BYTE       *valp;

  if (r - l + 1 > 1)    /* anything to sort */
  {
    db_fieldinfo (sqlp->db->base, sqlp->table, sqlp->colsort [col] & ~ DESC_ORDER, &f_info);
    set_null (f_info.type, last);

    workp->sorttype = f_info.type;
    workp->sortaddr = workp->key_addr [col];
    workp->sortdir  = (sqlp->colsort [col] & DESC_ORDER) == 0;
    vtablep         = VTABLEP (workp->vtable);

    qsort ((VOID *)&vtablep->recaddr [l], (SIZE_T)(r - l + 1), sizeof (LONG), compare);

    if (col + 1 < sqlp->numsort)
    {
      for (n = l, same_key = 0; n <= r; n++)
      {
        offset = vtablep->recaddr [n] * workp->key_len + workp->key_addr [col];
        valp   = &workp->sortbuf [offset];

        if (cmp_vals (f_info.type, valp, last) != 0)
        {
          if (n > l)                    /* don't sort first element */
            quicksort (sqlp, workp, n - same_key, n - 1, col + 1);

          same_key = 0;
          mem_move (last, valp, keysize (f_info.type, valp));
        } /* if */

        same_key++;
      } /* for */

      quicksort (sqlp, workp, r + 1 - same_key, r, col + 1);
    } /* if */
  } /* if */
} /* quicksort */

/*****************************************************************************/

LOCAL INT compare (arg1, arg2)
LONG *arg1, *arg2;

{
  INT res;

  res = cmp_vals (sworkp->sorttype,
                  &sworkp->sortbuf [*arg1 * sworkp->key_len + sworkp->sortaddr],
                  &sworkp->sortbuf [*arg2 * sworkp->key_len + sworkp->sortaddr]);

  return (sworkp->sortdir ? res : -res);
} /* compare */

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

LOCAL BOOLEAN check_record (sqlp, workp)
SQL_SPEC  *sqlp;
WORK_SPEC *workp;

{
  BOOLEAN    ok;
  WORD       row, i, col, rel, type;
  BYTE       *p;
  LONGSTR    cond, lower, upper;
  FIELD_INFO f_info;

  for (row = 0, ok = FALSE; (row < MAX_OR) && ! ok; row++)
    if (row_occupied (sqlp->text, row))
      for (i = 0, ok = TRUE; (i < sqlp->cols) && ok; i++)
      {
        col = sqlp->columns [i];
        get_cond (sqlp->text, row, col, cond);

        if (cond [0] != EOS)
        {
          db_fieldinfo (sqlp->db->base, sqlp->table, col, &f_info);
          p    = (BYTE *)workp->buffer + f_info.addr;
          rel  = get_values (sqlp, f_info.type, f_info.format, cond, lower, upper);
          type = f_info.type | USE_WILDCARD;

          if (HASWILD (f_info.type))
          {
            db_convstr (sqlp->db->base, lower);
            db_convstr (sqlp->db->base, upper);
            db_convstr (sqlp->db->base, p);
          } /* if */

          switch (rel)
          {
            case SQL_BETWEEN : ok = (cmp_vals (type, lower, p) <= 0) && (cmp_vals (type, upper, p) >= 0); break;
            case SQL_EQU     : ok = cmp_vals (type, lower, p) == 0; break;
            case SQL_NEQ     : ok = cmp_vals (type, lower, p) != 0; break;
            case SQL_GRT     : ok = cmp_vals (type, lower, p) <  0; break;
            case SQL_GEQ     : ok = cmp_vals (type, lower, p) <= 0; break;
            case SQL_LES     : ok = cmp_vals (type, lower, p) >  0; break;
            case SQL_LEQ     : ok = cmp_vals (type, lower, p) >= 0; break;
          } /* switch */
        } /* if */
      } /* for, if, for */

  return (ok);
} /* check_record */

/*****************************************************************************/

LOCAL WORD get_values (sqlp, type, format, s, lower, upper)
SQL_SPEC *sqlp;
WORD     type, format;
BYTE     *s;
VOID     *lower, *upper;

{
  WORD rel, inx;
  ID   id;

  inx = 0;

  while (isspace (s [inx])) inx++;                      /* eat spaces */

  inx = get_id (sqlp, s, inx, FALSE, FALSE, &id);       /* operator */
  rel = id.id;

  if (id.id == SQL_BETWEEN)
  {
    inx = get_value (sqlp, type, format, inx, s, lower);
    inx = get_id (sqlp, s, inx, FALSE, FALSE, &id);     /* AND */
    inx = get_value (sqlp, type, format, inx, s, upper);

    if (type == TYPE_CHAR) chrcat (upper, WILD_CHARS);  /* always include upper bound */
  } /* if */
  else
  {
    get_value (sqlp, type, format, inx, s, lower);
    mem_move (upper, lower, MAX_KEYSIZE);               /* upper bound same as lower bound */
  } /* else */

  return (rel);
} /* get_values */

/*****************************************************************************/

LOCAL WORD get_value (sqlp, type, format, inx, s, value)
SQL_SPEC *sqlp;
WORD     type, format, inx;
BYTE     *s;
VOID     *value;

{
  WORD    i, old;
  ID      id;
  LONGSTR cond;

  while (isspace (s [inx])) inx++;              /* eat spaces */

  inx = get_id (sqlp, s, old = inx, FALSE, FALSE, &id);

  if ((id.id == SQL_STRDEL) || (id.id == SQL_ALTSTRDEL)) old++;

  for (i = 0; old < inx; old++)                 /* get condition string */
    cond [i++] = s [old];

  cond [i] = EOS;

  if ((id.id == SQL_STRDEL)  || (id.id == SQL_ALTSTRDEL)) cond [i - 1] = EOS;

  switch (id.id)
  {
    case SQL_SYSDATE  : mem_move (value, &sqlp->date, sizeof (DATE));
                        break;
    case SQL_SYSTIME  : mem_move (value, &sqlp->time, sizeof (TIME));
                        break;
    case SQL_SYSSTAMP : mem_move (value, &sqlp->timestamp, sizeof (TIMESTAMP));
                        break;
    default           : if (printable (type))
                          if (sqlp->db->format != NULL) format2str (type, cond, sqlp->db->format [format]);
                        str2bin (type, cond, value);
                        break;
  } /* switch */

  return (inx);
} /* get_value */

/*****************************************************************************/

LOCAL WORD get_id (sqlp, s, inx, tbl, col, id)
SQL_SPEC *sqlp;
BYTE     *s;
WORD     inx;
BOOLEAN  tbl, col;
ID       *id;

{
  WORD       i;
  STRING     str;
  TABLE_INFO t_info;
  FIELD_INFO f_info;

  id->id    = FAILURE;
  id->value = FAILURE;

  while (isspace (s [inx])) inx++;

  if ((s [inx] == EOS) || (s [inx] == CHR_END))
    id->id = SQL_END;
  else
  {
    if (isalpha (ch_ascii (s [inx])))   /* identifier */
    {
      for (i = 0; isalnum (ch_ascii (s [inx])) || (s [inx] == '_'); inx++)
        str [i++] = s [inx];

      str [i] = EOS;
      scan_str (str, id);

      if (id->id == FAILURE)
        if (tbl)                /* look for tables */
        {
          strcpy (t_info.name, str);
          id->value = db_tableinfo (sqlp->db->base, FAILURE, &t_info);
          if (id->value != FAILURE) id->id = SQL_TABLE;
        } /* if */
        else
          if (col)              /* look for columns */
          {
            strcpy (f_info.name, str);
            id->value = db_fieldinfo (sqlp->db->base, sqlp->table, FAILURE, &f_info);
            if (id->value != FAILURE) id->id = SQL_COLUMN;
          } /* if, else, if */
    } /* if */
    else
      if (isdigit (s [inx]) || (s [inx] == '+') || (s [inx] == '-') || (s [inx] == '.') || (s [inx] == WILD_CHAR))
      {
        id->id = SQL_NUMBER;
        while (! isspace (s [inx]) && (s [inx] != EOS) && (s [inx] != CHR_END) && ! isalpha (ch_ascii (s [inx]))) inx++;
      } /* if */
      else                      /* character */
        inx = scan_char (s, inx, id);
  } /* if */

  return (inx);
} /* get_id */

/*****************************************************************************/

LOCAL WORD get_format (s, inx, id)
BYTE *s;
WORD inx;
ID   *id;

{
  REG WORD i;
  STRING   str;

  id->id    = FAILURE;
  id->value = FAILURE;

  while (isspace (s [inx])) inx++;

  if ((s [inx] == '-') || isdigit (s [inx]))
  {
    i = 0;
    if (s [inx] == '-') str [i++] = s [inx++];
    while (isdigit (s [inx])) str [i++] = s [inx++];

    str [i]   = EOS;
    id->id    = SQL_FORMAT;
    id->value = atoi (str);
  } /* if */
  else
    while (! isspace (s [inx]) && (s [inx] != EOS)) inx++;
  
  return (inx);
} /* get_format */

/*****************************************************************************/

LOCAL VOID scan_str (s, id)
BYTE *s;
ID   *id;

{
  REG WORD    i;
  REG SQL_STR *p;

  str_upper (s);

  for (i = 0, p = sql_str; i < MAX_SQLSTR; i++, p++)
    if (strcmp (s, p->str) == 0)
    {
      id->id = p->id;
      return;
    } /* if, for */

  id->id = FAILURE;
} /* scan_str */

/*****************************************************************************/

LOCAL WORD scan_char (s, inx, id)
BYTE *s;
WORD inx;
ID   *id;

{
  REG WORD    i;
  REG SQL_CHR *p;

  for (i = 0, p = sql_chr; i < MAX_SQLCHR; i++, p++)
    if (s [inx] == p->chr)
    {
      id->id = p->id;
      inx++;

      switch (p->id)
      {
        case SQL_NEQ       : inx++;                     /* delete '=' */
                             break;
        case SQL_GRT       : if (s [inx] == CHR_EQU)
                             {
                               id->id = SQL_GEQ;
                               inx++;
                             } /* if */
                             break;
        case SQL_LES       : if (s [inx] == CHR_EQU)
                             {
                               id->id = SQL_LEQ;
                               inx++;
                             } /* if */
                             else
                               if (s [inx] == CHR_GRT)
                               {
                                 id->id = SQL_NEQ;
                                 inx++;
                               } /* if, else */
                             break;
        case SQL_STRDEL    : while ((s [inx] != CHR_STRDEL) && (s [inx] != EOS)) inx++; /* eat non-' */
                             if (s [inx] != EOS) inx++;
                             break;
        case SQL_ALTSTRDEL : while ((s [inx] != CHR_ALTSTRDEL) && (s [inx] != EOS)) inx++; /* eat non-' */
                             if (s [inx] != EOS) inx++;
                             break;
        case SQL_LEFTBRACE : while ((s [inx] != CHR_RIGHTBRACE) && (s [inx] != EOS)) inx++; /* eat non-' */
                             if (s [inx] != EOS) inx++;
                             break;
      } /* switch */

      return (inx);
    } /* if, for */

  id->id = FAILURE;

  return (++inx);
} /* scan_char */

/*****************************************************************************/

LOCAL WORD scan (s, inx, between)
BYTE    *s;
WORD    inx;
BOOLEAN between;

{
  BOOLEAN strdel;
  BYTE    chstrdel;

  while (isspace (s [inx])) inx++;

  strdel = (s [inx] == CHR_STRDEL) || (s [inx] == CHR_ALTSTRDEL);

  if (strdel)
  {
    chstrdel = s [inx];
    inx++;
  } /* if */

  while ((s [inx] != EOS) && 
         (! strdel || (s [inx] != chstrdel)) &&
         (strdel || ! between || (s [inx] != CHR_MINUS) && (s [inx] != SP) && (s [inx] != CHR_RIGHTBRACK))) inx++;

  if (strdel && (s [inx] == chstrdel)) inx++;

  return (inx);
} /* scan */

/*****************************************************************************/

LOCAL WORD sql_error (errornum, sqlstr)
WORD errornum;
BYTE *sqlstr;

{
  LONGSTR s;
  STRING  sql;

  sql_errors++;
  strncpy (sql, sqlstr, STRLEN);
  sql [STRLEN] = EOS;

  sprintf (s, alerts [errornum], sql);

  return (open_alert (s));
} /* sql_error */

/*****************************************************************************/

LOCAL BOOLEAN col_present (columns, col, cols)
WORD *columns, col, cols;

{
  REG WORD i;

  for (i = 0; i < cols; i++)
    if (columns [i] == col) return (TRUE);

  return (FALSE);
} /* col_present */

/*****************************************************************************/

LOCAL VOID strlcpy (dst, src, len)
BYTE *dst, *src;
WORD len;

{
  strncpy (dst, src, len);
  dst [len] = EOS;
} /* strlcpy */

/*****************************************************************************/

LOCAL VOID strlcat (dst, src, len)
BYTE *dst, *src;
WORD len;

{
  WORD l;

  l = strlen (dst);
  strncpy (dst + l, src, len);
  dst [l + len] = EOS;
} /* strlcat */

/*****************************************************************************/

