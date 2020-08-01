/********************************************************************
 *																1.20*
 *	XAES: Dispatcher calling routines								*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	These were also WinLIB PRO's original dispatch routines.  I		*
 *	added quite a few extra routines to this module.				*
 *																	*
 ********************************************************************/

#include "xaes.h"

void *_MainDispatcher;
void *_MainKeyDispatcher;

LOCAL int WCallWndDispatcherSub(WINDOW *win, int msg_buf[], int Dispatcher(WINDOW *, int[]))
{
	if ((Dispatcher = win->WndDispatcher) && (win->handle > 0))
		return Dispatcher(win, msg_buf) ? FALSE : TRUE;

	return TRUE;
}

GLOBAL int WCallWndDispatcher(WINDOW *win, int msg_buf[])
{ return WCallWndDispatcherSub(win, msg_buf, WCallWndDispatcher); }

GLOBAL int WCallDlgDispatcher(WINDOW *win, int message)
{
	int msg_buf[8] = {WM_DIALOG, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & W_DIALOG) {
			msg_buf[3] = message;
			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallWKeyDispatcher(WINDOW *win, int key)
{
	int msg_buf[8] = {WM_KEYBD, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & (W_DIALOG|W_TEXT|W_TIMER|W_FLYING)) {
			msg_buf[3] = key;
			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallBtnDispatcher(WINDOW *win, int mx, int my, int button, int kstate, int bclicks)
{
	int msg_buf[8] = {WM_BUTTON, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & (W_DIALOG|W_TEXT|W_TIMER|W_FLYING)) {
			msg_buf[3] = mx;
			msg_buf[4] = my;
			msg_buf[5] = button;
			msg_buf[6] = kstate;
			msg_buf[7] = bclicks;
			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallTxtDispatcher(WINDOW *win, int message)
{
	int msg_buf[8] = {WM_TEXT, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & W_TEXT) {
			msg_buf[3] = message;
			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallFKeyDispatcher(WINDOW *win, int fkeynum)
{
	int msg_buf[8] = {WM_FKEY, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		msg_buf[3] = fkeynum;
		return WCallWndDispatcher(win, msg_buf);
	} else
		return FALSE;
}

GLOBAL int WCallHelpDispatcher(WINDOW *win)
{
	int msg_buf[8] = {WM_HELP, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & (W_DIALOG|W_TEXT|W_TIMER|W_FLYING)) {
			if (win->state & (W_DIALOG|W_FLYING))
				msg_buf[3] = 1;

			if (win->state & (W_TEXT|W_TIMER))
				msg_buf[3] = 2;

			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallUndoDispatcher(WINDOW *win)
{
	int msg_buf[8] = {WM_UNDO, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & (W_DIALOG|W_TEXT|W_TIMER|W_FLYING)) {
			if (win->state & (W_DIALOG|W_FLYING))
				msg_buf[3] = 1;

			if (win->state & (W_TEXT|W_TIMER))
				msg_buf[3] = 2;

			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallHotkeyDispatcher(WINDOW *win, int key, int objnum)
{
	int msg_buf[8] = {WM_HOTKEY, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & W_DIALOG) {
			msg_buf[3] = key;
			msg_buf[4] = objnum;
			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallTmrDispatcher(WINDOW *win)
{ 
	int msg_buf[8] = {WM_TIMER, 0, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & W_TIMER) {
			msg_buf[3] = win->handle;

			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallTMDDispatcher(WINDOW *win, int mode)
{
	int msg_buf[8] = {WM_TIMECHG, 0, 0, 0, 0, 0, 0};

	if (win) {
		if (win->state & W_TIMER) {
			msg_buf[3] = win->handle;
			msg_buf[4] = mode;

			return WCallWndDispatcher(win, msg_buf);
		}

		return TRUE;
	} else
		return FALSE;
}

GLOBAL int WCallBHelpDispatcher(WINDOW *win, int button)
{
	int msg_buf[8] = {WM_GETHELP, 0, 0, 0, 0, 0, 0};

	helpmode = FALSE;
	WGrafMouse(ARROW);

	if (win)
		if (win->state & W_DIALOG) {
			msg_buf[3] = win->handle;
			msg_buf[4] = button;

			return WCallWndDispatcher(win, msg_buf);
		}
	else
		return FALSE;

	return FALSE;
}

GLOBAL int WCallSliderDispatcher(WINDOW *win, int object, int pos, int lastpos)
{
	int msg_buf[8] = {WM_SLIDER, 0, 0, 0, 0, 0, 0};

	helpmode = FALSE;

	if (win)
		if (win->state & W_DIALOG) {
			msg_buf[3] = object;
			msg_buf[4] = pos;
			msg_buf[5] = lastpos;

			return WCallWndDispatcher(win, msg_buf);
		}
	else
		return FALSE;

	return FALSE;
}

LOCAL int WCallEtcDispatcherSub(int msg_buf[], int Dispatcher(int[]))
{
	if (Dispatcher = _MainDispatcher)
		return Dispatcher(msg_buf) ? FALSE : TRUE;

	return TRUE;
}

GLOBAL int WCallEtcDispatcher(int msg_buf[])
{ return WCallEtcDispatcherSub(msg_buf, WCallEtcDispatcher); }

LOCAL int WCallKeyDispatcherSub(int key, int Dispatcher(int))
{
	if (Dispatcher = _MainKeyDispatcher)
		return Dispatcher(key) ? FALSE : TRUE;

	return TRUE;
}

GLOBAL int WCallKeyDispatcher(int key)
{ return WCallKeyDispatcherSub(key, WCallKeyDispatcher); }
