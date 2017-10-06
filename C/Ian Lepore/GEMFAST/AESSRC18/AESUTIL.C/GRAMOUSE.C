/**************************************************************************
 * AESFAST PD utilties.
 *
 * For C compatibility, we use regular AES functions, not line-a.
 *
 *   gra_qonmouse
 *   gra_qofmouse
 *   gra_qmstate
 *************************************************************************/

#include "gemfast.h"

void gra_qonmouse()
{
    graf_mouse(M_ON, 0L);
}

void gra_qofmouse()
{
    graf_mouse(M_OFF, 0L);
}

void gra_qmstate(px, py, pb)
    int *px, *py, *pb;
{
    int dmy;
    graf_mkstate(px, py, pb, &dmy);
}
