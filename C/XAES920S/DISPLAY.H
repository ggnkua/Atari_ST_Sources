/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _DISPLAY_H_
#define _DISPLAY_H_


int display(const char *t, ...);
int sdisplay(char *s, const char *t, ...);
int vsdisplay(char *to, const char *f, void *sp);


#endif
