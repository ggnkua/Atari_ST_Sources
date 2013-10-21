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

#ifndef _XA_GLOBL_H_
#define _XA_GLOBL_H_

#include "kernel.h"

/*
 *	GLOBAL VARIABLES AND DATA STRUCTURES
 */

extern CFG cfg;
extern OPT default_options;
extern COMMON C;
extern SHARED S;

extern XA_SCREEN screen;				/* The screen descriptor */
extern XA_PENDING_WIDGET widget_active;	/* HR 0050601 */

/* Martin's stuff to help get rid of the clients array */
/* It is now:
   Henk's   stuff to get rid of the clients array :-) */
/* HR: what remains is a static pid array. :-)	*/

#if GENERATE_DIAGS
	XA_CLIENT *pid2client(int,char *,int);
	#define Pid2Client(pid) pid2client((pid),__FILE__,__LINE__)
#else
	#define Pid2Client(pid) S.Clients[pid]
#endif

#define Client2Pid(client_p) ((client_p)->pid)
void strnupr(char *, int n);
long clock(void);
bool xa_invalid(int which, int pid, void *addr, long size, bool allownil);

extern BUTTON button;			/* HR 180601 */
extern XA_TREE nil_tree;

#endif
