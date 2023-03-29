/*****************************************************************************/
/*                                                                           */
/* Modul: MLSCONF.H                                                          */
/* Datum: 06/05/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __MLSCONF__
#define __MLSCONF__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mlsconf _((VOID));
GLOBAL BOOLEAN term_mlsconf _((VOID));

GLOBAL BOOLEAN mload_config _((BYTE *filename, BOOLEAN show_error, BOOLEAN load_dbs));
GLOBAL BOOLEAN msave_config _((BYTE *filename, BOOLEAN show_error, BOOLEAN save_dbs));

#endif /* __MLSCONF__ */

