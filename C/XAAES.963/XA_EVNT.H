/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _XA_EVNT_H_
#define _XA_EVNT_H_

extern BUTTON pending_button;
void multi_intout(G_i *o, int evnt);  		/* HR: mouse data wasnt always filled out. 240401: state */
void cancel_evnt_multi(XA_CLIENT *client, int which);		/* HR */

void XA_keyboard_event(LOCK lock, KEY        *key);
void XA_button_event  (LOCK lock, MOOSE_DATA *md, bool widgets);
int  XA_move_event    (LOCK lock, MOOSE_DATA *md);
void XA_wheel_event   (LOCK lock, MOOSE_DATA *md);		/* HR 111002: wheel support */

bool  is_rect(G_i x, G_i y, int fl, RECT *o);
bool  is_bevent(int got, int clicks, G_i *o, int which);	/* HR */

void cancel_pending_button(void);		/* HR 070601 */

/* HR 050402: WDIAL */
void button_event(LOCK lock, XA_CLIENT *client, MOOSE_DATA *md);
void keybd_event(LOCK lock, XA_CLIENT *client, KEY *key);

#endif
