/**************************************************************************
 * RCSCALE.C -  Scale sourcerect into destrect using specified percentage.
 *              The destination rectangle is g'teed to have width and
 *              height values of at least 1, since GEM and other lib
 *              library routines puke on no-area rectangles.
 *************************************************************************/

#include "gemfast.h"

GRECT *rc_scale(psource, pdest, percentage)
    register GRECT *psource;
    register GRECT *pdest;
    register int    percentage;
{
    register int wdest;
    register int hdest;
    register int wsource;
    register int hsource;
    
    if (percentage < 0) {
        percentage = 100;
    }
    
    wsource = psource->g_w;
    hsource = psource->g_h;
    
    wdest = (wsource * (long)percentage) / 100;
    hdest = (hsource * (long)percentage) / 100;
    
    pdest->g_x = psource->g_x + ((wsource - wdest) / 2);
    pdest->g_y = psource->g_y + ((hsource - hdest) / 2);
    pdest->g_w = wdest ? wdest : 1;
    pdest->g_h = hdest ? hdest : 1;
    
    return pdest;
}
