/**************************************************************************
 * OBJRBUTL.C - Functions for working with radio buttons.
 *************************************************************************/

#include "gemfast.h"

/*-------------------------------------------------------------------------
 * obj_rbfind - Extended radio button finder.
 *-----------------------------------------------------------------------*/
 
int obj_rbfind(tree, parent, rbstate)
    register OBJECT *tree;
    register int    parent;
    register int    rbstate;
{
    register int    kid;
    register OBJECT *pobj;

    kid = tree[parent].ob_head;

    while ( (kid != parent) && (kid >= R_TREE) ) {
        pobj = &tree[kid];
        if ((pobj->ob_flags & RBUTTON) && (pobj->ob_state & rbstate)) {
            return kid;
        }
        kid = pobj->ob_next;
    }
    return NO_OBJECT;
}

/*-------------------------------------------------------------------------
 * obj_parent - Find the parent of a given child object.
 *-----------------------------------------------------------------------*/
 
int obj_parent(tree, curobj)
    register OBJECT *tree;
    register int    curobj;
{
    register int    nxtobj;
                 
    if (curobj == R_TREE)    /* The root of a tree has no parent */
        return R_TREE;

    for (;;) {
        nxtobj = tree[curobj].ob_next;
        if (tree[nxtobj].ob_tail == curobj)
            return nxtobj;
        curobj = nxtobj;
    }
}

/*-------------------------------------------------------------------------
 * obj_rbselect - Set a radio button to SELECTED, de-sel others in the group.
 *-----------------------------------------------------------------------*/

int obj_rbselect(ptree, selobj, state)
    register OBJECT *ptree;
    register int    selobj;
    register int    state;
{
    register int    oldobj;

    if (selobj <= R_TREE) {
        return NO_OBJECT;
    }

    oldobj = obj_rbfind(ptree, obj_parent(ptree, selobj), state);
    if (oldobj != NO_OBJECT) {
        ptree[oldobj].ob_state &= ~state;
    }
    ptree[selobj].ob_state |= state;
    return oldobj;
}

