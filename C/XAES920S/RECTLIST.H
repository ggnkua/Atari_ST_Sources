/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _RECTLIST_H_
#define _RECTLIST_H_
#include "xa_defs.h"

bool rc_intersect(const RECT *s, RECT *d);
XA_RECT_LIST *generate_rect_list(LOCK lock, XA_WINDOW *w);
void dispose_rect_list(XA_WINDOW *w);

XA_RECT_LIST *rect_get_user_first(XA_WINDOW *w);
XA_RECT_LIST *rect_get_user_next(XA_WINDOW *w);
XA_RECT_LIST *rect_get_system_first(XA_WINDOW *w);
XA_RECT_LIST *rect_get_system_next(XA_WINDOW *w);

#endif
