/********************************************************************
 *																0.10*
 *	XAES: Timer module												*
 *																	*
 *	Copyright (c) 1994, Bitgate Software							*
 *																	*
 *	Although I have the idea of how to create a cooperative task	*
 *	switching multitasking timer event, I have not done it yet.		*
 *	It's going to be a complicated design, and this will be a task	*
 *	in itself.  For now, it uses timing based on the 200HZ timer.	*
 *																	*
 ********************************************************************/

#include <time.h>

#include "xaes.h"

#ifdef __TURBOC__
#pragma warn -pia
#endif

#ifndef __TIMER__
#define __TIMER__
#endif

/*
 *	Start timer (ticks based on 200HZ timer)
 */
GLOBAL void WStartTimer(WINDOW *win)
{
	if (win) {
		win->timer.clock = clock() * 1000 / CLK_TCK + win->timer.ev_mtcount;
		win->timer.status = TRUE;

		WCallTMDDispatcher(win, T_RUNNING);
	}
}

/*
 *	Stop timer
 */
GLOBAL void WStopTimer(WINDOW *win)
{
	if (win) {
		win->timer.status = FALSE;

		WCallTMDDispatcher(win, T_STOPPED);
	}
}

/*
 *	Register new timer
 *
 *	status = status of timer
 *	ev_tcount = counter time in milliseconds
 *	TmrDispatcher = timer dispatcher
 *	user = pointer to user defined structure
 */
GLOBAL void WCreateTimer(WINDOW *win, int status, long ev_tcount, void *user)
{
	if (win) {
		win->timer.ev_mtcount = ev_tcount;
		win->timer.user = user;

		if (status)
			WStartTimer(win);
		else
			WStopTimer(win);
	}
}

GLOBAL BOOL WCheckTimersOpen(void)
{
	WINDOW *win = WindowChain;

	while(win->next) {
		win = win->next;
		if (win->timer.status != T_NOTEXIST)
			return TRUE;
	}

	return FALSE;
}