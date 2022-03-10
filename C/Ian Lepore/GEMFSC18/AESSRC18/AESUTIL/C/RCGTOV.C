/**************************************************************************
 * RCGTOV.C - Convert GRECT to VRECT.
 *************************************************************************/

#include "gemfast.h"

VRECT *rc_gtov(pgrect, pvrect)
    register GRECT *pgrect;
    register VRECT *pvrect;
{
    pvrect->v_x1 = pgrect->g_x;
    pvrect->v_y1 = pgrect->g_y;
    pvrect->v_x2 = pgrect->g_x + pgrect->g_w - 1;
    pvrect->v_y2 = pgrect->g_y + pgrect->g_h - 1;    
    return pvrect;
}

