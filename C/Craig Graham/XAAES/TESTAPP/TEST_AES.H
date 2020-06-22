#ifndef _TEST_AES_H_
#define _TEST_AES_H_

#include "../K_DEFS.H"

#define appl_init		Tappl_init
#define appl_exit		Tappl_exit

#define evnt_button		Tevnt_button
#define evnt_mesag		Tevnt_mesag

#define graf_mouse		Tgraf_mouse
#define graf_handle		Tgraf_handle
#define graf_mkstate	Tgraf_mkstate

#define wind_create		Twind_create
#define wind_open		Twind_open
#define wind_close		Twind_close
#define wind_set		Twind_set

short Tappl_init(void);
short Tappl_exit(void);
short Tevnt_button(short mc, short mask, short state, short *x, short *y, short *button, short *kstate);
short Tevnt_mesag(short *msg);
short Twind_create(short kind,short x, short y, short w, short h);
short Twind_open(short handle,short x, short y, short w, short h);
short Twind_close(short handle);
short Twind_set(short handle, short request, short x, short y, short w, short h);
short Tgraf_mouse(short number, void *addr);
short Tgraf_handle(short *wchar, short *hchar, short *wbox, short *hbox);
short Tgraf_mkstate(short *x, short *y, short *button, short *kstate);

#endif
