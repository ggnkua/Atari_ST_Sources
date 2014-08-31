/*
 * demo.c as of 02/14/97
 *
 * (c) 1995-97 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de),
 * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Sourcecode to demonstrate the use and the possibilities of the
 * color-icon- and resource-routines found in the files drawcicn.[ch],
 * convert.s and new_rsc.[ch].
 *
 * Permission is granted to spread this sourcecode, but only together
 * with all additional files, see manual.ger/eng for details!
 *
 * I can't be held responsible for the correct function of this program,
 * nor for any damage that occurs after the correct or incorrect use of
 * it. USE IT AT YOUR OWN RISK!
 *
 * If you find any bugs or have suggestions, please contact me!
 *
 * History:
 * 08/16/95: Creation
 * 08/17/95: Added comments and rescaling of the demo-dialog so that
 *           the button will always be on the same position relative
 *           to the icon.
 * 08/20/95: Adjusted the inquiry of the icon height to the new
 *           layout of the DRAW_CICON-structure
 * 08/26/95: Improved detection of ob_type (the upper byte is
 *           filtered)
 * 02/14/97: Adapted for compilation with Lattice C
 */

/*
 * new_rsc.h includes all other stuff we need, i.e. aes.h, vdi.h and
 * portab.h
 */
#include "new_rsc.h"
#include "demo.h"

WORD main(void)
{
	WORD		x, y, w, h,
				du,
				ch;
	OBJECT		*dial;
	DRAW_CICON	*cicon;
	ICONBLK		*micon;

/*
 * Initialise the program and get the height of one char of the AES'
 * system-font
 */
	if (appl_init() < 0)
		return(1);
	graf_mouse(ARROW, 0L);
	graf_handle(&du, &ch, &du, &du);
/*
 * Try to load the resource-file with the new call rsc_load, which is
 * used exactly like rsrc_load. rsc_load is able to load extended
 * resource-files (i.e. those with color-icons) and automatically
 * converts the color-icons into USERDEFs so that they will be
 * displayed independend of the OS-version.
 */
	if (rsc_load("demo.rsc"))
	{
/*
 * To get the addresses of structures in the resource, you have to
 * call rsc_gaddr instead of rsrc_gaddr. The use is exactly the same.
 */
		rsc_gaddr(R_TREE, DEMO_DIALOG, &dial);
/*
 * If you want to get information about an object that was a color-
 * icon in the original file, you must look at its current type,
 * which is either G_USERDEF (color-icon was successfully converted)
 * or G_ICON (in this case, the icon could just be transformed into
 * a simple icon). ub_parm of the G_USERDEF's ob_spec points to a
 * DRAW_CICON-structure (see drawcicn.h for details), which contains
 * the original icon's CICONBLK. The following code uses this to
 * determine the height in pixels of the icon.
 */
		if ((dial[DEMO_ICON].ob_type & 0xff) == G_USERDEF)
		{
#ifdef LATTICE
			cicon = (DRAW_CICON *)((USERBLK *)
				dial[DEMO_ICON].ob_spec)->ub_parm;
#else
			cicon = (DRAW_CICON *)dial[DEMO_ICON].ob_spec.userblk
				->ub_parm;
#endif
			h = cicon->original->monoblk.ib_hicon;
		}
		else
		{
#ifdef LATTICE
			micon = (ICONBLK *)dial[DEMO_ICON].ob_spec;
#else
			micon = dial[DEMO_ICON].ob_spec.iconblk;
#endif
			h = micon->ib_hicon;
		}
/*
 * Set the ob_height of the icon to its real height, so that it's not
 * influenced by the current character-height. Also, calculate the
 * new position (i.e. ob_y) of the button, so that it's always
 * located beneath the icon, independend of the current char-height.
 */
		dial[DEMO_ICON].ob_height = h;
		h = (h + ch - 1) / ch;
		h = dial[DEMO_ICON].ob_y + h * ch + 3 * ch;
		dial[0].ob_height = h;
		dial[DEMO_BUTTON].ob_y = h - 2 * ch;
/* Prepare, draw and use the dialog */
		form_center(dial, &x, &y, &w, &h);
		wind_update(BEG_UPDATE);
		form_dial(FMD_START, x, y, w, h, x, y, w, h);
		objc_draw(dial, 0, MAX_DEPTH, x, y, w, h);
		form_do(dial, 0);
		form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);
		wind_update(END_UPDATE);
/*
 * Do not forget to call rsc_free once a call to rsc_load was
 * successful, or you'll waste memory. Keep it mind that you can't
 * use the structures of the resource any more once you've called
 * rsc_free!
 */
		rsc_free();
	}
	else
	{
/*
 * When rsc_load returns 0, something went wrong. That could mean
 * there's not enough memory or the file is not a valid resource-
 * file, but the most common case is that the file wasn't found,
 * so we display a suitable alert-box.
 */
		form_alert(1, "[3][Resource-file demo.rsc|not found!]"
			"[ Cancel ]");
		appl_exit();
		return(1);
	}
	appl_exit();
	return(0);
}

/* EOF */
