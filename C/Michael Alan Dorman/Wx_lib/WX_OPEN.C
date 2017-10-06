#include <wx_lib.h>

/*
 * This procedure opens a window if the one the application owns isn't
 * actually open.
 */
int		wx_open(ws)
Window	*ws;
{
	/*
	 * If the window isn't marked active, or, if it is, if the window handle
	 * is negative (not a valid option), we're going to have to run the
	 * gamut.
	 */
	if ((ws->open == FALSE) || (ws->hand <= 0)) {

		/*
		 * If the window isn't marked as created, or the window handle is
		 * something impossible to believe.
		 */
		if ((ws->actv == FALSE) || (ws->hand <= 0)) {

			/*
			 * If there's no sensible info for the full size, open to the
			 * desktop dimensions.
			 */
			if ((ws->full.g_w == 0) || (ws->full.g_h == 0)) {
				wind_get(0,WF_WORKXYWH,&ws->full.g_x,&ws->full.g_y,
						&ws->full.g_w,&ws->full.g_h);
			}

			/*
			 * If there's an error opening the window, error out.
			 */
			if ((ws->hand = wind_create(ws->type,ws->full.g_x,ws->full.g_y,
									   ws->full.g_w,ws->full.g_h)) < 0) {
				return FALSE;
			}

			/*
			 * If we got this far, the window has been created, even if it isn't
			 * actually open.  Set the flag.
			 */
			ws->actv = TRUE;
		}

		/*
		 * If there are no sensible parameters for a first size, open to the
		 * window's maximum size.
		 */
		if ((ws->curr.g_w == 0) || (ws->curr.g_h == 0)) {
			ws->curr.g_x = ws->full.g_x;
			ws->curr.g_y = ws->full.g_y;
			ws->curr.g_w = ws->full.g_w;
			ws->curr.g_h = ws->full.g_h;
		}

		/*
		 * Open the window.  If we get an error, delete the window
		 * that we've already created, and return an error condition.
		 */
		if (wind_open(ws->hand,ws->curr.g_x,ws->curr.g_y,
						ws->curr.g_w,ws->curr.g_h) < 0) {
			wind_delete(ws->hand);
			return FALSE;
		}

		/*
		 * Set up all our GRECTs.
		 */
		wx_get(ws);

		/*
		 * Set the flag to indicate that the window has been opened
		 */
		ws->open = TRUE;
		ws->xpos = ws->minx;
		ws->ypos = ws->miny;
		wx_setclip(ws);
	}
	/*
	 * Indicate that we're doing alright.
	 */
	return TRUE;
}
