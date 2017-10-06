/**************************************************************************
 * RCADJUST.C - Adjust a GRECT or VRECT rectangle to a new size.
 *************************************************************************/

#include "gemfast.h"

static void rc_adjust(prect, xadjust, yadjust, is_grect)
    register VRECT *prect;
    register int    xadjust;
    register int    yadjust;
    int             is_grect;
{
    prect->v_x1 -= xadjust;
    prect->v_y1 -= yadjust;
    
    if (is_grect) {
        xadjust *= 2;
        yadjust *= 2;
    }
    
    prect->v_x2 += xadjust;
    prect->v_y2 += yadjust;
    
    if (prect->v_x1 < 0) {
        prect->v_x1 = 0;
    }
    
    if (prect->v_y1 < 0) {
        prect->v_y1 = 0;
    }
    
    if (prect->v_x2 <= 0) {
        prect->v_x2 = 1;
    }
    
    if (prect->v_y2 <= 0) {
        prect->v_y2 = 1;
    }
} 
VRECT *rc_vadjust(prect, xadjust, yadjust)
    VRECT *prect;
    int    xadjust;
    int    yadjust;
{
    rc_adjust(prect, xadjust, yadjust, 0);
    return prect;
}

GRECT *rc_gadjust(prect, xadjust, yadjust)
    GRECT *prect;
    int    xadjust;
    int    yadjust;
{
    rc_adjust(prect, xadjust, yadjust, 1);
    return prect;
}

