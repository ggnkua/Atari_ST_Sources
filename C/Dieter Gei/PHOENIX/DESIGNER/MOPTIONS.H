/*****************************************************************************
 *
 * Module : MOPTIONS.H
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 11.10.93
 *
 *
 * Description: This module implements the config dialog box.
 *
 * History:
 * 11.10.93: Dialog mconfmore deleted
 * 24.09.93: New dialog mconfmore added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __MOPTIONS__
#define __MOPTIONS__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_moptions _((VOID));
GLOBAL BOOLEAN term_moptions _((VOID));

GLOBAL BOOLEAN mload_config  _((BYTE *filename, BOOLEAN load_base));
GLOBAL BOOLEAN msave_config  _((BYTE *filename));
GLOBAL VOID    mconfig       _((VOID));
GLOBAL VOID    mparams       _((VOID));

#endif /* __MOPTIONS__ */

