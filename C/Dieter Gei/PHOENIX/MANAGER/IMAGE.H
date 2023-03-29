/*****************************************************************************/
/*                                                                           */
/* Modul: IMAGE.H                                                            */
/* Datum: 06/11/89                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __IMAGE__
#define __IMAGE__

/****** DEFINES **************************************************************/

#define CLASS_IMAGE   11                /* Klasse Imagefenster */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    print_image _((BYTE *filename));
GLOBAL WINDOWP crt_image   _((OBJECT *obj, OBJECT *menu, WORD icon, BYTE *filename));

GLOBAL BOOLEAN open_image  _((WORD icon, BYTE *filename));
GLOBAL BOOLEAN info_image  _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_image  _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_image  _((VOID));
GLOBAL BOOLEAN term_image  _((VOID));

#endif /* __IMAGE__ */

