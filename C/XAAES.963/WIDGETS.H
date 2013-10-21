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

#ifndef _WIDGETS_H_
#define _WIDGETS_H_

void fix_default_widgets(void *);
OBJECT *get_widgets(void);
void display_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg);  /* HR: saves a lot */
void standard_widgets(XA_WINDOW *wind, XA_WIND_ATTR tp, bool keep_stuff);
/* HR: window menu's are considered standard widgets, so their location is now handled by standard_widgets() */
XA_TREE *set_toolbar_widget(LOCK lock, XA_WINDOW *wind, OBJECT *obj, int item);
XA_TREE *set_popup_widget(Tab *tab, XA_WINDOW *wind, OBJECT *form, int item);		/* HR 091101 */
void remove_widget(LOCK lock, XA_WINDOW *wind, int tool); 	/* HR 120201 */
void *rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, RECT *r);	/* HR: use a RECT */
void calc_work_area(XA_WINDOW *wind);
int do_widgets(LOCK lock, XA_WINDOW *w, XA_WIND_ATTR mask, MOOSE_DATA *md);
int bound_sl(int p);
int pix_to_sl(long p, int s);
int sl_to_pix(long s, int p);
void XA_slider(XA_WINDOW *w, int which, int total, int visible, int start);
bool m_inside(G_i x, G_i y, RECT *o);
void redraw_menu(LOCK lock);
void redisplay_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, int state);
void done_widget_active(XA_WINDOW *wind, int i);
RECT iconify_grid(int i);
void do_active_widget(LOCK lock, XA_CLIENT *client);

WidgetBehaviour display_vslide;  /* For d_g_list, should go! */
WidgetBehaviour display_object_widget;  /* HR 270801: for desktop */

/*
XA_WIDGET *get_widget(XA_WINDOW *wind, int n);
*/
#define get_widget(w,n) (&(w)->widgets[n])
#endif
