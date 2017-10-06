/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_FORM_H_
#define _XA_FORM_H_

short do_form_alert(LOCK lock, short default_button, char *alert, short owner);
WidgetBehaviour
	click_object_widget,
	dclick_object_widget;
WindowKeypress
	handle_form_key;
short has_default(OBJECT *ob);
short find_flag(OBJECT *ob, short flag);
void center_form(OBJECT *form, short bars);
void display_toolbar(LOCK lock, XA_WINDOW *wind, short item);
bool form_button(LOCK lock,
					XA_TREE *wt,
					OBJECT *form, short f, short *item,
					short dbl,
					short click_x, short click_y);


#endif
