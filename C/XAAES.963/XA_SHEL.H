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

#ifndef _XA_SHEL_H_
#define _XA_SHEL_H_

int drive_and_path(char *fname, char *path, char *name, bool n, bool set);
int launch(LOCK lock, G_i mode, G_i wisgr, G_i wiscr, char *parm, char *tail, XA_CLIENT *caller);
int copy_env(char *to, char *s[], char *without, char **last);		/* HR */
long count_env(char *s[], char *without);				/* HR */
char *get_env(LOCK lock, const char *name);				/* HR */
long put_env(LOCK lock, G_i wisgr, G_i wiscr, char *cmd);		/* HR */
char *shell_find(LOCK lock, XA_CLIENT *client, char *fn);	/* HR */
XA_CLIENT * xa_fork_exec(G_i x_mode, XSHELW *xsh, char *fname, char *tail);

#endif
