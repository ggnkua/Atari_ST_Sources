#include <wx_lib.h>

/*
 * Free the VDI workstation that the wx_lib functions have been using (it
 * might only be stored in the structure.
 */
void	wx_free(ws)
Window	*ws;
{
	v_clsvwk(ws->vdih);
}

