#ifndef _C_WINDOW_H_
#define _C_WINDOW_H_

#include "XA_TYPES.H"

void standard_window(XA_WINDOW *wind, long tp);
XA_WINDOW *create_window(short pid, long tp, short rx, short ry, short rw, short rh);
XA_WINDOW *wind_find(short x, short y);
XA_WINDOW *get_wind_by_handle(short h);
void pull_wind_to_top(XA_WINDOW *w);
void send_wind_to_bottom(XA_WINDOW *w);
void delete_window(XA_WINDOW *wind);
void display_non_topped_window(XA_WINDOW *w,GRECT *clip);
void display_window(XA_WINDOW *wind);
void display_windows_below(XA_WINDOW *w);

#endif