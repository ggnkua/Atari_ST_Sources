/*****************************************************************************
 *
 * Module : DBROOT.H
 * Author : Dieter Geiß
 *
 * Creation date    : 01.07.89
 * Last modification: 14.11.92
 *
 *
 * Description: This module defines the database root routines.
 *
 * History:
 * 14.11.92: Function build_pass moved from conv
 * 11.11.92: DB_CDELETEDUPDATE added
 * 07.11.92: DB_CUPDATED added
 * 29.10.92: FHANDLE changed to HFILE
 * 25.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _DBROOT_H
#define _DBROOT_H

#ifdef __cplusplus
extern "C" {
#endif

/****** DEFINES **************************************************************/

enum DB_ERRORS
{
  DB_NOERROR = 20,
  DB_NOMEMORY,
  DB_TNOCREATE,
  DB_TNOOPEN,
  DB_TNOCLOSE,
  DB_TRDPAGE,
  DB_TWRPAGE,
  DB_TNOKEY,

  DB_DNOCREATE,
  DB_DNOOPEN,
  DB_DNOCLOSE,
  DB_DNOTCLOSED,
  DB_DVERSION,
  DB_DINSERT,
  DB_DDELETE,
  DB_DUDELETE,
  DB_DUPDATE,
  DB_DREAD,
  DB_DWRITE,
  DB_DNOLOCK,
  DB_DNOUNLOCK,

  DB_CDELETED,
  DB_CNOTABLE,
  DB_CNOCOLUMN,
  DB_CNOINDEX,
  DB_CNULLKEY,
  DB_CNOTUNIQUE,
  DB_CNOACCESS,
  DB_CRECLOCKED,
  DB_CLOCK_ERR,
  DB_CFREE_ERR,
  DB_CPASSWORD,
  DB_CCREATEDD,
  DB_CREADDD,
  DB_CINVALID,
  DB_CNULLCOL,
  DB_CNOINSERT,
  DB_CNODELETE,
  DB_CNOUPDATE,
  DB_CUPDATED,
  DB_CDELETEDUPDATE,

  PC_OVERFLOW,		/* compiler error codes */
  UNKNOWN_SYMBOL,
  NO_FIELD,
  NO_STATEMENT,
  NO_FACTOR,
  NO_LPARENT,
  NO_RPARENT,
  NO_SEMICOLON,
  NO_DTCONST,
  NO_BECOMES,
  NO_TYPE,
  NO_INDEX,
  NO_COMMA,
  THEN_EXPECTED,
  END_EXPECTED,
  DO_EXPECTED,
  UNTIL_EXPECTED,
  TOO_MANY_VARS,

  STACK_OVERFLOW,	/* interpreter error codes */
  SSP_OVERFLOW,
  DIV_BY_ZERO,
  FIELD_ERROR,
  TYPE_ERROR,
  CE_FUNCTION_FIELD,
  CE_SRC_FIELD,
  CE_DST_TABLE,
  CE_DST_FIELD,
  CE_DST_INDEX
}; /* DB_ERRORS */

#define OFFSET(type, ident) ((SIZE_T)(ULONG)&(((type *)0)->ident))
#define CHROFF(type, ident) ((SIZE_T)(ULONG)(((type *)0)->ident))

#define LOFFSET(type, ident) ((LONG)&(((type *)0)->ident))
#define LCHROFF(type, ident) ((LONG)(((type *)0)->ident))

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL SHORT WINAPI get_dberror _((VOID));
GLOBAL VOID  WINAPI set_dberror _((SHORT error));

GLOBAL VOID  WINAPI build_pass  _((LPSTR src, LPSTR dst));

GLOBAL BOOL  WINAPI expand_file _((HFILE handle, LONG pages));

#ifdef __cplusplus
}
#endif

#endif /* _DBROOT_H */
