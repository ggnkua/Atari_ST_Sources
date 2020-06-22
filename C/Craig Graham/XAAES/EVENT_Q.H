/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	Event Wait Queues
*/

#ifndef _EVENT_Q_H_
#define _EVENT_Q_H_
#include "K_DEFS.H"

/* A queue of client processes that are waiting for an event */
typedef struct evnt_q {
	struct evnt_q *next;
	short pid;		/* Id of client that is waiting for an event */
	AESPB *pb;		/* pointer to the parameter block for the client */
} EVNT_Q;

void EQ_append(EVNT_Q **q, short id, AESPB *pb);
EVNT_Q *EQ_pull_head(EVNT_Q **q);

#endif