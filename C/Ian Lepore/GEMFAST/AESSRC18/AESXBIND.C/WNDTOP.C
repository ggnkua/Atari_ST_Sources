/**************************************************************************
 * WNDTOP.C - The wnd_top() function.
 *            This critter is somewhere between a utility and a binding.
 *************************************************************************/

#include "gemfast.h"

int wnd_top()
{
    int topwindow;
    int dmy;
    
    wind_get(0, WF_TOP, &topwindow, &dmy, &dmy, &dmy);
    
    return topwindow;
}
