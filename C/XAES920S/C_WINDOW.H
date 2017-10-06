/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _C_WINDOW_H_
#define _C_WINDOW_H_

RECT wa_to_curr(XA_WINDOW *wi, short d, RECT r);
XA_WINDOW *create_window(LOCK lock, SendMessage *message_handler,
						short pid,
						bool nolist,
						XA_WIND_ATTR tp,
						short frame,
						RECT r,
						RECT *max,
						RECT *rem);
XA_WINDOW *wind_find(LOCK lock, short x, short y);
XA_WINDOW *get_wind_by_handle(LOCK lock, short h);
XA_WINDOW *pull_wind_to_top(LOCK lock, XA_WINDOW *w);
void send_wind_to_bottom(LOCK lock, XA_WINDOW *w);
void move_window(LOCK lock, XA_WINDOW *wind, short newstate, short x, short y, short w, short h);
bool close_window(LOCK lock, XA_WINDOW *wind);
short open_window(LOCK lock, short clnt_pid, short wh, RECT r);
void delete_window(LOCK lock, XA_WINDOW *wind);
void display_non_topped_window(LOCK lock, short which, XA_WINDOW *w, RECT *clip);
void display_window(LOCK lock, XA_WINDOW *wind);
void display_windows_below(LOCK lock, RECT *r, XA_WINDOW *w);
void calc_window(short pid, short request, unsigned long tp, RECT *r, RECT *o);

/* HR */
XA_WINDOW *top_w(LOCK lock);
XA_WINDOW *root_w(LOCK lock);

void top_window(LOCK lock, XA_WINDOW *w, short menu_owner);
void bottom_window(LOCK lock, XA_WINDOW *w);
void after_top(LOCK lock, bool untop);
short menu_owner(void);
RECT fit_inside(RECT r, RECT o);
void wi_put_first(WIN_BASE *b, XA_WINDOW *w);
void wi_put_last(WIN_BASE *b, XA_WINDOW *w);
void wi_put_blast(WIN_BASE *b, XA_WINDOW *w);
void wi_remove(WIN_BASE *b, XA_WINDOW *w);
void wi_insert(WIN_BASE *b, XA_WINDOW *w, XA_WINDOW *after);
void wind_new(LOCK lock, short pid);
void inside_root(RECT *r);
void clear_wind_handles(void);		/* HR */
void send_ontop(LOCK lock);
void send_untop(LOCK lock, XA_WINDOW *wind);

void  __regargs bclr(unsigned long *row,long bit);
short __regargs btst(unsigned long *row,long bit);
void  __regargs bset(unsigned long *row,long bit);

#endif
