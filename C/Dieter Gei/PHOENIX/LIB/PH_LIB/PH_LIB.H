/*****************************************************************************
 *
 * Module : PH_LIB.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 27.10.02
 * Last modification: 25.12.02
 *
 *
 * Description: Allgemeine Funktionen die vom Manager und Designer benutzt werden.
 *
 * History:
 * 05.08.05: get_nvdi added
 * 25.12.02: get_magic added
 * 02.11.02: malloc_global 
 * 27.10.02: appl_getinfo, get_cookie
 *****************************************************************************/

#ifndef __PH_LIB__
#define __PH_LIB__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL WORD appl_xgetinfo ( WORD type, WORD *out1, WORD *out2, WORD *out3, WORD *out4);
GLOBAL VOID *malloc_global ( LONG size );
GLOBAL WORD get_cookie( LONG cookie, void *value );
GLOBAL WORD get_magic ( void );
GLOBAL WORD get_nvdi ( void );

#endif /* __PH_LIB__ */
