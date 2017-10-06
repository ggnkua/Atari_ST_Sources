#include <wx_lib.h>

/*
 * This is the procedure you need to call before you use anything else related
 * to the wx_lib.  This stores the vdi-handle somewhere convenient (i.e.,
 * somewhere it can't be forgotten), and then sets up the vdi workstation to
 * various defaults that the library requires.
 *
 * This may mean, in the end, that you need to have an entire other workstation
 * for this library (not unlike GemFast 1.8 does).  This may be a disadvantage,
 * and some people may consider it a design flaw, I guess.  It all depends on
 * whether you use the VDI for anything else that might need to circumvent
 * these defaults.
 *
 * Arguments:	The Window structure you're going to be using, and the handle
 *				to a VDI workstation.
 * Returns:		TRUE if successful, FALSE if not.
 */
int		wx_init(ws,vh,wc,hc)
Window	*ws;
int		vh,
		wc,
		hc;
{
	int	junk;

	if (vh > 0) {
		/*
		 * First, store the vdi handle in the vdih member.  So we don't have to
		 * waste lots of time moving it around for the other routines.
		 */
		ws->vdih = vh;
		ws->wchr = wc;
		ws->hchr = hc;
		/*
		 * Set the text alignment the way that we expect it to be.
		 */
		vst_alignment(ws->vdih,0,5,&junk,&junk);
		/*
		 * Set the interior fill pattern to be solid.
		 */
		vsf_interior(ws->vdih,IP_SOLID);
		/*
		 * Set the fill color to be while.
		 */
		vsf_color(ws->vdih,0);
		/*
		 * Set the text color to be black.
		 */
		vst_color(ws->vdih,1);
		return TRUE;
	} else {
		return FALSE;
	}
}
