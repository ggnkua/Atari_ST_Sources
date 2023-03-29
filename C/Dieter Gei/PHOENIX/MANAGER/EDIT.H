/*****************************************************************************
 *
 * Module : EDIT.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 14.11.93
 *
 *
 * Description: This module defines the editor window.
 *
 * History:
 * 14.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __EDIT__
#define __EDIT__

/****** DEFINES **************************************************************/

#define CLASS_EDIT    12                /* Klasse Editierfenster */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    print_edit _((WINDOWP window));
GLOBAL WINDOWP crt_edit   _((OBJECT *obj, OBJECT *menu, WORD icon, BYTE *filename, FONTDESC *fontdesc));

GLOBAL BOOLEAN open_edit  _((WORD icon, BYTE *filename, FONTDESC *fontdesc));
GLOBAL BOOLEAN info_edit  _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_edit  _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_edit  _((VOID));
GLOBAL BOOLEAN term_edit  _((VOID));

#endif /* __EDIT__ */

