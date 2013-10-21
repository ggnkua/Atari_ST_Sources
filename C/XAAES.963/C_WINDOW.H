/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _C_WINDOW_H_
#define _C_WINDOW_H_

RECT		wa_to_curr(XA_WINDOW *wi, int d, RECT r);

XA_WINDOW *	create_window		(LOCK lock, SendMessage *message_handler,
									XA_CLIENT *client,
									bool nolist,
									XA_WIND_ATTR tp,
									WINDOW_TYPE dial,
									int frame,
									int thinframe,
									bool thinwork,
									RECT r,
									RECT *max,
									RECT *rem),
          *	find_window			(LOCK lock, int x, int y),
          *	get_wind_by_handle	(LOCK lock, int h),
          *	pull_wind_to_top	(LOCK lock, XA_WINDOW *w),
          *	top_w				(LOCK lock),						/* HR */
          * root_w				(LOCK lock);
bool		close_window		(LOCK lock, XA_WINDOW *wind);
int		    open_window			(LOCK lock, XA_WINDOW *w, RECT r);
void		send_wind_to_bottom	(LOCK lock, XA_WINDOW *w),
			move_window			(LOCK lock, XA_WINDOW *wind, int newstate, int x, int y, int w, int h),
			delete_window		(LOCK lock, XA_WINDOW *wind),
			display_window		(LOCK lock, int which, XA_WINDOW *w, RECT *clip),		/* Using rectangle list. */
			draw_window			(LOCK lock, XA_WINDOW *wind),
			display_windows_below(LOCK lock, RECT *r, XA_WINDOW *w);

RECT		free_icon_pos		(LOCK lock);
RECT		calc_window			(LOCK lock,
									XA_CLIENT *client,
									int request,
									unsigned long tp,
									int mg,
									int thinframe,
									bool thinwork,
									RECT r);

void		top_window			(LOCK lock, XA_WINDOW *w, XA_CLIENT *menu_owner),
			bottom_window		(LOCK lock, XA_WINDOW *w),
			after_top			(LOCK lock, bool untop),
			wi_put_first		(WIN_BASE *b, XA_WINDOW *w),
			wi_put_last			(WIN_BASE *b, XA_WINDOW *w),
			wi_put_blast		(WIN_BASE *b, XA_WINDOW *w),
			wi_remove			(WIN_BASE *b, XA_WINDOW *w),
			wi_insert			(WIN_BASE *b, XA_WINDOW *w, XA_WINDOW *after),
			remove_windows		(LOCK lock, XA_CLIENT *client),
			inside_root			(RECT *r, OPT *o),					/* HR */
			unhide_window		(LOCK lock, XA_WINDOW *wind),
			clear_wind_handles	(void),		/* HR */
			send_ontop			(LOCK lock),
			send_untop			(LOCK lock, XA_WINDOW *wind);
bool		is_hidden			(XA_WINDOW *wind),		 /* HR 210801 */
			unhide				(XA_WINDOW *w, G_i *x, G_i *y);

XA_WIND_ATTR hide_move(OPT *o);

void  __regargs bclr(unsigned long *row,long bit);
int   __regargs btst(unsigned long *row,long bit);
void  __regargs bset(unsigned long *row,long bit);

#endif
