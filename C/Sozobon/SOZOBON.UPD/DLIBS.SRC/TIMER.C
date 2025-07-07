#include <time.h>

clock_t	clock()
/*
 *	Return current value of 200Hz timer.  This is the ANSI compatible
 *	timer function.  The number of seconds elapsed between two events
 *	can be determined by calling this function twice and dividing the
 *	difference between the two times by CLK_TCK (200L).
 */
	{
	asm("	clr.l	-(sp)		");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* enter supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	$4BA,-(sp)	");	/* save system clock value */
	asm("	move.l	d0,-(sp)	");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* exit supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	(sp)+,d0	");	/* return system clock value */
	}

clock_t start_timer(t)
	clock_t *t;
/*
 *	Start a 200Hz timer.  This timer value can later be checked with
 *	time_since() to determine elapsed time.  These functions provide
 *	a very low-overhead way of timing events.
 */
	{
	asm("	clr.l	-(sp)		");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* enter supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	$4BA,-(sp)	");	/* save system clock value */
	asm("	move.l	d0,-(sp)	");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* exit supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	(sp)+,d0	");
	asm("	move.l	$8(a6),a0	");	/* grab pointer to timer */
	asm("	move.l	d0,(a0)		");	/* return clock value */
	}

clock_t time_since(t)
	clock_t *t;
/*
 *	Returns the number of 200Hz ticks since start_timer() was called
 *	for timer <t>.
 */
	{
	asm("	clr.l	-(sp)		");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* enter supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	$4BA,-(sp)	");	/* save system clock value */
	asm("	move.l	d0,-(sp)	");
	asm("	move.w	#$20,-(sp)	");
	asm("	trap	#1		");	/* exit supervisor mode */
	asm("	addq.l	#6,sp		");
	asm("	move.l	(sp)+,d0	");
	asm("	move.l	$8(a6),a0	");	/* grab pointer to timer */
	asm("	sub.l	(a0),d0		");	/* return elapsed time */
	}

sleep(dt)
	int dt;
/*
 *	Suspend operation for <dt> seconds.  This is implemented as a
 *	start_timer()/time_since() tight loop waiting for the specified
 *	amount of time to pass.  In a multi-tasking environment, this
 *	function should be replaced by a call which will de-activate
 *	this task for a period of time, allowing other tasks to run.
 */
	{
	clock_t t, start_timer(), time_since();
	register clock_t tt;

	tt = ((clock_t) dt) * CLK_TCK;
	start_timer(&t);
	while(time_since(&t) < tt)
		;
	}

usleep(dt)
	int dt;
/*
 *	Suspend operation for <dt> microseconds.  Works like sleep().
 */
	{
	clock_t t, start_timer(), time_since();
	register clock_t tt;

	tt = ((clock_t) dt) * (CLK_TCK / ((clock_t) 100));
	start_timer(&t);
	while(time_since(&t) < tt)
		;
	}
