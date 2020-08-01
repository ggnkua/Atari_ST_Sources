/********************************************************************
 *																0.20*
 *	XAES: Custom editing routines									*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	Oh no, my first attempt at custom editing routines and they're	*
 *	slow as hell!  I better 'borrow' Christian Grunenberg's OBJCEDIT*
 *	routines if I want to get anywhere...							*
 *																	*
 ********************************************************************/

#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "xaes.h"
#include "nkcc.h"

int edit_old_x, edit_old_y;

GLOBAL char *WGetEditText(char *te_ptmplt, char *te_ptext)
{
	char *ret;
	int i, j, len;

	ret = (char *) malloc(strlen(te_ptmplt));

	len = (int)(strlen(te_ptmplt) - (int)(strlen(te_ptext)));

	i = 0;
	while(i != len) {
		ret[i] = te_ptmplt[i++];
	}

	len = (int)(strlen(te_ptext));

	j = 0;
	while(j != len) {
		ret[i++] = te_ptext[j++];
	}

	ret[i] = '\0';

	return(ret);
}

GLOBAL void WObjc_Edit(WINDOW *win, int mode, int key, int kstate)
{
	int tophandle;

	WWindGet(win, WF_TOP, &tophandle);
	win = WFindHandle(tophandle);

	if (win) {
		WMoveWindow(win, -1, -1, -1, -1);

	if ((WFindOwner(tophandle)) && (win->edobject) && !(win->state & W_ICONIFIED)) {
	if (mode == ED_INIT)
		if ((win->tree[win->edobject].ob_type & 0xFF) != G_USERDEF) {
			int pos = ((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) - 
					   (win->tree[win->edobject].ob_spec.tedinfo->te_txtlen)) +
						win->edpos;
			int x, y, ourw, ourh, dummy;

			vst_height(VDIhandle, win->tree[win->edobject].ob_spec.tedinfo->te_font == 3 ? large_font : small_font,
					&dummy, &dummy, &ourw, &ourh);

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW) {
					x = win->size.g_x + win->wind[25].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
				}

				if (win->wind_type == WC_SWINDOW) {
					x = win->size.g_x + win->wind[32].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
				}
			} else {
				x = win->tree->ob_x + win->tree[win->edobject].ob_x;
				y = win->tree->ob_y + win->tree[win->edobject].ob_y;
			}

			x += (pos * ourw);
			x += 2; y += 2;
			y++;

			if (win->editmode == EDIT_INSERT)
				WObjc_Draw(win, x, y, 1, ourh);
			else
				WObjc_Draw(win, x, y, ourw + 1, ourh);

			vswr_mode(VDIhandle, MD_XOR);
			vsl_color(VDIhandle, BLACK);
			vsf_interior(VDIhandle, 1);

			WGrafMouse(M_OFF);

			if (win->editmode == EDIT_INSERT)
				line(x, y, x, y + ourh);
			else
				box_fill(x, y, ourw + 1, ourh, BLACK);

			WGrafMouse(M_ON);
			vsf_interior(VDIhandle, 0);
			vswr_mode(VDIhandle, MD_REPLACE);
		}

	if (mode == ED_END)
	if ((win->tree[win->edobject].ob_type & 0xFF) != G_USERDEF) {
			int pos = ((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) - 
					   (win->tree[win->edobject].ob_spec.tedinfo->te_txtlen)) +
						win->edpos;
			int x, y, ourw, ourh, dummy;

			vst_height(VDIhandle, win->tree[win->edobject].ob_spec.tedinfo->te_font == 3 ? large_font : small_font,
					&dummy, &dummy, &ourw, &ourh);

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW) {
					x = win->size.g_x + win->wind[25].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
				}

				if (win->wind_type == WC_SWINDOW) {
					x = win->size.g_x + win->wind[32].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
				}
			} else {
				x = win->tree->ob_x + win->tree[win->edobject].ob_x;
				y = win->tree->ob_y + win->tree[win->edobject].ob_y;
			}

			x += (pos * ourw);
			x += 2; y += 2;

			y++;

			WGrafMouse(M_OFF);

			if (win->editmode == EDIT_INSERT)
				WObjc_Draw(win, x, y, 1, ourh);
			else
				WObjc_Draw(win, x, y, ourw + 1, ourh);

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW)
					x = win->size.g_x + win->wind[25].ob_x + win->tree[win->edobject].ob_x +
						((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) * ourw) - 5;

				if (win->wind_type == WC_SWINDOW)
					x = win->size.g_x + win->wind[32].ob_x + win->tree[win->edobject].ob_x +
						((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) * ourw) - 5;
			} else
				x = win->size.g_x + win->tree[win->edobject].ob_x +
					((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) * ourw) - 5;

			if (win->editmode == EDIT_REPLACE)
				if (win->edpos == (win->tree[win->edobject].ob_spec.tedinfo->te_txtlen - 1))
					WObjc_Draw_Out(win, x, y, ourw + 2, ourh);

			WGrafMouse(M_ON);

			vsf_interior(VDIhandle, 0);
			vswr_mode(VDIhandle, MD_REPLACE);
		}

	if (mode == ED_CHAR)
		if ((win->tree[win->edobject].ob_type & 0xFF) != G_USERDEF) {
			int pos = ((win->tree[win->edobject].ob_spec.tedinfo->te_tmplen) - 
					   (win->tree[win->edobject].ob_spec.tedinfo->te_txtlen)) +
						win->edpos;
			int x, y, n_key, ourw, ourh, dummy;

			int maxpos = win->tree[win->edobject].ob_spec.tedinfo->te_txtlen;
			int tmplen = win->tree[win->edobject].ob_spec.tedinfo->te_tmplen;
			BOOL cango = FALSE;

			n_key = nkc_tconv((key & 0xff) | (((long) key & 0xff00) << 8) | ((long) kstate << 24)) & ~(NKF_FUNC | NKF_RESVD | NKF_NUM);

			vst_height(VDIhandle, win->tree[win->edobject].ob_spec.tedinfo->te_font == 3 ? large_font : small_font,
					&dummy, &dummy, &ourw, &ourh);

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW) {
					x = win->size.g_x + win->wind[25].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
				}

				if (win->wind_type == WC_SWINDOW) {
					x = win->size.g_x + win->wind[32].ob_x + win->tree[win->edobject].ob_x;
					y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
				}
			} else {
				x = win->tree->ob_x + win->tree[win->edobject].ob_x;
				y = win->tree->ob_y + win->tree[win->edobject].ob_y;
			}

			x += (pos * ourw);

			x += 2; y += 2;

			WObjc_Edit(win, ED_END, 0, 0);

			switch(n_key) {
				case NKF_CTRL | ' ':
				case NKF_CTRL | '`':
				case NKF_CTRL | '2':
				case NKF_RESVD:
				case NK_INVALID:
				case NKF_CTRL | NK_F1:
				case NKF_CTRL | NK_F2:
				case NKF_CTRL | NK_F3:
				case NKF_CTRL | NK_F4:
				case NKF_CTRL | NK_F5:
				case NKF_CTRL | NK_F6:
				case NKF_CTRL | NK_F7:
				case NKF_CTRL | NK_F8:
				case NKF_CTRL | NK_F9:
				case NKF_CTRL | NK_F10:
				case NKF_CTRL | NK_UP:
				case NKF_CTRL | NK_DOWN:
				case NKF_CTRL | NK_LEFT:
				case NKF_CTRL | NK_RIGHT:
					cango = FALSE;
					break;

				default:
					cango = TRUE;
					break;
			}

			if ((cango) && !(n_key & NKF_ALT))
				switch(n_key & 0xFF) {
					case NK_ESC:
						if (win->style & W_CUSTOMWINDOW) {
							if (win->wind_type == WC_WINDOW) {
								x = win->size.g_x + win->wind[25].ob_x + (win->tree[win->edobject].ob_x + ((tmplen - maxpos) * ourw));
								y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
							}

							if (win->wind_type == WC_SWINDOW) {
								x = win->size.g_x + win->wind[32].ob_x + (win->tree[win->edobject].ob_x + ((tmplen - maxpos) * ourw));
								y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
							}
						} else {
							x = win->tree->ob_x + (win->tree[win->edobject].ob_x + ((tmplen - maxpos) * ourw));
							y = win->tree->ob_y + win->tree[win->edobject].ob_y;
						}

						memset(win->tree[win->edobject].ob_spec.tedinfo->te_ptext, 95, maxpos);
						win->tree[win->edobject].ob_spec.tedinfo->te_ptext[0] = '\0';
						win->edpos = 0;

						x += 2; y += 2;

						WObjc_Draw(win, x, y - 2, win->tree[win->edobject].ob_width - ((tmplen - maxpos) * ourw), win->tree[win->edobject].ob_height + 4);
						break;

					case NK_DEL:
						{
							int start, finish;

							start = win->edpos;
							finish = maxpos - 1;

							do {
								win->tree[win->edobject].ob_spec.tedinfo->te_ptext[start] =
								win->tree[win->edobject].ob_spec.tedinfo->te_ptext[start + 1];
								start++;
							} while (start < finish);

							if (win->style & W_CUSTOMWINDOW) {
								if (win->wind_type == WC_WINDOW) {
									x = win->size.g_x + win->wind[25].ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
									y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
								}

								if (win->wind_type == WC_SWINDOW) {
									x = win->size.g_x + win->wind[32].ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
									y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
								}
							} else {
								x = win->tree->ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
								y = win->tree->ob_y + win->tree[win->edobject].ob_y;
							}

							x += 2; y += 2;

							WObjc_Draw(win, x, y - 2, win->tree[win->edobject].ob_width - (((tmplen - maxpos) + win->edpos) * ourw), win->tree[win->edobject].ob_height + 4);
						}
						break;

					case NK_BS:
						{
							int start, finish;

							start = win->edpos;
							finish = maxpos - 1;

							if (start != 0) {
								win->edpos--;

								if (win->edpos < 0)
									win->edpos = 0;

								start = win->edpos;

								do {
									win->tree[win->edobject].ob_spec.tedinfo->te_ptext[start] =
									win->tree[win->edobject].ob_spec.tedinfo->te_ptext[start + 1];
									start++;
								} while (start < finish);

								if (win->style & W_CUSTOMWINDOW) {
									if (win->wind_type == WC_WINDOW) {
										x = win->size.g_x + win->wind[25].ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
										y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
									}

									if (win->wind_type == WC_SWINDOW) {
										x = win->size.g_x + win->wind[32].ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
										y = win->size.g_y + win->wind[32].ob_y + win->tree[win->edobject].ob_y;
									}
								} else {
									x = win->tree->ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
									y = win->tree->ob_y + win->tree[win->edobject].ob_y;
								}

								x += 2; y += 2;
							}

							WObjc_Draw(win, x, y - 2, win->tree[win->edobject].ob_width - (((tmplen - maxpos) + win->edpos) * ourw), win->tree[win->edobject].ob_height + 4);
						}
						break;
						
					default:
						if (win->editmode == EDIT_REPLACE) {
							win->tree[win->edobject].ob_spec.tedinfo->te_ptext[win->edpos] = key;
							win->tree[win->edobject].ob_spec.tedinfo->te_ptext[maxpos - 1] = '\0';
							WObjc_Draw(win, x, y, gr_cw + 1, gr_ch + 1);
							win->edpos++;
						} else {
							int start, finish;
							char *str;

							finish = win->edpos - 1;
							start = maxpos - 2;

							str = win->tree[win->edobject].ob_spec.tedinfo->te_ptext;

							if (start > finish)
								do {
									str[start + 1] = str[start];
									start--;
								} while (start > finish);

							win->tree[win->edobject].ob_spec.tedinfo->te_ptext[win->edpos] = key;
							if ((win->wind) && (win->style & W_CUSTOMWINDOW)) {
								x = win->size.g_x + win->wind[25].ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
								y = win->size.g_y + win->wind[25].ob_y + win->tree[win->edobject].ob_y;
							} else {
								x = win->tree->ob_x + (win->tree[win->edobject].ob_x + (((tmplen - maxpos) + win->edpos) * ourw));
								y = win->tree->ob_y + win->tree[win->edobject].ob_y;
							}

							x += 2; y += 2;

							str[maxpos - 1] = '\0';
							win->tree[win->edobject].ob_spec.tedinfo->te_ptext = str;
							win->edpos++;

							if (win->edpos > (maxpos - 1))
								win->edpos = (maxpos - 1);

							WObjc_Draw(win, x, y - 2, win->tree[win->edobject].ob_width - (((tmplen - maxpos) + (win->edpos - 1)) * ourw), win->tree[win->edobject].ob_height + 4);
						}

					break;
				}

			if (win->edpos > (maxpos - 1))
				win->edpos = (maxpos - 1);

			WObjc_Edit(win, ED_INIT, 0, 0);

			vsf_interior(VDIhandle, 0);
			vswr_mode(VDIhandle, MD_REPLACE);
		}
	}
	}
}