#include <wx_lib.h>

/*
 * This is one of the workhorse functions, and also one of the ones that'll
 * have to get worked over enourmously in order to make this thing GemFast 1.8-
 * independent.
 *
 * What it does is scroll the interior of the window up a certain number of
 * text "lines".
 *
 * Arguments:	This function takes the Window structure that indicates which
 *				window we're working on.  It also takes the VDI handle of the
 *				workstation that the wx_xxxx functions are supposed to use.  It
 *				also takes the number of lines that it is to scroll.
 */
void	wx_fscroll(ws)
Window	*ws;
{
	/*
	 * This is the array for the function to clear the area of the screen that
	 * is "dirty" (i.e., has lines of text on it that have been scrolled up),
	 * and needs to be "cleaned" by painting over it with a filled rectangle.
	 */
	int		blank[4],
	/*
	 * This is the array that describes the two rectangles that we wish to blit
	 * between.
	 */
			blit[8];
	/*
	 * We need these MFDB's for the blit function.
	 */
	MFDB	src,
			dst;

	/*
	 * Set the array to point to that are of the screen that we want to
	 * preserve--the full width, and the first writable line of text (which
	 * may be different from 0, depending on the setting of the miny variable
	 * in the Window structure) to the height of the window minus the number
	 * of lines we're scrolling.
	 *
	 * 0-3 are the source, 4-7 are the destination.
	 */
	blit[0] = ws->work.g_x;
	blit[1] = ws->work.g_y + (ws->scrl * ws->hchr) + (ws->miny * ws->hchr);
	blit[2] = ws->work.g_x + ws->work.g_w - 1;
	blit[3] = ws->work.g_y + ws->work.g_h - 1;
	blit[4] = blit[0];
	blit[5] = blit[1] - (ws->scrl * ws->hchr);
	blit[6] = blit[2];
	blit[7] = blit[3] - (ws->scrl * ws->hchr);
	/*
	 * If the address of the MFDB is NULL, it points to the screen.
	 */
	src.fd_addr = dst.fd_addr = NULL;
	/*
	 * Set the array to the dimensions of the "dirty" screen area.
	 */
	blank[0] = ws->work.g_x;
	blank[1] = ws->work.g_y + ((ws->maxy - ws->scrl) * ws->hchr);
	blank[2] = ws->work.g_x + ws->work.g_w - 1;
	blank[3] = blank[1] + (ws->scrl * ws->hchr);
	/*
	 * Turn off the mouse.
	 */
	graf_mouse(M_OFF,NULL);
	/*
	 * Do our VDI ops.
	 */
	vro_cpyfm(ws->vdih,3,blit,&src,&dst);
	vr_recfl(ws->vdih,blank);
	/*
	 * Turn the mouse back on.
	 */
	graf_mouse(M_ON,NULL);
	/*
	 * Set the y character position to be correct by decrementing the number of
	 * lines we "scrolled" from it.
	 */
	ws->ypos -= ws->scrl;
}
