/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <SIGNAL.H>
#include "k_defs.h"
#include "xa_types.h"
#include "xa_globl.h"

/*
	Evnt_timer()
*/

unsigned long XA_evnt_timer(short clnt_pid, AESPB *pb)
{
	unsigned long ret;
	
	if (pb->intin[1])
		ret=0xffff0000L|XAC_T_TIMEOUT;
	else
		ret=((pb->intin[0])<<16)|XAC_T_TIMEOUT;
		
	clients[clnt_pid].waiting_pb=pb;			/* Store a pointer to the AESPB to fill when the event */
												/*  finally arrives. */
	clients[clnt_pid].waiting_for=XAWAIT_TIMER;	/* Flag the app as waiting for a timer */

	return ret;
}
