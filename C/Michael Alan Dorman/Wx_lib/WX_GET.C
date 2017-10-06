#include <wx_lib.h>

/*
 * This routine was lifted pretty much intact from GemFast, for the calling
 * sequence, and then customized to get all the parameters for the window.
 *
 * Arguments:	The Window structure for the window you want operated on.
 */
void	wx_get(ws)
Window	*ws;
{
	/*
	 * Get the parameters to the various GRECTs.
	 */
	wind_get(ws->hand,WF_WORKXYWH,&ws->work.g_x,&ws->work.g_y,
			&ws->work.g_w,&ws->work.g_h);
	wind_get(ws->hand,WF_CURRXYWH,&ws->curr.g_x,&ws->curr.g_y,
			&ws->curr.g_w,&ws->curr.g_h);
	wind_get(ws->hand,WF_PREVXYWH,&ws->prev.g_x,&ws->prev.g_y,
			&ws->prev.g_w,&ws->prev.g_h);
	wind_get(ws->hand,WF_FULLXYWH,&ws->full.g_x,&ws->full.g_y,
			&ws->full.g_w,&ws->full.g_h);
	/*
	 * Put the appropriate values in the appropriate GRECTs
	 */
	ws->maxx = ws->work.g_w / ws->wchr;
	ws->maxy = ws->work.g_h / ws->hchr;
}
