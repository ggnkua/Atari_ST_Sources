/*****************************************************************************
 *
 * Module : MENU.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 12.06.96
 *
 *
 * Description: This module implements the initialization and termination functions.
 *
 * History:
 * 12.06.96: Function hndl_ap_term added
 * 23.03.94: Function hndl_va_start added
 * 22.11.90: Variable ccp_ext added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MENU__
#define __MENU__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WORD title;                             /* Titel des MenÅs */
  WORD item;                              /* Nummer des MenÅs */
} FUNCINFO;

/****** VARIABLES ************************************************************/

GLOBAL BOOLEAN  menu_ok;                  /* MenÅ vorhanden ? */
GLOBAL BOOLEAN  menu_fits;                /* MenÅ paût in MenÅzeile ? */
GLOBAL FUNCINFO funcmenus [MAX_FUNC];     /* MenÅs auf den Funktionstasten */
GLOBAL SET      menus;                    /* WÑhlbare MenÅs vor Zustandswechsel */
GLOBAL WORD     ccp_ext;                  /* Cut/Copy/Paste extern auf Klemmbrett */

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    updt_menu     _((WINDOWP window));
GLOBAL VOID    hndl_menu     _((WINDOWP window, WORD title, WORD item));
GLOBAL VOID    hndl_va_start _((BYTE *filename));
GLOBAL VOID    hndl_ap_term  (WORD caller_apid, WORD reason);

GLOBAL BOOLEAN init_menu     _((VOID));
GLOBAL BOOLEAN term_menu     _((VOID));

#endif /* __MENU__ */
