/**************************************************************************
 *
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

void  frm_desktop(options, ptree)
    long             options;
    register OBJECT  *ptree;
{
    register OBJECT  *pobj2;
    int               fill;
    int               color;
    long              ob_spec;

    wind_update(BEG_UPDATE);
    if ((options & FRM_DTREMOVE) || ptree == NULL) {
        wind_set(0, WF_NEWDESK, NULL, 0, 0);
    } else {
        if (options & FRM_CENTER) {
            rc_copy(&gl_rwdesk, &ptree->ob_x); /* copy desk xywh to tree    */
            if (!(ptree->ob_flags & LASTOB)) { /* if there's another object */
                pobj2 = ptree + 1;             /* center it on the screen   */
                pobj2->ob_x = (ptree->ob_width  - pobj2->ob_width)  / 2;
                pobj2->ob_y = (ptree->ob_height - pobj2->ob_height) / 2;
            }
        }
        apl_vshared();                             /* fill in gl_vwout[]  */
        if (gl_vwout[13] == 2) {                   /* monochrome monitor? */
            ob_spec = ptree->ob_spec;              /* if so, and the      */
            fill  = (ob_spec & 0x00000070L) >> 4;  /* desktop is a solid  */
            color = (ob_spec & 0x0000000FL);       /* color, change it to */
            if (fill == 7 && color > 0) {          /* halftone gray.      */
                ptree->ob_spec = (ob_spec & 0xFFFFFF00L) | 0x00000041L;
            }
        }
        wind_set(0, WF_NEWDESK, ptree, 0, 0);
    }
    wind_update(END_UPDATE);
    frmx_dial(FMD_FINISH, NULL, &gl_rwdesk);    /* paint the new desktop */
}
