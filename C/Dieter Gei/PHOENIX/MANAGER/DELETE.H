/*****************************************************************************/
/*                                                                           */
/* Modul: DELETE.H                                                           */
/* Datum: 03/10/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __DELETE__
#define __DELETE__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_delete _((VOID));
GLOBAL BOOLEAN term_delete _((VOID));

GLOBAL BOOLEAN delete_list   _((DB *db, WORD table, WORD inx, WORD dir, BOOLEAN minimize, BOOLEAN ask));
GLOBAL BOOLEAN undelete_list _((DB *db, WORD table, WORD inx, WORD dir, BOOLEAN minimize));

#endif /* __DELETE__ */

