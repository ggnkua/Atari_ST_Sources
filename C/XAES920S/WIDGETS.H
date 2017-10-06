/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _WIDGETS_H_
#define _WIDGETS_H_

void fix_default_widgets(void *);
OBJECT *get_widgets(void);
void display_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg);  /* HR: saves a lot */
void standard_widgets(XA_WINDOW *wind, XA_WIND_ATTR tp, bool keep_stuff);
/* HR: window menu's are considered standard widgets, so their location is now handled by standard_widgets() */
XA_TREE *set_toolbar_widget(LOCK lock, XA_WINDOW *wind, OBJECT *obj, short item);
void remove_widget(LOCK lock, XA_WINDOW *wind, short tool); 	/* HR 120201 */
void *rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, RECT *r);	/* HR: use a RECT */
void calc_work_area(XA_WINDOW *wind);
short do_widgets(LOCK lock, XA_WINDOW *w, MOOSE_DATA *md);
short bound_sl(short p);
bool m_inside(short x, short y, RECT *o);
void redraw_menu(LOCK lock);
void redisplay_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, short state);
void cancel_widget_active(XA_WINDOW *wind, short i);
void done_widget_active(XA_WINDOW *wind, short i);
RECT iconify_grid(short i);
void do_active_widget(LOCK lock, XA_CLIENT *client);

WidgetBehaviour display_vslide;	/* For d_g_list, should go! */

#endif
