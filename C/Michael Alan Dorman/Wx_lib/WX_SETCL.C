#include <wx_lib.h>

/*
 * This is a simple utility function--it merely sets the wx_lib vdi handle's
 * clipping rectangle to be the interior of the window.
 *
 * Arguments:	Just the Window structure for the window involved.
 */
void	wx_setclip(ws)
Window	*ws;
{
	int	array[4];

	array[0] = ws->work.g_x;
	array[1] = ws->work.g_y;
	array[2] = ws->work.g_x + ws->work.g_w - 1;
	array[3] = ws->work.g_y + ws->work.g_h - 1;
	vs_clip(ws->vdih,TRUE,array);
}
