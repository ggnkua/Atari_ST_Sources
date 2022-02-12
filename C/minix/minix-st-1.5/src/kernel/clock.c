/* This file contains the code and data for the clock task.  The clock task
 * has a single entry point, clock_task().  It accepts four message types:
 *
 *   HARD_INT:    a clock interrupt has occurred
 *   GET_TIME:    a process wants the real time
 *   SET_TIME:    a process wants to set the real time
 *   SET_ALARM:   a process wants to be alerted after a specified interval
 *
 * The input message is format m6.  The parameters are as follows:
 *
 *     m_type    CLOCK_PROC   FUNC    NEW_TIME
 * ---------------------------------------------
 * | SET_ALARM  | proc_nr  |f to call|  delta  |
 * |------------+----------+---------+---------|
 * | HARD_INT   |          |         |         |
 * |------------+----------+---------+---------|
 * | GET_TIME   |          |         |         |
 * |------------+----------+---------+---------|
 * | SET_TIME   |          |         | newtime |
 * ---------------------------------------------
 *
 * When an alarm goes off, if the caller is a user process, a SIGALRM signal
 * is sent to it.  If it is a task, a function specified by the caller will
 * be invoked.  This function may, for example, send a message, but only if
 * it is certain that the task will be blocked when the timer goes off.
 */

#include "kernel.h"
#include <signal.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

/* Constant definitions. */
#define MILLISEC         100	/* how often to call the scheduler (msec) */
#define SCHED_RATE (MILLISEC*HZ/1000)	/* number of ticks per schedule */

/* Clock parameters. */
#if (CHIP == INTEL)
#define COUNTER_FREQ (2*TIMER_FREQ)	/* counter frequency using sqare wave*/
#define LATCH_COUNT     0x00	/* cc00xxxx, c = channel, x = any */
#define SQUARE_WAVE     0x36	/* ccaammmb, a = access, m = mode, b = BCD */
				/*   11x11, 11 = LSB then MSB, x11 = sq wave */
#define TIMER_COUNT ((unsigned) (TIMER_FREQ/HZ)) /* initial value for counter*/
#define TIMER_FREQ   1193182L	/* clock frequency for timer in PC and AT */
#endif

#if (CHIP == M68000)
#define FLUSH_MASK      0x07	/* bit mask used for flushing RS232 input */
#define TIMER_FREQ   2457600L	/* timer 3 input clock frequency */
#endif

/* Clock task variables. */
PRIVATE time_t boot_time;	/* time in seconds of system boot */
PRIVATE time_t next_alarm;	/* probable time of next alarm */
PRIVATE time_t pending_ticks;	/* ticks seen by low level only */
PRIVATE time_t realtime;	/* real time clock */
PRIVATE int sched_ticks = SCHED_RATE;	/* counter: when 0, call scheduler */
PRIVATE struct proc *prev_ptr;	/* last user process run by clock task */
PRIVATE message mc;		/* message buffer for both input and output */
PRIVATE void (*watch_dog[NR_TASKS+1])();  /* watch_dog functions to call */

FORWARD void do_clocktick();
FORWARD void do_get_time();
FORWARD void do_set_time();
FORWARD void do_setalarm();
FORWARD void init_clock();

/*===========================================================================*
 *				clock_task				     *
 *===========================================================================*/
PUBLIC void clock_task()
{
/* Main program of clock task.  It determines which of the 4 possible
 * calls this is by looking at 'mc.m_type'.   Then it dispatches.
 */
 
  int opcode;

  init_clock();			/* initialize clock task */

  /* Main loop of the clock task.  Get work, process it, sometimes reply. */
  while (TRUE) {
     receive(ANY, &mc);		/* go get a message */
     opcode = mc.m_type;	/* extract the function code */

     lock();
     realtime += pending_ticks;	/* transfer ticks from low level handler */
     pending_ticks = 0;
     unlock();

     switch (opcode) {
	case SET_ALARM:	 do_setalarm(&mc);	break;
	case GET_TIME:	 do_get_time();		break;
	case SET_TIME:	 do_set_time(&mc);	break;
	case HARD_INT:   do_clocktick();	break;
	default: panic("clock task got bad message", mc.m_type);
     }

    /* Send reply, except for clock tick. */
    mc.m_type = OK;
    if (opcode != HARD_INT) send(mc.m_source, &mc);
  }
}


/*===========================================================================*
 *				do_setalarm				     *
 *===========================================================================*/
PRIVATE void do_setalarm(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* A process wants an alarm signal or a task wants a given watch_dog function
 * called after a specified interval.  Record the request and check to see
 * it is the very next alarm needed.
 */

  register struct proc *rp;
  int proc_nr;			/* which process wants the alarm */
  long delta_ticks;		/* in how many clock ticks does he want it? */
  void (*function)();		/* function to call (tasks only) */

  /* Extract the parameters from the message. */
  proc_nr = m_ptr->CLOCK_PROC_NR;	/* process to interrupt later */
  delta_ticks = m_ptr->DELTA_TICKS;	/* how many ticks to wait */
  function = m_ptr->FUNC_TO_CALL;	/* function to call (tasks only) */
  rp = proc_addr(proc_nr);
  mc.SECONDS_LEFT = (rp->p_alarm == 0L ? 0 : (rp->p_alarm - realtime)/HZ );
  rp->p_alarm = (delta_ticks == 0L ? 0L : realtime + delta_ticks);
  if (istaskp(rp)) watch_dog[-proc_nr] = function;

  /* Which alarm is next? */
  next_alarm = MAX_P_LONG;
  for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++)
	if(rp->p_alarm != 0 && rp->p_alarm < next_alarm)next_alarm=rp->p_alarm;

}


/*===========================================================================*
 *				do_get_time				     *
 *===========================================================================*/
PRIVATE void do_get_time()
{
/* Get and return the current clock time in ticks. */

  mc.m_type = REAL_TIME;	/* set message type for reply */
  mc.NEW_TIME = boot_time + realtime/HZ;	/* current real time */
}


/*===========================================================================*
 *				do_set_time				     *
 *===========================================================================*/
PRIVATE void do_set_time(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Set the real time clock.  Only the superuser can use this call. */

  boot_time = m_ptr->NEW_TIME - realtime/HZ;
}


/*===========================================================================*
 *				do_clocktick				     *
 *===========================================================================*/
PRIVATE void do_clocktick()
{
/* This routine called on clock ticks when a lot of work needs to be done. */

  register struct proc *rp;
  register int proc_nr;

  if (next_alarm <= realtime) {
	/* An alarm may have gone off, but proc may have exited, so check. */
	next_alarm = MAX_P_LONG;	/* start computing next alarm */
	for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++) {
		if (rp->p_alarm != (time_t) 0) {
			/* See if this alarm time has been reached. */
			if (rp->p_alarm <= realtime) {
				/* A timer has gone off.  If it is a user proc,
				 * send it a signal.  If it is a task, call the
				 * function previously specified by the task.
				 */
				if ( (proc_nr = proc_number(rp)) >= 0)
					cause_sig(proc_nr, SIGALRM);
				else
					(*watch_dog[-proc_nr])();
				rp->p_alarm = 0;
			}

			/* Work on determining which alarm is next. */
			if (rp->p_alarm != (time_t)0 && rp->p_alarm < next_alarm)
				next_alarm = rp->p_alarm;
		}
	}
  }

  /* If a user process has been running too long, pick another one. */
  if (--sched_ticks == 0) {
	if (bill_ptr == prev_ptr) lock_sched();	/* process has run too long */
	sched_ticks = SCHED_RATE;		/* reset quantum */
	prev_ptr = bill_ptr;			/* new previous process */
  }
#if (CHIP == M68000)
  if (rdy_head[SHADOW_Q]) unshadow(rdy_head[SHADOW_Q]);
#endif
}


#if (CHIP == INTEL)
/*===========================================================================*
 *				init_clock				     *
 *===========================================================================*/
PRIVATE void init_clock()
{
/* Initialize channel 0 of the 8253A timer to e.g. 60 Hz. */

  out_byte(TIMER_MODE, SQUARE_WAVE);	/* set timer to run continuously */
  out_byte(TIMER0, TIMER_COUNT);	/* load timer low byte */
  out_byte(TIMER0, TIMER_COUNT >> 8);	/* load timer high byte */
  enable_irq(CLOCK_IRQ);	/* ready for clock interrupts */
}


/*==========================================================================*
 *				milli_delay				    *
 *==========================================================================*/
PUBLIC void milli_delay(millisec)
unsigned millisec;
{
/* Delay some milliseconds (or longer - interrupts may interfere). */

  register unsigned count;
  register unsigned diff;
  unsigned prev_count;
  unsigned long total_count;

  total_count = (unsigned long) millisec * (COUNTER_FREQ / 1000);
  diff = 100;			/* guess for emergencies */
  prev_count = read_counter();
  while (TRUE) {
	count = read_counter();
	/* Use difference between counts unless counter has not changed
	 * (broken?) or has increased (due to reset).
	 */
	if (count < prev_count) diff = prev_count - count;
	if (diff >= total_count) break;
	total_count -= diff;
	prev_count = count;
  }
}


/*==========================================================================*
 *				read_counter				    *
 *==========================================================================*/
PUBLIC unsigned read_counter()
{
/* Read the counter for channel 0 of the 8253A timer. The counter decrements
 * at twice the timer frequency (one full cycle for each half of square wave).
 * The counter normally has a value between 0 and TIMER_COUNT, but before
 * the clock task has been initialized, its maximum value is 65535, as set by
 * the BIOS.
 */

  register unsigned low_byte;

  out_byte(TIMER_MODE, LATCH_COUNT);	/* make chip copy count to latch */
  low_byte = in_byte(TIMER0);	/* countdown continues during 2-step read */
  return((in_byte(TIMER0) << 8) + low_byte);
}
#endif

#if (CHIP == M68000)
#include "staddr.h"
#include "stmfp.h"

/*===========================================================================*
 *				init_clock				     *
 *===========================================================================*/
PRIVATE void init_clock()
{
/* Initialize the timer C in the MFP 68901.
 * Reducing to HZ is not possible by hardware.  The resulting interrupt
 * rate is further reduced by software with a factor of 4.
 * Note that the expression below works for both HZ=50 and HZ=60.
 */
  do
	MFP->mf_tcdr = TIMER_FREQ/(64*4*HZ);
  while ((MFP->mf_tcdr & 0xFF) != TIMER_FREQ/(64*4*HZ));
  MFP->mf_tcdcr |= (T_Q064<<4);
}
#endif

/*===========================================================================*
 *				clock_handler				     *
 *===========================================================================*/
PUBLIC void clock_handler()
{
/* Switch context to do_clocktick if an alarm has gone off.
 * Also switch there to reschedule if the reschedule will do something.
 * This happens when
 *	(1) quantum has expired
 *	(2) current process received full quantum (as clock sampled it!)
 *	(3) something else is ready to run.
 * Also call TTY and PRINTER and let them do whatever is necessary.
 *
 * Many global global and static variables are accessed here.  The safety
 * of this must be justified.  Most of them are not changed here:
 *	k_reenter:
 *		This safely tells if the clock interrupt is nested.
 *	proc_ptr, bill_ptr:
 *		These are used for accounting.  It does not matter if proc.c
 *		is changing them, provided they are always valid pointers,
 *		since at worst the previous process would be billed.
 *	next_alarm, realtime, sched_ticks, bill_ptr, prev_ptr,
 *	rdy_head[USER_Q]:
 *		These are tested to decide whether to call interrupt().  It
 *		does not matter if the test is sometimes (rarely) backwards
 *		due to a race, since this will only delay the high-level
 *		processing by one tick, or call the high level unnecessarily.
 * The variables which are changed require more care:
 *	rp->user_time, rp->sys_time:
 *		These are protected by explicit locks in system.c.  They are
 *		not properly protected in dmp.c (the increment here is not
 *		atomic) but that hardly matters.
 *	pending_ticks:
 *		This is protected by an explicit lock in clock.c.  Don't
 *		update realtime directly, since there are too many
 *		references to it to guard conveniently.
 *	sched_ticks, prev_ptr:
 *		Updating these competes with similar code in do_clocktick().
 *		No lock is necessary, because if bad things happen here
 *		(like sched_ticks going negative), the code in do_clocktick()
 *		will restore the variables to reasonable values, and an
 *		occasional missed or extra sched() is harmless.
 *
 * Are these complications worth the trouble?  Well, they make the system 15%
 * faster on a 5MHz 8088, and make task debugging much easier since there are
 * no task switches on an inactive system.
 */

  register struct proc *rp;

  /* Update user and system accounting times.
   * First charge the current process for user time.
   * If the current process is not the billable process (usually because it
   * is a task), charge the billable process for system time as well.
   * Thus the unbillable tasks' user time is the billable users' system time.
   */
  if (k_reenter != 0)
	rp = cproc_addr(HARDWARE);
  else
	rp = proc_ptr;
  ++rp->user_time;
  if (rp != bill_ptr) ++bill_ptr->sys_time;

  ++pending_ticks;
#if (CHIP != M68000)
  tty_wakeup();			/* possibly wake up TTY */
  pr_restart();			/* possibly restart printer */
#endif
#if (CHIP == M68000)
  kb_timer();			/* keyboard repeat */
  if (sched_ticks == 1) fd_timer();	/* floppy deselect */

  /* If input characters are accumulating on an RS232 line, process them. */
  if (flush_flag) {
	if ( (((int)(realtime+pending_ticks)) & FLUSH_MASK) == 0) rs_flush();
		 		/* only low-order bits of realtime mattered */
  }
#endif

  if (next_alarm <= realtime + pending_ticks ||
      sched_ticks == 1 &&
      bill_ptr == prev_ptr &&
#if (CHIP != M68000)
      rdy_head[USER_Q] != NIL_PROC) {
#else
      (rdy_head[USER_Q] != NIL_PROC || rdy_head[SHADOW_Q] != NIL_PROC)) {
#endif
	interrupt(CLOCK);
	return;
  }

  if (--sched_ticks == 0) {
	/* If bill_ptr == prev_ptr, no ready users so don't need sched(). */
	sched_ticks = SCHED_RATE;	/* reset quantum */
	prev_ptr = bill_ptr;		/* new previous process */
  }
}
