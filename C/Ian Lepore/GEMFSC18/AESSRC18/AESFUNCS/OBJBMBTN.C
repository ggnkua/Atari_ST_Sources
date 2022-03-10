/**************************************************************************
 * OBJBMBTN.C - The obj_bmbuttons() function.
 *************************************************************************/

#include "gemfast.h"

int obj_bmbuttons(ptree, parent, selstate, newbits)
    register OBJECT *ptree;
    register int    parent;
    register int    selstate;
    register int    newbits;
{
    register OBJECT *pobj;
    register int    state;
    register int    xtype;
    register int    oldbits = 0;
    register int    curobj  = ptree[parent].ob_head;
    
    while(curobj != parent && curobj != -1) {
        pobj  = &ptree[curobj];
        xtype = pobj->ob_type >> 8;
        state = pobj->ob_state;
        if (state & selstate) {
            oldbits |= xtype;
        }
        if (newbits != OBJ_BMINQUIRE) {
            pobj->ob_state = (newbits & xtype) ? 
                                (state | selstate) : (state & ~selstate);
        }
        curobj = ptree[curobj].ob_next;
    }
    return oldbits;
}
