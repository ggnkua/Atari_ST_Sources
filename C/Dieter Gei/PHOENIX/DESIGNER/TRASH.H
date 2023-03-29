/*****************************************************************************/
/*                                                                           */
/* Modul: TRASH.H                                                            */
/* Datum: 06/11/89                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __TRASH__
#define __TRASH__

/****** DEFINES **************************************************************/

#define CLASS_TRASH   14                /* Klasse MÅlleimerfenster */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WINDOWP crt_trash  _((OBJECT *obj, OBJECT *menu, WORD icon));

GLOBAL BOOLEAN open_trash _((WORD icon));
GLOBAL BOOLEAN info_trash _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_trash _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_trash _((VOID));
GLOBAL BOOLEAN term_trash _((VOID));

#endif /* __TRASH__ */

