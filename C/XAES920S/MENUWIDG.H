/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _MENU_WIDG_H_
#define _MENU_WIDG_H_

TASK do_popup_menu, do_scroll_menu;
short attach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, short item, MENU *mn);
short detach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, short item);
void remove_attachments(LOCK lock, XA_CLIENT *client, OBJECT *menu);
void set_menu_widget(XA_WINDOW *wind, XA_TREE *wit);
void fix_menu(OBJECT *root, bool desk);		/* HR */

#endif
