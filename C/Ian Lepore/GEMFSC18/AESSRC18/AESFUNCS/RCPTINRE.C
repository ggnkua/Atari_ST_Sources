/**************************************************************************
 * RCPTINRE.C - Return TRUE/FALSE indicating point is in/out of rectangle.
 *************************************************************************/

#include "gemfast.h"

int rc_ptinrect(prect, x, y)
    register GRECT *prect;
    register int   x;
    register int   y;
{
    VRECT   r;
    
    rc_gtov(prect, &r);
    
    if (x < r.v_x1 || x > r.v_x2 || y < r.v_y1 || y > r.v_y2) {
        return 0;
    } else {
        return 1;
    } 
}
