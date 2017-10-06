/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _MESSAGES_H_
#define _MESSAGES_H_
/* HR */

typedef struct msg_buffer
{
	short m[8];
} MSG_BUF;


typedef void __stdargs
SendMessage(LOCK lock, struct xa_window *w,
	short dest_pid, short msg, short source_pid, short mp3,
	short mp4, short mp5, short mp6, short mp7);

SendMessage send_app_message;

void send_a_message(LOCK lock, short dest, MSG_BUF *msg);

#endif
