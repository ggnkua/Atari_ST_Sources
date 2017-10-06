#include <wx_lib.h>

void	wx_size(ws,w,h)
Window	*ws;
int		w,
		h;
{
	ws->curr.g_w = w;
	ws->curr.g_h = h;
	wind_set(ws->hand,WF_CURRXYWH,ws->curr.g_x,ws->curr.g_y,
			ws->curr.g_w,ws->curr.g_h);
	wx_get(ws);
	ws->xpos = ws->minx;
	ws->ypos = ws->miny;
	wx_setclip(ws);
}
