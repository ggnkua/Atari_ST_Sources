/*****************************************************************************
 *
 * Module : OLGA_.H
 * Author : Gerhard Stoll
 *
 * Creation date    : 25.12.02
 * Last modification: 25.12.02
 *
 *
 * Description: This module implements the olga protocol
 *
 * History:
 * 25.12.02: Creation of body
 *****************************************************************************/

#ifndef OLGA_
#define OLGA_

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD hndl_olga ( WORD msg[16] );
GLOBAL VOID init_olga ( VOID );
GLOBAL VOID term_olga ( VOID );

#endif /* OLGA_ */

