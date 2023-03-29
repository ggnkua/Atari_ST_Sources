/*****************************************************************************
 *
 * Module : ACCPREV.H
 * Author : Dieter Geiž
 *
 * Creation date    : 26.11.96
 * Last modification: 30.12.96
 *
 *
 * Description: This module defines the account preview window.
 *
 * History:
 * 30.12.96: AccPrevWriteGraphic modified
 * 28.12.96: AccPrevPrint and AccPrevPrintFile added
 * 22.12.96: Parameter lWidth in AccPrevWriteText added
 * 15.12.96: MAX_PAGES movef from ACCOUNT.C
 * 26.11.96: Creation of body
 *****************************************************************************/

#ifndef __ACCPREV__
#define __ACCPREV__

/****** DEFINES **************************************************************/

#define CLASS_ACCPREV		28	/* Class Account Preview Window */

#define MAX_PAGES		2500	/* max number of pages in page table */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOL    AccPrevInit             (VOID);
GLOBAL BOOL    AccPrevTerm             (VOID);

GLOBAL WINDOWP AccPrevCreate           (OBJECT *obj, OBJECT *menu, WORD icon, CHAR *pFileName, CHAR *pAccountName);

GLOBAL BOOL    AccPrevOpen             (WORD icon, CHAR *pFileName, CHAR *pAccountName);
GLOBAL BOOL    AccPrevInfo             (WINDOWP window, WORD icon);
GLOBAL BOOL    AccPrevHelp             (WINDOWP window, WORD icon);
GLOBAL VOID    AccPrevPrint            (WINDOWP window);
GLOBAL VOID    AccPrevPrintFile        (CHAR *pFileName, CHAR *pAccountName);

GLOBAL BOOL    AccPrevWriteBackground  (HFILE hFile, LRECT *rc, SHORT sColor);
GLOBAL BOOL    AccPrevWriteRectangle   (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle);
GLOBAL BOOL    AccPrevWriteLine        (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle);
GLOBAL BOOL    AccPrevWriteGroupBox    (HFILE hFile, LRECT *rc, SHORT sEffect, SHORT sMode, SHORT sColor, LONG lWidth, SHORT sStyle, FONTDESC *pFont, SHORT sHorzAlignment, CHAR *pText);
GLOBAL BOOL    AccPrevWriteCheckRadio  (HFILE hFile, LRECT *rc, SHORT sEffect, FONTDESC *pFont, CHAR *pText, BOOL bChecked, BOOL bRadio);
GLOBAL BOOL    AccPrevWriteText        (HFILE hFile, LRECT *rc, LONG lWidth, FONTDESC *pFont, SHORT sHorzAlignment, SHORT sVertAlignment, SHORT sRotation, CHAR *pText);
GLOBAL BOOL    AccPrevWriteGraphic     (HFILE hFile, LRECT *rc, LONG lWidth, CHAR *pFileName);

#endif /* __ACCPREV__ */
