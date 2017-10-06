/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _DESKTOP_H_
#define _DESKTOP_H_

void set_desktop(OBJECT *);
OBJECT *get_desktop(void);
OBJECT *get_xa_desktop(void);
#endif
