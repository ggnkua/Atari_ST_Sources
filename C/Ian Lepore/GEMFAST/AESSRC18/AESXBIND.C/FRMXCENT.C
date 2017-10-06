/**************************************************************************
 * FRMXCENT.C -  Extended form_center() function.
 *************************************************************************/

#include "gemfast.h"

int frmx_center(ptree, prect)
  OBJECT          *ptree;
  register GRECT  *prect;
{
  return form_center(ptree,&prect->g_x,&prect->g_y,&prect->g_w,&prect->g_h);
}
