/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _SCRLOBJC_H_
#define _SCRLOBJC_H_

short set_scroll(XA_CLIENT *client, OBJECT *form, short objc);		/* HR: title --> set_slist_widget() */
bool add_scroll_entry(OBJECT *form, short objc, OBJECT *icon, void *text, SCROLL_ENTRY_TYPE flag);
void empty_scroll_list(OBJECT *form, short objc, SCROLL_ENTRY_TYPE flag);
void click_scroll_list(LOCK lock, OBJECT *form, short objc, short cx, short cy);
void dclick_scroll_list(LOCK lock, OBJECT *form, short objc, short cx, short cy);
/* HR */
XA_WINDOW *set_slist_widget(
		LOCK lock,
		short pid,
		XA_WINDOW *parent_window,
		OBJECT *form,
		short item,
		scrl_widget *closer,
		scrl_widget *fuller,
		scrl_click *dclick,
		scrl_click *click,
		char *title, char *info,
		short line_max);
short scrl_cursor(SCROLL_INFO *list, short keycode);
void free_scrollist(SCROLL_INFO *list);

#endif