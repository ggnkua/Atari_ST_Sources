/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
/*
 * code for doing various user gadget type thingies
 */

#include "xgem.h"
#include "twdefs.h"
#include "twproto.h"

void
g_move()
{
	WINDOW *w;
	int x, y, width, height;
	int buttons, kshift;
	int i;

	w = gl_topwin;
	if (!w) return;

	wind_update(BEG_MCTRL);
	graf_mouse(POINT_HAND, 0L);
	wind_get(w->wi_handle, WF_CURRXYWH, &x, &y, &width, &height);

	evnt_button(1, 1, 1, &x, &y, &buttons, &kshift);

	i = graf_dragbox(width, height, x, y, xdesk, ydesk, wdesk, hdesk,
			 &x, &y);

	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);

	(*w->moved)(w, x, y, width, height);
}

void
g_full()
{
	WINDOW *w;

	w = gl_topwin;
	if (!w) return;

	(*w->fulled)(w);
}

void
g_scroll(which)
	long which;
{
	WINDOW *w;

	w = gl_topwin;
	if (!w) return;

	(*w->arrowed)(w, (int)which);
}

void
g_close()
{
	WINDOW *w;

	w = gl_topwin;
	if (w) {
		(*w->closed)(w);
	}
}
