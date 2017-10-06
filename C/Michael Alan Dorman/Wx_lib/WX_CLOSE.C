#include <wx_lib.h>

/*
 * This function closes and deletes the window that you're working with.
 * I'm thinking about splitting this off into two different functions--
 * one to close it, and one to actually delete it and reinitialize the
 * Window structure.
 *
 * Arguments:	Just a pointer to a valid window structure, though it actually
 *				checks to make sure that it's reasonable to close the window.
 */
void	wx_close(ws)
Window	*ws;
{
	/*
	 * If the window is open and the window handle is greater
	 * than 0 (which implies that it's valid (wonder what it'd do if it
	 * weren't)) then the window needs to be closed first.
	 */
	if ((ws->open != FALSE) && (ws->hand > 0)) {
		/*
		 * Close the window (normal GEM call).
		 */
		wind_close(ws->hand);
		/*
		 * Set the open indicator to false--just to be sure.
		 */
		ws->open = FALSE;
	}
	/*
	 * Actually delete the window from GEM's list of windows (normal GEM call).
	 */
	wind_delete(ws->hand);
	ws->actv = FALSE;
}
