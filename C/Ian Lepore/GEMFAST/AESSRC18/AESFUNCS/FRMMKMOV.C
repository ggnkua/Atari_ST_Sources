/**************************************************************************
 * 
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#define MOVER_CANT_BE (SELECTABLE|DEFAULT|EXIT|EDITABLE|RBUTTON|HIDETREE)
#define MOVER_MUST_BE (FRM_MOVER|TOUCHEXIT)

int frm_mkmoveable(ptree, object)
    register OBJECT *ptree;
    int              object;
{
    register int     oldflags;

    ptree           = &ptree[object];
    oldflags        = ptree->ob_flags;    
    ptree->ob_flags = (oldflags & ~MOVER_CANT_BE) | MOVER_MUST_BE;
    return oldflags;
}

