/**************************************************************************
 * RSCSXTYP.C - Set extended object types within a tree.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

void rsc_sxtypes(thetree)
    OBJECT          *thetree;
{
    register OBJECT *ptree;
    register int     thisobj;
    register int     thistype;
    va_list          args;

    va_start(args, thetree);
    ptree = thetree;
    for (;;) {
        thisobj = va_arg(args, int);
        if (thisobj < 0)
            break;
        thistype = va_arg(args, int);
        ptree[thisobj].ob_type |= thistype << 8;
    }
    va_end(args);
}
