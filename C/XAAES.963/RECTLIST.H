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

#ifndef _RECTLIST_H_
#define _RECTLIST_H_

bool was_visible(XA_WINDOW *w);			/* HR 251002: redraw optimizations */
bool rc_intersect(RECT s, RECT *d);		/* HR 210801: s by value in stead of const */
XA_RECT_LIST *generate_rect_list(LOCK lock, XA_WINDOW *w, short which);
void dispose_rect_list(XA_WINDOW *w);

XA_RECT_LIST *rect_get_user_first(XA_WINDOW *w);
XA_RECT_LIST *rect_get_user_next(XA_WINDOW *w);
XA_RECT_LIST *rect_get_system_first(XA_WINDOW *w);
XA_RECT_LIST *rect_get_system_next(XA_WINDOW *w);

#endif
