/*****************************************************************************/
/*                                                                           */
/* Modul: CLIPBRD.H                                                          */
/* Datum: 18/01/91                                                           */
/*                                                                           */
/* History:
 * 22.06.03: Alle Cliboardfunktionen aus global.h kopiert
 *           write_to_clipboard eingefÅgt.
 *                                                                           */
/*****************************************************************************/

#ifndef __CLIPBRD__
#define __CLIPBRD__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_clipbrd  _((BOOLEAN external));
GLOBAL BOOLEAN term_clipbrd  _((VOID));

GLOBAL WORD    scrap_read    _((BYTE *pscrap));
GLOBAL WORD    scrap_write   _((BYTE *pscrap));
GLOBAL WORD    scrap_clear   _((VOID));

GLOBAL VOID    clear_clipbrd _((BOOLEAN external));
GLOBAL VOID    info_clipbrd  _((BOOLEAN external));
GLOBAL BOOLEAN check_clipbrd _((BOOLEAN external));

/* [GS] 5.1c Start */
GLOBAL VOID write_to_clipboard   _(( BYTE *buf, LONG len ));
GLOBAL BYTE *read_from_clibboard _(( VOID ));

GLOBAL WORD    ClipboardGetMode  _((VOID));
GLOBAL WORD    ClipboardSetMode  _((WORD wMode));
GLOBAL VOID    ClipboardGetName  _((BYTE *pszFileName));
GLOBAL VOID    ClipboardSetName  _((BYTE *pszFileName));
GLOBAL LONG    ClipboardGetSize  _((WORD wFormat));
GLOBAL VOID    ClipboardSetSize  _((WORD wFormat, LONG lSize));
GLOBAL VOID    *ClipboardGetData _((WORD wFormat));
GLOBAL VOID    ClipboardSetData  _((WORD wFormat, VOID *pData));
GLOBAL VOID    ClipboardEmpty    _((VOID));
/* Ende  */

#endif /* __CLIPBRD__ */

