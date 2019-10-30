/********************************************************************
 *																0.50*
 *	XAES: Custom window handling									*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Well, at least it's half-way done.  I still need to get the		*
 *	small-window elements working decently.  Hell, I've still got	*
 *	to add them!													*
 *																	*
 ********************************************************************/

#include <string.h>
#include <stddef.h>
#include "xaes.h"

#define W_ULSIZE 1   /* BOX dans l'arbre WINDOW */
#define W_PCLOSE 2   /* BOX dans l'arbre WINDOW */
#define W_CLOSER 3   /* BOXTEXT dans l'arbre WINDOW */
#define W_TSIZE  4   /* BOX dans l'arbre WINDOW */
#define W_URSIZE 5   /* BOX dans l'arbre WINDOW */
#define W_PCASC  6   /* BOX dans l'arbre WINDOW */
#define W_FULLER 7   /* BOXTEXT dans l'arbre WINDOW */
#define W_LSIZE  8   /* BOX dans l'arbre WINDOW */
#define W_RSIZE  9   /* BOX dans l'arbre WINDOW */
#define W_LLSIZE 10  /* BOX dans l'arbre WINDOW */
#define W_PSLLT  11  /* BOX dans l'arbre WINDOW */
#define W_SLLT   12  /* BOXTEXT dans l'arbre WINDOW */
#define W_BSIZE  13  /* BOX dans l'arbre WINDOW */
#define W_LRSIZE 14  /* BOX dans l'arbre WINDOW */
#define W_PSLDN  15  /* BOX dans l'arbre WINDOW */
#define W_SLDN   16  /* BOXTEXT dans l'arbre WINDOW */
#define W_MOVER  17  /* BOXTEXT dans l'arbre WINDOW */
#define W_CASCADE 18  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU   19  /* BOX dans l'arbre WINDOW */
#define W_MENU_L 20  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU_R 21  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO   22  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO_R 24  /* BOXTEXT dans l'arbre WINDOW */ /* SWITCHED */
#define W_INFO_L 23  /* BOXTEXT dans l'arbre WINDOW */ /* SWITCHED */
#define WORKAREA 25  /* BOXTEXT dans l'arbre WINDOW */
#define W_SLUP   26  /* BOXTEXT dans l'arbre WINDOW */
#define W_VERTRK 27  /* BOX dans l'arbre WINDOW */
#define W_VERSL  28  /* BOX dans l'arbre WINDOW */
#define W_HORTRK 29  /* BOX dans l'arbre WINDOW */
#define W_HORSL  30  /* BOX dans l'arbre WINDOW */
#define W_SLRT   31  /* BOXTEXT dans l'arbre WINDOW */
#define W_OPTION 32  /* BOXTEXT dans l'arbre WINDOW */

#define S_ULSIZE 1   /* BOX dans l'arbre WINDSM */
#define S_CLOSER 3   /* BOXTEXT dans l'arbre WINDSM */
#define S_TSIZE  4   /* BOX dans l'arbre WINDSM */
#define S_URSIZE 5   /* BOX dans l'arbre WINDSM */
#define S_FULLER 7   /* BOXTEXT dans l'arbre WINDSM */
#define S_CASCADE 8   /* BOXTEXT dans l'arbre WINDSM */
#define S_RSIZE  9   /* BOX dans l'arbre WINDSM */
#define S_LRSIZE 10  /* BOX dans l'arbre WINDSM */
#define S_SLDN   12  /* BOXTEXT dans l'arbre WINDSM */
#define S_SLRT   13  /* BOXTEXT dans l'arbre WINDSM */
#define S_BSIZE  14  /* BOX dans l'arbre WINDSM */
#define S_LLSIZE 15  /* BOX dans l'arbre WINDSM */
#define S_SLLT   17  /* BOXTEXT dans l'arbre WINDSM */
#define S_LSIZE  18  /* BOX dans l'arbre WINDSM */
#define S_MOVER  19  /* BOXTEXT dans l'arbre WINDSM */
#define S_MENU   20  /* BOX dans l'arbre WINDSM */
#define S_MENU_L 21  /* BOXTEXT dans l'arbre WINDSM */
#define S_MENU_R 22  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO   23  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO_R 24  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO_L 25  /* BOXTEXT dans l'arbre WINDSM */
#define S_OPTIONS 26  /* BOXTEXT dans l'arbre WINDSM */
#define S_UP     27  /* BOXTEXT dans l'arbre WINDSM */
#define S_VERTRK 28  /* BOX dans l'arbre WINDSM */
#define S_VERSL  29  /* BOX dans l'arbre WINDSM */
#define S_HORTRK 30  /* BOX dans l'arbre WINDSM */
#define S_HORSL  31  /* BOX dans l'arbre WINDSM */
#define S_WORK   32  /* BOXTEXT dans l'arbre WINDSM */

#define WINPOP   0   /* Formulaire/Dialogue */
#define WPCLOSE  2   /* TEXT dans l'arbre WINPOP */
#define WPICON   3   /* TEXT dans l'arbre WINPOP */

#define CASCPOP  1   /* Formulaire/Dialogue */
#define WPCASC   2   /* TEXT dans l'arbre CASCPOP */
#define WPPTB    3   /* TEXT dans l'arbre CASCPOP */
#define WPPRIO   5   /* TEXT dans l'arbre CASCPOP */
#define WPBEVENT 6   /* TEXT dans l'arbre CASCPOP */
#define WPAOT    7   /* TEXT dans l'arbre CASCPOP */

#define FULLPOP  2   /* Formulaire/Dialogue */
#define WPMAX    2   /* TEXT dans l'arbre FULLPOP */
#define WPMIN    3   /* TEXT dans l'arbre FULLPOP */

#define RTPOP    3   /* Formulaire/Dialogue */
#define WHATIS   2   /* TEXT dans l'arbre RTPOP */
#define CLOSEWIN 4   /* TEXT dans l'arbre RTPOP */
#define CYCLEWIN 5   /* TEXT dans l'arbre RTPOP */
#define FORCEXIT 7   /* TEXT dans l'arbre RTPOP */
#define CLOSEALL 8   /* TEXT dans l'arbre RTPOP */
#define REDRWIN  9   /* TEXT dans l'arbre RTPOP */
#define REDRALL  10  /* TEXT dans l'arbre RTPOP */

#define HELPWIN  4   /* Formulaire/Dialogue */
#define HELPTITL 2   /* TEXT dans l'arbre HELPWIN */
#define HELPWORK 3   /* BOX dans l'arbre HELPWIN */
#define HELPOK   5   /* BOXTEXT dans l'arbre HELPWIN */

#define LBUP     1   /* BOXCHAR dans l'arbre LISTBOX */
#define LBVERTRK 2   /* BOX dans l'arbre LISTBOX */
#define LBVERSL  3   /* BOX dans l'arbre LISTBOX */
#define LBHORTRK 4   /* BOX dans l'arbre LISTBOX */
#define LBHORSL  5   /* BOX dans l'arbre LISTBOX */
#define LBDOWN   6   /* BOXCHAR dans l'arbre LISTBOX */
#define LBLEFT   7   /* BOXCHAR dans l'arbre LISTBOX */
#define LBRIGHT  8   /* BOXCHAR dans l'arbre LISTBOX */
#define LBTEXT1  9   /* STRING dans l'arbre LISTBOX */
#define LBTEXT2  10  /* STRING dans l'arbre LISTBOX */
#define LBTEXT3  11  /* STRING dans l'arbre LISTBOX */
#define LBTEXT4  12  /* STRING dans l'arbre LISTBOX */
#define LBTEXT5  13  /* STRING dans l'arbre LISTBOX */
#define LBTEXT6  14  /* STRING dans l'arbre LISTBOX */
#define LBTEXT7  15  /* STRING dans l'arbre LISTBOX */

#define PUUP     1   /* BOXCHAR dans l'arbre POPUP */
#define PUVERTRK 2   /* BOX dans l'arbre POPUP */
#define PUVERSL  3   /* BOX dans l'arbre POPUP */
#define PUDOWN   4   /* BOXCHAR dans l'arbre POPUP */
#define PUTEXT1  5   /* STRING dans l'arbre POPUP */
#define PUTEXT2  6   /* STRING dans l'arbre POPUP */
#define PUTEXT3  7   /* STRING dans l'arbre POPUP */
#define PUTEXT4  8   /* STRING dans l'arbre POPUP */
#define PUTEXT5  9   /* STRING dans l'arbre POPUP */
#define PUTEXT6  10  /* STRING dans l'arbre POPUP */
#define PUTEXT7  11  /* STRING dans l'arbre POPUP */
#define PUTEXT8  12  /* STRING dans l'arbre POPUP */
#define PUTEXT9  13  /* STRING dans l'arbre POPUP */
#define PUTEXT10 14  /* STRING dans l'arbre POPUP */

#define ICONPOP  4   /* Formulaire/Dialogue */
#define UNICON   2   /* TEXT dans l'arbre ICONPOP */
#define PODICON  3   /* TEXT dans l'arbre ICONPOP */
#define CLOICON  5   /* TEXT dans l'arbre ICONPOP */

#include "internal.rsh"

BOOL helpmode;

OBJECT *WINPOPUP = winp;
OBJECT *CASCPOPUP = cascp;
OBJECT *FULLPOPUP = fullp;
OBJECT *RTPOPUP = rtp;
OBJECT *ICONPOPUP = icp;
OBJECT *HELPWINDOW = helpw;
OBJECT *LBOX = listb;
OBJECT *P_UP = pop;
OBJECT *ALERTWIN = alertb;
OBJECT *ERRORWIN = errorb;

GLOBAL void WSetupWinPopups(void)
{
	WObjFixPosition(WINPOPUP);
	WObjFixPosition(FULLPOPUP);
	WObjFixPosition(CASCPOPUP);
	WObjFixPosition(RTPOPUP);
	WObjFixPosition(ICONPOPUP);
	WObjFixPosition(HELPWINDOW);
	WObjFixPosition(LBOX);
	WObjFixPosition(P_UP);
	WObjFixPosition(ALERTWIN);
	WObjFixPosition(ERRORWIN);

	fix_object(WINPOPUP, FALSE, FALSE);
	fix_object(FULLPOPUP, FALSE, FALSE);
	fix_object(CASCPOPUP, FALSE, FALSE);
	fix_object(RTPOPUP, FALSE, FALSE);
	fix_object(HELPWINDOW, FALSE, TRUE);
	fix_object(ICONPOPUP, FALSE, FALSE);
	fix_object(LBOX, TRUE, FALSE);
	fix_object(P_UP, TRUE, FALSE);

	P_UP[PUVERSL].ob_x++;	P_UP[PUVERSL].ob_y++;
	LBOX[LBHORSL].ob_x++;	LBOX[LBHORSL].ob_y++;
	LBOX[LBVERSL].ob_x++;	LBOX[LBVERSL].ob_y++;
}

GLOBAL void WDoRightHandle(void)
{
	int x, y, d, p;

	graf_mkstate(&x, &y, &d, &d);

	helpmode = FALSE;

	PMovePopupCoord(RTPOPUP, x, y);
	p = PDoPopupAddr(RTPOPUP);

	switch(p) {
		case WHATIS:
			helpmode = TRUE;
			WGrafMouse(HELP_MOUSE);
			break;

		case CLOSEWIN:
			WCloseWindow(NULL, WC_OBJECTABLE, K_ASK);
			break;

		case CYCLEWIN:
			WTopWindow(NULL);
			break;

		case REDRWIN:
			{
				WINDOW *win = WindowChain;
				int x, y, w, h;

				if (win->handle != 0) {
					WWindGet(win, WF_WORKXYWH, &x, &y, &w, &h);
					WRedrawWindow(win, x, y, w, h);
				}
			}
			break;

		case CLOSEALL:
			WKillAllWindows(K_ASK);
			vswr_mode(VDIhandle, MD_REPLACE);
			break;

		case REDRALL:
			WRedrawAllWindows();
			break;

		case FORCEXIT:
			WDie(FORCE_EXIT);
			break;
	}
}

GLOBAL void WDoIconHandle(WINDOW *win)
{
	int x, y, d, p;

	graf_mkstate(&x, &y, &d, &d);

	PMovePopupCoord(ICONPOPUP, x, y);
	p = PDoPopupAddr(ICONPOPUP);

	switch(p) {
		case UNICON:
			WWindSet(win, WF_UNICONIFIED, 1);
			break;

		case PODICON:
			form_alert(1, "[3][Sorry, cannot push icons|to the virtual desktop|as of yet.][ OK ]");
			/* WWindSet(win, WF_DROPICONDESK, 1); */
			break;

		case CLOICON:
			WCloseWindow(NULL, WC_OBJECTABLE, K_ASK);
			break;
	}
}

LOCAL void WHandleWindow(WINDOW *win, int object, int clicks)
{
	int msg_buf[8], but, d;

	UNUSED(clicks);
	graf_mkstate(&d, &d, &but, &d);

	if (win)
		if (win->style & W_CUSTOMWINDOW)
			if (!(win->wind[object].ob_state & DISABLED)) {
				if ((xaes.config1 & X_ELEMENTSEL) &&
					(object != W_CLOSER) &&
					(object != W_ULSIZE) &&
					(object != W_URSIZE) &&
					(object != W_LLSIZE) &&
					(object != W_LRSIZE))
					WObjc_Change(win, object, 0, win->wind[object].ob_state | SELECTED, 1);

				switch(object) {
					case W_CLOSER:
						if (but) {
							int p, x, y;

							objc_offset(win->wind, W_CLOSER, &x, &y);

							if (!(win->iconify))
								WINPOPUP[3].ob_state |= DISABLED;
							else
								WINPOPUP[3].ob_state &= ~DISABLED;

							PMovePopupCoord(WINPOPUP, x, y);
							p = PDoPopupAddr(WINPOPUP);

							switch(p) {
								case WPCLOSE:
									WObjc_Change(win, object, 0, win->wind[object].ob_state & ~SELECTED, 1);
									WCloseWindow(win, WC_OBJECTABLE, K_ASK);
									break;

								case WPICON:
									WObjc_Change(win, object, 0, win->wind[object].ob_state & ~SELECTED, 1);
									WWindSet(win, WF_ICONIFIED, 1);
									break;
							}
						} else
							WCloseWindow(win, WC_OBJECTABLE, K_ASK);

						break;

					case W_ULSIZE:
						WSizeBox(win, S_UPPERLEFT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_TSIZE:
						WSizeBox(win, S_TOP);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_URSIZE:
						WSizeBox(win, S_UPPERRIGHT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_LSIZE:
						WSizeBox(win, S_LEFT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_RSIZE:
						WSizeBox(win, S_RIGHT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_LRSIZE:
						WSizeBox(win, S_LOWERRIGHT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_BSIZE:
						WSizeBox(win, S_BOTTOM);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_LLSIZE:
						WSizeBox(win, S_LOWERLEFT);
						WMoveWindow(win, win->size.g_x, win->size.g_y,
									win->size.g_w, win->size.g_h);
						break;

					case W_INFO_R:
						if (strlen((char *) win->info) > 1) {
							win->infpos++;
							if (win->infpos > (strlen((char *) win->info))) {
								win->infpos = (int)(strlen((char *) win->info));
								if (!(win->wind[W_INFO_R].ob_state & DISABLED))
									WObjc_Change(win, W_INFO_R, 0, win->wind[W_INFO_R].ob_state | DISABLED, 1);
							} else {
								if (win->wind[W_INFO_L].ob_state & DISABLED)
									WObjc_Change(win, W_INFO_L, 0, win->wind[W_INFO_L].ob_state & ~DISABLED, 1);
								goto doredraw;
							}
						}
						break;

					case W_INFO_L:
						if (strlen((char *) win->info) > 1) {
							win->infpos--;
							if (win->infpos < 1) {
								win->infpos = 0;
								if (!(win->wind[W_INFO_L].ob_state & DISABLED))
									WObjc_Change(win, W_INFO_L, 0, win->wind[W_INFO_L].ob_state | DISABLED, 1);
								objc_draw(win->wind, W_INFO, 7, desk.g_x, desk.g_y, desk.g_w, desk.g_h);
								break;
							} else {
								if (win->wind[W_INFO_R].ob_state & DISABLED)
									WObjc_Change(win, W_INFO_R, 0, win->wind[W_INFO_R].ob_state & ~DISABLED, 1);
							} /* This is cheating... */
						}
doredraw:				{
							char *tempstr;

							tempstr = (char *) win->info;
							tempstr = tempstr + win->infpos;
							ChangeObjectText(win->wind, W_INFO, tempstr, 3, TE_LEFT);
							objc_draw(win->wind, W_INFO, 7, desk.g_x, desk.g_y, desk.g_w, desk.g_h);
						}
						break;

					case W_MOVER:
						if (xaes.config1 & X_MOUSEGADGETS)
							WGrafMouse(MOVER_MOUSE);

						if (xaes.config2 & X_ACTIVEDRAG)
							WHandleActiveDrag(win);
						else
							WDragBox(win->size.g_w + 1, win->size.g_h + 1,
									 win->size.g_x, win->size.g_y, (xaes.config1 & X_LEFTBORDER) ? -1 : desk.g_x,
									 desk.g_y, -1, -1, &win->size.g_x,
									 &win->size.g_y);

						WGrafMouse(ARROW);

						if (!(xaes.config2 & X_ACTIVEDRAG))
							WMoveWindow(win, win->size.g_x, win->size.g_y,
										win->size.g_w, win->size.g_h);
						break;

					case W_FULLER:
						if (but) {
							int p, x, y;

							objc_offset(win->wind, W_FULLER, &x, &y);

							PMovePopupCoord(FULLPOPUP, x, y);
							p = PDoPopupAddr(FULLPOPUP);

							switch(p) {
								case WPMAX:
									msg_buf[0] = WM_FULLED;
									msg_buf[3] = win->handle;
									WMsgWindow(win, msg_buf);
									break;

								case WPMIN:
									msg_buf[0] = WM_SIZED;
									msg_buf[3] = win->handle;
									msg_buf[4] = win->minimum.g_x;
									msg_buf[5] = win->minimum.g_y;
									msg_buf[6] = win->minimum.g_w;
									msg_buf[7] = win->minimum.g_h;
									WMsgWindow(win, msg_buf);
									break;
							}
						} else {
							msg_buf[0] = WM_FULLED;
							msg_buf[3] = win->handle;

							WMsgWindow(win, msg_buf);
						}
						break;

					case W_CASCADE:
						if (but) {
							int p, x, y;

							objc_offset(win->wind, W_CASCADE, &x, &y);

							PMovePopupCoord(CASCPOPUP, x, y);
							p = PDoPopupAddr(CASCPOPUP);

							switch(p) {
								case WPCASC:
									WTopWindow(NULL);
									break;

								case WPPTB:
									WTopWindow(win);
									break;

								case WPPRIO:
									if (!(win->state & W_TIMER))
										form_alert(1, "[3][Sorry, you cannot change|timer priority on a|non-timer window!][ OK ]");
									break;

								case WPBEVENT:
								case WPAOT:
									form_alert(1, "[3][Sorry, functions not yet|implemented.][ OK ]");
									break;
							}
						} else
							WTopWindow(NULL);
						break;
				}

				if ((xaes.config1 & X_ELEMENTSEL) &&
					(object != W_CLOSER) &&
					(object != W_ULSIZE) &&
					(object != W_URSIZE) &&
					(object != W_LLSIZE) &&
					(object != W_LRSIZE))
					WObjc_Change(win, object, 0, win->wind[object].ob_state & ~SELECTED, 1);
			}
}

GLOBAL int WForm_window(WINDOW *win, int obj, int clicks)
{
	OBJECT *tree, *obptr;
	int flags, state;
	EVENT event;

	UNUSED(clicks);

	if (win) {
		if (helpmode) {
			WHandleWindowHelp(obj);
			return 1;
		}

		wind_update(BEG_MCTRL);

		tree = win->wind;
		obptr = tree + obj;
		flags = obptr->ob_flags;
		state = obptr->ob_state;

		if ((flags & SELECTABLE) && !(state & DISABLED)) {
			if ((flags & RBUTTON) && (state & SELECTED))
				no_click();
			else {
				state ^= SELECTED;
				if (flags & (RBUTTON | TOUCHEXIT)) {
					if (flags & SELECTABLE)
						WObjc_Change(win, obj, 0, state, 1);

					if (flags & RBUTTON) {
						register int act = obj, lst, new;

						for (;;) {
							lst = act;
							new = obptr->ob_next;

							for (;;) {
								act = new;
								obptr = tree + act;

								if (obptr->ob_tail == lst) {
									new = obptr->ob_head;
									lst = act;
								} else {
									if (act == obj)
										goto rb_exit;

									if ((obptr->ob_state & SELECTED) && (obptr->ob_flags & RBUTTON)) {
										WObjc_Change(win, act, 0, obptr->ob_state ^ SELECTED, 1);
										goto rb_exit;
									} else
										break;
								}
							}
						}
rb_exit:				no_click();
					}
				} else {
					register OBJECT *ob = tree + obj;
					int x, y, dummy, events;

					event.ev_mflags = MU_BUTTON | MU_M1;

					event.ev_mbclicks = 1;
					event.ev_bmask = 0x0011;
					event.ev_mbstate = 0;

					objc_offset(tree, obj, &event.ev_mm1x, &event.ev_mm1y);
					event.ev_mm1width = ob->ob_width;
					event.ev_mm1height = ob->ob_height;

					graf_mkstate(&x, &y, &dummy, &dummy);
					if (rc_inside(x, y, (GRECT *) &event.ev_mm1x)) {
						event.ev_mm1flags = 1;
						WObjc_Change(win, obj, 0, ob->ob_state ^ SELECTED, 1);
					} else
						event.ev_mm1flags = 0;

					do {
						events = EvntMulti(&event);
						if (events & MU_M1)	{
							event.ev_mm1flags = 1 - event.ev_mm1flags;
							WObjc_Change(win, obj, 0, ob->ob_state ^ SELECTED, 1);
						}
					} while (!(events & MU_BUTTON));
				}
			}
		}

		wind_update(END_MCTRL);

		if (event.ev_mbreturn != 2)
			if (win->wind[obj].ob_flags & TOUCHEXIT) {
				WHandleWindow(win, obj, 1);
				if ((win->wind[obj].ob_flags & SELECTABLE) &&
					(win->wind[obj].ob_state & SELECTED))
					WObjc_Change(win, obj, 0, win->wind[obj].ob_state ^ SELECTED, 1);
			}

			if ((win->wind[obj].ob_state & SELECTED) &&
				!(win->wind[obj].ob_flags & TOUCHEXIT)) {
				WHandleWindow(win, obj, event.ev_mbreturn);

				if (win->state & W_OPEN)
					WObjc_Change(win, obj, 0, win->wind[obj].ob_state ^ SELECTED, 1);
			}

		return 1;
	} else
		return 0;
}
