/**************************************************************************
 * WNDUPDAT.C - Implement nested wind_update() logic.
 *************************************************************************/

#include "gemfast.h"

#undef wind_update    /* undo GEMFAST.H remapping, we need The Real Thing */

static int  windowcount;
static int  mousecount;

int wnd_update(flag)
{
    int *counter;
    
    counter = (flag & 0x0002) ? &mousecount : &windowcount;
    
    if (flag & 0x0001) {                /* BEG_UPDATE or BEG_MCTRL, count */
        if (++(*counter) == 1) {        /* it. if we went from 0 to 1, we */
            return wind_update(flag);   /* need to aquire the semaphore.  */
        }
    } else {                                /* END_UPDATE or END_MCTRL    */
        if (*counter > 0) {                 /* if we're currently holding */ 
            if (--(*counter) == 0) {        /* semaphore, decr count, if  */
                return wind_update(flag);   /* it goes to 0, release it.  */
            }
        }
    }
    return 1;
}
