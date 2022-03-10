/**************************************************************************
 * GRFXDRAG.C - Extended graf_dragbox() function.
 *************************************************************************/

#include "gemfast.h"
#ifndef NULL
  #define NULL 0L
#endif

int grfx_dragbox(startrect, boundrect, endrect)
    register GRECT *startrect;
    register GRECT *boundrect;
    register GRECT *endrect;
{
    if (boundrect == NULL) {
        boundrect = &gl_rwdesk;
    }

    endrect->g_w = startrect->g_w;
    endrect->g_h = startrect->g_h;

    return graf_dragbox(startrect->g_w, startrect->g_h,
                        startrect->g_x, startrect->g_y,
                        boundrect->g_x, boundrect->g_y,
                        boundrect->g_w, boundrect->g_h,
                        &endrect->g_x,  &endrect->g_y);
                          
}
