/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <memory.h>
#include "event_q.h"
#include "xa_defs.h"
#include "k_defs.h"

/*
 *	Event queue support routines
 */

void EQ_append(EVNT_Q **q, short id, AESPB *pb)
{
	EVNT_Q *n, *c;
	
	c = (EVNT_Q *)malloc(sizeof(EVNT_Q));	/* Create new event queue entry */

	if (!c)
		return;

	c->next = NULL;
	c->pid = id;
	c->pb = pb;
	
	if (*q == NULL)	/* new list? */
	{
		*q = c;
		return;
	}
	
	for(n = *q; n->next != NULL; n = n->next)	/* Find end of list */
		;
	n->next = c;		/* Append entry */
}

EVNT_Q *EQ_pull_head(EVNT_Q **q)
{
	EVNT_Q *r;
	
	r = *q;
	
	if (r != NULL)
		*q = r->next;
	
	return r;
}
