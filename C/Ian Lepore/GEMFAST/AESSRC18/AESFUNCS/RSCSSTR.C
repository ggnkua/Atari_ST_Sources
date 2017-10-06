/**************************************************************************
 * RSCSSTR.C - Set pointers to object strings from within a tree.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

void rsc_sstrings(thetree)
    OBJECT          *thetree;
{
    register OBJECT *ptree;
    register char  **ppstr;
    register int     thisobj;
    va_list          args;

    va_start(args, thetree);
    ptree = thetree;
    for (;;) {
        thisobj = va_arg(args, int);
        if (thisobj < 0)
            break;
        ppstr  = obj_ppstring(&ptree[thisobj]);
        *ppstr = va_arg(args, char *);
    }
    va_end(args);
}
