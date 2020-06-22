#ifndef _STD_WIDG_H_
#define _STD_WIDG_H_

#include "XA_TYPES.H"
#include "KERNAL.H"

void standard_widgets(XA_WINDOW *wind, long tp);
void set_menu_widget(XA_WINDOW *wind, XA_WIDGET_LOCATION loc, OBJECT *obj);
void set_toolbar_widget(XA_WINDOW *wind, XA_WIDGET_LOCATION loc, OBJECT *obj);

void fix_bitmaps(void);

void set_widget_active(XA_WINDOW *wind, XA_WIDGET *widg, WidgetCallback wc);
void cancel_widget_active(XA_WINDOW *wind);

void rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, short *x, short *y);
void display_widget_bitmap(short x, short y, unsigned short *addr);

void calc_work_area(XA_WINDOW *wind);
short do_widgets(XA_WINDOW *w, MOUSE_DATA *md);

#endif