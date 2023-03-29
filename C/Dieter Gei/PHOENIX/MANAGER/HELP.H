/*****************************************************************************/
/*                                                                           */
/* Modul: HELP.H                                                             */
/* Datum: 15/08/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __HELP__
#define __HELP__

/****** DEFINES **************************************************************/

#define CLASS_HELP   2                  /* Klasse Hilfefenster */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_help    _((BYTE *help_name, BYTE *help_path, BYTE *help_contents));
GLOBAL BOOLEAN term_help    _((VOID));

GLOBAL BOOLEAN open_dbhelp  _((BYTE *help_name, BYTE *help_path));
GLOBAL BOOLEAN close_dbhelp _((VOID));
GLOBAL BOOLEAN open_help    _((BYTE *help_name, BYTE *help_path, BYTE *help_msg));

#endif /* __HELP__ */

