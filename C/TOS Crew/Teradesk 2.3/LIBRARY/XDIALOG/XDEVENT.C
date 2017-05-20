/*
 * Xdialog Library. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifdef __PUREC__
 #include <np_aes.h>
 #include <tos.h>
 #include <vdi.h>
#else
 #include <aesbind.h>
 #include <osbind.h>
 #include <vdibind.h>
#endif

#include <ctype.h>
#include <stddef.h>

#include "xdialog.h"
#include "internal.h"

#define AV_SENDKEY		0x4710

/* Funktie voor het converteren van een VDI scancode  naar een
   eigen scancode. */

int xe_keycode(int scancode, int kstate)
{
	int keycode, nkstate, scan;

	/* Zet key state om in eigen formaat */

	nkstate = (kstate & 3) ? XD_SHIFT : 0;
	nkstate = nkstate | ((kstate & 0xC) << 7);

	/* Bepaal scancode */

	scan = ((unsigned int) scancode & 0xFF00) >> 8;

	/* Controleer of de scancode hoort bij een ASCII teken */

	if ((scan < 59) || (scan == 74) || (scan == 78) || (scan == 83) ||
		(scan == 96) || ((scan >= 99) && (scan <= 114)) || (scan >= 117))
	{
		if (scan >= 120)
			scan -= 118;

		if ((keycode = scancode & 0xFF) == 0)
		{
#ifdef __PUREC__
			keycode = toupper((int) ((unsigned char) (Keytbl((void *) -1, (void *) -1, (void *) -1)->unshift[scan])));
#else
			keycode = toupper((int) ((unsigned char) (((char *) ((_KEYTAB *) Keytbl((void *) -1, (void *) -1, (void *) -1))->unshift)[scan])));
#endif
		}
		keycode |= nkstate;
	}
	else
	{
		nkstate |= XD_SCANCODE;
		keycode = nkstate | scan;
	}

	return keycode;
}

/* Vervanging van evnt_multi, die eigen keycode terug levert. */

int xe_xmulti(XDEVENT *events)
{
	int r;
	static int level = 0;
	int old_mtlocount, old_mflags;

	level++;

	old_mtlocount = events->ev_mtlocount;
	old_mflags = events->ev_mflags;

	/* Check if the time out time is shorter than the minimum time.
	   If true set to the minimum time. */

	if ((events->ev_mthicount == 0) && (events->ev_mtlocount < xd_min_timer))
		events->ev_mtlocount = xd_min_timer;

	/* No message events when a dialog is opened and the dialog is
	   not in a window. */

	if (xd_dialogs && (xd_dialogs->dialmode != XD_WINDOW))
		events->ev_mflags &= ~MU_MESAG;

#ifdef __PUREC__
	EvntMulti((EVENT *) events);
#else
	events->ev_mwhich = evnt_multi(events->ev_mflags, events->ev_mbclicks,
		events->ev_mbmask, events->ev_mbstate, events->ev_mm1flags,
		events->ev_mm1.g_x, events->ev_mm1.g_y, events->ev_mm1.g_w,
		events->ev_mm1.g_h, events->ev_mm2flags, events->ev_mm2.g_x,
		events->ev_mm2.g_y, events->ev_mm2.g_w, events->ev_mm2.g_h, events->ev_mmgpbuf,
		(((unsigned long) events->ev_mthicount) << 16) | (unsigned long) events->ev_mtlocount,
		&events->ev_mmox, &events->ev_mmoy, &events->ev_mmobutton,
		&events->ev_mmokstate, &events->ev_mkreturn, &events->ev_mbreturn);
#endif

	if (((r = events->ev_mwhich) & MU_MESAG) && (events->ev_mmgpbuf[0] == AV_SENDKEY))
	{
		events->ev_mkreturn = events->ev_mmgpbuf[4];
		events->ev_mmokstate = events->ev_mmgpbuf[3];

		r &= ~MU_MESAG;
		r |= MU_KEYBD;
	}

	if (r & MU_KEYBD)
	{
		events->xd_keycode = xe_keycode(events->ev_mkreturn, events->ev_mmokstate);

		if (!xd_dialogs && (level == 1))
		{
			if (xw_hndlkey(events->xd_keycode,events->ev_mmokstate) == TRUE)
				r &= ~MU_KEYBD;
		}
	}

	if (r & MU_MESAG)
	{
		if ((events->ev_mmgpbuf[0] == MN_SELECTED) && xd_dialogs)
		{
			if (xd_menu != NULL)
				menu_tnormal(xd_menu, events->ev_mmgpbuf[3], 1);
			r &= ~MU_MESAG;
		}
		else if ((events->ev_mmgpbuf[0] == WM_CLOSED) && xd_dialogs)
		{
			if (xw_hfind(events->ev_mmgpbuf[3]) != xd_dialogs->window)
			{
				Bconout(2, 7);
				xw_set(xd_dialogs->window, WF_TOP);
			}
			r &= ~MU_MESAG;
		}
		else if (((events->ev_mmgpbuf[0] == WM_TOPPED) ||
				 (events->ev_mmgpbuf[0] == WM_NEWTOP)) &&
				 xd_dialogs)
		{
			if (xw_hfind(events->ev_mmgpbuf[3]) != xd_dialogs->window)
				Bconout(2, 7);
			xw_set(xd_dialogs->window, WF_TOP);
			r &= ~MU_MESAG;
		}
		else if (xw_hndlmessage(events->ev_mmgpbuf) == TRUE)
			r &= ~MU_MESAG;
	}

	if ((r & MU_BUTTON) && !xd_dialogs && (level == 1))
	{
		if (events->ev_mmobutton == 2)
			events->ev_mbreturn = 2;				/* HR 151102: right button is double click */
		if (xw_hndlbutton(events->ev_mmox, events->ev_mmoy,
						  events->ev_mbreturn, events->ev_mmobutton,
						  events->ev_mmokstate) == TRUE)
			r &= ~MU_BUTTON;
	}

	events->ev_mflags = old_mflags;
	events->ev_mtlocount = old_mtlocount;
	events->ev_mwhich = r;

	level--;

	return r;
}

/*
 * Bepaal de huidige toestand van de muis buttons.
 */

int xe_button_state(void)
{
	int dummy, mstate;

	graf_mkstate(&dummy, &dummy, &mstate, &dummy);

	return mstate;
}

/*
 * Funktie voor het wachten op een bepaald muis event.
 *
 * Parameters:
 *
 * mstate	- toestand muisknoppen waarop het muis event moet plaatsvinden,
 * x		- huidige x coordinaat muis,
 * y		- huidige y coordinaat muis,
 * kstate	- toestand SHIFT, CONTROL en ALTERNATE toetsen.
 *
 * Resultaat : TRUE als het event heeft plaatsgevonden, FALSE als het
 *			   event niet is opgetreden.
 */

int xe_mouse_event(int mstate, int *x, int *y, int *kstate)
{
	XDEVENT events;
	int flags;

	events.ev_mflags = MU_TIMER | MU_BUTTON;
	events.ev_mbclicks = 2;
	events.ev_mbmask = 1;
	events.ev_mbstate = mstate;
	events.ev_mm1flags = 0;
	events.ev_mm2flags = 0;
	events.ev_mtlocount = 0;
	events.ev_mthicount = 0;

	flags = xe_xmulti(&events);

	*x = events.ev_mmox;
	*y = events.ev_mmoy;
	*kstate = events.ev_mmokstate;

	return (flags & MU_BUTTON) ? TRUE : FALSE;
}
