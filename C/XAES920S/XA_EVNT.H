/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_EVNT_H_
#define _XA_EVNT_H_

extern BUTTON pending_button;
void multi_intout(short *o, short evnt);  		/* HR: mouse data wasnt always filled out. 240401: state */
void cancel_evnt_multi(XA_CLIENT *client);		/* HR */

void  XA_keyboard_event(LOCK lock, KEY        *key);
short XA_button_event  (LOCK lock, MOOSE_DATA *md, bool widgets);
short XA_move_event    (LOCK lock, MOOSE_DATA *md);

bool  is_rect(short x, short y, short fl, RECT *o);
bool  is_bevent(short got, short clicks, short *o, short which);	/* HR */

void cancel_pending_button(void);		/* HR 070601 */

#endif
