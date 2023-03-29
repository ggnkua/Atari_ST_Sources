/*****************************************************************************
 *
 * Module : PROCESS.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 02.01.97
 *
 *
 * Description: This module implements the process window.
 *
 * History:
 * 02.01.97: Element filestr added
 * 04.10.93: Element saved_recs_pe added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __PROCESS__
#define __PROCESS__

#include <time.h>

/****** DEFINES **************************************************************/

#define CLASS_PROCESS 15                 /* Class Process Window */

#define CLOCK_T       clock_t

/****** TYPES ****************************************************************/

#define PROC_INF struct proc_inf

typedef BOOLEAN (*WORKFUNC) _((PROC_INF *proc_inf));

struct proc_inf
{
  DB          *db;              /* database */
  WORD        table;            /* table of database */
  WORD        inx;              /* index to use */
  WORD        dir;              /* direction to use */
  WORD        cols;             /* number of actual cols */
  WORD        *columns;         /* column order */
  WORD        *colwidth;        /* column width */
  CURSOR      *cursor;          /* cursor for accessing records */
  WORD        format;           /* format (record or byte) */
  LONG        actrec;           /* actual record */
  LONG        maxrecs;          /* max number of records */
  LONG        events_ps;        /* events per second */
  LONG        recs_pe;          /* records per event */
  LONG        saved_recs_pe;     /* saved records per event */
  IMPEXPCFG   *impexpcfg;       /* import/export configuration */
  PAGE_FORMAT *page_format;     /* page format for lists */
  PRNCFG      *prncfg;          /* printer configuration */
  CALCCODE    *calccode;        /* code for calculation */
  BYTE        *memory;          /* more memory */
  WORD        slider;           /* slider value */
  CLOCK_T     start;            /* start time of process */
  CLOCK_T     sum_work;         /* number of seconds working */
  CLOCK_T     sec_work;         /* number of seconds working since last rest */
  BOOLEAN     pausing;          /* TRUE, if pausing */
  BOOLEAN     blocked;          /* TRUE, if process is waiting for the printer */
  BOOLEAN     aborted;          /* TRUE, if process was aborted */
  BOOLEAN     exclusive;        /* TRUE, if exclusive process */
  BOOLEAN     to_printer;       /* TRUE, if process goes directly to printer */
  BOOLEAN     binary;           /* TRUE, if process prints binary data */
  BOOLEAN     tmp;              /* TRUE, if temporary file */
  BOOLEAN     use_calc;         /* TRUE, if calculation should be used */
  BOOLEAN     uninteruptable;   /* TRUE, if process can be interrupted */
  WORD        special;          /* user defined special word */
  FULLNAME    filestr;		/* string of user defined filename */
  STRING      dbstr;            /* string of database and table name */
  STRING      inxstr;           /* string of index */
  BYTE        workstr [10];     /* string of working time */
  BYTE        reststr [10];     /* string of time remaining to work */
  FULLNAME    filename;         /* filename */
  FILE        *file;            /* file descriptor */
  LONG        filelength;       /* length of file */
  WORKFUNC    workfunc;         /* function for processing one record */
  WORKFUNC    stopfunc;         /* function for stopping process */
};

/****** VARIABLES ************************************************************/

GLOBAL WORD num_processes;      /* number of processes */

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_process  _((VOID));
GLOBAL BOOLEAN term_process  _((VOID));

GLOBAL WINDOWP crt_process   _((OBJECT *obj, OBJECT *menu, WORD icon, BYTE *title, PROC_INF *proc_inf, LONG bytes, UWORD flags));

GLOBAL BOOLEAN open_process  _((WORD icon));
GLOBAL BOOLEAN info_process  _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_process  _((WINDOWP window, WORD icon));

GLOBAL VOID    start_process _((WINDOWP window, BOOLEAN minimize, BOOLEAN background));
GLOBAL BOOLEAN proc_used     _((DB *db));
GLOBAL BOOLEAN chk_filenames _((BYTE *filename));
GLOBAL VOID    set_timer     _((VOID));

#endif /* __PROCESS__ */

