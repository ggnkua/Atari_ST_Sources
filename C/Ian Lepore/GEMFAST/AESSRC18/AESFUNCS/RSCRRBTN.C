/**************************************************************************
 * RSCRRBTN.C - The obj_rrbuttons() routine.
 *   This changes the specified objects into rounded-rectangle radio 
 *   buttons (by making them USERDEF objects), and supplies the drawing
 *   routine for the buttons.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

/*-------------------------------------------------------------------------
 * rr_draw - Draw a rounded rectangle radio button.  This routine is
 *           called by the AES whenever a rrbutton needs to be drawn
 *           or to have its state changed.  (Note that this routine
 *           gets control in supervisor mode.  Some runtime libraries
 *           will crash on stack overlow problems if you make calls
 *           to DOS, BIOS, or XBIOS from in here.)
 *
 *           We handle SELECTED and DISABLED states here, but other
 *           states are handled by the AES because we pass the states we
 *           didn't do back to the AES as the retval from this routine.
 *-----------------------------------------------------------------------*/

static long rr_draw(parmblk)
    register XPARMBLK *parmblk;
{
    int     vdi_handle;
    int     xpos;
    int     ypos;
    int     dmy;
    int     len;
    int     objstate;
    VRECT   cliprect;
    VRECT   boxrect;

    if (0 == (vdi_handle = apl_vshared())) {
        return 0;   /* oh well, so sorry */
    }

    objstate = parmblk->currstate;

    rc_gtov(&parmblk->cliprect, &cliprect);
    vs_clip(vdi_handle, 1, &cliprect);
    
    rc_gtov(&parmblk->drawrect, &boxrect);
    rc_vadjust(&boxrect, 1, 1);
    
    len = strlen((char *)parmblk->pub->ob_spec);

    xpos = parmblk->drawrect.g_x + 
                ((parmblk->drawrect.g_w - gl_wchar * len) / 2);
    ypos = parmblk->drawrect.g_y + 
                ((parmblk->drawrect.g_h - gl_hchar) / 2);
    
    if (objstate & SELECTED) {
        v_rfbox(vdi_handle, &boxrect);
        vswr_mode(vdi_handle, MD_TRANS);
        vst_color(vdi_handle, 0);
    } else {
        vsf_interior(vdi_handle, IS_HOLLOW);    
        v_rfbox(vdi_handle, &boxrect);
        vsf_interior(vdi_handle, IS_SOLID);
    }
    
    if (objstate & DISABLED) {
        vst_effect(vdi_handle, 0x0002); /* lightened text */
    }
    vst_alignment(vdi_handle, 0, 5, &dmy, &dmy);
    v_gtext(vdi_handle, xpos, ypos, parmblk->pub->ob_spec);
    vst_alignment(vdi_handle, 0, 0, &dmy, &dmy);
    if (objstate & DISABLED) {
        vst_effect(vdi_handle, 0x0000); /* normal text */
    }
    
    if (objstate & SELECTED) { 
        vst_color(vdi_handle, 1);
        vswr_mode(vdi_handle, MD_REPLACE);
    }
    
    vs_clip(vdi_handle, 0, &cliprect);
    
    return (objstate & ~(SELECTED|DISABLED));
}

/*-------------------------------------------------------------------------
 * rsc_rrbuttons - Transform all radio buttons into rounded radio buttons.
 *-----------------------------------------------------------------------*/

int rsc_rrbuttons(ptree)
    OBJECT           *ptree;
{
    register OBJECT   *pobj;
    register XUSERBLK *pblk;
    register long     *pspec;
    register int       obflags;
    register int       numobj = 0;
    
    if (0 == apl_vshared()) {
        return -35;             /* no more handles */
    }

/*
 * count the number of button objects we'll be transforming...
 */
 
    for (pobj = ptree; ; ++pobj) {
        obflags = pobj->ob_flags;         
        if ((pobj->ob_type & 0x00FF) == G_BUTTON && (obflags & RBUTTON)) {
            ++numobj;
        }
        if (obflags & LASTOB) {         /* stop after doing last    */
            break;                      /* object in the tree.      */
        }
    }

/*
 * allocate a chunk of memory to hold all the XUSERBLKs we're going
 * to attach to the objects.
 */

    if (NULL == (pblk = apl_malloc((long)(numobj * sizeof(*pblk))))) {
        return -39;
    }

/*
 * now go through and change each radio button object into a USERDEF.
 */

    for (pobj = ptree; ; ++pobj) {
        obflags = pobj->ob_flags;         
        if ((pobj->ob_type & 0x00FF) == G_BUTTON && (obflags & RBUTTON)) {
            obj_mxuserdef(pblk++, pobj, rr_draw);
        }
        if (obflags & LASTOB) {         /* stop after doing last    */
            break;                      /* object in the tree.      */
        }
    }

    return 0;
}
