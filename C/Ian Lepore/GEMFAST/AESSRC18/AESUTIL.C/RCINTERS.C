/**************************************************************************
 * RCINTERS.C - Calc intersection of two GRECT rectangles.
 *              Returns TRUE if rectanlges have common area, FALSE if not.
 *************************************************************************/

#include "gemfast.h"

int rc_intersect(prect1, prect2)
    register GRECT *prect1;
    register GRECT *prect2;
{
    register int    w1, w2;
    int             lx, rx;
    int             ty, by;
    
    /* calc right-side x as the lesser x of the two rectangles */
     
    w1 = prect1->g_x + prect2->g_w;
    w2 = prect2->g_x + prect2->g_w;
    rx  = (w1 < w2) ? w1 : w2;

    /*  calc bottom y as the lesser y of the two rectanlges */

    w1 = prect1->g_y + prect1->g_h;
    w2 = prect2->g_y + prect2->g_h;
    by  = (w1 < w2) ? w1 : w2;
    
    /* calc left-side x as the greater x of the two rectangles */

    w1 = prect1->g_x;
    w2 = prect2->g_x;
    lx = (w1 > w2) ? w1 : w2;
    
    /* calc top y as the greater y of the two rectangles */

    w1 = prect1->g_y;
    w2 = prect2->g_y;
    ty = (w1 > w2) ? w1 : w2;
    
    /* store the calculated rectangle (converting back to GRECT-type w/h) */

    prect2->g_x = lx;
    prect2->g_y = ty;
    prect2->g_w = rx - lx;
    prect2->g_h = by - ty;

    /* 
     * if the calculated width or height is zero or less, it indicates
     * that there is no overlap in at least one dimension, and thus no
     * overlap in the rectangles, so return FALSE.  if both values are
     * positive, there is a common intersecting area, so return TRUE.
     */
     
    if ( prect2->g_w <= 0 || prect2->g_h <= 0) {
        return 0;
    } else {
        return 1;
   }
}

