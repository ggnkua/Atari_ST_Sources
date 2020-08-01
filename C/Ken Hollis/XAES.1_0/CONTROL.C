/********************************************************************
 *																1.10*
 *	XAES: Control station											*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	This code was originally taken from the original version of		*
 *	XAES (WinLIB PRO) and was greatly optimized and modified to		*
 *	work with XAES's custom windows and window routines.  This is	*
 *	not the prettiest piece of code, but it works.  Code			*
 *	beautification comes in a later release...  Maybe I can 'borrow'*
 *	some of Christian Grunenberg's routines.						*
 *																	*
 ********************************************************************/

#include <stdio.h>
#include <stddef.h>
#include <time.h>

#include "xaes.h"
#include "nkcc.h"

#ifdef __TURBOC__
#pragma warn -pia
#pragma warn -sus
#endif

/*
 *	This routine returns the WINDOW structure of the window if the
 *	given handle is indeed an XAES window.
 */
GLOBAL WINDOW *WFindHandle(int handle)
{
	WINDOW *ptr = WindowChain;

	while (ptr)
		if (ptr->handle == handle)
			return ptr;
		else
			ptr = ptr->next;

	return (WINDOW *) FALSE;
}

/*
 *	This routine returns the window state of a window.
 */
GLOBAL int WFindState(int window)
{
	WINDOW *ptr = WindowChain;

	while(ptr)
		if (ptr->handle == window)
			return(ptr->state);
		else
			ptr = ptr->next;

	return 0;
}

/*
 *	This is various cruft.  The heart-and-soul of XAES's internal
 *	window and dialog handler.  I could optimize it, but then, why
 *	should I?  It's fast enough as it is.  :-)
 */
GLOBAL int WDoDial(void)
{
	EVENT event;

	Life = TRUE;
	Return = 0;

	event.ev_mbclicks = 0x0102;
	event.ev_bmask = 3;
	event.ev_mbstate = 0;

	while (Life) {
		WINDOW *win;
		int message, hand;
		GRECT old_rect;
		BOOL owner;

		old_rect.g_x = old_rect.g_y = old_rect.g_w = old_rect.g_h = 0;

		event.ev_mflags = MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD;

		if ((win!=NULL) && (win->timer.status != T_NOTEXIST)) {
			long tcount;

			tcount = win->timer.clock - (clock() * 1000 / CLK_TCK);
			
			if (tcount > 0) {
				event.ev_mtlocount = (int) (tcount & 0xffffL);
				event.ev_mthicount = (int) (tcount >> 16);
			} else
				event.ev_mtlocount = event.ev_mthicount = 0;
		} else
			event.ev_mtlocount = event.ev_mthicount = 0;

		message = EvntMulti(&event);

		hand = wind_find(event.ev_mmox, event.ev_mmoy);
		owner = WFindOwner(hand);

		if (owner) {
			win = WFindHandle(hand);
			WMoveWindow(win, -1, -1, -1, -1);
		}

		if ((win->handle != 0) && (message & MU_BUTTON))
			if ((win->state & W_ICONIFIED) && (win->iconify))
				if (objc_find(win->iconify, 0, 99, event.ev_mmox, event.ev_mmoy) == win->icon_num) {
					if (event.ev_mbreturn == 1)
						WDoIconHandle(win);

					if (event.ev_mbreturn == 2)
						WWindSet(win, WF_UNICONIFIED, 1);
				}

		if (win)
			if ((event.ev_mmobutton == 2) && ((win->style & W_CUSTOMWINDOW) || (win->handle == 0))) {
				WDoRightHandle();
				goto exit_kbd;
			}
		else {
		if (message & MU_MESAG)
			switch (event.ev_mmgpbuf[0]) {
				case WM_TOPPED:
					if ((win = WFindHandle(event.ev_mmgpbuf[3])) && (win->state & W_OPEN)) {
						if (win->state & W_BEVENT) {
							int dummy;
							long applrecord[] =	{
													1, 0x010000L,
													0, 16,
													1, 0x100001L
												};
							GRECT rect;

							graf_mkstate(&event.ev_mmox, &event.ev_mmoy, &event.ev_mmobutton, &event.ev_mmokstate);

							if (!event.ev_mmobutton) {
								WMsgWindow(win, event.ev_mmgpbuf);
								break;
							}

							if (event.ev_mmobutton & 1) {
								if (AES_VERSION > 0x0100)
									appl_tplay(applrecord, 3, 100);

								WMoveWindow(win, -1, -1, -1, -1);

								if (win) {
									WWindGet(win, WF_WORKXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
									if (rc_inside(event.ev_mmox, event.ev_mmoy, &rect) && (!win->tree) || (!win->iconify))
										goto button;

									wind_get(win->handle, WF_WORKXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
									if (rc_inside(event.ev_mmox, event.ev_mmoy, &rect) && (
											((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree) && (dummy = objc_find(((win->state & W_ICONIFIED) ? win->iconify : win->tree), 0, 99, event.ev_mmox, event.ev_mmoy)) != -1 &&
												(((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_flags & (SELECTABLE | EXIT) : win->tree[dummy].ob_flags & (SELECTABLE | EXIT)))))
									{
button:									message |= MU_BUTTON;
										event.ev_mbreturn = 1;
									}

									if (win->style & W_CUSTOMWINDOW) {
										dummy = objc_find(win->wind, 0, 99, event.ev_mmox, event.ev_mmoy);

										if (win->wind && dummy != -1 && dummy != 25 && ((event.ev_mbreturn == 1) || (event.ev_mmobutton)))
											WForm_window(win, dummy, event.ev_mbreturn);
									}

									dummy = objc_find((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, event.ev_mmox, event.ev_mmoy);

									if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_flags & TOUCHEXIT : win->tree[dummy].ob_flags & TOUCHEXIT)) {
										int type;

										graf_mkstate(&event.ev_mmox, &event.ev_mmoy, &type, &type);
										dummy = objc_find((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, event.ev_mmox, event.ev_mmoy);

										if (dummy!=-1) {
											int d, button;

											if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_flags & SELECTABLE : win->tree[dummy].ob_flags & SELECTABLE))
												Objc_Change(win, dummy, 0, (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_state | SELECTED : win->tree[dummy].ob_state | SELECTABLE), 1);

											do {
												switch((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_type >> 8 : win->tree[dummy].ob_type >> 8)) {
													case SLIDERLEFT:
													case SLIDERRIGHT:
													case SLIDERUP:
													case SLIDERDOWN:
													case SLIDERTRACK:
														WHandleSlider(win, dummy);
														break;

													case SLIDERSLIDE:
														if (xaes.config1 & X_MOUSESLIDERS) {
															EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_spec.userblk->ub_parm : win->tree[dummy].ob_spec.userblk->ub_parm));

															if (ex->te_slider.slide_type == SLIDER_HOR)
																WGrafMouse(LRSLIDE_MOUSE);
															if (ex->te_slider.slide_type == SLIDER_VER)
																WGrafMouse(UDSLIDE_MOUSE);
														}

														WHandleSlider(win, dummy);
														break;

												}
												graf_mkstate(&d, &d, &button, &d);
/*												WCallDlgDispatcher(win, dummy); */
											} while (button);

											WGrafMouse(ARROW);

											if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_flags & SELECTABLE : win->tree[dummy].ob_flags & SELECTABLE))
												Objc_Change(win, dummy, 0, (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[dummy].ob_state & ~SELECTED : win->tree[dummy].ob_state & ~SELECTED), 1);
										}
									}
								}
							}
							break;
						}

						WMsgWindow(win, event.ev_mmgpbuf);
					}
					break;

				case WM_CLOSED:
					if (win = WFindHandle(event.ev_mmgpbuf[3]))
						WCloseWindow(win, WC_OBJECTABLE, K_ASK);
					break;

				case WM_REDRAW:			/* Handle window messages */
				case WM_NEWTOP:
				case WM_ARROWED:
				case WM_VSLID:
				case WM_SIZED:
				case WM_FULLED:
				case WM_HSLID:
				case WM_MOVED:
				case WM_CREATED:
					if (win = WFindHandle(event.ev_mmgpbuf[3]))
						WMsgWindow(win, event.ev_mmgpbuf);
					break;

				case AP_DRAGDROP:
					if (win = WFindHandle(event.ev_mmgpbuf[3]))
						WMsgWindow(win, event.ev_mmgpbuf);
					else
						WCallEtcDispatcher(event.ev_mmgpbuf);
					break;

				case AC_OPEN:				/* Program/environmental messages */
				case AC_CLOSE:
					switch(event.ev_mmgpbuf[0]) {
						case AC_CLOSE:	if (WCallEtcDispatcher(event.ev_mmgpbuf))
											WKillAllWindows(K_ACC);
										break;

						case AC_OPEN:	WCallEtcDispatcher(event.ev_mmgpbuf);
										break;
					}
					break;

				case MN_SELECTED:		/* Menu messages */
					if (WCallEtcDispatcher(event.ev_mmgpbuf))
						menu_tnormal(wl_menubar, event.ev_mmgpbuf[3], 1);
					break;
			}

		if ((owner) || (message & MU_TIMER)) {
			if (win)
				if (win->timer.status != T_NOTEXIST) {
					WStartTimer(win);
					WCallTmrDispatcher(win);
				} else {
					int mx, my, co, tophandle;

					graf_mkstate(&mx,&my,&co,&co);

					if ((xaes.config1 & X_AUTOCHANGE) && (!(win->state & W_ICONIFIED)) && (win->style & W_CUSTOMWINDOW)) {
						co = objc_find(win->wind, 0, 99, mx, my);
						WChangeMouseElement(win, co);
					} else
						if (xaes.config1 & X_AUTOCHANGE) {
							int ts;

							co = wind_find(mx, my);
							ts = WFindState(co);
							if (((ts & W_ICONIFIED) && (!(ts & W_DESKTOP))) ||
								((!(win->style & W_CUSTOMWINDOW)) && (!(ts & W_DESKTOP)) &&
								(cur_mouse_form != TEXT_CRSR)))
								WGrafMouse(ARROW);
							else if (co == -1)
								WChangeMouseElement(win, co);

							if (ts & W_DESKTOP)
								WGrafMouse(NOWINDOW_MOUSE);
						}

					if (win) {
						WWindGet(win, WF_TOP, &tophandle);

						if ((win->state & W_OPEN) && (win->handle == tophandle) && (win->handle != 0) && (win->edobject) && !rc_inside(mx,my,&old_rect)) {
							co = objc_find((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, mx, my);

							if (co != -1) {
								if (win->style & W_CUSTOMWINDOW)
									if ((win->wind_type == WC_WINDOW) || (win->wind_type == WC_SWINDOW)) {
										old_rect.g_x = win->size.g_x + win->wind[25].ob_x + ((co) ? win->tree[co].ob_x - 1 : 0);
										old_rect.g_y = win->size.g_y + win->wind[25].ob_y + ((co) ? win->tree[co].ob_y - 1 : 0);
									}
								else
									old_rect.g_x = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify->ob_x : win->tree->ob_x) + ((co) ? ((win->state & W_ICONIFIED) ? win->iconify[co].ob_x - 1 : win->tree[co].ob_x - 1) : 0);
									old_rect.g_y = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify->ob_y : win->tree->ob_y) + ((co) ? ((win->state & W_ICONIFIED) ? win->iconify[co].ob_y - 1 : win->tree[co].ob_y - 1) : 0);

								old_rect.g_w = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[co].ob_width + 1 : win->tree[co].ob_width + 1);
								old_rect.g_h = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[co].ob_height + 1 : win->tree[co].ob_height + 1);
	
								if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[co].ob_flags & EDITABLE : win->tree[co].ob_flags & EDITABLE))
									WGrafMouse((helpmode) ? IBARHELP_MOUSE : TEXT_CRSR);
								else
									WGrafMouse((helpmode) ? HELP_MOUSE : ARROW);
							
								}
							}
						}
				}

		if (message & MU_KEYBD) {
			int	n_key, nxtobj, nxtchr;

			win = WindowChain;
			if (win)
			if (!(win->state & W_MINIMIZED)) {
			n_key = nkc_tconv((event.ev_mkreturn & 0xff) | (((long) event.ev_mkreturn & 0xff00) << 8) | ((long) event.ev_mmokstate << 24));

			WMoveWindow(win, -1, -1, -1, -1);

			if ((n_key & NKF_ALT) && (n_key & NKF_CTRL)) {
				switch(n_key & 0xFF) {
					case NK_UP:
					case '8':		if ((((n_key & 0xFF) == '8') && (n_key & NKF_NUM)) || ((n_key & 0xFF) == NK_UP)) {
										int m[8];

										m[0] = WM_ARROWED;
										m[4] = ((n_key & NKF_RSH) || (n_key & NKF_LSH)) ? WA_UPPAGE : WA_UPLINE;

										WMsgWindow(win, m);
									}
									goto exit_kbd;

					case NK_DOWN:
					case '2':		if ((((n_key & 0xFF) == '2') && (n_key & NKF_NUM)) || ((n_key & 0xFF) == NK_DOWN)) {
										int m[8];

										m[0] = WM_ARROWED;
										m[4] = ((n_key & NKF_RSH) || (n_key & NKF_LSH)) ? WA_DNPAGE : WA_DNLINE;

										WMsgWindow(win, m);
									}
									goto exit_kbd;

					case '*':		if ((n_key & NKF_NUM) && (win->handle!=0) && (win->kind & FULLER)) {
										int m[8];

										m[0] = WM_FULLED;
										m[3] = win->handle;

										WMsgWindow(win, m);
									}
									goto exit_kbd;

					case NK_F5:		/*Change3DType(L_MULTITOS);*/
									WRedrawAllWindows();
									goto exit_kbd;

					case NK_F6:		/*Change3DType(L_CUSTOM);*/
									WRedrawAllWindows();
									goto exit_kbd;

					case NK_F7:		if (num_colors>4) {
									/*	Change3DType(L_MOTIF); */
										WRedrawAllWindows();
									} /*else
										WFormCustAlert(3,
														" Motif look ",
														"Sorry, the Motif 3D style look",
														"is  only available  in a color",
														"mode with  more than 4 colors.",
														"Please change mode or resolut-",
														"ions   to    see   the   mode.",
														" ", "Okay", " "); */
									goto exit_kbd;

					case NK_F8:		/*Change3DType(L_GENEVA);*/
									WRedrawAllWindows();
									goto exit_kbd;

					case NK_F9:		/*Change3DType(L_WINLIB);*/
									WRedrawAllWindows();
									goto exit_kbd;

					case NK_F10:	/*Change3DType(L_STANDARD);*/
									WRedrawAllWindows();
									goto exit_kbd;

					case ' ':		WRedrawAllWindows();
									goto exit_kbd;

					case 'Q':
					case 'q':		WDie(FORCE_EXIT);
									goto exit_kbd;

					case NK_ESC:	WCloseWindow(win, WC_OBJECTABLE, K_ASK);
									goto exit_kbd;

					case NK_TAB:	WTopWindow(NULL);
									goto exit_kbd;

					case NK_BS:		WKillAllWindows(K_ASK);
									goto exit_kbd;

/*					case NK_HELP:	CallInternalHelp();
									goto exit_kbd; */

					case NK_ENTER:	{
										int x, y, w, h;

										if (win->handle != 0) {
											WWindGet(win, WF_WORKXYWH, &x, &y, &w, &h);
											WRedrawWindow(win, x, y, w, h);
										}
									}

									goto exit_kbd;
				}
			}

			if (win->state & W_OPEN) {
				nxtobj = 0;

				if (WCallWKeyDispatcher(win, n_key))
					if (WCallKeyDispatcher(n_key))
						if (win->tree)
							if (WForm_keybd(win, event.ev_mkreturn, event.ev_mmokstate, &nxtobj, &nxtchr)) {
								if ((nxtchr) && (win->edobject))
									WObjc_Edit(win, ED_CHAR, event.ev_mkreturn, event.ev_mmokstate);

								if ((nxtobj != win->edobject) && (win->edobject != 0) && (nxtobj != 0)) {
									register char *t;
									register int pos;

									win->edobject = nxtobj;

									t = win->tree[win->edobject].ob_spec.tedinfo->te_ptext;
									t += pos = find_position(win->tree, win->edobject, event.ev_mmox);

									edit_pos(win, pos);
									win->edobject = nxtobj;
								}
							} else {
								if (!(win->tree[nxtobj].ob_flags & RBUTTON)) {
									if (nxtobj != 0)
										Objc_Change(win->tree, nxtobj, 0, win->tree[nxtobj].ob_state ^ SELECTED, 1);
								} else {
									int act = nxtobj, lst, new;
									OBJECT *obptr = win->tree + nxtobj;

									if (!(win->tree[nxtobj].ob_state & SELECTED))
										Objc_Change(win->tree, nxtobj, 0, win->tree[nxtobj].ob_state | SELECTED, 1);

									for(;;) {
										lst = act;
										new = obptr->ob_next;

										for(;;)	{
											act = new;
											obptr = win->tree + act;

											if (obptr->ob_tail == lst) {
												new = obptr->ob_head;
												lst = act;
											} else {
												if (act == nxtobj)
													goto rb_exit;

												if ((obptr->ob_state & SELECTED) && (obptr->ob_flags & RBUTTON)) {
													Objc_Change(win->tree, act, 0, obptr->ob_state ^ SELECTED, 1);
													goto rb_exit;
												} else break;
											}
										}
									}
								}

								if (!(win->tree[nxtobj].ob_flags & RBUTTON || win->tree[nxtobj].ob_type & 0x8000)) {
									int st = win->tree[nxtobj].ob_state;

									st &= ~SELECTED;
									Objc_Change(win->tree, nxtobj, 0, st, 1);
								}

rb_exit:						WCallDlgDispatcher(win, nxtobj);
							}
			} else
				WCallKeyDispatcher(n_key);
			}
		}

exit_kbd:
		if (message & MU_BUTTON) {
			int nxtobj, tophandle;

			if (wind_find(event.ev_mmox, event.ev_mmoy) == 0) {
				int endx, endy;

				WGraf_Rubberbox(event.ev_mmox, event.ev_mmoy, &endx, &endy);
			}

			if (win)
			if (!(win->state & W_MINIMIZED)) {
			if (!(win = WFindHandle(wind_find(event.ev_mmox, event.ev_mmoy))))
				win = WindowChain;

			if (win->style & W_CUSTOMWINDOW)
				nxtobj = objc_find(win->wind, 0, 99, event.ev_mmox, event.ev_mmoy);

			WMoveWindow(win, -1, -1, -1, -1);

			if (win->wind && win->handle != 0 && nxtobj != -1 && nxtobj != 25 && ((event.ev_mbreturn == 1) || (event.ev_mmobutton)) && (win->style & W_CUSTOMWINDOW)) {
				EXTINFO *ex = (EXTINFO *)(win->wind[nxtobj].ob_spec.userblk->ub_parm);

				if (ex->te_routines.mouse_down)
					ex->te_routines.mouse_down(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, nxtobj);

				WForm_window(win, nxtobj, event.ev_mbreturn);

				if (ex->te_routines.mouse_up)
					ex->te_routines.mouse_up(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, nxtobj);
			} else if (win->handle != 0) {
				WWindGet(win, WF_TOP, &tophandle);

				if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree) && (nxtobj = objc_find(((win->state & W_ICONIFIED) ? win->iconify : win->tree), 0, 99, event.ev_mmox, event.ev_mmoy)) != -1 && event.ev_mbreturn==1)
					if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_flags & (SELECTABLE | EDITABLE) : win->tree[nxtobj].ob_flags & (SELECTABLE | EDITABLE))) {
						int oldobj;

						if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_type & 0xFF : win->tree[nxtobj].ob_type & 0xFF)) == G_USERDEF) {
							EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_spec.userblk->ub_parm : win->tree[nxtobj].ob_spec.userblk->ub_parm));

							if (ex->te_routines.mouse_down)
								ex->te_routines.mouse_down(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, nxtobj);
						}

						oldobj = nxtobj;
						WForm_button(win, nxtobj, event.ev_mbreturn, &nxtobj);

						if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[oldobj].ob_type & 0xFF : win->tree[oldobj].ob_type & 0xFF)) == G_USERDEF) {
							EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[oldobj].ob_spec.userblk->ub_parm : win->tree[oldobj].ob_spec.userblk->ub_parm));

							if (ex->te_routines.mouse_up)
								ex->te_routines.mouse_up(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, oldobj);
						}

						if ((win->tree[nxtobj].ob_flags & EDITABLE) && nxtobj != win->edobject)
							if (win->handle == tophandle) {
								register char *t;
								register int pos;

								WObjc_Edit(win, ED_END, 0, 0);
								win->edobject = nxtobj;

								t = win->tree[win->edobject].ob_spec.tedinfo->te_ptext;
								t += pos = find_position(win->tree, win->edobject, event.ev_mmox);

								edit_pos(win, pos);
								win->edobject = nxtobj;
							} else
								win->edobject = nxtobj;

						if (win->tree[nxtobj].ob_flags & EDITABLE)
							if (win->handle == tophandle) {
								register char *t = win->tree[win->edobject].ob_spec.tedinfo->te_ptext;
								register int pos;

								t += pos = find_position(win->tree, win->edobject, event.ev_mmox);

								edit_pos(win, pos);
								win->edobject = nxtobj;
							} else win->edobject = nxtobj;

						if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_flags & SELECTABLE : win->tree[nxtobj].ob_flags & SELECTABLE)
							&& !((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_flags & RBUTTON : win->tree[nxtobj].ob_flags & RBUTTON) ||
								 (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_type & 0x8000 : win->tree[nxtobj].ob_type & 0x8000))) {
								int st = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_state : win->tree[nxtobj].ob_state);

								st &= ~SELECTED;
								Objc_Change(win, nxtobj, 0, st, 1);
							}

						if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_flags & EXIT : win->tree[nxtobj].ob_flags & EXIT))
							WCallDlgDispatcher(win, nxtobj);
					} else
						if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_flags & TOUCHEXIT : win->tree[nxtobj].ob_flags & TOUCHEXIT)) {
							int dummy, button;

							if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_type & 0xFF : win->tree[nxtobj].ob_type & 0xFF)) == G_USERDEF) {
								EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_spec.userblk->ub_parm : win->tree[nxtobj].ob_spec.userblk->ub_parm));

								if (ex->te_routines.mouse_down)
									ex->te_routines.mouse_down(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, nxtobj);
							}

							Objc_Change(win, nxtobj, 0, (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_state | SELECTED : win->tree[nxtobj].ob_state | SELECTED), 1);

							do {
								switch((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_type >> 8 : win->tree[nxtobj].ob_type >> 8)) {
									case SLIDERLEFT:
									case SLIDERRIGHT:
									case SLIDERUP:
									case SLIDERDOWN:
									case SLIDERTRACK:
										WHandleSlider(win, nxtobj);
										break;

									case SLIDERSLIDE:
										if (xaes.config1 & X_MOUSESLIDERS) {
											EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_spec.userblk->ub_parm : win->tree[nxtobj].ob_spec.userblk->ub_parm));

											if (ex->te_slider.slide_type == SLIDER_HOR)
												WGrafMouse(LRSLIDE_MOUSE);
											if (ex->te_slider.slide_type == SLIDER_VER)
												WGrafMouse(UDSLIDE_MOUSE);
										}

										WHandleSlider(win, nxtobj);
										break;
								}
								graf_mkstate(&dummy, &dummy, &button, &dummy);
								WCallDlgDispatcher(win, nxtobj);
							} while (button == 1);

							WGrafMouse(ARROW);

							Objc_Change(win, nxtobj, 0, (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_state & ~SELECTED : win->tree[nxtobj].ob_state & ~SELECTED), 1);

							if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_type & 0xFF : win->tree[nxtobj].ob_type & 0xFF)) == G_USERDEF) {
								EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[nxtobj].ob_spec.userblk->ub_parm : win->tree[nxtobj].ob_spec.userblk->ub_parm));

								if (ex->te_routines.mouse_up)
									ex->te_routines.mouse_up(event.ev_mmox, event.ev_mmoy, event.ev_mbreturn, event.ev_mmokstate, nxtobj);
							}
						}
				else
					WCallBtnDispatcher(win, event.ev_mmox, event.ev_mmoy, event.ev_mmobutton, event.ev_mmokstate, event.ev_mbreturn);
			}
			}
		}
		}
	}
	}

	return Return;
}
