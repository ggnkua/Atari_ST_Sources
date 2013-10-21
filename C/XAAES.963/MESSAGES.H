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

#ifndef _MESSAGES_H_
#define _MESSAGES_H_
/* HR */

typedef union msg_buffer
{
	G_i m[8];
	struct
	{
		G_i msg, src, m2, m3;
		void *p1, *p2;
	} s;
} MSG_BUF;


typedef void
SendMessage(
	LOCK lock,
	struct xa_window *wind,
	struct xa_client *to,			/* if different from wind->owner */
	G_i mp0, G_i mp1, G_i mp2, G_i mp3,
	G_i mp4, G_i mp5, G_i mp6, G_i mp7);

SendMessage send_app_message;

void send_a_message(LOCK lock, G_i dest, MSG_BUF *msg);

#endif
