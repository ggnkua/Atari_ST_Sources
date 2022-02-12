/* This file contains the code and data for the clock task.  The clock task
 * accepts six message types:
 *
 *   HARD_INT:    a clock interrupt has occurred
 *   GET_UPTIME:  get the time since boot in ticks
 *   GET_TIME:    a process wants the real time in seconds
 *   SET_TIME:    a process wants to set the real time in seconds
 *   SET_ALARM:   a process wants to be alerted after a specified interval
 *   SET_SYN_AL:  set the sync alarm
 *
 *
 * The input message is format m6.  The parameters are as follows:
 *
 *     m_type    CLOCK_PROC   FUNC    NEW_TIME
 * ---------------------------------------------
 * | HARD_INT   |          |         |         |
 * |------------+----------+---------+---------|
 * | GET_UPTIME |          |         |         |
 * |------------+----------+---------+---------|
 * | GET_TIME   |          |         |         |
 * |------------+----------+---------+---------|
 * | SET_TIME   |          |         | newtime |
 * |------------+----------+---------+---------|
 * | SET_ALARM  | proc_nr  |f to call|  delta  |
 * |------------+----------+---------+---------|
 * | SET_SYN_AL | proc_nr  |         |  delta  |
 * ---------------------------------------------
 * NEW_TIME, DELTA_CLICKS, and SECONDS_LEFT all refer to the same field in
 * the message, depending upon the message type.
 *
 * Reply messages are of type OK, except in the case of a HARD_INT, to
 * which no reply is generated. For the GET_* messages the time is returned
 * in the NEW_TIME field, and for the SET_ALARM and SET_SYN_AL the time
 * in seconds remaining until the alarm is returned is returned in the same
 * field.
 *
 * When an alarm goes off, if the caller is a user process, a SIGALRM signal
 * is sent to it.  If it is a task, a function specified by the caller will
 * be invoked.  This function may, for example, send a message, but only if
 * it is certain that the task will be blocked when the timer goes off. A
 * synchronous alarm sends a message to the synchronous alarm task, which
 * in turn can dispatch a message to another server. This is the only way
 * to send an alarm to a server, since servers cannot use the function-call
 * mechanism available to tasks and servers cannot receive signals.
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
#define TIMER_FREQ  1193182L	/* clock frequency for timer in PC and AT */

#define CLOCK_ACK_BIT	0x80	/* PS/2 clock interrupt acknowledge bit */
#endif

#if (CHIP == M68000)
#define TIMER_FREQ  2457600L	/* timer 3 input clock frequency */
#endif

/* Clock task variables. */
PRIVATE clock_t realtime;	/* real time clock */
PRIVATE time_t boot_time;	/* time in seconds of system boot */
PRIVATE clock_t next_alarm;	/* probable time of next alarm */
PRIVATE message mc;		/* message buffer for both input and output */
PRIVATE int watchdog_proc;	/* contains proc_nr at call of *watch_dog[]*/
PRIVATE watchdog_t watch_dog[NR_TASKS+NR_PROCS];

/* Variables used by both clock task and synchronous alarm task */
PRIVATE int syn_al_alive= TRUE; /* don't wake syn_alrm_task before inited*/
PRIVATE int syn_table[NR_TASKS+NR_PROCS]; /* which tasks get CLOCK_INT*/

/* Variables changed by interrupt handler */
PRIVATE clock_t pending_ticks;	/* ticks seen by low level only */
PRIVATE int sched_ticks = SCHED_RATE;	/* counter: when 0, call scheduler */
PRIVATE struct proc *prev_ptr;	/* last user process run by clock task */

FORWARD _PROTOTYPE( void common_setalarm, (int proc_nr,
		long delta_ticks, watchdog_t fuction) );
FORWARD _PROTOTYPE( void do_clocktick, (void) );
FORWARD _PROTOTYPE( void do_get_time, (void) );
FORWARD _PROTOTYPE( void do_getuptime, (void) );
FORWARD _PROTOTYPE( void do_set_time, (message *m_ptr) );
FORWARD _PROTOTYPE( void do_setalarm, (message *m_ptr) );
FORWARD _PROTOTYPE( void init_clock, (void) );
FORWARD _PROTOTYPE( void cause_alarm, (void) );
FORWARD _PROTOTYPE( void do_setsyn_alrm, (message *m_ptr) );
FORWARD _PROTOTYPE( int clock_handler, (int irq) );

/*===========================================================================*
 *				clock_task				     *
 *===========================================================================*/
PUBLIC void clock_task()
{
/* Main program of clock task.  It corrects realtime by adding pending
 * ticks seen only by the interrupt service, then it determines which
 * of the 6 possible calls this is by looking at 'mc.m_type'.  Then
 * it dispatches.
 */

  int opcode;

  init_clock();			/* initialize clock task */

  /* Main loop of the clock task.  Get work, process it, sometimes reply. */
  while (TRUE) {
     receive(ANY, &mc);		/* go get a message */
     opcode = mc.m_type;	/* extract the function code */

     lock();
     realtime += pending_ticks;	/* transfer ticks from low level handler */
     pending_ticks = 0;		/* so we don't have to worry about them */
     unlock();

     switch (opcode) {
	case HARD_INT:   do_clocktick();	break;
	case GET_UPTIME: do_getuptime();	break;
	case GET_TIME:	 do_get_time();		break;
	case SET_TIME:	 do_set_time(&mc);	break;
	case SET_ALARM:	 do_setalarm(&mc);	break;
	case SET_SYNC_AL:do_setsyn_alrm(&mc);	break;
	default: panic("clock task got bad message", mc.m_type);
     }

    /* Send reply, except for clock tick. */
    mc.m_type = OK;
    if (opcode != HARD_INT) send(mc.m_source, &mc);
  }
}


/*===========================================================================*
 *				do_clocktick				     *
 *===========================================================================*/
PRIVATE void do_clocktick()
{
/* Despite its name, this routine is not called on every clock tick. It
 * is called on those clock ticks when a lot of work needs to be done.
 */

  register struct proc *rp;
  register int proc_nr;

  if (next_alarm <= realtime) {
	/* An alarm may have gone off, but proc may have exited, so check. */
	next_alarm = LONG_MAX;	/* start computing next alarm */
	for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++) {
		if (rp->p_alarm != 0) {
			/* See if this alarm time has been reached. */
			if (rp->p_alarm <= realtime) {
				/* A timer has gone off.  If it is a user proc,
				 * send it a signal.  If it is a task, call the
				 * function previously specified by the task.
				 */
				proc_nr = proc_number(rp);
				if (watch_dog[proc_nr+NR_TASKS]) {
					watchdog_proc= proc_nr;
					(*watch_dog[proc_nr+NR_TASKS])();
				}
				else
					cause_sig(proc_nr, SIGALRM);
				rp->p_alarm = 0;
			}

			/* Work on determining which alarm is next. */
			if (rp->p_alarm != 0 && rp->p_alarm < next_alarm)
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
#if (SHADOWING == 1)
  if (rdy_head[SHADOW_Q]) unshadow(rdy_head[SHADOW_Q]);
#endif
}


/*===========================================================================*
 *				do_getuptime				     *
 *===========================================================================*/
PRIVATE void do_getuptime()
{
/* Get and return the current clock uptime in ticks. */

  mc.NEW_TIME = realtime;	/* current uptime */
}


/*===========================================================================*
 *				get_uptime				     *
 *===========================================================================*/
PUBLIC clock_t get_uptime()
{
/* Get and return the current clock uptime in ticks.  This function is
 * designed to be called from other tasks, so they can get uptime without
 * the overhead of messages. It has to be careful about pending_ticks.
 */

  clock_t uptime;

  lock();
  uptime = realtime + pending_ticks;
  unlock();
  return(uptime);
}


/*===========================================================================*
 *				do_get_time				     *
 *===========================================================================*/
PRIVATE void do_get_time()
{
/* Get and return the current clock time in seconds. */

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
 *				do_setalarm				     *
 *===========================================================================*/
PRIVATE void do_setalarm(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* A process wants an alarm signal or a task wants a given watch_dog function
 * called after a specified interval.
 */

  register struct proc *rp;
  int proc_nr;			/* which process wants the alarm */
  long delta_ticks;		/* in how many clock ticks does he want it? */
  watchdog_t function;		/* function to call (tasks only) */

  /* Extract the parameters from the message. */
  proc_nr = m_ptr->CLOCK_PROC_NR;	/* process to interrupt later */
  delta_ticks = m_ptr->DELTA_TICKS;	/* how many ticks to wait */
  function = (watchdog_t) m_ptr->FUNC_TO_CALL;
					/* function to call (tasks only) */
  rp = proc_addr(proc_nr);
  mc.SECONDS_LEFT = (rp->p_alarm == 0 ? 0 : (rp->p_alarm - realtime)/HZ );
  if (!istaskp(rp)) function= 0;	/* user processes get signaled */
  common_setalarm(proc_nr, delta_ticks, function);
}


/*===========================================================================*
 *				do_setsyn_alrm				     *
 *===========================================================================*/
PRIVATE void do_setsyn_alrm(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* A process wants a synchronous alarm.
 */

  register struct proc *rp;
  int proc_nr;			/* which process wants the alarm */
  long delta_ticks;		/* in how many clock ticks does he want it? */

  /* Extract the parameters from the message. */
  proc_nr = m_ptr->CLOCK_PROC_NR;	/* process to interrupt later */
  delta_ticks = m_ptr->DELTA_TICKS;	/* how many ticks to wait */
  rp = proc_addr(proc_nr);
  mc.SECONDS_LEFT = (rp->p_alarm == 0 ? 0 : (rp->p_alarm-realtime+HZ-1)/HZ);
  common_setalarm(proc_nr, delta_ticks, cause_alarm);
}


/*===========================================================================*
 *				common_setalarm				     *
 *===========================================================================*/
PRIVATE void common_setalarm(proc_nr, delta_ticks, function)
int proc_nr;			/* which process wants the alarm */
long delta_ticks;		/* in how many clock ticks does he want it? */
watchdog_t function;		/* function to call (0 if cause_sig is
				 * to be called */
{
/* Finish up work of do_set_alarm and do_setsyn_alrm.  Record an alarm
 * request and check to see if it is the next alarm needed.
 */

  register struct proc *rp;

  rp = proc_addr(proc_nr);
  rp->p_alarm = (delta_ticks == 0 ? 0 : realtime + delta_ticks);
  watch_dog[proc_nr+NR_TASKS] = function;

  /* Which alarm is next? */
  next_alarm = LONG_MAX;
  for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++)
	if(rp->p_alarm != 0 && rp->p_alarm < next_alarm)next_alarm=rp->p_alarm;

}


/*===========================================================================*
 *				cause_alarm				     *
 *===========================================================================*/
PRIVATE void cause_alarm()
{
/* Routine called if a timer goes off and the process requested a synchronous
 * alarm. The process number is in the global variable watchdog_proc (HACK).
 */
  message mess;

  syn_table[watchdog_proc + NR_TASKS]= TRUE;
  if (!syn_al_alive) send (SYN_ALRM_TASK, &mess);
}


/*===========================================================================*
 *				syn_alrm_task				     *
 *===========================================================================*/
PUBLIC void syn_alrm_task()
{
/* Main program of the synchronous alarm task.
 * This task receives messages only from cause_alarm in the clock task.
 * It sends a CLOCK_INT message to a process that requested a syn_alrm.
 * Synchronous alarms are so called because, unlike a signals or the
 * activation of a watchdog, a synchronous alarm is received by a process
 * when it is in a known part of its code, that is, when it has issued
 * a call to receive a message.
 */

  message mess;
  int work_done;	/* ready to sleep ? */
  int *al_ptr;		/* pointer in syn_table */
  int i;

  syn_al_alive= TRUE;
  for (i= 0, al_ptr= syn_table; i<NR_TASKS+NR_PROCS; i++, al_ptr++)
	*al_ptr= FALSE;

  while (TRUE) {
	work_done= TRUE;
	for (i= 0, al_ptr= syn_table; i<NR_TASKS+NR_PROCS; i++, al_ptr++)
		if (*al_ptr) {
			*al_ptr= FALSE;
			mess.m_type= CLOCK_INT;
			send (i-NR_TASKS, &mess);
			work_done= FALSE;
		}
	if (work_done) {
		syn_al_alive= FALSE;
		receive (CLOCK, &mess);
		syn_al_alive= TRUE;
	}
  }
}


/*===========================================================================*
 *				clock_handler				     *
 *===========================================================================*/
PRIVATE int clock_handler(irq)
int irq;
{
/* This executes on every clock tick (i.e., every time the timer chip
 * generates an interrupt). It does a little bit of work so the clock
 * task does not have to be called on every tick.
 *
 * Switch context to do_clocktick if an alarm has gone off.
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
 *		This is protected by explicit locks in clock.c.  Don't
 *		update realtime directly, since there are too many
 *		references to it to guard conveniently.
 *	lost_ticks:
 *		Clock ticks counted outside the clock task.
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
  register unsigned ticks;
  clock_t now;

  if (ps_mca) {
	/* Acknowledge the PS/2 clock interrupt. */
	out_byte(PORT_B, in_byte(PORT_B) | CLOCK_ACK_BIT);
  }

  /* Update user and system accounting times.
   * First charge the current process for user time.
   * If the current process is not the billable process (usually because it
   * is a task), charge the billable process for system time as well.
   * Thus the unbillable tasks' user time is the billable users' system time.
   */
  if (k_reenter != 0)
	rp = proc_addr(HARDWARE);
  else
	rp = proc_ptr;
  ticks = lost_ticks + 1;
  lost_ticks = 0;
  rp->user_time += ticks;
  if (rp != bill_ptr && rp != proc_addr(IDLE)) bill_ptr->sys_time += ticks;

  pending_ticks += ticks;
  now = realtime + pending_ticks;
  if (tty_timeout <= now) tty_wakeup(now);	/* possibly wake up TTY */
#if (CHIP != M68000)
  pr_restart();					/* possibly restart printer */
#endif
#if (CHIP == M68000)
  kb_timer();					/* keyboard repeat */
  if (sched_ticks == 1) fd_timer();		/* floppy deselect */
#endif

  if (next_alarm <= now ||
      sched_ticks == 1 &&
      bill_ptr == prev_ptr &&
#if (SHADOWING == 0)
      rdy_head[USER_Q] != NIL_PROC) {
#else
      (rdy_head[USER_Q] != NIL_PROC || rdy_head[SHADOW_Q] != NIL_PROC)) {
#endif
	interrupt(CLOCK);
	return 1;	/* Reenable interrupts */
  }

  if (--sched_ticks == 0) {
	/* If bill_ptr == prev_ptr, no ready users so don't need sched(). */
	sched_ticks = SCHED_RATE;	/* reset quantum */
	prev_ptr = bill_ptr;		/* new previous process */
  }
  return 1;	/* Reenable clock interrupt */
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
  put_irq_handler(CLOCK_IRQ, clock_handler);	/* set the interrupt handler */
  enable_irq(CLOCK_IRQ);		/* ready for clock interrupts */
}


/*===========================================================================*
 *				clock_stop				     *
 *===========================================================================*/
PUBLIC void clock_stop()
{
/* Reset the clock to the BIOS rate. (For rebooting) */

  out_byte(TIMER_MODE, 0x36);
  out_byte(TIMER0, 0);
  out_byte(TIMER0, 0);
}


/*==========================================================================*
 *				milli_delay				    *
 *==========================================================================*/
PUBLIC void milli_delay(millisec)
unsigned millisec;
{
/* Delay some milliseconds. */

  struct milli_state ms;

  milli_start(&ms);
  while (milli_elapsed(&ms) < millisec) {}
}

/*==========================================================================*
 *				milli_start				    *
 *==========================================================================*/
PUBLIC void milli_start(msp)
struct milli_state *msp;
{
/* Prepare for calls to milli_elapsed(). */

  msp->prev_count = 0;
  msp->accum_count = 0;
}


/*==========================================================================*
 *				milli_elapsed				    *
 *==========================================================================*/
PUBLIC unsigned milli_elapsed(msp)
struct milli_state *msp;
{
/* Return the number of milliseconds since the call to milli_start().  Must be
 * polled rapidly.
 */
  unsigned count;

  /* Read the counter for channel 0 of the 8253A timer.  The counter
   * decrements at twice the timer frequency (one full cycle for each
   * half of square wave).  The counter normally has a value between 0
   * and TIMER_COUNT, but before the clock task has been initialized,
   * its maximum value is 65535, as set by the BIOS.
   */
  out_byte(TIMER_MODE, LATCH_COUNT);	/* make chip copy count to latch */
  count = in_byte(TIMER0);	/* countdown continues during 2-step read */
  count |= in_byte(TIMER0) << 8;

  /* Add difference between previous and new count unless the counter has
   * increased (restarted its cycle).  We may lose a tick now and then, but
   * microsecond precision is not needed.
   */
  msp->accum_count += count <= msp->prev_count ? (msp->prev_count - count) : 1;
  msp->prev_count = count;

  return msp->accum_count / (TIMER_FREQ / 1000);
}
#endif /* (CHIP == INTEL) */


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
  do {
	MFP->mf_tcdr = TIMER_FREQ/(64*4*HZ);
  } while ((MFP->mf_tcdr & 0xFF) != TIMER_FREQ/(64*4*HZ));
  MFP->mf_tcdcr |= (T_Q064<<4);
}
#endif /* (CHIP == M68000) */
