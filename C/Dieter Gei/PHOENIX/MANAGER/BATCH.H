/*****************************************************************************
 *
 * Module : BATCH.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.03.94
 *
 *
 * Description: This module defines the batch definition window.
 *
 * History:
 * 20.03.93: Parameter saveas added
 * 04.11.93: Using fontdesc
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __BATCH__
#define __BATCH__

/****** DEFINES **************************************************************/

#define CLASS_BATCH  24                 /* Class Batch Window */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_batch    _((VOID));
GLOBAL BOOLEAN term_batch    _((VOID));

GLOBAL WINDOWP crt_batch     _((OBJECT *obj, OBJECT *menu, WORD icon, DB *db, BYTE *batch, BYTE *name, FONTDESC *fontdesc));

GLOBAL BOOLEAN open_batch    _((WORD icon, DB *db, BYTE *batch, BYTE *name, FONTDESC *fontdesc));
GLOBAL BOOLEAN info_batch    _((WINDOWP window, WORD icon));
GLOBAL BOOLEAN help_batch    _((WINDOWP window, WORD icon));

GLOBAL VOID    print_batch   _((WINDOWP window));

GLOBAL BOOLEAN close_batch   _((DB *db));

GLOBAL VOID    batch_new     _((VOID));
GLOBAL VOID    batch_old     _((WINDOWP window));
GLOBAL BOOLEAN batch_save    _((WINDOWP window, BOOLEAN saveas));
GLOBAL VOID    batch_execute _((WINDOWP window));
GLOBAL BOOLEAN batch_exec    _((WINDOWP window, DB *db, BYTE *batch));

#endif /* __BATCH__ */

