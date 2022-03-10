/**************************************************************************
 * OBJOXYWH.C - Return GRECT data from object.
 *************************************************************************/

#include "gemfast.h"

/*-------------------------------------------------------------------------
 * obj_xywh - Return object's GRECT, not adjusted to screen coordinates.
 *-----------------------------------------------------------------------*/

void obj_xywh(ptree, object, prect)
    register OBJECT  *ptree;
    int               object;
    register GRECT   *prect; /* really a pointer to a grect */
{
    ptree = &ptree[object];
    prect->g_x = ptree->ob_x;
    prect->g_y = ptree->ob_y;
    prect->g_w = ptree->ob_width;
    prect->g_h = ptree->ob_height;
}

/*-------------------------------------------------------------------------
 * obj_offxywh - Return object's GRECT, adjusted to screen coordinates.
 *-----------------------------------------------------------------------*/

void obj_offxywh(ptree, object, prect)
    register OBJECT  *ptree;
    int               object;
    register GRECT   *prect;
{
    obj_xywh(ptree, object, prect);
    objc_offset(ptree, object, &prect->g_x, &prect->g_y);
}


