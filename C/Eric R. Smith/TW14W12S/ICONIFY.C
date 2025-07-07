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
#include "xgem.h"
#include "twdefs.h"
#include "twproto.h"

#define IM_RESERVE	12345
#define IM_RELEASE	12346
#define AP_TERM		50

#define DEF_WIDTH 32
#define DEF_HEIGHT 32

/* set up an iconify request */

static void
make_iconrequest(slot)
	int slot;
{
	static int mbuf[8];
	int id = appl_find ("ICONMGR ");
	int x;

	mbuf[0] = IM_RESERVE;
	mbuf[1] = gl_apid;
	mbuf[2] = 0;
	mbuf[3] = 0;

	if (id < 0) {
		id = gl_apid;	/* send the message to ourselves */
		x = xdesk+slot*(DEF_WIDTH+4);
		if (x + DEF_WIDTH > xdesk + wdesk)
			x = xdesk;
		mbuf[3] = slot;
		mbuf[4] = x;
		mbuf[5] = ydesk+ hdesk - (DEF_HEIGHT+4);
		mbuf[6] = DEF_WIDTH; mbuf[7] = DEF_HEIGHT;
	}

	appl_write (id, 16, mbuf);
}

/* function called when the user asks us to iconify a window */

static WINDOW *iconlock;
static int res_slot;

void
iconify_topwin()
{
	iconify_win(gl_topwin);
}

void
iconify_win(w)
	WINDOW *w;
{
	int slot;

	if (!w || (w->flags & WICONIFIED)) return;
	if (iconlock) return;	/* another window is being iconified */
	iconlock = w;
	if (w->icon_slot >= 0)
		slot = w->icon_slot;
	else
		slot = res_slot++;
	make_iconrequest(slot);
}


void
iconify_message(msgbuff)
	int *msgbuff;
{
	extern void quit();
	WINDOW *w;

	switch(msgbuff[0]) {
	case IM_RESERVE:
		w = iconlock;
		if (w) {
			(*w->iconify)(w, msgbuff[3], msgbuff[4], msgbuff[5],
			                 msgbuff[6], msgbuff[7]);
			iconlock = 0;
		}
		break;
	case IM_RELEASE:
		break;
	case AP_TERM:
		quit();
		break;
	case AC_OPEN:
		ac_open();
		break;
	case AC_CLOSE:
		force_ac_close();
		break;
	}
}
