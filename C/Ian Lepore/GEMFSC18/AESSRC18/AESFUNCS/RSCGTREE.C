/**************************************************************************
 * RSCGTREE.C - rsc_gtrees() function.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

typedef struct parms {
    short    idx;
    OBJECT **pptree;
} Parms;

void rsc_gtrees(firstparm)
    Parms firstparm;
{
    register Parms  *pparm = &firstparm;
     
    while (pparm->idx >= 0) {
        rsrc_gaddr(R_TREE, pparm->idx, pparm->pptree);
        ++pparm;
    }

}

