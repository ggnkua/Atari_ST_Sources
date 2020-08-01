#include "xaes.h"
#include "window.rsh"

GLOBAL OBJECT *WINDTREE = rs_object;

GLOBAL void WInitCustomWindow(void)
{
	WObjFixPosition(WINDTREE);
}