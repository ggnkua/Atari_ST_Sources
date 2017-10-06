/**************************************************************************
 * RSCCUBTN.C - The rsc_cubuttons() routine.
 *   This changes the specified objects into CUA-style selection & radio
 *   buttons (by making them USERDEF objects), and supplies the drawing
 *   routine for the buttons.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

typedef struct {
    int wchar;
    int hchar;
    int outer_radius;
    int inner_radius;
    int text_xoffs;
    int text_yoffs;
    int circle_xoffs;
    int circle_yoffs;
    int box_xoffs;
    int box_yoffs;
    int box_xsize;
    int box_ysize;
} PreCalcs;

static PreCalcs precalcs;

/*-------------------------------------------------------------------------
 * init_precalcs - Fill in the precalculated values structure.
 *-----------------------------------------------------------------------*/

static void init_precalcs()
{
    register PreCalcs  *pc      = &precalcs;
    register int        wchar   = gl_wchar;
    register int        hchar   = gl_hchar;
    register int        h8      = hchar / 8;
    register int        aspectx = gl_vwout[3];
    register int        aspecty = gl_vwout[4];

    pc->wchar        = wchar;
    pc->hchar        = hchar;
    
    pc->text_xoffs   = wchar * 3;               
    pc->text_yoffs   = 0;
    
    pc->box_ysize    = hchar - h8;
    pc->box_xsize    = (pc->box_ysize * aspecty) / aspectx; 
    pc->box_xoffs    = 1;
    pc->box_yoffs    = 0;
    
    pc->outer_radius = ((hchar * aspecty) / aspectx) / 2;
    pc->inner_radius = pc->outer_radius / 2;    
    pc->circle_xoffs = pc->outer_radius + pc->box_xoffs;
    pc->circle_yoffs = (hchar / 2) - h8;     
    
}

/*-------------------------------------------------------------------------
 * cua_draw - Draw a CUA-style button.  This routine is called by
 *            the AES whenever a CUA-style button needs to be drawn
 *            or to have its state changed.  (Note that this routine
 *            gets control in supervisor mode.  Some runtime libraries
 *            will crash on stack overlow problems if you make calls
 *            to DOS, BIOS, or XBIOS from in here.)
 *
 *            We handle SELECTED, CROSSED, OUTLINED, and DISABLED states
 *            here, but other states are handled by the AES because we
 *            pass the states we didn't do back to the AES as the return
 *            value from this routine.
 *-----------------------------------------------------------------------*/

static long cua_draw(parmblk)
    register XPARMBLK  *parmblk;
{
    register PreCalcs  *pc = &precalcs;
    int                 dmy;
    register int        xpos;
    register int        ypos;
    register int        vdi_handle;
    register int        objstate;
    VRECT               boxrect;
    VRECT               cliprect;

    if (0 == (vdi_handle = apl_vshared())) {
        return 0;   /* oh well, so sorry */
    }

    objstate = parmblk->currstate;

    rc_gtov(&parmblk->cliprect, &cliprect);
    vs_clip(vdi_handle, 1, &cliprect);
    vsf_interior(vdi_handle, IS_HOLLOW);

    xpos = parmblk->drawrect.g_x;
    ypos = parmblk->drawrect.g_y + ((parmblk->drawrect.g_h - pc->hchar) / 2);

    if (objstate & DISABLED) {
        vst_effect(vdi_handle, 0x0002);
    }
    vst_alignment(vdi_handle, 0, 5, &dmy, &dmy);
    v_gtext(vdi_handle, (xpos + pc->text_xoffs), (ypos + pc->text_yoffs),
            parmblk->pub->ob_spec);
    vst_alignment(vdi_handle, 0, 0, &dmy, &dmy);
    if (objstate & DISABLED) {
        vst_effect(vdi_handle, 0x0000);
    }

    if (parmblk->ptree[parmblk->obj].ob_flags & RBUTTON) {
        xpos += pc->circle_xoffs;
        ypos += pc->circle_yoffs;
        v_circle(vdi_handle, xpos, ypos, pc->outer_radius);
        if (objstate & (SELECTED|CROSSED)) {
            vsf_interior(vdi_handle, IS_SOLID);
            v_circle(vdi_handle, xpos, ypos, pc->inner_radius);
            vsf_interior(vdi_handle, IS_HOLLOW);
        }
    } else {
        boxrect.v_x1 = xpos + pc->box_xoffs;
        boxrect.v_y1 = ypos + pc->box_yoffs;
        boxrect.v_x2 = boxrect.v_x1 + pc->box_xsize;
        boxrect.v_y2 = boxrect.v_y1 + pc->box_ysize;
        v_bar(vdi_handle, &boxrect);
        if (objstate & (SELECTED|CROSSED)) {
            register int temp;
            v_pline(vdi_handle, 2, &boxrect);
            temp         = boxrect.v_x1;
            boxrect.v_x1 = boxrect.v_x2;
            boxrect.v_x2 = temp;
            v_pline(vdi_handle, 2, &boxrect);
        }
    }

    if (objstate & OUTLINED) {
        rc_gtov(&parmblk->drawrect, &boxrect);
        rc_vadjust(&boxrect, 3, 3);
        vswr_mode(vdi_handle, MD_TRANS);
        v_bar(vdi_handle, &boxrect);
        vswr_mode(vdi_handle, MD_REPLACE);
    }
    
    vsf_interior(vdi_handle, IS_SOLID);
    vs_clip(vdi_handle, 0, &cliprect);
    
    return (objstate & ~(SELECTED|DISABLED|OUTLINED|CROSSED));
}

/*-------------------------------------------------------------------------
 * rsc_cubuttons - Transform all non-exit buttons in a tree to CUA-style.
 *-----------------------------------------------------------------------*/

int rsc_cubuttons(ptree)
    OBJECT            *ptree;
{ 
    register OBJECT   *pobj;
    register XUSERBLK *pblk;
    register long     *pspec;
    register int       obflags;
    register int       numobj = 0;

/*
 * do setup stuff...
 */
 
    if (0 == apl_vshared()) {   /* force open shared workstation, also  */
        return -35;             /* tests to make sure one is available. */
    }

    if (precalcs.outer_radius == 0) {   /* this must follow apl_vshared() */
        init_precalcs();
    }

/*
 * count the number of button objects we'll be transforming...
 */
 
    for (pobj = ptree; ; ++pobj) {
        obflags = pobj->ob_flags;         
        if ((pobj->ob_type & 0x00FF) == G_BUTTON
         && !(obflags & (EXIT|DEFAULT))) {
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
 * now go through and change each non-exit button object into a USERDEF.
 */

    for (pobj = ptree; ; ++pobj) {
        obflags = pobj->ob_flags;         
        if ((pobj->ob_type & 0x00FF) == G_BUTTON
         && !(obflags & (EXIT|DEFAULT))) {
            obj_mxuserdef(pblk++, pobj, cua_draw);
        }
        if (obflags & LASTOB) {         /* stop after doing last    */
            break;                      /* object in the tree.      */
        }
    }

    return 0;
}

