/* This task handles the interface between file system and kernel as well as
 * between memory manager and kernel.  System services are obtained by sending
 * sys_task() a message specifying what is needed.  To make life easier for
 * MM and FS, a library is provided with routines whose names are of the
 * form sys_xxx, e.g. sys_xit sends the SYS_XIT message to sys_task.  The
 * message types and parameters are:
 *
 *   SYS_FORK	 informs kernel that a process has forked
 *   SYS_NEWMAP	 allows MM to set up a process memory map
 *   SYS_EXEC	 sets program counter and stack pointer after EXEC
 *   SYS_XIT	 informs kernel that a process has exited
 *   SYS_GETSP	 caller wants to read out some process' stack pointer
 *   SYS_TIMES	 caller wants to get accounting times for a process
 *   SYS_ABORT	 MM or FS cannot go on; abort MINIX
#if (CHIP == M68000)
 *   SYS_FRESH	 start with a fresh process image during EXEC
#endif
 *   SYS_SIG	 send a signal to a process
 *   SYS_KILL	 cause a signal to be sent via MM
 *   SYS_COPY	 requests a block of data to be copied between processes
 *   SYS_GBOOT	 copies the boot parameters to a process
 *   SYS_UMAP	 compute the physical address for a given virtual address
 *   SYS_MEM	 returns the next free chunk of physical memory 
 *   SYS_TRACE	 request a trace operation
 *
 * Message type m1 is used for all except SYS_SIG and SYS_COPY, both of
 * which need special parameter types.
 *
 *    m_type       PROC1     PROC2      PID     MEM_PTR   
 * ------------------------------------------------------
 * | SYS_FORK   | parent  |  child  |   pid   |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_NEWMAP | proc nr |         |         | map ptr |
 * |------------+---------+---------+---------+---------|
 * | SYS_EXEC   | proc nr | traced  | new sp  |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_XIT    | parent  | exitee  |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_GETSP  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_TIMES  | proc nr |         | buf ptr |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_ABORT  |         |         |         |         |
#if (CHIP == M68000)
 * |------------+---------+---------+---------+---------|
 * | SYS_FRESH  | proc nr | data_cl |         |         |
#endif
 * |------------+---------+---------+---------+---------|
 * | SYS_GBOOT  | proc nr |         |         | bootptr |
 * ------------------------------------------------------
 *
 *
 *    m_type       m2_i1     m2_i2     m2_l1     m2_l2     
 * ------------------------------------------------------
 * | SYS_TRACE  | proc_nr | request |  addr   |  data   |
 * ------------------------------------------------------
 *
 *
 *    m_type       m6_i1     m6_i2     m6_i3     m6_f1     
 * ------------------------------------------------------
 * | SYS_SIG    | proc_nr  |  sig    |         | handler |
 * ------------------------------------------------------
 * | SYS_KILL   | proc_nr  |  sig    |         |         |
 * ------------------------------------------------------
 *
 *
 *    m_type      m5_c1   m5_i1    m5_l1   m5_c2   m5_i2    m5_l2   m5_l3
 * --------------------------------------------------------------------------
 * | SYS_COPY   |src seg|src proc|src vir|dst seg|dst proc|dst vir| byte ct |
 * --------------------------------------------------------------------------
 * | SYS_UMAP   |  seg  |proc nr |vir adr|       |        |       | byte ct |
 * --------------------------------------------------------------------------
 *
 *
 *    mem_type    DEVICE    PROC_NR    COUNT   POSITION
 * |------------+---------+---------+---------+---------|
 * | SYS_MEM    | extflag |         |mem size |mem base |
 * ------------------------------------------------------
 *
 * In addition to the main sys_task() entry point, there are 5 other minor
 * entry points:
 *   cause_sig:	take action to cause a signal to occur, sooner or later
 *   inform:	tell MM about pending signals
 *   numap:	umap D segment starting from process number instead of pointer
 *   umap:	compute the physical address for a given virtual address
 *   alloc_segments: allocate segments for 8088 or higher processor
 */

#include "kernel.h"
#include <signal.h>
#include <minix/boot.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"
#if (CHIP == INTEL)
#include "protect.h"
#endif

PRIVATE message m;
PRIVATE char sig_stuff[SIG_PUSH_BYTES];	/* used to send signals to processes */

FORWARD int do_abort();
FORWARD int do_copy();
FORWARD int do_exec();
FORWARD int do_fork();
FORWARD int do_gboot();
FORWARD int do_getsp();
FORWARD int do_kill();
FORWARD int do_mem();
FORWARD int do_newmap();
FORWARD int do_sig();
FORWARD int do_times();
FORWARD int do_trace();
FORWARD int do_umap();
FORWARD int do_xit();
#if (CHIP == M68000)
FORWARD void build_sig();
#endif

/*===========================================================================*
 *				sys_task				     *
 *===========================================================================*/
PUBLIC void sys_task()
{
/* Main entry point of sys_task.  Get the message and dispatch on type. */

  register int r;

  while (TRUE) {
	receive(ANY, &m);

	switch (m.m_type) {	/* which system call */
	    case SYS_FORK:	r = do_fork(&m);	break;
	    case SYS_NEWMAP:	r = do_newmap(&m);	break;
	    case SYS_EXEC:	r = do_exec(&m);	break;
	    case SYS_XIT:	r = do_xit(&m);		break;
	    case SYS_GETSP:	r = do_getsp(&m);	break;
	    case SYS_TIMES:	r = do_times(&m);	break;
	    case SYS_ABORT:	r = do_abort(&m);	break;
#if (CHIP == M68000)
	    case SYS_FRESH:	r = do_fresh(&m);	break;
#endif
	    case SYS_SIG:	r = do_sig(&m);		break;
	    case SYS_KILL:	r = do_kill(&m);	break;
	    case SYS_COPY:	r = do_copy(&m);	break;
	    case SYS_GBOOT:	r = do_gboot(&m);	break;
	    case SYS_UMAP:	r = do_umap(&m);	break;
	    case SYS_MEM:	r = do_mem(&m);		break;
	    case SYS_TRACE:	r = do_trace(&m);	break;
	    default:		r = E_BAD_FCN;
	}

	m.m_type = r;		/* 'r' reports status of call */
	send(m.m_source, &m);	/* send reply to caller */
  }
}


/*===========================================================================*
 *				do_fork					     * 
 *===========================================================================*/
PRIVATE int do_fork(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_fork().  m_ptr->PROC1 has forked.  The child is m_ptr->PROC2. */

#if (CHIP == INTEL)
  reg_t old_ldt_sel;
#endif 
  register struct proc *rpc;
  struct proc *rpp;

  if (!isoksusern(m_ptr->PROC1) || !isoksusern(m_ptr->PROC2))
	return(E_BAD_PROC);
  rpp = proc_addr(m_ptr->PROC1);
  rpc = proc_addr(m_ptr->PROC2);

  /* Copy parent 'proc' struct to child. */
#if (CHIP == INTEL)
  old_ldt_sel = rpc->p_ldt_sel;	/* stop this being obliterated by copy */
  *rpc = *rpp;
  rpc->p_ldt_sel = old_ldt_sel;
#else
  phys_copy( rpp, (phys_bytes)proc_addr(m_ptr->PROC2),
	     (phys_bytes)sizeof(struct proc));
#endif 
  rpc->p_nr = m_ptr->PROC2;	/* this was obliterated by copy */

#if (CHIP != M68000)
  rpc->p_flags |= NO_MAP;	/* inhibit the process from running */
#endif
  rpc->p_flags &= ~(PENDING | SIG_PENDING | P_STOP);
				/* only one in group should have PENDING */
				/* child does not inherit trace status */
  rpc->p_pending = 0;
  rpc->p_pendcount = 0;
  rpc->p_pid = m_ptr->PID;	/* install child's pid */
  rpc->p_reg.retreg = 0;	/* child sees pid = 0 to know it is child */

  rpc->user_time = 0;		/* set all the accounting times to 0 */
  rpc->sys_time = 0;
  rpc->child_utime = 0;
  rpc->child_stime = 0;
#if (CHIP == M68000)
  rpc->p_nflips = 0;
  mkshadow(rpp, (phys_clicks)m_ptr->m1_p1);	/* run child first */
#endif
  return(OK);
}


/*===========================================================================*
 *				do_newmap				     * 
 *===========================================================================*/
PRIVATE int do_newmap(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_newmap().  Fetch the memory map from MM. */

  register struct proc *rp, *rsrc;
  phys_bytes src_phys, dst_phys, pn;
  vir_bytes vmm, vsys, vn;
  int caller;			/* whose space has the new map (usually MM) */
  int k;			/* process whose map is to be loaded */
#if (CHIP != M68000)
  int old_flags;		/* value of flags before modification */
#endif
  struct mem_map *map_ptr;	/* virtual address of map inside caller (MM) */

  /* Extract message parameters and copy new memory map from MM. */
  caller = m_ptr->m_source;
  k = m_ptr->PROC1;
  map_ptr = (struct mem_map *) m_ptr->MEM_PTR;
  if (!isokprocn(k)) return(E_BAD_PROC);
  rp = proc_addr(k);		/* ptr to entry of user getting new map */
  rsrc = proc_addr(caller);	/* ptr to MM's proc entry */
  vn = NR_SEGS * sizeof(struct mem_map);
  pn = vn;
  vmm = (vir_bytes) map_ptr;	/* careful about sign extension */
  vsys = (vir_bytes) rp->p_map;	/* again, careful about sign extension */
  if ( (src_phys = umap(rsrc, D, vmm, vn)) == 0)
	panic("bad call to sys_newmap (src)", NO_NUM);
  if ( (dst_phys = umap(proc_ptr, D, vsys, vn)) == 0)
	panic("bad call to sys_newmap (dst)", NO_NUM);
  phys_copy(src_phys, dst_phys, pn);

#if (CHIP != M68000)
  alloc_segments(rp);
  old_flags = rp->p_flags;	/* save the previous value of the flags */
  rp->p_flags &= ~NO_MAP;
  if (old_flags != 0 && rp->p_flags == 0) lock_ready(rp);
#endif

  return(OK);
}


/*===========================================================================*
 *				do_exec					     * 
 *===========================================================================*/
PRIVATE int do_exec(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_exec().  A process has done a successful EXEC. Patch it up. */

  register struct proc *rp;
  int *sp;			/* new sp */

  sp = (int *) m_ptr->STACK_PTR;	/* bad ptr type */
  if (!isoksusern(m_ptr->PROC1)) return E_BAD_PROC;
  if (m_ptr->PROC2) cause_sig(m_ptr->PROC1, SIGTRAP);
  rp = proc_addr(m_ptr->PROC1);
  rp->p_reg.sp = (reg_t) sp;	/* set the stack pointer (bad type) */
#if (CHIP == M68000)
  rp->p_splow = (reg_t) sp;	/* set the stack pointer low water */
  rp->p_reg.pc = (reg_t) ((vir_bytes)rp->p_map[T].mem_vir << CLICK_SHIFT);
#else
  rp->p_reg.pc = 0;		/* reset pc */
#endif
  rp->p_alarm = 0;		/* reset alarm timer */
  rp->p_flags &= ~RECEIVING;	/* MM does not reply to EXEC call */
  if (rp->p_flags == 0) lock_ready(rp);
  set_name(m_ptr->PROC1, (char *)sp); /* save command string for F1 display */
  return(OK);
}


/*===========================================================================*
 *				do_xit					     * 
 *===========================================================================*/
PRIVATE int do_xit(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_xit().  A process has exited. */

  register struct proc *rp, *rc;
  struct proc *np, *xp;
  int parent;			/* number of exiting proc's parent */
  int proc_nr;			/* number of process doing the exit */
#if (CHIP == M68000)
  phys_clicks base, size;
#endif

  parent = m_ptr->PROC1;	/* slot number of parent process */
  proc_nr = m_ptr->PROC2;	/* slot number of exiting process */
  if (!isoksusern(parent) || !isoksusern(proc_nr)) return(E_BAD_PROC);
  rp = proc_addr(parent);
  rc = proc_addr(proc_nr);
  lock();
  rp->child_utime += rc->user_time + rc->child_utime;	/* accum child times */
  rp->child_stime += rc->sys_time + rc->child_stime;
  unlock();
  rc->p_alarm = 0;		/* turn off alarm timer */
  if (rc->p_flags == 0) lock_unready(rc);
#if (CHIP == M68000)
  rmshadow(rc, &base, &size);
  m_ptr->m1_i1 = (int)base;
  m_ptr->m1_i2 = (int)size;
#endif
  set_name(proc_nr, (char *) 0);	/* disable command printing for F1 */

  /* If the process being terminated happens to be queued trying to send a
   * message (i.e., the process was killed by a signal, rather than it doing an
   * EXIT), then it must be removed from the message queues.
   */
  if (rc->p_flags & SENDING) {
	/* Check all proc slots to see if the exiting process is queued. */
	for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++) {
		if (rp->p_callerq == NIL_PROC) continue;
		if (rp->p_callerq == rc) {
			/* Exiting process is on front of this queue. */
			rp->p_callerq = rc->p_sendlink;
			break;
		} else {
			/* See if exiting process is in middle of queue. */
			np = rp->p_callerq;
			while ( ( xp = np->p_sendlink) != NIL_PROC)
				if (xp == rc) {
					np->p_sendlink = xp->p_sendlink;
					break;
				} else {
					np = xp;
				}
		}
	}
  }
  if (rc->p_flags & PENDING) --sig_procs;
  rc->p_pending = 0;
  rc->p_pendcount = 0;
  rc->p_flags = P_SLOT_FREE;
  return(OK);
}


/*===========================================================================*
 *				do_getsp				     * 
 *===========================================================================*/
PRIVATE int do_getsp(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_getsp().  MM wants to know what sp is. */

  register struct proc *rp;

  if (!isoksusern(m_ptr->PROC1)) return(E_BAD_PROC);
  rp = proc_addr(m_ptr->PROC1);
  m.STACK_PTR = (char *) rp->p_reg.sp;	/* return sp here (bad type) */
  return(OK);
}


/*===========================================================================*
 *				do_times				     * 
 *===========================================================================*/
PRIVATE int do_times(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_times().  Retrieve the accounting information. */

  register struct proc *rp;

  if (!isoksusern(m_ptr->PROC1)) return E_BAD_PROC;
  rp = proc_addr(m_ptr->PROC1);

  /* Insert the four times needed by the TIMES system call in the message. */
  lock();
  m_ptr->USER_TIME   = rp->user_time;
  m_ptr->SYSTEM_TIME = rp->sys_time;
  unlock();
  m_ptr->CHILD_UTIME = rp->child_utime;
  m_ptr->CHILD_STIME = rp->child_stime;
  return(OK);
}


/*===========================================================================*
 *				do_abort				     * 
 *===========================================================================*/
PRIVATE int do_abort(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_abort.  MINIX is unable to continue.  Terminate operation. */

  panic("", NO_NUM);
  return(OK);			/* pro-forma (really EDISASTER) */
}


#if (CHIP == M68000)
/*===========================================================================*
 *				do_fresh				     * 
 *===========================================================================*/
PRIVATE int do_fresh(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_fresh.  Start with fresh process image during EXEC. */
  register struct proc *p;
  int proc_nr;			/* number of process doing the exec */
  phys_clicks base, size;
  phys_clicks c1, nc;

  proc_nr = m_ptr->PROC1;	/* slot number of exec-ing process */
  if (proc_nr < 0 || proc_nr >= NR_PROCS)
	return(E_BAD_PROC);
  p = proc_addr(proc_nr);
  rmshadow(p, &base, &size);
  do_newmap(m_ptr);
  c1 = p->p_map[D].mem_phys;
  nc = p->p_map[S].mem_phys - p->p_map[D].mem_phys + p->p_map[S].mem_len;
  c1 += m_ptr->m1_i2;
  nc -= m_ptr->m1_i2;
  zeroclicks(c1, nc);
  m_ptr->m1_i1 = (int)base;
  m_ptr->m1_i2 = (int)size;
  return(OK);
}
#endif /* (CHIP == M68000) */


/*===========================================================================*
 *				do_sig					     * 
 *===========================================================================*/
PRIVATE int do_sig(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_sig(). Signal a process.  The stack is known to be big enough. */

  register struct proc *rp;
  phys_bytes src_phys, dst_phys;
  vir_bytes vir_addr, sig_size, new_sp;
  int proc_nr;			/* process number */
  int sig;			/* signal number 1-16 */
  void (*sig_handler)();	/* pointer to the signal handler */

  /* Extract parameters and prepare to build the words that get pushed. */
  proc_nr = m_ptr->PR;		/* process being signalled */
  if (!isokusern(proc_nr)) return(E_BAD_PROC);
  rp = proc_addr(proc_nr);
  sig = m_ptr->SIGNUM;		/* signal number, 1 to 16 */
  if (sig == -1) {
	/* Except -1 is kludged to mean "finished one KSIG". */
	if (rp->p_pendcount != 0 &&
	    --rp->p_pendcount == 0 &&
	    (rp->p_flags &= ~SIG_PENDING) == 0)
		lock_ready(rp);
	return(OK);
  }
  sig_handler = m_ptr->FUNC;	/* run time system addr for catching sigs */
  vir_addr = (vir_bytes) sig_stuff;	/* info to be pushed is in 'sig_stuff' */
  new_sp = (vir_bytes) rp->p_reg.sp;

  /* Actually build the block of words to push onto the stack. */
  build_sig(sig_stuff, rp, sig);	/* build up the info to be pushed */

  /* Prepare to do the push, and do it. */
  sig_size = SIG_PUSH_BYTES;
  new_sp -= sig_size;
  src_phys = umap(proc_ptr, D, vir_addr, sig_size);
  dst_phys = umap(rp, S, new_sp, sig_size);
  if (dst_phys == 0) panic("do_sig can't signal; SP bad", NO_NUM);
  phys_copy(src_phys, dst_phys, (phys_bytes) sig_size);	/* push pc, psw */

  /* Change process' sp and pc to reflect the interrupt. */
  rp->p_reg.sp = new_sp;
  rp->p_reg.pc = (reg_t) sig_handler;	/* bad ptr type */
  return(OK);
}


/*===========================================================================
 *				do_kill					     * 
 *===========================================================================*/
PRIVATE int do_kill(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_kill(). Cause a signal to be sent to a process via MM. */

  int proc_nr;			/* process number */
  int sig;			/* signal number 1-16 */

  proc_nr = m_ptr->PR;		/* process being signalled */
  sig = m_ptr->SIGNUM;		/* signal number, 1 to 16 */
  if (!isokusern(proc_nr)) return(E_BAD_PROC);
  cause_sig(proc_nr, sig);
  return(OK);
}


/*==========================================================================*
 *				do_trace				    *
 *==========================================================================*/

#define PROCNR	(m->m2_i1)
#define REQUEST (m->m2_i2)
#define ADDR	((vir_bytes) m->m2_l1)
#define DATA	(m->m2_l2)
#define VLSIZE	((vir_bytes) sizeof(long))

PRIVATE int do_trace(m)
register message *m;
{
  register struct proc *rp;
  phys_bytes src, dst;
  int i;

  rp = proc_addr(PROCNR);
  if (rp->p_flags & P_SLOT_FREE) return(EIO);
  switch (REQUEST) {
  case -1:			/* stop process */
	lock_unready(rp);
	rp->p_flags |= P_STOP;
	rp->p_reg.psw &= ~TRACEBIT;	/* clear trace bit */
	return(OK);
  case 1:			/* return value from instruction space */
	if (rp->p_map[T].mem_len != 0) {
		if ((src = umap(rp, T, ADDR, VLSIZE)) == 0) return(EIO);
		dst = umap(proc_ptr, D, (vir_bytes) &DATA, VLSIZE);
		phys_copy(src, dst, (phys_bytes) sizeof(long));
		break;
	}
	/* Text space is actually data space - fall through. */
  case 2:			/* return value from data space */
	if ((src = umap(rp, D, ADDR, VLSIZE)) == 0) return(EIO);
	dst = umap(proc_ptr, D, (vir_bytes) &DATA, VLSIZE);
	phys_copy(src, dst, (phys_bytes) sizeof(long));
	break;
  case 3:			/* return value from process table */
	if ((ADDR & (sizeof(long) - 1)) != 0 ||
	    ADDR > sizeof(struct proc) - sizeof(long))
		return(EIO);
	DATA = *(long *) ((char *) rp + (int) ADDR);
	break;
  case 4:			/* set value from instruction space */
	if (rp->p_map[T].mem_len != 0) {
		if ((dst = umap(rp, T, ADDR, VLSIZE)) == 0) return(EIO);
		src = umap(proc_ptr, D, (vir_bytes) &DATA, VLSIZE);
		phys_copy(src, dst, (phys_bytes) sizeof(long));
		DATA = 0;
		break;
	}
	/* Text space is actually data space - fall through. */
  case 5:			/* set value from data space */
	if ((dst = umap(rp, D, ADDR, VLSIZE)) == 0) return(EIO);
	src = umap(proc_ptr, D, (vir_bytes) &DATA, VLSIZE);
	phys_copy(src, dst, (phys_bytes) sizeof(long));
	DATA = 0;
	break;
  case 6:			/* set value in process table */
	if ((ADDR & (sizeof(reg_t) - 1)) != 0 ||
	     ADDR > sizeof(struct stackframe_s) - sizeof(reg_t))
		return(EIO);
	i = (int) ADDR;
#if (CHIP == INTEL)
	/* Altering segment registers might crash the kernel when it
	 * tries to load them prior to restarting a process, so do
	 * not allow it.
	 */
	if (i == (int) &((struct proc *) 0)->p_reg.cs ||
	    i == (int) &((struct proc *) 0)->p_reg.ds ||
	    i == (int) &((struct proc *) 0)->p_reg.es ||
#if INTEL_32BITS
	    i == (int) &((struct proc *) 0)->p_reg.gs ||
	    i == (int) &((struct proc *) 0)->p_reg.fs ||
#endif
	    i == (int) &((struct proc *) 0)->p_reg.ss)
		return(EIO);
#endif
	if (i == (int) &((struct proc *) 0)->p_reg.psw)
		/* only selected bits are changeable */
		SETBITS(rp, DATA);
	else
		*(reg_t *) ((char *) &rp->p_reg + i) = (reg_t) DATA;
	DATA = 0;
	break;
  case 7:			/* resume execution */
	rp->p_flags &= ~P_STOP;
	if (rp->p_flags == 0) lock_ready(rp);
	DATA = 0;
	break;
  case 9:			/* set trace bit */
	rp->p_reg.psw |= TRACEBIT;
	rp->p_flags &= ~P_STOP;
	if (rp->p_flags == 0) lock_ready(rp);
	DATA = 0;
	break;
  default:
	return(EIO);
  }
  return(OK);
}


/*===========================================================================*
 *				do_copy					     *
 *===========================================================================*/
PRIVATE int do_copy(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_copy().  Copy data for MM or FS. */

  int src_proc, dst_proc, src_space, dst_space;
  vir_bytes src_vir, dst_vir;
  phys_bytes src_phys, dst_phys, bytes;

  /* Dismember the command message. */
  src_proc = m_ptr->SRC_PROC_NR;
  dst_proc = m_ptr->DST_PROC_NR;
  src_space = m_ptr->SRC_SPACE;
  dst_space = m_ptr->DST_SPACE;
  src_vir = (vir_bytes) m_ptr->SRC_BUFFER;
  dst_vir = (vir_bytes) m_ptr->DST_BUFFER;
  bytes = (phys_bytes) m_ptr->COPY_BYTES;

  /* Compute the source and destination addresses and do the copy. */
#if (CHIP != M68000)
  if (src_proc == ABS)
	src_phys = (phys_bytes) m_ptr->SRC_BUFFER;
  else
#endif
	src_phys = umap(proc_addr(src_proc),src_space,src_vir,(vir_bytes)bytes);

#if (CHIP != M68000)
  if (dst_proc == ABS)
	dst_phys = (phys_bytes) m_ptr->DST_BUFFER;
  else
#endif
	dst_phys = umap(proc_addr(dst_proc),dst_space,dst_vir,(vir_bytes)bytes);

  if (src_phys == 0 || dst_phys == 0) return(EFAULT);
  phys_copy(src_phys, dst_phys, bytes);
  return(OK);
}


/*===========================================================================*
 *				cause_sig				     * 
 *===========================================================================*/
PUBLIC void cause_sig(proc_nr, sig_nr)
int proc_nr;			/* process to be signalled */
int sig_nr;			/* signal to be sent in range 1 - 16 */
{
/* A task wants to send a signal to a process.   Examples of such tasks are:
 *   TTY wanting to cause SIGINT upon getting a DEL
 *   CLOCK wanting to cause SIGALRM when timer expires
 * Signals are handled by sending a message to MM.  The tasks don't dare do
 * that directly, for fear of what would happen if MM were busy.  Instead they
 * call cause_sig, which sets bits in p_pending, and then carefully checks to
 * see if MM is free.  If so, a message is sent to it.  If not, when it becomes
 * free, a message is sent.  The process being signaled is blocked while MM
 * has not seen or finished with all signals for it.  These signals are
 * counted in p_pendcount, and the SIG_PENDING flag is kept nonzero while
 * there are some.  It is not sufficient to ready the process when MM is
 * informed, because MM can block waiting for FS to do a core dump.
 */

  register struct proc *rp, *mmp;

  rp = proc_addr(proc_nr);
  if (rp->p_pending & (1 << (sig_nr - 1)))
	return;			/* this signal already pending */
  rp->p_pending |= 1 << (sig_nr - 1);
  ++rp->p_pendcount;		/* count new signal pending */
  if (rp->p_flags & PENDING)
	return;			/* another signal already pending */
  if (rp->p_flags == 0) lock_unready(rp);
  rp->p_flags |= PENDING | SIG_PENDING;
  ++sig_procs;			/* count new process pending */

  mmp = cproc_addr(MM_PROC_NR);
  if ( ((mmp->p_flags & RECEIVING) == 0) || mmp->p_getfrom != ANY)
	return;
  inform();
}


/*===========================================================================*
 *				inform					     * 
 *===========================================================================*/
PUBLIC void inform()
{
/* When a signal is detected by the kernel (e.g., DEL), or generated by a task
 * (e.g. clock task for SIGALRM), cause_sig() is called to set a bit in the
 * p_pending field of the process to signal.  Then inform() is called to see
 * if MM is idle and can be told about it.  Whenever MM blocks, a check is
 * made to see if 'sig_procs' is nonzero; if so, inform() is called.
 */

  register struct proc *rp;

  /* MM is waiting for new input.  Find a process with pending signals. */
  for (rp = BEG_SERV_ADDR; rp < END_PROC_ADDR; rp++)
	if (rp->p_flags & PENDING) {
		m.m_type = KSIG;
		m.PROC1 = proc_number(rp);
		m.SIG_MAP = rp->p_pending;
		sig_procs--;
		if (lock_mini_send(cproc_addr(HARDWARE), MM_PROC_NR, &m) != OK)
			panic("can't inform MM", NO_NUM);
		rp->p_pending = 0;	/* the ball is now in MM's court */
		rp->p_flags &= ~PENDING;/* remains inhibited by SIG_PENDING */
#if (MACHINE == ATARI)
		/* SIGSTKFLT is not generated in the PC version. */
		if (m.SIG_MAP == (1 << (SIGSTKFLT - 1))) {
			if (rp->p_pendcount != 0 &&
			    --rp->p_pendcount == 0 &&
			    (rp->p_flags &= ~SIG_PENDING) == 0)
				lock_ready(rp);
		}
#endif
		lock_pick_proc();	/* avoid delay in scheduling MM */
		return;
	}
}


/*==========================================================================*
 *				numap					    *
 *==========================================================================*/
PUBLIC phys_bytes numap(proc_nr, vir_addr, bytes)
int proc_nr;			/* process number to be mapped */
vir_bytes vir_addr;		/* virtual address in bytes within D seg */
vir_bytes bytes;		/* # of bytes required in segment  */
{
/* Do umap() starting from a process number instead of a pointer.  This
 * function is used by device drivers, so they need not know about the
 * process table.  To save time, there is no 'seg' parameter. The segment
 * is always D.
 */

  return(umap(proc_addr(proc_nr), D, vir_addr, bytes));
}


/*===========================================================================*
 *				umap					     * 
 *===========================================================================*/
PUBLIC phys_bytes umap(rp, seg, vir_addr, bytes)
register struct proc *rp;	/* pointer to proc table entry for process */
int seg;			/* T, D, or S segment */
vir_bytes vir_addr;		/* virtual address in bytes within the seg */
vir_bytes bytes;		/* # of bytes to be copied */
{
/* Calculate the physical memory address for a given virtual address. */
  vir_clicks vc;		/* the virtual address in clicks */
  phys_bytes seg_base, pa;	/* intermediate variables as phys_bytes */

  /* If 'seg' is D it could really be S and vice versa.  T really means T.
   * If the virtual address falls in the gap,  it causes a problem. On the
   * 8088 it is probably a legal stack reference, since "stackfaults" are
   * not detected by the hardware.  On 8088s, the gap is called S and
   * accepted, but on other machines it is called D and rejected.
   * The Atari ST behaves like the 8088 in this respect.
   */

  if (bytes <= 0) return( (phys_bytes) 0);
  vc = (vir_addr + bytes - 1) >> CLICK_SHIFT;	/* last click of data */

#if (CHIP == INTEL) || (CHIP == M68000)
  if (seg != T)
	seg = (vc < rp->p_map[D].mem_vir + rp->p_map[D].mem_len ? D : S);
#else
  if (seg != T)
	seg = (vc < rp->p_map[S].mem_vir ? D : S);
#endif

  if((vir_addr>>CLICK_SHIFT) >= rp->p_map[seg].mem_vir + rp->p_map[seg].mem_len)
	return( (phys_bytes) 0 );
#if (CHIP == INTEL)
  seg_base = (phys_bytes) rp->p_map[seg].mem_phys;
  seg_base = seg_base << CLICK_SHIFT;	/* segment origin in bytes */
#endif
  pa = (phys_bytes) vir_addr;
#if (CHIP != M68000)
  pa -= rp->p_map[seg].mem_vir << CLICK_SHIFT;
  return(seg_base + pa);
#endif
#if (CHIP == M68000)
  if (rp->p_shadow && seg != T) {
	pa -= (phys_bytes)rp->p_map[D].mem_phys << CLICK_SHIFT;
	pa += (phys_bytes)rp->p_shadow << CLICK_SHIFT;
  }
  return(pa);
#endif
}


#if (CHIP == INTEL)
/*==========================================================================*
 *				alloc_segments				    *
 *==========================================================================*/
PUBLIC void alloc_segments(rp)
register struct proc *rp;
{
  phys_bytes code_bytes;
  phys_bytes data_bytes;
  int privilege;

  if (protected_mode) {
	data_bytes = (phys_bytes) (rp->p_map[S].mem_vir + rp->p_map[S].mem_len)
	             << CLICK_SHIFT;
	if (rp->p_map[T].mem_len == 0)
		code_bytes = data_bytes;	/* common I&D, poor protect */
	else
		code_bytes = (phys_bytes) rp->p_map[T].mem_len << CLICK_SHIFT;
	privilege = istaskp(rp) ? TASK_PRIVILEGE : USER_PRIVILEGE;
	init_codeseg(&rp->p_ldt[CS_LDT_INDEX],
		     (phys_bytes) rp->p_map[T].mem_phys << CLICK_SHIFT,
		     code_bytes, privilege);
	init_dataseg(&rp->p_ldt[DS_LDT_INDEX],
		     (phys_bytes) rp->p_map[D].mem_phys << CLICK_SHIFT,
		     data_bytes, privilege);
	rp->p_reg.cs = (CS_LDT_INDEX * DESC_SIZE) | TI | privilege;
#if INTEL_32BITS
	rp->p_reg.gs =
	rp->p_reg.fs =
#endif
	rp->p_reg.ss =
	rp->p_reg.es =
	rp->p_reg.ds = (DS_LDT_INDEX*DESC_SIZE) | TI | privilege;
  } else {
	rp->p_reg.cs = click_to_hclick(rp->p_map[T].mem_phys);
	rp->p_reg.ss =
	rp->p_reg.es =
	rp->p_reg.ds = click_to_hclick(rp->p_map[D].mem_phys);
  }
}
#endif /* (CHIP == INTEL) */


/*==========================================================================*
 *				do_gboot				    *
 *==========================================================================*/
PUBLIC struct bparam_s boot_parameters = {	/* overwritten if new boot */
  DROOTDEV, DRAMIMAGEDEV, DRAMSIZE, DSCANCODE, DPROCESSOR,
};

PRIVATE int do_gboot(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Copy the boot parameters.  Normally only called during fs init. */

  phys_bytes src_phys, dst_phys;

  src_phys = umap(proc_ptr, D, (vir_bytes) &boot_parameters,
		  (vir_bytes) sizeof(boot_parameters));
  if ( (dst_phys = umap(proc_addr(m_ptr->PROC1), D,
			(vir_bytes) m_ptr->MEM_PTR,
			(vir_bytes) sizeof(boot_parameters))) == 0)
	panic("bad call to SYS_GBOOT", NO_NUM);
  phys_copy(src_phys, dst_phys, (phys_bytes) sizeof(boot_parameters));
  return(OK);
}


/*==========================================================================*
 *				do_umap					    *
 *==========================================================================*/
PRIVATE int do_umap(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Same as umap(), for non-kernel processes. */

  m_ptr->SRC_BUFFER = umap(proc_addr((int) m_ptr->SRC_PROC_NR),
                           (int) m_ptr->SRC_SPACE,
                           (vir_bytes) m_ptr->SRC_BUFFER,
                           (vir_bytes) m_ptr->COPY_BYTES);
  return(OK);
}


/*===========================================================================*
 *				do_mem					     *
 *===========================================================================*/
PRIVATE int do_mem(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Return the base and size of the next chunk of memory of a given type. */

#if (CHIP == INTEL)
  unsigned mem;

  for (mem = 0; mem < NR_MEMS; ++mem) {
	if (mem_type[mem] & 0x80) {
	    mem_size[mem] = check_mem((phys_bytes) mem_base[mem]<<CLICK_SHIFT,
				      (phys_bytes) mem_size[mem]<<CLICK_SHIFT)
			   >> CLICK_SHIFT;
		mem_type[mem] &= ~0x80;
	}
	if (mem_size[mem] != 0 && m_ptr->DEVICE == mem_type[mem]) {
		m_ptr->COUNT = mem_size[mem];
		m_ptr->POSITION = mem_base[mem];
		mem_size[mem] = 0;	/* now MM has it */
		return(OK);
	}
  }
  m_ptr->COUNT = 0;		/* no more */
#endif /* (CHIP == INTEL) */

#if (MACHINE == ATARI)
  long i;
  static int beenhere = 0;

  if (beenhere)
	m_ptr->COUNT = 0;
  else {
	/* The ST fills address 0x0436 with the memory size when starting. */
	phys_copy((phys_bytes)0x0436, (phys_bytes)&i, (phys_bytes)sizeof(i));
	m_ptr->COUNT =  i >> CLICK_SHIFT;
	beenhere++;
  }
#endif /* (MACHINE == ATARI) */

  m_ptr->POSITION = 0;
  return(OK);
}


#if (CHIP == M68000)
/*===========================================================================*
 *                              build_sig                                    *
 *===========================================================================*/
PRIVATE void build_sig(sig_stuff, rp, sig)
char *sig_stuff;
register struct proc *rp;
int sig;
{
  register struct frame {
		int	f_sig;
		u16_t	f_psw;
		reg_t	f_pc;
  } *fp;

  fp = (struct frame *)sig_stuff;
  fp->f_sig = sig;
  fp->f_psw = rp->p_reg.psw;
  fp->f_pc = rp->p_reg.pc;
}
#endif /* (CHIP == M68000) */
