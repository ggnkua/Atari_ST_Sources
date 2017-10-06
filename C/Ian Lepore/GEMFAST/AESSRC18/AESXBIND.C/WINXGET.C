/**************************************************************************
 * WINXGET.C - Extended wind_get() function.
 *************************************************************************/

#include "gemfast.h"

int 
winx_get(whandle, wfield, prect)
    int     whandle;
    int     wfield;
    GRECT   *prect;
{
    return wind_get(whandle, wfield, 
                    &prect->g_x, &prect->g_y,
                    &prect->g_w, &prect->g_h);
}

