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

#ifndef _SCRLOBJC_H_
#define _SCRLOBJC_H_

int set_scroll(XA_CLIENT *client, OBJECT *form, int objc);		/* HR: title --> set_slist_object() */
bool add_scroll_entry(OBJECT *form, int objc, OBJECT *icon, void *text, SCROLL_ENTRY_TYPE flag);
void empty_scroll_list(OBJECT *form, int objc, SCROLL_ENTRY_TYPE flag);
void click_scroll_list(LOCK lock, OBJECT *form, int objc, MOOSE_DATA *md);		/* HR 181201: use MOOSE_DATA structure */
void dclick_scroll_list(LOCK lock, OBJECT *form, int objc, MOOSE_DATA *md);
/* HR */
SCROLL_INFO *set_slist_object(
		LOCK lock,
		XA_TREE *wt,					/* HR 290702 */
		OBJECT *form,
		G_i item,
		scrl_widget *closer,
		scrl_widget *fuller,
		scrl_click *dclick,
		scrl_click *click,
		char *title, char *info,
		G_i line_max);
int scrl_cursor(SCROLL_INFO *list, G_u keycode);
void free_scrollist(SCROLL_INFO *list);

#endif