/*****************************************************************************/
/*                                                                           */
/* Modul: IMPEXP.H                                                           */
/* Datum: 11/08/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __IMPEXP__
#define __IMPEXP__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_impexp _((VOID));
GLOBAL BOOLEAN term_impexp _((VOID));

GLOBAL BOOLEAN imp_list    _((DB *db, WORD table, WORD cols, WORD *columns, WORD *colwidth, BYTE *filename, BOOLEAN minimize));
GLOBAL BOOLEAN exp_list    _((DB *db, WORD table, WORD inx, WORD dir, WORD cols, WORD *columns, WORD *colwidth, BYTE *filename, BOOLEAN minimize));

#endif /* __IMPEXP__ */

