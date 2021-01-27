/**************************************************************************
 * AESFAST PD utilties.
 *
 * For C compatibility, we use regular AES functions, not line-a.
 *
 *   gra_qonmouse
 *   gra_qofmouse
 *   gra_qmstate
 *************************************************************************/

#include "gemf.h"

int grf_mouse( int shape, void *pform);

void gra_qonmouse(void)
{
	graf_mouse(M_ON, 0L);
}

void gra_qofmouse(void)
{
	graf_mouse(M_OFF, 0L);
}

void gra_qmstate(int *px, int *py, int *pb)
{
	int dmy;
	graf_mkstate(px, py, pb, &dmy);
}
