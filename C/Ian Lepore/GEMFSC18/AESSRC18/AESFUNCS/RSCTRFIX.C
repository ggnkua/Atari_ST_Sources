/**************************************************************************
 * RSCTRFIX.C - Do rsrc_obfix() for all objects in a tree.
 *************************************************************************/

#include "gemfast.h"

void rsc_treefix(ptree)
    register OBJECT *ptree;
{
    register int    objcounter = -1;

    do  {
        rsrc_obfix(ptree, ++objcounter);
    } while (!(ptree[objcounter].ob_flags & LASTOB));
}

