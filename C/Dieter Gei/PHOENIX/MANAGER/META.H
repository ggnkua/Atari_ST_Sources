/*****************************************************************************/
/*                                                                           */
/* Modul: META.H                                                             */
/* Datum: 06/11/89                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __META__
#define __META__

/****** DEFINES **************************************************************/

#define CLASS_META    10                /* Klasse Metafenster */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    print_meta _((BYTE *filename));
GLOBAL WINDOWP crt_meta   _((OBJECT *obj, OBJECT *menu, WORD icon, BYTE *filename));

GLOBAL BOOLEAN open_meta  _((WORD icon, BYTE *filename));
GLOBAL BOOLEAN info_meta  _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_meta  _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_meta  _((VOID));
GLOBAL BOOLEAN term_meta  _((VOID));

#endif /* __META__ */

