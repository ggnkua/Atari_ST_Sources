/**************************************************************************
 * OBJFLCHG.C - Change object options, with optional redraw.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

void obj_flchange(ptree, object, newflags, drawflag, optional_clip)
    register OBJECT *ptree;
    int             object;
    int             newflags;
    int             drawflag;
    GRECT           *optional_clip; // present only if drawflag==OBJ_CLIPDRAW
{
    GRECT           clip_rect;
    
/*
 * check the newflags value. if the high bit is set, AND the newflags
 * with the current options, else OR them.
 */
 
    if (newflags & 0x8000) {
        ptree[object].ob_flags &= newflags;
    }
    else {
        ptree[object].ob_flags |= newflags;
    }

/* 
 * if drawflag is true, we need to do a redraw starting at the changed
 * object's tree root (this is in case the HIDETREE flag is being changed),
 * but the redraw must be clipped by the object we're trying to update.
 * if the drawflag indicates a clipping rectangle was passed, the object's
 * rectangle is clipped to it.
 */

    if (drawflag) {
        obj_clcalc(ptree, object, &clip_rect, NULL);
        if (drawflag == OBJ_CLIPDRAW) {
            rc_intersect(optional_clip, &clip_rect);
        }
        objc_draw(ptree, R_TREE, MAX_DEPTH, clip_rect);
    }
}

