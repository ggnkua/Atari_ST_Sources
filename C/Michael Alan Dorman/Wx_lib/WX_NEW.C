#include <wx_lib.h>

/*
 * This is a default procedure for initializing the window structure to some
 * defaults that wx_open() will deal with in a consistent and rarely
 * upsetting manner.
 */
void	wx_new(ws)
Window	*ws;
{
	/*
	 * Set the handle variable to 0 - we don't actually have one yet.
	 */
	ws->hand = -1;

	/*
	 * Set the active and open flags to false, because we're not.
	 */
	ws->actv = FALSE;
	ws->open = FALSE;

	/*
	 * Set the type to 0 - the user can supply whatever else they want after
	 * this routine, or they can circumvent this routine altogether - it's
	 * really just for convenience during testing.
	 */
	ws->type = 0;

	/*
	 * Reset the "cursor" position.  This will be used by wx_puts() for
	 * determining where the text string of text should go.
	 */
	ws->xpos = 0;
	ws->ypos = 0;
	ws->minx = 0;
	ws->miny = 0;
	ws->maxx = 0;
	ws->maxy = 0;
	ws->scrl = 1;

	/*
	 * All these GRECTs get initialized to 0s so that wx_open() won't try
	 * to do something stupid with the values that might be there, depending
	 * on whether or not that chunk of memory was cleared before the run.
	 * Again, let me emphasize that this routine is in no way a requirement -
	 * it's just to make life easier for me.  Although, in general, most of
	 * this stuff should remain undefined until after the wx_open() is
	 * performed.
	 */

	/*
	 * Set GRECT curr params to 0
	 */
	ws->curr.g_x = 0;
	ws->curr.g_y = 0;
	ws->curr.g_w = 0;
	ws->curr.g_h = 0;

	/*
	 * Set GRECT work params to 0
	 */
	ws->work.g_x = 0;
	ws->work.g_y = 0;
	ws->work.g_w = 0;
	ws->work.g_h = 0;

	/*
	 * Set GRECT prev params to 0
	 */
	ws->prev.g_x = 0;
	ws->prev.g_y = 0;
	ws->prev.g_w = 0;
	ws->prev.g_h = 0;

	/*
	 * Set GRECT full params to 0
	 */
	ws->full.g_x = 0;
	ws->full.g_y = 0;
	ws->full.g_w = 0;
	ws->full.g_h = 0;
}
