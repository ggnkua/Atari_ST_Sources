#include <wx_lib.h>

void	wx_move(ws,x,y)
Window	*ws;
int		x,
		y;
{
	ws->curr.g_x = x;
	ws->curr.g_y = y;
	wind_set(ws->hand,WF_CURRXYWH,ws->curr.g_x,ws->curr.g_y,
			ws->curr.g_w,ws->curr.g_h);
	wx_get(ws);
	ws->xpos = ws->minx;
	ws->ypos = ws->miny;
	wx_setclip(ws);
}
