/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
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

#include <np_aes.h>			/* HR 151102: modern */
#include <stddef.h>
#include <vdi.h>

#include <boolean.h>
#include <xdialog.h>

#include "desk.h"
#include "events.h"
#include <xscncode.h> /* DjV 033 010203 */
#include "error.h"    /* DjV 033 010203 */
#include "desktop.h"  /* DjV 033 010203 */


static int event(int evflags, int mstate, int *key)
{
	XDEVENT events;
	int result;

	events.ev_mflags = MU_TIMER | evflags;
	events.ev_mbclicks = 2;
	events.ev_mbmask = 1;
	events.ev_mbstate = mstate;
	events.ev_mm1flags = 0;
	events.ev_mm2flags = 0;
	events.ev_mtlocount = 0;
	events.ev_mthicount = 0;

	do
	{
		if ((result = xe_xmulti(&events)) & MU_MESAG)
		{
			if (hndlmessage(events.ev_mmgpbuf) != 0)
				return -1;
		}
	} while (!(result == MU_TIMER) && !(result & ~(MU_MESAG | MU_TIMER)));

	*key = events.xd_keycode;

	return result;
}

/*
 * Check if there is a key pressed.
 *
 * Parameters:
 *
 * key		- pressed key.
 * hndl_msg	- handle message events
 *
 * Result	: 0 if there is no key pressed
 *			  1 if there is a key pressed
 *			 -1 if a message is received which terminates the program
 */

int key_state(int *key, boolean hndl_msg)
{
	int result;

	result = event( (hndl_msg ? (MU_KEYBD | MU_MESAG) : MU_KEYBD), 0, key);

	if (result == -1)
	{
		if (hndl_msg)
			return -1;
		else
			return 0;
	}
	else if (result & MU_KEYBD)
		return 1;
	else
		return 0;
}

void clr_key_buf(void)
{
	int dummy;

	while (key_state(&dummy, FALSE) > 0);
}

void wait_button(void)
{
	while (xe_button_state());
}

/*
 * Handle all messages still in the message buffer.
 *
 * Result	: 0 OK
 *			 -1 if a message is received which terminates the program
 */

int clr_msg_buf(void)
{
	int dummy;

	if (event(MU_MESAG, 0, &dummy) < 0)
		return -1;
	else
		return 0;
}

/* DjV 033 010203 ---vvv--- */
/*
 * This is a routine for confirmation of an abort caused
 * by pressing [ESC] during multiple copy, delete, print, etc.
 * An alert is posted with a text "Abort current operation? 
 */

boolean escape_abort( boolean hndl_msg )
{
	int key, r;

	if ((r = key_state(&key, hndl_msg)) > 0)
	{
		if (key == ESCAPE)
			if ( alert_printf(2, ABOOP) == 1 )
				return TRUE;
	}
	else if (r < 0)
		return TRUE;
	
	return FALSE;

} 
/* DjV 033 010203 ---^^^--- */
