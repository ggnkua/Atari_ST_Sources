/**************************************************************************
 * OBJCLCAL.C - Calc clipping rectangle(s) for object in a tree.
 *************************************************************************/

#include "gemfast.h"
#ifndef NULL
  #define NULL 0L
#endif

int obj_clcalc(ptree, object, pgrect, pvrect)
    register OBJECT *ptree;
    int              object;
    GRECT           *pgrect;
    VRECT           *pvrect;
{
    int              adjust;
    long             ob_spec;
    int              ob_type;
    int              ob_flags;
    GRECT            workrect;

    obj_offxywh(ptree, object, &workrect);  /* get basic placement/sizes */

    ptree    = &ptree[object];              /* registerize/precalc some  */
    ob_type  = ptree->ob_type & 0x00FF;     /* miscellanious things we   */
    ob_flags = ptree->ob_flags;             /* us a lot below.           */
    ob_spec  = ptree->ob_spec;

    if (ob_flags & INDIRECT) {              /* if INDIRECT flag is set,  */
        ob_spec = *(long *)ob_spec;         /* go get the real ob_spec.  */
    }

    if (ob_type == G_USERDEF) {
        register XUSERBLK *pxub = (XUSERBLK *)ob_spec;
        if (pxub->ub_self == pxub) {
            ob_type = pxub->ob_type;
            ob_spec = pxub->ob_spec;
        }
    }

    /*
     * deal with objects that can have graphics that extend outside
     * their ob_width/ob_height values...
     */

    switch (ob_type) {
      case G_BOXTEXT:
      case G_FBOXTEXT:
        adjust = ((TEDINFO*)ob_spec)->te_thickness;
        break;
      case G_BOX:
      case G_IBOX:
      case G_BOXCHAR:
        adjust = (int)((char)(ob_spec >> 16));
        break;
      case G_BUTTON:
        adjust = -1;
        if (ob_flags & EXIT)
            --adjust;
        if (ob_flags & DEFAULT)
            --adjust;
        break;
      default:
        adjust = 0;
        break;
    }

    if (adjust > 0) {       /* if adjust value is positive, object has    */
        adjust = 0;         /* "inner width" and no adjustment is needed. */
    } else {                /* negative value implies outer width, invert */
        adjust = -adjust;   /* it to a positive number for rc_gadjust().  */
    }

    if (ptree->ob_state & (OUTLINED|SHADOWED)) { /* SHADOWED and OUTLINED */
        adjust = 4;                              /* get fixed adjustment. */
    }

    rc_gadjust(&workrect, adjust, adjust);       /* apply adjustment      */

    if (pgrect != NULL) {                        /* if caller wants GRECT,*/
        *pgrect = workrect;                      /* copy results to it.   */
    }

    if (pvrect != NULL) {                        /* if caller wants VRECT,*/
        rc_gtov(&workrect, pvrect);              /* convert results to it.*/
    }

    return adjust;
}

