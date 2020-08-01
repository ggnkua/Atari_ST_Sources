/********************************************************************
 *																1.10*
 *	XAES: Dialog-forming library									*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	This is that type of module that desperately cries out, "PLEASE!*
 *	OPTIMIZE ME!"  It shall be done soon...  I just need to get		*
 *	around to speeding things up in the next release...				*
 *																	*
 ********************************************************************/

#include "xaes.h"

GLOBAL void Objc_Change(WINDOW *win, int ob_cobject, int ob_crecvd, int ob_cnewstate, int ob_credraw)
{
	if (win)
		if (win->tree || win->iconify) {
		objc_change((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), ob_cobject, ob_crecvd, 0, 0, 0, 0, ob_cnewstate, 0);

		if ((ob_credraw) && (win->state & W_OPEN)) {
			GRECT own, temp;
			int x, y, tx, ty, tw, th;

			WMoveWindow(win, -1, -1, -1, -1);

			objc_offset((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), ob_cobject, &x, &y);
			wind_get(win->handle, WF_WORKXYWH, &tx, &ty, &tw, &th);

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW) {
					own.g_x = tx + win->wind[25].ob_x - 1;
					own.g_y = ty + win->wind[25].ob_y - 1;
					own.g_w = win->wind[25].ob_width + 1;
					own.g_h = win->wind[25].ob_height + 1;
				}

				if (win->wind_type == WC_SWINDOW) {
					own.g_x = tx + win->wind[32].ob_x - 1;
					own.g_y = ty + win->wind[32].ob_y - 1;
					own.g_w = win->wind[32].ob_width + 1;
					own.g_h = win->wind[32].ob_height + 1;
				}
			} else {
				own.g_x = tx;
				own.g_y = ty;
				own.g_w = tw;
				own.g_h = th;
			}

			wind_update(BEG_UPDATE);

			WWindGet(win, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			WMoveWindow(win, -1, -1, -1, -1);

			while (temp.g_w && temp.g_h) {
				if (rc_intersect(&temp, &own)) {
					switch ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[ob_cobject].ob_type & 0xFF : win->tree[ob_cobject].ob_type & 0xFF)) {
						case G_BUTTON:
						case G_USERDEF:
						case G_BOXCHAR:
						case G_BOX:
						case G_STRING:
						case G_IMAGE:
							if (ob_cobject == 0)
								objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
							else
								objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), ob_cobject, 2, temp.g_x, temp.g_y, temp.g_w, temp.g_h);

							break;

						default:
							if ((ob_cobject == 0) || ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[ob_cobject].ob_type & 0x0F : win->tree[ob_cobject].ob_type & 0x0F)) == G_IMAGE)
								objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
							else
								objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), ob_cobject, 2, temp.g_x, temp.g_y, temp.g_w, temp.g_h);

							break;
					}
				}

				WWindGet(win, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			}

			wind_update(END_UPDATE);
		}

		WMoveWindow(win, -1, -1, -1, -1);
	}
}

GLOBAL void WObjc_Change(WINDOW *win, int ob_cobject, int ob_crecvd, int ob_cnewstate, int ob_credraw)
{
	if (win)
		if (win->style & W_CUSTOMWINDOW) {
			objc_change(win->wind, ob_cobject, ob_crecvd, 0, 0, 0, 0, ob_cnewstate, 0);

			if ((ob_credraw) && (win->state & W_OPEN)) {
				GRECT own, temp;
				int x, y, tx, ty, tw, th;

				objc_offset(win->wind, ob_cobject, &x, &y);
				wind_get(win->handle, WF_WORKXYWH, &tx, &ty, &tw, &th);

				own.g_x = tx;
				own.g_y = ty;
				own.g_w = tx + tw;
				own.g_h = ty + th;

				wind_update(BEG_UPDATE);

				WWindGet(win, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
				WMoveWindow(win, -1, -1, -1, -1);

				while (temp.g_w && temp.g_h) {
					if (rc_intersect(&temp, &own))
						switch (win->wind[ob_cobject].ob_type & 0xff) {
							case G_BUTTON:
							case G_USERDEF:
							case G_BOXCHAR:
							case G_BOX:
							case G_STRING:
							case G_IMAGE:
								if (ob_cobject == 0)
									objc_draw(win->wind, 0, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
								else
									objc_draw(win->wind, ob_cobject, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
								break;

							default:
								if ((ob_cobject == 0) || ((win->wind[ob_cobject].ob_type & 0x0F) == G_IMAGE))
									objc_draw(win->wind, 0, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
								else
									objc_draw(win->wind, ob_cobject, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
								break;
						}

					WWindGet(win, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
				}

				wind_update(END_UPDATE);
			}
		}

		WMoveWindow(win, -1, -1, -1, -1);
}

GLOBAL int WForm_button(WINDOW *win, int obj, int clicks, int *nxtobj)
{
	OBJECT *tree, *obptr;
	int flags, state;

	if (win) {
		if ((clicks == 2) && (*nxtobj == win->icon_num))
			WWindSet(win, WF_UNICONIFIED, 1);
		else {
		WMoveWindow(win, -1, -1, -1, -1);

		tree = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree);
		obptr = tree + obj;
		flags = obptr->ob_flags;
		state = obptr->ob_state;

		if (helpmode) {
			WCallBHelpDispatcher(win, obj);
			return 1;
		}

		wind_update(BEG_MCTRL);

		if (clicks == 2) {}
		if (clicks == 3) {}
		if ((flags & SELECTABLE) && ! (state & DISABLED)) {
			*nxtobj = obj;

			if ((flags & RBUTTON) && (state & SELECTED))
				no_click();
			else {
				state ^= SELECTED;
				if (flags & (RBUTTON | TOUCHEXIT)) {
					if (flags & SELECTABLE)
						Objc_Change(win, obj, 0, state, 1);

					if (flags & TOUCHEXIT) {
						int d, button;

						do {
							graf_mkstate(&d, &d, &button, &d);
							switch((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_type >> 8 : win->tree[obj].ob_type >> 8)) {
								case SLIDERLEFT:
								case SLIDERRIGHT:
								case SLIDERUP:
								case SLIDERDOWN:
								case SLIDERTRACK:
									WHandleSlider(win, obj);
									break;

								case SLIDERSLIDE:
									if (xaes.config1 & X_MOUSESLIDERS) {
										EXTINFO *ex = (EXTINFO *)((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_spec.userblk->ub_parm : win->tree[obj].ob_spec.userblk->ub_parm));

										if (ex->te_slider.slide_type == SLIDER_HOR)
											WGrafMouse(LRSLIDE_MOUSE);
										if (ex->te_slider.slide_type == SLIDER_VER)
											WGrafMouse(UDSLIDE_MOUSE);
									}

									WHandleSlider(win, obj);
									break;
							}

							WCallDlgDispatcher(win, obj);
						} while(button);

						WGrafMouse(ARROW);
					}

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
										Objc_Change(win, act, 0, obptr->ob_state ^ SELECTED, 1);
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
					EVENT event;
					int x, y, dummy, events;

					event.ev_mflags = MU_BUTTON | MU_M1;
					event.ev_mbclicks = 1;
					event.ev_bmask = 0x11;
					event.ev_mbstate = 0;

					objc_offset(tree, obj, &event.ev_mm1x, &event.ev_mm1y);
					event.ev_mm1width = ob->ob_width;
					event.ev_mm1height = ob->ob_height;

					graf_mkstate(&x, &y, &dummy, &dummy);
					if (rc_inside(x, y, (GRECT *) &event.ev_mm1x)) {
						event.ev_mm1flags = 1;
						Objc_Change(win, obj, 0, ob->ob_state ^ SELECTED, 1);
					} else
						event.ev_mm1flags = 0;

					do {
						events = EvntMulti(&event);
						if (events & MU_M1)	{
							event.ev_mm1flags = 1 - event.ev_mm1flags;
							Objc_Change(win, obj, 0, ob->ob_state ^ SELECTED, 1);
						}
					} while (!(events & MU_BUTTON));

					if (!(ob->ob_state & SELECTED))
						*nxtobj = 0;
				}
			}
		} else
			if (flags & EDITABLE)
				*nxtobj = obj;
			else
				*nxtobj = 0;

		wind_update(END_MCTRL);

		if (*nxtobj)
			if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[*nxtobj].ob_flags & (EXIT | TOUCHEXIT) : win->tree[*nxtobj].ob_flags & (EXIT | TOUCHEXIT)))
				return 0;
		}
	}

	return 1;
}

GLOBAL void WUpdateWindow(WINDOW *win, int x, int y, int w, int h, int obj)
{
	GRECT own, temp;

	if (win) {
		WMoveWindow(win, -1, -1, -1, -1);

		own.g_x = x;
		own.g_y = y;
		own.g_w = w;
		own.g_h = h;

		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);

		WWindGet(win, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
		WMoveWindow(win, -1, -1, -1, -1);

		while (temp.g_w && temp.g_h) {
			if (rc_intersect(&temp, &own))
				if (obj == 0)
					if ((win->wind) && (win->style & W_CUSTOMWINDOW)) {
						objc_draw(win->wind, 0, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
						objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
					} else if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree)) && !(win->style & W_CUSTOMWINDOW))
						objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
				else
					if ((win->wind) && (win->style & W_CUSTOMWINDOW))
						objc_draw(win->wind, obj, 7, temp.g_x, temp.g_y, temp.g_w, temp.g_h);
					else if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree)) && !(win->style & W_CUSTOMWINDOW))
						objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), obj, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);

			WWindGet(win, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
		}

		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
	}

	WMoveWindow(win, -1, -1, -1, -1);
}

GLOBAL void WUpdateWindowDlg(WINDOW *win, int obj)
{
	GRECT own, temp;
	int tx, ty, tw, th;

	if (win) {
		WMoveWindow(win, -1, -1, -1, -1);

		if (win->state & W_OPEN) {
			wind_get(win->handle, WF_WORKXYWH, &tx, &ty, &tw, &th);

			if (obj == 0)
				if (win->style & W_CUSTOMWINDOW) {
					if (win->wind_type == WC_WINDOW) {
						own.g_x = tx + win->wind[25].ob_x - 1;
						own.g_y = ty + win->wind[25].ob_y - 1;
						own.g_w = win->wind[25].ob_width + 1;
						own.g_h = win->wind[25].ob_height + 1;
					}

					if (win->wind_type == WC_SWINDOW) {
						own.g_x = tx + win->wind[32].ob_x - 1;
						own.g_y = ty + win->wind[32].ob_y - 1;
						own.g_w = win->wind[32].ob_width + 1;
						own.g_h = win->wind[32].ob_height + 1;
					}
				} else {
					own.g_x = tx;
					own.g_y = ty;
					own.g_w = tw;
					own.g_h = th;
				}
			else {
				own.g_x = tx + (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_x - 1 : win->tree[obj].ob_x - 1);
				own.g_y = ty + (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_y - 1 : win->tree[obj].ob_y - 1);
				own.g_w = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_width + 1 : win->tree[obj].ob_width + 1);
				own.g_h = (((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify[obj].ob_height + 1 : win->tree[obj].ob_height + 1);
			}

			wind_update(BEG_UPDATE);
			wind_update(BEG_MCTRL);

			WWindGet(win, WF_FIRSTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			WMoveWindow(win, -1, -1, -1, -1);

			while (temp.g_w && temp.g_h) {
				if (rc_intersect(&temp, &own))
					if (obj != 0)
						if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree))
							objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), obj, 99, temp.g_x, temp.g_y, temp.g_w, temp.g_h);

				WWindGet(win, WF_NEXTXYWH, &temp.g_x, &temp.g_y, &temp.g_w, &temp.g_h);
			}

			wind_update(END_MCTRL);
			wind_update(END_UPDATE);
		}

		WMoveWindow(win, -1, -1, -1, -1);
	}
}

GLOBAL int rc_intersect(GRECT *r1, GRECT *r2)
{
	r1->g_w = min(r1->g_x + r1->g_w, r2->g_x + r2->g_w );
	r1->g_h = min(r1->g_y + r1->g_h, r2->g_y + r2->g_h );
	r1->g_x = max(r1->g_x, r2->g_x);
	r1->g_y = max(r1->g_y, r2->g_y);
	r1->g_w -= r1->g_x;
	r1->g_h -= r1->g_y;
	return (r1->g_w > 0 && r1->g_h > 0) ? TRUE : FALSE;
}

GLOBAL int rc_inside(int x, int y, GRECT *r)
{
	return (x > r->g_x && x < (r->g_x + r->g_w) &&
			 y > r->g_y && y < (r->g_y + r->g_h));
}

GLOBAL void no_click(void)
{
	int dummy, bstate;

	graf_mkstate(&dummy, &dummy, &bstate, &dummy);
	if (bstate & 1)
		evnt_button(1, 3, 0, &dummy, &dummy, &dummy, &dummy);
}