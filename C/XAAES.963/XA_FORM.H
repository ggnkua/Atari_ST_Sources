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

#ifndef _XA_FORM_H_
#define _XA_FORM_H_

int do_form_alert(LOCK lock, XA_CLIENT *client, int default_button, char *alert);
WidgetBehaviour
	click_object_widget,
	dclick_object_widget;
WindowKeypress
	handle_form_key;
int has_default(OBJECT *ob);
int find_flag(OBJECT *ob, int flag);
void center_form(OBJECT *form, int bars);
void display_toolbar(LOCK lock, XA_WINDOW *wind, int item);
bool do_form_button(LOCK lock,
					XA_TREE *wt,
					OBJECT *form, int f, int *item,
					int dbl,
					G_i click_x, G_i click_y, int click_s);

void init_form_do(LOCK lock, XA_TREE *wt, OBJECT *form, int item, bool draw); /* HR 060702 */
void set_form_do(LOCK lock, XA_CLIENT *client, OBJECT *form, int item); /* HR 250602 */

/* HR 111101: Introduction of slidable and srollable forms. */
SendMessage handle_form_window;

ClassicClick click_form_do;

ExitForm XA_form_exit,
         exit_toolbar,
         exit_wdial,
         exit_form_do,
         exit_form_dial,
         classic_exit_form_do;
         
#endif
