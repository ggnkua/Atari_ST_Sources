/**************************************************************************
 * WINXCALC.C - Extended wind_calc() function.
 *************************************************************************/

#include "gemfast.h"

int winx_calc(type, kind, inrect, poutrect)
    int     type;
    int     kind;
    GRECT   inrect;
    GRECT  *poutrect;
{
    return wind_calc(type, kind, inrect,
                        &poutrect->g_x, &poutrect->g_y,
                        &poutrect->g_w, &poutrect->g_h);
}
