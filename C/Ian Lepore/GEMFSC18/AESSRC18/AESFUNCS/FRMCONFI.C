/**************************************************************************
 * FRMCONFI.C - The frm_confine() function.
 *************************************************************************/

#include "gemfast.h"

void frm_confine(ptree, boundrect)
    register OBJECT *ptree;
    GRECT           *boundrect;
{
    register GRECT  *prect = (GRECT *)&ptree->ob_x;
    
    if (ptree->ob_state & (OUTLINED|SHADOWED)) {
        rc_gadjust(prect, 4, 4);
    }
    
    rc_confine(boundrect, prect);
    
    if (ptree->ob_state & (OUTLINED|SHADOWED)) {
        rc_gadjust(prect, -4, -4);
    } 
}
