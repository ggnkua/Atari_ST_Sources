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

#ifndef _MENU_WIDG_H_
#define _MENU_WIDG_H_

TASK click_form_popup_entry, click_popup_entry, do_scroll_menu;
void do_popup(Tab *tab, OBJECT *root, int item, TASK *click, G_i rdx, G_i rdy);
int inquire_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, int item, MENU *mn);
int attach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, int item, MENU *mn);
int detach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, int item);
void remove_attachments(LOCK lock, XA_CLIENT *client, OBJECT *menu);
void set_menu_widget(XA_WINDOW *wind, XA_TREE *wit);
void fix_menu(OBJECT *root, bool desk);		/* HR */
XA_TREE   *get_menu  (void);
XA_CLIENT *menu_owner(void);
XA_TREE *set_popup_widget(Tab *tab, XA_WINDOW *wind, OBJECT *form, int item);

#endif
