#include <wx_lib.h>

/*
 * This is a simple utility function to keep a little orthagonality--it just
 * sets the window's type.  You can do it by hand, but it looks better if it's
 * function based.
 */
void	wx_settype(ws,t)
Window	*ws;
int		t;
{
	ws->type = t;
}
