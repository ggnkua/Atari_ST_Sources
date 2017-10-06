/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _NEW_CLNT_H_
#define _NEW_CLNT_H_


char *getsuf(char *f);
char *get_procname(short pid);

void remove_refs(XA_CLIENT *client, bool secure);

#endif