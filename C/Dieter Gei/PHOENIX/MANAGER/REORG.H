/*****************************************************************************
 *
 * Module : REORG.H
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 10.03.94
 *
 *
 * Description: This module defines the list window.
 *
 * History:
 * 13.03.94: Parameter dbs in reorganizer added, dbname removed
 * 13.02.91: Parameter dbname in reorganizer added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef __REORG__
#define __REORG__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN init_reorg  _((VOID));
GLOBAL BOOLEAN term_reorg  _((VOID));

GLOBAL VOID    reorganizer _((DB_SPEC *dbs));

#endif /* __REORG__ */

