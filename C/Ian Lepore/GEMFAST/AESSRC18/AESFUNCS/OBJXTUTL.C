/**************************************************************************
 * OBJXTUTL.C - Functions for dealing with extended object types.
 *************************************************************************/

#include "gemfast.h"

/*-------------------------------------------------------------------------
 * obj_xtfind - Return index of object with specified extended object type.
 *-----------------------------------------------------------------------*/

int obj_xtfind(ptree, parent, xtype)
    register OBJECT *ptree;
    register int    parent; 
    register char   xtype;
{
    register int    curobj;

    curobj = ptree[parent].ob_head;
    while(curobj != parent && curobj != -1) {
        if (xtype == *(char *)&(ptree[curobj].ob_type)) { 
            return curobj;
        }
        curobj = ptree[curobj].ob_next; 
    }
    return -1;
}

