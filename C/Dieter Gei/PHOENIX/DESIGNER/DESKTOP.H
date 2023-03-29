/*****************************************************************************
 *
 * Module : DESKTOP.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 19.03.97
 *
 *
 * Description: This module implements the desktop.
 *
 * History:
 * 19.03.97: Function save_desktop added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __DESKTOP__
#define __DESKTOP__

/****** DEFINES **************************************************************/

#if GEM & XGEM
#define CLASS_DESK    DESKWINDOW        /* Klasse Desktopfenster */
#else
#define CLASS_DESK    DESK              /* Klasse Desktopfenster */
#endif

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WINDOWP find_desk    _((VOID));
GLOBAL VOID    get_dxywh    _((WORD obj, RECT *border));
GLOBAL VOID    set_func     _((CONST BYTE *keys));
GLOBAL VOID    draw_func    _((VOID));
GLOBAL VOID    draw_key     _((WORD key));
GLOBAL VOID    set_meminfo  _((VOID));

GLOBAL VOID    save_desktop _((FILE *file));

GLOBAL WINDOWP crt_desktop  _((OBJECT *obj, OBJECT *menu, WORD icon));

GLOBAL BOOLEAN open_desktop _((WORD icon));
GLOBAL BOOLEAN info_desktop _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_desktop _((WINDOWP window, WORD icon));

GLOBAL BOOLEAN init_desktop _((VOID));
GLOBAL BOOLEAN term_desktop _((VOID));

#endif /* __DESKTOP__ */

