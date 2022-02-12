/* This file contains essentially all of the process and message handling.
 * It has two main entry points from the outside:
 *
 *   sys_call:   called when a process or task does SEND, RECEIVE or SENDREC
 *   interrupt:	called by interrupt routines to send a message to task
 *
 * It also has several minor entry points:
 *
 *   lock_ready:      put a process on one of the ready queues so it can be run
 *   lock_unready:    remove a process from the ready queues
 *   lock_sched:      a process has run too long; schedule another one
 *   lock_mini_send:  send a message (used by interrupt signals, etc.)
 *   lock_pick_proc:  pick a process to run (used by system initialization)
 *   unhold:          repeat all held-up interrupts
 */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

PRIVATE unsigned char switching;	/* nonzero to inhibit interrupt() */

FORWARD int mini_send();
FORWARD int mini_rec();
FORWARD void pick_proc();
FORWARD void ready();
FORWARD void sched();
FORWARD void unready();

#if (CHIP == INTEL)
#define CopyMess(s,sp,sm,dp,dm) \
	cp_mess(s,(sp)->p_map[D].mem_phys,sm,(dp)->p_map[D].mem_phys,dm)
#endif
#if (CHIP == M68000)
#define CopyMess(s,sp,sm,dp,dm) \
	cp_mess(s,sp,sm,dp,dm)
#endif

/*===========================================================================*
 *				interrupt				     * 
 *===========================================================================*/
PUBLIC void interrupt(task)
int task;			/* number of task to be started */
{
/* An interrupt has occurred.  Schedule the task that handles it. */

  register struct proc *rp;	/* pointer to task's proc entry */

  rp = proc_addr(task);

  /* If this call would compete with other process-switching functions, put
   * it on the 'held' queue to be flushed at the next non-competing restart().
   * The competing conditions are:
   * (1) k_reenter == (typeof k_reenter) -1:
   *     Call from the task level, typically from an output interrupt
   *     routine.  An interrupt handler might reenter interrupt().  Rare,
   *     so not worth special treatment.
   * (2) k_reenter > 0:
   *     Call from a nested interrupt handler.  A previous interrupt handler
   *     might be inside interrupt() or sys_call().
   * (3) switching != 0:
   *     Some process-switching function other than interrupt() is being
   *     called from the task level, typically sched() from CLOCK.  An
   *     interrupt handler might call interrupt and pass the k_reenter test.
   */
  if (k_reenter != 0 || switching) {
	lock();
	if (!rp->p_int_held) {
		rp->p_int_held = TRUE;
		if (held_head != NIL_PROC)
			held_tail->p_nextheld = rp;
		else
			held_head = rp;
		held_tail = rp;
		rp->p_nextheld = NIL_PROC;
	}
	unlock();
	return;
  }

  /* If task is not waiting for an interrupt, record the blockage. */
  if ( (rp->p_flags & (RECEIVING | SENDING)) != RECEIVING ||
      !isrxhardware(rp->p_getfrom)) {
	rp->p_int_blocked = TRUE;
	return;
  }

  /* Destination is waiting for an interrupt.
   * Send it a message with source HARDWARE and type HARD_INT.
   * No more information can be reliably provided since interrupt messages
   * are not queued.
   */
  rp->p_messbuf->m_source = HARDWARE;
  rp->p_messbuf->m_type = HARD_INT;
  rp->p_flags &= ~RECEIVING;
  rp->p_int_blocked = FALSE;

   /* Make rp ready and run it unless a task is already running.  This is
    * ready(rp) in-line for speed.
    */
  if (rdy_head[TASK_Q] != NIL_PROC)
	rdy_tail[TASK_Q]->p_nextready = rp;
  else
#if (CHIP != M68000)
	proc_ptr =
#endif
	rdy_head[TASK_Q] = rp;
  rdy_tail[TASK_Q] = rp;
  rp->p_nextready = NIL_PROC;
}


/*===========================================================================*
 *				sys_call				     * 
 *===========================================================================*/
PUBLIC int sys_call(function, src_dest, m_ptr)
int function;			/* SEND, RECEIVE, or BOTH */
int src_dest;			/* source to receive from or dest to send to */
message *m_ptr;			/* pointer to message */
{
/* The only system calls that exist in MINIX are sending and receiving
 * messages.  These are done by trapping to the kernel with an INT instruction.
 * The trap is caught and sys_call() is called to send or receive a message
 * (or both). The caller is always given by proc_ptr.
 */

  register struct proc *rp;
  int n;

  /* Check for bad system call parameters. */
  if (!isoksrc_dest(src_dest)) return(E_BAD_SRC);
  rp = proc_ptr;
  if (function != BOTH && isuserp(rp))
	return(E_NO_PERM);	/* users only do BOTH */

  /* The parameters are ok. Do the call. */
  if (function & SEND) {
	/* Function = SEND or BOTH. */
	n = mini_send(rp, src_dest, m_ptr);
	if (function == SEND || n != OK)
		return(n);	/* done, or SEND failed */
  }

  /* Function = RECEIVE or BOTH.
   * We have checked user calls are BOTH, and trust 'function' otherwise.
   */
  return(mini_rec(rp, src_dest, m_ptr));
}


/*===========================================================================*
 *				mini_send				     * 
 *===========================================================================*/
PRIVATE int mini_send(caller_ptr, dest, m_ptr)
register struct proc *caller_ptr;	/* who is trying to send a message? */
int dest;			/* to whom is message being sent? */
message *m_ptr;			/* pointer to message buffer */
{
/* Send a message from 'caller_ptr' to 'dest'. If 'dest' is blocked waiting
 * for this message, copy the message to it and unblock 'dest'. If 'dest' is
 * not waiting at all, or is waiting for another source, queue 'caller_ptr'.
 */

  register struct proc *dest_ptr, *next_ptr;
  vir_bytes vb;			/* message buffer pointer as vir_bytes */
  vir_clicks vlo, vhi;		/* virtual clicks containing message to send */

  /* User processes are only allowed to send to FS and MM.  Check for this. */
  if (isuserp(caller_ptr) && !isservn(dest)) return(E_BAD_DEST);
  dest_ptr = proc_addr(dest);	/* pointer to destination's proc entry */
  if (dest_ptr->p_flags & P_SLOT_FREE) return(E_BAD_DEST);	/* dead dest */

  /* Check for messages wrapping around top of memory or outside data seg. */
  vb = (vir_bytes) m_ptr;
  vlo = vb >> CLICK_SHIFT;	/* vir click for bottom of message */
  vhi = (vb + MESS_SIZE - 1) >> CLICK_SHIFT;	/* vir click for top of msg */
  if (vhi < vlo ||
      vhi - caller_ptr->p_map[D].mem_vir >= caller_ptr->p_map[D].mem_len)
	return(E_BAD_ADDR);

  /* Check for deadlock by 'caller_ptr' and 'dest' sending to each other. */
  if (dest_ptr->p_flags & SENDING) {
	next_ptr = caller_ptr->p_callerq;
	while (next_ptr != NIL_PROC) {
		if (next_ptr == dest_ptr) return(ELOCKED);
		next_ptr = next_ptr->p_sendlink;
	}
  }

  /* Check to see if 'dest' is blocked waiting for this message. */
  if ( (dest_ptr->p_flags & (RECEIVING | SENDING)) == RECEIVING &&
       (dest_ptr->p_getfrom == ANY ||
        dest_ptr->p_getfrom == proc_number(caller_ptr))) {
	/* Destination is indeed waiting for this message. */
	CopyMess(proc_number(caller_ptr), caller_ptr, m_ptr, dest_ptr,
		 dest_ptr->p_messbuf);
	dest_ptr->p_flags &= ~RECEIVING;	/* deblock destination */
	if (dest_ptr->p_flags == 0) ready(dest_ptr);
  } else {
	/* Destination is not waiting.  Block and queue caller. */
	caller_ptr->p_messbuf = m_ptr;
	if (caller_ptr->p_flags == 0) unready(caller_ptr);
	caller_ptr->p_flags |= SENDING;

	/* Process is now blocked.  Put in on the destination's queue. */
	if ( (next_ptr = dest_ptr->p_callerq) == NIL_PROC)
		dest_ptr->p_callerq = caller_ptr;
	else {
		while (next_ptr->p_sendlink != NIL_PROC)
			next_ptr = next_ptr->p_sendlink;
		next_ptr->p_sendlink = caller_ptr;
	}
	caller_ptr->p_sendlink = NIL_PROC;
  }
  return(OK);
}


/*===========================================================================*
 *				mini_rec				     * 
 *===========================================================================*/
PRIVATE int mini_rec(caller_ptr, src, m_ptr)
register struct proc *caller_ptr;	/* process trying to get message */
int src;			/* which message source is wanted (or ANY) */
message *m_ptr;			/* pointer to message buffer */
{
/* A process or task wants to get a message.  If one is already queued,
 * acquire it and deblock the sender.  If no message from the desired source
 * is available, block the caller.  No need to check parameters for validity.
 * Users calls are always sendrec(), and mini_send() has checked already.  
 * Calls from the tasks, MM, and FS are trusted.
 */

  register struct proc *sender_ptr;
  register struct proc *previous_ptr;

  /* Check to see if a message from desired source is already available. */
  if (!(caller_ptr->p_flags & SENDING)) {
	/* Check caller queue. */
    for (sender_ptr = caller_ptr->p_callerq; sender_ptr != NIL_PROC;
	 previous_ptr = sender_ptr, sender_ptr = sender_ptr->p_sendlink) {
	if (src == ANY || src == proc_number(sender_ptr)) {
		/* An acceptable message has been found. */
		CopyMess(proc_number(sender_ptr), sender_ptr,
			 sender_ptr->p_messbuf, caller_ptr, m_ptr);
		if (sender_ptr == caller_ptr->p_callerq)
			caller_ptr->p_callerq = sender_ptr->p_sendlink;
		else
			previous_ptr->p_sendlink = sender_ptr->p_sendlink;
		if ((sender_ptr->p_flags &= ~SENDING) == 0)
			ready(sender_ptr);	/* deblock sender */
		return(OK);
	}
    }

    /* Check for blocked interrupt. */
    if (caller_ptr->p_int_blocked && isrxhardware(src)) {
	m_ptr->m_source = HARDWARE;
	m_ptr->m_type = HARD_INT;
	caller_ptr->p_int_blocked = FALSE;
	return(OK);
    }
  }

  /* No suitable message is available.  Block the process trying to receive. */
  caller_ptr->p_getfrom = src;
  caller_ptr->p_messbuf = m_ptr;
  if (caller_ptr->p_flags == 0) unready(caller_ptr);
  caller_ptr->p_flags |= RECEIVING;

  /* If MM has just blocked and there are kernel signals pending, now is the
   * time to tell MM about them, since it will be able to accept the message.
   */
  if (sig_procs > 0 && proc_number(caller_ptr) == MM_PROC_NR && src == ANY)
	inform();
  return(OK);
}


/*===========================================================================*
 *				pick_proc				     * 
 *===========================================================================*/
PRIVATE void pick_proc()
{
/* Decide who to run now.  A new process is selected by setting 'proc_ptr'.
 * When a fresh user (or idle) process is selected, record it in 'bill_ptr',
 * so the clock task can tell who to bill for system time.
 */

  register struct proc *rp;	/* process to run */

  if ( (rp = rdy_head[TASK_Q]) != NIL_PROC) {
	proc_ptr = rp;
	return;
  }
  if ( (rp = rdy_head[SERVER_Q]) != NIL_PROC) {
	proc_ptr = rp;
	return;
  }
  if ( (rp = rdy_head[USER_Q]) != NIL_PROC) {
	proc_ptr = rp;
	bill_ptr = rp;
	return;
  }
  /* No one is ready.  Run the idle task.  The idle task might be made an
   * always-ready user task to avoid this special case.
   */
  bill_ptr = proc_ptr = cproc_addr(IDLE);
}


/*===========================================================================*
 *				ready					     * 
 *===========================================================================*/
PRIVATE void ready(rp)
register struct proc *rp;	/* this process is now runnable */
{
/* Add 'rp' to the end of one of the queues of runnable processes. Three
 * queues are maintained:
 *   TASK_Q   - (highest priority) for runnable tasks
 *   SERVER_Q - (middle priority) for MM and FS only
 *   USER_Q   - (lowest priority) for user processes
 */

  if (istaskp(rp)) {
	if (rdy_head[TASK_Q] != NIL_PROC)
		/* Add to tail of nonempty queue. */
		rdy_tail[TASK_Q]->p_nextready = rp;
	else
{
#if (CHIP != M68000)
		proc_ptr =		/* run fresh task next */
#endif
		rdy_head[TASK_Q] = rp;	/* add to empty queue */
}
	rdy_tail[TASK_Q] = rp;
	rp->p_nextready = NIL_PROC;	/* new entry has no successor */
	return;
  }
  if (!isuserp(rp)) {		/* others are similar */
	if (rdy_head[SERVER_Q] != NIL_PROC)
		rdy_tail[SERVER_Q]->p_nextready = rp;
	else
		rdy_head[SERVER_Q] = rp;
	rdy_tail[SERVER_Q] = rp;
	rp->p_nextready = NIL_PROC;
	return;
  }
#if (CHIP == M68000)
  if (isshadowp(rp)) {		/* others are similar */
	if (rdy_head[SHADOW_Q] != NIL_PROC)
		rdy_tail[SHADOW_Q]->p_nextready = rp;
	else
		rdy_head[SHADOW_Q] = rp;
	rdy_tail[SHADOW_Q] = rp;
	rp->p_nextready = NIL_PROC;
	return;
  }
#endif
  if (rdy_head[USER_Q] != NIL_PROC)
	rdy_tail[USER_Q]->p_nextready = rp;
  else
	rdy_head[USER_Q] = rp;
  rdy_tail[USER_Q] = rp;
  rp->p_nextready = NIL_PROC;
}


/*===========================================================================*
 *				unready					     * 
 *===========================================================================*/
PRIVATE void unready(rp)
register struct proc *rp;	/* this process is no longer runnable */
{
/* A process has blocked. */

  register struct proc *xp;
  register struct proc **qtail;  /* TASK_Q, SERVER_Q, or USER_Q rdy_tail */

  if (istaskp(rp)) {
	if ( (xp = rdy_head[TASK_Q]) == NIL_PROC) return;
	if (xp == rp) {
		/* Remove head of queue */
		rdy_head[TASK_Q] = xp->p_nextready;
		if (rp == proc_ptr) pick_proc();
		return;
	}
	qtail = &rdy_tail[TASK_Q];
  }
  else if (!isuserp(rp)) {
	if ( (xp = rdy_head[SERVER_Q]) == NIL_PROC) return;
	if (xp == rp) {
		rdy_head[SERVER_Q] = xp->p_nextready;
#if (CHIP == M68000)
		if (rp == proc_ptr)
#endif
		pick_proc();
		return;
	}
	qtail = &rdy_tail[SERVER_Q];
  } else
#if (CHIP == M68000)
  if (isshadowp(rp)) {
	if ( (xp = rdy_head[SHADOW_Q]) == NIL_PROC) return;
	if (xp == rp) {
		rdy_head[SHADOW_Q] = xp->p_nextready;
		if (rp == proc_ptr)
			pick_proc();
		return;
	}
	qtail = &rdy_tail[SHADOW_Q];
  } else
#endif
  {
	if ( (xp = rdy_head[USER_Q]) == NIL_PROC) return;
	if (xp == rp) {
		rdy_head[USER_Q] = xp->p_nextready;
#if (CHIP == M68000)
		if (rp == proc_ptr)
#endif
		pick_proc();
		return;
	}
	qtail = &rdy_tail[USER_Q];
  }

  /* Search body of queue.  A process can be made unready even if it is
   * not running by being sent a signal that kills it.
   */
  while (xp->p_nextready != rp)
	if ( (xp = xp->p_nextready) == NIL_PROC) return;
  xp->p_nextready = xp->p_nextready->p_nextready;
  while (xp->p_nextready != NIL_PROC) xp = xp->p_nextready;
  *qtail = xp;
}


/*===========================================================================*
 *				sched					     * 
 *===========================================================================*/
PRIVATE void sched()
{
/* The current process has run too long.  If another low priority (user)
 * process is runnable, put the current process on the end of the user queue,
 * possibly promoting another user to head of the queue.
 */

  if (rdy_head[USER_Q] == NIL_PROC) return;

  /* One or more user processes queued. */
  rdy_tail[USER_Q]->p_nextready = rdy_head[USER_Q];
  rdy_tail[USER_Q] = rdy_head[USER_Q];
  rdy_head[USER_Q] = rdy_head[USER_Q]->p_nextready;
  rdy_tail[USER_Q]->p_nextready = NIL_PROC;
  pick_proc();
}


/*==========================================================================*
 *				lock_mini_send				    *
 *==========================================================================*/
PUBLIC int lock_mini_send(caller_ptr, dest, m_ptr)
struct proc *caller_ptr;	/* who is trying to send a message? */
int dest;			/* to whom is message being sent? */
message *m_ptr;			/* pointer to message buffer */
{
/* Safe gateway to mini_send() for tasks. */

  int result;

  switching = TRUE;
  result = mini_send(caller_ptr, dest, m_ptr);
  switching = FALSE;
  return(result);
}


/*==========================================================================*
 *				lock_pick_proc				    *
 *==========================================================================*/
PUBLIC void lock_pick_proc()
{
/* Safe gateway to pick_proc() for tasks. */

  switching = TRUE;
  pick_proc();
  switching = FALSE;
}


/*==========================================================================*
 *				lock_ready				    *
 *==========================================================================*/
PUBLIC void lock_ready(rp)
struct proc *rp;		/* this process is now runnable */
{
/* Safe gateway to ready() for tasks. */

  switching = TRUE;
  ready(rp);
  switching = FALSE;
}


/*==========================================================================*
 *				lock_sched				    *
 *==========================================================================*/
PUBLIC void lock_sched()
{
/* Safe gateway to lock_sched() for tasks. */

  switching = TRUE;
  sched();
  switching = FALSE;
}


/*==========================================================================*
 *				lock_unready				    *
 *==========================================================================*/
PUBLIC void lock_unready(rp)
struct proc *rp;		/* this process is no longer runnable */
{
/* Safe gateway to ready() for tasks. */

  switching = TRUE;
  unready(rp);
  switching = FALSE;
}


/*==========================================================================*
 *				unhold					    *
 *==========================================================================*/
PUBLIC void unhold()
{
/* Flush any held-up interrupts.  k_reenter must be 0.  held_head must not
 * be NIL_PROC.  Interrupts must be disabled.  They will be enabled but will
 * be disabled when this returns.
 */

  register struct proc *rp;	/* current head of held queue */

  if (switching) return;
  rp = held_head;
  do {
	if ( (held_head = rp->p_nextheld) == NIL_PROC) held_tail = NIL_PROC;
	rp->p_int_held = FALSE;
	unlock();		/* reduce latency; held queue may change! */
	interrupt(proc_number(rp));
	lock();			/* protect the held queue again */
  }
  while ( (rp = held_head) != NIL_PROC);
}


#if (CHIP == M68000)
/*==========================================================================*
 *				cp_mess					    *
 *==========================================================================*/
PRIVATE void cp_mess(src, src_p, src_m, dst_p, dst_m)
int src;			/* sender process */
register struct proc *src_p;	/* source proc entry */
message *src_m;			/* source message */
register struct proc *dst_p;	/* destination proc entry */
message *dst_m;			/* destination buffer */
{
  register vir_clicks clk;

  if (clk = src_p->p_shadow) {
	clk -= src_p->p_map[D].mem_phys;
	src_m = (message *)((char *)src_m + ((phys_bytes)clk << CLICK_SHIFT));
  }
  if (clk = dst_p->p_shadow) {
	clk -= dst_p->p_map[D].mem_phys;
	dst_m = (message *)((char *)dst_m + ((phys_bytes)clk << CLICK_SHIFT));
  }
#ifdef NEEDFSTRUCOPY
  phys_copy(src_m,dst_m,(phys_bytes) sizeof(message));
#else
  *dst_m = *src_m;
#endif
  dst_m->m_source = src;
}
#endif
