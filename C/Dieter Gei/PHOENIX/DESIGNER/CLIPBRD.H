/*****************************************************************************/
/*                                                                           */
/* Modul: CLIPBRD.H                                                          */
/* Datum: 18/01/91                                                           */
/*                                                                           */
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
GLOBAL BOOLEAN empty_clipbrd _((WINDOWP window, BOOLEAN external));
/* GS 5.1c Start */
GLOBAL VOID write_to_clipboard   _(( BYTE *buf, LONG len ));
GLOBAL BYTE *read_from_clibboard _(( VOID ));
/* Ende */
GLOBAL BOOLEAN copy2clipbrd  _((WINDOWP window, WORD class, SET objs, BOOLEAN external));
GLOBAL BOOLEAN paste_clipbrd _((WINDOWP window, RECT *r, BOOLEAN external));

#endif /* __CLIPBRD__ */

