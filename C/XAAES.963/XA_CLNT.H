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

#ifndef _NEW_CLNT_H_
#define _NEW_CLNT_H_


char *getsuf(char *f);
char *chsuf(char *f, char *suf);
char *get_procname(short pid);

void remove_refs(XA_CLIENT *client, bool secure);
void get_app_options(XA_CLIENT *client);

XA_CLIENT *NewClient(int clnt_pid);
void      FreeClient(LOCK lock, XA_CLIENT *client);

bool is_client(XA_CLIENT *client);

#endif