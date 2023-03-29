/*****************************************************************************
 *
 * Module : COMMDLG.H
 * Author : Dieter Geiž
 *
 * Creation date    : 11.10.93
 * Last modification: 21.03.94
 *
 *
 * Description: This module defines the the common dialog boxes.
 *
 * History:
 * 21.03.94: Function FontType added
 * 10.03.94: Function FontIsMonospaced added
 * 05.12.93: Function GetPathNameDialog added
 * 13.11.93: Functions FontNameFromNumber and FontNumberFromName added
 * 04.11.93: Structs FONTDESC and FONTINFO move to GLOBAL.H
 * 03.11.93: Parameter wErrNoOpen in InitCommDlg added
 * 01.11.93: FONT_FLAG_SHOW_SYSTEM added
 * 11.10.93: Creation of body
 *****************************************************************************/

#ifndef __COMMDLG__
#define __COMMDLG__

/****** DEFINES **************************************************************/

#define FILE_FLAG_HIDE_HELP	0x00000001L

#define FONT_FLAG_HIDE_HELP	0x00000001L
#define FONT_FLAG_HIDE_EFFECTS	0x00000002L
#define FONT_FLAG_HIDE_COLOR	0x00000004L
#define FONT_FLAG_SHOW_SYSTEM	0x00000008L
#define FONT_FLAG_SHOW_MONO	0x00000010L
#define FONT_FLAG_SHOW_PROP	0x00000020L
#define FONT_FLAG_SHOW_VECTOR	0x00000040L

/****** TYPES ****************************************************************/

typedef struct
{
  BYTE *suffix;				/* suffix eg "TXT" */
  ICON icon1;				/* monochrome icon */
  ICON icon4;				/* 16 color icon */
} ICONSUFFIX;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN InitCommDlg           (WORD wErrNoOpen, BYTE **ppszOrderByStrings, BYTE **ppszColorStrings, WORD wNumIconSuffix, ICONSUFFIX *pIconSuffix);
GLOBAL BOOLEAN TermCommDlg           (VOID);

GLOBAL BOOLEAN GetOpenFileNameDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName);
GLOBAL BOOLEAN GetSaveFileNameDialog (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszFilter, LONG *plFilterIndex, BYTE *pszInitialDir, BYTE *pszDefExt, BYTE *pszFullName, BYTE *pszFileName);
GLOBAL BOOLEAN GetPathNameDialog     (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, BYTE *pszInitialDir);

GLOBAL BOOLEAN GetFontDialog         (BYTE *pszTitle, BYTE *pszHelpID, ULONG ulFlags, WORD vdi_handle, FONTDESC *pFontDesc);

GLOBAL VOID    FontNameFromNumber    (BYTE *pszFontName, WORD wFont);
GLOBAL WORD    FontNumberFromName    (BYTE *pszFontName);
GLOBAL BOOLEAN FontIsMonospaced      (WORD vdi_handle, WORD wFont);
GLOBAL WORD    FontType              (WORD wFont);

GLOBAL BOOLEAN LoadFonts             (WORD vdi_handle);
GLOBAL BOOLEAN UnloadFonts           (WORD vdi_handle);

#endif /* __COMMDLG__ */

