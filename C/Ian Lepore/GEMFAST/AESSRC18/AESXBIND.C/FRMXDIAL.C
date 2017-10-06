/**************************************************************************
 * FRMXDIAL.C -  Extended form_dial() function.
 *************************************************************************/

#include "gemfast.h"
#ifndef NULL
  #define NULL 0L
#endif

int frmx_dial(flag, plittle, pbig)
    int             flag;
    register GRECT  *plittle;
    register GRECT  *pbig;
{
    static GRECT dmyrect = {0,0,0,0};
     
    if (plittle == NULL)
        plittle = &dmyrect;
    
    return form_dial(flag, *plittle, *pbig);
}
