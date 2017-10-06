#include <wx_lib.h>

/*
 * This routine will clear the interior of the window described by the Window
 * structure ws, by painting a filled rectangle of color 0 over the work space.
 * If there's a better (i.e., faster) way to do this, please let me know.
 *
 * Arguments:	A pointer to the Window structure representing the window we're
 *				working on.
 */
void	wx_clear(ws)
Window	*ws;
{
	/*
	 * This is the array into which we put the coordinates (upper left and
	 * lower right) for the rectangle.
	 */
	int     array[4];

	/*
	 * Put the appropriate values in the VDI array.
	 */
	array[0] = ws->work.g_x;
	array[1] = ws->work.g_y;
	/*
	 * For the lower-right corner, subtract one to make up for the fact that
	 * the width is figured from 1, rather than 0.
	 */
	array[2] = ws->work.g_x + ws->work.g_w - 1;
	array[3] = ws->work.g_y + ws->work.g_h - 1;
	/*
	 * Turn off the mouse, so it won't get written over.
	 */
	graf_mouse(M_OFF,NULL);
	/*
	 * Draw the filled rectangle (is there a faster way to do this?  Malloc a
	 * chunk of memory, bzero it and blit it to the screen?  Must check).
	 */
	vr_recfl(ws->vdih,array);
	/*
	 * Turn the mouse back on, so people can use it.
	 */
	graf_mouse(M_ON,NULL);
}
