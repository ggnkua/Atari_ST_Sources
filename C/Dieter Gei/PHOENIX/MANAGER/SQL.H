/*****************************************************************************
 *
 * Module : SQL.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 02.10.93
 *
 *
 * Description: This module defines the sql process.
 *
 * History:
 * 02.10.93: MAX_OR changed to 16
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __SQL__
#define __SQL__

/****** DEFINES **************************************************************/

#define MAX_OR          16              /* maximum OR-links = lines */
#define MAX_SORT        16              /* maximum different sort criterias */
#define MAX_TEXT      2048              /* maximum chars for QBE */

#define COL_PRESENT   0x0001            /* column is present */

/****** TYPES ****************************************************************/

typedef struct
{
  DB        *db;                        /* database */
  WORD      table;                      /* table of database */
  WORD      inx;                        /* index of list */
  WORD      dir;                        /* direction of list */
  WORD      cols;                       /* number of actual cols */
  WORD      *columns;                   /* column order */
  WORD      *colwidth;                  /* column width */
  FIELDNAME sql_name;                   /* name of sql query */
} SQL_RESULT;

typedef struct
{
  DB        *db;                        /* database */
  WORD      table;                      /* table of database */
  WORD      cols;                       /* number of actual cols */
  WORD      *columns;                   /* column order */
  WORD      *colwidth;                  /* column width */
  BYTE      *colheader;                 /* column header */
  UBYTE     *colflags;                  /* column present ? */
  WORD      numsort;                    /* number of columns sorted */
  WORD      colsort [MAX_SORT];         /* column sort order */
  BYTE      *sqlstr;                    /* sql string */
  BYTE      *text;                      /* text of qbe */
  WORD      max_text;                   /* max text of qbe */
  DATE      date;                       /* actual date */
  TIME      time;                       /* actual time */
  TIMESTAMP timestamp;                  /* actual timestamp */
} SQL_SPEC;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_sql  _((VOID));
GLOBAL BOOLEAN term_sql  _((VOID));

GLOBAL VOID    sql_exec  _((DB *db, BYTE *sql, BYTE *sql_name, BOOLEAN background, SQL_RESULT *sql_result));
GLOBAL BOOLEAN set_sql   _((SQL_SPEC *sqlp, BOOLEAN checkonly, BOOLEAN qbemode));
GLOBAL BOOLEAN get_sql   _((SQL_SPEC *sqlp));
GLOBAL WORD    get_order _((SQL_SPEC *sqlp, WORD col));

GLOBAL VOID    get_cond  _((BYTE *text, WORD row, WORD col, BYTE *cond));
GLOBAL BOOLEAN set_cond  _((BYTE *text, WORD row, WORD col, BYTE *cond, WORD max_text));
GLOBAL VOID    del_cond  _((BYTE *text, WORD row, WORD col));
GLOBAL WORD    get_pos   _((BYTE *text, WORD row, WORD col));

#endif /* __SQL__ */

