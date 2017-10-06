/*****************************************************************************
 * EXTERR.H - Extensions to errno for application-specific error handling.
 ****************************************************************************/

#pragma idempotent              /* Sozobon: only include this file once.   */

#ifndef _EXTERROR_H_
#define _EXTERROR_H_

#include <errno.h>              /* pull in compiler's standard errno stuff */

typedef struct _Err_tab {       /* application-specific error message table*/
    int     code;               /* error code                              */
    char    *msg;               /* pointer to message for this code        */
    } _Err_tab;                 /* last entry marked by entry w/code 0     */

extern  int   exterrset();      /* add/remove ap-specific err msg table    */
extern  char  *exterror();      /* get ap-specific error message           */

#endif

