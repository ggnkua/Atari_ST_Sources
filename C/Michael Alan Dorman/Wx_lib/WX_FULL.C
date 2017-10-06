#include <wx_lib.h>

/*
 * This function sets the window to its declared full size.
 */
void	wx_full(ws)
Window	*ws;
{
	/*
	 * Set the window.
	 */
	wind_set(ws->hand,WF_CURRXYWH,ws->full.g_x,ws->full.g_y,
			ws->full.g_w,ws->full.g_h);
	/*
	 * Update all our GRECTs.
	 */
	wx_get(ws);
	ws->xpos = ws->minx;
	ws->ypos = ws->miny;
	/*
	 * Re-set our clipping rectangle.
	 */
	wx_setclip(ws);
}
