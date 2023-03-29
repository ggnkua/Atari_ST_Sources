/*****************************************************************************
 *
 * Module : DD.H
 * Author : Gerhard Stoll
 *
 * Creation date    : 03.11.02
 * Last modification: 08.11.02
 *
 *
 * Description: This module implements the drag & drop  protocol
 *
 * History:
 * 08.11.02: Alles nochmal komplett um ger„umt
 * 07.11.02: Zus„tzlicher Parameter in hndl_dd (window).
 * 03.11.02: Creation of body
 *****************************************************************************/

#ifndef __DD__
#define __DD__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID dd_no ( WINDOWP window, WORD msg[16] );
GLOBAL VOID *dd_start ( WORD msg[] );
GLOBAL VOID dd_end ( void );

#endif /* __DD__ */
