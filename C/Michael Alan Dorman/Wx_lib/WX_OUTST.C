#include <wx_lib.h>

void	wx_outstr(ws,sp)
Window	*ws;
char	*sp;
{
	int		array[4],
			xpixel,
			ypixel;

	/*
	 * If we're on the last line, scroll the window display
	 */
	if (ws->ypos >= ws->maxy) {
		wx_fscroll(ws);
	}

	/*
	 * Compute our actual position based on the offset into the bitmap (based
	 * on the work positions) plus our character positions times their
	 * extents.
	 */
	xpixel = ws->work.g_x + (ws->xpos * ws->wchr);
	ypixel = ws->work.g_y + (ws->ypos * ws->hchr);

	/*
	 * Write the text
	 */
	graf_mouse(M_OFF,NULL);
	v_gtext(ws->vdih,xpixel,ypixel,sp);

	/*
	 * Clear to EOL.
	 * The upper left corner is the end of the string v. the y value of the
	 * string position.
	 */
	array[0] = xpixel + (strlen(sp) * ws->wchr);
	array[1] = ypixel;
	array[2] = ws->work.g_x + ws->work.g_w - 1;
	array[3] = ypixel + ws->hchr;
	vr_recfl(ws->vdih,array);
	graf_mouse(M_ON,NULL);

	/*
	 * Move the cursor to the end of the string.
	 */
	ws->xpos += strlen(sp);
}
