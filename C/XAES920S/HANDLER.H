/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _HANDLER_H_
#define _HANDLER_H_

void hook_into_vector(void);
void asm_hook_into_vector(void);
void unhook_from_vector(void);
bool   lock_screen(short pid, long time_out, short *r);		/* HR 050201: internal functions. */
void unlock_screen(short pid);

#endif
