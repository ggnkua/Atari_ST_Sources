/*****************************************************************************
 *
 * Module : MENU.H
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 30.10.02
 *
 *
 * Description: This module implements the initialization and termination functions.
 *
 * History:
 * 30.10.02: globaler Puffer (menu_pipe) fÅr den Inhalt des Messages-Buffer
 * 20.05.96: Function hndl_ap_term added
 * 15.03.94: Function hndl_va_start added
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
GLOBAL WORD     menu_pipe [8];						/* Inhalt von Message	*/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    about_menu    (VOID);

GLOBAL VOID    updt_menu     (WINDOWP window);
GLOBAL VOID    hndl_menu     (WINDOWP window, WORD title, WORD item);
GLOBAL VOID    hndl_va_start (BYTE *filename);
GLOBAL VOID    hndl_ap_term  (WORD caller_apid, WORD reason);

GLOBAL BOOLEAN init_menu     (VOID);
GLOBAL BOOLEAN term_menu     (VOID);

#endif /* __MENU__ */

