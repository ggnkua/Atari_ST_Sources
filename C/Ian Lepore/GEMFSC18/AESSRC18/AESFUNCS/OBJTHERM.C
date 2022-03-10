/**************************************************************************
 * 
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#define EXTEND_INTERIOR 0x8000

typedef struct {
    XUSERBLK xub;
    int      tick_limit;
    int      tick_count;
    int      tick_width;
    int      curr_width;
    int      full_width;
    int      fill_style;
    int      xoffset;
} ThermoInfo;

static long draw_thermo(pb)
    register XPARMBLK   *pb;
{
    register ThermoInfo *pt = (ThermoInfo *)pb->pub;
    register int         vdi_handle;
    register int         fillwidth;
    VRECT                cliprect;
    VRECT                boxrect;
    GRECT                objrect;

    if (0 == (vdi_handle = apl_vshared())) {
        return 0;
    }
    
    fillwidth = pt->tick_count * pt->tick_width;
    if (fillwidth > pt->full_width) {
        fillwidth = pt->full_width;
    }

    rc_copy(&pb->drawrect, &objrect);
    objrect.g_x += pt->xoffset;
    objrect.g_w  = pt->full_width;
    
    rc_gtov(&objrect, &boxrect);
    rc_vadjust(&boxrect, 1, 1);
    
    if (pt->fill_style & EXTEND_INTERIOR) {
        objrect.g_x += pt->curr_width - 1;
        rc_intersect(&pb->cliprect, &objrect);
        rc_gtov(&objrect, &cliprect);
        vs_clip(vdi_handle, 1, &cliprect);
    } else {
        rc_gtov(&pb->cliprect, &cliprect);
        vs_clip(vdi_handle, 1, &cliprect);
        vsf_interior(vdi_handle, IS_HOLLOW);
        v_bar(vdi_handle, &boxrect);
    }
    
    boxrect.v_x2 = boxrect.v_x1 + fillwidth;

    vsf_interior(vdi_handle, IS_PATTERN);
    vsf_style(vdi_handle, pt->fill_style & 0x0007);
    v_bar(vdi_handle, &boxrect);
    vsf_style(vdi_handle, IP_SOLID);
    vsf_interior(vdi_handle, IS_SOLID);

    vs_clip(vdi_handle, 0, &cliprect);
    
    pt->curr_width = fillwidth;
    
    return 0;

}

int obj_mkthermo(ptree, object, nincr)
    OBJECT          *ptree;
    register int     object;
    register int     nincr;
{
    register int          iwidth;
    register OBJECT      *pobj = &ptree[object];
    register ThermoInfo  *pt;
    
/*-------------------------------------------------------------------------
 * Check for zero increments to prevent div-by-zero errors.
 * Calc the pixel width of one increment.
 * Make sure a VDI workstation is available for later.
 *-----------------------------------------------------------------------*/
    
    if (0 >= nincr) 
        return -1;

    if (0 == (iwidth = pobj->ob_width / nincr))
        return -64;

    if (0 == apl_vshared()) {
        return -35;
    }

/*-------------------------------------------------------------------------
 * If the object has already been made into a G_THERMO extended object,
 * just get its pointer, else make it into such an object.
 *-----------------------------------------------------------------------*/
 
    if ((pobj->ob_type & 0x00FF) == G_USERDEF) {
        pt = (ThermoInfo *)pobj->ob_spec;
        if (pt->xub.ob_type != G_THERMO) {
            return -1;
        }
    } else {
        if (NULL == (pt = apl_malloc((long)sizeof(*pt)))) {
            return -39;
        }
        obj_mxuserder(&pt->xub, pobj, draw_thermo);
        pt->xub.ub_size = sizeof(*pt);
        pt->xub.ob_type = G_THERMO;
    }

/*-------------------------------------------------------------------------
 *-----------------------------------------------------------------------*/
    
    pt->curr_width = 0;
    pt->tick_limit = nincr;
    pt->tick_count = 0;
    pt->tick_width = iwidth;
    pt->full_width = nincr * iwidth;
    pt->xoffset    = (pobj->ob_width - pt->full_width) / 2;
    pt->fill_style = (pt->xub.ob_spec >> 4) & 0x0007;
    
    return 0;
    
}

int obj_udthermo(ptree, object, newpos, pclip)
    OBJECT *ptree;
    int     object;
    int     newpos;
    GRECT  *pclip;
{
    register ThermoInfo *pt = (ThermoInfo *)ptree[object].ob_spec;
    int                 oldpos;
    
    if ((ptree[object].ob_type & 0x00FF) != G_USERDEF
     || pt->xub.ob_type != G_THERMO) {
        return 0;
    }

    oldpos = pt->tick_count;    

    if (newpos == OBJ_TINQUIRE) {
        return oldpos;
    } else if (newpos < 0) {
        newpos = pt->tick_count + 1;
    }
    
    if (newpos > pt->tick_limit) {
        newpos = pt->tick_limit;
    }
    
    if (oldpos == newpos) {
        return oldpos;
    }
    
    pt->tick_count = newpos;

    if (pclip != NULL) {
        if (oldpos < newpos) {
            pt->fill_style |= EXTEND_INTERIOR;
        }
        objc_draw(ptree, object, MAX_DEPTH, *pclip);
        pt->fill_style &= ~EXTEND_INTERIOR;
    }
    
    return oldpos;
}

