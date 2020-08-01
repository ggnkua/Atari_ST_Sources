/********************************************************************
 *																1.00*
 *	XAES: Active redrawing of windows and elements					*
 *	By Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	These routines are 100% WinX compatible.  AES has a really hard	*
 *	time keeping up with the correct redraw tables.  Unfortunately,	*
 *	I have not yet put these routines in to counter its problem.	*
 *	Wait for a later release for this problem to be cleared.		*
 *																	*
 ********************************************************************/

#include "xaes.h"

#ifdef __TURBOC__
#pragma warn -pia
#pragma warn -sus
#endif

/*
 *	Handle the active redrawing of a window.  These are for custom
 *	windows only.  Yes, these too could be optimized, but I don't
 *	have the time to sit down and optimize them right now.  ^_^
 */
void WHandleActiveDrag(WINDOW *win)
{
	int initialx, initialy, lx, ly, button, d;
	EVENT event;

	graf_mkstate(&initialx, &initialy, &button, &d);

	initialx -= win->size.g_x;
	initialy -= win->size.g_y;
	lx = ly = 0;

	event.ev_mbclicks = 0x0001;
	event.ev_bmask = event.ev_mbstate = 1;

	do {
		int message;

		event.ev_mflags = MU_MESAG | MU_BUTTON | MU_TIMER;
		event.ev_mtlocount = event.ev_mthicount = 0;

		message = EvntMulti(&event);
		graf_mkstate(&d, &d, &button, &d);

		if (message & MU_MESAG) {
			WINDOW *tempwin;

			switch(*event.ev_mmgpbuf) {
				case WM_REDRAW:			/* Handle window messages */
					if (tempwin = WFindHandle(event.ev_mmgpbuf[3]))
						WMsgWindow(tempwin, event.ev_mmgpbuf);

					WMoveWindow(win, -1, -1, -1, -1);
					break;
			}
		}

		if ((event.ev_mmox != lx) || (event.ev_mmoy != ly)) {
			lx = event.ev_mmox;
			ly = event.ev_mmoy;

			if ((event.ev_mmoy - initialy) < desk.g_y)
				WMoveWindow(win, (event.ev_mmox - initialx),
						desk.g_y, win->size.g_w,
						win->size.g_h);
			else
				WMoveWindow(win, (event.ev_mmox - initialx),
						(event.ev_mmoy - initialy), win->size.g_w,
						win->size.g_h);
		}
	} while(button);
}