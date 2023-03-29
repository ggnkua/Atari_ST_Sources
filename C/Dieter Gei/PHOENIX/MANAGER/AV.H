/*****************************************************************************
 *
 * Module : AV.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 02.11.02
 * Last modification: 02.11.02
 *
 *
 * Description: This module implements the av protokol
 *
 * History:
 * 
 * 02.11.02: Creation of body
 *****************************************************************************/

#ifndef __AV__
#define __AV__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID send_avstartprog ( BYTE *str, WORD magic );
GLOBAL WORD hndl_av ( WORD msg[16] );
GLOBAL WORD init_av ( VOID );
GLOBAL WORD term_av ( VOID );

#endif /* __AV__ */
