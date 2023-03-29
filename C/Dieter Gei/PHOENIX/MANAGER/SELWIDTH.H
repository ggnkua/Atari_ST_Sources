/*****************************************************************************/
/*                                                                           */
/* Modul: SELWIDTH.H                                                         */
/* Datum: 03/10/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __SELWIDTH__
#define __SELWIDTH__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_selwidth _((VOID));
GLOBAL BOOLEAN term_selwidth _((VOID));

GLOBAL WORD    selwidth      _((BYTE *name, WORD width, WORD minwidth, WORD maxwidth, LONG reswidth, BOOLEAN show_reswidth));

#endif /* __SELWIDTH__ */

