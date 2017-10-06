/**************************************************************************
 * RCCONFIN.C - Force destrect to be within boundrect.
 *              If destrect is bigger than boundrect, precedence is given
 *              to the upper and left edges (ie, dest will be aligned
 *              with the boundry on the topleft edge).
 *************************************************************************/

#include "gemfast.h"

GRECT *rc_confine(pbound, pdest)
    GRECT           *pbound;
    register GRECT  *pdest;
{
    register int    diff;
    VRECT           bound;
    VRECT           dest;
    
    rc_gtov(pbound, &bound);
    rc_gtov(pdest,  &dest);
    
    if (0 < (diff = dest.v_x2 - bound.v_x2)) {
        pdest->g_x -= diff;
    }
    
    if (0 < (diff = dest.v_y2 - bound.v_y2)) {
        pdest->g_y -= diff;
    }
    
    if (dest.v_x1 < bound.v_x1) {
        pdest->g_x = bound.v_x1;
    }
    
    if (dest.v_y1 < bound.v_y1) {
        pdest->g_y = bound.v_y1;
    }
    
    return pdest;
}
