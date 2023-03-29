/*****************************************************************************/
/*                                                                           */
/* Modul: DISK.H                                                             */
/* Datum: 16/04/89                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __DISK__
#define __DISK__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN icons_disk _((WORD src_obj, WORD dest_obj));
GLOBAL WINDOWP crt_disk   _((OBJECT *obj, OBJECT *menu, WORD icon));

GLOBAL BOOLEAN open_disk  _((WORD icon));
GLOBAL BOOLEAN info_disk  _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_disk  _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_disk  _((VOID));
GLOBAL BOOLEAN term_disk  _((VOID));

#endif /* __DISK__ */

