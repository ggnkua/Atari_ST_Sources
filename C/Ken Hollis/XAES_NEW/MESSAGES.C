/********************************************************************
 *																1.00*
 *	XAES: Handle all messages (boy is this fun!)					*
 *	Code by Ken Hollis, Bug checking by Sascha Blank				*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	This is the message control module.  This routine controls the	*
 *	powerhouse of the most common messages.  I will add compat-		*
 *	ibility for other desktops, but not at this time...				*
 *																	*
 ********************************************************************/

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include "xaes.h"

GLOBAL void WMsgWindow(WINDOW *win, int msg_buf[8])
{
	int tophandle;

	if (win) {
		WMoveWindow(win, -1, -1, -1, -1);

		switch (msg_buf[0]) {
			GRECT *realrect, temp, work;
			int pxyarray[4];
			BOOL ret;

			case WM_REDRAW:		WWindGet(win, WF_TOP, &tophandle);
								if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
									WObjc_Edit(win, ED_END, 0, 0);
									win->edit_disp = FALSE;
								}

								realrect = (GRECT *) (msg_buf + 4);		/* nasty */
								WMoveWindow(win, -1, -1, -1, -1);

								if (rc_intersect(realrect, &desk)) {
									wind_get(win->handle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);

								if (rc_intersect(realrect, &work))
									if (msg_buf[7] > 0 && WCallWndDispatcher(win, msg_buf))
										if ((win->wind) || (win->tree) || (win->iconify))
											WUpdateWindow(win, msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7], 0);
										else {
											wind_update(BEG_UPDATE);
											graf_mouse(M_OFF, NULL);

											vsf_interior(VDIhandle, FIS_SOLID);
											vswr_mode(VDIhandle, MD_REPLACE);
											vsf_color(VDIhandle, 0);

											wind_get(win->handle, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
											while (temp.g_w && temp.g_h) {
												if (rc_intersect(&temp, realrect)) {
													pxyarray[0] = temp.g_x;
													pxyarray[1] = temp.g_y;
													pxyarray[2] = temp.g_x + temp.g_w - 1;
													pxyarray[3] = temp.g_y + temp.g_h - 1;

													v_bar(VDIhandle, pxyarray);
												}
												wind_get(win->handle, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
											}

											graf_mouse(M_ON, NULL);
											wind_update(END_UPDATE);
										}
							}

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}

							msg_buf[0] = WM_PAINT;
							msg_buf[1] = Ap_ID;
							msg_buf[3] = win->handle;

							WMsgWindow(win, msg_buf);

						break;

		case WM_CLOSED:	
							if (WCallWndDispatcher(win, msg_buf)) {	
								WCruelCloseWindow(win, FALSE);

								unfix_object(win->tree);
								unfix_object(win->iconify);

								WKillWindow(win);
							}

						break;

		case WM_KILL:	WCallWndDispatcher(win, msg_buf);

						if (win->state & W_OPEN)				/* Close window if it isn't already closed */
							WCruelCloseWindow(win, FALSE);

						free(win->WndDispatcher);
						wind_delete(win->handle);				/* Delete window for good */

						owned_winds[win->handle].handle = win->handle;
						owned_winds[win->handle].owner  = W_NOTOWNER;

						if (win->prev)							/* Remove window from chain */
							win->prev->next = win->next;
						win->next->prev = win->prev;

						if (WindowChain == win)					/* Make sure WindowChain doesn't point to the removed window */
							WindowChain = win->next;

						free(win);								/* And free memory */

						break;

		case WM_NEWTOP:	
							WWindGet(win, WF_TOP, &tophandle);
							WCallWndDispatcher(win, msg_buf);
						break;

		case WM_ONTOP:	
							WWindGet(win, WF_TOP, &tophandle);
							WCallWndDispatcher(win, msg_buf);
						break;

		case WM_CREATED:WWindGet(win, WF_TOP, &tophandle);
						WCallWndDispatcher(win, msg_buf);
						break;

		case WM_COPIED:	WWindGet(win, WF_TOP, &tophandle);
						WCallWndDispatcher(win, msg_buf);
						break;

		case WM_PAINT:	WCallWndDispatcher(win, msg_buf);
						break;

		case WM_UNTOPPED:
							WCallWndDispatcher(win, msg_buf);
						break;

		case WM_ARROWED:
							WWindGet(win, WF_TOP, &tophandle);

							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							WCallWndDispatcher(win, msg_buf);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case WM_VSLID:	
							WWindGet(win, WF_TOP, &tophandle);

							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							WCallWndDispatcher(win, msg_buf);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case WM_HSLID:	
							WWindGet(win, WF_TOP, &tophandle);
							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							WCallWndDispatcher(win, msg_buf);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case WM_SIZED:	
							WWindGet(win, WF_TOP, &tophandle);
							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							if (WCallWndDispatcher(win, msg_buf))
								WMoveWindow(win, -1, -1, msg_buf[6], msg_buf[7]);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case WM_MOVED:	
							if (WCallWndDispatcher(win, msg_buf))
								if ((win->state & W_ICONIFIED) && (win->iconify))
									WMoveWindow(win, msg_buf[4], msg_buf[5], win->iconify->ob_width, win->iconify->ob_height);
								else
									WMoveWindow(win, msg_buf[4], msg_buf[5], -1, -1);

						break;

		case WM_TOPPED:	
							WWindGet(win, WF_TOP, &tophandle);
							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							if (WindowChain != win && ! (win->state & W_UNUNTOPPABLE) && WindowChain->state & W_UNUNTOPPABLE) {
								win = WindowChain;
								msg_buf[3] = win->handle;
							}

							if (WCallWndDispatcher(win, msg_buf))
								WTopWindow(win);

							WMoveWindow(win, -1, -1, -1, -1);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case WM_FULLED:	
							WWindGet(win, WF_TOP, &tophandle);
							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							if (WCallWndDispatcher(win, msg_buf)) {
								int x, y, w, h;

								WWindGet(win, WF_CURRXYWH, &x, &y, &w, &h);
								if (x == desk.g_x && y == desk.g_y && w == desk.g_w && h == desk.g_h)
									WWindGet(win, WF_PREVXYWH, &x, &y, &w, &h);
								else {
									x = desk.g_x;
									y = desk.g_y;
									w = desk.g_w;
									h = desk.g_h;
								}

								WMoveWindow(win, x, y, w, h);
							}

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;

		case AP_DRAGDROP:
							WWindGet(win, WF_TOP, &tophandle);
							if (win->edobject && win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_END, 0, 0);
								win->edit_disp = FALSE;
							}

							if (WCallWndDispatcher(win, msg_buf)) 
								WCallEtcDispatcher(msg_buf);

							if (win->edobject && !win->edit_disp && win->handle == tophandle && !(win->state & W_MINIMIZED)) {
								WObjc_Edit(win, ED_INIT, 0, 0);
								win->edit_disp = TRUE;
							}
						break;
		}
	}
}

GLOBAL int WFindOwner(int handle)
{
	if ((owned_winds[handle].owner == Ap_ID) && (owned_winds[handle].owner != W_NOTOWNER))
		return TRUE;
	else if (handle == 0)
		return TRUE;

	return FALSE;
}