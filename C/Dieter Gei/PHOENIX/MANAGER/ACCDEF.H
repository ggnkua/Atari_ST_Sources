/*****************************************************************************
 *
 * Module : ACCDEF.H
 * Author : Dieter Geiž
 *
 * Creation date    : 08.07.95
 * Last modification: 28.12.96
 *
 *
 * Description: This module defines the account definition window.
 *
 * History:
 * 28.12.96: AccDefPrint added
 * 10.10.95: AccDefToForeground and AccDefToBackground added
 * 08.07.95: Creation of body
 *****************************************************************************/

#ifndef __ACCDEF__
#define __ACCDEF__

/****** DEFINES **************************************************************/

#define CLASS_ACCDEF  26                /* Class AccDef Window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOL    AccDefInit           (VOID);
GLOBAL BOOL    AccDefTerm           (VOID);

GLOBAL WINDOWP AccDefCreate         (OBJECT *obj, OBJECT *menu, WORD icon, DB *db, SYSACCOUNT *sysaccount);

GLOBAL BOOL    AccDefOpen           (WORD icon, DB *db, SYSACCOUNT *sysaccount);
GLOBAL BOOL    AccDefInfo           (WINDOWP window, WORD icon);
GLOBAL BOOL    AccDefHelp           (WINDOWP window, WORD icon);
GLOBAL VOID    AccDefPrint          (WINDOWP window);

GLOBAL BOOL    AccDefClose          (DB *db);

GLOBAL VOID    AccDefNew            (VOID);
GLOBAL VOID    AccDefLoad           (WINDOWP window);
GLOBAL BOOL    AccDefSave           (WINDOWP window, BOOL saveas);
GLOBAL BOOL    AccDefExec           (WINDOWP window, DB *db, SHORT table, SHORT inx, SHORT dir);
GLOBAL VOID    AccDefExecute        (WINDOWP window);

GLOBAL BOOL    AccDefHasAccHeader   (WINDOWP window);
GLOBAL BOOL    AccDefHasPageHeader  (WINDOWP window);
GLOBAL VOID    AccDefFlipAccHeader  (WINDOWP window);
GLOBAL VOID    AccDefFlipPageHeader (WINDOWP window);

GLOBAL VOID    AccDefFlipRaster     (VOID);

GLOBAL VOID    AccDefToForeground   (WINDOWP window);
GLOBAL VOID    AccDefToBackground   (WINDOWP window);

#endif /* __ACCDEF__ */

