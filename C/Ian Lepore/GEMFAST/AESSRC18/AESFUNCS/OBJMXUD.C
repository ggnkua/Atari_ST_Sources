/**************************************************************************
 * OBJMXUD.C - Turn a normal object into an XUSERDEF object.
 *
 *  Whenever a library routine wants to supply a custom drawing routine
 *  for a standard GEM object, it calls this to fill in an XUSERDEF
 *  and attach it to the original object.  The difference between an
 *  XUSERDEF object and a regular USERDEF object is the contents of the
 *  USERBLK structure attached to the object.  A regular USERBLK contains
 *  a pointer to the drawing routine followed by a longword of anything
 *  the application wants.  For an XUSERBLK, the ap-specific longword is
 *  a pointer to the XUSERBLK itself, and then there are three more fields,
 *  which contain the original ob_type and the original ob_spec, and a
 *  longword of anything the XUSERBLK creator wants.
 *
 *  All this smoke-and-mirrors lets us transform a standard GEM object
 *  into a new custom type without losing the information from the
 *  original object.  Other library routines (rsc_gstrings, for example)
 *  know how to cope with XUSERBLK objects.
 *
 *  Note that we properly cope with INDIRECT objects (as always), and
 *  we preserve any extended type info in the original object; we only
 *  change the low-order byte when plugging in the G_USERDEF ob_type.
 *************************************************************************/

#include "gemfast.h"

void obj_mxuserdef(pblk, pobj, pcode)
    XUSERBLK    *pblk;
    OBJECT      *pobj;
    void        *pcode;
{
    long        *pspec;

    pspec = &pobj->ob_spec;
    if (pobj->ob_flags & INDIRECT) {
        pspec = (long *)*pspec;
    }

    pblk->ub_code  = pcode;
    pblk->ub_self  = pblk;
    pblk->ub_size  = sizeof(XUSERBLK);
    pblk->reserved = (void *)0;

    pblk->ob_type  = pobj->ob_type & 0x00FF;
    pobj->ob_type  = G_USERDEF | (pobj->ob_type & 0xFF00);

    pblk->ob_spec  = *pspec;
    *pspec         = (long)pblk;
}
