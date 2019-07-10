/*
 * event.h -- Event handler definitions
 *
 * 88Jan09 orc	TODAY() macro added for day-selectable events
 * 87Oct27 orc	Extracted from ctdl.h
 */

#ifndef _EVENT_H
#define _EVENT_H

/* #event type [days] time "name" flags */

struct evt_type {
    int evtTime;		/* minutes after midnight.		*/
    char evtDay;		/* what days the event can happen	*/
				/* (bitfield: 76543210)			*/
				/*             SFRWTMS			*/
    short evtType;		/* type of event:			*/
#define EVENT_NETWORK	0		/* invoke citadel networker	*/
#define EVENT_PREEMPTIVE 1		/* preemptive event		*/
#define EVENT_TIMEOUT	2		/* nonpreemptive event		*/

    int evtLen;			/* How long this event is expected to	*/
				/* last.				*/

    LABEL evtMsg;		/* message citadel gives you before it	*/
				/* punts you into never-never land.	*/
				/* It will be printed in the form	*/
				/* "system going down at %d:%d for %s".	*/

    int evtRel;			/* relative event flag for timeouts	*/
				/* if this flag is set, citadel will	*/
				/* find evtTime by adding evtRel to	*/
				/* curTime()				*/

    short evtFlags;		/* special event flags for the net:	*/
				/* return code for everything else	*/
} ;

#define	TODAY(x, d)	((x).evtDay & (1<<(d)))
#define	isNetwork(x)	((x)->evtType == EVENT_NETWORK)
#define	isPreemptive(x)	(isNetwork(x) || (x)->evtType == EVENT_PREEMPTIVE)

#endif
