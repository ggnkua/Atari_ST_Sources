/* This file contains the code and data for the clock task.  The clock task
 * accepts six message types:
 *
 *   HARD_INT:    a clock interrupt has occurred
 *   GET_UPTIME:  get the time since boot in ticks
 *   GET_TIME:    a process wants the real time in seconds
 *   SET_TIME:    a process wants to set the real time in seconds
 *   SET_ALARM:   a process wants to be alerted after a specified interval
 *   SET_SYNC_AL: set the sync alarm
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
 * | SET_ALARM  | proc_nr  |         |  delta  |
 * |------------+----------+---------+---------|
 * | SET_SYNC_AL| proc_nr  |         |  delta  |
 * ---------------------------------------------
 * NEW_TIME, DELTA_CLICKS, and SECONDS_LEFT all refer to the same field in
 * the message, depending upon the message type.
 *
 * Reply messages are of type OK, except in the case of a HARD_INT, to
 * which no reply is generated. For the GET_* messages the time is returned
 * in the NEW_TIME field, and for the SET_ALARM and SET_SYNC_AL the time
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
#include <stddef.h>
#include <signal.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

/* Constant definitions. */
#define MILLISEC         100	/* how often to call the scheduler (msec) */
#define SCHED_RATE (MILLISEC*HZ/1000)	/* number of ticks per schedule */

/* Clock parameters. */
#if (CHIP == INTEL)
#define COUNTER_FREQ (2*TIMER_FREQ) /* counter frequency using square wave */
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
PRIVATE timer_t *timers;	/* list of active timers */
PRIVATE clock_t next_timer;	/* when the first timer expires */
PRIVATE timer_t tmr_alarm[NR_PROCS];	/* timers for alarm(2) */

/* Variables changed by interrupt handler */
PRIVATE clock_t pending_ticks;	/* ticks seen by low level only */
PRIVATE int sched_ticks = SCHED_RATE;	/* counter: when 0, call scheduler */
PRIVATE struct proc *prev_ptr;	/* last user process run by clock task */

FORWARD _PROTOTYPE( void do_clocktick, (void) );
FORWARD _PROTOTYPE( void do_get_time, (message *m_ptr) );
FORWARD _PROTOTYPE( void do_getuptime, (message *m_ptr) );
FORWARD _PROTOTYPE( void do_set_time, (message *m_ptr) );
FORWARD _PROTOTYPE( void do_setalarm, (message *m_ptr, int handler,
						tmr_func_t function) );
FORWARD _PROTOTYPE( void init_clock, (void) );
FORWARD _PROTOTYPE( void cause_alarm, (timer_t *tp) );
FORWARD _PROTOTYPE( void cause_synalarm, (timer_t *tp) );
#if (MACHINE != ATARI)
FORWARD _PROTOTYPE( int clock_handler, (irq_hook_t *hook) );
#endif /* MACHINE != ATARI */

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
  message mc;			/* message buffer for both input and output */
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
	case GET_UPTIME: do_getuptime(&mc);	break;
	case GET_TIME:	 do_get_time(&mc);	break;
	case SET_TIME:	 do_set_time(&mc);	break;
	case SET_ALARM:	 do_setalarm(&mc, CLOCK, cause_alarm);	break;
	case SET_SYNC_AL:do_setalarm(&mc, SYN_ALRM_TASK, cause_synalarm); break;
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
  timer_t *tp;
  struct proc *p;

  if (next_timer <= realtime) {
	/* One or more timers may have expired.  If so move the expired timers
	 * to the per-task expired timers list and alert the task.
	 */
	while ((tp = timers) != NULL && tp->tmr_exp_time <= realtime) {
		timers = tp->tmr_next;
		p= proc_addr(tp->tmr_task);
		if (p->p_exptimers == NULL && p != proc_ptr) {
			interrupt(tp->tmr_task);
		}
		tp->tmr_next = p->p_exptimers;
		p->p_exptimers = tp;
	}

	/* When does the next timer expire? */
	next_timer = timers == NULL ? TMR_NEVER : timers->tmr_exp_time;

	/* It's possible that one of the clock's own timers expired. */
	tmr_exptimers();
  }

  /* If a user process has been running too long, pick another one. */
  if (--sched_ticks == 0) {
	if (bill_ptr == prev_ptr) lock_sched();	/* process has run too long */
	sched_ticks = SCHED_RATE;		/* reset quantum */
	prev_ptr = bill_ptr;			/* new previous process */
  }
#if (SHADOWING == 1)
  if (rdy_head[SHADOW_Q]) unshadow(rdy_head[SHADOW_Q]);
#endif /* SHADOWING */

}

/*===========================================================================*
 *				tmr_settimer				     *
 *===========================================================================*/
PUBLIC void tmr_settimer(tp, task, exp_time, fp)
timer_t *tp;
int task;
clock_t exp_time;
tmr_func_t fp;
{
  /* Activate a timer to run function 'fp' at time 'exp_time'.  The timer
   * is to be owned by the given task.  (Usually the clock task, the calling
   * task itself or the synchronous alarm task.)
   */
  timer_t **atp;

  if (tp->tmr_exp_time != TMR_NEVER) tmr_clrtimer(tp);
  tp->tmr_task = task;
  tp->tmr_exp_time = exp_time;
  tp->tmr_func = fp;

  /* Put the timer in the list of active timers with the first to expire in
   * front.
   */
  for (atp = &timers; *atp != NULL; atp = &(*atp)->tmr_next) {
	if (exp_time < (*atp)->tmr_exp_time) break;
  }
  tp->tmr_next = *atp;
  *atp = tp;
  
  /* The new timer may be the first. */
  next_timer = timers->tmr_exp_time;
}

/*===========================================================================*
 *				tmr_clrtimer				     *
 *===========================================================================*/
PUBLIC void tmr_clrtimer(tp)
timer_t *tp;
{
  /* Deactivate a timer by removing it from the active and expired lists. */
  timer_t **atp;
  struct proc *p;

  tp->tmr_exp_time = TMR_NEVER;

  for (atp = &timers; *atp != NULL; atp = &(*atp)->tmr_next) {
	if (*atp == tp) {
		*atp = tp->tmr_next;
		return;
	}
  }

  p = proc_addr(tp->tmr_task);
  for (atp = &p->p_exptimers; *atp != NULL; atp = &(*atp)->tmr_next) {
	if (*atp == tp) {
		*atp = tp->tmr_next;
		return;
	}
  }
}

/*===========================================================================*
 *				tmr_exptimers				     *
 *===========================================================================*/
PUBLIC void tmr_exptimers()
{
  /* One or more timers of the caller may have expired.  Run the functions
   * they reference and deactivate the timers.  This function must be called
   * by the clock task if its main timer expires, or by a task in its main
   * loop if p_exptimers is non-NULL.
   */
  timer_t *tp;
  struct proc *p;

  p = proc_ptr;

  while ((tp = p->p_exptimers) != NULL) {
	p->p_exptimers = tp->tmr_next;
	tp->tmr_exp_time = TMR_NEVER;
	(*tp->tmr_func)(tp);
  }
}

/*===========================================================================*
 *				do_getuptime				     *
 *===========================================================================*/
PRIVATE void do_getuptime(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Get and return the current clock uptime in ticks. */

  m_ptr->NEW_TIME = realtime;	/* current uptime */
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
PRIVATE void do_get_time(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Get and return the current clock time in seconds. */

  m_ptr->NEW_TIME = boot_time + realtime/HZ;	/* current real time */
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
PRIVATE void do_setalarm(m_ptr, handler, function)
message *m_ptr;			/* pointer to request message */
int handler;			/* CLOCK or SYN_ALRM_TASK */
tmr_func_t function;		/* cause_alarm or cause_synalarm */
{
/* A process requests an alarm signal or a synchronous alarm. */

  register struct proc *rp;
  int proc_nr;			/* which process wants the alarm */
  long delta_ticks;		/* in how many clock ticks does he want it? */
  timer_t *tp;

  /* Extract the parameters from the message. */
  proc_nr = m_ptr->CLOCK_PROC_NR;	/* process to interrupt later */
  delta_ticks = m_ptr->DELTA_TICKS;	/* how many ticks to wait */

  rp = proc_addr(proc_nr);
  tp = &tmr_alarm[proc_nr];

  /* Return the number of seconds left on the old timer. */
  if (tp->tmr_exp_time <= realtime || tp->tmr_exp_time == TMR_NEVER) {
	m_ptr->SECONDS_LEFT = 0;
  } else {
	m_ptr->SECONDS_LEFT = (tp->tmr_exp_time - realtime + (HZ-1)) / HZ;
  }

  /* Clear or set the new timer. */
  if (delta_ticks == 0) {
	tmr_clrtimer(tp);
  } else {
	tmr_arg(tp)->ta_int = proc_nr;
	tmr_settimer(tp, handler, get_uptime() + delta_ticks, function);
  }
}

/*===========================================================================*
 *				cause_alarm				     *
 *===========================================================================*/
PRIVATE void cause_alarm(tp)
timer_t *tp;
{
/* Routine called if a timer goes off for a process that requested an SIGALRM
 * signal using the alarm(2) system call.  The timer argument contains the
 * process number of the process to signal.
 */

  cause_sig(tmr_arg(tp)->ta_int, SIGALRM);
}

/*===========================================================================*
 *				cause_synalarm				     *
 *===========================================================================*/
PRIVATE void cause_synalarm(tp)
timer_t *tp;
{
/* Routine called if a timer goes off and the process requested a synchronous
 * alarm.  Send that process a CLOCK_INT message.
 */
  message mess;

  mess.m_type= CLOCK_INT;
  send(tmr_arg(tp)->ta_int, &mess);
}

/*===========================================================================*
 *				syn_alrm_task				     *
 *===========================================================================*/
PUBLIC void syn_alrm_task()
{
/* Main program of the synchronous alarm task.
 * All this task ever does is expire timers that call the cause_synalarm
 * function that sends processes a CLOCK_INT message.  These alarm messages
 * are called synchronous alarms because, unlike a signals or the timers
 * run by the CLOCK task, a synchronous alarm is received by a process
 * when it is in a known part of its code, that is, when it has issued
 * a call to receive a message.
 */
  message mess;

  while (TRUE) {
	tmr_exptimers();		/* send synchronous alarms */

	receive(HARDWARE, &mess);	/* wait for an interrupt */
  }
}

/*===========================================================================*
 *				cancel_alarm				     *
 *===========================================================================*/
PUBLIC void cancel_alarm(proc_nr)
int proc_nr;			/* process to cancel alarm for */
{
/* Cancel the alarm timer of a process, probably because it has exited. */

  tmr_clrtimer(&tmr_alarm[proc_nr]);
}

/*===========================================================================*
 *				clock_handler				     *
 *===========================================================================*/
#if (MACHINE != ATARI)
PRIVATE int clock_handler(hook)
irq_hook_t *hook;
#else
PUBLIC int clock_handler(hook)
int hook;
#endif /* MACHINE != ATARI */
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
 *	next_timer, realtime, sched_ticks, bill_ptr, prev_ptr,
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

#if (MACHINE == IBM_PC)
  if (ps_mca) {
	/* Acknowledge the PS/2 clock interrupt. */
	outb(PORT_B, inb(PORT_B) | CLOCK_ACK_BIT);
  }
#endif /* MACHINE == IBM_PC */

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
#if (CHIP == INTEL) && ENABLE_PRINTER
  pr_restart();					/* possibly restart printer */
#endif
#if (CHIP == M68000)
  kb_timer();					/* keyboard repeat */
  if (sched_ticks == 1) fd_timer();		/* floppy deselect */
#endif

  if (next_timer <= now
	|| (sched_ticks == 1 && bill_ptr == prev_ptr
#if (SHADOWING == 0)
		&& rdy_head[USER_Q] != NIL_PROC)
#else
	&& (rdy_head[USER_Q] != NIL_PROC || rdy_head[SHADOW_Q] != NIL_PROC))
#endif /* SHADOWING */
  ) {
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
  static irq_hook_t clock_hook;

  outb(TIMER_MODE, SQUARE_WAVE);	/* set timer to run continuously */
  outb(TIMER0, TIMER_COUNT);		/* load timer low byte */
  outb(TIMER0, TIMER_COUNT >> 8);	/* load timer high byte */
  put_irq_handler(&clock_hook, CLOCK_IRQ, clock_handler);/* register handler */
  enable_irq(&clock_hook);		/* ready for clock interrupts */
}

/*===========================================================================*
 *				clock_stop				     *
 *===========================================================================*/
PUBLIC void clock_stop()
{
/* Reset the clock to the BIOS rate. (For rebooting) */

  outb(TIMER_MODE, 0x36);
  outb(TIMER0, 0);
  outb(TIMER0, 0);
}

/*==========================================================================*
 *				micro_delay				    *
 *==========================================================================*/
PUBLIC void micro_delay(micros)
unsigned long micros;
{
/* Delay some microseconds. */
  struct micro_state ms;

  micro_start(&ms);
  while (micro_elapsed(&ms) < micros) {}
}

/*==========================================================================*
 *				micro_start				    *
 *==========================================================================*/
PUBLIC void micro_start(msp)
struct micro_state *msp;
{
  /* Prepare for calls to micro_elapsed(). */
  msp->prev_count = 0;
  msp->accum_count = 0;
}

/*==========================================================================*
 *				micro_elapsed				    *
 *==========================================================================*/
PUBLIC unsigned long micro_elapsed(msp)
struct micro_state *msp;
{
  /* Return the number of microseconds since the call to micro_start().  Must
   * be polled rapidly.
   *
   * Micro_elapsed() is used by micro_delay() to busy wait until some
   * number of microseconds have elapsed.  Micro_elapsed() can also be
   * used to poll a device for some time.
   */
  unsigned count;

  /* Read the counter of channel 0 of the 8253A timer.  This counter counts
   * down at a rate of TIMER_FREQ and restarts at TIMER_COUNT-1 when it
   * reaches zero.  We count each tick here, unlike the main task that cares
   * more about the HZ per second restarts.
   */
  lock();
  outb(TIMER_MODE, LATCH_COUNT);
  count = inb(TIMER0);
  count |= (inb(TIMER0) << 8);
  unlock();

  /* Add difference between previous and new count unless the counter has
   * increased (restarted its cycle).  In that case add 1, which should be
   * correct when polling rapidly.
   */
  msp->accum_count += count <= msp->prev_count ? (msp->prev_count - count) : 1;
  msp->prev_count = count;

  /* Return the number of microseconds counted, avoiding overflow. */
  if (msp->accum_count < ULONG_MAX / 1000000) {
	/* Precise for about 3600 us. */
	return msp->accum_count * 1000000 / TIMER_FREQ;
  } else {
	/* Longer periods need not be so precise. */
	return msp->accum_count / TIMER_FREQ * 1000000;
  }
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
