/*****************************************************************************
 *
 * Module : DBCALC.H
 * Author : Jürgen Geiß
 *
 * Creation date    : 01.07.89
 * Last modification: 04.07.95
 *
 *
 * Description: This module defines the database calculation routines.
 *
 * History:
 * 04.07.95: Types VALUE and VALUEDESC added, parameter retval added to db_execute
 * 14.11.92: HPVOID used as data type of parameter buffer in db_excute
 * 31.10.92: Far pointer definitions for DLL implementation added
 * 26.10.92: db_compile and db_execute have INT results
 * 25.10.92: Module header added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef _DBCALC_H
#define _DBCALC_H

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef	union
{
  CHAR      *stringVal;
  SHORT	    wordVal;
  LONG	    longVal;
  DOUBLE    floatVal;
  DATE	    dateVal;
  TIME	    timeVal;
  TIMESTAMP timeStampVal;
} VALUE;


typedef	struct
{
  SHORT	type;
  VALUE	val;
} VALUEDESC;

typedef VALUEDESC FAR *LPVALUEDESC;	/* pointer to value descriptor */

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL INT WINAPI db_compile (LPBASE base, SHORT table, LPSYSCALC syscalc, LPSHORT line, LPSHORT col, LPFORMAT form);
GLOBAL INT WINAPI db_execute (LPBASE base, SHORT table, LPCALCCODE calccode, HPVOID buffer, LONG count, LPFORMAT form, LPVALUEDESC retval);

#endif /* _DBCALC_H */

