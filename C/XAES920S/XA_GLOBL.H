/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_GLOBL_H_
#define _XA_GLOBL_H_

#include "kernel.h"

/*
 *	GLOBAL VARIABLES AND DATA STRUCTURES
 */

extern CFG cfg;
extern COMMON C;
extern SHARED S;

extern XA_SCREEN screen;				/* The screen descriptor */
extern XA_PENDING_WIDGET widget_active;	/* HR 0050601 */

/* Martin's stuff to help get rid of the clients array */
/* It is now:
   Henk's   stuff to get rid of the clients array :-) */
/* HR: what remains is a static pid array. :-)	*/

void NoClient(XA_CLIENT *client);	/* initialize a client */

XA_CLIENT *NewClient(short clnt_pid);
void      FreeClient(LOCK lock, XA_CLIENT *client);
#if GENERATE_DIAGS
	XA_CLIENT *pid2client(short,char *,int);
	#define Pid2Client(pid) pid2client((pid),__FILE__,__LINE__)
#else
	#define Pid2Client(pid) S.Clients[pid]
#endif

#define Client2Pid(client_p) ((client_p)->pid)
bool is_client(XA_CLIENT *client);

void strnupr(char *, short n);
long clock(void);
bool xa_invalid(short which, short pid, void *addr, long size, bool allownil);

extern BUTTON button;			/* HR 180601 */

#endif
