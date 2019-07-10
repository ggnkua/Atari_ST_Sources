/*
 * libevent.c -- Code to handle events
 *
 * 90Nov07 AA	We've got ANSI C.  (-:
 * 88Aug28 orc	minutes() parameter mismatch fixed (I want ANSI C!)
 * 88Jan08 orc	Support for day-selectable events added in
 * 87May25 orc	Created.
 */

#include "ctdl.h"
#include "event.h"
#include "config.h"
#include "citlib.h"

/*
 * initEvent()	Initialise the event table.
 * setUpEvent()	Set up next event.
 * doEvent()	Do an event.
 */

struct evt_type *nextEvt;	/* next event to execute		*/
int evtRunning = FALSE;		/* an event is waiting			*/
char forceOut;			/* next event is preemptive		*/
long evtClock;			/* time when next event takes place	*/
long evtTrig;			/* timeLeft trigger for warnings	*/

char evtChar[] = { 'N', 'P', 'T', 'S' };

extern char warned;		/* warning flag... */

#define hour(x)	((x) % (24*60))

int
minutes(int *today)
{
    timeis(&now);
    *today = now.tm_wday;
    return (60 * now.tm_hour) + now.tm_min;
}

int
event_pending(int warn)
{
    if (evtRunning && cfg.evtclosetime > 0) {	/* check for close events */
	long timeTil = timeLeft(evtClock);	/* in seconds */

	if (timeTil < (long)cfg.evtclosetime) {
	    if (warn) {
		long hr, min, sec;
	    
	    	sec = timeTil % 60L; timeTil /= 60L;
	    	min = timeTil % 60L; timeTil /= 60L;
	    	hr = timeTil;
	    
	    	mprintf("Sorry, event `%s' goes off in ", nextEvt->evtMsg);
	    	if (hr > 0)
		    mprintf("%s, ", plural ("hour", hr));
	    	if (min > 0)
	    	    mprintf("%s, ", plural ("minute", min));
	    	mprintf("%s\r", plural ("second", sec));
	    }
	    return YES;
	}
    }
    return NO;
}

/*
 * initEvent() - initializes the event table
 */
static int
evtSort(const struct evt_type *p1, const struct evt_type *p2)
{
    register int diff = p1->evtTime - p2->evtTime;

    if (diff > 0)
	return 1;
    else if (diff < 0)
	return -1;
    return 0;
}

void
initEvent(void)
{
    int i, dummy;

    if (cfg.evtCount > 0) {
	for (i=0; i<cfg.evtCount; i++)
	    if (evtTab[i].evtRel)
		evtTab[i].evtTime = hour(minutes(&dummy) + evtTab[i].evtRel);
	qsort((void *)evtTab, (size_t)cfg.evtCount, sizeof(*evtTab),
	    (int (*)(const void *, const void *))evtSort);
	setUpEvent();
    }
}

/*
 * setUpEvent() - set up timers for the next event
 */
void
setUpEvent(void)
{
    register int count, rover, day;
    register int timeNow;
    register int start;	int end;
    long upTime();
    int today;

    evtRunning = FALSE;
    evtClock = upTime();
    timeNow = minutes(&today);

    if (cfg.evtCount > 0) {
	/* search for events that are active for each day in the week */

	for (day=today, count=0; count < 7; count++, day = (1+day)%7) {
	    for (rover=0; rover < cfg.evtCount; rover++) {
		nextEvt = &evtTab[rover];
		if (TODAY(*nextEvt, day) == 0)
		    continue;

		start = nextEvt->evtTime;
		end   = hour(start + nextEvt->evtLen);
		if (timeNow < start || timeNow < end) {	/* found one... */
		    evtClock += (start-timeNow) * 60L;
		    evtRunning = TRUE;
		    if (forceOut = isPreemptive(nextEvt)) {
			warned = FALSE;
			evtTrig = 300L;
		    }
		    else
			evtTrig = 0L;
		    return;
		}
	    }
	    timeNow -= 24*60;	/* checking a day ahead so back off the */
				/* desired time to yesterday...		*/
	}
    }
}

/*
 * doEvent() - do an event.
 */
void
doEvent(void)
{
    extern char Abandon, eventExit;
    extern int exitValue;

    eventExit = warned = FALSE;
    exitValue = nextEvt->evtFlags;

    if (evtRunning)
	if (nextEvt->evtType == EVENT_NETWORK) {
	    netmode(nextEvt->evtLen, exitValue);
	    setUpEvent();
	}
	else
	    Abandon = TRUE;
}
