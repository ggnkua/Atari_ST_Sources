/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_MOUSE_H_
#define _XA_MOUSE_H_

void  XA_keyboard_event(LOCK lock, KEY        *key);
short XA_button_event  (LOCK lock, MOOSE_DATA *md);
short XA_move_event    (LOCK lock, MOOSE_DATA *md);

bool  is_rect(short x, short y, short fl, RECT *o);
bool  is_bevent(short got, short cliks, short clks, short msk, short st,short which);	/* HR */

#endif
