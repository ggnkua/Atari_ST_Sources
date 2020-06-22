/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "EVENT_Q.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"

/*
	evnt_button() routine
*/
unsigned long XA_evnt_button(short clnt_pid,AESPB *pb)
{
	clients[clnt_pid].waiting_for=XAWAIT_BUTTON;	/* Flag the app as waiting for messages */
	clients[clnt_pid].waiting_pb=pb;				/* Store a pointer to the AESPB to fill when the event */
													/*  finally arrives. */
	return XAC_BLOCK;	/* Returning FALSE blocks the client app to wait for the event */
}
