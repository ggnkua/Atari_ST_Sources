/*  status.c    Dan Ackerman 1997         baldrick@netset.com
 *
 * Contains routins applicable to the STACK_STATUS TPL
 */
#include "lattice.h"
#include <stdio.h>      /* for NULL */

#include "globdefs.h"
#include "globdecl.h"


long * cdecl get_elog(void)
{
    return (elog);
}

