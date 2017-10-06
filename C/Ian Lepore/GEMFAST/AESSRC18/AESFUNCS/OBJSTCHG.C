/**************************************************************************
 * OBJSTCHG.C - Change object state, with optional redraw.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif 

void obj_stchange(ptree, object, newstate, drawflag,optional_clip)
    register OBJECT *ptree;
    int             object;
    int             newstate;
    int             drawflag;
    GRECT           *optional_clip;
{
    GRECT           *pclip;
    
/*
 * check the newstate value. if the high bit is set, AND the newstate
 * with the current state, else OR them.
 */
 
    if (newstate & 0x8000) {
        newstate &= ptree[object].ob_state;
    }
    else {
        newstate |= ptree[object].ob_state;
    }

/*
 * if the drawflag is set, redraw the object.  
 * if the drawflag says a clipping rectangle was passed, use it, 
 * else use root object as the clipping rectangle for the redraw.
 */

    if (drawflag == OBJ_CLIPDRAW) {
        drawflag = OBJ_WITHDRAW;    // xlate from 2 to 1
        pclip = optional_clip;
    } else {
        pclip = (GRECT *)&ptree->ob_x;
    }
    
    objc_change(ptree, object, 0, *pclip, newstate, drawflag);
    
}

