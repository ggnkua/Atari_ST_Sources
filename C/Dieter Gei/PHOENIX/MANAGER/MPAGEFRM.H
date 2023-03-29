/*****************************************************************************
 *
 * Module : MPAGEFRM.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.04.94
 *
 *
 * Description: This module defines the page format dialog box.
 *
 * History:
 * 04.04.94: Parameter loadfile replaced by loadinf in load_pageformat
 * 01.09.91: Parameter updt_dialog in load_impexp added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MPAGEFRM__
#define __MPAGEFRM__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

GLOBAL PAGE_FORMAT page_format;

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_mpagefrm   _((VOID));
GLOBAL BOOLEAN term_mpagefrm   _((VOID));

GLOBAL VOID    get_pageformat  _((PAGE_FORMAT *page_format));
GLOBAL VOID    set_pageformat  _((PAGE_FORMAT *page_format));
GLOBAL BOOLEAN load_pageformat _((BYTE *loadinf, BYTE *loadname, PAGE_FORMAT *format, BOOLEAN updt_dialog));
GLOBAL BOOLEAN save_pageformat _((FILE *savefile, BYTE *savename, PAGE_FORMAT *format));

GLOBAL VOID    mpageformat     _((VOID));

#endif /* __MPAGEFRM__ */

