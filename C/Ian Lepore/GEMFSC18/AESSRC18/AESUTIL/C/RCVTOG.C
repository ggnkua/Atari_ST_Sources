/**************************************************************************
 * RCVTOG.C - Convert VRECT to GRECT.
 *************************************************************************/

#include "gemfast.h"

GRECT *rc_vtog(pvrect, pgrect)
    register VRECT *pvrect;
    register GRECT *pgrect;
{
    pgrect->g_x = pvrect->v_x1;
    pgrect->g_y = pvrect->v_y1;
    pgrect->g_w = pvrect->v_x2 - pvrect->v_x1 + 1;
    pgrect->g_h = pvrect->v_y2 - pvrect->v_y1 + 1;
    return pgrect;
}

